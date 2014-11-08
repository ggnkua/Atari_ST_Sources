/*
 * $Id: tos.h pdonze Exp $
 * 
 * TOS.LIB - (c) 1998 - 2006 Philipp Donze
 *
 * A replacement for PureC PCTOSLIB.LIB
 *
 * This file is part of TOS.LIB and contains the prototypes and structures of
 * BIOS, XBIOS and GEMDOS system calls.
 *
 * TOS.LIB is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * TOS.LIB is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with the GNU C Library; see the file COPYING.LIB.  If not,
 * write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

#ifndef _TOS_H
# define _TOS_H
# define __TOS

typedef struct basep
{
    char *p_lowtpa;     /* pointer to self (bottom of TPA) */
    char *p_hitpa;      /* pointer to top of TPA + 1 */
    char *p_tbase;      /* base of text segment */
    long p_tlen;        /* length of text segment */
    char *p_dbase;      /* base of data segment */
    long p_dlen;        /* length of data segment */
    char *p_bbase;      /* base of BSS segment */
    long p_blen;        /* length of BSS segment */
    char *p_dta;        /* (UNOFFICIAL, DON'T USE) */
    struct basep *p_parent; /* pointer to parent's basepage */
    char *p_reserved;   /* reserved for future use */
    char *p_env;        /* pointer to environment string */
    char p_junk[8];
    long p_undef[18];   /* scratch area... don't touch */
    char p_cmdlin[128]; /* command line image */
} BASEPAGE;

extern BASEPAGE *_BasPag;       /* defined in start-up code */
extern long _PgmSize;           /* defined in start-up code */




/*******************************************************************************
 * BIOS defines and structures
 ******************************************************************************/

/* Device codes for Bconin(), Bconout(), Bcostat(), Bconstat() */
#define _PRT    0
#define _AUX    1
#define _CON    2
#define _MIDI   3
#define _IKBD   4
#define _RAWCON 5

/* Structure returned by Getbpb() */
typedef struct
{
    short recsiz;           /* bytes per sector */
    short clsiz;            /* sectors per cluster */
    short clsizb;           /* bytes per cluster */
    short rdlen;            /* root directory size */
    short fsiz;             /* size of file allocation table */
    short fatrec;           /* startsector of second FAT */
    short datrec;           /* first data sector */
    short numcl;            /* total number of clusters */
    short bflags;           /* some flags */
} BPB;


/* Structures used by Getmpb() */
/* Memory descriptor */
typedef struct md
{
    struct md *md_next;     /* next descriptor in the chain */
    long md_start;          /* starting address of block */
    long md_length;         /* length of the block */
    long md_owner;          /* owner's process descriptor */
} MD;

/* Memory parameter block */
typedef struct
{
    MD *mp_free;            /* free memory chunks */
    MD *mp_used;            /* used memory descriptors */
    MD *mp_rover;           /* rover memory descriptor */
} MPB;


/*  BIOS bindings   */
void    Getmpb(MPB *ptr);
short   Bconstat(short dev);
long    Bconin(short dev);
void    Bconout(short dev, short c);
long    Rwabs(short rwflag, void *buf, short cnt, short recnr, short dev,
                long lrecno);
long    Setexc(short number, long vec);
long    Tickcal(void);
BPB     *Getbpb(short dev);
long    Bcostat(short dev);
long    Mediach(short dev);
long    Drvmap(void);
long    Kbshift(short mode);




/*******************************************************************************
 * XBIOS defines and structures
 ******************************************************************************/

/* Codes used with Cursconf() */
#define CURS_HIDE       0
#define CURS_SHOW       1
#define CURS_BLINK      2
#define CURS_NOBLINK    3
#define CURS_SETRATE    4
#define CURS_GETRATE    5

/* Structure returned by Iorec() */
typedef struct
{
    char    *ibuf;
    short   ibufsiz;
    volatile short  ibufhd;
    volatile short  ibuftl;
    short   ibuflow;
    short   ibufhi;
} IOREC;

typedef struct
{
    short   (*Bconstat) ();
    long    (*Bconin) ();
    short   (*Bcostat) ();
    void    (*Bconout) ();
    long    (*Rsconf) ();
    IOREC   *iorec;
}MAPTAB;

/* Structure used by Bconmap()  */
typedef struct
{
    MAPTAB  *maptab;
    short   maptabsize;
}BCONMAP;

/* Structure used by Initmouse() */
typedef struct
{
    char    topmode;
    char    buttons;
    char    xparam;
    char    yparam;
    short   xmax;
    short   ymax;
    short   xstart;
    short   ystart;
} PARAM;

/* Structure returned by Kbdvbase() */
typedef struct
{
    void    (*midivec)  (void);
    void    (*vkbderr)  (void);
    void    (*vmiderr)  (void);
    void    (*statvec)  (void *);
    void    (*mousevec) (void *);
    void    (*clockvec) (void *);
    void    (*joyvec)   (void *);
    long    (*midisys)  (void);
    long    (*ikbdsys)  (void);
    char    kbstate;
} KBDVECS;

/* Structure returned by Keytbl() */
typedef struct
{
    char *unshift;  /* pointer to unshifted keys */
    char *shift;    /* pointer to shifted keys */
    char *caps;     /* pointer to capslock keys */

    /* Entries below available
     * when _AKP cookie is present.
     */
    char *alt;      /* pointers to alt translation tables */
    char *altshift;
    char *altcaps;

   /* Entry below is available
    * on MilanTOS and as of FreeMiNT 1.16.1
    */
    char *altgr;
} KEYTAB;

