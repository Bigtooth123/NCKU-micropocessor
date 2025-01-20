#include <xc.h>
#include <pic18f4520.h>

// Configuration Bits
#pragma config OSC = INTIO67
#pragma config WDT = OFF
#pragma config PWRT = OFF
#pragma config BOREN = ON
#pragma config PBADEN = OFF
#pragma config LVP = OFF
#pragma config CPD = OFF
#define _XTAL_FREQ 125000  // delay (125kHz)
void setServoPosition(unsigned int dutyCycle);

void main(void)
{
    // PWM Initialization
    T2CONbits.TMR2ON = 0b1;       // Turn on Timer2 to act as the time base for PWM
    T2CONbits.T2CKPS = 0b01;      // Set Timer2 prescaler to 4 (T2CKPS = 01)
    OSCCONbits.IRCF = 0b001;      // Set oscillator frequency to 31 kHz (internal clock control)
    CCP1CONbits.CCP1M = 0b1100;   // Configure CCP1 module in PWM mode
    TRISBbits.TRISB0 = 1;         // Set RB0 as input (for button functionality)
    TRISCbits.TRISC2 = 0;         // Set RC2 as output (PWM output pin)
    LATC = 0;                     // Clear LATC register to initialize port outputs
    T2CON = 0b00000101;           // Reconfigure T2CON: Prescaler set to 4 and Timer2 enabled
    PR2 = 0x9B;                   // Set the PWM period register to define the frequency
    CCPR1L = 0;                   // Initialize PWM duty cycle to 0 (off)

    unsigned char currentPosition = 0; // 0: -90°, 1: +90°
    unsigned char buttonPressed = 0;

    // Initialize servo to -90° position
    setServoPosition(15); // -90° (1 ms pulse)

    while (1)
    {
        if (PORTBbits.RB0 == 0) // Button pressed
        {
            // Move servo from 15 to 75 (0°) and back to 15 (-90°)
            for (int x = 15; x <= 75; x++) // Move to +90°
            {
                setServoPosition(x);
                __delay_ms(30); // Smooth transition
            }
            setServoPosition(15);
        }
    }
}

// Function to set servo position
void setServoPosition(unsigned int dutyCycle)
{
    CCPR1L = dutyCycle >> 2;                // High 8 bits
    CCP1CONbits.DC1B = dutyCycle & 0x03;   // Low 2 bits
}