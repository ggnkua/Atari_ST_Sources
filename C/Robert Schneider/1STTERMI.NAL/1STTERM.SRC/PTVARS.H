#include <gemobdef.h>

/******************************************************************************/
/* WENN COLOR DEFINIERT IST, DANN TUT SICH WAS IM GETRIEBE                    */
/******************************************************************************/
/* #define COLOR 1 */
/******************************************************************************/

#define BUSERROR asm{MOVE.W #0, 0}
#define NOPS   asm{NOP}
#define WI_KIND (NAME|FULLER|CLOSER|MOVER|SIZER)
#define TRUE 1
#define FALSE 0

#define PFEIL graf_mouse(0,0l)
#define TASSE graf_mouse(255,tasse)

#define _COLOR 24
#define _LSTLIN 32
#define _LN_MASK 34
#define _WRT_MODE 36
#define _X1 38
#define _Y1 40
#define _X2 42
#define _Y2 44
#define _PATPTR 46
#define _PATMSK 50
#define _CLIP 54


/********* defines fÅr Auto-Logon-Prozedur *************/
#define  WAITSTRING  0X10
#define  WAITTIME    0X11
#define  SENDSTRING  0X20
#define  SENDFKEY    0X21

/********* SCREEN defines *****************************/
#ifdef COLOR
   #define  SXY   0x0000000l     /* x=0   y=0   */
   #define  SWH   0x28000C8l     /* w=640 h=200 */
   #define  SMXY  0x13b0061l     /* x=315 y=97  */
   #define  SMWH  0x00a0005l     /* w=10  h=10  */
   #define  VTXY  0x000000Cl     /* x=0   y=12  */
   #define  VTWH  0x28000BCl     /* w=640 h=188 */
#else
   #define  SXY   0x0000000l     /* x=0   y=0   */
   #define  SWH   0x2800190l     /* w=640 h=400 */
   #define  SMXY  0x13b00c3l     /* x=315 y=195 */
   #define  SMWH  0x00a000al     /* w=10  h=10  */
   #define  VTXY  0x0000018l     /* x=0   y=24  */
   #define  VTWH  0x2800178l     /* w=640 h=376 */
#endif

extern int boxsuch,waittrue,dtr;
extern int modemon,autoda,jo_buff,auto_on,code,waiter;
extern int onli_curs,vtoldx,vtoldy,vt52mode,vtwrap,vtrevers;
extern int debug,filnamcnv,image,when_cr,curs_on;
extern int jo_disk, jo_screen, jo_handle, jo_print;
extern int bremser,own_loaded,asc_loaded;
extern int mouse_but, mouse_x, mouse_y;
extern int buf,onli_vt52;
extern int wi_han1, wi_han_off, top_window,wh_main;
extern int gl_xfull, gl_yfull, gl_wfull, gl_hfull;
extern int xcur, ycur, max_xcur, max_ycur, null_xcur, null_ycur;
extern int w_up,copyflag;
extern int s_up_x, s_up_y, s_up_w,  s_up_h;
extern int s_down_x, s_down_y, s_down_w, s_down_h;
extern int xc_old, yc_old;
extern int online;
extern int out_string;
extern int redraw_w, redraw_h;
extern int title_anz;
extern int irq_menu,alert_akt;
extern int baud, xmode, rmode, data, stop, ucr, parity;
extern int mode, duplex, transfer, echo;
extern int lf_screen, lf_rs232, lf_disk, lf_print;
extern int vdi_handle;
extern int work_out[];
extern int MBUTTON(), MMOVE(), OLDMBUTT(), OLDMMOVE();
extern int MB(), MSX(), MSY(), MX1(), MX2(), MY1(), MY2();
extern int MX(), MY();
extern int IRQ_MENU();
extern int ALERT_AKT();
extern int tasse[];

extern int old_hun,old_zehn,old_ein;

extern int *digi_flag[];
extern int digi_index[];

extern int profibox,login,main_da,sub_da,main_anz,sub_anz;

extern unsigned  digi[];

extern long line_a_var;
extern long buf_size;
extern long wholefree;
extern long screenline=1280l;    /* Bytes pro Bildschirmzeile */
extern long curs_adr;            /* Bildschirmadr des Cursors */
extern long old_curs_adr;	 /* 		  des alten Cursors */
extern long *seconds;

extern char such1[100];
extern char such2[100];
extern char space80[];
extern char *space0;
extern char cr_lf[];
extern char strich80[];
extern char *reserved;
extern char *buf_point;
extern char *buf_end;
extern char *buf_start;
extern char *screen_base;
extern char *box_space;
extern char *STARTFONT, *SCREEN;
extern char *fkey[],fbuffer[],fflag[];
extern char jo_name[];
extern char screen_table[][], key_table[][];
extern char *menu[];
extern char *boxstart;
extern char *own_table;
extern char *iwn_table;
extern char *numdoc[], *nums[], *regs[];
extern char *cur_up,*cur_dn,*cur_lt,*cur_rt;
extern char ALNOTOPEN[],ALNOMEM[],ALREAERR[],ALWRIERR[];
extern char sound[];
extern unsigned char *autocode;
extern char windtitel[];

extern OBJECT *mainmenu,*time__di,*rs232_di,*outputdi,*fsel__di,*setup_di;
extern OBJECT *fkey_di,*transfer_di,*about_di,*disk__di,*proto_di,*kermitdi;
extern OBJECT *alert_di,*alert_ic,*finam_di,*logon_di,*user__di,*boxnr_di;
extern OBJECT *help__di,*dial__di,*jornaldi,*deskmenu;

extern GRECT window_box;
extern FDB screen, save;

typedef struct   {
   char* ibuf;
   int   isize;
   int   ihd;
   int   itl;
   int   ilow;
   int   ihi;
         } IOREC;

extern IOREC old_io, new_io, *iorec;

extern struct  {
   int index;
   int x1;
   int y1;
   int x2;
   int y2;
        } titles[];

extern struct  {
   int index;
   int x1;
   int y1;
   int x2;
   int y2;
   int offset;
   int xcount;
   int ycount;
         } boxes[];

extern struct  {
   int   mhide;
   int   mis;
   int   mshould;
   int   monline;
        }   mouse;
