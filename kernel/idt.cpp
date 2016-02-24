#include <sys/io.h>
#include <string.h>
#include "idt.h"
#include "Misc.h"
#include "drivers/Screen.h"

#define PIC0_CTRL	0x20    /* Master PIC control register address. */
#define PIC0_DATA	0x21    /* Master PIC data register address. */
#define PIC1_CTRL	0xA0    /* Slave PIC control register address. */
#define PIC1_DATA	0xA1    /* Slave PIC data register address. */



#define INT_CNT         256     /* 中断向量数 */


// 中断描述符表
static idt_entry_t idt_entries[INT_CNT];
// 中断名称
static const char *int_names[INT_CNT];
// IDTR
static idt_ptr_t idt_ptr;
// 指向中断处理函数的指针数组
static interrupt_handler_t interrupt_handlers[INT_CNT];


static void init_8259A();
static void idt_set_gate(uint8_t, uint32_t, uint16_t, uint8_t);
static void init_int_names();
static inline uint64_t flush_idt(uint16_t, uint32_t)


void idt_init()
{
    init_8259A();

    // 设置IDTR
    idt_ptr.limit = sizeof(idt_entry_t) * INT_CNT - 1;
    idt_ptr.base = (uint32_t)&idt_entries;
    // 加载IDT
    uint64_t idt_ptr_m = flush_idt(idt_ptr.limit, idt_ptr.base);
    asm volatile ("lidt %0" : : "m" (idt_ptr_m));
    
    bzero((uint8_t *)&interrupt_handlers, sizeof(interrupt_handler_t) * INT_CNT);

    // 0-32:  用于 CPU 的中断处理
    idt_set_gate( 0, (uint32_t)isr0,  0x08, 0x8E);
    idt_set_gate( 1, (uint32_t)isr1,  0x08, 0x8E);
    idt_set_gate( 2, (uint32_t)isr2,  0x08, 0x8E);
    idt_set_gate( 3, (uint32_t)isr3,  0x08, 0x8E);
    idt_set_gate( 4, (uint32_t)isr4,  0x08, 0x8E);
    idt_set_gate( 5, (uint32_t)isr5,  0x08, 0x8E);
    idt_set_gate( 6, (uint32_t)isr6,  0x08, 0x8E);
    idt_set_gate( 7, (uint32_t)isr7,  0x08, 0x8E);
    idt_set_gate( 8, (uint32_t)isr8,  0x08, 0x8E);
    idt_set_gate( 9, (uint32_t)isr9,  0x08, 0x8E);
    idt_set_gate(10, (uint32_t)isr10, 0x08, 0x8E);
    idt_set_gate(11, (uint32_t)isr11, 0x08, 0x8E);
    idt_set_gate(12, (uint32_t)isr12, 0x08, 0x8E);
    idt_set_gate(13, (uint32_t)isr13, 0x08, 0x8E);
    idt_set_gate(14, (uint32_t)isr14, 0x08, 0x8E);
    idt_set_gate(15, (uint32_t)isr15, 0x08, 0x8E);
    idt_set_gate(16, (uint32_t)isr16, 0x08, 0x8E);
    idt_set_gate(17, (uint32_t)isr17, 0x08, 0x8E);
    idt_set_gate(18, (uint32_t)isr18, 0x08, 0x8E);
    idt_set_gate(19, (uint32_t)isr19, 0x08, 0x8E);
    idt_set_gate(20, (uint32_t)isr20, 0x08, 0x8E);
    idt_set_gate(21, (uint32_t)isr21, 0x08, 0x8E);
    idt_set_gate(22, (uint32_t)isr22, 0x08, 0x8E);
    idt_set_gate(23, (uint32_t)isr23, 0x08, 0x8E);
    idt_set_gate(24, (uint32_t)isr24, 0x08, 0x8E);
    idt_set_gate(25, (uint32_t)isr25, 0x08, 0x8E);
    idt_set_gate(26, (uint32_t)isr26, 0x08, 0x8E);
    idt_set_gate(27, (uint32_t)isr27, 0x08, 0x8E);
    idt_set_gate(28, (uint32_t)isr28, 0x08, 0x8E);
    idt_set_gate(29, (uint32_t)isr29, 0x08, 0x8E);
    idt_set_gate(30, (uint32_t)isr30, 0x08, 0x8E);
    idt_set_gate(31, (uint32_t)isr31, 0x08, 0x8E);
   
    idt_set_gate(32, (uint32_t)irq0, 0x08, 0x8E);
    idt_set_gate(33, (uint32_t)irq1, 0x08, 0x8E);
    idt_set_gate(34, (uint32_t)irq2, 0x08, 0x8E);
    idt_set_gate(35, (uint32_t)irq3, 0x08, 0x8E);
    idt_set_gate(36, (uint32_t)irq4, 0x08, 0x8E);
    idt_set_gate(37, (uint32_t)irq5, 0x08, 0x8E);
    idt_set_gate(38, (uint32_t)irq6, 0x08, 0x8E);
    idt_set_gate(39, (uint32_t)irq7, 0x08, 0x8E);
    idt_set_gate(40, (uint32_t)irq8, 0x08, 0x8E);
    idt_set_gate(41, (uint32_t)irq9, 0x08, 0x8E);
    idt_set_gate(42, (uint32_t)irq10, 0x08, 0x8E);
    idt_set_gate(43, (uint32_t)irq11, 0x08, 0x8E);
    idt_set_gate(44, (uint32_t)irq12, 0x08, 0x8E);
    idt_set_gate(45, (uint32_t)irq13, 0x08, 0x8E);
    idt_set_gate(46, (uint32_t)irq14, 0x08, 0x8E);
    idt_set_gate(47, (uint32_t)irq15, 0x08, 0x8E);
    
    // 255 将来用于实现系统调用
    idt_set_gate(255, (uint32_t)isr255, 0x08, 0x8E);
        
    //init_int_names();
}


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

