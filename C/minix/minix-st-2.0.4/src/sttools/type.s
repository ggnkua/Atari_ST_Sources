#ifdef boot_fd
#define	BOOT
#define	type_fd
#endif
#ifdef boot_dd
#define	BOOT
#define	type_dd
#endif

#ifndef type_dd
#ifndef type_fd
#define	type_fd
#endif
#endif

#ifdef ACK
	.sect	.text
	.sect	.rom
	.sect	.data
	.sect	.bss
#endif

	.sect	.text
start:
#ifdef BOOT
	bra	boot		! 000: jump to loader
#else
	rts			! 000: do not boot
#endif
	.ascii	"MINIX "	! 002: 6 byte identification
	.data1	0,0,0		! 008: volume serial
	.data1	0,2		! 00B: 512 bytes/sector (low byte first)
	.data1	2		! 00D: 2 sectors/cluster
	.data1	1,0		! 00E: reserved sector (low byte first)
	.data1	2		! 010: number of FATS
	.data1	112,0		! 011: number of dirs (low byte first)
#ifdef type_fd
	.data1	208,2		! 013: 720 sectors (low byte first)
 	.data1	248		! 015: media descriptor (80 track SS)
#endif
#ifdef type_dd
	.data1	160,5		! 013: 1440 sectors (low byte first)
	.data1	249		! 015: media descriptor (80 track DS)
#endif
	.data1	5,0		! 016: sectors/FAT (low byte first)
	.data1	9,0		! 018: sectors/track (low byte first)
#ifdef type_fd
	.data1	1,0		! 01A: number of sides (low byte first)
#endif
#ifdef type_dd
	.data1	2,0		! 01A: number of sides (low byte first)
#endif
	.data1	0,0		! 01C: hidden sectors (low byte first)
