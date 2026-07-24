using System;
using System.Collections;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public enum TeacherLessonMode
    {
        Dictionary,
        Tense,
        Vocabulary,
        Story,
        Speaking,
        Writing
    }

    [Serializable]
    public class TeacherLessonStep
    {
        public string state = "Speaking";
        [TextArea(2, 5)] public string text;
        public string prop = "None";
        public float holdSeconds = 1.4f;
    }

    public sealed class TeacherLessonDirector : MonoBehaviour
    {
        public Teacher3DCommandReceiver receiver;
        public TeacherLipSyncScheduler lipSync;
        public TeacherLessonMode mode;
        public TeacherLessonStep[] steps;
        public bool autoPlay;

        private Coroutine sequence;

        private void Start()
        {
            if (autoPlay && steps != null && steps.Length > 0)
                Play();
        }

        public void Play()
        {
            Stop();
            sequence = StartCoroutine(Run());
        }

        public void Stop()
        {
            if (sequence != null)
                StopCoroutine(sequence);
            sequence = null;
            lipSync?.StopLipSync();
            Send("Idle", "", "None");
        }

        public void LoadDictionaryDemo()
        {
            mode = TeacherLessonMode.Dictionary;
            steps = new[]
            {
                Step("Welcome", "আজ আমরা একটি নতুন শব্দ শিখব।", "Book", 1.4f),
                Step("Speaking", "Beautiful মানে সুন্দর।", "None", 2.0f),
                Step("Pointing", "বোর্ডে শব্দটির spelling দেখো: B E A U T I F U L.", "Pointer", 2.6f),
                Step("Listening", "এবার তুমি শব্দটি বলো।", "None", 2.2f),
                Step("Praise", "দারুণ! আবার একবার বলি—Beautiful.", "None", 2.0f),
            };
        }

        public void LoadTenseDemo()
        {
            mode = TeacherLessonMode.Tense;
            steps = new[]
            {
                Step("Welcome", "আজ আমরা Present Simple Tense শিখব।", "Book", 1.6f),
                Step("WritingBoard", "I play. You play. We play.", "Chalk", 2.5f),
                Step("Pointing", "He, She অথবা It-এর সঙ্গে verb-এর শেষে s অথবা es বসে।", "Pointer", 3.0f),
                Step("Speaking", "She plays football every day.", "None", 2.4f),
                Step("Thinking", "এখন বলো—He go হবে, নাকি He goes?", "None", 2.5f),
            };
        }

        public void LoadStoryDemo()
        {
            mode = TeacherLessonMode.Story;
            steps = new[]
            {
                Step("Reading", "Once there was an honest woodcutter.", "Book", 2.4f),
                Step("Reading", "একদিন তার কুঠার নদীতে পড়ে গেল।", "Book", 2.4f),
                Step("Surprised", "হঠাৎ নদী থেকে একটি পরী উঠল!", "None", 1.8f),
                Step("Thinking", "কাঠুরে কি সোনার কুঠারটি নিজের বলে নেবে?", "None", 2.4f),
                Step("Praise", "ঠিক বলেছ—সৎ মানুষ কখনো মিথ্যা বলে না।", "None", 2.2f),
            };
        }

        public void RespondCorrect()
        {
            Send("Praise", "দারুণ! তুমি সঠিক উত্তর দিয়েছ।", "None", 2.2f);
        }

        public void RespondIncorrect()
        {
            Send("Correction", "কোনো সমস্যা নেই। চলো আবার সহজভাবে চেষ্টা করি।", "None", 2.4f);
        }

        private IEnumerator Run()
        {
            if (steps == null) yield break;

            foreach (TeacherLessonStep step in steps)
            {
                Send(step.state, step.text, step.prop);
                if (step.state.Equals("Speaking", StringComparison.OrdinalIgnoreCase) ||
                    step.state.Equals("Reading", StringComparison.OrdinalIgnoreCase) ||
                    step.state.Equals("Pointing", StringComparison.OrdinalIgnoreCase) ||
                    step.state.Equals("WritingBoard", StringComparison.OrdinalIgnoreCase))
                {
                    lipSync?.PlayText(step.text);
                }

                yield return new WaitForSecondsRealtime(Mathf.Max(.3f, step.holdSeconds));
                lipSync?.StopLipSync();
            }

            Send("Idle", "আমি তোমার পরবর্তী প্রশ্নের জন্য প্রস্তুত।", "None");
            sequence = null;
        }

        private TeacherLessonStep Step(string state, string text, string prop, float hold)
        {
            return new TeacherLessonStep
            {
                state = state,
                text = text,
                prop = prop,
                holdSeconds = hold
            };
        }

        private void Send(
            string state,
            string message,
            string prop,
            float duration = 0f)
        {
            if (receiver == null) return;
            Teacher3DCommand command = new Teacher3DCommand
            {
                state = state,
                message = message,
                prop = prop,
                duration = duration
            };
            receiver.ReceiveCommand(JsonUtility.ToJson(command));
        }
    }
}
