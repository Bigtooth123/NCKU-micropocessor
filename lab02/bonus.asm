List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	MOVLW 0x15
	MOVFF WREG, 0x00
	MOVLW 0x35
	MOVFF WREG, 0x01
	MOVLW 0x55 
	MOVFF WREG, 0x02
	MOVLW 0x75
	MOVFF WREG, 0x03
	MOVLW 0x95
	MOVFF WREG, 0x04
	MOVLW 0xB5
	MOVFF WREG, 0x05
	MOVLW 0xD5
	MOVFF WREG, 0x06
	
	MOVLW 0x34
	MOVFF WREG, 0x07  ;target
	
	MOVLW 0x00
	MOVFF WREG, 0x20  ;left
	MOVLW 0x06  
	MOVFF WREG, 0x21  ;right
	LFSR 0, 0x000 ; FSR0 point to [0x000] which is the first element
	
	MOVLW 0x00
	MOVFF WREG, 0x011  ;initiazation
	    
	Loop:
	    MOVFF 0x20, WREG
	    ADDWF 0x21, W  ;W = left(W) + right
	    MOVFF WREG, 0x22  ;store left+right
	    BCF 0x22, 0  ;clear 0 bit of mid
	    RRNCF 0x22  ;mid index = (left+right)/2 and is stored in 0x22
	    
	    MOVFF 0x22, WREG
	    MOVFF PLUSW0, 0x30  ; *store the value of mid into 0x30 temprarily
	    MOVFF 0x30, WREG
	    
	    CPFSLT 0x07  ;if [0x07](target) < WREG([0x30] == the value of mid)
	    GOTO GreatEqual
	    GOTO Less
	    
	    GreatEqual:
		CPFSEQ 0x07  ;==
		GOTO Great
		GOTO Equal  ;find the target
		
	    Great:  ;target > value of mid
		MOVLW 0x01
		ADDWF 0x22, W  ;W = mid + W(==1)
		MOVFF WREG, 0x20  ;store left
		GOTO EndLoop
    
	    Less:  ;target < value of mid
		MOVLW 0x01
		SUBWF 0x22, W  ;subtract W from f and store into W
		MOVFF WREG, 0x21  ;store right
		
	    EndLoop:
		MOVFF 0x21, WREG
		CPFSGT 0x20  ;if 0x20 > 0x21 skip  (if left > right)
		GOTO  Check  ;left <= right
		GOTO TheEnd  ;not found
		
	    Check:  ;check if right is positive or negative
		BTFSS 0x21, 7  ;examine right, 1 -> negative 
		GOTO Loop  ;positive
		GOTO TheEnd  ;negative
		
	Equal:  ;find the target
	    MOVLW 0xFF
	    MOVFF WREG, 0x011
	    
	TheEnd:
	    ;NOP
	end


