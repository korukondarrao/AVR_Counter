; Initialization
CBI  DDRA, 0          ; PA0 input (SW1)
CBI  DDRA, 1          ; PA1 input (SW2)
SBI  PORTA, 0         ; pull-up on PA0
SBI  PORTA, 1         ; pull-up on PA1

SBI  DDRD, 0          ; PD0 output (LED1)
SBI  DDRD, 1		  ; PD1 output (LED2)
SBI  DDRD, 2		  ; PD2 output (LED3)
SBI  DDRD, 3		  ; PD3 output (LED4)
SBI  DDRD, 4		  ; PD4 output (LED5)

CLR  cnt              ; start count at 0
RCALL SHOW_COUNT

AGAIN:

; SW1 for Increment
; Wait for pressed button SW1 (PA0 has an ACTIVE-LOW)
WAIT_PRESS:
    SBIC PINA, 0      ; skip next if bit is clear (pressed = 0)
    RJMP WAIT_PRESS   ; if released, keep waiting (pressed = 1)

    ; debounce press
    RCALL DEBOUNCE

    ; confirm still pressed after debounce
    SBIC PINA, 0
    RJMP WAIT_PRESS

    ; increment 0-25 w/ wrap-around
    INC  cnt
    CPI  cnt, 26
    BRLO INC_OK
    LDI  cnt, 0

INC_OK:
    RCALL SHOW_COUNT

; Wait for released button SW1 (PA0 goes HIGH)
WAIT_RELEASE:
    SBIS PINA, 0      ; skip next if bit is set (released = 1)
    RJMP WAIT_RELEASE ; if still held, keep waiting (released = 0)

    ; debounce release
    RCALL DEBOUNCE

    ; confirm still released after debounce
    SBIS PINA, 0
    RJMP WAIT_RELEASE

	RJMP AGAIN

; SW2 for Decrement
; Wait for pressed button SW2 (PA1 has an ACTIVE-LOW)
CHK_DEC_PRESS:
    SBIC PINA, 1           ; skip next if bit is clear (pressed = 0)
    RJMP AGAIN             ; if released, keep waiting (pressed = 1)

	; debounce press
    RCALL DEBOUNCE

	; confirm still pressed after debounce
    SBIC PINA, 1           ; confirm still pressed
    RJMP AGAIN

	; decrement 0-25 w/ wrap-around
    TST  cnt
    BRNE DEC_OK
    LDI  cnt, 25           
    RJMP DEC_DONE

DEC_OK:
    DEC  cnt

DEC_DONE:
    RCALL SHOW_COUNT



; wait for SW2 release
; Wait for released button SW2 (PA1 goes HIGH)
WAIT_REL_DEC:
    SBIS PINA, 1           ; skip next if bit is set (released = 1)
    RJMP WAIT_REL_DEC	   ; if released, keep waiting (released = 0)

	; debounce release
    RCALL DEBOUNCE

	; confirm still released after debounce
    SBIS PINA, 1
    RJMP WAIT_REL_DEC
    RJMP AGAIN

; SHOW_COUNT: write cnt (the lower 5 bits) to PD0, PD1, PD2, PD3, and PD4
SHOW_COUNT:
    MOV  R17, cnt
    ANDI R17, 0x1F          ; keep PD0-PD4
	COM R17
	ANDI R17, 0x1F
    
	IN   R18, PORTD
    ANDI R18, 0xE0         ; keep PD5-PD7 as is
    OR   R17, R18
    OUT  PORTD, R17
    RET

; DEBOUNCE: 10ms time delay for LEDs to light up
DEBOUNCE:
    LDI  R18, 75

DB1: 
	LDI R17, 200

DB2: 
	NOP
    NOP
    DEC  R17
    BRNE DB2
	DEC R18
	BRNE DB1
    RET
