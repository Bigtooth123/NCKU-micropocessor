#include "xc.inc"
GLOBAL _mysqrt  ; Make function globally accessible
PSECT mytext,local,class=CODE,reloc=2
    
_mysqrt:
    ;a  equ 0x00   ; cannot use a as a name, but y, xl, xh .... can be used
  
    MOVFF WREG, 0x00  
    CLRF 0x01  ;[0x01] = 0
    MOVLW 0x10
    MOVFF WREG, 0x10  ;[0x10] = 16  the Loop will run 16 times at most if a > 225
    Loop:
	MOVFF 0x01, WREG
	MULWF 0x01  ;[0x01] * [0x01]
	MOVFF 0x00, WREG
	CPFSLT PRODL  ;if PRODL < WREG(a)   skip
	GOTO Finish  ;PRODL >= a
	INCF 0x01
	
	DECFSZ 0x10
	GOTO Loop

    Finish:
	MOVFF 0x01, WREG  ;Will return WREG, but 0x01 will also be the anser
	RETURN  ;return WREG