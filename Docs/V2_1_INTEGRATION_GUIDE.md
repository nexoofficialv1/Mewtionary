# v2.1 Final Character Integration Guide

## 1. Import final model
Final FBX/GLB-টি Unity Project-এর `Assets/Characters/` folder-এ রাখুন।

Model Import Settings:
- Animation Type: Humanoid
- Avatar Definition: Create From This Model
- Read/Write: Off, যদি runtime mesh modification না লাগে
- Optimize Game Objects: facial/prop anchors যাচাই করার পরে
- Materials: Extract Materials
- Blend Shapes: On

## 2. Run auto-mapping
Unity menu:

```text
Mewtionary
→ Final Character Setup Wizard
```

Source Character select করে:

```text
Analyse Character
Create Profile and Runtime Prefab
```

Wizard তৈরি করবে:
- `Teacher3DCharacterProfile.asset`
- `MewtionaryTeacher_Final_Runtime.prefab`

Unknown mappings Inspector থেকে যাচাই করতে হবে।

## 3. Blendshape names
`FINAL_FBX_NAMING_STANDARD.json`-এর নাম অনুসরণ করলে viseme ও expressions auto-map হবে।

## 4. Lesson integration
`TeacherLessonDirector`-এ Dictionary, Tense ও Story demo রয়েছে। মূল app Flutter bridge দিয়ে একই JSON command পাঠাবে।

## 5. Flutter–Unity Android integration
Unity project Android Library হিসেবে export করুন। Generated `unityLibrary` module Flutter Android host project-এ যুক্ত করুন। Reflection-based plugin Unity library absent থাকলেও compile করতে পারে, কিন্তু teacher command চালাতে embedded Unity প্রয়োজন।

## 6. Validate
Unity menu:

```text
Mewtionary
→ Validate Android Teacher Build
```

তারপর real Android device-এ:
- voice start/stop
- touch zones
- orientation
- pause/resume
- 30/60 FPS
- memory usage
পরীক্ষা করুন।
