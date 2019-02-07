/* S19.C -- AUTO TICKLERS */

#include "obdefs.h"
#include "stdio.h"
#include "ctools.h"
#include "schdefs.h"
#include "schedule.h"

extern int rec_no,atkey_tab[10],atdays_tab[10],atfrwd_tab[10],xfed_tab[2][5],
           max_recs,tik_modified;

extern char tik_file[129];

extern TICKLERS auto_ticklers[NUM_AUTO_TICKLERS];

extern RECORD *rec;

extern CUSTOM data_entry;

do_auto_ticklers()
{
   OBJECT *tree;
   int exit_obj;

   hide_windows();

   rsrc_gaddr(0,TAUTTICK,&tree);

   save_form(tree);

   for(;;)
   {
      exit_obj=do_dialog(tree,TAUTTICK,0,1,0);

      if(exit_obj==ATLOAD)
      {
         load_auto_ticklers(TRUE);
         put_ticklers();
      }
      else if(exit_obj==ATSAVE)
      {
         get_ticklers();
         save_auto_ticklers(TRUE);
      }
      else
         break;
   }

   if(exit_obj==ATCANCEL)
   {
      cancel_form(tree);
      get_ticklers();
   }
   else
   {
      get_ticklers();
      tik_modified=TRUE;
   }

   show_windows();
}

get_ticklers()
{
   OBJECT *tree;
   int i,j,val,found;
   char **tedptr;

   found=FALSE;

   rsrc_gaddr(0,TAUTTICK,&tree);

   for(i=0; i<10; i++)
   {
      tedptr=(char *)tree[atkey_tab[i]].ob_spec;
      strcpy(auto_ticklers[i].akeyword,*tedptr);
      if(strlen(auto_ticklers[i].akeyword)>0)
         found=TRUE;
      if(ob_selected(tree,atfrwd_tab[i]))
         auto_ticklers[i].adir=FORWARD;
      else
         auto_ticklers[i].adir=BACKWARD;
      for(j=0; j<5; j++)
      {
         tedptr=(char *)tree[atdays_tab[i]+j].ob_spec;
         val=atoi(*tedptr);
         auto_ticklers[i].adays[j]=val;
         if(val>0)
            found=TRUE;
      }
   }

   if(!found)
      strcpy(tik_file,"\0"); /* if no ticklers, remove old pref name */
}

put_ticklers()
{
   OBJECT *tree;
   int i,j;
   char **tedptr;

   rsrc_gaddr(0,TAUTTICK,&tree);

   for(i=0; i<10; i++)
   {
      tedptr=(char *)tree[atkey_tab[i]].ob_spec;
      strcpy(*tedptr,auto_ticklers[i].akeyword);
      if(auto_ticklers[i].adir==FORWARD)
         reset_rbuttons(tree,atfrwd_tab[i],FALSE);
      else
         reset_rbuttons(tree,atfrwd_tab[i]-1,FALSE);
      for(j=0; j<5; j++)
      {
         tedptr=(char *)tree[atdays_tab[i]+j].ob_spec;
         if(auto_ticklers[i].adays[j]>0)
            itoa(auto_ticklers[i].adays[j],*tedptr);
         else
            strcpy(*tedptr,"\0");
      }
   }
}

