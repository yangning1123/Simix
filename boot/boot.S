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

	/* 软驱复位 */
	xor 	%ah, %ah
	xor 	%dl, %dl
	int 	$0x13
	
	push	$OFFSET_OF_READ_SECS
	push	$BASE_OF_READ_SECS
	
	


/* 在根目录下寻找"LOADER.BIN"文件 */
find_loader:
	call sectors_of_root
	/* 为了方便，一次读取整个root */
	push	%ax
	push	$0x13
	call 	read_sector
	sub	$0x4, %sp

	/* BASE_OF_READ_SECS:OFFSET_OF_READ_SECS */	
	mov	$OFFSET_OF_READ_SECS, %di
	xor	%ax, %ax
cmp_loader_name:	
	/* 逐字节比较 */
	lea 	LOADER_NAME, %si
	mov	$0xb, %cx
	cld
	repe	cmpsb
	je 	get_fat_entry
	/* 指向本条目的开头 */
	and	$0xffe0, %di  	
	add	$0x20, %di
	inc 	%ax
	cmp 	BPB_NUMBER_ROOT_ENTRIES, %ax
	je	loader_not_found
	jmp	cmp_loader_name

loader_not_found:
	jmp	.
	
/* 给定簇号，查找FAT ENTRY，
 * 返回文件的下一个簇号（如果占多个扇区的话）
 */
	.type get_fat_entry, @function
get_fat_entry:
	push	%bp
	mov	%sp, %bp

	push	$0x1
	push	$0x9
	call	read_sector
	

	leave 
	ret
	
/* 加载loader */
load_loader:
	
	/* 跳转至loader */
	ljmp	$BASE_OF_READ_SECS, $OFFSET_OF_READ_SECS
	
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
	
	leave
	ret


/* 常量定义 */
LOADER_NAME:
	.ascii	"LOADER  BIN"

	
	.org  510
	.word BOOT_SIGNATURE 

