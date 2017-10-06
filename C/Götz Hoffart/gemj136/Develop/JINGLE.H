#if !defined(__JINGLE__)
#define __JINGLE__

#define RT_NO_MEM     117
#define RT_NO_FILE    118
#define RT_PACKED     119
#define RT_WRONG_CHUNK  120
#define RT_WRONG_FILE 121
#define RT_LOCKED     122
#define RT_SND_ERR    123
#define RT_WRONG_HARDWARE 124
#define RT_UNSUPPORTED_AU_SND 125

#define MLC_ST_RAM  0
#define MLC_TT_RAM  1
#define MLC_STTT_RAM  2
#define MLC_TTST_RAM  3

#define ST      0
#define TT      1
#define FALCON  2

#define _SND_COOKIE 0x5f534e44L
#define McSn_COOKIE 0x4d63536eL
#define HSN_COOKIE  0x48536e64L
#define MagX_COOKIE 0x4D616758L
#define MiNT_COOKIE 0x4D694E54L
#define FSEL_COOKIE 0x4653454cL
#define STIC_COOKIE 0x53744963L
#define MgMc_COOKIE 0x4D674D63L
#define MgPC_COOKIE 0x4D675043L
#define Lity_COOKIE 0x4C697479L
#define strk_COOKIE 0x7374726bL

#define HSND_COMP   1
#define MSND_COMP   2
#define F030_COMP   3
#define STE_COMP    4
#define ST_COMP   5
#define ST_W_COMP   6	/* "weiche" Frequenzen: alle sind mîglich */
#define ST_H_COMP   7	/* "harte" Frequenzen, es gehen nur bestimmte, siehe flc_play_sam() */

#define NONE_COMP   100

typedef struct
{
    short   vers;   /* Version in BCD*/
    short   size;   /* Grîûe der Struktur */

    short   play;   /* AbspielfÑhigkeiten */
    short   record; /* AufnahmefÑhigkeiten */
    short   dsp;    /* Ist der DSP da? */
    short   pint;   /* Playing: Interrupt mîglich bei Frame-Ende */
    short   rint;   /* Recording: Interrupt mîglich bei Frame-Ende */

    long    res1;   /* Reserviert....... */
    long    res2;
    long    res3;
    long    res4;
} McSnCookie_STRCT;

typedef struct
{
  WORD    *adr;       	/* Startadresse       */
  WORD    *end;       	/* Endadresse         */
  ULONG   len;        	/* SamplelÑnge          */
  ULONG   header_len;   /* gesamter Header!     */
  WORD    *sample_start;/* Adresse, ab der der Datenteil anfÑngt */
  UWORD   res;        	/* Auflîsung          */
  ULONG   frq;        	/* Frequenz in Hz       */
  UWORD   channels;   	/* KanÑle           */
  WORD    fmt;        	/* Format: 1=WAV, 2=DVS, 3=SMP, 4=STE */
  WORD    snd_system;   /* vorhandene Soundhardware des Systems */
 /* WORD    malloc_flag; */ /* 0, wenn die Routinen RAM allozieren sollen, ==1, wenn es der Aufrufer tat */
  WORD    delayrate;    /* Pause zw. Wiederholungen in Sekunden; 0 = keine Pause */
  WORD    repeatrate;   /* Wie oft wiederholen? 0 = keinmal Wiederholen = einmal Spielen */
  BYTE *	 memoryplay;	/* Aus dem Speicher heraus spielen */
  ULONG	 memoryplay_len;	/* Aus dem Speicher heraus spielen */
  BOOLEAN no_menu;      /* */
  BOOLEAN gs_valid;		/* Parameter-Flag fÅr GEMScript, siehe split_gs_line() */
  BYTE    *file;      	/* Zu spielende Datei */
} NEWDEF;

extern BYTE sam_flag;

WORD spiele_sample(NEWDEF *new);
WORD get_cookie(CONST LONG cookie, LONG *value);


LONG    FileLen(CONST BYTE *fname);
VOID    *OwnMalloc(CONST LONG amount, CONST WORD typ);
VOID    OwnMfree(CONST VOID *adr);
BOOLEAN Laden(CONST BYTE *fname, BYTE *addr, CONST LONG len);
VOID    handle_SIGUSR1(VOID);
VOID    handle_SIGTERM(VOID);
VOID    output(NEWDEF *new);

#endif