/* Structure used by Prtblk() */
typedef struct
{
    void    *pb_scrptr;
    short   pb_offset;
    short   pb_width;
    short   pb_height;
    short   pb_left;
    short   pb_right;
    short   pb_screz;
    short   pb_prrez;
    void    *pb_colptr;
    short   pb_prtype;
    short   pb_prport;
    void    *pb_mask;
} PBDEF;

/* Structure used by Initmous() */
typedef struct
{
    char    topmode;
    char    buttons;
    char    x_scale;
    char    y_scale;
    short   x_max;
    short   y_max;
    short   x_start;
    short   y_start;
} MOUSE;

typedef struct
{
    long    gm_magic;   /* should be 0x87654321 */
    void    *gm_end;    /* end of memory used by GEM */
    void    *gm_init;   /* start address of GEM */
} GEM_MUPB;

/* system variable _sysbase (0x4F2L) points to next structure         */
typedef struct _osheader
{
    unsigned short  os_entry;   /* $00 BRA to reset handler             */
    unsigned short  os_version; /* $02 TOS version number               */
    void    *reseth;            /* $04 -> reset handler                 */
    struct _osheader *os_beg;   /* $08 -> baseof OS                     */
    void    *os_end;            /* $0c -> end BIOS/GEMDOS/VDI ram usage */
    long    os_rsv1;            /* $10 << unused,reserved >>            */
    GEM_MUPB *os_magic;         /* $14 -> GEM memoryusage parm. block   */
    long    os_date;            /* $18 Date of system build($MMDDYYYY)  */
    short   os_conf;            /* $1c OS configuration bits            */
    short   os_dosdate;         /* $1e DOS-format date of systembuild   */
/*  The next three fields are only available in TOS versions >= 1.2 */
    char    **p_root;           /* $20 -> base of OS pool               */
    char    **pkbshift;         /* $24 -> keyboard shift state variable */
    BASEPAGE    **p_run;        /* $28 -> GEMDOS PID of current process */
    char    *p_rsv2;            /* $2c << unused, reserved >>           */
} OSHEADER; /* or SYSHDR */


/*  XBIOS bindings  */
void    Initmous(short type, MOUSE *par, void *(*vec)());
void    *Ssbrk(short count);
void    *Physbase(void);
void    *Logbase(void);
short   Getrez(void);
void    Setscreen(void *laddr, void *paddr, short rez);
void    Setpalette(void *pallptr);
short   Setcolor(short colornum, short color);
short   Floprd(void *buf, long filler, short devno, short sectno,
                short trackno, short sideno, short count);
short   Flopwr(void *buf, long filler, short devno, short sectno,
                short trackno, short sideno, short count);
short   Flopfmt(void *buf, long filler, short devno, short spt, 
                short trackno, short sideno, short shorterlv, long magic,
                short virgin);
void    Midiws(short cnt, void *ptr);
void    Mfpint(short erno, void (*vector)());
IOREC   *Iorec(short dev);
long    Rsconf(short baud, short ctr, short ucr, short rsr, short tsr,
                short scr);
KEYTAB  *Keytbl(void *unshift, void *shift, void *capslock);
long    Random(void);
void    Protobt(void *buf, long serialno, short disktype, short execflag);
short   Flopver(void *buf, long filler, short devno, short sectno,
                short trackno, short sideno, short count);
void    Scrdmp(void);
short   Cursconf(short func, short rate);
void    Settime(unsigned long time);
unsigned long   Gettime(void);
void    Bioskeys(void);
void    Ikbdws(short count, void *ptr);
void    Jdisint(short number);
void    Jenabint(short number);
char    Giaccess(short data, short regno);
void    Offgibit(short bitno);
void    Ongibit(short bitno);
void    Xbtimer(short timer, short control, short data, void (*vector)());
void    Dosound(void *buf);
short   Setprt(short config);
KBDVECS *Kbdvbase(void);
short   Kbrate(short initial, short repeat);
void    Prtblk(PBDEF *par);
void    Vsync(void);
long    Supexec(long (*func)());
void    Puntaes(void);
short   Floprate(short devno, short newrate);
short   Blitmode(short mode);


/***** XBIOS extensions for TT TOS *****/
short   EsetShift(short shftMode);
short   EgetShift(void);
short   EsetBank(short bankNum);
short   EsetColor(short colorNum, short color);
void    EsetPalette(short colorNum, short count, short *palettePtr);
void    EgetPalette(short colorNum, short count, short *palettePtr);
short   EsetGray(short swtch);
short   EsetSmear(short swtch);
short   DMAread(long sector, short count, void *buffer, short devno);
short   DMAwrite(long sector, short count, void *buffer, short devno);
long    Bconmap(short devno);
short   NVMaccess(short opcode, short start, short count, void *buffer);


/***** XBIOS extensions for ST Book *****/
void    Waketime(unsigned short w_date, unsigned short w_time);


/***** XBIOS extensions for Falcon TOS (video) *****/

/* Video mode codes */
#define VERTFLAG    0x100   /* double-line on VGA, interlace on ST/TV */
#define STMODES     0x080   /* ST compatible */
#define OVERSCAN    0x040   /* Multiply X&Y rez by 1.2, ignored on VGA */
#define PAL         0x020   /* PAL if set, else NTSC */
#define VGA         0x010   /* VGA if set, else TV mode */
#define COL80       0x008   /* 80 column if set, else 40 column */
#define NUMCOLS     7       /* Mask for number of bits per pixel */
#define BPS16       4
#define BPS8        3
#define BPS4        2
#define BPS2        1
#define BPS1        0

