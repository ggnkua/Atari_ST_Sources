/*****************************************************************
*
* SNDBIND.H	Low level Sound function bindings for use with "C"
*		and the added Falcon Sound XBIOS calls.
*
*		Mike Schmal		7/7/92
*
*
* Updates:
*
* 7/13/92 MS  Added buffptr function.
* 7/24/92 MF  Added equates for function parameters
* 1/15/96 MH  SOUND changed to xbios call, first letter to capital
* 1/17/96 MH  Names of some #define constants changed
*
*****************************************************************/



/*
 * soundcmd() 'mode' parameter values
*/

#define	LTATTEN		0
#define	RTATTEN		1
#define	LTGAIN		2
#define	RTGAIN		3
#define	ADDERIN		4
#define	ADCINPUT		5
#define	SETPRESCALE	6



/*
 * SOUND BIOS inquiry
*/

#define	INQUIRE	-1

/*
 * SOUND BIOS Errors
*/

#define	SNDNOTLOCK	-128	;Unlocksnd() returns
#define	SNDLOCKED 	-129 ;Locksnd() returns



/*
 * ADDERIN bit masks
*/

#define ADDERIN_ADC	1
#define ADDERIN_MATRIX	2



/*
 * SETPRESCALE values
*/

#define STE_6K 		0	/* Invalid... won't do 6.25khz samples */
#define STE_12K		1	/* 12.5KHz STE/TT compatible */
#define STE_25K		2	/* 25KHz STE/TT compatible   */
#define STE_50K		3	/* 50KHz STE/TT compatible   */



/*
 * setmode() parameter values
*/

#define STEREO8 	0
#define STEREO16	1
#define MONO8   	2



/*
 * devconnect() source/destination device parameter values
*/

#define ADC		3	/* source parameter is one of these ... */
#define EXTINP 	2
#define DSPXMIT 	1
#define DMAPLAY 	0

#define DAC    	8	/* destination parameter is any combination */
#define EXTOUT 	4	/* of these ... */
#define DSPREC 	2
#define DMAREC 	1	/* e.g.  DAC|DSPREC|DMAREC */

/*
 * devconnect() clock input parameter values
*/

#define	INTERNAL_25M	0	/* internal 25.175MHz clock */
#define	EXT_CLOCK 	1	/* external clock input */
#define	INTERNAL_32M	2	/* internal 32Mhz clock (DSP Dependent) */

/*
 * devconnect() clock prescale parameter values
*/

#define CLK_STE	0	/* STE/TT prescale values... see SETPRESCALE stuff above. */
#define CLK50K 	1
#define CLK33K 	2
#define CLK25K 	3
#define CLK20K 	4
#define CLK16K		5
#define CLK12K		7
#define CLK10K		9
#define CLK8K		11

/*
 * devconnect() handshake protocols
*/

#define HANDSHAKE   	0
#define NO_HANDSHAKE	1

/*
 * Buffoper()
*/

#define PLAY_ENABLE 	1
#define PLAY_REPEAT 	2
#define RECORD_ENABLE	4
#define RECORD_REPEAT	8

/*
 * Dsptristate() inputs
*/

#define ENABLE 	1
#define TRISTATE 	0



/*
 * Falcon sound routines
*/

#define	Locksnd() 		(long)xbios(0x80)
#define	Unlocksnd()		(long)xbios(0x81)
#define	Soundcmd(a,b)		(long)xbios(0x82,a,b)
#define	Setbuffer(a,b,c)	(long)xbios(0x83,a,(int *)b,(int *)c)
#define	Setmode(a)		(long)xbios(0x84,a)
#define	Settrack(a,b)		(long)xbios(0x85,a,b)
#define	Setmontrack(a)		(long)xbios(0x86,a)
#define	Setinterrupt(a,b)	(long)xbios(0x87,a,b)
#define	Buffoper(a)		(long)xbios(0x88,a)
#define	Dsptristate(a,b)	(long)xbios(0x89,a,b)
#define	Gpio(a,b) 		(long)xbios(0x8A,a,b)
#define	Devconnect(a,b,c,d,e)	(long)xbios(0x8B,a,b,c,d,e)
#define	Sndstatus(a)		(long)xbios(0x8C,a)
#define	Buffptr(a)		(long)xbios(0x8D,a)

/*************** end of sndbind.h ****************/
 