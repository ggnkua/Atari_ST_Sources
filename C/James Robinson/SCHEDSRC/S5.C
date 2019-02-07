/* S5.C -- FILE ROUTINES */

#include "obdefs.h"
#include "osbind.h"
#include "gemdefs.h"
#include "ctools.h"
#include "schdefs.h"
#include "schedule.h"

extern char dir[129],rec_file[129],mac_file[129],tik_file[129],rec_name[20],
            tik_file[129],code_file[129],filealrt[],timealrt[],memalrt[],
            r1alrt[],r2alrt[],r3alrt[],r4alrt[],r5alrt[],crecalrt[],
            crptalrt[],rpt_file[129],wdw_file[129],sys_date[9],dfullalrt[],
            rnfalrt[],standalrt[],impfalrt[],delralrt[],tikalrt[],macalrt[],
            codalrt[],nodiskalrt[];

extern int  gl_hbox,gl_wbox,sort_flag,dummy,rec_modified,rpt_modified,
            tik_modified,mac_modified,cod_modified,rec_no,max_recs,
            disk_full,size_rec,no_disk,sel_windex,xf_table[NUM_XFIELDS],
            rez,rpt_check_one,rpt_ok;

extern long menu_tree;

extern OBJECT *citree;

extern RECORD *rec;

extern CUSTOM data_entry;

extern WIND window[NUM_WINDS];

extern LAST_USED last;

extern OTHER_PREFS prefs;

extern TICKLERS auto_ticklers[NUM_AUTO_TICKLERS];

extern PCODES prt_codes;

extern SELECTION select[NUM_SELECTIONS];

extern RPT report[NUM_REPORTS];

