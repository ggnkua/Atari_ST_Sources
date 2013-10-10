#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>

#include "aesextra.h"

#include "mp2audio.h"
#include "mp2wind.h"
#include "mp2info.h"

/* Functions in this module */
void main_event_loop(void);
void bg_event_loop(void);
void fg_event_loop(void);
int ev2_loop(WINDFORM *, int, int);
int checkhang(void);
void toggle_object(WINDFORM *,int,int);
void fg_init(WINDFORM *);
int find_windform(int );
int handle_message(int *);
int do_dragdrop(int *, int);
void update_objects(WINDFORM *,int,int, int *);
int key2button(int);
int do_formstuff(int);
long calc_time(void);
void update_time(void);
void setfilename(char *);

/* global variables */
int fgbg,closed_acc=0,file_was_open,looping=0,replay_pause=0;
long total_time;
char *app_name="MP2AUDIO";

/* global variable from mp2init.c */
extern int buf_init,first_init;
extern long first_buf,o_filepos;

/* global variables from mp2file.c */
extern char path[512], filename[512];
extern long filesize,filepos,bufferpos;

/* global variables from mp2audio.c */
extern int time_slice, count_dir;
extern int fd,replay,quit,file_open;
extern long buffer,left;
extern int acc_id,app_id;
extern WINDFORM windforms[5];
#ifdef STATIC_BUFFER
extern char buffer_mem[(long)BLOCK_SIZE];
#else
extern char *buffer_mem;
#endif

/* global variable from mp2info.c */
extern MP2INFO mp2info;

/* Functions from mp2init.c */
extern void init_replay(void);
extern void continue_replay(void);

/* Functions from mp2exit.c */
extern void exit_replay(void);
extern void pause_replay(void);

/* Functions from mp2file.c */
extern int open_file(void);
extern int reopen_file(void);
extern void reset_file(int fd);
extern void close_file(int fd);
extern void load(int q);
extern int next_song(char *, char *, int);

/* Functions from mp2info.c */
extern int getmp2info(int);
extern void show_mp2_error(int);

#define FG 1
#define BG 0

#define CLOSE_WIND 21
#define SWITCH_WIND 42

#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))

typedef struct { int x1,y1,x2,y2; } CORDS2;

void main_event_loop()
{
	fgbg=(_app?FG:BG);
	
	while(!quit)
	{
		if(closed_acc)
		{
			evnt_timer(1000,0);
#ifdef DEBUG
			form_alert(1,"[1][ACC reopened][Ok]");
#endif
			fg_init(&windforms[WIND_CTRL]);
			if(file_was_open)
				fd=reopen_file();
			closed_acc=0;
		}
		if(fgbg==FG)
			fg_event_loop();
		else if(fgbg==BG)
			bg_event_loop();
	}

}

/* No form window is open */
void bg_event_loop()
{
	int x,y,kstate,key,clicks,event,state;
	int pipe[8];


#ifdef DEBUG
	form_alert(1,"[1][ACC bg][Ok]");
#endif
	do {
		event = evnt_multi( MU_MESAG | MU_TIMER,
							2, 0x1, 1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							pipe,
							time_slice, 0,
							&x, &y, &state, &kstate, &key, &clicks );

		if (event & MU_TIMER)
			if (replay)
			{
				if(first_init)
					checkhang();
				load(1);
				update_time();
			}

		if (event & MU_MESAG)
		{
			handle_message(pipe); /* no window to handle */
		}

			
	} while ((fgbg==BG) && !closed_acc);
}

