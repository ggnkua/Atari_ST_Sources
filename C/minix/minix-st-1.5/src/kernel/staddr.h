/*
 * Atari ST hardware:
 * Address map
 */

#define	AD_RAM		0x00000000L	/* main memory */
#define	AD_CART		0x00FA0000L	/* expansion cartridge */
#define	AD_ROM		0x00FC0000L	/* system ROM */
#define	AD_IO		0x00FF8000L	/* I/O devices */

/*
 * I/O address parts of 0x000200 each
 */
#define	AD_RAMCFG	0x00FF8000L	/* ram configuration */
#define	AD_VIDEO	0x00FF8200L	/* video controller */
/*	AD_RESERVED	0x00FF8400L	/* reserved */
#define	AD_DMA		0x00FF8600L	/* DMA device access */
#define	AD_SOUND	0x00FF8800L	/* YM-2149 */

#define	AD_MFP		0x00FFFA00L	/* 68901 */
#define	AD_ACIA		0x00FFFC00L	/* 2 * 6850 */
