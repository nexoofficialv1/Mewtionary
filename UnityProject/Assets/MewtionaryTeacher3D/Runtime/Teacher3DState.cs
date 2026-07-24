using System;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public enum Teacher3DState
    {
        Welcome,
        Idle,
        Listening,
        Speaking,
        Thinking,
        Praise,
        Correction,
        Reading,
        Pointing,
        WritingBoard,
        Dancing,
        Laughing,
        Surprised,
        Sleepy,
        AdjustGlasses,
        Nodding
    }

    public enum Teacher3DProp
    {
        None,
        Book,
        Pointer,
        Chalk
    }

    public enum TeacherViseme
    {
        Rest = 0,
        A = 1,
        E = 2,
        O = 3,
        MBP = 4,
        FV = 5,
        LRTDN = 6
    }

    [Serializable]
    public class Teacher3DCommand
    {
        public string state = "Idle";
        public string message = "";
        public string prop = "None";
        public int viseme = 0;
        public float gazeX = 0f;
        public float gazeY = 0f;
        public float duration = 0f;
        public bool lowMotion = false;
    }
}
