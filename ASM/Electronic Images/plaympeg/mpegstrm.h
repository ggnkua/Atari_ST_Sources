/*
 *		PLAYMPEG v0.71
 *		(c) 1994/95 Martin Griffiths
 */
 
/* MPEG Stream Constants */

/* Start codes. */

#define PICTURE_START_CODE       0x00000100
#define SLICE_MIN_START_CODE     0x00000101
#define SLICE_MAX_START_CODE     0x000001af
#define RESERVED_START_CODE_1    0x000001b0
#define RESERVED_START_CODE_2    0x000001b1
#define USER_START_CODE          0x000001b2
#define SEQ_START_CODE           0x000001b3
#define EXT_START_CODE           0x000001b5
#define RESERVED_START_CODE_3    0x000001b6
#define SEQ_END_CODE             0x000001b7
#define GOP_START_CODE           0x000001b8
#define ISO_11172_END_CODE       0x000001b9
#define PACK_START_CODE          0x000001ba
#define SYSTEM_HEADER_START_CODE 0x000001bb
#define RESERVED_STREAM          0x000001bc
#define PRIVATE_STREAM_1         0x000001bd
#define PADDING_STREAM           0x000001be
#define PRIVATE_STREAM_2         0x000001bf
#define AUDIO_STREAM_0           0x000001c0
#define AUDIO_STREAM_31          0x000001df
#define VIDIO_STREAM_0           0x000001e0
#define VIDIO_STREAM_15          0x000001ef
#define RESERVED_DATA_STREAM_0   0x000001f0
#define RESERVED_DATA_STREAM_15  0x000001ff

/* other stuff */
#define MAX_NUM_STREAMS  43

/* Picture_coding_type */

#define I_TYPE  1
#define P_TYPE  2
#define B_TYPE  3
#define D_TYPE  4

/* Macros used with macroblock address decoding. */

#define MB_STUFFING  34
#define MB_ESCAPE    35

/* Special values for DCT Coefficients */
#define END_OF_BLOCK  62
#define ESCAPE        61

/* Audio */

#define AUDIO_HEADER_SYNC  0xfff

#define LAYER_I        3
#define LAYER_II       2
#define LAYER_III      1
#define LAYER_RESERVED 0

#define SAMPLE_FREQ_44		0
#define SAMPLE_FREQ_48		1
#define SAMPLE_FREQ_32		2
#define SAMPLE_FREQ_RESERVED	3

#define MODE_STEREO         0
#define MODE_JOINT_STEREO   1
#define MODE_DUAL_CHANNEL   2
#define MODE_SINGLE_CHANNEL 3

#define EMPHASIS_NONE       0
#define EMPHASIS_50_15      1
#define EMPHASIS_RESERVED   2
#define EMPHASIS_CCITTJ17   3

typedef struct {
	FILE			*stream;
	unsigned int	STD_scale;		/*  1 bit  */
	unsigned int	STD_size;		/* 13 bits */
	unsigned int	PTS_hibit;		/*  1 bit  */
	unsigned int	PTS;			/* 32 bits */
	unsigned int	DTS_hibit;		/*  1 bit  */
	unsigned int	DTS;			/* 32 bits */
} StreamInfo;

typedef struct {
	unsigned int	SCR_hibit;		/*  1 bit  */
	unsigned int	SCR;			/* 32 bits */
	unsigned int	mux_rate;		/* 22 bits */
} Pack_Header;

typedef struct {
	unsigned int	header_length;	/* 16 bits  */
	unsigned int	rate_bound;		/* 22 bits  */
	unsigned int	audio_bound;	/*  6 bits  */
	unsigned int	fixed_flag;		/*  1 bit   */
	unsigned int	CSPS_flag;		/*  1 bit   */
	unsigned int	audio_lock_flag;/*  1 bit   */
	unsigned int	video_lock_flag;/*  1 bit   */
	unsigned int	video_bound;	/*  5 bits  */
	unsigned int	reserved_byte;	/*  8 bits  */
	unsigned int	STD_flag[MAX_NUM_STREAMS];
	unsigned int	STD_scale_bound[MAX_NUM_STREAMS];
	unsigned int	STD_size_bound[MAX_NUM_STREAMS];
} System_Header;

typedef struct {
	unsigned int	stream_id;		/*  8 bits  */
	unsigned int	packet_length;	/* 16 bits  */
	unsigned int	STD_flag;		/*  1 bit   */
	unsigned int	STD_scale;		/*  1 bit   */
	unsigned int	STD_size;		/* 13 bits  */
	unsigned int	PTS_Flag;		/*  1 bit   */
	unsigned int	PTS_hibit;		/*  1 bit   */
	unsigned int	PTS;			/* 32 bits  */
	unsigned int	DTS_Flag;		/*  1 bit	*/
	unsigned int	DTS_hibit;		/*  1 bit   */
	unsigned int	DTS;			/* 32 bits  */
	unsigned int	buffer_size;
	char			*buffer;
} Packet;

