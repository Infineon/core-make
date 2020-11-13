#!/usr/bin/env python3

import argparse
import os.path
import ntpath
import re
import sys
from datetime import datetime
from pathlib import PurePath
from collections import namedtuple
from collections import defaultdict
from xml.dom import minidom
from xml.etree import ElementTree

GRP_UNFILTERED = "unf:/tered*"

REMOVE_QUOTE_REGEX = re.compile(r"^\"|\"$")

# cmsisdata.temp file format
# ------------------------------------#
# AppName
# Device
# Core
# Linker script
# Defines (Comma separated list)
# Include Paths (Comma separated list)
# .c Source Files (Comma separated list)
# .S Asm Files (Comma separated list)
# .h Header files (Comma separated list)
# .a Lib files (Comma separated list)
# --------------------------------------

def parseCmsisData(fileName):
    """
    Parses a .cmsisdata file to extract the information necessary for project connection file creation

    Returns a tuple of (project_name device_name core linker_script defineList includePathList cSrcList asmSrcList headersList libsList searches getlibsSharedDir archName)
    """
    ProjectData = namedtuple("ProjectData", "projectName deviceName core linkerScript defineList includePathList cSrcList asmSrcList headersList libsList searches getlibsSharedDir archName")

    with open(fileName, 'r') as fp:
        projectName = fp.readline().strip()
        device = fp.readline().strip()
        core = fp.readline().strip()
        linkerScript = fp.readline().strip()
        # filter() returns an iteration which can only be used once
        # hence converting it back to a list to able to iterate multiple times.
        defineList = list(filter(None, fp.readline().strip().split(',')))
        includePathList = list(filter(None, fp.readline().strip().split(',')))
        cSrcList = list(filter(None, fp.readline().strip().split(',')))
        asmSrcList = list(filter(None, fp.readline().strip().split(',')))
        headersList = list(filter(None, fp.readline().strip().split(',')))
        libsList = list(filter(None, fp.readline().strip().split(',')))
        searches = list(filter(None, fp.readline().strip().split(',')))
        getlibsSharedDir = fp.readline().strip()
        archName = fp.readline().strip()

    return ProjectData(projectName, device, core, linkerScript, defineList, includePathList, cSrcList, asmSrcList, headersList, libsList, searches, getlibsSharedDir, archName)

def getDuplicateFiles(sourceList):
    seen = set()
    dups = []
    for file in sourceList:
        fileNameExt = os.path.basename(cleanUpPath(file))
        fileName = os.path.splitext(fileNameExt)[0]
        if fileName not in seen:
            seen.add(fileName)
        else:
            dups.append(fileNameExt)
    return dups

def cleanUpPath(path):
    """
    This function:
    1) Removes extra beginning/trailing quotes, spaces and newlines.
    2) Normalizes the paths.
    3) Appends './' to all paths. All paths are assumed to be relative to the Makefile.

    Returns a clean up path.
    """
    # Remove extra quotes and spaces
    cleanPath = path.strip()
    cleanPath = cleanPath.strip("\"")
    # The normalize operation needs to happen before prepend project directory 
    # variable operation. After appending the placeholder variable to the output 
    # is not a standard path so the normalize operation does not work correctly
    cleanPath = ntpath.normpath(cleanPath)
    # Append project dir
    if cleanPath != ".":
        cleanPath = ntpath.join('./', cleanPath)
    # Replace backslashes with slashes
    cleanPath = cleanPath.replace('\\', '/')
    return cleanPath

def cleanUpDefine(define):
    """
    This function:
    1) Removes extra beginning/trailing quotes, spaces and newlines.
    2) Changes to Windows style slashes for paths in defines.

    Returns a clean up path.
    """
    # Remove extra quotes and trailing spacess
    cleanDefine = define.strip()
    cleanDefine = REMOVE_QUOTE_REGEX.sub("", cleanDefine)
    # Normalize paths in defines if any present.
    cleanDefine = ntpath.normpath(cleanDefine)
    return cleanDefine

