using System;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    [DisallowMultipleComponent]
    public sealed class Teacher3DMotionController : MonoBehaviour
    {
        public Teacher3DRig rig;
        public Teacher3DState state = Teacher3DState.Welcome;
        public Teacher3DProp prop = Teacher3DProp.Book;
        public TeacherViseme viseme = TeacherViseme.Rest;
        public bool lowMotion;
        [Range(-1f, 1f)] public float gazeX;
        [Range(-1f, 1f)] public float gazeY;
        public string currentMessage = "Hello! Let's learn together.";

        private Vector3 rootBasePosition;
        private Quaternion headBaseRotation;
        private Quaternion leftUpperBase, leftForeBase, rightUpperBase, rightForeBase;
        private Quaternion leftThighBase, rightThighBase;
        private Vector3 leftPupilBase, rightPupilBase;
        private float stateTimer;
        private float blinkTimer;
        private float nextBlink = 2.2f;
        private float blinkAmount;
        private int autoVisemeIndex;
        private float autoVisemeTimer;

        private readonly TeacherViseme[] speechCycle =
        {
            TeacherViseme.A, TeacherViseme.E, TeacherViseme.O,
            TeacherViseme.MBP, TeacherViseme.A, TeacherViseme.LRTDN,
            TeacherViseme.E, TeacherViseme.FV
        };

        private void Awake()
        {
            if (rig == null) rig = GetComponent<Teacher3DRig>();
            CacheBasePose();
            ApplyProp();
            ApplyViseme();
        }

        private void CacheBasePose()
        {
            rootBasePosition = transform.localPosition;
            if (rig == null) return;
            headBaseRotation = rig.headPivot.localRotation;
            leftUpperBase = rig.leftUpperArm.localRotation;
            leftForeBase = rig.leftForearm.localRotation;
            rightUpperBase = rig.rightUpperArm.localRotation;
            rightForeBase = rig.rightForearm.localRotation;
            leftThighBase = rig.leftThigh.localRotation;
            rightThighBase = rig.rightThigh.localRotation;
            leftPupilBase = rig.leftPupil.localPosition;
            rightPupilBase = rig.rightPupil.localPosition;
        }

        private void Update()
        {
            if (rig == null) return;
            stateTimer += Time.deltaTime;
            UpdateBlink();
            UpdateGaze();
            UpdateBody();
            UpdateFace();
            UpdatePropsAndEffects();

            if (state == Teacher3DState.Speaking)
                UpdateAutomaticViseme();
            else if (viseme != TeacherViseme.Rest)
                SetViseme(TeacherViseme.Rest);
        }

        private void UpdateBlink()
        {
            blinkTimer += Time.deltaTime;
            if (blinkTimer >= nextBlink)
            {
                blinkAmount = Mathf.PingPong((blinkTimer - nextBlink) * 7f, 1f);
                if (blinkTimer - nextBlink > 0.30f)
                {
                    blinkTimer = 0f;
                    blinkAmount = 0f;
                    nextBlink = UnityEngine.Random.Range(2.0f, 5.0f);
                }
            }
            else blinkAmount = 0f;

            float eyeScaleY = Mathf.Lerp(1f, 0.08f, blinkAmount);
            if (state == Teacher3DState.Sleepy) eyeScaleY = 0.22f;
            rig.leftEye.localScale = new Vector3(rig.leftEye.localScale.x, eyeScaleY, rig.leftEye.localScale.z);
            rig.rightEye.localScale = new Vector3(rig.rightEye.localScale.x, eyeScaleY, rig.rightEye.localScale.z);
        }

        private void UpdateGaze()
        {
            Vector3 shift = new Vector3(gazeX * 0.025f, gazeY * 0.018f, -0.004f);
            rig.leftPupil.localPosition = Vector3.Lerp(rig.leftPupil.localPosition, leftPupilBase + shift, Time.deltaTime * 12f);
            rig.rightPupil.localPosition = Vector3.Lerp(rig.rightPupil.localPosition, rightPupilBase + shift, Time.deltaTime * 12f);

            float listenTilt = state == Teacher3DState.Listening ? -8f : 0f;
            float thinkTilt = state == Teacher3DState.Thinking ? -6f : 0f;
            Quaternion target = headBaseRotation * Quaternion.Euler(
                -gazeY * 5f,
                gazeX * 8f,
                listenTilt + thinkTilt
            );
            rig.headPivot.localRotation = Quaternion.Slerp(rig.headPivot.localRotation, target, Time.deltaTime * 7f);
        }

        private void UpdateBody()
        {
            float t = Time.time;
            float breathe = lowMotion ? 0f : Mathf.Sin(t * 2.0f) * 0.012f;
            Vector3 targetRoot = rootBasePosition + Vector3.up * breathe;
            Quaternion leftUpper = leftUpperBase;
            Quaternion leftFore = leftForeBase;
            Quaternion rightUpper = rightUpperBase;
            Quaternion rightFore = rightForeBase;
            Quaternion leftThigh = leftThighBase;
            Quaternion rightThigh = rightThighBase;

            switch (state)
            {
                case Teacher3DState.Welcome:
                    rightUpper *= Quaternion.Euler(0, 0, -55 + Mathf.Sin(t * 7f) * 12f);
                    rightFore *= Quaternion.Euler(0, 0, -45);
                    break;
                case Teacher3DState.Listening:
                    rightUpper *= Quaternion.Euler(0, 0, -62);
                    rightFore *= Quaternion.Euler(0, 0, -80);
                    targetRoot += Vector3.left * 0.025f;
                    break;
                case Teacher3DState.Thinking:
                    rightUpper *= Quaternion.Euler(0, 0, -28);
                    rightFore *= Quaternion.Euler(0, 0, -105);
                    break;
                case Teacher3DState.Praise:
                    targetRoot += Vector3.up * Mathf.Abs(Mathf.Sin(t * 5.5f)) * 0.12f;
                    leftUpper *= Quaternion.Euler(0, 0, 58);
                    leftFore *= Quaternion.Euler(0, 0, 40);
                    rightUpper *= Quaternion.Euler(0, 0, -58);
                    rightFore *= Quaternion.Euler(0, 0, -40);
                    break;
                case Teacher3DState.Correction:
                    rightUpper *= Quaternion.Euler(0, 0, -18);
                    rightFore *= Quaternion.Euler(0, 0, -52);
                    break;
                case Teacher3DState.Reading:
                    leftUpper *= Quaternion.Euler(0, 0, 22);
                    leftFore *= Quaternion.Euler(0, 0, 55);
                    rightUpper *= Quaternion.Euler(0, 0, -22);
                    rightFore *= Quaternion.Euler(0, 0, -55);
                    break;
                case Teacher3DState.Pointing:
                case Teacher3DState.WritingBoard:
                    rightUpper *= Quaternion.Euler(-15, 18, -70 + Mathf.Sin(t * 3f) * 5f);
                    rightFore *= Quaternion.Euler(0, 0, -25);
                    break;
                case Teacher3DState.Dancing:
                    targetRoot += Vector3.up * Mathf.Abs(Mathf.Sin(t * 7f)) * 0.08f;
                    transform.localRotation = Quaternion.Euler(0, Mathf.Sin(t * 4f) * 8f, Mathf.Sin(t * 5f) * 5f);
                    leftUpper *= Quaternion.Euler(0, 0, 55 + Mathf.Sin(t * 7f) * 20f);
                    rightUpper *= Quaternion.Euler(0, 0, -55 - Mathf.Sin(t * 7f) * 20f);
                    leftThigh *= Quaternion.Euler(Mathf.Sin(t * 7f) * 14f, 0, 0);
                    rightThigh *= Quaternion.Euler(-Mathf.Sin(t * 7f) * 14f, 0, 0);
                    break;
                case Teacher3DState.Laughing:
                    targetRoot += Vector3.up * Mathf.Abs(Mathf.Sin(t * 8f)) * 0.025f;
                    break;
                case Teacher3DState.Sleepy:
                    targetRoot += Vector3.down * 0.025f;
                    break;
                case Teacher3DState.AdjustGlasses:
                    rightUpper *= Quaternion.Euler(0, 0, -58);
                    rightFore *= Quaternion.Euler(0, 0, -82);
                    break;
                case Teacher3DState.Nodding:
                    rig.headPivot.localRotation *= Quaternion.Euler(Mathf.Sin(t * 8f) * 5f, 0, 0);
                    break;
            }

            if (state != Teacher3DState.Dancing)
                transform.localRotation = Quaternion.Slerp(transform.localRotation, Quaternion.identity, Time.deltaTime * 7f);

            transform.localPosition = Vector3.Lerp(transform.localPosition, targetRoot, Time.deltaTime * 8f);
            rig.leftUpperArm.localRotation = Quaternion.Slerp(rig.leftUpperArm.localRotation, leftUpper, Time.deltaTime * 8f);
            rig.leftForearm.localRotation = Quaternion.Slerp(rig.leftForearm.localRotation, leftFore, Time.deltaTime * 8f);
            rig.rightUpperArm.localRotation = Quaternion.Slerp(rig.rightUpperArm.localRotation, rightUpper, Time.deltaTime * 8f);
            rig.rightForearm.localRotation = Quaternion.Slerp(rig.rightForearm.localRotation, rightFore, Time.deltaTime * 8f);
            rig.leftThigh.localRotation = Quaternion.Slerp(rig.leftThigh.localRotation, leftThigh, Time.deltaTime * 8f);
            rig.rightThigh.localRotation = Quaternion.Slerp(rig.rightThigh.localRotation, rightThigh, Time.deltaTime * 8f);
        }

        private void UpdateFace()
        {
            if (rig.leftBrow == null || rig.rightBrow == null) return;

            float leftZ = 0f;
            float rightZ = 0f;
            if (state == Teacher3DState.Thinking) leftZ = -10f;
            if (state == Teacher3DState.Correction) { leftZ = 8f; rightZ = -8f; }
            if (state == Teacher3DState.Surprised) { leftZ = -12f; rightZ = 12f; }

            rig.leftBrow.localRotation = Quaternion.Slerp(
                rig.leftBrow.localRotation, Quaternion.Euler(0, 0, leftZ), Time.deltaTime * 8f);
            rig.rightBrow.localRotation = Quaternion.Slerp(
                rig.rightBrow.localRotation, Quaternion.Euler(0, 0, rightZ), Time.deltaTime * 8f);
        }

        private void UpdateAutomaticViseme()
        {
            autoVisemeTimer += Time.deltaTime;
            if (autoVisemeTimer < 0.095f) return;
            autoVisemeTimer = 0f;
            autoVisemeIndex = (autoVisemeIndex + 1) % speechCycle.Length;
            SetViseme(speechCycle[autoVisemeIndex]);
        }

        private void UpdatePropsAndEffects()
        {
            Teacher3DProp desired = prop;
            if (state == Teacher3DState.Reading) desired = Teacher3DProp.Book;
            if (state == Teacher3DState.Pointing) desired = Teacher3DProp.Pointer;
            if (state == Teacher3DState.WritingBoard) desired = Teacher3DProp.Chalk;

            rig.closedBook.SetActive(desired == Teacher3DProp.Book && state != Teacher3DState.Reading);
            rig.openBook.SetActive(desired == Teacher3DProp.Book && state == Teacher3DState.Reading);
            rig.pointer.SetActive(desired == Teacher3DProp.Pointer);
            rig.chalk.SetActive(desired == Teacher3DProp.Chalk);
            if (rig.praiseStars) rig.praiseStars.SetActive(state == Teacher3DState.Praise || state == Teacher3DState.Dancing);
            if (rig.listenWaves) rig.listenWaves.SetActive(state == Teacher3DState.Listening);
            if (rig.thinkingMark) rig.thinkingMark.SetActive(state == Teacher3DState.Thinking);
        }

        public void ApplyCommand(Teacher3DCommand command)
        {
            if (command == null) return;
            if (Enum.TryParse(command.state, true, out Teacher3DState parsedState))
                SetState(parsedState, command.duration);
            if (Enum.TryParse(command.prop, true, out Teacher3DProp parsedProp))
                prop = parsedProp;
            currentMessage = command.message ?? currentMessage;
            gazeX = Mathf.Clamp(command.gazeX, -1f, 1f);
            gazeY = Mathf.Clamp(command.gazeY, -1f, 1f);
            lowMotion = command.lowMotion;
            SetViseme((TeacherViseme)Mathf.Clamp(command.viseme, 0, 6));
            ApplyProp();
        }

        public void SetState(Teacher3DState next, float autoReturnSeconds = 0f)
        {
            state = next;
            stateTimer = 0f;
            if (autoReturnSeconds > 0f)
                CancelInvoke(nameof(ReturnIdle));
            if (autoReturnSeconds > 0f)
                Invoke(nameof(ReturnIdle), autoReturnSeconds);
        }

        private void ReturnIdle() => SetState(Teacher3DState.Idle);

        public void SetViseme(TeacherViseme next)
        {
            if (viseme == next) return;
            viseme = next;
            ApplyViseme();
        }

        private void ApplyViseme()
        {
            if (rig == null) return;
            GameObject[] mouths = rig.MouthObjects;
            for (int i = 0; i < mouths.Length; i++)
                if (mouths[i] != null) mouths[i].SetActive(i == (int)viseme);
        }

        private void ApplyProp()
        {
            if (rig == null) return;
            UpdatePropsAndEffects();
        }

        public void ReactToTouch(TeacherTouchPart part)
        {
            switch (part)
            {
                case TeacherTouchPart.Head:
                    SetState(Teacher3DState.Surprised, 1.5f);
                    break;
                case TeacherTouchPart.Glasses:
                    SetState(Teacher3DState.AdjustGlasses, 1.7f);
                    break;
                case TeacherTouchPart.Body:
                    SetState(Teacher3DState.Nodding, 1.5f);
                    break;
                case TeacherTouchPart.LeftHand:
                case TeacherTouchPart.RightHand:
                    SetState(Teacher3DState.Welcome, 1.8f);
                    break;
                case TeacherTouchPart.Book:
                    prop = Teacher3DProp.Book;
                    SetState(Teacher3DState.Reading, 2.2f);
                    break;
                case TeacherTouchPart.Pointer:
                    prop = Teacher3DProp.Pointer;
                    SetState(Teacher3DState.Pointing, 2.0f);
                    break;
                case TeacherTouchPart.Feet:
                    SetState(Teacher3DState.Dancing, 2.5f);
                    break;
            }
        }
    }
}
