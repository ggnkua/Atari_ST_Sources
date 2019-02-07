/* GEMTOOLS.C */

#include "obdefs.h"
#include "gemdefs.h"
#include "schedule.h"
#include "schdefs.h"
#include "ctools.h"

extern WIND window[NUM_WINDS];

extern SELECTION select[NUM_SELECTIONS];

extern int  dummy,pxy[4],cal_idx,rpt_index,vdi_handle,gl_hbox,
            cal_idx,topped,sel_windex,ed_obj,ed_idx,
            org_y[2][500],org_height[2],rez;

extern char wdwalrt[];

static char org_ed[75][61],org_rbut[100];

hide_windows()
{
   int  i;

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].whidden==FALSE)
      {
         window[i].whidden=TRUE;
         wind_close(window[i].whandle);
      }
   }
}

show_windows()
{
   int  i,top,whand,top_idx,dummy;

   wind_update(1);

   top=(-1);

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].whidden==TRUE)
      {
         wind_open(window[i].whandle,
                   window[i].wx,window[i].wy,
                   window[i].wwidth,window[i].wheight);
         fill_window(&window[i].work_area);
         window[i].whidden=FALSE;

         if(window[i].wtopped==TRUE)
            top=i;
      }
   }
   if(top!=(-1))
   {
      wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);
      top_idx=set_windex(whand);
      if(top!=top_idx)
         top_window(window[top].whandle,FALSE);
      if(window[top].wcontents>=WC_REPORT && window[top].wopen==TRUE)
         shown_count(top);
   }

   for(i=0; i<NUM_SELECTIONS; i++)
      select[i].sselected=FALSE;

   wind_update(0);
}

top_window(whand,draw_flag)
int  whand,draw_flag;
{
   int  windex;

   if(whand>0)
   {
      windex=set_windex(whand);

      wind_set(whand,WF_TOP,0,0,0,0);
      if(window[windex].wopen==TRUE &&
         window[windex].wcontents==WC_CALENDAR && draw_flag)
      {
         set_xy(window[windex].work_area.g_x,window[windex].work_area.g_y);
         cal_idx=windex;
         draw_cal(windex,&window[windex].work_area);
      }
   }
}

clr_tops()
{
   int  i;

   for(i=0; i<NUM_WINDS; i++)
      window[i].wtopped=FALSE;
}

int 
get_windex()
{
   int  i;

   for(i=0; i<NUM_WINDS; i++)
      if(window[i].wopen!=TRUE)
         return(i);
   return(-1);
}

int 
create_window(contents,features,clr_flag,windex)
int  contents,features,clr_flag,windex;
{
   WIND *wdw;
   int  i,gl_xfull,gl_yfull,gl_wfull,gl_hfull;

   if(clr_flag)
   {
      i=get_windex();

      if(i==(-1))
      {
         form_alert(1,wdwalrt);
         return(-1);
      }
   }
   else
      i=windex;

   wdw = &window[i];

   if(clr_flag)
   {
      window[i].wcontents=contents;
      window[i].wfeatures=features;
   }

   if(window[i].wcontents>=WC_REPORT)
   {
      if(clr_flag)
         window[i].wcontents=contents+rpt_index;
      set_wdw_header(i);
   }

   if(clr_flag)
   {
      window[i].wbeg_flag=FALSE;
      window[i].wend_flag=FALSE;
      window[i].wsys_sdate=FALSE;
      window[i].wsys_edate=FALSE;
      window[i].wxindex=0;
      window[i].wyindex=0;
      window[i].wlines=0;
   }

   wind_get(0,WF_WXYWH,&gl_xfull,&gl_yfull,&gl_wfull,&gl_hfull);

   window[i].whandle=wind_create(features,gl_xfull-1,gl_yfull,
                                 gl_wfull,gl_hfull);

   if(!clr_flag && window[i].whandle<=ERROR)
   {
      form_alert(1,wdwalrt);
      return(-1);
   }

   strcpy(wdw->wtitle,"\0");

   wind_set(window[i].whandle,WF_NAME,wdw->wtitle,0,0);

   if(clr_flag && window[i].wcontents>=WC_REPORT && window[i].wheight<(70*rez))
   {
      window[i].wx=gl_xfull-1;
      window[i].wy=gl_yfull;
      window[i].wwidth=gl_wfull;
      window[i].wheight=gl_hfull;
   }
   return(i);
}

