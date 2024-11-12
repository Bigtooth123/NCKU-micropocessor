List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	MOVLW 0xCC  ;first number
	MOVWF 0x00
	MOVWF 0x20  ;store into [0x20] 
	
	MOVLW 0x01  ;second number
	MOVWF 0x10
	
	Loop:
	    BTFSS 0x00, 0
	    GOTO  Even  ;if first bit is 0
	    
	    DECF 0x10  ; is odd so [0x10] -1
	    GOTO Last
	      
	    Even:
		BTFSS 0x00, 1
		GOTO Forth
		INCF 0x10  ; is even so [0x10]+1
		GOTO Last
		
	    Forth:
		MOVLW 0x02
		ADDWF 0x10, F  ;[0x10]+2
		GOTO Last
		
	    Last:
		RRNCF 0x00
		MOVFF 0x20, WREG
		
		CPFSEQ 0x00
		GOTO Loop
		
	end


