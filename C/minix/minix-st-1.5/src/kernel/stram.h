/*
 * Atari ST hardware:
 * RAM configuration register
 */

#define	RAMCFG	((struct ramcfg *)AD_RAMCFG)

struct ramcfg {
	unsigned char	rc_gap;
	unsigned char	rc_ram;
};

/*
 * rc_ram contains 0000xxyy where both xx and yy can be
 *	00:  128k
 *	01:  512k
 *	10: 2048k
 *	11: reserved
 * xx for bank0 starting at 0x000000, yy for bank1 contiguous to bank0
 *
 * the available ram can be calculated with the following piece of code:
 *
 *	char k128[16] = {
 *		 1 +  1,  1 +  4,  1 + 16,  0,
 *		 4 +  1,  4 +  4,  4 + 16,  0,
 *		16 +  1, 16 +  4, 16 + 16,  0,
 *		 0     ,  0     ,  0     ,  0,
 *	};
 *
 *	nbytes = 0x20000 * k128[RAMCFG->rc_ram & 0x0F];
 */
