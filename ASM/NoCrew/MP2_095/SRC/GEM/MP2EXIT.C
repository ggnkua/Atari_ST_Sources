#include <tos.h>

#include "snddefs.h"
#include "mp2audio.h"

/* Functions in this module */
void exit_replay(void);
void pause_replay(void);
void quit_stream(void);

/* global variables from mp2audio.c */
extern int replay,fd,file_open;

/* Function from mp2extra.c */
extern void mute(int mode);

/* Function from mp2file.c */
extern void reset_file(int fd);

void exit_replay()
{
	quit_stream();
/*	close_file(fd); */
	reset_file(fd);
	replay = 0;
}

void pause_replay()
{
	Dsp_Hf0(1);				/* tell DSP to pause */
	replay = 0;
}

void quit_stream()
{
	mute(MUTE);
	sndstatus(SND_RESET); /* Reset sound system */
	mute(MUTE_RESTORE);
}
