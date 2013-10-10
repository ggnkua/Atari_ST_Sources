#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_switch_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_switch_win(void)\n");
Log(LOG_INIT,"Switches window Init\n");
#endif
  rsrc_gaddr(R_TREE,SWITCHES,&switch_win.dialog);
  strncpy(switch_win.w_name,alerts[WN_SWITCH],MAXWINSTRING);
  switch_win.attr=NAME|MOVE|CLOSE;
  switch_win.icondata=&icons[ICON_FIRESTORM];
  switch_win.i_x=100;
  switch_win.i_y=100;
  switch_win.status=WINDOW_CLOSED;
  switch_win.type=TYPE_DIALOG;
  form_center(switch_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);
    
  Return;
}
/********************************************************************/
/* ™ppnar Switch f”nstret                                           */
/********************************************************************/
void open_switch_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"open_path_win(void)\n");
#endif

  if(config.unknown_aes)
    button(&switch_win,SWITCH_MSG_ALERT,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_MSG_ALERT,CLEAR_STATE,CROSSED,FALSE);
  if(config.save_exit)
    button(&switch_win,SWITCH_SAVE_EXIT,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_SAVE_EXIT,CLEAR_STATE,CROSSED,FALSE);
  if(config.save_window)
    button(&switch_win,SWITCH_SAVE_WIND,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_SAVE_WIND,CLEAR_STATE,CROSSED,FALSE);
  if(config.use_comment)
    button(&switch_win,SWITCH_USE_COMM,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_USE_COMM,CLEAR_STATE,CROSSED,FALSE);
  if(config.show_comment)
    button(&switch_win,SWITCH_SHOW_COMM,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_SHOW_COMM,CLEAR_STATE,CROSSED,FALSE);
  if(config.hide_header)
    button(&switch_win,SWITCH_HIDE_HEAD,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_HIDE_HEAD,CLEAR_STATE,CROSSED,FALSE);
  if(config.open_group)
    button(&switch_win,SWITCH_OPEN_GRP,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_OPEN_GRP,CLEAR_STATE,CROSSED,FALSE);
  if(config.open_msg)
    button(&switch_win,SWITCH_OPEN_MSG,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_OPEN_MSG,CLEAR_STATE,CROSSED,FALSE);
  if(config.fkey_va)
    button(&switch_win,SWITCH_FKEYS,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_FKEYS,CLEAR_STATE,CROSSED,FALSE);

#ifdef LOGGING
  if(strstr(log.what,LOG_FILEOP))
    button(&switch_win,SWITCH_LOG_F,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_F,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_MEMORY))
    button(&switch_win,SWITCH_LOG_M,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_M,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_WINDOW))
    button(&switch_win,SWITCH_LOG_W,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_W,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_ERROR))
    button(&switch_win,SWITCH_LOG_E,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_E,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_INIT))
    button(&switch_win,SWITCH_LOG_I,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_I,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_AESMESSAGE))
    button(&switch_win,SWITCH_LOG_A,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_A,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_DIALOG))
    button(&switch_win,SWITCH_LOG_D,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_D,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_FUNCTION))
    button(&switch_win,SWITCH_LOG_P,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_P,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_FUNCTION2))
    button(&switch_win,SWITCH_LOG_V,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_V,CLEAR_STATE,SELECTED,FALSE);
  if(strstr(log.what,LOG_TEMPORARY))
    button(&switch_win,SWITCH_LOG_T,SET_STATE,SELECTED,FALSE);
  else
    button(&switch_win,SWITCH_LOG_T,CLEAR_STATE,SELECTED,FALSE);
  if(log.on)
    button(&switch_win,SWITCH_LOG,SET_STATE,CROSSED,FALSE);
  else
    button(&switch_win,SWITCH_LOG,CLEAR_STATE,CROSSED,FALSE);
#else
    button(&switch_win,SWITCH_LOG_F,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_M,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_W,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_E,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_I,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_A,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_D,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_P,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_V,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG_T,SET_FLAG,HIDETREE,FALSE);
    button(&switch_win,SWITCH_LOG,CLEAR_STATE,CROSSED,FALSE);
  
#endif
  open_nonmodal(&switch_win,NULL);

  Return;
}

