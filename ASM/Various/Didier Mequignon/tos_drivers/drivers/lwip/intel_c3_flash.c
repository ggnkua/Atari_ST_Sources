/*
 * File:        intel_c3_flash.c
 * Purpose:     Flash driver for programming Intel Flash devices
 *
 * Notes:       This driver supports a single banks of Intel Flash.
 *              A bank is defined as one or more of the same Flash 
 *              device connected to a single chip-select.
 */

#include "net.h"
#include "intel_c3_flash.h"

/********************************************************************/
/*
 * Global pointer to base of Intel Flash device
 */
static INTEL_C3_FLASH_CELL *pFlash;

/********************************************************************/
void intel_c3_flash_init(unsigned long base)
{
    pFlash = (INTEL_C3_FLASH_CELL *)base;
}
/********************************************************************/
void intel_c3_flash_unlock(unsigned long start, int bytes)
{
    int i, unlocked = 0;

    if (bytes == 0)
        return;

    for (i = 0; i < INTEL_C3_FLASH_SECTORS; i++)
    {
        if (start >= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i)) &&
            start <= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1)))
        {
            break;
        }
    }

    bytes += ((int)start - (int)((unsigned long)pFlash + C3_SOFFSET(i)));

    while (unlocked < bytes)
    {
        /*
         * Unlock Block command
         */
        pFlash[C3_SADDR(i)] = INTEL_C3_FLASH_CMD_DATA(0x60);
        pFlash[C3_SADDR(i)] = INTEL_C3_FLASH_CMD_DATA(0xD0);
        unlocked += C3_SSIZE(i);
        i++;
    }
}
/********************************************************************/
void intel_c3_flash_lock(unsigned long start, int bytes)
{
    int i, locked = 0;

    if (bytes == 0)
        return;

    for (i = 0; i < INTEL_C3_FLASH_SECTORS; i++)
    {
        if (start >= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i)) &&
            start <= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1)))
        {
            break;
        }
    }

    bytes += ((int)start - (int)((unsigned long)pFlash + C3_SOFFSET(i)));

    while (locked < bytes)
    {
        /*
         * Lock Block command
         */
        pFlash[C3_SADDR(i)] = INTEL_C3_FLASH_CMD_DATA(0x60);
        pFlash[C3_SADDR(i)] = INTEL_C3_FLASH_CMD_DATA(0x01);
        locked += C3_SSIZE(i);
        i++;
    }
}
/********************************************************************/
void intel_c3_flash_sector_erase(int n)
{
    INTEL_C3_FLASH_CELL status;

    /*
     * Erase Block command
     */
    pFlash[C3_SADDR(n)] = INTEL_C3_FLASH_CMD_DATA(0x20);
    pFlash[C3_SADDR(n)] = INTEL_C3_FLASH_CMD_DATA(0xD0);

    /*
     * Wait for the erase operation to finish
     */
    do
    {
        pFlash[C3_SADDR(n)] = INTEL_C3_FLASH_CMD_DATA(0x70);
        status = pFlash[C3_SADDR(n)];
    }
    while (!(status & INTEL_C3_FLASH_CMD_DATA(0x80)));

    /*
     * Place back in normal read mode
     */
    pFlash[C3_SADDR(n)] = INTEL_C3_FLASH_CMD_DATA(0xFF);
}
/********************************************************************/
int intel_c3_flash_erase(unsigned long start, int bytes, void (*putchar)(char))
{
    int i, ebytes = 0;

    if (bytes == 0)
        return 0;

    /*
     * Unlock the required blocks
     */
    intel_c3_flash_unlock(start, bytes);

    for (i = 0; i < INTEL_C3_FLASH_SECTORS; i++)
    {
        if (start >= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i)) &&
            start <= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1)))
        {
            break;
        }
    }

    bytes += ((int)start - (int)((unsigned long)pFlash + C3_SOFFSET(i)));

    while (ebytes < bytes)
    {
        if (putchar != NULL)
        {
            putchar('.');
        }
        intel_c3_flash_sector_erase(i);
        ebytes += C3_SSIZE(i);
        i++;
    }

    if (putchar != NULL)
    {
        putchar(10);    /* LF */
        putchar(13);    /* CR */
    }

    /*
     * Lock up
     */
    intel_c3_flash_lock(start, bytes);

    return ebytes;
}
/********************************************************************/
void intel_c3_flash_program_cell(INTEL_C3_FLASH_CELL *dst, INTEL_C3_FLASH_CELL data)
{
    INTEL_C3_FLASH_CELL status;

    *dst = INTEL_C3_FLASH_CMD_DATA(0x40);
    *dst = data;

    /*
     * Wait for program operation to finish
     */
    do
    {
        *dst = INTEL_C3_FLASH_CMD_DATA(0x70);
        status = *dst;
    }
    while (!(status & INTEL_C3_FLASH_CMD_DATA(0x80)));

    /*
     * Place back in normal read mode
     */
    *dst = INTEL_C3_FLASH_CMD_DATA(0xFF);
}
/********************************************************************/
int intel_c3_flash_program(unsigned long dest, unsigned long source,
                    int bytes, int erase,
                    void (*func)(void),
                    void (*putchar)(char))
{
    INTEL_C3_FLASH_CELL *src, *dst;
    int hashi=1,hashj=0;
    char hash[5];

    hash[0]=8;  /* Backspace */
    hash[1]=124;/* "|" */
    hash[2]=47; /* "/" */
    hash[3]=45; /* "-" */
    hash[4]=92; /* "\" */

    src = (INTEL_C3_FLASH_CELL *)source;
    dst = (INTEL_C3_FLASH_CELL *)dest;

    /*
     * Erase device if necessary
     */
    if (erase)
    {
        intel_c3_flash_erase(dest, bytes, putchar);
    }

    /*
     * Unlock the required blocks
     */
    intel_c3_flash_unlock(dest, bytes);

    /*
     * Program device
     */
    while (bytes > 0)
    {
        intel_c3_flash_program_cell(dst,*src);

        /* Verify Write */
        if (*dst == *src)
        {
            bytes -= INTEL_C3_FLASH_CELL_BYTES;
            *dst++, *src++;

            if ((putchar != NULL))
            {
                /* Hash marks to indicate progress */
                if (hashj == 0x1000)
                {
                    hashj = -1;
                    putchar(hash[0]);
                    putchar(hash[hashi]);

                    hashi++;
                    if (hashi == 5)
                    {
                        hashi=1;
                    }
                }
                hashj++;
            }
        }
        else
            break;
    }

    if (putchar != NULL)
    {
        putchar(hash[0]);
    }

    /*
     * Leaving now - lock up
     */
    intel_c3_flash_lock(dest, bytes);

    /*
     * If a function was passed in, call it now
     */
    if ((func != NULL))
    {
        func();
    }

    return ((int)src - (int)source);
}
/********************************************************************/
unsigned long intel_c3_flash_sector_start(unsigned long addr)
{
    /*
     * Returns beginning of sector containing addr
     */
    int i;

    for (i = 0; i < INTEL_C3_FLASH_SECTORS; i++)
    {
        if (addr >= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i)) &&
            addr <= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1)))
        {
            return (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i));
        }
    }
    return (unsigned long)NULL;
}
/********************************************************************/
unsigned long intel_c3_flash_sector_end(unsigned long addr)
{
    /* Returns end of sector containing unsigned long */
    int i;

    for (i = 0; i < INTEL_C3_FLASH_SECTORS; i++)
    {
        if (addr >= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i)) &&
            addr <= (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1)))
        {
            return (unsigned long)((unsigned long)pFlash + C3_SOFFSET(i) + (C3_SSIZE(i) - 1));
        }
    }
    return (unsigned long)NULL;
}
/********************************************************************/
