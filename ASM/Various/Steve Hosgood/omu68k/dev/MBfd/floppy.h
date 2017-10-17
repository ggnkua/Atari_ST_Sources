/* ################ CPM-68k ################
 * floppy.h
 * +++++++++++++++++++++++++++++++++++++++++
 *
 *	definitions for the 5.25" floppy interface
 *	on the eltec vme kits
 *	using the mitsubishi disc drive
 */


struct fdc	{
	char	null2;
	char	csr;
	char	null3;
	char	track;
	char	null4;
	char	sector;
	char	null5;
	char	data;
	char	null1;
	char	bits;
};


#define		END_TRACK	(0x4f)
#define		ON		1
#define		OFF		0
#define		FDC_PORT	((struct fdc*) 0xFA0008)
#define		STEP_RATE	(0x00)		/* 3 ms step rate */
#define		IN		STEP_IN
#define		OUT		STEP_OUT
#define		NO_CHANGE	STEP
#define		DELAY_TIME	60	/* used by forcintr (16us delay) */

/*
 *	Single density def's
 */

#define		SD_LENGTH_SECT	128
#define		SD_TRACK_LENGTH	3200	/* no of bytes in track */
#define		SD_NUM_SECT	16
#define		SD_TYPE_SECT	0

/*
 *	Double density def's
 */

#define		DD_LENGTH_SECT	512
#define		DD_TRACK_LENGTH	6400	/* no of bytes in track */
#define		DD_NUM_SECT	10
#define		DD_TYPE_SECT	02

/*
 *	Now for the data for formatting
 */

#define		PR_CRCFM	(0xf8)
#define		PR_CRCMFM	(0xf5)
#define		CRC		(0xf7)
#define		INDEX		(0xfc)
#define		ID_ADDR		(0xfe)
#define		DATA_ADDR	(0xfb)
#define		PRE_INDEX	(0xf6)
#define		PRE_MARK	(0xf5)
#define		NULL		(0)
#define		FILL_FM		(0xff)
#define		FILL_MFM	(0x4e)
#define		FMT_DATA	(0xe5)


/*
 *	The following are application dependant
 *	The 1793 has positive logic data bus
 *	 ie TRUE = logic 1
 */


/*
 *	Control bits in the fdc_bits register
 */


/*
 *	WRITE ONLY BITS
 */

#define DRIVE_0		(0x01)
#define	DRIVE_1		(0x02)
#define	DRIVE_2		(0x04)
#define	DRIVE_3		(0x08)
#define	NONE		(0x00)
#define	FIVE_SEL	(0x40)
#define	SDEN		(0x80)
#define	SIDE_ZERO	(0x00)
#define	SIDE_ONE	(0x10)
#define	MOTOR_ON	(0x20)

#define MOTORTIME	500000
#define TIMEOUT		100000

/*
 *	READ ONLY
 */

#define	DISK_CHANGED	(0x01)
#define	TWO_SIDED	(0x02)
#define	DATA_REQ	(0x20)
#define	INT_REQ		(0x10)


/*
 *	Struct used in formatting to contain
 *	the pointers to the headers of all 
 *	the sectors in a track
 */

#define		TRACK		0
#define		SIDE		1
#define		SECTOR		2
#define		TYPE		3


struct	hdrs_dd{
	char	*sects_dd[DD_NUM_SECT];
};

struct	hdrs_sd{
	char	*sects_sd[SD_NUM_SECT];
};


#define	DD_8		0
#define	DD_5		1
#define	SD_8		2
#define	SD_5		3

/* ################ CPM-68k ################
 * 1793.h
 * +++++++++++++++++++++++++++++++++++++++++
 *
 *	Western Digital FD179X Series Floppy Disk Controller
 *		- Command and Status information
 */



/*
 *	Command sub-fields
 */

#define	LOAD_HEAD	(0x08)
#define	VERIFY		(0x04)
#define	RATE_BITS	(0x03)
#define	UPDATE_TRACK	(0x10)
#define	MULTI_RECORD	(0x10)
#define	SIDE_1		(0x08)
#define	DELAY_15	(0x04)
#define	COMPARE_SIDE	(0x02)
#define	DELETED_DATA	(0x01)


/*
 *	interrupting conditions
 *	for the force interrupt cmnd
 */

#define	ON_READY	(0x01)
#define	ON_NOTREADY	(0x02)
#define	INT_PULSE	(0x04)
#define	IMMEDIATE	(0x08)
#define	TERMINATE	(0x00)


#define	STEP_3ms	0
#define	STEP_6ms	1
#define	STEP_10ms	2
#define	STEP_15ms	3

#define	NO_FLAGS	(0)



/*
 *	Type I Commands			Sub-fields
 */

#define	RESTORE		(0x00)	/* LOAD_HEAD,VERIFY,RATE_BITS */
#define	SEEK		(0x10)	/* LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP		(0x20)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP_IN		(0x40)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP_OUT	(0x60)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */

/*
 *	Type II Commands
 */

#define	READSECTOR	(0x80)	/* MULTI_RECORD,SIDE_1,DELAY_15,COMPARE_SIDE */
#define	WRITESECTOR	(0xA0)	/* M/RECD,SIDE_1,DELAY_15,COM/SIDE,DEL/DATA  */

/*
 *	Type III Commands
 */

#define	READADDRESS	(0xC0)	/* DELAY_3ms */
#define	READTRACK	(0xE0)	/* DELAY_3ms */
#define	WRITETRACK	(0xF0)	/* DELAY_3ms */

/*
 *	Type IV Command
 */

#define	FORCEINTERRUPT	(0xD0)	/* TERMINATE, or			      */
				/* ON_READY,ON_NOTREADY,INDEX_PULSE,IMMEDIATE */



/*
 *	Status Register bits
 */

#define	BUSY		(0x01)
#define	INDEX_PULSE	(0x02)	/* Type I commands */
#define	DRQ		(0x02)	/* Type II commands */
#define TR00		(0x04)	/* Type I commands */
#define	LOST_DATA	(0x04)	/* Type II commands */
#define	CRC_ERROR	(0x08)	
#define	SEEK_ERROR	(0x10)	/* Type I commands */
#define	REC_NOT_FOUND	(0x10)	/* Type II commands */
#define	HEAD_LOADED	(0x20)	/* Type I commands */
#define	DEL_DATA_MARK	(0x20)	/* Type II commands */
#define	WR_PROT		(0x40)
#define	NOT_RDY		(0x80)

#define WRITE_ERR	(0x7C)
#define READ_ERR	(0x1C)
#define SK_ERR		(0x18)

/* For Steves bit
 */

struct id {
	char    id_trk;
	char    id_side;
	char    id_sector;
	char    id_len;
	char    id_crc1;
	char    id_crc2;
};

#define		FDC	((struct fdc*) 0xFA0008)
#define		SECTLENGTH	512
