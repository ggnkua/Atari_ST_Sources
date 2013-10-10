#include "firetext.h"
/********************************************************************/
/********************************************************************/
void init_writewin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,WRITE,&write_win.dialog);
  strncpy(write_win.w_name,alerts[W_WRITE],MAXWINSTRING);
  write_win.attr=NAME|MOVE|CLOSE;
  write_win.icondata=NULL;
  write_win.status=WINDOW_CLOSED;
  form_center(write_win.dialog, &dummy, &dummy, &dummy, &dummy);

}
/********************************************************************/
/********************************************************************/
void open_writewin(int config)
{
  if(!config)
  {
    t_textconf.override_from=FALSE;
    t_textconf.override_to=FALSE;
    t_textconf.override_subj=FALSE;
    t_textconf.override_area=FALSE;
    strcpy(t_textconf.from,"");
    strcpy(t_textconf.f_adress,"");
    strcpy(t_textconf.to,"");
    strcpy(t_textconf.t_adress,"");
    strcpy(t_textconf.subj,"");
    strcpy(t_textconf.area,"");
    button(&write_win,WRITE_TIME_SETUP,SET_FLAGS,HIDETREE);
  }
  else
  {
    button(&write_win,WRITE_TIME_SETUP,CLEAR_FLAGS,HIDETREE);
  }
  str2ted(write_win.dialog,WRITE_FROM,t_textconf.from);
  str2ted(write_win.dialog,WRITE_F_ADRESS,t_textconf.f_adress);
  str2ted(write_win.dialog,WRITE_TO,t_textconf.to);
  str2ted(write_win.dialog,WRITE_T_ADRESS,t_textconf.f_adress);
  str2ted(write_win.dialog,WRITE_SUBJECT,t_textconf.subj);
  str2ted(write_win.dialog,WRITE_AREA,t_textconf.area);
  if(t_textconf.override_from)
    button(&write_win,WRITE_A_FROM,SET_STATE,SELECTED|CROSSED);
  else
    button(&write_win,WRITE_A_FROM,CLEAR_STATE,SELECTED|CROSSED);
  if(t_textconf.override_to)
    button(&write_win,WRITE_A_TO,SET_STATE,SELECTED|CROSSED);
  else
    button(&write_win,WRITE_A_TO,CLEAR_STATE,SELECTED|CROSSED);
  if(t_textconf.override_subj)
    button(&write_win,WRITE_A_SUBJECT,SET_STATE,SELECTED|CROSSED);
  else
    button(&write_win,WRITE_A_SUBJECT,CLEAR_STATE,SELECTED|CROSSED);
  if(t_textconf.override_subj)
    button(&write_win,WRITE_A_AREA,SET_STATE,SELECTED|CROSSED);
  else
    button(&write_win,WRITE_A_AREA,CLEAR_STATE,SELECTED|CROSSED);

  open_dialog(&write_win);
}
/********************************************************************/
/********************************************************************/
void check_writewin(RESULT svar)
{
  short dummy;
  char  temp[MAXSTRING];
  
  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&write_win);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[0])
    {
      case WRITE_CANCEL:
        close_dialog(&write_win);
        button(&write_win, WRITE_CANCEL, CLEAR_STATE, SELECTED);
        break;
      case WRITE_FILE:
        fsel_exinput(config->lastpath,config->lastfile,&dummy,"Open File");
        if(dummy)
        {
          strcpy(t_textconf.file,config->lastpath);
          strcpy(strrchr(t_textconf.file,'\\')+1,config->lastfile);
          str2ted(write_win.dialog,WRITE_FILE,t_textconf.file);
          button(&write_win,WRITE_FILE,CLEAR_STATE,SELECTED);
        }
        break;
      case WRITE_OK:
        ted2str(write_win.dialog,WRITE_FROM,t_textconf.from);
        ted2str(write_win.dialog,WRITE_F_ADRESS,t_textconf.f_adress);
        ted2str(write_win.dialog,WRITE_TO,t_textconf.to);
        ted2str(write_win.dialog,WRITE_T_ADRESS,t_textconf.t_adress);
        ted2str(write_win.dialog,WRITE_SUBJECT,t_textconf.subj);
        ted2str(write_win.dialog,WRITE_AREA,t_textconf.area);
        if(t_textconf.file[NOLL]!=NOLL)
          write_text(t_textconf.file);
        button(&write_win,WRITE_OK,CLEAR_STATE,SELECTED);
        close_dialog(&write_win);
        break;
      case WRITE_A_FROM:
          if(!t_textconf.override_from)
          {
            t_textconf.override_from=TRUE;
            button(&write_win,WRITE_A_FROM,SET_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_FROM,CLEAR_STATE,DISABLED);
            button(&write_win,WRITE_F_ADRESS,CLEAR_STATE,DISABLED);
          }
          else
          {
            t_textconf.override_from=FALSE;
            button(&write_win,WRITE_A_FROM,CLEAR_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_FROM,SET_STATE,DISABLED);
            button(&write_win,WRITE_F_ADRESS,SET_STATE,DISABLED);
          }
        break;
      case WRITE_A_TO:
          if(!t_textconf.override_to)
          {
            t_textconf.override_to=TRUE;
            button(&write_win,WRITE_A_TO,SET_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_TO,CLEAR_STATE,DISABLED);
            button(&write_win,WRITE_T_ADRESS,CLEAR_STATE,DISABLED);
          }
          else
          {
            t_textconf.override_to=FALSE;
            button(&write_win,WRITE_A_TO,CLEAR_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_TO,SET_STATE,DISABLED);
            button(&write_win,WRITE_T_ADRESS,SET_STATE,DISABLED);
          }
        break;
        case WRITE_A_SUBJECT:
          if(!t_textconf.override_subj)
          {
            t_textconf.override_subj=TRUE;
            button(&write_win,WRITE_A_SUBJECT,SET_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_SUBJECT,CLEAR_STATE,DISABLED);
          }
          else
          {
            t_textconf.override_subj=FALSE;
            button(&write_win,WRITE_A_SUBJECT,CLEAR_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_SUBJECT,SET_STATE,DISABLED);
          }
        break;
        case WRITE_A_AREA:
          if(!t_textconf.override_area)
          {
            t_textconf.override_area=TRUE;
            button(&write_win,WRITE_A_AREA,SET_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_AREA,CLEAR_STATE,DISABLED);
            if(t_textconf.area[0]==NOLL)
            {
              tempvar.sel_area=popup(arealist,tempvar.sel_area,write_win.dialog,WRITE_AREA,temp);
              strcpy(t_textconf.area,areasbbs[tempvar.sel_area].area);
              str2ted(write_win.dialog,WRITE_AREA,t_textconf.area);
            }
          }
          else
          {
            t_textconf.override_area=FALSE;
            button(&write_win,WRITE_A_AREA,CLEAR_STATE,SELECTED|CROSSED);
            button(&write_win,WRITE_AREA,SET_STATE,DISABLED);
          }
          break;
        case WRITE_AREA:
          tempvar.sel_area=popup(arealist,tempvar.sel_area,write_win.dialog,WRITE_AREA,temp);
           strcpy(t_textconf.area,areasbbs[tempvar.sel_area].area);
           str2ted(write_win.dialog,WRITE_AREA,t_textconf.area);
        break;

      default:;
    }
}