do_name(string)
char *string;
{
   auto char temp[81];

   strcpy(temp," ");
   strcat(temp,string);
   strcat(temp," ");
   strcpy(string,temp);
}

open_window(windex)
int  windex;
{
   wind_open(window[windex].whandle,window[windex].wx,window[windex].wy,
             window[windex].wwidth,window[windex].wheight);

   wind_get(window[windex].whandle,WF_WXYWH,
            &window[windex].work_area.g_x,&window[windex].work_area.g_y,
            &window[windex].work_area.g_w,&window[windex].work_area.g_h);

   window[windex].wopen=TRUE;

   fill_window(&window[windex].work_area);
   set_sliders(window[windex].whandle,window[windex].wcontents);
}

fill_window(clip_area)
GRECT *clip_area;
{
   vsf_interior(vdi_handle,1);
   vsf_color(vdi_handle,WHITE);
   grect_to_array(clip_area,pxy);
   HIDE_MOUSE;
   vr_recfl(vdi_handle,pxy);
   SHOW_MOUSE;
}

fulled(wh)
int  wh;
{
   GRECT prev,curr,full;
   int  windex;
 
   HIDE_MOUSE;

   windex=set_windex(wh);

   wind_get(wh,WF_FXYWH,&full.g_x,&full.g_y,&full.g_w,&full.g_h);
   wind_get(wh,WF_CXYWH,&curr.g_x,&curr.g_y,&curr.g_w,&curr.g_h);

   if(rc_equal(&curr,&full))
   {
      wind_get(wh,WF_PXYWH,&prev.g_x,&prev.g_y,&prev.g_w,&prev.g_h);
      if(!rc_equal(&prev,&full))
      {
         wind_set(wh,WF_CXYWH,prev.g_x,prev.g_y,prev.g_w,prev.g_h);
         wind_get(wh,WF_WXYWH,
                  &window[windex].work_area.g_x,&window[windex].work_area.g_y,
                  &window[windex].work_area.g_w,&window[windex].work_area.g_h);
         wind_get(wh,WF_CXYWH,
                  &window[windex].wx,&window[windex].wy,
                  &window[windex].wwidth,&window[windex].wheight);
      }
   }
   else
   {
      wind_set(wh,WF_CXYWH,full.g_x,full.g_y,full.g_w,full.g_h);
      wind_get(wh,WF_WXYWH,
               &window[windex].work_area.g_x,&window[windex].work_area.g_y,
               &window[windex].work_area.g_w,&window[windex].work_area.g_h);
      wind_get(wh,WF_CXYWH,
               &window[windex].wx,&window[windex].wy,
               &window[windex].wwidth,&window[windex].wheight);
   }
   SHOW_MOUSE;
}