/* VgetMonitor() return values */
enum montypes {STmono=0, STcolor, VGAcolor, TVcolor};

/* VsetSync flags - 0=internal, 1=external */

#define VID_CLOCK   1
#define VID_VSYNC   2
#define VID_HSYNC   4

void    VsetScreen(void *laddr, void *paddr, short rez , short mode);
short   VsetMode(short modecode);
short   VgetMonitor(void);
void    VsetSync(short external);
long    VgetSize(short mode);
void    VsetRGB(short index, short count, long *array);
void    VgetRGB(short index, short count, long *array);
short   Validmode(short mode);
short   VsetMask(short andmask, short ormask);


/***** XBIOS extensions for Falcon TOS (sound) *****/

/* _SND cookie values */

#define SND_PSG     0x01    /* Yamaha PSG */
#define SND_8BIT    0x02    /* 8 bit DMA stereo */
#define SND_16BIT   0x04    /* 16 bit CODEC */
#define SND_DSP     0x08    /* DSP */
#define SND_MATRIX  0x10    /* Connection Matrix */

/* XXX Docs say Falcon shows 0x3f. What does bit 0x20 mean ??? */

/*
 * Sound data memory layout - samples are all signed values
 *
 *              (each char = 1 byte, 2 chars = 1 word)
 * 1 16 bit stereo track:   LLRRLLRRLLRRLLRR
 * 1 8 bit stereo track:    LRLRLRLR  
 * 2 16 bit stereo tracks:  L0R0L1R1L0R0L1R1
 *  etc...
 */

/* Setbuffer regions */

#define SR_PLAY     0   /* Set playback registers */
#define SR_RECORD   1   /* Set record registers */

/* Soundcmd Modes */

#define LTATTEN     0   /* Left-channel output attenuation */
#define RTATTEN     1   /* Right channel atten */
#define LTGAIN      2   /* Left input gain */
#define RTGAIN      3   /* Right channel gain */
                /* gain and attenuation in 1.5 dB units, 0x00V0, V:0-15 */
#define ADDERIN     4   /* Select inputs to adder 0=off, 1=on */
#define ADCIN       1   /* Input from ADC */
#define MATIN       2   /* Input from connection matrix */
#define ADCINPUT    5   /* Select input to ADC, 0=mic, 1=PSG */
#define ADCRT       1   /* Right channel input */
#define ADCLT       2   /* Left input */
#define SETPRESCALE 6   /* Set TT compatibility prescaler */
#define PREMUTE     0   /* was /1280, now is invalid, mutes */
#define PRE1280     PREMUTE
#define PRE640      1   /* divide by 640 */
#define PRE320      2   /* / 320 */
#define PRE160      3   /* / 160 */

/* Record/Playback modes */

#define STEREO8     0   /* 8 bit stereo */
#define STEREO16    1   /* 16 bit stereo */
#define MONO8       2   /* 8 bit mono */

/* Record/Playback tracks range from 0 to 3 */

/* XXX Doc for Settracks could be clearer. Can we individually set, e.g.,
   tracks 0 & 2 for playback, or must track selections be contiguous? */

/* Sound buffer interrupts */
    /* sources */
#define SI_TIMERA   0   /* Timer A interrupt */
#define SI_MFPI7    1   /* MFP interrupt 7 */
    /* causes */
#define SI_NONE     0   /* No interrupts */
#define SI_PLAY     1   /* Intr at end of play buffer */
#define SI_RECORD   2   /* Intr at end of record buffer */
#define SI_BOTH     3   /* Interrupt for either play or record */

/* Buffoper flags */

#define SB_PLA_ENA  1   /* Play enable */
#define SB_PLA_RPT  2   /* Play repeat (continuous loop mode) */
#define SB_REC_ENA  4   /* Record enable */
#define SB_REC_RPT  8   /* Record repeat */

/* Dsptristate - 0=tristate, 1=enable */

/* Gpio modes */

#define GPIO_SET    0   /* Set I/O direction, 0=in, 1=out */
#define GPIO_READ   1   /* Read bits - only 3 bits on gpio */
#define GPIO_WRITE  2   /* Write gpio data bits */

/* Devconnect (connection matrix) source devices */

#define DMAPLAY     0   /* DMA playback */
#define DSPXMIT     1   /* DSP transmit */
#define EXTINP      2   /* External input */
#define ADC         3   /* Microphone/PSG, see Soundcmd(ADCINPUT) */

/* Devconnect destination devices, bitmapped */

#define DMAREC      1   /* DMA record */
#define DSPRECV     2   /* DSP receive */
#define EXTOUT      4   /* External output */
#define DAC         8   /* Headphone, internal speaker, monitor */

/* Devconnect clock sources */

#define CLK25M      0   /* Internal 25.175 MHz clock */
#define CLKEXT      1   /* External clock */
#define CLK32M      2   /* Internal 32 MHz. Invalid for CODEC */

/* Devconnect clock prescaler values */

/* XXX Doc lists incorrect hz numbers for many of these... */

#define CLKOLD      0   /* TT compatible, see Soundcmd(SETPRESCALE) */
#define CLK50K      1   /* 49170 hz */
#define CLK33K      2   /* 32780 hz */
#define CLK25K      3   /* 24585 hz */
#define CLK20K      4   /* 19668 hz */
#define CLK16K      5   /* 16390 hz */
        /*  6   (14049 hz) invalid for CODEC */
#define CLK12K      7   /* 12292 hz */
        /*  8   (10927 hz) invalid for CODEC */
