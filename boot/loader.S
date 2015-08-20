	.code16
	.text
	.global _start
_start:	
	mov	$0xb800, %ax
	mov	%ax, %gs
	mov	$0x0f, %ah
	mov	$0x4c, %al
	mov	%ax, %gs:((80 * 1 + 39) * 2)
	jmp 	.
