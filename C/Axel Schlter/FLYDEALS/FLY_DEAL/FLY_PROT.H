/*
	FLY-DEAL Version 3.0 fÅr TOS 12.07.1992
	written '92 by Axel SchlÅter

	Alle Variablen, Includes, Strukturen, usw... ,
	die fÅr die Library nîtig sind
*/

#ifndef __FLYPROTO__
#define __FLYPROTO__

#include <stdio.h>
#include <stdlib.h>
#include <aes.h>
#include <vdi.h>
#include <ext.h>
#include <string.h>
#include <tos.h>
#include "fly_deal.h"
#include "images.h"
#include "structur.h"

#define ALERTBOX 0
#define IACHTUNG 2 
#define IFRAGE 3  
#define ISTOP 4  
#define TEXT1 5  /* 6 7 8 */
#define TEXT5 9  
#define BUTTON1 10
#define BUTTON2 11
#define BUTTON3 12
#define BUTTMOVE 13

static int cdecl FLY_movebutt(PARMBLK *pblk);
static int cdecl FLY_buttons(PARMBLK *pblk);
static int cdecl FLY_text(PARMBLK *pblk);
static int cdecl FLY_boxes(PARMBLK *pblk);
static int cdecl FLY_radio(PARMBLK *pblk);
static int cdecl NEW_menu(PARMBLK *pblk);
void 			 MakeDial(OBJECT *dealog,int object);
int 			 do_deal(void);
int 			 ask_for_infoscrn(int *x,int *y,int *b,int *h);
void 			 movebox(long *Boxadr);
void 			 MakeSave(OBJECT *deal,int obj,int mode);
void 			 fly_bar(int x,int y,int w,int h,int color);
void 			 fly_line(int x1,int y1,int x2,int y2);
void 			 fly_rectangle(int x,int y,int b,int h);
void 			 fly_circle(int x,int y,int mode);
void			 fly_round(int x,int y,int mode);
void 			 fly_radio_box(int mode,OBJECT *dealog,int object,int RoundObject);
void 			 TreeWalk(OBJECT *tree,int mode);
static 			 void _tw(void (*callrout)(OBJECT *deal,int obj),int start);
int 		 	 ask_for_infoscrn(int *x,int *y,int *b,int *h);
int 			 fly_do_every_radio(int exit);
void 			 trans_image(OBJECT *tree,int obj);
void 			 vdi_trans(void *saddr,int swb,void *daddr,int dwb,int h);
void 			 vdi_fix(MFDB *pfd,void *saddr,int wb,int h);
void 			 ChangeMenu(OBJECT *dealog,int object);

#endif