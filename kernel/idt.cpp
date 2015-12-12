#include "idt.h"
#include <sys/io.h>
#include "Misc.h"

#define PIC0_CTRL	0x20    /* Master PIC control register address. */
#define PIC0_DATA	0x21    /* Master PIC data register address. */
#define PIC1_CTRL	0xA0    /* Slave PIC control register address. */
#define PIC1_DATA	0xA1    /* Slave PIC data register address. */

#define INT_CNT         256     /* 中断向量数 */


// 中断描述符表
static idt_entry_t idt_entries[INT_CNT];
// IDTR
static idt_ptr_t idt_ptr;
    
static void init_8259A()
{
    /* Mask all interrupts on both PICs. */
    outb (PIC0_DATA, 0xff);
    outb (PIC1_DATA, 0xff);

    /* Initialize master. */
    outb (PIC0_CTRL, 0x11); /* ICW1: single mode, edge triggered, expect ICW4. */
    outb (PIC0_DATA, 0x20); /* ICW2: line IR0...7 -> irq 0x20...0x27. */
    outb (PIC0_DATA, 0x04); /* ICW3: slave PIC on line IR2. */
    outb (PIC0_DATA, 0x01); /* ICW4: 8086 mode, normal EOI, non-buffered. */

    /* Initialize slave. */
    outb (PIC1_CTRL, 0x11); /* ICW1: single mode, edge triggered, expect ICW4. */
    outb (PIC1_DATA, 0x28); /* ICW2: line IR0...7 -> irq 0x28...0x2f. */
    outb (PIC1_DATA, 0x02); /* ICW3: slave ID is 2. */
    outb (PIC1_DATA, 0x01); /* ICW4: 8086 mode, normal EOI, non-buffered. */

    /* Unmask all interrupts. */
    outb (PIC0_DATA, 0x00);
    outb (PIC1_DATA, 0x00);
}


static void idt_set_gate(uint8_t num, uint32_t base, uint16_t seletor, uint8_t flags)
{
    idt_entries[num].base_low  = base& 0xFFFF;
    idt_entries[num].base_high = (base >> 16) & 0xFFFF;

    idt_entries[num].selector  = seletor;
    idt_entries[num].always0   = 0;

    idt_entries[num].flags     = flags;
}

extern "C"
void isr_handler(pt_regs_t *regs)
{
    Misc::disp_meminfo();
}


void init_idt()
{
    init_8259A();

    // 设置IDTR
    idt_ptr.limit = sizeof(idt_entry_t) * 256 - 1;
    idt_ptr.base = (uint32_t)&idt_entries;

    // 中断向量表
    idt_set_gate(0, (uint32_t)isr0, 0x08, 0x8E);
    
    // 加载IDT
    asm volatile ("lidt %0" : : "m" (idt_ptr));
}



















