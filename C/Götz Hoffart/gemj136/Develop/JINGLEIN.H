#if !defined(__JINGLE_IN__)
#define __JINGLE_IN__

#define	LTATTEN				0
#define	RTATTEN				1
#define	LTGAIN				2
#define	RTGAIN				3
#define	ADDERIN				4
#define	ADCINPUT				5
#define	SETPRESCALE			6
#define	ADC					3

#define SMP_HEAD		0x7e817e81L			/* '~~', SMP-Format von Galactic	*/
#define VOC_HEAD		0xabcdef12L			/* dummy f. Test					*/
#define AVR_HEAD		0x32424954L			/* Michtrons AVR-Format			*/
#define STEue_HEAD	0x53544581L			/* 'STE', von SMP abgeleitetes, eigenes Format */
#define DVS_HEAD		0x4456534dL			/* 'DVSM'							*/
#define JAVA_HEAD		0x4A415641L			/* von WAVE abgeleitet			*/
#define WAV_HEAD		0x52494646L			/* 'RIFF': WAVE-Format			*/
#define NeXT_HEAD		0x2e736e64L			/* '.snd'; NeXT/au-Format		*/
#define PSION_HEAD	0x414C6177L			/* 'ALaw'; Psion WVE-Format	*/

#define ST_SOUND	1
#define STE_SOUND 2
#define FLC_SOUND 3

#define	AUDIOGROESSE		32000L
#define	VORTEILER			1

/* m”gliche VORTEILER-Werte */
#define R_KHZ49   1		/*49170*/
#define R_KHZ33   2		/*33880*/
#define R_KHZ24   3		/*24585*/
#define R_KHZ20   4		/*20770*/
#define R_KHZ16   5		/*16940*/          /* (kein Vorteiler 6,8,10 !!) */
#define R_KHZ12   7		/*12292*/
#define R_KHZ09   9		/* 9834*/
#define R_KHZ08  11		/* 8195*/

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
#define	DSPREC		0x2
#define	DMAREC		0x1

#define	STEREO8		0
#define	STEREO16		1
#define	MONO8			2

#define	ENABLE		1
#define	TRISTATE		0

#define	PLAY_ENABLE		1		/* fr buffoper */
#define	PLAY_REPEAT		2
#define	RECORD_ENABLE	4
#define	RECORD_REPEAT	8		/* PC-Doku: 2, ist falsch ! */

#define	PLAY			0
#define	RECORD		1

#define	CLK_25M		0
#define	CLK25M		0
#define	CLK_EXT		1
#define	CLK_32M		2

#define	NO_SHAKE		1
#define	HANDSHAKE	0

#define	CLK50K		1
#define	CLK33K		2
#define	CLK25K		3
#define	CLK20K		4
#define	CLK16K		5
#define	CLK12K		7
#define	CLK10K		9
#define	CLK8K			11

#define	ACT_CLK50K	49170L
#define	ACT_CLK33K	33880L
#define	ACT_CLK25K	24585L
#define	ACT_CLK20K	20770L
#define	ACT_CLK16K	16490L
#define	ACT_CLK12K	12292L
#define	ACT_CLK10K	9834L
#define	ACT_CLK8K	8195L

/*
 *  SOUND XBIOS Errors.
 */
#define	SNDNOTLOCK	-128
#define	SNDLOCKED	-129

/* STRK-XBIOS-Erweiterungen */
#define cardmagic() xbios(500,12)

enum dvs_modes
{
	DVS8 = 0, DVS9, DVS12, DVS16, DVS19, DVS24, DVS32,
	DVS49
};

/* Der Header eines HSN-Samples */
/* Header des HSN-Formats Version 1.1 */
typedef struct
{
    char    name[20];
    long    laenge;
    int     frequenz;
    int     stereo;
    int     res1;
    int     bitsps;
    int     res2;
    int     dm_laut;
    int     dm_links;
    int     dm_rechts;
    int     dm_hoehen;
    int     dm_tiefen;
    long    res3;
    char    info[41];
} HSN_NEW;

