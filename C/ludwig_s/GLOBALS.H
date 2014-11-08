/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

	global variable declarations

******************************************************************************/

/* note to myself: !!! marks unfinished code */

	/* doesn't have to be in externs.h */
char copyright[60]= "Ludwig 1.0, Copyright 1988 Hybrid Arts, Inc.";

   /* needed by VDI and AES */
int contrl[12], intin[128], ptsin[128], intout[128], ptsout[128];

	/* for custom mouse/menu/accessory handling */
char *Mstate;				/* pointer to mouse buttons byte */
int *Mousex,*Mousey;		/* pointers to mouse position words */
char deskacc; 			   /* set by newmvec when a desk acc is about to run */
char wait_for;				/* newmvec waiting for L-button state: 0/1 = up/down */
int Downx,Downy;			/* where newmvec saw the L-button go down */
int Upx,Upy;				/* where newmvec saw the L-button go back up */
char Freezex,Freezey;	/* nonzero means don't allow x or y mouse motion */
int menu_lo_x,menu_hi_x,menu_hi_y;				/* menu bar position */
int acc_lo_x,acc_hi_x,acc_lo_y,acc_hi_y;		/* desk accessory position */

	/* saved/restored system */
long savemvec;					/* pointer to normal mouse vector */
long save_spur,save_tran;	/* pointer to normal spurious & transmit vectors */
char savectl_d,savedat_d;	/* timer D settings */
char timer_a,timer_d;		/* set when timers are running */
long save_butv,save_motv;	/* normal butv/motv routines */

	/* copy protection stuff */
int maincrc,mainchksum;

	/* for custom graphics */
long scrbase;          /* pointer to start of physical screen memory */
long Abase;				  /* --> line A variables */
int bytesperline;		  /* # bytes per scan line */
long fontptr;			  /* --> system font data */

	/* screen layout */
char *windptr[NTYPE];		/* window frames */
long windleng[NTYPE];		/* size of window frames: # longs divided by 8 */
char *dialptr[NDIAL];		/* fake dialog boxes */
long dialleng[NDIAL];		/* size of fake dialog boxes: # longs div by 8 */
char *dialname2[NDIAL]=
{	"PDIAL.BL2",	"RDIAL.BL2",	"PRAND.BL2",	"RRAND.BL2"	};
char *dialname3[NDIAL]=
{	"PDIAL.BL3",	"RDIAL.BL3",	"PRAND.BL3",	"RRAND.BL3"	};
int wind2_y[NWIND]= { 19, 114, 209, 304 };	/* window positions (mono) */
int wind1_y[NWIND]= { 11,  58, 105, 152 };	/* window positions (color) */
int *wind_y;					/* --> wind2_y or wind1_y */
int val1_y[NROW]= { 6,15,26,35 };	/* window-relative y-coord of parameters */
int val2_y[NROW]= { 8,24,56,72 };
int tag1_y[NTAG]= { 6,20,35 };
int tag2_y[NTAG]= { 8,40,72 };
int *tag_y;
int *val_y;
int wind_start[NWIND];		/* for each window, start # in P/R series */
int typetags[3]= { 'P', 'R', 'V' };		/* window types displayed as */
char songname[13];
char *wind_seq,*wind_type;		/* point into masterdata */

	/* edit mode */
int editwind;				/* window currently being edited */
int editmode;				/* 0= not editing, 1= editing, 2= fake dial */
PARAM editparam[2];		/* parameter structures for parameters being edited */
int editparnum[2];		/* parameter #s being edited */
int editval[2];			/* edited values */
int dialwind;				/* which window fake dialog box was placed in */
char *editptr[2];			/* pointers to parameters being edited */
int oldval[2];				/* original (unedited) value */
	/* fill mode */
int fillmode,fillwind,fillparnum,fill_y,fill_y2;
PARAM fillparam;

	/* miscellaneous */