def printPretty(root):
    ugly = ElementTree.tostring(root, encoding='utf8', method='xml')
    parsed = minidom.parseString(ugly) 
    return parsed.toprettyxml(indent="  ", encoding='utf8')

def filterFiles(groupDict, searchDict, fileList, category):
    """
    Filters the files into groups. This function currently only support MTB project structure.
    It assumes a libs directory that contains all libaries used by the project and  creates a 
    group for each folder under libs directory. All application source is added at the top level
    project under Keil uVision.
    """

    for fileName in fileList:
        cleanFile = cleanUpPath(fileName)
        # 'include' path should end with slash
        if category == 'include' and not cleanFile.endswith('/'):
            cleanFile += '/'
        dirsList = PurePath(cleanFile).parts
        # uVision with GCC toolchain creates *.o files in the project root
        # Exclude generated object files (auto-discovered in incremental exports)
        if cleanFile.endswith('.o') and len(dirsList) == 1:
            print("WARNING: object file {0} was not added to the generated .cpdsc, add manually as needed".format(cleanFile))
            continue
        try:
            # Find the first libs directory.
            index = dirsList.index("libs")
            # Any child of libs directory is a group.
            grp = dirsList[index + 1]
            groupDict[grp].append((cleanFile, category))
        except (ValueError, IndexError) as e:
            addedToSearchGroup = False
            for k,v in searchDict.items():
                if cleanFile.startswith(k):
                    groupDict[v].append((cleanFile, category))
                    addedToSearchGroup = True
            if not addedToSearchGroup:
                groupDict[GRP_UNFILTERED].append((cleanFile, category))

def processSearches(sharedLibsDir, searches):
    cleanSharedLibsDir = cleanUpPath(sharedLibsDir)
    searchDict = {}

    for search in searches:
        cleanSearch = cleanUpPath(search)
        if cleanSharedLibsDir and cleanSearch.startswith(cleanSharedLibsDir):
            # group name for directory in getlibsShared is the name of all directory in search starting after the sharedlibs dir joined together with underscores
            searchDict[cleanSearch] = cleanSearch[len(cleanSharedLibsDir) + 1 : ].replace('/', '_')
        else:
            searchDict[cleanSearch] = os.path.basename(cleanSearch)
    return searchDict

def createFileElement(groupElem, fileName, category):
    ElementTree.SubElement(groupElem, 'file',
        {'category': category, 'name': fileName})

def getRootElement(projectName):
    """
    Create root XML tree with mandatory root elements
    """
    # Need PACK.xsd version >= 1.6.0 for Pre_Include_Global_h
    root = ElementTree.Element('package', {
        'xmlns:xs': 'http://www.w3.org/2001/XMLSchema-instance',
        'schemaVersion': "1.6.0",
        'xs:noNamespaceSchemaLocation': 'PACK.xsd'})

    # Add mandatory root elements
    # https://www.keil.com/pack/doc/CMSIS/Pack/html/cpdsc_pg.html#element_package_cpdsc
    ElementTree.SubElement(root, 'vendor').text = "Cypress"
    ElementTree.SubElement(root, 'name').text = projectName
    ElementTree.SubElement(root, 'description').text = "Generated by ModusToolbox"
    ElementTree.SubElement(root, 'url').text = "http://cypress.com/modustoolbox"
    releasesElem = ElementTree.SubElement(root, 'releases')
    releaseElem = ElementTree.SubElement(releasesElem, 'release', { 'version': "1.0.0" })
    releaseElem.text = datetime.now().strftime("Generated by ModusToolbox at %d/%m/%Y %H:%M:%S")

    return root