/* Form window open */
void fg_event_loop()
{
	int x,y,kstate,key,clicks,event,state;
	int pipe[8],obj_id;
	int fgexit=0,tmph,th;
	
	wind_open(windforms[WIND_CTRL].whandle,
		windforms[WIND_CTRL].wind.x,windforms[WIND_CTRL].wind.y,
		windforms[WIND_CTRL].wind.w,windforms[WIND_CTRL].wind.h);
	windforms[WIND_CTRL].wind_open=1;

#ifdef DEBUG
	form_alert(1,"[1][ACC fg][Ok]");
#endif
	do {
		event = evnt_multi( MU_MESAG | MU_TIMER | MU_BUTTON | MU_KEYBD,
							1, 0x3, 0x1,
							0, 0, 0, 0, 0,
							0, 0, 0, 0, 0,
							pipe,
							time_slice, 0,
							&x, &y, &state, &kstate, &key, &clicks );

		if (event & MU_TIMER)
			if (replay)
			{
				if(first_init)
					checkhang();
				load(1);
				update_time();
			}

		if(event & MU_KEYBD)
		{
			obj_id=key2button(key);
			if(obj_id < 0)
			{
				switch(-obj_id)
				{
					case CLOSE_WIND:
						wind_get(0, WF_TOP, &pipe[3]);
						pipe[0]=WM_CLOSED;
						fgexit=handle_message(pipe);
						break;
					case SWITCH_WIND:
						wind_get(0, WF_TOP, &tmph);
						/* find handle of next open window */
						th=tmph;
						while(((th=find_windform(th)+1)%N_WINDS)!=tmph)
						{
							if(windforms[th].wind_open)
							{
								wind_set(windforms[th].whandle,WF_TOP);
								break;
							}
						}
					default:
						break;
				}
			}
			else
				do_formstuff(obj_id);
		}

		if(!fgexit)
		{
			if (event & MU_MESAG)
				fgexit=handle_message(pipe);
	
			if (event & MU_BUTTON)
			{
				if(replay || replay_pause)
				{
					windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_flags |= KEEPSELECT;
					windforms[WIND_CTRL].formtree[CTRL_FF].ob_flags |= KEEPSELECT;
				}
				else
				{
					windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_flags &= ~KEEPSELECT;
					windforms[WIND_CTRL].formtree[CTRL_FF].ob_flags &= ~KEEPSELECT;
				}
				if(wind_find(x,y) == windforms[WIND_CTRL].whandle)
					if(ev2_loop(&windforms[WIND_CTRL],x,y))
						event=0;
			}
		}
		
		if(_app)
			quit=fgexit;
		else
			if(fgexit)
				fgbg=BG;

	} while ((replay || fgbg==FG) && !fgexit);
}

int ev2_loop(WINDFORM *wind,int mx,int my)
{
	int x,y,kstate,key,clicks,event,state,org_state;
	int obj_id,ev2exit,fgexit=0;
	int pipe[8];
	CORDS t;

	if((obj_id=objc_find(wind->formtree,CTRL_FIRST,1,mx,my))>=0)
	{
		if(wind->formtree[obj_id].ob_flags & SELECTABLE)
		{
			org_state=wind->formtree[obj_id].ob_state & SELECTED;
			toggle_object(wind,obj_id,TOGGLE);

			objc_offset(wind->formtree,obj_id,&t.x,&t.y);
			t.w=wind->formtree[obj_id].ob_width;
			t.h=wind->formtree[obj_id].ob_height;
			ev2exit=0;
			do {
				event = evnt_multi( MU_MESAG | MU_TIMER | MU_BUTTON | MU_M1 | MU_M2,
									1, 0x1, 0x0,
									0, t.x, t.y, t.w, t.h,
									1, t.x, t.y, t.w, t.h,
									pipe,
									time_slice, 0,
									&x, &y, &state, &kstate, &key, &clicks );

				if (event & MU_TIMER)
					if (replay)
					{
						if(first_init)
							checkhang();
						load(1);
						update_time();
					}
			
				if (event & MU_MESAG)
					fgexit=handle_message(pipe);

				if (event & MU_M1) /* Enter area */
				{
					if(org_state==(wind->formtree[obj_id].ob_state & SELECTED))
						toggle_object(wind,obj_id,TOGGLE);
				}
				if (event & MU_M2) /* Leave area */
				{
					if(org_state!=(wind->formtree[obj_id].ob_state & SELECTED))
						toggle_object(wind,obj_id,TOGGLE);
				}
			
				if (event & MU_BUTTON)
				{
					if(obj_id==objc_find(wind->formtree,CTRL_FIRST,1,x,y))
					{
						if(wind->formtree[obj_id].ob_flags & KEEPSELECT)
						{
							if(org_state && (wind->formtree[obj_id].ob_state & SELECTED))
								toggle_object(wind,obj_id,SET_NORMAL);
							if(!org_state && !(wind->formtree[obj_id].ob_state & SELECTED))
								toggle_object(wind,obj_id,SET_SELECTED);
						}
						else if(wind->formtree[obj_id].ob_state & SELECTED)
							toggle_object(wind,obj_id,SET_NORMAL);

						fgexit=do_formstuff(obj_id);
					}
					else
					{
						objc_change(wind->formtree,obj_id,0,wind->form.x,
							wind->form.y,wind->form.w,wind->form.h,org_state,0);
						update_objects(wind,obj_id,1,0);
					}
					ev2exit=1;
				}

		
			} while (((replay || fgbg==FG) && !fgexit) && !ev2exit);
			event=0;
			return 1;
		}
	}
	return 0;
}		

