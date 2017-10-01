/* ****** TTX_AES.C: AES specific calls ****** */

#include <string.h>
#include <aes.h>

#include "ttx_main.h"
#include "xgriff.h"

#ifndef FALSE
#define FALSE 0
#define TRUE  (!0)
#endif

#ifndef NULL
#define NULL 0L
#endif

#ifndef FL3DACT
#define FL3DIND  0x0200
#define FL3DBAK  0x0400
#define FL3DACT  0x0600
#endif

#ifdef SOZOBON
#define aesversion  gl_apversion	/* Depends on your gem-lib */
#endif

#ifdef __TURBOC__
#define aesversion _GemParBlk.global[0]
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))
int rc_intersect( GRECT *r1, GRECT *r2 )
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



/* ***Dialog neu zeichnen, Rechteckliste beachten*** */
void wdial_redraw(int dwhndl, OBJECT *tree, GRECT *redrwrect)
{
 GRECT clip;               /* FÅr Rechtecksliste */

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


/* *** Redraw a single object *** */
void redraw_objc(short obnum)
{
 GRECT box;
 OBJECT *dlg;

 dlg=dlgs[dlgmode];

 objc_offset(dlg, obnum, &box.g_x, &box.g_y);
 box.g_w=dlg[obnum].ob_width;   box.g_h=dlg[obnum].ob_height;
 if(dlg[obnum].ob_flags&FL3DACT )
  {
   box.g_x-=2; box.g_y-=2;
   box.g_w+=4; box.g_h+=4;
  }
 wdial_redraw(whndl, dlg, &box);
}


/* *** Send a mesage *** */
void sendmesag(short dest_id, short msgtype)
{
 int sendbuf[8], i;

 sendbuf[0]=msgtype;
 sendbuf[1]=ap_id;
 for(i=2; i<7; i++) sendbuf[i]=0;
 appl_write(dest_id, 16, sendbuf);
}


/* ****Fileselector**** */
int fselector(char *pname, char *fname, int *retbut, char *fstitle)
{
 short retcode;

 wind_update(BEG_MCTRL);

 if(aesversion>0x0130)
   retcode=fsel_exinput(pname, fname, retbut, fstitle);
  else
   retcode=fsel_input(pname, fname, retbut);

 wind_update(END_MCTRL);

 return(retcode);
}



/* ***PopUp darstellen*** */
int wdial_popup(OBJECT *ptree, int *pitem, int popupx, int popupy, void (*msghndlr)(int msgbf[]), long msec, void (*tmrhndlr)(void))
{
 int mpopupret, pwhndl;
 int dx, dy, dw, dh;
 int newitem=-1, olditem=-1;
 int msgbuf[8];
 int which;
 int mx, my, mb, br;
 int modalflag;
 int j;

 graf_mouse(ARROW, NULL);
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
  {
   modalflag=TRUE;
   form_dial(FMD_START, 0,0,0,0, dx, dy, dw, dh);
  }
  else
  {
   modalflag=FALSE;
   wind_open(pwhndl, dx, dy, dw, dh);			 /* Open window */
  }
 objc_draw(ptree, 0, 1, dx, dy, dw, dh);		 /* Draw Popup */

 do graf_mkstate(&mx, &my, &mb, &j); while(mb);	 /* Release mouse buttons now */

 do
  {
   which=evnt_multi(MU_MESAG|MU_BUTTON|MU_TIMER, 1,1,1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    msgbuf, (short)msec,(short)(msec>>16), &mx, &my, &mb,
                    &j, &j, &br);

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
           wind_set(pwhndl, WF_TOP, 0, 0, 0, 0);
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
           prct.g_x=ptree->ob_x+ptree[olditem].ob_x; prct.g_y=ptree->ob_y+ptree[olditem].ob_y;
           prct.g_w=ptree[olditem].ob_width; prct.g_h=ptree[olditem].ob_height;
           if(modalflag)
             objc_draw(ptree, olditem, 0, prct.g_x,prct.g_y,prct.g_w,prct.g_h);
            else
              wdial_redraw(pwhndl, ptree, &prct);
          }
         ptree[newitem].ob_state|=SELECTED;
         prct.g_x=ptree->ob_x+ptree[newitem].ob_x;
         prct.g_y=ptree->ob_y+ptree[newitem].ob_y;
         prct.g_w=ptree[newitem].ob_width; prct.g_h=ptree[newitem].ob_height;
         if(modalflag)
           objc_draw(ptree, olditem, 0, prct.g_x,prct.g_y,prct.g_w,prct.g_h);
          else
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
 while(mb!=1);  /* Until mousbutton pressed */

 newitem=objc_find(ptree, 0, 1, mx, my);
 if(newitem>0 && (ptree[newitem].ob_flags&TOUCHEXIT) && !(ptree[newitem].ob_state&DISABLED) )
  { *pitem=newitem; mpopupret=TRUE; }
  else { mpopupret=FALSE; }
 if(olditem>0) ptree[olditem].ob_state&=~SELECTED;

 if(modalflag)                                   /* Close the popup */
   form_dial(FMD_FINISH, 0,0,0,0, dx, dy, dw, dh);
  else
   { wind_close(pwhndl);  wind_delete(pwhndl); }

 return(mpopupret);
}


/* ***Handle PopUp-Button*** */
int wdial_popupbutn(OBJECT *buttree, int butnr, OBJECT *ptree, int *pitem)
{
 int oldchoice=*pitem;
 int butnx, butny;
 int mpopret;

 objc_offset(buttree, butnr, &butnx, &butny);

 mpopret=wdial_popup(ptree, pitem, butnx, butny, NULL, 1, ((playflag  && eofrmode<=2)?checkbuf:NULL));

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
