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

/*........................... redraw window ..................................*/

redraw(handle,x,y,w,h)
int handle,x,y,w,h;
{
   GRECT t1,t2;

/* if necessary, get this window's work area */
   if ((x+y+w+h)==get_tr())   /* 0 */
      wind_get(handle,WF_WORKXYWH,&t2.g_x,&t2.g_y,&t2.g_w,&t2.g_h); 
   else
   {
      t2.g_x= x+get_tr();  /* 0 */
      t2.g_y= y+get_tr();  /* 0 */
      t2.g_w= w+get_tr();  /* 0 */
      t2.g_h= h+get_tr();  /* 0 */
   }
/* hide the mouse during this */     
   v_hide_c(gl_hand);   
/* protect all window rectangle lists */
   wind_update(1);      
/* get the first rectangle in this window's rectangle list */
   wind_get(handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
   while (t1.g_w && t1.g_h)  /* loop until a null entry in rectangle list */
   {
/* find intersection (if any) of the update rect. and the rect. from list */
      if (rc_intersect(&t2,&t1))
      {
/* update the portion of window lying within the intersection area */
         set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
         if ((editmode==get_ill())||(editmode==2))   /* 1 */
            ed_window();
         else
            do_window(handle);    /* draw clipped window contents */
      }   
/* get next rectangle in this window's rectangle list */
      wind_get(handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
   }
/* unprotect window rectangle lists */
   wind_update(0);    
/* unhide mouse */
   v_show_c(gl_hand,0); 
}   /* end redraw(handle) */

/*........................ draw window contents ..............................*/

do_window(handle)
int handle;
{
   int x,y,w,h;
   register int i;
   int xyarray[8],slotbox[8];
   int xchar;
   char *wbptr;

/* get window's work area */
   wind_get(handle,WF_WORKXYWH,&x,&y,&w,&h); 
/* define rectangle for work area background */
   xyarray[0]= x;
   xyarray[1]= y-1;
   xyarray[2]= x+w-1;
   xyarray[3]= y-1;
   xyarray[4]= x+w-1;
   xyarray[5]= y+h;
   xyarray[6]= x;
   xyarray[7]= y+h;

   vsf_color(gl_hand,0);
   vsf_interior(gl_hand,get_ill());   /* 1 */
/* no vsf_style needed for interior type 1 */
   vsf_perimeter(gl_hand,0);
/* paint work area background */
   v_fillarea(gl_hand,4,xyarray);

/* invert background within active slot */
   if ((handle == ws_hand) && (handle == top_hand) && (act_slot))
   {
      vsf_color(gl_hand,get_ill());  /* 1 */
      v_fillarea(gl_hand,4,xyarray);
   }
   if ((handle != ws_hand) && (handle == top_hand) && (act_slot))
   {
      slotbox[6]= slotbox[0]= x;
      slotbox[3]= slotbox[1]= y-rez+(act_slot-1)*h/17;
      slotbox[4]= slotbox[2]= x+w-1;
      slotbox[7]= slotbox[5]= y-rez+act_slot*h/17;
      if (act_slot==17)
      {
         slotbox[3]=slotbox[1]= slotbox[3]+1;
         slotbox[5]=slotbox[7]= y+h;
      }
      vsf_color(gl_hand,get_ill());   /* 1 */
      v_fillarea(gl_hand,4,slotbox);
   }

/* workspace window: includes name */
   if (handle == ws_hand) 
   {
      if ((handle == top_hand) && (act_slot)) vswr_mode(gl_hand,3);
      v_gtext(gl_hand,x+(w-80)/2-24,y+h-2*rez,ws_dat);
      vswr_mode(gl_hand,1);
      return;
   }      

   if (handle == wba_hand)
      wbptr= wba_dat;
   else
      wbptr= wbb_dat;
      
/* x-coord for slot numbers */
   if (handle==cz_hand)
      xchar= x+(w-16)/2;
   else
      xchar= x+2;

/* horizontal lines, slot #'s, slot names */
   for (i=0; i<=15; i++)       
   {
      xyarray[1]= xyarray[3]= y-rez+(i+1)*h/17;
      v_pline(gl_hand,2,xyarray);
      if ((handle==top_hand)&&((i+1)==act_slot)) vswr_mode(gl_hand,3);
      v_gtext(gl_hand,xchar,xyarray[1]-2*rez,*numtype+3*i);
      vswr_mode(gl_hand,1);
      if ((handle != cz_hand)&&((syntype!=3)||(i<4)))
      {
         if ((handle==top_hand)&&((i+1)==act_slot)) vswr_mode(gl_hand,3);
         v_gtext(gl_hand,xchar+32,xyarray[1]-2*rez,&wbptr[17*i]);
         vswr_mode(gl_hand,1);
      }
   } /* end for (i=0; i<=15; i++) */

   xyarray[1]= xyarray[3]= xyarray[1]+1;
   v_pline(gl_hand,2,xyarray);
   if ((handle==top_hand)&&(act_slot==17)) vswr_mode(gl_hand,3);
   v_gtext(gl_hand,x+(w-24)/2,y+h-2*rez,&"ALL");
   vswr_mode(gl_hand,1);

}   /* end do_window() */
   
/*........... combine directory and file name into a pathname ................*/

combine(d,f)
char *d,*f;
{
   register char c;
   register int i;

   i= strlen(d);
   while (i && (((c=d[i-1]) != '\\') && (c != ':')))  i--;
   d[i]= '\0';
   strcat(d,f);
} /* end combine(d,f) */

/*.................... set clipping rectangle ................................*/

set_clip(x,y,w,h)
int x,y,w,h;
{
   int clip[4];

   clip[0]= x;
   clip[1]= y;
   clip[2]= x+w-1;
   clip[3]= y+h-1;
   vs_clip(gl_hand,1,clip);
} /* end set_clip(x,y,w,h) */

/*........................... handle dialog box ..............................*/
 
do_dial(dialaddr,obj,editobj)   /* return the selected exit object number */
long dialaddr;
int obj,editobj;
{
   int x,y,w,h;
   int exit_obj;
   FDB savefdb;
   int xyarray[8];

/* get coordinates for the dialog box */
   form_center(dialaddr,&x,&y,&w,&h);
/* save the screen which will lie under the box */
   form_dial(0,0,0,0,0,x,y,w,h);
   savefdb.fd_addr= saveptr;
   savefdb.fd_w= 640;
   savefdb.fd_h= 200*rez;
   savefdb.fd_wdwidth= 40;
   savefdb.fd_stand= 0;
   if (rez==1)
      savefdb.fd_nplanes= 2;
   else
      savefdb.fd_nplanes= 1;
   xyarray[0]= x;   xyarray[1]= y;   xyarray[2]= x+w;   xyarray[3]=  y+h;
   xyarray[4]= 0;   xyarray[5]= 0;   xyarray[6]= w;     xyarray[7]=  h;
   v_hide_c(gl_hand);   
   if (saveptr) vro_cpyfm(gl_hand,3,xyarray,&scrfdb,&savefdb);
   v_show_c(gl_hand,0); 
/* put up the box */
   objc_draw(dialaddr,ROOT,MAX_DEPTH,x,y,w,h);
/* interact with user, return the exit object selected */
   exit_obj= form_do(dialaddr,editobj);
/* restore the screen */
   xyarray[0]= 0;   xyarray[1]= 0;   xyarray[2]= w;     xyarray[3]=  h;
   xyarray[4]= x;   xyarray[5]= y;   xyarray[6]= x+w;   xyarray[7]=  y+h;
   v_hide_c(gl_hand);
   if (saveptr)
   {
      vs_clip(gl_hand,0,&dummy);   /* turn clipping off */
      vro_cpyfm(gl_hand,3,xyarray,&savefdb,&scrfdb);
   }
   else
      form_dial(3,0,0,0,0,0,0,0,0);
   v_show_c(gl_hand,0);
/* de-select the exit object */
   desel_obj(dialaddr,exit_obj);
   return(exit_obj);
} /* end do_dial(dialaddr,obj) */
 
/*........................... select an object ...............................*/

sel_obj(tree,obj)
long tree;
int obj;
{
   int state;
   state= LWGET(OB_STATE(obj));
   LWSET(OB_STATE(obj),state | SELECTED);
}

/*......................... deselect an object ...............................*/

desel_obj(tree,obj)
long tree;
int obj;
{
   int state;
   state= LWGET(OB_STATE(obj));
   LWSET(OB_STATE(obj),state & ~SELECTED);
}

/*............................ parse a file name .............................*/

parsfil(name)   /* return 0 for good, not 0 for bad */
char *name;
{
   int len;
   char c;
   int bad=0;
   register int i=0;
   int nperiods=0;
   int j=0;

   if (name[0] == '\0') bad=1;       /* null name is illegal */
   if (name[0] == '.') bad=2;        /* name cannot start with a period */
   len=strlen(name);                 /* # chars in string (not counting \0 */
   if (name[len-1] == '.') bad=3;    /* name cannot end with a period */

/* name must consist of all upper case letters, digits, and no more than 
   one period (note: underscore counts as a letter */

   while ((i<13) && (name[i] != '\0') && (bad==0))
   {
      c=name[i];
      if (  ((c<='Z') && (c>='A')) || (c=='_')   )
         bad=0;
      else
      {
         if ((c<='9') && (c>='0'))
            bad=0;
         else
         {
            if (c=='.')
            {
               j=i;
               nperiods++;
               if (nperiods>1) bad=4;
            }
            else
               bad=5;
         }
      }
      i++;
   }

   if (!bad)
   {
/* if there is no period, name cannot exceed eight characters */
/* if there is a period, no more than 8 characters before period and
   no more than 3 characters after period */
      if (nperiods==0)
      {
         if (len>8) bad=6;
      }
      else
         if (((len-1-j)>3) || (j>8)) bad=7;   
   } /* end if (!bad) */
   return(bad);
} /* end parsfil() */
      
/*.................. convert a string to all upper case ......................*/

lc_to_uc(name)
char name[];
{
   register int i=0;

   while (name[i])
   {
      if ((name[i]>='a')&&(name[i]<='z')) name[i]=name[i]-'a'+'A';
      i++;
   }
} /* end lc_to_uc() */

/*.......................... name something...................................*/

do_name(nameptr)
char *nameptr;
{
   register int i;

   if (top_hand==ws_hand)
   {
      strcpy(ws_dat,nameptr);
      return;
   }
   if (act_slot<17)
   {
      if (top_hand==wba_hand)
         strcpy(&wba_dat[17*(act_slot-1)],nameptr);
      else
         strcpy(&wbb_dat[17*(act_slot-1)],nameptr);
      return;
   }
   if (top_hand==wba_hand)
   {
      for (i=0; i<=15; i++)
         strcpy(&wba_dat[17*i],nameptr);
   }
   if (top_hand==wbb_hand)
   {
      for (i=0; i<=15; i++)
         strcpy(&wbb_dat[17*i],nameptr);
   }
     
} /* end do_name(nameptr) */

/*............................. clear active slot ............................*/

undoslot()
{
   if (!act_slot) return;   /* do nothing if there is no active slot */
   deact_slot(top_hand,act_slot);
   act_slot= 0;
   menu_ienable(menuaddr,NAME,0);
   menu_ienable(menuaddr,INIT,0);
   menu_ienable(menuaddr,DISTORT,0);
   menu_ienable(menuaddr,DROID,0);
   menu_ienable(menuaddr,HARDCOPY,0);
} /* end undoslot() */

/*......................... deactivate/activate a slot .......................*/

activ_slot(window,slot)
int window,slot;
{
   do_slot(window,slot,1,3);
   vswr_mode(gl_hand,1);  /* reset normal text */
} /* end activ_slot(window,slot) */

deact_slot(window,slot)
int window,slot;
{
   do_slot(window,slot,0,1);
} /* end deact_slot(window,slot) */

do_slot(handle,slot,backcolr,textmode)
int handle,slot,backcolr,textmode;
{
   GRECT t1,t2;
   int x,y,w,h;
   int xyarray[8];

   wind_get(handle,WF_WORKXYWH,&x,&y,&w,&h);  /* get work area */

/* hide the mouse during this */     
   v_hide_c(gl_hand);   
/* protect all window rectangle lists */
   wind_update(1);      
   t2.g_x= x;          /* update rectangle */
   t2.g_y= y;
   t2.g_w= w;
   t2.g_h= h;
/* get the first rectangle in this window's rectangle list */
   wind_get(handle,WF_FIRSTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
   while (t1.g_w && t1.g_h)  /* loop until a null entry in rectangle list */
   {
/* find intersection (if any) of the update rect. and the rect. from list */
      if (rc_intersect(&t2,&t1))
      {
/* update the portion of window lying within the intersection area */
         set_clip(t1.g_x,t1.g_y,t1.g_w,t1.g_h);
/* fill the slot area */
         vsf_color(gl_hand,backcolr);
	 vsf_interior(gl_hand,1);
         /* no vsf_style needed for interior 1 */
         xyarray[6]= xyarray[0]= x;
         xyarray[3]= xyarray[1]= y-rez+(slot-1)*h/17;
         xyarray[4]= xyarray[2]= x+w-1;
         xyarray[7]= xyarray[5]= y-rez+slot*h/17;
         if (slot==17)
         {
            xyarray[3]=xyarray[1]= xyarray[3]+1;
            xyarray[5]=xyarray[7]= y+h;
         }
         if (handle == ws_hand)
         {
            xyarray[3]= xyarray[1]= y-1;
            xyarray[7]= xyarray[5]= y+h;
         }
         v_fillarea(gl_hand,4,xyarray);
         vswr_mode(gl_hand,textmode);
         if (slot == 17)
         {
            v_gtext(gl_hand,x+(w-24)/2,y+h-2*rez,&"ALL");
         }
         else
         {
            if (handle == ws_hand)
               v_gtext(gl_hand,x+(w-80)/2-24,y+h-2*rez,&ws_dat);
            if (handle == wba_hand)
            {
               v_gtext(gl_hand,x+2,y-3*rez+slot*h/17,*numtype+3*(slot-1));
               v_gtext(gl_hand,x+34,y-3*rez+slot*h/17,&wba_dat[17*slot-17]);
            }
            if (handle == wbb_hand)
            {
               v_gtext(gl_hand,x+2,y-3*rez+slot*h/17,*numtype+3*(slot-1));
               v_gtext(gl_hand,x+34,y-3*rez+slot*h/17,&wbb_dat[17*slot-17]);
            }
            if (handle == cz_hand)
               v_gtext(gl_hand,x+(w-16)/2,y-3*rez+slot*h/17,
                       *numtype+3*(slot-1));  
         } /* end if (slot == 17) */
      } /* end if (rc_intersect(&t2,&t1)) */
/* get next rectangle in this window's rectangle list */
      wind_get(handle,WF_NEXTXYWH,&t1.g_x,&t1.g_y,&t1.g_w,&t1.g_h);
   } /* end while (t1.g_w && t1.g_h) */
/* unprotect window rectangle lists */
   wind_update(0);    
/* unhide mouse */
   v_show_c(gl_hand,0); 
}   /* end do_slot(handle,slot) */

/*...................... convert y-coord to slot #  ..........................*/

getslot(y,h,mousey,box_y,box_h)  /* return slot=1-17 */
int y,h;
register int mousey;
int *box_y,*box_h;
{
   register int i;
   int next_y;
   
   for (i=1; i<=16; i++)
   {
      next_y= y-rez+i*h/17;
      if (mousey < next_y)
      {
         *box_y= y-rez+(i-1)*h/17;
         *box_h= next_y - *box_y + 1;
         return(i);
      }
   }
   *box_y= next_y+1;
   next_y= y+h;
   *box_h= next_y - *box_y + 1;
   return(17);
} /* end getslot(y,h,mousey) */

/*..........................activate menu items ..............................*/

act_menu(window,slot)
int window,slot;
{
/* default all four menu items */
   menu_ienable(menuaddr,NAME,1);
   menu_ienable(menuaddr,INIT,1);
   menu_ienable(menuaddr,DISTORT,1);
   menu_ienable(menuaddr,DROID,1);
   menu_ienable(menuaddr,HARDCOPY,1);

/* you cannot name CZ slots */
   if (window==cz_hand) menu_ienable(menuaddr,NAME,0);

/* you cannot hard-list names from a CZ other than CZ-1 */
   if ((window==cz_hand)&&(slot==17)&&(syntype!=2))    
      menu_ienable(menuaddr,HARDCOPY,0);

} /* end act_menu(window,slot) */

/* EOF */
