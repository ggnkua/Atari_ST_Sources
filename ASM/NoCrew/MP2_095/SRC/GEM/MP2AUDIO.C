/* MPEG Audio Layer II Decoder */

#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "version.h"
#include "snddefs.h"
#include "mp2audio.h"
#include "mp2info.h"
#include "mp2conf.h"

#include "mp2ctrl.rsh"	/* rsc file */
#include "mp2ctrl.rh"
#include "mp2wind.h"

/* global variables */
int time_slice=DEFAULT_TIME_SLICE,count_dir=DEFAULT_COUNT_DIR;
int find_first=0,play_first=0;
long block=(long)DEFAULT_BLOCK_SIZE*1024L;
int fd,replay,file_open,ext,quit;
int app_id, acc_id, vdi_id;
long buffer;
WINDFORM windforms[5];
#ifdef STATIC_BUFFER
char buffer_mem[(long)BLOCK_SIZE];
#else
char *buffer_mem;
#endif

extern int _app;

/* global variables from mp2file.c */
extern char path[512], filename[512];
extern long filesize,filepos;

/* global variables from mp2event.c */
extern long total_time;

/* Function in this module */
void setup_rsrc(int nbpl);
void readconfig(void);
int interpret(char *, char **);
void unix2dos(char *);

/* Functions from mp2init.c */
extern int external_clock(void);
extern void init_replay(void);
extern int open_file(void);

/* Functions from mp2exit.c */
extern void exit_replay(void);

/* Functions from mp2file.c */
extern void close_file(int fd);
extern int reopen_file(void);
extern int next_song(char *, char *, int);

/* Functions from mp2event.c */
extern void main_event_loop(void);
extern void fg_init(WINDFORM *wind);
extern void update_time(void);
extern void setfilename(char *);

/* Functions from mp2info.c */
extern int getmp2info(int);
extern void show_mp2_error(int);

