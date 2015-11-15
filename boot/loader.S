/*
 * loader.S:
 * 1、从floppy中加载kernel.bin ELF文件
 * 2、设置VGA mode(无需设置，默认状态 Text mode, 16 colors, 80x25, 640x200)
 * 3、跳入内核执行
 *
 * Author: yangning1123@gmail.com
 *
 */

#include <sys/boot.h>
	
	.text
	
	.code16
	.global _start
_start:	
	jmp	start
	
	.include "fat12.inc"

start:
	mov	%cs, %ax
	mov	%ax, %ds
	mov	%ax, %es
	mov	%ax, %ss
	mov	$0xfc00, %sp  # 栈顶

	/* 清屏 */
	mov	$0x0600, %ax
	mov	$0x0700, %bx
	xor	%cx, %cx
	mov	$0x184f, %dx
	int 	$0x10

	mov	$0x0, %dh
	call	DispStr

	/* 软驱复位 */
	xor 	%ah, %ah
	xor 	%dl, %dl
	int	$0x13
/* 在根目录下寻找"KERNEL.BIN"文件 */
find_kernel:
	call	sectors_of_root
	/* 为了方便，一次读取整个root */
	push	$OFFSET_OF_ROOT
	push	$BASE_OF_ROOT 
	push	%ax
	push	$0x13
	call 	read_sector
	sub	$0x8, %sp

	/* BASE_OF_ROOT:OFFSET_OF_ROOT */	
	mov	$OFFSET_OF_ROOT, %di
	xor	%ax, %ax
cmp_kernel_name:	
	/* 逐字节比较 */
	lea 	KERNEL_NAME, %si
	mov	$0xb, %cx
	cld
	repe	cmpsb
	je 	load_kernel
	/* 指向本条目的开头 */
	and	$0xffe0, %di  	
	add	$0x20, %di
	inc 	%ax
	cmp 	BPB_NUMBER_ROOT_ENTRIES, %ax
	je	kernel_not_found
	jmp	cmp_kernel_name

kernel_not_found:
	mov	$0x2, %dh
	call 	DispStr
	jmp	.

load_kernel:	
	and	$0xffe0, %di
	/* 取kernel的第一个簇号 */
	add	$0x1a, %di
	mov	%es:(%di), %ax
	xor	%cx, %cx

loop:
	mov	%ax, %dx
	add	$0x1f, %dx
	push	%dx
	mov	BPB_BYTES_PER_SECTOR, %ax
	mul 	%cx
	add	$OFFSET_OF_KERNEL, %ax
	pop	%dx
	push	%ax
	push	$BASE_OF_KERNEL
	push	$0x1
	push	%dx
	call	read_sector
	sub 	$0x8, %sp
	inc 	%cx

	sub	$0x1f, %dx
	push	%dx
	call	get_fat_entry
	sub	$0x2, %sp
	cmp 	$0xff8, %ax
	jae	1f
	jmp 	loop
1:
	mov	$0x1, %dh
	call	DispStr

	/* kernel.bin为elf文件，定义入口地址为80400,跳转至kernel(80400) */
	ljmp	$0x8000, $0x400

	
/* 给定簇号，查找FAT ENTRY，
 * 返回文件的下一个簇号（如果占多个扇区的话）
 */
	.type get_fat_entry, @function
get_fat_entry:
	push	%bp
	mov	%sp, %bp

	push 	%es
	push	%bx
	push	%cx
	push	%dx

	call 	sectors_of_root
	mulw    BPB_BYTES_PER_SECTOR
	
	push	%ax
	push	$BASE_OF_ENTRY
	push	$0x9
	push	$0x1
	call	read_sector

	mov	4(%bp), %ax
	
	mov	$0x3, %cx
	mul	%cx
	dec	%cx
	div	%cx
	
	cmp 	$0x0, %dx
	jz	even
	jmp 	odd
	
odd:	
	add	%ax, %bx
	mov	%es:(%bx), %al
	and	$0xf0, %al
	inc	%bx
	mov	%es:(%bx), %dl
	mov	%dl, %ah
	shr	$0x4, %ax

	jmp	1f
/* 偶数 */
even:
	add	%ax, %bx
	mov	%es:(%bx), %al
	inc	%bx
	mov	%es:(%bx), %dl
	and	$0x0f, %dl
	mov	%dl, %ah
	
1:
	sub	$0x8, %sp
	pop	%dx
	pop	%cx
	pop	%bx
	pop 	%es
	leave
	ret
	
	
/* 计算根目录扇区数,计算结果保存在ax中 */
	.type	sectors_of_root, @function
sectors_of_root:
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


/* 读取指定扇区内容，参数顺序遵循c标准风格
 * input: 目标扇区号、读取扇区数、 读取到的位置es:bx
 */
	.type	read_sector, @function
read_sector:	
	push	%bp
	mov	%sp, %bp
	
	mov	4(%bp), %ax
	mov	8(%bp), %es
	mov	10(%bp), %bx

	push	%cx
	push	%dx
 	
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

	xor	%dl, %dl
	mov	$0x02, %ah
	mov	6(%bp), %al
	int 	$0x13

	pop	%dx
	pop	%cx
	leave
	ret
	

	
/* 函数: Disptr
 * 作用:
 *	显示一个字符串, 函数开始时 dh 中应该是字符串序号(0-based)
 */
	.type	Dispstr, @function
DispStr:
	mov	$MessageLength, %ax
	mul 	%dh
	add	$LoadMessage, %ax
	mov	%ax, %bp
	mov	%ds, %ax
	mov	%ax, %es
	mov	$MessageLength, %cx
	mov	$0x1301, %ax
	mov	$0x0c, %bx
	xor	%dl, %dl
	int	$0x10
	ret
	

/* 常量定义 */
KERNEL_NAME:
	.ascii	"KERNEL  BIN"
	
	.set	MessageLength, 0x9
LoadMessage:
	.ascii	"Loading.."
Message1:
	.ascii	"Ready...."
Message2:
	.ascii	"No Kernel"


