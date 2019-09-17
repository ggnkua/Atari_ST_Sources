/***********************************************************************
** 
** Lattice C WavePlay() Xbios Binding - opcode 0xa5;
** Original binding by Scott Sanders/SDS.
** Extra comments by Anthony Jacques & Xav for KPP.
**     (http://www.cs.man.ac.uk/~jacquesa/)
**     (http://www.compsoc.man.ac.uk/~xav)
**
**
** Function is present ONLY if the 'SAM\0' cookie is in the cookie
** jar. This should be checked prior to calling these functions.
** To determine the presence of SAM, use something like:
**
**    sam_present=get_cookie(SAM_COOKIE, NULL);
**
************************************************************************
**
** short WavePlay(short flags,    /* Flags (see WP_...)         */
**                long rate,      /* See below for valid rates  */
**                void *sound,    /* Pointer to start of sound  */
**                long length);   /* Length in _bytes_!         */
**
** This plays the given sample at the given rate with the
** given properties.
**
** Returns:
**   0 (WP_OK)      = Sound played...everything ok.
**   1 (WP_NOSOUND) = No error, but sound not played
**  -1 (WP_ERROR)   = An error occurred
**
************************************************************************
**
** short WavePlayGlobal(long global); /* see AG_ list below      */
** 
**
** This plays the globally defined system-wide sample for
** the given event (QUIT, SAVE etc). Note that your application
** should have this event flagged in an SAA for this to take
** effect.
**
** Returns:
**   0 (WP_OK)      = Sound played...everything ok.
**   1 (WP_NOSOUND) = No error, but sound not played
**  -1 (WP_ERROR)   = An error occurred
**
************************************************************************
**
** short WavePlayMacro(char *cookie, /* 4-letter cookie         */
**                     long macro);  /* global number 0-15      */
** 
** This plays an application macro, as defined in an
** application's SAA file.
**
** Returns:
**   0 (WP_OK)      = Sound played...everything ok.
**   1 (WP_NOSOUND) = No error, but sound not played
**  -1 (WP_ERROR)   = An error occurred
**
************************************************************************
**
** = Note =
**
** WavePlayMacro() and WavePlayGlobal() are actually variations of 
** the same call as WavePlay(), but  this should be transparent to
** the application programmer.
**
***********************************************************************/

#ifndef _WAVEPLAY_H_
#define _WAVEPLAY_H_

/* error messages */
#define WP_OK        0
#define WP_ERROR    -1
#define WP_NOSOUND   1

/* sample format */
#define WP_STEREO   0x00
#define WP_MONO     0x01

#define WP_8BIT     0x00
#define WP_16BIT    0x02

/* SAM can use AFM if installed */
#define WP_NOUSEDSP 0x00
#define WP_USEDSP   0x04

/* used by the WavePlayMacro() and WavePlayGlobal() calls */
#define WP_MACRO    0x100

/* Falcon compatible frequencies */
#ifndef ACT_CLK50K
#define ACT_CLK50K  49170
#define ACT_CLK33K  33880
#define ACT_CLK25K  24585
#define ACT_CLK20K  20770
#define ACT_CLK16K  16490
#define ACT_CLK12K  12292
#define ACT_CLK10K  9834
#define ACT_CLK8K   8195
#endif

/* STe/TT Rates */
#ifndef TT_CLK50K
#define TT_CLK50K   50066L
#define TT_CLK25K   25033L
#define TT_CLK12K   12517L
#define TT_CLK6K    6258L    /* NOTE: this isn't valid on a Falcon */
#endif

/* both = 'SAM\0' */
#define SAM_COOKIE  0x53414D00
#define APP_GLOBAL  (char *)0x53414D00

/* the 'application globals' used for system-wide sounds. */
#define AG_FIND     0L
#define AG_REPLACE  1L
#define AG_CUT      2L
#define AG_COPY     3L
#define AG_PASTE    4L
#define AG_DELETE   5L
#define AG_HELP     6L
#define AG_PRINT    7L
#define AG_SAVE     8L
#define AG_ERROR    9L
#define AG_QUIT     10L

/* _sslll = xbios function call */
#pragma inline d0=_sslll((short),(short),,,)    {register d2,a2; "4e4e";}

/* The WavePlay xbios call, and some macros using it. */
#define WavePlay(a,b,c,d)   _sslll(0xA5,a,b,c,d)
#define WavePlayGlobal(a)   _sslll(0xA5, WP_MACRO, 0L, APP_GLOBAL, a);
#define WavePlayMacro(a,b)  _sslll(0xA5, WP_MACRO, 0L, (char *)a, (long)b);

#endif
