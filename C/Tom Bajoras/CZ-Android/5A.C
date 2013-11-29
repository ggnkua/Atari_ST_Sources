/*........................ include header files ..............................*/

#include <vdibind.h>    /* VDI stuff */
#include <gemdefs.h>    /* AES stuff */
#include <obdefs.h>     /* more AES stuff */
#include <osbind.h>     /* GEMDOS, BIOS, XBIOS stuff */
#include <taddr.h>      /* OB macros */
#include <portab.h>     
#include <machine.h>    /* LW macros */
#include <cz_andrd.h>   /* created by RCS */

#include <defines.h>
#include <externs.h>

/*............................. editor global variables ......................*/

int edlines[169]= {   /* lines within edit window */
0,87,639,87,      0,143,639,143,    0,144,639,144,   /* big horizontal lines */
216,31,216,143,    424,31,424,143,                  /* big vertical lines */
126,144,126,199,  127,144,127,199,  128,144,128,199, /* small vertical lines */
254,144,254,199,  255,144,255,199,  256,144,256,199,
382,144,382,199,  383,144,383,199,  384,144,384,199,
511,144,511,199,  512,144,512,199,  513,144,513,199,
0,43,136,43,      136,43,136,31,                  /* boxes for envelope text */
216,43,352,43,    352,43,352,31,
424,43,560,43,    560,43,560,31,
0,99,136,99,      136,99,136,87,
216,99,352,99,    352,99,352,87,
424,99,560,99,    560,99,560,87,
19,144,19,156,    19,156,109,156,   109,156,109,144,   /* smaller boxes */
161,144,161,156,  161,156,225,156,  225,156,225,144,
291,144,291,156,  291,156,350,156,  350,156,350,144, 
460,144,460,199,  384,178,510,178,  410,156,510,156,   410,156,410,199,
800};  /* signals end of array */

/* zoom box coordinates */
int zoomxy[48]= {188,32,216,32,216,45,188,45,     /* DCO 1 */
                 396,32,424,32,424,45,396,45,     /* DCW 1 */
                 611,32,639,32,639,45,611,45,     /* DCA 1 */
                 188,88,216,88,216,101,188,101,   /* DCO 2 */
                 396,88,424,88,424,101,396,101,   /* DCW 2 */
                 611,88,639,88,639,101,611,101};  /* DCA 2 */

long zoomdata[12]={0xfffffff0,0xe0000030,0xecfff9b0,0xef3fe7b0,
                   0xefcf9fb0,0xeff07fb0,0xefffffb0,0xefffffb0,
                   0xefffffb0,0xe0000030,0xfffffff0,0xfffffff0};
