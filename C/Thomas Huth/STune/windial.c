/**
 * STune - The battle for Aratis
 * windial.c : Window dialogs
 * Copyright (C) 2003 Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#include <stdlib.h>
#include "stunegem.h"

#define USEFULLSCR 1

#if USEFULLSCR
#include "stunedef.h"
#include "stunmain.h"
#include "th_aesev.h" /* For fullscrflag */
#include "th_graf.h"  /* For drwindow() */
#endif


#ifdef __TURBOC__
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))
int rc_intersect(GRECT *r1, GRECT *r2)
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}
#endif


GRECT fsdlgclip[4];
short modaldlgflag=FALSE;


/* ***Fenster anmelden + Dialog zeichnen*** */
int wdial_init(OBJECT *tree, char *title, short drawnow)
{
 int wx, wy, ww, wh;
 int dwhndl;

 form_center(tree, &wx, &wy, &ww, &wh);              /* Gr”že holen */
 if(fullscrflag)
  {
   modaldlgflag=TRUE;
   objc_draw(tree, ROOT, MAX_DEPTH, wx, wy, ww, wh); /* Dialog zeichnen */
   dwhndl=0;
   fsdlgclip[0].g_x=0;  fsdlgclip[0].g_w=scrwidth;
   fsdlgclip[0].g_y=0;  fsdlgclip[0].g_h=tree->ob_y;
   fsdlgclip[1].g_x=0;  fsdlgclip[1].g_w=tree->ob_x;
   fsdlgclip[1].g_y=tree->ob_y;  fsdlgclip[1].g_h=tree->ob_height;
   fsdlgclip[2].g_x=tree->ob_x+tree->ob_width;  fsdlgclip[2].g_w=scrwidth-fsdlgclip[2].g_x;
   fsdlgclip[2].g_y=tree->ob_y;  fsdlgclip[2].g_h=tree->ob_height;
   fsdlgclip[3].g_x=0;  fsdlgclip[3].g_w=scrwidth;
   fsdlgclip[3].g_y=tree->ob_y+tree->ob_height;  fsdlgclip[3].g_h=scrheight-fsdlgclip[3].g_y;
  }
 else
  {
   modaldlgflag=FALSE;
   wind_calc(WC_BORDER, NAME|MOVER, wx, wy, ww, wh, &wx, &wy, &ww, &wh);
   dwhndl=wind_create(NAME|MOVER, wx, wy, ww, wh);    /* Fenster anmelden */
   if(dwhndl<0)  return(dwhndl);
   wind_set_str(dwhndl, WF_NAME, title);              /* Name setzen */
   wind_open(dwhndl, wx, wy, ww, wh);                 /* Fenster ”ffnen */
   if(drawnow)
    objc_draw(tree, ROOT, MAX_DEPTH, wx, wy, ww, wh); /* Dialog zeichnen */
  }

 return(dwhndl);
}

/* ***Fenster schliežen + l”schen*** */
void wdial_close(int dwhndl, OBJECT *tree)
{
 if(fullscrflag)
  {
   modaldlgflag=FALSE;
   if(in_game_flag)
    {
     GRECT rct;
     rct.g_x=tree->ob_x;  rct.g_y=tree->ob_y;
     rct.g_w=tree->ob_width;  rct.g_h=tree->ob_height;
     drwindow(&rct);
     drwmwind(&rct);
    }
    else
    {
     int xy[4];
     xy[0]=tree->ob_x;  xy[1]=tree->ob_y;
     xy[2]=xy[0]+tree->ob_width-1;  xy[3]=xy[1]+tree->ob_height-1;
     vsf_color(vhndl, 1);
     graf_mouse(M_OFF, 0L);
     v_bar(vhndl, xy);               /* Hintergrund loeschen */
     graf_mouse(M_ON, 0L);
    }
  }
  else
  {
   wind_close(dwhndl);             /* Fenster schliessen */
   wind_delete(dwhndl);            /* Fenster abmelden */
  }
}

