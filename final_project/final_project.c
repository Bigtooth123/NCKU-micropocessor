// CONFIG1H
#pragma config OSC = INTIO67  // Oscillator Selection bits (HS oscillator)
#pragma config FCMEN = OFF    // Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor disabled)
#pragma config IESO = ON      // Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

// CONFIG2L
#pragma config PWRT = OFF       // Power-up Timer Enable bit (PWRT disabled)
#pragma config BOREN = SBORDIS  // Brown-out Reset Enable bits (Brown-out Reset enabled in hardware only (SBOREN is disabled))
#pragma config BORV = 3         // Brown Out Reset Voltage bits (Minimum setting)

// CONFIG2H
#pragma config WDT = OFF  // Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
#pragma config WDTPS = 1  // Watchdog Timer Postscale Select bits (1:1)

// CONFIG3H
#pragma config CCP2MX = PORTC  // CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
#pragma config PBADEN = ON     // PORTB A/D Enable bit (PORTB<4:0> pins are configured as analog input channels on Reset)
#pragma config LPT1OSC = OFF   // Low-Power Timer1 Oscillator Enable bit (Timer1 configured for higher power operation)
#pragma config MCLRE = ON      // MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

// CONFIG4L
#pragma config STVREN = ON  // Stack Full/Underflow Reset Enable bit (Stack full/underflow will cause Reset)
#pragma config LVP = OFF    // Single-Supply ICSP Enable bit (Single-Supply ICSP enabled)
#pragma config XINST = OFF  // Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

// CONFIG5L
#pragma config CP0 = OFF  // Code Protection bit (Block 0 (000800-001FFFh) not code-protected)
#pragma config CP1 = OFF  // Code Protection bit (Block 1 (002000-003FFFh) not code-protected)
#pragma config CP2 = OFF  // Code Protection bit (Block 2 (004000-005FFFh) not code-protected)
#pragma config CP3 = OFF  // Code Protection bit (Block 3 (006000-007FFFh) not code-protected)

// CONFIG5H
#pragma config CPB = OFF  // Boot Block Code Protection bit (Boot block (000000-0007FFh) not code-protected)
#pragma config CPD = OFF  // Data EEPROM Code Protection bit (Data EEPROM not code-protected)

// CONFIG6L
#pragma config WRT0 = OFF  // Write Protection bit (Block 0 (000800-001FFFh) not write-protected)
#pragma config WRT1 = OFF  // Write Protection bit (Block 1 (002000-003FFFh) not write-protected)
#pragma config WRT2 = OFF  // Write Protection bit (Block 2 (004000-005FFFh) not write-protected)
#pragma config WRT3 = OFF  // Write Protection bit (Block 3 (006000-007FFFh) not write-protected)

// CONFIG6H
#pragma config WRTC = OFF  // Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) not write-protected)
#pragma config WRTB = OFF  // Boot Block Write Protection bit (Boot block (000000-0007FFh) not write-protected)
#pragma config WRTD = OFF  // Data EEPROM Write Protection bit (Data EEPROM not write-protected)

// CONFIG7L
#pragma config EBTR0 = OFF  // Table Read Protection bit (Block 0 (000800-001FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR1 = OFF  // Table Read Protection bit (Block 1 (002000-003FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR2 = OFF  // Table Read Protection bit (Block 2 (004000-005FFFh) not protected from table reads executed in other blocks)
#pragma config EBTR3 = OFF  // Table Read Protection bit (Block 3 (006000-007FFFh) not protected from table reads executed in other blocks)

// CONFIG7H
#pragma config EBTRB = OFF  // Boot Block Table Read Protection bit (Boot block (000000-0007FFh) not protected from table reads executed in other blocks)

#include <ctype.h>
#include <pic18f4520.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <xc.h>

#define _XTAL_FREQ 4000000  

