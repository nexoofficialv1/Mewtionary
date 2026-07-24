# Error Handling

| Area | User message | Recovery |
|---|---|---|
| Microphone unavailable | Voice input is unavailable; type the answer. | Continue with text input |
| Speech recognition error | We could not hear clearly. Try again. | Retry or type |
| TTS unavailable | Audio playback is unavailable. | Continue reading on screen |
| Invalid dictionary pack | Pack verification failed. | Reject import and preserve existing data |
| Unsupported pack schema | This content version is not supported. | Ask for a compatible pack |
| Database write failure | Progress could not be saved. | Retry once and keep the current screen |
| Empty answer | Enter or select an answer first. | Keep question active |
| File export cancelled | No file was saved. | Return without data loss |
| Export directory unavailable | Export could not be written. | Use application documents fallback and report failure safely |
| Content file missing | Learning content is unavailable. | Show a safe empty-state screen |
| Time limit reached | Time is over; the exam was submitted. | Show result and review |

Errors must not expose stack traces, tokens, local paths or personal data
in the user interface.