/* Header des HSN-Formats Version 1.0 */
typedef struct
{
    char    name[20];
    long    laenge;
    int     frequenz;
    int     stereo;
    int     res1;
    int     bitsps;
    int     res2;
    int     dm_laut;
    int     dm_links;
    int     dm_rechts;
    int     dm_hoehen;
    int     dm_tiefen;
    long    res3;
} HSN_ALT;

typedef struct
{
	ULONG	main_chunk;		/* 'RIFF' */
	ULONG	length;			/* Gesamtl„nge der Datei */
	ULONG	chunk_type;		/* 'WAVE' */
	ULONG	sub_chunk;		/* 'fmt ' */
	ULONG	len_sub;			/* L„nge sub_chunk, immer =16 Bytes */
	WORD	format;			/* momentan immer =1 fr PCM-Code */
	WORD	modus;			/* =1 fr Mono und =2 fr Stereo */
	ULONG	sample_fq;		/* Sample-Frequenz */
	ULONG	byte_p_sec;		/* Datendurchsatz pro Sekunde */
	WORD	byte_p_spl;		/* Bytes per Sample; =1 fr 8-Bit, =2 fr 16 Bit */
	WORD	bit_p_spl;		/* Bits per Sample; 8,12,16 */
	ULONG	data_chunk;		/* Kennung des Data-Bereichs ='data' */
	ULONG data_length;	/* L„nge des Data-Blocks */
} my_wav_hd;

typedef struct
{
	ULONG	len_sub;			/* L„nge sub_chunk, immer =16 Bytes */
	WORD	format;			/* momentan immer =1 fr PCM-Code */
	WORD	modus;			/* =1 fr Mono und =2 fr Stereo */
	ULONG	sample_fq;		/* Sample-Frequenz */
	ULONG	byte_p_sec;		/* Datendurchsatz pro Sekunde */
	WORD	byte_p_spl;		/* Bytes per Sample; =1 fr 8-Bit, =2 fr 16 Bit */
	WORD	bit_p_spl;		/* Bits per Sample; 8,12,16 */
} SUB_CH;

typedef struct
{
	ULONG	main_chunk;		/* 'JAVA' */
	LONG	res1;
	LONG	res2;
	ULONG	length;			/* Gesamtl„nge der Datei */
	ULONG	chunk_type;		/* 'JAVA' */
	ULONG	sub_chunk;		/* 'BYTE' */
	ULONG	len_sub;			/* L„nge sub_chunk, immer =16 Bytes */
	WORD	format;			/* momentan immer =1 fr PCM-Code */
	WORD	modus;			/* =1 fr Mono und =2 fr Stereo */
	ULONG	sample_fq;		/* Sample-Frequenz */
	ULONG	byte_p_sec;		/* Datendurchsatz pro Sekunde */
	WORD	byte_p_spl;		/* Bytes per Sample; =1 fr 8-Bit, =2 fr 16 Bit */
	WORD	bit_p_spl;		/* Bits per Sample; 8,12,16 */
	ULONG	data_chunk;		/* Kennung des Data-Bereichs ='data' */
	ULONG data_length;	/* L„nge des Data-Blocks */
} my_java_hd;

typedef struct
{
	ULONG id;			/* Kennung $7e817e81								*/
	UWORD header_len;	/* L„nge dieses Vorspanns						*/
	UWORD info_len;	/* L„nge zus„tzlicher Infos nach diesem Vorspann */
	ULONG	sam_len;		/* Samplel„nge ungepackt						*/
	ULONG sam_lenp;	/* Samplel„nge   gepackt						*/
	UBYTE res;			/* Bitzahl pro Samplewert (4,8,16)			*/
	UBYTE fmt;			/* Bitzahl eines Samplewerts auf Medium 	*/
	ULONG	frq;			/* Samplefrequenz in Hz 						*/
	UWORD flags;		/* Low-Byte: Kanalzahl (0=Mono, 1=Stereo)	*/
							/* Bit 8:	0: Kan„le abwechselnd			*/
							/*				1: Kan„le in Bl”cken hintereinander */
							/* Bit 9:	1: Relativkomprimieren (Delta)*/
							/* Bit 10:	1: Huffman							*/
							/* Bit 11-14: Computer; 0=Atari				*/
	UWORD	rel_len;		/* Spannweite beim Relativkomprimieren		*/
	ULONG date;			/* Format:	Tgetdate								*/
	ULONG time;			/*				Tgettime								*/
	UBYTE rem[150];	/* Bemerkungen										*/
	UWORD blocks;		/* Markenanzahl (hier: immer 0)				*/
	WORD	hufftablen;	/* L„nge der Huffmantabelle (immer 8Bit bezogen) */
} SMPHEADER;

