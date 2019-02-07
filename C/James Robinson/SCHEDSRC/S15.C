/* S15.C -- CALENDAR DIALOG SIMULATED WINDOW FUNCTIONS */

#include "obdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int cicolumns,cilines,cixdescr,cixind,ciyind,my,mx,cicounter,
           cishown,cixshown,rpt_index,cal_idx,sel_tab[CAL_LINES],rec_no;

extern char hdate[9],header1[MAX_CLMS+1],header2[MAX_CLMS+1],
            und_score[MAX_CLMS+1];

extern OBJECT *citree;

extern WIND window[NUM_WINDS];

extern RPT report[NUM_REPORTS];

ci_vt_slider(tree)
OBJECT *tree;
{
   float perc,offset;
   int startx,starty,boundx,boundy,xfinish,yfinish;

   offset=((float)cilines+(float)cixdescr)/(float)cilines;

   objc_offset(tree,CIVTSLID,&startx,&starty);
   objc_offset(tree,CIVTSCR,&boundx,&boundy);

   graf_dragbox(tree[CIVTSLID].ob_width,tree[CIVTSLID].ob_height,
                startx,starty,boundx,boundy,
                tree[CIVTSCR].ob_width,tree[CIVTSCR].ob_height,
                &xfinish,&yfinish);

   perc=((float)yfinish-(float)boundy)/
        ((float)tree[CIVTSCR].ob_height-(float)tree[CIVTSLID].ob_height);

   ciyind=(float)perc*((float)cilines-((float)CAL_LINES/(float)offset));

   ci_boundaries();
}

ci_hz_slider(tree)
OBJECT *tree;
{
   float perc;
   int startx,starty,boundx,boundy,xfinish,yfinish;

   objc_offset(tree,CIHZSLID,&startx,&starty);
   objc_offset(tree,CIHZSCR,&boundx,&boundy);

   graf_dragbox(tree[CIHZSLID].ob_width,tree[CIHZSLID].ob_height,
                startx,starty,boundx,boundy,
                tree[CIHZSCR].ob_width,tree[CIHZSCR].ob_height,
                &xfinish,&yfinish);

   perc=((float)xfinish-(float)boundx)/
        ((float)tree[CIHZSCR].ob_width-(float)tree[CIHZSLID].ob_width);

   cixind=(float)perc*((float)cicolumns-70.0);

   ci_header(tree);
}

ci_size_sliders(tree)
OBJECT *tree;
{
   float val,offset;

   offset=((float)cilines+(float)cixdescr)/(float)cilines;

   val=(float)cilines/((float)CAL_LINES/(float)offset);
   if(val<1.0 || rec_no==0)
      val=1.0;

   tree[CIVTSLID].ob_height=MAX(10,(int)tree[CIVTSCR].ob_height/val);

   if(tree[CIVTSLID].ob_height>tree[CIVTSCR].ob_height)
      tree[CIVTSLID].ob_height=tree[CIVTSCR].ob_height;

   val=cicolumns/70.0;
   if(val<1.0)
      val=1.0;

   tree[CIHZSLID].ob_width=MAX(20,(int)tree[CIHZSCR].ob_width/val);

   if(tree[CIHZSLID].ob_width>tree[CIHZSCR].ob_width)
      tree[CIHZSLID].ob_width=tree[CIHZSCR].ob_width;
}

vt_scroll(tree)
OBJECT *tree;
{
   int slidex,slidey;

   objc_offset(tree,CIVTSLID,&slidex,&slidey);

   if(my<slidey)
      ciyind-=cishown;
   else
      ciyind+=cishown;

   set_vt_pos(tree);
}

hz_scroll(tree)
OBJECT *tree;
{
   int slidex,slidey;

   objc_offset(tree,CIHZSLID,&slidex,&slidey);

   if(mx<slidex)
      cixind-=70;
   else
      cixind+=70;

   set_hz_pos(tree);
}