int main(int argc, char *argv[])
{
	int wchar,hchar,wbar,hbar;
	int work_in[11]={ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
	int work_out[57];

	replay = 0;
	
	/* default clock is automatically choosen */
	ext=external_clock();

	/* default path is current */
	path[0] = 'A' + (char)Dgetdrv();
	path[1] = ':';
	Dgetpath(path+2, 0);
	strcat(path, "\\*.MP?");

	readconfig();

	if ((app_id = appl_init()) >= 0)
	{
#ifndef STATIC_BUFFER
		if((buffer_mem=(char *)malloc((size_t)block))==NULL)
		{
			form_alert(1,"[1][Not enough memory!][OK]");
			appl_exit();
			return 1;
		}
#endif

		if(!_app)
			acc_id = menu_register(app_id, "  MPEG2 Audio ");
		
		work_in[0]=graf_handle(&wchar,&hchar,&wbar,&hbar);
		v_opnvwk(work_in,&vdi_id,work_out);
		if(vdi_id > 0)
		{
			vq_extnd(vdi_id,1,work_out);
			v_clsvwk(vdi_id);
			setup_rsrc(work_out[4]);
			if (_app) 
			{
				fg_init(&windforms[WIND_CTRL]);
				graf_mouse(ARROW,NULL);
				if(argc>1)
				{
					int error;
					char *o;
					
					if((o=strrchr(argv[1],'\\'))==NULL)
					{
						strcpy(filename,argv[1]);
					}
					else
					{
						strcpy(path,argv[1]);
						strcpy(filename,&o[1]);
						o=strrchr(path,'\\');
						strncpy(o,"\\*.MP?",6);
						o[6] = '\0';
					}
					filepos=0;
					fd=reopen_file();
					filesize=Fseek(0L,fd,2);
					Fseek(0L,fd,0);
					if((error=getmp2info(fd))==MP2_NOERR)
					{
						update_time();
						setfilename(filename);
						init_replay();
					}
					else
					{
						show_mp2_error(error);
						close_file(fd);
						strcpy(windforms[WIND_CTRL].wind_title,"MPEG");
						wind_set(windforms[WIND_CTRL].whandle,WF_NAME,
							windforms[WIND_CTRL].wind_title);
						setfilename("MPEGFILE");
					}
				}
				else if(find_first)
				{
					int tfd;

					filename[0] = '\0';

					while((tfd=next_song(path, filename, 1))!=0)
					{
						if(getmp2info(tfd)!=MP2_NOERR)
						{
							close_file(tfd);
						} 
						else
						{
							fd = tfd;
							file_open=1;
							update_time();
							setfilename(filename);
							if(play_first)
								init_replay();
							break;
						}
					}
				}
				main_event_loop();
				if (replay)
					exit_replay();
			} 
			else
			{
				if (acc_id >= 0)
					main_event_loop();
			}
		}
		appl_exit();
#ifndef STATIC_BUFFER
		free(buffer_mem);
#endif
	}
	else
		fprintf(stderr, "Que pasa?\n");
	return 0;
}

void setup_rsrc(int nbpl)
{
	int ob;
	char ver[64];
	
	for(ob=0 ; ob<NUM_OBS ; ob++)
		rsrc_obfix(rs_object,ob);

	switch(nbpl)
	{
		case 1:
		case 2:
			windforms[WIND_CTRL].formtree=rs_trindex[FORM_CTRL1];
			windforms[WIND_INFO].formtree=rs_trindex[FORM_INFO1];
			break;
		case 4:
		default:
			windforms[WIND_CTRL].formtree=rs_trindex[FORM_CTRL4];
			windforms[WIND_INFO].formtree=rs_trindex[FORM_INFO4];
	}

	strcpy(windforms[WIND_CTRL].wind_title,"MPEG");
	strcpy(windforms[WIND_INFO].wind_title,"Info");
	strcpy(ver,"Version ");
	strcat(ver,VERSION_TEXT);
	strcpy(windforms[WIND_INFO].formtree[INFO_VERSION].ob_spec.tedinfo->te_ptext,ver);
	windforms[WIND_CTRL].windkind=(MOVER | CLOSER | NAME);
	windforms[WIND_INFO].windkind=(MOVER | CLOSER | NAME);
	windforms[WIND_CTRL].firstobj=CTRL_FIRST;
	windforms[WIND_INFO].firstobj=INFO_FIRST;
	windforms[WIND_CTRL].objdepth=2;
	windforms[WIND_INFO].objdepth=1;
	
	if(!count_dir) /* default set to count up */
	{
		objc_change(windforms[WIND_CTRL].formtree,CTRL_TIME,0,
			windforms[WIND_CTRL].form.x,windforms[WIND_CTRL].form.y,
			windforms[WIND_CTRL].form.w,windforms[WIND_CTRL].form.h,
			SELECTED,0);
		windforms[WIND_CTRL].formtree[windforms[WIND_CTRL].formtree[CTRL_TIME].ob_head].ob_x++;
		windforms[WIND_CTRL].formtree[windforms[WIND_CTRL].formtree[CTRL_TIME].ob_head].ob_y++;
	}
}

void readconfig()
{
	FILE *cf;
	char line[256],*value=line;
	
	cf=fopen("mp2audio.cnf","r");
	if(cf == NULL)
		cf=fopen("c:\\mp2audio.cnf","r");

	if(cf != NULL)
	{
		do
		{
			fgets(line,255,cf);
			if(line[0]!='#' || isspace((int)line[0]))
			{
				switch(interpret(line,&value))
				{
					case CF_BLOCK_SIZE:
#ifdef STATIC_BUFFER
						block = (long)BLOCK_SIZE;
#else
						/* config value is in kb */
						block = atol(value)*1024L;
#endif
						break;
					case CF_COUNT_DIR:
						if(!strcmp(strlwr(value),"up"))
							count_dir=0;
						else if(!strcmp(strlwr(value),"down"))
							count_dir=1;
						break;
					case CF_TIME_SLICE:
						time_slice = atoi(value);
						break;
					case CF_DEFAULT_PATH:
						strupr(value);
						strcpy(path,value);
						unix2dos(path);
						strcat(path,"*.MP?");
						break;
					case CF_FORCE_CLOCK:
						if(!strcmp(strlwr(value),"internal"))
							ext=0;
						else if(!strcmp(strlwr(value),"external"))
							ext=1;
						break;
					case CF_FIND_FIRST:
						if(!strcmp(value,"yes"))
							find_first=1;
						break;
					case CF_PLAY_FIRST:
						if(!strcmp(value,"yes"))
						{
							play_first=1;
							find_first=1;
						}
					default:
						/* Unknown or invalid config, ignored */
						break;
				}
			}
		} while(!feof(cf));
		fclose(cf);
	}
}

int interpret(char *line,char **value)
{
	int i=0;
	char *tmp,*tt;

	tt=strchr(line,'=');
		
	if(tt!=NULL)
	{
		/* remove possible spaces before '=' */
		tmp=tt;
		tmp--;
		while(*tmp==' ' || *tmp=='\t') tmp--;
		tmp[1]='\0';

		/* remove possible spaces after '=' */
		tmp=tt;
		tmp++;
		while((*tmp==' ' || *tmp=='\t') && *tmp) tmp++;
		if(!*tmp) /* invalid value to argument */
			return 0;
		*value=tmp;

		/* remove possible spaces after value */
		while(!isspace((int)*tmp)) tmp++;
		*tmp='\0';
		
		while(config_args[i].arg)
		{
			if(!strcmp(line,config_args[i].arg))
				return config_args[i].define;
			i++;
		}
	}
	/* unknown or invalid config argument */
	return 0;
}

void unix2dos(char *path)
{
	int i=0;
	char tmp[512];

	if(path[0] == '/')
	{
		strcpy(tmp,&path[1]);
		strcpy(path,"U:\\");
		strcat(path,tmp);
		while(path[i])
		{
			if(path[i] == '/')
				path[i] = '\\';
			i++;
		}
	}
	if(path[strlen(path)-1] != '\\')
		strcat(path,"\\");
}


