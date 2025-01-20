#include <xc.h>
#include <pic18f4520.h>
#include <stdio.h>

#pragma config OSC = INTIO67 // Oscillator Selection bits
#pragma config WDT = OFF     // Watchdog Timer Enable bit
#pragma config PWRT = OFF    // Power-up Enable bit
#pragma config BOREN = ON    // Brown-out Reset Enable bit
#pragma config PBADEN = OFF  // Watchdog Timer Enable bit
#pragma config LVP = OFF     // Low Voltage (single -supply) In-Circute Serial Pragramming Enable bit
#pragma config CPD = OFF     // Data EEPROM?Memory Code Protection bit (Data EEPROM code protection off)

#define _XTAL_FREQ 1000000   //default oscillator frequency is 1 million

const unsigned char studentID[] = {7, 4, 1, 1, 4, 0, 5, 3};

void __interrupt(high_priority)H_ISR(){
    
    //step4
    int value = ADRESH;
    
    
    //do things
    unsigned char index = (value * 8) / 256; // map 0~255 to 0~7
    LATB = studentID[index];
    
    //clear flag bit
    PIR1bits.ADIF = 0;
    //step5 & go back step3
    __delay_us(4);      //need to wait at least 2 Tad
    ADCON0bits.GO = 1;
  
    
    return;
}

void main(void) 
{
    //configure OSC and port
    OSCCONbits.IRCF = 0b100; //1MHz
    TRISAbits.RA0 = 1;       //RA0 is analog input port
    TRISB = 0x00;    //portb is output
    
    //step1
    ADCON1bits.VCFG0 = 0;
    ADCON1bits.VCFG1 = 0;
    ADCON1bits.PCFG = 0b1110; //AN0 ia analog input,other is digital
    ADCON0bits.CHS = 0b0000;  //set AN0 as analog input
    ADCON2bits.ADCS = 0b000;  //Tad =  2*Tosc = 2 us
    ADCON2bits.ACQT = 0b001;  //set acquisition time = 2Tad = 4 us > 2.4 us
    ADCON0bits.ADON = 1;
    ADCON2bits.ADFM = 0;    //left justified 
    
    
    //step2
    PIE1bits.ADIE = 1;
    PIR1bits.ADIF = 0;
    INTCONbits.PEIE = 1;
    INTCONbits.GIE = 1;


    //step3
    ADCON0bits.GO = 1;
    
    while(1);
    
    return;
}