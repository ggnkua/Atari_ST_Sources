/*  addr.h  */
/*      Addresses of all dialogue and alert boxes in resource file  */


/* Dialogue boxes */
OBJECT *menuobj;	/* -> menu tree */
OBJECT *abtdial;	/* -> about dialogue tree */
char   *nowincap;
OBJECT *physdial;
OBJECT *typedial;
OBJECT *logdial;

/* Dialogues for Format */
OBJECT *fwarning;
OBJECT *dsknames;
OBJECT *nofmt;
OBJECT *fmtfnl;
OBJECT *fmtmsg;
OBJECT *scanmsg;
OBJECT *dmrkmsg;
OBJECT *cantform;
OBJECT *instlmsg;

/* Dialogues for Partition */
OBJECT *machtype;		/* box for select a right type hard disk driver */
OBJECT *ibmpnl;			/* box for edit a  partition for IBM */
OBJECT *scrpnl;			/* box for edit a  partition for IBM */
OBJECT *exppnl;			/* box for select extended partition scheme */
OBJECT *maxlogms;		/* box for mention the max logica partition */
OBJECT *nodev;			/* box for mention the no exist physical unit */
OBJECT *maxpsize;		/* box for mention the max partition size < 256Mb */
OBJECT *pwarning;
OBJECT *ppnl;
OBJECT *p;
OBJECT *nopart;
OBJECT *partfnl;
OBJECT *partmsg;
OBJECT *part2big;
OBJECT *cantpart;

/* Dialogues for Zero */
OBJECT *zwarning;
OBJECT *zerofnl;
OBJECT *zeromsg;
char   *hdrwrite;

/* Dialogues for Markbad */
OBJECT *mwarning;
OBJECT *lmrkmsg;
OBJECT *lmrkfile;
OBJECT *lmrksub;
OBJECT *markorph;
char   *svfiles;
char   *nsfiles;
OBJECT *nodrslot;
OBJECT *lmrkdone;

/* Dialogues for Ship */
OBJECT *shipdial;
OBJECT *shipdev;
OBJECT *shipfnl;
OBJECT *scommand;

/* Error messages */
char *bslread;
char *bslwrite;
char *cruptbsl;
char *fatread;
char *fatwrite;
char *badfat;
char *dirread;
char *dirwrite;
char *sdirread;
char *sdirwrit;
char *rootread;
char *rootwrit;
char *bootread;
char *bootwrit;

char *nomemory;
char *rsrvbad;
char *manyldev;
char *autoboot;
char *cantdel;
char *dskwrite;
char *cruptfmt;
char *needboot;		/* box for mention the reboot the system */
char *needinfo;		/* box for mention putting info into wincap file */

char  *manybad;
char  *nomenu;
char  *nexsmem;
char  *oldfmt;
char  *mdach;
OBJECT *wronparm;

/* Errors applicable only to removable media */
char  *mdmchng;
char  *wrprotct;
char  *drvnrdy;
char  *instdrv;
