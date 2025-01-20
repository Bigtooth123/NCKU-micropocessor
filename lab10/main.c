#include <stdlib.h>
#include "stdio.h"
#include "string.h"
#define _XTAL_FREQ 4000000
// using namespace std;

void UART_Initialize(void);
char * GetString();
void UART_Write(unsigned char data);
void UART_Write_Text(char* text);
void ClearBuffer();
void MyusartRead();
void SYSTEM_Initialize(void);
void OSCILLATOR_Initialize(void);
void INTERRUPT_Initialize (void);

char mystring[20];
int lenStr = 0;

void INTERRUPT_Initialize (void)
{
    RCONbits.IPEN = 1;      //enable Interrupt Priority mode
    INTCONbits.GIEH = 1;    //enable high priority interrupt
    INTCONbits.GIEL = 1;     //disable low priority interrupt
}

void SYSTEM_Initialize(void)
{
    // PIN_MANAGER_Initialize();
    OSCILLATOR_Initialize(); //default 1Mhz
//    TMR2_Initialize();
//    TMR1_Initialize();
//    TMR0_Initialize();
    INTERRUPT_Initialize();
    UART_Initialize();
    INTCONbits.INT0IF = 0;
    INTCONbits.GIE = 1;
    INTCONbits.INT0IE = 1;
    TRISA = 0b11110000;
    TRISBbits.RB0 = 1;
    LATA = 0;
    ADCON1 = 0x0F;
}

void OSCILLATOR_Initialize(void)
{
    IRCF2 = 1; // default setting 4M Hz
    IRCF1 = 1;
    IRCF0 = 0;

    // RCON = 0x0000;
}

void UART_Initialize() {
           
    /*       TODObasic   
        Serial Setting      
        1.   Setting Baud rate
        2.   choose sync/async mode 
        3.   enable Serial port (configures RX/DT and TX/CK pins as serial port pins)
        3.5  enable Tx, Rx Interrupt(optional)
        4.   Enable Tx & RX
   */        
    TRISCbits.TRISC6 = 1;            
    TRISCbits.TRISC7 = 1;            
    
    //  Setting baud rate
    TXSTAbits.SYNC = 0;           
    BAUDCONbits.BRG16 = 0;          
    TXSTAbits.BRGH = 0;
    SPBRG = 51;      
    
   //   Serial enable
    RCSTAbits.SPEN = 1;              
    PIR1bits.TXIF = 0;
    PIR1bits.RCIF = 0;
    TXSTAbits.TXEN = 1;           
    RCSTAbits.CREN = 1;             
    PIE1bits.TXIE = 0;       
    IPR1bits.TXIP = 0;             
    PIE1bits.RCIE = 1;              
    IPR1bits.RCIP = 0;    //priority
              
    }

void UART_Write(unsigned char data)  // Output on Terminal
{
    while(!TXSTAbits.TRMT);
    TXREG = data;              //write to TXREG will send data 
}


void UART_Write_Text(char* text) { // Output on Terminal, limit:10 chars
    for(int i=0;text[i]!='\0';i++)
        UART_Write(text[i]);
}

void ClearBuffer(void){
    for(int i = 0; i < 10 ; i++)
        mystring[i] = '\0';
    lenStr = 0;
}

void MyusartRead(void)
{
    /* TODObasic: try to use UART_Write to finish this function */
    char data;
    data = RCREG;
    mystring[lenStr++] = RCREG;
    if(data == '\r')
        UART_Write('\n');
    UART_Write(data);
    if(lenStr == 9)
    {
        lenStr = 0;
    }
    return ;
}

char *GetString(void){
    return mystring;
}


// void interrupt low_priority Lo_ISR(void)
void __interrupt(low_priority)  Lo_ISR(void)
{
    if(RCIF)
    {
        if(RCSTAbits.OERR)
        {
            CREN = 0;
            Nop();
            CREN = 1;
        }
        MyusartRead();
    }
    
   // process other interrupt sources here, if required
    return;
}


char str[20];
int interrupted = 0;
void Mode1(){   // Todo : Mode1
    LATA = (int)str[2] - 48;
    return ;
}
void Mode2(){   // Todo : Mode2 
    int limit = (int)str[2] - 48;
    int i = 0;
    while(1)
    {
        if(interrupted)
        {
            break;
        }
        LATA = i++;
        __delay_ms(500);
        if(i == limit+1)
        {
            i = 0;
        }
    }
    return;
}
void main(void) 
{
    
    SYSTEM_Initialize();
    
    while(1) {
        interrupted = 0;
        strcpy(str, GetString()); // TODO : GetString() in uart.c
        if(str[0]=='m' && str[1]=='1' && str[2] != '\0'){ // Mode1
            Mode1();
            ClearBuffer();
        }
        else if(str[0]=='m' && str[1]=='2' && str[2] != '\0'){ // Mode2
            Mode2();
            ClearBuffer();  
            interrupted = 0;
        }
    }
    return;
}

void __interrupt(high_priority) Hi_ISR(void)
{
    LATA = 0;
    interrupted = 1;
    INTCONbits.INT0IF = 0;
}