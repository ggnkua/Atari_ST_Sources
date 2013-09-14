/*  addr.h  */
/*      Addresses of all dialogue and alert boxes in resource file  */

extern	OBJECT *menuobj;	/* -> menu tree */

/* Dialogue for About in menu */
extern	OBJECT *abtdial;	/* -> about dialogue tree */

/* Box for current unit and disk type */
extern	OBJECT *unittype;	/* display */

/* Dialogues for Controller Test */
extern	OBJECT *ctrlpass;	/* test is passed */
extern	OBJECT *ctrlfail;	/* test is failed */

/* Dialogues for Daisy Chain Test */
extern	OBJECT *dchpass;	/* test is passed */
extern	char   *nodcent;	/* missing 'dc' entry in wincap */
extern	OBJECT *dchwfail;	/* test failed with write error */
extern	OBJECT *dchrfail;	/* test failed with read error */
OBJECT *dchdfail;	/* test failed with data error */

/* Dialogues and Alerts for Format + Partition */
extern	OBJECT *physdial;
extern	OBJECT *dsknames;
extern	OBJECT *fmtmsg;
extern	OBJECT *nofmt;
extern	OBJECT *cantform;
extern	OBJECT *cantpart;
extern	OBJECT *nopart;
extern	char *cruptfmt;
extern	char *notfmtd;

/* Dialogues and Alerts for Burn-in */
extern	OBJECT *brninmsg;
extern	OBJECT *bslform;
extern	OBJECT *dskpass;
extern	OBJECT *dskfail;

/* Dialogues and Alerts for Inputting Defect List */
extern	OBJECT *npdeflst;
extern	OBJECT *nputform;
extern	OBJECT *askxam;
extern	OBJECT *xamform;
extern	OBJECT *edtform;
extern	OBJECT *keepdefs;
extern	char *cylis0;
extern	char *cyl0bad;
extern	char *npcmpent;
extern	char *bghdnum;
extern	char *bgcylnum;
extern	char *bgbytnum;
extern	char *deffull;
extern	char *defemp;

/* Alert for Ship */
extern	char *scommand;


/* Error messages */
extern	OBJECT *errnum;
extern	OBJECT *part2big;
extern	OBJECT *partmsg;
extern	char *autoboot;
extern	char *bootread;
extern	char *bslread;
extern	char *bslwrite;
extern	char *cruptbsl;
extern	char *cyl0bad;
extern	char *cylis0;
extern	char *dskwrite;
extern	char *fatread;
extern	char *fatwrite;
extern	char *manybad;
extern	char *manyldev;
extern	char *midrez;
extern	char *nowincap;
extern	char *nomemory;
extern	char *rootbad;
extern	char *rootread;
extern	char *rootwrit;
