#include "firecall.h"
void show_export_type(int oldtype, int newtype);
void export_single(FILE *text);
/********************************************************************/
/********************************************************************/
void init_exportwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,EXPORT,&export_win.dialog);
  strncpy(export_win.w_name,alerts[WN_EXPORT],MAXWINSTRING);
  export_win.attr=NAME|MOVE|CLOSE;
  export_win.icondata=NULL;
  export_win.status=WINDOW_CLOSED;
  export_win.type=TYPE_DIALOG;
  form_center(export_win.dialog, &dummy, &dummy, &dummy, &dummy);

  button(&export_win,EXPORT_TYPE_0,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_1,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_2,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_3,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_4,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_5,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_6,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_7,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_8,CLEAR_STATE,SELECTED,FALSE);
  button(&export_win,EXPORT_TYPE_9,CLEAR_STATE,SELECTED,FALSE);
}
/********************************************************************/
/********************************************************************/
void open_exportwin(int new)
{
  button(&export_win,EXPORT_EXAMPLE_0,SET_FLAGS,HIDETREE,FALSE);
  button(&export_win,EXPORT_EXAMPLE_1,SET_FLAGS,HIDETREE,FALSE);
  button(&export_win,EXPORT_EXAMPLE_2,SET_FLAGS,HIDETREE,FALSE);
  button(&export_win,EXPORT_EXAMPLE_3,SET_FLAGS,HIDETREE,FALSE);
  button(&export_win,EXPORT_EXAMPLE_4,SET_FLAGS,HIDETREE,FALSE);
  button(&export_win,EXPORT_EXAMPLE_5,SET_FLAGS,HIDETREE,FALSE);
  switch(config->export_type)
  {
    case 0:
      button(&export_win,EXPORT_EXAMPLE_0,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_0,SET_STATE,SELECTED,FALSE);
      break;
    case 1:
      button(&export_win,EXPORT_EXAMPLE_1,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_1,SET_STATE,SELECTED,FALSE);
      break;
    case 2:
      button(&export_win,EXPORT_EXAMPLE_2,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_2,SET_STATE,SELECTED,FALSE);
      break;
    case 3:
      button(&export_win,EXPORT_EXAMPLE_3,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_3,SET_STATE,SELECTED,FALSE);
      break;
    case 4:
      button(&export_win,EXPORT_EXAMPLE_4,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_4,SET_STATE,SELECTED,FALSE);
      break;
    case 5:
      button(&export_win,EXPORT_EXAMPLE_5,CLEAR_FLAGS,HIDETREE,FALSE);
      button(&export_win,EXPORT_TYPE_5,SET_STATE,SELECTED,FALSE);
      break;
    default:
      break;
  }
  if(new)
    open_dialog(&export_win,NULL);
  else
    button(&export_win,ROOT,CLEAR_STATE,SELECTED,TRUE);
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_exportwin(RESULT svar)
{
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    menu_icheck(menu_tree,MENU_LIST_EXPORT,FALSE);
    menu_ienable(menu_tree,MENU_LIST_EXPORT,TRUE);
    close_dialog(&export_win);
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case EXPORT_CANCEL:
        menu_icheck(menu_tree,MENU_LIST_EXPORT,FALSE);
        menu_ienable(menu_tree,MENU_LIST_EXPORT,TRUE);
        close_dialog(&export_win);
        break;
      case EXPORT_EX_IM:
        menu_icheck(menu_tree,MENU_LIST_EXPORT,FALSE);
        menu_ienable(menu_tree,MENU_LIST_EXPORT,TRUE);
        close_dialog(&export_win);
        export_list();
        button(&export_win,EXPORT_EX_IM,CLEAR_STATE,SELECTED,FALSE);
      case EXPORT_TYPE_0:
      case EXPORT_TYPE_1:
      case EXPORT_TYPE_2:
      case EXPORT_TYPE_3:
      case EXPORT_TYPE_4:
      case EXPORT_TYPE_5:
      case EXPORT_TYPE_6:
      case EXPORT_TYPE_7:
      case EXPORT_TYPE_8:
      case EXPORT_TYPE_9:
        if(config->export_type!=svar.data[SVAR_OBJECT]-EXPORT_TYPE_0)
        {
          show_export_type(config->export_type,svar.data[SVAR_OBJECT]-EXPORT_TYPE_0);
          config->export_type=svar.data[SVAR_OBJECT]-EXPORT_TYPE_0;
        }
        break;
      default: 
        break;
    }
  }
}
/********************************************************************/
/********************************************************************/
void show_export_type(int oldtype, int newtype)
{
  switch(oldtype)
  {
    case 0:
      button(&export_win,EXPORT_EXAMPLE_0,SET_FLAGS,HIDETREE,FALSE);
      break;
    case 1:
      button(&export_win,EXPORT_EXAMPLE_1,SET_FLAGS,HIDETREE,FALSE);
      break;
    case 2:
      button(&export_win,EXPORT_EXAMPLE_2,SET_FLAGS,HIDETREE,FALSE);
      break;
    case 3:
      button(&export_win,EXPORT_EXAMPLE_3,SET_FLAGS,HIDETREE,FALSE);
      break;
    case 4:
      button(&export_win,EXPORT_EXAMPLE_4,SET_FLAGS,HIDETREE,FALSE);
      break;
    case 5:
      button(&export_win,EXPORT_EXAMPLE_5,SET_FLAGS,HIDETREE,FALSE);
      break;
  }
  switch(newtype)
  {
    case 0:
      button(&export_win,EXPORT_EXAMPLE_0,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
    case 1:
      button(&export_win,EXPORT_EXAMPLE_1,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
    case 2:
      button(&export_win,EXPORT_EXAMPLE_2,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
    case 3:
      button(&export_win,EXPORT_EXAMPLE_3,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
    case 4:
      button(&export_win,EXPORT_EXAMPLE_4,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
    case 5:
      button(&export_win,EXPORT_EXAMPLE_5,CLEAR_FLAGS,HIDETREE,TRUE);
      break;
  }
}
/********************************************************************/
/********************************************************************/
void export_list()
{
  FILE *text_file;
  char filename[MAXSTRING],filepath[MAXSTRING];
  int counter;
  short dummy;

  strcpy(filepath,system_dir);
  strcat(filepath,"*.LST");
  strcpy(filename,"CALLER.LST");
  fsel_exinput(filepath, filename, &dummy,alerts[FS_CALLER]);
  if(!dummy)
    return;

  strcpy(strrchr(filepath,'\\')+1,filename);

  text_file=fopen(filepath,"w");
  if(text_file==NULL)
  {
    alertbox(1,alerts[E_OPEN_FILE]);
    return;
  }

  for(counter=NOLL;counter<tempvar.num_phones;counter++)
  {
    tempvar.phonedata=get_entity(phonelist,counter);
    if(tempvar.phonedata)
      export_single(text_file);
  }
  
  fclose(text_file);     
}

/********************************************************************/
/********************************************************************/
void export_single(FILE *text)
{
  char buffer[MAXSTRING];
                                                                                  
  switch(config->export_type)
  {
    case 0:
      strcpy(buffer,tempvar.phonedata->number);
      strncat(buffer,SPACES,SIZE_NUMB-strlen(tempvar.phonedata->number)+1);
      strcat(buffer,tempvar.phonedata->name);
      break;
    case 1:
      strcpy(buffer,tempvar.phonedata->name);
      strncat(buffer,SPACES,SIZE_NAME-strlen(tempvar.phonedata->name)+1);
      strcat(buffer,tempvar.phonedata->number);
      break;
    case 2:
      strcpy(buffer,tempvar.phonedata->number);
      strncat(buffer,SPACES,SIZE_NUMB-strlen(tempvar.phonedata->number)+1);
      strcat(buffer,tempvar.phonedata->name);
      strcat(buffer,"\n"); 
      if(tempvar.phonedata->info1[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NUMB+1);
        strcat(buffer,tempvar.phonedata->info1);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info2[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NUMB+1);
        strcat(buffer,tempvar.phonedata->info2);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info3[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NUMB+1);
        strcat(buffer,tempvar.phonedata->info3);
        strcat(buffer,"\n");
      }
      break;
    case 3:
      strcpy(buffer,tempvar.phonedata->name);
      strncat(buffer,SPACES,SIZE_NAME-strlen(tempvar.phonedata->name)+1);
      strcat(buffer,tempvar.phonedata->number);
      strcat(buffer,"\n"); 
      if(tempvar.phonedata->info1[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NAME+1);
        strcat(buffer,tempvar.phonedata->info1);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info2[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NAME+1);
        strcat(buffer,tempvar.phonedata->info2);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info3[NOLL]!=NOLL)
      {
        strncat(buffer,SPACES,SIZE_NAME+1);
        strcat(buffer,tempvar.phonedata->info3);
        strcat(buffer,"\n");
      }
      break;
    case 4:
      strcpy(buffer,tempvar.phonedata->number);
      strcat(buffer,"\n");
      strcat(buffer,tempvar.phonedata->name);
      strcat(buffer,"\n");
      if(tempvar.phonedata->info1[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info1);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info2[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info2);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info3[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info3);
        strcat(buffer,"\n");
      }
      break;
    case 5:
      strcpy(buffer,tempvar.phonedata->name);
      strcat(buffer,"\n");
      strcat(buffer,tempvar.phonedata->number);
      strcat(buffer,"\n");
      if(tempvar.phonedata->info1[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info1);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info2[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info2);
        strcat(buffer,"\n");
      }
      if(tempvar.phonedata->info3[NOLL]!=NOLL)
      {
        strcat(buffer,tempvar.phonedata->info3);
        strcat(buffer,"\n");
      }
      break;
    default:
      break;
  }
  fprintf(text,"%s\n",buffer);
}