rec_save(need_file)
int  need_file;
{
   int  untitled;

   if(strlen(rec_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
      hide_windows();

   save_recs(need_file,&data_entry,FALSE);

   if(need_file || untitled)
      show_windows();
}

rec_load()
{
   hide_windows();
   open_recs(TRUE,TRUE,FALSE,TRUE);
   set_names();
   show_windows();
   set_all_wdw_headers();
}

rpt_save()
{
   hide_windows();
   save_rpts(TRUE);
   show_windows();
}

rpt_load()
{
   hide_windows();
   load_reports(TRUE);
   set_names();
   show_windows();
   set_all_wdw_headers();
}

wdw_save()
{
   hide_windows();
   save_windows();
   show_windows();
}

wdw_load()
{
   hide_windows();
   load_windows(TRUE);
   set_names();
   show_windows();
   set_all_wdw_headers();
}

merge_file()
{
   hide_windows();
   open_recs(FALSE,TRUE,FALSE,TRUE);
   show_windows();
}

new()
{
   int  i;

   hide_windows();

   upd_records();

   rec_no=0;

  for(i=0; i<NUM_SELECTIONS; i++)
  {
      select[i].sselected=FALSE;
      select[i].srec_no=(-1);
      select[i].scommon=FALSE;
   }

   rec_modified=FALSE;

   del_state(menu_tree,RECNEW,DISABLED);
   del_state(citree,CINEWREC,DISABLED);

   strcpy(rec_file,"\0");
   strcpy(rec_name,"UNTITLED.REC");

   for(i=0; i<NUM_WINDS; i++)
   {
      if(window[i].wcontents>=WC_REPORT)
      {
         window[i].wxindex=0;
         window[i].wyindex=0;
         window[i].wlines=0;
         window[i].wcolumns=0;
         window[i].wshown=0;
         window[i].wxdescr=0;
         set_sliders(window[i].whandle,window[i].wcontents);
      }
   }

   show_windows();
}

get_path(dir,buf,spec)
char *dir,*buf,*spec;
{
   int  drive;
   static char temp1[4],temp2[128];

   drive=Dgetdrv();

   temp1[0]=drive + 'A';
   temp1[1]=':';
   temp1[2]='\\';

   Dgetpath(temp2,drive+1);

   if(strlen(temp2)>0)
   {
      strcat(temp2,"\\");
      temp1[2]='\0';
   }
   else
      temp1[2]='\0';

   strcpy(buf,temp1);
   strcat(buf,temp2);

   strcpy(dir,temp1);
   strcat(dir,temp2);

   strcat(buf,spec);
}

get_name(name,file)
char *name,*file;
{
   int  i,j;
   static char temp[20];

   if(strlen(file)==0)
      return;

   i=strlen(file)-1; j=0;

   while(file[i]!='\\' && file[i]!=':' && i>=0)
   {
      temp[j]=file[i];
      i--;
      j++;
   }
   temp[j]='\0';

   reverse(temp);
   strcpy(name,temp);
}

abandon()
{
   hide_windows();
   open_recs(TRUE,FALSE,FALSE,TRUE);
   set_names();
   show_windows();
}

path_to_name(dname,fname)
char *dname,*fname;
{
   char c;
   int  i;

   i=strlen(dname);
   while(i && (((c=dname[i-1]) !='\\') && (c!=':')))
      i--;
   dname[i]='\0';
   strcat(dname,fname);
}

delete()
{
   int  ok,i;
   static char path[129],dir[129],fname[129],name[20],temp[20],old_path[129];

   hide_windows();

   get_path(dir,path,"*.REC");

   for(;;)
   {
      strcpy(name,"\0");
      fsel_input(path,name,&ok);
      if(!ok)
         break;

      strcpy(old_path,path);
      do_extension(name,"REC");
      path_to_name(path,name);
      strcpy(fname,path);
      strcpy(path,old_path);

      if(!instr(fname,"SCHEDULE.PRG") &&
         !instr(fname,"SCHEDULE.RSC"))
      {
         if(strlen(name)>0)
         {
            strcpy(temp,name);
            strcat(temp,"?");
            strcat(temp,replicate(' ',13-strlen(temp)));

            for(i=0; i<13; i++)
               delralrt[40+i]=temp[i];

            if(form_alert(1,delralrt)==1)
               Fdelete(fname);
         }
      }
      else
         form_alert(1,impfalrt);
   }
   show_windows();
}

save_macs(need_file)
int  need_file;
{
   OBJECT *tree;
   int  file_handle,i,exit_obj,magic,untitled;
   static char name[20];
   char **tedptr,*mac_str;

   rsrc_gaddr(0,TMACROS,&tree);

   if(strlen(mac_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
   {
      get_name(name,mac_file);
      exit_obj=use_fsel(mac_file,name,"*.MAC");
   }

   if(exit_obj==0 && untitled)
      strcpy(mac_file,"\0");

   if(exit_obj!=0 || (!need_file && !untitled))
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fcreate(mac_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=MAC_MAGIC;

         EFwrite(file_handle,2L,&magic);

         for(i=0; i<26; i++)
         {
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               Fclose(file_handle);
               Fdelete(mac_file);
               break;
            }

            tedptr=(char *)tree[AMAC+i].ob_spec;
            mac_str= *tedptr;

            EFwrite(file_handle,30L,mac_str);
         }
         if(!disk_full)
         {
            Fclose(file_handle);
            mac_modified=FALSE;
         }
      }
      graf_mouse(ARROW,&dummy);
   }
}

load_macs(need_name)
int  need_name;
{
   OBJECT *tree;
   int  file_handle,i,exit_obj,magic;
   static char name[20];
   char **tedptr,mac_str[31];

   rsrc_gaddr(0,TMACROS,&tree);

   if(need_name)
      exit_obj=use_fsel(mac_file,name,"*.MAC");
   else
   {
      if(strlen(mac_file)==0)
         return;
      get_name(name,mac_file);
   }

   if(exit_obj!=0 || !need_name)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(mac_file,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=MAC_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            return(0);
         }

         for(i=0; i<26; i++)
         {
            Fread(file_handle,30L,mac_str);
            tedptr=(char *)tree[AMAC+i].ob_spec;
            strcpy(*tedptr,mac_str);
         }
         Fclose(file_handle);
      }
      graf_mouse(ARROW,&dummy);
   }
}

save_codes(need_file)
int  need_file;
{
   long size;
   int  file_handle,exit_obj,magic,untitled;
   static char name[20];

   if(strlen(code_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
   {
      get_name(name,code_file);
      exit_obj=use_fsel(code_file,name,"*.COD");
   }

   if(exit_obj==0 && untitled)
      strcpy(code_file,"\0");

   if(exit_obj!=0 || (!need_file && !untitled))
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fcreate(code_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=COD_MAGIC;

         EFwrite(file_handle,2L,&magic);

         size=sizeof(PCODES);
         EFwrite(file_handle,size,&prt_codes);

         if(disk_full)
         {
            form_alert(1,dfullalrt);
            Fclose(file_handle);
            Fdelete(code_file);
         }
         else
         {
            Fclose(file_handle);
            cod_modified=FALSE;
         }
      }
      graf_mouse(ARROW,&dummy);
   }
}

load_codes(need_file)
int  need_file;
{
   long size;
   int  file_handle,exit_obj,magic;
   static char name[20];

   if(need_file)
      exit_obj=use_fsel(code_file,name,"*.COD");
   else
   {
      if(strlen(code_file)==0)
         return;
      get_name(name,code_file);
   }

   if(exit_obj!=0 || !need_file)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(code_file,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=COD_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            return(0);
         }

         size=sizeof(PCODES);
         Fread(file_handle,size,&prt_codes);
         Fclose(file_handle);
      }
      graf_mouse(ARROW,&dummy);
   }
}

