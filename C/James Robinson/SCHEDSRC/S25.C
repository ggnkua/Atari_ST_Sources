/* S25.C -- WINDOW, MISC FUNCTIONS */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "ctools.h"
#include "schdefs.h"
#include "schedule.h"

extern int vdi_handle,dummy,py,mark_x[NUM_WINDS],mark_y[NUM_WINDS],rez;

extern char header1[MAX_CLMS+1],header2[MAX_CLMS+1],und_score[MAX_CLMS+1],
            sys_time[6],sys_date[9],nowdwalrt[];

extern WIND window[NUM_WINDS];

extern RPT report[NUM_REPORTS];

extern OTHER_PREFS prefs;

wdw_header(windex,clip_area)
int windex;
GRECT *clip_area;
{
   int pxy[4],totcol,flag,i;

   wind_update(1);

   HIDE_MOUSE;

   set_clip(vdi_handle,TRUE,clip_area);

   totcol=(window[windex].work_area.g_w-2)/8;

   py=0;

   for(i=0; i<2; i++)
   {
      flag=FALSE;

      if(i==0 && strlen(window[windex].w1header)>0)
         flag=TRUE;
      else if(i==1 && strlen(window[windex].w2header)>0)
         flag=TRUE;

      if(flag==TRUE)
      {
         if(i==0)
            wind_text(windex,mid(window[windex].w1header,
                                 window[windex].wxindex+1,totcol));
         else
            wind_text(windex,mid(window[windex].w2header,
                                 window[windex].wxindex+1,totcol));

         pxy[0]=window[windex].work_area.g_x;
         pxy[1]=window[windex].work_area.g_y+py;
         pxy[2]=pxy[0]+window[windex].work_area.g_w;
         pxy[3]=pxy[1];

         vsl_color(vdi_handle,1);
         vsl_type(vdi_handle,1);
         v_pline(vdi_handle,2,pxy);

         py++;
      }
   }

   set_clip(vdi_handle,FALSE,clip_area);

   SHOW_MOUSE;

   wind_update(0);
}

upd_header(windex)
int windex;
{
   GRECT box;

   wind_update(1);

   HIDE_MOUSE;

   wind_get(window[windex].whandle,WF_FIRSTXYWH,
            &box.g_x,&box.g_y,&box.g_w,&box.g_h);

   while(box.g_w && box.g_h)
   {
      wdw_header(windex,&box);
      wind_get(window[windex].whandle,WF_NEXTXYWH,
         &box.g_x,&box.g_y,&box.g_w,&box.g_h);
   }

   SHOW_MOUSE;

   wind_update(0);
}

set_wdw_header(windex)
int windex;
{
   do_header(window[windex].wcontents-WC_REPORT,header1,header2,und_score);
   strcpy(window[windex].w1header,header1);
   strcpy(window[windex].w2header,header2);
   window[windex].wcolumns=strlen(window[windex].w1header);
   if(strlen(window[windex].w2header)>window[windex].wcolumns)
      window[windex].wcolumns=strlen(window[windex].w2header);
}

set_all_wdw_headers()
{
   int i;

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT)
      {
         set_wdw_header(i);
         upd_header(i);
      }
   }
}

upd_name(windex)
int windex;
{
   WIND *wdw;

   wdw = &window[windex];

   if(report[window[windex].wcontents-WC_REPORT].cavailable==TRUE)
      strcpy(wdw->wtitle,report[window[windex].wcontents-WC_REPORT].cname);
   else
      strcpy(wdw->wtitle,"Untitled Report");
   do_name(wdw->wtitle);

   wind_set(window[windex].whandle,WF_NAME,wdw->wtitle,0,0);
}

set_names()
{
   int i;

   for(i=0; i<NUM_WINDS; i++)
      if(window[i].wopen==TRUE && window[i].wcontents>=WC_REPORT)
          upd_name(i);
}