#define CLK10K      9   /* 9834 hz */
        /*  10  (8940 hz) invalid for CODEC */
#define CLK8K       11  /* 8195 hz */
        /*  12  (7565 hz) invalid */
        /*  13  (7024 hz) invalid */
        /*  14  (6556 hz) invalid */
        /*  15  (6146 hz) invalid */

/* Sndstatus command */

#define SND_CHECK   0   /* Check current status */
#define SND_RESET   1   /* Reset sound system */
    /*
     * Reset effects: DSP tristated, gain=atten=0, matrix reset,
     * ADDERIN=0, Mode=STEREO8, Play=Record=Monitor tracks=0,
     * interrupts disabled, buffer operation disabled.
     */

/* Sndstatus status return */

#define SS_OK       0   /* No errors */
#define SS_CTRL     1   /* Invalid control field (Data assumed OK) */
#define SS_SYNC     2   /* Invalid sync format (mutes) */
#define SS_SCLK     3   /* Serial clock out of valid range (mutes) */

#define SS_RTCLIP   0x10    /* Right channel is clipping */
#define SS_LTCLIP   0x20    /* Left channel is clipping */

/* Structure used by Buffptr */

typedef struct SndBufPtr {
    char *play;
    char *record;
    long reserve1;
    long reserve2;
} SndBufPtr;

long    Locksnd(void);
long    Unlocksnd(void);
long    Soundcmd(short mode, short data);
long    Setbuffer(short reg, void *begaddr, void *endaddr);
long    Setmode(short mode);
long    Settracks(short playtracks, short rectracks);
long    Setmontracks(short montracks);
long    Setinterrupt(short src_inter, short cause);
long    Buffoper(short mode);
long    Dsptristate(short dspxmit, short dsprec);
long    Gpio(short mode, short data);
long    Devconnect(short src, short dst, short srcclk, short prescale,
                short protocol);
long    Sndstatus(short reset);
long    Buffptr(SndBufPtr *ptr);


/***** XBIOS extensions for Falcon TOS (dsp) *****/

typedef struct
{
    short   blocktype;
    long    blocksize;
    void    *blockaddr;
} DSPBLOCK;

void    Dsp_DoBlock(char *data_in, long size_in, 
                char *data_out, long size_out);
void    Dsp_BlkHandShake(char *data_in, long size_in, 
                char *data_out, long size_out);
void    Dsp_BlkUnpacked(char *data_in, long size_in, 
                char *data_out, long size_out);
void    Dsp_InStream(char *data_in, long block_size, 
                long num_blocks, long *blocks_done);
void    Dsp_OutStream(char *data_in, long block_size, 
                long num_blocks, long *blocks_done);
void    Dsp_IOStream(char *data_in, char *data_out,
                long block_insize, long block_outsize,
                long num_blocks, long *blocks_done);
void    Dsp_RemoveInterrupts(short mask);
short   Dsp_GetWordSize(void);
short   Dsp_Lock(void);
void    Dsp_Unlock(void);
void    Dsp_Available(long *xavail, long *yavail);
short   Dsp_Reserve(long xreserve, long yreserve);
short   Dsp_LoadProg(char *file, short ability, void *buffer);
void    Dsp_ExecProg(char *codeptr, long codesize, short ability);
void    Dsp_ExecBoot(char *codeptr, long codesize, short ability);
long    Dsp_LodToBinary(char *file, char *codeptr);
void    Dsp_TriggerHC(short vector);
short   Dsp_RequestUniqueAbility(void);
short   Dsp_GetProgAbility(void);
void    Dsp_FlushSubroutines(void);
short   Dsp_LoadSubroutine(char *codeptr, long size, short ability);
short   Dsp_InqSubrAbility(short flag);
short   Dsp_RunSubroutine(short handle);
short   Dsp_Hf0(short flag);
short   Dsp_Hf1(short flag);
short   Dsp_Hf2(void);
short   Dsp_Hf3(void);
void    Dsp_BlkWords(short *data_in, long size_in, 
                short *data_out, long size_out);
void    Dsp_BlkBytes(char *data_in, long size_in, 
                char *data_out, long size_out);
short   Dsp_HStat(void);
void    Dsp_SetVectors(void (*receiver)(),
                long (*transmitter)());
void    Dsp_MultBlocks(long numsend, long numreceive,
                DSPBLOCK *sendblk,
                DSPBLOCK *receiveblock);











/*******************************************************************************
 * GEMDOS defines and structures
 ******************************************************************************/

/* Structure used by Cconrs() */
typedef struct
{
    unsigned char maxlen;
    unsigned char actuallen;
    char buffer[255];
} CCONLINE;

/* Structure used by Dfree() */
typedef struct 
{
    long b_free;        /* number of free clusters */
    long b_total;       /* total number of clusters */
    long b_secsiz;      /* number of bytes per sector */
    long b_clsiz;       /* number of sectors per cluster */
} DISKINFO;

/* Structure returned by Fdatime() */
typedef struct 
{
    unsigned short time;
    unsigned short date;
} DOSTIME;

/* Structure used by Fgetdta(), Fsetdta(), Fsfirst(), Fsnext() */
typedef struct 
{
    char            d_reserved[21]; /* reserved */
    unsigned char   d_attrib;       /* file attribute */
    unsigned short  d_time;         /* file time stamp */
    unsigned short  d_date;         /* file date stamp */
    unsigned long   d_length;       /* file size */
    char            d_fname[14];    /* file name */
} DTA;

