# Test Traceability

| Requirement area | Automated coverage | Device/simulator coverage |
|---|---|---|
| Match start/pause/resume/reset | `Test_RugbyGameModel`, `Test_RugbyIdleTimerControls` | Full control smoke flow |
| Timestamp accuracy/delayed callbacks | `Test_RugbyGameModel`, `Test_RugbyTime` | Full-length drift check |
| Period and final auto transition | `Test_RugbyGameModel`, `Test_RugbyMatchController` | Summary opens once |
| Variants and clock adjustments | `Test_RugbyVariantConfig`, `Test_RugbyIdleTimerControls` | Pre-match menu on each profile |
| Scores, latest-event undo, and event history | `Test_RugbyGameModel` | Menu navigation and summary |
| Conversion timer | `Test_RugbyGameModel`, `Test_RugbyPersistence` | Overlay and haptic behavior |
| Yellow/red cards | `Test_RugbyGameModel` | Multiple-card layout and haptics |
| Input gates, recoverable/terminal exit states, and confirmations | `Test_RugbyGameModel`, `Test_RugbyIdleTimerControls` | Physical-button, Exit & save, and Stop & exit checks |
| Activity recording, GPS, mileage, heart rate, and rugby FIT events | `Test_RugbyActivityRecorder`, `Test_RugbyMatchController` | Physical FIT route/distance/HR, event lap fields, and save/discard |
| Interrupted-match recovery | `Test_RugbyPersistence` | Exit/relaunch restores paused |
| Layout/resource compatibility | Compiler resource validation, `Test_RugbyLayoutSupport` | Fēnix 6 and Instinct 2 visual checks; Fēnix 7 build validation |
