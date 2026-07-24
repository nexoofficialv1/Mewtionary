using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public sealed class Mewtionary3DBootstrap : MonoBehaviour
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        private static void AutoStart()
        {
            if (Object.FindObjectOfType<Teacher3DMotionController>() != null) return;

            SetupEnvironment();
            GameObject teacher = ProceduralTeacherFactory.Create(new Vector3(0, 0, 0));
            GameObject raycaster = new GameObject("Teacher Mobile Touch Raycaster");
            raycaster.AddComponent<TeacherMobileTouchRaycaster>();
        }

        private static void SetupEnvironment()
        {
            Camera camera = Camera.main;
            if (camera == null)
            {
                GameObject cameraObject = new GameObject("Main Camera");
                camera = cameraObject.AddComponent<Camera>();
                cameraObject.tag = "MainCamera";
            }
            camera.transform.position = new Vector3(0, 1.85f, -6.2f);
            camera.transform.LookAt(new Vector3(0, 1.55f, 0));
            camera.fieldOfView = 35f;
            camera.clearFlags = CameraClearFlags.SolidColor;
            camera.backgroundColor = new Color(.72f, .88f, .92f);

            if (Object.FindObjectOfType<Light>() == null)
            {
                GameObject key = new GameObject("Key Light");
                Light light = key.AddComponent<Light>();
                light.type = LightType.Directional;
                light.intensity = 1.05f;
                light.color = new Color(1f, .91f, .82f);
                key.transform.rotation = Quaternion.Euler(38, -28, 0);

                GameObject fill = new GameObject("Fill Light");
                Light fillLight = fill.AddComponent<Light>();
                fillLight.type = LightType.Point;
                fillLight.intensity = 2.2f;
                fillLight.range = 8f;
                fillLight.color = new Color(.62f, .80f, 1f);
                fill.transform.position = new Vector3(-3, 3, -3);
            }

            Material floorMat = new Material(Shader.Find("Standard"));
            floorMat.color = new Color(.71f, .52f, .32f);
            GameObject floor = GameObject.CreatePrimitive(PrimitiveType.Cube);
            floor.name = "Classroom Floor";
            floor.transform.position = new Vector3(0, -.06f, 0);
            floor.transform.localScale = new Vector3(8, .1f, 6);
            floor.GetComponent<Renderer>().sharedMaterial = floorMat;

            Material boardMat = new Material(Shader.Find("Standard"));
            boardMat.color = new Color(.035f, .20f, .15f);
            GameObject board = GameObject.CreatePrimitive(PrimitiveType.Cube);
            board.name = "Blackboard";
            board.transform.position = new Vector3(-2.05f, 2.0f, .85f);
            board.transform.localScale = new Vector3(2.6f, 1.5f, .08f);
            board.GetComponent<Renderer>().sharedMaterial = boardMat;
        }
    }
}
