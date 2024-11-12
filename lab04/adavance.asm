List p=18f4520
    #include<p18f4520.inc>
        CONFIG OSC = INTIO67
        CONFIG WDT = OFF
        org 0x00
	
	MOVLW 0x03
	MOVWF 0x10
	MOVLW 0x04
	MOVWF 0x11
	MOVLW 0x07
	MOVWF 0x12
	A1     equ 0x010  
	A2     equ 0x011  
	A3     equ 0x012
     
	MOVLW 0x05
	MOVWF 0x13
	MOVLW 0x05
	MOVWF 0x14
	MOVLW 0x03
	MOVWF 0x15
	B1     equ 0x013  
	B2     equ 0x014  
	B3     equ 0x015  
     
	C1     equ 0x020  
	C2     equ 0x021  
	C3     equ 0x022  
     
	rcall cross
	GOTO finish
     
	cross:
	    MOVFF A2, WREG        ; W = A2        need to write WREG not W
	    MULWF B3           ; A2 * B3
	    MOVFF PRODL, 0x00
	    
	    MOVFF A3, WREG        ; W = A3
	    MULWF B2           ; A3 * B2
	    MOVFF PRODL, 0x01
	    
	    ;[0x00] - [0x01]
	    MOVFF 0x01, WREG
	    SUBWF 0x00, W  ;subtract W from f and store into W
	    MOVFF WREG, C1
	    
	    
	    MOVFF A3, WREG      
	    MULWF B1
	    MOVFF PRODL, 0x00
	    
	    MOVFF A1, WREG       
	    MULWF B3        
	    MOVFF PRODL, 0x01
	    
	    ;[0x00] - [0x01]
	    MOVFF 0x01, WREG
	    SUBWF 0x00, W  ;subtract W from f and store into W
	    MOVFF WREG, C2
	    
	    
	    MOVFF A1, WREG      
	    MULWF B2
	    MOVFF PRODL, 0x00
	    
	    MOVFF A2, WREG       
	    MULWF B1        
	    MOVFF PRODL, 0x01
	    
	    ;[0x00] - [0x01]
	    MOVFF 0x01, WREG
	    SUBWF 0x00, W  ;subtract W from f and store into W
	    MOVFF WREG, C3
	    
	    RETURN
	    
	    
	finish:
	
	end