redraw(whand,area)
int  whand;
GRECT *area;
{
   GRECT box,dummy;
   int  windex,top_idx,top_hand;

   wind_update(1);

   windex=set_windex(whand);

   HIDE_MOUSE;
   wind_get(whand,WF_FIRSTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
   while(box.g_w && box.g_h)
   {
      if(window[windex].wcontents==WC_CALENDAR)
      {
         if(rc_intersect(area,&box))
         {
            cal_idx=windex;
            draw_cal(windex,&box);
         }
      }
      else if(window[windex].wcontents>=WC_REPORT)
      {
         sel_clear(&box,FALSE);

         if(rc_intersect(area,&box))
            wind_report(windex,&box);
      }
      wind_get(whand,WF_NEXTXYWH,&box.g_x,&box.g_y,&box.g_w,&box.g_h);
   }
   SHOW_MOUSE;

   sel_clear(&dummy,TRUE);

   if(window[windex].wcontents>=WC_REPORT)
   {
      wind_get(0,WF_TOP,&top_hand,&dummy,&dummy,&dummy);
      top_idx=set_windex(top_hand);
      if(windex==top_idx || window[top_idx].wopen!=TRUE)
         shown_count(windex);
   }
   wind_update(0);
}

int 
set_windex(whand)
int  whand;
{
   int  i;

   for(i=0; i<NUM_WINDS; i++)
      if(window[i].whandle==whand)
         return(i);

   return(-1);
}

grect_to_array(area,array)
GRECT *area;
int  *array;
{
   *array++ = area->g_x;
   *array++ = area->g_y;
   *array++ = area->g_x + area->g_w - 1;
   *array = area->g_y + area->g_h - 1;
}

set_clip(vdi_handle,clip_flag,s_area)
int  vdi_handle,clip_flag;
GRECT *s_area;
{
   int pxy[4];

   grect_to_array(s_area,pxy);
   vs_clip(vdi_handle,clip_flag,pxy);
}

rc_intersect(p1,p2)
GRECT *p1,*p2;
{
     int tx,ty,tw,th;

     tw = min(p2->g_x + p2->g_w, p1->g_x + p1->g_w);
     th = min(p2->g_y + p2->g_h, p1->g_y + p1->g_h);
     tx = max(p2->g_x, p1->g_x);
     ty = max(p2->g_y, p1->g_y);
     p2->g_x = tx;
     p2->g_y = ty;
     p2->g_w = tw - tx;
     p2->g_h = th - ty;
     return((tw > tx) && (th > ty));
}

rc_equal(p1,p2)
GRECT *p1,*p2;
{
   if((p1->g_x != p2->g_x) ||
      (p1->g_y != p2->g_y) ||
      (p1->g_w != p2->g_w) ||
      (p1->g_h != p2->g_h))
         return(FALSE);
   return(TRUE);
}

align_x(x)
int  x;
{
   return((x & 0xfff0) + ((x & 0x000c) ? 0x0010 : 0));
}

ob_selected(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_state & SELECTED)
      return(TRUE);
   else
      return(FALSE);
}

ob_disabled(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_state & DISABLED)
      return(TRUE);
   else
      return(FALSE);
}

ob_hide(tree,obj)
OBJECT *tree;
int obj;
{
   tree[obj].ob_flags|=HIDETREE;
}

ob_unhide(tree,obj)
OBJECT *tree;
int obj;
{
   int flags;

   flags=tree[obj].ob_flags;
   tree[obj].ob_flags=flags & ~HIDETREE;
}

ob_hidden(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & HIDETREE)
      return(TRUE);
   else
      return(FALSE);
}

sel_obj(tree,obj)
OBJECT *tree;
int obj;
{
   tree[obj].ob_state|=SELECTED;
}

desel_obj(tree,obj)
OBJECT *tree;
int obj;
{
   int state;

   state=tree[obj].ob_state;
   tree[obj].ob_state=state & ~SELECTED;
}

ob_exit(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & EXIT)
      return(TRUE);
   else
      return(FALSE);
}

ob_touch_exit(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & TOUCHEXIT)
      return(TRUE);
   else
      return(FALSE);
}

ob_checked(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_state & CHECKED)
      return(TRUE);
   else
      return(FALSE);
}

ob_uncheck(tree,obj)
OBJECT *tree;
int obj;
{
   int state;

   state=tree[obj].ob_state;
   tree[obj].ob_state=state & ~CHECKED;
}

unhide_all(tree)
OBJECT *tree;
{
   int  i;

   i=0;
  
   for(;;)
   {
      if(ob_hidden(tree,i))
         ob_unhide(tree,i);
      if(last_ob(tree,i))
         break;
      i++;
   }
}

last_ob(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & LASTOB)
      return(TRUE);
   else
      return(FALSE);
}

ob_editable(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & EDITABLE)
      return(TRUE);
   else
      return(FALSE);
}

ob_rbutton(tree,obj)
OBJECT *tree;
int obj;
{
   if(tree[obj].ob_flags & RBUTTON)
      return(TRUE);
   else
      return(FALSE);
}

clear_form(tree)
OBJECT *tree;
{
   char **tedptr;
   int  i;

   i=0;

   for(;;)
   {
      i++;
      if(ob_editable(tree,i))
      {
         tedptr=(char *)tree[i].ob_spec;
         strcpy(*tedptr,"\0");
      }
      if(last_ob(tree,i))
         break;
   }
}

