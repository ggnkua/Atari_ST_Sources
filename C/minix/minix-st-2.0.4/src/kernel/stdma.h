/*
 * Atari ST hardware:
 * DMA circuitry
 */

#define	DMA	((struct dma *)AD_DMA_ACSI)

struct dma {
    unsigned short		dma_gap[2];	/* reserved */
    _VOLATILE unsigned short	dma_data;	/* controller data path */
    _VOLATILE unsigned short	dma_mode;	/* mode register */
    _VOLATILE unsigned char	dma_addr[6];	/* base address H/M/L */
    _VOLATILE unsigned short	fdc_mode;	/* floppy mode register */
};
#define	dma_nsec      dma_data		/* sector count */
#define	dma_stat      dma_mode		/* status register */

/*
 * Mode register bits
 */
/*		0x0001		   not used */
#define	A0	0x0002		/* signal A0 to fdc/hdc */
#define	A1	0x0004		/* signal A1 to fdc/hdc */
#define	HDC	0x0008		/* must be on if accessing hdc */
#define	SCREG	0x0010		/* access sector count register */
/*		0x0020		   reserved */
#define	NODMA	0x0040		/* no DMA (yet) */
#define	FDC	0x0080		/* must be on if accessing fdc */
#define	WRBIT	0x0100		/* write to fdc/hdc via dma_data */

/*
 * Status register bits
 */
#define	DMAOK	0x0001		/* something wrong */
#define	SCNOT0	0x0002		/* sector count not 0 */
#define	DATREQ	0x0004		/* FDC data request signal */

/*
 * Indices into dma_addr.
 * Access low byte of 16 bits.
 * Fill low/mid/high in this order.
 */
#define	AD_HIGH	1
#define	AD_MID	3
#define	AD_LOW	5

/*
 * floppy mode register bits
 */
#define	FD_DD	0x0000		/* 360/720 Kb (DD) floppy */
#define	FD_HD	0x0003		/* 1.44 Mb (HD) floppy */

/*
 * used for transfers to/from "fast ram"
 */
#define	is_fast_ram(p)	((p) >= 0x400000)