int checkhang()
{
	long ptr[4];
	
	first_init=0;
	
	buffptr(ptr);

#ifdef DEBUG	
	fprintf(stderr,"first_buf=%lx ptr[0]=%lx\n",first_buf,ptr[0]);
#endif

	if(ptr[0]-first_buf < 512)
	{
#ifdef DEBUG
		fprintf(stderr,"init failed, trying again!\n");
		fprintf(stderr,"first_buf=%lx ptr[0]=%lx\n",first_buf,ptr[0]);
#endif
		Fseek(o_filepos,fd,0);
		filepos = o_filepos;
		init_replay();
		return 1;
	}
	return 0;
}

void toggle_object(WINDFORM *wind,int obj_id,int mode)
{
	if((mode==SET_NORMAL) || 
		((mode==TOGGLE) && (wind->formtree[obj_id].ob_state & SELECTED)))
	{
		objc_change(wind->formtree,obj_id,0,wind->form.x,
			wind->form.y,wind->form.w,wind->form.h,
			NORMAL,0);
		wind->formtree[wind->formtree[obj_id].ob_head].ob_x--;
		wind->formtree[wind->formtree[obj_id].ob_head].ob_y--;
	}
	else if((mode==SET_SELECTED) || 
		((mode==TOGGLE) && !(wind->formtree[obj_id].ob_state & SELECTED)))
	{
		objc_change(wind->formtree,obj_id,0,wind->form.x,
			wind->form.y,wind->form.w,wind->form.h,
			SELECTED,0);
		wind->formtree[wind->formtree[obj_id].ob_head].ob_x++;
		wind->formtree[wind->formtree[obj_id].ob_head].ob_y++;
	}
	update_objects(wind,obj_id,1,0);
}

void fg_init(WINDFORM *wind)
{
	form_center(wind->formtree,&wind->form.x,&wind->form.y,
		&wind->form.w,&wind->form.h);
	wind_calc(WC_BORDER,wind->windkind,wind->form.x,wind->form.y,
		wind->form.w,wind->form.h,&wind->wind.x,&wind->wind.y,
		&wind->wind.w,&wind->wind.h);
	wind->whandle=wind_create(wind->windkind,wind->wind.x,wind->wind.y,
		wind->wind.w,wind->wind.h);
	wind_set(wind->whandle,WF_NAME,wind->wind_title);

	if(wind == &windforms[WIND_CTRL])
		wind_set(wind->whandle,WF_BEVENT,1,0,0,0); /* untoppable */
	
	wind_calc(WC_WORK,wind->windkind,wind->wind.x,wind->wind.y,
		wind->wind.w,wind->wind.h,&wind->form.x,&wind->form.y,
		&wind->form.w,&wind->form.h);
	wind->formtree[wind->firstobj].ob_x=wind->form.x;
	wind->formtree[wind->firstobj].ob_y=wind->form.y;
	wind->formtree[wind->firstobj].ob_width=wind->form.w;
	wind->formtree[wind->firstobj].ob_height=wind->form.h;
}

