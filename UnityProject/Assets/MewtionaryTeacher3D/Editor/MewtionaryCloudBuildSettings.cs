#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace Mewtionary.Teacher3D.Editor
{
    /// <summary>
    /// Applies safe Android test-build settings on Unity Cloud Build.
    /// The final Flutter + Unity production build will use a separate
    /// unityLibrary export pipeline.
    /// </summary>
    public sealed class MewtionaryCloudBuildSettings :
        IPreprocessBuildWithReport
    {
        private const string ScenePath =
            "Assets/MewtionaryTeacher3D/MewtionaryCloudBootstrap.unity";

        public int callbackOrder => -1000;

        public void OnPreprocessBuild(BuildReport report)
        {
            if (!File.Exists(ScenePath))
            {
                throw new BuildFailedException(
                    "Required bootstrap scene was not found: " + ScenePath);
            }

            EditorBuildSettings.scenes = new[]
            {
                new EditorBuildSettingsScene(ScenePath, true),
            };

            PlayerSettings.companyName = "Astra Technologies";
            PlayerSettings.productName = "Mewtionary 3D Teacher";
            PlayerSettings.SetApplicationIdentifier(
                BuildTargetGroup.Android,
                "com.astratechnologies.mewtionary");

            PlayerSettings.defaultInterfaceOrientation =
                UIOrientation.Portrait;
            PlayerSettings.Android.minSdkVersion =
                AndroidSdkVersions.AndroidApiLevel24;
            PlayerSettings.Android.targetArchitectures =
                AndroidArchitecture.ARMv7 |
                AndroidArchitecture.ARM64;

            EditorUserBuildSettings.buildAppBundle = false;

            AssetDatabase.SaveAssets();
            Debug.Log(
                "[Mewtionary] Cloud Android test-build settings applied. " +
                "Scene: " + ScenePath);
        }
    }
}
#endif
