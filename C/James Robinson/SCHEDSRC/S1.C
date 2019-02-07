/* S1.C -- MENU */

#include "obdefs.h"
#include "schdefs.h"
#include "schedule.h"

extern int  sel_windex;

extern long menu_tree;

extern WIND window[NUM_WINDS];

extern CUSTOM data_entry;

int 
menu(title,item)
int  title,item;
{
   switch(title)
   {
      case MDESK:    switch(item)
                     {
                        case ABOUT:    do_about();
                                       break;
                     }
                     break;
      case MFILE:    switch(item)
                     {
                        case FSAVE:    rec_save(FALSE);
                                       break;
                        case FSAVEAS:  rec_save(TRUE);
                                       break;
                        case FOPENF:   rec_load();
                                       break;
                        case FNEW:     new();
                                       break;
                        case FMERGE:   merge_file();
                                       break;
                        case FABANDON: abandon();
                                       break;
                        case FDELETE:  delete();
                                       break;
                        case FRENAME:  rename();
                                       break;
                        case FQUIT:    return(FQUIT);
                                       break;
                     }
                     break;
       case MCALEND: switch(item)
                     {
                        case CALOPEN:  cal_window();
                                       break;
                        case CALEDIT:  do_edit_report(TCALINFO,FALSE);
                                       break;
                     }
                     break;
      case MOPTIONS: switch(item)
                     {
                        case OCALCBD:  calc_between_dates();
                                       break;
                        case OCALCFD:  calc_from_date();
                                       break;
                        case OSYSDATE: date_enter();
                                       break;
                        case OSENDCOD: hide_windows();
                                       send_code();
                                       show_windows();
                                       break;
                        case OHELP:    do_help();
                                       break;
                     }
                     break;
      case MRECORDS: switch(item)
                     {
                        case RECNEW:   enter_records();
                                       break;
                        case RECEDIT:  modify_records(RECEDIT);
                                       break;
                        case RECDELET: modify_records(RECDELET);
                                       break;
                        case RECTRANS: modify_records(RECTRANS);
                                       break;
                        case RECPRINT: sel_print();
                                       break;
                        case RECCLEAR: evnt_timer(100,0);
                                       sel_clear(&window[sel_windex].work_area,TRUE);
                                       break;
                        case RECSETFL: cust_data_entry();
                                       break;
                        case RECINFO:  file_info();
                                       break;
                     }
                     break;
      case MPREFS:   switch(item)
                     {
                        case PAUTTICK: do_auto_ticklers();
                                       break;
                        case PMACROS:  macros();
                                       break;
                        case PPRINTER: do_codes();
                                       break;
                        case POTHER:   other_prefs();
                                       break;
                        case PSAVECFG: save_prefs();
                                       break;
                     }
                     break;
      case MREPORT:  switch(item)
                     {
                        case RPTCREAT: do_create_report();
                                       break;
                        case RPTEDIT:  do_edit_report(TPRTREPT,TRUE);
                                       break;
                        case RPTPRINT: modify_records(RPTPRINT);
                                       break;
                        case RPTLOAD:  rpt_load();
                                       break;
                        case RPTSAVE:  rpt_save();
                                       break;
                     }
                     break;
      case MWINDOWS: switch(item)
                     {
                        case WDWCLOSE: close_all_windows();
                                       break;
                        case WDWEDALL: edit_all_windows();
                                       break;
                        case WDWEDIT:  edit_top_window();
                                       break;
                        case WDWMARK:  mark_position();
                                       evnt_timer(100,0);
                                       break;
                        case WDWGOTO:  goto_mark();
                                       break;
                        case WDWLOAD:  wdw_load();
                                       break;
                        case WDWSAVE:  wdw_save();
                                       break;
                     }
                     break;
   }
   menu_tnormal(menu_tree,title,TRUE);
}

