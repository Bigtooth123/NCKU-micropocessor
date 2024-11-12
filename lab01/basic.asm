List p=18f4520 ;???PIC18F4520
    ;???PIC18F
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00  ;PC = 0x00

	MOVLW 0x11  ;a
	MOVWF 0x00  ;store into [0x00]
	
	MOVLW 0xA1  ;b
	MOVWF 0x01  ;??[0x01]
	
	ADDWF 0x00, W
	MOVWF 0x02  ;A1
	
	MOVLW 0xC5  ;c
	MOVWF 0x10  ;??[0x10]
	
	MOVLW 0xB7  ;d
	MOVWF 0x11  ;??[0x11]
	
	SUBWF 0x10, W  ;subtract W from f and store into W
	MOVWF 0x12  ;A2   W=A2
	
	CPFSGT 0x02  ;f>W
	GOTO Lessequal  ; <=
	GOTO Greater
	
	Lessequal:
	    CPFSEQ 0x02  ;==
	    GOTO Less
	    GOTO Equal
	
	Greater:
	    MOVLW 0xAA
	    GOTO TheEnd
	
	Equal:
	    MOVLW 0xBB
	    GOTO TheEnd
	    
	Less:
	    MOVLW 0xCC
	
	TheEnd:
	    MOVWF 0x20
	
	end