//------------------------------------------------------------------------------
// PORT 
//------------------------------------------------------------------------------
#define LCD_DATA_PORT      PORTC
#define LCD_DATA_TRIS      TRISC
#define LCD_RS             LATBbits.LATB1
#define LCD_EN             LATBbits.LATB2
#define LCD_RS_TRIS        TRISBbits.TRISB1
#define LCD_EN_TRIS        TRISBbits.TRISB2

#define BUTTON_INPUT       PORTBbits.RB0
#define BUTTON_INPUT_TRIS  TRISBbits.TRISB0

//------------------------------------------------------------------------------
// Function
//------------------------------------------------------------------------------
void System_Init(void);
void LCD_Init(void);
void LCD_Command(unsigned char cmd);
void LCD_Data(unsigned char data);
void LCD_Clear(void);
void LCD_SetCursor(unsigned char col, unsigned char row);
void LCD_WriteString(const char *str);
void LCD_CreateChar(unsigned char loc, const unsigned char *charmap);

unsigned long millis(void);
int MyRandom(int min_val, int max_val);

void GameSetup(void);
void GameLoop(void);

//------------------------------------------------------------------------------
// ?????? (CGRAM ??) - Dino, Cactus, Bird
//------------------------------------------------------------------------------


const unsigned char GHOST_STAND_PART1[8] = {0b00000,0b01111,0b01101,0b01111,0b01111,0b01111,0b01010,0b00000};

const unsigned char GHOST_STAND_PART2[8] = {0b00000,0b11110,0b10110,0b11110,0b11110,0b11110,0b10100,0b00000};

const unsigned char GHOST_RIGHT_FOOT_PART1[8] = {0b00000,0b01111,0b01101,0b01111,0b01111,0b01111,0b01010,0b00000};

const unsigned char GHOST_RIGHT_FOOT_PART2[8] = {0b00000,0b11110,0b10110,0b11110,0b11110,0b11110,0b10100,0b00000};

const unsigned char GHOST_LEFT_FOOT_PART1[8] = {0b00000,0b01111,0b01101,0b01111,0b01111,0b01111,0b00101,0b00000};

const unsigned char GHOST_LEFT_FOOT_PART2[8] = {0b00000,0b11110,0b10110,0b11110,0b11110,0b11110,0b01010,0b00000};


const unsigned char DINO_STAND_PART1[8] = {0b00000,0b00000,0b00010,0b00010,0b00011,0b00011,0b00001,0b00001};

const unsigned char DINO_STAND_PART2[8] = {0b00111,0b00111,0b00111,0b00100,0b11100,0b11100,0b11000,0b01000};

const unsigned char DINO_RIGHT_FOOT_PART1[8] = {0b00000,0b00000,0b00010,0b00010,0b00011,0b00011,0b00001,0b00001};

const unsigned char DINO_RIGHT_FOOT_PART2[8] = {0b00111,0b00111,0b00111,0b00100,0b11100,0b11100,0b11000,0b00000};

const unsigned char DINO_LEFT_FOOT_PART1[8] = {0b00000,0b00000,0b00010,0b00010,0b00011,0b00011,0b00001,0b00000};

const unsigned char DINO_LEFT_FOOT_PART2[8] = {0b00111,0b00111,0b00111,0b00100,0b11100,0b11100,0b11000,0b01000};


const unsigned char GOBLIN_STAND_PART1[8] = {0b00000,0b00100,0b01110,0b10101,0b10101,0b01110,0b00100,0b00000};

const unsigned char GOBLIN_STAND_PART2[8] = {0b00000,0b00100,0b01010,0b11111,0b01110,0b00100,0b00000,0b00000};

const unsigned char GOBLIN_RIGHT_FOOT_PART1[8] = {0b00000,0b00010,0b00111,0b01111,0b11110,0b01110,0b00100,0b00000};

const unsigned char GOBLIN_RIGHT_FOOT_PART2[8] = {0b00000,0b00100,0b01110,0b10101,0b10101,0b01110,0b00100,0b00000};

const unsigned char GOBLIN_LEFT_FOOT_PART1[8] = {0b00000,0b00100,0b01110,0b10101,0b01110,0b00100,0b00000,0b00000};

