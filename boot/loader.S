	.global	_start
_start:	
	mov	$0xb800, %ax
	mov	%ax, %gs
	mov	$0x0f, %ah
	mov	'L', %al
	mov	%ax, %gs:((80 * 0 + 39) * 2)
	jmp 	.
