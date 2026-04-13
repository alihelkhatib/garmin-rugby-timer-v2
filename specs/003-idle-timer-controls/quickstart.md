# Quickstart: idle-timer-controls validation

1. Build app and install on a physical device (fenix 6 recommended).  
2. Launch the app and ensure no match is active (idle screen).  
3. Press Up/Menu short-press: expect main timer to increase by 1 minute.  
4. Press Down short-press: expect main timer to decrease by 1 minute (min 00:00).  
5. Verify score dialog is not accessible via Up/Menu when idle.  
6. Start a match and verify Up/Menu now opens the score dialog as before.  
7. Run tests in `tests/idle_button_behavior.mc` and `tests/timer_sync.mc` in simulator and on device.
