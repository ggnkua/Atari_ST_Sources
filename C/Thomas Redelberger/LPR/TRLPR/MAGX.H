/************************************************************************/
/*      MAGX.H      #defines for MAGIX Extensions                       */
/*              started 01/11/91 Andreas Kromke                         */
/*                                                                      */
/*     fÅr TURBO C                                                      */
/************************************************************************/

#if !defined( __PORTAB__ )
#include <portab.h>
#endif

#if  !defined( __AES__ )
#define OBJECT void
#endif

/* ApplicationDescriptor                                                */
/************************************************************************/

typedef void APPL;


/* ProcessDescriptor, Aufbau der Basepage                               */
/************************************************************************/

typedef struct pd
{
   void   *p_lowtpa;
   void   *p_hitpa;
   void   *p_tbase;
   LONG   p_tlen;
   void   *p_dbase;
   LONG   p_dlen;
   void   *p_bbase;
   LONG   p_blen;
   DTA    *p_dta;
   struct pd *p_parent;
   WORD   p_res0;
   WORD   p_res1;
   char   *p_env;
   char   p_devx[6];
   char   p_res2;
   char   p_defdrv;
   LONG   p_res3[18];
   char   p_cmdlin[128];
} PD;

/* ProgramHeader, Programmkopf fÅr ausfÅhrbare Dateien                  */
/************************************************************************/

typedef struct {
   int  ph_branch;        /* 0x00: muû 0x601a sein!! */
   long ph_tlen;          /* 0x02: LÑnge  des TEXT - Segments */
   long ph_dlen;          /* 0x06: LÑnge  des DATA - Segments */
   long ph_blen;          /* 0x0a: LÑnge  des BSS  - Segments */
   long ph_slen;          /* 0x0e: LÑnge  der Symboltabelle   */
   long ph_res1;          /* 0x12: */
   long ph_res2;          /* 0x16: */
   int  ph_flag;          /* 0x1a: */
} PH;

/* new GEMDOS- Calls */

#define SCONFIG		0x33							/* KAOS 1.2 */
#define Sconfig(a,b)    gemdos(0x33, (int) (a), (long) (b)) /* KAOS 1.2 */
/* extern long Sconfig(WORD fn, ...); */
#define Fshrink(a)      Fwrite(a, 0L, (void *) -1L)         /* KAOS 1.2 */
#define Mgrow(a,b)      Mshrink(a,b)                        /* KAOS 1.2 */
#define Mblavail(a)     Mshrink(a,-1L)                      /* KAOS 1.2 */
#define Ssync()         gemdos(0x150)					/* MagiC 4.01 */
/* Sconfig - Functions */

#define SC_GETCONF   0                                      /* KAOS 1.2 */
#define SC_SETCONF   1                                      /* KAOS 1.2 */
#define SC_DOSVARS   2                                      /* KAOS 1.4 */
#define SC_MOWNER	 3		/* reserviert */			/* MagiC 3.00 */
#define SC_WBACK	 4								/* MagiC 4.01 */
#define  SCWB_GET	 0		/* (fÅr WBDAEMON) */		/* MagiC 4.01 */
#define  SCWB_SET    1								/* MagiC 4.01 */
#define  SCWB_RESET  2								/* MagiC 4.01 */
#define SC_INTMAVAIL 5        /* reserviert */			/* MagiC 4.01 */
#define SC_INTGARBC  6		/* reserviert */			/* MagiC 4.01 */

/* Sconfig Bits */

#define SCB_PTHCK   0x001                                   /* KAOS 1.2 */
#define SCB_DSKCH   0x002                                   /* KAOS 1.2 */
#define SCB_BREAK   0x004                                   /* KAOS 1.2 */
#define SCB_NCTLC   0x008                                   /* KAOS 1.2 */
#define SCB_NFAST   0x010                                   /* KAOS 1.2 */
#define SCB_CMPTB   0x020                                   /* KAOS 1.4 */
#define SCB_NSMRT   0x040                                   /* KAOS 1.4 */
#define SCB_NGRSH   0x080                                   /* KAOS 1.4 */
#define SCB_NHALT   0x100                                   /* KAOS 1.4 */
#define SCB_RESVD   0x200                                   /* KAOS 1.4 */
#define SCB_PULLM   0x400                                   /* KAOS 1.4 */
#define SCB_FLPAR   0x800                                   /* MagiC 3.0 */