int handle_message(int pipe[8])
{
	static int first_open=0;
	int wnr,error; /* ,avmsg[8]; */
	char *vamsg,*o;

#ifdef DEBUG
	char tmp[128];
#endif

	switch (pipe[0]) {
		case AC_OPEN:
			if (pipe[4] == acc_id)
			{
				if(first_open)
				{
					if(windforms[WIND_CTRL].wind_open)
						wind_set(windforms[WIND_CTRL].whandle,WF_TOP);
					else
						fgbg=FG;
				}
				else
				{
					fg_init(&windforms[WIND_CTRL]);
					fgbg=FG;
					first_open=1;
				}
			}
#ifdef DEBUG
				form_alert(1,"[1][Got AC_OPEN][Ok]");
#endif
			break;
		case AC_CLOSE:
/*			if (pipe[4] == acc_id) */

			{
#ifdef DEBUG
				sprintf(tmp,"[1][Got AC_CLOSE|ACC id: %d|pipe4: %d][Ok]",acc_id,pipe[4]);
				form_alert(1,tmp);
#endif

				if(windforms[WIND_CTRL].wind_open)
				{
					wind_close(windforms[WIND_CTRL].whandle);
					wind_delete(windforms[WIND_CTRL].whandle);
					windforms[WIND_CTRL].wind_open=0;
				}
				if(windforms[WIND_INFO].wind_open)
				{
					wind_close(windforms[WIND_INFO].whandle);
					wind_delete(windforms[WIND_INFO].whandle);
					windforms[WIND_INFO].wind_open=0;
				}
#ifdef DEBUG
				sprintf(tmp,"[1][Filepos: %ld][Ok]",filepos);
				form_alert(1,tmp);
#endif
				file_was_open=file_open;
				if(file_open)
					close_file(fd);
				closed_acc=1;
				return 1;
			}
/*			break; */
			
		case AP_TERM:
			quit=1;
			return 1;
/*			switch(pipe[5])
			{
				case AP_RESCHG:
					printf("Got AP_RESCHG!\n");
				break;
				case AP_TERM:
					printf("Got AP_TERM!");
				break;
				default:
					printf("Got unknown AP_TERM!");
			}
*/
/*			break; */
		case RESCHG_COMPLETED:
/*			printf("Got RESCHG_COMPLETED!"); */
			break;
		
		case WM_REDRAW:
			if((wnr=find_windform(pipe[3]))>=0)
				update_objects(&windforms[wnr],windforms[wnr].firstobj,
					windforms[wnr].objdepth,pipe);
			break;
		case WM_MOVED:
			if((wnr=find_windform(pipe[3]))>=0)
			{
				wind_set(windforms[wnr].whandle,WF_CURRXYWH,pipe[4],pipe[5],pipe[6],pipe[7]);
				windforms[wnr].wind.x=pipe[4];
				windforms[wnr].wind.y=pipe[5];
				windforms[wnr].wind.w=pipe[6];
				windforms[wnr].wind.h=pipe[7];
				wind_calc(WC_WORK,windforms[wnr].windkind,
					windforms[wnr].wind.x,windforms[wnr].wind.y,
					windforms[wnr].wind.w,windforms[wnr].wind.h,
					&windforms[wnr].form.x,&windforms[wnr].form.y,
					&windforms[wnr].form.w,&windforms[wnr].form.h);
				windforms[wnr].formtree[windforms[wnr].firstobj].ob_x=windforms[wnr].form.x;
				windforms[wnr].formtree[windforms[wnr].firstobj].ob_y=windforms[wnr].form.y;
				windforms[wnr].formtree[windforms[wnr].firstobj].ob_width=windforms[wnr].form.w;
				windforms[wnr].formtree[windforms[wnr].firstobj].ob_height=windforms[wnr].form.h;
				if(replay)
					update_time();
			}
			break;
		case WM_CLOSED:
			if((wnr=find_windform(pipe[3]))>=0)
			{
				wind_close(windforms[wnr].whandle);
				windforms[wnr].wind_open=0;
				if(wnr==WIND_CTRL)
				{
					if(windforms[WIND_INFO].wind_open)
					{
						wind_close(windforms[WIND_INFO].whandle);
						windforms[WIND_INFO].wind_open=0;
					}
					return 1;
				}
				else
					wind_delete(windforms[wnr].whandle);
			}
			break;
		case WM_TOPPED:
			if((wnr=find_windform(pipe[3]))>=0)
				wind_set(pipe[3],WF_TOP);
			break;
		case AP_DRAGDROP:
			if(wind_find(pipe[4],pipe[5]) == windforms[WIND_CTRL].whandle)
			{
				if(do_dragdrop(pipe,DD_OK))
				{
					exit_replay();

					if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
						toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
					Dsp_Hf1(0);				
					if(windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_state & SELECTED)
						toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
					replay_pause=0;

					filepos=0;
					fd=reopen_file();
					filesize=Fseek(0L,fd,2);
					Fseek(0L,fd,0);
					if((error=getmp2info(fd))==MP2_NOERR)
					{
						update_time();
						setfilename(filename);
						if(!(pipe[6] & K_ALT))
							init_replay();
					}
					else
					{
						exit_replay();
						show_mp2_error(error);
						close_file(fd);
						strcpy(windforms[WIND_CTRL].wind_title,"MPEG");
						wind_set(windforms[WIND_CTRL].whandle,WF_NAME,
							windforms[WIND_CTRL].wind_title);
						setfilename("MPEGFILE");
					}
				}
			}
			else
			{
				do_dragdrop(pipe,DD_NAK);
			}
			break;

		case VA_START:
			vamsg=*((char **)&pipe[3]);
			strcpy(path,vamsg);

/* This *should* be sent to the application
	which sent the VA_START msg, but it seems
	to hang Thing doing it. */
/*
			avmsg[0]=AV_STARTED;
			avmsg[1]=app_id;
			avmsg[2]=0;
			avmsg[3]=pipe[3];
			avmsg[4]=pipe[4];
			appl_write(pipe[1],5*2,avmsg);
*/
			if((o=strchr(path,' '))!=NULL)
				o[0]='\0';
			o=strrchr(path,'\\');
			strcpy(filename,&o[1]);
			o=strrchr(path,'\\');
			strncpy(o,"\\*.MP?",6);
			o[6] = '\0';


			exit_replay();

			if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
				toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
			Dsp_Hf1(0);				
			if(windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_state & SELECTED)
				toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
			replay_pause=0;

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
				exit_replay();
				show_mp2_error(error);
				close_file(fd);
				strcpy(windforms[WIND_CTRL].wind_title,"MPEG");
				wind_set(windforms[WIND_CTRL].whandle,WF_NAME,
					windforms[WIND_CTRL].wind_title);
				setfilename("MPEGFILE");
			}
			
			break;
		default:
#ifdef DEBUG
			sprintf(tmp,"[1][Unimplemented| message: %d][Ok]",pipe[0]);
			form_alert(1,tmp);
#endif
			break;
	}
	return 0;
}

