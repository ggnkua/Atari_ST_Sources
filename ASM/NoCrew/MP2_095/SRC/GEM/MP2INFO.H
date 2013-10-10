typedef struct
{
	unsigned int sync		: 12;
	unsigned int id			: 1;
	unsigned int layer		: 2;
	unsigned int protection	: 1;
	unsigned int bitrate	: 4;
	unsigned int frequency	: 2;
	unsigned int padding	: 1;
	unsigned int private	: 1;
	unsigned int mode		: 2;
	unsigned int mode_ext	: 2;
	unsigned int copyright	: 1;
	unsigned int original	: 1;
	unsigned int emphasis	: 2;
} FRAME_HEADER;

#define ID_LOWER 0
#define ID_NORMAL 1

#define LAYER_RESERVED 0
#define LAYER_I 1
#define LAYER_II 2
#define LAYER_III 3

#define PROT_CRC 0
#define PROT_NOCRC 1

#define PADDING_NO 0
#define PADDING_ADD 1

#define MODE_STEREO 0
#define MODE_JOINT 1
#define MODE_DUAL 2
#define MODE_MONO 3

#define MODE_EXT_SUB4 0
#define MODE_EXT_SUB8 1
#define MODE_EXT_SUB12 2
#define MODE_EXT_SUB16 3

#define NO_COPYRIGHT 0
#define COPYRIGHTED 1

#define COPY 0
#define ORIGINAL 1

#define NO_EMPHASIS 0
#define EMPHASIS_50_15 1
#define EMPHASIS_RESERVED 2
#define EMPHASIS_CCITT_J17 3

#ifdef IS_MP2INFO_C
static long bitrates[2][3][16] =  /* [id][layer][bitrate] */
{
	{ /* ID_LOWER */
		{ 0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L }, /* dummy layer */
		{ 0L,32000L,48000L,56000L,64000L,80000L,96000L,112000L,128000L,
			144000L,160000L,176000L,192000L,224000L,256000L,-1L }, /* Layer I */
		{ 0L,8000L,16000L,24000L,32000L,40000L,48000L,56000L,64000L,
			80000L,96000L,112000L,128000L,144000L,160000L,-1L }  /* Layer II */
	},
	{ /* ID_NORMAL */
		{ 0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L,0L }, /* dummy layer */
		{ 0L,32000L,64000L,96000L,128000L,160000L,192000L,224000L,
			256000L,288000L,320000L,352000L,384000L,416000L,448000L,-1L }, /* Layer I */
		{ 0L,32000L,48000L,56000L,64000L,80000L,96000L,112000L,128000L,
			160000L,192000L,224000L,256000L,320000L,384000L,-1L }  /* Layer II */
	}
};

static long frequencies[2][4] =  /* [id][frequency] */
{
	{ 22050L , 24000L , 16000L , 0L }, /* ID_LOWER */
	{ 44100L , 48000L , 32000L , 0L }  /* ID_NORMAL */
};
#endif /* IS_MP2INFO_C */

typedef struct
{
	long bitrate,sample_frequency,filelength,timelength;
} MP2INFO;

#define MP2_NOERR    0
#define MP2ERR_SYNC  1
#define MP2ERR_MONO  2
#define MP2ERR_CRC   3
#define MP2ERR_OTHER 42

