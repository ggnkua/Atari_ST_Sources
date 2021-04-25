/************************************************************************/
/* AR20_CNF.C                 by Bill Penner           28 November 1987 */
/************************************************************************/
/* Configuration program for AREAL20.ACC accessory for the ATARI ST.    */
/*                                                                      */
/*                            Bill Penner                               */
/*                            3235 Wright Avenue                        */
/*                            Bremerton, WA  98310                      */
/*                                                                      */
/************************************************************************/

#include <stdio.h>
#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "ar20pipe.h"

/*------------------------- Built in RSC file --------------------------*/

/* Color Buttons */
#define ME_TOP    0
#define ME_C0     1
#define ME_C1     2
#define ME_C2     3
#define ME_C3     4
#define ME_C4     5
#define ME_C5     6
#define ME_C6     7
#define ME_C7     8
#define ME_C8     9
#define ME_C9    10
#define ME_CA    11
#define ME_CB    12
#define ME_CC    13
#define ME_CD    14
#define ME_CE    15
#define ME_CF    16
#define ME_CSEL  34
/* Operation Buttons */
#define ME_LOAD  17
#define ME_SAVE  18
#define ME_CRED  19
#define ME_QUIT  20
/* Assorted Options */
#define ME_BCLK  23
#define ME_BBEL  24
#define ME_TIME  25
#define ME_DATE  26
#define ME_24H   27
#define ME_TWOL  28
#define ME_PX    30
#define ME_PY    31
#define ME_UPDAT 32
#define ME_SET   33

#define CREDOK    9

char STR00[] = "Save Config",
     STR01[] = "Load Config",
     STR02[] = "Credits",
     STR03[] = "Quit",
     STR04[] = "Clock",
     STR05[] = "No Bell",
     STR06[] = "Do when booting:",
     STR07[] = "Time",
     STR08[] = "Date",
     STR09[] = "12 Hour",
     STR10[] = "Two Line",
     STR11[] = "Position:",
     STR12[] = "___",
     STR13[] = "Y: ___",
     STR14[] = "999",
     STR15[] = "__",
     STR16[] = "X: __",
     STR17[] = "99",
     STR18[] = "____",
     STR19[] = "Update Int (mS): ____",
     STR20[] = "9999",
     STR21[] = "Color:",
     STR22[] = "Make Settings",
     BLK00[] = "";

char STR30[] = "A-Real Time Clock Customizer",
     STR31[] = "Version 2.02",
     STR32[] = "Written by:",
     STR33[] = "Bill Penner",
     STR34[] = "3235 Wright Avenue",
     STR35[] = "Bremerton, WA 98310",
     STR36[] = "OK",
     STR37[] = "A-Real Time Clock is entered",
     STR38[] = "into the public domain.  This",
     STR39[] = "program is not to be sold.";

TEDINFO TED00[] = {STR11,BLK00,BLK00, 3, 6, 0, 0x1180, 0x0, 255, 10, 1};
TEDINFO TED01[] = {STR12,STR13,STR14, 3, 6, 0, 0x1180, 0x0, 255,  4, 7};
TEDINFO TED02[] = {STR15,STR16,STR17, 3, 6, 0, 0x1180, 0x0, 255,  3, 6};
TEDINFO TED03[] = {STR18,STR19,STR20, 3, 6, 0, 0x1180, 0x0, 255,  5,22};
TEDINFO TED04[] = {STR21,BLK00,BLK00, 3, 6, 0, 0x1180, 0x0, 255,  7, 1};

