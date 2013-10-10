/* FALCON new functions */

extern long xbios();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* DSP XBIOS functions (trap #14) */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

#define	Dsp_DoBlock(a,b,c,d)			(void) xbios(96,a,b,c,d)
#define	Dsp_BlkHandShake(a,b,c,d)		(void) xbios(97,a,b,c,d)
#define	Dsp_BlkUnpacked(a,b,c,d)		(void) xbios(98,a,b,c,d)
#define	Dsp_InStream(a,b,c,d)			(void) xbios(99,a,b,c,d)
#define	Dsp_OutStream(a,b,c,d)			(void) xbios(100,a,b,c,d)
#define	Dsp_IOStream(a,b,c,d,e,f)		(void) xbios(101,a,b,c,d,e,f)
#define	Dsp_RemoveInterrupts(a)			(void) xbios(102,a)
#define	Dsp_GetWordSize()				(int)  xbios(103)
#define	Dsp_Lock()						(int)  xbios(104)
#define	Dsp_Unlock()					(void) xbios(105)
#define	Dsp_Available(a,b)				(void) xbios(106,a,b)
#define	Dsp_Reserve(a,b)				(int) xbios(107,a,b)
#define	Dsp_LoadProg(a,b,c)				(int) xbios(108,a,b,c)
#define	Dsp_ExecProg(a,b,c)				(void) xbios(109,a,b,c)
#define	Dsp_ExecBoot(a,b,c)				(void) xbios(110,a,b,c)
#define	Dsp_LodToBinary(a,b)			(long) xbios(111,a,b)
#define	Dsp_TriggerHC(a)				(void) xbios(112,a)
#define	Dsp_RequestUniqueAbility()		(int)  xbios(113)
#define	Dsp_GetProgAbility()			(int)  xbios(114)
#define	Dsp_FlushSubroutines()			(void) xbios(115)
#define	Dsp_LoadSubroutine(a,b,c)		(int)  xbios(116,a,b,c)
#define	Dsp_InqSubrAbility(a)			(int)  xbios(117,a)
#define	Dsp_RunSubroutine(a)			(int)  xbios(118,a)
#define	Dsp_Hf0(a)						(int)  xbios(119,a)
#define	Dsp_Hf1(a)						(int)  xbios(120,a)
#define	Dsp_Hf2()						(int)  xbios(121)
#define	Dsp_Hf3()						(int)  xbios(122)
#define	Dsp_BlkWords(a,b,c,d)			(void) xbios(123,a,b,c,d)
#define	Dsp_BlkBytes(a,b,c,d)			(void) xbios(124,a,b,c,d)
#define	Dsp_HStat()						(char) xbios(125)
#define Dsp_SetVectors(a,b)				(void) xbios(126,a,b)

/* ~~~~~~~~~~ */
/* AJOUTS AES */
/* ~~~~~~~~~~ */

typedef struct _menu
{
   OBJECT *mn_tree;			/* Object tree of the menu  */
   int	  mn_menu;			/* Parent of the menu items */
   int    mn_item;			/* Starting menu item       */
   int    mn_scroll;		/* scroll flag for the menu */
   int    mn_keystate;		/* CTRL, ALT, SHIFT Keystate*/
}MENU;


/* Structure for the Menu Settings */
typedef struct _mn_set
{
   int    Display;		/* The display delay      */
   int    Drag;			/* The drag delay         */
   int    Delay;		/* The Arrow Delay        */
   long   Speed;		/* The scroll speed delay */
   int    Height;		/* The menu scroll height */
}MN_SET;


int  menu_popup( MENU *Menu, int xpos, int ypos, MENU *MData );
int  menu_attach( int flag, OBJECT *tree, int item, MENU *Menu );
int  menu_istart( int flag, OBJECT *tree, int menu, int item );
int  menu_settings( int flag, MN_SET *Values );

/* ~~~~~ */
/* VIDEO */
/* ~~~~~ */

#define Vsetmode(a)  	(int)xbios(88,a)
#define mon_type(a) 	(int)xbios(89)
#define VsetSync(a) 	(void)xbios(90,a)
#define VgetSize(a)	 	(long)xbios(91,a)
#define VsetRGB(a,b,c)	(void)xbios(93,a,b,c)
#define VgetRGB(a,b,c)  (void)xbios(94,a,b,c)
#define VsetMask(a,b)   (void)xbios(150,a,b)

#define VERTFLAG    0x100
#define STMODES     0x80
#define OVERSCAN    0x40
#define PAL     	0x20
#define VGA     	0x10
#define TV      	0

#define COL80       0x8
#define COL40       0
#define NUMCOLS     7   /* This is the bit mask for bit/plane numbers */

#define BPS16       4
#define BPS8        3
#define BPS4        2
#define BPS2        1
#define BPS1        0

/* ~~~~~ */
/* SOUND */
/* ~~~~~ */

#define	INQUIRE		-1

#define	LTATTEN		0
#define	RTATTEN		1
#define	LTGAIN		2
#define	RTGAIN		3
#define	ADDERIN		4
#define	ADCINPUT	5
#define	SETPRESCALE	6

#define	ADC			3
#define	EXTINP		2
#define	DSPXMIT		1
#define	DMAPLAY		0

#define	DAC			0x8
#define	EXTOUT		0x4
#define	DSPRECV		0x2
#define	DMAREC		0x1

#define	STEREO8		0
#define	STEREO16	1
#define	MONO8		2

#define	ENABLE		1
#define	TRISTATE	0

#define	PLAY_ENABLE	0x1
#define	PLAY_REPEAT	0x2
#define	RECORD_ENABLE	0x4
#define	RECORD_REPEAT	0x8

#define PLAY		0
#define	RECORD		1

#define	M25_CLK		0
#define	EXT_CLK		1
#define	M32_CLK		2

#define	CLK50K		1
#define	CLK33K		2
#define	CLK25K		3
#define	CLK20K		4
#define	CLK16K		5
#define	CLK12K		7
#define	CLK10K		9
#define	CLK8K		11

#define	ACT_CLK50K	49170
#define	ACT_CLK33K	33880
#define	ACT_CLK25K	24585
#define	ACT_CLK20K	20770
#define	ACT_CLK16K	16490
#define	ACT_CLK12K	12292
#define	ACT_CLK10K	9834
#define	ACT_CLK8K	8195

#define	SNDNOTLOCK	-128
#define	SNDLOCKED	-129

#define	locksnd()			xbios(0x80)
#define	unlocksnd()			xbios(0x81)
#define	soundcmd(a,b)		xbios(0x82,a,b)
#define	setbuffer(a,b,c)	xbios(0x83,a,b,c)
#define	setmode(a)			xbios(0x84,a)
#define	settrack(a,b)		xbios(0x85,a,b)
#define	setmontrack(a)		xbios(0x86,a)
#define	setinterrupt(a,b)	xbios(0x87,a,b)
#define	buffoper(a)			xbios(0x88,a)
#define	dsptristate(a,b)	xbios(0x89,a,b)
#define	gpio(a,b)			xbios(0x8A,a,b)
#define	devconnect(a,b,c,d,e)	xbios(0x8B,a,b,c,d,e)
#define	sndstatus(a)		xbios(0x8C,a)
#define	buffptr(a)			xbios(0x8D,a)







