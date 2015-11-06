/*
 * boot.S：从floppy寻找loader并读入内存
 * 
 * Author:yangning1123@gmail.com
 *
 */		

#include "boot.h"
	
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
	

/* 在根目录下寻找"LOADER.BIN"文件 */
find_loader:
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
cmp_loader_name:	
	/* 逐字节比较 */
	lea 	LOADER_NAME, %si
	mov	$0xb, %cx
	cld
	repe	cmpsb
	je 	load_loader
	/* 指向本条目的开头 */
	and	$0xffe0, %di  	
	add	$0x20, %di
	inc 	%ax
	cmp 	BPB_NUMBER_ROOT_ENTRIES, %ax
	je	loader_not_found
	jmp	cmp_loader_name

loader_not_found:
	mov	$0x2, %dh
	call 	DispStr
	jmp	.

load_loader:	
	and	$0xffe0, %di
	/* 取loader的第一个簇号 */
	add	$0x1a, %di
	mov	%es:(%di), %ax
	xor	%cx, %cx

loop:
	mov	%ax, %dx
	add	$0x1f, %dx
	push	%dx
	mov	BPB_BYTES_PER_SECTOR, %ax
	mul 	%cx
	add	$OFFSET_OF_LOADER, %ax
	pop	%dx
	push	%ax
	push	$BASE_OF_LOADER
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
	/* 跳转至loader */
	ljmp	$BASE_OF_LOADER, $OFFSET_OF_LOADER

	
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
	add	$BootMessage, %ax
	mov	%ax, %bp
	mov	%ds, %ax
	mov	%ax, %es
	mov	$MessageLength, %cx
	mov	$0x1301, %ax
	mov	$0x7, %bx
	xor	%dl, %dl
	int	$0x10
	ret
	
/* 常量定义 */
LOADER_NAME:
	.ascii	"LOADER  BIN"
	
	.set	MessageLength, 0x9
BootMessage:
	.ascii	"Booting.."
Message1:
	.ascii	"Ready    "
Message2:
	.ascii	"No Loader"
	
	.org  510
	.word BOOT_SIGNATURE 

