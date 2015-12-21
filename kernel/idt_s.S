# 中断函数汇编部分	
	
####### 定义两个构造中断处理函数的宏(有的中断有错误代码，有的没有)
####### 用于没有错误代码的中断
	.macro ISR_NOERRCODE int_no
	.global isr\int_no
isr\int_no:
	cli
	push	$0x0
	push	\int_no
	jmp	isr_common_stub
	.endm
	
####### 用于有错误代码的中断
	.macro ISR_ERRCODE int_no
	.global isr\int_no
isr\int_no:
	cli
	push	\int_no	
	jmp	isr_common_stub	
	.endm

####### IRQ
	.macro IRQ vec, int_no
	.global irq\vec
irq\vec:
	cli
	push	$0x0
	push	\int_no
	jmp	irq_common_stub	
	.endm
	
	
	.section .text
# 定义中断处理函数 -- 异常
ISR_NOERRCODE	0	# 0 #DE 除 0 异常
ISR_NOERRCODE   1 	# 1 #DB 调试异常
ISR_NOERRCODE   2 	# 2 NMI
ISR_NOERRCODE   3 	# 3 BP 断点异常 
ISR_NOERRCODE   4 	# 4 #OF 溢出 
ISR_NOERRCODE   5 	# 5 #BR 对数组的引用超出边界 
ISR_NOERRCODE   6 	# 6 #UD 无效或未定义的操作码 
ISR_NOERRCODE   7 	# 7 #NM 设备不可用(无数学协处理器) 
ISR_ERRCODE     8 	# 8 #DF 双重故障(有错误代码) 
ISR_NOERRCODE   9 	# 9 协处理器跨段操作
ISR_ERRCODE     10 	# 10 #TS 无效TSS(有错误代码) 
ISR_ERRCODE     11 	# 11 #NP 段不存在(有错误代码) 
ISR_ERRCODE     12 	# 12 #SS 栈错误(有错误代码) 
ISR_ERRCODE     13 	# 13 #GP 常规保护(有错误代码) 
ISR_ERRCODE     14 	# 14 #PF 页故障(有错误代码) 
ISR_NOERRCODE   15 	# 15 CPU 保留 
ISR_NOERRCODE   16 	# 16 #MF 浮点处理单元错误 
ISR_ERRCODE     17 	# 17 #AC 对齐检查 
ISR_NOERRCODE   18 	# 18 #MC 机器检查 
ISR_NOERRCODE   19 	# 19 #XM SIMD(单指令多数据)浮点异常

# 20~31 Intel 保留
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31
	
# 32～255 用户自定义
ISR_NOERRCODE 255

	.extern isr_handler
isr_common_stub:
	pusha
	mov 	%ds, %ax
	push 	%eax          # 保存数据段描述符

	mov	$0x10, %ax
	mov 	%ax, %ds
	mov 	%ax, %es
	mov 	%ax, %fs
	mov 	%ax, %gs
	mov 	%ax, %fs

	push 	%esp
	call   	isr_handler
	add 	$0x4, %esp
	
	pop	%ebx
	mov 	%bx, %ds
	mov 	%bx, %es
	mov 	%bx, %fs
	mov 	%bx, %gs
	mov 	%bx, %ss

	popa
	add 	$0x8, %esp    # 清理栈里的 error code 和 ISR
	iret
	

IRQ   0,    32 	# 电脑系统计时器
IRQ   1,    33 	# 键盘
IRQ   2,    34 	# 与 IRQ9 相接，MPU-401 MD 使用
IRQ   3,    35 	# 串口设备
IRQ   4,    36 	# 串口设备
IRQ   5,    37 	# 建议声卡使用
IRQ   6,    38 	# 软驱传输控制使用
IRQ   7,    39 	# 打印机传输控制使用
IRQ   8,    40 	# 即时时钟
IRQ   9,    41 	# 与 IRQ2 相接，可设定给其他硬件
IRQ  10,    42 	# 建议网卡使用
IRQ  11,    43 	# 建议 AGP 显卡使用
IRQ  12,    44 	# 接 PS/2 鼠标，也可设定给其他硬件
IRQ  13,    45 	# 协处理器使用
IRQ  14,    46 	# IDE0 传输控制使用
IRQ  15,    47 	# IDE1 传输控制使用	

	.extern irq_handler
irq_common_stub:
	pusha
	mov 	%ds, %ax
	push 	%eax          # 保存数据段描述符

	mov	$0x10, %ax
	mov 	%ax, %ds
	mov 	%ax, %es
	mov 	%ax, %fs
	mov 	%ax, %gs
	mov 	%ax, %fs

	push 	%esp
	call   	irq_handler
	add 	$0x4, %esp
	
	pop	%ebx
	mov 	%bx, %ds
	mov 	%bx, %es
	mov 	%bx, %fs
	mov 	%bx, %gs
	mov 	%bx, %ss

	popa
	add 	$0x8, %esp    # 清理栈里的 error code 和 IRQ
	iret