const unsigned char GOBLIN_LEFT_FOOT_PART2[8] = {0b00000,0b00000,0b00100,0b01110,0b11111,0b01110,0b00100,0b00000};


const unsigned char CACTUS_PART1[8] = {0b00000,0b00100,0b00100,0b10100,0b10100,0b11100,0b00100,0b00100};

const unsigned char CACTUS_PART2[8] = {0b00100,0b00101,0b00101,0b10101,0b11111,0b00100,0b00100,0b00100};

const unsigned char BIRD_WINGS_PART1[8] = {0b00001,0b00001,0b00001,0b00001,0b01001,0b11111,0b00000,0b00000};

const unsigned char BIRD_WINGS_PART2[8] = {0b00000,0b10000,0b11000,0b11100,0b11110,0b11111,0b00000,0b00000};

//------------------------------------------------------------------------------
// Global variables for game state
//------------------------------------------------------------------------------
int dinoCol1 = 1;
int dinoCol2 = 2;
int dinoRow = 1;

unsigned long clock1 = 0; 
int period1 = 100;
int footFlag = 1;  

int obstacleRow = 0;
int obstacleCol = 13;
int period2 = 100;
unsigned long clock2 = 0;


int obstacleGenerateFlag = 0;  
int jumpTime1 = 1;
int jumpTime2 = 2;
int jumpState = 0;  // 0 = stand, 1 = jump

unsigned long clock3 = 0;
int period3 = 100;

int score1 = 0;
int score2 = 0;

int randomNum = 0;
int birdCol = 13;
int birdRow = 1;

int currentSignal = 0;
int previousSignal = 0;

int fVar = 13; 
int acceleration = 1;

unsigned long clock4 = 0;
int period4 = 800;

int animal = 0;
int preanimal = -1;


void ADC_Init(){
    // Set RA0(AN0) as analog input(variable resistor)
    ADCON1bits.PCFG = 0b1110;  // AN0 as analog input, others as digital
    ADCON0bits.CHS = 0b0000;   // Select AN0 channel

    // step1
    ADCON1bits.VCFG0 = 0;     // Vref+ = Vdd
    ADCON1bits.VCFG1 = 0;     // Vref- = Vss
    ADCON2bits.ADCS = 0b010;  // ADC clock Fosc/4
    ADCON2bits.ACQT = 0b001;  // Tad = 2 us acquisition time set 2Tad = 4 > 2.4
    ADCON0bits.ADON = 1;      // Enable ADC
    ADCON2bits.ADFM = 0;      // left justified

    // step2
    PIE1bits.ADIE = 1;    // Enable ADC interrupt
    PIR1bits.ADIF = 0;    // Clear ADC interrupt flag
    INTCONbits.PEIE = 1;  // Enable peripheral interrupts
    INTCONbits.GIE = 1;   // Enable global interrupts

    // step3
    ADCON0bits.GO = 1;  // Start ADC conversion
}

int checkButton = 0;  //0 : no push button

void __interrupt()ISR(){
    
    if (PIR1bits.ADIF){
        //step4
        int value = ADRESH / 86 ;
        animal = value;
        /**/

        //clear flag bit
        PIR1bits.ADIF = 0;
        //step5 & go back step3
        __delay_us(4);      //need to wait at least 2 Tad
        ADCON0bits.GO = 1;
    }
    else if (INTCONbits.INT0IF){
        checkButton = 1;
        INTCONbits.INT0IF = 0;
    }
    
    return;
}

//------------------------------------------------------------------------------
// main
//------------------------------------------------------------------------------
void main(void)
{
    System_Init();   
    LCD_Init();      
    //gamesetup:
    GameSetup();     
    
    while(1)
    {   
        GameLoop();  
    }
}

