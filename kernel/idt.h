/*
 * idt设置 
 *
 */


#ifndef IDT_H
#define IDT_H

#include <stdint.h>

void init_idt();

// 中断描述符
typedef
struct idt_entry {
    uint16_t base_low;
    uint16_t selector;
    uint8_t  always0;
    uint8_t  flags;
    uint16_t base_high;
}__attribute__((packed)) idt_entry_t;

// IDTR
typedef
struct idt_ptr {
    uint16_t limit;
    uint32_t base;
}__attribute__((packed)) idt_ptr_t;

// 寄存器类型
typedef
struct pt_regs {
    uint32_t ds;		    // 用于保存用户的数据段描述符
    uint32_t edi; 		    // 从 edi 到 eax 由 pusha 指令压入
    uint32_t esi; 
    uint32_t ebp;
    uint32_t esp;
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t int_no; 	            // 中断号
    uint32_t err_code;  	    // 错误代码(有中断错误代码的中断会由CPU压入)
    uint32_t eip;		    // 以下由处理器自动压入
    uint32_t cs; 		
    uint32_t eflags;
    uint32_t useresp;
    uint32_t ss;
} pt_regs_t;



// 声明中断处理函数 0 ~ 19 属于 CPU 的异常中断
// ISR中断服务程序:(interrupt service routine)
extern "C"
{
    void isr0();                    // 0 #DE 除 0 异常
    void isr1();                    // 1 #DB 调试异常
    void isr2();                    // 2 NMI
    void isr3();                    // 3 BP 断点异常
    void isr4();                    // 4 #OF 溢出
    void isr5();                    // 5 #BR 对数组的引用超出边界
    void isr6();                    // 6 #UD 无效或未定义的操作码
    void isr7();                    // 7 #NM 设备不可用无数学协处理器()
    void isr8();                    // 8 #DF 双重故障有错误代码()
    void isr9();                    // 9 协处理器跨段操作
    void isr10();                   // 10 #TS 无效TSS有错误代码()
    void isr11();                   // 11 #NP 段不存在有错误代码()
    void isr12();                   // 12 #SS 栈错误有错误代码()
    void isr13();                   // 13 #GP 常规保护有错误代码()
    void isr14();                   // 14 #PF 页故障(有错误代码) 
    void isr15(); 	            // 15 CPU 保留 
    void isr16(); 		    // 16 #MF 浮点处理单元错误 
    void isr17(); 		    // 17 #AC 对齐检查 
    void isr18(); 		    // 18 #MC 机器检查 
    void isr19(); 		    // 19 #XM SIMD(单指令多数据)浮点异常

    // 20 ~ 31 Intel 保留
    void isr20();
    void isr21();
    void isr22();
    void isr23();
    void isr24();
    void isr25();
    void isr26();
    void isr27();
    void isr28();
    void isr29();
    void isr30();
    void isr31();

    // 32 ~ 255 用户自定义异常
    void isr255();
}

#endif /* IDT_H */

