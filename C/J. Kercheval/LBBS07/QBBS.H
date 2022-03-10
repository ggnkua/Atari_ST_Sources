/* 
 *	QBBS Message base structures header file 
 *
 *	Public Domain.
 */

#ifndef WORD
#define WORD short
#endif

#ifndef LONG
#define LONG unsigned long
#endif

#ifndef UWORD
#define UWORD unsigned short
#endif

#ifndef BYTE
#define BYTE char
#endif

typedef struct 
{
    char    from[36];
    char    to[36];
    char    subject[72];
    char    time[20];
    LONG    stamp;
    LONG    msgoffset;
    UWORD   reserved1;
    UWORD   reply_to;
    UWORD   attrib;
    WORD    mailer[8];
    UWORD   size;
    UWORD   read_count;
    UWORD   cost;
    UWORD   o_zone;
    UWORD   o_net;
    UWORD   o_node;
    UWORD   o_point;
    UWORD   d_zone;
    UWORD   d_net;
    UWORD   d_node;
    UWORD   d_point;
}

QBBS_MHEADER;

/* user.bbs */

#define MAXLOGIN	7
#define MAXNAME	30
#define MAXPASS	12
#define MAXPHONE	12
#define MAXLOC		10

typedef struct {
	BYTE junk; /* !! pascal strings !! :-( */
	char name[36];
	char city[26];
	char pass[16];
	char phone[12];
	char reserved1[13]; /* dataph */
	char reserved2[6]; /* tm */
	char reserved3[9]; /* date */
	BYTE attrib; /* Bit0: Delete, Bit1: ClrScr, Bit3: FSE */
	BYTE flags[4];
	WORD credit;
	WORD lastday; /* since 1/1/70, time()/86400 on unix systems */
	WORD posted;
	WORD isansi;
	WORD security;
	WORD calls;
	WORD upload;
	WORD download;
	WORD dlkb;
	WORD dlkb_today;
	WORD seconds_today;
	WORD scr_len;
	char login[8]; /* lazybbs extension */
} QBBS_USERS;

#define GetUserFlag(u,c,n)	(u->flags[c] & (1<<n))
#define SetUserFlag(u,c,n)	(u->flags[c]|=(1<<n))
#define ResetUserFlag(u,c,n)	(u->flags[c]&=(!(1<<n))

#define USATTR_KILLED	0x01
#define USATTR_FSE		0x07

#define KILLFLAG 0x8000
#define POSTFLAG 0x0100  /* 'Local' */
#define PRVTFLAG 0x0001  /* 'Private' */
#define CRASFLAG 0x0002  /* crashmail */
#define RCVDFLAG 0x0004  /* mail read */

#define StrPasToC(a) (a[(int)(*((char *)a-1))]=0)
#define StrCToPas(a) (*((char *)a-1)=strlen(a))
