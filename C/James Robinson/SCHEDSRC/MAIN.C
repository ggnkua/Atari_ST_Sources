/* MAIN.C */

#include "stdio.h"
#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "schdefs.h"
#include "schedule.h"

long _stksize=16000L; /* default size was not enough */

char release_date[9]="19890701"; /* any date before is invalid */

char hdate[9],header1[MAX_CLMS+1],header2[MAX_CLMS+1],und_score[MAX_CLMS+1],
     rpt_sdate[9],rpt_edate[9],rpt_title[61],old_date[9],old_sys_date[9],
     old_time[6],rec_file[129],mac_file[129],code_file[129],tik_file[129],
     wdw_file[129],rpt_file[129],rec_name[20],sys_date[9],dir[129],
     fld_buffer[160],sys_time[6],asc_name[129],rm_stime[6],rm_etime[6],
     rm_subj[41],rm_xfield[NUM_XFIELDS][41],rm_descr[41];

char *buf_stime,*buf_etime,*buf_subj,*buf_xfields,*buf_descr,*ct_buff;

char *rec_items[6]={ "  Edit Records...        ",
                     "  Edit Selections...     ",
                     "  Delete Records...      ",
                     "  Delete Selections...   ",
                     "  Transfer Records...    ",
                     "  Transfer Selections... " };

int  contrl[13],intin[128],ptsin[128],intout[128],ptsout[128],dummy,
     work_in[]={1,1,1,1,1,1,1,1,1,1,2},work_out[57],handle,title_retained,
     mx,my,mb,ks,kr,br,mgbuf[8],vdi_handle,rez,xf_table[NUM_XFIELDS],
     gl_wchar,gl_hchar,gl_wbox,gl_hbox,gl_xfull,gl_yfull,gl_wfull,gl_hfull,
     rpt_index,device,org_y[2][500],org_height[2],no_disk,top_rec,
     ed_obj,ed_idx,cal_idx,tot_lines,topped,sel_windex,day_spacing,
     sort_flag,cixind=0,ciyind=0,cicolumns,rec_no=0,max_recs,sel_tab[CAL_LINES],
     cilines,cicounter,cidraw=FALSE,rpt_free,rptcounter,skip_flag,
     too_many_columns=FALSE,old_line_number,cixdescr,cishown,inc_page,
     cixshown,rec_modified=FALSE,rpt_modified=FALSE,tik_modified=FALSE,
     mac_modified=FALSE,cod_modified=FALSE,disk_full=FALSE,cur_modified,
     rpt_decision[9]={EQUAL,EQUAL,IN,IN,IN,IN,IN,IN,IN},windex,
     trans_fhandle,move_flag,cur_file,total,size_rec,pages_this_rpt,
     file_handle,pxy[4],py=0,line_number=0,page_number=1,mark_x[NUM_WINDS],
     mark_y[NUM_WINDS],*y_to_rec_no[9],rm_decision[9],beg_flag,end_flag,
     new_transfer_file,line_this_rpt,cal_flags[31],rpt_check_one=FALSE,
     rpt_ok,add_on_flag=FALSE,dec_counter=0;

int  tsm_pallete[16]={ 0x777,0x700,0x070,0x000,
                       0x000,0x000,0x000,0x000,
                       0x000,0x000,0x000,0x000,
                       0x000,0x000,0x000,0x000 },gem_pallete[16];

