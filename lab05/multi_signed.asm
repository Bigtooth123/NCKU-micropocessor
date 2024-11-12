#include "xc.inc"
GLOBAL _multi_signed  ; Make function globally accessible
PSECT mytext,local,class=CODE,reloc=2
    
_multi_signed:
    MOVFF WREG, 0x11
    MOVFF 0x01, 0x12
    xh  equ 0x10
    xl  equ 0x11
    y  equ 0x12
    resulth  equ 0x02
    resultl  equ 0x01
    sign  equ 0x20  ;0 for positive 1 for negative
    indx  equ 0x30  ;control loop
    CLRF resulth
    CLRF resultl
    CLRF sign
    
    ;record positive or negative
    MOVFF xl, WREG
    XORWF y, w  ;WREG = xl xor y
    BCF sign, 0
    BTFSC WREG, 7
    BSF sign, 0  ;negative so sign = 1
    
    ;make all positive
    CLRF xh
    BTFSC xl, 7
    NEGF xl  ;negate xl
    BTFSC y, 7
    NEGF y  ;negate y
    
    MOVLW 0x04  ;run 4 times
    MOVWF indx
    
    Loop:
	BTFSS y, 0
	GOTO endLoop  ;zero so don't need to add
	MOVFF xl, WREG
	ADDWF resultl, f  ;resultl = resultl + xl
	MOVFF xh, WREG
	ADDWFC resulth, f
	
	endLoop:
	RRNCF y  ;shift right y
	
	; shift left x
	RLNCF xh
	BCF xh, 0
	BTFSC xl, 7
	BSF xh, 0
	RLNCF xl
	BCF xl, 0
	
	DECFSZ indx
	GOTO Loop
	
    BTFSS sign, 0
    GOTO Finish  ;positive so don't need to negate
    
    ;find 2's complement of result
    MOVLW 0xFF
    XORWF resultl, f  ;resultl = resultl xor 0xFF
    XORWF resulth, f
    MOVLW 0x01
    ADDWF resultl, f
    MOVLW 0x00
    ADDWFC resulth, f  ;add carry
    
    Finish:
    RETURN