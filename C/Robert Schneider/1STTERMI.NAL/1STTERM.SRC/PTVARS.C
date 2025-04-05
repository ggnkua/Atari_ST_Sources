#include <gemobdef.h>
#include <osbind.h>

/*#define DEBUG 1*/

#define BUSERROR asm{MOVE.W #0, 0}
#define NOPS   asm{NOP}
#define WI_KIND (NAME|FULLER|CLOSER|MOVER|SIZER)
#define TRUE 1
#define FALSE 0

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

int auto_on,code,waiter,boxsuch,waittrue;
int modemon,jo_buff;
int vtoldx,vtoldy,vt52mode,vtrevers,vtwrap;
int onli_curs,onli_vt52;
int curs_on;
int jo_disk;
int jo_screen=1;
int jo_handle;
int jo_print;
int bremser;
int mouse_but;
int mouse_x;
int mouse_y;
int buf;
int wi_han1;
int wi_han_off;
int top_window;
int gl_xfull;
int gl_yfull;
int gl_wfull;
int gl_hfull;
int xcur;
int ycur;
int max_xcur;
int max_ycur;
int null_xcur;
int null_ycur;
int copyflag;
int w_up;
int s_up_x;
int s_up_y;
int s_up_w;
int s_up_h;
int s_down_x;
int s_down_y;
int s_down_w;
int s_down_h;
int xc_old;
int yc_old;
int online;
int out_string=0;
int redraw_w;
int redraw_h;
int title_anz;
int irq_menu=0;
int baud;
int xmode;
int rmode;
int data;
int stop;
int ucr;
int parity;
int mode;
int duplex;
int echo;
int transfer;
int lf_screen;
int lf_rs232;
int lf_disk;
int lf_print;

int old_hun,old_zehn,old_ein;

int *digi_flag[21];
int digi_index[21];

int profibox;
int login=1;
int main_da;
int sub_da;
int wh_main;
int main_anz;
int sub_anz;
int own_loaded=0;
int asc_loaded=0;

unsigned  digi[]={
   0X003F,
   0X0006,
   0X005B,
   0X004F,
   0X0066,
   0X006D,
   0X007D,
   0X0007,
   0X007F,
   0X006F              };

extern int MBUTTON(), MMOVE(), OLDMBUTT(), OLDMMOVE();
extern int MB(), MSX(), MSY(), MX1(), MX2(), MY1(), MY2();
extern int MX(), MY();
extern int IRQ_MENU();

long curs_adr;
long old_curs_adr;
long screenline=1280;
long line_a_var;
long buf_size;
long wholefree;
long *seconds;

char *reserved;
char *own_table;
char *iwn_table;
char *buf_start;
char *buf_point;
char *buf_end;
char *screen_base;
char *box_space;
char *STARTFONT;
char *SCREEN;
char * fkey[42];
char fbuffer[2000];
char fflag[42];
char jo_name[40];
char *menu[200];
char *numdoc[10];
char *nums[10];
char *regs[17];
char *boxstart;
char *cur_up,*cur_dn,*cur_lt,*cur_rt;
char space80[] = "                                                                                ";
char *space0;
char strich80[]= "------------------------------------------------------------------------------";
char cr_lf[] = "\15\12";
char windtitel[]="ATARI\277 1ST-TERMINAL V1.03 ";
char such1[100];
char such2[100];

char ALNOTOPEN[]="[3][Datei l„žt sich nicht ”ffnen !][Abbruch]";
char ALNOMEM[]  ="[3][Nicht genug Speicher frei !][Abbruch]";
char ALREAERR[] ="[3][Lesefehler !][Abbruch]";
char ALWRIERR[] ="[3][Schreibfehler !][Abbruch]";
char ALNOWIN[]  ="[3][Kann kein Window ”ffnen][Abbruch]"; 
char sound[]={
   0x00,0xef,0x01,0x00,0x02,0x00,0x03,0x00,
   0x04,0x00,0x05,0x00,0x06,0x00,0x07,0xfe,
   0x08,0x10,0x09,0x00,0x0a,0x00,0x0b,0x00,
   0x0c,0x10,0x0d,0x09,0xff,0x00
             };

char *autocode;

OBJECT * mainmenu;
OBJECT * deskmenu;
OBJECT * time__di;
OBJECT * rs232_di;
OBJECT * outputdi;
OBJECT * setup_di;
OBJECT * fkey_di;
OBJECT * transfer_di;
OBJECT * disk__di;
OBJECT * about_di;
OBJECT * proto_di;
OBJECT * kermitdi;
OBJECT * logon_di;
OBJECT * user__di;
OBJECT * finam_di;
OBJECT * help__di;
OBJECT * boxnr_di;
OBJECT * dial__di;
OBJECT * jornaldi;

GRECT window_box;

FDB screen;
FDB save;

struct  {
   int   mhide;
   int   mis;
   int   mshould;
   int   monline;
        }   mouse;



struct  {
   int index;
   int x1;
   int y1;
   int x2;
   int y2;
        } titles[20];

struct  {
   int index;
   int x1;
   int y1;
   int x2;
   int y2;
   int offset;
   int xcount;
   int ycount;
         } boxes[20];

typedef struct   {
   char  *ibuf;
   int   isize;
   int   ihd;
   int   itl;
   int   ilow;
   int   ihi;
         } IOREC;

IOREC old_io, new_io, *iorec;

int tasse[]={

   0X0000,0X0000,0X0000,0X0001,0X0000,

   0XEEE0,0XFFE0,0XFFE0,0XFFE0,0X7FF0,0XFFFF,0XFFFF,0XFFFF,
   0XFFFF,0XFFFF,0XFFFF,0XFFFE,0XFFF8,0XFFF8,0X7FF0,0X1FC0,

   0X0000,0X4440,0X6240,0X3280,0X1F80,0X3AE0,0X4616,0X707E,
   0X7FF2,0X7FF6,0X7FFC,0X7FF0,0X7FF0,0X3FE0,0X0F80,0X0000
            };


#ifdef DEBUG
dprintf(string,a,b,c,d,e,f,g)
long string,a,b,c,d,e,f,g;
{
   char s1[400];
   long strlen();

   sprintf(s1,string,a,b,c,d,e,f,g);
   Fwrite(3,strlen(s1),s1);
   Fwrite(3,2l,"\n\r");
}
#endif