OBJECT medial[] = {
-1,  1, 35, G_BOX,    NONE,       OUTLINED, 0xFF1143L,  0,   0, 36, 17,
 2, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1170L,  2,  11,  2,  1,
 3, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1171L,  4,  11,  2,  1,
 4, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1172L,  6,  11,  2,  1,
 5, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1173L,  8,  11,  2,  1,
 6, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1174L, 10,  11,  2,  1,
 7, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1175L, 12,  11,  2,  1,
 8, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1176L, 14,  11,  2,  1,
 9, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1177L, 16,  11,  2,  1,
10, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1178L, 18,  11,  2,  1,
11, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x1179L, 20,  11,  2,  1,
12, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117AL, 22,  11,  2,  1,
13, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117BL, 24,  11,  2,  1,
14, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117CL, 26,  11,  2,  1,
15, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117DL, 28,  11,  2,  1,
16, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117EL, 30,  11,  2,  1,
17, -1, -1, G_BOX,    TOUCHEXIT,  NORMAL,     0x117FL, 32,  11,  2,  1,
18, -1, -1, G_BUTTON, 0x5,        NORMAL,       STR01,  2,  13, 12,  1,
19, -1, -1, G_BUTTON, 0x5,        NORMAL,       STR00,  2,  15, 12,  1,
20, -1, -1, G_BUTTON, 0x5,        NORMAL,       STR02, 22,  13, 12,  1,
21, -1, -1, G_BUTTON, 0x5,        NORMAL,       STR03, 22,  15, 12,  1,

25, 22, 24, G_BOX,    NONE,       NORMAL,   0xFF1100L, 12,   1, 22,  3,
23, -1, -1, G_STRING, NONE,       NORMAL,       STR06,  3,   0, 16,  1,
24, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR04,  0,   2, 10,  1,
21, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR05, 12,   2, 10,  1,

26, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR07,  2,   1,  8,  1,
27, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR08,  2,   3,  8,  1,
28, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR09,  2,   7,  8,  1,
29, -1, -1, G_BUTTON, SELECTABLE, NORMAL,       STR10,  2,   5,  8,  1,
30, -1, -1, G_TEXT,   NONE,       NORMAL,       TED00, 12,   5,  9,  1,
31, -1, -1, G_FTEXT,  EDITABLE,   NORMAL,       TED02, 22,   5,  5,  1,
32, -1, -1, G_FTEXT,  EDITABLE,   NORMAL,       TED01, 28,   5,  6,  1,
33, -1, -1, G_FTEXT,  EDITABLE,   NORMAL,       TED03, 13,   7, 21,  1,
34, -1, -1, G_BUTTON, 0x7,        NORMAL,       STR22, 18,   9, 16,  1,
35, -1, -1, G_BOX,    NONE,       NORMAL,     0x1179L, 10,   9,  5,  1,
 0, -1, -1, G_TEXT,   LASTOB,     NORMAL,       TED04,  2,   9,  6,  1 };

OBJECT creddial[] = {
-1,  1, 13, G_BOX,    NONE,       OUTLINED,   0x1143L,  0,   0, 36, 13,
 4,  2,  3, G_BOX,    NONE,       SHADOWED, 0xFD1100L, 	2,   1, 32,  2,
 3, -1, -1, G_STRING, NONE,       NORMAL,       STR30,  2,   0, 28,  1,
 1, -1, -1, G_STRING, NONE,       NORMAL,       STR31, 10,   1, 12,  1,
 9,  5,  8, G_BOX,    NONE,       SHADOWED, 0xFD1100L,  2,   4, 24,  4,
 6, -1, -1, G_STRING, NONE,       NORMAL,       STR32,  1,   0, 11,  1,
 7, -1, -1, G_STRING, NONE,       NORMAL,       STR33,  3,   1, 11,  1,
 8, -1, -1, G_STRING, NONE,       NORMAL,       STR34,  3,   2, 18,  1,
 4, -1, -1, G_STRING, NONE,       NORMAL,       STR35,  3,   3, 19,  1,
13, 10, 12, G_BOX,    NONE,       SHADOWED, 0xFD1100L,  2,   9, 32,  3,
11, -1, -1, G_STRING, NONE,       NORMAL,       STR37,  2,   0, 29,  1,
12, -1, -1, G_STRING, NONE,       NORMAL,       STR38,  2,   1, 26,  1,
 9, -1, -1, G_STRING, NONE,       NORMAL,       STR39,  2,   2, 28,  1,
 0, -1, -1, G_BUTTON, 0x27,       SHADOWED,     STR36, 29,   5,  5,  2 };

#define  MENUM    36
#define  CREDNUM  14

/*------------------------- End of RSC file ----------------------------*/

extern int  gl_apid;
extern char str();

int    msg[8],rply[8];   /* Send and Receive messages */
int    acchand;          /* Address of the AREAL acc  */
int    ret;              /* Junk and temp use thingy  */
int    color;
int    updat;
int    opflag;
int    px,py;
int    xywh[4];

