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

    ORG 0x00
    
    
GOTO Initial			    
ISR:				
    org 0x08                
    BTFSS PIR1, TMR2IF
    GOTO BUTTON
    GOTO TIMER
BUTTON:
    INCF STATEL
    INCF STATET
    ;STATEL CYCLE
    MOVLW 0x03 
    CPFSGT STATEL
    GOTO next
    MOVLW 0x01
    MOVWF STATEL
next:
    ;STATET CYCLE
    MOVLW 0x02
    CPFSGT STATET
    GOTO st1
    MOVLW 0x01
    MOVWF STATET
st1:
    ; STATET1
    MOVLW 0x01
    CPFSEQ STATET
    GOTO st2
    MOVLW D'61'		
    MOVWF PR2	
    GOTO ttt
st2: ;STATET 2
    MOVLW D'122'		
    MOVWF PR2	
    
ttt:
    ;STATEL 1
    MOVLW 0x03
    CPFSEQ STATEL
    GOTO sl1sl2
    MOVLW 0x0F
    MOVWF COUNTER
    GOTO exii
sl1sl2:
    CLRF COUNTER
    GOTO exii
exii:
    BCF INTCON, INT0IF
    CALL display
    RETFIE
TIMER:
    MOVLW 0x01
    CPFSEQ STATEL
    GOTO sl2sl3
    INCF COUNTER
    MOVLW 0x07
    CPFSGT COUNTER
    GOTO exi
    MOVLW 0x00
    MOVWF COUNTER
    GOTO exi
sl2sl3:
    MOVLW 0x02
    CPFSEQ STATEL
    GOTO sl3
    INCF COUNTER
    MOVLW 0x0F
    CPFSGT COUNTER
    GOTO exi
    MOVLW 0x00
    MOVWF COUNTER
    GOTO exi
sl3:
    DECF COUNTER
    MOVLW 0xFF
    CPFSEQ COUNTER
    GOTO exi
    MOVLW 0x0F
    MOVWF COUNTER
exi:
    BCF PIR1, TMR2IF
    CALL display
RETFIE
    
Initial:			
    COUNTER EQU 0x00
    TEMP EQU 0x01
    STATEL EQU 0x02
    STATET EQU 0x03
    MOVLW 0x0F
    MOVWF ADCON1
    CLRF TRISA
    CLRF LATA
    BSF TRISB, 0
    BSF RCON, IPEN
    BSF INTCON, GIE
    ;button
    BSF INTCON, INT0IE ; enable bit(allow interrupt)
    BCF INTCON, INT0IF ; flag bit(interrupt open)
    ;timer
    BCF PIR1, TMR2IF ; timer flag
    BSF IPR1, TMR2IP ; timer priority
    BSF PIE1 , TMR2IE ; enable
    MOVLW b'11111111'	       
    MOVWF T2CON		
    MOVLW D'61'		
    MOVWF PR2				
    MOVLW D'00100000'
    MOVWF OSCCON	       
    MOVLW 0x01
    MOVWF STATET
    MOVLW 0x01
    MOVWF STATEL
    CLRF COUNTER
    CLRF TEMP
    
main:		
    bra main	    
display:
    MOVFF COUNTER, WREG
    RRCF WREG
    RLCF TEMP
    RRCF WREG
    RLCF TEMP
    RRCF WREG
    RLCF TEMP
    RRCF WREG
    RLCF TEMP
    MOVFF TEMP , LATA
    RETURN
end


