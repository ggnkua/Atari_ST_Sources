/*
         Name: Sound program
         Type: C and DSP 56001 assembler
       Author: Fredrik Noring
      Version: 0.00á
 Date Entered: 31 October 1994
  Last Change: 20 November 1994

  Description: This program can replay and apply different effects
               on sound samples (DVS) or ADC.
*/

#define VERSION "v0.00á"
#define HEAD_BUF 256
#define SOUND_BUF 400*1024
#define DSP_LOD "sound.lod"

#define WORD short
#define LONG int

#include <math.h>
#include <float.h>
#include <stdio.h>
#include <falcon.h>
#include "dsp_bin.h"

struct {
	char *file_name;
	int prescale;
	int frequency;
	enum{replay, record, thru} function;
	struct {
		long mono, karaoke, flange;
	} dsp;
} options = {"sample.smp", (int) CLK50K, (int) 50033, thru, 0x000082, 0x000083, 0x000084};

typedef struct {
	char magic[6];	/* "DVSM" */
	WORD headlen;	/* Headlen in Bytes */
	WORD freq;		/* Sample freqency 0=8kHz 7=50kHz */
	char pack;		/* 0 unpacked, 2=DVS packmethod */
	char mode;		/* 0=Stereo 8Bit,1=Stereo 16Bit,2=Mono 8Bit */
	LONG blocklen;	/* if pack=1: Length of a packed block */
} DVSMHEAD;

int dsp_abil;			/* DSP ability */
char head[HEAD_BUF];		/* File header */
char sound[SOUND_BUF];		/* File buffer */

long filelength(FILE *fp)
{
	long size;
	long offset;

	offset = ftell(fp);
	fseek(fp, 0, 2);
	size = ftell(fp);
	fseek(fp, offset, 0);

return size;
}

long fileleft(FILE *fp)
{
	long size;
	long offset;

	offset = ftell(fp);
	fseek(fp, 0, 2);
	size = ftell(fp) - offset;
	fseek(fp, offset, 0);

return size;
}

void set_options()
{
	switch(options.prescale) {
		case CLK8K:  options.frequency = 8195; break;
		case CLK10K: options.frequency = 9834; break;
		case CLK12K: options.frequency = 12292; break;
		case CLK16K: options.frequency = 16490; break;
		case CLK20K: options.frequency = 20770; break;
		case CLK25K: options.frequency = 24585; break;
		case CLK33K: options.frequency = 33880; break;
		case CLK50K: options.frequency = 50033; break;
	}
}

void init_sound_system()
{
	char lod_buf[30000];
	WORD ltatten, rtatten, ltgain, rtgain;

	/* Lock Sound System */
	locksnd();

	/* Save old settings */
	ltatten = soundcmd(LTATTEN, -1);
	rtatten = soundcmd(RTATTEN, -1);
	ltgain = soundcmd(LTGAIN, -1);
	rtgain = soundcmd(RTGAIN, -1);
	/* Reset sound system */
	sndstatus(1);
	/* Restore old settings */
	soundcmd(LTATTEN, ltatten);
	soundcmd(RTATTEN, rtatten);
	soundcmd(LTGAIN, ltgain);
	soundcmd(RTGAIN, rtgain);

	/* Set some necessary parameters */
	settracks(0,0);
	setmontracks(0);
	setmode(STEREO16);
	setbuffer(0,sound,sound+sizeof(sound));

	soundcmd(ADDERIN, 0x2);
	soundcmd(ADCINPUT, 0x0);

	/* DSP side */
	dsptristate(ENABLE, ENABLE);
	dsp_abil = Dsp_RequestUniqueAbility();
/*	Dsp_LoadProg(DSP_LOD, dsp_abil, lod_buf);	*/
	Dsp_ExecProg(dsp_bin, sizeof(dsp_bin)/3, dsp_abil);

	/* Connect DMA playback with DSP and then to DAC */
	switch (options.function) {
		case replay:
			devconnect(DMAPLAY, DSPRECV, CLK25M, options.prescale, NO_SHAKE);
			devconnect(DSPXMIT, DAC, CLK25M, options.prescale, NO_SHAKE);
			break;
		case record:
			break;
		case thru:
			devconnect(ADC, DSPRECV, CLK25M, options.prescale, NO_SHAKE);
			devconnect(DSPXMIT, DAC, CLK25M, options.prescale, NO_SHAKE);
			break;
	}

	Dsp_BlkUnpacked(&options.dsp.mono, 1L, 0L, 0L);
	Dsp_BlkUnpacked(&options.dsp.karaoke, 1L, 0L, 0L);
	Dsp_BlkUnpacked(&options.dsp.flange, 1L, 0L, 0L);
}

void exit_sound_system()
{
	WORD ltatten, rtatten, ltgain, rtgain;

	/* Save old settings */
	ltatten = soundcmd(LTATTEN, -1);
	rtatten = soundcmd(RTATTEN, -1);
	ltgain = soundcmd(LTGAIN, -1);
	rtgain = soundcmd(RTGAIN, -1);
	/* Reset sound system */
	sndstatus(1);
	/* Restore old settings */
	soundcmd(LTATTEN, ltatten);
	soundcmd(RTATTEN, rtatten);
	soundcmd(LTGAIN, ltgain);
	soundcmd(RTGAIN, rtgain);

	/* Set some necessary parameters */
	settracks(0,0);
	setmontracks(0);
	setmode(STEREO16);
	soundcmd(ADDERIN, 0x2);
	soundcmd(ADCINPUT, 0x0);
	devconnect(ADC, DAC, CLK25M, CLK50K, 1);

	/* Unlock Sound System */
	unlocksnd();
}