/* Sconfig(2) -> */

typedef struct
   {
   char      *in_dos;                 /* Adresse der DOS- Semaphore */
   int       *dos_time;               /* Adresse der DOS- Zeit      */
   int       *dos_date;               /* Adresse des DOS- Datums    */
   long      res1;                    /*                            */
   long      res2;                    /*                            */
   long      res3;                    /* ist 0L                     */
   void      *act_pd;                 /* Laufendes Programm         */
   long      res4;                    /*                            */
   int       res5;                    /*                            */
   void      *res6;                   /*                            */
   void      *res7;                   /* interne DOS- Speicherliste */
   void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
   long      (*etv_critic)();         /* etv_critic des GEMDOS      */
   char *    ((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
   long      res8;                    /*                            */
   long      res9;                    /*                            */
   long      res10;                   /*                            */
   } DOSVARS;

/* Memory Control Block */

typedef struct
     {
     long mcb_magic;                    /* 'ANDR' oder 'KROM' (letzter)    */
     long mcb_len;                      /* NettolÑnge                      */
     long mcb_owner;                    /* PD *                            */
     long mcb_prev;                     /* vorh. Block oder NULL           */
     char mcb_data[0];
     } MCB;

/* GEMDOS- Device- Handles */

#define HDL_CON -1                                          /* TOS */
#define HDL_AUX -2                                          /* TOS */
#define HDL_PRN -3                                          /* TOS */
#define HDL_NUL -4                                          /* KAOS 1.2 */

/* GEMDOS- Standard- Handles */

#define STDIN   0                                           /* TOS */
#define STDOUT  1                                           /* TOS */
#define STDAUX  2                                           /* TOS */
#define STDPRN  3                                           /* TOS */
#define STDERR  4                                           /* TOS */
#define STDXTRA 5                                           /* TOS */

/* GEMDOS Error Codes */

#define EBREAK -68L /* user break (^C)                         KAOS 1.2 */
#define EXCPT  -69L /* 68000- exception ("bombs")              KAOS 1.2 */
#define EPTHOV -70L /* path overflow                           MAG!X    */
#define ELOOP  -80L /* too many symlinks in path               MiNT */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */

/* GEMDOS (MiNT) Fopen modes */

#ifndef   O_RDONLY
#define   O_RDONLY       0
#define   O_WRONLY       1
#define   O_RDWR         2
#define   O_APPEND       8
#define   O_COMPAT       0
#define   O_DENYRW       0x10
#define   O_DENYW        0x20
#define   O_DENYR        0x30
#define   O_DENYNONE     0x40
#define   O_CREAT        0x200
#define   O_TRUNC        0x400
#define   O_EXCL         0x800
#endif

/* GEMDOS Fseek Modes */

#define SEEK_SET    0                                       /* TOS */
#define SEEK_CUR    1                                       /* TOS */
#define SEEK_END    2                                       /* TOS */

/* Psemaphore */

#define PSEM_CRGET       0                                  /* MagiC 3.0 */
#define PSEM_DESTROY     1
#define PSEM_GET         2
#define PSEM_RELEASE     3

/* Dlock modes */

#define DLOCKMODE_LOCK   1
#define DLOCKMODE_UNLOCK 0
#define DLOCKMODE_GETPID 2

/* Dopendir modes */

#define DOPEN_COMPAT     1
#define DOPEN_NORMAL     0

/* Fxattr modes */

#define FXATTR_RESOLVE	0
#define FXATTR_NRESOLVE	1

/* Pdomain modes */

#define PDOM_TOS         0
#define PDOM_MINT        1

/* Modi und Codes fÅr Dpathconf() (-> MiNT) */

#define   DP_MAXREQ      -1
#define   DP_IOPEN       0
#define   DP_MAXLINKS    1
#define   DP_PATHMAX     2
#define   DP_NAMEMAX     3
#define   DP_ATOMIC      4
#define   DP_TRUNC       5
#define    DP_NOTRUNC    0
#define    DP_AUTOTRUNC  1
#define    DP_DOSTRUNC   2
#define   DP_CASE        6
#define    DP_CASESENS   0
#define    DP_CASECONV   1
#define    DP_CASEINSENS 2
#define DP_MODEATTR		7
#define	DP_ATTRBITS	0x000000ffL
#define	DP_MODEBITS	0x000fff00L
#define	DP_FILETYPS	0xfff00000L
#define	DP_FT_DIR		0x00100000L
#define	DP_FT_CHR		0x00200000L
#define	DP_FT_BLK		0x00400000L
#define	DP_FT_REG		0x00800000L
#define	DP_FT_LNK		0x01000000L
#define	DP_FT_SOCK	0x02000000L
#define	DP_FT_FIFO	0x04000000L
#define	DP_FT_MEM		0x08000000L
#define DP_XATTRFIELDS	8
#define	DP_INDEX		0x0001
#define	DP_DEV		0x0002
#define	DP_RDEV		0x0004
#define	DP_NLINK		0x0008
#define	DP_UID		0x0010
#define	DP_GID		0x0020
#define	DP_BLKSIZE	0x0040
#define	DP_SIZE		0x0080
#define	DP_NBLOCKS	0x0100
#define	DP_ATIME		0x0200
#define	DP_CTIME		0x0400
#define	DP_MTIME		0x0800

/* additional Dcntl/Fcntl Modes */

#define CDROMEJECT			(('C'<<8)|0x09)
#define CDROMPREVENTREMOVAL	(('C'<<8)|0x0e)
#define CDROMALLOWREMOVAL	(('C'<<8)|0x0f)
#define KER_DRVSTAT			0x0104	/* Kernel: Drive-Status (ab 9.9.95) */
#define KER_XFSNAME			0x0105	/* Kernel: XFS-Name (ab 15.6.96) */
#define VFAT_CNFDFLN		0x5600	/* VFAT-XFS: ab 2.1.96 */
#define VFAT_CNFLN			0x5601	/* VFAT-XFS: ab 2.1.96 */

/* D/Fcntl(FUTIME,...) */

struct mutimbuf
     {
     unsigned int actime;          /* Zugriffszeit */
     unsigned int acdate;
     unsigned int modtime;         /* letzte énderung */
     unsigned int moddate;
     };

/* os_magic -> */

typedef struct
     {
     long magic;                   /* muû $87654321 sein              */
     void *membot;                 /* Ende der AES- Variablen         */
     void *aes_start;              /* Startadresse                    */
     long magic2;                  /* ist 'MAGX'                      */
     long date;                    /* Erstelldatum ttmmjjjj           */
     void (*chgres)(int res, int txt);  /* Auflîsung Ñndern           */
     long (**shel_vector)(void);   /* residentes Desktop              */
     char *aes_bootdrv;            /* von hieraus wurde gebootet      */
     int  *vdi_device;             /* vom AES benutzter VDI-Treiber   */
     void *reservd1;
     void *reservd2;
     void *reservd3;
     int  version;                 /* z.B. $0201 ist V2.1             */
     int  release;                 /* 0=alpha..3=release              */
     } AESVARS;

/* Cookie MagX --> */

typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     void *res1;
     void *hddrv_functions;
     long status_bits;             /* MagiC 3 ab 24.5.95         */
     } MAGX_COOKIE;

/* Bits for <status_bits> in MAGX_COOKIE (read only!) */

#define MGXSTB_TSKMAN_ACTIVE  1    /* MagiC task manager is currently active */

/* tail for default shell */

#if  !defined( __MTAES__ )
typedef struct
     {
     int  dummy;                   /* ein Nullwort               */
     long magic;                   /* 'SHEL', wenn ist Shell     */
     int  isfirst;                 /* erster Aufruf der Shell    */
     long lasterr;                 /* letzter Fehler             */
     int  wasgr;                   /* Programm war Grafikapp.    */
     } SHELTAIL;

/* shel_write modes for parameter "isover" */

#define SHW_IMMED        0                                  /* PC-GEM 2.x  */
#define SHW_CHAIN        1                                  /* TOS         */
#define SHW_DOS          2                                  /* PC-GEM 2.x  */
#define SHW_PARALLEL     100                                /* MAG!X       */
#define SHW_SINGLE       101                                /* MAG!X       */

/* shel_write modes for parameter "doex" */

#define SHW_NOEXEC       0
#define SHW_EXEC         1
#define SHW_EXEC_ACC	3							/* AES 3.3	*/
#define SHW_SHUTDOWN     4                                  /* AES 3.3     */
#define SHW_RESCHNG      5                                  /* AES 3.3     */
#define SHW_BROADCAST    7                                  /* AES 4.0     */
#define SHW_INFRECGN     9                                  /* AES 4.0     */
#define SHW_AESSEND      10                                 /* AES 4.0     */
#define SHW_THR_CREATE	20							/* MagiC 4.5	*/

/* extended shel_write() modes and parameter structure */

#define SHW_XMDLIMIT	256
#define SHW_XMDNICE		512
#define SHW_XMDDEFDIR	1024
#define SHW_XMDENV		2048

typedef struct {
	char	*command;
	long	limit;
	long nice;
	char *defdir;
	char *env;
} XSHW_COMMAND;

typedef struct {
	LONG cdecl (*proc)(void *par);
	void *user_stack;
	ULONG stacksize;
	WORD mode;		/* immer auf 0 setzen! */
	LONG res1;		/* immer auf 0L setzen! */
} THREADINFO;

/* menu_bar modes */

#define MENU_HIDE        0                                  /* TOS         */
#define MENU_SHOW        1                                  /* TOS         */
#define MENU_INSTL       100                                /* MAG!X       */

/* objc_edit definition */

#define ED_CRSR          100                                /* MAG!X       */
#define ED_DRAW          103                                /* MAG!X 2.00  */

/* Event definition */

#define WM_UNTOPPED      30                                 /* GEM  2.x    */
#define WM_ONTOP         31                                 /* AES 4.0     */
#define WM_BOTTOMED      33                                 /* AES 4.1     */
#define WM_ICONIFY       34                                 /* AES 4.1     */
#define WM_UNICONIFY     35                                 /* AES 4.1     */
#define WM_ALLICONIFY    36                                 /* AES 4.1     */
#define AP_TERM          50                                 /* AES 4.0     */
#define AP_TFAIL         51                                 /* AES 4.0     */
#define AP_RESCHG        57                                 /* AES 4.0     */
#define SHUT_COMPLETED   60                                 /* AES 4.0     */
#define RESCH_COMPLETED  61                                 /* AES 4.0     */
#define AP_DRAGDROP      63                                 /* AES 4.0     */
#define SH_WDRAW         72                                 /* MultiTOS    */
#define SC_CHANGED       80                                 /* */
#define PA_EXIT          89                                 /* MagiC 3     */
#define CH_EXIT          90                                 /* MultiTOS    */
#define WM_M_BDROPPED    100                                /* KAOS 1.4    */
#define SM_M_SPECIAL     101                                /* MAG!X       */
#define SM_M_RES2        102                                /* MAG!X       */
#define SM_M_RES3        103                                /* MAG!X       */
#define SM_M_RES4        104                                /* MAG!X       */
#define SM_M_RES5        105                                /* MAG!X       */
#define SM_M_RES6        106                                /* MAG!X       */
#define SM_M_RES7        107                                /* MAG!X       */
#define SM_M_RES8        108                                /* MAG!X       */
#define SM_M_RES9        109                                /* MAG!X       */

/* SM_M_SPECIAL codes */

#define SMC_TIDY_UP		0							/* MagiC 2	*/
#define SMC_TERMINATE	1							/* MagiC 2	*/
#define SMC_SWITCH		2							/* MagiC 2	*/
#define SMC_FREEZE		3							/* MagiC 2	*/
#define SMC_UNFREEZE	4							/* MagiC 2	*/
#define SMC_RES5		5							/* MagiC 2	*/
#define SMC_UNHIDEALL	6							/* MagiC 3.1	*/
#define SMC_HIDEOTHERS	7							/* MagiC 3.1	*/
#define SMC_HIDEACT		8							/* MagiC 3.1	*/

/* AES wind_s/get()- Modes */

#define WF_ICONIFY       26                                 /* AES 4.1     */
#define WF_UNICONIFY     27                                 /* AES 4.1     */
#define WF_UNICONIFYXYWH 28                                 /* AES 4.1     */
#define WF_M_BACKDROP    100                                /* KAOS 1.4    */
#define WF_M_OWNER       101                                /* KAOS 1.4    */
#define WF_M_WINDLIST    102                                /* KAOS 1.4    */

/* Window definition */

#define HOTCLOSEBOX      0x1000                             /* GEM 2.x     */
#define BACKDROP         0x2000                             /* KAOS 1.4    */
#define ICONIFIER        0x4000                             /* AES 4.1     */
#define SMALLER ICONIFIER

/* wind_set(WF_DCOLOR) */

#define W_SMALLER        19                                 /* AES 4.1     */
#define W_BOTTOMER       20                                 /* MagiC 3     */

/* ob_flags */

#ifndef FL3DMASK
#define FL3DMASK     0x0600
#define FL3DNONE     0x0000
#define FL3DIND      0x0200	/* 3D Indicator			  AES 4.0		*/
#define FL3DBAK      0x0400	/* 3D Background			  AES 4.0		*/
#define FL3DACT      0x0600	/* 3D Activator			  AES 4.0		*/
#endif

/* objc_sysvar */

#ifndef LK3DIND
#define LK3DIND      1                                      /* AES 4.0     */
#define LK3DACT      2                                      /* AES 4.0     */
#define INDBUTCOL    3                                      /* AES 4.0     */
#define ACTBUTCOL    4                                      /* AES 4.0     */
#define BACKGRCOL    5                                      /* AES 4.0     */
#define AD3DVALUE    6                                      /* AES 4.0     */
#define MX_ENABLE3D  10                                     /* MagiC 3.0   */
#endif

/* MAG!X Object types  */

#define G_SWBUTTON       34                                 /* MAG!X       */
#define G_POPUP          35                                 /* MAG!X       */
#define G_RESVD1		36							/* MagiC 3.1	*/

typedef struct {
     char *string;                 /* etwa "TOS|KAOS|MAG!X"                */
     int  num;                     /* Nr. der aktuellen Zeichenkette       */
     int  maxnum;                  /* maximal erlaubtes <num>              */
     } SWINFO;

typedef struct {
     OBJECT *tree;                 /* Popup- MenÅ                          */
     int  obnum;                   /* aktuelles Objekt von <tree>          */
     } POPINFO;

/* Object states */

#define WHITEBAK         0x40                               /* TOS         */
#define DRAW3D           0x80                               /* GEM 2.x     */

/* extended appl_write structure */

typedef struct {
     int  dst_apid;
     int  unique_flg;
     void *attached_mem;
     int  *msgbuf;
     } XAESMSG;

/* form_xdo definitions */

typedef struct {
     char scancode;
     char nclicks;
     int  objnr;
     } SCANX;

typedef struct {
     SCANX *unsh;
     SCANX *shift;
     SCANX *ctrl;
     SCANX *alt;
     void  *resvd;
     } XDO_INF;

/* scrollable textedit objects */

typedef struct _xted {
	char		*xte_ptmplt;
	char		*xte_pvalid;
	WORD		xte_vislen;
	WORD		xte_scroll;
} XTED;

/* AES function prototypes */

void _appl_yield    ( void );                               /* TOS         */
int  vq_aes         ( void );                               /* TOS         */
void appl_yield     ( void );                               /* GEM 2.x     */
void appl_bvset     ( int  disks,  int harddisks );         /* GEM 2.x     */
void shel_rdef      ( char *cmd, char *dir );               /* GEM 2.x     */
void shel_wdef      ( char *cmd, char *dir );               /* GEM 2.x     */
int  menu_unregister( int menu_id );                        /* GEM 2.x     */
int  scrp_clear     ( void );                               /* GEM 2.x     */
int  xgrf_stepcalc  (                                       /* GEM 2.x     */
                      int orgw, int orgh,
                      int xc, int yc, int w, int h,
                      int *cx, int *cy,
                      int *stepcnt, int *xstep, int *ystep
                    );
int  xgrf_2box      (                                       /* GEM 2.x     */
                      int xc, int yc, int w, int h,
                      int corners, int stepcnt,
                      int xstep, int ystep, int doubled
                    );
int  menu_click     ( int val, int setit );                 /* GEM 3.x     */
int  form_popup     ( OBJECT *tree, int x, int y );         /* MAG!X       */

int  form_xerr      ( long errcode, char *errfile );        /* MAG!X       */
int  form_xdo       (                                       /* MAG!X       */
                      OBJECT *tree, int startob,
                      int *lastcrsr, XDO_INF *tabs,
                      void *flydial
                    );
int  form_xdial     (                                       /* MAG!X       */
                      int flag,
                      int ltx, int lty, int ltw, int lth,
                      int bgx, int bgy, int bgw, int bgh,
                      void **flydial
                    );

int graf_xhandle    (                                       /* KAOS 1.4    */
                      int *wchar, int *hchar,
                      int *wbox, int *hbox, int *dev
                    );

int objc_sysvar     ( int mode, int which,                  /* AES 4.0     */
                      int ival1, int ival2,
                      int *oval1, int *oval2
                     );
#endif
