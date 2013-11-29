// L”rdag 13:00 Farmor
#include "firecall.h"
#include <dos.h>
#include <sersofst.h>
#include <mintbind.h>
/********************************************************************/
/* Initiering av Setup-f”nstret                                     */
/********************************************************************/
void init_setupwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,SETUP,&setup_win.dialog);
  strncpy(setup_win.w_name,alerts[WN_SETUP],MAXWINSTRING);
  setup_win.attr=NAME|MOVE|CLOSE;
  setup_win.icondata=NULL;
  setup_win.status=WINDOW_CLOSED;
  setup_win.type=TYPE_DIALOG;
  form_center(setup_win.dialog, &dummy, &dummy, &dummy, &dummy);
}
/********************************************************************/
/* ™ppnandet av Setup-F”nstret                                      */
/********************************************************************/
void open_setupwin()
{
  char text[ROWSIZE];
  long rspeed,speed,ospeed;
  
  str2ted(setup_win.dialog,SETUP_PORT_MESS,config->messwait);
  str2ted(setup_win.dialog,SETUP_PORT,config->port);
  str2ted(setup_win.dialog,SETUP_PORT_INIT,config->portinit);
  str2ted(setup_win.dialog,SETUP_DIAL,config->dialcommand);
  str2ted(setup_win.dialog,SETUP_GET_LINE,config->linecommand);
  sprintf(text,"%d",config->log_number);
  str2ted(setup_win.dialog,SETUP_LOG_NUMBER,text);

  if(config->save_exit)
    button(&setup_win,SETUP_SAVE_EXIT,SET_STATE,CROSSED,TRUE);
  else
    button(&setup_win,SETUP_SAVE_EXIT,CLEAR_STATE,CROSSED,TRUE);
  
  if(tempvar.portfile!=FAIL)
  {
    rspeed=-1;
    Fcntl(tempvar.portfile, (long)&rspeed, TIOCIBAUD);
    sprintf(text,"%d",rspeed);
    str2ted(setup_win.dialog,SETUP_SPEED,text);
    button(&setup_win,SETUP_SPEED,CLEAR_STATE,DISABLED,TRUE);
    speed=99999999;
    strcpy(tempvar.speedpop,alerts[T_SELECT_SPEED]);
    do
    {
      speed--;
      ospeed=speed;
      Fcntl(tempvar.portfile, (long)&speed, TIOCIBAUD);
      if(speed<ospeed)
        sprintf(tempvar.speedpop,"%s|%ld",tempvar.speedpop,speed);
    }while(speed<ospeed);
  }
  else
  {
    str2ted(setup_win.dialog,SETUP_SPEED,"");
    button(&setup_win,SETUP_SPEED,SET_STATE,DISABLED,TRUE);
  }
  open_dialog(&setup_win,NULL);

}
/********************************************************************/
/* Hantering av Setup-f”nstret                                      */
/********************************************************************/
void check_setupwin(RESULT svar)
{
  char text[MAXSTRING];
  long porttemp,rspeed,speed,ospeed;
  int counter,choice;

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&setup_win);
    menu_icheck(menu_tree,MENU_SETUP,FALSE);
    menu_ienable(menu_tree,MENU_SETUP,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case SETUP_PORT:
        strcpy(text,alerts[T_SELECT_PORT]);
        choice=FALSE;
        for(counter=NOLL;tempvar.port[counter]!=NULL;counter++)
        {
          strcat(text,"|");
          strcat(text,tempvar.port[counter]->name);
          if(!strcmp(tempvar.port[counter]->name,setup_win.dialog[SETUP_PORT].ob_spec))
            choice=counter;
        }
        choice=popup(text,choice,setup_win.dialog,SETUP_PORT,setup_win.dialog[SETUP_PORT].ob_spec);
        strcpy(text,"u:\\dev\\");
        strcat(text,tempvar.port[choice]->name);
        porttemp=Fopen(text,FO_RW);
        if(porttemp!=FAIL)
        {
          rspeed=-1;
          Fcntl(porttemp, (long)&rspeed, TIOCIBAUD);
          sprintf(text,"%d",rspeed);
          str2ted(setup_win.dialog,SETUP_SPEED,text);
          button(&setup_win,SETUP_SPEED,CLEAR_STATE,DISABLED,TRUE);
          speed=99999999;
          strcpy(tempvar.speedpop,alerts[T_SELECT_SPEED]);
          do
          {
            speed--;
            ospeed=speed;
            Fcntl(porttemp, (long)&speed, TIOCIBAUD);
            if(speed<ospeed)
              sprintf(tempvar.speedpop,"%s|%ld",tempvar.speedpop,speed);
          }while(speed<ospeed);
          Fclose(porttemp);
        }
        break;
      case SETUP_SPEED:
        choice=popup(tempvar.speedpop,choice,setup_win.dialog,SETUP_SPEED,setup_win.dialog[SETUP_SPEED].ob_spec);
        break;
      case SETUP_SAVE_EXIT:
        if(setup_win.dialog[SETUP_SAVE_EXIT].ob_state&CROSSED)
           button(&setup_win,SETUP_SAVE_EXIT,CLEAR_STATE,CROSSED,TRUE);
        else
           button(&setup_win,SETUP_SAVE_EXIT,SET_STATE,CROSSED,TRUE);
        break;
      case SETUP_OK:
        ted2str(setup_win.dialog,SETUP_PORT_MESS,config->messwait);
        ted2str(setup_win.dialog,SETUP_PORT,config->port);
        ted2str(setup_win.dialog,SETUP_PORT_INIT,config->portinit);
        ted2str(setup_win.dialog,SETUP_DIAL,config->dialcommand);
        ted2str(setup_win.dialog,SETUP_GET_LINE,config->linecommand);
        if(setup_win.dialog[SETUP_SAVE_EXIT].ob_state&CROSSED)
          config->save_exit=TRUE;
        else
          config->save_exit=FALSE;
        ted2str(setup_win.dialog,SETUP_SPEED,text);
        sscanf(text,"%d",&config->port_speed);
        ted2str(setup_win.dialog,SETUP_LOG_NUMBER,text);
        if(sscanf(text,"%d",&config->log_number)!=1)
          config->log_number=LOG_SIZE;

        tempvar.conf_change=TRUE;
        init_port();
        button(&setup_win,SETUP_OK,CLEAR_STATE,SELECTED,TRUE);
        close_dialog(&setup_win);
        menu_icheck(menu_tree,MENU_SETUP,FALSE);
        menu_ienable(menu_tree,MENU_SETUP,TRUE);
        break;
      case SETUP_CANCEL:
        button(&setup_win, SETUP_CANCEL, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&setup_win);
        menu_icheck(menu_tree,MENU_SETUP,FALSE);
        menu_ienable(menu_tree,MENU_SETUP,TRUE);
        break;
      default:
        break;
    }
}