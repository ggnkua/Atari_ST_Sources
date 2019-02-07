/* S18.C -- DATE/TIME RELATED FUNCTIONS */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int ed_idx,ed_obj;

extern char sys_date[9],sys_time[6],release_date[9],alert0[],alert1[];

extern LAST_USED last;

extern CUSTOM data_entry;

manip_date(tree,tdef,which,amount)
OBJECT *tree;
int tdef,which,amount;
{
   static char **tedptr,res_date[9],dy_str[3],mn_str[3],yr_str[5],temp[9];
   int date_obj,sys_flag,dy,mn,yr,edate,oldcent,oldyear,olddy,amt;

   objc_edit(tree,ed_obj,0,&ed_idx,EDEND);

   date_obj=edate=sys_flag=FALSE;

   switch(tdef)
   {
      case TEDITREC: date_obj=ERDATE;
                     break;
      case TPRTREPT: if(ed_obj==PREDATE)
                     {
                        date_obj=ed_obj;
                        edate=TRUE;
                     }
                     else
                        date_obj=PRSDATE;
                     break;
      case TCALCBD:  if(ed_obj==BDEDATE)
                     {
                        date_obj=ed_obj;
                        edate=TRUE;
                     }
                     else
                        date_obj=BDSDATE;
                     break;
      case TCALCFD:  date_obj=FDDATE;
                     break;
      case TGODATE:  date_obj=GDDATE;
                     break;
      case TSYSDATE: date_obj=SDDATE;
                     sys_flag=TRUE;
                     break;
   }

   if(date_obj)
   {
      if(sys_flag==TRUE)
      {
         oldcent=data_entry.dcentury;
         oldyear=data_entry.dyear;

         data_entry.dcentury=FALSE;
         data_entry.dyear=TRUE;
      }

      tedptr=(char *)tree[date_obj].ob_spec;

      if(!validate_date(*tedptr,tdef))
      {
         if(!sys_flag)
            strcpy(temp,edate? last.ledate : last.lsdate);

         if(data_entry.dcentury==TRUE && !sys_flag)
            strcpy(*tedptr,temp);
         else
         {
            if(data_entry.dyear==TRUE && !sys_flag)
            {
               strcpy(*tedptr,left(temp,4));
               strcat(*tedptr,right(temp,2));
            }
            else
               strcpy(*tedptr,left(temp,4));
         }
      }
      if(!validate_date(*tedptr,tdef))
      {
         strcpy(*tedptr,"\0");
         if(sys_flag)
         {
            data_entry.dcentury=oldcent;
            data_entry.dyear=oldyear;
         }
         objc_draw(tree,date_obj,0,0,0,0,0);
         objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
         return(-1);
      }
      dy=atoi(mid(*tedptr,3,2));
      mn=atoi(left(*tedptr,2));
      if(data_entry.dcentury==TRUE)
         yr=atoi(right(*tedptr,4));
      else
      {
         if(data_entry.dyear==TRUE)
            yr=atoi(right(*tedptr,2));
         else
            yr=0;
      }

      olddy=dy;

      if(amount==DAY)
         amt=1;
      else
         amt=7;

      if(which==PLUS)
         dy+=amt;
      else
         dy-=amt;

      if(dy<=0)
      {
         mn--;
         if(mn<=0)
         {
            mn=12;
            yr--;
         }
         dy=num_days(mn,yr)-(amt-olddy);
      }
      if(dy>num_days(mn,yr))
      {
         dy-=num_days(mn,yr);
         mn++;
         if(mn>12)
         {
            mn=1;
            yr++;
         }
      }
      if(yr<0)
         yr=0;
      if(data_entry.dcentury==TRUE && yr>9999)
         yr=9999;
      if(data_entry.dcentury==FALSE && yr>99)
         yr=99;

      itoa(mn,mn_str);
      strcpy(mn_str,rjustify(mn_str,2));
      chg_chr(mn_str,' ','0');

      itoa(dy,dy_str);
      strcpy(dy_str,rjustify(dy_str,2));
      chg_chr(dy_str,' ','0');

      if(data_entry.dcentury==TRUE)
      {
         itoa(yr,yr_str);
         strcpy(yr_str,rjustify(yr_str,4));
         chg_chr(yr_str,' ','0');
      }
      if(data_entry.dcentury==FALSE && data_entry.dyear==TRUE)
      {
         itoa(yr,yr_str);
         strcpy(yr_str,rjustify(yr_str,2));
         chg_chr(yr_str,' ','0');
      }
      strcpy(res_date,mn_str);
      strcat(res_date,dy_str);
      strcat(res_date,yr_str);
      if(data_entry.dyear==TRUE)
         strcpy(*tedptr,res_date);
      else
         strcpy(*tedptr,left(res_date,4));
      objc_draw(tree,date_obj,0,0,0,0,0);

      do_msgs(tree,tdef,date_obj,TRUE,FALSE);
   }
   objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);

   if(sys_flag)
   {
      data_entry.dcentury=oldcent;
      data_entry.dyear=oldyear;
   }
}

