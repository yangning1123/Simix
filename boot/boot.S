/*
 * boot.S：从floppy寻找loader并读入内存
 * 
 * Author:yangning1123@gmail.com
 *
 */		

#include <boot.h>
	
	.text
	.code16
	.global _start
	.type	_start, @function
_start:
	jmp	after_BPB
	nop

/* fat12文件格式 */
	.include "fat12.inc"
	
after_BPB:
	ljmp	$0, $real_start
	
real_start:
/* 初始化堆栈及各个寄存器,段寄存器均为0,故忽略 */
	xorw	%ax, %ax
	xorw	%cx, %cx
	movw	$BASE_OF_STACK, %sp

	call	sectors_of_entry
	movw 	%ax, %bx

	/* 跳转至loader */
	ljmp	$0x9000, $0
	
/* 计算根目录扇区数,计算结果保存在ax中 */
	.type	sectors_of_entry, @function
sectors_of_entry:
	xorw	%ax, %ax
	xorw	%dx, %dx
	movw	BPB_NUMBER_ROOT_ENTRIES, %ax 
	shl	$5, %ax   /* 每条目32bytes */
	divw	BPB_BYTES_PER_SECTOR
	testw	%dx, %dx
	jnz	1f
	ret
1:
	inc 	%ax
	ret


/* 读取指定扇区内容 */
	.type	read_sector, @function
read_sector:	
	

	.org  510
	.word BOOT_SIGNATURE 

