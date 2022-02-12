/*
 * Atari ST hardware:
 * DMA circuitry
 */

#define	SCSIDMA	((struct scsidma *)AD_DMA_SCSI)

struct scsidma {
    /* for dma_addr and dma_byte_cnt use only the odd bytes */
    _VOLATILE unsigned char	dma_addr[8];	/* base address U/UM/LM/L */
    _VOLATILE unsigned char	dma_byte_cnt[8];/* byte count U/UM/LM/L */
    _VOLATILE unsigned char	data_residue[4];/* data residue register */
    _VOLATILE unsigned char	dma_gap;	/* gap */
    _VOLATILE unsigned char	dma_control;	/* control register */
};

#ifndef SCCDMA
/*
 * control register bits
 */
#define DIR	0x0001		/* DMA direction; 0 is in from port, 1 is out */
#define	ENABLE	0x0002		/* 0: dma disable; 1: dma enable */
/*		0x0004		   unused, must be 0 */
/*		0x0008		   unused, must be 0 */
/*		0x0010		   unused, must be 0 */
/*		0x0020		   unused, must be 0 */
#define	CNT0	0x0040		/* byte count zero; read only, clred by read */
#define	BERR	0x0080		/* bus error during dma; rd only, clred by rd */

/*
 * Indices into dma_addr and dma_byte_cnt
 * Access low byte of 16 bits.
 * Fill low/low-mid/up-mid/up in this order.
 */
#define	AD_UP		1
#define	AD_UP_MID	3
#define	AD_LOW_MID	5
#define	AD_LOW		7
#endif
