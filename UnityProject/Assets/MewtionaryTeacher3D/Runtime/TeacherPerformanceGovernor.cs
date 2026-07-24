using UnityEngine;

namespace Mewtionary.Teacher3D
{
    public enum TeacherQualityTier
    {
        Low,
        Medium,
        High
    }

    public sealed class TeacherPerformanceGovernor : MonoBehaviour
    {
        public TeacherQualityTier forcedTier = TeacherQualityTier.High;
        public bool autoDetect = true;
        public LODGroup characterLod;
        public Light[] optionalLights;
        public ParticleSystem[] celebrationParticles;
        public SkinnedMeshRenderer[] skinnedMeshes;

        public TeacherQualityTier ActiveTier { get; private set; }

        private void Awake()
        {
            ActiveTier = autoDetect ? DetectTier() : forcedTier;
            Apply(ActiveTier);
        }

        public TeacherQualityTier DetectTier()
        {
            int memory = SystemInfo.systemMemorySize;
            int graphicsMemory = SystemInfo.graphicsMemorySize;
            int cores = SystemInfo.processorCount;

            if (memory <= 3500 || graphicsMemory <= 900 || cores <= 4)
                return TeacherQualityTier.Low;
            if (memory <= 6000 || graphicsMemory <= 1800 || cores <= 6)
                return TeacherQualityTier.Medium;
            return TeacherQualityTier.High;
        }

        public void Apply(TeacherQualityTier tier)
        {
            ActiveTier = tier;

            switch (tier)
            {
                case TeacherQualityTier.Low:
                    Application.targetFrameRate = 30;
                    QualitySettings.shadowDistance = 8;
                    QualitySettings.lodBias = .65f;
                    SetLights(false);
                    SetParticles(false);
                    SetOffscreenUpdates(false);
                    break;

                case TeacherQualityTier.Medium:
                    Application.targetFrameRate = 45;
                    QualitySettings.shadowDistance = 15;
                    QualitySettings.lodBias = 1f;
                    SetLights(true);
                    SetParticles(true);
                    SetOffscreenUpdates(false);
                    break;

                default:
                    Application.targetFrameRate = 60;
                    QualitySettings.shadowDistance = 25;
                    QualitySettings.lodBias = 1.35f;
                    SetLights(true);
                    SetParticles(true);
                    SetOffscreenUpdates(false);
                    break;
            }
        }

        private void SetLights(bool enabled)
        {
            if (optionalLights == null) return;
            foreach (Light light in optionalLights)
                if (light != null) light.enabled = enabled;
        }

        private void SetParticles(bool enabled)
        {
            if (celebrationParticles == null) return;
            foreach (ParticleSystem particle in celebrationParticles)
                if (particle != null)
                {
                    if (enabled) particle.Play();
                    else particle.Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);
                }
        }

        private void SetOffscreenUpdates(bool enabled)
        {
            if (skinnedMeshes == null) return;
            foreach (SkinnedMeshRenderer mesh in skinnedMeshes)
                if (mesh != null) mesh.updateWhenOffscreen = enabled;
        }
    }
}
