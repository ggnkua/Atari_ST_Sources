#include "firecall.h"
/********************************************************************/
/********************************************************************/
void init_infowin(void)
{
  short dummy;
  char text[ROWSIZE];
  rsrc_gaddr(R_TREE,INFORMATION,&info_win.dialog);
  strncpy(info_win.w_name,alerts[WN_INFORMATION],MAXWINSTRING);
  info_win.attr=NAME|MOVE|CLOSE /*|SMALLER*/ ;
  info_win.icondata=NULL /*&icons[ICON_FIRESTORM] */ ;
  info_win.i_x=100;
  info_win.i_y=100;
  info_win.status=WINDOW_CLOSED;
  info_win.type=TYPE_DIALOG;
  form_center(info_win.dialog, &dummy, &dummy, &dummy, &dummy);
  sprintf(text,alerts[T_VERSION],VERSION);
  str2ted(info_win.dialog,INFO_VERSION,text);
    
  rsrc_gaddr(R_TREE,REGISTER,&register_win.dialog);
  strncpy(register_win.w_name,alerts[WN_REGISTER],MAXWINSTRING);
  register_win.attr=NAME|MOVE|CLOSE;
  register_win.icondata=NULL;
  register_win.status=WINDOW_CLOSED;
  register_win.type=TYPE_DIALOG;
  form_center(register_win.dialog, &dummy, &dummy, &dummy, &dummy);
  str2ted(register_win.dialog,REG_NAME,"Unregistered");
  str2ted(register_win.dialog,REG_ADR1,"");
  str2ted(register_win.dialog,REG_ADR2,"");
  str2ted(register_win.dialog,REG_ADR3,"");
  str2ted(register_win.dialog,REG_KEY,"");
}
/********************************************************************/
/* Hantering av informations-f”nstret                               */
/********************************************************************/
void check_infowin(RESULT svar)
{

  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&info_win);
    menu_icheck(menu_tree,MENU_INFO,FALSE);
    menu_ienable(menu_tree,MENU_INFO,TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[SVAR_OBJECT])
    {
      case INFO_OK:
        button(&info_win, INFO_OK, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&info_win);
        menu_icheck(menu_tree,MENU_INFO,FALSE);
        menu_ienable(menu_tree,MENU_INFO,TRUE);
        init_port();
        break;
      case INFO_REGISTER:
        button(&info_win, INFO_REGISTER, CLEAR_STATE, SELECTED,TRUE);
//        close_dialog(&info_win);
        open_nonmodal(&register_win,NULL);
        break;
      default:;
    }
}

/********************************************************************/
/* Handling of the Registration window                              */
/********************************************************************/
void check_registerwin(RESULT svar)
{
  short xy[4];
  if((svar.type==WINDOW_CLICKED)&&(svar.data[SVAR_WINDOW_MESSAGE]==WM_CLOSED))
  {
    close_dialog(&register_win);
    menu_icheck(menu_tree,MENU_INFO,FALSE); 
    menu_ienable(menu_tree,MENU_INFO,TRUE); 
  }
  else if(svar.type==DIALOG_CLICKED)
  {
    switch(svar.data[SVAR_OBJECT])
    {
      case REG_EXIT:
        button(&register_win, REG_EXIT, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&register_win);
        menu_icheck(menu_tree,MENU_INFO,FALSE); 
        menu_ienable(menu_tree,MENU_INFO,TRUE); 
        break;
      case REG_REGISTER:
        if(check_key(FALSE))
        {
          tempvar.registered=TRUE;
          button(&register_win, REG_REGISTER, CLEAR_STATE, SELECTED,TRUE);
          close_dialog(&register_win);
          menu_icheck(menu_tree,MENU_INFO,FALSE); 
          menu_ienable(menu_tree,MENU_INFO,TRUE); 
          tempvar.conf_change=TRUE;
        }
        else
        {
          tempvar.registered=FALSE;
          button(&register_win, REG_REGISTER, CLEAR_STATE, SELECTED,TRUE);
        }
        break;
      case REG_LOAD_KEY:
        load_reg_file();
        button(&register_win, REG_LOAD_KEY, CLEAR_STATE, SELECTED,TRUE);
        wind_get(register_win.ident,WF_WORKXYWH,xy,xy+1,xy+2,xy+3);
        update_dialog(&register_win,xy);
        break;
      default:;
    }
  }
}