main()
  {
  int cmd,i,contfg;

  appl_init();

  acchand = appl_find("AREAL20 ");          /* Find the AREAL20 acc  */
  if (acchand < 0) acchand = appl_find("AR20NCLK");
  if (acchand < 0) form_alert(1,"[3][Must have AREAL20 or AR20NCLK |Accessory Loaded ][ Reboot with AREAL20]");
  else /* AREAL20 accessory found */
    {
    for(i=0;i<MENUM;i++)   rsrc_obfix(medial,i);   /* Obfix MENU    */
    for(i=0;i<CREDNUM;i++) rsrc_obfix(creddial,i); /* Obfix CREDITS */
    for(i=0;i<8;i++) msg[i] = 0;

    /* Force clock on if not already */
    send_msg(ENCLKD,1);
    
    init_set();
    graf_mouse(ARROW,0L);
    di_show(creddial,0);            /* Show credit on opening */
    di_open(medial,xywh,0,0,0,0);   /* Open up the main dial  */
    set_color(color);

    contfg = TRUE;
    while(contfg)
      {
      graf_mouse(ARROW,0L);
      cmd = form_do(medial,ME_PX) & 0x7FFF;
      graf_mouse(BUSYBEE,0L);
      if(cmd <= ME_CF) set_color(cmd - ME_C0);
      else
        {
        switch(cmd)
          {
          case ME_SAVE: save_file();     break;
          case ME_LOAD: load_file();     break;
          case ME_QUIT: contfg = FALSE;  break;
          case ME_SET:  set_params();    break;
          case ME_CRED:
            graf_mouse(ARROW,0L);
            di_close(xywh,0,0,0,0);
            di_show(creddial,0);
            di_open(medial,xywh,0,0,0,0);
            break;
          default:                       break;
          }
        di_desel(medial,cmd);
        objc_draw(medial,cmd,0,xywh[0],xywh[1],xywh[2],xywh[3]);
        }
      }
    di_close(xywh,0,0,0,0);
    }
  appl_exit();
  }

/************************************************************************/
/* Tell ACC to save the file                                            */
/************************************************************************/

save_file()
  {
  if(form_alert(1,"[0][Place disk in boot drive ][ OK |Cancel]") == 1)
    send_msg(WCFIG,10);
  }

/************************************************************************/
/* Tell ACC to load the file                                            */
/************************************************************************/

load_file()
  {
  if(form_alert(1,"[0][Place disk in boot drive ][ OK |Cancel]") == 1)
    {
    if(send_msg(RCFIG,10))
      {
      if(rply[3] == rply[5])
        {
        init_set();
        objc_draw(medial,ME_TOP,10,xywh[0],xywh[1],xywh[2],xywh[3]);
        }
      else if (rply[3] == 0) form_alert(1,"[0][AREAL20.INF not found ][ OK ]");
      else form_alert(1,"[0][AREAL20.INF file old version ][ OK ]");
      }
    }
  }

/************************************************************************/
/* Initialize Values                                                    */
/************************************************************************/

init_set()
  {
  /* Go set up the present settings */
  if(send_msg(RPARAM,1)) /* Get the OPFLAG value */
    {
    opflag = rply[3];
    px     = (rply[5] >> 9) & 127;
    py     = rply[5] & 511;
    updat  = rply[6];
    color  = rply[7];

    if(opflag & CKENAB)  di_sel(medial,ME_BCLK);
    else               di_desel(medial,ME_BCLK);
    if(opflag & DATEFG)  di_sel(medial,ME_DATE);
    else               di_desel(medial,ME_DATE);
    if(opflag & TIMEFG)  di_sel(medial,ME_TIME);
    else               di_desel(medial,ME_TIME);
    if(opflag & TWOLINE) di_sel(medial,ME_TWOL);
    else               di_desel(medial,ME_TWOL);
    if(opflag & TWELVE)  di_sel(medial,ME_24H);
    else               di_desel(medial,ME_24H);
    if(opflag & NOBELL)  di_sel(medial,ME_BBEL);
    else               di_desel(medial,ME_BBEL);

    cvrt_itoa(STR15,2,px);
    cvrt_itoa(STR12,3,py);
    cvrt_itoa(STR18,4,updat * 5);
    }
  }

/************************************************************************/
/* Set up the color display                                             */
/************************************************************************/

set_color(a)
int a;
  {
  int i;

  color = a;
  medial[ME_CSEL].ob_spec = medial[a + ME_C0].ob_spec;
  objc_draw(medial,ME_CSEL,0,xywh[0],xywh[1],xywh[2],xywh[3]);
  }

/************************************************************************/
/* Routine to send the message to the AREAL accessory                   */
/************************************************************************/

send_msg(cmd,a)
int cmd,a;
  {
  int event;

  msg[0] = cmd;      /* Pipe Command Value    */
  msg[1] = gl_apid;  /* Our application num   */
  msg[2] = 0;        /* Excess message length */
  msg[4] = acchand;  /* AREAL Address         */
  appl_write(acchand,16,msg);

  rply[0] = 0;
  event = 0;
  while((msg[0] != rply[0]) && (event != MU_TIMER))
    {
    event = evnt_multi(MU_MESAG | MU_TIMER, 1,1,1, 0,0,0,0,0, 0,0,0,0,0,
                       rply,a * 0x3E8,0,&ret,&ret,&ret,&ret,&ret,&ret);
    }
  if(event == MU_TIMER)
    {
    form_alert(1,"[0][Accessory NOT Communicating][HUH?]");
    return(FALSE);
    }
  return(TRUE);
  }

