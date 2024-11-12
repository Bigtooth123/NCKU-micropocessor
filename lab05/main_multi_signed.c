#include <xc.h>

extern unsigned int multi_signed(unsigned char x, unsigned char y);  //x will be in WREG, y will be in 0x01

void main(void) {
    volatile unsigned int result = multi_signed(-20, -4);
    while(1);
    
    return;
}
