#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Mewtionary.Teacher3D.Editor
{
    public sealed class TeacherCharacterSetupWizard : EditorWindow
    {
        private GameObject sourcePrefab;
        private string outputFolder = "Assets/MewtionaryTeacher3D/Generated";
        private Vector2 scroll;
        private readonly List<string> report = new List<string>();

        private static readonly string[] FaceRendererHints =
        {
            "face", "head", "body", "character"
        };

        [MenuItem("Mewtionary/Final Character Setup Wizard")]
        public static void Open()
        {
            GetWindow<TeacherCharacterSetupWizard>(
                "Teacher Character Setup");
        }

        private void OnGUI()
        {
            EditorGUILayout.LabelField(
                "Mewtionary Final 3D Character Setup",
                EditorStyles.boldLabel);
            EditorGUILayout.HelpBox(
                "Imported FBX/GLB prefab নির্বাচন করুন। Wizard humanoid bones, face renderer, eyes, glasses, hands এবং props-এর সম্ভাব্য mapping তৈরি করবে।",
                MessageType.Info);

            sourcePrefab = (GameObject)EditorGUILayout.ObjectField(
                "Source Character",
                sourcePrefab,
                typeof(GameObject),
                false);

            outputFolder = EditorGUILayout.TextField(
                "Output Folder",
                outputFolder);

            GUI.enabled = sourcePrefab != null;
            if (GUILayout.Button("Analyse Character"))
                Analyse();
            if (GUILayout.Button("Create Profile and Runtime Prefab"))
                CreateProfileAndPrefab();
            GUI.enabled = true;

            EditorGUILayout.Space();
            scroll = EditorGUILayout.BeginScrollView(scroll);
            foreach (string line in report)
                EditorGUILayout.LabelField("• " + line, EditorStyles.wordWrappedLabel);
            EditorGUILayout.EndScrollView();
        }

        private void Analyse()
        {
            report.Clear();
            if (sourcePrefab == null) return;

            Animator animator = sourcePrefab.GetComponentInChildren<Animator>();
            report.Add(animator != null
                ? $"Animator found: {animator.name}"
                : "Animator not found.");

            SkinnedMeshRenderer face = FindFaceRenderer(sourcePrefab);
            report.Add(face != null
                ? $"Likely face renderer: {face.name}; blendshapes: {face.sharedMesh.blendShapeCount}"
                : "No suitable face renderer found.");

            foreach (string item in new[]
            {
                "Head", "Eye_L", "Eye_R", "Glasses",
                "Hand_L", "Hand_R", "Book", "Pointer", "Chalk"
            })
            {
                Transform t = FindByHints(sourcePrefab.transform, HintsFor(item));
                report.Add(t != null ? $"{item}: {t.name}" : $"{item}: not found");
            }

            if (face != null)
            {
                HashSet<string> names = new HashSet<string>(
                    StringComparer.OrdinalIgnoreCase);
                for (int i = 0; i < face.sharedMesh.blendShapeCount; i++)
                    names.Add(face.sharedMesh.GetBlendShapeName(i));

                foreach (string required in RequiredBlendshapes())
                    report.Add(names.Contains(required)
                        ? $"Blendshape OK: {required}"
                        : $"Blendshape missing: {required}");
            }
        }

        private void CreateProfileAndPrefab()
        {
            if (sourcePrefab == null) return;
            EnsureFolder(outputFolder);

            GameObject instance = (GameObject)PrefabUtility.InstantiatePrefab(sourcePrefab);
            instance.name = "MewtionaryTeacher_Final_Runtime";

            Teacher3DProductionAdapter adapter =
                instance.GetComponent<Teacher3DProductionAdapter>() ??
                instance.AddComponent<Teacher3DProductionAdapter>();
            Teacher3DCommandReceiver receiver =
                instance.GetComponent<Teacher3DCommandReceiver>() ??
                instance.AddComponent<Teacher3DCommandReceiver>();
            TeacherLipSyncScheduler lipSync =
                instance.GetComponent<TeacherLipSyncScheduler>() ??
                instance.AddComponent<TeacherLipSyncScheduler>();
            TeacherLessonDirector director =
                instance.GetComponent<TeacherLessonDirector>() ??
                instance.AddComponent<TeacherLessonDirector>();
            TeacherPerformanceGovernor governor =
                instance.GetComponent<TeacherPerformanceGovernor>() ??
                instance.AddComponent<TeacherPerformanceGovernor>();

            Teacher3DCharacterProfile profile =
                ScriptableObject.CreateInstance<Teacher3DCharacterProfile>();
            profile.characterPrefab = sourcePrefab;
            profile.faceRenderer = FindFaceRenderer(instance);
            profile.head = FindByHints(instance.transform, HintsFor("Head"));
            profile.leftEye = FindByHints(instance.transform, HintsFor("Eye_L"));
            profile.rightEye = FindByHints(instance.transform, HintsFor("Eye_R"));
            profile.glasses = FindByHints(instance.transform, HintsFor("Glasses"));
            profile.leftHand = FindByHints(instance.transform, HintsFor("Hand_L"));
            profile.rightHand = FindByHints(instance.transform, HintsFor("Hand_R"));
            profile.bookAnchor = FindByHints(instance.transform, HintsFor("Book"));
            profile.pointerAnchor = FindByHints(instance.transform, HintsFor("Pointer"));
            profile.chalkAnchor = FindByHints(instance.transform, HintsFor("Chalk"));

            string profilePath = $"{outputFolder}/Teacher3DCharacterProfile.asset";
            AssetDatabase.CreateAsset(profile, profilePath);
            AssetDatabase.SaveAssets();

            adapter.profile = profile;
            adapter.animator = instance.GetComponentInChildren<Animator>();
            receiver.productionAdapter = adapter;
            receiver.lipSync = lipSync;
            lipSync.productionAdapter = adapter;
            director.receiver = receiver;
            director.lipSync = lipSync;

            string prefabPath = $"{outputFolder}/MewtionaryTeacher_Final_Runtime.prefab";
            PrefabUtility.SaveAsPrefabAsset(instance, prefabPath);
            DestroyImmediate(instance);

            report.Clear();
            report.Add($"Profile created: {profilePath}");
            report.Add($"Runtime prefab created: {prefabPath}");
            report.Add("Open the profile and verify uncertain mappings before production use.");
            Selection.activeObject = profile;
        }

        private static SkinnedMeshRenderer FindFaceRenderer(GameObject root)
        {
            SkinnedMeshRenderer best = null;
            int bestScore = int.MinValue;

            foreach (SkinnedMeshRenderer renderer in
                     root.GetComponentsInChildren<SkinnedMeshRenderer>(true))
            {
                int score = renderer.sharedMesh != null
                    ? renderer.sharedMesh.blendShapeCount * 10
                    : 0;
                string lower = renderer.name.ToLowerInvariant();
                foreach (string hint in FaceRendererHints)
                    if (lower.Contains(hint)) score += 50;
                if (score > bestScore)
                {
                    bestScore = score;
                    best = renderer;
                }
            }
            return best;
        }

        private static Transform FindByHints(Transform root, string[] hints)
        {
            foreach (Transform t in root.GetComponentsInChildren<Transform>(true))
            {
                string lower = t.name.ToLowerInvariant();
                foreach (string hint in hints)
                    if (lower == hint || lower.Contains(hint))
                        return t;
            }
            return null;
        }

        private static string[] HintsFor(string key)
        {
            switch (key)
            {
                case "Head": return new[] { "head", "head_jnt", "b_head" };
                case "Eye_L": return new[] { "eye_l", "lefteye", "eye.left" };
                case "Eye_R": return new[] { "eye_r", "righteye", "eye.right" };
                case "Glasses": return new[] { "glasses", "spectacles", "frame" };
                case "Hand_L": return new[] { "hand_l", "lefthand", "hand.left" };
                case "Hand_R": return new[] { "hand_r", "righthand", "hand.right" };
                case "Book": return new[] { "bookanchor", "book", "prop_l" };
                case "Pointer": return new[] { "pointeranchor", "pointer", "prop_r" };
                case "Chalk": return new[] { "chalkanchor", "chalk", "prop_r" };
                default: return new[] { key.ToLowerInvariant() };
            }
        }

        private static string[] RequiredBlendshapes()
        {
            return new[]
            {
                "viseme_REST", "viseme_A", "viseme_E", "viseme_O",
                "viseme_MBP", "viseme_FV", "viseme_LRTDN",
                "expr_SMILE", "expr_LAUGH", "expr_SURPRISE",
                "expr_GENTLE", "expr_SLEEPY", "blink_L", "blink_R"
            };
        }

        private static void EnsureFolder(string path)
        {
            string[] parts = path.Split('/');
            string current = parts[0];
            for (int i = 1; i < parts.Length; i++)
            {
                string next = current + "/" + parts[i];
                if (!AssetDatabase.IsValidFolder(next))
                    AssetDatabase.CreateFolder(current, parts[i]);
                current = next;
            }
        }
    }
}
#endif
