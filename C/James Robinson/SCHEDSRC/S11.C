/* S11.C -- DATE CALCULATION, OTHER DIALOGS */

#include "stdio.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "ctools.h"
#include "schedule.h"

extern int  dummy;

extern char sys_date[9],sys_time[6],sdatealrt[],release_date[9],timealrt[],
            notimealrt[],alert1[];

extern LAST_USED last;

extern WIND window[NUM_WINDS];

calc_between_dates()
{
   OBJECT *tree;
   char   sdate[9],edate[9],stime[6],etime[6],**tedptr,num_temp[10];
   int    exit_obj,valid,err_obj,hours,mins;
   long   days;

   hide_windows();

   for(;;)
   {
      rsrc_gaddr(0,TCALCBD,&tree);
      clear_form(tree);
      clr_msgs(tree,TCALCBD);

      valid=FALSE; err_obj=0;

      while(!valid)
      {
         exit_obj=do_dialog(tree,TCALCBD,err_obj,0,1);

         if(exit_obj!=BDCANCEL)
         {
            valid=TRUE;

            tedptr=(char *)tree[BDSDATE].ob_spec;
            if(!validate_date(*tedptr,TCALCBD))
            {
               valid=FALSE;
               date_error_alert(*tedptr);
               err_obj=BDSDATE;
               continue;
            }
            else
               get_date(*tedptr,sdate,last.lsdate);

            tedptr=(char *)tree[BDSTIME].ob_spec;
            if(!time_valid(*tedptr))
            {
               valid=FALSE;
               form_alert(1,timealrt);
               err_obj=BDSTIME;
               continue;
            }
            else
               get_time(*tedptr,stime,last.lstime);

            tedptr=(char *)tree[BDEDATE].ob_spec;
            if(!validate_date(*tedptr,TCALCBD))
            {
               valid=FALSE;
               date_error_alert(*tedptr);
               err_obj=BDEDATE;
               continue;
            }
            else
               get_date(*tedptr,edate,last.ledate);

            tedptr=(char *)tree[BDETIME].ob_spec;
            if(!time_valid(*tedptr))
            {
               valid=FALSE;
               form_alert(1,timealrt);
               err_obj=BDETIME;
               continue;
            }
            else
               get_time(*tedptr,etime,last.letime);

            if(strcmp(sdate,edate)>0 || (strcmp(sdate,edate)==0 &&
                                         strcmp(stime,etime)>0))
            {
               valid=FALSE;
               form_alert(1,sdatealrt);
               err_obj=BDSDATE;
               continue;
            }

            rsrc_gaddr(0,TBDRESLT,&tree);

            tedptr=(char *)tree[BDRESULT].ob_spec;

            days=calc_bd(sdate,edate);
            if(strlen(stime)>0 && strlen(etime)>0)
            {
               hours=hours_between(stime,etime);
               mins=mins_between(stime,etime);
               if(hours<0)
               {
                  hours+=24;
                  days--;
               }
               if(mins<0)
               {
                  mins+=60;
                  hours--;
               }
               if(hours<0)
               {
                  hours=23;
                  days--;
               }
            }
            else
            {
               hours=mins=0;
            }
            ltoa(days,*tedptr);
            strcat(*tedptr," days");
            if(strlen(stime)>0 && strlen(etime)>0)
            {
               itoa(hours,num_temp);
               strcat(*tedptr,", ");
               strcat(*tedptr,num_temp);
               if(hours==1)
                  strcat(*tedptr," hour");
               else
                  strcat(*tedptr," hours");
               itoa(mins,num_temp);
               strcat(*tedptr,", ");
               strcat(*tedptr,num_temp);
               if(mins==1)
                  strcat(*tedptr," minute");
               else
                  strcat(*tedptr," minutes");
            }

            do_dialog(tree,TCALCBD,0,1,1);
         }
         else
         {
            show_windows();
            return(0);
         }
         if(!enter_more())
         {
            show_windows();
            return(0);
         }
      }
   }
}

calc_from_date()
{
   OBJECT *tree;
   auto char date[9],*botmsg_ptr,*days_ptr,days_hold[10],
              *res_ptr,**tedptr,*strptr,**textptr,res_date[9];
   int  days,dir,exit_obj,valid;

   hide_windows();

   for(;;)
   {
      rsrc_gaddr(0,TCALCFD,&tree);
      clear_form(tree);

      valid=FALSE;

      while(!valid)
      {
         clr_msgs(tree,TCALCFD);
         exit_obj=do_dialog(tree,TCALCFD,0,0,1);

         if(exit_obj!=FDCANCEL)
         {
            valid=TRUE;

            tedptr=(char *)tree[FDDATE].ob_spec;
            if(!validate_date(*tedptr,TCALCFD))
            {
               valid=FALSE;
               date_error_alert(*tedptr);
               continue;
            }

            get_date(*tedptr,date,last.lsdate);

            tedptr=(char *)tree[FDDAYS].ob_spec;
            days_ptr= *tedptr;
            days=atoi(days_ptr);
            strcpy(days_hold,days_ptr);
            if(days==1)
               strcat(days_hold," day");
            else
               strcat(days_hold," days");
            strcpy(last.ldays,*tedptr);

            if(ob_selected(tree,FDFRWD))
            {
               strcpy(res_date,fd_forward(date,days));
               dir=1;
            }
            else
            {
               strcpy(res_date,fd_backward(date,days));
               dir=2;
            }

            if(strcmp(month_str(res_date),"Invalid")==0)
               continue;

            rsrc_gaddr(0,TFDRESLT,&tree);

            strptr=(char *)tree[FDNODAYS].ob_spec;
            days_ptr=strptr;

            strptr=(char *)tree[FDBOTMSG].ob_spec;
            botmsg_ptr=strptr;

            textptr=(char *)tree[FDRESULT].ob_spec;
            res_ptr= *textptr;

            strcpy(days_ptr,days_hold);

            if(dir==1)
               strcpy(botmsg_ptr,"after ");
            else
               strcpy(botmsg_ptr,"before ");
            strcat(botmsg_ptr,"the date of ");
            strcat(botmsg_ptr,mid(date,5,2));
            strcat(botmsg_ptr,"/");
            strcat(botmsg_ptr,right(date,2));
            strcat(botmsg_ptr,"/");
            strcat(botmsg_ptr,left(date,4));
            strcat(botmsg_ptr," is:");

            strcpy(res_ptr,"\0");
            cat_date(res_ptr,res_date);

            do_dialog(tree,TCALCFD,0,1,1);
         }
         else
         {
            show_windows();
            return(0);
         }
         if(!enter_more())
         {
            show_windows();
            return(0);
         }
      }
   }
}

