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

	call	sectors_of_entry
	mov 	%ax, %bx

	push	$0x7c00
	push	$0x0
	push	$0x21
	call	read_sector
	
	/* 跳转至loader */
	ljmp	$0x9000, $0
	
/* 计算根目录扇区数,计算结果保存在ax中 */
	.type	sectors_of_entry, @function
sectors_of_entry:
	xor	%ax, %ax
	xor	%dx, %dx
	mov	BPB_NUMBER_ROOT_ENTRIES, %ax 
	shl	$5, %ax   /* 每条目32bytes */
	divw	BPB_BYTES_PER_SECTOR
	test	%dx, %dx
	jnz	1f
	ret
1:
	inc 	%ax
	ret


/* 读取指定扇区内容，默认每次读一个扇区
 * input: 目标扇区数, 读取到的位置es:bx
 */
	.type	read_sector, @function
read_sector:	
	push	%bp
	mov	%sp, %bp
	
	xor 	%ax, %ax
	mov	%ax, %es
	sub	$4, %sp
	lea	-4(%bp), %bx
	
	mov	4(%bp), %ax
/*	mov	6(%bp), %es
	mov	8(%bp), %bx
*/
 
	
	divb 	BPB_SECS_PER_TRACK
	/* 柱面号 */
	mov	%al, %ch  
	shr	$1, %ch
	/* 磁头号 */
	mov	%al, %dh
	and	$1, %dh
	/* 起始扇区号 */
	mov	%ah, %cl
	inc 	%cl	

	mov	$0, %dl
	mov	$0x0201, %ax
	int 	$0x13
	jc	read_error
	
	leave
	ret

	
read_error:
	mov	%ax, %bx	

	.org  510
	.word BOOT_SIGNATURE 

