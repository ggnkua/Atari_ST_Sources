#include <tos.h>
#include <aes.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "snddefs.h"
#include "mp2audio.h"
#include "mp2wind.h"
#include "mp2info.h"

/* #define DEBUG */

/* Functions in this module */
int open_file(void);
int reopen_file(void);
void close_file(int fd);
void reset_file(int fd);
void real_load(long l, char *b);
void load(int q);
void set_stop(long *buf);
int has_stopped(int state);
int match(char *, char *, int);
int next_song(char *, char *, int);

/* global variables */
char path[512]="\0", filename[512]="\0";
long filesize,filepos,bufend=0,bufferpos=0;

/* global variables from mp2audio.c */
extern int file_open,fd,quit,replay;
extern long buffer,block;
extern WINDFORM windforms[5];
#ifdef STATIC_BUFFER
extern char buffer_mem[(long)BLOCK_SIZE];
#else
extern char *buffer_mem;
#endif

/* global variables from mp2event.c */
extern long total_time;
extern int looping;

/* global variable from mp2init.c */
extern int buf_init;

/* Function from mp2info.c */
extern int getmp2info(int);

/* Function from mp2exit.c */
extern void exit_replay(void);

/* Function from mp2init.c */
extern void init_replay(void);

/* Functions from mp2event.c */
extern void toggle_object(WINDFORM *, int, int);
extern void update_time(void);
extern void setfilename(char *);

int open_file(void)
{
	int button,ret;
	char tmp[1024],tfn[512];

	strcpy(tfn,filename);
	fsel_exinput(path, tfn, &button, "Load MPEG");
	if (button == 1) {
		if(*tfn)
		{
			if(replay)
				exit_replay();
			if(file_open)
				close_file(fd);
			strcpy(tmp,path);
			strrchr(tmp, '\\')[1] = '\0';
			if((ret=(int) Fopen(strcat(tmp, tfn), FO_READ)) > 0)
			{
				file_open=1;
				filesize=Fseek(0L,ret,2);
				Fseek(0L,ret,0);
				bufferpos = filepos = 0;
				strcpy(filename,tfn);
			}
			return ret;
		}
	}
	return 0;
}

int reopen_file()
{
	char tmp[1024];
	int tfd;
	long fp;

	strcpy(tmp,path);
	strrchr(tmp, '\\')[1] = '\0';
	file_open=1;
	tfd=(int)Fopen(strcat(tmp, filename), FO_READ);
	fp=Fseek(filepos,tfd,0);

	fp=fp;
#ifdef DEBUG
	sprintf(tmp,"[1][New filepos: %ld|Should be: %ld][Ok]",fp,filepos);
	form_alert(1,tmp);
#endif
	return tfd;
}

void close_file(int fd)
{
	file_open=0;
	Fclose(fd);
}

void reset_file(int fd)
{
	Fseek(0L,fd,0);
	buf_init = 0;
	bufferpos = filepos = 0;
}



void real_load(long l, char *b)
{
	long a=l;
	long tmp,t=(long)b;

#ifdef DEBUG
	long ffp;
	char tt[128];
#endif

	while (a > 0)
	{

#ifdef DEBUG
		ffp=Fseek(0L,fd,1);
		sprintf(tt,"[1][%d: a=%ld|t=%lx fpos=%ld][Ok]",fd,a,t,ffp);
		puts(tt);
#endif
			
		tmp=Fread(fd, a & 0xfffffffeL, (void *)t);

#ifdef DEBUG
		ffp=Fseek(0L,fd,1);
		sprintf(tt,"[1][%d Read tmp=%ld|a=%ld|t=%lx fpos=%ld][Ok]",fd,tmp,a,t,ffp);
		puts(tt);
#endif

		if (tmp < 0)
		{
#ifdef DEBUG
			ffp=Fseek(0L,fd,1);
			sprintf(tt,"[1][%d reset tmp<0|a=%ld t=%lx|tmp=%ld fpos=%ld][Ok]",fd,a,t,tmp,ffp);
			puts(tt);
#endif
			bufend=t;
			for( ; a>0 ; a--,t++)
				*((char *)t) = 0x42;
		}
		else
		{
			filepos += tmp;
		
			a-=tmp;
			t+=tmp;
			if(a >= 1)
			{

#ifdef DEBUG
				ffp=Fseek(0L,fd,1);
				sprintf(tt,"[1][%d reset a>0 a=%ld|t=%lx tmp=%ld|fpos=%ld][Ok]",fd,a,t,tmp,ffp);
				puts(tt);
#endif
				bufend=t;
#ifdef DEBUG
				printf("bufend = %lx\n",bufend);
#endif
				for( ; a>0 ; a--,t++)
					*((char *)t) = 0x42;
			}
		}
	}
}


int match(char *s1, char *s2, int dir)
{
	int n=0;

	if(dir) /* Find next */
	{
		if(strcmp(s1,s2) < 0)
		{
			n++;
			while(*(s1++) == *(s2++))
				n++;
		}
	}
	else /* Find previous */
	{
		if(strcmp(s1,s2) > 0)
		{
			n++;
			while(*(s1++) == *(s2++))
				n++;
		}
	}
	return n;
}