int      descr_idx[4]={ERDESCR1,ERDESCR2,ERDESCR3,ERDESCR4},
       atdays_tab[10]={ATDAYS1,ATDAYS2,ATDAYS3,ATDAYS4,ATDAYS5,
                       ATDAYS6,ATDAYS7,ATDAYS8,ATDAYS9,ATDAYS10},
       atfrwd_tab[10]={ATFRWD1,ATFRWD2,ATFRWD3,ATFRWD4,ATFRWD5,
                       ATFRWD6,ATFRWD7,ATFRWD8,ATFRWD9,ATFRWD10},
       atkey_tab[10]={ATKEY1,ATKEY2,ATKEY3,ATKEY4,ATKEY5,
                       ATKEY6,ATKEY7,ATKEY8,ATKEY9,ATKEY10},
     xfpar_tab[2][5]={{TXF1PAR,TXF2PAR,TXF3PAR,TXF4PAR,TXF5PAR},
                      {PXF1PAR,PXF2PAR,PXF3PAR,PXF4PAR,PXF5PAR}},
     xflab_tab[2][5]={{TXF1LAB,TXF2LAB,TXF3LAB,TXF4LAB,TXF5LAB},
                      {PXF1LAB,PXF2LAB,PXF3LAB,PXF4LAB,PXF5LAB}},
      xfed_tab[2][5]={{TXF1ED,TXF2ED,TXF3ED,TXF4ED,TXF5ED},
                      {PXF1ED,PXF2ED,PXF3ED,PXF4ED,PXF5ED}},
     eparr_tab[2][9]={{EPPLUS1,EPPLUS2,EPPLUS3,EPPLUS4,EPPLUS5,
                       EPPLUS6,EPPLUS7,EPPLUS8,EPPLUS9},
                      {EPMIN1,EPMIN2,EPMIN3,EPMIN4,EPMIN5,
                       EPMIN6,EPMIN7,EPMIN8,EPMIN9}},
        prdec_tab[9]={PRSTDEC,PRETDEC,PRSUBDEC,PRXF1DEC,PRXF2DEC,PRXF3DEC,
                      PRXF4DEC,PRXF5DEC,PRDESDEC},
       prdec2_tab[7]={PRINBUT,PREQBUT,PRNEBUT,PRLTBUT,PRGTBUT,PRLEBUT,
                      PRGEBUT},
      algn_tab[3][9]={{EPALGNL1,EPALGNL2,EPALGNL3,EPALGNL4,EPALGNL5,
                       EPALGNL6,EPALGNL7,EPALGNL8,EPALGNL9},
                      {EPALGNC1,EPALGNC2,EPALGNC3,EPALGNC4,EPALGNC5,
                       EPALGNC6,EPALGNC7,EPALGNC8,EPALGNC9},
                      {EPALGNR1,EPALGNR2,EPALGNR3,EPALGNR4,EPALGNR5,
                       EPALGNR6,EPALGNR7,EPALGNR8,EPALGNR9}};

long menu_tree;

FILE *asc_file;

RECORD *rec;

TICKLERS auto_ticklers[NUM_AUTO_TICKLERS];

CUSTOM data_entry,trans_data,prev_data;

RPT report[NUM_REPORTS];

WIND window[NUM_WINDS];

LAST_USED last;

PCODES prt_codes;

PAGE page_setup;

SELECTION select[NUM_SELECTIONS];

OTHER_PREFS prefs;

OBJECT *citree;

