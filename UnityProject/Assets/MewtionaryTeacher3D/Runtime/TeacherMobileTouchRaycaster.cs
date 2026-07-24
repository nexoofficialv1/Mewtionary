using UnityEngine;
using UnityEngine.EventSystems;

namespace Mewtionary.Teacher3D
{
    public sealed class TeacherMobileTouchRaycaster : MonoBehaviour
    {
        public Camera interactionCamera;
        public LayerMask touchMask = ~0;
        public float maxDistance = 100f;

        private void Awake()
        {
            if (interactionCamera == null)
                interactionCamera = Camera.main;
        }

        private void Update()
        {
            if (interactionCamera == null) return;

            if (Input.touchCount > 0)
            {
                Touch touch = Input.GetTouch(0);
                if (touch.phase == TouchPhase.Ended)
                    TryTouch(touch.position, touch.fingerId);
            }
#if UNITY_EDITOR || UNITY_STANDALONE
            if (Input.GetMouseButtonUp(0))
                TryTouch(Input.mousePosition, -1);
#endif
        }

        private void TryTouch(Vector2 screenPosition, int pointerId)
        {
            if (EventSystem.current != null &&
                EventSystem.current.IsPointerOverGameObject(pointerId))
                return;

            Ray ray = interactionCamera.ScreenPointToRay(screenPosition);
            if (!Physics.Raycast(ray, out RaycastHit hit, maxDistance, touchMask))
                return;

            TeacherTouchZone zone = hit.collider.GetComponent<TeacherTouchZone>();
            if (zone == null)
                zone = hit.collider.GetComponentInParent<TeacherTouchZone>();

            if (zone != null)
                zone.SendMessage("OnMouseDown", SendMessageOptions.DontRequireReceiver);
        }
    }
}
