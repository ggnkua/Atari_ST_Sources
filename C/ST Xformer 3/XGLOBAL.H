
/****************************************************************************

    XGLOBAL.H

    - contains of all global declarations and defines

    01/23/88 created
    
    05/14/89 13:40

****************************************************************************/

#ifndef XGLOBAL

#define XGLOBAL

#define xxxEBUG

#ifndef DEBUG

#define Assert(x,y)
#define Debug(x)
#define Alert(x)

#else   /* DEBUG */

#define Assert(x,y)     if (!(x)) _alert(y);
#define Debug(x)        x

#endif  /* DEBUG */

#define TRUE   ~0
#define FALSE   0

#define loop for(;;)

#define Blit(f,t)       _blit(f,t)
#define Blitb(f,t,cb)   _blitb(f,t,cb)
#define Blitbz(f,t,cb)  _blitbz(f,t,cb)
#define Blitw(f,t,cw)   _blitw(f,t,cw)
#define Blitwz(f,t,cw)  _blitwz(f,t,cw)
#define Blitl(f,t,cl)   _blitl(f,t,cl)
#define Blitlz(f,t,cl)  _blitlz(f,t,cl)
#define Blitc(ch,t,cb)  _blitc(ch,t,cb)
#define Blitcz(ch,t,cb) _blitcz(ch,t,cb)
#define Blitzb(t,cb)    _blitzb(t,cb)
#define Blitzw(t,cw)    _blitzw(t,cw)
#define Blitzl(t,cl)    _blitzl(t,cl)

extern char * _blit();
extern void _blitb(), _blitbz(), _blitw(), _blitwz(), _blitl(),
    _blitlz(), _blitc(), _blitcz(), _blitzb(), _blitzw(), _blitzl();

extern int  RunAt();
extern int  CchDisAsm();
extern int  CchShowRegs();
extern void PutReg();
extern int  GetReg();
extern void Push();
extern int  Pop();
extern void Poke();
extern int  Peek();

extern fn_nul();

extern int  fInMon;
extern int exit_code;

extern int reg_A, reg_Y, reg_X, reg_PC, reg_SP;
extern char reg_P, reg_N, reg_Z;

extern int fReboot;

extern long _base, _topstack;
extern _main();

extern execute(), do_execute();

extern char heap[];

/* these 4 blocks make up the heap */
extern long lWStat;    /* 64K block of write status bytes */
extern long lMemory;   /* 64K normal address space of 6502, 64K boundary */ 
extern long lScr;      /* 40K 8-bit screen */
extern char lMem0[];
extern char lWStat0[];
extern char lXLRAM[];
extern int  fXLRAM;		/* 0 = XL ROM, 1 = XL RAM */
extern char _rgDL[];    /* inital GR.0 screen */
extern char rgDL[];     /* Display List structures */

/* array of screen location pointers (16-bit) */
extern long lScrPtrs[];

extern long lEmul;     /* pointer to op00 */
long   lScrGEM;   /* pointer to desktop */
extern int fIsMono;    /* mono or color */

extern int fFastFP;    /* Fastchip FP option */
extern int fXCD;        /* Xformer Cable with D: */
extern int fXCP;        /* Xformer cable with P: */
extern int fBasic;     /* Atari BASIC option */
extern int mdFont;     /* 0 - 7 */
extern int uAtRAM;      /* maximum top of video RAM 40K or 48K */
extern int fTrace;

extern long qoldbank, rgqBank[8];

/* pointers to the 2 system fonts */
extern long lFont8, lFont16;

/* anytime we must force a reboot, this will disable Continue button */
extern int rgwPalette[16];

/* path and name of context file */
extern char pathXCX[12], nameXCX[80];

/* status bits of the P register: (6502)  NV_BDIZC */

#define NBIT 0x80
#define VBIT 0x40
#define BBIT 0x10
#define DBIT 0x08
#define IBIT 0x04
#define ZBIT 0x02
#define CBIT 0x01

/* status bits of the CCR register: (68000)  ___XNZVC */

#define BITV 0x02
#define BITN 0x08
#define BITZ 0x04
#define BITC 0x01
#define BITX 0x10

extern ROMA000(), ROMD000(), ROMC000(), ROMD800(), ROMFAST(), ROME000(),
    ROME200(), ROMCC00(), ROMCE00(), ROMCF00(), ROME400(), ROME800();

extern int rgwAtColors[16];

typedef struct
    {
    int  mode;
    int  h;
    int  fWP;
    int  wSectorMac;
    char *pbRAMdisk;
    char path[80];
    char name[12];
    } DRIVE;

#define MD_OFF  0
#define MD_SD   1
#define MD_ED   2
#define MD_DD   3
#define MD_QD   4
#define MD_HD   5
#define MD_RD   6
#define MD_35   7
#define MD_EXT  8

extern DRIVE rgDrives[8];

typedef struct
    {
    unsigned char ichid;
    unsigned char icdno;
    unsigned char iccmd;
    unsigned char icsta;
    unsigned char icbal;
    unsigned char icbah;
    unsigned char icptl;    
    unsigned char icpth;
    unsigned char icbll;
    unsigned char icblh;
    unsigned char icax1;
    unsigned char icax2;
    unsigned char icax3;
    unsigned char icax4;
    unsigned char icax5;
    unsigned char icax6;
    } IOCB;

#endif