char memalrt[]="[3][    Out of memory!         | | | | ][ OK ]",
      r4alrt[]="[3][ Old filename not found.   | | | | ][ OK ]",
     extalrt[]="[3][  Invalid extension.       | | | | ][ OK ]",
    timealrt[]="[3][    Invalid time.          | | | | ][ OK ]",
  notimealrt[]="[3][ Please enter a time.      | | | | ][ OK ]",
      alert0[]="[3][ Please enter a date.      | | | | ][ OK ]",
      alert1[]="[3][    Invalid date.          | | | | ][ OK ]",
     notalrt[]="[0][    No records found.      | | | | ][ OK ]",
   norptalrt[]="[0][ No reports are available. | | | | ][ OK ]",
   nowdwalrt[]="[0][   No windows are open.    | | | | ][ OK ]",
    freealrt[]="[0][     Print free days?      | | | | ][ YES | NO ]",
     delalrt[]="[0][      Delete Report?       | | | | ][ YES | NO ]",
  chgrptalrt[]="[0][      Change report?       | | | | ][ YES | NO ]",
    drecalrt[]="[0][ Delete selected records?  | | | | ][ YES | NO ]",
    poffalrt[]="[3][ Printer is not ready.     | | | | ][ READY | CANCEL ]",
    filealrt[]="[3][ This is not a proper file | for this operation.        | | | ][ OK ]",
  schwdwalrt[]="[0][ Can't edit desk accessory | windows.                   | | | ][ OK ]",
    movealrt[]="[0][ Do you want to MOVE or    | COPY the records?          | | | ][ MOVE | COPY ]",
     curalrt[]="[0][ All records will be       | transferred in memory.     | | | ][ OK ]",
    delralrt[]="[0][ Are you sure you want to  | delete 12345678.123?       | | | ][ YES | NO ]",
     limalrt[]="[0][ All fields must be from   | 1-40 in length.            | | | ][ OK ]",
      apalrt[]="[0][ Do you want to WRITE or   | APPEND to this file?       | | | ][ WRITE | APPEND ]",
    diskalrt[]="[0][ Please select the file to | print to.                  | | | ][ OK ]",
   sdatealrt[]="[0][ The starting date must be | equal to or greater than   | the ending date.         | | ][ OK ]",
    linealrt[]="[0][ The line counter is now   | set to zero.  We are now at| the top of the page.     | | ][ OK ]",
 onedescalrt[]="[3][ The event description can | only be reported in one    | column.                  | | ][ OK ]",
     resalrt[]="[3][ Please change to medium   | resolution to use The      | Schedule Maker.          | | ][ OK ]",
     wdwalrt[]="[3][ Can't open another window.| Please close a window      | before doing this.       | | ][ OK ]",
 freememalrt[]="[3][ There is not enough free  | memory available to use The| Schedule Maker.          | | ][ OK ]",
    crecalrt[]="[0][ RECORDS have been changed.| Do you want to save the    | changes?                 | | ][ YES | NO |SAVE AS]",
    crptalrt[]="[0][ REPORTS have been changed.| Do you want to save the    | changes?                 | | ][ YES | NO |SAVE AS]",
     tikalrt[]="[0][ AUTO TICKLERS have been   | changed.  Do you want to   | save the changes?        | | ][ YES | NO |SAVE AS]",
     macalrt[]="[0][ MACROS have been changed. | Do you want to save the    | changes?                 | | ][ YES | NO |SAVE AS]",
     codalrt[]="[0][ PRINTER CODES have been   | changed.  Do you want to   | save the changes?        | | ][ YES | NO |SAVE AS]",
    ddayalrt[]="[0][ Are you sure you want to  | delete this day's reported | events?                  | | ][ YES | NO ]",
   standalrt[]="[0][ Are you sure you want to  | replace the standard       | report file?             | | ][ YES | NO ]",
   addonalrt[]="[0][ Do you want to start a    | NEW report or ADD ON to    | the last report?         | | ][ NEW | ADD ON ]",
   samedalrt[]="[0][ Do you to APPEND to the   | last file or select a      | NEW FILE?                | | ][ APPEND | NEW FILE ]",
    tranalrt[]="[0][ Please select or enter the| destination file for the   | records.                 | | ][ OK ]",
      r1alrt[]="[0][ First, locate and select  | the file to be renamed by  | using the item selector. | | ][ OK | CANCEL ]",
      r2alrt[]="[0][ Next, locate the directory| and enter the new name of  | the file.                | | ][ OK | CANCEL ]",
      r3alrt[]="[3][ Destination file already  | exists.                    |                          | | ][ OK ]",
      r5alrt[]="[3][ The new file must be on   | the same drive as the old  | file.                    | | ][ OK ]",
    copyalrt[]="[0][       Field copied.       |                            |      Use F2 to paste.    | | ][ OK ]",
     rnfalrt[]="[3][ Can't load reports file.  | No reports will be         | available.               | | ][ OK ]",
    rsrcalrt[]="[3][ Can't load the resource   | file or there is not enough| free memory available.   | | ][ OK ]",
  toevntalrt[]="[0][  SHORT-> days             | MEDIUM-> days,hh:mm        |   LONG-> days hrs mins   | | ][ SHORT | MED | LONG ]",
     setalrt[]="[0][ Records have been changed | and/or added.  Save or     | abandon the new records  | before setting fields.   | ][ OK ]",
     rptalrt[]="[0][ This report has too many  | columns.  The maximum      | amount of columns in a   | report is 255.           | ][ OK ]",
     fldalrt[]="[1][ Changes made to fields    | will affect records in     | memory and on disk unless| you cancel the changes.  | ][ OK | CANCEL ]",
   dfullalrt[]="[1][    THIS DISK IS FULL!     |                            | Please use another disk  | with more room.          | ][ OK ]",
    impfalrt[]="[0][ This is a very important  | file needed by The Schedule| Maker.  You can't delete | this file.               | ][ OK ]",
    pausalrt[]="[0][ Please insert a new sheet | after printing stops.      | Select OK when ready to  | continue printing.       | ][ OK ]",
  nodiskalrt[]="[1][ Can't load preference     | files from this drive.     | Load your files manually,| then resave preferences. | ][ OK ]",
  newfldalrt[]="[0][ Is the field 123456789112 | a NEW field or are you just| CHANGING the field's     | label?                   | ][ NEW | CHANGING ]";

