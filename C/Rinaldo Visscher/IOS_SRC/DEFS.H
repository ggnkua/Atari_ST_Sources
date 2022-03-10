#if !defined (__DEFS_H__)
#define __DEFS_H__

/*
/*#define BETAVERSION		1*/
*/

/*
**	Filenames
*/

#define	CONFIGFILE	"IOSMAIL.CFG"
#define CONFIGBIN	"IOSMAIL.BIN"
#define	HISTORYFILE	"IOSMAIL.HIS"
#define	HISTORYDUP	"IOSMAIL.DUP"
#define	KEYFILE		"IOSMAIL.KEY"
#define	AREAFILE	"AREAS.BBS"
#define	DAREAFILE	"DAREAS.BBS"
#define LANG_FILE	"IOSMAIL.LNG"
#define PRD_FILE	"IOSMAIL.PRD"
#define BIN_AREAS	"AREAS.BIN"
#define DUPESFILE	"IOSDUPES.LOG"

/*
**	Version numbers.
*/

#define V_IOSMAIL	"IOSmail 0.89a m5D"
#define V_INMAIL	"InMail 0.77"
#define V_OUTMAIL	"OutMail 0.70"
#define V_SCANMAIL	"ScanMail 0.70"
#define V_CONSULTANT "IOS areaconsultant"

/*
**	Status output
*/

#define S_ALL		0
#define S_AREA		1
#define S_IMP		2
#define S_EXP		3
#define S_SYSOP		4
#define S_NETMAIL	5
#define S_DELETED	6
#define S_FROM		7
#define S_DEST		8
#define S_COMMENT	9
#define S_TRASH		10

#define S_START		7	/*	Einde van statusline	*/

/*
**	Multitaskers
*/

#define NOTASK		0
#define MULTIGEM	1
#define MINT		2
#define MULTITOS	3

/*
**	Debug switches
*/

#if defined BETAVERSION

/*#define DEBUG		1	*/

#define EXTERNDEBUG	1		/* Inmail & scanmail debug			*/
#define OUTDEBUG	1		/* Outmail debug					*/

#endif

#define	PATCHLEVEL	"2"

/*
**	Product code
*/

#define	IOSPRDCODE		(UBYTE) 0xB0	/*	own PRDcode			*/
#define IOSPKTVERS		(UBYTE) 0x58	/*	Revision Version	*/
#define IOSMINOR		(UBYTE)	0x00	/*	Revision Minor		*/
#define TOSSCANPRD		(UBYTE) 0x3f	/*	TosScan				*/
 
/*
** Version number
*/

#define G_VERSION		"IOSmail 0.88bta"

/*
**	Packet Types
*/

#define	STONEAGE		0
#define	TYPE2PLUS	1
#define	TYPE2_2		2
#define	TYPE3			3

/*
**	Defines for message header flags
*/

#define	PRIVATE			0x0001	/* Flag private bit				*/
#define CRASH			0x0002	/* Mail: crash message			*/
#define RECEIVED		0x0004	/* Flag received bit			*/
#define SENT			0x0008	/* Mail: msg has been sent		*/
#define FILEATCH		0x0010	/*       msg has file attached	*/
#define MSGFWD			0x0020	/*       msg has been send		*/
#define ORPHAN			0x0040	/*    unknown destination		*/
#define KILLSEND		0x0080	/*       kill/send				*/
#define MSGLOCAL		0x0100	/*    message entered here		*/
#define MSGHOLD			0x0200	/*    hold message for pickup	*/
#define DELETED			0x8000	/* Flag deleted bit				*/

#define ALLBITS			(CRASH|RECEIVED|SENT|MSGFWD|ORPHAN|KILLSEND|MSGLOCAL|MSGHOLD|DELETED)

/*
**	Defines spaces
*/

