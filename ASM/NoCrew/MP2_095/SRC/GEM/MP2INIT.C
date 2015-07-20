#include <tos.h>
#include <aes.h>
#include <ext.h>
#include <stdio.h>
#include <string.h>

#include "snddefs.h"
#include "mp2audio.h"
#include "mp2wind.h"
#include "mp2info.h"

/* Functions in this module */
int external_clock(void);
void init_replay(void);
void continue_replay(void);
void cont_stream(void);
void init_stream1(void);
void init_stream2(void);

/* global variables */
int buf_init=0,first_init=1;
long first_buf,o_filepos;

/* global variables from mp2audio.c */
extern int quit,replay,fd,ext;
extern long block;
extern WINDFORM windforms[5];
#ifdef STATIC_BUFFER
extern char buffer_mem[(long)BLOCK_SIZE];
#else
extern char *buffer_mem;
#endif

/* global variable from mp2info.c */
extern MP2INFO mp2info;

/* global variable from mp2file.c */
extern long filepos;

/* Function from mp2dsp.s */
extern void ass_init_stream1(void);
extern long do_devc_e44(void);
extern long do_devc_e22(void);
extern long do_devc_i48(void);
extern long do_devc_i32(void);
extern long do_devc_i24(void);
extern long do_devc_i16(void);

/* Function from mp2extra.c */
extern void mute(int mode);

/* Function from mp2event.c */
extern void load(int q);
extern void update_objects(WINDFORM *,int,int,int *);


/* Function from mp2dsp.c */
extern void bootdsp(void);

void init_replay()
{
	long ptr[4];

	quit = 0;

	o_filepos = filepos;

	load(0);
	mute(MUTE);
	init_stream1();
	buf_init=1;
	bootdsp();			/* Reset, bootstrap, execute, upload data */
	mute(MUTE_RESTORE);
	init_stream2();
		
	buffptr(ptr);
	first_buf=ptr[0];
	first_init=1;
	
	replay = 1;
}

void continue_replay()
{
	Dsp_Hf0(0);				/* tell DSP to depause */
	replay=1;
}

void cont_stream()
{
	switch((int)(mp2info.sample_frequency/10))
	{
		case 1600:
			Supexec(do_devc_i16); /* use 16390 Hz */
			break;
		case 2205:
			if(ext)
				Supexec(do_devc_e22); /* external 22.05 KHz clock */
			else
				Supexec(do_devc_i24); /* use 24585 Hz (interpolate?) */			
			break;
		case 2400:
			Supexec(do_devc_i24); /* use 24585 Hz */
			break;
		case 3200:
			Supexec(do_devc_i32); /* use 32780 Hz */
			break;
		case 4410:
			if(ext)
				Supexec(do_devc_e44); /* external 44.1 Khz clock */
			else
				Supexec(do_devc_i48); /* interpolate 44.1 KHz to 49Khz */
			break;
		case 4800:
			Supexec(do_devc_i48); /* use 49170 Hz */
			break;
	}
}

void init_stream1()
{
	sndstatus(SND_RESET);
	setmode(STEREO16);
	soundcmd(ADDERIN,MATIN);
	dsptristate(ENABLE,ENABLE);


	setbuffer(SR_PLAY,(void *)buffer_mem,(void *)((long)buffer_mem+block));

	switch((int)(mp2info.sample_frequency/10))
	{
		case 1600:
			Supexec(do_devc_i16); /* use 16390 Hz */
			break;
		case 2205:
			if(ext)
				Supexec(do_devc_e22); /* external 22.05 KHz clock */
			else
				Supexec(do_devc_i24); /* use 24585 Hz (interpolate?) */			
			break;
		case 2400:
			Supexec(do_devc_i24); /* use 24585 Hz */
			break;
		case 3200:
			Supexec(do_devc_i32); /* use 32780 Hz */
			break;
		case 4410:
			if(ext)
				Supexec(do_devc_e44); /* external 44.1 Khz clock */
			else
				Supexec(do_devc_i48); /* interpolate 44.1 KHz to 49Khz */
			break;
		case 4800:
			Supexec(do_devc_i48); /* use 49170 Hz */
			break;
	}


}

void init_stream2()
{
	buffoper(SB_PLA_ENA | SB_PLA_RPT);
}

int external_clock()
{
	int n;
	int src[] = { 42, 43, 44, 45, 46, 0 };
	int dst[] = {  0,  0,  0,  0,  0, 0 };

	mute(MUTE);
	sndstatus(SND_RESET); /* Reset sound system */
	setbuffer(SR_PLAY, src, src+sizeof(src));
	setbuffer(SR_RECORD, dst, dst+sizeof(dst));
	devconnect(0x0, 0x1, 1, 1, 0);
	devconnect(0x1, 0x0, 1, 1, 0);
	devconnect(0x2, 0x0, 1, 1, 0);
	devconnect(0x3, 0x0, 1, 1, 0);
	buffoper(0x5); delay(100); buffoper(0x0);
	for (n = 0; (src[n] != 0) && (src[n] == dst[n]); n++);
	mute(MUTE_RESTORE);
	if (src[n]) return 0;
	return 1;
}