int do_dragdrop(int pipe[8], int mode)
{
	char misc[512],*o;
	char dd_name[32],dd_cmsg;
	int i,dd_pipe,headsize,again=1,ret=0;
	long datasize,err;
	
	strcpy(dd_name,"U:\\PIPE\\DRAGDROP.");
	strcat(dd_name,(char *)&pipe[7]);
	
	if((err=Fopen(dd_name,FO_RW)) >= 0)
	{
		dd_pipe=(int)err;

		dd_cmsg=(char)mode;
		Fwrite(dd_pipe,1,&dd_cmsg);
		if(mode==DD_OK)
		{
			strcpy(misc,"ARGS");
			for(i=(int)strlen(misc) ; i<32 ; i++)
				misc[i] = '\0';
			Fwrite(dd_pipe,32,misc);
			
			while(again)
			{
				Fread(dd_pipe,2,&headsize);
				
				if(headsize > 0)
				{
					Fread(dd_pipe,headsize,misc);
					if(!strncmp(misc,"ARGS",4))
					{
						datasize = *((long *)&misc[4]);

						dd_cmsg=DD_OK;
						Fwrite(dd_pipe,1,&dd_cmsg);
						Fread(dd_pipe,datasize,misc);
	
						if((o=strchr(misc,' '))!=NULL)
							o[0]='\0';
						o=strrchr(misc,'\\');
						strcpy(path,misc);
						strcpy(filename,&o[1]);
						o=strrchr(path,'\\');
						strncpy(o,"\\*.MP?",6);
						o[6] = '\0';

						again=0;
						ret=1;
					}
					else
					{
						dd_cmsg=DD_EXT;
						Fwrite(dd_pipe,1,&dd_cmsg);
						again=1;
					}
				}
				else
					again=0;
			}
		}
		/* mode==DD_NAK do nothing*/

		Fclose(dd_pipe);
	}
	
	return ret;
}