typedef struct
{
	char magic[6];			/* "DVSM\0\0" */
	int headlen;			/* Headlen in Bytes*/
	unsigned int freq;/* Samplefrequenz 0=8kHz 7=50kHz (erlaubte 
	                    CODEC Frequenzen)*/
	char pack,mode;	/* 0=Ungepackt, 2=DVS Packmethode(CPU)*/ /* 0=Stereo 8Bit,1=Stereo 16Bit,2=Mono 8Bit*/
	LONG blocklen;		/* falls pack>1: L„nge eines gepackten Blocks*/
} DVSMHEAD;

typedef struct
{
	LONG	magic;				/* '2BIT' */
	BYTE	rsv1[7];				/* reserviert/unbekannt */
	BYTE	channels;			/* 12. Byte: Kan„le */
	BYTE	rsv2[2];				/* reserviert/unbekannt */
	BYTE	res;					/* 15. Byte: RESolution - Aufl”sung in Bit */
	BYTE	rsv3;					/* reserviert/unbekannt */
	BYTE	sign;					/* 17. Byte: Vorzeichen der Sampledaten */
	BYTE	rsv4[4];				/* reserviert/unbekannt */
	LONG	frq;					/* 22. Byte: Frequenz in Hz */
	LONG	len;					/* 26. Byte: L„nge, muž bei STEREO verdoppelt werden! */
} AVRHEADER;

typedef struct
{
        BYTE magic[4];				/* "2BIT" */
        BYTE name[8];           /* null-padded sample name */
        UWORD mono;             /* 0 = mono, 0xffff = stereo */
        WORD rez;              /* 8 = 8 bit, 16 = 16 bit */
        UWORD sign;             /* 0 = unsigned, 0xffff = signed */
        UWORD loop;             /* 0 = no loop, 0xffff = looping sample */
        WORD midi;             /* 0xffff = no MIDI note assigned,
                                   0xffXX = single key note assignment
                                   0xLLHH = key split, low/hi note */
        LONG rate;              /* sample frequency in hertz */
        LONG size;              /* sample length in bytes or words (see rez) */
        LONG lbeg;              /* offset to start of loop in bytes or words.
                                   set to zero if unused. */
        LONG lend;              /* offset to end of loop in bytes or words.
                                   set to sample length if unused. */
        WORD res1;             /* Reserved, MIDI keyboard split */
        WORD res2;             /* Reserved, sample compression */
        WORD res3;             /* Reserved */
        BYTE ext[20];           /* Additional filename space, used
                                   if (name[7] != 0) */
        BYTE user[64];          /* User defined. Typically ASCII message. */
} AVR_NEWHEADER;

#define PSION_COMPLETE_MAGIC	"ALawSoundFile**"
#define PSION_HEADER_LEN		32
typedef struct
{
	/* Immer 8000 Hz mono signed */
	BYTE magic[16];	/* "ALawSoundFile**" */
	WORD fmt_version;	/* format version number */
	LONG num_samples; /* number of samples in the file */
	WORD len_silence;	/* length of silence (in 1/32 seconds)
								to append on playback */
	WORD repeats;		/* number of times to repeat on playback
								(0 and 1 both mean play once) */
} PSION_WVE_HEADER;

typedef struct
{
	LONG playbufptr;
	LONG recbufptr;
	LONG res1,res2;
} DMAPOS;

#endif