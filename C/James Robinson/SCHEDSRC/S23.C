/* S23.C -- HANDLE SELECTED RECORDS IN WINDOW REPORTS */

#include "obdefs.h"
#include "vdibind.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "schedule.h"

extern int vdi_handle,gl_hbox,gl_hchar,mx,my,dummy,sel_windex,
           rec_modified,rez;

extern char drecalrt[],*rec_items[6];

extern long menu_tree;

extern WIND window[NUM_WINDS];

extern SELECTION select[NUM_SELECTIONS];

rpt_button(windex)
int windex;
{
   int heads,sel_idx,add_y,add_height,top_idx,whand;

   wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);
   top_idx=set_windex(whand);

   if(windex!=top_idx)
      return;

   sel_windex=windex;

   if(mx<window[windex].work_area.g_x ||
      mx>window[windex].work_area.g_x+window[windex].work_area.g_w)
      return;

   heads=num_heads();
   sel_idx=(my-window[windex].work_area.g_y-heads)/(gl_hbox-2);

   if(my<window[windex].work_area.g_y+heads)
      return;

   if(my>window[windex].work_area.g_y+window[windex].work_area.g_h)
      return;

   if(select[sel_idx].sselected==TRUE)
      return;

   if(select[sel_idx].srec_no==(-1))
      return;

   select[sel_idx].sselected=TRUE;

   sel_down(sel_idx);

   add_y=num_y(sel_idx);

   add_height=num_height(sel_idx);

   sel_highlight(&window[windex].work_area,sel_idx,heads,add_y,add_height);

   menu_text(menu_tree,RECEDIT,rec_items[1]);
   menu_text(menu_tree,RECDELET,rec_items[3]);
   menu_text(menu_tree,RECTRANS,rec_items[5]);

   menu_ienable(menu_tree,RECCLEAR,1);
   menu_ienable(menu_tree,RECPRINT,1);
}

sel_clear(area,flag)
GRECT *area;
int flag;
{
   int i,heads,add_y,add_height;

   for(i=0; i<NUM_SELECTIONS; i++)
   {
      if(select[i].sselected==TRUE && select[i].srec_no>(-1))
      {
         if(select[i].scommon==TRUE)
         {
            if(flag)
               select[i].sselected=FALSE;
         }
         else
         {
            heads=num_heads();
            if(flag)
               select[i].sselected=FALSE;
            add_y=num_y(i);
            add_height=num_height(i);
            sel_highlight(area,i,heads,add_y,add_height);
         }
      }
   }
   menu_ienable(menu_tree,RECCLEAR,0);
   menu_ienable(menu_tree,RECPRINT,0);
   rec_menu_normal();

   if(flag)
      sel_windex=(-1);
}

int
num_heads()
{
   int heads;

   heads=0;
   if(strlen(window[sel_windex].w1header)>0)
      heads+=(10*rez);
   if(strlen(window[sel_windex].w2header)>0)
      heads+=(10*rez);

   return(heads);
}

int
num_y(sel_idx)
int sel_idx;
{
   int add_y,i;

   add_y=0;

   for(i=0; i<sel_idx; i++)
   {
      if(select[sel_idx].srec_no==select[i].srec_no)
      {
         add_y+=(gl_hbox-2);
         select[i].sselected=TRUE;
      }
   }
   return(add_y);
}

sel_down(sel_idx)
int sel_idx;
{
   int i;

   for(i=sel_idx; i<NUM_SELECTIONS; i++)
   {
      if(select[sel_idx].srec_no==select[i].srec_no)
         select[i].sselected=TRUE;
   }
}

int
num_height(sel_idx)
int sel_idx;
{
   int add_height,i;

   add_height=0;

   if(sel_idx<NUM_SELECTIONS)
   {
      for(i=sel_idx+1; i<NUM_SELECTIONS; i++)
      {
         if(select[sel_idx].srec_no==select[i].srec_no)
         {
            add_height+=(gl_hbox-2);
            select[i].sselected=TRUE;
         }
      }
   }
   return(add_height);
}

sel_highlight(area,sel_idx,heads,add_y,add_height)
GRECT *area;
int sel_idx,heads,add_y,add_height;
{
   int pxy[4];

   pxy[0]=window[sel_windex].work_area.g_x;
   pxy[1]=window[sel_windex].work_area.g_y+heads+(sel_idx*(gl_hbox-2))-add_y;
   pxy[2]=pxy[0]+window[sel_windex].work_area.g_w;
   pxy[3]=pxy[1]+(gl_hchar)+add_height+add_y+1;

   vswr_mode(vdi_handle,MD_XOR);
   vsf_perimeter(vdi_handle,FALSE);

   set_clip(vdi_handle,TRUE,area);

   HIDE_MOUSE;
   v_bar(vdi_handle,pxy);
   SHOW_MOUSE;

   set_clip(vdi_handle,FALSE,area);

   vsf_perimeter(vdi_handle,TRUE);

   vswr_mode(vdi_handle,MD_REPLACE);
}

rec_menu_normal()
{
   menu_text(menu_tree,RECEDIT,rec_items[0]);
   menu_text(menu_tree,RECDELET,rec_items[2]);
   menu_text(menu_tree,RECTRANS,rec_items[4]);
}

