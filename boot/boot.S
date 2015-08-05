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
	xor	%ax, %ax
	xor	%cx, %cx
	mov	$BASE_OF_STACK, %sp

	

	.org  510
	.word BOOT_SIGNATURE 