int ap_id;						/* application i.d. */
int gl_hand;					/* vdi handle */
int windhndl;					/* window handle */
int messbuf[8];				/* buffer for messages from GEM */
int dummy;						/* place-holder word */
int rez;							/* screen resolution:  1,2 = medium,high */
int debugflag;					/* general purpose debugging int !!! */
int *keyb_head,*keyb_tail;	/* --> keyboard i/o record head and tail */
char record_on;				/* non-0 to enable midi input */
char sysexflag;				/* set during receiving and ignoring sysex */
char runningstat;				/* keep track of running status in midi input */
char midithru,thruchan,thruport;		/* for midi thru */
long timestamp;				/* time-stamp for recording */
int edprchan;					/* midi thru/play channel for pattern editors */
int edpplex,edrtplex;		/* midiplexer outputs for pattern editors */
int edrwith,edpwith;			/* pattern editor links */
char no_dissolve;				/* suppresses hsw dissolve effect */
char play_safe,lazy_mouse;	/* options not saved in file */
int keycmds[20*4]=			/* slightly oversized */
{
	0x26, ALT, LUFILE, LULOAD,		/* scan code, kstate, title, item */
	0x1f, ALT, LUFILE, LUSAVE,
	0x1f, ALT|LSHIFT, LUFILE, LUSNG,
	0x2e, ALT, LUFILE, LUDRIVE,
	0x20, ALT, LUFILE, LUDELETE,
	0x21, ALT, LUFILE, LUFORMAT,

	0x19, 0,	  LUPATTRN, LUPITCH,
	0x13, 0,	  LUPATTRN, LURHYTHM,

	0x14, CTRL, LUTRACKS, LUSUMARY,
	0x32, CTRL, LUTRACKS, LUTSYNC,
	0x1f, CTRL, LUTRACKS, LUSCALES,
	0x2f, CTRL, LUTRACKS, LUVELMAP,
	0x2e, CTRL, LUTRACKS, LUCOPY,
	0x21, CTRL, LUTRACKS, LUFILL,

	0x14, 0,		LUOPTION, LUTEMPO,
	0x39, 0,		LUOPTION, LUPLAY,
	0x39, ALT,	LUOPTION, LUAGAIN,
	0x17, 0,		LUOPTION, LUINIT,

	0,		0,		0,		0					/* marks end of array */
};
int playkeycmds[20*4]=
{
	0x26, ALT, LUFILE, LULOAD,		/* scan code, kstate, title, item */
	0x1f, ALT, LUFILE, LUSAVE,
	0x2e, ALT, LUFILE, LUDRIVE,
	0x20, ALT, LUFILE, LUDELETE,
	0x21, ALT, LUFILE, LUFORMAT,

	0x19, 0,	  LUPATTRN, LUPITCH,
	0x13, 0,	  LUPATTRN, LURHYTHM,

	0x14, CTRL, LUTRACKS, LUSUMARY,
	0x32, CTRL, LUTRACKS, LUTSYNC,
	0x1f, CTRL, LUTRACKS, LUSCALES,
	0x2f, CTRL, LUTRACKS, LUVELMAP,
	0x2e, CTRL, LUTRACKS, LUCOPY,
	0x21, CTRL, LUTRACKS, LUFILL,

	0x14, 0,		LUOPTION, LUTEMPO,
	0x17, 0,		LUOPTION, LUINIT,
	0,		0,		0,		0					/* marks end of array */
};

	/* buffers */
long scrsave;       			/* saved screen + general purpose */
char *seq1data[NSEQ];		/* sequence real-time parameters */
char *nonr1data[NSEQ];		/* sequence non-real-time parameters */
char *masterdata;				/* master real-time parameters */
char *pitch1data[NGRP];		/* user-defined pitch groups */
char *rhyth1data[NGRP];		/* user-defined rhythm groups */
char *seqdata,*nonrdata,*pitchdata,*rhythmdata;
char *segptr[NSEG];
long segleng[NSEG];
char *recstart,*rectail,*recend;	/* midi input */

	/* play mode */
