unsigned long _STACK=16384;

/* Stik interfacing stuff */
DRV_LIST *drivers=(DRV_LIST *)NULL;
TPL *tpl=(TPL *)NULL;

/* Definition of constants */

#define VT 0ÄFUIOIYYH2F3BK00017888 	/*Offset above info line for redraw */
#define FORWARDS 1 	/*Channel/window cycling */
#define BACKWARDS 2
#define NOFWIN 6 	/* number of windows (until DMA!). Also no. servers */

#define WMCLEAR 0 	/* Means ok to write to window */
#define WMDONTWRITE 1 	/* Dont write to that window! */
#define WMFULLESD 2 	/* Window has been fulled */

#define SAWAIT 4 	/* DCC file - wait for response to a SEND request */
#define SACTIVE 3 	/* DCC file - send in progress */
#define RAWAIT 3	/* DCC file - receive in progress */
#define RESUME 5	/* DCC file - waiting for signal to commence from Resume */

#define DCIN 1 	/* DCC file - direction in */
#define DCOUT 2 /* DCC file - direction out */

#define AMQUIT 0	/* auto macro for /quit */
#define AMAWAY 1	/* auto macro for /away */

#define MGTAG "MagX" /* Magic cookie */
#define MITAG "MiNT" /* Mint cookie */

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
#define CDIVIDE 10
#define CINPINFO 11

/* definitions for calling font selector */
#define FONT_FLAGS 	(FNTS_BTMP + FNTS_OUTL + FNTS_MONO + FNTS_PROP)
#define FNTS_3D 1
#define BUTTON_FLAGS (FNTS_SNAME + FNTS_SSTYLE + FNTS_SSIZE + FNTS_SRATIO + FNTS_CHNAME + FNTS_CHSTYLE + FNTS_CHSIZE + FNTS_CHRATIO + FNTS_RATIO )

/* Window dialogue handles */
DIALOG *hdccsend,*hdomacros,*hpathset,*habout,*hsortconnect,*hopenchan;
DIALOG *hsetcols,*hdisplay,*huserset,*hserverset,*hfontform,*hgeneralform;
DIALOG *hautonotify,*hamacform,*hdccfform,*htoolbox;

/* Font dialogue */
FNT_DIALOG *fnt_dialog;

/* Channel types */
#define NORMCHAN 1
#define DCCCHAN 2 /* this would be a DCC chat channel */


/* Definition of variables */

short dctbufsize=1024; /*DCC file - transfer block size */
short soff=0,serv=0;
WORD winfont=1,winpoint=10,inpfont=1,inppoint=10;
OBJECT *mnu; /* main menu */
CIB *cb; /* Connection information */
GRECT ms; /* Screen rectangle */
GRECT redbox;
MFDB scr; /* MFDB for vro_cpyfm */
char oserver[100],oport[20]; /* global definitions for server connection */
MENU pop;
EVNT events;
VDI_Workstation ws;
DIALOG *dials[128];
char mnormg=0;

typedef struct {
	long cktag;
	long ckvalue;
} ck_entry;

short aes_font,	aes_height,aes_flags,tree_count;

char crackmes[200]={"Crackers: You're too good at your art for me to stop you"};

short mdrag=0;

RSHDR *rsh;
OBJECT **tree_addr;
char **fstring_addr;				


typedef struct {
	char texteffects;
	char boldnicks;
	char autodcd;
	char flashcurs;
	char smothscrol;
	char autodccrecv;
	char smscrolspd;
	char urlgrab;
	char autonewwindow;
	char playsounds;
	char autoresume;
	char typethru;
}COFIG;

COFIG conf={1,1,1,1,0,0,2,0,0,1,1,1};

char am[5][60];
char oc=0;
short pfctcr=0;
char far dccp[2000],*oreg;
short fversion=1200; /* here the 1 signifies beta and the rest the version */
char away;
char fname[FNSIZE],fpath[FMSIZE];
char dname[255];
char dccrecvname[255],odccrecvname[255];
char lastn[20][12];
char far macs[20][60];
char far otp2[2000],ann[8][12];
char logfname[255],ologfname[255];
char urlfname[255],ourlfname[255];
char sounddir[255],osounddir[255];
long lh;
short ndelay=5;
short logop=0;
short lastnt,lastnc;

short blkfirst,blklast;
short scx,scy;
int cwin=-1;
typedef struct{
	int hand;
	char stat;
	int chan;
	short hght;
	char info[120];
	char title[120];
	GRECT wwa;
	short scb;
	short clcnt;
	char cl[150][150];
	char clc[150];
	short iof[80];
	short cvof;
	short ihc[80];
	char inp[1200];
	short cx;
	short cptl;
	short cnn;
}WIND;
WIND far wn[6];