load_auto_ticklers(need_file)
int  need_file;
{
   long size;
   int  file_handle,exit_obj,magic,i;
   static char name[20];

   if(need_file)
      exit_obj=use_fsel(tik_file,name,"*.TIK");
   else
   {
      if(strlen(tik_file)==0)
         return;
      get_name(name,tik_file);
   }

   if(exit_obj!=0 || !need_file)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(tik_file,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=TIK_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            return(0);
         }

         size=sizeof(TICKLERS);
         for(i=0; i<NUM_AUTO_TICKLERS; i++)
            Fread(file_handle,size,&auto_ticklers[i]);

         Fclose(file_handle);
      }
      else
      {
         if(file_handle==(-6))
            no_disk=TRUE;
      }
      graf_mouse(ARROW,&dummy);
   }
}

save_auto_ticklers(need_file)
int  need_file;
{
   long size;
   int  file_handle,exit_obj,magic,i,untitled;
   static char name[20];

   if(strlen(tik_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
   {
      get_name(name,tik_file);
      exit_obj=use_fsel(tik_file,name,"*.TIK");
   }

   if(exit_obj==0 && untitled)
      strcpy(tik_file,"\0");

   if(exit_obj!=0 || (!need_file && !untitled))
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fcreate(tik_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=TIK_MAGIC;

         EFwrite(file_handle,2L,&magic);

         size=sizeof(TICKLERS);
         for(i=0; i<NUM_AUTO_TICKLERS; i++)
         {
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               Fclose(file_handle);
               Fdelete(tik_file);
               break;
            }
            else
               EFwrite(file_handle,size,&auto_ticklers[i]);
         }
         if(!disk_full)
         {
            Fclose(file_handle);
            tik_modified=FALSE;
         }
      }
      graf_mouse(ARROW,&dummy);
   }
}

get_cdir(dir)
char *dir;
{
   int  drive;
   auto char temp1[4],temp2[129];

   drive=Dgetdrv();

   temp1[0]=drive + 'A';
   temp1[1]=':';
   temp1[2]='\\';

   Dgetpath(temp2,drive+1);

   if(strlen(temp2)>0)
   {
      strcat(temp2,"\\");
      temp1[2]='\0';
   }
   else
      temp1[2]='\0';

   strcpy(dir,temp1);
   strcat(dir,temp2);
}

upd_records()
{
   int  ret;

   if(rec_modified==TRUE && rec_no>0)
   {
      ret=form_alert(1,crecalrt);
      if(ret==1)
         save_recs(FALSE,&data_entry,FALSE);
      else if(ret==3)
         save_recs(TRUE,&data_entry,FALSE);
   }
   return(TRUE);
}

upd_rpts()
{
   int  ret;

   if(rpt_modified==TRUE)
   {
      ret=form_alert(1,crptalrt);
      if(ret==1)
         save_rpts(FALSE);
      else if(ret==3)
         save_rpts(TRUE);
   }
   return(TRUE);
}

upd_prefs()
{
   int  ret;

   if(tik_modified==TRUE)
   {
      ret=form_alert(1,tikalrt);
      if(ret==1)
         save_auto_ticklers(FALSE);
      else if(ret==3)
         save_auto_ticklers(TRUE);
   }
   if(mac_modified==TRUE)
   {
      ret=form_alert(1,macalrt);
      if(ret==1)
         save_macs(FALSE);
      else if(ret==3)
         save_macs(TRUE);
   }
   if(cod_modified==TRUE)
   {
      ret=form_alert(1,codalrt);
      if(ret==1)
         save_codes(FALSE);
      else if(ret==3)
         save_codes(TRUE);
   }
   return(TRUE);
}

do_extension(filename,extension)
char *filename,*extension;
{
   int  i;

   if(strlen(filename)==0)
      return;

   for(i=0; filename[i]!='\0'; i++)
      if(filename[i]=='.' && filename[i+1]!='\0')
         return;

   filename[i]='.';

   filename[i+1]='\0';

   strcat(filename,extension);
}

