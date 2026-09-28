#!/usr/bin/env python3
"""Create a checked-in, dependency-free Xcode project. No generator is required on the Mac."""
import hashlib
import json
import plistlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
objects = {}

def oid(name):
    return hashlib.sha1(name.encode()).hexdigest()[:24].upper()

def add(identity, isa, **fields):
    key = oid(identity)
    objects[key] = dict(isa=isa, **fields)
    return key

def render(value, depth=0):
    pad = "\t" * depth
    if isinstance(value, dict):
        return "{\n" + "\n".join("\t" * (depth + 1) + json.dumps(str(k)) + " = " + render(v, depth + 1) + ";" for k, v in value.items()) + "\n" + pad + "}"
    if isinstance(value, list):
        return "(\n" + "\n".join("\t" * (depth + 1) + render(v, depth + 1) + "," for v in value) + "\n" + pad + ")"
    return json.dumps(str(value), ensure_ascii=False)

def main(root=ROOT, project_name="LearningApp"):
    global ROOT
    ROOT = Path(root)
    objects.clear()
    config = json.loads((ROOT / "Core/Resources/app-config.json").read_text())
    product_name = config["productName"]
    project_dir = ROOT / (project_name + ".xcodeproj")
    (project_dir / "xcshareddata/xcschemes").mkdir(parents=True, exist_ok=True)
    swift_files = sorted((ROOT / "App").glob("*.swift"))
    refs = []
    builds = []
    for file in swift_files:
        relative = file.relative_to(ROOT).as_posix()
        ref = add(relative, "PBXFileReference", lastKnownFileType="sourcecode.swift", path=relative, sourceTree="<group>")
        refs.append(ref); builds.append(add("build:" + relative, "PBXBuildFile", fileRef=ref))
    resources = []
    for path, file_type in [("App/Assets.xcassets", "folder.assetcatalog"), ("Configuration/PrivacyInfo.xcprivacy", "text.xml")]:
        ref = add(path, "PBXFileReference", lastKnownFileType=file_type, path=path, sourceTree="<group>")
        refs.append(ref); resources.append(add("build:" + path, "PBXBuildFile", fileRef=ref))
    info_ref = add("info", "PBXFileReference", lastKnownFileType="text.plist.xml", path="Configuration/Info.plist", sourceTree="<group>")
    storekit_ref = add("storekit", "PBXFileReference", lastKnownFileType="text", path="Configuration/Tips.storekit", sourceTree="<group>")
    product = add("product", "PBXFileReference", explicitFileType="wrapper.application", includeInIndex=0, path=product_name + ".app", sourceTree="BUILT_PRODUCTS_DIR")
    product_group = add("products", "PBXGroup", children=[product], name="Products", sourceTree="<group>")
    root_group = add("main", "PBXGroup", children=refs + [info_ref, storekit_ref, product_group], sourceTree="<group>")
    package = add("core-package", "XCLocalSwiftPackageReference", relativePath=".")
    dependency = add("core-product", "XCSwiftPackageProductDependency", package=package, productName="LearningCore")
    linked_core = add("core-link", "PBXBuildFile", productRef=dependency)
    source_phase = add("sources", "PBXSourcesBuildPhase", buildActionMask=2147483647, files=builds, runOnlyForDeploymentPostprocessing=0)
    resource_phase = add("resources", "PBXResourcesBuildPhase", buildActionMask=2147483647, files=resources, runOnlyForDeploymentPostprocessing=0)
    framework_phase = add("frameworks", "PBXFrameworksBuildPhase", buildActionMask=2147483647, files=[linked_core], runOnlyForDeploymentPostprocessing=0)
    # ENABLE_USER_SCRIPT_SANDBOXING lets a run script read only the inputs it declares, and
    # a declared folder does not cover the files inside it. Naming folders made the archive
    # fail with "Sandbox: deny file-read-data .../Scripts/validate_release.py". So every file
    # the check opens is listed here, including the Python modules it imports.
    gate_files = ["Scripts/validate_release.py", "Scripts/content_approval.py",
                  "Scripts/validate_content_pack.py",
                  "Core/Resources/app-config.json", "Core/Resources/legal.json"]
    for folder in ["Core/Resources/SelectedPack", "Schemas"]:
        gate_files += sorted(p.relative_to(ROOT).as_posix() for p in (ROOT / folder).glob("*.json"))
    gate_inputs = [f"$(SRCROOT)/{path}" for path in gate_files]
    gate = add("content-gate", "PBXShellScriptBuildPhase", buildActionMask=2147483647, files=[], inputPaths=gate_inputs, outputPaths=[],
               name="Paket und Veröffentlichung prüfen", runOnlyForDeploymentPostprocessing=0, shellPath="/bin/sh",
               # Bytecode must not be written into the project, and an existing __pycache__
               # there must not be read either: the sandbox would deny both. The prefix moves
               # lookup and writing into the build folder.
               shellScript='export PYTHONDONTWRITEBYTECODE=1\nexport PYTHONPYCACHEPREFIX="$DERIVED_FILE_DIR/pycache"\nif [ "$CONFIGURATION" = "Release" ]; then\n  /usr/bin/python3 "$SRCROOT/Scripts/validate_release.py" "$SRCROOT/Core/Resources/SelectedPack"\nfi\n')
    project_settings = dict(CLANG_ENABLE_MODULES="YES", CLANG_ENABLE_OBJC_ARC="YES", SDKROOT="iphoneos", IPHONEOS_DEPLOYMENT_TARGET="17.0", SWIFT_VERSION="5.0", ENABLE_USER_SCRIPT_SANDBOXING="YES")
    target_settings = dict(PRODUCT_BUNDLE_IDENTIFIER=config["bundleIdentifier"], PRODUCT_NAME=product_name, TARGETED_DEVICE_FAMILY="1", CODE_SIGN_STYLE="Automatic",
        GENERATE_INFOPLIST_FILE="NO", INFOPLIST_FILE="Configuration/Info.plist", ASSETCATALOG_COMPILER_APPICON_NAME="AppIcon", CURRENT_PROJECT_VERSION="11",
        # Must match the version record in App Store Connect, otherwise the upload
        # cannot be attached to it. That record is 1.0.
        MARKETING_VERSION="1.0", SWIFT_EMIT_LOC_STRINGS="YES", SUPPORTED_PLATFORMS="iphoneos iphonesimulator", SUPPORTS_MACCATALYST="NO",
        LD_RUNPATH_SEARCH_PATHS=["$(inherited)", "@executable_path/Frameworks"], SWIFT_STRICT_CONCURRENCY="targeted")
    project_configs = []; target_configs = []
    for build_config in ["Debug", "Release"]:
        p = dict(project_settings)
        p.update(SWIFT_OPTIMIZATION_LEVEL="-Onone" if build_config == "Debug" else "-O", DEBUG_INFORMATION_FORMAT="dwarf" if build_config == "Debug" else "dwarf-with-dsym")
        if build_config == "Debug": p.update(SWIFT_ACTIVE_COMPILATION_CONDITIONS="DEBUG", ENABLE_TESTABILITY="YES", ONLY_ACTIVE_ARCH="YES")
        project_configs.append(add("project:" + build_config, "XCBuildConfiguration", name=build_config, buildSettings=p))
        target_configs.append(add("target:" + build_config, "XCBuildConfiguration", name=build_config, buildSettings=target_settings))
    project_config_list = add("project-configs", "XCConfigurationList", buildConfigurations=project_configs, defaultConfigurationIsVisible=0, defaultConfigurationName="Debug")
    target_config_list = add("target-configs", "XCConfigurationList", buildConfigurations=target_configs, defaultConfigurationIsVisible=0, defaultConfigurationName="Debug")
    target = add("target", "PBXNativeTarget", buildConfigurationList=target_config_list, buildPhases=[gate, source_phase, framework_phase, resource_phase], buildRules=[], dependencies=[],
        name=product_name, packageProductDependencies=[dependency], productName=product_name, productReference=product, productType="com.apple.product-type.application")
    project = add("project", "PBXProject", attributes={"BuildIndependentTargetsInParallel": "YES", "LastUpgradeCheck": "1600"}, buildConfigurationList=project_config_list,
        compatibilityVersion="Xcode 14.0", developmentRegion="de", hasScannedForEncodings=0, knownRegions=["de", "en", "Base"], mainGroup=root_group,
        packageReferences=[package], productRefGroup=product_group, projectDirPath="", projectRoot="", targets=[target])
    document = dict(archiveVersion=1, classes={}, objectVersion=56, objects=objects, rootObject=project)
    (project_dir / "project.pbxproj").write_text("// !$*UTF8*$!\n" + render(document) + "\n")
    reference = f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{target}" BuildableName="{product_name}.app" BlueprintName="{product_name}" ReferencedContainer="container:{project_name}.xcodeproj"/>'
    scheme = f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="1600" version="1.7">
 <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{reference}</BuildActionEntry></BuildActionEntries></BuildAction>
 <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables/></TestAction>
 <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></LaunchAction>
 <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES"><BuildableProductRunnable runnableDebuggingMode="0">{reference}</BuildableProductRunnable></ProfileAction>
 <AnalyzeAction buildConfiguration="Debug"/>
 <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
