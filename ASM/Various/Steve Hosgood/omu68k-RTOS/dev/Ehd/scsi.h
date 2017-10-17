/*******************************************************************************
 *	Scsi.h	SCSI interface headers
 *******************************************************************************
 */

/*
 *	Scsi data control block Class 0 comands
 */
struct	Sidcb {
	char	opcode;
	char	hiblock;
	char	miblock;
	char	loblock;
	char	noblocks;
	char	control;
};

/*
 *	Scsi data control block Class 1 comands
 */
struct	Sidcb1 {
	char	opcode;
	short	none;
	char	hiblock;
	char	miblock;
	char	loblock;
	char	none1;
	char	hnoblocks;
	char	lnoblocks;
	char	control;
};

/*
 *	Scsi commands
 */
# define	SICLASS(a)	(((a) >> 5) & 0x3) /* Scsi opcode class */
# define	SICMDMASK(a)	((a) & 0xFF)	/* Scsi opcode */
# define	SITEST_RDY	0	/* Test unit ready */
# define	SIREZERO	1	/* Rezero unit */
# define	SIREQSENSE	3	/* Request sense */
# define	SIFORMAT	4
# define	SIREASSIGNBLKS	7
# define	SIREAD		8
# define	SIWRITE		0x0A
# define	SISEEK		0x0B
# define	SIREADUSAGE	0x11
# define	SIINQUIRY	0x12
# define	SIM_SELECT	0x15
# define	SIRESERVE	0x16
# define	SIRELEASE	0x17
# define	SIM_SENSE	0x1A
# define	SISTART_STOP	0x1B
# define	SIREC_DIAG	0x1C
# define	SISEND_DIAG	0x1D
# define	SIREAD_CAP	0x25
# define	SIREADBIG	0x28
# define	SIWRITEBIG	0x2A
# define	SIREAD_DEFECT	0x37
# define	SICERTIFY	0xE2

/*	SCSI Sense errors */
struct	Sierr {
	char	logadd;
	char	none0;
	char	sensekey;
	char	hiblk;
	char	mhiblk;
	char	mlblk;
	char	loblk;
	char	none1[5];
	char	errcode;
	char	none2[5];
};

/*	IOCTL command structure */
struct	Siioctl {
	struct	Sidcb dcb;		/* Comand to scsi */
	char	*data;			/* Pointer to data area */
};

/*	IOCTL command structure Class 1 commands */
struct	Siioctl1 {
	struct	Sidcb1 dcb;		/* Comand to scsi */
	char	*data;			/* Pointer to data area */
};

struct	Sicap {
	long	lblock;
	long	blocklen;
};

/*	SCSI errors */
# define	SCSI_SELTIMEOUT	250000	/* Scsi SEL timeout 0.25 secs Approx */
# define	SCSI_HSTIMEOUT	50000	/* Scsi Hand shake timeout */
# define	SIERR_BUSY	1	/* SCSI BUSY timeout */
# define	SIERR_NDEV	2	/* No device with the given ID */
# define	SIERR_NTX	3	/* No request on tx timeout */
# define	SIERR_NRX	4	/* No request on rx timeout */
