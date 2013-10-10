/******************************************************************************

                                    Ludwig

                                      by
                                  Tom Bajoras

	DEFINE'd things

******************************************************************************/

/* note to myself: !!! marks unfinished code */

   /* Initialization error messages */
#define BADINIT   "[1][Cannot initialize|this application.][Abort]"
#define BADRSRC   "[1][Cannot load resource file.][Abort]"
#define BADREZ    "[1][Screen resolution must|be set to medium.][Abort]"
#define BADWIND   "[1][Cannot open this|application's window.][Abort]"
#define BADSCR    "[1][Cannot load SCREEN data.][Abort]"
#define BADMEM    "[1][Not enough memory!][Abort]"

	/* disk i/o error messages */
#define BADFMT    "[1][Disk formatting has failed.][Cancel]"
#define BADDEL1  "[1][Cannot delete file|"
#define BADDEL2  "][Cancel]"
#define BADOPEN1  "[1][Cannot open file|"
#define BADOPEN2  "][Cancel]"
#define BADREAD1  "[1][Cannot read file "
#define BADREAD2	"|or, it is the wrong kind|of file.][Cancel]"
#define BADMAGIC  "[1][This is not a Ludwig file.][Cancel]"
#define BADNSEG	"[1][This file is damaged, or|it is the wrong kind of file.]\
[Cancel]"
#define BADCREAT1 "[1][Cannot create file|"
#define BADCREAT2 "][Cancel]"
#define BADWRITE1 "[1][Cannot save to file|"
#define BADWRITE2 "][Cancel]"
#define BADSNG		"[1][Write error occurred|while saving SNG file.][Abort]"

	/* parsing error messages */
#define BADGRPN "[1][Pattern number must be 00-95.][Try Again]"
#define BADSCLN "[1][Scale number must be 1-8.][Try Again]"
#define BADVEL "[1][Velocity must be 1-127.][Try Again]"
#define BADACCNT "[1][Accent must be 0-126.][Try Again]"
#define BADMIDICH "[1][MIDI Channel must|be 1-16.][Try Again]"

	/* play mode error messages */
#define BADPLAY "[1][Play buffer is full.][Stop]"
#define BADMIDI "[1][MIDI buffer overflowed.|Music is too dense or|too fast.]\
[Stop]"
#define BADSTART "[1][Every pitch and rhythm series|must begin with either|\
a U or ?, or + followed by|a U or ?.][Stop]"
#define BADLOOP	"[1][Empty loop!  You can't have|a < right after > or|\
at the start of a series][Stop]"

	/* other error messages */
#define BADMIDINP "[1][MIDI buffer overflowed.][Cancel]"
#define BADRECDUR "[1][Duration cannot exceed|a whole note/rest.][Cancel]"
#define BADACCESS	"[1][A desk accessory has stolen|memory.  Suggest you quit|\
now, find the offender and|drag him to the trash can.][Good Idea]"

	/* version messages */
#define DEMOMSG "[3][Ludwig 1.0 demo version:|This function not available.]\
[Sorry]"
#define DEMOMSG2 "[3][\
          Ludwig 1.0          |\
  Copyright 1988 Hybrid Arts  |\
         Demo version         ]\
[Demo]"

   /* warning messages */
#define CHEKFMT "[3][Formatting a disk|will erase all files on it.][OK|Cancel]"
#define CHEKDEL1 "[3][Delete file "
#define CHEKDEL2 " ?][Delete|Cancel]"
#define CHEKREPL1 "[3][Replace file "
#define CHEKREPL2 " ?][Replace|Cancel]"
#define CHEKINIT  "[3][Initialize pattern|"
#define CHEKYESNO " ?][Yes|No]"
#define CHEKFROM	"[3][Copy pattern|"
#define CHEKTO		"|to pattern|"
#define CHEKSFRM	"[3][Copy scale "
#define CHEKSTO	"|to scale "
#define CHEKQUIT	"[3][Exiting Ludwig will cause the|contents of the play \
buffer|to be lost.  Click on OK|only if you don't mind this.][OK|Cancel]"
#define CHEKPLAY	"[3][Entering play mode will cause|the contents of the play|\
buffer to be lost.  Click on|OK only if you don't mind this.][OK|Cancel]"
#define CHEKSHAR	"[2][Save tracks to...][Sequencer|File]"
#define CHEKSHARE	"[3][Track too large for KEEP|buffer.  Chop end of track?]\
[Chop|Cancel]"
#define CHEKKEEP	"[3][There is something in the|sequencer's keep buffer that|\
has not been saved.  Ludwig|track will overwrite it.][Overwrite|Cancel]"
#define CHEKINALL	"[2][Initialize all parameters|before loading file?][Yes|No]"
#define CHEKBOX	"[1][No Sync Box!][Retry|Cancel]"

	/* prompts for top of screen during file selector (80 chars) */
