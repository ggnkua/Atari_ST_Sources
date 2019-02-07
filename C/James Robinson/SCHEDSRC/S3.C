/* S3.C -- FORM HANDLER */

#include "ctype.h"
#include "stdio.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "schedule.h"
#include "ctools.h"

static int next_obj,cursor_flag;

extern char sys_date[9],sys_time[6],old_sys_date[9],old_time[6];

extern int ed_obj,ed_idx,mx,my;

extern OTHER_PREFS prefs;

int
find_obj(tree,start_obj,flag,which)
OBJECT *tree;
int start_obj,flag,which;
{
   register int obj,theflag,inc;

   obj=0;
   inc=1;
   switch(which)
   {
      case FMD_BACKWARD:
                         inc = -1;
                           
      case FMD_FORWARD:
                         obj = start_obj + inc;
                         break;
   }

   while(obj>=0)
   {
      theflag=tree[obj].ob_flags;
      if(theflag & flag && !(theflag & HIDETREE) &&
         !(tree[obj].ob_state & DISABLED))
         return(obj);
      if(theflag & LASTOB)
         obj=(-1);
      else
         obj+=inc;
   }
   return(start_obj);
}

int
get_last_obj(tree)
OBJECT *tree;
{
   register int obj,flag,last_obj;

   obj=0;

   while(TRUE)
   {
      flag=tree[obj].ob_flags;
      if(flag & EDITABLE && !(tree[obj].ob_flags & HIDETREE))
         last_obj=obj;
      if(flag & LASTOB)
         break;
      else
         obj++;
   }
   return(last_obj);
}

int
fm_inifld(tree,start_fld)
OBJECT *tree;
int start_fld;
{
   if(start_fld==0 || tree[start_fld].ob_flags & HIDETREE)
      start_fld=find_obj(tree,start_fld,EDITABLE,FMD_FORWARD);
   else
      return(start_fld);
}

reset_rbuttons(tree,obj,draw_flag)
OBJECT *tree;
int obj,draw_flag;
{
   int start_obj,end_obj,i;

   objc_change(tree,obj,0,0,0,0,0,SELECTED,draw_flag);

   start_obj=obj;
   end_obj=obj;

   while(tree[start_obj].ob_flags & RBUTTON)
      start_obj--;

   while(tree[end_obj].ob_flags & RBUTTON)
      end_obj++;

   for(i=start_obj+1; i<end_obj; i++)
   {
      if(i!=obj && !(tree[i].ob_flags & HIDETREE)
                && !(tree[i].ob_state & DISABLED))
         objc_change(tree,i,0,0,0,0,0,NORMAL,draw_flag);
   }
}

