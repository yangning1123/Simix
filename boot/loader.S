/*
 * loader.S: 从floppy中加载kernel.bin文件并跳入保护模式
 *
 * Author: yangning1123@gmail.com
 *
*/

#include "boot.h"
	
	.text
	
	.code16
	.global _start
_start:	
	jmp	start


/* 定义GDT */
label_gdt:
	.quad	0
	

start:
	jmp	.
	