save_form(tree)
OBJECT *tree;
{
   char **tedptr;
   int  obj,ed_idx;

   obj=0; ed_idx=0;

   for(;;)
   {
      obj++;
      org_rbut[obj]=FALSE;
      if(ob_editable(tree,obj))
      {
         tedptr=(char *)tree[obj].ob_spec;
         strcpy(org_ed[ed_idx],*tedptr);
         ed_idx++;
      }
      else if(ob_rbutton(tree,obj))
         if(ob_selected(tree,obj))
            org_rbut[obj]=TRUE;
      if(last_ob(tree,obj))
         break;
   }
}

save_ob_xy(tree,tdef)
OBJECT *tree;
int  tdef;
{
   int  i,which;

   if(tdef==TEDITREC)
      which=0;
   if(tdef==TPRTREPT)
      which=1;

   i=0;

   for(;;)
   {
      org_y[which][i]=tree[i].ob_y;
      if(last_ob(tree,i))
      {
         i++;
         org_y[which][i]=(-99);
         break;
      }
      i++;
   }
   org_height[which]=tree[0].ob_height;
}

restore_ob_xy(tree,tdef) /* well... y and height anyway... */
OBJECT *tree;
int  tdef;
{
   int  i,which;

   i=0;

   if(tdef==TEDITREC)
      which=0;
   if(tdef==TPRTREPT)
      which=1;

   for(;;)
   {
      tree[i].ob_y=org_y[which][i];

      if(last_ob(tree,i))
         break;

      if(org_y[which][i]==(-99))
         break;

      i++;
   }
   tree[0].ob_height=org_height[which];

   if(tree[0].ob_height<20) /* bug should be fixed, but let's make sure */
   {
      if(tdef==TEDITREC)
         tree[0].ob_height=(160*rez);
      else
         tree[0].ob_height=(168*rez);
   }
}

set_xy(x,y)
int  x,y;
{
   OBJECT *tree;

   rsrc_gaddr(0,TCALEND,&tree);

   tree[0].ob_x=x;
   tree[0].ob_y=y+1;
}

cancel_form(tree)
OBJECT *tree;
{
   char **tedptr;
   int  obj,ed_idx,rbut_idx;

   obj=0; ed_idx=0; rbut_idx=0;

   for(;;)
   {
      obj++;
      if(ob_editable(tree,obj))
      {
         tedptr=(char *)tree[obj].ob_spec;
         strcpy(*tedptr,org_ed[ed_idx]);
         ed_idx++;
      }
      else if(ob_rbutton(tree,obj))
         if(org_rbut[obj]==TRUE)
            reset_rbuttons(tree,obj,FALSE);
      if(last_ob(tree,obj))
         break;
   }
}

ob_sel(tree,obj)
OBJECT *tree;
int  obj;
{
   tree[obj].ob_state|=SELECTED;
}

set_state(tree,obj,bit)
OBJECT *tree;
int obj,bit;
{
   tree[obj].ob_state|=bit;
}

del_state(tree,obj,bit)
OBJECT *tree;
int obj,bit;
{
   int state;

   state=tree[obj].ob_state;
   tree[obj].ob_state=state & ~bit;
}

ob_date(tree,obj)
OBJECT *tree;
int obj;
{
   char *tmp_ptr;
   
   tmp_ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;

   if(strcmp(tmp_ptr,"__/__/____")==0)
      return(TRUE);
   else if(strcmp(tmp_ptr,"__/__/__")==0)
      return(TRUE);
   else if(strcmp(tmp_ptr,"__/__")==0)
      return(TRUE);

   return(FALSE);
}

ob_time(tree,obj)
OBJECT *tree;
int  obj;
{
   char *tmp_ptr;
   
   tmp_ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;

   if(strcmp(tmp_ptr,"__:__ _.m.")==0)
      return(TRUE);

   return(FALSE);
}

work_shown(windex)
int  windex;
{
   int  amt,heads;
   float offset;

   heads=0;

   if(strlen(window[windex].w1header)>0)
      heads++;
   if(strlen(window[windex].w2header)>0)
      heads++;

   offset=((float)window[windex].wlines+(float)window[windex].wxdescr)/
           (float)window[windex].wlines;

   amt=((((float)window[windex].work_area.g_h-((float)gl_hbox-1.0))/
         ((float)gl_hbox-2.0))/(float)offset)/(float)heads;

   return(amt);
}