int
form_do(tree,tdef,start_fld,verify_flag,edit_exit)
OBJECT *tree;
int start_fld,tdef,verify_flag,edit_exit;
{
   int exit_obj,def_obj,last_obj,which,cont,mb,ks,kr,br,mgbuf[8];

   next_obj=fm_inifld(tree,start_fld);
   exit_obj=ed_obj=0;
   def_obj=find_obj(tree,0,DEFAULT,FMD_FORWARD);
   last_obj=get_last_obj(tree);

   cont=TRUE;
   while(cont)
   {
      if((next_obj!=0) && (ed_obj!=next_obj))
      {
         ed_obj=next_obj;
         exit_obj=next_obj;
         next_obj=0;
         if(tree[ed_obj].ob_flags & EDITABLE)
            if(!cursor_flag)
               objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
      }

      which=evnt_multi(MU_TIMER|MU_KEYBD|MU_BUTTON,1,0x01,1,0,
                       0,0,0,0,0,0,0,0,0,mgbuf,
                       2000,0,&mx,&my,&mb,&ks,&kr,&br);

      cursor_flag=FALSE;

      if(which & MU_TIMER)
      {
         if(tdef!=TSYSDATE)
         {
            strcpy(old_sys_date,sys_date);
            strcpy(old_time,sys_time);

            get_sys_date(FALSE);

            if((prefs.optime_display && strcmp(old_time,sys_time)!=0) ||
               (prefs.optime_display && prefs.opdate_display) ||
               (prefs.opdate_display && strcmp(old_sys_date,sys_date)!=0))
               time_display();

            if(strcmp(old_time,sys_time)!=0)
               if(tdef==TCALINFO)
                  if(uses_time(0))
                     ci_report();

            if(strcmp(old_sys_date,sys_date)!=0)
               if(tdef==TCALINFO)
                  if(uses_day(0))
                     ci_report();
         }
      }

      if(which & MU_KEYBD)
      {
         if(tree[ed_obj].ob_flags & EDITABLE)
         {
            if(is_edit_key(tree,ed_obj,kr,ks))
               continue;
            else if(is_macro(tree,ed_obj,kr))
               continue;
            else
            {
               if(kr==0x3B00)
                  do_copy(tree,ed_obj);
               else if(kr==0x3C00)
                  do_paste(tree,tdef,ed_obj);
               else if(kr==0x3D00)
               {
                  objc_edit(tree,ed_obj,0,&ed_idx,EDEND);
                  do_last(tree,tdef,ed_obj);
                  objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
                  if(ed_obj!=last_obj)
                     next_obj=find_obj(tree,ed_obj,EDITABLE,FMD_FORWARD);
               }
               else if(kr==0x3E00)
               {
                  objc_edit(tree,ed_obj,0,&ed_idx,EDEND);
                  use_sys_date(tree,tdef,ed_obj);
                  objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
                  if(ed_obj!=last_obj)
                     next_obj=find_obj(tree,ed_obj,EDITABLE,FMD_FORWARD);
               }
               else if(kr==0x3F00)
                  manip_date(tree,tdef,MINUS,DAY);
               else if(kr==0x4000)
                  manip_date(tree,tdef,PLUS,DAY);
               else if(kr==0x4100)
                  manip_date(tree,tdef,MINUS,WEEK);
               else if(kr==0x4200)
                  manip_date(tree,tdef,PLUS,WEEK);
               else if(kr==0x4300)
                  manip_time(tree,tdef,MINUS);
               else if(kr==0x4400)
                  manip_time(tree,tdef,PLUS);
               else if(kr==0x720D)
               {
                  exit_obj=0;

                  if(ks==0x0008)
                  {
                     if(tdef==TEDITREC)
                        exit_obj=ERCANCEL;
                     else if(tdef==TPRTREPT)
                        exit_obj=PRCANCEL;
                     else if(tdef==TAUTTICK)
                        exit_obj=ATCANCEL;
                     else if(tdef==TCALCBD)
                        exit_obj=BDCANCEL;
                     else if(tdef==TCALCFD)
                        exit_obj=FDCANCEL;
                     else if(tdef==TCUSTOM)
                        exit_obj=CCANCEL;
                     else if(tdef==TPRTCODE)
                        exit_obj=PCCANCEL;
                     else if(tdef==TMACROS)
                        exit_obj=MCANCEL;
                     else if(tdef==TSENDCOD)
                        exit_obj=SCCANCEL;
                     else if(tdef==TEDITRPT)
                        exit_obj=EPCANCEL;
                     else if(tdef==TPAGESET)
                        exit_obj=PSCANCEL;
                     else if(tdef==TPAGERNG)
                        exit_obj=PGRCNCL;
                     else if(tdef==TGODATE)
                        exit_obj=GDCANCEL;
                     else if(tdef==TCALEDIT)
                        exit_obj=CECANCEL;
                     else if(tdef==TOTHERPF)
                        exit_obj=OPCANCEL;
                  }
                  else
                  {
                     if(tdef==TEDITREC)
                        exit_obj=EROK;
                     else if(tdef==TPRTREPT)
                        exit_obj=PROK;
                     else if(tdef==TAUTTICK)
                        exit_obj=ATOK;
                     else if(tdef==TCALCBD)
                        exit_obj=BDOK;
                     else if(tdef==TCALCFD)
                        exit_obj=FDOK;
                     else if(tdef==TSYSDATE)
                        exit_obj=SDOK;
                     else if(tdef==TCUSTOM)
                        exit_obj=COK;
                     else if(tdef==TPRTCODE)
                        exit_obj=PCOK;
                     else if(tdef==TMACROS)
                        exit_obj=MACOK;
                     else if(tdef==TSENDCOD)
                        exit_obj=SCOK;
                     else if(tdef==TEDITRPT)
                        exit_obj=EPOK;
                     else if(tdef==TPAGESET)
                        exit_obj=PSOK;
                     else if(tdef==TPAGERNG)
                        exit_obj=SROK;
                  }
                  if(def_obj && !exit_obj)
                     exit_obj=def_obj;
                  if(exit_obj)
                  {
                     objc_change(tree,exit_obj,0,0,0,0,0,SELECTED,1);
                     cont=FALSE;
                  }
               }
               else if(kr==0x720D || kr==0x1C0D || kr==0x5000)
               {
                  exit_obj=0;

                  if(kr==0x720D && ks==0x0008)
                  {
                     if(tdef==TPRTDEV)
                        exit_obj=PDCANCEL;
                     else if(tdef==TPRINT)
                        exit_obj=PCANCEL;
                     else if(tdef==TSELRPT)
                        exit_obj=SPCANCEL;
                  }
                  if(kr==0x5000 || kr==0x1C0D || (kr==0x720D && ks!=0x0008))
                  {
                     next_obj=find_obj(tree,ed_obj,EDITABLE,FMD_FORWARD);
                     if(tdef==TEDITRPT && next_obj>EPNAME)
                        next_obj=ed_obj; /* strange fix */
                  }
                  if((exit_obj || def_obj) && kr!=0x5000)
                  {
                     if(def_obj && !exit_obj)
                        exit_obj=def_obj;
                     objc_change(tree,exit_obj,0,0,0,0,0,SELECTED,1);
                     cont=FALSE;
                  }
                  if(kr==0x5000 || kr==0x1C0D)
                  {
                     if(!verify_flag && ed_obj==next_obj)
                     { 
                        cont=FALSE;
                        exit_obj=next_obj;
                     }
                  }
               }
               else if(kr==0x4800)
                  next_obj=find_obj(tree,ed_obj,EDITABLE,FMD_BACKWARD);
               else
               {
                  if(edit_exit)
                     next_obj=0;
                  if(kr!=0x0C5F)
                  {
                     if((!ob_date(tree,ed_obj) || kr!=0x352F) &&
                       (!ob_time(tree,ed_obj) || kr!=0x273A))
                        if(tree[ed_obj].ob_flags & EDITABLE)
                           if(!val_special(tree,kr))
                           objc_edit(tree,ed_obj,kr,&ed_idx,EDCHAR);
                     if(edit_exit==TRUE
                        && kr!=0x4D00 && kr!=0x4B00 && kr!=0x4800)
                     {
                        cursor_flag=TRUE;
                        return(ed_obj);
                     }
                  }
               }
            }
         }
         else if(kr==0x720D || kr==0x1C0D)
         {
            exit_obj=0;

            if(kr==0x720D && ks==0x0008)
            {
               if(tdef==TPRTDEV)
                  exit_obj=PDCANCEL;
               else if(tdef==TPRINT)
                  exit_obj=PCANCEL;
               else if(tdef==TSELRPT)
                  exit_obj=SPCANCEL;
            }
            if(exit_obj || def_obj)
            {
               if(def_obj && !exit_obj)
                  exit_obj=def_obj;
               objc_change(tree,exit_obj,0,0,0,0,0,SELECTED,1);
               cont=FALSE;
            }
         }
      }

      if(which & MU_BUTTON)
      {
         next_obj=objc_find(tree,ROOT,MAX_DEPTH,mx,my);
         if(next_obj > 0 && !(tree[next_obj].ob_state & DISABLED))
         {
            if(tree[next_obj].ob_flags & SELECTABLE)
               objc_change(tree,next_obj,0,0,0,0,0,SELECTED,1);
            if(tree[next_obj].ob_flags & EXIT)
            {
               if(!track_button(tree,next_obj))
               {
                  cursor_flag=TRUE;
                  next_obj=0;
                  continue;
               }
               cont=FALSE;
               exit_obj=next_obj;
            }
            else if(tree[next_obj].ob_type==G_BUTTON &&
                  !(tree[next_obj].ob_flags & RBUTTON))
               up_button();
                 
            if(tree[next_obj].ob_flags & RBUTTON)
               reset_rbuttons(tree,next_obj,TRUE);
            if(tree[next_obj].ob_flags & TOUCHEXIT)
            {
               cont=FALSE;
               exit_obj=next_obj;
               objc_edit(tree,ed_obj,0,&ed_idx,EDEND);
               return(exit_obj);
            }
            if(tree[next_obj].ob_flags & EDITABLE)
            {
               mouse_pos(tree,next_obj);
               ed_obj=next_obj;
               cursor_flag=TRUE;
            }
            if(!(tree[next_obj].ob_flags & EDITABLE))
               if(!(tree[next_obj].ob_state & DISABLED))
                  if(!(tree[next_obj].ob_flags & EXIT))
                     next_obj=ed_obj;
         }
         else
            next_obj=ed_obj;
       }

       if((!cont) || ((next_obj != 0) && !cursor_flag && (next_obj != ed_obj)))
       {
          if(tree[ed_obj].ob_flags & EDITABLE)
             objc_edit(tree,ed_obj,0,&ed_idx,EDEND);
       }
    }

    if(tree[exit_obj].ob_flags & SELECTABLE)
       objc_change(tree,exit_obj,0,0,0,0,0,NORMAL,0);

    return(exit_obj);
}