/* ***Dialog neu zeichnen, Rechteckliste beachten*** */
void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect)
{
 GRECT clip;               /* Fr Rechtecksliste */

 graf_mouse(M_OFF, 0L);

 if(fullscrflag)
  {
   objc_draw(tree, ROOT, MAX_DEPTH, redrwrect->g_x, redrwrect->g_y, redrwrect->g_w, redrwrect->g_h);
  }
  else
  {
   wind_update(BEG_UPDATE);
   wind_get(dwhndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
   while(clip.g_w!=0 && clip.g_h!=0)
    {
     if( rc_intersect(redrwrect, &clip) )
       objc_draw(tree, ROOT, MAX_DEPTH, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
     wind_get(dwhndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
    }
   wind_update(END_UPDATE);
  }

 graf_mouse(M_ON, 0L); 
}


/*--------------------------------------------*/
/*             A new form_do()                */
/*         for a dialog in a window           */
/*--------------------------------------------*/

#ifndef FALSE
#define  FALSE    0
#define  TRUE     -1
#endif

#ifndef FMD_DEFLT
#define  FMD_DEFLT     0
#define  FMD_FORWARD   1
#define  FMD_BACKWARD  2
#endif

#ifndef NO_OBJECT
#define NO_OBJECT  -1
#endif

/* **Find the first editable object in the tree** */
int find_obj(OBJECT *tree, int start_obj, int which)
{
 register int  obj, flag, theflag, inc;

 obj=0;
 flag=EDITABLE;
 inc=1;
 switch(which)
  {
   case FMD_BACKWARD:
     inc=-1;
   case FMD_FORWARD:
     obj=start_obj+inc;
     break;
   case FMD_DEFLT:
     flag=DEFAULT;
     break;
  }

 while(obj>=0)
  {
   theflag=tree[obj].ob_flags;
   if(theflag & flag)
     return(obj);
   if(theflag & LASTOB)
     obj=-1;
    else
     obj+=inc;
  }
 return(start_obj);
}

/* **Find the first edit-object** */
int fm_inifld(OBJECT *tree, int start_fld)
{
 if(start_fld==0)
   start_fld=find_obj(tree, 0, FMD_FORWARD);
 return(start_fld);
}



/* ***enhanced form-do main function*** */
short wdial_formdo(int dwhndl, OBJECT *tree, short strt_fld, void (*msghndlr)(int msgbf[]), long msec, void (*tmrhndlr)(void))
{
 int  edit_obj;
 int next_obj;
 register int  which;
 int events=MU_KEYBD|MU_BUTTON|MU_MESAG;
 int  cont;
 int  idx;
 int kshift, kcode;
 int  mx, my, mb, br;
 int  obx, oby, obw, obh;           /* Koordinaten des Dialogs */
 int msgbuf[8];

 graf_mouse(ARROW, 0L);

 if(msec>=0)  events|=MU_TIMER;

 next_obj=fm_inifld(tree, strt_fld);
 edit_obj=0;
 cont=TRUE;

 while(cont)
  {

   if( (next_obj!=0) && (edit_obj!=next_obj) )
    {
     edit_obj=next_obj;
     next_obj=0;
     objc_edit(tree, edit_obj, 0, idx, ED_INIT, &idx);
    }

   which=evnt_multi(events, 2, 1, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    msgbuf, (short)msec,(short)(msec>>16), &mx, &my, &mb,
                    &kshift, &kcode, &br);

   if(which & MU_MESAG)
    {
     if(!fullscrflag && msgbuf[3]==dwhndl && msgbuf[0]>=WM_REDRAW && msgbuf[0]<=WM_NEWTOP)
      {
       switch(msgbuf[0])
        {
         case WM_REDRAW:
           wdial_redraw(dwhndl, tree, (GRECT *)(&msgbuf[4]));
           if(edit_obj) objc_edit(tree, edit_obj, 0, idx, ED_INIT, &idx);
           break;
         case WM_TOPPED:
           wind_set(dwhndl, WF_TOP, 0,0,0,0);
           break;
         case WM_MOVED:
           wind_set(dwhndl, WF_CURRXYWH, msgbuf[4], msgbuf[5],
                 msgbuf[6], msgbuf[7]);
           wind_calc(WC_WORK, NAME|MOVER, msgbuf[4], msgbuf[5],
                 msgbuf[6], msgbuf[7], &obx, &oby, &obw, &obh);
           tree[ROOT].ob_x=obx;
           tree[ROOT].ob_y=oby;
           break;
        }
      }
     else if( msghndlr )  msghndlr(msgbuf);
    }

   if( (which & MU_TIMER) && tmrhndlr )   tmrhndlr();

   if(which & MU_KEYBD)
    {
     cont=form_keybd(tree, edit_obj, next_obj, kcode, &next_obj, &kcode);
     if(kcode)
       objc_edit(tree, edit_obj, kcode, idx, ED_CHAR, &idx);
    }

   if(which & MU_BUTTON)
    {
     next_obj=objc_find(tree, ROOT, MAX_DEPTH, mx, my);
     if(next_obj == NO_OBJECT)                /* outside of object? */
       next_obj=0;
      else
       cont=form_button(tree, next_obj, br, &next_obj);
    }

   if( /*(which & (MU_BUTTON|MU_KEYBD)) &&*/ edit_obj!=0 &&
      ((!cont) || (next_obj!=0 && next_obj!=edit_obj)) )
    {
     objc_edit(tree, edit_obj, 0, idx, ED_END, &idx);
    }

  }

 return( next_obj );
}





#if 1
/* ***Modales PopUp darstellen (fr Fulllscreenmodus)*** */
short modal_popup(OBJECT *ptree, short *pitem, short popupx, short popupy, long msec, void (*tmrhndlr)(void))
{
 int mpopupret;
 GRECT dr;
 int newitem=-1, olditem=-1;
 int msgbuf[8]; int which;
 int mx, my, mb, br, p;

 graf_mouse(ARROW, 0L);
 wind_get(0, WF_WORKXYWH, &dr.g_x, &dr.g_y, &dr.g_w, &dr.g_h); /* Desktop size */

 if(popupx+ptree->ob_width > dr.g_x+dr.g_w)
  popupx=dr.g_x+dr.g_w-ptree->ob_width;
 if(popupx<dr.g_x)  popupx=dr.g_x;
 ptree->ob_x=popupx;
 if(*pitem > 0)  popupy-=ptree[*pitem].ob_y;
 if(popupy+ptree->ob_height > dr.g_y+dr.g_h)
   popupy=dr.g_y+dr.g_h-ptree->ob_height;
 if(popupy<dr.g_y)  popupy=dr.g_y;
 ptree->ob_y=popupy;

 dr.g_x=ptree->ob_x-2;      dr.g_y=ptree->ob_y-2;
 dr.g_w=ptree->ob_width+4;  dr.g_h=ptree->ob_height+4;

#if USEFULLSCR
 if(!fullscrflag)
  form_dial(FMD_START, 0,0,0,0, dr.g_x,dr.g_y,dr.g_w,dr.g_h);
 fsdlgclip[0].g_x=0;  fsdlgclip[0].g_w=scrwidth;
 fsdlgclip[0].g_y=0;  fsdlgclip[0].g_h=dr.g_y;
 fsdlgclip[1].g_x=0;  fsdlgclip[1].g_w=dr.g_x;
 fsdlgclip[1].g_y=dr.g_y;  fsdlgclip[1].g_h=dr.g_h;
 fsdlgclip[2].g_x=dr.g_x+dr.g_w;  fsdlgclip[2].g_w=scrwidth-fsdlgclip[2].g_x;
 fsdlgclip[2].g_y=dr.g_y;  fsdlgclip[2].g_h=dr.g_h;
 fsdlgclip[3].g_x=0;  fsdlgclip[3].g_w=scrwidth;
 fsdlgclip[3].g_y=dr.g_y+dr.g_h;  fsdlgclip[3].g_h=scrheight-fsdlgclip[3].g_y;
 modaldlgflag=TRUE;
#else
 form_dial(FMD_START, 0,0,0,0, dr.g_x,dr.g_y,dr.g_w,dr.g_h);
#endif

 objc_draw(ptree, 0, 1, dr.g_x,dr.g_y,dr.g_w,dr.g_h); /* Popup zeichnen */

 do graf_mkstate(&mx, &my, &mb, &p); while(mb);  /* Maustasten vorher loslassen */

 do
  {
   which=evnt_multi(MU_BUTTON|MU_TIMER, 1,1,1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    msgbuf, (short)msec,(short)(msec>>16), &mx, &my, &mb,
                    &p, &p, &br);
   if(which&MU_TIMER)
    {
     newitem=objc_find(ptree, 0, 1, mx, my);
     if(newitem>0 && newitem!=olditem)
      {
       if( (ptree[newitem].ob_flags&TOUCHEXIT) && !(ptree[newitem].ob_state&DISABLED) )
        {
         if(olditem>0)
          {
/*           ptree[olditem].ob_state&=~SELECTED;*/
/*           objc_draw(ptree, olditem, 0, dr.g_x,dr.g_y,dr.g_w,dr.g_h);*/
           objc_change(ptree, olditem, 0, dr.g_x,dr.g_y,dr.g_w,dr.g_h,NORMAL,1);
          }
/*         ptree[newitem].ob_state|=SELECTED; */
/*         objc_draw(ptree, newitem, 0, dr.g_x,dr.g_y,dr.g_w,dr.g_h); */
         objc_change(ptree, newitem, 0, dr.g_x,dr.g_y,dr.g_w,dr.g_h,SELECTED,1);
         olditem=newitem;
        }
        else
         newitem=olditem;
      }
      else
       newitem=olditem;
     if( tmrhndlr )  tmrhndlr();
    }

  }
 while(mb!=1);  /* Bis Maustaste gedrckt */

 newitem=objc_find(ptree, 0, 1, mx, my);
 if(newitem>0 && (ptree[newitem].ob_flags&TOUCHEXIT) && !(ptree[newitem].ob_state&DISABLED) )
  { *pitem=newitem; mpopupret=TRUE; }
  else { mpopupret=FALSE; }
 if(olditem>0) ptree[olditem].ob_state&=~SELECTED;

#if USEFULLSCR
 modaldlgflag=FALSE;
 if(!fullscrflag)
   form_dial(FMD_FINISH, 0,0,0,0, dr.g_x,dr.g_y,dr.g_w,dr.g_h);
  else
  {
   GRECT brc;
   drwindow(&dr);
   drwmwind(&dr);
   brc.g_x=scrwidth-128;
   brc.g_y=INFHEIGHT+statusypos;
   if(brc.g_y<scrheight)
    {
     brc.g_w=128;  brc.g_h=scrheight-brc.g_y;
     if( rc_intersect(&dr, &brc) )
      {
       int xy[4];
       xy[0]=brc.g_x;   xy[1]=brc.g_y;
       xy[2]=brc.g_x+brc.g_w-1;  xy[3]=brc.g_y+brc.g_h-1;
       graf_mouse(M_OFF, 0L);
       vsf_color(vhndl, 1);
       v_bar(vhndl, xy);
       graf_mouse(M_ON, 0L);
      }
    }
  }
#else
 form_dial(FMD_FINISH, 0,0,0,0, dr.g_x,dr.g_y,dr.g_w,dr.g_h);
#endif

 return(mpopupret);
}
#endif




#if 1
/* ***PopUp darstellen*** */
short wdial_popup(OBJECT *ptree, short *pitem, short popupx, short popupy, void (*msghndlr)(int msgbf[]), long msec, void (*tmrhndlr)(void))
{
 int mpopupret, pwhndl;
 int dx, dy, dw, dh;
 int newitem=-1, olditem=-1;
 int msgbuf[8]; int which;
 int mx, my, mb, br;

#if USEFULLSCR
 if(fullscrflag)  return modal_popup(ptree, pitem, popupx, popupy, msec, tmrhndlr);
#endif

 graf_mouse(ARROW, 0L);
 wind_get(0, WF_WORKXYWH, &dx, &dy, &dw, &dh); /* Desktop size */

 if(popupx+ptree->ob_width > dx+dw)
  popupx=dx+dw-ptree->ob_width;
 if(popupx<dx)  popupx=dx;
 ptree->ob_x=popupx;
 if(*pitem > 0)  popupy-=ptree[*pitem].ob_y;
 if(popupy+ptree->ob_height > dy+dh)
   popupy=dy+dh-ptree->ob_height;
 if(popupy<dy)  popupy=dy;
 ptree->ob_y=popupy;

 wind_calc(WC_BORDER, 0, ptree->ob_x, ptree->ob_y,
           ptree->ob_width, ptree->ob_height, &dx, &dy, &dw, &dh);
 pwhndl=wind_create(0, dx, dy, dw, dh);  /* Fenster anmelden */
 if(pwhndl<0)
   return modal_popup(ptree, pitem, popupx, popupy, msec, 0L); /*return(FALSE);*/
 wind_open(pwhndl, dx, dy, dw, dh);               /* Fenster ”ffnen */
 /*objc_draw(ptree, 0, 1, dx, dy, dw, dh); ->Durch WM_REDRAW zeichnen lassen*/

 do graf_mkstate(&mx, &my, &mb, &dx); while(mb);  /* Maustasten vorher loslassen */

 do
  {
   which=evnt_multi(MU_MESAG|MU_BUTTON|MU_TIMER, 1,1,1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    msgbuf, (short)msec,(short)(msec>>16), &mx, &my, &mb,
                    &dx, &dx, &br);

   if(which&MU_MESAG)
    {
     if(msgbuf[3]==pwhndl && msgbuf[0]>=WM_REDRAW && msgbuf[0]<=WM_NEWTOP)
      {
       switch(msgbuf[0])
        {
         case WM_REDRAW:
           wdial_redraw(pwhndl, ptree, (GRECT *)(&msgbuf[4]));
           break;
         case WM_TOPPED:
           wind_set(pwhndl, WF_TOP, 0,0,0,0);
           break;
        }
      }
     else if( msghndlr )  msghndlr(msgbuf);
    }

   if(which&MU_TIMER)
    {
     newitem=objc_find(ptree, 0, 1, mx, my);
     if(newitem>0 && newitem!=olditem)
      {
       if( (ptree[newitem].ob_flags&TOUCHEXIT) && !(ptree[newitem].ob_state&DISABLED) )
        {
         GRECT prct;
         if(olditem>0)
          {
           ptree[olditem].ob_state&=~SELECTED;
           prct.g_x=ptree->ob_x+ptree[olditem].ob_x;
           prct.g_y=ptree->ob_y+ptree[olditem].ob_y;
           prct.g_w=ptree[olditem].ob_width; prct.g_h=ptree[olditem].ob_height;
           wdial_redraw(pwhndl, ptree, &prct);
          }
         ptree[newitem].ob_state|=SELECTED;
         prct.g_x=ptree->ob_x+ptree[newitem].ob_x;
         prct.g_y=ptree->ob_y+ptree[newitem].ob_y;
         prct.g_w=ptree[newitem].ob_width; prct.g_h=ptree[newitem].ob_height;
         wdial_redraw(pwhndl, ptree, &prct);
         olditem=newitem;
        }
        else
         newitem=olditem;
      }
      else
       newitem=olditem;
     if( tmrhndlr )  tmrhndlr();
    }

  }
 while(mb!=1);  /* Bis Maustaste gedrckt */

 newitem=objc_find(ptree, 0, 1, mx, my);
 if(newitem>0 && (ptree[newitem].ob_flags&TOUCHEXIT) && !(ptree[newitem].ob_state&DISABLED) )
  { *pitem=newitem; mpopupret=TRUE; }
  else { mpopupret=FALSE; }
 if(olditem>0) ptree[olditem].ob_state&=~SELECTED;

 wind_close(pwhndl);  wind_delete(pwhndl);        /* Fenster schliessen */

 return(mpopupret);
}
#endif



#if 0
/* ***PopUp-Knopf behandeln*** */
int wdial_popupbutn(OBJECT *buttree, int butnr, OBJECT *ptree, int *pitem)
{
 int oldchoice=*pitem;
 int butnx, butny;
 int mpopret;

 objc_offset(buttree, butnr, &butnx, &butny);

 mpopret=wdial_popup(ptree, pitem, butnx, butny, NULL, 1, NULL);

 if(mpopret)
  {
   ptree[oldchoice].ob_state=NORMAL;
   ptree[*pitem].ob_state=CHECKED;
   strcpy(buttree[butnr].ob_spec.tedinfo->te_ptext,
      ptree[*pitem].ob_spec.free_string+2);
  }

 buttree[butnr].ob_state&=~SELECTED;
 objc_draw(buttree, butnr, 1, butnx-2, butny-2, buttree[butnr].ob_width+4, buttree[butnr].ob_height+4);

 return(mpopret);
}
#endif
