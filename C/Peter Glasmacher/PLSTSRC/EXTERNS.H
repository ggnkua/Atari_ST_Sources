/*----------------------------------------------------------------------*
*                      MSVAR.C                                          *
*-----------------------------------------------------------------------*/
extern long envsiz;
extern BASPAG *_BasPag;
extern FILE  *bat_file[4];
extern CMD cmdlist[];

extern struct PLIST plist;
extern char *msg[];
extern char  argvbuf[128];
extern char  *argv[50];
extern int argc;

extern char tempbuf[64];
extern char inbuf[80];
extern char combine[64];
extern char dirname[64];
extern char *cbuf;                      /* ptr to copybuf               */
extern char prompt[64];
extern char path[64];
extern char cdest[80];
extern char  curdir[64];
extern char  dirpart[64];
extern struct DIR *dirptr[DENTRY];

extern int bat_depth;
extern char  bat_var[4][128];
extern char  *bat_arg[4][51];

extern short stop_flag;
extern short msg_flag;
extern short echo_flag;
extern short err_flag;
extern short exit_flag;
extern short specdrive;
extern short errorlevel;
extern short drive;
extern short in_exec;
extern short gf;
extern jmp_buf cmd_ret;

extern char *devices[];


/*----------------------------------------------------------------------*
*-----------------------------------------------------------------------*/
extern char paid[],proid[],ipmt[],bsl[],bsb[],
            cdot[],csdot[],onms[],offms[],cver[],
            nuls[],sp1[],gen[];


