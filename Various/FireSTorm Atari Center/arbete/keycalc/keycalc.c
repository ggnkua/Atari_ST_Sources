#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <stdio.h>
#include <errno.h>
#include "FIRECONF\keycalc.h"
#include "..\windia\win_dia.h"

typedef struct
{
  char             name[MAXSTRING],
                   key[MAXSTRING];
} proglist;
/********************************************************************/
/********************************************************************/
WIN_DIALOG   registerwin;
extern short screenx, screeny, screenw, screenh;
extern int   ap_id;
char         configkeys[]="1qazxsw2QWASZX3edcvfr4VCFDREbnhgty65TYBNHGMKkmJIijUu78lpoLPO09";
char         system_dir[MAXSTRING],*programlist;
char         *alerts[MAX_ALERTS];
proglist     *program;
int          prognums,progselect;
extern error fel;

/********************************************************************/
/********************************************************************/
int main(void)
{
  if(init_appl()&&init_graph()&&init_rsc()&&load_config())
  {
    Pdomain(1);
    open_dialog(&registerwin,NULL);
    while(!check_registerwin());
  }
  deinit();
  return(FALSE);
}

/********************************************************************/
/* Handling of the Registration window                              */
/********************************************************************/
int check_registerwin()
{
  RESULT svar;
  char   keykode[27];
  
  svar=form_dialog();
  if((svar.type==WINDOW_CLICKED)&&(svar.data[0]==WM_CLOSED))
  {
    close_dialog(&registerwin);
    return(TRUE);
  }
  else if(svar.type==DIALOG_CLICKED)
    switch(svar.data[0])
    {
      case QUIT:
        button(&registerwin, QUIT, CLEAR_STATE, SELECTED,TRUE);
        close_dialog(&registerwin);
        return(TRUE);
        break;
      case CALCULATE:
        button(&registerwin, CALCULATE, CLEAR_STATE, SELECTED,TRUE);
        str2ted(registerwin.dialog,KEY_CODE,(char *)check_key(keykode,(char *)program[progselect].key));
        button(&registerwin,KEY_CODE,CLEAR_STATE,SELECTED,TRUE);
        break;
      case SAVE_KEY:
        make_registerfile();   
        button(&registerwin, SAVE_KEY, CLEAR_STATE, SELECTED,TRUE);
        break;
      case CHANGE_PROG:
        progselect=popup(programlist,progselect,registerwin.dialog,CHANGE_PROG,NULL);
        button(&registerwin, CHANGE_PROG, CLEAR_STATE, SELECTED,TRUE);
        strncpy((char *)registerwin.dialog[CHANGE_PROG].ob_spec,program[progselect].name,26);
        break;
      default:;
    }
  else if(svar.type=KEY_CLICKED)
  {
   //printf("(%d)",svar.data[0]);
  }
  return(FALSE);
}

/********************************************************************/
/* Making of the register.txt file                                  */
/********************************************************************/
int make_registerfile(void)
{
  char filename[255],filepath[255];
  FILE *file;
  short dummy;
  
  strcpy(filepath,"A:");
  filepath[0]=Dgetdrv()+'A';
  Dgetpath(filepath+2,0);
  strcat(filepath,"\\*.DAT");
  strcpy(filename,"REGISTER.DAT");
  fsel_exinput(filepath, filename, &dummy,alerts[A_SAVE_KEY]);
  if(!dummy)
    return(FALSE);

  strcpy(strrchr(filepath,'\\')+1,filename);

  file=fopen(filepath,"w");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_FILE_OPEN],errno);
    alertbox(1,fel.text);
    return(FALSE);
  }

  dummy=FALSE;
  fprintf(file,"%s\n",(char *)((TEDINFO *)registerwin.dialog[RNAME].ob_spec)->te_ptext);
  fprintf(file,"%s\n",(char *)((TEDINFO *)registerwin.dialog[ADRESS_1].ob_spec)->te_ptext);
  fprintf(file,"%s\n",(char *)((TEDINFO *)registerwin.dialog[ADRESS_2].ob_spec)->te_ptext);
  fprintf(file,"%s\n",(char *)((TEDINFO *)registerwin.dialog[ADRESS_3].ob_spec)->te_ptext);
  fprintf(file,"%s",(char *)((TEDINFO *)registerwin.dialog[KEY_CODE].ob_spec)->te_ptext);
  fclose(file);
  return(TRUE);
}

