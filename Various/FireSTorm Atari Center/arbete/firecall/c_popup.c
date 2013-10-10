#include "firecall.h"
#include <time.h>
PHONE_DATA *find_number(char *text);
/********************************************************************/
char *find_region(char* telenum,char* text);
/********************************************************************/
/********************************************************************/
void init_popupwin(void)
{
  rsrc_gaddr(R_TREE,POPUP,&popup_win.dialog);
  strncpy(popup_win.w_name,alerts[WN_POPUP],MAXWINSTRING);
  popup_win.attr=NAME|MOVE|CLOSE;
  popup_win.icondata=NULL;
  popup_win.status=WINDOW_CLOSED;
  popup_win.type=TYPE_DIALOG;
  popup_win.tag=NOLL;
  form_center(popup_win.dialog, &tempvar.dummy, &tempvar.dummy, &tempvar.dummy, &tempvar.dummy);
  button(&popup_win,POPUP_NUMBER,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_NAME,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_INFO1,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_INFO2,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_INFO3,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_TIMES,CLEAR_FLAGS,EDITABLE,FALSE);
  button(&popup_win,POPUP_DIAL,CLEAR_FLAGS,DISABLED,TRUE);
  button(&popup_win,POPUP_PAGE_1,CLEAR_FLAGS,HIDETREE,FALSE);
  button(&popup_win,POPUP_PAGE_2,SET_FLAGS,HIDETREE,FALSE);
}
/********************************************************************/
/********************************************************************/
void open_popupwin(int type, char *string)
{
  char text[ROWSIZE],date[ROWSIZE];
  
  switch(type)
  {
    case PC_CALLFIND:   /* Inkommande samtal                        */
      if(string==NULL)
        return;
      if(tempvar.num_calls<config->log_number)
        tempvar.num_calls++;
      tempvar.popup_close=TRUE;
      tempvar.phonedata=find_number(string);
      if(!tempvar.phonedata)
      {
#ifdef LOGGING
Log(LOG_GENERAL," - Number NOT found");
#endif
        add_log(string,NULL);
        if(tempvar.edit_num)
          return;
        if(tempvar.num_calls>1)
        {
          popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_NEXT];
          button(&popup_win,POPUP_OK_NEXT,UPDATE,SELECTED,TRUE);
          return;
        }
        popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_OK];
        str2ted(popup_win.dialog,POPUP_NUMBER,string);
        str2ted(popup_win.dialog,POPUP_REGION,find_region(string,text));
        getdate(date);
        str2ted(popup_win.dialog,POPUP_NAME,"");
        str2ted(popup_win.dialog,POPUP_INFO1,"");
        str2ted(popup_win.dialog,POPUP_INFO2,"");
        str2ted(popup_win.dialog,POPUP_INFO3,"");
        str2ted(popup_win.dialog,POPUP_DATE,date);
        str2ted(popup_win.dialog,POPUP_TIMES,"");
        popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_EDIT];
      }
      else
      {
#ifdef LOGGING
Log(LOG_GENERAL," - Number found!");
#endif
        add_log(NOLL,tempvar.phonedata);
        if(tempvar.edit_num)
          return;
        if(tempvar.num_calls>1)
        {
          popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_NEXT];
          popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_EDIT];
          button(&popup_win,POPUP_OK_NEXT,UPDATE,SELECTED,TRUE);
          button(&popup_win,POPUP_ADD_EDIT,UPDATE,SELECTED,TRUE);
          return;
        }
        popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_OK];
        str2ted(popup_win.dialog,POPUP_NUMBER,string);
        strcpy(tempvar.last_num,string);
        str2ted(popup_win.dialog,POPUP_REGION,find_region(tempvar.last_num,text));
        getdate(date);
        tempvar.phonedata->times++;
        strcpy(tempvar.phonedata->date,date);
        tempvar.list_change=TRUE;
        str2ted(popup_win.dialog,POPUP_NAME,tempvar.phonedata->name);
        str2ted(popup_win.dialog,POPUP_INFO1,tempvar.phonedata->info1);
        str2ted(popup_win.dialog,POPUP_INFO2,tempvar.phonedata->info2);
        str2ted(popup_win.dialog,POPUP_INFO3,tempvar.phonedata->info3);
        str2ted(popup_win.dialog,POPUP_DATE,date);
        sprintf(text,"%d",tempvar.phonedata->times);
        str2ted(popup_win.dialog,POPUP_TIMES,text);
        popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_EDIT];
      }
      break;
    case PC_LISTVIEW:   /* Dubbeltryck fr†n Listan                  */
      if(tempvar.phonedata==NOLL)
        return;
      tempvar.popup_close=FALSE;
      str2ted(popup_win.dialog,POPUP_NAME,tempvar.phonedata->name);
      str2ted(popup_win.dialog,POPUP_INFO1,tempvar.phonedata->info1);
      str2ted(popup_win.dialog,POPUP_INFO2,tempvar.phonedata->info2);
      str2ted(popup_win.dialog,POPUP_INFO3,tempvar.phonedata->info3);
      str2ted(popup_win.dialog,POPUP_NUMBER,tempvar.phonedata->number);
      str2ted(popup_win.dialog,POPUP_DATE,tempvar.phonedata->date);
      sprintf(text,"%d",tempvar.phonedata->times);
      str2ted(popup_win.dialog,POPUP_TIMES,text);
      str2ted(popup_win.dialog,POPUP_REGION,find_region(tempvar.phonedata->number,text));
      popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_EDIT];
      tempvar.edit_num=FALSE;
      break;
    case PC_LISTEDIT:   /* Edit ifr†n Listan */
      if(tempvar.phonedata==NOLL)
        return;
      tempvar.popup_close=FALSE;
      str2ted(popup_win.dialog,POPUP_NAME,tempvar.phonedata->name);
      str2ted(popup_win.dialog,POPUP_INFO1,tempvar.phonedata->info1);
      str2ted(popup_win.dialog,POPUP_INFO2,tempvar.phonedata->info2);
      str2ted(popup_win.dialog,POPUP_INFO3,tempvar.phonedata->info3);
      str2ted(popup_win.dialog,POPUP_NUMBER,tempvar.phonedata->number);
      str2ted(popup_win.dialog,POPUP_DATE,tempvar.phonedata->date);
      sprintf(text,"%d",tempvar.phonedata->times);
      str2ted(popup_win.dialog,POPUP_TIMES,text);
      str2ted(popup_win.dialog,POPUP_REGION,find_region(tempvar.phonedata->number,text));
      tempvar.edit_num=TRUE;
      break;
    case PC_LOGFIND:    /* Dubbeltryck fr†n Loggen                  */
      if(string==NOLL)
        return;
      sscanf(string,"%s %s %s",date,date+SIZE_DATE+1,text);
      date[SIZE_DATE]=' ';
      tempvar.edit_num=FALSE;
      str2ted(popup_win.dialog,POPUP_NUMBER,text);
      strcpy(tempvar.last_num,text);
      str2ted(popup_win.dialog,POPUP_REGION,find_region(tempvar.last_num,text));
      tempvar.phonedata=find_number(tempvar.last_num);
      if(!tempvar.phonedata)
      {
        str2ted(popup_win.dialog,POPUP_DATE,date);
        str2ted(popup_win.dialog,POPUP_NAME,"");
        str2ted(popup_win.dialog,POPUP_INFO1,"");
        str2ted(popup_win.dialog,POPUP_INFO2,"");
        str2ted(popup_win.dialog,POPUP_INFO3,"");
        str2ted(popup_win.dialog,POPUP_TIMES,"");
        popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_ADD];
      }
      else
      {
        str2ted(popup_win.dialog,POPUP_NAME,tempvar.phonedata->name);
        str2ted(popup_win.dialog,POPUP_INFO1,tempvar.phonedata->info1);
        str2ted(popup_win.dialog,POPUP_INFO2,tempvar.phonedata->info2);
        str2ted(popup_win.dialog,POPUP_INFO3,tempvar.phonedata->info3);
        str2ted(popup_win.dialog,POPUP_DATE,date);
        sprintf(text,"%d",tempvar.phonedata->times);
        str2ted(popup_win.dialog,POPUP_TIMES,text);
        popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_EDIT];
      }
      break;
    case PC_NEW:
      tempvar.edit_num=TRUE;
      tempvar.phonedata=NOLL;
      tempvar.popup_close=FALSE;
      str2ted(popup_win.dialog,POPUP_NAME,"");
      str2ted(popup_win.dialog,POPUP_INFO1,"");
      str2ted(popup_win.dialog,POPUP_INFO2,"");
      str2ted(popup_win.dialog,POPUP_INFO3,"");
      str2ted(popup_win.dialog,POPUP_NUMBER,"");
      str2ted(popup_win.dialog,POPUP_DATE,"");
      str2ted(popup_win.dialog,POPUP_TIMES,"");
      str2ted(popup_win.dialog,POPUP_REGION,"");
      break;
  }
  if(tempvar.edit_num)
  {
    popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_OK];
    popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_CANCEL];
    button(&popup_win,POPUP_DIAL,SET_FLAGS,DISABLED,FALSE);
    button(&popup_win,POPUP_NAME,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO1,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO2,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO3,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_TIMES,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_NUMBER,SET_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_DIAL,SET_STATE,DISABLED,FALSE);
  }
  else
  {
    button(&popup_win,POPUP_NUMBER,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_NAME,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO1,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO2,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_INFO3,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_TIMES,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_DATE,CLEAR_FLAGS,EDITABLE,FALSE);
    button(&popup_win,POPUP_DIAL,CLEAR_STATE,DISABLED,FALSE);
  }
  open_dialog(&popup_win,NULL);
}

