using System;
using System.Collections.Generic;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    [DisallowMultipleComponent]
    public sealed class Teacher3DProductionAdapter : MonoBehaviour
    {
        public Teacher3DCharacterProfile profile;
        public Animator animator;
        public Teacher3DMotionController fallbackController;

        [Header("Animator Parameter Names")]
        public string stateParameter = "State";
        public string speakingParameter = "IsSpeaking";
        public string listeningParameter = "IsListening";
        public string gazeXParameter = "GazeX";
        public string gazeYParameter = "GazeY";
        public string lowMotionParameter = "LowMotion";
        public string gestureTrigger = "Gesture";

        private readonly Dictionary<string, int> blendshapeIndices =
            new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

        private float blinkTimer;
        private float nextBlink = 2.6f;
        private float manualBlink;
        private TeacherViseme currentViseme = TeacherViseme.Rest;

        private void Awake()
        {
            if (animator == null) animator = GetComponentInChildren<Animator>();
            if (fallbackController == null)
                fallbackController = GetComponent<Teacher3DMotionController>();
            CacheBlendshapeIndices();
            ConfigureRenderer();
        }

        private void Update()
        {
            if (profile == null || profile.faceRenderer == null) return;
            UpdateBlink();
        }

        private void ConfigureRenderer()
        {
            if (profile?.faceRenderer == null) return;
            profile.faceRenderer.updateWhenOffscreen =
                profile.useSkinnedMeshUpdateWhenOffscreen;
        }

        private void CacheBlendshapeIndices()
        {
            blendshapeIndices.Clear();
            if (profile?.faceRenderer?.sharedMesh == null) return;

            Mesh mesh = profile.faceRenderer.sharedMesh;
            for (int i = 0; i < mesh.blendShapeCount; i++)
                blendshapeIndices[mesh.GetBlendShapeName(i)] = i;
        }

        public bool HasBlendshape(string name) =>
            !string.IsNullOrWhiteSpace(name) &&
            blendshapeIndices.ContainsKey(name);

        public void ApplyCommand(Teacher3DCommand command)
        {
            if (command == null) return;

            if (animator != null)
            {
                animator.SetInteger(stateParameter, StateToAnimator(command.state));
                animator.SetBool(speakingParameter,
                    command.state.Equals("Speaking", StringComparison.OrdinalIgnoreCase));
                animator.SetBool(listeningParameter,
                    command.state.Equals("Listening", StringComparison.OrdinalIgnoreCase));
                animator.SetFloat(gazeXParameter, Mathf.Clamp(command.gazeX, -1f, 1f));
                animator.SetFloat(gazeYParameter, Mathf.Clamp(command.gazeY, -1f, 1f));
                animator.SetBool(lowMotionParameter, command.lowMotion);
            }

            ApplyGaze(command.gazeX, command.gazeY);
            SetViseme((TeacherViseme)Mathf.Clamp(command.viseme, 0, 6));
            SetExpressionForState(command.state);

            if (fallbackController != null)
                fallbackController.ApplyCommand(command);
        }

        public void TriggerGesture(string gesture)
        {
            if (animator == null || string.IsNullOrWhiteSpace(gesture)) return;
            animator.SetTrigger(gestureTrigger);
            animator.CrossFade(gesture, .12f);
        }

        public void SetViseme(TeacherViseme viseme, float weight = 100f)
        {
            if (profile?.faceRenderer == null) return;
            currentViseme = viseme;
            string[] names = profile.VisemeNames;

            for (int i = 0; i < names.Length; i++)
                SetBlendshape(names[i], i == (int)viseme ? weight : 0f);
        }

        public void SetExpressionForState(string state)
        {
            if (profile?.faceRenderer == null) return;
            ResetExpressionBlendshapes();

            if (state.Equals("Praise", StringComparison.OrdinalIgnoreCase))
                SetBlendshape(profile.expressionSmile, 100);
            else if (state.Equals("Laughing", StringComparison.OrdinalIgnoreCase) ||
                     state.Equals("Dancing", StringComparison.OrdinalIgnoreCase))
                SetBlendshape(profile.expressionLaugh, 100);
            else if (state.Equals("Surprised", StringComparison.OrdinalIgnoreCase))
                SetBlendshape(profile.expressionSurprise, 100);
            else if (state.Equals("Correction", StringComparison.OrdinalIgnoreCase))
                SetBlendshape(profile.expressionGentle, 100);
            else if (state.Equals("Sleepy", StringComparison.OrdinalIgnoreCase))
                SetBlendshape(profile.expressionSleepy, 100);
            else
                SetBlendshape(profile.expressionSmile, 55);
        }

        public void ApplyGaze(float x, float y)
        {
            x = Mathf.Clamp(x, -1f, 1f);
            y = Mathf.Clamp(y, -1f, 1f);

            Quaternion eyeRotation = Quaternion.Euler(-y * 8f, x * 11f, 0);
            if (profile?.leftEye != null)
                profile.leftEye.localRotation = Quaternion.Slerp(
                    profile.leftEye.localRotation, eyeRotation, Time.deltaTime * 12f);
            if (profile?.rightEye != null)
                profile.rightEye.localRotation = Quaternion.Slerp(
                    profile.rightEye.localRotation, eyeRotation, Time.deltaTime * 12f);
            if (profile?.head != null)
            {
                Quaternion headRotation = Quaternion.Euler(-y * 4f, x * 6f, 0);
                profile.head.localRotation = Quaternion.Slerp(
                    profile.head.localRotation, headRotation, Time.deltaTime * 6f);
            }
        }

        public void ManualBlink(float amount)
        {
            manualBlink = Mathf.Clamp01(amount);
            ApplyBlink(manualBlink * 100f);
        }

        private void UpdateBlink()
        {
            blinkTimer += Time.deltaTime;
            if (blinkTimer < nextBlink)
            {
                if (manualBlink <= 0)
                    ApplyBlink(0);
                return;
            }

            float phase = (blinkTimer - nextBlink) / .22f;
            float amount = Mathf.Sin(Mathf.Clamp01(phase) * Mathf.PI) * 100f;
            ApplyBlink(Mathf.Max(amount, manualBlink * 100f));

            if (phase >= 1f)
            {
                blinkTimer = 0;
                nextBlink = UnityEngine.Random.Range(2.0f, 5.2f);
            }
        }

        private void ApplyBlink(float weight)
        {
            SetBlendshape(profile.blinkLeft, weight);
            SetBlendshape(profile.blinkRight, weight);
        }

        private void ResetExpressionBlendshapes()
        {
            SetBlendshape(profile.expressionSmile, 0);
            SetBlendshape(profile.expressionLaugh, 0);
            SetBlendshape(profile.expressionSurprise, 0);
            SetBlendshape(profile.expressionGentle, 0);
            SetBlendshape(profile.expressionSleepy, 0);
        }

        private void SetBlendshape(string name, float weight)
        {
            if (profile?.faceRenderer == null ||
                string.IsNullOrWhiteSpace(name) ||
                !blendshapeIndices.TryGetValue(name, out int index))
                return;

            profile.faceRenderer.SetBlendShapeWeight(index, weight);
        }

        private int StateToAnimator(string state)
        {
            if (Enum.TryParse(state, true, out Teacher3DState parsed))
                return (int)parsed;
            return (int)Teacher3DState.Idle;
        }
    }
}
