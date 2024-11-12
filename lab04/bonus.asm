List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00

	MOVLW 0x18
	MOVWF 0x09  ;store n
	rcall fib
	GOTO finish
	
	fib:  ;Fibonacci
	    MOVLW 0x01
	    CPFSGT 0x09  ;if [0x09] > W(1) skip
	    GOTO Compare;[0x090] <= 1
	    
	    MOVLW 0x00
	    MOVWF 0x10 
	    MOVLW 0x00
	    MOVWF 0x11  ;first number [0x10] [0x11]
	    
	    MOVLW 0x00
	    MOVWF 0x20
	    MOVLW 0x01
	    MOVWF 0x21  ;second number [0x20] [0x21]
	    
	    DECF 0x09  ;[0x09]--
	    Loop:  ;run n-1 times
		MOVFF 0x11, WREG
		ADDWF 0x21, W  ;W = W([0x11]) + [0x21]
		MOVFF WREG, 0x01  ;low byte
		
		MOVLW 0x00
		BTFSC STATUS, 0  ;Bit Test f, Skip if Clear
		MOVLW 0x01  ;carry = 1
		
		ADDWF 0x10, W  ;W = W(carry) + [0x10]  
		ADDWF 0x20, W  ;W = [0x20] + W([0x10] + carry)
		MOVFF WREG, 0x00  ;high byte
		
		MOVFF 0x21, 0x11
		MOVFF 0x20, 0x10
		MOVFF 0x01, 0x21
		MOVFF 0x00, 0x20  ;update first and second nnumber
		
		DECFSZ 0x09  ;control Loop
		GOTO Loop
		GOTO funcEnd
		    
	    Compare:
		MOVLW 0x00
		CPFSEQ 0x09  ;[0x09](n) == 0x00 skip
		MOVLW 0x01
		MOVFF WREG, 0x01
		
	    funcEnd:
		RETURN
	    
	    
	    
	finish:

	end