/* Codes used with Fsfirst(), Fcreate() */
#define FA_RDONLY           0x01
#define FA_HIDDEN           0x02
#define FA_SYSTEM           0x04
#define FA_LABEL            0x08
#define FA_DIR              0x10
#define FA_CHANGED          0x20
#define FA_ATTRIB           (FA_SUBDIR|FA_READONLY|FA_HIDDEN|FA_SYSTEM)

/* GEMDOS standard device handles */
#define HDL_CON -1                                          /* TOS */
#define HDL_AUX -2                                          /* TOS */
#define HDL_PRN -3                                          /* TOS */
#define HDL_NUL -4                                          /* KAOS 1.2 */


/* GEMDOS standard file handles */
#define STDIN_FILENO   0                                           /* TOS */
#define STDOUT_FILENO  1                                           /* TOS */
#define STDAUX_FILENO  2                                           /* TOS */
#define STDPRN_FILENO  3                                           /* TOS */
#define STDERR_FILENO  4                                           /* TOS */
#define STDXTRA_FILENO 5                                           /* TOS */

/* old Fopen() modes (see O_RDONLY, O_WRONLY and O_RDWR) */
#define FO_READ             0
#define FO_WRITE            1
#define FO_RW               2

/* Fseek() modes */
#define SEEK_SET            0       /* TOS */
#define SEEK_CUR            1       /* TOS */
#define SEEK_END            2       /* TOS */

/* Codes used with Pexec() */
#define PE_LOADGO           0       /* load & go */
#define PE_LOAD             3       /* just load */
#define PE_GO               4       /* just go */
#define PE_CBASEPAGE        5       /* just create basepage */
#define PE_GO_FREE          6       /* just go, then free */
#define PE_ASYNC_LOADGO     100     /* load and asynchronously go (MiNT) */
#define PE_ASYNC_GO         104     /* asynchronously go (MiNT) */
#define PE_ASYNC_GO_FREE    106     /* asynchronously go and free (MiNT) */
#define PE_OVERLAY          200     /* load and overlay (MiNT) */


/*  GEMDOS bindings */

void    Pterm0(void);
long    Cconin(void);
void    Cconout(short c);
long    Cauxin(void);
void    Cauxout(short c);
void    Cprnout(short c);
long    Crawio(short c);
long    Crawcin(void);
long    Cnecin(void);
void    Cconws(const char *str);
void    Cconrs(CCONLINE *buf);
short   Cconis(void);
long    Dsetdrv(short drv);
short   Cconos(void);
short   Cprnos(void);
short   Cauxis(void);
short   Cauxos(void);
short   Dgetdrv(void);
void    Fsetdta(DTA *buf);
long    Super(void *stack);
unsigned short  Tgetdate(void);
short   Tsetdate(unsigned short date);
unsigned short  Tgettime(void);
short   Tsettime(unsigned short time);
DTA     *Fgetdta(void);
short   Sversion(void);
void    Ptermres(long keepcnt, short retcode);
long    Dfree(DISKINFO *buf, short driveno);
long    Dcreate(const char *path);
long    Ddelete(const char *path);
long    Dsetpath(const char *path);
long    Fcreate(const char *filename, short attr);
long    Fopen(const char *filename, short mode);
long    Fclose(short handle);
long    Fread(short handle, long count, void *buf);
long    Fwrite(short handle, long count, const void *buf);
long    Fdelete(const char *path);
long    Fseek(long where, short handle, short how);
long    Fattrib(const char *filename, short wflag, short attrib);
long    Fdup(short handle);
long    Fforce(short stdh, short nonstdh);
long    Dgetpath(char *path, short driveno);
void    *Malloc(long size);
long    Mfree(void *block);
long    Mshrink(void *block, long newsiz);
long    Pexec(short mode, const void *ptr1, const void *ptr2, const void *ptr3);
void    Pterm(short retcode);
long    Fsfirst(const char *filename, short attr);
long    Fsnext(void);
long    Frename(const char *oldname, const char *newname);
long    Fdatime(DOSTIME *timeptr, short handle, short wflag);


/***** GEMDOS extensions for TT TOS *****/
/*	Mxalloc() mode	*/
#define MX_STRAM	0
#define MX_TTRAM	1
#define	MX_PREFST	2
#define MX_PREFTT	3

long    Maddalt(void *start, long size);
long    Mxalloc(long size, short mode);


/***** GEMDOS extension for Network *****/

long    Flock(short handle, short mode, long start, long length);


/***** GEMDOS extension for shared libraries *****/

typedef void *SLB_HANDLE;
/* Because of a bug in Pure C (cdecl is ignored when variable number
   of arguments is used), we can't use type checking. 
  typedef long (cdecl *SLB_EXEC)(SLB_HANDLE *sl, long fn, short nargs, ...); */
typedef long (*SLB_EXEC)(void , ...);

long    Slbopen(char *name, char *path, long min_ver, SLB_HANDLE *sl, 
            SLB_EXEC *fn);
long    Slbclose(SLB_HANDLE *sl);


/***** GEMDOS extension for Falcon TOS *****/

long    Srealloc(long len);


/***** GEMDOS extension for MagiC OS *****/

long    Sconfig(short subfn, long flags);


/***** GEMDOS extension for MiNT *****/

/* New Mxalloc() modes (combined with existing modes)  */
#define MX_MPROT	(1<<3)

#define MX_PRIVATE	(1<<4)
#define MX_GLOBAL	(2<<4)
#define MX_SUPER	(3<<4)
#define MX_READABLE	(4<<4)

