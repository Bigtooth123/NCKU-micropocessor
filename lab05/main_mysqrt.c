#include <xc.h>

extern unsigned char mysqrt(unsigned char a);

void main(void) {
    volatile unsigned char result = mysqrt(255);
    while(1);
    
    return;
}