manip_time(tree,tdef,which)
OBJECT *tree;
int tdef,which;
{
   static char **tedptr,res_time[6],hr_str[3],min_str[3],pm_str[2],temp[6];
   int time_obj,etime,min,hr;

   objc_edit(tree,ed_obj,0,&ed_idx,EDEND);

   time_obj=etime=FALSE;

   switch(tdef)
   {
      case TEDITREC: if(ed_obj==ERETIME)
                     {
                        time_obj=ed_obj;
                        etime=TRUE;
                     }
                     else
                        time_obj=ERSTIME;
                     break;
      case TPRTREPT: if(ed_obj==PRETIME)
                     {
                        time_obj=ed_obj;
                        etime=TRUE;
                     }
                     else
                        time_obj=PRSTIME;
                     break;
      case TCALCBD:  if(ed_obj==BDETIME)
                     {
                        time_obj=ed_obj;
                        etime=TRUE;
                     }
                     else
                        time_obj=BDSTIME;
                     break;
      case TSYSDATE: time_obj=SDTIME;
                     break;
   }

   if(time_obj)
   {
      tedptr=(char *)tree[time_obj].ob_spec;

      if(!time_valid(*tedptr) || strlen(*tedptr)==0)
      {
         strcpy(temp,etime? last.letime : last.lstime);
         strcpy(*tedptr,temp);
      }
      if(!time_valid(*tedptr) || strlen(*tedptr)==0)
      {
         strcpy(*tedptr,"\0");
         objc_draw(tree,time_obj,0,0,0,0,0);
         objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
         return;
      }
      hr=atoi(left(*tedptr,2));
      min=atoi(mid(*tedptr,3,2));

      strcpy(pm_str,right(*tedptr,1));

      if(which==PLUS)
         hr++;
      else
         hr--;

      if(hr<1)
         hr=12;
      if(hr>12)
         hr=1;

      if(hr==12 && which==PLUS)
      {
         if(strcmp(right(*tedptr,1),"a")==0)
            strcpy(pm_str,"p");
         else
            strcpy(pm_str,"a");
      }

      if(hr==11 && which==MINUS)
      {
         if(strcmp(right(*tedptr,1),"p")==0)
            strcpy(pm_str,"a");
         else
            strcpy(pm_str,"p");
      }

      itoa(hr,hr_str);
      strcpy(hr_str,rjustify(hr_str,2));
      chg_chr(hr_str,' ','0');

      itoa(min,min_str);
      strcpy(min_str,rjustify(min_str,2));
      chg_chr(min_str,' ','0');

      strcpy(res_time,hr_str);
      strcat(res_time,min_str);
      strcat(res_time,pm_str);

      strcpy(*tedptr,res_time);

      objc_draw(tree,time_obj,0,0,0,0,0);
   }
   objc_edit(tree,ed_obj,0,&ed_idx,EDINIT);
}

validate_date(date,tdef)
char *date;
int tdef;
{
   char mn_str[3],dy_str[3],yr_str[5];
   int mn,dy,yr;

   strcpy(mn_str,left(date,2));
   strcpy(dy_str,mid(date,3,2));
   if(tdef!=TSYSDATE)
   {
      if(data_entry.dcentury)
      {
         if(strlen(date)==8)
            strcpy(yr_str,right(date,4));
         else
            return(FALSE);
      }
      if(!data_entry.dcentury && data_entry.dyear)
      {
         if(strlen(date)==6)
         {
            strcpy(yr_str,left(sys_date,2));
            strcat(yr_str,right(date,2));
         }
         else
            return(FALSE);
      }
      if(!data_entry.dcentury && !data_entry.dyear)
      {
         if(strlen(date)==4)
            strcpy(yr_str,left(sys_date,4));
         else
            return(FALSE);
      }
   }
   else /* enter date dialog */
   {
      if(strlen(date)==6)
         strcpy(yr_str,right(date,4));
      else
         return(FALSE);
   }

   mn=atoi(mn_str);
   dy=atoi(dy_str);
   yr=atoi(yr_str);

   if(mn<1 || mn>12)
      return(FALSE);

   if(dy<1 || dy>num_days(mn,yr))
      return(FALSE);

   return(TRUE);
}

