using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public static class ProceduralTeacherFactory
    {
        private static Material Mat(string name, Color color, float smoothness = .35f)
        {
            Shader shader = Shader.Find("Standard");
            Material mat = new Material(shader) { name = name, color = color };
            mat.SetFloat("_Glossiness", smoothness);
            return mat;
        }

        private static GameObject Primitive(
            PrimitiveType type, string name, Transform parent,
            Vector3 localPosition, Vector3 localScale, Material material)
        {
            GameObject go = GameObject.CreatePrimitive(type);
            go.name = name;
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            go.transform.localScale = localScale;
            go.GetComponent<Renderer>().sharedMaterial = material;
            return go;
        }

        private static Transform Pivot(string name, Transform parent, Vector3 localPosition)
        {
            GameObject go = new GameObject(name);
            go.transform.SetParent(parent, false);
            go.transform.localPosition = localPosition;
            return go.transform;
        }

        private static GameObject AddTouch(GameObject target, TeacherTouchPart part)
        {
            TeacherTouchZone zone = target.AddComponent<TeacherTouchZone>();
            zone.part = part;
            return target;
        }

        public static GameObject Create(Vector3 position)
        {
            Material skin = Mat("Skin", new Color(.96f, .62f, .45f), .25f);
            Material skinShadow = Mat("SkinShadow", new Color(.83f, .39f, .29f), .22f);
            Material hair = Mat("Hair", new Color(.19f, .08f, .055f), .42f);
            Material hairLight = Mat("HairLight", new Color(.34f, .15f, .10f), .38f);
            Material white = Mat("Shirt", new Color(1f, .97f, .91f), .2f);
            Material vest = Mat("Vest", new Color(.20f, .19f, .17f), .32f);
            Material pants = Mat("Trousers", new Color(.47f, .31f, .23f), .25f);
            Material shoe = Mat("Shoes", new Color(.20f, .075f, .04f), .5f);
            Material tie = Mat("Tie", new Color(.02f, .24f, .40f), .45f);
            Material eyeWhite = Mat("EyeWhite", Color.white, .7f);
            Material iris = Mat("Iris", new Color(.27f, .12f, .07f), .65f);
            Material black = Mat("Black", new Color(.02f, .015f, .012f), .45f);
            Material mouth = Mat("Mouth", new Color(.36f, .035f, .04f), .3f);
            Material tongue = Mat("Tongue", new Color(.8f, .18f, .20f), .35f);
            Material bookMat = Mat("Book", new Color(.39f, .055f, .08f), .4f);
            Material paper = Mat("Paper", new Color(.94f, .83f, .62f), .15f);
            Material wood = Mat("Pointer", new Color(.26f, .10f, .04f), .25f);
            Material chalkMat = Mat("Chalk", Color.white, .05f);
            Material starMat = Mat("Stars", new Color(1f, .68f, .04f), .6f);

            GameObject root = new GameObject("MewtionaryTeacher");
            root.transform.position = position;

            Teacher3DRig rig = root.AddComponent<Teacher3DRig>();
            Teacher3DMotionController motion = root.AddComponent<Teacher3DMotionController>();
            Teacher3DCommandReceiver receiver = root.AddComponent<Teacher3DCommandReceiver>();
            TeacherLipSyncScheduler lipSync = root.AddComponent<TeacherLipSyncScheduler>();
            TeacherLessonDirector lessonDirector = root.AddComponent<TeacherLessonDirector>();
            TeacherPerformanceGovernor governor = root.AddComponent<TeacherPerformanceGovernor>();
            motion.rig = rig;
            receiver.controller = motion;
            receiver.lipSync = lipSync;
            lipSync.fallbackController = motion;
            lessonDirector.receiver = receiver;
            lessonDirector.lipSync = lipSync;
            lessonDirector.LoadDictionaryDemo();
            governor.autoDetect = true;
            rig.bodyRoot = root.transform;

            Transform torsoPivot = Pivot("Torso", root.transform, new Vector3(0, 1.62f, 0));
            rig.torso = torsoPivot;
            GameObject shirtBody = Primitive(PrimitiveType.Capsule, "ShirtBody", torsoPivot,
                Vector3.zero, new Vector3(.56f, .62f, .34f), white);
            shirtBody.transform.localRotation = Quaternion.Euler(0, 0, 0);
            AddTouch(shirtBody, TeacherTouchPart.Body);

            Primitive(PrimitiveType.Cube, "VestLeft", torsoPivot,
                new Vector3(-.16f, 0, -.19f), new Vector3(.27f, .68f, .08f), vest);
            Primitive(PrimitiveType.Cube, "VestRight", torsoPivot,
                new Vector3(.16f, 0, -.19f), new Vector3(.27f, .68f, .08f), vest);
            Primitive(PrimitiveType.Cube, "Tie", torsoPivot,
                new Vector3(0, .10f, -.27f), new Vector3(.11f, .45f, .055f), tie);
            for (int i = 0; i < 3; i++)
                Primitive(PrimitiveType.Sphere, "VestButton_" + i, torsoPivot,
                    new Vector3(0, .12f - i * .20f, -.30f), new Vector3(.035f, .035f, .025f), skinShadow);

            // Legs
            rig.leftThigh = Pivot("LeftThigh", root.transform, new Vector3(-.20f, 1.09f, 0));
            Primitive(PrimitiveType.Capsule, "LeftLeg", rig.leftThigh,
                new Vector3(0, -.42f, 0), new Vector3(.19f, .48f, .20f), pants);
            rig.leftShin = rig.leftThigh;
            GameObject leftFoot = Primitive(PrimitiveType.Cube, "LeftFoot", root.transform,
                new Vector3(-.20f, .20f, -.09f), new Vector3(.27f, .14f, .43f), shoe);
            rig.leftFoot = leftFoot.transform;
            AddTouch(leftFoot, TeacherTouchPart.Feet);

            rig.rightThigh = Pivot("RightThigh", root.transform, new Vector3(.20f, 1.09f, 0));
            Primitive(PrimitiveType.Capsule, "RightLeg", rig.rightThigh,
                new Vector3(0, -.42f, 0), new Vector3(.19f, .48f, .20f), pants);
            rig.rightShin = rig.rightThigh;
            GameObject rightFoot = Primitive(PrimitiveType.Cube, "RightFoot", root.transform,
                new Vector3(.20f, .20f, -.09f), new Vector3(.27f, .14f, .43f), shoe);
            rig.rightFoot = rightFoot.transform;
            AddTouch(rightFoot, TeacherTouchPart.Feet);

            // Head pivot and face
            rig.headPivot = Pivot("HeadPivot", root.transform, new Vector3(0, 2.37f, 0));
            GameObject head = Primitive(PrimitiveType.Sphere, "Head", rig.headPivot,
                Vector3.zero, new Vector3(.63f, .72f, .58f), skin);
            AddTouch(head, TeacherTouchPart.Head);
            Primitive(PrimitiveType.Sphere, "LeftEar", rig.headPivot,
                new Vector3(-.57f, -.02f, 0), new Vector3(.15f, .24f, .12f), skin);
            Primitive(PrimitiveType.Sphere, "RightEar", rig.headPivot,
                new Vector3(.57f, -.02f, 0), new Vector3(.15f, .24f, .12f), skin);

            // Hair and beard
            Primitive(PrimitiveType.Sphere, "HairTop", rig.headPivot,
                new Vector3(0, .46f, .02f), new Vector3(.66f, .30f, .55f), hair);
            Primitive(PrimitiveType.Sphere, "HairSweep", rig.headPivot,
                new Vector3(-.15f, .58f, -.15f), new Vector3(.50f, .20f, .34f), hairLight);
            Primitive(PrimitiveType.Sphere, "Beard", rig.headPivot,
                new Vector3(0, -.37f, -.34f), new Vector3(.48f, .34f, .19f), hair);
            Primitive(PrimitiveType.Cube, "MoustacheLeft", rig.headPivot,
                new Vector3(-.12f, -.18f, -.57f), new Vector3(.20f, .055f, .055f), hair);
            Primitive(PrimitiveType.Cube, "MoustacheRight", rig.headPivot,
                new Vector3(.12f, -.18f, -.57f), new Vector3(.20f, .055f, .055f), hair);
            Primitive(PrimitiveType.Sphere, "Nose", rig.headPivot,
                new Vector3(0, -.05f, -.58f), new Vector3(.11f, .10f, .09f), skinShadow);

            // Eyes
            rig.leftEye = Primitive(PrimitiveType.Sphere, "LeftEye", rig.headPivot,
                new Vector3(-.21f, .08f, -.52f), new Vector3(.17f, .22f, .08f), eyeWhite).transform;
            rig.rightEye = Primitive(PrimitiveType.Sphere, "RightEye", rig.headPivot,
                new Vector3(.21f, .08f, -.52f), new Vector3(.17f, .22f, .08f), eyeWhite).transform;
            rig.leftPupil = Primitive(PrimitiveType.Sphere, "LeftPupil", rig.leftEye,
                new Vector3(0, 0, -.88f), new Vector3(.46f, .46f, .18f), iris).transform;
            rig.rightPupil = Primitive(PrimitiveType.Sphere, "RightPupil", rig.rightEye,
                new Vector3(0, 0, -.88f), new Vector3(.46f, .46f, .18f), iris).transform;
            Primitive(PrimitiveType.Sphere, "LeftPupilBlack", rig.leftPupil,
                new Vector3(0, 0, -.65f), new Vector3(.48f, .48f, .18f), black);
            Primitive(PrimitiveType.Sphere, "RightPupilBlack", rig.rightPupil,
                new Vector3(0, 0, -.65f), new Vector3(.48f, .48f, .18f), black);

            rig.leftBrow = Primitive(PrimitiveType.Cube, "LeftBrow", rig.headPivot,
                new Vector3(-.21f, .34f, -.55f), new Vector3(.30f, .055f, .05f), hair).transform;
            rig.rightBrow = Primitive(PrimitiveType.Cube, "RightBrow", rig.headPivot,
                new Vector3(.21f, .34f, -.55f), new Vector3(.30f, .055f, .05f), hair).transform;

            // Glasses (stylized rectangular/rounded frame)
            rig.glassesRoot = Pivot("GlassesRoot", rig.headPivot, Vector3.zero);
            GameObject glassesTouch = new GameObject("GlassesTouch");
            glassesTouch.transform.SetParent(rig.glassesRoot, false);
            BoxCollider gc = glassesTouch.AddComponent<BoxCollider>();
            gc.center = new Vector3(0, .08f, -.65f);
            gc.size = new Vector3(.86f, .46f, .12f);
            TeacherTouchZone gz = glassesTouch.AddComponent<TeacherTouchZone>();
            gz.part = TeacherTouchPart.Glasses;
            foreach (float x in new[] { -.21f, .21f })
            {
                Primitive(PrimitiveType.Cube, "GlassTop", rig.glassesRoot,
                    new Vector3(x, .29f, -.64f), new Vector3(.34f, .035f, .035f), black);
                Primitive(PrimitiveType.Cube, "GlassBottom", rig.glassesRoot,
                    new Vector3(x, -.12f, -.64f), new Vector3(.34f, .035f, .035f), black);
                Primitive(PrimitiveType.Cube, "GlassLeft", rig.glassesRoot,
                    new Vector3(x - .17f, .085f, -.64f), new Vector3(.035f, .43f, .035f), black);
                Primitive(PrimitiveType.Cube, "GlassRight", rig.glassesRoot,
                    new Vector3(x + .17f, .085f, -.64f), new Vector3(.035f, .43f, .035f), black);
            }
            Primitive(PrimitiveType.Cube, "GlassBridge", rig.glassesRoot,
                new Vector3(0, .08f, -.64f), new Vector3(.10f, .03f, .035f), black);

            // Mouth visemes
            Transform mouthRoot = Pivot("MouthRoot", rig.headPivot, new Vector3(0, -.25f, -.58f));
            rig.mouthRest = Primitive(PrimitiveType.Cube, "Mouth_Rest", mouthRoot,
                Vector3.zero, new Vector3(.22f, .025f, .035f), mouth);
            rig.mouthA = Primitive(PrimitiveType.Sphere, "Mouth_A", mouthRoot,
                Vector3.zero, new Vector3(.16f, .11f, .045f), mouth);
            rig.mouthE = Primitive(PrimitiveType.Cube, "Mouth_E", mouthRoot,
                Vector3.zero, new Vector3(.25f, .075f, .04f), mouth);
            rig.mouthO = Primitive(PrimitiveType.Sphere, "Mouth_O", mouthRoot,
                Vector3.zero, new Vector3(.10f, .14f, .045f), mouth);
            rig.mouthMBP = Primitive(PrimitiveType.Cube, "Mouth_MBP", mouthRoot,
                Vector3.zero, new Vector3(.21f, .035f, .04f), mouth);
            rig.mouthFV = Primitive(PrimitiveType.Cube, "Mouth_FV", mouthRoot,
                new Vector3(0, -.01f, 0), new Vector3(.21f, .055f, .04f), mouth);
            rig.mouthLRTDN = Primitive(PrimitiveType.Sphere, "Mouth_LRTDN", mouthRoot,
                Vector3.zero, new Vector3(.13f, .09f, .045f), tongue);

            // Arms with pivots
            rig.leftUpperArm = Pivot("LeftUpperArm", torsoPivot, new Vector3(-.48f, .25f, 0));
            Primitive(PrimitiveType.Capsule, "LeftUpperArmMesh", rig.leftUpperArm,
                new Vector3(0, -.25f, 0), new Vector3(.14f, .31f, .14f), white);
            rig.leftForearm = Pivot("LeftForearm", rig.leftUpperArm, new Vector3(0, -.55f, 0));
            Primitive(PrimitiveType.Capsule, "LeftForearmMesh", rig.leftForearm,
                new Vector3(0, -.23f, 0), new Vector3(.12f, .28f, .12f), skin);
            GameObject leftHand = Primitive(PrimitiveType.Sphere, "LeftHand", rig.leftForearm,
                new Vector3(0, -.52f, 0), new Vector3(.16f, .18f, .13f), skin);
            rig.leftHand = leftHand.transform;
            AddTouch(leftHand, TeacherTouchPart.LeftHand);

            rig.rightUpperArm = Pivot("RightUpperArm", torsoPivot, new Vector3(.48f, .25f, 0));
            Primitive(PrimitiveType.Capsule, "RightUpperArmMesh", rig.rightUpperArm,
                new Vector3(0, -.25f, 0), new Vector3(.14f, .31f, .14f), white);
            rig.rightForearm = Pivot("RightForearm", rig.rightUpperArm, new Vector3(0, -.55f, 0));
            Primitive(PrimitiveType.Capsule, "RightForearmMesh", rig.rightForearm,
                new Vector3(0, -.23f, 0), new Vector3(.12f, .28f, .12f), skin);
            GameObject rightHand = Primitive(PrimitiveType.Sphere, "RightHand", rig.rightForearm,
                new Vector3(0, -.52f, 0), new Vector3(.16f, .18f, .13f), skin);
            rig.rightHand = rightHand.transform;
            AddTouch(rightHand, TeacherTouchPart.RightHand);

            // Props
            rig.closedBook = Primitive(PrimitiveType.Cube, "ClosedBook", rig.leftHand,
                new Vector3(-.08f, -.05f, -.05f), new Vector3(.34f, .48f, .10f), bookMat);
            AddTouch(rig.closedBook, TeacherTouchPart.Book);

            rig.openBook = new GameObject("OpenBook");
            rig.openBook.transform.SetParent(torsoPivot, false);
            rig.openBook.transform.localPosition = new Vector3(0, -.22f, -.52f);
            GameObject pageL = Primitive(PrimitiveType.Cube, "PageLeft", rig.openBook.transform,
                new Vector3(-.18f, 0, 0), new Vector3(.34f, .30f, .035f), paper);
            pageL.transform.localRotation = Quaternion.Euler(0, -18, 0);
            GameObject pageR = Primitive(PrimitiveType.Cube, "PageRight", rig.openBook.transform,
                new Vector3(.18f, 0, 0), new Vector3(.34f, .30f, .035f), paper);
            pageR.transform.localRotation = Quaternion.Euler(0, 18, 0);

            rig.pointer = Primitive(PrimitiveType.Cylinder, "Pointer", rig.rightHand,
                new Vector3(0, -.42f, -.03f), new Vector3(.025f, .48f, .025f), wood);
            rig.pointer.transform.localRotation = Quaternion.Euler(0, 0, 0);
            AddTouch(rig.pointer, TeacherTouchPart.Pointer);

            rig.chalk = Primitive(PrimitiveType.Cylinder, "Chalk", rig.rightHand,
                new Vector3(0, -.14f, -.04f), new Vector3(.035f, .13f, .035f), chalkMat);

            // Effects
            rig.praiseStars = new GameObject("PraiseStars");
            rig.praiseStars.transform.SetParent(root.transform, false);
            for (int i = 0; i < 5; i++)
                Primitive(PrimitiveType.Sphere, "Star_" + i, rig.praiseStars.transform,
                    new Vector3(Mathf.Sin(i * 1.4f) * .85f, 2.4f + (i % 2) * .35f, -.25f),
                    Vector3.one * .08f, starMat);

            rig.listenWaves = new GameObject("ListenWaves");
            rig.listenWaves.transform.SetParent(rig.headPivot, false);
            Primitive(PrimitiveType.Cube, "Wave1", rig.listenWaves.transform,
                new Vector3(.72f, .05f, -.1f), new Vector3(.04f, .25f, .04f), tie);
            Primitive(PrimitiveType.Cube, "Wave2", rig.listenWaves.transform,
                new Vector3(.84f, .05f, -.1f), new Vector3(.04f, .38f, .04f), tie);

            rig.thinkingMark = new GameObject("ThinkingMark");
            rig.thinkingMark.transform.SetParent(rig.headPivot, false);
            Primitive(PrimitiveType.Sphere, "QuestionDot", rig.thinkingMark.transform,
                new Vector3(.70f, .42f, 0), Vector3.one * .08f, tie);
            Primitive(PrimitiveType.Cube, "QuestionStem", rig.thinkingMark.transform,
                new Vector3(.70f, .62f, 0), new Vector3(.08f, .25f, .08f), tie);

            motion.rig = rig;
            return root;
        }
    }
}