main()
{
   int  term_type,which;

   term_type=init();

   if(term_type>0)
      quit(term_type);
   else
   {
      for(;;)
      {
         which=evnt_multi(MU_MESAG|MU_BUTTON|MU_KEYBD|MU_TIMER,1,0x01,1,0,
                          0,0,0,0,0,0,0,0,0,mgbuf,
                          2000,0,&mx,&my,&mb,&ks,&kr,&br);

         if(which & MU_TIMER)
         {
            strcpy(old_time,sys_time);
            strcpy(old_sys_date,sys_date);

            get_sys_date(FALSE);

            if((prefs.optime_display && strcmp(old_time,sys_time)!=0) ||
               (prefs.optime_display && prefs.opdate_display) ||
               (prefs.opdate_display && strcmp(old_sys_date,sys_date)!=0))
            time_display();

            if(strcmp(old_time,sys_time)!=0)
               time_rpts_update();

            if(strcmp(old_sys_date,sys_date)!=0)
               day_rpts_update();
         }

         if(which & MU_MESAG)
         {
            if(mgbuf[0]==MN_SELECTED)
            {
               if(menu(mgbuf[3],mgbuf[4])==FQUIT)
                  break;
            }
            else
               hndl_msg();
         }
      
         if(which & MU_BUTTON)
            hndl_button(mx,my);

         if(which & MU_KEYBD)
            hndl_keyboard(kr);
      }
      quit(0);
   }
}