file_info()
{
   OBJECT *tree;
   char *strptr,**tedptr;

   hide_windows();

   rsrc_gaddr(0,TINFO,&tree);

   tedptr=(char *)tree[FITITLE].ob_spec;
   strcpy(*tedptr,"INFORMATION FOR ");
   if(strlen(rec_file)==0)
      strcat(*tedptr,"UNTITLED.REC");
   else
      strcat(*tedptr,rec_name);

   strptr=(char *)tree[FIMAX].ob_spec;
   itoa(max_recs,strptr);

   strptr=(char *)tree[FIUSED].ob_spec;
   itoa(rec_no,strptr);

   strptr=(char *)tree[FIBYTES].ob_spec;
   ltoa(((long)rec_no*((long)size_rec+9L))+(long)sizeof(CUSTOM)+4L,strptr);
   strcat(strptr," bytes");

   do_dialog(tree,TINFO,0,0,0);

   show_windows();
}

load_prefs()
{
   int  file_handle;
   static char fname[129];
   long size;

   graf_mouse(HOURGLASS,&dummy);

   rpt_check_one=FALSE;

   get_cdir(dir);
   strcpy(fname,dir);
   strcat(fname,"SCHEDULE.INF");

   file_handle=ERROR;
   file_handle=Fopen(fname,0);
   if(file_handle>ERROR)
   {
      Fread(file_handle,128L,tik_file);
      Fread(file_handle,128L,mac_file);
      Fread(file_handle,128L,code_file);
      Fread(file_handle,128L,rec_file);
      Fread(file_handle,128L,rpt_file);
      Fread(file_handle,128L,wdw_file);
 
      size=sizeof(OTHER_PREFS);
      Fread(file_handle,size,&prefs);
 
      Fclose(file_handle);

      no_disk=FALSE;

      load_auto_ticklers(FALSE);
      if(no_disk)
      {
         form_alert(1,nodiskalrt);
         form_alert(1,rnfalrt);
         mal_records(FALSE);
      }
      else
      {
         put_ticklers();
         load_macs(FALSE);
         load_codes(FALSE);
         put_codes();
         rpt_check_one=TRUE;
         rpt_ok=load_reports(FALSE);
         rpt_check_one=FALSE;
         load_windows(FALSE);
         set_names();
         if(!open_recs(TRUE,FALSE,FALSE,FALSE))
            mal_records(FALSE);

         if(!rpt_ok)
         {
            get_cdir(dir);
            strcpy(rpt_file,dir);
            strcat(rpt_file,"STANDARD.RPT");
            load_reports(FALSE);
         }
      }
   }
   else
   {
      get_cdir(dir);
      strcpy(rpt_file,dir);
      strcat(rpt_file,"STANDARD.RPT");
      load_reports(FALSE);
      mal_records(FALSE);
   }

   enable_pbuttons();

   graf_mouse(ARROW,&dummy);
}

save_prefs()
{
   int  file_handle,i,wdwopen;
   static char fname[129];
   long size;

   graf_mouse(HOURGLASS,&dummy);

   wdwopen=FALSE;

   for(i=0; i<NUM_WINDS; i++)
      if(window[i].wopen==TRUE)
         wdwopen=TRUE;

   if(!wdwopen)
      strcpy(wdw_file,"\0");

   get_cdir(dir);
   strcpy(fname,dir);
   strcat(fname,"SCHEDULE.INF");

   file_handle=ERROR;
   file_handle=Fcreate(fname,0);
   if(file_handle>ERROR)
   {
      disk_full=FALSE;

      EFwrite(file_handle,128L,tik_file);
      EFwrite(file_handle,128L,mac_file);
      EFwrite(file_handle,128L,code_file);
      EFwrite(file_handle,128L,rec_file);
      EFwrite(file_handle,128L,rpt_file);
      EFwrite(file_handle,128L,wdw_file);

      size=sizeof(OTHER_PREFS);
      EFwrite(file_handle,size,&prefs);

      if(disk_full)
      {
         form_alert(1,dfullalrt);
         Fclose(file_handle);
         Fdelete(fname);
      }
      else
      {
         Fclose(file_handle);
      }
   }
   graf_mouse(ARROW,&dummy);
}

