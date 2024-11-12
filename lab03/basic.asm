List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
;logic shift : add 0
;arithmatic shift : left: the same with logic shift. right: before shift, if 7 bit is 1 -> add 1, if 0 add 0

	MOVLW 0xC8
	MOVFF WREG, TRISA
	
	RLNCF TRISA
	BCF TRISA, 0  ;clear 0 bit of [0x00]
	
	BCF TRISA, 0
	BTFSC TRISA, 7  ;test seventh bit of [0x00] skip if clear
	BSF TRISA, 0
	
	RRNCF TRISA

	end
