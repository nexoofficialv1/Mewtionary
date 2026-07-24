# API

Mewtionary v2.8 has no required backend API.

Internal application services act as local APIs:

- `DictionaryPackService`
- `CurriculumEngine`
- `DiagnosticService`
- `PronunciationCoachService`
- `MockExamService`
- `StudyPlannerService`
- `GamificationService`
- `ParentReportService`

A future sync API must be optional, authenticated, encrypted and designed
so the offline app remains functional when the service is unavailable.