typedef struct{
	int16 cn;
	char nick[20];
	int16 auth;
	char server[100];
	char cpbuff[2000];
	char outp[4000];
	short noton[128];
	char nickflag;
}CNTN;
CNTN far cn[6];

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
far DCSTRCT dcc[10];	

char dcctempbuffer[4097];
short wcount=0;
short blink=2;
short quit;
char col[25]={1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0};

uint16 port;
short handle;
WORD kreturn,msg[16];
short cf;
short ith,th,tw,sw,sh;
short flag;

typedef struct {
	short win;
	short stat;
	char name[20];
	int16 cn;
} CHAN;
CHAN chan[30];

short notcount=0;
far char itp[5][1200],itemp[1200];
char far otp[10][350],otemp[3000];
char snick[50]="Joebloggs\0";
char chinp[150];
char irc_server[4][100],irc_port[4][10];
char far tempa[4000],tempb[2000],tempc[2000],tempd[2000];
char hostname[100],username[100],realname[100];
char far outpa[2000],outpb[2000];
char bold,red,reset,reversed,underlined;
char notlist[128][12];
short appl_id;
char MenuTitle[] = "  FracIRC\0";

BASEPAGE *gjbp;

/* Lets define our functions */

int check_carrier(void);
int checkstik(void);
void reg(void);
int findsawaitdc(char *nm,char *sndr);
int findresmdc(char *sndr);

int getsoundlist(char *ps);
int playsound(char *ps);
void addtotablist(char *ps);
void srt(char *ps,int16 cnct);

void startupdate(void);
void finishupdate(void);
int writeanurl(char *ps);

void event_loop(void);
void HandleEvents(short fin);
void HandleMessage(WORD *msg);
void HandleTimer(void);
void HandleButton(void);
void HandleKeybd(short blah);
void HandleMenus(short *msg);
int HandleDialoges(void);


void writeinpinfo(short w,char swt);
int inpbclear(short w,short swit);
int doms(short mnum);
int closchan(short chantc);
int findfreedc(void);
int findfreechannel(void);
int findthechannel(char *nch);
int getchanhan(char *p);
int citw(char *p,short twin);
int findlastchannel(void);
int findnextchannel(void);
int cycchan(short dri);
int openwin(short x,short y,short w,short h,short swtch);
int clearwin(int handd,short x, short y, short w, short h);
int fullwin(int hand);
int findusedwindow(short dir);
int findfreewindow(void);
int findwhand(int hand);
int oneofours(int hand);
int topwindow(int hand);
int cycwin(int dir);
int closewin(int hand);
int resizewindow(int hand, short x,short y, short w, short h,char flip);
int dowindinfo(int hand);
int is_dw_open(DIALOG *dialog);
void initdialogs(void);
void finishdialogs(void);
int writeblock(char *dp,short hof,short vof,short coll,short hand);
int writeoutput(short hand, char *ps,short vof,short coll,char swit);
int checkoutputvalid(short hand);
void initiateredraw(int hand,short x,short y,short w,short h);
int dofontselector(short whichfont);
int setinpfont();
int setwinfont();
void wd_close(DIALOG *dialog);
void clearipb(short w);
int inputprocess();
int checkformacs();
void drawvslid();
int sbvslid(short newpos);
void scrolldown();
void scrollup();
int scrollback();
int scrollbbk();
int opendccsenddialog(short temp,char *name);
int opendccrecvdialog(short temp,char *name);
int resetadcc(short num, char swt);
int clcursor(short w);
int redoinpb(short hand,char swit);
int clchar();
int docursor(short w);
int wtib(char *point);
int doobj(short fj,short type);
int tlog(char *str);
int openlog();
int closelog();
int checkdccchat();
int loadprefs(char *fn);
int loadmacs(char *fn);
int savmacs(char *fn);
int savprefs(char *fn);
int initiatedccchat(char *usr);
int initiatedcc(char *usr,char *ftg);
int dcc_recv();
int dcc_send();
int gotcmd();
int sortcmd(char *ps,short twin);
int domacros(void);
int sendout(char *ps,int bland,short coll,char swit);
int doblock(short offset,short bland,short coll,short x,short y);
int dodccsend(void);
int dopathset(void);
int sortconnection(void);
int openchan(void);
int setcols(void);
int stoolbox(void);
int useroptions(void);
int serveroptions(void);
int dispoptions(void);
int fselector(char *buf,char *strg,short f);
int basename(char *s);
int findfreedc(void);
int findfreechannel(void);
int findusedwindow(short dir);
int findfreewindow(void);
int findwhand(short hand);XGMXPG    9 L)abcds9êdhstuoy_M_dxstuoy (1,EIAL0x088sfTUHXT004  