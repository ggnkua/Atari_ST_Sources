/*
*		Header for DSP-XBIOS-Library (rev. 3 and rev. 4)
*		Sound- and DSP-IO functions
*		Last update: 28.09.93			by J. Lietzow
*/

#ifndef __DSPLIB__
#define __DSPLIB__

/************	DSP IO functions    ************************/

/* sizeof( vdsp ) meens Dsp_GetWordSize() */
/* A vdsp-array is organized like a */
/* DSP word array. Actually 3 Bytes */

#define vdsp	char		

void Dsp_DoBlock( vdsp *data_in, long size_in, vdsp *data_out,
                  long size_out );
void Dsp_BlkHandshake( long *data_in, long size_in,
                       long *data_out, long size_out );
void Dsp_BlkUnpacked( long *data_in, long size_in,
                      long *data_out, long size_out );
void Dsp_InStream( vdsp *data_in, long block_size,
                   long num_blocks, long *blocks_done );
void Dsp_OutStream( vdsp *data_out, long block_size,
                    long num_blocks, long *blocks_done );
void Dsp_IOStream( vdsp *data_in, vdsp *data_out,
                   long block_insize, long block_outsize,
                   long num_blocks, long *blocks_done );
#define RECEIVE   1
#define TRANSMIT  2

void Dsp_RemoveInterrupts( int mask );
int  Dsp_GetWordSize( void );
int  Dsp_Lock( void );		/* 0 == OK */
void Dsp_Unlock( void );
void Dsp_Available( long *xavailable, long *yavailable );
int  Dsp_Reserve( long xreserve, long yreserve );
int  Dsp_LoadProg( char *file, int ability, vdsp *buffer );
void Dsp_ExecProg( vdsp *buffer, long codesize, int ability );
void Dsp_ExecBoot( vdsp *codeptr, long codesize, int ability );
long Dsp_LodToBinary( char *file, vdsp *buffer );
void Dsp_TriggerHC( int vector );
int  Dsp_RequestUniqueAbility( void );
int  Dsp_GetProgAbility( void );
void Dsp_FlushSubroutines( void );
int  Dsp_LoadSubroutine( vdsp *ptr, long size, int ability );
int  Dsp_InqSubrAbility( int ability );
int  Dsp_RunSubroutine( int handle );

#define HF_SET		1
#define HF_CLR		0
#define HF_READ		-1

int  Dsp_Hf0( int flag );
int  Dsp_Hf1( int flag );
int  Dsp_Hf2( void );
int  Dsp_Hf3( void );
void Dsp_BlkWords( int *data_in, long size_in, int *data_out,
                   long size_out );
void Dsp_BlkBytes( unsigned char *data_in, long size_in,
                   unsigned char *data_out, long size_out );
unsigned char  Dsp_HStat( void );
void Dsp_SetVectors(void volatile cdecl (*receiver)(long val),
                    long volatile cdecl (*transmitter)(void) );

#define BLKTYPE_LONG	0
#define BLKTYPE_INT		1
#define BLKTYPE_UCHAR	2

typedef struct dspblk
{
		int		block_type;
		long	blk_size;
		vdsp	*addr;
}	DSPBLK;

void Dsp_MultBlock( long num_send, long num_receive,
                    DSPBLK *send, DSPBLK *receive );

/************	DSP sound functions    *************/

/*	soundcmd() */
					  /* data mask: bits of low byte */
#define	LTATTEN		0 /* LLLL0000  left output */
#define	RTATTEN		1 /* RRRR0000  right output */
#define	LTGAIN		2 /* LLLL0000  left input */
#define	RTGAIN		3 /* RRRR0000  right input */
#define	ADDERIN		4 /* 000000MA  M: Muliplexer A: DA-Coder */
#define	ADCINPUT	5 /* 000000LR  L:Left- R:Right Sound-Chip */
					  /*           otherwise microphone */
#define	SETPRESCALE	6 /* 000000VV  1=1/640, 2=1/320, 3=1/160 */
					  /* only STE modus */
#define INQUIRE    -1

/*	setsndmode() */

#define	STEREO8		0
#define STEREO16	1
#define MONO8		2

/*	buffoper() */

#define PLAY_ENABLE		1
#define PLAY_REPEAT		2
#define RECORD_ENABLE	4
#define RECORD_REPEAT	8

/*	dsptristate() */

#define	TRISTATE		0
#define ENABLE			1

/*	devconnect() */

#define DMAPLAY			0
#define DSPXMIT			1
#define EXTINP			2
#define ADC				3

#define	DMAREC			0
#define DSPREC			1
#define EXTOUT			2
#define DAC				3

#define CLK25M			0
#define CLKEXTERN		1
#define CLK32M			2	/* not for CODEC */

/* for CLK25M only */

#define	CLKSTE			0	/* plus soundcmd(SETPRESCALE,) */
#define CLK50K			1
#define CLK33K			2
#define CLK25K			3
#define CLK20K			4
#define CLK16K			5
#define CLK12K			7
#define CLK10K			9
#define CLK8K			11

#define SHAKE			0
#define NO_SHAKE		1

/* Added SOUND BIOS Errors. */

#define	SNDNOTLOCK	-128
#define	SNDLOCKED	-129

#define vsnd	char

long locksnd( void );			/* 1 ==> OK */
long unlocksnd( void );			/* 0 ==> OK */
long soundcmd( int mode, int data );
long setbuffer( int reg, vsnd *begaddr, vsnd *endaddr );
long setsndmode( int mode );
long settracks( int playtracks, int rectracks );/* 0 - 3 */
long setmontrack( int montrack );				/* 0 - 3 */
long setinterrupt( int src_inter, int cause );
long buffoper( int mode );
long dsptristate( int dspxmit, int dsprec );
long gpio( int mode, int data );
long devconnect( int src, int dst, int srcclk, int prescale,
                 int protocol );
long sndstatus( int reset );	/* 1: reset CODEC 0: inquire */

typedef struct playrec
{
		vsnd	*playbufptr;
		vsnd	*recbufptr;
		long	reserved1, reserved2;
}	PLAYREC;

long buffptr( PLAYREC *pointer );

#endif