load_reports(need_file)
int  need_file;
{
   int  file_handle,i,exit_obj,magic;
   static char name[20];
   long size;

   if(need_file)
   {
      upd_rpts();
      exit_obj=use_fsel(rpt_file,name,"*.RPT");
   }
   else
   {
      if(strlen(rpt_file)==0)
         return(FALSE);
      get_name(name,rpt_file);
   }

   if(exit_obj!=0 || !need_file)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(rpt_file,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=RPT_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            return(FALSE);
         }

         rpt_modified=FALSE;

         size=sizeof(RPT);

         for(i=0; i<NUM_REPORTS; i++)
            Fread(file_handle,size,&report[i]);

         Fclose(file_handle);

         count_all_lines();

         do_rpt_check();
      }
      else
      {
         if(!rpt_check_one) /* one of two checks for a report file */
         {                     
            graf_mouse(ARROW,&dummy);
            form_alert(1,rnfalrt);
            strcpy(rpt_file,"\0");
            return(FALSE);
         }
         else
            return(FALSE);
      }
      graf_mouse(ARROW,&dummy);
   }

   return(TRUE);
}

save_rpts(need_file)
int  need_file;
{
   int  file_handle,i,exit_obj,magic,untitled;
   static char name[20];
   long size;

   if(strlen(rpt_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
   {
      get_name(name,rpt_file);
      exit_obj=use_fsel(rpt_file,name,"*.RPT");
   }

   if(exit_obj==0 && untitled)
      strcpy(rpt_file,"\0");

   if(exit_obj!=0 || (!need_file && !untitled))
   {
      if(instr(rpt_file,"STANDARD.RPT"))
         if(form_alert(1,standalrt)==2)
            return;

      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fcreate(rpt_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=RPT_MAGIC;

         EFwrite(file_handle,2L,&magic);

         size=sizeof(RPT);

         for(i=0; i<NUM_REPORTS; i++)
         {
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               Fclose(file_handle);
               Fdelete(rpt_file);
               break;
            }
            else
               EFwrite(file_handle,size,&report[i]);
         }
         if(!disk_full)
         {
            Fclose(file_handle);
            rpt_modified=FALSE;
         }
      }
      graf_mouse(ARROW,&dummy);
   }
}

load_windows(need_file)
int  need_file;
{
   int  file_handle,i,j,exit_obj,magic,wdw_rez,ret;
   static char name[20];
   long size;

   if(need_file)
      exit_obj=use_fsel(wdw_file,name,"*.WDW");
   else
   {
      if(strlen(wdw_file)==0)
         return;
      get_name(name,wdw_file);
   }

   if(exit_obj!=0 || !need_file)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(wdw_file,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=WDW_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            return(0);
         }   

         menu_ienable(menu_tree,RECCLEAR,0);

         rec_menu_normal();

         for(i=0; i<NUM_SELECTIONS; i++)
         {
            select[i].srec_no=(-1);
            select[i].sselected=FALSE;
         }

         for(i=0; i<NUM_WINDS; i++)
         {
            if(window[i].wopen==TRUE)
            {
                if(window[i].whidden==FALSE)
                   wind_close(window[i].whandle);
                wind_delete(window[i].whandle);
                clr_window(window[i].whandle);
            }
         }

         Fread(file_handle,2L,&wdw_rez);

         size=sizeof(WIND);

         for(i=0; i<NUM_WINDS; i++)
            Fread(file_handle,size,&window[i]);

         if(wdw_rez!=rez)
         {
            if(rez==2 && wdw_rez==1)
            {
               for(i=0; i<NUM_WINDS; i++)
               {
                  window[i].wy=window[i].wy*2;
                  window[i].wheight=window[i].wheight*2;
               }
            }
            else if(rez==1 && wdw_rez==2)
            {
               for(i=0; i<NUM_WINDS; i++)
               {
                  window[i].wy=window[i].wy/2;
                  window[i].wheight=window[i].wheight/2;
               }
            }
         }         

         Fclose(file_handle);
      }
 
      for(i=0; i<NUM_WINDS; i++)
      {
         if(window[i].wopen==TRUE)
         {
            ret=create_window(window[i].wcontents,window[i].wfeatures,FALSE,i);
            if(ret>(-1))
            {
               open_window(i);
               if(window[i].wcontents==WC_CALENDAR)
                  set_xy(window[i].work_area.g_x,window[i].work_area.g_y);
               else if(window[i].wcontents>=WC_REPORT)
               { 
                  if(window[i].wsys_sdate==TRUE)
                     strcpy(window[i].wsdate,sys_date);
                  if(window[i].wsys_edate==TRUE)
                     strcpy(window[i].wedate,sys_date);
               }
            }
            else
            {
               for(j=i; j<NUM_WINDS; j++)
               {
                  window[j].wopen=FALSE;
                  window[j].whidden=FALSE;
               }
               break;
            }
         }
         window[i].whidden=FALSE;
      }

      count_all_lines();

      graf_mouse(ARROW,&dummy);
   }
}

