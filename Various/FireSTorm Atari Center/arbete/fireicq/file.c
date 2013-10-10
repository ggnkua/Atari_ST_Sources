#include "fireicq.h"
#include <dos.h>
#undef NOLL

/********************************************************************/
/* Laddar in en datafil till minnet och reserverar plats            */
/********************************************************************/
long load_datafile(char *path,char *namn, char **memory,long int fsize)
{
  char     temp[MAXSTRING+1];
  FILE     *file;
  long int size;
  
  if(path==NULL)
    strcpy(temp,system_dir);
  else
    strcpy(temp,path);
    
  strcat(temp,namn);
  file=fopen(temp,"rb");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"load_datafile(1)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  rewind(file);
  fseek(file,0,SEEK_END);
  size=ftell(file);
  rewind(file);
  if((fsize!=0)&&(fsize!=size))
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile(2)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  if(*memory==NULL)
    *memory=(char *)calloc(1,size+1);
  if(*memory==NULL)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_ALLOC_MEM],"load_datafile(3)");
    alertbox(1,fel.text);
    Return FAIL;
  }
  if(fread(*memory,1,size,file)!=size)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_READ_FILE],namn,"load_datafile(4)");
    alertbox(1,fel.text);
    Return FAIL; 
  }
  fclose(file);
  if(fsize)
  {
    Return TRUE;
  }
  else
  {
    Return size;
  }
}

/********************************************************************/
/* Sparar en Datafil fr†n minnet                                    */
/********************************************************************/
int save_datafile(int type, char *path, char *namn, char *memory,long int fsize)
{
  char     temp[MAXSTRING+1];
  FILE     *file;
  
  if(memory==NULL)
  {
    Return FALSE;
  }

  if(path==NULL)
    strcpy(temp,system_dir);
  else
    strcpy(temp,path);
    
  strcat(temp,namn);
  if(type)
    file=fopen(temp,"wb");
  else
    file=fopen(temp,"ab");
  if(file==NULL)
  {
    sprintf(fel.text,alerts[E_OPEN_FILE],namn,"save_datafile()");
    alertbox(1,fel.text);
    Return FALSE;
  }
  rewind(file);
  fseek(file,0,SEEK_END);
  if(fwrite(memory,1,fsize,file)!=fsize)
  {
    fclose(file);
    sprintf(fel.text,alerts[E_WRITE_FILE],namn,"save_datafile()");
    alertbox(1,fel.text);
    Return FALSE; 
  }

  fclose(file);
  Return TRUE;
}

/********************************************************************/
/* Execute program                                                  */
/********************************************************************/
int execute(char program[MAXSTRING],char command[MAXSTRING],int multi)
{
  char comstring[MAXSTRING+1];

  if(!multi)
  {
//    hide_dialog(NULL);
    strncpy(comstring," ",MAXSTRING);
    comstring[MAXSTRING]=EOL;
    strncat(comstring,command,MAXSTRING);
    comstring[MAXSTRING]=EOL;
    Pexec(0,program,comstring,NULL);
    menu_bar(menu_tree, 1);
    redraw_window(NULL);
//    unhide_dialog(NULL);  
  }
  Return TRUE;
}