/***********************************************************************/
/* Set up the clock paramters to writing out                           */
/***********************************************************************/

set_params()
  {
  send_msg(DISCLKD,1);

  px    = cvrt_atoi(STR15);
  py    = cvrt_atoi(STR12);
  updat = cvrt_atoi(STR18) / 5;

  opflag = 0;
  if(di_issel(medial,ME_BCLK)) opflag |= CKENAB;
  if(di_issel(medial,ME_BBEL)) opflag |= NOBELL;
  if(di_issel(medial,ME_TIME)) opflag |= TIMEFG;
  if(di_issel(medial,ME_DATE)) opflag |= DATEFG;
  if(di_issel(medial,ME_24H )) opflag |= TWELVE;
  if(di_issel(medial,ME_TWOL)) opflag |= TWOLINE;

  msg[3] = opflag;
  msg[5] = ((px & 127) << 9) | (py & 511);
  msg[6] = updat;
  msg[7] = color;

  send_msg(WPARAM,1);
  send_msg(ENCLKD,1);
  }

/***********************************************************************/
/* Integer - ASCII conversion routines                                 */
/***********************************************************************/

int cvrt_atoi(a)
char *a;
  {
  int i,j;

  i = 0;
  j = 0;

  while((a[i] != 0) && ((a[i] == '_') || (a[i] == 32))) i += 1;
  while((a[i] != 0) && (a[i] >= '0') && (a[i] <= '9'))
    j = j * 10 + a[i++] - '0';

  return(j);
  }

cvrt_itoa(a,b,c)
char *a;
int  b,c;
  {
  a[b--] = 0;
  while(b >= 0)
    {
    a[b--] = c % 10 + '0';
    c = c / 10;
    }
  }

/************************************************************************/
/* Object handling routines                                             */
/************************************************************************/

/***************************************/
/* Display and close a dialog box      */
/***************************************/

int di_exe(di_tree,f_text)
OBJECT *di_tree;
int    f_text;
  {
  int di_xywh[4],di_i;

  di_open(di_tree,di_xywh,0,0,0,0);
  di_i = form_do(di_tree,f_text);
  di_close(di_xywh,0,0,0,0);

  return(di_i);
  }

/***************************************/
/* Display and reset button            */
/***************************************/

int di_show(di_tree,f_text)
OBJECT *di_tree;
int    f_text;
  {
  int di_i;

  di_i = di_exe(di_tree,f_text);
  di_desel(di_tree,di_i);

  return(di_i);
  }

/***************************************/
/* Open dialog box                     */
/***************************************/

di_open(di_tree,di_xywh,di_x,di_y,di_w,di_h)
OBJECT *di_tree;
int    *di_xywh,di_x,di_y,di_w,di_h;
  {
  form_center(di_tree,&di_xywh[0],&di_xywh[1],&di_xywh[2],&di_xywh[3]);
  form_dial(0,di_x,di_y,di_w,di_h,di_xywh[0],di_xywh[1],di_xywh[2],di_xywh[3]);
  form_dial(1,di_x,di_y,di_w,di_h,di_xywh[0],di_xywh[1],di_xywh[2],di_xywh[3]);
  objc_draw(di_tree,0,10,di_xywh[0],di_xywh[1],di_xywh[2],di_xywh[3]);
  }

/***************************************/
/* Close dialog tree                   */
/***************************************/

di_close(di_xywh,di_x,di_y,di_w,di_h)
int    *di_xywh,di_x,di_y,di_w,di_h;
  {
  form_dial(2,di_x,di_y,di_w,di_h,di_xywh[0],di_xywh[1],di_xywh[2],di_xywh[3]);
  form_dial(3,di_x,di_y,di_w,di_h,di_xywh[0],di_xywh[1],di_xywh[2],di_xywh[3]);
  }

/***************************************/
/* Select an object                    */
/***************************************/

di_sel(di_tree,di_but)
OBJECT *di_tree;
int    di_but;
  {
  di_tree[di_but].ob_state |= SELECTED;
  }

/***************************************/
/* Deselect an object                  */
/***************************************/

di_desel(di_tree,di_but)
OBJECT *di_tree;
int    di_but;
  {
  di_tree[di_but].ob_state &= (~SELECTED);
  }

/***************************************/
/* Check if object selected            */
/***************************************/

int di_issel(di_tree,di_but)
OBJECT *di_tree;
int    di_but;
  {
  return(di_tree[di_but].ob_state & SELECTED)? TRUE: FALSE;
  }






