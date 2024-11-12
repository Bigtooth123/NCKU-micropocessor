List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	MOVLW 0xFF
	MOVWF 0x00
	MOVLW 0xF1
	MOVWF 0x01
	
	MOVLW 0x00
	MOVWF 0x10  ;set (the number of 1) == 0
	
	MOVLW 0x00
	MOVWF 0x11  ;the max bit of 1
	
	MOVLW 0x01
	MOVWF 0x20  ;the number of Loop (index i)
	
	Loop:
	    BTFSC 0x01, 0  ;bit test
	    INCF 0x10  ;(the number of 1)++
	    
	    BTFSC 0x01, 0  ;bit test
	    MOVFF 0x20, 0x11  ;if 0 bit is 1 then [0x11] = [0x20]
    
	    ;  right rotate
	    RRNCF 0x01
	    BCF 0x01, 7  ;clear 7 bit of [0x01]
	    BTFSC 0x00, 0  ;if 0 bit of [0x00] is 0 skip
	    BSF 0x01, 7  ;the 0 bit of [0x00]is 1 -> set 7 bit of [0x01] 1
	    RRNCF 0x00

	    INCF 0x20  ;i++
	    MOVLW 0x10  ;run 16 times
	    CPFSGT 0x20  ;[0x20] > W(16)
	    GOTO Loop
	    GOTO TheEnd
	    
	TheEnd:
	    MOVLW 0x01
	    CPFSGT 0x10   ; if [0x10] > W(1)
	    DECF 0x11  ;[0x10] == 1  ->  [0x11]--
	    MOVFF 0x11, 0x02  ;[0x02] == anser
	    
	end