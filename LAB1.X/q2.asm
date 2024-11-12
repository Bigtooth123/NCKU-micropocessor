List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	MOVLW 0xA6  
	MOVWF 0x00  ;store into [0x00]     using first 4 bits
	
	MOVLW 0x79
	MOVWF 0x01  ;store into [0x01]    using last 4 bits
	
	MOVFF 0x00, WREG  ;move [0x00] to WREG
	ANDLW 0xF0  ;W && 0xF0 and store  inito W
	MOVWF 0x10  ;store first 4 bits into [0x10] temporarily
	
	MOVFF 0x01, WREG
	ANDLW 0x0F  ;W && 0x0F and store  inito W
	
	ADDWF 0x10, w  ;W(last 4 bits) + [0x10] store into W
	MOVWF 0x02
	
	MOVLW 0x08
	MOVWF 0x10  ;control Loop 
	
	CLRF 0x03  ;need to clear before using
	
	Loop:     ;0001 0010
	    BTFSS 0x02, 0  ;if bit is 1 then skip
	    INCF 0x03  ;if 0
	    RRNCF 0x02
	    
	    DECFSZ 0x10
	    GOTO Loop
	    
	end
	    