#define LOAD_TITL "\
                         Load Ludwig Parameters from...                        "
#define SAVE_TITL "\
                          Save Ludwig Parameters to...                         "
#define DEL_TITL "\
                                 Delete File...                                "
#define SNG_TITL "\
                         Save Play Buffer to SNG File...                       "

	/* messages */
#define LOAD_MSG "Load Ludwig Parameters from"
#define SAVE_MSG "Save Ludwig Parameters to"
#define INIT_MSG "Initialize Ludwig Parameters"
#define PGRP_MSG "Pitch Patterns"
#define RGRP_MSG "Rhythm Patterns"
#define TEMPO_MSG "Tempo: "
#define TRK_MSG	"Track "
#define SNG_NAME  "Saved from Ludwig"
#define SHARMSG1	"Receiving Ludwig Track "
#define SHARMSG2	"Name: "
#define SHARMSG3A "MIDI Channel: "
#define SHARMSG3B "   Patch: "

	/* file names */
#define RSRCNAME   "LUDWIG.RSC"	   	/* resource file name */
#define AUTOFILE	 "AUTOLOAD.LWG"		/* auto-load file name */
#define INITNAME	 "INIT.LWG"				/* default song name */
#define FILE_EXT	 "LWG"					/* Ludwig file extension */
#define SNG_EXT	 "SNG"					/* MTST song file extension */
#define PWINDNAME1 "PRWINDOW.BL2"		/* color pitch/rhythm window frame */
#define PWINDNAME2 "PRWINDOW.BL3"		/* mono pitch/rhythm window frame */
#define VWINDNAME1 "VWINDOW.BL2"			/* color velocity window frame */
#define VWINDNAME2 "VWINDOW.BL3"			/* mono velocity window frame */
#define BL3HEADLNG 62L						/* header length of BL3 file */
#define BL2HEADLNG 68L						/* header length of BL2 file */

	/* for conditional compilations, set only one at a time */
#define DEMOFLAG  0			/* re-compile main,file,event */
#define ALOCKFLAG 1			/* re-compile main, interupt, gem */
#define BETAFLAG 0			/* re-compile main */
	/* for alock copy protection */
#define MAINLENGW 10000L	/* approx # words in main segment */
#define MAINCRC 0x7f71		/* correct CRC of main segment (used in gem.c) */
#define MAINCHKSUM 0x29cd	/* correct checksum of main segment (in gem.c) */

   /* bit-manipulation macros */
#define BITTEST(A,B) ( 1 & (B>>A) )				/* 0 or 1 */
#define BITSET(A,B)  ( (B) |= (1<<(A)) )
#define BITCLR(A,B)  ( (B) &= ~(1<<(A)) )
	/* standard C macros */
#define	abs(a)	((a)>0?(a):-(a))		/* absolute value */
#define	max(a,b)	((a)>(b)?(a):(b))		/* max of 2 values */
#define	min(a,b)	((a)<(b)?(a):(b))		/* min of 2 values */

	/* lengths */
#define SCRLENG 32000L		/* # bytes in screen save buffer */
#define GEMMEM	3072L			/* minimum memory needed for GEM */
#define MINPLAY (1000L*NSEQ)	/* minimum useful play buffer (?) !!! */
#define RECLENG 3072L		/* record buffer */

	/* mouse icons */
#define ARROWMOUSE 0
#define BEE_MOUSE 2
#define FINGERMOUSE 3

	/* hide/show mouse (line A) */
#define HIDEMOUSE asm { move.l a2,-(a7) dc.w 0xA00A move.l (a7)+,a2 }
#define SHOWMOUSE { intin[0]=1; \
	asm { move.l a2,-(a7) dc.w 0xA009 move.l (a7)+,a2 } }

   /* kb state bits */
