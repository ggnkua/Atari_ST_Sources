/************************************************************************
*************************************************************************
** NOTE:                                                               **
**   This Module is part of the ATARI ST Implementation of Parselst    **
**   It should NOT be used for general reference. Please read the com- **
**   plete Disclaimer either at the TOP of PARSELST.C.                 **
**   Peter Glasmacher at 1:143/9  Ph (408)985-1538                     **
*************************************************************************
*************************************************************************/

/*----------------------------------------------------------------------*
*                              Nodelist Parser                          *
*                                                                       *
*              This module was originally written by Bob Hartman        *
*                       Sysop of FidoNet node 1:132/101                 *
*                                                                       *
* Spark Software, 427-3 Amherst St, CS 2032, Suite 232, Nashua, NH 03061*
*                                                                       *
* This program source code is being released with the following         *
* provisions:                                                           *
*                                                                       *
* 1.  You are  free to make  changes to this source  code for use on    *
*     your own machine,  however,  altered source files may not be      *
*     distributed without the consent of Spark Software.                *
*                                                                       *
* 2.  You may distribute "patches"  or  "diff" files for any changes    *
*     that you have made, provided that the "patch" or "diff" files are *
*     also sent to Spark Software for inclusion in future releases of   *
*     the entire package.   A "diff" file for the source archives may   *
*     also contain a compiled version,  provided it is  clearly marked  *
*     as not  being created  from the original source code.             *
*     No other  executable  versions may be  distributed without  the   *
*     consent of Spark Software.                                        *
*                                                                       *
* 3.  You are free to include portions of this source code in any       *
*     program you develop, providing:  a) Credit is given to Spark      *
*     Software for any code that may is used, and  b) The resulting     *
*     program is free to anyone wanting to use it, including commercial *
*     and government users.                                             *
*                                                                       *
* 4.  There is  NO  technical support  available for dealing with this  *
*     source code, or the accompanying executable files.  This source   *
*     code  is provided as is, with no warranty expressed or implied    *
*     (I hate legalease).   In other words, if you don't know what to   *
*     do with it,  don't use it,  and if you are brave enough to use it,*
*      you're on your own.                                              *
*                                                                       *
* Spark Software may be contacted by modem at (603) 888-8179            *
* (node 1:132/101)                                                      *
* on the public FidoNet network, or at the address given above.         *
*                                                                       *
*-----------------------------------------------------------------------*/

typedef struct SC {
   int zone;
   int net;
   int node;
   char *script;
   struct SC *next;
} SCTR, *SCTRP;

typedef struct PW {
   int zone;
   int net;
   int node;
   char *pw;
   struct PW *next;
} PWTR, *PWTRP;

typedef struct PH {
   int zone;
   int net;
   int node;
   char *num;
   struct PH *next;
} PHTR, *PHTRP;

typedef struct BD {
   int zone;
   int net;
   int node;
   int baud;
   struct BD *next;
} BDTR, *BDTRP;

typedef struct DL {
   char *mstr;
   int mlen;
   char *pre;
   char *post;
   struct DL *next;
} DLTR, *DLTRP;

typedef struct CO {
   char *mstr;
   int mlen;
   int cost;
   int baud;
   struct CO *next;
} COTR, *COTRP;

typedef struct FN {
   char *fname;
   int private;
   struct FN *next;
} FNLST, *FNLSTP;

typedef struct ET {
   int zone;
   int net;
   int node;
   char etype;
   struct ET *next;
} ETTR, *ETTRP;

typedef struct CM {
   int zone;
   int net;
   int node;
   struct CM *next;
} CMTR, *CMTRP;

  struct _oldnode {
    int number;                 /* node number */
    int net;                    /* net number */
    int cost;                   /* cost per minute to call */
    int rate;                   /* baud rate */
    char name[20];                      /* node name */
    char phone[40];                     /* phone number */
    char city[40];                      /* city and state */
   };

  struct _node {
    int  net;               /* net number */
    int  number;           /* node number, */
    int  cost;              /* cost per minute to call */
    char name[34];         /* node name */
    char phone[40];        /* phone number */
    char city[30];         /* city and state, */

    char password[8];      /* warning, not necessarily null terminated */
    int  realcost;            /* phone company's charge */
    int  hubnode;          /* node # of this node's hub or 0 if none */
    char rate;              /* actual baud rate divided by 300 */
    char modem;                  /* modem type code (see below) */
    unsigned int flags1;   /* set of flags (see below) */
    int  reserved;         /* reserved */
   };


