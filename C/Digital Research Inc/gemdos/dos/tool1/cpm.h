/***************************************************************************
 *									    
 *				   C P M . H
 *				   -----------				    
 *	Copyright 1982,1983 by Digital Research Inc. All rights reserved.   
 *									    
 *	Edits:								    
 *	4-Apr-85 bv	Created from OSIF.h to get channels stuff for CPM
 *									    
 ****************************************************************************/

			/*** Operating System ***/
#undef CPM
#define CPM	1

			/*** Compiler ***/
#define ALCYON	1	/* Alcyon C Compiler */



/****************************************************************************
 *	CP/M FCB definition
 ****************************************************************************/
struct	fcbtab					/****************************/
{						/*			    */
	BYTE	drive;				/* Disk drive field [0]	    */
	BYTE	fname[8];			/* File name [1-8]	    */
	BYTE	ftype[3];			/* File type [9-11]	    */
	BYTE	extent;				/* Current extent number[12]*/
	BYTE	s1,s2;				/* "system reserved" [13-14]*/
	BYTE	reccnt;				/* Record counter [15]	    */
	BYTE	fpasswd[8];			/* Parsefn passwd area[16-23]*/
	BYTE	fuser;				/* Parsefn user# area [24]  */
	BYTE	resvd[7];			/* More "system reserved"   */
	LONG	record;				/* Note -- we overlap [32-36]*/
						/* current record field to  */
						/* make this useful.	    */
};						/****************************/
						/*			    */
#define SECSIZ		128			/* size of CP/M sector	    */
						/*   to obtain nsecs on err */
						/****************************/

/***************************************************************************
 *									    
 *	Channel Control Block (CCB)					    
 *									    
 *	One CCB is allocated (statically) for each of the 16 possible open  
 *	files under C (including STDIN, STDOUT, STDERR).  Permanent data    
 *	regarding the channel is kept here.				    
 *									    
 *									    
 ****************************************************************************/

struct	ccb				/************************************/
{					/*				    */
	WORD	flags;			/*sw	Flags byte		    */
	BYTE	user;			/*sw	User #			    */
	BYTE	chan;			/*	Channel number being used   */
	LONG	offset;			/*	File offset word (bytes)    */
	LONG	sector;			/* 	Sector currently in buffer  */
	LONG	hiwater;		/*	High water mark		    */
	struct fcbtab fcb;		/*	File FCB (may have TTY info)*/
	BYTE	buffer[SECSIZ];		/*	Read/write buffer	    */
};					/************************************/

extern	struct	ccb	_fds[]; /*  */	/*	Declare storage		    */
#define FD struct ccb			/*	FD Type definition	    */
#define NULLFD ((FD *)0)		/*	NULLPTR for FD		    */
					/************************************/
/*	Flags word bit definitions					    */
					/************************************/
#define	OPENED	0x01			/*	Channel is OPEN		    */
#define	ISTTY	0x02			/*	Channel open to TTT	    */
#define	ISLPT	0x04			/*	Channel open to LPT	    */
#define	ISREAD	0x08			/*	Channel open readonly	    */
#define	ISASCII	0x10			/*	ASCII file attached	    */
#define	ATEOF	0x20			/*	End of file encountered	    */
#define DIRTY	0x40			/*	Buffer needs writing	    */
#define ISSPTTY	0x80			/*	Special tty info	    */
#define	ISAUX	0x100			/*sw	Auxiliary device	    */
#define ISQUE	0x0200			/*whf	Queue device		    */

#define STDIN	0
#define STDOUT	1
#define STDERR	2