/********************************************************************/
/* Loading of the register.txt file                                 */
/********************************************************************/
int load_reg_file(void)
{
  char filename[MAXSTRING],filepath[MAXSTRING];
  FILE *file;
  short dummy;

  strcpy(filepath,system_dir);
  strcat(filepath,"*.DAT");
  strcpy(filename,"REGISTER.DAT");
  fsel_exinput(filepath, filename, &dummy,alerts[FS_REGISTER]);
  if(!dummy)
    return(FALSE);

  strcpy(strrchr(filepath,'\\')+1,filename);

  file=fopen(filepath,"rb");
  if(file==NULL)
  {
    alertbox(1,alerts[E_OPEN_FILE]);
    return(FALSE);
  }

  dummy=FALSE;
  fgets(filename,MAXSTRING,file);
  while((filename[strlen(filename)-1]=='\n')||(filename[strlen(filename)-1]=='\r')) filename[strlen(filename)-1]=NOLL;
  str2ted(register_win.dialog,REG_NAME,filename);
  fgets(filename,MAXSTRING,file);
  while((filename[strlen(filename)-1]=='\n')||(filename[strlen(filename)-1]=='\r')) filename[strlen(filename)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR1,filename);
  fgets(filename,MAXSTRING,file);
  while((filename[strlen(filename)-1]=='\n')||(filename[strlen(filename)-1]=='\r')) filename[strlen(filename)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR2,filename);
  fgets(filename,MAXSTRING,file);
  while((filename[strlen(filename)-1]=='\n')||(filename[strlen(filename)-1]=='\r')) filename[strlen(filename)-1]=NOLL;
  str2ted(register_win.dialog,REG_ADR3,filename);
  fgets(filename,MAXSTRING,file);
  while((filename[strlen(filename)-1]=='\n')||(filename[strlen(filename)-1]=='\r')) filename[strlen(filename)-1]=NOLL;
  str2ted(register_win.dialog,REG_KEY,filename);

  fclose(file);
  return(TRUE);
}

/********************************************************************/
/* Check the key against the important information                  */
/********************************************************************/
int check_key(int first)
{
  char *data[4],*testkey;
  char validkeys[]=VALIDKEY;
  char key[27];
  int  sum=0, oldsum=0;
  int  count[4]={0,0,0,0},
       count1,count2,
       maxcount=strlen(validkeys);

  if(first)
  {
     str2ted(register_win.dialog,REG_NAME,config->name);
     str2ted(register_win.dialog,REG_KEY,config->key);
     str2ted(register_win.dialog,REG_ADR1,config->adr1);
     str2ted(register_win.dialog,REG_ADR2,config->adr2);
     str2ted(register_win.dialog,REG_ADR3,config->adr3);
  }
  else
  {
    ted2str(register_win.dialog,REG_NAME,config->name);
    ted2str(register_win.dialog,REG_KEY,config->key);
    ted2str(register_win.dialog,REG_ADR1,config->adr1);
    ted2str(register_win.dialog,REG_ADR2,config->adr2);
    ted2str(register_win.dialog,REG_ADR3,config->adr3);
  }
  data[0]=(char *)((TEDINFO *)register_win.dialog[REG_NAME].ob_spec)->te_ptext;
  data[1]=(char *)((TEDINFO *)register_win.dialog[REG_ADR1].ob_spec)->te_ptext;
  data[2]=(char *)((TEDINFO *)register_win.dialog[REG_ADR2].ob_spec)->te_ptext;
  data[3]=(char *)((TEDINFO *)register_win.dialog[REG_ADR3].ob_spec)->te_ptext;

  testkey=(char *)((TEDINFO *)register_win.dialog[REG_KEY].ob_spec)->te_ptext;

/* Kod f”r att fixa fram key-koden */

  for(count1=0;count1<26;count1++)
  {
    for(count2=0,sum=0; count2<4; count2++)
    {
      if(data[count2][count[count2]]==NOLL)
        count[count2]=NOLL;
      sum+=data[count2][count[count2]];
      count[count2]++;
    }
    sum+=oldsum;
    sum=sum%maxcount;
    key[count1]=validkeys[sum];
    oldsum=sum;
  }
  key[count1]=NOLL;

/* slut p† key-fixar koden */

  if(!strcmp(key,testkey))
  { 
    info_win.dialog[INFO_OK].ob_width=info_win.dialog[INFO_REGISTER].ob_x+info_win.dialog[INFO_REGISTER].ob_width-info_win.dialog[INFO_OK].ob_x;
    button(&info_win,INFO_REGISTER,SET_FLAGS,HIDETREE,TRUE);
    button(&info_win,INFO_REGISTERED,CLEAR_FLAGS,HIDETREE,TRUE);
    str2ted(info_win.dialog,INFO_USERNAME,((TEDINFO *)register_win.dialog[REG_NAME].ob_spec)->te_ptext);
    return(TRUE);
  }
  else
  {
    info_win.dialog[INFO_REGISTERED].ob_flags|=HIDETREE;
    return(FALSE);
  }    
}