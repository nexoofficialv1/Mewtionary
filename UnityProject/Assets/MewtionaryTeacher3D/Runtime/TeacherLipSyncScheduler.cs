using System;
using System.Collections;
using System.Collections.Generic;
using System.Text;
using UnityEngine;

namespace Mewtionary.Teacher3D
{
    [Serializable]
    public struct TimedViseme
    {
        public TeacherViseme viseme;
        public float duration;

        public TimedViseme(TeacherViseme viseme, float duration)
        {
            this.viseme = viseme;
            this.duration = duration;
        }
    }

    public sealed class TeacherLipSyncScheduler : MonoBehaviour
    {
        public Teacher3DMotionController fallbackController;
        public Teacher3DProductionAdapter productionAdapter;
        [Range(.04f, .20f)] public float baseStepSeconds = .095f;
        [Range(.5f, 2f)] public float durationMultiplier = 1f;

        private Coroutine playback;

        public void PlayText(string text)
        {
            StopLipSync();
            playback = StartCoroutine(PlayTimeline(BuildTimeline(text)));
        }

        public void StopLipSync()
        {
            if (playback != null)
                StopCoroutine(playback);
            playback = null;
            SetViseme(TeacherViseme.Rest);
        }

        public List<TimedViseme> BuildTimeline(string text)
        {
            List<TimedViseme> result = new List<TimedViseme>();
            if (string.IsNullOrWhiteSpace(text))
            {
                result.Add(new TimedViseme(TeacherViseme.Rest, baseStepSeconds));
                return result;
            }

            string normalized = text.Normalize(NormalizationForm.FormC).ToLowerInvariant();
            foreach (char c in normalized)
            {
                TeacherViseme viseme = MapCharacter(c);
                float duration = DurationForCharacter(c);

                if (result.Count > 0 &&
                    result[result.Count - 1].viseme == viseme &&
                    !char.IsWhiteSpace(c))
                {
                    TimedViseme last = result[result.Count - 1];
                    last.duration = Mathf.Min(last.duration + duration, .28f);
                    result[result.Count - 1] = last;
                }
                else
                {
                    result.Add(new TimedViseme(viseme, duration));
                }
            }

            if (result.Count == 0)
                result.Add(new TimedViseme(TeacherViseme.Rest, baseStepSeconds));
            return result;
        }

        private IEnumerator PlayTimeline(List<TimedViseme> timeline)
        {
            foreach (TimedViseme item in timeline)
            {
                SetViseme(item.viseme);
                yield return new WaitForSecondsRealtime(item.duration * durationMultiplier);
            }

            SetViseme(TeacherViseme.Rest);
            playback = null;
        }

        private void SetViseme(TeacherViseme viseme)
        {
            if (productionAdapter != null)
                productionAdapter.SetViseme(viseme);
            if (fallbackController != null)
                fallbackController.SetViseme(viseme);
        }

        private TeacherViseme MapCharacter(char c)
        {
            if ("মবপmbp".IndexOf(c) >= 0) return TeacherViseme.MBP;
            if ("ফভfv".IndexOf(c) >= 0) return TeacherViseme.FV;
            if ("ওোৌউুূoou".IndexOf(c) >= 0) return TeacherViseme.O;
            if ("এেৈইিীeyei".IndexOf(c) >= 0) return TeacherViseme.E;
            if ("আাঅa".IndexOf(c) >= 0) return TeacherViseme.A;
            if ("লরটডতদনlrtdn".IndexOf(c) >= 0) return TeacherViseme.LRTDN;
            if (char.IsWhiteSpace(c) || char.IsPunctuation(c))
                return TeacherViseme.Rest;
            if ((c >= '\u0980' && c <= '\u09FF') || char.IsLetter(c))
                return (c % 2 == 0) ? TeacherViseme.A : TeacherViseme.E;
            return TeacherViseme.Rest;
        }

        private float DurationForCharacter(char c)
        {
            if (c == '.' || c == '!' || c == '?' || c == '।')
                return baseStepSeconds * 3.2f;
            if (c == ',' || c == ';' || c == ':')
                return baseStepSeconds * 2.0f;
            if (char.IsWhiteSpace(c))
                return baseStepSeconds * 1.5f;
            return baseStepSeconds;
        }
    }
}
