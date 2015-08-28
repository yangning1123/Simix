/*
 * loader.S: 从floppy中加载kernel.bin文件并跳入保护模式
 *
 * Author: yangning1123@gmail.com
 *
 */
	.text
	
	.code16
	.global _start
_start:	
	jmp	start


/* 定义GDT */

	

start:
	jmp	.
	