/* New file access modes for Fopen()  */
#define O_RDONLY    0x00        /* Open read-only.  */
#define O_WRONLY    0x01        /* Open write-only.  */
#define O_RDWR      0x02        /* Open read/write.  */
#define O_APPEND    0x08        /* position at EOF */
#define O_ACCMODE   (O_RDONLY|O_WRONLY|O_RDWR)

/* Bits OR'd into the second argument to Fopen()  */
#undef  O_CREAT
#define O_CREAT     0x200       /* create new file if needed */
#undef  O_TRUNC
#define O_TRUNC     0x400       /* make file 0 length */
#undef  O_EXCL
#define O_EXCL      0x800       /* error if file exists */
#define O_NOCTTY    0x4000      /* do not open new controlling tty */

/* file sharing modes */
#define O_COMPAT    0x00    /* old TOS compatibility mode */
#define O_DENYRW    0x10    /* deny both reads and writes */
#define O_DENYW     0x20
#define O_DENYR     0x30
#define O_DENYNONE  0x40    /* don't deny anything */
#define O_SHMODE    0x70    /* mask for file sharing mode */
#define O_SYNC      0x00    /* sync after writes (not implemented) */

/*  Fgetchar() modes    */
#define CMODE_RAW       0
#define CMODE_COOKED    1
#define CMODE_ECHO      2

/* Psemaphore */
#define PSEM_CRGET      0
#define PSEM_DESTROY    1
#define PSEM_GET        2
#define PSEM_RELEASE    3

/* Dlock modes */
#define DLOCKMODE_LOCK  1
#define DLOCKMODE_UNLOCK0
#define DLOCKMODE_GETPID2

/* Dopendir modes */
#define DOPEN_COMPAT    1
#define DOPEN_NORMAL    0

/* Fxattr modes */
#define FXATTR_RESOLVE  0
#define FXATTR_NRESOLVE 1

/* Pdomain modes */
#define PDOM_TOS        0
#define PDOM_MINT       1

/*  Dpathconf() modes   */
#define DP_MAXREQ      -1
#define DP_IOPEN        0
#define DP_MAXLINKS     1
#define DP_PATHMAX      2
#define DP_NAMEMAX      3
#define DP_ATOMIC       4
#define DP_TRUNC        5
#define DP_CASE         6
#define DP_MODEATTR     7
#define DP_XATTRFIELDS  8

/*  Return values for Dpathconf(...,DP_TRUNC)   */
#define DP_NOTRUNC      0
#define DP_AUTOTRUNC    1
#define DP_TOSTRUNC     2

/*  Return values for Dpathconf(...,DP_CASE)    */
#define DP_CASESENS     0
#define DP_CASECONV     1
#define DP_CASEINSENS   2

/*  Return values for Dpathconf(...,DP_MODEATTR)    */
#define DP_FT_DIR       0x00100000L
#define DP_FT_CHR       0x00200000L
#define DP_FT_BLK       0x00400000L
#define DP_FT_REG       0x00800000L
#define DP_FT_LNK       0x01000000L
#define DP_FT_SOCK      0x02000000L
#define DP_FT_FIFO      0x04000000L
#define DP_FT_MEM       0x08000000L

/*  Return values for Dpathconf(...,DP_XATTRFIELDS) */
#define DP_INDEX        0x0001
#define DP_DEV          0x0002
#define DP_RDEV         0x0004
#define DP_NLINK        0x0008
#define DP_UID          0x0010
#define DP_GID          0x0020
#define DP_BLKSIZE      0x0040
#define DP_SIZE         0x0080
#define DP_NBLOCKS      0x0100
#define DP_ATIME        0x0200
#define DP_CTIME        0x0400
#define DP_MTIME        0x0800

/* file types for XATTR */
#define S_IFMT          0170000     /* mask to select file type */
#define S_IFCHR         0020000     /* BIOS special file */
#define S_IFDIR         0040000     /* directory file */
#define S_IFREG         0100000     /* regular file */
#define S_IFIFO         0120000     /* FIFO */
#define S_IMEM          0140000     /* memory region or process */
#define S_IFLNK         0160000     /* symbolic link */
                        
/* special bits:         setuid, setgid, sticky bit */
#define S_ISUID         04000
#define S_ISGID         02000
#define S_ISVTX         01000

/* file access modes for user, group, and other*/
#define S_IRUSR         0400
#define S_IWUSR         0200
#define S_IXUSR         0100
#define S_IRGRP         0040
#define S_IWGRP         0020
#define S_IXGRP         0010
#define S_IROTH         0004
#define S_IWOTH         0002
#define S_IXOTH         0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE    (0666)

/* Extended file attributes */
typedef struct
{
    unsigned short  mode;           /*  file access mode    */
    long    index;                  /*  file number */
    unsigned short  dev;            /*  device number   */
    unsigned short  rdev;           /*  real bios device number */
    unsigned short  nlink;          /*  number of links to this file    */
    unsigned short  uid;            /*  user id */
    unsigned short  gid;            /*  group id    */
    long    size;                   /*  file size in bytes  */
    long    blksize;                /*  block size  */
    long    nblocks;                /*  number of blocks occupied   */
    unsigned short  mtime, mdate;   /*  modification date & time    */
    unsigned short  atime, adate;   /*  last access date & time */
    unsigned short  ctime, cdate;   /*  creation date & time    */
    unsigned short  attr;           /*  TOS attributes  */
    short   reserved2;
    long    reserved3[2];
} XATTR;


/* Structure used by Pmsg() */
typedef struct
{
    long    msg1;
    long    msg2;
    short   pid;
} MSG;


