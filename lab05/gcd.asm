#include "xc.inc"
GLOBAL _gcd  ; Make function globally accessible
PSECT mytext,local,class=CODE,reloc=2

REMAINDER:
    LoopR:  ;cannot name Loop because there is Loop lable in gcd functon
	MOVFF yl, WREG
	SUBWF xl, f  ;subtract W from f and store into f
	MOVFF yh, WREG
	SUBWFB xh, f  ;**subtract W from f and store into f with borrow**
	
	;if x >= y GOTO LoopR
	MOVFF yh, WREG
	CPFSLT xh   ;if xh < yh
	GOTO BiggerequalR

	RETURN

	BiggerequalR:
	MOVFF yh, WREG
	CPFSEQ xh  ;if xh==yh
	GOTO LoopR

	MOVFF yl, WREG
	CPFSLT xl   ;if xl < yl
	GOTO LoopR
	RETURN
	
	
ChangeXY:  
    MOVFF xh, 0x12
    MOVFF xl, 0x11
    MOVFF yh, xh
    MOVFF yl, xl
    MOVFF 0x12, yh
    MOVFF 0x11, yl
    RETURN
    
_gcd:
    xh  equ 0x02
    xl  equ 0x01
    yh  equ 0x04
    yl  equ 0x03
  
    ;x<y than change
    MOVFF yh, WREG
    CPFSLT xh   ;if xh < yh
    GOTO Biggerequal
    
    RCALL ChangeXY
    GOTO Loop
    
    Biggerequal:
    MOVFF yh, WREG
    CPFSEQ xh  ;if xh==yh
    GOTO Loop
    
    MOVFF yl, WREG
    CPFSGT xl   ;if xl > yl
    RCALL ChangeXY
    
    Loop:
	TSTFSZ yl  ;Test f, skip if 0
	GOTO NotZero
	TSTFSZ yh
	GOTO NotZero
	GOTO Finish
	
	NotZero:
	RCALL REMAINDER
	RCALL ChangeXY
	GOTO Loop
    
    Finish:
    RETURN