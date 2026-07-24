using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public sealed class Teacher3DCommandReceiver : MonoBehaviour
    {
        public Teacher3DMotionController controller;
        public Teacher3DProductionAdapter productionAdapter;
        public TeacherLipSyncScheduler lipSync;

        private void Awake()
        {
            if (controller == null)
                controller = GetComponent<Teacher3DMotionController>();
            if (productionAdapter == null)
                productionAdapter = GetComponent<Teacher3DProductionAdapter>();
            if (lipSync == null)
                lipSync = GetComponent<TeacherLipSyncScheduler>();
        }

        // Flutter / Android calls:
        // UnitySendMessage("MewtionaryTeacher", "ReceiveCommand", json)
        public void ReceiveCommand(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) return;

            try
            {
                Teacher3DCommand command = JsonUtility.FromJson<Teacher3DCommand>(json);

                if (productionAdapter != null)
                    productionAdapter.ApplyCommand(command);
                else if (controller != null)
                    controller.ApplyCommand(command);

                if (lipSync != null)
                {
                    if (command.state.Equals("Speaking",
                            System.StringComparison.OrdinalIgnoreCase) ||
                        command.state.Equals("Reading",
                            System.StringComparison.OrdinalIgnoreCase))
                    {
                        lipSync.PlayText(command.message);
                    }
                    else if (command.viseme == 0)
                    {
                        lipSync.StopLipSync();
                    }
                }
            }
            catch (System.Exception ex)
            {
                Debug.LogError($"Invalid teacher command: {ex.Message}");
            }
        }

        public void SetStateByName(string stateName)
        {
            ReceiveCommand("{\"state\":\"" + stateName + "\"}");
        }

        public void SetGaze(string csv)
        {
            string[] parts = csv.Split(',');
            if (parts.Length != 2) return;

            float x = 0;
            float y = 0;
            float.TryParse(parts[0], out x);
            float.TryParse(parts[1], out y);

            Teacher3DCommand command = new Teacher3DCommand
            {
                state = controller != null ? controller.state.ToString() : "Idle",
                gazeX = Mathf.Clamp(x, -1, 1),
                gazeY = Mathf.Clamp(y, -1, 1)
            };
            ReceiveCommand(JsonUtility.ToJson(command));
        }
    }
}
