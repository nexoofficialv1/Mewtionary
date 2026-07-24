#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Mewtionary.Teacher3D.Editor
{
    public static class MewtionaryProductionSceneBuilder
    {
        [MenuItem("Mewtionary/Build v2.1 Lesson Integration Scene")]
        public static void Build()
        {
            Scene scene = EditorSceneManager.NewScene(
                NewSceneSetup.EmptyScene,
                NewSceneMode.Single);

            GameObject bootstrap = new GameObject("Mewtionary3DBootstrap");
            bootstrap.AddComponent<Mewtionary3DBootstrap>();

            GameObject lessonUi = new GameObject("Lesson Director Host");
            TeacherLessonDirector director =
                lessonUi.AddComponent<TeacherLessonDirector>();
            director.autoPlay = false;

            const string path =
                "Assets/MewtionaryTeacher3D/MewtionaryTeacher_v2_1_LessonScene.unity";
            EditorSceneManager.SaveScene(scene, path);
            Selection.activeGameObject = bootstrap;
            Debug.Log("Created " + path + ". Press Play, then use the Lesson Director on the generated teacher.");
        }
    }
}
#endif
