/* ### Fensterdialoge ### */

#include <aes.h>
#include <stdlib.h>
#include <string.h>

extern char endeflag;

/* ***Fenster anmelden + Dialog zeichnen*** */
int wdial_init(OBJECT *tree, char *title)
{
 short wx, wy, ww, wh;
 int dwhndl;

 form_center(tree, &wx, &wy, &ww, &wh);           /* Gr”že holen */
 wind_calc(WC_BORDER, NAME|MOVER, wx, wy, ww, wh, &wx, &wy, &ww, &wh);
 dwhndl=wind_create(NAME|MOVER, wx, wy, ww, wh);  /* Fenster anmelden */
 if(dwhndl<0)  return(NULL);
 wind_set(dwhndl, WF_NAME, title);                /* Name setzen */
 wind_open(dwhndl, wx, wy, ww, wh);               /* Fenster ”ffnen */
 objc_draw(tree, ROOT, MAX_DEPTH, wx, wy, ww, wh);  /* Dialog zeichnen */

 return(dwhndl);
}

/* ***Fenster schliežen + l”schen*** */
void wdial_close(int dwhndl)
{
 wind_close(dwhndl);                       /* Fenster schliessen */
 wind_delete(dwhndl);                      /* Fenster abmelden */
}

/* ***Dialog neu zeichnen, Rechteckliste beachten*** */
void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect)
{
 GRECT clip;               /* Fr Rechtecksliste */

 wind_update(BEG_UPDATE); graf_mouse(M_OFF, 0L);

 wind_get(dwhndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 while(clip.g_w!=0 && clip.g_h!=0)
  {
   if( rc_intersect(redrwrect, &clip) )
     objc_draw(tree, ROOT, MAX_DEPTH, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
   wind_get(dwhndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
  }

 graf_mouse(M_ON, 0L); wind_update(END_UPDATE);
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
short wdial_formdo(int dwhndl, OBJECT *tree, short strt_fld, void (*msghndlr)(int msgbf[]), long msec, void (*tmrhndlr)())
{
 int  edit_obj;
 int next_obj;
 register int  which;
 int events=MU_KEYBD|MU_BUTTON|MU_MESAG;
 int  cont;
 int  idx;
 short kshift, kcode;
 int  mx, my, mb, br;
 int  obx, oby, obw, obh;           /* Koordinaten des Dialogs */
 int msgbuf[8];

 if(msec>=0)  events|=MU_TIMER;

 next_obj=fm_inifld(tree, strt_fld);
 edit_obj=0;
 cont=TRUE;

 while(cont && !endeflag)
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
     if(msgbuf[3]==dwhndl && msgbuf[0]>=WM_REDRAW && msgbuf[0]<=WM_NEWTOP)
      {
       switch(msgbuf[0])
        {
         case WM_REDRAW:
           wdial_redraw(dwhndl, tree, (GRECT *)(&msgbuf[4]));
           if(edit_obj) objc_edit(tree, edit_obj, 0, idx, ED_INIT, &idx);
           break;
         case WM_TOPPED:
           wind_set(dwhndl, WF_TOP, 0L, 0L);
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




/* ***PopUp darstellen*** */
short wdial_popup(OBJECT *ptree, short *pitem, short popupx, short popupy, void (*msghndlr)(int msgbf[]), unsigned long msec, void (*tmrhndlr)())
{
 int mpopupret, pwhndl;
 int dx, dy, dw, dh;
 int newitem=-1, olditem=-1;
 int msgbuf[8]; int which;
 int mx, my, mb, br;

 wind_get(0, WF_WORKXYWH, &dx, &dy, &dw, &dh); /* Desktopgr”že */

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
 if(pwhndl<0)  return(FALSE);
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
           wind_set(pwhndl, WF_TOP, 0L, 0L);
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
         ptree[olditem].ob_state&=~SELECTED;
         ptree[newitem].ob_state|=SELECTED;
         prct.g_x=ptree->ob_x+ptree[olditem].ob_x;
         prct.g_y=ptree->ob_y+ptree[olditem].ob_y;
         prct.g_w=ptree[olditem].ob_width; prct.g_h=ptree[olditem].ob_height;
         wdial_redraw(pwhndl, ptree, &prct);
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



/* ***PopUp-Knopf behandeln*** */
int wdial_popupbutn(OBJECT *buttree, int butnr, OBJECT *ptree, int *pitem)
{
 int oldchoice=*pitem;
 int butnx, butny;
 int mpopret;

 objc_offset(buttree, butnr, &butnx, &butny);

 mpopret=wdial_popup(ptree, pitem, butnx, butny, NULL, 0, NULL);

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
