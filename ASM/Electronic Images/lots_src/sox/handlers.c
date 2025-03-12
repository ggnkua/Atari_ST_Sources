/*
 * July 5, 1991
 * Copyright 1991 Lance Norskog And Sundry Contributors
 * This source code is freely redistributable and may be used for
 * any purpose.  This copyright notice must be maintained. 
 * Lance Norskog And Sundry Contributors are not responsible for 
 * the consequences of using this software.
 */

#include "st.h"

/*
 * Sound Tools file format and effect tables.
 */

/* File format handlers. */

char *rawnames[] = {
	"raw",
/*?	"sou", /* */
	(char *) 0
};
extern rawstartread(), rawread();
extern rawstartwrite(), rawwrite(), rawstopwrite();

char *vocnames[] = {
	"voc",
	(char *) 0
};
extern vocstartread(), vocread(), vocstopread();
extern vocstartwrite(), vocwrite(), vocstopwrite();

char *aunames[] = {
	"au",
#ifdef	NeXT
	"snd",
#endif
	(char *) 0
};
extern austartread();
extern austartwrite(), auwrite(), austopwrite();

char *aiffnames[] = {
	"aiff",
	"aif",
	(char *) 0
};
extern aiffstartread(), aiffread(), aiffstopread();
extern aiffstartwrite(), aiffwrite(), aiffstopwrite();

char *svxnames[] = {
	"8svx",
	"iff",
	(char *) 0
};
extern svxstartread(), svxread(), svxstopread();
extern svxstartwrite(), svxwrite(), svxstopwrite();

char *hcomnames[] = {
	"hcom",
	(char *) 0
};
extern hcomstartread(), hcomread(), hcomstopread();
extern hcomstartwrite(), hcomwrite(), hcomstopwrite();

char *sndtnames[] = {
	"sndt",
#ifdef	DOS
	"snd",
#endif
	(char *) 0
}; 
extern sndtstartread();
extern sndtstartwrite(), sndtwrite(), sndtstopwrite();

char *sndrnames[] = {
	"sndr",
	(char *) 0
};
extern sndrstartwrite();

char *ubnames[] = {
	"ub",
	"sou",
	"fssd",
#ifdef	MAC
	"snd",
#endif
	(char *) 0
};
extern ubstartread();
extern ubstartwrite();

char *sbnames[] = {
	"sb",
	(char *) 0
};
extern sbstartread();
extern sbstartwrite();

char *uwnames[] = {
	"uw",
	(char *) 0
};
extern uwstartread();
extern uwstartwrite();

char *swnames[] = {
	"sw",
	(char *) 0
};
extern swstartread();
extern swstartwrite();

char *ulnames[] = {
	"ul",
	(char *) 0
};
extern ulstartread();
extern ulstartwrite();


char *sfnames[] = {
	"sf",
	(char *) 0
};
extern sfstartread();
extern sfstartwrite();

char *wavnames[] = {
	"wav",
	(char *) 0
};
extern wavstartread(), wavread();
extern wavstartwrite(), wavwrite(), wavstopwrite();

#if	defined(BLASTER) || defined(SBLAST)
char *sbdspnames[] = {
	"sbdsp",
	(char *) 0
};
extern sbdspstartread(), sbdspread(), sbdspstopread();
extern sbdspstartwrite(), sbdspwrite(), sbdspstopwrite();
#endif

char *smpnames[] = {
	"smp",
	(char *) 0,
};

extern smpstartread(), smpread(), smpwrite();
extern smpstartwrite(), smpstopwrite();

char *autonames[] = {
	"auto",
	(char *) 0,
};

extern autostartread();
extern autostartwrite();

extern nothing();

