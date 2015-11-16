/*
 * start.S: 内核入口，要做的工作如下,
 * 1、检测内存信息
 * 2、进入保护模式
 * 3、开启分页机制
 * 4、跳入main函数
 * 
 */
#include <sys/boot.h>

# CR0相关属性	
#define CR0_PE 		0x00000001      /* 保护模式 */
#define CR0_PG 		0x80000000	/* 分页机制 */

# 页相关属性		
#define	PDE_ADDR	0x100000  	/* 页表目录在1MB内存处 */
#define PTE_ADDR	0x101000        /* 页表地址1M + 4K */
#define PG_P		0x1             /* 页存在标识位 */	

	.section .text
	.code16
 	.global _start
_start:
	# 清屏 
	mov	$0x0600, %ax
	mov	$0x0700, %bx
	xor	%cx, %cx
	mov	$0x184f, %dx
	int 	$0x10
	
	mov	%cs, %ax
	mov 	%ax, %ds
	mov 	%ax, %es
	mov 	%ax, %ss
	
/* 获取内存信息 */
# Set string instructions to go upward.
	cld

#### Get memory size, via interrupt 15h function 88h (see [IntrList]),
#### which returns AX = (kB of physical memory) - 1024.  This only
#### works for memory sizes <= 65 MB, which should be fine for our
#### purposes.  We cap memory at 64 MB because that's all we prepare
#### page tables for, below.

	movb 	$0x88, %ah
	int 	$0x15
	addl 	$1024, %eax	# Total kB memory
	cmp 	$0x10000, %eax	# Cap at 64 MB
	jbe 	1f
	mov 	$0x10000, %eax
1:	shrl 	$2, %eax		# Total 4 kB pages
	addr32 	movl %eax, init_ram_pages - KERNEL_PHY_ADDR

/* -- 此方法获取可用内存分布图，但比较繁琐，故改用上述方式只获取内存大小 --
	xor	%ebx, %ebx
	addr32  mov $mem_info_buffer - KERNEL_PHY_ADDR, %edi
get_mem_info:
	mov	$0xe820, %eax
	mov	$0x14, %ecx
	mov	$0x534d4150, %edx
	int	$0x15
	jc	get_mem_fail
	add	$0x14, %di
	addr32  incl mem_entry_count - KERNEL_PHY_ADDR
	cmp	$0x0, %ebx
	jne	get_mem_info
	jmp	get_mem_ok

get_mem_fail:
	addr32  movl $0x0, mem_entry_count - KERNEL_PHY_ADDR
	jmp	.

get_mem_ok:
*/

/* 进入保护模式 */
enter_pm_start:
	data32 addr32 lgdt gdtptr - KERNEL_PHY_ADDR
	cli

	# 打开地址线A20
	in	$0x92, %al
	or 	$0x2, %al
	out	%al, $0x92 

	# 准备切换到保护模式
	mov	%cr0, %eax
	orl	$CR0_PE, %eax
	mov	%eax, %cr0

	data32	ljmp $0x8, $1f
	
	.code32
1:
	mov	$0x10, %ax
	mov 	%ax, %ds
	mov 	%ax, %es
	mov 	%ax, %fs
	mov 	%ax, %gs
	mov 	%ax, %ss
	call 	setup_paging
	mov	$top_of_stack, %esp
	and 	$0xFFFFFFF0, %esp     # 16字节对齐, why?
	mov	$0x0, %ebp

	# note:如果入口函数不是main，要extern "C"
	call 	main 		      # fire up the kernel.

	jmp	.


/* 设置页表 */
setup_paging:
	# 初始化页目录
  	mov 	init_ram_pages, %ecx
	shrl	$0xa, %ecx            # 页目录个数
	mov  	$PDE_ADDR, %edi
	mov 	$PTE_ADDR | PG_P, %eax
1:	
	stosl
	add 	$0x1000, %eax
	loop	1b

	# 初始化所有页表
	mov 	init_ram_pages, %ecx  # 页表个数
	mov 	$PTE_ADDR, %edi
	xor	%eax, %eax            # 从内存起始开始映射
	mov	$PG_P, %eax
1:
	stosl
	add 	$0x1000, %eax
	loop	1b

	# CR3指向页目录表地址
	mov	$PDE_ADDR, %eax
	mov 	%eax, %cr3
	mov 	%cr0, %eax
	orl 	$CR0_PG, %eax	      # 分页机制
	movl 	%eax, %cr0

	ret	





#### GDT
	.align 8
gdt:
	.quad 0x0000000000000000	# Null segment.  Not used by CPU.
	.quad 0x00cf9a000000ffff	# System code, base 0, limit 4 GB.
	.quad 0x00cf92000000ffff        # System data, base 0, limit 4 GB.

gdtptr:
	.word	gdtptr - gdt - 1	# Size of the GDT, minus 1 byte.
	.long	gdt			# Address of the GDT.


	.section .data
/* 内存信息缓存块 */
	.global mem_info_buffer
mem_info_buffer:
	.fill	256
/* 内存块条数 */
	.global	mem_entry_count	
mem_entry_count:
	.int	0

# 内存分页数	
	.global init_ram_pages
init_ram_pages:
	.int	0

# 内核栈1K大小
	.section .bss
	.fill  1024
top_of_stack:	