use_sys_date(tree,tdef,obj)
OBJECT *tree;
int tdef,obj;
{
   char **tedptr;

   if(!ob_date(tree,obj))
      return;

   tedptr=(char *)tree[obj].ob_spec;
   strcpy(*tedptr,right(sys_date,4));

   if(tdef==TSYSDATE)
      strcat(*tedptr,mid(sys_date,3,2));
   else
   {
      if(data_entry.dcentury==TRUE)
         strcat(*tedptr,left(sys_date,4));
      else
      {
         if(data_entry.dyear==TRUE)
            strcat(*tedptr,mid(sys_date,3,2));
      }
   }
   objc_draw(tree,obj,0,0,0,0,0);

   do_msgs(tree,tdef,obj,TRUE,TRUE);
}

get_sys_date(check_date)
int check_date;
{
   char temp[5];
   int yr,mn,dy,min,hr;
         
   strcpy(sys_date,left(release_date,2));
   yr=80+(Tgetdate()/512);
   itoa(yr,temp);
   strcat(sys_date,temp);
   mn=(Tgetdate()/32) & 0x0f;
   itoa(mn,temp);
   if(mn<10)
      strcat(sys_date,"0");
   strcat(sys_date,temp);
   dy=Tgetdate() & 0x1f;
   itoa(dy,temp);
   if(dy<10)
      strcat(sys_date,"0");
   strcat(sys_date,temp);

   hr=(Tgettime() >> 11) & 0x1f;
   min=(Tgettime() >> 5) & 0x3f;

   if(hr>=12)
   {
      strcpy(sys_time,"p");
      hr-=12;
   }
   else
      strcpy(sys_time,"a");

   itoa(hr,temp);
   strcpy(temp,rjustify(temp,2));
   chg_chr(temp,' ','0');
   strcat(sys_time,temp);

   itoa(min,temp);
   strcpy(temp,rjustify(temp,2));
   chg_chr(temp,' ','0');
   strcat(sys_time,temp);

   if(strcmp(sys_date,release_date)<0 && check_date)
      date_enter();
}

cat_date(string,date)
char *string,*date;
{
   strcat(string,wday_str(date));
   if(wday(date)>0)
      strcat(string,", ");
   strcat(string,month_str(date));
   strcat(string," ");
   if(strcmp(mid(date,7,1),"0")!=0)
      strcat(string,right(date,2));
   else
      strcat(string,right(date,1));
   num_suffix(string);
   strcat(string,", ");
   strcat(string,left(date,4));
}

time_valid(tedptr)
char *tedptr;
{
   int hr,minute;

   if(strlen(tedptr)==0)
      return(TRUE);

   if(strlen(tedptr)!=5)
      return(FALSE);

   if(strcmp(right(tedptr,1),"a")!=0 &&
      strcmp(right(tedptr,1),"p")!=0)
      return(FALSE);

   hr=atoi(left(tedptr,2));

   if(hr==0 || hr>12)
      return(FALSE);

   minute=atoi(mid(tedptr,3,2));

   if(minute>59)
      return(FALSE);

   return(TRUE);
}

