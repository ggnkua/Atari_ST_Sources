#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_user_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_user_win(void)\n");
Log(LOG_INIT,"User Window Init\n");
#endif
  rsrc_gaddr(R_TREE,USER,&user_win.dialog);
  strncpy(user_win.w_name,alerts[WN_PATH],MAXWINSTRING);
  user_win.attr=NAME|MOVE|CLOSE|SMALLER;
  user_win.icondata=&icons[ICON_FIRESTORM];
  user_win.i_x=100;
  user_win.i_y=100;
  user_win.status=WINDOW_CLOSED;
  user_win.type=TYPE_DIALOG;
  form_center(user_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);
    
  Return;
}
/********************************************************************/
/* ™ppnar Path f”nstret                                             */
/********************************************************************/
void open_user_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"open_user_win(void)\n");
#endif
  
  str2ted(user_win.dialog,USER_REALNAME,config.real_name);
  str2ted(user_win.dialog,USER_EMAIL,config.email);
  str2ted(user_win.dialog,USER_REPLYTO,config.replyto);
  str2ted(user_win.dialog,USER_ORGANIZ,config.organization);
  str2ted(user_win.dialog,USER_PAGE,config.homepage);
  str2ted(user_win.dialog,USER_REPLYSTR1,config.replystring1);
  str2ted(user_win.dialog,USER_REPLYSTR2,config.replystring2);
  open_nonmodal(&user_win,NULL);

  Return;
}

/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_user_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_user_win(...)\n");
#endif

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&user_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case USER_OK:
        ted2str(user_win.dialog,USER_EMAIL,config.email);
        ted2str(user_win.dialog,USER_REALNAME,config.real_name);
        ted2str(user_win.dialog,USER_REPLYTO,config.replyto);
        ted2str(user_win.dialog,USER_ORGANIZ,config.organization);
        ted2str(user_win.dialog,USER_PAGE,config.homepage);
        ted2str(user_win.dialog,USER_REPLYSTR1,config.replystring1);
        ted2str(user_win.dialog,USER_REPLYSTR2,config.replystring2);
        button(&user_win, USER_OK, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&user_win);
        break;
      case USER_CANCEL:
        button(&user_win, USER_CANCEL, CLEAR_STATE, SELECTED,FALSE);
        close_dialog(&user_win);
        break;
      default:;
    }
  }
  
  Return;
}