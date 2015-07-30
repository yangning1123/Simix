/*
 * boot.S：从floppy寻找loader并读入内存
 * 
 * Author:yangning1123@gmail.com
 *
 */		

	.text
	.code16
	.global _start
_start:
	ljmp	$0, $start
	nop
start:
	nop



	.org 510
	.word 0xaa55
	
