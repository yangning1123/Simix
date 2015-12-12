#include "Misc.h"
#include "idt.h"


void kern_init();
void main()
{
    kern_init();
}



void kern_init()
{
    init_idt();
    asm volatile ("int $0x0");
}










