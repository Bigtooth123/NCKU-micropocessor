LIST p=18f4520
#include<p18f4520.inc>

    CONFIG OSC = INTIO67 ; Set internal oscillator to 1 MHz
    CONFIG WDT = OFF     ; Disable Watchdog Timer
    CONFIG LVP = OFF     ; Disable Low Voltage Programming

    L1 EQU 0x14         ; Define L1 memory location
    L2 EQU 0x15         ; Define L2 memory location
    s1 EQU 0x16
    org 0x00            ; Set program start address to 0x00

; instruction frequency = 1 MHz / 4 = 0.25 MHz
; instruction time = 1/0.25 = 4 ?s
; Total_cycles = 2 + (2 + 8 * num1 + 3) * num2 cycles
; num1 = 111, num2 = 70, Total_cycles = 62512 cycles
; Total_delay ~= Total_cycles * instruction time = 0.25 s
DELAY macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles
    LOOP2:
    MOVLW num1          
    MOVWF L1  
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:
    NOP                 ; busy waiting
    NOP
    NOP
    NOP
    NOP
    DECFSZ L1, 1        
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2           
endm
    
DELAYCheckButton macro num1, num2
    local LOOP1         ; Inner loop
    local LOOP2         ; Outer loop
    
    ; 2 cycles
    MOVLW num2          ; Load num2 into WREG
    MOVWF L2            ; Store WREG value into L2
    
    ; Total_cycles for LOOP2 = 2 cycles
    LOOP2:
    MOVLW num1          
    MOVWF L1  
    
    ; Total_cycles for LOOP1 = 8 cycles
    LOOP1:   
    
    BTFSS PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    BRA State0         ; If button is pressed, branch to State0
    
    NOP                 ; busy waiting
    NOP
    NOP
    
    DECFSZ L1, 1        
    BRA LOOP1           ; BRA instruction spends 2 cycles
    
    ; 3 cycles
    DECFSZ L2, 1        ; Decrement L2, skip if zero
    BRA LOOP2           
endm

start:
int:
; let pin can receive digital signal
    MOVLW 0x0f          ; Set ADCON1 register for digital mode
    MOVWF ADCON1        ; Store WREG value into ADCON1 register
    CLRF PORTB          ; Clear PORTB
    BSF TRISB, 0        ; Set RB0 as input (TRISB = 1111 1111)
    CLRF LATA           ; Clear LATA
    
    ; Set RA0 RA1 RA2 as output (TRISA = 1111 1000)
    BCF TRISA, 0        
    BCF TRISA, 1
    BCF TRISA, 2
    
    CLRF s1
    
; Button check
State0:
    BCF LATA, 0
    BCF LATA, 1
    BCF LATA, 2
    DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    BCF s1, 0  ;s1=0
    
    CheckO:
    BTFSC PORTB, 0      ; Check if PORTB bit 0 is low (button pressed)
    BRA CheckO   ; If button is not pressed, branch back to self
    BRA lightup0         ; If button is pressed, branch to lightup
    
lightup0:
    BCF LATA, 2
    BSF LATA, 0
    
    TSTFSZ s1  ;s1==0 means need to solve bouncing problem 
    GOTO notfirst
	
    DELAY d'111', d'70' ; Call delay macro to delay for about 0.25 seconds  need to delay press button
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    BSF s1, 0  ;s1==1
    GOTO lightup1
    
    notfirst:
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    GOTO lightup1
    
lightup1:
    BCF LATA, 0
    BSF LATA, 1
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    
    GOTO lightup2
    
lightup2:
    BCF LATA, 1
    BSF LATA, 2
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    DELAYCheckButton d'111', d'70' ; Call delay macro to delay for about 0.25 seconds
    
    GOTO lightup0
    
end