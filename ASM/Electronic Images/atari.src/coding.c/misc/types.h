/*
 *	Various types.
 */

typedef unsigned char  UBYTE;
typedef unsigned short UINT16;
typedef unsigned long  UINT32;
typedef char  BYTE;
typedef short INT16;
typedef long  INT32;
typedef enum bool {FALSE=0,TRUE=1} Bool;

#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) < (b) ? (b) : (a))

#define SWAP32(a,b) { INT32 t = (a); b=(a) ; (a) = t; }
#define SWAP16(a,b) { INT16 t = (a); b=(a) ; (a) = t; }
#define SWAP8(a,b) { BYTE t = (a); b=(a) ; (a) = t; }

typedef enum {
   SUCCESS	= 0,
   OPEN_FAILED	= 1,
   READ_ERROR	= 2,
   WRITE_ERROR	= 3,
   WRONG_FORMAT	= 4,
   OUT_OF_MEMORY= 5
} DISK_STATUS;

typedef enum {
    BITS8_SIGNED   = 0,
    BITS8_UNSIGNED = 1,
    BITS16_SIGNED  = 2,
    BITS16_UNSIGNED= 3
} SAMPLE_FORMAT;

typedef struct {
	UINT32 samples;
	UINT32 frequency;
	SAMPLE_FORMAT format;
	char *data_ptr;
	char *malloc_ptr;
} Generic_SampleInfo;

#define PATCH_ID "GF1PATCH110"

typedef struct {
    	UBYTE  ident[12];
	UBYTE  version[10];
	UBYTE  descript[60];
	UBYTE  instruments;
	UBYTE  voices;
	UBYTE  channels;
	UINT16 waveforms;
	UINT16 master_volume;
	UINT32 data_length;
	UBYTE  reserved[36];
	UINT16 instrument_no;
	UBYTE  instrument_name[16];
	UINT32 instrument_length;
	UBYTE  layers;
	UBYTE  ireserved[40];
} PATCH_HEADER;

typedef struct {
    	UBYTE  name[7];
	UBYTE  lp_fractions;
	UINT32 length;
	UINT32 loop_start;
	UINT32 loop_end;
	UINT16 sample_rate;
	UINT32 low_freq;
	UINT32 high_freq;
	UINT32 root_freq;
	UINT16 tune;
	UBYTE balance;
	UBYTE env_rates[6];
	UBYTE env_offsets[6];
	UBYTE tremolo[3];
	UBYTE vibrato[3];
	UBYTE modes;
	UINT16 scale_factor;
	UBYTE reserved[36];
} PATCH_DATA;

#define DEFAULT_FREQUENCY 32768