#define	N_ALIAS			80			/* Number of max. aliases	*/
#define	N_AREAS			500			/* Number of max. areas		*/
#define	N_UNAREAS		100			/* Unreg 100 area			*/
#define	N_PUNAREAS		15			/* Unreg point 15 areas		*/
#define	N_POINTS		75			/* Number of max. points	*/
#define	N_DOMAINS		50			/* Number of applications	*/
#define	N_SEENS			450
#define	N_PKTFILE		10
#define	N_MAXPKT			100
#define	N_AREAFILE		3
#define	N_MAXAREA		20
#define N_FASTAREAS		10
#define N_FASTTOTAL		20
#define	N_KILL			20
#define N_FDBASE		50
#define N_NODELIST		50

#define	SECONDS_PRO_DAY	86400L
#define	QBBSMAXAREAS	200

/*
**	Defines for reading netmail
*/

#define	END_OF_HDR		0			/* End of area reached		*/
#define	NEW_MSG			1			/* New message				*/

/*
** Defines for area tag
*/

#define READ_ONLY	0
#define	PUBLIC		1
#define REMOTE_ONLY	2

#define	KEEPMSGS	1
#define	KILLMSGS	0

/*
**	Defines for LED
*/

#define	NOTHINGNEW		0x0000
#define	UNREADMSGS		0x0001
#define	NEWMSGS			0x0002
#define	SYSOPMSGS		0x0004

/*
**	Do we use ^aREALNAME, and when do we use it
*/

#define	REALIN			0x01
#define REALOUT			0x02
#define REALAL			0x03

/*
**	defines for request
*/

#define	NOTFOUND		0			/* Area not found			*/
#define	CONNECT			1			/* Connect to area			*/
#define	DISCONNECT		2			/* Disconnect				*/
#define	NOTALLOWED		4			/* Not a public area		*/
#define	DIFFZONE		8			/* Other zone				*/

/*
**	defines for inbounds
*/

#define	PROTINBOUND		0
#define	KNOWNINBOUND	1
#define	NORMALINBOUND	2

/*
**	defines for messageheadertype
*/

#define	TYPE3d			0
#define	TYPE4d			1
#define	FTS_TYPE		0
#define	FRONTDOOR		1
#define TYPE_2_1		2
#define TYPE_2_2		3

/*
**	Defines for extract arcmail
*/

#define	isARCmail		0
#define	isLZHmail		1
#define	isZIPmail		2
#define	isARJmail		4
#define	isUNKNOWN		3

/*
**	Defines for routing table
*/

#define	SENDARC			0x0001
#define	HOLDMSG			0x0002
#define	ROUTE			0x0004
#define	FILETO			0x0008
#define	KNOWNAS			0x0010
#define	POLLNODE		0x0020
#define	FILEMAX			0x0040
#define	CRASHOK			0x0080
#define	HOLDPOLL		0x0100
#define	HOLDMAX			0x0200
#define	HOLDDEL			0x0400
#define CRASHPOINT		0x0800
#define DENYOK			0x1000
#define MSGTRACK		0x2000
#define	R_TO_HIM		0x8000

/*
**	Defines for crunch
*/

#define	AFTERIMPORT		1
#define	AFTERSCAN		2
#define	CRUNCHALWAYS	3

#define	CRUNCHALL		0
#define	CRUNCHSPECIALS	1

#define DBFILEIO	0		/* Debug file IO (creation of files)		*/
#define SMALLBUF    0		/* use buffers <= 64K?						*/

							/* defines for Aopen						*/
#define AR_OK		0		/* Area is OK to process					*/
#define AR_EMPTY	1		/* Area is empty							*/
#define AR_NOCHANGE	2		/* Area is not changed						*/
#define AR_TOSMALL	3		/* Area contains to little hdrs				*/
#define AR_TOBIG	4		/* Area contains to munch hdrs				*/
#define AR_DISKFREE	5		/* Not enoug free space on drive			*/
#define AR_IOERR	6		/* IO error while opening files				*/
#define AR_MSGERR	7		/* No messagebody							*/

#define	MAXMSGS		15000	/* this way, an array of ints < 32K			*/
#define LBBSRECSIZE	(200 * sizeof(WORD))

#define DEF_SAFETY	14		/* default number of -S option days			*/
#define DEF_MINHDR	1		/* default numer of -M option headers		*/

