#include "firemail.h"
/********************************************************************/
/********************************************************************/
void init_userwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,USERS,&user_win.dialog);
  strncpy(user_win.w_name,"User information",MAXWINSTRING);
  user_win.attr=NAME|MOVE|CLOSE;
  user_win.icondata=NULL;
  user_win.status=WINDOW_CLOSED;
  form_center(user_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
/********************************************************************/
/* Hantering av anv„ndar-installations-f”nstret                     */
/********************************************************************/
void check_userwin(RESULT svar)
{

  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&user_win);
    menu_icheck(menu_tree,MENU_CONF_USERS,FALSE);
    menu_ienable(menu_tree,MENU_CONF_USERS,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[0])
    {
      case USER_EXIT:
        close_dialog(&user_win);
        menu_icheck(menu_tree,MENU_CONF_USERS,FALSE);
        menu_ienable(menu_tree,MENU_CONF_USERS,TRUE);
        button(&user_win, USER_EXIT, CLEAR_STATE, SELECTED);
        break;
      case USER_ADD:
        if(!tempvar.add_user)
        {
          str2ted(user_win.dialog,USER_ADRESS,"");
          str2ted(user_win.dialog,USER_NAME,"");
          button(&user_win,USER_NEXT,SET_STATE,DISABLED);
          button(&user_win,USER_PREV,SET_STATE,DISABLED);
          button(&user_win,USER_LIST,SET_STATE,DISABLED);
          button(&user_win,USER_SWITCHES,SET_STATE,DISABLED);
          button(&user_win,USER_EXIT,SET_STATE,DISABLED);
          tempvar.add_user=TRUE;
          button(&user_win,USER_ADD,CLEAR_STATE,SELECTED);
        }
        else
        {
          button(&user_win,USER_NEXT,CLEAR_STATE,DISABLED);
          button(&user_win,USER_PREV,CLEAR_STATE,DISABLED);
          button(&user_win,USER_LIST,CLEAR_STATE,DISABLED);
          button(&user_win,USER_SWITCHES,CLEAR_STATE,DISABLED);
          button(&user_win,USER_EXIT,CLEAR_STATE,DISABLED);
          tempvar.add_user=FALSE;
          button(&user_win,USER_ADD,CLEAR_STATE,SELECTED);\
        }
        break;
      case USER_DELETE:
        if(tempvar.add_user)
        {
          button(&user_win,USER_NEXT,CLEAR_STATE,DISABLED);
          button(&user_win,USER_PREV,CLEAR_STATE,DISABLED);
          button(&user_win,USER_LIST,CLEAR_STATE,DISABLED);
          button(&user_win,USER_SWITCHES,CLEAR_STATE,DISABLED);
          button(&user_win,USER_EXIT,CLEAR_STATE,DISABLED);
          tempvar.add_user=FALSE;
          button(&user_win,USER_DELETE,CLEAR_STATE,SELECTED);
        }
        break;
      default:;
    }
}