auto_perform()
{
   OBJECT *tree;
   char **tedptr,temp[200],temp2[200],temp3[200],up_descr[200];
   int i,j,l,m,match,exit_obj,err_obj,ret,old_rec;

   cust_forms(TRUE);

   rsrc_gaddr(0,TEDITREC,&tree);

   tedptr=(char *)tree[ERTITLE1].ob_spec;
   strcpy(*tedptr,"  A U T O   T I C K L E R  ");

   ob_hide(tree,EREXIT);
   ob_hide(tree,ERDELETE);

   old_rec=rec_no;

   for(i=0; i<10; i++)
   {
      match=FALSE;
      if(data_entry.dsubj)
         if(instr(rec[old_rec].rsubj,auto_ticklers[i].akeyword))
            match=TRUE;
      for(l=0; l<data_entry.dxfields; l++)
         if(instr(rec[old_rec].rxfield[l],auto_ticklers[i].akeyword))
            match=TRUE;
      for(l=0; l<data_entry.ddescr_lines; l++)
      {
         strcpy(up_descr,rec[old_rec].rdescr[l]);
         upper(up_descr);
         if(instr(up_descr,auto_ticklers[i].akeyword))
            match=TRUE;
      }

      if(match)
      {
         for(j=0; j<5; j++)
         {
            if(auto_ticklers[i].adays[j]>0 && rec_no+1<max_recs)
            {
               rec_no++;

               clear_form(tree);

               tedptr=(char *)tree[ERDATE].ob_spec;
               strcpy(*tedptr,right(rec[old_rec].rdate,4));
               if(data_entry.dcentury==TRUE)
                  strcat(*tedptr,left(rec[old_rec].rdate,4));
               else
                  if(data_entry.dyear==TRUE)
                     strcat(*tedptr,mid(rec[old_rec].rdate,3,2));

               tedptr=(char *)tree[ERTICKLE].ob_spec;
               itoa(auto_ticklers[i].adays[j],*tedptr);

               if(auto_ticklers[i].adir==FORWARD)
                  reset_rbuttons(tree,ERTICKAH,FALSE);
               else
                  reset_rbuttons(tree,ERTICKBK,FALSE);
               
               if(data_entry.dsubj==TRUE)
               {
                  tedptr=(char *)tree[TSUBJED].ob_spec;
                  strcpy(temp,"\0");
                  if(strlen(auto_ticklers[i].akeyword)<data_entry.dlen_subj-8)
                  {
                     strcat(temp,auto_ticklers[i].akeyword);
                     strcat(temp," ");
                  }
                  strcat(temp,"TICKLER");
                  strcpy(*tedptr,left(temp,data_entry.dlen_subj));
               }
               for(l=0; l<data_entry.dxfields; l++)
               {
                  tedptr=(char *)tree[xfed_tab[0][l]].ob_spec;
                  strcpy(*tedptr,rec[old_rec].rxfield[l]);
               }
               tedptr=(char *)tree[ERDESCR1].ob_spec;
               itoa(auto_ticklers[i].adays[j],temp);
               if(auto_ticklers[i].adays[j]==1)
                  strcat(temp," day");
               else
                  strcat(temp," days");
               if(auto_ticklers[i].adir==FORWARD)
                  strcat(temp," after ");
               else
                  strcat(temp," before ");
               strcat(temp,rec[old_rec].rdescr[0]);

               if(strlen(temp)>data_entry.dlen_descr[0])
               {
                  m=strlen(temp);
                  while(m>20)
                  {
                     if(word_end(temp[m]) && m<data_entry.dlen_descr[0])
                        break;
                     m--;
                  }

                  if(m>39)
                     m=39;
                  strcpy(temp2,left(temp,m+1));
                  strcpy(*tedptr,left(temp2,data_entry.dlen_descr[0]));
                  rtrim(*tedptr);
                  ltrim(*tedptr);

                  if(data_entry.ddescr_lines>=2)
                  {
                     tedptr=(char *)tree[ERDESCR2].ob_spec;
                     strcpy(temp,right(temp,strlen(temp)-m-1));
                     if(strlen(rec[old_rec].rdescr[1])>0)
                     {
                        strcat(temp," ");
                        strcat(temp,rec[old_rec].rdescr[1]);
                     }
                  }
                  if(data_entry.ddescr_lines>=3)
                  {
                     if(strlen(rec[old_rec].rdescr[2])>0)
                     {
                        strcat(temp," ");
                        strcat(temp,rec[old_rec].rdescr[2]);
                     }
                  }
                  if(data_entry.ddescr_lines>=4)
                  {
                     if(strlen(rec[old_rec].rdescr[3])>0)
                     {
                        strcat(temp," ");
                        strcat(temp,rec[old_rec].rdescr[3]);
                     }
                  }

                  if(data_entry.ddescr_lines>=2)
                  {
                     strcpy(*tedptr,left(temp,data_entry.dlen_descr[1]));
                     rtrim(*tedptr);
                     ltrim(*tedptr);
                  }

                  if(data_entry.ddescr_lines>=3)
                  {
                     if(strlen(temp)>data_entry.dlen_descr[2])
                     {
                        tedptr=(char *)tree[ERDESCR3].ob_spec;
                        strcpy(temp3,mid(temp,data_entry.dlen_descr[0]+1,
                                              data_entry.dlen_descr[2]));
                        strcpy(temp3,left(temp3,data_entry.dlen_descr[2]));
                        rtrim(temp3);
                        ltrim(temp3);
                        strcpy(*tedptr,left(temp3,data_entry.dlen_descr[2]));
                     }
                  }

                  if(data_entry.ddescr_lines>=4 && strlen(temp)>80)
                  {
                     tedptr=(char *)tree[ERDESCR4].ob_spec;
                     strcpy(temp3,mid(temp,data_entry.dlen_descr[0]+
                                           data_entry.dlen_descr[1]+1,
                                           data_entry.dlen_descr[3]));
                     strcpy(*tedptr,left(temp3,data_entry.dlen_descr[3]));
                     rtrim(*tedptr);
                     ltrim(*tedptr);
                  }
               }
               else
               {
                  tedptr=(char *)tree[ERDESCR1].ob_spec;
                  strcpy(*tedptr,temp);
                  if(data_entry.ddescr_lines>=2)
                  {
                     tedptr=(char *)tree[ERDESCR2].ob_spec;
                     strcpy(*tedptr,rec[old_rec].rdescr[1]);
                  }
               }

               do_msgs(tree,TEDITREC,ERDATE,FALSE,FALSE);

               err_obj=ERDESCR1;
                
               for(;;)
               {
                  exit_obj=do_dialog(tree,TEDITREC,err_obj,0,1);

                  if(exit_obj!=ERCANCEL)
                  {
                     ret=save_event(tree,TRUE);

                     if(ret==(-1))
                        err_obj=ERDATE;
                     else
                        break;
                  }
                  else
                  {
                     rec_no--;
                     break;
                  }
               }
            }
         }
      }
   }
   cust_forms(-1);
}

tick_result(res_date)
char res_date[9];
{
   OBJECT *tree;
   char **tedptr;

   rsrc_gaddr(0,TTICKRES,&tree);

   tedptr=(char *)tree[TRINFO].ob_spec;

   strcpy(*tedptr,wday_str(res_date));
   
   if(wday(res_date)>0)
      strcat(*tedptr,", ");
   strcat(*tedptr,month_str(res_date));
   strcat(*tedptr," ");
   if(strcmp(mid(res_date,7,1),"0")==0)
      strcat(*tedptr,right(res_date,1));
   else
      strcat(*tedptr,right(res_date,2));
   num_suffix(*tedptr);
   strcat(*tedptr,", ");
   strcat(*tedptr,left(res_date,4));

   do_dialog(tree,TTICKRES,0,0,0);
}

