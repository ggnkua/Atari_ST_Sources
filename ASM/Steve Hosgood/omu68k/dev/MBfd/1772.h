/*******************************************************************************
 *	1772.h
 *******************************************************************************
 *
 *	definitions for the 1772 chip on the Micro-box computer
 */

#define		DELAY_TIME	60	/* used by forcintr (16us delay) */
#define		MOTORTIME	500000
#define		TIMEOUT		100000
#define		SECTLENGTH	512

struct Fdc{
	char	null2;
	char	csr;
	char	null3;
	char	track;
	char	null4;
	char	sector;
	char	null5;
	char	data;
};

/*
 *	Western Digital FD1772 Series Floppy Disk Controller
 *		- Command and Status information
 */

/*
 *	Command sub-fields
 */
	/*Type I */
#define INH_MOTOR	(0x08)
#define	EN_MOTOR	0
#define	VERIFY		(0x04)
#define	RATE_BITS	(0x03)
#define	UPDATE_TRACK	(0x10)

	/* Type II & III */
#define	MULTI_RECORD	(0x10)
#define	WR_NOCOMP	(0x02)
#define	DELAY_30	(0x04)
#define	DELETED_DATA	(0x01)

	/* Type IV */
#define INT_PULSE	(0x04)
#define IMMEDIATE	(0x08)
#define TERMINATE	(0x00)

#define STEP_2ms	0
#define STEP_3ms	1
#define STEP_5ms	2
#define STEP_6ms	3

#define NO_FLAGS	(0)


/*
 *	Type I Commands			Sub-fields
 */

#define	RESTORE		(0x00)	/* LOAD_HEAD,VERIFY,RATE_BITS */
#define	SEEK		(0x10)	/* LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP		(0x30)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP_IN		(0x50)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */
#define	STEP_OUT	(0x70)	/* UPDATE_TRACK,LOAD_HEAD,VERIFY,RATE_BITS */

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
#define	MOTOR_SPIN	(0x20)	/* Type I commands */
#define	DEL_DATA_MARK	(0x20)	/* Type II commands */
#define	WR_PROT		(0x40)
#define	NOT_RDY		(0x80)

#define WRITE_ERR	(0x5C)
#define READ_ERR	(0x1C)

#define ONE_ERR		(REC_NOT_FOUND)
