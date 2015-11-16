/*
 * 定义IO操作
 */

#ifndef IO_H
#define IO_H

#include <stdint.h>

/* Reads and returns a byte from PORT. */
static inline uint8_t
inb (uint16_t port)
{
    /* See [IA32-v2a] "IN". */
    uint8_t data;
    asm volatile ("inb %w1, %b0" : "=a" (data) : "dN" (port));
    return data;
}

/* Reads and returns 16 bits from PORT. */
static inline uint16_t
inw (uint16_t port)
{
    uint16_t data;
    /* See [IA32-v2a] "IN". */
    asm volatile ("inw %w1, %w0" : "=a" (data) : "dN" (port));
    return data;
}

/* Reads and returns 32 bits from PORT. */
static inline uint32_t
inl (uint16_t port)
{
    /* See [IA32-v2a] "IN". */
    uint32_t data;
    asm volatile ("inl %w1, %0" : "=a" (data) : "dN" (port));
    return data;
}

/* Writes byte DATA to PORT. */
static inline void
outb (uint16_t port, uint8_t data)
{
    /* See [IA32-v2b] "OUT". */
    asm volatile ("outb %b0, %w1" : : "a" (data), "dN" (port));
}

/* Writes the 16-bit DATA to PORT. */
static inline void
outw (uint16_t port, uint16_t data)
{
    /* See [IA32-v2b] "OUT". */
    asm volatile ("outw %w0, %w1" : : "a" (data), "dN" (port));
}

/* Writes the 32-bit DATA to PORT. */
static inline void
outl (uint16_t port, uint32_t data)
{
    /* See [IA32-v2b] "OUT". */
    asm volatile ("outl %0, %w1" : : "a" (data), "dN" (port));
}


#endif /* IO_H */