/* signal handling */
#define NSIG        31      /* number of signals recognized */
#define SIGNULL     0       /* not really a signal */
#define SIGHUP      1       /* hangup signal */
#define SIGINT      2       /* sent by ^C */
#define SIGQUIT     3       /* quit signal */
#define SIGILL      4       /* illegal instruction */
#define SIGTRAP     5       /* trace trap */
#define SIGABRT     6       /* abort signal */
#define SIGPRIV     7       /* privilege violation */
#define SIGFPE      8       /* divide by zero */
#define SIGKILL     9       /* cannot be ignored */
#define SIGBUS      10      /* bus error */
#define SIGSEGV     11      /* illegal memory reference */
#define SIGSYS      12      /* bad argument to a system call */
#define SIGPIPE     13      /* broken pipe */
#define SIGALRM     14      /* alarm clock */
#define SIGTERM     15      /* software termination signal */
#define SIGURG      16      /* urgent condition on I/O channel */
#define SIGSTOP     17      /* stop signal not from terminal */
#define SIGTSTP     18      /* stop signal from terminal */
#define SIGCONT     19      /* continue stopped process */
#define SIGCHLD     20      /* child stopped or exited */
#define SIGTTIN     21      /* read by background process */
#define SIGTTOU     22      /* write by background process */
#define SIGIO       23      /* I/O possible on a descriptor */
#define SIGXCPU     24      /* CPU time exhausted */
#define SIGXFSZ     25      /* file size limited exceeded */
#define SIGVTALRM   26      /* virtual timer alarm */
#define SIGPROF     27      /* profiling timer expired */
#define SIGWINCH    28      /* window size changed */
#define SIGUSR1     29      /* user signal 1 */
#define SIGUSR2     30      /* user signal 2 */

#define SA_NOCLDSTOP    1   /* don't send SIGCHLD when child stops */

#define SIG_ERR     -1L
#define SIG_DFL     0L
#define SIG_IGN     1L

typedef void cdecl (*__sig_handler) (unsigned long signum);

typedef struct sigaction {
    __sig_handler   sa_handler;     /* pointer to signal handler */
    unsigned long   sa_mask;        /* add. signals masked during delivery */
    unsigned short  sa_flags;       /* signal specific flags */
} SIGACTION;

/* Ssystem modes:  */
# define S_OSNAME		0
# define S_OSXNAME		1
# define S_OSVERSION	2
# define S_OSHEADER		3
# define S_OSBUILDDATE	4
# define S_OSBUILDTIME	5
# define S_OSCOMPILE	6
# define S_OSFEATURES	7
# define S_GETCOOKIE	8
# define S_SETCOOKIE	9
# define S_GETLVAL		10
# define S_GETWVAL		11
# define S_GETBVAL		12
# define S_SETLVAL		13
# define S_SETWVAL		14
# define S_SETBVAL		15
# define S_SECLEVEL		16
# define S_RUNLEVEL		17	/* currently disabled, reserved */
# define S_TSLICE		18
# define S_FASTLOAD		19
# define S_SYNCTIME		20
# define S_BLOCKCACHE	21
# define S_FLUSHCACHE	22
# define S_CTRLCACHE	23
# define S_INITIALTPA	24
# define S_CTRLALTDEL	25 /* ctraltdel behavoiur */
# define S_DELCOOKIE	26
# define S_LOADKBD		27	/* reload the keyboard table */
# define S_CLOCKUTC		100
# define S_TIOCMGET		0x54f8	/* 21752 */

/* experimental - need feedback
 * additional informations about the kernel
 * reserved 900 - 999
 */
# define S_KNAME	900	/* kernel name - arg1 pointer to a buffer of arg2 len */
# define S_CNAME	910	/* compiler name - arg1 pointer to a buffer of arg2 len */
# define S_CVERSION	911	/* compiler version - arg1 pointer to a buffer of arg2 len */
# define S_CDEFINES	912	/* compiler definitions - arg1 pointer to a buffer of arg2 len */
# define S_COPTIM	913	/* compiler flags - arg1 pointer to a buffer of arg2 len */

/* debug section
 * reserved 1000 - 1999
 */
# define S_DEBUGLEVEL	1000	/* debug level */
# define S_DEBUGDEVICE	1001	/* BIOS device number */
# define S_DEBUGKMTRACE	1100	/* KM_TRACE debug feature */

