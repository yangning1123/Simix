/* 定义fat12引导扇区格式
 *
 * http://www.maverick-os.dk/FileSystemFormats/FAT12_FileSystem.html
 *
 */	
BPB_OEM_NAME:
	.ascii	"YangNing"
BPB_BYTES_PER_SECTOR:
	.word 	0x200
BPB_SECS_PER_CLUSTER:
	.byte 	0x1
BPB_RESERVED_SECTORS:
	.word	0x1
BPB_NUMBER_FATS:
	.byte 	0x2
BPB_NUMBER_ROOT_ENTRIES:
	.word 	0xE0
BPB_NUMBER_SECTORS:
	.word 	0xB40
BPB_MEDIA_DESC:
	.byte 	0xF0
BPB_SECS_PER_FAT:
	.word	0x9
BPB_SECS_PER_TRACK:
	.word 	0x12
BPB_NUMBER_HEADS:
	.word	0x2
BPB_HIDDEN_SECTORS:
	.word	0x0, 0x0
/* Large number of sectors - Used when volume size is greater than 32Mb */
	.word 	0x0, 0x0
BPB_DRIVE_NUMBER:
	.byte 	0x0
BPB_RESERVED:
	.byte	0x0
BPB_BOOT_SIGNATURE:
	.byte	0x29
BPB_VOLUME_ID:
 	.word	0x0, 0x0
BPB_VOLUME_LABEL:
	.ascii	"Simix v0.01"
BPB_FS_TYPE:
	.ascii	"FAT12   "

