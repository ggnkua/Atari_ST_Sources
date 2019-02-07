/* S13.C -- CALENDAR, MISC FUNCTIONS */

#include "obdefs.h"
#include "gemdefs.h"
#include "schdefs.h"
#include "schedule.h"
#include "ctools.h"

extern int  rec_no,vdi_handle,dummy,mx,my,cal_idx,pxy[4],sel_windex,
            rm_decision[9],cal_flags[31],rez;

extern char sys_date[9],rm_stime[6],rm_etime[6],rm_subj[41],
            rm_xfield[NUM_XFIELDS][41],rm_descr[41];

extern WIND window[NUM_WINDS];

extern RECORD *rec;

extern CUSTOM data_entry;

cal_window()
{
   long tree;
   int  windex,xdial,ydial,wdial,hdial;

   wind_update(1);
   
   windex=create_window(WC_CALENDAR,CAL_WFEATURES,TRUE,0);

   if(windex==(-1))
   {
      wind_update(0);
      return(0);
   }

   rsrc_gaddr(0,TCALEND,&tree);

   form_center(tree,&xdial,&ydial,&wdial,&hdial);

   window[windex].wx=align_x(xdial)-1;
   window[windex].wy=ydial-(10*rez);
   window[windex].wwidth=wdial+25;
   window[windex].wheight=hdial+(13*rez);

   window[windex].wlines=399;
   window[windex].wxindex=year(sys_date)-1700;
   window[windex].wyindex=month(sys_date);

   cal_idx=windex;

   if(modify_records(CALOPEN))
      open_window(windex);
   else
   {
      wind_delete(window[windex].whandle);
      clr_window(window[windex].whandle);
   }

   wind_update(0);
}

draw_cal(calindex,clip_area)
int  calindex;
GRECT *clip_area;
{
   WIND *wdw;
   OBJECT *tree;
   static char **tedptr,str[3],title[80],mn_str[3],yr_str[5],res_date[9];
   register int  i,mn,dy,yr,first_used;
   
   if(window[calindex].wcontents!=WC_CALENDAR ||
      window[calindex].wheight==0)
      return(-1);

   wind_update(1);

   rsrc_gaddr(0,TCALEND,&tree);

   mn=window[calindex].wyindex;
   yr=1700+window[calindex].wxindex;
   if(mn<1)
   {
      mn=12;
      yr--;
      window[calindex].wyindex=12;
      window[calindex].wxindex--;
   }
   if(mn>12)
   {
      mn=1;
      yr++;
      window[calindex].wyindex=1;
      window[calindex].wxindex++;
   }
   if(yr<1700)
   {
      yr=1700;
      window[calindex].wxindex=0;
   }
   if(yr>2099)
   {
      yr=2099;
      window[calindex].wxindex=399;
   }

   itoa(yr,yr_str);
   itoa(mn,mn_str);

   strcpy(res_date,yr_str);
   chg_chr(yr_str,'0','O');
   if(mn<10)
      strcat(res_date,"0");
   strcat(res_date,mn_str);
   strcat(res_date,"01");

   mn=month(res_date); yr=year(res_date);

   strcpy(window[calindex].wsdate,left(res_date,6));

   strcpy(title,month_str(res_date));
   strcat(title," ");
   itoa(yr,yr_str);
   chg_chr(yr_str,'0','O');
   strcat(title,yr_str);

   do_name(title);
   wdw = &window[calindex];
   strcpy(window[calindex].wtitle,title);
   wind_set(window[calindex].whandle,WF_NAME,wdw->wtitle,0,0);

   for(i=CALFIRST; i<=CALLAST; i++)
      objc_change(tree,i,0,0,0,0,0,NORMAL,0);

   strcpy(rm_stime,window[cal_idx].wstime);
   strcpy(rm_etime,window[cal_idx].wetime);
   strcpy(rm_subj,window[cal_idx].wsubj);
   for(i=0; i<NUM_XFIELDS; i++)
      strcpy(rm_xfield[i],window[cal_idx].wxfield[i]);
   strcpy(rm_descr,window[cal_idx].wdescr);
   for(i=0; i<9; i++)
      rm_decision[i]=window[cal_idx].wdecision[i];

   flag_cal(res_date);

   first_used=wday(res_date)-1;

   for(i=CALFIRST; i<CALFIRST+first_used; i++)
   {
      tedptr=(char *)tree[i].ob_spec;
      strcpy(*tedptr,"  ");
   }

   dy=0;

   for(i=CALFIRST+first_used; i<=CALLAST; i++)
   {
     dy++;
     if(dy>num_days(mn,yr))
        strcpy(str,"  ");
     else
     {
        itoa(dy,str);
        if(cal_flags[dy-1]==TRUE)
           set_state(tree,i,SELECTED);
        if(year(sys_date)==yr && month(sys_date)==mn && mday(sys_date)==dy)
           set_state(tree,i,DISABLED);
     }
     chg_chr(str,'0','O');
     tedptr=(char *)tree[i].ob_spec;
     strcpy(*tedptr,rjustify(str,2));
   }

   grect_to_array(clip_area,pxy);

   vsf_color(vdi_handle,WHITE);
   vsf_interior(vdi_handle,1);
   vswr_mode(vdi_handle,MD_REPLACE);
   HIDE_MOUSE;
   vr_recfl(vdi_handle,pxy);
   SHOW_MOUSE;

   set_xy(window[calindex].work_area.g_x,window[calindex].work_area.g_y);

   objc_draw(tree,0,8,pxy[0],pxy[1],pxy[2]-pxy[0]+1,pxy[3]-pxy[1]+1);

   wind_update(0);
}