#define RSHIFT  0x0001
#define LSHIFT  0x0002
#define LRSHIFT 0x0003
#define CTRL    0x0004
#define ALT     0x0008

	/* MIDI */
#define MIDIACIA 0xFFFFFC04		/* hardware registers */
#define MIDIDATA 0xFFFFFC06
#define MIDDLE_C 0x3c				/* default pitch */
#define MIDDLE_V 64					/* default velocity */
#define NOTE_ON  0x90				/* note the usage of ints and longs */
#define NOTE_OFF 0x80
#define PLAY_NOP 0x10L
#define MIDICLOCK 0xF8
#define MIDISTART 0xFA
#define MIDISTOP	0xFC

	/* screen layout */
#define P_TYPE 0						/* pitch window type */
#define R_TYPE 1						/* rhythm window type */
#define V_TYPE 2						/* velocity window type */
#define NWIND 4						/* # windows on screen */
#define NTYPE 3						/* # of kinds of parameters (P,R,V) */
#define NROW 4							/* # of rows within each window */
#define P_DIAL 0						/* pitch dialog */
#define R_DIAL 1						/* rhythm dialog */
#define PR_DIAL 2						/* pitch randomizer dialog */
#define RR_DIAL 3						/* rhythm randomizer dialog */
#define NDIAL 4						/* # of kinds of dialog boxes */
#define NTAG 3							/* # of rows of window tags */

	/* column #s (0-79) */
#define X_SEQ 1						/* start of "Seq X" */
#define X_SEQX 5						/* the X in "Seq X" */
#define X_TYPE 3						/* P/R/V */
#define X_SERIES 9					/* start of series */
#define X_RANDOM 61
#define X_VSYNC 9						/* velocity options */
#define X_VREST 20
#define X_VRAND 34
#define X_VRAMT 38
#define X_VSTEP 45
#define X_VTIME 51
#define X_VATON 58
#define X_VADUR 61
#define X_VUTON 68
#define X_VUDUR 73

#define X_CLOSE 1
#define X_PAUSE 4
#define X_TEMPO 32
#define X_MUTE  64

	/* file format */
#define NSEQ 8					/* # of sequences */
#define NGRP 96				/* # of user-defined groups, can't be changed */
#define MAGIC 'VEAL'			/* validates Ludwig file */
#define NSEG (NSEQ+4)		/* # of data segments (in this version) */
#define MAXNSEG (16*NSEG)	/* largest possible directory for future versions */
#define NCELL 1024			/* # cells in a series */
#define NCHD	32				/* # chords or note-rests in a user-defined group */
#define NPERPAGE 32			/* # cells that fit in a window */
#define INIT_PNAME ""		/* initialized pitch group name */
#define INIT_RNAME ""		/* initialized rhythm group name */
#define NTEMPO 232			/* how many different master tempi */
#define MINTEMPO 24			/* no tempi below this */

	/* buffer lengths, also the lengths of each data segment to be saved */
#define SEQ1LENG 4272L
#define SEQLENG (NSEQ*SEQ1LENG)
#define NONR1LENG 100L
#define NONRLENG (NSEQ*NONR1LENG)
#define MASTERLENG 16L
#define PITCH1LENG 116L
#define PITCHLENG (NGRP*PITCH1LENG)
#define RHYTH1LENG 116L
#define RHYTHMLENG (NGRP*RHYTH1LENG)

	/* offsets into data segments */
	/* SEQ segment */
#define S_PSERIES 0					/* start of pitch series */
#define S_RSERIES (2*NCELL)		/* start of rhythm series */
#define S_VSERIES (4*NCELL)		/* start of velocity series */
#define S_VOPTS (S_VSERIES+32L)	/* start of velocity options */
	#define S_VSYNC 0				/* velocity sync type */
	#define S_VREST 1				/* handling of rests */
	#define S_VRAND 2				/* random shift direction */
	#define S_VRAMT 3				/* random shift amount */
	#define S_VSTEP 4				/* step by chord or by duration */
	#define S_VTIME 5				/* duration for step */
	#define S_VATON 6				/* chromatic tone to be accented */
	#define S_VADUR 7				/* duration to be accented */
	#define S_VUTON 8				/* chromatic tone to be unaccented */
	#define S_VUDUR 9				/* duration to be unaccented */
