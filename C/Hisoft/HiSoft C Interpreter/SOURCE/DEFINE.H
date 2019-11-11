#define ROOT      0
#define MAX_DEPTH 10
#define MU_KEYBD  0x0001   
#define MU_BUTTON 0x0002
#define MU_M1     0x0004
#define MU_M2     0x0008
#define MU_MESAG  0x0010
#define MU_TIMER  0x0020
#define MN_SELECTED 10
#define WM_REDRAW   20
#define WM_TOPPED   21
#define WM_CLOSED   22
#define WM_FULLED   23
#define WM_ARROWED  24
#define WM_HSLID    25
#define WM_VSLID    26
#define WM_SIZED    27
#define WM_MOVED    28
#define WM_NEWTOP   29
#define FMD_START  0
#define FMD_GROW   1
#define FMD_SHRINK 2
#define FMD_FINISH 3
#define R_TREE      0
#define R_OBJECT    1
#define R_TEDINFO   2
#define R_ICONBLK   3
#define R_BITBLK    4
#define R_STRING    5      /* gets pointer to free strings */
#define R_IMAGEDATA 6      /* gets pointer to free images */
#define R_OBSPEC    7
#define R_TEPTEXT   8      /* sub ptrs in TEDINFO */
#define R_TEPTMPLT  9
#define R_TEPVALID 10
#define R_IBPMASK  11      /* sub ptrs in ICONBLK */
#define R_IBPDATA  12
#define R_IBPTEXT  13
#define R_BIPDATA  14      /* sub ptrs in BITBLK  */
#define R_FRSTR    15      /* gets addr of ptr to free strings */
#define R_FRIMG    16      /* gets addr of ptr to free images */
#define NAME    0x0001
#define CLOSER  0x0002
#define FULLER  0x0004
#define MOVER   0x0008
#define INFO    0x0010
#define SIZER   0x0020
#define UPARROW 0x0040
#define DNARROW 0x0080
#define VSLIDE  0x0100
#define LFARROW 0x0200
#define RTARROW 0x0400
#define HSLIDE  0x0800
#define WF_KIND       1
#define WF_NAME       2
#define WF_INFO       3
#define WF_WORKXYWH   4
#define WF_CURRXYWH   5
#define WF_PREVXYWH   6
#define WF_FULLXYWH   7
#define WF_HSLIDE     8
#define WF_VSLIDE     9
#define WF_TOP       10
#define WF_FIRSTXYWH 11
#define WF_NEXTXYWH  12
#define WF_RESVD     13
#define WF_NEWDESK   14
#define WF_HSLSIZE   15
#define WF_VSLSIZE   16
#define WF_SCREEN    17
#define   END_UPDATE 0
#define   BEG_UPDATE 1
#define   END_MCTRL  2
#define   BEG_MCTRL  3
#define   ARROW       0
#define   BUSYBEE     2
#define   HOURGLASS  2
#define   M_OFF     256
#define   M_ON      257
#define MD_REPLACE 1
#define MD_TRANS   2
#define MD_XOR     3
#define MD_ERASE   4
#define G_BOX      20
#define G_TEXT     21
#define G_BOXTEXT  22
#define G_IMAGE    23
#define G_USERDEF  24
#define G_IBOX     25
#define G_BUTTON   26
#define G_BOXCHAR  27
#define G_STRING   28
#define G_FTEXT    29
#define G_FBOXTEXT 30
#define G_ICON     31
#define G_TITLE    32
#define NONE       0x0000
#define SELECTABLE 0x0001
#define DEFAULT    0x0002
#define EXIT       0x0004
#define EDITABLE   0x0008
#define RBUTTON    0x0010
#define LASTOB     0x0020
#define TOUCHEXIT  0x0040
#define HIDETREE   0x0080
#define INDIRECT   0x0100
#define NORMAL   0x0000
#define SELECTED 0x0001
#define CROSSED  0x0002
#define CHECKED  0x0004
#define DISABLED 0x0008
#define OUTLINED 0x0010
#define SHADOWED 0x0020
typedef struct object
{
  short          ob_next;    /* -> object's next sibling */
  short          ob_head;    /* -> head of object's children */
  short          ob_tail;    /* -> tail of object's children */
  unsigned short ob_type;    /* type of object- BOX, CHAR,... */
  unsigned short ob_flags;   /* flags  */
  unsigned short ob_state;   /* state- SELECTED, OPEN, ...  */
  long           ob_spec;    /* "out"- -> anything else  */
  short          ob_x;       /* upper left corner of object */
  short          ob_y;       /* upper left corner of object */
  short          ob_width;   /* width of object */
  short          ob_height;  /* height of object */
} OBJECT;
typedef struct grect
{
  short   g_x;
  short   g_y;
  short   g_w;
  short   g_h;
} GRECT;
typedef struct text_edinfo
{
  long  te_ptext;     /* ptr to text (must be 1st) */
  long  te_ptmplt;    /* ptr to template */
  long  te_pvalid;    /* ptr to validation chrs. */
  short te_font;      /* font */
  short te_junk1;     /* junk short */
  short te_just;      /* justification- left, right... */
  short te_color;     /* color information short */
  short te_junk2;     /* junk short */
  short te_thickness; /* border thickness */
  short te_txtlen;    /* length of text string */
  short te_tmplen;    /* length of template string */
} TEDINFO;
typedef struct fdbstr
{
  long  fd_addr;
  short fd_w;
  short fd_h;
  short fd_wdwidth;
  short fd_stand;
  short fd_nplanes;
  short fd_r1;
  short fd_r2;
  short fd_r3;
} FDB;
#define VOID   /**/
#define BOOLEAN int
#define BYTE   unsigned char
#define WORD   short
#define LONG   long
#define TRUE   1
#define FALSE  0
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<=(b)?(a):(b))
#define abs(a) ((a)>=0?(a):-(a))
extern BYTE   *strcpy();
extern BYTE   *strncpy();
extern BYTE   *strcat();
extern BYTE   *strncat();
extern LONG bios();
extern LONG xbios();
extern LONG gemdos();
#define Cconin()       gemdos(0x1)
#define Cconout(a)     gemdos(0x2,a)
#define Cauxin()       gemdos(0x3)
#define Cauxout(a)     gemdos(0x4,a)
#define Cprnout(a)     gemdos(0x5,a)
#define Crawio(a)      gemdos(0x6,a)
#define Crawcin()      gemdos(0x7)
#define Cnecin()       gemdos(0x8)
#define Cconws(a)      gemdos(0x9,a)
#define Cconrs(a)      gemdos(0x0a,a)
#define Cconis()       gemdos(0x0b)
#define Dsetdrv(a)     gemdos(0x0e,a)
#define Cconos()       gemdos(0x10)
#define Cprnos()       gemdos(0x11)
#define Cauxis()       gemdos(0x12)
#define Cauxos()       gemdos(0x13)
#define Dgetdrv()      gemdos(0x19)
#define Fsetdta(a)     gemdos(0x1a,a)
#define Tgetdate()     gemdos(0x2a)
#define Tsetdate(a)    gemdos(0x2b,a)
#define Tgettime()     gemdos(0x2c)
#define Tsettime(a)    gemdos(0x2d,a)
#define Dfree(a,b)     gemdos(0x36,a,b)
#define Dcreate(a)     gemdos(0x39,a)
#define Ddelete(a)     gemdos(0x3a,a)
#define Dsetpath(a)    gemdos(0x3b,a)
#define Fcreate(a,b)   gemdos(0x3c,a,b)
#define Fopen(a,b)     gemdos(0x3d,a,b)
#define Fclose(a)      gemdos(0x3e,a)
#define Fread(a,b,c)   gemdos(0x3f,a,b,c)
#define Fwrite(a,b,c)  gemdos(0x40,a,b,c)
#define Fdelete(a)     gemdos(0x41,a)
#define Fseek(a,b,c)   gemdos(0x42,a,b,c)
#define Fattrib(a,b,c) gemdos(0x43,a,b,c)
#define Dgetpath(a,b)  gemdos(0x47,a,b)
#define Malloc(a)      gemdos(0x48,a)
#define malloc(a)      ((BYTE*)gemdos(0x48,a))
#define Mfree(a)       gemdos(0x49,a)
#define Frename(a,b,c) gemdos(0x56,a,b,c)
#define Fdatime(a,b,c) gemdos(0x57,a,b,c)
#define Physbase()             ((BYTE*)xbios(2))
#define Logbase()              xbios(3)
#define Getrez()               xbios(4)
#define Setscreen(a,b,c)       xbios(5,a,b,c)
#define Setpallete(a)          xbios(6,a)
#define Setcolor(a,b)          xbios(7,a,b)
#define Floprd(a,b,c,d,e,f,g)  xbios(8,a,b,c,d,e,f,g)
#define Flopwr(a,b,c,d,e,f,g)  xbios(9,a,b,c,d,e,f,g)
#define Midiws(a,b)            xbios(12,a,b)
#define Mfpint(a,b)            xbios(13,a,b)
#define Iorec(a)               xbios(14,a)
#define Rsconf(a,b,c,d,e,f)    xbios(15,a,b,c,d,e,f)
#define Keytbl(a,b,c)          xbios(16,a,b,c)
#define Random()               xbios(17)
#define Protobt(a,b,c,d)       xbios(18,a,b,c,d)
#define Flopver(a,b,c,d,e,f,g) xbios(19,a,b,c,d,e,f,g)
#define Prtblk()               xbios(20)
#define Cursconf(a,b)          xbios(21,a,b)
#define Settime(a)             xbios(22,a)
#define Gettime()              xbios(23)
#define Bioskeys()             xbios(24)
#define Ikbdws(a,b)            xbios(25,a,b)
#define Jdisint(a)             xbios(26,a)
#define Jenabint(a)            xbios(27,a)
#define Giaccess(a,b)          xbios(28,a,b)
#define Offgibit(a)            xbios(29,a)
#define Ongibit(a)             xbios(30,a)
#define Xbtimer(a,b,c,d)       xbios(31,a,b,c,d)
#define Dosound(a)             xbios(32,a)
#define Setprt(a)              xbios(33,a)
#define Kbdvbase()             xbios(34)
#define Kbrate(a,b)            xbios(35,a,b)
#define Vsync()                xbios(37)