//********************************************************************
// 980916 - Created, the part that selects the correct config-file
//          is still missing, only the text-config is loaded now.
//********************************************************************
// This function should compare the binary and the text-config and
// and take the one that is the latest
//********************************************************************
int load_config()
{

	return load_textconfig();
}
//********************************************************************
// 980916 - Created
//********************************************************************
// This function loads the text-based configuration
//********************************************************************
int load_textconfig()
{
	char	temp[MAXSTRING+1],data[MAXSTRING+1];
	FILE	*file;

	init_config();

	sprintf(temp,"%s%s",system_dir,CONFIGFILE);
	file=fopen(temp,"r");
	if(file)
	{
    	while(fgets(temp,MAXSTRING,file))
		{
			if(!strncmp(CONFIG_NAME,temp,strcspn(CONFIG_NAME," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.name,data,SIZE_NAME);
				config.name[SIZE_NAME]=0;
				strcpy(config.name,strchr(temp,'{')+1);
				((char *)strrchr(config.name,'}'))[0]='\0';
			}
			else if(!strncmp(CONFIG_ADRESS1,temp,strcspn(CONFIG_ADRESS1," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.adr1,data,SIZE_NAME);
				config.adr1[SIZE_NAME]=0;
			}
			else if(!strncmp(CONFIG_ADRESS2,temp,strcspn(CONFIG_ADRESS2," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.adr2,data,SIZE_NAME);
				config.adr2[SIZE_NAME]=0;
			}
			else if(!strncmp(CONFIG_ADRESS3,temp,strcspn(CONFIG_ADRESS3," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.adr3,data,SIZE_NAME);
				config.adr3[SIZE_NAME]=0;
			}
			else if(!strncmp(CONFIG_KEY,temp,strcspn(CONFIG_KEY," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.key,data,SIZE_NAME);
				config.key[SIZE_NAME]=0;
			}
			else if(!strncmp(CONFIG_STRINGSRV,temp,strcspn(CONFIG_STRINGSRV," \n\r")+1))
			{
				strcpy(data,strchr(temp,'{')+1);
				((char *)strrchr(data,'}'))[0]='\0';
				strncpy(config.stringserver,data,SIZE_ID);
				config.stringserver[SIZE_ID]=0;
			}
			else if(!strncmp(CONFIG_UIN,temp,strcspn(CONFIG_UIN," \n\r")+1))
    		{
    			sscanf(temp,CONFIG_UIN,&config.active_uin);
    		}
		}
	}

	tempvar.registered=check_key(TRUE);

	if(file)
		fclose(file);
	else
		save_config();
	Return TRUE;
}
//********************************************************************
// 980916 - Created
//********************************************************************
// save_config: This function saves both the text-based and "binary"
//              config file
//********************************************************************
int save_config(void)
{
	save_textconfig();

	Return TRUE;
}

//********************************************************************
// 980916 - Created
//********************************************************************
// This function saves the text-based configuration  
//********************************************************************
int save_textconfig(void)
{
	char	temp[ MAXSTRING + 1 ];
	FILE	*file;

	sprintf(temp,"%s%s",system_dir,CONFIGFILE);
	file=fopen(temp,"w");
	if(file)
	{
		fprintf(file,CONFIG_NAME,config.name);
		fprintf(file,CONFIG_ADRESS1,config.adr1);
		fprintf(file,CONFIG_ADRESS2,config.adr2);
		fprintf(file,CONFIG_ADRESS3,config.adr3);
		fprintf(file,CONFIG_KEY,config.key);
		fprintf(file,CONFIG_STRINGSRV,config.stringserver);
		fprintf(file,CONFIG_UIN,config.active_uin);
		fclose(file);
		tempvar.config_changed=FALSE;
		Return TRUE;
	}
	else
	{
		Return FALSE;
	}
}

//********************************************************************
// 980916 - Created
//********************************************************************
// This function takes the data in the global variable user and saves
// it to disc
//********************************************************************
int save_userinfo()
{
	char	temp[ MAXSTRING + 1 ];
	FILE	*file;

	if( main_win.status != WINDOW_CLOSED )
		wind_get(main_win.ident,WF_CURRXYWH,&t_user.main_wind_pos[X],&t_user.main_wind_pos[Y],&t_user.main_wind_pos[W],&t_user.main_wind_pos[H]);
	memcpy(user.main_wind_pos,t_user.main_wind_pos,sizeof(user.main_wind_pos));

	sprintf(temp,"%s%d.uin",system_dir,user.uin);
	file=fopen(temp,"w");
	if(!file)
	{
		fclose(file);
		Return TRUE;
	}
	else
	{
		Return FALSE;
	}
}