#define S_PRAND (S_VOPTS+64L)	/* start of pitch randomizer */
	#define P_RCOPY 0				/* user group # to be mixed with */
	#define P_RNCOL1 2			/* # of last column (low limit) */
	#define P_RNCOL2 4			/* # of last column (high limit) */
	#define P_RORDER 6			/* play order */
	#define P_RNSEL 8				/* randomizer function for each chord */
#define S_RRAND (S_PRAND+40L)	/* start of rhythm randomizer */
	#define R_RCOPY 0				/* user group # to be mixed with */
	#define R_RNCOL1 2			/* # of last column (low limit) */
	#define R_RNCOL2 4			/* # of last column (high limit) */
	#define R_RORDER 6			/* play order */
	#define R_RNSEL 8				/* randomizer function for each note/rest */

	/* NONREAL segment (for each sequence) */
#define N_TONIC 0					/* tonic key */
#define N_ACCID 1					/* accidental option */
#define N_SCALE 2					/* scale information */
#define N_LEGATO 14				/* legato percentage 1-100 */
#define N_MIDICH 16				/* midi channel */
#define N_VELMAP 18				/* velocity map */
#define N_ACCENT 26				/* accent amount */
#define N_VWHICH 27			/* velocity map for attack/release/neither/both */
#define N_VDEFAT 28				/* default attack velocity (if not mapped) */
#define N_VDEFRL 29				/* default release velocity (if not mapped) */
#define N_MUTE 30					/* sequence mute */
#define N_NAME 31					/* 17-character name (16+null) */
#define N_PSYNCTRK 48			/* pitch series sync'd to which track */
#define N_PSYNCTYP 49			/* pitch series sync'd to which parameter */
#define N_RSYNCTRK 50			/* rhythm series sync'd to which track */
#define N_RSYNCTYP 51			/* rhythm series sync'd to which parameter */
#define N_PATCH 52				/* patch # for track */
#define N_PLEXER 53				/* midiplexer port # */
#define N_MESH 54					/* P/R meshing */

	/* MASTER segment */
#define M_SYNC 0					/* midi sync on/off */
#define M_THRUON 1				/* midi thru on/off */
#define M_LINK 2					/* pitch/rhythm linked */
#define M_TEMPO 3					/* tempo information */
#define M_THRUCHON 4				/* midi thru channelize on/off */
#define M_THRUCHAN 5				/* midi thru channel */
#define M_PATCH 6					/* send patches at start of play */
#define M_PLEXER 7				/* midi thru midiplexer port */
#define M_SEQ 8					/* what track in each window */
#define M_TYPE 12					/* what type of parameter in each window */

	/* PITCH segment (for each group) */
#define P_NAME 0					/* 16 character name (15+null) */
#define P_NOTE 16					/* note information */
#define P_NTREF 80				/* midi note # for note 0 */
#define P_NCOLS 112				/* # of last column */
#define P_ACCID 114				/* enharmonic display option */

	/* RHYTHM segment (for each group) */
#define R_NAME 0					/* 16 character name (15+null) */
#define R_DUR 16					/* duration information */
#define R_NTRST 80				/* note or rest */
#define R_NCOLS 112				/* # of last column */

	/* parameter editing structure */
typedef struct {
	int offset;			/* byte offset into seq1data, in terms of S_ defines */
	char nbytes;		/* 1 or 2 */
	char row;			/* row # 0-3 */
	char col;			/* col # 0-79 */
	char ncols;			/* width in columns */
	int low;				/* value low limit */
	int high;			/* value high limit */
	char dial;			/* -1 or fake dialog box # */
	char ndigits;		/* # digits for L/R editing */
	char **encode;		/* --> display string array */
}	PARAM;
#define NPPARAMS	(2*NPERPAGE + NCHD + 4)
#define NRPARAMS	(2*NPERPAGE + NCHD + 4)
#define NVPARAMS	(NPERPAGE + 10)

	/* miscellaneous */
#define N_OPERS	30		/* # of pitch or rhythm operators */
#define NR_OPERS	12		/* # of pitch o rhythm randomizer functions */
#define TITLEH		13		/* height of fakedial title bar in color */

/*************************************** EOF *********************************/