init()
{
   OBJECT *tree;
   int  i;
   char **tedptr,*malloc();

   if(appl_init()==ERROR)
      return(4);

   wind_update(1);

   rez=Getrez();

   if(!rsrc_load("SCHEDULE.RSC"))
   {
      wind_update(0);
      form_alert(1,rsrcalrt);
      return(3);
   }

   if(Malloc(-1L)<32000L)
   {
      wind_update(0);
      form_alert(1,freememalrt);
      return(5);
   }

   handle=graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox);
   vdi_handle=handle;
   v_opnvwk(work_in,&vdi_handle,work_out);
   if(vdi_handle==0)
   {
      wind_update(0);
      return(2);
   }

   if(rez==0)
   {
      wind_update(0);
      form_alert(1,resalrt);
      return(1);
   }
   else
   {
      for(i=0; i<16; i++)
         gem_pallete[i]=Setcolor(i,-1);
      Setpallete(tsm_pallete);
   }

   ct_buff=(char *)malloc(256);

   sort_flag=FALSE;

   rsrc_gaddr(0,TMACROS,&tree);
   clear_form(tree);

   rsrc_gaddr(0,TCUSTOM,&tree);
   clear_form(tree);

   rsrc_gaddr(0,TAUTTICK,&tree);
   clear_form(tree);

   rsrc_gaddr(0,TPRTCODE,&tree);
   clear_form(tree);

   rsrc_gaddr(0,TPRTREPT,&tree);
   save_ob_xy(tree,TPRTREPT);

   rsrc_gaddr(0,TEDITREC,&tree);
   save_ob_xy(tree,TEDITREC);

   rsrc_gaddr(0,TMENU,&menu_tree);
   rsrc_gaddr(0,TCALINFO,&citree);

   rsrc_gaddr(0,TOTHERPF,&tree);
   tedptr=(char *)tree[OPEXTENS].ob_spec;
   strcpy(prefs.opdisk_extension,*tedptr);

   set_defaults();

   init_special_forms();

   HIDE_MOUSE;
   menu_bar(menu_tree,1);
   SHOW_MOUSE;

   graf_mouse(ARROW,&dummy);

   get_sys_date(TRUE);

   time_display();

   load_prefs();

   sel_windex=(-1);

   wind_update(0);

   return(0);
}

set_defaults()
{
   int  i;

   for(i=0; i<NUM_WINDS; i++)
   {
      window[i].wopen=FALSE;
      window[i].whandle=(-1);
      window[i].whidden=FALSE;
      window[i].wcontents=(-1);
      window[i].wlines=0;
      window[i].wcolumns=0;
      window[i].wshown=0;
      window[i].wxindex=0;
      window[i].wyindex=0;
   }

   for(i=0; i<NUM_REPORTS; i++)
   {
      strcpy(report[i].cname,"\0");
      report[i].cavailable=FALSE;
      report[i].cstyle=COLUMN;
      report[i].cspacing[0]=2;
      report[i].cspacing[1]=2;
      report[i].ctot_clms[0]=0;
      report[i].ctot_clms[1]=0;
      report[i].cmin_spacing_per_day=1;
   }

   prev_data.dcentury=data_entry.dcentury=FALSE;
   prev_data.dyear=data_entry.dyear=TRUE;
   prev_data.dtickler=data_entry.dtickler=TRUE;
   prev_data.dstime=data_entry.dstime=TRUE;
   prev_data.detime=data_entry.detime=FALSE;
   prev_data.dsubj=data_entry.dsubj=TRUE;
   prev_data.dlen_subj=data_entry.dlen_subj=15;
   prev_data.ddescr_lines=data_entry.ddescr_lines=2;
   for(i=0; i<4; i++)
   {
      prev_data.dlen_descr[i]=data_entry.dlen_descr[i]=40;
   }
   prev_data.dxfields=data_entry.dxfields=0;
   for(i=0; i<NUM_XFIELDS; i++)
   {
      strcpy(data_entry.dxflabel[i],"\0");
      data_entry.dxfchrs[i]=0;
   }

   prefs.opbackup=TRUE;
   prefs.optime_display=TRUE;
   prefs.opdate_display=TRUE;

   page_setup.plmarg=1;
   page_setup.prmarg=80;
   page_setup.ptmarg=1;
   page_setup.pbmarg=55;
   page_setup.ppage_size=66;
   page_setup.pcopies=1;
   page_setup.ptype_sheet=CONTINUOUS;
   page_setup.pnumber_page=FALSE;
   page_setup.pheader=FALSE;
   page_setup.pfile_stamp=FALSE;
   page_setup.pdate_stamp=FALSE;
   page_setup.ptime_stamp=FALSE;
   page_setup.peject_page=TRUE;
   page_setup.pstyle=PICA;
   page_setup.pmode=DRAFT;
   page_setup.pnew_report=TRUE;

   cust_forms(FALSE);
}

