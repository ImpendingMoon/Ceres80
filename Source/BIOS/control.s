;**
; exit: Exit
; Exits the current program and restarts the shell (by resetting the system...)
; Parameters: None
; Returns: N/A
;**
e_exit:
i_exit:
    RST $00



;**
; get_bios_version: Get BIOS Version
; Gets the current BIOS version as three integers
; Parameters: None
; Returns: None
;**
e_get_bios_version:
    POP HL
    POP DE
i_get_bios_version:
    LD A, BIOS_MAJOR_VER
    LD L, BIOS_MINOR_VER
    LD H, BIOS_PATCH_VER
    RET



;**
; get_system_ticks: Get System Ticks
; Gets the number of milliseconds the system has been running
; Parameters: None
; Returns: None
;**
e_get_system_ticks:
    POP HL
    POP DE
i_get_system_ticks:
    LD HL, (system_ticks)
    EX DE, HL
    LD HL, (system_ticks+2)
    RET



;**
; sleep: Sleep Milliseconds
; Halts the system for at least a number of milliseconds
; Parameters:
; - HL: Milliseconds to sleep
; Returns: None
;**
e_sleep:
    POP HL                              ; Pop parameters from stack
    POP DE
i_sleep:
    PUSH HL
    HALT                                ; Halt first for minimum time guarantee
.sleep_loop:
    HALT
    DEC HL
    LD A, L
    OR H
    JR NZ, .sleep_loop

    POP HL
    RET

