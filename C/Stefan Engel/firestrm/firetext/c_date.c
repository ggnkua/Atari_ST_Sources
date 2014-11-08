#include "firetext.h"
/********************************************************************/
/* Initiate auto-date-config window                                 */
/********************************************************************/
void init_autolistwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,AUTO_DATE,&autolist_win.dialog);
  strncpy(autodate_win.w_name,alerts[W_AUTO_CONFIG],MAXWINSTRING);
  autodate_win.attr=NAME|MOVE|CLOSE;
  autodate_win.icondata=NULL;
  autodate_win.status=WINDOW_CLOSED;
  form_center(autodate_win.dialog, &dummy, &dummy, &dummy, &dummy);
  
}/********************************************************************/
/* Initiate auto-date-config window                                 */
/********************************************************************/
void init_autodatewin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,AUTO_DATE,&autodate_win.dialog);
  strncpy(autodate_win.w_name,alerts[W_AUTO_CONFIG],MAXWINSTRING);
  autodate_win.attr=NAME|MOVE|CLOSE;
  autodate_win.icondata=NULL;
  autodate_win.status=WINDOW_CLOSED;
  form_center(autodate_win.dialog, &dummy, &dummy, &dummy, &dummy);
  
}
/********************************************************************/
/* Procedur f”r att ”ppna dialogen "autodate"                       */
/********************************************************************/
void open_autodatewin(void)
{
  char temp[MAXSTRING];
//  popup(alerts[P_AUTO_DATE],NOLL,autodate_win.dialog,FAIL,temp);
//  str2ted(autodate_win.dialog,AUTO_DATE_COM,temp);
  button(&autodate_win, AUTO_DATE_MONTH, SET_FLAGS, HIDETREE);
  button(&autodate_win, AUTO_DATE_WDAYS, SET_FLAGS, HIDETREE);
  button(&autodate_win, AUTO_DATE_MDAYS, SET_FLAGS, HIDETREE);
  button(&autodate_win, AUTO_DATE_WEEKS, SET_FLAGS, HIDETREE);
  button(&autodate_win, AUTO_DATE_TIME1, SET_FLAGS, HIDETREE);
  button(&autodate_win, AUTO_DATE_TIME2, SET_FLAGS, HIDETREE);
  change_size();
  open_dialog(&autodate_win);
}

/********************************************************************/
/* Procedur f”r att kolla om ett datum st„mmer med "configen"       */
/********************************************************************/
void check_autodatewin(RESULT svar)
{
  char temp[MAXSTRING];
  int  selection;
  
  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&autodate_win);
    menu_icheck(menu_tree,MENU_CONF_AUTO,FALSE);
    menu_ienable(menu_tree,MENU_CONF_AUTO,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    
    switch(svar.data[0])
    {
      case AUTO_DATE_COM:
        tempvar.date_com=popup(alerts[P_AUTO_DATE],tempvar.date_com,autodate_win.dialog,AUTO_DATE_COM,temp);
        str2ted(autodate_win.dialog,AUTO_DATE_COM,temp);
        button(&autodate_win, AUTO_DATE_COM, CLEAR_STATE, SELECTED);
        button(&autodate_win, AUTO_DATE_MONTH, SET_FLAGS, HIDETREE);
        button(&autodate_win, AUTO_DATE_WDAYS, SET_FLAGS, HIDETREE);
        button(&autodate_win, AUTO_DATE_MDAYS, SET_FLAGS, HIDETREE);
        button(&autodate_win, AUTO_DATE_WEEKS, SET_FLAGS, HIDETREE);
        button(&autodate_win, AUTO_DATE_TIME1, SET_FLAGS, HIDETREE);
        button(&autodate_win, AUTO_DATE_TIME2, SET_FLAGS, HIDETREE);
        str2ted(autodate_win.dialog,AUTO_DATE_TIME1,"");
        str2ted(autodate_win.dialog,AUTO_DATE_TIME2,"");
        switch(tempvar.date_com)
        {
          case 0:
            autodate_win.dialog[AUTO_DATE_MONTH].ob_x=16;
            autodate_win.dialog[AUTO_DATE_MONTH].ob_y=32;
            button(&autodate_win, AUTO_DATE_MONTH, CLEAR_FLAGS, HIDETREE);
            change_size(&autodate_win);  
            break;
          case 1:
            autodate_win.dialog[AUTO_DATE_TIME1].ob_x=16;
            autodate_win.dialog[AUTO_DATE_TIME1].ob_y=32;
            strcpy(((TEDINFO *)autodate_win.dialog[AUTO_DATE_TIME1].ob_spec)->te_ptmplt,alerts[T_DATE_MONTH]);
            button(&autodate_win, AUTO_DATE_TIME1, CLEAR_FLAGS, HIDETREE);
            change_size(&autodate_win);  
            break;
          case 2:
            autodate_win.dialog[AUTO_DATE_TIME1].ob_x=16;
            autodate_win.dialog[AUTO_DATE_TIME1].ob_y=32;
            strcpy(((TEDINFO *)autodate_win.dialog[AUTO_DATE_TIME1].ob_spec)->te_ptmplt,alerts[T_DATE_DAY]);
            button(&autodate_win, AUTO_DATE_TIME1, CLEAR_FLAGS, HIDETREE);
            change_size(&autodate_win);  
            break;
          case 4:
            autodate_win.dialog[AUTO_DATE_WEEKS].ob_x=16;
            autodate_win.dialog[AUTO_DATE_WEEKS].ob_y=32;
            button(&autodate_win, AUTO_DATE_WEEKS, CLEAR_FLAGS, HIDETREE);
            change_size(&autodate_win);  
            break;
          default:
            break;
        }
        break;
      default:;
        break;
    }
}