init_special_forms()
{
   OBJECT *tree;
   char **tedptr;

   rsrc_gaddr(0,TPAGESET,&tree);

   tedptr=(char *)tree[PSCOPIES].ob_spec;
   itoa(page_setup.pcopies,*tedptr);

   tedptr=(char *)tree[PSLEFTM].ob_spec;
   itoa(page_setup.plmarg,*tedptr);

   tedptr=(char *)tree[PSRIGHTM].ob_spec;
   itoa(page_setup.prmarg,*tedptr);

   tedptr=(char *)tree[PSTOPM].ob_spec;
   itoa(page_setup.ptmarg,*tedptr);

   tedptr=(char *)tree[PSBOTM].ob_spec;
   itoa(page_setup.pbmarg,*tedptr);

   tedptr=(char *)tree[PSPGSIZE].ob_spec;
   itoa(page_setup.ppage_size,*tedptr);

   if(page_setup.pstyle==NLQ)
      reset_rbuttons(tree,PSSNLQ,FALSE);
   else if(page_setup.pstyle==PICA)
      reset_rbuttons(tree,PSSPICA,FALSE);
   else if(page_setup.pstyle==ELITE)
      reset_rbuttons(tree,PSSELITE,FALSE);
   else if(page_setup.pstyle==CONDENSED)
      reset_rbuttons(tree,PSSCOND,FALSE);

   if(page_setup.pmode==DRAFT)
      reset_rbuttons(tree,PSMDRAFT,FALSE);
   else if(page_setup.pmode==BOLD)
      reset_rbuttons(tree,PSMBOLD,FALSE);
   else if(page_setup.pmode==DOUBLE)
      reset_rbuttons(tree,PSMDOUBL,FALSE);
   else if(page_setup.pmode==EXPANDED)
      reset_rbuttons(tree,PSMEXPAN,FALSE);

   if(page_setup.peject_page==TRUE)
      set_state(tree,PSEJECT,SELECTED);
   else
      del_state(tree,PSEJECT,SELECTED);

   if(page_setup.pdate_stamp==TRUE)
      set_state(tree,PSPDATE,SELECTED);
   else
      del_state(tree,PSPDATE,SELECTED);

   if(page_setup.ptime_stamp==TRUE)
      set_state(tree,PSPTIME,SELECTED);
   else
      del_state(tree,PSPTIME,SELECTED);

   if(page_setup.pfile_stamp==TRUE)
      set_state(tree,PSPFILE,SELECTED);
   else
      del_state(tree,PSPFILE,SELECTED);

   if(page_setup.pnumber_page)
      set_state(tree,PSPGNUM,SELECTED);
   else
      del_state(tree,PSPGNUM,SELECTED);

   if(page_setup.pheader)
      set_state(tree,PSPHEAD,SELECTED);
   else
      del_state(tree,PSPHEAD,SELECTED);

   if(page_setup.ptype_sheet==SINGLE)
      reset_rbuttons(tree,PSSINGLE,FALSE);
   else
      reset_rbuttons(tree,PSCONTIN,FALSE);
}

quit(term_type)
int  term_type;
{
   int  i;

   switch(term_type)
   {
      case 5: /* not enough free memory for records */
              rsrc_free();
              appl_exit();
              break;

      case 0: /* normal termination */
              for(i=0; i<NUM_WINDS; i++)
              {
                 if(window[i].wopen==TRUE)
                 {
                    wind_close(window[i].whandle);
                    wind_delete(window[i].whandle);
                    clr_window(window[i].whandle);
                 }
              }

              upd_records();
              upd_rpts();
              upd_prefs();

              free(ct_buff);

              rsrc_free();

              Setpallete(gem_pallete);

      case 1: /* ran in low resolution */

      case 2: /* couldn't open device */
              v_clsvwk(vdi_handle);

      case 3: /* couldn't load resource */
              appl_exit();

      case 4: /* couldn't appl_init() */
              break;
   }
}