#define TOTPART		(5L)	/* The sum of the following parts!!!	*/
#define HDRWRPART	(1L)
#define HDRRDPART	(1L)
#define BODWRPART	(3L)
#define FLAG (0xFFFFFFFFL)

#define MAXDRIVES	32

#define NOATTRIB	0

#define SECSDAY 86400L      /* Number of seconds in 1 day */

#define MSGDELETE	0
#define MSGOK		1

/*
**	Defines for labels
*/

#define	NOLABEL			0
#define	USELABEL		1
#define	ENDLABEL		2

/*
**	Miscellaneous defines
*/

#define	SCANNED			0x8000
#define	MDATE			__DATE__

#define	FILEclosed		0
#define	FILEopen		1

#define NO_CRASH		0
#define AT_CRASH		1

#define ARC_PKTS		0
#define NORM_PKTS		1

/*
#define	MAXMSGLENGTH	(30 * 1024)
*/

#define COPYAREA		0
#define MOVEAREA		1

#define FD_FROM			0
#define FD_TO			1

/*
**	Where we must save the message.
*/

#define	TONETMAIL		0
#define	TOTRASH			1
#define	TOPACKET		2
#define	TOLOCAL			3
#define	TOPRIVATE		4
#define	NETMAILPACKET	5
#define TODATABASE		6

/*
**	Messageheader in local base
*/

typedef struct
{
	BYTE	from[36],
			to[36],
			topic[72],
			time[20];
	
	LONG	create,
			Mstart;	
	UWORD	up,				/* unused					*/
			parent,
	
			flags,
			mailer[8],
			size,
			reads,
			cost,			/* Cost of message * 100	*/
			Ozone,
			Onet,
			Onode,
			Opoint,
			
			Dzone,
			Dnet,
			Dnode,
			Dpoint;
} MSGHEADER;


/*
**	Header to use in netmail with domain.
*/

typedef struct
{
	BYTE	from[36],
			to[36],
			topic[72],
			time[20];
	
	LONG	create,
			Mstart;	
	UWORD	up,				/* unused					*/
			parent,
	
			flags;
	BYTE	domain[8];
	UWORD	mailer[4],
			size,
			reads,
			cost,			/* Cost of message * 100	*/
			Ozone,
			Onet,
			Onode,
			Opoint,
			
			Dzone,
			Dnet,
			Dnode,
			Dpoint;
} DONAINHEADER;

/*
**	Messagebase for small use of database.
*/

typedef struct {
	BYTE	from[36],
			to[36],
			topic[72],
			time[20],
			area[40];
	LONG	Mstart;
	UWORD	flags,
			size;
} SMALLBASE;

/*
**	Alias addresses
*/

typedef struct
{
	UWORD	zone,
			net,
			node,
			point,
			pointnet;
	BYTE	Domain [10];
} Aliases;

/*
**	Key definitions
*/

typedef struct
{
	UWORD	zone,
			net,
			node,
			point;
			
	BYTE	pwd[8],			/* Mailpasword				*/
			Afix[30],		/* Areafix password			*/
			Uname[32],		/* Naam van user			*/
			Ugroup[63],		/* Area groep				*/
			
			mtype,			/* Message type				*/
			htype,			/* PKT header type			*/
			arctype,		/* Archiver					*/
			intl_type,
			intl_always,	/* Always INTL				*/
			crash_to,		/* Only at crash			*/
			Send_PKT,		/* With SendAlwaysPKT		*/
			TosScan,		/* Use TosScan product code */
			Domain[10];
} Key;

/*
**	Routing rules
*/

struct _RouteDef
{
	WORD	flags;
	BYTE	destnode[30];
	BYTE	fromnode[30];
};

/*
**	Readdress buffer.
*/

typedef struct 
{
	BYTE fname[36],
		 tname[36],
		 fnode[20],
		 tnode[20];
} READDRESS;

/*
**	Domain definition
*/

typedef struct
{
	WORD	zone;
	BYTE	path[128],
			domain[40];
} Dom_;

/*
**	Packet header
*/

struct _pkthdr
{
	UWORD	ph_onode,
			ph_dnode,
			
