/*
 * boot.S：从floppy寻找kernel并读入内存
 * 
 * Author:yangning1123@gmail.com
 *
 */		

#include <sys/boot.h>
	
	.text
	.code16
	.global _start
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
	mov	$0x184F, %dx
	int 	$0x10

	mov	$0x0, %dh
	call	DispStr

	/* 软驱复位 */
	xor 	%ah, %ah
	xor 	%dl, %dl
	int	$0x13
	

/* 在根目录下寻找"KERNEL.BIN"文件 */
find_kernel:
	/* 为了方便，一次读取整个root(14sectors)到0x7E00处 */
	mov	$OFFSET_OF_CACHE, %bx
	mov	$0x13, %ax
	mov	$0xE, %cx
	call 	read_sector

	mov	$OFFSET_OF_CACHE, %di
	xor	%ax, %ax
cmp_kernel_name:	
	/* 逐字节比较 */
	lea 	KERNEL_NAME, %si
	mov	$0xB, %cx
	cld
	repe	cmpsb
	je 	load_fat
	/* 指向本条目的开头 */
	and	$0xFFE0, %di  	
	add	$0x20, %di
	inc 	%ax
	cmp 	BPB_NUMBER_ROOT_ENTRIES, %ax
	je	kernel_not_found
	jmp	cmp_kernel_name

kernel_not_found:
	mov	$0x2, %dh
	call 	DispStr
	jmp	.

	
load_fat:
	and	$0xFFE0, %di
	/* 取kernel的第一个簇号 */
	add	$0x1A, %di
	mov	(%di), %dx
	push 	%dx
	mov	$OFFSET_OF_CACHE, %bx
	mov	$0x1, %ax
	mov	$0x9, %cx
	call 	read_sector

load_kernel:	
	pop	%dx
	mov	%dx, %ax
	mov	$BASE_OF_KERNEL, %cx
	mov	%cx, %es
	mov	$OFFSET_OF_KERNEL, %bx
	
loop:
	push 	%dx
	add	$0x1F, %ax

	mov	$1, %cx
	call	read_sector

	pop	%ax
	call	get_fat_entry
	cmp 	$0xff8, %ax
	jae	2f
	mov	%ax, %dx
	add	BPB_BYTES_PER_SECTOR, %bx
	jnc	loop
1:
	push	%ax
	mov	%es, %ax
	add	$0x1000, %ax     # 段 + 1
	mov	%ax, %es
	pop 	%ax
	jmp	loop
2:
	mov	$0x1, %dh
	call	DispStr
	
	/* Fire up the kernel! */
	ljmp	$0x1000, $0x400

	
/* 给定簇号，查找FAT ENTRY，
 * 返回文件的下一个簇号（如果占多个扇区的话）
 */
	.type get_fat_entry, @function
get_fat_entry:
	xor	%si, %si
	mov	$OFFSET_OF_CACHE, %si
	mov	$0x3, %cx
	mul	%cx
	dec	%cx
	div	%cx
	
	cmp 	$0x0, %dx
	jz	even
	jmp 	odd
	
odd:	
	add	%ax, %si
	mov	%ds:(%si), %al
	and	$0xf0, %al
	inc	%si
	mov	%ds:(%si), %dl
	mov	%dl, %ah
	shr	$0x4, %ax
	ret
/* 偶数 */
even:
	add	%ax, %si
	mov	%ds:(%si), %al
	inc	%si
	mov	%ds:(%si), %dl
	and	$0x0f, %dl
	mov	%dl, %ah	
	ret
	
	
/* 读取扇区内容到指定内存位置
 * ax:目标扇区号 cx:读取扇区数  读取到的位置es:bx
 */
	.type	read_sector, @function
read_sector:
	push	%cx
	
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

	pop	%ax
	mov	$0x02, %ah
	xor	%dl, %dl
	int 	$0x13
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
	mov	$0x0c, %bx
	xor	%dl, %dl
	int	$0x10
	ret
	
/* 常量定义 */
KERNEL_NAME:
	.ascii	"KERNEL  BIN"
	
	.set	MessageLength, 0x9
BootMessage:
	.ascii	"Booting.."
Message1:
	.ascii	"Ready...."
Message2:
	.ascii	"No Kernel"
	
	.org  	510
	.word 	BOOT_SIGNATURE 