long    Syield(void);
long    Fpipe(short *usrh);
long    Ffchown(short fh, short uid, short gid);
long    Ffchmod(short fh, short mode);
long    Fsync(short fh);
long    Fcntl(short fh, long arg, short cmd);
long    Finstat(short fh);
long    Foutstat(short fh);
long    Fgetchar(short fh, short mode);
long    Fputchar(short fh, long c, short mode);
long    Pwait(void);
long    Pnice(short increment);
long    Pgetpid(void);
long    Pgetppid(void);
long    Pgetpgrp(void);
long    Psetpgrp(short pid, short newgrp);
long    Pgetuid(void);
long    Psetuid(short id);
long    Pkill(short pid, short sig);
long    Psignal(short sig, __sig_handler *handler);
long    Pvfork(void);
long    Pgetgid(void);
long    Psetgid(short id);
long    Psigblock(long mask);
long    Psigsetmask(long mask);
long    Pusrval(long arg);
long    Pdomain(short newdom);
long    Psigreturn(void);
long    Pfork(void);
long    Pwait3(short flag, long *rusage);
long    Fselect(short timeout, long *rfd, long *wfd, long *xfd);
long    Prusage(long *rsp);
long    Psetlimit(short i, long val);
long    Talarm(long sec);
long    Pause(void);
long    Sysconf(short which);
long    Psigpending(void);
long    Dpathconf(const char *name, short which);
long    Pmsg(short mode, long mbox, MSG *msg);
long    Fmidipipe(short mode, short in, short out);
long    Prenice(short pid, short delta);
long    Dopendir(const char *name, short flags);
long    Dreaddir(short buflen, long dirh, char *buf);
long    Drewinddir(long dirh);
long    Dclosedir(long dirh);
long    Fxattr(short flag, const char *name, XATTR *buf);
long    Flink(const char *oldname, const char *newname);
long    Fsymlink(const char *oldname, const char *newname);
long    Freadlink(short buflen, char *buf, const char *linkfile);
long    Dcntl(short cmd, const char *name, long arg);
long    Fchown(const char *name, short uid, short gid);
long    Fchmod(const char *name, short mode);
long    Pumask(short mode);
long    Psemaphore(short mode, long id, long timeout);
long    Dlock(short mode, short drive);
long    Psigpause(long sigmask);
long    Psigaction(short sig, const SIGACTION *act, SIGACTION *oact);
long    Pgeteuid(void);
long    Pgetegid(void);
long    Pwaitpid(short pid, short flag, long *rusage);
long    Dgetcwd(char *path, short drive, short size);
long    Salert(char *msg);
long    Tmalarm(long time);
long    Psigintr(short vec, short sig);
long    Suptime(long *uptime, long loadaverage[3]);
long    Ptrace(short request, short pid, void *addr, long data);
long    Mvalidate(short pid, void *addr, long size, long *flags);
long    Dxreaddir(short len, long dirh, char *buf, XATTR *xattr,
                long *xret);
long    Pseteuid(short id);
long    Psetegid(short id);
long    Psetauid(short id);
long    Pgetauid(void);
long    Pgetgroups(short gidsetlen, short gidset[]);
long    Psetgroups(short ngroups, short gidset[]);
long    Tsetitimer(short which, long *interval, long *value,
            long *ointerval, long *ovalue);
long    Dchroot(const char *dir);
long    Fstat64(short flag, const char *name, void *stat);
long    Fseek64(long high, long low, short fh, short how, void *newpos);
long    Dsetkey(long major, long minor, char *key, short cipher);
long    Psetreuid(short rid, short eid);
long    Psetregid(short rid, short eid);
long    Sync(void);
long    Shutdown(long restart);
long    Dreadlabel(const char *path, char *label, short maxlen);
long    Dwritelabel(const char *path, const char *label);
long    Ssystem(short mode, long arg1, long arg2);

long    Tgettimeofday(void *tv, void *tz);
long    Tsettimeofday(void *tv, void *tz);
long    Tadjtime(const void *delta, void *olddelta);
long    Pgetpriority(short which, short who);
long    Psetpriority(short which, short who, short prio);
long    Fpoll(void *fds, long nfds, long timeout);
long    Fwritev(short fh, const void *iov, long iovcnt);
long    Freadv(short fh, const void *iov, long iovcnt);
long    Ffstat64(short fh, void *stat);
long    Psysctl(long *name, long namelen, void *old, long *oldlenp,
            const void *new, long newlen);
long    Pemulation(short which, short op, long a1, long a2, long a3,
            long a4, long a5, long a6, long a7);
long    Fsocket(long domain, long type, long protocol);
long    Fsocketpair(long domain, long type, long protocol, short fds[2]);
long    Faccept(short fh, void *name, long *namelen);
long    Fconnect(short fh, const void *name, long namelen);
long    Fbind(short fh, const void *name, long namelen);
long    Flisten(short fh, long backlog);
long    Frecvmsg(short fh, void *msg, long flags);
long    Fsendmsg(short fh, void *msg, long flags);
long    Frecvfrom(short fh, void *buf, long len, long flags,
            void *from, long *fromlen);
long    Fsendto(short fh, const void *buf, long len, long flags,
            const void *to, long tolen);
long    Fsetsockopt(short fh, long level, long name, const void *val,
            long valsize);
long    Fgetsockopt(short fh, long level, long name, void *val,
            long *avalsize);
long    Fgetpeername(short fh, void *addr, long addrlen);
long    Fgetsockname(short fh, void *addr, long addrlen);
long    Fshutdown(short fh, long how);
long    Pshmget(long key, long size, long shmflg);
long    Pshmctl(long shmid, long cmd, void *buf);
long    Pshmat(long shmid, const void *shmaddr, long shmflg);
long    Pshmdt(const void *shmaddr);
long    Psemget(long key, long nsems, long semflg);
long    Psemctl(long semid, long semnum, long cmd, void *arg);
long    Psemop(long semid, void *sops, long nsops);
long    Psemconfig(long flag);
long    Pmsgget(long key, long msgflg);
long    Pmsgctl(long msqid, long cmd, void *buf);
long    Pmsgsnd(long msqid, const void *msgp, long msgsz, long msgflg);
long    Pmsgrcv(long msqid, void *msgp, long msgsz, long msgtyp,
            long msgflg);
long    Maccess(void *addr, long size, short mode);
long    Fchown16(const char *name, short uid, short gid, 
            short follow_links);





/* The following functions are not compatible with multi-threading
   environments. It's better to not use them at all!    */

#ifdef NO_MULTITHREADING
long    cdecl bios(short num, ...);     /*  NOT reentrant !!!!  */
long    cdecl xbios(short num, ...);    /*  NOT reentrant !!!!  */
long    cdecl gemdos(short num, ...);   /*  NOT reentrant !!!!  */
#endif

#endif   /* _TOS_H */