/********************************************************************/
/********************************************************************/
void check_popupwin(RESULT svar)
{
  char text[ROWSIZE];
  long wait;
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    tempvar.edit_num=FALSE;
    tempvar.num_calls=NOLL;
     close_dialog(&popup_win);
  }
  else if(svar.type=DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case POPUP_ADD_EDIT:
        if(!tempvar.edit_num)
        {
          tempvar.edit_num=TRUE;
          popup_win.dialog[POPUP_ADD_EDIT].ob_spec=alerts[T_OK];
          popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_CANCEL];
          str2ted(popup_win.dialog,POPUP_REGION,"");
          button(&popup_win, POPUP_DIAL, SET_STATE, DISABLED,TRUE);
          button(&popup_win, POPUP_OK_NEXT, CLEAR_STATE, SELECTED,TRUE);
          button(&popup_win, POPUP_ADD_EDIT, CLEAR_STATE, SELECTED,TRUE);
          button(&popup_win,POPUP_NUMBER,SET_FLAGS,EDITABLE,TRUE);
          button(&popup_win,POPUP_NAME,SET_FLAGS,EDITABLE,FALSE);
          button(&popup_win,POPUP_INFO1,SET_FLAGS,EDITABLE,FALSE);
          button(&popup_win,POPUP_INFO2,SET_FLAGS,EDITABLE,FALSE);
          button(&popup_win,POPUP_INFO3,SET_FLAGS,EDITABLE,FALSE);
          button(&popup_win,POPUP_TIMES,SET_FLAGS,EDITABLE,FALSE);
          button(&popup_win,POPUP_IMAGE,SET_FLAGS,EXIT,FALSE);
        }
        else
        {
          if(!tempvar.phonedata)
          {
            if((tempvar.num_phones>=MAX_UNREG)&(!tempvar.registered))
            {
              alertbox(1,alerts[M_UNREG_LIST]);
              button(&popup_win,POPUP_ADD_EDIT,CLEAR_STATE,SELECTED,TRUE);
              return;
            }
            tempvar.phonedata=new_entity(&phonelist,sizeof(PHONE_DATA),SIZE_ALLOC);
          }
          if(tempvar.phonedata)
          {
            ted2str(popup_win.dialog,POPUP_NAME,tempvar.phonedata->name);
            ted2str(popup_win.dialog,POPUP_INFO1,tempvar.phonedata->info1);
            ted2str(popup_win.dialog,POPUP_INFO2,tempvar.phonedata->info2);
            ted2str(popup_win.dialog,POPUP_INFO3,tempvar.phonedata->info3);
            ted2str(popup_win.dialog,POPUP_NUMBER,tempvar.phonedata->number);
            ted2str(popup_win.dialog,POPUP_DATE,tempvar.phonedata->date);
            ted2str(popup_win.dialog,POPUP_TIMES,text);
            if(sscanf(text,"%d",&tempvar.phonedata->times)!=1)
              tempvar.phonedata->times=0;
            tempvar.list_change=TRUE;
          }
          button(&popup_win, POPUP_ADD_EDIT, CLEAR_STATE, SELECTED,TRUE);
          if(list_win.status==WINDOW_OPENED)
            open_listwin();
          tempvar.edit_num=FALSE;
          if(tempvar.num_calls<=NOLL)
          {
            tempvar.popup_close=FALSE;
            button(&popup_win,POPUP_OK_NEXT,CLEAR_STATE,SELECTED,TRUE);
            close_dialog(&popup_win);
            tempvar.num_calls=NOLL;
            return;
          }
          else if(tempvar.num_calls==1)
            popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_OK];
          button(&popup_win,POPUP_OK_NEXT,CLEAR_STATE,SELECTED,TRUE);
          strncpy(text,logtext+(tempvar.num_log-tempvar.num_calls)*LENGTH_LOG,ROWSIZE-1);
          open_popupwin(PC_LOGFIND,text);
        }
        break;
      case POPUP_OK_NEXT:
        if(!tempvar.edit_num)
          tempvar.num_calls--;
        if(tempvar.num_calls<=NOLL)
        {
          tempvar.popup_close=FALSE;
          tempvar.edit_num=FALSE;
          button(&popup_win,POPUP_OK_NEXT,CLEAR_STATE,SELECTED,TRUE);
          close_dialog(&popup_win);
          tempvar.num_calls=NOLL;
          return;
        }
        else if(tempvar.num_calls==1)
        {
          popup_win.dialog[POPUP_OK_NEXT].ob_spec=alerts[T_OK];
          button(&popup_win,POPUP_OK_NEXT,CLEAR_STATE,SELECTED,TRUE);
        }
        strncpy(text,logtext+(tempvar.num_log-tempvar.num_calls)*LENGTH_LOG,ROWSIZE-1);
        open_popupwin(PC_LOGFIND,text);
        break;
      case POPUP_DIAL:
        tempvar.popup_close=FALSE;
        Fwrite(tempvar.portfile,strlen(config->linecommand),config->linecommand);
        Fwrite(tempvar.portfile,1,"\n");
        wait=clock();
        while(wait+CLOCKS_PER_SEC>clock());
        if(tempvar.phonedata!=NULL)
          sprintf(text,"%s %s\n",config->dialcommand,tempvar.phonedata->number);
        else
          sprintf(text,"%s %s\n",config->dialcommand,tempvar.last_num);
        Fwrite(tempvar.portfile,strlen(text),text);
        wait=clock();
        while(wait+DIALWAIT>clock());
        Fwrite(tempvar.portfile,2," \n");
        button(&popup_win, POPUP_DIAL, CLEAR_STATE, SELECTED,TRUE);
         break;
      case POPUP_NEXTPAGE:
        tempvar.popup_close=FALSE;
        if(popup_win.dialog[POPUP_PAGE_1].ob_flags&HIDETREE)
        {
          button(&popup_win,POPUP_PAGE_1,CLEAR_FLAGS,HIDETREE,FALSE);
          button(&popup_win,POPUP_PAGE_2,SET_FLAGS,HIDETREE,FALSE);
          button(&popup_win,ROOT,CLEAR_STATE,SELECTED,TRUE);
        }
        else if(popup_win.dialog[POPUP_PAGE_2].ob_flags&HIDETREE)
        {
          button(&popup_win,POPUP_PAGE_2,CLEAR_FLAGS,HIDETREE,FALSE);
          button(&popup_win,POPUP_PAGE_1,SET_FLAGS,HIDETREE,FALSE);
          button(&popup_win,ROOT,CLEAR_STATE,SELECTED,TRUE);
        }
        break;
      case POPUP_IMAGE:
        break;
    }
}