def generatePdsc(inFile, cpdscFile, gpdscFile, cprjFile):
    """
    Generates the CMSIS Description files based on data from Make Build system.
    """
    projectData = parseCmsisData(inFile)
    if projectData.deviceName == None:
        raise Exception("Invalid file format for input file.\n")

    searchDict = processSearches(projectData.getlibsSharedDir, projectData.searches)

    # Combine input file lists by groups
    groupDict = defaultdict(list)
    # Using CMSIS category 'source' for all firmware file types:
    # https://www.keil.com/pack/doc/CMSIS/Pack/html/pdsc_components_pg.html#FileCategoryEnum
    filterFiles(groupDict, searchDict, projectData.includePathList, 'include')
    filterFiles(groupDict, searchDict, projectData.headersList, 'source')
    filterFiles(groupDict, searchDict, projectData.cSrcList, 'source')
    filterFiles(groupDict, searchDict, projectData.asmSrcList, 'source')
    filterFiles(groupDict, searchDict, projectData.libsList, 'library')

    cSrcDups = getDuplicateFiles(projectData.cSrcList)
    asmSrcDups = getDuplicateFiles(projectData.asmSrcList)
    if len(cSrcDups) != 0 or len(asmSrcDups) != 0:
        print("WARNING: Keil uVision does not support files with the same "
              "name even if they have different extensions. There were multiple source "
              "files detected with name(s):", end = ' ')
        print(*cSrcDups, sep = ";", end=' ')
        print(*asmSrcDups, sep = ";")

    architectureElement = projectData.archName
    generateCpdsc(projectData, groupDict, cpdscFile, architectureElement)
    generateGpdsc(projectData, groupDict, gpdscFile)
    generateCprj(projectData, groupDict, cprjFile, architectureElement)

def generateCpdsc(projectData, groupDict, cpdscFile, architectureElement):
    """
    Generates CPDSC file
    """
    # Create root XML tree with mandatory root elements
    root = getRootElement(projectData.projectName)

    # Set package/compiler/language requirements
    requirementsElem = ElementTree.SubElement(root, 'requirements')
    packagesElem = ElementTree.SubElement(requirementsElem, 'packages')
    ElementTree.SubElement(packagesElem, 'package', { 'vendor': "Cypress", 'name': architectureElement})
    compilersElem = ElementTree.SubElement(requirementsElem, 'compilers')
    ElementTree.SubElement(compilersElem, 'compiler', { 'name': "ARMCC", 'version': "6.11.0" })
    languagesElem = ElementTree.SubElement(requirementsElem, 'languages')
    ElementTree.SubElement(languagesElem, 'language', { 'name': "C", 'version': "99" })

# Determine CPU Pname
    CORE_NAME_CM0P = 'CM0P'
    CORE_NAME_CM4 = 'CM4'
    processorName = ""
    if projectData.core == CORE_NAME_CM0P:
        processorName = 'Cortex-M0p'
    elif projectData.core == CORE_NAME_CM4:
        processorName = 'Cortex-M4'
    else:
        raise Exception("Core %s not supported by this export mechanism.\n Support core names are %s %s\n" % projectData.core, CORE_NAME_CM0P, CORE_NAME_CM4)

    # Set target device
    createElem = ElementTree.SubElement(root, 'create')
    projectElem = ElementTree.SubElement(createElem, 'project')
    targetElem = ElementTree.SubElement(projectElem, 'target',
        { 'Dname': projectData.deviceName, 'Pname': processorName, 'Dvendor': "Cypress:19"})

    # Add the application sources to the 'Source' group
    # The library sources are added by GPDSC
    filesElem = ElementTree.SubElement(projectElem, 'files')
    groupElem = ElementTree.SubElement(filesElem, "group", { 'name': "Source" })
    for fileName, category in groupDict[GRP_UNFILTERED]:
        createFileElement(groupElem, fileName, category)

    # Add the linker script from BSP (cannot be added by GPDSC)
    createFileElement(groupElem, projectData.linkerScript, 'linkerScript')

    # The printPretty function takes care of encoding hence the file is
    # opened in binary mode.
    with open(cpdscFile, 'wb') as opf:
        opf.write(printPretty(root))

    print("Generated CMSIS Project Description file: %s" % cpdscFile)

