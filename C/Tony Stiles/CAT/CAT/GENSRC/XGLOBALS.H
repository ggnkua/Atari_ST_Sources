#ifndef GOT_GLOBALS
#define GOT_GLOBALS 1

extern char *msg[];
extern int odet[][23];
extern char *olng[];
extern char *osht[];
extern int osynn[];
extern char *osynt[];
extern int rmd[][4];
extern char *rml[];
extern int rmp[][3];
extern char *rms[];
extern int vchk[][2];
extern int vsynn[];
extern char *vsynt[];
extern char *oqual[];
extern char *oqualo[];
extern char *vprep[];

#ifdef MAIN
int cnt[500]={0};
int player=0;
int score=0;
int turns=0;
int x=2;
int usc=0;
int cplr=0;
BOOLEAN wgt_c=TRUE;
char *sep= " ,.;:'!?";
char noun_t[2000]="";
char noun_o[2000]="";
char verb_t[80]="";
char vp[80]="";
char np[80]="";
char pc[80]="";
char prepv[80]="";
char prepo[80]="";
char actor[80]="";
char quala[80]="";
char qual[80]="";
char file[13]="";
BOOLEAN dead=FALSE;
BOOLEAN script=FALSE;
BOOLEAN verbose=FALSE;
char str[81];
char *sptr;
#else
extern char *dict[];
extern int cnt[];
extern int player;
extern int score;
extern int turns;
extern int x;
extern int usc;
extern int cplr;
extern BOOLEAN wgt_c;
extern char *sep;
extern char noun_t[];
extern char noun_o[];
extern char verb_t[];
extern char vp[];
extern char np[];
extern char pc[];
extern char prepv[];
extern char prepo[];
extern char actor[];
extern char quala[];
extern char qual[];
extern char file[];
extern BOOLEAN dead;
extern BOOLEAN script;
extern BOOLEAN verbose;
extern char str[];
extern char *sptr;
#endif

#endif
