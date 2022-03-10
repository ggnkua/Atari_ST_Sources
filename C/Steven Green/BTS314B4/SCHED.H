#ifndef H_SCHED
#define H_SCHED
/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*               Scheduler definitions used in BinkleyTerm                  */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*--------------------------------------------------------------------------*/


/* Definitions for day of the week */
#define DAY_SUNDAY      0x01
#define DAY_MONDAY      0x02
#define DAY_TUESDAY     0x04
#define DAY_WEDNESDAY   0x08
#define DAY_THURSDAY    0x10
#define DAY_FRIDAY      0x20
#define DAY_SATURDAY    0x40
#define DAY_UNUSED      0x80

#define DAY_WEEK  (DAY_MONDAY|DAY_TUESDAY|DAY_WEDNESDAY|DAY_THURSDAY|DAY_FRIDAY)
#define DAY_WKEND (DAY_SUNDAY|DAY_SATURDAY)

/* Definitions for matrix behavior */
#define MAT_CM          0x0001
#define MAT_DYNAM       0x0002
#define MAT_BBS         0x0004
#define MAT_NOREQ       0x0008
#define MAT_OUTONLY     0x0010
#define MAT_NOOUT       0x0020
#define MAT_FORCED      0x0040
#define MAT_LOCAL       0x0080
#define MAT_SKIP        0x0100
#define MAT_NOMAIL24    0x0200
#define MAT_NOOUTREQ    0x0400
#define MAT_NOCM        0x0800
#ifdef NEW
#define MAT_KILLBAD     0x1000		/* Kill *.$$? packets */
#else
#define MAT_RESERVED1   0x1000
#endif
#define MAT_RESERVED2   0x2000
#define MAT_RESERVED3   0x4000
#define MAT_RESERVED4   0x8000

/*********************************************************************
* If either of these structures are changed, don't forget to change  *
* the BinkSched string in sched.c, as well as the routines that read *
* and write the schedule file (read_sched, write_sched)!!!           *
*********************************************************************/
typedef struct _event
{
   short days;				/* Bit field for which days to execute */
   short minute;			/* Minutes after midnight to start event */
   short length;			/* Number of minutes event runs */
   short errlevel[9];		/* Errorlevel exits */
   short last_ran;			/* Day of month last ran */
   short behavior;			/* Behavior mask */
   short wait_time;			/* Average number of seconds to wait between dials */
   short with_connect;		/* Number of calls to make with carrier */
   short no_connect;		/* Number of calls to make without carrier */
   short node_cost;			/* Maximum cost node to call during this event */
   char call_slot[33];		/* Mask to define Pollslots in conjunction with the keys statment */
   char cmd[32];			/* Chars to append to packer, aftermail and cleanup */
   char month;				/* Month when to do it   */
   char day;				/* Day of month to do it */
   char err_extent[6][4];	/* 3 byte extensions for errorlevels 4-9 */
   short extra[1];			/* Extra space for later */
} BTEVENT;

typedef struct _history
{
   short which_day;                       /* Day number for this record */
   short bbs_calls;                       /* Number of BBS callers */
   short mail_calls;                      /* Number of mail calls */
   short calls_made;                      /* Number of outgoing calls made */
   short connects;                        /* Number of outbound call successes */
   short files_in;                        /* Number of files received */
   short files_out;                       /* Number of files sent */
   short last_caller;                     /* Type of last call */
   short last_zone;                       /* Zone number of last call */
   short last_net;                        /* Net  number of last call */
   short last_node;                       /* Node number of last call */
   short last_point;					/* Point of last call */
   char last_Domain[32];				/* Domain of last call */
   long last_Elapsed;					/* Time of last outbound session */
   short next_zone;                       /* Zone number of next call */
   short next_net;                        /* Net  number of next call */
   short next_node;                       /* Node number of next call */
   short next_point;					/* Point of next call */
   char next_Domain[32];				/* Domain of next call */
   long callcost;                       /* Cumulative of call costs */
   short extmails;						/* Number of external mailer calls */	
} HISTORY;

extern HISTORY hist;
extern BTEVENT *e_ptrs[];


#endif	/* H_SCHED */
