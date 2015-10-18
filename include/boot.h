#ifndef BOOT_H
#define BOOT_H

#define		BOOT_SIGNATURE 	     0xaa55	
#define 	BASE_OF_STACK 	     0x7c00

/* 定义从软盘读取根目录到内存的位置，0x7e00=0x7c00+0x200 */
#define         BASE_OF_ROOT         0x7e0
#define         OFFSET_OF_ROOT       0x0


/* 定义从软盘读取FAT Entry内容到内存位置, 放在root后面，偏移地址须由计算得出 */
#define         BASE_OF_ENTRY        0x7e0
     

/* 定义读取loader的内存位置，0x90000=0x9000:0x0 */
#define         BASE_OF_LOADER       0x9000
#define         OFFSET_OF_LOADER     0x0

#define         LOADER_PHY_ADDR      0x90000


/* 定义读取kernel的内存位置,0x80000=0x8000:0x0 */
#define         BASE_OF_KERNEL       0x8000
#define         OFFSET_OF_KERNEL     0x0

#define         KERNEL_PHY_ADDR      0x80000

#define         ENTRY_OF_KERNEL      0x80400

#endif /* BOOT_H */
