/* Demonstration program to illustrate the use of popup menus. (c) 1991 by
   Andrew Brown. Copying and distribution subject to the restrictions laid
   out in the main documentation

  COMPILER: Lattice 'C' V5
     NOTES: File is fully prototyped, you can use the -rr option */


#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stddef.h>
#include "popup.h"     /* vital file: you must include this */
#include "demo.h"      /* this contains the popup menu source */


#define TRUE 1          /* These really should be standard defines */
#define FALSE 0

#define KBD_ALTA 0x1e00   /* keyboard scan codes */
#define KBD_ALTC 0x2e00
#define KBD_ALTQ 0x1000
#define KBD_ALTD 0x2000
#define KBD_ALTH 0x2300


int main(void);                         /* Function prototypes */
int topmenu_choice(int,int);
int topmenu_useitem(MITEM *,int);
int handle_keybd(int);
void do_events(void);
void menu_switch(int);


extern int PopupMenu_Index;       /* These are vital if you are using a */
extern int PopupMenu_X;           /* popup menu as your top bar */
extern int PopupMenu_Y;


int ws_handle;                              /* VDI Workstation handle */
int CH_HEIGHT,CH_WIDTH,SCR_W,SCR_H;         /* Screen/character sizes */
int NPLANES,MENUDISP;                       /* Colour planes/menu disp */
char *topmenu_bar="  Desk  File  Options";  /* Our menu bar */


/****************************/
/* Main program starts here */
/****************************/

int main(void)
{
int work_in[11]={1,1,1,1,1,1,1,1,1,1,2};
int work_out[57],dummy;

  if(appl_init()<0)           /* tell AES I exist */
  {
    puts("Cannot initialise application");
    Crawcin();
    exit(-1);
  }
  ws_handle=graf_handle(&dummy,&dummy,&dummy,&dummy);
  v_opnvwk(work_in,&ws_handle,work_out);    /* open VDI workstation */
  if(!ws_handle)
  {
    form_alert(1,"[1][Cannot open workstation][Abort]");
    return(appl_exit());
  }
  graf_mouse(ARROW,NULL);

  CH_WIDTH=8;
  SCR_W=work_out[0]+1;
  SCR_H=work_out[1]+1;
  switch(Getrez())        /* some variables must be set */
  {
    case 0:               /* Low resolution */
      NPLANES=4;
      CH_HEIGHT=8;
      MENUDISP=1;
      break;
    case 1:               /* Medium resolution */
      NPLANES=2;
      CH_HEIGHT=8;
      MENUDISP=1;
      break;
    case 2:               /* High resolution */
      NPLANES=1;
      CH_HEIGHT=16;
      SCR_W=640;
      SCR_H=400;
      MENUDISP=2;
  }

  PopupInit(work_out[0]+1,work_out[1]+1,ws_handle);  /* initialise popups */
  PopupRegister(topmenu_bar);     /* register my menu bar */

  do_events();          /* central program function */

  v_clsvwk(ws_handle);    /* close virtual work station */
  return(appl_exit());    /* quit, returning an exit code */
}

/*************************/
/* Main program function */
/*************************/

void do_events(void)
{
int mx,my,dummy,events,key,code;

  menu_switch(TRUE);            /* display top menu bar */
  code=TRUE;
  do
  {
    events=evnt_multi(MU_KEYBD|MU_M1,0,0,0,
                        0,0,0,SCR_W,CH_HEIGHT+MENUDISP,
                        0,0,0,0,0,
                        0L,
                        0,0,
                        &mx,&my,&dummy,&dummy,&key,&dummy);
    if(events & MU_KEYBD) code=handle_keybd(key);   /* keyboard event */
    if(events & MU_M1) code=topmenu_choice(mx,my);  /* mouse in menu bar */
  } while(code);

  menu_switch(FALSE);
}

/*******************/
/* Handle keypress */
/*******************

This is a good example of how to implement keyboard shortcuts to the menu
options. */

int handle_keybd(key)
int key;
{
  switch(key)
  {
    case KBD_ALTA:
      return(topmenu_useitem(MENU_DESK,ITM_ABOUT));
    case KBD_ALTC:
      return(topmenu_useitem(MENU_FILE,ITM_CHECKME));
    case KBD_ALTQ:
      return(topmenu_useitem(MENU_FILE,ITM_QUIT));
    case KBD_ALTD:
      return(topmenu_useitem(MENU_OPTIONS,ITM_DROPDOWN));
    case KBD_ALTH:
      return(topmenu_useitem(MENU_OPTIONS,ITM_HOLDDOWN));
  }
}

/*******************************/
/* handle top line menu choice */
/*******************************

You may use this function as it stands, by calling in the manner above.
All you must do is change or add to the case statements that select the
appropriate menu tree. Note that FALSE is returned if QUIT is selected
from the menu, otherwise TRUE is returned */


