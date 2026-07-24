import 'teacher_3d_bridge.dart';

enum MewtionaryLessonMode {
  dictionary,
  tense,
  vocabulary,
  story,
  speaking,
  writing,
}

class Teacher3DLessonController {
  Teacher3DLessonController({Teacher3DBridge? bridge})
      : bridge = bridge ?? Teacher3DBridge();

  final Teacher3DBridge bridge;

  Future<void> welcome(String childName) => bridge.send(
        state: Teacher3DState.welcome,
        message: 'হ্যালো $childName! আজ আমরা আনন্দ করে শিখব।',
        prop: Teacher3DProp.book,
        duration: 1.8,
      );

  Future<void> explainDictionaryWord({
    required String word,
    required String meaning,
    required String example,
  }) async {
    await bridge.send(
      state: Teacher3DState.speaking,
      message: '$word মানে $meaning।',
    );
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    await bridge.send(
      state: Teacher3DState.pointing,
      message: 'Example: $example',
      prop: Teacher3DProp.pointer,
    );
  }

  Future<void> teachPresentTense() async {
    await bridge.send(
      state: Teacher3DState.writingBoard,
      message: 'Present Simple Tense বর্তমান সময়ের নিয়মিত কাজ বোঝায়।',
      prop: Teacher3DProp.chalk,
    );
    await Future<void>.delayed(const Duration(milliseconds: 1800));
    await bridge.send(
      state: Teacher3DState.pointing,
      message: 'He, She অথবা It-এর সঙ্গে verb-এর শেষে s বা es বসে।',
      prop: Teacher3DProp.pointer,
    );
  }

  Future<void> startStory(String openingLine) => bridge.send(
        state: Teacher3DState.reading,
        message: openingLine,
        prop: Teacher3DProp.book,
      );

  Future<void> listenToChild() =>
      bridge.send(state: Teacher3DState.listening);

  Future<void> praise() => bridge.send(
        state: Teacher3DState.praise,
        message: 'দারুণ! তুমি একদম ঠিক বলেছ।',
        duration: 2.2,
      );

  Future<void> correctGently(String hint) => bridge.send(
        state: Teacher3DState.correction,
        message: 'কোনো সমস্যা নেই। $hint',
        duration: 2.4,
      );

  Future<void> celebrate() => bridge.send(
        state: Teacher3DState.dancing,
        message: 'ইয়াহু! আজকের lesson complete!',
        duration: 2.8,
      );
}
