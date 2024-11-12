List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

	Sub_Mul macro  xh, xl, yh, yl
	    MOVFF yl, WREG
	    SUBWF xl, W  ;subtract W from f and store into W
	    MOVFF WREG, 0x01
	    
	    MOVFF yh, WREG
	    SUBWFB xh, W  ;**subtract W from f and store into W with borrow**
	    MOVFF WREG, 0x00
	    
	    MULWF 0x01  ;[0x01] * WREG([0x00])
	    MOVFF PRODL, 0x11
	    MOVFF PRODH, 0x10
	    
	    endm

	MOVLW 0x03
	MOVWF 0x20  ;xh
	MOVLW 0xA5
	MOVWF 0x21  ;xl
	MOVLW 0x02
	MOVWF 0x22  ;yh
	MOVLW 0xA7
	MOVWF 0x23  ;yl
	
	Sub_Mul 0x20, 0x21, 0x22, 0x23
	    
	end