def generateGpdsc(projectData, groupDict, gpdscFile):
    """
    Generates GPDSC file
    """
    # Create root XML tree with mandatory root elements
    root = getRootElement(projectData.projectName)

    # Collect the list of global preincluded symbols
    includeText = ""
    # Exclude -DDEVICE from the list of defines - already added by CMSIS DFP
    deviceDefine = projectData.deviceName.replace('-', '_')
    for define in projectData.defineList:
        cleanDefine = cleanUpDefine(define).replace('=', ' ')
        if cleanDefine != deviceDefine:
            includeText += "\n#define {}".format(cleanDefine)
    includeElemAdded = False

    # Add the library sources
    componentsElem = ElementTree.SubElement(root, 'components')
    for grp in sorted(groupDict.keys()):
        if grp != GRP_UNFILTERED:
            componentElem = ElementTree.SubElement(componentsElem, 'component',
                {'Cvendor': "Cypress", 'Cclass': grp, 'Cgroup': "ModusToolbox" })
            if grp.startswith("TARGET") and not includeElemAdded:
                # Add Pre_Include_Global_h element to the first TARGET component
                includeElem = ElementTree.SubElement(componentElem, 'Pre_Include_Global_h')
                includeElem.text = includeText
                includeElemAdded = True
            filesElem = ElementTree.SubElement(componentElem, 'files')
            for fileName, category in groupDict[grp]:
                createFileElement(filesElem, fileName, category)

    if not includeElemAdded:
        print("WARNING: CMSIS exporter was not able to find the BSP library.")
        print("Preprocessor symbol definitions were NOT added to the generated project:")
        print(' '.join([cleanUpDefine(define) for define in projectData.defineList]))

    # The printPretty function takes care of encoding hence the file is
    # opened in binary mode.
    with open(gpdscFile, 'wb') as opf:
        opf.write(printPretty(root))

    print("Generated CMSIS Generator Package Description file: %s" % gpdscFile)


def createCrpjFileElement(groupElem, fileName, category, version):
    if os.path.splitext(fileName) == '.h':
        category = 'header'
    ElementTree.SubElement(groupElem, 'file',
        {'category': category, 'name': fileName, 'version': version})