/********************************************************************/
/********************************************************************/
void check_switch_win(const RESULT svar)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"check_switch_win(...)\n");
#endif

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&switch_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case SWITCH_OK:
      {
        if (switch_win.dialog[SWITCH_HIDE_HEAD].ob_state&CROSSED)
        {
          if(!config.hide_header)
          {
            config.hide_header=TRUE;
            read_win.text->textstart=active.body_text;
            read_win.text->offset_y=read_win.text->offset_x=NOLL;
            button(&read_win, MSGTOP_HEADER, SET_STATE, SELECTED,FALSE);
            open_dialog(&read_win,tempconf.readw_xy);
          }
          config.hide_header=TRUE;
        }
        else
        {
          if(config.hide_header)
          {
            config.hide_header=FALSE;
            read_win.text->textstart=active.msg_text;
            read_win.text->offset_y=read_win.text->offset_x=NOLL;
            button(&read_win, MSGTOP_HEADER, CLEAR_STATE, SELECTED,FALSE);
            open_dialog(&read_win,tempconf.readw_xy);
          }
          config.hide_header=FALSE;
        }
        if (switch_win.dialog[SWITCH_OPEN_GRP].ob_state&CROSSED)
          config.open_group=TRUE;
        else
          config.open_group=FALSE;
        if (switch_win.dialog[SWITCH_OPEN_MSG].ob_state&CROSSED)
          config.open_msg=TRUE;
        else
          config.open_msg=FALSE;
        if (switch_win.dialog[SWITCH_SAVE_EXIT].ob_state&CROSSED)
          config.save_exit=TRUE;
        else
          config.save_exit=FALSE;
        if (switch_win.dialog[SWITCH_SAVE_WIND].ob_state&CROSSED)
          config.save_window=TRUE;
        else
          config.save_window=FALSE;
        if (switch_win.dialog[SWITCH_FKEYS].ob_state&CROSSED)
          config.fkey_va=TRUE;
        else
          config.fkey_va=FALSE;
        if (switch_win.dialog[SWITCH_MSG_ALERT].ob_state&CROSSED)
          config.unknown_aes=TRUE;
        else
          config.unknown_aes=FALSE;
        if (switch_win.dialog[SWITCH_SHOW_COMM].ob_state&CROSSED)
          config.show_comment=TRUE;
        else
          config.show_comment=FALSE;

#ifdef LOGGING		
        strcpy(log.what,"");
        if(switch_win.dialog[SWITCH_LOG_F].ob_state&SELECTED)
          strcat(log.what,LOG_FILEOP);
        if(switch_win.dialog[SWITCH_LOG_M].ob_state&SELECTED)
          strcat(log.what,LOG_MEMORY);
        if(switch_win.dialog[SWITCH_LOG_W].ob_state&SELECTED)
          strcat(log.what,LOG_WINDOW);
        if(switch_win.dialog[SWITCH_LOG_E].ob_state&SELECTED)
          strcat(log.what,LOG_ERROR);
        if(switch_win.dialog[SWITCH_LOG_I].ob_state&SELECTED)
          strcat(log.what,LOG_INIT);
        if(switch_win.dialog[SWITCH_LOG_A].ob_state&SELECTED)
          strcat(log.what,LOG_AESMESSAGE);
        if(switch_win.dialog[SWITCH_LOG_D].ob_state&SELECTED)
          strcat(log.what,LOG_DIALOG);
        if(switch_win.dialog[SWITCH_LOG_P].ob_state&SELECTED)
          strcat(log.what,LOG_FUNCTION);
        if(switch_win.dialog[SWITCH_LOG_V].ob_state&SELECTED)
          strcat(log.what,LOG_FUNCTION2);
        if(switch_win.dialog[SWITCH_LOG_T].ob_state&SELECTED)
          strcat(log.what,LOG_TEMPORARY);
        if (switch_win.dialog[SWITCH_LOG].ob_state&CROSSED)
          log.on=TRUE;
        else
          log.on=FALSE;
#endif          

        button(&switch_win,SWITCH_OK,CLEAR_STATE,SELECTED,TRUE);
        close_dialog(&switch_win);
        break;
      }
      case SWITCH_CANCEL:
      {
        button(&switch_win,SWITCH_CANCEL,CLEAR_STATE,SELECTED,TRUE);
        close_dialog(&switch_win);
        break;
      }
    }
  }
}