char tempodivs[NTEMPO][8];
char *tranbuf,*tranhead,*trantail;					/* midi transmit buffer */
long *playstart[NSEQ],*playhead[NSEQ],*playtail[NSEQ],*playend[NSEQ];
long masterclock,softclock,nextevent[NSEQ],stop_time,nextclock;
char *notestat;
char throwaway,clockdivider;
char clockdivs[8];
int play_mode;
int vdx[NSEQ];
int xorc_col[NWIND],xorc_row[NWIND];		/* computational xor boxes */
int xorp_col[NWIND],xorp_row[NWIND];		/* now-playing xor boxes */
int xor_lock;										/* if set, don't track xor's */
char mutebyte,midi_sync,play_pause;
char *loopcnt;
int px[NSEQ],rx[NSEQ],pready[NSEQ],rready[NSEQ];

	/* pitch and rhythm data */
char nchords[NSEQ];				/* = 1-32 */
char nnotes[NSEQ][NCHD];		/* = 0-16 */
char notes[NSEQ][NCHD][16];	/* = 0-127 */
	/* notes array also used in saving a song file */
char nntrsts[NSEQ];				/* = 1-32 */
long duration[NSEQ][NCHD];		/* ticks */
char nt_or_rst[NSEQ][NCHD];	/* 0 rest, 1 note */
int legato[NSEQ];					/* legato factor 1-99 */
	/* on-deck copies */
char _nchords[NSEQ];				/* = 1-32 */
char _nnotes[NSEQ][NCHD];		/* = 0-16 */
char _notes[NSEQ][NCHD][16];	/* = 0-127 */
char _nntrsts[NSEQ];				/* = 1-32 */
long _duration[NSEQ][NCHD];	/* ticks */
char _nt_or_rst[NSEQ][NCHD];	/* 0 rest, 1 note */
int _legato[NSEQ];				/* legato factor 1-99 */

	/* stuff needed to make xorp tracking work */
int pxor_p[NSEQ],pxor_r[NSEQ];
int pxor_pp[NSEQ],pxor_rr[NSEQ];
int pxor_ppp[NSEQ],pxor_rrr[NSEQ];
char nchords1[NSEQ],nntrsts1[NSEQ];

	/* hybri-switch */
long mshrinkamt;			/* amount m-shrunk in init, used for switching */
long sw_ptr;				/* pointer to switcher structure */

	/* midiplexer */
int midiplex;			/* midiplexer dma device # (0-7), -1 if no midiplexer */
int DMAadr;									/* DMA address */
long MPtrBbuf,MPtrCbuf,MPtrDbuf;		/* circular buffer addresses */
long MPtrBlim,MPtrClim,MPtrDlim;		/* limits */
long MPtrBhead,MPtrBtail,MPtrChead,MPtrCtail,MPtrDhead,MPtrDtail;
char plexer_on;

	/* copy-protection stuff !!! */

	/* objects in ldsvtree equated to file segments */
int ldsvobj[NSEG]= { LDSVBUT0+0,LDSVBUT0+1,LDSVBUT0+2,LDSVBUT0+3,
							LDSVBUT0+4,LDSVBUT0+5,LDSVBUT0+6,LDSVBUT0+7,
							LDSVBUT0+10,LDSVBUT0+10,LDSVBUT0+8,LDSVBUT0+9 };

	/* pointer to each object tree */
OBJECT *menuaddr,*infoaddr,*fmtaddr,*drivaddr,*ldsvaddr,*grpaddr,*filladdr;
OBJECT *veloaddr,*copyaddr,*scaladdr,*edpaddr,*edraddr,*tempaddr,*trakaddr;
OBJECT *syncaddr,*thruaddr,*sharaddr;

	/* preset scales */
char maj_scale[12]= {0,-1,0,-1,0,0,-1,0,-1,0,-1,0};
char min_scale[12]= {0,-1,0,0,-1,0,-1,0,0,-1,0,-1};
	/* default velocity map */
char def_velmap[8]= {0x0f,0x1f,0x2f,0x3f,0x4f,0x5f,0x6f,0x7f};
	/* chromatic tone names */
char *chromas[12]= { "C","C#","D","D#","E","F","F#","G","G#","A","A#","B" };
char *chromaf[12]= { "C","Db","D","Eb","E","F","Gb","G","Ab","A","Bb","B" };
	/* durations displayable with a single symbol */
int exactdur[10]= { 1, 2, 3, 4, 6, 8, 12, 16, 24, 32 };

/************************************* EOF ***********************************/