static inline uint64_t
flush_idt(uint16_t limit, uint32_t base)
{
    return limit | ((uint64_t) base << 16);
}

static void init_int_names()
{
    /* Initialize intr_names. */
    for (int i = 0; i < INT_CNT; i++)
	int_names[i] = "unknown";
    int_names[0] = "#DE Divide Error";
    int_names[1] = "#DB Debug Exception";
    int_names[2] = "NMI Interrupt";
    int_names[3] = "#BP Breakpoint Exception";
    int_names[4] = "#OF Overflow Exception";
    int_names[5] = "#BR BOUND Range Exceeded Exception";
    int_names[6] = "#UD Invalid Opcode Exception";
    int_names[7] = "#NM Device Not Available Exception";
    int_names[8] = "#DF Double Fault Exception";
    int_names[9] = "Coprocessor Segment Overrun";
    int_names[10] = "#TS Invalid TSS Exception";
    int_names[11] = "#NP Segment Not Present";
    int_names[12] = "#SS Stack Fault Exception";
    int_names[13] = "#GP General Protection Exception";
    int_names[14] = "#PF Page-Fault Exception";
    int_names[16] = "#MF x87 FPU Floating-Point Error";
    int_names[17] = "#AC Alignment Check Exception";
    int_names[18] = "#MC Machine-Check Exception";
    int_names[19] = "#XF SIMD Floating-Point Exception";
}


void isr_handler(pt_regs_t *regs)
{
    if (interrupt_handlers[regs->int_no])
    {   
	interrupt_handlers[regs->int_no](regs);
    }
    else
    {
	IO::Screen unhanded;
	unhanded.print_string((char*)"Unhandled interrupt!", IO::vga_color::COLOR_RED, IO::vga_color::COLOR_BLACK);
    }
}


// 注册一个中断处理函数
void register_interrupt_handler(uint8_t n, interrupt_handler_t h)
{
    interrupt_handlers[n] = h;
}


// IRQ 处理函数
void irq_handler(pt_regs *regs)
{
    // 发送中断结束信号给 PICs
    // 按照我们的设置，从 32 号中断起为用户自定义中断
    // 因为单片的 Intel 8259A 芯片只能处理 8 级中断
    // 故大于等于 40 的中断号是由从片处理的
    if (regs->int_no >= 40) {
	// 发送重设信号给从片
	outb(PIC1_CTRL, 0x20);
    }
    // 发送重设信号给主片
    outb(PIC0_CTRL, 0x20);

    if (interrupt_handlers[regs->int_no]) {
     	interrupt_handlers[regs->int_no](regs);
    }
}
