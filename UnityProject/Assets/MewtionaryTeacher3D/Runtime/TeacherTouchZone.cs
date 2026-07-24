using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public enum TeacherTouchPart
    {
        Head,
        Glasses,
        Body,
        LeftHand,
        RightHand,
        Book,
        Pointer,
        Feet
    }

    [RequireComponent(typeof(Collider))]
    public sealed class TeacherTouchZone : MonoBehaviour
    {
        public TeacherTouchPart part;
        private Teacher3DMotionController controller;

        private void Awake()
        {
            controller = GetComponentInParent<Teacher3DMotionController>();
        }

        private void OnMouseDown()
        {
            if (controller != null)
                controller.ReactToTouch(part);
        }
    }
}
