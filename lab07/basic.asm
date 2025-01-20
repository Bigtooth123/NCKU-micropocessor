#include "p18f4520.inc"

; CONFIG1H
  CONFIG  OSC = INTIO67         ; Oscillator Selection bits (Internal oscillator block, port function on RA6 and RA7)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = OFF            ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  BOREN = SBORDIS       ; Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
  CONFIG  BORV = 3              ; Brown Out Reset Voltage bits (Minimum setting)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 32768         ; Watchdog Timer Postscale Select bits (1:32768)

; CONFIG3H
  CONFIG  CCP2MX = PORTC        ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = ON           ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = ON           ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

    L1 EQU 0x14
    L2 EQU 0x15
    cooldownH EQU 0x40   ;used to handle bouncing problem
    cooldownL EQU 0x42
 
    MAXNUM EQU 0x20

    org 0x00
    
DELAY macro num1, num2 
    local LOOP1 
    local LOOP2
    MOVLW num2
    MOVWF L2
    LOOP2:
	MOVLW num1
	MOVWF L1
	LOOP1:   ;14-16 clock cycle
	    MOVF cooldownH, W
	    BNZ cooldown_decrement    ; 
	    MOVF cooldownL, W
	    BNZ cooldown_decrement    ; 
	    GOTO Next
	    cooldown_decrement:
		DECF cooldownL
		MOVLW 0x00
		SUBWFB cooldownH
	    Next:
	    NOP
	    NOP
	    NOP
	    NOP
	    NOP
	    DECFSZ L1, 1
	    BRA LOOP1   ;2 cycle
	    
	DECFSZ L2, 1
	BRA LOOP2
endm
	
; ??????????main??????????RB0???????interrupt???ISR??
; ISR??????????RA?????Delay?0.5?????

goto Initial			; ????????????ISR????????
ISR:				; Interrupt????????????
    org 0x08	
    ; setup ISR		
    ; change state
    
	;handle bouncing problem
	MOVF cooldownH, W
	BNZ End_isr               ; Cooldown hasn't end
	MOVF cooldownL, W
	BNZ End_isr
	;F46 = 3910*16 = 62500cycle = 0.25second
	MOVLW 0x0F
	MOVWF cooldownH
	MOVLW 0x46
	MOVWF cooldownL
	
	BTFSS MAXNUM, 0   ;if it is the first time pressing button set 1
	INCF MAXNUM
	
        RLNCF MAXNUM
        INCF MAXNUM
	 ; MAXNUM = MAXNUM * 2 + 1
        BTFSC MAXNUM, 4
        GOTO set_maxnum_3 ; MAXNUM = 3 if MAXNUM == 31
        GOTO lsr_continue

        set_maxnum_3:
            MOVLW 0x03
            MOVWF MAXNUM
        lsr_continue:
            ; turn off all lights
            CLRF LATA
    End_isr:
    ; teardown ISR 
    BCF INTCON, INT0IF
    RETFIE                    ; ??ISR?????????????????GIE??1??????interrupt????
    
    
Initial:				; ????????
    MOVLW 0x0F
    MOVWF ADCON1		; Digitial I/O 
    
    CLRF TRISA
    CLRF LATA
    BSF TRISB,  0
    BCF RCON, IPEN
    BCF INTCON, INT0IF		; Interrupt flag bit
    BSF INTCON, GIE		; Global interrupt enable bit
    BSF INTCON, INT0IE		; set interrupt0 enable bit 1 (INT0 is at the same port as RB0 pin)
main:
    DELAY  d'50' , d'175'   ;50*175 = 8750 => 8750* 14 = 125000 = 0.5 second
    MOVFF MAXNUM, WREG
    CPFSLT LATA 
    GOTO end_state
    GOTO increase_lata
    increase_lata:
        INCF LATA
	GOTO main_continue
    end_state:
	MOVLW 0x20 ; set LATA to b10000
	MOVFF WREG, LATA
    main_continue:
        bra main
end