#include "firemail.h"
/********************************************************************/
/* check: Checks what happens                                       */
/********************************************************************/
void check(void)
{
  int exit=FALSE;
  RESULT svar;
  char temp[MAXSTRING];
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
        exit=TRUE;
        break;
      default:
        sprintf(temp,"[1][ Meddelande #%d][ OK ]",svar.type);
        alertbox(1,temp);
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
//  char text[255];
//  sprintf(text,"[1][data(0)=%x|data(1)=%d|data(2)=%d|data(3)=%d|window=%d][OK]",svar.data[0],svar.data[1],svar.data[2],svar.data[3],svar.window);
//  alertbox(1,text);
  return(TRUE);
}

/********************************************************************/
/* Handling of the Menu-row                                         */
/********************************************************************/
int handle_menu(RESULT svar)
{
  if(svar.data[3]!=FAIL)
    objc_change(menu_tree,svar.data[3],0,0,0,0,0,0,O_REDRAW);

  switch(svar.data[4])
  {
    case MENU_INFORMATION:
      menu_icheck(menu_tree,MENU_INFORMATION,TRUE);
      menu_ienable(menu_tree,MENU_INFORMATION,FALSE);
      open_dialog(&info_win);
      break;
    case MENU_FILE_QUIT:
      if(tempvar.conf_change)
        if(alertbox(1,alerts[Q_SAVE_CONF_EXIT])==1)
        {
          save_datafile(TRUE,CONFIGFILE,(char *)&config,sizeof(CONFIG));
          if(routedata1!=NULL)
            save_datafile(TRUE,AREAFILE,(char *)routedata1,tempvar.num_area1*sizeof(AREADATA));
          if(routedata2!=NULL)
            save_datafile(FALSE,AREAFILE,(char *)routedata2,tempvar.num_area2*sizeof(AREADATA));
        }
      return(FALSE);
      break;
    case MENU_PROC_IMPORT:
      import();
      break;
    case MENU_PROC_EXPORT:
//      export();
      break;
    case MENU_PROC_STAT:
//      statitics();
      break;
    case MENU_CONF_PATH:
      menu_icheck(menu_tree,MENU_CONF_PATH,TRUE);
      menu_ienable(menu_tree,MENU_CONF_PATH,FALSE);
      open_pathwin();
      break;
    case MENU_CONF_USERS:
      tempvar.add_user=FALSE;
      menu_icheck(menu_tree,MENU_CONF_USERS,TRUE);
      menu_ienable(menu_tree,MENU_CONF_USERS,FALSE);
      open_dialog(&user_win);
      break;
    case MENU_CONF_ROUTE:
      menu_icheck(menu_tree,MENU_CONF_ROUTE,TRUE);
      menu_ienable(menu_tree,MENU_CONF_ROUTE,FALSE);
      open_listroutewin();
      break;
    case MENU_CONF_MISC:
      break;
    case MENU_CONF_SAVE:
      save_datafile(TRUE,CONFIGFILE,(char *)&config,sizeof(CONFIG));
      if(routedata1!=NULL)
        save_datafile(TRUE,AREAFILE,(char *)routedata1,tempvar.num_area1*sizeof(AREADATA));
      if(routedata2!=NULL)
        save_datafile(FALSE,AREAFILE,(char *)routedata2,tempvar.num_area2*sizeof(AREADATA));
      tempvar.conf_change=FALSE;
      break;
    case MENU_HELP_INDEX:
      break;
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
  if(svar.data[3]==info_win.ident)
    check_infowin(svar);
  else if(svar.data[3]==user_win.ident)
    check_userwin(svar);
  else if(svar.data[3]==path_win.ident)
    check_pathwin(svar);
  else if(svar.data[3]==register_win.ident)
    check_registerwin(svar);
  else if(svar.data[3]==route_win.ident)
    check_routewin(svar);
  else if(svar.data[3]==listroute_win.ident)
    check_listroutewin(svar);
    
    return(TRUE);
}