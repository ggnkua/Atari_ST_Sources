#include "firenews.h"
/********************************************************************/
/********************************************************************/
void init_group_win(void)
{
#ifdef LOGGING
Log(LOG_FUNCTION,"init_group_win()\n");
Log(LOG_INIT,"Server Window Init\n");
#endif
  rsrc_gaddr(R_TREE,GROUP_INFO,&group_win.dialog);
  strncpy(group_win.w_name,alerts[WN_SERVER],MAXWINSTRING);
  group_win.attr=NAME|MOVE|CLOSE;
  group_win.icondata=&icons[ICON_FIRESTORM];
  group_win.i_x=100;
  group_win.i_y=100;
  group_win.status=WINDOW_CLOSED;
  group_win.type=TYPE_DIALOG;
  form_center(group_win.dialog, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter, (short *)&tempvar.tempcounter);
    
  Return;
}
/********************************************************************/
/* ™ppning av Informations f”nstret                                 */
/********************************************************************/
void open_group_win(int group_num)
{
  GROUPS *g;
  
  if(group_num!=FAIL)
    group_win.tag=group_num;
  else
    group_win.tag=active.group_num;
  
  g=get_entity(active.glist,group_win.tag);
  str2ted(group_win.dialog,GROUP_NAME,g->groupname);
  str2ted(group_win.dialog,GROUP_FILE_NAME,g->filename);
  sprintf(tempvar.tempstring,"%5d",g->max_day);
  str2ted(group_win.dialog,GROUP_MAX_DAYS,tempvar.tempstring);
  sprintf(tempvar.tempstring,"%5d",g->days);
  str2ted(group_win.dialog,GROUP_DAYS,tempvar.tempstring);
  if (g->f_header)
    button(&group_win,GROUP_HEAD_ONLY,SET_STATE,CROSSED,TRUE);
  else
    button(&group_win,GROUP_HEAD_ONLY,CLEAR_STATE,CROSSED,TRUE);
  if (g->f_ronly)
    button(&group_win,GROUP_READ_ONLY,SET_STATE,CROSSED,TRUE);
  else
    button(&group_win,GROUP_READ_ONLY,CLEAR_STATE,CROSSED,TRUE);
  str2ted(group_win.dialog,GROUP_DESC1,g->description);
  if (strlen(g->description)>30)
    str2ted(group_win.dialog,GROUP_DESC2,g->description+30);
  else 
    str2ted(group_win.dialog,GROUP_DESC2,"");
  str2ted(group_win.dialog,GROUP_MAILTO1,g->mailto);
  if (strlen(g->mailto)>30)
    str2ted(group_win.dialog,GROUP_MAILTO2,g->mailto+30);
  else
    str2ted(group_win.dialog,GROUP_MAILTO2,"");
  
  open_dialog(&group_win,NULL);


}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_group_win(const RESULT svar)
{
  GROUPS *g;
#ifdef LOGGING
Log(LOG_FUNCTION,"check_group_win()\n");
#endif

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&group_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case GROUP_OK:
        button(&group_win, GROUP_OK, CLEAR_STATE, SELECTED,TRUE);
        g=get_entity(active.glist,group_win.tag);
        ted2str(group_win.dialog,GROUP_NAME,g->groupname);
        ted2str(group_win.dialog,GROUP_FILE_NAME,g->filename);
        ted2str(group_win.dialog,GROUP_MAX_DAYS,tempvar.tempstring);
        sscanf(tempvar.tempstring,"%5d",&(g->max_day));
        ted2str(group_win.dialog,GROUP_DAYS,tempvar.tempstring);
        sscanf(tempvar.tempstring,"%5d",&(g->days));

        if(group_win.dialog[GROUP_HEAD_ONLY].ob_state&CROSSED)
          g->f_header=TRUE;
        else
          g->f_header=FALSE;
        if(group_win.dialog[GROUP_READ_ONLY].ob_state&CROSSED)
          g->f_ronly=TRUE;
        else
          g->f_ronly=FALSE;
        ted2str(group_win.dialog,GROUP_DESC1,g->description);
        ted2str(group_win.dialog,GROUP_DESC2,tempvar.tempstring);
        if (tempvar.tempstring[0])
          strcat(g->description,tempvar.tempstring);

        ted2str(group_win.dialog,GROUP_MAILTO1,g->mailto);
        ted2str(group_win.dialog,GROUP_MAILTO2,tempvar.tempstring);
        if (tempvar.tempstring[0])
          strcat(g->mailto,tempvar.tempstring);
        
        close_dialog(&group_win);
        break;
      case GROUP_CANCEL:
        button(&group_win, GROUP_CANCEL, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&group_win);
        break;
      default:;
    }
  }

  Return;
}