//------------------------------------------------------------------------------
// System_Init
//------------------------------------------------------------------------------
void System_Init(void)
{
    
    // LCD
    LCD_DATA_TRIS = 0x00;  // RA0~RA7 
    LCD_RS_TRIS = 0;  // RB1 -> RS
    LCD_EN_TRIS = 0;  // RB2 -> EN

    // Button
    BUTTON_INPUT_TRIS = 1;  // RB0
    OSCCONbits.IRCF = 0b100;


    LCD_DATA_PORT = 0x00;
    LCD_RS = 0;
    LCD_EN = 0;

    //Timer0
    T0CON = 0x88;  // TMR0ON=1
    TMR0L = 0;     
}

//------------------------------------------------------------------------------
// LCD Function
//------------------------------------------------------------------------------
void LCD_Command(unsigned char cmd)
{
    LCD_RS = 0;               // Set RS to 0 for command mode
    LCD_DATA_PORT = cmd;      // Send the command to the data port
    LCD_EN = 1;               // Enable the LCD
    __delay_us(4);            // Small delay for processing
    LCD_EN = 0;               // Disable the LCD
    __delay_ms(2);            // Wait for the command to execute
}

// Function to send data (character) to the LCD
void LCD_Data(unsigned char data)
{
    LCD_RS = 1;               // Set RS to 1 for data mode
    LCD_DATA_PORT = data;     // Send the data to the data port
    LCD_EN = 1;               // Enable the LCD
    __delay_us(4);            // Small delay for processing
    LCD_EN = 0;               // Disable the LCD
    __delay_ms(2);            // Wait for the data to be written
}

// Function to initialize the LCD
void LCD_Init(void)
{
    __delay_ms(20);           // Wait for the LCD to power up
    LCD_Command(0x38);        // Configure LCD for 2 lines and 5x7 matrix
    LCD_Command(0x0C);        // Display ON, Cursor OFF
    LCD_Command(0x06);        // Auto-increment cursor
    LCD_Command(0x01);        // Clear display
    __delay_ms(2);            // Wait for the clear command to execute
}

// Function to clear the LCD display
void LCD_Clear(void)
{
    LCD_Command(0x01);        // Clear display command
    __delay_ms(2);            // Wait for the clear command to execute
}

// Function to set the cursor position on the LCD
void LCD_SetCursor(unsigned char col, unsigned char row)
{
    unsigned char address = (row == 0) ? 0x80 : 0xC0; // Base address for row 0 or row 1
    address += col;           // Add column offset
    LCD_Command(address);     // Send the address as a command
}

// Function to write a string to the LCD
void LCD_WriteString(const char *str)
{
    while(*str)               // Loop through the string until null terminator
    {
        LCD_Data(*str++);     // Send each character to the LCD
    }
}

// Function to create a custom character in CGRAM
// loc: CGRAM location (0 to 7)
// charmap: Array containing the character pattern (8 bytes)
void LCD_CreateChar(unsigned char loc, const unsigned char *charmap)
{
    if(loc < 8)               // Ensure location is within valid range
    {
        LCD_Command(0x40 | (loc << 3)); // Set CGRAM address (0x40 base address)
        for(int i = 0; i < 8; i++)      // Write 8 bytes of character pattern
        {
            LCD_Data(charmap[i]);       // Send each byte to CGRAM
        }
        LCD_Command(0x80);              // Return to DDRAM (0x80 base address)
    }
}


//------------------------------------------------------------------------------
// Timer0
//------------------------------------------------------------------------------
unsigned long millis(void)
{
    // This function calculates the elapsed time in microseconds based on an 8-bit timer (Timer0).
    // Assumes Timer0 is configured with a 1:1 prescaler and a timer clock of 1 MHz (Fosc = 4 MHz, divided by 4).
    // Each timer tick corresponds to 1 microsecond.
    // Timer0 overflows every 256 microseconds (256 ticks).
    // The function tracks time by combining timer overflows and the current timer value.

    static unsigned long total_overflow = 0; // Tracks the total time in microseconds from Timer0 overflows
    static unsigned char old_val = 0;       // Stores the previous value of Timer0 low byte
    unsigned char new_val = TMR0L;          // Read the current value of Timer0 low byte

    // Check if Timer0 has overflowed (when it rolls over from 0xFF to 0x00)
    if (new_val < old_val)
    {
        total_overflow += 256; // Add 256 microseconds for each overflow
    }
    old_val = new_val;         // Update the old value to the current value

    // Return the total elapsed time (overflows + current timer value)
    // The result is in microseconds
    return (total_overflow + new_val); 
}


