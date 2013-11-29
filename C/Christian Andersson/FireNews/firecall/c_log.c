#include "firecall.h"
/********************************************************************/
/********************************************************************/
void init_logwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,LOG,&log_win.dialog);
  strncpy(log_win.w_name,alerts[WN_LOG],MAXWINSTRING);
  log_win.attr=NAME|MOVE|CLOSE;
  log_win.icondata=NULL;
  log_win.status=WINDOW_CLOSED;
  log_win.type=TYPE_DIALOG;
  form_center(log_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
/********************************************************************/
/********************************************************************/
void open_logwin()
{
  make_log();
  open_dialog(&log_win,NULL);
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_logwin(RESULT svar)
{
  char date[SIZE_TIME],time[SIZE_TIME],number[SIZE_NUMB],text[ROWSIZE],dummy[ROWSIZE];
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&log_win);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case LOG_0:
      case LOG_1:
      case LOG_2:
      case LOG_3:
      case LOG_4:
      case LOG_5:
      case LOG_6:
      case LOG_7:
      case LOG_8:
      case LOG_9:
        ted2str(log_win.dialog,svar.data[SVAR_OBJECT],text);
        sscanf(text,"%s %s %s %s",date,time,number,dummy);
        sprintf(text,"%s %s %s",date,time,number);
        tempvar.phonedata=NULL;
        if(!tempvar.edit_num)
          open_popupwin(PC_LOGFIND,text);
        break;
      case LOG_SLIDE_UP:
        tempvar.offset_log--;
        make_log();
        button(&log_win, LOG_SLIDE_UP, CLEAR_STATE, SELECTED,TRUE);
        break;
      case LOG_SLIDE_DRAG:
        tempvar.offset_log=log_win.dialog[LOG_SLIDE_DRAG].ob_y*tempvar.num_log/log_win.dialog[LOG_SLIDE_BACK].ob_height;
        make_log();
        break;
      case LOG_SLIDE_DOWN:
        tempvar.offset_log++;
        make_log();
        button(&log_win, LOG_SLIDE_DOWN, CLEAR_STATE, SELECTED,TRUE);
        break;
      default: 
        break;
    }
}
/********************************************************************/
/* Ut”kning av Nummer-logen                                         */
/********************************************************************/
int add_log(char *string)
{
  char text[ROWSIZE];
  char date[ROWSIZE];
  FILE *logfile;
  int counter;
  
  getdate(date);
  if(string!=NULL)
  {
    strcpy(text,date);
    strncat(text,SPACES,SIZE_TIME-strlen(date)+1);
    strcat(text,string);
    strncat(text,SPACES,SIZE_NUMB-strlen(string)+1);
    strcat(text,alerts[UNKNOWN_NUMBER]);
  }
  else
  {
    strcpy(text,tempvar.phonedata->date);
    strncat(text,SPACES,SIZE_TIME-strlen(tempvar.phonedata->date)+1);
    strcat(text,tempvar.phonedata->number);
    strncat(text,SPACES,SIZE_NUMB-strlen(tempvar.phonedata->number)+1);
    strcat(text,tempvar.phonedata->name);
  }
   
  strcat(text,"\n");
  strcpy(date,system_dir);
  strcat(date,LOGFILE);
  logfile=fopen(date,"a");
  if(logfile==NULL)
  {
    sprintf(date,alerts[E_OPEN_FILE],LOGFILE,"add_log");
    alertbox(1,date);
    return(FAIL);
  }
  fputs(text,logfile);
  fclose(logfile);
  text[strlen(text)-1]=0;
  if(tempvar.num_log<config->log_number)
  {
    strcpy(logtext+tempvar.num_log*LENGTH_LOG,text);
    tempvar.num_log++;
  }
  else
  {
    for(counter=1;counter<config->log_number;counter++)
      strcpy(logtext+(counter-1)*LENGTH_LOG,logtext+counter*LENGTH_LOG);
    strcpy(logtext+(tempvar.num_log-1)*LENGTH_LOG,text);
  }
  
  if(log_win.status==WINDOW_OPENED)
    open_logwin();
}