save_windows()
{
   int  file_handle,i,exit_obj,magic;
   static char name[20];
   long size;

   get_name(name,wdw_file);
   exit_obj=use_fsel(wdw_file,name,"*.WDW");

   if(exit_obj!=0)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fcreate(wdw_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=WDW_MAGIC;

         EFwrite(file_handle,2L,&magic);

         EFwrite(file_handle,2L,&rez);

         size=sizeof(WIND);
         for(i=0; i<NUM_WINDS; i++)
         {
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               Fclose(file_handle);
               Fdelete(wdw_file);
               break;
            }
            else
               EFwrite(file_handle,size,&window[i]);
         }
         if(!disk_full)
            Fclose(file_handle);
      }
      graf_mouse(ARROW,&dummy);
   }
}

rename()
{
   int  button,i,exit_obj,ret;
   static char rdir[128],path[128],name[20],old_fname[129],new_fname[129];

   hide_windows();

   strcpy(rdir,dir);

   button=form_alert(1,r1alrt);

   if(button==2)
   {
      show_windows();
      return(0);
   }

   get_path(rdir,path,"*.REC");
   fsel_input(path,name,&exit_obj);

   if(exit_obj!=0)
   {
      do_extension(name,"REC");
      path_to_name(path,name);
      strcpy(old_fname,path);
   }
   else
   {
      show_windows();
      return(0);
   }

   button=form_alert(1,r2alrt);

   if(button==2)
   {
      show_windows();
      return(0);
   }

   strcpy(path,left(old_fname,strlen(old_fname)-strlen(name)));
   strcat(path,"*");
   for(i=0; old_fname[i]!='\0' && old_fname[i]!='.'; i++);
   strcat(path,right(old_fname,strlen(old_fname)-i));

   fsel_input(path,name,&exit_obj);

   if(exit_obj!=0)
   {
      do_extension(name,"REC");
      path_to_name(path,name);
      strcpy(new_fname,path);
   }
   else
   {
      show_windows();
      return(0);
   }

   ret=Frename(0,old_fname,new_fname);

   if(ret==EACCDN)
      form_alert(1,r3alrt);
   else if(ret==EPTHNF)
      form_alert(1,r4alrt);
   else if(ret==ENSAME)
      form_alert(1,r5alrt);

   show_windows();
}

make_backup(file)
char *file;
{
   int i,p_idx;
   static char backup[129];

   i=0; p_idx=(-1);

   while(file[i]!='\0')
   {
      if(file[i]=='.')
         p_idx=i;
      i++;
   }

   if(p_idx>(-1))
      strcpy(backup,left(file,p_idx));
   else
      strcpy(backup,left(file,i));

   strcat(backup,".BAK");

   Fdelete(backup);

   Frename(0,file,backup);
}

int 
use_fsel(filename,name,spec)
char *filename,*name,spec[6];
{
   int  exit_obj;
   static char path[129];

   if(strlen(filename)>0)
   {
      get_name(name,filename);
      strcpy(path,left(filename,strlen(filename)-strlen(name)));
      strcat(path,spec);
   }
   else
      get_path(dir,path,spec);

   fsel_input(path,name,&exit_obj);
   if(strlen(name)>0)
   {
      path_to_name(path,name);
      strcpy(filename,path);
      do_extension(filename,right(spec,3));
      do_extension(name,right(spec,3));
   }
   else
      return(0);

   return(exit_obj);
}