int find_windform(int whandle)
{
	/* Do this more general later perhaps */

	if(whandle==windforms[WIND_CTRL].whandle)
		return WIND_CTRL;
	if(whandle==windforms[WIND_INFO].whandle)
		return WIND_INFO;
	return -1;
}

void update_objects(WINDFORM *wind,int obj_id,int depth, int pipe[8])
{
	CORDS2 r,u,o;
	CORDS t;

	if(pipe)
	{
		o.x1=pipe[4];
		o.y1=pipe[5];
		o.x2=pipe[4]+pipe[6]-1;
		o.y2=pipe[5]+pipe[7]-1;
	}

	graf_mouse(M_OFF,0);
	wind_update(BEG_UPDATE);
	wind_get(wind->whandle,WF_FIRSTXYWH,&t.x,&t.y,&t.w,&t.h);
	while(t.w || t.h)
	{
		if(pipe)
		{
			r.x1=t.x;				r.y1=t.y;
			r.x2=t.x+t.w-1;		r.y2=t.y+t.h-1;
			u.x1=max(r.x1,o.x1);	u.y1=max(r.y1,o.y1);
			u.x2=min(r.x2,o.x2);	u.y2=min(r.y2,o.y2);
		}
		else
		{
			u.x1=t.x;				u.y1=t.y;
			u.x2=t.x+t.w-1;		u.y2=t.y+t.h-1;
		}
		
		if((u.x2>=u.x1) && (u.y2>=u.y1)) 
			objc_draw(wind->formtree,obj_id,depth,
				u.x1, u.y1, u.x2-u.x1+1, u.y2-u.y1+1);
		wind_get(wind->whandle,WF_NEXTXYWH,&t.x,&t.y,&t.w,&t.h);
	}
	wind_update(END_UPDATE);
	graf_mouse(M_ON,0);
}

