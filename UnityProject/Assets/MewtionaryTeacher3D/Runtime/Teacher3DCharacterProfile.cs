using System;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    [CreateAssetMenu(
        fileName = "Teacher3DCharacterProfile",
        menuName = "Mewtionary/Teacher 3D Character Profile")]
    public sealed class Teacher3DCharacterProfile : ScriptableObject
    {
        [Header("Identity")]
        public string characterId = "mewtionary_male_teacher_v1";
        public string displayName = "Mewtionary Teacher";
        public GameObject characterPrefab;

        [Header("Animator")]
        public RuntimeAnimatorController animatorController;
        public Avatar humanoidAvatar;

        [Header("Blendshape Renderer")]
        public SkinnedMeshRenderer faceRenderer;

        [Header("Viseme Blendshape Names")]
        public string visemeRest = "viseme_REST";
        public string visemeA = "viseme_A";
        public string visemeE = "viseme_E";
        public string visemeO = "viseme_O";
        public string visemeMBP = "viseme_MBP";
        public string visemeFV = "viseme_FV";
        public string visemeLRTDN = "viseme_LRTDN";

        [Header("Expression Blendshape Names")]
        public string expressionSmile = "expr_SMILE";
        public string expressionLaugh = "expr_LAUGH";
        public string expressionSurprise = "expr_SURPRISE";
        public string expressionGentle = "expr_GENTLE";
        public string expressionSleepy = "expr_SLEEPY";
        public string blinkLeft = "blink_L";
        public string blinkRight = "blink_R";

        [Header("Rig Transforms")]
        public Transform head;
        public Transform leftEye;
        public Transform rightEye;
        public Transform glasses;
        public Transform leftHand;
        public Transform rightHand;
        public Transform bookAnchor;
        public Transform pointerAnchor;
        public Transform chalkAnchor;

        [Header("Props")]
        public GameObject closedBookPrefab;
        public GameObject openBookPrefab;
        public GameObject pointerPrefab;
        public GameObject chalkPrefab;

        [Header("Mobile Quality")]
        [Range(0, 100000)] public int lod0TriangleBudget = 45000;
        [Range(0, 100000)] public int lod1TriangleBudget = 22000;
        [Range(0, 100000)] public int lod2TriangleBudget = 9000;
        public bool useSkinnedMeshUpdateWhenOffscreen = false;

        public string[] VisemeNames => new[]
        {
            visemeRest, visemeA, visemeE, visemeO,
            visemeMBP, visemeFV, visemeLRTDN
        };
    }
}