void load_dsample(char sample[], FILE *fp, long *f_left, long s_left)
{
	long n=0, r;

	while (s_left > 0) {
		if (*f_left > 0) {
			r = 16384;
			if (s_left < r) r = (int) s_left;
			if (*f_left < r) r = (int) *f_left;
			fread(sample+n, r, 1, fp);
			*f_left -= r; s_left -= r; n += r;
		}
		if (*f_left == 0) {
			for (r=0; r <= s_left; r++)
				sample[n+r] = 0;
			s_left = 0;
		}
	}
}

int replay_sample(FILE *fp, long f_size)
{
	long f_left;

	SndBufPtr pointer;

	f_left = f_size;
	init_sound_system();
	load_dsample(sound, fp, &f_left, sizeof(sound)/2);
	printf("\rPlayback sound\n");
	buffoper(0x3);
	load_dsample(sound+sizeof(sound)/2, fp, &f_left, sizeof(sound)/2);
	buffptr(&pointer);
	while(pointer.play < sound+sizeof(sound)/2)
		buffptr(&pointer);

	while (f_left > 0) {
		buffptr(&pointer);
		while(pointer.play < sound+sizeof(sound)/2)
			buffptr(&pointer);
		printf("\r%lds   ", (f_size-f_left)/(4*options.frequency)); fflush(stdout);
		load_dsample(sound, fp, &f_left, sizeof(sound)/2);

		buffptr(&pointer);
		while(pointer.play > sound+sizeof(sound)/2)
			buffptr(&pointer);
		printf("\r%lds   ", (f_size-f_left)/(4*options.frequency)); fflush(stdout);
		load_dsample(sound+sizeof(sound)/2, fp, &f_left, sizeof(sound)/2);
		if (!f_left) {
			fseek(fp, 0, 0);
			f_left = filelength(fp);
		}
	}
	buffptr(&pointer);
	while(pointer.play < sound+sizeof(sound)/2 && !Bconstat(2))
		buffptr(&pointer);
	load_dsample(sound, fp, &f_left, sizeof(sound)/2);
	buffoper(0x0);
	exit_sound_system();
return(0);
}

int replay_file() {
	FILE *fp;
	long size;

	/* Open file */
	if ((fp = fopen(options.file_name, "rb")) == NULL) {
		fprintf(stderr, "Sound: Cannot open file \"%s\".\n", options.file_name);
		return(-1);
	}

	/* Get the size of the file to load */
	size = filelength(fp);

	/* Get file format */
	fread(head, 256, 1, fp);	/* Read header */
	rewind(fp);

	/* Identify format */
	if (!strncmp("DVSM", head, sizeof("DVSM")-1)) {
		DVSMHEAD dvsm;
		fread(&dvsm, sizeof(dvsm), 1, fp);	/* Read DVSM header */
		switch(dvsm.freq) {
			case 0: options.prescale = CLK8K; break;
			case 1: options.prescale = CLK10K; break;
			case 2: options.prescale = CLK12K; break;
			case 3: options.prescale = CLK16K; break;
			case 4: options.prescale = CLK20K; break;
			case 5: options.prescale = CLK25K; break;
			case 6: options.prescale = CLK33K; break;
			case 7: options.prescale = CLK50K; break;
		}
		fseek(fp, (int) dvsm.headlen, 0);
	}

	set_options();
	printf("\rFile size: %ldkb\n", size/1024);
	printf("\rSound buffer: %ldkb\n", sizeof(sound)/1024);
	printf("\rEstimated replay time: %lds\n", size/(4*options.frequency));
	printf("\rReading %s into main memory system.\n", options.file_name);

	replay_sample(fp, fileleft(fp));
	fclose(fp);
return(0);
}

int main(argc, argv)
int argc;
char *argv[];
{
	long i;

	printf("\rDSP 56001 Audio Program.\n");

	/* Read parameters */
	for (i=1; i<argc; i++) {
		if (*argv[i] != '-') {
			options.file_name = argv[i];
			if (options.function == thru)
				options.function = replay;
		}
		else if (!strcmp("-thru", argv[i]))
			options.function = thru;
		else if (!strcmp("-replay", argv[i]))
			options.function = replay;
		else if (!strcmp("-record", argv[i]))
			options.function = record;
		else if (!strncmp("-dsp:", argv[i], sizeof("-dsp:")-1)) {
			int j=sizeof("-dsp:")-1;
			while (*(argv[i]+j) != '\0') {
				switch (*(argv[i]+j)) {
					case 'm': options.dsp.mono |= 0xffff00; break;
					case 'k': options.dsp.karaoke |= 0xffff00; break;
					case 'f': options.dsp.flange |= 0xffff00; break;
				}
				j++;
			}
		}
	}

	switch (options.function) {
		case replay: replay_file(); break;
		case thru: init_sound_system(); break;
	}

/*	printf("\rZzzzzzzzzz\n");
	getchar();	*/
return(0);
}