//------------------------------------------------------------------------------
// MyRandom
//------------------------------------------------------------------------------
int MyRandom(int min_val, int max_val)
{
    static unsigned long seed = 12345;
    seed = (seed * 1103515245UL + 12345UL) & 0x7FFFFFFFUL; 
    int range = max_val - min_val;
    int r = (int)(seed % range);
    return (r + min_val);
}

//------------------------------------------------------------------------------
// GameSetup
//------------------------------------------------------------------------------
void GameSetup(void)
{
    LCD_CreateChar(0, DINO_STAND_PART1);
    LCD_CreateChar(1, DINO_STAND_PART2);
    LCD_CreateChar(2, GHOST_STAND_PART1);
    LCD_CreateChar(3, GHOST_STAND_PART2);
    LCD_CreateChar(4, GOBLIN_STAND_PART1);
    LCD_CreateChar(5, GOBLIN_STAND_PART2);
    LCD_CreateChar(6, CACTUS_PART1);
    LCD_CreateChar(7, CACTUS_PART2);
    ADC_Init();
    
    INTCONbits.INT0IF = 0; // Clear INT0 interrupt flag
    INTCONbits.INT0IE = 1; // Enable INT0 external interrupt
    
    preanimal = -1;
    LCD_SetCursor(0,0);
    LCD_WriteString("Rotate To Choose");
    while(checkButton == 0){
        if (animal == 0 && preanimal != animal){
            LCD_SetCursor(7, 1);
            LCD_Data(0); 
            LCD_SetCursor(8, 1);
            LCD_Data(1); 
            preanimal = animal;       
        }
        else if (animal == 1 && preanimal != animal){
            LCD_SetCursor(7, 1);
            LCD_Data(2); 
            LCD_SetCursor(8, 1);
            LCD_Data(3); 
            preanimal = animal;
        }
        else if (animal == 2 && preanimal != animal){
            LCD_SetCursor(7, 1);
            LCD_Data(4); 
            LCD_SetCursor(8, 1);
            LCD_Data(5); 
            preanimal = animal;   
        }      
    }
    if (animal == 0){
        LCD_CreateChar(0, DINO_STAND_PART1);
        LCD_CreateChar(1, DINO_STAND_PART2);
        LCD_CreateChar(2, DINO_RIGHT_FOOT_PART1);
        LCD_CreateChar(3, DINO_RIGHT_FOOT_PART2);
        LCD_CreateChar(4, DINO_LEFT_FOOT_PART1);
        LCD_CreateChar(5, DINO_LEFT_FOOT_PART2);       
    }
    else if (animal == 1){
        LCD_CreateChar(0, GHOST_STAND_PART1);
        LCD_CreateChar(1, GHOST_STAND_PART2);
        LCD_CreateChar(2, GHOST_RIGHT_FOOT_PART1);
        LCD_CreateChar(3, GHOST_RIGHT_FOOT_PART2);
        LCD_CreateChar(4, GHOST_LEFT_FOOT_PART1);
        LCD_CreateChar(5, GHOST_LEFT_FOOT_PART2);
    }
    else if (animal == 2){
        LCD_CreateChar(0, GOBLIN_STAND_PART1);
        LCD_CreateChar(1, GOBLIN_STAND_PART2);
        LCD_CreateChar(2, GOBLIN_RIGHT_FOOT_PART1);
        LCD_CreateChar(3, GOBLIN_RIGHT_FOOT_PART2);
        LCD_CreateChar(4, GOBLIN_LEFT_FOOT_PART1);
        LCD_CreateChar(5, GOBLIN_LEFT_FOOT_PART2);        
    }      
    PIE1bits.ADIE = 0;    // disable ADC interrupt
    ADCON0bits.GO = 0;
    
    INTCONbits.INT0IE = 0; // Enable INT0 external interrupt
    checkButton = 0;
    

    LCD_Clear();
    LCD_SetCursor(0,0);
    LCD_WriteString("   Game Start");
    __delay_ms(500);
    LCD_Clear();
}