open_recs(clear_flag,need_file,temp_flag,free_flag)
int  clear_flag,need_file,temp_flag,free_flag;
{
   int  i,j,k,file_handle,exit_obj,ret_code,magic,xfidx;
   long size,xfval;
   static char fname[129],temp_buff[41],old_name[20];
   CUSTOM open_data;

   if(clear_flag && !temp_flag && need_file)
      upd_records();

   exit_obj=0;

   if(clear_flag && !temp_flag)
   {
      del_state(menu_tree,RECNEW,DISABLED);
      del_state(citree,CINEWREC,DISABLED);
   }

   if(!need_file && strlen(rec_file)==0)
   {
      rec_no=0;
      return;
   }

   strcpy(old_name,rec_name);

   if(need_file)
   {
      if(!clear_flag)
         strcpy(rec_name,"\0");

      exit_obj=use_fsel(fname,rec_name,"*.REC");

      if(exit_obj==0 || !clear_flag)
         strcpy(rec_name,old_name);
   }
   else
   {
      strcpy(fname,rec_file);
      get_name(rec_name,rec_file);
   }

   if(exit_obj!=0 || !need_file)
   {
      graf_mouse(HOURGLASS,&dummy);

      file_handle=ERROR;
      file_handle=Fopen(fname,0);
      if(file_handle>ERROR)
      {
         Fread(file_handle,2L,&magic);
         if(magic!=REC_MAGIC)
         {
            graf_mouse(ARROW,&dummy);
            form_alert(1,filealrt);
            Fclose(file_handle);
            strcpy(rec_name,old_name);
            return(0);
         }

         if(clear_flag)
            rec_no=0;

         Fread(file_handle,2L,&sort_flag);

         size=sizeof(CUSTOM);
         Fread(file_handle,size,&open_data);

         if(clear_flag)
         {
            data_entry.dcentury=open_data.dcentury;
            data_entry.dyear=open_data.dyear;
            data_entry.dtickler=open_data.dtickler;
            data_entry.dstime=open_data.dstime;
            data_entry.detime=open_data.detime;
            data_entry.dsubj=open_data.dsubj;
            data_entry.dlen_subj=open_data.dlen_subj;
            data_entry.ddescr_lines=open_data.ddescr_lines;
            for(i=0; i<4; i++)
               data_entry.dlen_descr[i]=open_data.dlen_descr[i];
            data_entry.dxfields=open_data.dxfields;
            for(i=0; i<NUM_XFIELDS; i++)
            {
               strcpy(data_entry.dxflabel[i],open_data.dxflabel[i]);
               data_entry.dxfchrs[i]=open_data.dxfchrs[i];
            }
         }

         if(clear_flag && !temp_flag)
         {
            cust_forms(FALSE);
            mal_records(free_flag);
         }

         graf_mouse(HOURGLASS,&dummy);

         for(;;)
         {
            if(rec_no>=max_recs)
            {
               form_alert(1,memalrt);
               set_state(menu_tree,RECNEW,DISABLED);
               set_state(citree,CINEWREC,DISABLED);
               break;
            }

            clr_record(rec_no);

            ret_code=Fread(file_handle,9L,rec[rec_no].rdate);
                     if(open_data.dstime)
                        Fread(file_handle,6L,rec[rec_no].rstime);
                     if(open_data.detime)
                        Fread(file_handle,6L,rec[rec_no].retime);
                     if(open_data.dsubj)
                     {
                        xfval=open_data.dlen_subj+1;
                        Fread(file_handle,xfval,rec[rec_no].rsubj);
                     }
                     for(j=0; j<open_data.dxfields; j++)
                     {
                        xfidx=(-1);

                        if(!clear_flag && strcmp(open_data.dxflabel[j],
                                                data_entry.dxflabel[j])!=0)
                        {
                           for(k=0; k<NUM_XFIELDS; k++)
                           {
                              if(strcmp(open_data.dxflabel[j],
                                 data_entry.dxflabel[k])==0)
                              {
                                 xfidx=k;
                                 break;
                              }
                           }
                        }
                        else
                           xfidx=j;

                        xfval=open_data.dxfchrs[j]+1;

                        if(xfidx>(-1))
                           Fread(file_handle,xfval,rec[rec_no].rxfield[xfidx]);
                        else
                           Fread(file_handle,xfval,temp_buff);
                     }
                     for(j=0; j<open_data.ddescr_lines; j++)
                     {
                        xfval=open_data.dlen_descr[j]+1;
                        Fread(file_handle,xfval,rec[rec_no].rdescr[j]);
                     }
             
             rec[rec_no].rdeleted=FALSE;

             if(ret_code==0)
                break;
             else
                rec_no++;
         }
         Fclose(file_handle);
      }
      else
      {
         graf_mouse(ARROW,&dummy);
         if(!need_file)
         {
            strcpy(rec_file,"\0");
            strcpy(rec_name,"UNTITLED.REC");
         }
         else
            strcpy(rec_name,old_name);
         return(FALSE);
      }

      if(clear_flag)
         rec_modified=FALSE;
      else
         rec_modified=TRUE;

      if(!clear_flag || sort_flag==TRUE)
         sort_cal(rec,rec_no);

      sort_flag=FALSE;

      count_all_lines();

      if(clear_flag && !temp_flag)
         strcpy(rec_file,fname);

      graf_mouse(ARROW,&dummy);
   }
   return(TRUE);
}

