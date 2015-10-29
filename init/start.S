/*
 * start.S: 内核入口，要做的工作如下,
 * 1、检测内存信息
 * 2、开启分页机制
 * 3、进入保护模式
 *
 */
#include <boot.h>
	.text
	.code16
 	.global _start
_start:
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

/* -- 此方法比较繁琐，故改用上述方式获取内存大小 --
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
	
/* 设置页表 */
setup_paging:


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
	or	$0x1, %eax
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
	call 	main
	jmp	.

/* 内存信息缓存块 */
#	.global mem_info_buffer
#mem_info_buffer:
#	.fill	256
/* 内存块条数 */
#	.global	mem_entry_count	
#mem_entry_count:
#	.int	0

# 内存分页数	
	.global init_ram_pages
init_ram_pages:
	.int	0


#### GDT
	.align 8
gdt:
	.quad 0x0000000000000000	# Null segment.  Not used by CPU.
	.quad 0x00cf9a000000ffff	# System code, base 0, limit 4 GB.
	.quad 0x00cf92000000ffff        # System data, base 0, limit 4 GB.

gdtptr:
	.word	gdtptr - gdt - 1	# Size of the GDT, minus 1 byte.
	.long	gdt			# Address of the GDT.
	