int topmenu_choice(mx,my)
int mx,my;
{
int mx1,pxyarray[4],dummy,item,menu,index;
MITEM *tree;

  vs_clip(ws_handle,FALSE,pxyarray);
  vsf_color(ws_handle,BLACK);
  vsf_interior(ws_handle,FIS_SOLID);
  vsf_style(ws_handle,8);
  pxyarray[1]=1;
  pxyarray[3]=CH_HEIGHT+MENUDISP;

  while(my<CH_HEIGHT+2)
  {
    mx/=CH_WIDTH;
    if(topmenu_bar[mx]==' ' || mx>strlen(topmenu_bar)-1) return(TRUE);

    while(topmenu_bar[--mx]!=' ');
    mx1=++mx;
    while(topmenu_bar[mx1]!=' ' && topmenu_bar[mx1]) mx1++;
    pxyarray[0]=(mx-1)*CH_WIDTH;
    pxyarray[2]=(mx1+1)*CH_WIDTH;
    vswr_mode(ws_handle,MD_XOR);
    graf_mouse(M_OFF,0L);
    vr_recfl(ws_handle,pxyarray);
    graf_mouse(M_ON,0L);
    vswr_mode(ws_handle,MD_REPLACE);

    for(menu=index=0;;)
    {
      while(topmenu_bar[menu++]==' ');
      menu--;
      if(menu==mx) break;
      index++;
      while(topmenu_bar[menu++]!=' ');
    }
    PopupMenu_Index=index;
    switch(index)
    {
      case 0:
        tree=MENU_DESK;
        break;
      case 1:
        tree=MENU_FILE;
        break;
      case 2:
        tree=MENU_OPTIONS;
        break;
    }
    PopupMenu_X=(mx-1)*CH_WIDTH;
    PopupMenu_Y=CH_HEIGHT+2;
    item=PopupMenu(tree,TRUE,TRUE);
    vswr_mode(ws_handle,MD_XOR);
    graf_mouse(M_OFF,0L);
    vr_recfl(ws_handle,pxyarray);
    graf_mouse(M_ON,0L);
    vswr_mode(ws_handle,MD_REPLACE);
    if(item!=-1) break;
    graf_mkstate(&mx,&my,&dummy,&dummy);
  }
  return(topmenu_useitem(tree,item));
}

/***************************/
/* Use the top menu choice */
/***************************

You may use this function 'as is' without modifying it's structure at all.
All you should do is change/add to the 'else if' list, and insert the
appropriate case statements. Do not use one huge case list as some of the
menu item indices are likely to be the same. In this case, FALSE is returned
if 'Quit' is selected, else FALSE is returned */


int topmenu_useitem(tree,item)
MITEM *tree;
int item;
{
  if(tree==MENU_DESK && item==ITM_ABOUT)
    form_alert(1,"[1][Popup demo program, written|by Andrew Brown 1991.][ Okay ]");
  else if(tree==MENU_FILE)
  {
    switch(item)
    {
      case ITM_CHECKME:
        tree[ITM_CHECKME].flags^=MCHECKED;
        break;
      case ITM_QUIT:
        if(form_alert(1,"[2][Really quit ?][ Quit | Cancel ]")==1) return(FALSE);
        break;
    }
  }
  else if(tree==MENU_OPTIONS)
  {
    switch(item)
    {
      case ITM_DROPDOWN:
        menu_switch(FALSE);                     /* top menu off */
        PopupMenu(MENU_DROPDOWN,TRUE,FALSE);    /* handle popup */
        menu_switch(TRUE);                      /* top menu back on */
        break;
      case ITM_HOLDDOWN:
        menu_switch(FALSE);
        PopupMenu(MENU_HOLDDOWN,FALSE,FALSE);
        menu_switch(TRUE);
        break;
    }
  }
  return(TRUE);     /* 'Quit' not selected, so return TRUE */
}

/******************************/
/* Top line menu bar switcher */
/******************************/

void menu_switch(flag)
int flag;
{
int pxyarray[4];

  vs_clip(ws_handle,FALSE,pxyarray);
  vswr_mode(ws_handle,MD_REPLACE);
  graf_mouse(M_OFF,NULL);
  pxyarray[0]=pxyarray[1]=0;
  pxyarray[2]=SCR_W-1;
  pxyarray[3]=CH_HEIGHT;
  vsf_color(ws_handle,WHITE);
  vsf_style(ws_handle,FIS_SOLID);
  vr_recfl(ws_handle,pxyarray);
  if(flag) v_gtext(ws_handle,0,CH_HEIGHT-MENUDISP,topmenu_bar);
  vsl_color(ws_handle,BLACK);
  vsl_type(ws_handle,SOLID);
  pxyarray[0]=0;
  pxyarray[1]=pxyarray[3]=CH_HEIGHT+2;
  pxyarray[2]=SCR_W-1;
  v_pline(ws_handle,2,pxyarray);
  graf_mouse(M_ON,NULL);
}

