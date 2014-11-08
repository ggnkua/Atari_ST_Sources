#include "firecall.h"
/********************************************************************/
/* check: Checks what happens                                       */
/********************************************************************/
void check(void)
{
  int exit=FALSE;
  RESULT svar;
  do
  {
    svar=form_dialog();
    switch(svar.type)
    {
      case MENU_CLICKED:
        exit=!handle_menu(svar);
        break;
      case DIALOG_CLICKED:
      case WINDOW_CLICKED:
        exit=!handle_window(svar);
        break;
      case KEY_CLICKED:
        exit=!handle_key(svar);
        break;
      case BUTTON_CLICKED:
        exit=!handle_button(svar);
        break;
      case TIMER_EXIT:
        check_port();
        break;
      default:
        switch(svar.data[0])
        {
          char temp[MAXSTRING];
          case 0x400:                        /* ACC_ID           */
          case 0x4700:                       /* AV_PROTOKOLL     */
          case 0x4724:                       /* VA_ACCWINDOPEN   */
          case 0x4726:                       /* AV_ACCWINDCLOSED */
            break;
          default:
            sprintf(temp,"[1][ Message %#lx|From %d|%d,%d,%d,%d,%d][ NEXT ]",svar.data[0],svar.data[1],
              (unsigned short)svar.data[3],(unsigned short)svar.data[4],(unsigned short)svar.data[5],(unsigned short)svar.data[6],(unsigned short)svar.data[7]);
            alertbox(1,temp);
            break;
        }
    }
  }while(!exit);
}

/********************************************************************/
/* Handling the Clicks of the button on the mouse                   */
/********************************************************************/
int handle_button(RESULT svar)
{
  return(TRUE);
}

/********************************************************************/
/* Handling of the Keyboard                                         */
/********************************************************************/
int handle_key(RESULT svar)
{
  return(TRUE);
}

/********************************************************************/
/* Handling of the Menu-row                                         */
/********************************************************************/
int handle_menu(RESULT svar)
{
  
  if(svar.data[SVAR_OBJECT_MENU_ROW]!=FAIL)
    objc_change(menu_tree,svar.data[SVAR_OBJECT_MENU_ROW],0,0,0,0,0,0,O_REDRAW);

  switch(svar.data[SVAR_OBJECT])
  {
    case MENU_INFO:
      menu_icheck(menu_tree,MENU_INFO,TRUE);
      menu_ienable(menu_tree,MENU_INFO,FALSE);
      open_dialog(&info_win,NULL);
      break;
    case MENU_FILE_DISABL:
      deinit_port();
      break;
    case MENU_FILE_ENABLE:
      config->disabled=FALSE;
      init_port();
      break;
    case MENU_LIST_OWIND:
      open_listwin();
      break;
    case MENU_LIST_SAVE:
      if(!tempvar.accessory)
      {
        save_list();
        tempvar.list_change=FALSE;
      }
      break;
    case MENU_LIST_EXPORT:
      menu_icheck(menu_tree,MENU_LIST_EXPORT,TRUE);
      menu_ienable(menu_tree,MENU_LIST_EXPORT,FALSE);
      open_exportwin(TRUE);
    case MENU_SAVE_SETUP:
      save_datafile(TRUE,CONFIGFILE,(char *)config,sizeof(CONFIG));
      tempvar.conf_change=FALSE;
      break;
    case MENU_SETUP:
      menu_icheck(menu_tree,MENU_SETUP,TRUE);
      menu_ienable(menu_tree,MENU_SETUP,FALSE);
      set_timer(FAIL);
      open_setupwin();
      break;
    case MENU_LOG_VIEW:
      open_logwin();
      break;
    case MENU_QUIT:
      if(config->save_exit)
      {
        save_datafile(TRUE,CONFIGFILE,(char *)config,sizeof(CONFIG));
        if(!tempvar.accessory)
        {
          save_list();
          tempvar.list_change=FALSE;
        }
        tempvar.conf_change=FALSE;
      }
      if(tempvar.conf_change)
        if(alertbox(1,alerts[Q_SAVE_CONF_EXIT])==1)
          save_datafile(TRUE,CONFIGFILE,(char *)config,sizeof(CONFIG));
      if((tempvar.list_change)&&(!tempvar.accessory))
        if(alertbox(1,alerts[Q_SAVE_LIST_EXIT])==1)
          save_list();
      return(FALSE);
      break;
    case MENU_HELP_INDEX:
    {
      long stguide_id;
      char temprow[MAXSTRING];
      stguide_id=appl_find("ST-GUIDE");
      strcpy(temprow,"*:\\firecall.hyp");
      if(stguide_id!=FAIL)
      {
        svar.data[0]=(short)0x4711;
        svar.data[1]=(short)ap_id;
        svar.data[2]=(short)0;
        svar.data[3]=(short)temprow >> 16;
        svar.data[4]=(short)temprow & 0xffff;
        svar.data[5]=(short)0;
        svar.data[6]=(short)0;
        svar.data[7]=(short)0;
        appl_write(stguide_id,16,svar.data);
      }
      break;
    }  
    default:
      break;
  }
  return(TRUE);
}

/********************************************************************/
/* Handling of the Windows                                          */
/********************************************************************/
int handle_window(RESULT svar)
{
  if(svar.data[SVAR_WINDOW_ID]==info_win.ident)
    check_infowin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==register_win.ident)
    check_registerwin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==popup_win.ident)
    check_popupwin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==setup_win.ident)
    check_setupwin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==list_win.ident)
    check_listwin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==log_win.ident)
    check_logwin(svar);
  else if(svar.data[SVAR_WINDOW_ID]==export_win.ident)
    check_exportwin(svar);
  else
    printf("None of my windows, which is strange\n");
  return(TRUE);
}