EXPORT format_t formats[] = {
	{autonames, autostartread, nothing, nothing,	/* Guess from header */
		autostartwrite, nothing, nothing},	/* patched run time */
	{smpnames, smpstartread, smpread, nothing,	/* SampleVision sound */
		smpstartwrite, smpwrite, smpstopwrite},	/* Turtle Beach */
	{rawnames, rawstartread, rawread, nothing, 	/* Raw format */
		rawstartwrite, rawwrite, nothing},
	{vocnames, vocstartread, vocread, vocstopread,  /* Sound Blaster .VOC */
		vocstartwrite, vocwrite, vocstopwrite},
	{aunames, austartread, rawread, nothing, 	/* SPARC .AU w/header */
		austartwrite, auwrite, austopwrite},	
	{ubnames, ubstartread, rawread, nothing, 	/* unsigned byte raw */
		ubstartwrite, rawwrite, nothing},	/* Relies on raw */
	{sbnames, sbstartread, rawread, nothing, 	/* signed byte raw */
		sbstartwrite, rawwrite, nothing},	
	{uwnames, uwstartread, rawread, nothing, 	/* unsigned word raw */
		uwstartwrite, rawwrite, nothing},	
	{swnames, swstartread, rawread, nothing, 	/* signed word raw */
		swstartwrite, rawwrite, nothing},
	{ulnames, ulstartread, rawread, nothing, 	/* u-law byte raw */
		ulstartwrite, rawwrite, nothing},	
	{aiffnames, aiffstartread, rawread, nothing,    /* SGI/Apple AIFF */
		aiffstartwrite, aiffwrite, aiffstopwrite},
	{svxnames, svxstartread, svxread, svxstopread,      /* Amiga 8SVX */
		svxstartwrite, svxwrite, svxstopwrite},
	{hcomnames, hcomstartread, hcomread, hcomstopread, /* Mac FSSD/HCOM */
		hcomstartwrite, hcomwrite, hcomstopwrite},
	{sfnames, sfstartread, rawread, nothing, 	/* IRCAM Sound File */
		sfstartwrite, rawwrite, nothing},	/* Relies on raw */
	{sndtnames, sndtstartread, rawread, nothing,    /* Sndtool Sound File */
		sndtstartwrite, sndtwrite, sndtstopwrite},
	{sndrnames, sndtstartread, rawread, nothing,    /* Sounder Sound File */
		sndrstartwrite, rawwrite, nothing},
	{wavnames, wavstartread, wavread, nothing, 	/* Windows 3.0 .wav */
		wavstartwrite, wavwrite, wavstopwrite},	
#if	defined(BLASTER) || defined(SBLAST)
	/* 386 Unix sound blaster players.  No more of these, please! */
	{sbdspnames, sbdspstartread, sbdspread, sbdspstopread, 	/* /dev/sbdsp */
		sbdspstartwrite, sbdspwrite, sbdspstopwrite},	
#endif
	0
};

/* Effects handlers. */

extern null_drain();		/* dummy drain routine */

extern copy_getopts(), copy_start(), copy_flow(), copy_stop();
extern avg_getopts(), avg_start(), avg_flow(), avg_stop();
extern pred_getopts(), pred_start(), pred_flow(), pred_stop();
extern stat_getopts(), stat_start(), stat_flow(), stat_stop();
extern vibro_getopts(), vibro_start(), vibro_flow(), vibro_stop();
extern band_getopts(), band_start(), band_flow(), band_stop();
extern lowp_getopts(), lowp_start(), lowp_flow(), lowp_stop();
extern echo_getopts(), echo_start(), echo_flow(), echo_drain(), echo_stop();
extern rate_getopts(), rate_start(), rate_flow(), rate_stop();
extern reverse_getopts(), reverse_start(), 
       reverse_flow(), reverse_drain(), reverse_stop();

/*
 * EFF_CHAN means that the number of channels can change.
 * EFF_RATE means that the sample rate can change.
 * The first effect which can handle a data rate change, stereo->mono, etc.
 * is the default handler for that problem.
 * 
 * EFF_MCHAN just means that the effect is coded for multiple channels.
 */

EXPORT effect_t effects[] = {
	{"copy", EFF_MCHAN, 
		copy_getopts, copy_start, copy_flow, null_drain, nothing},
	{"avg", EFF_CHAN, 
		avg_getopts, avg_start, avg_flow, null_drain, avg_stop},
	{"pred", 0,
		pred_getopts, pred_start, pred_flow, null_drain, pred_stop},
	{"stat", EFF_MCHAN, 
		stat_getopts, stat_start, stat_flow, null_drain, stat_stop},
	{"vibro", 0, 
		vibro_getopts, vibro_start, vibro_flow, null_drain, nothing},
	{"echo", 0, 
		echo_getopts, echo_start, echo_flow, echo_drain, echo_stop},
	{"band", 0, 
		band_getopts, band_start, band_flow, null_drain, band_stop},
	{"lowp", 0, 
		lowp_getopts, lowp_start, lowp_flow, null_drain, lowp_stop},
	{"rate", EFF_RATE, 
		rate_getopts, rate_start, rate_flow, null_drain, nothing},
	{"reverse", 0, 
		reverse_getopts, reverse_start, 
		reverse_flow, reverse_drain, reverse_stop},
	0
};