date_error_alert(tedptr)
char tedptr[9];
{
   char date[9];
   int mn,dy,yr;

   if(data_entry.dcentury==TRUE)
   {
      strcpy(date,right(tedptr,4));
      strcat(date,left(tedptr,4));
   }
   else
   {
      if(data_entry.dyear==TRUE)
      {
         strcpy(date,left(sys_date,2));
         strcat(date,right(tedptr,2));
         strcat(date,left(tedptr,4));
      }
      else
      {
         strcpy(date,left(sys_date,4));
         strcat(date,left(tedptr,4));
      }
   }

   mn=month(date); dy=mday(date); yr=year(date);

   if(strlen(tedptr)==0)
   {
      form_alert(1,alert0);
      return(0);
   }
   if(data_entry.dcentury==TRUE && strlen(tedptr)<8)
   {
      form_alert(1,alert1);
      return(0);
   }
   if(data_entry.dcentury==FALSE && data_entry.dyear==TRUE && strlen(tedptr)<6)
   {
      form_alert(1,alert1);
      return(0);
   }
   if(data_entry.dcentury==FALSE && data_entry.dyear==FALSE && strlen(tedptr)<4)
   {
      form_alert(1,alert1);
      return(0);
   }
   if(mn<1 || mn>12 || dy==0 || dy>num_days(mn,yr))
   {
      form_alert(1,alert1);
      return(0);
   }
}

do_msgs(tree,tdef,obj,draw_flag,sys_flag)
OBJECT *tree;
int tdef,obj,draw_flag,sys_flag;
{
   char **ptr_date,**ptr_msg,msg[40],date[9],chr_dummy[41];
   int draw,msg_obj,tmp_len;

   draw=FALSE; msg_obj=0;

   switch(tdef)
   {
      case TEDITREC: msg_obj=ERMSG;
                     break;
      case TPRTREPT: if(obj==PRSDATE)
                        msg_obj=PRSDMSG;
                     else
                        msg_obj=PREDMSG;
                     break;
      case TCALCBD:  if(obj==BDSDATE)
                        msg_obj=BDSDMSG;
                     else
                        msg_obj=BDEDMSG;
                     break;
      case TCALCFD:  msg_obj=FDMSG;
                     break;
      case TSYSDATE: msg_obj=SDMSG;
                     break;
      case TGODATE:  msg_obj=GDMSG;
                     break;
   }

   ptr_date=(char *)tree[obj].ob_spec;
   ptr_msg=(char *)tree[msg_obj].ob_spec;

   tmp_len=((TEDINFO *)tree[obj].ob_spec)->te_tmplen;
   if(data_entry.dyear==FALSE)
      tmp_len++;

   if(tdef==TPRTREPT && strlen(*ptr_date)==0)
   {
      if(msg_obj==PRSDMSG)
         strcpy(*ptr_msg,"(from beginning)");
      else
         strcpy(*ptr_msg,"(to end)");
      draw=TRUE;
   }
   else if(tdef==TPRTREPT && sys_flag==TRUE)
   {
      strcpy(*ptr_msg,"(use system date)");
      draw=TRUE;
   }       
   else
   {
      if(!validate_date(*ptr_date,tdef) && strcmp(*ptr_msg,"\0")!=0)
      {
         strcpy(*ptr_msg,"");
         draw=TRUE;
      }
      else if(validate_date(*ptr_date,tdef))
      {
         get_date(*ptr_date,date,chr_dummy);

         strcpy(msg,"(");
         cat_date(msg,date);
         strcpy(msg,left(msg,strlen(msg)-6));
         strcat(msg,")");
         if(strcmp(msg,*ptr_msg)!=0)
         {
            draw=TRUE;
            strcpy(*ptr_msg,msg);
         }
         else
            draw=FALSE;
      }
   }

   if(tdef!=TGODATE)
      strcat(*ptr_msg,replicate(' ',27-strlen(*ptr_msg)));

   if(draw_flag && draw)
      objc_draw(tree,msg_obj,0,0,0,0,0);
}

clr_msgs(tree,tdef)
OBJECT *tree;
int tdef;
{
   char **tedptr;
   int i,obj[2];

   obj[0]=obj[1]=0;

   switch(tdef)
   {
      case TEDITREC: obj[0]=ERMSG;
                     break;
      case TPRTREPT: obj[0]=PRSDMSG;
                     obj[1]=PREDMSG;
                     break;
      case TCALCBD:  obj[0]=BDSDMSG;
                     obj[1]=BDEDMSG;
                     break;
      case TCALCFD:  obj[0]=FDMSG;
                     break;
      case TSYSDATE: obj[0]=SDMSG;
                     break;
      case TGODATE:  obj[0]=GDMSG;
                     break;
   }

   for(i=0; i<2; i++)
   {
      if(obj[i])
      {
         tedptr=(char *)tree[obj[i]].ob_spec;
         if(tdef==TPRTREPT)
         {
            if(obj[i]==PRSDMSG)
               strcpy(*tedptr,"(from beginning)");
            else
               strcpy(*tedptr,"(to end)");
         }
         else
            strcpy(*tedptr,"");
      }
      if(tdef!=TGODATE)
         strcat(*tedptr,replicate(' ',27-strlen(*tedptr)));
   }
}