/*------------------------------------------------------------------------*/
/* Values for the `flags1' field                                          */
/*------------------------------------------------------------------------*/
#define B_hub      0x0001  /* node is a net hub       0000 0000 0000 0001 */
#define B_host     0x0002  /* node is a net host      0000 0000 0000 0010 */
#define B_region   0x0004  /* node is region coord    0000 0000 0000 0100 */
#define B_zone     0x0008  /* node is a zone coord    0000 0000 0000 1000 */
#define B_CM       0x0010  /* runs continuous mail    0000 0000 0001 0000 */
#define B_ores1    0x0020  /* reserved for Opus       0000 0000 0010 0000 */
#define B_ores2    0x0040  /* reserved for Opus       0000 0000 0100 0000 */
#define B_ores3    0x0080  /* reserved for Opus       0000 0000 1000 0000 */
#define B_ores4    0x0100  /* reserved for Opus       0000 0001 0000 0000 */
#define B_ores5    0x0200  /* reserved for Opus       0000 0010 0000 0000 */
#define B_res1     0x0400  /* reserved for non-Opus   0000 0100 0000 0000 */
#define B_res2     0x0800  /* reserved for non-Opus   0000 1000 0000 0000 */
#define B_res3     0x1000  /* reserved for non-Opus   0001 0000 0000 0000 */
#define B_res4     0x2000  /* reserved for non-Opus   0010 0000 0000 0000 */
#define B_res5     0x4000  /* reserved for non-Opus   0100 0000 0000 0000 */
#define B_res6     0x8000  /* reserved for non-Opus   1000 0000 0000 0000 */

/*------------------------------------------------------------------------*/
/* Values for the `modem' field                                           */
/*------------------------------------------------------------------------*/
#define M_HST      0x01    /* node uses an HST                  0000 0001 */
#define M_PEP      0x02    /* node uses a PEP modem             0000 0001 */

/*--------------------------------------------------------------------------*/
/* Nodelist.Idx                                                             */
/* (File is terminated by EOF)                                              */
/*--------------------------------------------------------------------------*/
struct _ndi {
      int   node;          /* node number  */
      int   net;           /* net number   */
};

/* SEAdog NETLIST.DOG format */
struct netls {
   int netnum;
   char netname[14];
   char netcity[40];
   int havehost;
   int nethost;
   int havegate;
   int netgate;
   long nodeptr;
   int numnodes;
};

/* SEAdog NODELIST.DOG format */
struct nodels {
   int nodenum;
   char nodename[14];
   char nodecity[40];
   char nodephone[40];
   int havehub;
   int nodehub;
   int nodecost;
   int nodebaud;
};

/* SEAdog INDEX.DOG format */
struct nidxs {
   int idxnet;
   int idxnode;
   long netlptr;
   long nodelptr;
   long idxspace;
};

/* Things most nodelists don't contain, but Binkley likes to have */
struct extrastuff {
   char password[8];
   unsigned int flags1;
   char extra[6]; /* for future expansion */
};

/* QuickBBS v2.01 QNL_IDX.BBS format */
struct qidx {
   int zone;
   int net;
   int node;
   char nodetype;
};

/* QuickBBS v2.01 QNL_DAT.BBS format */
struct qdat {
   char nodetype;
   int zone;
   int net;
   int node;
   char namesize;
   char name[20];
   char citysize;
   char city[40];
   char phonesize;
   char phone[40];
   char passwordsize;
   char password[8];
   unsigned int flags;
   int baudrate;
   int cost;
};

/*----------------------------------------------------------------------*
* STarNet Nodelist
*-----------------------------------------------------------------------*/
struct starlist  {
   int type;
   int zone;
   int net;
   int node;
   int rnet;
   int rnode;
   int baud;
   int cost;
   int route;
   char bbsname[50];
   char bbsloc[30];
   char bbsnumber[20];
   char password[10];
   int flags;
   char res1;
   char res2;
   char res3;
   char res4;
};

struct dex  {
   int type;
   int zone;
   int net;
   long position;
   char realloc[30];
   char location[50];
};

/* Used for low-level I/O routines */
typedef struct {
   char far *wbuff;
   char far *wptr;
   unsigned int wsize;
} WBUFFER, *WBUFFPTR;