long truerast[24],testrast[24];
int eddata[810]={    /* data structure for numerical editing */

589,159,32,8,1,3,   589,175,16,8,1,2,   355,166,8,8,1,1,   355,196,16,8,0,60,
355,176,8,8,0,3,    355,186,16,8,0,11,  200,166,32,8,1,3,  207,176,16,8,0,99,
207,186,16,8,0,99,  207,196,16,8,0,99,  411,177,48,20,1,7, 461,177,48,20,1,8,
102,186,8,8,0,9,    102,166,8,8,0,9,    438,84,184,4,1,7,  
439,62,16,8,0,99,   439,78,16,8,0,99,   463,62,16,8,0,99,   463,78,16,8,0,99,
487,62,16,8,0,99,   487,78,16,8,0,99,   511,62,16,8,0,99,   511,78,16,8,0,99,
535,62,16,8,0,99,   535,78,16,8,0,99,   559,62,16,8,0,99,   559,78,16,8,0,99,
583,62,16,8,0,99,   583,78,16,8,0,99,   607,62,16,8,0,99,   607,78,16,8,0,99,
438,84,184,4,1,8,   230,84,184,4,1,7,
229,62,16,8,0,99,   229,78,16,8,0,99,   253,62,16,8,0,99,   253,78,16,8,0,99,
277,62,16,8,0,99,   277,78,16,8,0,99,   301,62,16,8,0,99,   301,78,16,8,0,99,
325,62,16,8,0,99,   325,78,16,8,0,99,   349,62,16,8,0,99,   349,78,16,8,0,99,
373,62,16,8,0,99,   373,78,16,8,0,99,   397,62,16,8,0,99,   397,78,16,8,0,99,
230,84,184,4,1,8,   14,84,184,4,1,7,
15,62,16,8,0,99,    15,78,16,8,0,99,    39,62,16,8,0,99,    39,78,16,8,0,99,
63,62,16,8,0,99,    63,78,16,8,0,99,    87,62,16,8,0,99,    87,78,16,8,0,99,
111,62,16,8,0,99,   111,78,16,8,0,99,   135,62,16,8,0,99,   135,78,16,8,0,99,
159,62,16,8,0,99,   159,78,16,8,0,99,   183,62,16,8,0,99,   183,78,16,8,0,99,
14,84,184,4,1,8,    411,198,48,19,1,7,  461,198,48,19,1,8,  102,196,8,8,0,9,
102,176,8,8,0,9,    438,140,184,4,1,7,
439,118,16,8,0,99,  439,134,16,8,0,99,  463,118,16,8,0,99,  463,134,16,8,0,99,
487,118,16,8,0,99,  487,134,16,8,0,99,  511,118,16,8,0,99,  511,134,16,8,0,99,
535,118,16,8,0,99,  535,134,16,8,0,99,  559,118,16,8,0,99,  559,134,16,8,0,99,
583,118,16,8,0,99,  583,134,16,8,0,99,  607,118,16,8,0,99,  607,134,16,8,0,99,
438,140,184,4,1,8,  230,140,184,4,1,7,
229,118,16,8,0,99,  229,134,16,8,0,99,  253,118,16,8,0,99,  253,134,16,8,0,99,
277,118,16,8,0,99,  277,134,16,8,0,99,  301,118,16,8,0,99,  301,134,16,8,0,99,
325,118,16,8,0,99,  325,134,16,8,0,99,  349,118,16,8,0,99,  349,134,16,8,0,99,
373,118,16,8,0,99,  373,134,16,8,0,99,  397,118,16,8,0,99,  397,134,16,8,0,99,
230,140,184,4,1,8,  14,140,184,4,1,7,
15,118,16,8,0,99,   15,134,16,8,0,99,   39,118,16,8,0,99,   39,134,16,8,0,99,
63,118,16,8,0,99,   63,134,16,8,0,99,   87,118,16,8,0,99,   87,134,16,8,0,99,
111,118,16,8,0,99,  111,134,16,8,0,99,  135,118,16,8,0,99,  135,134,16,8,0,99,
159,118,16,8,0,99,  159,134,16,8,0,99,  183,118,16,8,0,99,  183,134,16,8,0,99,
14,140,184,4,1,8,   589,191,40,8,1,2,
/* cz-1 parameters */
348,83,16,8,0,15,   348,93,16,8,0,15,   348,103,16,8,0,15,   348,72,16,8,0,15,
426,83,16,8,0,15,   426,93,16,8,0,15,   426,103,16,8,0,15,   426,72,16,8,0,15};
   
char ednorm[135],wsnorm[135];               /* edit buffer */
char levsave[6];                /* overwritten L(end) */
char sustsave[6];               /* overwritten sustain point */

/* rasters */
long vibwv0[8]={0x04000000,0x0e00000c,0x1b01801c,0x3183000c,
                0x60c6000c,0xc06c000c,0x0038000c,0x0010003f};               
long vibwv1[8]={0x00038000,0x000f801e,0x00398033,0x00e18003,
                0x03818006,0x0e01800c,0x38018018,0xe001803f};
long vibwv2[8]={0xe0000000,0xf000003f,0xdc000006,0xc700000c,
                0xc1c00006,0xc0700003,0xc01c0033,0xc007001e};