clr_window(whand)
int whand;
{
   int i,windex;

   windex=set_windex(whand);

   window[windex].wopen=FALSE;
   window[windex].whandle=(-1);
   window[windex].whidden=FALSE;
   window[windex].wfeatures=0;
   window[windex].wtopped=FALSE;
   window[windex].wcontents=(-1);
   window[windex].wxindex=0;
   window[windex].wyindex=0;
   window[windex].wlines=0;
   window[windex].wcolumns=0;
   window[windex].wbeg_flag=FALSE;
   window[windex].wend_flag=FALSE;
   window[windex].wsys_sdate=FALSE;
   window[windex].wsys_edate=FALSE;

   window[windex].wdecision[0]=EQUAL;
   window[windex].wdecision[1]=EQUAL;
   for(i=0; i<7; i++)
      window[windex].wdecision[2+i]=IN;

   strcpy(window[windex].w1header,"\0");
   strcpy(window[windex].w2header,"\0");
}

close_all_windows()
{
   int i;

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wopen==TRUE)
      {
         wind_close(window[i].whandle);
         wind_delete(window[i].whandle);
         clr_window(window[i].whandle);
      }
   }
}

edit_top_window()
{
   modify_records(WDWEDIT);
}

edit_all_windows()
{
   modify_records(WDWEDALL);
}

time_display()
{
   char time[11],date[9],temp[11];
   static int toggle;

   if(!prefs.optime_display && !prefs.opdate_display)
      return;

   vst_color(vdi_handle,BLACK);
   vst_effects(vdi_handle,NORMAL);
   vswr_mode(vdi_handle,MD_REPLACE);

   if(prefs.optime_display && prefs.opdate_display)
   {
      if(toggle==2)
         toggle=1;
      else
         toggle=2;
   }

   if((prefs.optime_display && !prefs.opdate_display) ||
      (prefs.optime_display && toggle==1))
   {
      if(strcmp(mid(sys_time,2,2),"00")==0)
      {
         time[0]='1'-32;
         time[1]='2'-32;
      }
      else
      {
         if(sys_time[1]=='0')
         {
            time[0]=' ';
            time[1]=sys_time[2]-32;
         }
         else
         {
            time[0]=sys_time[1]-32;
            time[1]=sys_time[2]-32;
         }
      }
      time[2]=':';
      time[3]=sys_time[3]-32;
      time[4]=sys_time[4]-32;

      time[5]='\0';

      if(sys_time[0]=='a')
         strcat(time," a.m.");
      else
         strcat(time," p.m.");

      HIDE_MOUSE;
      v_gtext(vdi_handle,544,7*rez,time);
      SHOW_MOUSE;
   }
   else if((prefs.opdate_display && !prefs.optime_display) ||
           (prefs.opdate_display && toggle==2))
   {
      strcpy(date,"\0");
      cat_short_date(date,sys_date);

      strcpy(temp,replicate(' ',(10-strlen(date))/2));
      strcat(temp,date);
      strcat(temp,replicate(' ',10-strlen(date)));

      HIDE_MOUSE;
      v_gtext(vdi_handle,544,7*rez,temp);
      SHOW_MOUSE;
   }
}

mark_position()
{
   int whand,windex;

   wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);

   if(whand==0)
   {
      form_alert(1,nowdwalrt);
      return;
   }

   windex=set_windex(whand);

   if(window[windex].wopen==TRUE)
   {
      mark_x[windex]=window[windex].wxindex;
      mark_y[windex]=window[windex].wyindex;
   }
}

goto_mark()
{
   int whand,windex,dummy;

   wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);

   if(whand==0)
   {
      form_alert(1,nowdwalrt);
      return;
   }

   windex=set_windex(whand);

   if(window[windex].wopen==TRUE)
   {
      window[windex].wxindex=mark_x[windex];
      window[windex].wyindex=mark_y[windex];

      if(window[windex].wcontents>=WC_REPORT)
      {
         rpt_boundaries(windex);
         set_sliders(window[windex].whandle,window[windex].wcontents);
         wind_report(windex,&window[windex].work_area);
         shown_count(windex);
      }
      else if(window[windex].wcontents==WC_CALENDAR)
      {
         if(window[windex].wyindex>11)
            window[windex].wyindex=11;
         if(window[windex].wxindex>399)
            window[windex].wxindex=399;
         set_sliders(window[windex].whandle,window[windex].wcontents);
         draw_cal(windex,&window[windex].work_area);
      }
   }
}


