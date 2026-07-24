#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Mewtionary.Teacher3D.Editor
{
    public static class TeacherAndroidBuildValidator
    {
        [MenuItem("Mewtionary/Validate Android Teacher Build")]
        public static void Validate()
        {
            List<string> errors = new List<string>();
            List<string> warnings = new List<string>();

            if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
                warnings.Add("Active build target is not Android.");

            if (PlayerSettings.GetScriptingBackend(BuildTargetGroup.Android) !=
                ScriptingImplementation.IL2CPP)
                warnings.Add("IL2CPP is recommended for the final Android build.");

            if (PlayerSettings.Android.minSdkVersion < AndroidSdkVersions.AndroidApiLevel24)
                warnings.Add("Android API 24 or higher is recommended.");

            Teacher3DCommandReceiver receiver =
                Object.FindObjectOfType<Teacher3DCommandReceiver>();
            if (receiver == null)
                errors.Add("Teacher3DCommandReceiver is missing from the scene.");

            Camera camera = Camera.main;
            if (camera == null)
                errors.Add("Main Camera is missing.");

            TeacherPerformanceGovernor governor =
                Object.FindObjectOfType<TeacherPerformanceGovernor>();
            if (governor == null)
                warnings.Add("TeacherPerformanceGovernor is not configured.");

            string message = "Mewtionary Android validation\n\n";
            if (errors.Count == 0) message += "No blocking errors.\n";
            foreach (string error in errors) message += "ERROR: " + error + "\n";
            foreach (string warning in warnings) message += "WARNING: " + warning + "\n";

            EditorUtility.DisplayDialog(
                "Teacher Android Build Validation",
                message,
                "OK");

            Debug.Log(message);
        }
    }
}
#endif
