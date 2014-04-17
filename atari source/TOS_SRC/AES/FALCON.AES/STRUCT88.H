/*
*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/struct88.h,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:30:56 $	$Locker: kbad $
* =======================================================================
*  $Log:	struct88.h,v $
* Revision 2.2  89/04/26  18:30:56  mui
* TT
* 
* Revision 2.1  89/02/22  05:32:26  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:36:26  lozben
* Initial revision
* 
*************************************************************************
*/
/*	STRUCT88.H	1/28/84 - 01/18/85	Lee Jay Lorenzen	*/
/*	for atari	03/20/85 - 5/08/85	Lowell Webster		*/
/*	Document EVB	02/19/88		D.Mui			*/
/*	More PD definitions	07/13/90	D.Mui			*/
/*	Increase number of NFORKS	8/17/92	D.Mui			*/

/*
*	-------------------------------------------------------------
*	GEM Application Environment Services		  Version 1.0
*	Serial No.  XXXX-0000-654321		  All Rights Reserved
*	Copyright (C) 1985			Digital Research Inc.
*	-------------------------------------------------------------
*/

#define PD	struct pd		/* process descriptor		*/
#define UDA	struct uda		/* user stack data area		*/
#define UDA2	struct uda2		/* user stack data area		*/
#define UDA3	struct uda3		/* user stack data area		*/
#define CDA	struct cdastr		/* console data area structure	*/
#define QPB	struct qpb		/* queue parameter block	*/
#define EVB 	struct evb		/* event block 			*/
#define CQUEUE	struct cqueue		/* console kbd queue		*/
#define MFORM	struct mform		/* mouse form			*/
#define SPB	struct spb		/* sync parameter block 	*/
#define FPD	struct fpd		/* fork process descriptor 	*/

typedef UWORD	EVSPEC;

#define NUM_ACCS 1			/* for atari in rom		*/
#define NUM_PDS (NUM_ACCS + 2)		/* acc's + ctrlpd + dos appl.	*/
#define NUM_EVBS (NUM_PDS * 5)		/* 5 * the number of PDs	*/
#define MAX_ACCS 6			/* for atari, from disk		*/
#define EVB_PROC 5			/* for atari, number of EVB per process */

#define KBD_SIZE 8
#define QUEUE_SIZE 256
#define NFORKS 96

CQUEUE
{
	WORD	c_buff[KBD_SIZE];
	WORD	c_front;
	WORD	c_rear;
	WORD	c_cnt;
};


MFORM
{
	WORD	mf_xhot;
	WORD	mf_yhot;
	WORD	mf_nplanes;
	WORD	mf_fg;
	WORD	mf_bg;
	WORD	mf_mask[16];
	WORD	mf_data[16];
} ;


#define C_KOWNER 0x0001
#define C_MOWNER 0x0002

CDA
{
	UWORD	c_flags;
	EVB	*c_iiowait;	/* Waiting for Input		*/
	EVB	*c_msleep;	/* wait for mouse rect		*/
	EVB	*c_bsleep;	/* wait for button		*/
	CQUEUE	c_q;		/* input queue 			*/
};


#define STACK1_SIZE 500
#define STACK2_SIZE 500
#define STACK3_SIZE 500

UDA
{
	WORD	u_insuper;		/* in supervisor flag		*/ 
	ULONG	u_regs[15];		/* d0-d7, a0-a6			*/
	ULONG	*u_spsuper;		/* supervisor stack 		*/
	ULONG	*u_spuser;		/* user stack 			*/
	ULONG	u_super[STACK1_SIZE];
	ULONG	u_supstk;
};

UDA2
{
	WORD	u_insuper;		/* in supervisor flag		*/ 
	ULONG	u_regs[15];		/* d0-d7, a0-a6			*/
	ULONG	*u_spsuper;		/* supervisor stack 		*/
	ULONG	*u_spuser;		/* user stack 			*/
	ULONG	u_super[STACK2_SIZE];
	ULONG	u_supstk;
};