do_century(flag)
int flag;
{
   OBJECT *tree;

   rsrc_gaddr(0,TEDITREC,&tree);
   mod_date(tree,flag,ERDATE);

   rsrc_gaddr(0,TPRTREPT,&tree);
   mod_date(tree,flag,PRSDATE);
   mod_date(tree,flag,PREDATE);

   rsrc_gaddr(0,TCALCBD,&tree);
   mod_date(tree,flag,BDSDATE);
   mod_date(tree,flag,BDEDATE);

   rsrc_gaddr(0,TCALCFD,&tree);
   mod_date(tree,flag,FDDATE);

   rsrc_gaddr(0,TGODATE,&tree);
   mod_date(tree,flag,GDDATE);
}

mod_date(tree,flag,obj)
OBJECT *tree;
int flag,obj;
{
   char *ptr;

   if(flag==FALSE)
   {
      if(data_entry.dyear==TRUE)
      {
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
         strcpy(ptr,"__/__/__");
         ((TEDINFO *)tree[obj].ob_spec)->te_tmplen=9;
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_pvalid;
         strcpy(ptr,"999999");
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
         strcpy(ptr,"__/__/__");
         ((TEDINFO *)tree[obj].ob_spec)->te_txtlen=7;
         tree[obj].ob_width=72;
      }

      if(data_entry.dyear==FALSE)
      {
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
         strcpy(ptr,"__/__");
         ((TEDINFO *)tree[obj].ob_spec)->te_tmplen=6;
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_pvalid;
         strcpy(ptr,"9999");
         ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
         strcpy(ptr,"__/__");
         ((TEDINFO *)tree[obj].ob_spec)->te_txtlen=5;
         tree[obj].ob_width=48;
      }
   }

   if(flag==TRUE)
   {
      ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
      strcpy(ptr,"__/__/____");
      ((TEDINFO *)tree[obj].ob_spec)->te_tmplen=11;
      ptr=((TEDINFO *)tree[obj].ob_spec)->te_pvalid;
      strcpy(ptr,"99999999");
      ptr=((TEDINFO *)tree[obj].ob_spec)->te_ptmplt;
      strcpy(ptr,"__/__/____");
      ((TEDINFO *)tree[obj].ob_spec)->te_txtlen=9;
      tree[obj].ob_width=88;
   }
}

get_date(tedptr,date,last)
char *tedptr,*date,*last;
{
   if(data_entry.dcentury==TRUE)
   {
      strcpy(date,right(tedptr,4));
      strcat(date,left(tedptr,4));
      strcpy(last,tedptr);
   }
   else
   {
      if(data_entry.dyear==TRUE)
      {
         strcpy(date,left(sys_date,2));
         strcat(date,right(tedptr,2));
         strcat(date,left(tedptr,4));
         strcpy(last,left(tedptr,4));
         strcat(last,left(sys_date,2));
         strcat(last,right(tedptr,2));
      }
      else
      {
         strcpy(date,left(sys_date,4));
         strcat(date,left(tedptr,4));
         strcpy(last,left(tedptr,4));
         strcat(last,left(sys_date,4));
      }
   }
}

get_time(tedptr,time,last)
char *tedptr,*time,*last;
{
   strcpy(time,right(tedptr,1));
   if(strcmp(left(tedptr,2),"12")==0)
   {
      strcat(time,"00");
      strcat(time,mid(tedptr,3,2));
   }
   else
      strcat(time,left(tedptr,4));

   if(strlen(tedptr)>0)
      strcpy(last,tedptr);
}

cat_short_date(str,date)
char *str,date[9];
{
   if(strcmp(mid(date,5,1),"0")==0)
      strcat(str,mid(date,6,1));
   else
      strcat(str,mid(date,5,2));
   strcat(str,"/");
   if(strcmp(mid(date,7,1),"0")==0)
      strcat(str,right(date,1));
   else
      strcat(str,right(date,2));
   strcat(str,"/");
   strcat(str,mid(date,3,2));
}
         
