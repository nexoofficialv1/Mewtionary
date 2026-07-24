using System;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    [Serializable]
    public class Teacher3DRig : MonoBehaviour
    {
        [Header("Core")]
        public Transform bodyRoot;
        public Transform torso;
        public Transform headPivot;

        [Header("Face")]
        public Transform leftEye;
        public Transform rightEye;
        public Transform leftPupil;
        public Transform rightPupil;
        public Transform leftBrow;
        public Transform rightBrow;
        public Transform glassesRoot;

        [Header("Mouth Shapes")]
        public GameObject mouthRest;
        public GameObject mouthA;
        public GameObject mouthE;
        public GameObject mouthO;
        public GameObject mouthMBP;
        public GameObject mouthFV;
        public GameObject mouthLRTDN;

        [Header("Arms")]
        public Transform leftUpperArm;
        public Transform leftForearm;
        public Transform leftHand;
        public Transform rightUpperArm;
        public Transform rightForearm;
        public Transform rightHand;

        [Header("Legs")]
        public Transform leftThigh;
        public Transform leftShin;
        public Transform leftFoot;
        public Transform rightThigh;
        public Transform rightShin;
        public Transform rightFoot;

        [Header("Props")]
        public GameObject closedBook;
        public GameObject openBook;
        public GameObject pointer;
        public GameObject chalk;

        [Header("Effects")]
        public GameObject praiseStars;
        public GameObject listenWaves;
        public GameObject thinkingMark;

        public GameObject[] MouthObjects => new[]
        {
            mouthRest, mouthA, mouthE, mouthO, mouthMBP, mouthFV, mouthLRTDN
        };
    }
}