int key2button(int key)
{
	int ac,sc;
	
	ac=key & 0xff;			/* extract ascii code */
	sc=(key>>8) & 0xff;	/* extract scan code (not the best) */
	sc=sc;					/* dummy */

	switch(ac)
	{
		case 0x09:			/* C-i = info */
			return CTRL_INFO;
		case 0x12:			/* C-r = repeat on/off */
			toggle_object(&windforms[WIND_CTRL],CTRL_LOOP,TOGGLE);
			return CTRL_LOOP;
/* C-w hangs the desktop when run as accessory */
		case 0x17:			/* C-w = switch window */
			if(_app)
				return -SWITCH_WIND;
			else
				return 0;
		case 0x15:			/* C-u = close window */
			return -CLOSE_WIND;
		case 0x0f:			/* C-o = open new file */
			return CTRL_LOAD;
		case 0x0c:			/* C-l = (load and) play */
			return CTRL_PLAY;
		case 0x13:			/* C-s = stop */
			return CTRL_STOP;
		case 0x10:			/* C-p = pause */
			if(replay_pause)
				toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
			else if(replay)
				toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_SELECTED);
			return CTRL_PAUSE;
		case 0x06:			/* C-f = next song */
			return CTRL_NEXT;
		case 0x02:			/* C-b = previous song */
			return CTRL_PREV;
		case 0x16:			/* C-v = Fast Forward */
			toggle_object(&windforms[WIND_CTRL],CTRL_FF,TOGGLE);
			return CTRL_FF;
		case 0x14:			/* C-t = count up/down */
			toggle_object(&windforms[WIND_CTRL],CTRL_TIME,TOGGLE);
			return CTRL_TIME;
		case ' ':			/* SPC = play/stop */
			if(replay)
				return CTRL_STOP;
			else
				return CTRL_PLAY;
		default:
			return 0;
	}
}