def generateCprj(projectData, groupDict, cprjFile, architectureElement):
    """
    Generates CPDSC file
    """
    COMPILER_ATTR = 'AC6'

    # Create root XML tree with mandatory root elements
    root = ElementTree.Element('cprj', {
    'xmlns:xs': 'http://www.w3.org/2001/XMLSchema-instance',
    'schemaVersion': "1.0.0",
    'xs:noNamespaceSchemaLocation': 'CPRJ.xsd'})

    infoElem = ElementTree.SubElement(root, 'info', { 'isLayer': 'false' })
    ElementTree.SubElement(infoElem, 'description').text = "Generated by ModusToolbox"
    packagesElem = ElementTree.SubElement(root, 'packages')
    ElementTree.SubElement(packagesElem, 'package', { 'vendor': "Cypress", 'name': architectureElement})
    compilersElem = ElementTree.SubElement(root, 'compilers')
    ElementTree.SubElement(compilersElem, 'compiler', { 'name': COMPILER_ATTR, 'version': "6.11.0" })

    # Determine CPU Pname
    processorName = ""
    if projectData.core == "CM0P":
        processorName = 'Cortex-M0p'
    elif projectData.core == "CM4":
        processorName = 'Cortex-M4'
    else:
        raise Exception('Core %s not supported by this export mechanism.\n' % projectData.core)
    
    # Set defines
    deviceDefine = projectData.deviceName.replace('-', '_')
    includeText = ''
    for fileName, category in groupDict[GRP_UNFILTERED]:
        if category == 'include':
            includeText += ' -I' + fileName

    # target element
    targetElem = ElementTree.SubElement(root, 'target', { 'Dname': projectData.deviceName, 'Pname': processorName, 'Dvendor': 'Cypress:19'})
    ElementTree.SubElement(targetElem, 'output', { 'name': projectData.projectName, 'type': 'exe'})
    ElementTree.SubElement(targetElem, 'ldflags', { 'compiler': COMPILER_ATTR, 'file': projectData.linkerScript})
    compile_flags = '-Wno-packed -Wno-missing-variable-declarations -Wno-missing-prototypes -Wno-missing-noreturn -Wno-sign-conversion -Wno-nonportable-include-path -Wno-reserved-id-macro -Wno-unused-macros -Wno-documentation-unknown-command -Wno-documentation -Wno-license-management -Wno-parentheses-equality' + includeText
    ElementTree.SubElement(targetElem, 'cflags', { 'compiler': COMPILER_ATTR, 'add': '-std=c99 ' + compile_flags})
    ElementTree.SubElement(targetElem, 'cxxflags', { 'compiler': COMPILER_ATTR, 'add': '-std=c++11 ' + compile_flags})
    ElementTree.SubElement(targetElem, 'asflags', { 'compiler': COMPILER_ATTR, 'add': '-masm=armasm'})

    # components element
    componentsElem = ElementTree.SubElement(root, 'components')
    for grp in sorted(groupDict.keys()):
        if grp != GRP_UNFILTERED:
            componentElem = ElementTree.SubElement(componentsElem, 'component',
                {'Cvendor': 'Cypress', 'Cclass': grp, 'Cgroup': 'ModusToolbox' })
            # add include path before adding source files
            includePaths = ''
            for fileName, category in groupDict[grp]:
                if category == 'include':
                    if includePaths != '':
                        includePaths += ' '
                    includePaths += '-I' + fileName
            if includePaths != '':
                ElementTree.SubElement(componentElem, 'cflags', { 'compiler': COMPILER_ATTR, 'add': includePaths})
                ElementTree.SubElement(componentElem, 'cxxflags', { 'compiler': COMPILER_ATTR, 'add': includePaths})
            for fileName, category in groupDict[grp]:
                if category != 'include':
                    createCrpjFileElement(componentElem, fileName, category, '1.0.0')

    # Add the application sources to the 'Source' group
    # The library sources are added by GPDSC
    filesElem = ElementTree.SubElement(root, 'files')
    groupElem = ElementTree.SubElement(filesElem, "group", { 'name': 'Source' })
    for fileName, category in groupDict[GRP_UNFILTERED]:
        if category != 'include':
            createFileElement(groupElem, fileName, category)

    # The printPretty function takes care of encoding hence the file is
    # opened in binary mode.
    with open(cprjFile, 'wb') as opf:
        opf.write(printPretty(root))

    print('Generated CMSIS Project file: %s' % cprjFile)

def is_valid_file(parser, arg):
    if not os.path.isfile(arg):
        parser.error("The file %s does not exist!" % arg)
    return arg

def run_export():
    argParser = argparse.ArgumentParser()
    argParser.add_argument("-i", dest="inFile", required=True,
                    help="Project data file generated by `make TOOLCHAIN=ARM uvision5`", metavar="FILE",
                    type=lambda x: is_valid_file(argParser, x))
    argParser.add_argument("-cpdsc", dest="cpdscFile", required=False, 
                    help="CMSIS Project Description file. By default specified by make build system: (APPNAME).cpdsc", metavar="FILE")
    argParser.add_argument("-gpdsc", dest="gpdscFile", required=False, 
                    help="CMSIS Generator Package Description file. By default specified by make build system: (APPNAME).gpdsc", metavar="FILE")
    argParser.add_argument('-cprj', dest="cprjFile", required=False,
                    help="CMSIS Project File. By default specified by make build system: (APPNAME).cprj",
                    metavar="FILE")

    args = argParser.parse_args()

    generatePdsc(args.inFile, args.cpdscFile, args.gpdscFile, args.cprjFile)

if __name__ == '__main__':
    try:
        run_export()
    except Exception as error:
        print("ERROR: %s" % error)
        sys.exit(1)
