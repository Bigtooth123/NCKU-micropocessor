#include <xc.h>

extern unsigned int gcd(unsigned int x, unsigned int y);

void main(void) {
    volatile unsigned int result = gcd(12321, 65535);  //12321, 65535
    while(1);
    
    return;
}