int do_formstuff(int obj_id)
{
	int tfd;

	switch(obj_id)
	{
		case CTRL_STOP:
			if(Dsp_Hf1(-1))	/* If fast forwarding */
			{
				if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
					toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
				Dsp_Hf1(0);				
			}

			if(replay || replay_pause)
			{
				if(windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_state & SELECTED)
					toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
				replay_pause=0;
				exit_replay();
				update_time();
			}
			break;
		case CTRL_PLAY:
			if(replay_pause || Dsp_Hf1(-1))
			{
				if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
					toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
				Dsp_Hf1(0);				

				if(windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_state & SELECTED)
					toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
				continue_replay();
				replay_pause=0;
			}
			else
			{
				if(!replay && file_open)
				{
					replay_pause=0;
					init_replay();
				}
				else
				{
					if((tfd = open_file()) > 0)
					{
						int error;
						
						fd=tfd;
						if((error=getmp2info(fd))==MP2_NOERR)
						{
							replay_pause=0;
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
				}
			}
			break;
		case CTRL_PAUSE:

			if(replay_pause)
			{
				continue_replay();
				replay_pause=0;
			}
			else
			{
				if(replay)
				{
					pause_replay();
					replay_pause=1;
				}
			}

			break;
		case CTRL_LOAD:
			if((tfd = open_file()) > 0)
			{
				int error;
			
				if(windforms[WIND_CTRL].formtree[CTRL_PAUSE].ob_state & SELECTED)
					toggle_object(&windforms[WIND_CTRL],CTRL_PAUSE,SET_NORMAL);
				replay_pause=0;

				if(Dsp_Hf1(-1))	/* If fast forwarding */
				{
					if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
						toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
					Dsp_Hf1(0);				
				}

				fd=tfd;
				if((error=getmp2info(tfd))==MP2_NOERR)
				{
					update_time();
					setfilename(filename);
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
			break;
		case CTRL_LOOP:
			looping=(windforms[WIND_CTRL].formtree[CTRL_LOOP].ob_state & SELECTED);
			break;
		case CTRL_INFO:
			/* Open info window */
			if(windforms[WIND_INFO].wind_open)
				wind_set(windforms[WIND_INFO].whandle,WF_TOP);
			else
			{
				fg_init(&windforms[WIND_INFO]);
				wind_open(windforms[WIND_INFO].whandle,
					windforms[WIND_INFO].wind.x,windforms[WIND_INFO].wind.y,
					windforms[WIND_INFO].wind.w,windforms[WIND_INFO].wind.h);
				windforms[WIND_INFO].wind_open=1;
			}
			break;
		case CTRL_NEXT:
			if(file_open)
			{
				int o_replay,o_pause;
			
				if(Dsp_Hf1(-1))	/* If fast forwarding */
				{
					if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
						toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
					Dsp_Hf1(0);				
				}

				o_replay = replay;
				o_pause = replay_pause;
				exit_replay();
				while((tfd=next_song(path, filename, 1))!=0)
				{
					if(getmp2info(tfd)!=MP2_NOERR)
					{
						close_file(tfd);
					} 
					else
					{
						if(file_open)
							close_file(fd);
						fd = tfd;
						file_open=1;
						update_time();
						setfilename(filename);
						replay = o_replay;
						replay_pause = o_pause;
						if(replay)
							init_replay();
						if(replay_pause)
						{
							init_replay();
							pause_replay();
						}
						break;
					}
				}
				if(!tfd)
				{
					update_time();
				}
			}
			break;
		case CTRL_PREV:
			if(file_open)
			{
				int o_replay,o_pause;
				
				if(Dsp_Hf1(-1))	/* If fast forwarding */
				{
					if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
						toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
					Dsp_Hf1(0);				
				}

				o_replay = replay;
				o_pause = replay_pause;

				/* if more than or one second of the song
					has elapsed, go to the beginning of
					of the same song! */
				if(calc_time() > 0)
				{
					reset_file(fd);
					update_time();
					replay = o_replay;
					replay_pause = o_pause;
					if(replay)
						init_replay();
					if(replay_pause)
					{
						init_replay();
						pause_replay();
					}
				}
				else
				{
					exit_replay();
					while((tfd=next_song(path, filename, 0))!=0)
					{
						if(getmp2info(tfd)!=MP2_NOERR)
						{
							close_file(tfd);
						}
						else
						{
							if(file_open)
								close_file(fd);
							fd = tfd;
							file_open=1;
							update_time();
							setfilename(filename);
							replay = o_replay;
							replay_pause = o_pause;
							if(replay)
								init_replay();
							if(replay_pause)
							{
								init_replay();
								pause_replay();
							}
							break;
						}
					}
					if(!tfd)
					{
						update_time();
					}
				}
			}
			break;
		case CTRL_FF:
			if (windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
				Dsp_Hf1(1);
			else
				Dsp_Hf1(0);
			break;
		case CTRL_TIME:
			if(windforms[WIND_CTRL].formtree[CTRL_TIME].ob_state & SELECTED)
				count_dir = 0; /* count up */
			else
				count_dir = 1; /* count down */
			if(file_open)
				update_time();
			break;
		default:
			break;
	}
	return 0;
}

long calc_time()
{
	long ptr[4];

	if(buf_init)
		buffptr(ptr);
	else
		ptr[0]=(long)buffer_mem;	

	return (bufferpos+ptr[0]-(long)buffer_mem)/(mp2info.bitrate/8);
}

void update_time()
{
	long time;
	char tmp[64];
	
	if(count_dir)
		time = total_time - calc_time();
	else
		time = calc_time();
		
	sprintf(tmp,"%02ld:%02ld",time/60,time%60);
	if(strcmp(tmp,windforms[WIND_CTRL].wind_title))
	{
		strcpy(windforms[WIND_CTRL].wind_title,tmp);
		wind_set(windforms[WIND_CTRL].whandle,WF_NAME,
			windforms[WIND_CTRL].wind_title);
	}
}

void setfilename(char *fname)
{
	char *t,*text;
	
	text = &windforms[WIND_CTRL].formtree[CTRL_FILENAME].ob_spec.
		tedinfo->te_ptext[6];
	
	strncpy(text, fname, 8);
	text[8] = '\0';
	if((t=strchr(text, '.')) != NULL)
		*t = '\0';

	update_objects(&windforms[WIND_CTRL],CTRL_FNAME_BOX,0,0);
	update_objects(&windforms[WIND_CTRL],CTRL_FILENAME,0,0);
}