			ph_yr, ph_mo, ph_dy,
			ph_hr, ph_mn, ph_sc,
			
			ph_rate,
			ph_ver,
			
			ph_onet,
			ph_dnet;
			
	UBYTE	ph_prod,
			ph_rev;
			
	BYTE	ph_pwd[8];
			
	UWORD	ph_qozone,
			ph_qdzone,
			
			ph_auxnet,
			ph_CWcopy;
	
	UBYTE	ph_prodH,
			ph_revMin;
			
	UWORD	ph_capable,
			
			ph_ozone,
			ph_dzone,
			ph_opoint,
			ph_dpoint;
			
	LONG	ph_rsvd;
};

/*
**	Type 2.2 packet header as is in FSC-0045.001

The proposed packet header structure is as follows:

    Offset   Width     Description
    ======   =====     ===========
         0       2     Originating node number
         2       2     Destination node number
         4       2   * Originating point number
         6       2   * Destination point number
         8       8     Reserved, must be zero
        16       2     Packet sub-version (2)
        18       2     Packet version (2)
        20       2     Originating network
        22       2     Destination network
        24       1     Product code
        25       1     Product revision level
        26       8     Password
        34       2   * Originating zone
        36       2   * Destination zone
        38       8   * Originating domain
        46       8   * Destination domain
        54       4     Product specific data
        58     ---     Start of first packed message

                     * Field only guaranteed accurate in a type 2.2 header

*/

struct _phdr2
{
	UWORD	ph_onode,
			ph_dnode,
			
			ph_opoint,
			ph_dpoint;
	
	ULONG	ph_res[2];
	
	UWORD	ph_sub,
			ph_ver,
			ph_onet,
			ph_dnet;
	
	BYTE	ph_prod,
			ph_rev,
			ph_pwd[8];
	
	UWORD	ph_ozone,
			ph_dzone;
	
	BYTE	ph_odomain[8],
			ph_ddomain[8];
	UBYTE	ph_spec_data[4];
};

/*
**	Messageheader in PKT file
*/

struct _pktmsg
{
	WORD	pm_ver,					/* Message version			*/
			
			pm_onode,
			pm_dnode,
			pm_onet,
			pm_dnet,
			
			pm_attr,
			pm_cost;
};

/*
**	Capture buffers
*/

typedef struct
{
	BYTE	name[36];
	
	UWORD	zone,
			net,
			node,
			point;
} CAPTUREBUF;

/*
**	IOSmail key definitions
*/

#define	ALPHALEVEL		25
#define	BETALEVEL		66
#define	REGISTEREDLEVEL	23

#define	STARTTOKEN		'.'

#define	DATE_XOR		0x48
#define	NAME_XOR		0x66
#define	TYPE_XOR		0x48
#define	START_XOR		0x44
#define KTYPE_XOR		0x76

#define REG_VERS	240
#define UNR_VERS	104
#define BET_VERS	99
#define NO_KEY		251

typedef struct
{
	BYTE	year,
			day,
			month,
			
			type,
			start,
			
			res[215],
			name[36];
	UWORD	reg_num,
			zone;
} IOSKEY;

typedef struct
{
	WORD	Qlr[QBBSMAXAREAS];
} QBBSLASTREAD;
/* structure definitions					*/

typedef struct {
	long	size;		/* size in bytes								*/
	BYTE 	*start;		/* pointer to start								*/
	BYTE	*curpos;	/* pointer to current position					*/
	long	level;		/* no. of items currently in buffer				*/
	long	maxitem;	/* max no. of items in buffer					*/
} _filebuf;

typedef struct {
	WORD		days;		/* no. of days to keep messages in this area	*/
	WORD		min;		/* min no. of messages to keep in this area		*/
	WORD		max;		/* max no. of messages to keep in this area		*/
	BYTE		*name;		/* name of this area, malloc'd					*/
	BYTE		*path;		/* path to this area, malloc'd					*/
} _area;

struct _ndi
{
   WORD node;									  /* node number  */
   WORD net;									  /* net number   */
};

#endif