set_vt_pos(tree)
OBJECT *tree;
{
   float perc,val,offset;

   offset=((float)cilines+(float)cixdescr)/(float)cilines;

   ci_shown_count();

   ci_boundaries();

   perc=((float)ciyind/
        ((float)cilines-
        ((float)CAL_LINES/(float)offset)));

   val=(((float)tree[CIVTSCR].ob_height-(float)tree[CIVTSLID].ob_height)*(float)perc)+(float)tree[CIVTSCR].ob_y;

   if(val+tree[CIVTSLID].ob_height>=tree[CIVTSCR].ob_y+tree[CIVTSCR].ob_height)
      tree[CIVTSLID].ob_y=tree[CIVTSCR].ob_y+tree[CIVTSCR].ob_height-tree[CIVTSLID].ob_height;
   else
      tree[CIVTSLID].ob_y=val;

   objc_draw(tree,CIVTSCR,0,0,0,0,0);
   objc_draw(tree,CIVTSLID,0,0,0,0,0);
}

set_hz_pos(tree)
OBJECT *tree;
{
   float perc,val;

   ci_boundaries();

   perc=(float)cixind/(float)cicolumns;

   val=tree[CIHZSCR].ob_width*perc;
   if(val<0)
      val=0;

   val+=tree[CIHZSCR].ob_x;

   if(val+tree[CIHZSLID].ob_width>=tree[CIHZSCR].ob_x+tree[CIHZSCR].ob_width)
      tree[CIHZSLID].ob_x=tree[CIHZSCR].ob_x+tree[CIHZSCR].ob_width-tree[CIHZSLID].ob_width;
   else
      tree[CIHZSLID].ob_x=val;

   objc_draw(tree,CIHZSCR,0,0,0,0,0);
   objc_draw(tree,CIHZSLID,0,0,0,0,0);
}

ci_header(tree)
OBJECT *tree;
{
   char **tedptr;

   ci_boundaries();

   tedptr=(char *)tree[CIHEADER].ob_spec;
   strcpy(*tedptr,mid(header1,cixind+1,70));
   strcat(*tedptr,replicate(' ',70-strlen(*tedptr)));

   objc_draw(tree,CIHEADER,0,0,0,0,0);
}

set_header()
{
   rpt_index=0;
   do_header(rpt_index,header1,header2,und_score);
   cicolumns=strlen(header1)-report[rpt_index].cspacing[0];
}

ci_report()
{
   rpt_index=0;
   print_schedule(DEV_CINFO_WINDOW,-2,hdate,hdate,window[cal_idx].wstime,
                  window[cal_idx].wetime,window[cal_idx].wsubj,
                  window[cal_idx].wxfield[0],window[cal_idx].wxfield[1],
                  window[cal_idx].wxfield[2],window[cal_idx].wxfield[3],
                  window[cal_idx].wxfield[4],window[cal_idx].wdescr);
}

ci_reset(tree)
OBJECT *tree;
{
   int i;
   char **tedptr;

   for(i=0; i<CAL_LINES; i++)
   {
       tedptr=(char *)tree[CIDESCR1+i].ob_spec;
       strcpy(*tedptr,"\0");
       tree[CIDESCR1+i].ob_state=DISABLED;
       sel_tab[i]=(-1);
   }

   cixind=0; ciyind=0;

   tree[CIVTSLID].ob_y=tree[CIVTSCR].ob_y;
   tree[CIHZSLID].ob_x=tree[CIHZSCR].ob_x;
}

ci_shown_count()
{
   print_schedule(DEV_SHOWN,-2,hdate,hdate,window[cal_idx].wstime,
                  window[cal_idx].wetime,window[cal_idx].wsubj,
                  window[cal_idx].wxfield[0],window[cal_idx].wxfield[1],
                  window[cal_idx].wxfield[2],window[cal_idx].wxfield[3],
                  window[cal_idx].wxfield[4],window[cal_idx].wdescr);
}

ci_boundaries()
{
   int old_y;
   float offset;

   old_y=ciyind;

   offset=((float)cilines+(float)cixdescr)/(float)cilines;

   if(cixind>cicolumns-70)
      cixind=cicolumns-70;
   if(cixind<0)
      cixind=0;
   if(cishown==0)
      ciyind--;
   if(ciyind<0)
      ciyind=0;

   if(old_y!=ciyind)
      ci_shown_count();
}


