OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH("i386")
ENTRY(_start)			/* Kernel starts at "start" symbol. */
SECTIONS
{
    /* Specify the kernel base address. */
    . = 0x80400; PROVIDE(kern_start = .);

    /* Kernel starts with code, followed by read-only data and writable data. */
    .text : 
    {
	*(.text)
    } 
    .data : 
    {
	*(.data)
    }

    /* BSS (zero-initialized data) is after everything else. */
    PROVIDE(bss_start = .);
    .bss : { *(.bss) }
    PROVIDE(bss_end = .);

    PROVIDE(kern_end = .);
    /* 暂时不能加载超过64KB的内核镜像 */
    ASSERT(kern_end - kern_start <= 64K, "Kernel image is too big.")
}