int
do_dialog(tree,tdef,start_obj,verify,edit_exit)
long *tree;
int tdef,start_obj,verify,edit_exit;
{
   int xdial,ydial,wdial,hdial,exit_obj;

   wind_update(1);
   wind_update(3);

   form_center(tree,&xdial,&ydial,&wdial,&hdial);
   form_dial(0,0,0,0,0,xdial,ydial,wdial,hdial);
   objc_draw(tree,0,8,xdial,ydial,wdial,hdial);

   if(tdef==TCALINFO)
   {
      set_header(tree);
      ci_header(tree);
      ci_shown_count();
      ci_size_sliders(tree);
      set_vt_pos(tree);
      set_hz_pos(tree);
      ci_report();
   }

   cursor_flag=FALSE;

   for(;;)
   {
      exit_obj=form_do(tree,tdef,start_obj,verify,edit_exit);

      if(ob_touch_exit(tree,exit_obj) ||
        (edit_exit && !ob_exit(tree,exit_obj)) && exit_obj!=next_obj)
         start_obj=extend_dialog(tree,tdef,exit_obj);
      else
         break;
   }

   form_dial(3,0,0,0,0,xdial,ydial,wdial,hdial);

   wind_update(0);
   wind_update(2);

   return(exit_obj);
}

int
track_button(tree,button)
OBJECT *tree;
int button;
{
   int which,finished,butx,buty,butw,buth,dummy;

   butw=tree[button].ob_width;
   buth=tree[button].ob_height;

   objc_offset(tree,button,&butx,&buty);

   finished=FALSE;

   while(!finished)
   {
      which=evnt_multi(MU_BUTTON|MU_M1|MU_M2,1,0x01,0,
                       0x01,butx,buty,butw,buth,
                       0x00,butx,buty,butw,buth,
                       &dummy,
                       0,0,&dummy,&dummy,&dummy,&dummy,&dummy,&dummy);

      if(which & MU_M1)
         objc_change(tree,button,0,0,0,0,0,NORMAL,1);
      if(which & MU_M2)
         objc_change(tree,button,0,0,0,0,0,SELECTED,1);
      if(which & MU_BUTTON)
         finished=TRUE;
   }

   if(ob_selected(tree,button))
      return(TRUE);
   else
      return(FALSE);
}