cal_criteria(date,table,n)
char *date;
RECORD *table;
int  n;
{
   register int  cond;
   register RECORD *low = &table[0];
   register RECORD *high = &table[n-1];
   register RECORD *mid;

   while(low<=high)
   {
      mid=low+(high-low)/2;
      if((cond=strcmp(date,mid->rdate))<0)
         high=mid-1;
      else if(cond>0)
         low=mid+1;
      else
      {
         while(strcmp(date,mid->rdate)==0)
            mid--;

         mid++;

         while(strcmp(date,mid->rdate)==0)
         {
            if(rec_match(mid))
               return(TRUE);
            mid++;
         }
         return(FALSE);
      }
   }
   return(FALSE);
}

flag_cal(date)
char *date;
{
   char res_date[9];
   int i;

   strcpy(res_date,date);

   for(i=0; i<31; i++)
   {
      if(cal_criteria(res_date,rec,rec_no))
         cal_flags[i]=TRUE;
      else
         cal_flags[i]=FALSE;

      strcpy(res_date,fd_forward(res_date,1));
   }
}

int 
hndl_button(mx,my)
int  mx,my;
{
   int  whand,windex;

   whand=wind_find(mx,my);

   windex=set_windex(whand);

   if(whand==0)
   {
      if(sel_windex!=(-1))
         sel_clear(&window[sel_windex].work_area,TRUE);
      return(FALSE);
   }

   if(window[windex].wcontents==(-1) ||
      window[windex].wopen!=TRUE)
      return(FALSE);

   if(window[windex].wcontents==WC_CALENDAR)
   {
      wind_get(0,WF_TOP,&whand,&dummy,&dummy,&dummy);
      windex=set_windex(whand);
      if(cal_idx!=windex)
      {
         cal_idx=windex;
         draw_cal(cal_idx,&window[windex].work_area);
      }
      cal_button(cal_idx);
   }
   else if(window[windex].wcontents>=WC_REPORT)
      rpt_button(windex);
}

cal_button(windex)
int  windex;
{
   OBJECT *tree;
   char **tedptr,day_str[3];
   int  obj,day;

   rsrc_gaddr(0,TCALEND,&tree);
   obj=objc_find(tree,0,8,mx,my);
   if(obj>0)
   {
      tedptr=(char *)tree[obj].ob_spec;
      strcpy(day_str,*tedptr);
      chg_chr(day_str,'O','0');
      day=atoi(day_str);
      if(day<10)
      {
         day=atoi(right(*tedptr,1));
         day_str[0]='0';
      }

      if(day>0)
         do_info(windex,day_str);
   }
}

rec_match(rec_ptr)
RECORD *rec_ptr;
{
   int i,found[9];
   char up_descr[41];

   for(i=0; i<9; i++)
      found[i]=FALSE;

   if(strlen(rm_stime)==0)
      found[0]=TRUE;
   else
   {
      if(data_entry.dstime)
         if(match(rm_decision[0],rec_ptr->rstime,rm_stime))
            found[0]=TRUE;
   }

   if(strlen(rm_etime)==0)
      found[1]=TRUE;
   else
   {
      if(data_entry.detime)
         if(match(rm_decision[1],rec_ptr->retime,rm_etime))
            found[1]=TRUE;
   }

   if(strlen(rm_subj)==0)
      found[2]=TRUE;
   else
   {
      if(data_entry.dsubj)
         if(match(rm_decision[2],rec_ptr->rsubj,rm_subj))
            found[2]=TRUE;
   }

   for(i=0; i<NUM_XFIELDS; i++)
   {
      if(strlen(rm_xfield[i])==0)
         found[3+i]=TRUE;
      else
      {
         if(data_entry.dxfields>i)
            if(match(rm_decision[3+i],rec_ptr->rxfield[i],rm_xfield[i]))
               found[3+i]=TRUE;
      }
   }

   for(i=0; i<4; i++)
   {
      if(strlen(rm_descr)==0)
         found[8]=TRUE;
      else
      {
         if(data_entry.ddescr_lines>i)
         {
            strcpy(up_descr,rec_ptr->rdescr[i]);
            upper(up_descr);

            if(match(rm_decision[8],up_descr,rm_descr))
               found[8]=TRUE;
         }
      }

      if(rm_decision[8]!=IN)
         break;
   }
   if(found[0] && found[1] && found[2] && found[3] && found[4] &&
      found[5] && found[6] && found[7] && found[8])
      return(TRUE);
   else
      return(FALSE);
}