int next_song(char *path, char *filename, int dir)
{
	int next_fd,ok;
	DTA *dta;
	char tmp[1024];
	int q, score=0;

	dta = Fgetdta();
	strcpy(tmp, path);
	strrchr(tmp, '\\')[1] = '\0';
	ok = Fsfirst(strcat(tmp, "*.MP?"), 0);
	while (ok == 0) {
		if ((dta->d_attrib & (FA_VOLUME | FA_SUBDIR)) == 0) {
			q = match(filename, dta->d_fname, dir);
#ifdef DEBUG
			fprintf(stderr,"Matching %s and %s with match=%d\n",filename,dta->d_fname,q);
#endif
			if (score < q)
			{
				score = q;
				strcpy(tmp, dta->d_fname);
#ifdef DEBUG
				fprintf(stderr,"Score choice = %s\n",tmp);
#endif
			}
			else if(score == q)
			{
				if(dir) /* Find next */
				{
					if(strcmp(tmp, dta->d_fname) > 0)
					{
						strcpy(tmp, dta->d_fname);
#ifdef DEBUG
						fprintf(stderr,"Diff choice = %s\n",tmp);
#endif
					}
				}
				else /* Find previous */
				{
					if(strcmp(tmp, dta->d_fname) < 0)
					{
						strcpy(tmp, dta->d_fname);
#ifdef DEBUG
						fprintf(stderr,"Diff choice = %s\n",tmp);
#endif
					}
				}
			}
		}
		ok = Fsnext();
	}
	
	if (score) {
		strcpy(filename, tmp);
		strcpy(tmp, path);
		strrchr(tmp, '\\')[1] = '\0';
		if((next_fd=(int) Fopen(strcat(tmp, filename), FO_READ)) > 0)
		{
			filesize=Fseek(0L,next_fd,2);
			Fseek(0L,next_fd,0);
			return next_fd;
		}
	}
	return 0;  /* No next file */
}


void load(int q)
{
	static int state = 0;
	static long lastbuf=0;
	long ptr[4];
	
#ifdef DEBUG
	long bo;
	char tt[128];
#endif

	buffptr(ptr);
	buffer = ptr[0];

	if(buffer < lastbuf)
		bufferpos+=block;
		
	lastbuf=buffer;
	
	if(!q)
	{
		bufferpos=filepos;
		lastbuf=0;
		state = 0;
		bufend=0;
	}
	else
	{
		if (has_stopped(state))
		{
			if(bufend)
			{
#ifdef DEBUG
				printf("Song reset!\n");
#endif
				if(looping)
				{
					int ff;
					
					reset_file(fd);
					update_time();
					ff=Dsp_Hf1(-1);
					init_replay();
					Dsp_Hf1(ff);
				} else
				{
					int next_fd,ff;

					ff=Dsp_Hf1(-1);
					while((next_fd=next_song(path, filename, 1))!=0)
					{
						if (getmp2info(next_fd)!=MP2_NOERR) {
							close_file(next_fd);
						} else
						{
							if(file_open)
								close_file(fd);
							fd = next_fd;
							file_open=1;
							buf_init = 0;
							bufferpos = filepos = 0;
							update_time();
							setfilename(filename);
							init_replay();
							Dsp_Hf1(ff);
							break;
						}
					}
					if(!next_fd)
					{
						if(windforms[WIND_CTRL].formtree[CTRL_FF].ob_state & SELECTED)
							toggle_object(&windforms[WIND_CTRL],CTRL_FF,SET_NORMAL);
						Dsp_Hf1(0);				
						
						exit_replay();
						update_time();
					}
				}
			}
			else
			{
#ifdef DEBUG
				fprintf(stderr,"Song continues! filepos=%lx bufferpos=%lx\n",
					filepos,bufferpos);
#endif
				init_replay();
				update_time();
			}
			return;
		}
	}

	if(!bufend)
	{
		if(state && (buffer < ((long)buffer_mem + block/2)) &&
			(buffer > ((long)buffer_mem + STOP_BLOCK)))
		{
			real_load(block/2, (char *) ((long)buffer_mem + block/2));
			set_stop((long *)buffer_mem);
			state = !state;
		}
		else if(!q || (!state && (buffer >= ((long)buffer_mem + block/2 + STOP_BLOCK))))
		{
			real_load(block/2, buffer_mem);
			set_stop((long *) ((long)buffer_mem + block/2));
			state = !state;
		}
	}
}

void set_stop(long *buf)
{
	int i;

	for (i=0 ; i<(STOP_BLOCK/4) ; i++)
		buf[i] = 0x42424242L;
}

int has_stopped(int state)
{
	if(bufend)
	{
		if(bufend < ((long)buffer_mem + block/2))
		{
			if((buffer > bufend) && (buffer < ((long)buffer_mem + block/2)))
				return 1;
		}
		else
		{
			if(buffer > bufend)
				return 1;
		}
	}
	else
	{
		if(state && (buffer > ((long)buffer_mem + block/2)) &&
			(buffer < ((long)buffer_mem + block/2 + STOP_BLOCK)))
			return 1;
		else if(!state && (buffer > (long)buffer_mem) &&
			(buffer < ((long)buffer_mem + STOP_BLOCK)))
			return 1;
	}

	return 0;
}
