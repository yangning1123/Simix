OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH("i386")
ENTRY(_start)			/* Kernel starts at "_start" symbol. */
SECTIONS
{
    /* Specify the kernel base address. */
    . = 0x80400; PROVIDE(kernel_start = .);

    /* Kernel starts with code, followed by writable data. */
    .text : 
    {
	*(.text)
	*(.text.*)
    }
    .rodata :
    {
	*(.rodata) 
	*(.rodata.*)
    }   
    .data : 
    {
	*(.data)
    }
   
    /* BSS (zero-initialized data) is after everything else. */
    PROVIDE(bss_start = .);
    .bss : { *(.bss) }
    PROVIDE(bss_end = .);

    PROVIDE(kernel_end = .);
    /* 暂时不能加载超过64KB的内核镜像 */
    ASSERT(kernel_end - kernel_start <= 64K, "Kernel image is too big.")
}
