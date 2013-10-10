/*
    File: DMA.H               Atari ST DMA device.

    Oct 1988. V1.00 T.H. Schipper
*/
/* References:
 
 * Atari Toolkit page 933 
 * c't Magazin 88/3  page 265 
*/
/*
Copyright (c) 1988 - 1991 by Ted Schipper.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

This software is provided AS IS with no warranties of any kind.  The author
shall have no liability with respect to the infringement of copyrights,
trade secrets or any patents by this file or any part thereof.  In no
event will the author be liable for any lost revenue or profits or
other special, indirect and consequential damages.
*/

#define DMA_ADDR 0xFF8600L      /* DMA device addres */

#define DMA      ((struct dma_chip *) DMA_ADDR)


struct dma_chip {
             short reserved[2]; /* reserved registers */
             short DATA;        /* controller & sector count reg */
             short MODE;        /* mode & status register */
             char  ADDR[6];     /* base addres. High/Mid/Low */
                 } ;


/* pseudo names */

#define SECT_CNT     DATA
#define STATUS       MODE

/* offset into addr, odd bytes used only */

#define HIGH         1
#define MID          3
#define LOW          5

/* Mode Register bits */

#define NOT_USED     0x0001     /* not used bit */
#define A0           0x0002     /* A0 line, A1 on DMA port */
#define A1           0x0004     /* A1 line, not used on DMA port */
#define HDC          0x0008     /* HDC / FDC register select */
#define SC_REG       0x0010     /* Sector count register select */
#define RESERVED5    0x0020     /* reserved for future expansion ? */
#define RESERVED6    0x0040     /* bit has no function */
#define NO_DMA       0x0080     /* disable / enable DMA transfer */
#define DMA_WR       0x0100     /* Write to / Read from DMA port */

/* Status Register bits */

#define DMA_OK       0x0001     /* DMA transfer went OK */
#define SC_NOT_0     0x0002     /* Sector count register not zero */
#define DATA_REQ     0x0004     /* DRQ line state */