/********************************************************************/
/* Inladdning av nummer-loggen                                      */
/********************************************************************/
int load_log()
{
  char text[ROWSIZE];
  FILE *logfile;
  int counter=NOLL;
//  char *read_dta;
  
  strcpy(text,system_dir);
  strcat(text,LOGFILE);
  logfile=fopen(text,"r");
  if(logfile==NULL)
  {
    sprintf(text,alerts[E_OPEN_FILE],LOGFILE,"load_log");
    alertbox(1,text);
    return(FAIL);
  }
  while(fgets(text,LENGTH_LOG-1,logfile)!=NULL)
  {
    text[strlen(text)-1]=0;
    if(tempvar.num_log<config->log_number)
    {
      strcpy(logtext+tempvar.num_log*LENGTH_LOG,text);
      tempvar.num_log++;
    }
    else
    {
      for(counter=1;counter<config->log_number;counter++)
        strcpy(logtext+(counter-1)*LENGTH_LOG,logtext+counter*LENGTH_LOG);
      strcpy(logtext+(tempvar.num_log-1)*LENGTH_LOG,text);
    }
  }
  fclose(logfile);
}
/********************************************************************/
/********************************************************************/
void make_log()
{
  int counter;
  if(tempvar.offset_log+LOG_9-LOG_0>tempvar.num_log)
    tempvar.offset_log=NOLL;

  for(counter=0;(counter<tempvar.num_log)&&(counter<(LOG_9-LOG_0+1));counter++)
  {
    str2ted(log_win.dialog,LOG_0+counter,logtext+(counter+tempvar.offset_log)*LENGTH_LOG);
    button(&log_win,LOG_0+counter,CLEAR_STATE,SELECTED,FALSE);
    button(&log_win,LOG_0+counter,CLEAR_STATE,DISABLED,FALSE);
  }
  for(;counter<=LOG_9-LOG_0;counter++)
  {
    str2ted(log_win.dialog,LOG_0+counter,"");
    button(&log_win,LOG_0+counter,CLEAR_STATE,SELECTED,FALSE);
    button(&log_win,LOG_0+counter,SET_STATE,DISABLED,FALSE);
  }
  if(tempvar.num_log>LOG_9-LOG_0+1)
  {
    log_win.dialog[LOG_SLIDE_DRAG].ob_height=log_win.dialog[LOG_SLIDE_BACK].ob_height*(LOG_9-LOG_0+1)/(tempvar.num_log);
    log_win.dialog[LOG_SLIDE_DRAG].ob_y=log_win.dialog[LOG_SLIDE_BACK].ob_height*(tempvar.offset_log)/(tempvar.num_log);
    button(&log_win,LOG_SLIDE_DRAG,CLEAR_STATE,DISABLED,FALSE);
    button(&log_win,LOG_SLIDE_BACK,CLEAR_STATE,DISABLED,TRUE);
  }
  if(tempvar.offset_log!=NOLL)
    button(&log_win,LOG_SLIDE_UP,CLEAR_STATE,DISABLED,TRUE);
  else
    button(&log_win,LOG_SLIDE_UP,SET_STATE,DISABLED,TRUE);
  if((tempvar.num_log-tempvar.offset_log>LOG_9-LOG_0+1)||(tempvar.offset_log+LOG_9-LOG_0+1<tempvar.num_log))
    button(&log_win,LOG_SLIDE_DOWN,CLEAR_STATE,DISABLED,TRUE);
  else
    button(&log_win,LOG_SLIDE_DOWN,SET_STATE,DISABLED,TRUE);

  button(&log_win,LOG_BACKGROUND,UPDATE,DISABLED,TRUE);
}