up_button()
{
   int dummy;

   evnt_button(1,0x01,0,&dummy,&dummy,&dummy,&dummy);
}

mouse_pos(tree,next_obj)
OBJECT *tree;
int next_obj;
{
   char **tedptr,*tmp_ptr;
   int objx,new_idx,minx,dummy;

   tedptr=(char *)tree[next_obj].ob_spec;
   objc_offset(tree,next_obj,&objx,&dummy);

   tmp_ptr=((TEDINFO *)tree[next_obj].ob_spec)->te_ptmplt;
   minx=(tree[next_obj].ob_width-(strlen(tmp_ptr)*8))/2;

   new_idx=(mx-(objx-minx))/8;

   new_idx-=count_non_editables(tree,next_obj,new_idx);

   if(new_idx<0)
      new_idx=0;

   if(new_idx>strlen(*tedptr))
      new_idx=strlen(*tedptr);

   if(new_idx!=ed_idx || ed_obj!=next_obj)
   {
      objc_edit(tree,ed_obj,0,&ed_idx,EDEND);
      ed_idx=new_idx;
      objc_edit(tree,next_obj,0,&ed_idx,EDEND);
   }
}

int
count_non_editables(tree,next_obj,new_idx)
OBJECT *tree;
int next_obj,new_idx;
{
   char *tmp_ptr;
   int i,counter;

   tmp_ptr=((TEDINFO *)tree[next_obj].ob_spec)->te_ptmplt;

   counter=0;

   for(i=new_idx-1; i>=0; i--)
      if(tmp_ptr[i]!='_')
         counter++;

   return(counter);
}

