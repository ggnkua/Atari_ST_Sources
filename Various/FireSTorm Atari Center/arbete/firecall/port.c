#include "firecall.h"
#include <mintbind.h>
#include <dos.h>
#include <cookie.h>
#include <sersofst.h>

typedef struct
{
  unsigned long ctlline,
                adrline;
} IR_DATA;

/********************************************************************/
/*                                                                  */
/********************************************************************/
void check_port()
{
  char tecken;
  int length;
 
  if(tempvar.portfile==FAIL)
    return;
  if((popup_win.status!=WINDOW_CLOSED)&&(config->popup_time!=NOLL)&&(tempvar.popup_close==TRUE)&&(tempvar.port_counter==FAIL))
  {
    tempvar.popup_counter++;
    if(tempvar.popup_counter>=config->popup_time)
    {
      tempvar.popup_counter=NOLL;
      tempvar.popup_close=FALSE;
      close_dialog(&popup_win);
    }
  }
  else if(Fread(tempvar.portfile,1,&tecken)==1)
  {
    tempvar.popup_close=FALSE;
    set_timer(NOLL);
    if(tecken=='\n')
    {
      tempvar.new_line=TRUE;
    }
    else if(tecken=='\r')
    {
    }
    else
    {
      length=strlen(tempvar.message);
      tempvar.message[length]=tecken;
      tempvar.message[length+1]=NOLL;
    }  
    tempvar.port_counter=NOLL;
  }
  else if(tempvar.port_counter!=FAIL)
  {
    tempvar.popup_close=FALSE;
    if(++tempvar.port_counter>PORT_NUMS)
    {
      set_timer(PORT_TIME);
      tempvar.port_counter=FAIL;
      tempvar.popup_counter=NOLL;
      tempvar.message[NOLL]=NOLL;
    }
  }
  if(tempvar.new_line)
  {
    if(!strncmp(tempvar.message,config->messwait,strlen(config->messwait)))
    {
      length=strlen(tempvar.message);
      while(!isdigit(tempvar.message[length]))
        tempvar.message[length--]=NOLL;
      
      tempvar.phonedata=NULL;
      if(!tempvar.edit_num)
      {
        open_popupwin(PC_CALLFIND,tempvar.message+strlen(config->messwait));
      }
    }
    tempvar.message[NOLL]=NOLL;
    tempvar.new_line=FALSE;
  }
}

/********************************************************************/
/********************************************************************/
int init_port()
{
  char    name[ROWSIZE];
  long    speed;
//  IR_DATA ir_data;
//  FILE    *test=NOLL;
  
  if(!config->disabled)
  {
    if(strcmp(config->port,alerts[T_NO_PORT]))
    {
      strcpy(name,"u:\\dev\\");
      strcat(name,config->port);
      if(tempvar.portfile>=0)
      {
        Fclose(tempvar.portfile),tempvar.portfile=FAIL;
      }
      if(!tempvar.port_lock)
      {
        Flock(tempvar.portfile,1,0,0);
      }
      tempvar.portfile=Fopen(name,FO_RW);
      if(tempvar.portfile<=NOLL)
      {
        sprintf(fel.text,alerts[E_OPEN_PORT],config->port);
        alertbox(1,fel.text);
        return(FALSE);
      }
      tempvar.port_lock=Flock(tempvar.portfile,0,0,0);
Log("port_lock=%d",tempvar.port_lock);
      if(tempvar.port_lock)
      {
        sprintf(fel.text,"[1][Could not lock port %s][Damn!]",config->port);
Log("E",fel.text);
//        alertbox(1,fel.text);
      }
      speed=config->port_speed;
      if(Fcntl(tempvar.portfile, (long)&speed, TIOCIBAUD))
      {
        set_timer(FAIL);
        Fclose(tempvar.portfile);
        tempvar.portfile=FAIL;
        config->disabled=TRUE;
        menu_icheck(menu_tree,MENU_FILE_ENABLE,FALSE);
        menu_icheck(menu_tree,MENU_FILE_DISABL,TRUE);
        menu_ienable(menu_tree,MENU_FILE_ENABLE,FALSE);
        menu_ienable(menu_tree,MENU_FILE_DISABL,FALSE);
        sprintf(fel.text,alerts[E_SET_SPEED],config->port_speed,config->port);
        alertbox(1,fel.text);
        return(FALSE);
      }    
      Fwrite(tempvar.portfile,strlen(config->portinit),config->portinit);
      Fwrite(tempvar.portfile,1,"\n");
/*
      test=fopen("data.dat","w");
      do
      {
        speed=NOLL;
	    name[0]=NOLL;
        do
        {
          Fread(tempvar.portfile,1,&(name[speed]));
          name[speed+1]=NOLL;
        }while(name[speed++]!='\n');
        if(test!=NOLL)
          fprintf(test,name);
        name[strcspn(name,"\n\r")]=NOLL;
        printf("(%s)",name);
        getch();
      }while(strcmp(name,"OK"));
      if(test!=NOLL)
        fclose(test),test=NOLL;
*/        
      
      menu_icheck(menu_tree,MENU_FILE_ENABLE,TRUE);
      menu_icheck(menu_tree,MENU_FILE_DISABL,FALSE);
      menu_ienable(menu_tree,MENU_FILE_ENABLE,TRUE);
      menu_ienable(menu_tree,MENU_FILE_DISABL,TRUE);
      set_timer(PORT_TIME);
    }
    else
    {
      set_timer(FAIL);
      tempvar.portfile=NOLL;
      config->disabled=TRUE;
      menu_icheck(menu_tree,MENU_FILE_ENABLE,FALSE);
      menu_icheck(menu_tree,MENU_FILE_DISABL,TRUE);
      menu_ienable(menu_tree,MENU_FILE_ENABLE,FALSE);
      menu_ienable(menu_tree,MENU_FILE_DISABL,FALSE);
    }
  }
  else
  {
    set_timer(FAIL);
    tempvar.portfile=NOLL;
    config->disabled=TRUE;
    menu_icheck(menu_tree,MENU_FILE_ENABLE,FALSE);
    menu_icheck(menu_tree,MENU_FILE_DISABL,TRUE);
  }
  return(TRUE);
}

/********************************************************************/
/********************************************************************/
void deinit_port()
{
  if(tempvar.portfile>0)
  {
    set_timer(FAIL);
    if(!tempvar.port_lock)
      Flock(tempvar.portfile,1,0,0);
    Fclose(tempvar.portfile);
    tempvar.portfile=NOLL;
    config->disabled=TRUE;
    menu_icheck(menu_tree,MENU_FILE_ENABLE,FALSE);
    menu_icheck(menu_tree,MENU_FILE_DISABL,TRUE);
  }
}