'''
    (project_dir / "xcshareddata/xcschemes" / (product_name + ".xcscheme")).write_text(scheme)
    info = dict(CFBundleDevelopmentRegion="de", CFBundleDisplayName=config["appName"], CFBundleExecutable="$(EXECUTABLE_NAME)", CFBundleIdentifier="$(PRODUCT_BUNDLE_IDENTIFIER)",
        CFBundleInfoDictionaryVersion="6.0", CFBundleName="$(PRODUCT_NAME)", CFBundlePackageType="APPL", CFBundleShortVersionString="$(MARKETING_VERSION)", CFBundleVersion="$(CURRENT_PROJECT_VERSION)",
        NSMicrophoneUsageDescription="Wenn du möchtest, kannst du deine Antwort im Fachgespräch aufnehmen und selbst anhören. Die Aufnahme bleibt auf deinem iPhone.", LSRequiresIPhoneOS=True, UILaunchScreen={}, UIApplicationSceneManifest={"UIApplicationSupportsMultipleScenes": False},
        # Portrait only. Landscape was declared but never checked on a device, and the
        # learning views are laid out as a single column for one-handed use.
        UISupportedInterfaceOrientations=["UIInterfaceOrientationPortrait"], ITSAppUsesNonExemptEncryption=False)
    if not config["featureFlags"]["oralExam"]: info.pop("NSMicrophoneUsageDescription", None)
    (ROOT / "Configuration/Info.plist").write_bytes(plistlib.dumps(info))
    privacy = dict(NSPrivacyTracking=False, NSPrivacyTrackingDomains=[], NSPrivacyCollectedDataTypes=[],
        NSPrivacyAccessedAPITypes=[dict(NSPrivacyAccessedAPIType="NSPrivacyAccessedAPICategorySystemBootTime", NSPrivacyAccessedAPITypeReasons=["35F9.1"])])
    (ROOT / "Configuration/PrivacyInfo.xcprivacy").write_bytes(plistlib.dumps(privacy))
    products = []
    for i, (product_id, label) in enumerate(zip(config["tipProductIds"], config["tipLabels"])):
        products.append(dict(displayPrice=label["testPrice"], familyShareable=False, internalID=str(100001+i),
            localizations=[dict(description=label["detail"], displayName=label["title"], locale="de_DE")],
            productID=product_id, referenceName=label["title"], type="Consumable"))
    storekit = dict(identifier="AEC4258B", nonRenewingSubscriptions=[], products=products,
        settings={"_applicationInternalID": "0", "_developerTeamID": "", "_failTransactionsEnabled": False, "_locale": "de_DE", "_storefront": "DEU", "_storeKitErrors": []},
        subscriptionGroups=[], version=dict(major=3, minor=0))
    (ROOT / "Configuration/Tips.storekit").write_text(json.dumps(storekit, ensure_ascii=False, indent=2)+"\n")
    print(f"Xcode-Projekt mit {len(swift_files)} App-Dateien und lokalem Swift-Paket erzeugt.")

if __name__ == "__main__": main()
