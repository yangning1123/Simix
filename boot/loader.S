/*
 * loader.S: 从floppy中加载kernel.bin文件并跳入保护模式
 *
 * Author: yangning1123@gmail.com
 *
*/

#include <boot.h>
	
	.text
	
	.code16
	.global _start
_start:	
	jmp	start



start:
	jmp	.
	


#### GDT

	.align 8
gdt:
	.quad 0x0000000000000000	# Null segment.  Not used by CPU.
	.quad 0x00cf9a000000ffff	# System code, base 0, limit 4 GB.
	.quad 0x00cf92000000ffff        # System data, base 0, limit 4 GB.

gdtdesc:
	.word	gdtdesc - gdt - 1	# Size of the GDT, minus 1 byte.
	.long	gdt			# Address of the GDT.
	
