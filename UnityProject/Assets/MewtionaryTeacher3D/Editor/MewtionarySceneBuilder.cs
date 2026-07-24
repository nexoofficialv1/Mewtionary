#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Mewtionary.Teacher3D.Editor
{
    public static class MewtionarySceneBuilder
    {
        [MenuItem("Mewtionary/Build 3D Teacher Prototype Scene")]
        public static void BuildPrototypeScene()
        {
            Scene scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            GameObject bootstrap = new GameObject("Mewtionary3DBootstrap");
            bootstrap.AddComponent<Mewtionary3DBootstrap>();

            // Enter play mode once to let the bootstrap create the runtime scene,
            // or keep this object in your own app scene.
            const string path = "Assets/MewtionaryTeacher3D/PrototypeScene.unity";
            EditorSceneManager.SaveScene(scene, path);
            Selection.activeGameObject = bootstrap;
            Debug.Log("Created " + path + ". Press Play to view the animated 3D teacher.");
        }
    }
}
#endif
