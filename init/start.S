/*
 * start.S: 内核入口
 *
 */
	
	.text
	.code32
 	.global _start
_start:
	mov	$0x10, %eax
	mov 	%ax, %ds
	mov 	%ax, %es
	mov 	%ax, %fs
	mov 	%ax, %gs
	mov 	%ax, %ss

	call 	main

	jmp	.

	


