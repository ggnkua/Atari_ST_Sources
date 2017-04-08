 /* Definition of variables */
#define DD_OK 0
#define DD_NAK 1
#define DD_EXT 2
#define DD_LEN 3
#define DD_TRASH 4
#define DD_PRINTER 5
#define DD_CLIPBOARD 6

#define VT 15
#define NLW 65

#define FORWARDS 1 
#define BACKWARDS 2

#define NOFWIN 6
#define WMCLEAR 0
#define WMDONTWRITE 1
#define WMFULLESD 2
#define SAWAIT 4	/* wait for response to DCC file send */
#define SACTIVE 3	/* DCC file send in progress */
#define RAWAIT 2	/* DCC file receive in progress */
#define RESUME 5

#define DCIN 1 /* DCC file is coming in */
#define DCOUT 2 /* DCC file is going on out */

#define AMQUIT 0 /*auto macro for /quit */
#define AMAWAY 1 /*auto macro for /away */

#define MGTAG "MagX"
#define MITAG "MiNT"

/* Flying dialogue handles */
extern DIALOG *hdccsend,*hdomacros,*hpathset,*habout,*hsortconnect,*hopenchan;
extern DIALOG *hsetcols,*hdisplay,*huserset,*hserverset,*hfontform;
extern DIALOG *hgeneralform,*hautonotify,*hamacform;
extern DIALOG *hdccfform,*htoolbox,*hftalk;

#define	FONT_FLAGS	( FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP )
#define FNTS_3D 1

#define	BUTTON_FLAGS ( FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE + FNTS_SRATIO + FNTS_CHNAME + FNTS_CHSTYLE + FNTS_CHSIZE + FNTS_CHRATIO + FNTS_RATIO )
extern FNT_DIALOG	*fnt_dialog;
#define NORMCHAN 1
#define DCCCHAN 2

extern int16 dctbufsize;
extern short soff,serv;
extern WORD winfont,winpoint,inpfont,inppoint;
extern OBJECT *mnu;
extern CIB *cb;
extern GRECT ms;
extern GRECT redbox;
extern MFDB scr;
extern char oserver[100],oport[20];
extern MENU pop;
extern EVNT events;
extern VDI_Workstation ws;
extern DIALOG *dials[128];
extern char mnormg;

typedef struct {
	long cktag;
	long ckvalue;
} ck_entry;

extern short aes_font,	aes_height,aes_flags,tree_count;

extern short mdrag;

extern RSHDR *rsh;
extern OBJECT **tree_addr;
extern char **fstring_addr;				


typedef struct {
	char boldnicks;
	char autodcd;
	char smothscrol;
	char autodccrecv;
	char smscrolspd;
	char urlgrab;
	char autonewwindow;
	char playsounds;
	char autoresume;
	char typethru;
	char autojoin;
	char nickchan;
	char dccav;
	char amaj1[15];
	char amaj2[15];
	char snick[20];
	char snick2[20];	
}COFIG;

extern COFIG conf;

extern char am[5][60];
extern char oc;
extern short pfctcr;
extern char far dccp[2000],*oreg;
extern short fversion; /* here the 1 signifies beta and the rest the version */
extern char away;
extern char fname[64],fpath[512];
extern char dname[256];
extern char dccsname[256];
extern char lastn[20][12];
extern char macs[20][60];
extern char ann[8][12];
typedef struct{
	char log[256];
	char oldlog[256];
	char url[256];
	char oldurl[256];
	char sound[256];
	char oldsound[256];
	char dcc[256];
	char olddcc[256];
}PATH;
extern far PATH path;

extern long lh;
extern short ndelay;
extern short logop;
extern short lastnt,lastnc;

extern short blkfirst,blklast;
extern short scx,scy;
extern int cwin;
typedef struct{
	int hand;
	char stat;
	int chan;
	short hght;
	char info[120];
	char info2[120];
	char title[120];
	GRECT wwa;
	short scb;
	short clcnt;
	short clastrd;
	char cl[150][200];
	char clc[150];
	short iof[80];
	short cvof;
	short ihc[80];
	char inp[1200];
	short cx;
	short cptl;
	short cnn;
}WIND;
extern WIND far fakewn;
extern WIND far wn[NOFWIN];

typedef struct{
	int16 cn;
	char nick[20];
	int16 auth;
	char server[100];
	char cpbuff[2048];
	char outp[4096];
	short noton[128];
	char nickflag;
}CNTN;
extern CNTN far fakecn;
extern CNTN far cn[6];

typedef struct{
	int16 cna;
	int16 cnb;
	char avec[15];
	char *buf;
	int stat;
	uint32 rip;
	int16 rporta;
	int16 rportb;
}FTSTRCT;
extern far FTSTRCT ftalk;

typedef struct{
	int16 cn;
	short stat;
	uint32 cnt,lack;
	char avec[15];
	DIALOG *dcw;
	char fname[150];
	long dcfh;
	short dir;
	long len;
	char dtit[40];
	uint32 rip;
	int16 rport;
}DCSTRCT;
extern far DCSTRCT dcc[10];	

extern char dcctempbuffer[5000];
extern short wcount;
extern short blink;
extern short quit;
extern char col[25];

#define CERRORS 0
#define CPMSGSTO 1
#define CPMSGSFROM 2
#define CCURSOR 3
#define CINPTEXT 4
#define CSYSTEM 5
#define CACTIONS 6
#define CDCCINFO 7
#define CBODY 8
#define CBACK 9
#define CDIVIDET 10
#define CINPINFO 11
#define CNICKLIST 12
#define CNLBACK 13
#define CINPBACK 14
#define CDIVIDEB 15
#define CNLDIVIDE 16

extern uint16 port;
extern short handle;
extern WORD kreturn,msg[16];
extern short ith,th,tw,sw,sh;
extern short flag;

typedef struct {
	short win;
	short stat;
	char name[20];
	int16 cn;
	char nl[128][12];
	short nn;
} CHAN;
extern CHAN fakechan;
extern far CHAN chan[30];

extern short notcount;
extern char chinp[150];
extern char irc_server[4][100],irc_port[4][10];
extern char hostname[100],username[100],realname[100];
extern char far outpa[2000],outpb[2000];
extern char bold,red,reset,reversed,underlined;
extern char notlist[128][12];
extern short appl_id;
extern char MenuTitle[12];

extern BASEPAGE *gjbp;