do_about()
{
   long tree;

   hide_windows();

   rsrc_gaddr(0,TABOUT,&tree);
   do_dialog(tree,TABOUT,0,1,0);

   show_windows();
}

enter_more()
{
   long tree;
   int exit_obj;

   rsrc_gaddr(0,TENTMORE,&tree);
   exit_obj=do_dialog(tree,TENTMORE,0,1,0);
 
   if(exit_obj==EMOREYES)
      return(TRUE);
   else
      return(FALSE);
}

do_help()
{
   long tree,wtree;
   int  exit_obj;

   hide_windows();

   rsrc_gaddr(0,THELP,&tree);
   rsrc_gaddr(0,TWDWKEYS,&wtree);

   for(;;)
   {
      exit_obj=do_dialog(tree,THELP,0,1,0);

      if(exit_obj==HVWDWKEY)
         do_dialog(wtree,TWDWKEYS,0,1,0);       
      else
         break;
   }
   show_windows();
}

date_enter()
{
   OBJECT *tree;
   char **tedptr;
   int  exit_obj,i,yr,mn,dy,valid,err_obj,second;
   unsigned int  hour,minute,time;
   register unsigned long ikbd_time;

   hide_windows();

   rsrc_gaddr(0,TSYSDATE,&tree);
   clear_form(tree);
   clr_msgs(tree,TSYSDATE);

   valid=FALSE; err_obj=0;

   while(!valid)
   {
      exit_obj=do_dialog(tree,TSYSDATE,err_obj,0,1);

      if(exit_obj==SDCANCEL)
      {
         show_windows();
         return;
      }

      valid=TRUE;

      tedptr=(char *)tree[SDDATE].ob_spec;
      if(validate_date(*tedptr,TSYSDATE))
      {
         yr=atoi(right(*tedptr,2))-FIRST_SYS_YEAR;
         mn=atoi(left(*tedptr,2));
         dy=atoi(mid(*tedptr,3,2));

         if(yr<0)
         {
            valid=FALSE;
            err_obj=SDDATE;
            form_alert(1,alert1);
            continue;
         }

         strcpy(sys_date,left(release_date,2));
         strcat(sys_date,right(*tedptr,2));
         strcat(sys_date,left(*tedptr,2));
         strcat(sys_date,mid(*tedptr,3,2));

         strcpy(last.lsdate,*tedptr);
      }
      else
      {
         valid=FALSE;
         err_obj=SDDATE;
         date_error_alert(*tedptr);
         continue;
      }

      tedptr=(char *)tree[SDTIME].ob_spec;
      if(strlen(*tedptr)==0)
      {
         valid=FALSE;
         err_obj=SDTIME;
         form_alert(1,notimealrt);
         continue;
      }
      else if(time_valid(*tedptr))
      {
         hour=atoi(left(*tedptr,2));
         if(strcmp(left(*tedptr,2),"12")==0)
         {
            if(strcmp(right(*tedptr,1),"a")==0)
               hour=0;
            else
               hour=12;
         }
         else
            if(strcmp(right(*tedptr,1),"p")==0)
               hour+=12;

         minute=atoi(mid(*tedptr,3,2));

         time=(hour*2048)+(minute*32);

         Tsettime(time); /* set GEM-DOS time */

         strcpy(sys_time,right(*tedptr,1));
         if(strcmp(left(*tedptr,2),"12")==0)
         {
            strcat(sys_time,"00");
            strcat(sys_time,mid(*tedptr,3,2));
         }
         else
            strcat(sys_time,left(*tedptr,4));

         strcpy(last.lstime,*tedptr);
      }
      else
      {
         valid=FALSE;
         err_obj=SDTIME;
         form_alert(1,timealrt);
         continue;
      }
   }

   Tsetdate((yr*512)+(mn*32)+dy); /* set GEM-DOS date */

   second=0;

   ikbd_time=((unsigned long)yr<<25)    |
             ((unsigned long)mn<<21)    |
             ((unsigned long)dy<<16)    |
             ((unsigned long)hour<<11)  |
             ((unsigned long)minute<<5) |
             ((unsigned long)second>>1);

   Settime(ikbd_time); /* set IKBD time (xbios) */

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wcontents>=WC_REPORT)
      {
         if(window[i].wsys_sdate==TRUE)
            strcpy(window[i].wsdate,sys_date);
         if(window[i].wsys_edate==TRUE)
            strcpy(window[i].wedate,sys_date);
      }
   }

   time_display();

   sys_count();

   show_windows();
}

