#ifndef H_NODEPROC
#define H_NODEPROC
/*
 * nodeproc.h
 *
 * Definitions for using nodeproc.c
 *
 */

/*--------------------------------------------------------------------------*/
/* NodeList.Sys 															*/
/*																			*/
/*	  NET > 0 and NODE > 0	  Normal node									*/
/*																			*/
/*	  NET > 0 and NODE <= 0   Host node 									*/
/*								 Net host........node== 0					*/
/*								 Regional host...node==-1					*/
/*								 Country host....node==-2					*/
/*																			*/
/*	  NET == -1 	 Nodelist.Sys revision									*/
/*																			*/
/*	  NET == -2 	 Nodelist statement 									*/
/*																			*/
/*--------------------------------------------------------------------------*/


#if 0
/*--------------------------------------------------------------------------*/
/* NODE 																	*/
/* Please note the NewStyle structure (below).	Time is running out for the */
/* existing `_node' structure!	Opus currently uses the old style node		*/
/* structure, but not for long. 											*/
/*--------------------------------------------------------------------------*/
struct _node
{
   WORD number; 								  /* node number								   */
   WORD net;									  /* net number 								   */
   WORD cost;									  /* cost of a message to this
												  * node				*/
   UWORD rate;									  /* baud rate									   */
   char name[20];								 /* node name									  */
   char phone[40];								 /* phone number								  */
   char city[40];								 /* city and state								  */
};
#endif

/*--------------------------------------------------------------------------*/
/* THE NEWSTYLE NODE LIST IS NOW BEING USED BY OPUS 1.10					*/
/*--------------------------------------------------------------------------*/
struct _newnode
{
   word NetNumber;
   word NodeNumber;
   word Cost;									 /* cost to user for a
												  * message */
   byte SystemName[34]; 						 /* node name */
   byte PhoneNumber[40];						 /* phone number */
   byte MiscInfo[30];							 /* city and state */
   byte Password[8];							 /* WARNING: not necessarily
												  * null-terminated */
   word RealCost;								 /* phone company's charge */
   word HubNode;								 /* node # of this node's hub
												  * or 0 if none */
   UBYTE BaudRate;								 /* baud rate divided by 300 */
   byte ModemType;								 /* RESERVED for modem type */
   word NodeFlags;								 /* set of flags (see below) */
   word NodeFiller;
};


/*------------------------------------------------------------------------*/
/* Values for the `NodeFlags' field 									  */
/*------------------------------------------------------------------------*/
#define B_hub	   0x0001
#define B_host	   0x0002
#define B_region   0x0004
#define B_zone	   0x0008
#define B_CrashM   0x0010
#define B_ores1    0x0020
#define B_ores2    0x0040
#define B_ores3    0x0080
#define B_ores4    0x0100
#define B_ores5    0x0200
#define B_res1	   0x0400
#define B_res2	   0x0800
#define B_res3	   0x1000
#define B_res4	   0x2000
#define B_res5	   0x4000
#define B_res6	   0x8000

/*------------------------------------------------------------------------*/
/* Values for the `modem' field 										  */
/*------------------------------------------------------------------------*/
#define M_HST	   0x01    /* node uses an HST					0000 0001 */
#define M_PEP	   0x02    /* node uses a PEP modem 			0000 0010 */


/*--------------------------------------------------------------------------*/
/* Nodelist.Idx 															*/
/* (File is terminated by EOF)												*/
/*--------------------------------------------------------------------------*/

struct _ndi
{
   WORD node;									  /* node number  */
   WORD net;									  /* net number   */
};


#if 0
/*--------------------------------------------------------------------------*/
/* QuickBBS 2.00 QNL_IDX.BBS												*/
/* (File is terminated by EOF)												*/
/*--------------------------------------------------------------------------*/

struct QuickNodeIdxRecord
{
   WORD QI_Zone;
   WORD QI_Net;
   WORD QI_Node;
   byte QI_NodeType;
};


