#include <tos.h>
#ifdef DEBUG
#include <stdio.h>
#endif

/* #include "dsp_boot.h" */
/* #include "dsp_dsp.h"  */

#include "mp2info.h"

/* global variables from dsp_bin.c */
extern char dsp_binext[], dsp_binint[];

/* global variables from dsp_dat.c */
extern char dsp_dat[];

/* Function in this module */
void bootdsp(void);

/* Function from dsp_bin.c */
extern long get_bin_len(int);

/* Function from dsp_dat.c */
extern long get_dat_len(void);

/* Function from mp2boot.s */
extern long dsp_load(void);

/* global variable from mp2audio.c */
extern int ext;

/* global variable from mp2info.c */
extern MP2INFO mp2info;

/*
/* global variable */
long dsp_codebin,dsp_bootbin;
int dsp_codelen,dsp_bootlen;
*/

void bootdsp()
{
	char *dsp_binptr;
	long dsp_binsize,dsp_datsize;
	
	if((mp2info.sample_frequency==44100L) && !ext)
	{
		dsp_binptr=dsp_binint; /* use internal clock */
		dsp_binsize = get_bin_len(0)/3;
/*		dsp_binsize=((long)sizeof(dsp_binint))/3; */
	}
	else
	{
		dsp_binptr=dsp_binext; /* use external clock */
		dsp_binsize = get_bin_len(1)/3;
/*		dsp_binsize=((long)sizeof(dsp_binext))/3; */
	}

/*
	dsp_codebin=(long)dsp_binptr;
	dsp_codelen=(int)dsp_binsize;
	dsp_bootbin=(long)dsp_bootstrap;
	dsp_bootlen=((int)sizeof(dsp_bootstrap))/3;
	Supexec(dsp_load);
*/

	Dsp_ExecProg(dsp_binptr, dsp_binsize, 0x42);


#ifdef DEBUG
	printf("DSP bootstrapped\n");
#endif
	
	dsp_datsize=get_dat_len()/4;
	Dsp_BlkUnpacked((long *)dsp_dat, dsp_datsize, 0, 0);
#ifdef DEBUG
	printf("DSP data uploaded\n");
#endif
}