int
val_special(tree,ed_char)
OBJECT *tree;
int ed_char;
{
   char *val_ptr,orgchr;
   int manipulated,at_end;

   if(ed_char==0x0E08 || ed_char==0x011B || ed_char==0x4B00 ||
      ed_char==0x4D00 || ed_char==0x537F)
      return(FALSE);

   val_ptr=((TEDINFO *)tree[ed_obj].ob_spec)->te_pvalid;

   manipulated=FALSE;

   if(ed_idx>=strlen(val_ptr))
      at_end=TRUE;
   else
      at_end=FALSE;

   if(val_ptr[ed_idx-at_end]=='t')
   {
      ed_char=toascii(ed_char);
      ed_char=tolower(ed_char);
      orgchr=val_ptr[ed_idx-at_end];
      manipulated=TRUE;
      if(ed_char!='a' && ed_char!='p')
         ed_char=0;
   }
   if(val_ptr[ed_idx-at_end]=='U' || val_ptr[ed_idx-at_end]=='u')
   {
      ed_char=toascii(ed_char);
      ed_char=toupper(ed_char);
      orgchr=val_ptr[ed_idx-at_end];
      manipulated=TRUE;
   }

   if(manipulated)
   {
      if(ed_char)
      {
         val_ptr[ed_idx-at_end]='X'; /* SET TO A VALUE THAT OBJC_EDIT WILL TAKE */
         objc_edit(tree,ed_obj,ed_char,&ed_idx,EDCHAR);
         val_ptr[ed_idx-1]=orgchr; /* RESTORE TO ORIGINAL VALIDATION CHR */
      }
   }

   return(manipulated);
}