/********************************************************************/
/* Check the key against the important information                  */
/********************************************************************/
char *check_key(char *key,char *validkey)
{
  char *data[4];
  int  sum=0, oldsum=0;
  int  count[4]={0,0,0,0},
       count1,count2,
       maxcount=strlen(validkey);
            
  data[0]=(char *)((TEDINFO *)registerwin.dialog[RNAME].ob_spec)->te_ptext;
  data[1]=(char *)((TEDINFO *)registerwin.dialog[ADRESS_1].ob_spec)->te_ptext;
  data[2]=(char *)((TEDINFO *)registerwin.dialog[ADRESS_2].ob_spec)->te_ptext;
  data[3]=(char *)((TEDINFO *)registerwin.dialog[ADRESS_3].ob_spec)->te_ptext;

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
    key[count1]=validkey[sum];
    oldsum=sum;
  }
  key[count1]=NOLL;

/* slut p† key-fixar koden */

  return(key);
}

/********************************************************************/
/* Initiates the Registration-window                                */
/********************************************************************/
void init_registerwin(void)
{
  short dummy;
  
  rsrc_gaddr(R_TREE,REGISTER,&registerwin.dialog);
  strncpy(registerwin.w_name,"key Calculator",MAXWINSTRING);
  registerwin.attr=NAME|CLOSE|MOVE;
  registerwin.icondata=NULL;
  registerwin.status=WINDOW_CLOSED;
  str2ted(registerwin.dialog,RNAME,"");
  str2ted(registerwin.dialog,ADRESS_1,"");
  str2ted(registerwin.dialog,ADRESS_2,"");
  str2ted(registerwin.dialog,ADRESS_3,"");
  str2ted(registerwin.dialog,KEY_CODE,"");
  form_center(registerwin.dialog, &dummy, &dummy, &dummy, &dummy);
}

/********************************************************************/
/* Initiates the Application                                        */
/********************************************************************/
int init_appl(void)
{
  ap_id=appl_init();
  if(ap_id==FAIL)
  {
    alertbox(1,APPL_ERROR);
    return(FALSE);
  }

  
  strcpy(system_dir,"A:");
  system_dir[0]=Dgetdrv()+'A';
  Dgetpath(system_dir+2,0);
  strcat(system_dir,"\\FIRECONF\\");

  return(TRUE);
}

/********************************************************************/
/* Initiates the Resource-file                                      */
/********************************************************************/
int init_rsc(void)
{
  char temp[MAXSTRING];
  short dummy;

  strcpy(temp,system_dir);
  strcat(temp,"keycalc.rsc");
  rsrc_free(); 
  if(!rsrc_load(temp))
  {
    alertbox(1,RESOURCE_ERROR);
    return(FALSE);
  }
  
  init_registerwin();

  for(dummy=1; dummy<MAX_ALERTS; dummy++)
    rsrc_gaddr(R_STRING,dummy,&alerts[dummy]);	


  return(TRUE);
}

/********************************************************************/
/********************************************************************/
void deinit(void)
{
   
  rsrc_free();
    
  if(ap_id!=NOLL)
    appl_exit();

  if(program!=NULL)
    Mfree(program);
  if(programlist!=NULL)
    Mfree(programlist);
    
}

/********************************************************************/
/********************************************************************/
int load_config()
{
  char     temp1[MAXSTRING],temp2[MAXSTRING];
  FILE     *config;
  int      counter=NOLL;
  long int size;
  strcpy(temp1,system_dir);
  strcat(temp1,"keycalc.cfg");
  config=fopen(temp1,"r");
  if(config==NULL)
  {
    return(FALSE);
  }
  rewind(config);
  while((fgets(temp1,MAXSTRING,config)!=NULL)&&(fgets(temp2,MAXSTRING,config)!=NULL))
    prognums++;
  rewind(config);
  program=(proglist *)Malloc(prognums*sizeof(proglist));
  if(program==NULL)
  {
    fclose(config);
    return(FALSE);
  }
  counter=NOLL;
  size=strlen(alerts[A_CHOOSE]);
  while((fgets(temp1,MAXSTRING,config)!=NULL)&&(fgets(temp2,MAXSTRING,config)!=NULL))
  {
    size++;
    while(!(isprint(temp1[strlen(temp1)-1])))
      temp1[strlen(temp1)-1]=NOLL;
    while(!(isprint(temp2[strlen(temp2)-1])))
      temp2[strlen(temp2)-1]=NOLL;
    strcpy(program[counter].name,temp1);
    strcpy(program[counter].key,temp2);
    size+=strlen(program[counter].name);
    counter++;
  }
  fclose(config);
  size++;
  programlist=(char *)Malloc(size);
  if(programlist==NULL)
  {
    return(FALSE);
  }

  strcpy(programlist,alerts[A_CHOOSE]);
  for(counter=NOLL;counter<prognums;counter++)
  {
    strcat(programlist,"|");
    strncat(programlist,program[counter].name,26);
  }
  progselect=NOLL;
  strncpy((char *)registerwin.dialog[CHANGE_PROG].ob_spec,program[progselect].name,26);
  return(TRUE);
}