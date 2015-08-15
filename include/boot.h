#ifndef BOOT_H
#define BOOT_H

#define		BOOT_SIGNATURE 	     0xaa55	
#define 	BASE_OF_STACK 	     0x7c00

/* 定义从软盘读取sectors到内存的位置，0x7e00=0x7c00+0x200 */
#define         OFFSET_OF_READ_SECS  0x07e00


#endif /* BOOT_H */