//------------------------------------------------------------------------------
// GameLoop
//------------------------------------------------------------------------------
void GameLoop(void)
{
    // 1. Dino run (footFlag toggle)
    if (millis() > (clock1 + (unsigned long)period1)) // Check if the time interval has elapsed
    {
        clock1 = millis(); // Update clock1 to the current time
        if (footFlag == 1) 
            footFlag = 2;  // Toggle footFlag between 1 and 2 to animate the dino's running
        else if (footFlag == 2) 
            footFlag = 1;  // Switch back to 1
    }

    // 2. Obstacle movement and generation
    if (millis() > (clock2 + (unsigned long)period2)) // Check if the obstacle update interval has elapsed
    {
        clock2 = millis(); // Update clock2 to the current time
        obstacleCol--;      // Move the obstacle one column to the left
        if (obstacleCol < 0) // If the obstacle has moved off-screen
        {
            obstacleCol = 13;              // Reset the obstacle position to the starting column
            period2 -= acceleration;       // Decrease the obstacle movement interval (increase speed)
            if (period2 < 10) 
                period2 = 10;              // Set a minimum speed limit
            randomNum = MyRandom(0, 3);    // Generate a new random number for obstacle characteristics
        }

        // Clear the obstacle's previous position on the LCD (both lines)
        LCD_SetCursor((unsigned char)(obstacleCol + 1), 1); // Clear line 1
        LCD_WriteString(" ");
        LCD_SetCursor((unsigned char)(obstacleCol + 1), 0); // Clear line 0
        LCD_WriteString(" ");
        LCD_SetCursor(0, 1); // Clear the leftmost column of line 1
        LCD_WriteString(" ");
        LCD_SetCursor(0, 0); // Clear the leftmost column of line 0
        LCD_WriteString(" ");
        
        obstacleGenerateFlag = 1; // Set a flag to indicate a new obstacle should be generated
    }


    // 3. Draw the Dino
    if (jumpState == 0) // If the dino is not jumping
    {
        if (footFlag == 1) // Toggle between right foot
        {
            // Draw the right foot of the dino
            LCD_SetCursor((unsigned char)dinoCol1, (unsigned char)dinoRow);
            LCD_Data(2); // Display DINO_RIGHT_FOOT_PART1
            LCD_SetCursor((unsigned char)dinoCol2, (unsigned char)dinoRow);
            LCD_Data(3); // Display DINO_RIGHT_FOOT_PART2
        }
        else // Toggle to left foot
        {
            // Draw the left foot of the dino
            LCD_SetCursor((unsigned char)dinoCol1, (unsigned char)dinoRow);
            LCD_Data(4); // Display DINO_LEFT_FOOT_PART1
            LCD_SetCursor((unsigned char)dinoCol2, (unsigned char)dinoRow);
            LCD_Data(5); // Display DINO_LEFT_FOOT_PART2
        }
    }

    // 4. Generate and display obstacles
    if (obstacleGenerateFlag == 1) // If it's time to generate a new obstacle
    {
        if (randomNum == 1) // Generate obstacle type 1 (Cactus Part 1)
        {
            obstacleRow = 1; // Place it on the bottom row
            LCD_CreateChar(6, CACTUS_PART1); // Create a custom character for the cactus
            LCD_SetCursor((unsigned char)obstacleCol, (unsigned char)obstacleRow);
            LCD_Data(6); // Display the cactus on the LCD
        }
        else if (randomNum == 2) // Generate obstacle type 2 (Cactus Part 2)
        {
            obstacleRow = 1; // Place it on the bottom row
            LCD_CreateChar(7, CACTUS_PART2); // Create a custom character for the cactus
            LCD_SetCursor((unsigned char)obstacleCol, (unsigned char)obstacleRow);
            LCD_Data(7); // Display the cactus on the LCD
        }
        else // Generate a flying obstacle (Bird)
        {
            birdCol = obstacleCol - 1; // The bird takes up two columns
            obstacleRow = 0; // Place the bird on the top row

            // Create and display the bird's wings
            LCD_CreateChar(6, BIRD_WINGS_PART1); // Left wing
            LCD_SetCursor((unsigned char)birdCol, 0);
            LCD_Data(6);

            LCD_CreateChar(7, BIRD_WINGS_PART2); // Right wing
            LCD_SetCursor((unsigned char)obstacleCol, 0);
            LCD_Data(7);
        }
        obstacleGenerateFlag = 0; // Reset the obstacle generation flag
    }


    // 5. Game Over Condition (Collision Detection)
    // If Dino collides with a bird in row 0 or a cactus in row 1
    if (BUTTON_INPUT == 0 && 
    ((obstacleCol == 1 || obstacleCol == 2 || birdCol == 1 || birdCol == 2) && obstacleRow == 0))
    {
        LCD_Clear(); // Clear the LCD
        LCD_SetCursor(3, 0);
        LCD_WriteString("GAME OVER"); // Display "GAME OVER" message     
        __delay_ms(500); // Pause for a moment
        LCD_Clear();

        // Reset game variables
        obstacleCol = 15;  // Reset obstacle position
        period2 = 100;     // Reset obstacle speed
        score1 = 0;        // Reset score
        score2 = 0;        // Reset additional score
        GameSetup();       // Restart the game
    }

    // If Dino collides with a cactus in row 1
    if (BUTTON_INPUT == 1 && 
    ((obstacleCol == 1 || obstacleCol == 2) && obstacleRow == 1))
    {
        LCD_Clear(); // Clear the LCD
        LCD_SetCursor(3, 0);
        LCD_WriteString("GAME OVER"); // Display "GAME OVER" message
        __delay_ms(500); // Pause for a moment
        LCD_Clear();

        // Reset game variables
        obstacleCol = 15;  // Reset obstacle position
        period2 = 100;     // Reset obstacle speed
        score1 = 0;        // Reset score
        score2 = 0;        // Reset additional score
        GameSetup();       // Restart the game
    }

    // 6. Dino Jump Logic
    if (BUTTON_INPUT == 0) // When the button is pressed
    {
        jumpTime1 = 50; // Set jump duration
        jumpTime2 = 50;

        if (jumpState == 0) // If Dino is on the ground
        {
            // Clear the Dino's ground position
            LCD_SetCursor(0, 1);
            LCD_WriteString("    ");
        }
        jumpState = 1; // Set Dino to jump state

        // Draw the Dino in its jump position
        LCD_SetCursor((unsigned char)dinoCol1, 0);
        LCD_Data(2); // Draw Dino part 1
        LCD_SetCursor((unsigned char)dinoCol2, 0);
        LCD_Data(3); // Draw Dino part 2
    }
    else // When the button is released
    {
        jumpTime1 = 1;  // Reset jump duration
        jumpTime2 = 2;
        jumpState = 0;  // Reset Dino to ground state
    }

    // 7. Score Update (every `period3` ms)
    if (millis() > (clock3 + (unsigned long)period3))
    {
        clock3 = millis(); // Update clock3 to current time

        // Update score1 (units place)
        LCD_SetCursor(14, 1); // Set cursor for score display
        char buf[4]; // Buffer to store score as a string
        sprintf(buf, "%3d", score1); // Format score1 as a 3-digit number
        LCD_WriteString(buf); // Display score1

        score1++; // Increment score1
        
        // Handle button signal change
        currentSignal = BUTTON_INPUT; // Read current button state
        if (currentSignal != previousSignal) // If the button state changes
        {
            LCD_SetCursor(1, 0);
            LCD_WriteString("  "); // Clear any residual display
        }
        previousSignal = currentSignal; // Update the previous signal
    }

}