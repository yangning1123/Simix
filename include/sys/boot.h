#ifndef BOOT_H
#define BOOT_H

#define		BOOT_SIGNATURE 	     0xaa55	
#define 	BASE_OF_STACK 	     0x7c00

/* 定义从软盘读取根目录、FAT表项到内存的位置，0x7e00=0x7c00+0x200 */
#define         OFFSET_OF_CACHE       0x7E00

/* 定义读取kernel的内存位置,0x10000=0x1000:0x0 */
#define         BASE_OF_KERNEL       0x1000
#define         OFFSET_OF_KERNEL     0x0
#define         KERNEL_PHY_ADDR      BASE_OF_KERNEL << 4 + OFFSET_OF_KERNEL

#define         ENTRY_OF_KERNEL      0x10400

#endif /* BOOT_H */