long vibwv3[8]={0xffe03000,0xc0603006,0xc060300e,0xc060301e,
                0xc0603036,0xc060303f,0xc0603006,0xc07ff006};
int dcowv8[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x01c0,
                0x0000,0x0000,0x0220,    0x0000,0x0000,0x0220,
                0x0000,0x0000,0x0220,    0x0000,0x0000,0x01c0,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv0[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0020,
                0x0000,0x0000,0x0060,    0x0007,0x0000,0x0020,
                0x0007,0xc000,0x0020,    0x0006,0x7000,0x0020,
                0x0006,0x1c00,0x0000,    0x0006,0x0700,0x0000,
                0x0006,0x01c0,0x0000,    0x0006,0x0070,0x0000,
                0x0006,0x001c,0x0000,    0x0006,0x0007,0x0000,
                0x0006,0x0001,0xc000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv1[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x03c0,
                0x0000,0x0000,0x0020,    0x0003,0xff80,0x01c0,
                0x0003,0x0180,0x0200,    0x0003,0x0180,0x03e0,
                0x0003,0x0180,0x0000,    0x0003,0x0180,0x0000,
                0x0003,0x0180,0x0000,    0x0003,0x0180,0x0000,
                0x0003,0x0180,0x0000,    0x0003,0x0180,0x0000,
                0x0003,0x01ff,0xc000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv2[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x03c0,
                0x0002,0x0000,0x0020,    0x0002,0x0000,0x01c0,
                0x0007,0x0000,0x0020,    0x0005,0x0000,0x03c0,
                0x000d,0x8000,0x0000,    0x0008,0x8000,0x0000,
                0x0018,0xc000,0x0000,    0x0010,0x4000,0x0000,
                0x0030,0x6000,0x0000,    0x0020,0x2000,0x0000,
                0x0040,0x3fff,0xfc00,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv3[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0060,
                0x0010,0x0070,0x00a0,    0x0010,0x0088,0x0120,
                0x0038,0x018c,0x01f0,    0x0028,0x0104,0x0020,
                0x006c,0x0306,0x0000,    0x0044,0x0202,0x0000,
                0x00c6,0x0603,0x0000,    0x0082,0x0c01,0x8000,
                0x0183,0x0800,0x8000,    0x0101,0x1000,0x4000,
                0x0200,0xe000,0x3800,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv4[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x01e0,
                0x0000,0x0000,0x0100,    0x0000,0xf800,0x01e0,
                0x0003,0x9800,0x0010,    0x0006,0x1800,0x01e0,
                0x001c,0x1800,0x0000,    0x0030,0x1800,0x0000,
                0x0060,0x1800,0x0000,    0x00c0,0x1800,0x0000,
                0x00c0,0x1800,0x0000,    0x0180,0x1800,0x0000,
                0x0180,0x1fff,0xe000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv5[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x00e0,
                0x0000,0x0000,0x0100,    0x0030,0x0000,0x01e0,
                0x0048,0x2000,0x0110,    0x0048,0x5000,0x00e0,
                0x0048,0x5040,0x0000,    0x0048,0x50a0,0x0000,
                0x0048,0x5091,0x8000,    0x0084,0x8912,0x4000,
                0x0084,0x8912,0x4400,    0x0084,0x8912,0x4a00,
                0x0084,0x8912,0x4a00,    0x0303,0x060c,0x3180,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv6[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x01f0,
                0x0000,0x0000,0x0010,    0x0000,0x1818,0x0020,
                0x0000,0x2424,0x0040,    0x0000,0x2424,0x0040,
                0x0008,0x2424,0x1000,    0x0014,0x2424,0x2800,
                0x0014,0x2424,0x2800,    0x0022,0x4242,0x4400,
                0x0222,0x4242,0x4440,    0x0522,0x4242,0x44a0,
                0x0522,0x4242,0x44a0,    0x18c1,0x8181,0x8318,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
int dcowv7[60]={0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x00e0,
                0x0000,0x0000,0x0110,    0x0060,0x6060,0x00e0,
                0x0090,0x9090,0x0110,    0x0090,0x9090,0x00e0,
                0x0090,0x9090,0x4000,    0x0090,0x9090,0xa000,
                0x0090,0x9090,0xa000,    0x0109,0x0909,0x1000,
                0x0109,0x0909,0x1100,    0x0109,0x0909,0x1280,
                0x0109,0x0909,0x1280,    0x0606,0x0606,0x0c60,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000,
                0x0000,0x0000,0x0000,    0x0000,0x0000,0x0000};
                
FDB edfdb;    /* source memory form definition block for rasters */
int xyarray[8];   /* used in raster operations */
int color[2]= {1,0};   /* colors for raster operations */
int Ndiffer;      /* # of parameters that have been edited */
extern int offset;   /* imported from zoom() */
extern int keylock;

/*...................... process menu choice = edit ..........................*/

edit()
{
   register int i;

   undoslot();

/* get and save WS window size and location */
   wind_get(ws_hand,WF_CURRXYWH,&ws_x,&ws_y,&ws_w,&ws_h);
/* get rid of WS window */
   wind_close(ws_hand);
   wind_delete(ws_hand);
/* expand into edit window */
   graf_growbox(ws_x,ws_y,ws_w,ws_h,work_x,work_y,work_w,work_h);
   ws_hand= wind_create(WI_KIND2,work_x,work_y,work_w,work_h);
   top_hand= ws_hand;
/* title */
   strcpy(edittitl,&" Editing: ");
   strcat(edittitl,ws_dat);
   strcat(edittitl,&" ");   
   wind_set(ws_hand,WF_NAME,edittitl,0);
/* info line */
   edited= 1;
   for (i=0; i<=79; i++) editline[i]=' ';
   strcpy(editline,&" Edited  ");   editline[9]=' ';
   strcpy(&editline[57],&"parameter(s) edited.");
   wind_open(ws_hand,work_x,work_y,work_w,work_h);

   copybyte(&ws_dat[17],ednorm,135);  /* start with workspace=editspace */
   copybyte(&ws_dat[17],wsnorm,135);
   monedit(ednorm);               /* send edited to CZ if monitoring is on */

/* start with no parameters edited */
   Ndiffer=0;
   for (i=0; i<=5; i++)
   { levsave[i]=0;  sustsave[i]=9;  }

/* activate/deactivate menu items */
   menu_ienable(menuaddr,FILETOA,0);
   menu_ienable(menuaddr,FILETOB,0);
   menu_ienable(menuaddr,ATOFILE,0);
   menu_ienable(menuaddr,BTOFILE,0);
   menu_ienable(menuaddr,RENAME,0);
   menu_ienable(menuaddr,ERASE,0);
   menu_ienable(menuaddr,FORMAT,0);
   menu_ienable(menuaddr,BEGIN,0);
   menu_ienable(menuaddr,COMPARE,1);
   menu_ienable(menuaddr,CPSWLINE,1);
   menu_ienable(menuaddr,CPSWENVS,1);
   menu_ienable(menuaddr,UNDOEDIT,1);
   if (syntype==2) menu_ienable(menuaddr,CZ1PARS,1);
   menu_ienable(menuaddr,BANK,0);
   menu_ienable(menuaddr,INIT,1);
   menu_ienable(menuaddr,DISTORT,1);
   menu_ienable(menuaddr,DROID,1);
   menu_ienable(menuaddr,SAFETY,0);
   menu_ienable(menuaddr,QUITQUIT,0);
/* set edit mode flag =2 means we are going into edit mode 
   do_mesage() will set editmode=1 when edit window contents have been drawn */
   editmode= 2;

} /* end edit() */
/*.......................handle exiting from editor...........................*/

quitedit()
{
   int exit_obj;

   if (ndiffer())
   {
      exit_obj= form_alert(1,CHEKEXIT);
      if (exit_obj==1) return;   /* cancel */
      if (exit_obj==2)           /* keep */
         copybyte(ednorm,&ws_dat[17],135);
   }   
/* activate/deactivate menu items */
   menu_ienable(menuaddr,FILETOA,1);
   menu_ienable(menuaddr,FILETOB,1);
   menu_ienable(menuaddr,ATOFILE,1);
   menu_ienable(menuaddr,BTOFILE,1);
   menu_ienable(menuaddr,RENAME,1);
   menu_ienable(menuaddr,ERASE,1);
   menu_ienable(menuaddr,FORMAT,1);
   menu_ienable(menuaddr,BEGIN,1);
   menu_ienable(menuaddr,COMPARE,0);
   menu_ienable(menuaddr,CPSWLINE,0);
   menu_ienable(menuaddr,CPSWENVS,0);
   menu_ienable(menuaddr,UNDOEDIT,0);
   menu_ienable(menuaddr,CZ1PARS,0);
   menu_ienable(menuaddr,BANK,1);
   menu_ienable(menuaddr,INIT,0);
   menu_ienable(menuaddr,DISTORT,0);
   menu_ienable(menuaddr,DROID,0);
   menu_ienable(menuaddr,SAFETY,1);
   menu_ienable(menuaddr,QUITQUIT,1);

/* get rid of edit window */
   wind_close(ws_hand);
   wind_delete(ws_hand);
/* shrink into WS window */
   graf_shrinkbox(ws_x,ws_y,ws_w,ws_h,work_x,work_y,work_w,work_h);
/* re-create WS window */
   ws_hand= wind_create(WI_KIND,ws_x,ws_y,ws_w,ws_h);
   wind_set(ws_hand,WF_NAME," Workspace ",0);   
   top_hand= ws_hand;
   wind_open(ws_hand,ws_x,ws_y,ws_w,ws_h);
   
/* set edit mode flag = 3 meaning we are leaving editor 
   do_mesage() will reset flag to 0 after ws window has been redrawn */
   editmode= 3;
   wind_update(3);
   keylock=1;

} /* end quitedit() */

/*.......................handle menu choice= monitor..........................*/

monitor()
{
   if (editmon)       /* turn monitoring off */
   {
      editmon=0;
      menu_icheck(menuaddr,MONITOR,0);
   }
   else               /* turn monitoring on */
   {
      editmon=1;
      menu_icheck(menuaddr,MONITOR,1);
      if (editmode)
      {
         if (edited)
            monedit(ednorm);
         else
            monedit(wsnorm);
      }
   }
} /* end monitor() */

/*.......................handle menu choice= compare..........................*/

compare()
{
   char codebuf[4];

   if (edited)      /* going to original version */
   {
      edited=0;
      menu_ienable(menuaddr,CPSWLINE,0);
      menu_ienable(menuaddr,CPSWENVS,0);
      menu_ienable(menuaddr,UNDOEDIT,0);
      menu_ienable(menuaddr,CZ1PARS,0);
      menu_ienable(menuaddr,INIT,0);
      menu_ienable(menuaddr,DISTORT,0);
      menu_ienable(menuaddr,DROID,0);
      monedit(wsnorm);
      strcpy(editline,&" Original");   editline[9]=' ';
   }
   else             /* going to edited version */
   {
      edited=1;
      menu_ienable(menuaddr,CPSWLINE,1);
      menu_ienable(menuaddr,CPSWENVS,1);
      menu_ienable(menuaddr,UNDOEDIT,1);
      if (syntype==2) menu_ienable(menuaddr,CZ1PARS,1);
      menu_ienable(menuaddr,INIT,1);
      menu_ienable(menuaddr,DISTORT,1);
      menu_ienable(menuaddr,DROID,1);
      monedit(ednorm);
      strcpy(editline,&" Edited  ");   editline[9]=' ';
   }    
   redraw(ws_hand,0,0,0,0);
} /* end compare() */

/*.......................handle menu choice= cpswline.........................*/

cpswline()
{
   int i;
   int exit_obj,fromenvx,toenvx;
   long tree,fromarea,toarea,from_cz1,to_cz1;
   char codebuf[4],temp;
   
   sel_obj(lineaddr,FROMLIN1);
   desel_obj(lineaddr,FROMLIN2);
   sel_obj(lineaddr,TOLINE1);
   desel_obj(lineaddr,TOLINE2);
   exit_obj= do_dial(lineaddr,CZLINES,-1);  /* czlines dialog */
   if (exit_obj==CANLINE) return; 

   tree= lineaddr;  /* tree needed by macros */
   if (LWGET(OB_STATE(FROMLIN1)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TOLINE1)) & SELECTED) return;
      fromarea= &ednorm[10];   toarea= &ednorm[68];   /* from=1, to=2 */
      from_cz1= &ednorm[127];  to_cz1= &ednorm[131];
      fromenvx= 0;    toenvx= 3;
   }
   else
   {
      if (LWGET(OB_STATE(TOLINE2)) & SELECTED) return;
      fromarea= &ednorm[68];   toarea= &ednorm[10];   /* from=2, to=1 */
      from_cz1= &ednorm[131];  to_cz1= &ednorm[127];
      fromenvx= 3;    toenvx= 0;
   }
   if (exit_obj==COPYLINE) 
   {
      copybyte(fromarea,toarea,58);
      copybyte(from_cz1,to_cz1,4);
      for (i=0; i<=2; i++)
      {   levsave[toenvx+i] = levsave[fromenvx+i];
          sustsave[toenvx+i]= sustsave[fromenvx+i];   }
   }
   else
   {
      swapbyte(fromarea,toarea,58);
      swapbyte(from_cz1,to_cz1,4);
      for (i=0; i<=2;  i++)
      {
         temp=levsave[toenvx+i]; levsave[toenvx+i]=levsave[fromenvx+i];
         levsave[fromenvx+i]=temp;
         temp=sustsave[toenvx+i]; sustsave[toenvx+i]=sustsave[fromenvx+i];
         sustsave[fromenvx+i]=temp;
      }
   }
   monedit(ednorm);
   Ndiffer= ndiffer();
   wind_get(dummy,WF_TOP,&i,&dummy,&dummy,&dummy);
   if (i==ws_hand)   /* no desk acc window on top */
   {
      vs_clip(gl_hand,0,&dummy);
      v_hide_c(gl_hand);
      for (i=0; i<=126; i++)
         outpar(ednorm,i);
      encode(codebuf,Ndiffer,3,0);
      v_gtext(gl_hand,432,27*rez+2,codebuf);
      v_show_c(gl_hand,0);
   }
   else        /* desk acc window on top */
      redraw(ws_hand,0,0,0,0);
} /* end cpswline() */

/*.......................handle menu choice= cpswenvs.........................*/

cpswenvs()
{
   int i;
   int exit_obj,start1x,start2x,fromenvx,toenvx;
   long tree,fromarea,toarea;
   char codebuf[4],temp;

   sel_obj(envsaddr,FROMDCO1);
   desel_obj(envsaddr,FROMDCO2);
   desel_obj(envsaddr,FROMDCW1);
   desel_obj(envsaddr,FROMDCW2);
   desel_obj(envsaddr,FROMDCA1);
   desel_obj(envsaddr,FROMDCA2);
   sel_obj(envsaddr,TODCO1);
   desel_obj(envsaddr,TODCO2);
   desel_obj(envsaddr,TODCW1);
   desel_obj(envsaddr,TODCW2);
   desel_obj(envsaddr,TODCA1);
   desel_obj(envsaddr,TODCA2);
   exit_obj= do_dial(envsaddr,CZENVS,-1);   /* czenvs dialog */
   if (exit_obj==CANENVS) return; 

   tree= envsaddr;  /* tree needed by macros */
   if (LWGET(OB_STATE(FROMDCO1)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCO1)) & SELECTED) return;
      fromarea= &ednorm[50];   start1x=50;      fromenvx= 0;
   }
   if (LWGET(OB_STATE(FROMDCO2)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCO2)) & SELECTED) return;
      fromarea= &ednorm[108];   start1x=108;    fromenvx= 3;
   }
   if (LWGET(OB_STATE(FROMDCW1)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCW1)) & SELECTED) return;
      fromarea= &ednorm[32];   start1x=32;    fromenvx= 1;
   }
   if (LWGET(OB_STATE(FROMDCW2)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCW2)) & SELECTED) return;
      fromarea= &ednorm[90];   start1x=90;    fromenvx= 4;
   }
   if (LWGET(OB_STATE(FROMDCA1)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCA1)) & SELECTED) return;
      fromarea= &ednorm[14];   start1x=14;    fromenvx= 2;
   }
   if (LWGET(OB_STATE(FROMDCA2)) & SELECTED) 
   {
      if (LWGET(OB_STATE(TODCA2)) & SELECTED) return;
      fromarea= &ednorm[72];   start1x=72;    fromenvx= 5;
   }
   if (LWGET(OB_STATE(TODCO1)) & SELECTED) 
   {
      toarea= &ednorm[50];   start2x=50;    toenvx= 0;
   }
   if (LWGET(OB_STATE(TODCO2)) & SELECTED) 
   {
      toarea= &ednorm[108];   start2x=108;    toenvx= 3;
   }
   if (LWGET(OB_STATE(TODCW1)) & SELECTED) 
   {
      toarea= &ednorm[32];   start2x=32;    toenvx= 1;
   }
   if (LWGET(OB_STATE(TODCW2)) & SELECTED) 
   {
      toarea= &ednorm[90];   start2x=90;    toenvx= 4;
   }
   if (LWGET(OB_STATE(TODCA1)) & SELECTED) 
   {
      toarea= &ednorm[14];   start2x=14;    toenvx= 2;
   }
   if (LWGET(OB_STATE(TODCA2)) & SELECTED) 
   {
      toarea= &ednorm[72];   start2x=72;    toenvx= 5;
   }
   if (exit_obj==COPYENVS) 
   {
      copybyte(fromarea,toarea,18);
      levsave[toenvx]=  levsave[fromenvx];
      sustsave[toenvx]= sustsave[fromenvx];
   }
   else
   {
      swapbyte(fromarea,toarea,18);
      temp=levsave[toenvx];   levsave[toenvx]=levsave[fromenvx];
      levsave[fromenvx]=temp;
      temp=sustsave[toenvx];   sustsave[toenvx]=sustsave[fromenvx];
      sustsave[fromenvx]=temp;
   }
   monedit(ednorm);
   wind_get(dummy,WF_TOP,&i,&dummy,&dummy,&dummy);
   if (i==ws_hand)   /* no desk acc window on top */
   {
      v_hide_c(gl_hand);
      if (exit_obj==COPYENVS)
      {
         for (i=0; i<=17; i++)
            outpar(ednorm,start2x+i);
      }
      else
      {
         for (i=0; i<=17; i++)
            outpar(ednorm,start1x+i);
         for (i=0; i<=17; i++)
            outpar(ednorm,start2x+i);
      }      
      vs_clip(gl_hand,0,&dummy);
      i=ndiffer();
      if (i!=Ndiffer)
      {
         encode(codebuf,i,3,0);
         v_gtext(gl_hand,432,27*rez+2,codebuf);
         Ndiffer=i;
      }
      v_show_c(gl_hand,0);
   }
   else        /* desk acc window on top */
   {
      Ndiffer=ndiffer();
      redraw(ws_hand,0,0,0,0);
   }
} /* end cpswenvs() */

/* EOF */
