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
#define	AD_DMA_ACSI	0x00FF8600L	/* DMA device access */
#define	AD_DMA_SCSI	0x00FF8700L	/* SCSI DMA device address */
#define	AD_SCSI		0x00FF8780L	/* NCR 5380 */
#define	AD_SOUND	0x00FF8800L	/* YM-2149 */
#define	AD_DMA_SOUND	0x00FF8900L	/* SOUND DMA device address */
#define	AD_RTC_NVM	0x00FF8960L	/* MC146818A */
#define	AD_DMA_SCC	0x00FF8C00L	/* SCC DMA device address */
#define	AD_SCC		0x00FF8C80L	/* 8530 SCC */

#define	AD_MFP		0x00FFFA00L	/* 68901 */
#define	AD_ACIA		0x00FFFC00L	/* 2 * 6850 */
