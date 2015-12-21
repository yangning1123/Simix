#include <string.h>
#include <sys/io.h>
#include "drivers/Screen.h"
#include "idt.h"
#include "Misc.h"


static void bss_init();
void init_timer(uint32_t frequency);

extern "C"
void main()
{
    bss_init();
    idt_init();
    
    init_timer(1);
    
    asm volatile ("sti");
}


static void bss_init()
{
    extern uint32_t bss_start, bss_end;
    memset (&bss_start, 0, &bss_end - &bss_start);
}


void timer_callback(pt_regs *regs)
{
    using namespace IO;
    static uint8_t tick = 1;
    Screen t(0, tick);
    t.print_string((char*)"Hello, OS kernel!", vga_color::COLOR_GREEN, vga_color::COLOR_BLACK);
    ++tick;
}

void init_timer(uint32_t frequency)
{
    // 注册时间相关的处理函数
    register_interrupt_handler(IRQ0, timer_callback);

    // Intel 8253/8254 PIT芯片 I/O端口地址范围是40h~43h
    // 输入频率为 1193180，frequency 即每秒中断次数
    uint32_t divisor = 1193180 / frequency;

    // D7 D6 D5 D4 D3 D2 D1 D0
    // 0  0  1  1  0  1  1  0
    // 即就是 36 H
    // 设置 8253/8254 芯片工作在模式 3 下
    outb(0x43, 0x36);

    // 拆分低字节和高字节
    uint8_t low = (uint8_t)(divisor & 0xFF);
    uint8_t high = (uint8_t)((divisor >> 8) & 0xFF);
	
    // 分别写入低字节和高字节
    outb(0x40, low);
    outb(0x40, high);
}