/*--------------------------------------------------------------------------*/
/* QuickBBS 2.00 QNL_DAT.BBS												*/
/* (File is terminated by EOF)												*/
/*--------------------------------------------------------------------------*/

struct QuickNodeListRecord
{
   byte QL_NodeType;
   WORD QL_Zone;
   WORD QL_Net;
   WORD QL_Node;
   byte QL_Name[21];							 /* Pascal! 1 byte count, up
												  * to 20 chars */
   byte QL_City[41];							 /* 1 + 40 */
   byte QL_Phone[41];							 /* 1 + 40 */
   byte QL_Password[9]; 						 /* 1 + 8 */
   word QL_Flags;								 /* Same as flags in new
												  * nodelist structure */
   UWORD QL_BaudRate;
   WORD QL_Cost;
};


/* SEAdog NETLIST.DOG format */
struct netls
{
   WORD netnum;
   char netname[14];
   char netcity[40];
   WORD havehost;
   WORD nethost;
   WORD havegate;
   WORD netgate;
   long nodeptr;
   WORD numnodes;
};

/* SEAdog NODELIST.DOG format */
struct nodels
{
   WORD nodenum;
   char nodename[14];
   char nodecity[40];
   char nodephone[40];
   WORD havehub;
   WORD nodehub;
   WORD nodecost;
   UWORD nodebaud;
};

/* Things most nodelists don't contain, but Binkley likes to have */
struct extrastuff
{
   char password[8];
   UWORD flags1;
   byte modem;
   char extra[5];								 /* for future expansion */
};

#endif

/*
 * BTNC Nodelist structures
 */

typedef struct {
	UBYTE name[13];
	UBYTE listfile[13];
	UWORD zone;
	ULONG startoffset;
	ULONG length;
} DOMAINS_BNL;

typedef struct {
	UBYTE sysname[34];
	UBYTE location[30];
	UBYTE operator[30];
	UBYTE phone[40];
	UWORD hubnode;
	BYTE maxbaud;
	WORD modemtype;
	UWORD flags;
} NODEINFO_BNL;

typedef struct {
	BYTE type;
	UWORD value;
} INDEX_BNL;

#define BNL_ZONECOORD 6
#define BNL_REGCOORD  5
#define BNL_NETCOORD  4
#define BNL_HUB 	  3
#define BNL_NODE	  2
#define BNL_POINT	  1

#define BNL_HST    1
#define BNL_PEP    2
#define BNL_MNP    4
#define BNL_V32    8
#define BNL_V32B  16
#define BNL_V42   32
#define BNL_V42B  64
#define BNL_MAX  128

#define MAILONLY			  1U	/* no MailBox behind mailer */
#define CONTINUOUSMAIL		  2U	/* Crashmail capable */
#define NOARCMAIL			  4U	/* no arcmail supported */
#define UNDIALABLE			  8U	/* should be set by bink */
#define BARK_REQUEST		 16U
#define BARK_UPDATEREQUEST	 32U
#define WAZOO_REQUEST		 64U
#define WAZOO_UPDATEREQUEST 128U
#define PRIVATE 			256U	/* redirect to hub/host */
#define HOLD				512U

/*
 * Enumerated type for nodelists
 */

typedef enum {
	VERSION6,
	BTNC,
	LASTNODELIST
} NODELISTTYPE;

#define B_CM CONTINUOUSMAIL			/* Used by rest of program */

/*---------------------------------------------------------------------
 * Variables
 */

extern NODELISTTYPE nodeListType;				/* Type of nodelist */
extern unsigned int cacheSize;					/* Size of nodelist cache */

extern char *node_prefix;
extern int autobaud;
extern int found_zone;							 /* zone we found			  */
extern int found_net;							 /* zone we found			  */
extern struct _newnode newnodedes;				 /* structure in new list	  */
extern char far *node_index;

/*-----------------------------------------------------------------------
 * Functions
 */

void lock_nodelist(BOOLEAN flag);
int nodefind (ADDR *, int);
int checklist (void);
int nodeproc (char *);
long cost_of_call (long, long);

#endif
