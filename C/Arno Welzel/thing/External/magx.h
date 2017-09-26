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

#define Sconfig(a,b)    gemdos(0x33, (int) (a), (long) (b)) /* KAOS 1.2 */
/* extern long Sconfig(int mode, long value); */
#define Fshrink(a)      Fwrite(a, 0L, (void *) -1L)         /* KAOS 1.2 */
#define Mgrow(a,b)      Mshrink(a,b)                        /* KAOS 1.2 */
#define Mblavail(a)     Mshrink(a,-1L)                      /* KAOS 1.2 */

/* Sconfig - Modes */

#define SC_GET   0                                          /* KAOS 1.2 */
#define SC_SET   1                                          /* KAOS 1.2 */
#define SC_VARS  2                                          /* KAOS 1.4 */

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
     } MAGX_COOKIE;

/* tail for default shell */

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
#define SHW_SHUTDOWN     4                                  /* AES 3.3     */
#define SHW_RESCHNG      5                                  /* AES 3.3     */
#define SHW_INFRECGN     9                                  /* AES 4.0     */
#define SHW_AESSEND      10                                 /* AES 4.0     */

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
#define CH_EXIT          90                                 /* MultiTOS    */
#define WM_M_BDROPPED    100                                /* KAOS 1.4    */
#define SM_M_RES1        101                                /* MAG!X       */
#define SM_M_RES2        102                                /* MAG!X       */
#define SM_M_RES3        103                                /* MAG!X       */
#define SM_M_RES4        104                                /* MAG!X       */
#define SM_M_RES5        105                                /* MAG!X       */
#define SM_M_RES6        106                                /* MAG!X       */
#define SM_M_RES7        107                                /* MAG!X       */
#define SM_M_RES8        108                                /* MAG!X       */
#define SM_M_RES9        109                                /* MAG!X       */

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

int objc_sysvar     ( int mode, int which,                  /* AES 4.0     */
                      int ival1, int ival2,
                      int *oval1, int *oval2
                     );
