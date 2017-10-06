#if !defined(__SND_AU__)
#define __SND_AU__

/*
* "big-endian"
*         0       1       2       3
*         +-------+-------+-------+-------+
* 0       | 0x2e  | 0x73  | 0x6e  | 0x64  |       "magic" number
*         +-------+-------+-------+-------+
* 4       |                               |       data location
*         +-------+-------+-------+-------+
* 8       |                               |       data size
*         +-------+-------+-------+-------+
* 12      |                               |       data format (enum)
*         +-------+-------+-------+-------+
* 16      |                               |       sampling rate (int)
*         +-------+-------+-------+-------+
* 20      |                               |       channel count
*         +-------+-------+-------+-------+
* 24      |       |       |       |       |       (optional) info  
*                                                 string
*
* 28 = minimum value for data location
*/

typedef struct {
    long magic;               /* magic number SND_MAGIC */
    long dataLocation;        /* offset or pointer to the data */
    long dataSize;            /* number of bytes of data */
    long dataFormat;          /* the data format code */
    long samplingRate;        /* the sampling rate */
    long channelCount;        /* the number of channels */
    char info[4];            /* optional text information */
} SNDSoundStruct;

#define SND_FORMAT_UNSPECIFIED	0  /* unspecified format */
#define SND_FORMAT_MULAW_8			1  /* 8-bit mu-law samples */
#define SND_FORMAT_LINEAR_8		2  /* 8-bit linear samples */
#define SND_FORMAT_LINEAR_16		3  /* 16-bit linear samples */
#define SND_FORMAT_LINEAR_24		4  /* 24-bit linear samples */
#define SND_FORMAT_LINEAR_32		5  /* 32-bit linear samples */
#define SND_FORMAT_FLOAT			6  /* floating-point samples */
#define SND_FORMAT_DOUBLE			7  /* double-precision float samples */
#define SND_FORMAT_INDIRECT		8  /* fragmented sampled data */
#define SND_FORMAT_NESTED			9  /* ? */
#define SND_FORMAT_DSP_CORE		10 /* DSP program */
#define SND_FORMAT_DSP_DATA_8		11 /* 8-bit fixed-point samples */
#define SND_FORMAT_DSP_DATA_16	12 /* 16-bit fixed-point samples */
#define SND_FORMAT_DSP_DATA_24	13 /* 24-bit fixed-point samples */
#define SND_FORMAT_DSP_DATA_32	14 /* 32-bit fixed-point samples */
#define SND_FORMAT_DISPLAY			16 /* non-audio display data */
#define SND_FORMAT_MULAW_SQUELCH	17 /* ? */
#define SND_FORMAT_EMPHASIZED				18 /* 16-bit linear with emphasis */
#define SND_FORMAT_COMPRESSED				19 /* 16-bit linear with compression */
#define SND_FORMAT_COMPRESSED_EMPHASIZED	20 /* A combination of the two above */
#define SND_FORMAT_DSP_COMMANDS				21 /* Music Kit DSP commands */
#define SND_FORMAT_DSP_COMMANDS_SAMPLES	22 /* ? */

/* Some new ones supported by Sun.  This is all I currently know. --GvR */

#define SND_FORMAT_ADPCM_G721		23
#define SND_FORMAT_ADPCM_G722		24
#define SND_FORMAT_ADPCM_G723_3	25
#define SND_FORMAT_ADPCM_G723_5	26
#define SND_FORMAT_ALAW_8			27

#endif