/********************************************************************/
/********************************************************************/
PHONE_DATA *find_number(char *text)
{
  PHONE_DATA *temp=NULL;
  int counter=0;
  while(counter<tempvar.num_phones)
  {
    temp=get_entity(phonelist,counter++);
    if(temp)
    {
      if(!strcmp(temp->number,text))
        return(temp);
    }
  }
  return NULL;
}
/********************************************************************/
/* Check Area                                                       */
/********************************************************************/
char *find_region(char *telenum,char *text)
{
  char areacode[SIZE_NUMB],
       areaname[MAXSTRING]="",
       *temp_point=tempvar.num_list;
  int  counter;
  strcpy(text,"");
  if(tempvar.num_list==NULL)
  {
    strcpy(text,"");
    return(text);
  }
  do
  {
    while(!isdigit(*temp_point))
    {
      temp_point++;
      if(*temp_point==NOLL)
        return(text);
    }
    counter=NOLL;
    while(isdigit(*temp_point))
    {
      areacode[counter++]=*temp_point;
      temp_point++;
      if(*temp_point==NOLL)
        return(text);
    }
    areacode[counter]=NOLL;
    counter=NOLL;
    while((*temp_point!='\n')&&(*temp_point!='\r'))
    {
      if((isspace(*temp_point))&&(counter==NOLL))
      ;
      else
        areaname[counter++]=*temp_point;
      
      temp_point++;
      if(*temp_point==NOLL)
        return(text);
    }
    areaname[counter]=NOLL;
    if(!strncmp(telenum,areacode,strlen(areacode)))
    {
      strcpy(text,areaname);
      return(text);
    }
  }while(TRUE);
}