UDA3
{
	WORD	u_insuper;		/* in supervisor flag		*/ 
	ULONG	u_regs[15];		/* d0-d7, a0-a6			*/
	ULONG	*u_spsuper;		/* supervisor stack 		*/
	ULONG	*u_spuser;		/* user stack 			*/
	ULONG	u_super[STACK3_SIZE];
	ULONG	u_supstk;
};


#define NOCANCEL 0x0001		/* event is occuring 	*/
#define COMPLETE 0x0002		/* event completed 	*/
#define EVDELAY  0x0004		/* event is delay event */
#define EVMOUT   0x0008		/* event flag for mouse wait outside of rect*/

EVB		/* event block structure */
{
	EVB	*e_nextp;	/* link to next EVB on PD event list	*/
	EVB	*e_link;	/* link to next EVB on CDA event chain	*/
	EVB	*e_pred;	/* link to prev EVB on CDA event chain	*/
	BYTE	*e_pd;		/* owner PD (data for fork)		*/
	LONG	e_parm;		/* parameter for request event		*/
	WORD	e_flag;		/* look to above defines		*/
	EVSPEC	e_mask;		/* mask for event notification		*/
	LONG	e_return;	/* e_mask correspond to p_evbits	*/ 
};				/* e_return return number of clicks	*/
				/* character or button state		*/

				/* in the case of mouse rectangle, 	*/
				/* e_parm and e_return has the MBOLK	*/



/* pd defines */

#define		PS_RUN		1	/* p_stat */
#define		PS_MWAIT	2
#define		PS_TRYSUSPEND	4
#define		PS_TOSUSPEND	8
#define		PS_SUSPENDED	16

PD 
{
	PD	*p_link;	/* link to other process	*/
	PD	*p_thread;	/* I don't think it is used	*/
	UDA	*p_uda;		/* store the machine's status	*/

	BYTE	p_name[8];	/* processor name		*/

	CDA	*p_cda;		/* Tells what we are waiting 	*/
	LONG	p_ldaddr;	/* long address of load		*/
	WORD 	p_pid;		/* process id number		*/
	WORD	p_stat;		/* PS_RUN or PS_MWAIT		*/

	EVSPEC	p_evbits;	/* event bits in use 8 max EVB	*/
	EVSPEC	p_evwait;	/* event wait mask 		*/
	EVSPEC	p_evflg;	/* EVB that satisified		*/
	WORD	p_message[10];
	MFORM	p_mouse;
	EVB	*p_evlist;	/* link to EVB			*/
	EVB	*p_qdq;
	EVB	*p_qnq;
	LONG	p_qaddr;	/* message queue pointer	*/
	WORD	p_qindex;	/* message queue index		*/
	BYTE	p_queue[QUEUE_SIZE];
};



QPB
{
	WORD	qpb_pid;
	WORD	qpb_cnt;
	LONG	qpb_buf;
};


SPB				/* AMUTEX control block	*/
{
	WORD	sy_tas;		/* semaphore				*/
	PD	*sy_owner;	/* owner's PD address			*/
	EVB	*sy_wait;	/* EVB that is waiting for the screen	*/
};


FPD
{
	WORD	(*f_code)();
	LONG	f_data;
};


#define ACCPD struct accpd
ACCPD
{
	PD	ac_pd;
	UDA	ac_uda;
	CDA	ac_cda;
	EVB	ac_evb[EVB_PROC];	/* 5 evb's per process		*/
};

#define NOT_FOUND 100	 /* try to return from event not on PD list */
#define NOT_COMPLETE 101 /* try to ret from event which has not occured */

						/* async bdos calls */
#define AQRD 1
#define AQWRT 2
#define ADELAY 3
#define AMUTEX 4
#define AKBIN 5
#define AMOUSE 6
#define ABUTTON 7