save_recs(need_file,specs,xf_flag)
int  need_file,xf_flag;
CUSTOM *specs;
{
   int  file_handle,exit_obj,i,j,magic,untitled,xfidx;
   long size,xfval;
   static char empty[41],temp_info[41];

   strcpy(empty,"\0");

   if(strlen(rec_file)==0)
      untitled=TRUE;
   else
      untitled=FALSE;

   if(need_file || untitled)
      exit_obj=use_fsel(rec_file,rec_name,"*.REC");

   if(exit_obj==0 && untitled)
   {
       strcpy(rec_file,"\0");
       strcpy(rec_name,"UNTITLED.REC");
   }

   if(exit_obj!=0 || (!need_file && !untitled))
   {
      graf_mouse(HOURGLASS,&dummy);

      if(prefs.opbackup)
         make_backup(rec_file);

      file_handle=ERROR;
      file_handle=Fcreate(rec_file,0);
      if(file_handle>ERROR)
      {
         disk_full=FALSE;

         magic=REC_MAGIC;

         EFwrite(file_handle,2L,&magic);

         EFwrite(file_handle,2L,&sort_flag);

         size=sizeof(CUSTOM);
         EFwrite(file_handle,size,&data_entry);

         for(i=0; i<rec_no; i++)
         {
            if(disk_full)
            {
               form_alert(1,dfullalrt);
               Fclose(file_handle);
               Fdelete(rec_file);
               break;
            }

            if(rec[i].rdeleted!=TRUE)
            {
               EFwrite(file_handle,9L,rec[i].rdate);

               if(data_entry.dstime)
               {
                  if(specs->dstime)
                     EFwrite(file_handle,6L,rec[i].rstime);
                  else
                     EFwrite(file_handle,6L,empty);
               }
               if(data_entry.detime)
               {
                  if(specs->detime)
                     EFwrite(file_handle,6L,rec[i].retime);
                  else
                     EFwrite(file_handle,6L,empty);
               }
               if(data_entry.dsubj)
               {
                  xfval=data_entry.dlen_subj+1;
                  if(specs->dsubj)
                  {
                     if(specs->dlen_subj+1>=xfval)
                     {
                        strcpy(temp_info,left(rec[i].rsubj,(int )xfval-1));
                        EFwrite(file_handle,xfval,temp_info);
                     }
                     else
                     {
                        EFwrite(file_handle,(long)specs->dlen_subj,rec[i].rsubj);
                        EFwrite(file_handle,(long)xfval-(long)specs->dlen_subj,empty);
                     }
                  }
                  else
                     EFwrite(file_handle,xfval,empty);
               }
               for(j=0; j<data_entry.dxfields; j++)
               {
                  if(xf_flag)
                     xfidx=xf_table[j];
                  else
                     xfidx=j;

                  xfval=data_entry.dxfchrs[j]+1;

                  if(xfidx!=(-1))
                  {
                     if(specs->dxfchrs[xfidx]+1>=xfval)
                     {
                        strcpy(temp_info,left(rec[i].rxfield[xfidx],(int )xfval-1));
                        EFwrite(file_handle,xfval,temp_info);
                     }
                     else
                     {
                        EFwrite(file_handle,(long)specs->dxfchrs[xfidx],rec[i].rxfield[xfidx]);
                        EFwrite(file_handle,(long)xfval-(long)specs->dxfchrs[xfidx],empty);
                     }
                  }
                  else
                     EFwrite(file_handle,xfval,empty);
               }
               for(j=0; j<data_entry.ddescr_lines; j++)
               {
                  xfval=data_entry.dlen_descr[j]+1;
                  if(specs->ddescr_lines>j)
                  {
                     if(specs->dlen_descr[j]+1>=xfval)
                     {
                        strcpy(temp_info,left(rec[i].rdescr[j],(int )xfval-1));
                        EFwrite(file_handle,xfval,temp_info);
                     }
                     else
                     {
                        EFwrite(file_handle,(long)specs->dlen_descr[j],rec[i].rdescr[j]);
                        EFwrite(file_handle,(long)xfval-(long)specs->dlen_descr[j],empty);
                     }
                  }
                  else
                     EFwrite(file_handle,xfval,empty);
               }
            }
         }
         if(!disk_full)
         {
            Fclose(file_handle);
            rec_modified=FALSE;
         }
      }
      graf_mouse(ARROW,&dummy);
   }
}

EFwrite(fh,size,str)
int  fh;
long size;
char *str;
{
   int  ret;

   ret=Fwrite(fh,size,str);

   if(ret<=ERROR || ret<size)
      disk_full=TRUE;
}

