/*
 *	Various Standard types and macros.
 * 	Martin Griffiths August-November 1994
 */


#define RESOURCENAME  "MIDIPLAY.RSC"
#define CFG_NAME	  "MIDIPLAY.CFG"
#define MAP_NAME      "MIDIPLAY.MAP"
#define LOD_FILENAME  "MIDI_ENG.LOD"
#define VERSION "0.70\x9e"
#define GMSOURCESET_PATH "F:\\GM1.SET\\"
#ifndef FALSE
#define FALSE (0)
#endif

#ifndef TRUE
#define TRUE (1)
#endif

long filesize(char *);

#define ENVELOPES (6)
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) < (b) ? (b) : (a))
#define SWAP32(a,b) { INT32 t = (a); b=(a) ; (a) = t; }
#define SWAP16(a,b) { INT16 t = (a); b=(a) ; (a) = t; }
#define SWAP8(a,b) { BYTE t = (a); b=(a) ; (a) = t; }
#define swapi(a)   (( (UINT16) a & 0xFF) << 8) | ( (UINT16) a >> 8)
#define swapl(a)   (( (UINT32) a & 0xFF) << 24) | (( (UINT32) a & 0xFF00) << 8) | (( (UINT32) a & 0xFF0000) >> 8) | ( (UINT32) a >> 24)

typedef int Bool;
#ifndef UBYTE
typedef unsigned char UBYTE;
#endif
typedef unsigned short UINT16;
typedef unsigned long  UINT32;
#ifndef BYTE
typedef char BYTE;
#endif

typedef short INT16;
typedef long  INT32;

typedef struct
{	long	num_samples;
	long	a,b,c;
	long	sample_offsets[128];
	long	sample_freqshs[128];
} NEW_PATCH_MAIN_HEADER;

typedef struct
{	unsigned long	wave_size;
	unsigned long 	start_loop;
	unsigned long	end_loop;
	unsigned short	tune;
	unsigned short	scale_frequency;
	unsigned short	scale_factor;		/* from 0 to 2048 or 0 to 2 */
	unsigned short	sample_rate;
	unsigned char	envelope_rate[ ENVELOPES ];
	unsigned char	envelope_offset[ ENVELOPES ];	
	unsigned char	balance;
	unsigned char	modes;
	char		reserved[62];
} NEW_SAMPLE_HEADER;

typedef enum { NOSONG=0,PLAYING=1,STOPPED=2,PAUSED=3,MIDI_IN=4} Player_status;
typedef enum { INSTRUMENT_CHANNEL=0,PERCUSSION_CHANNEL=1} Channel_Type;
typedef enum { INSTRUMENT=0,PERCUSSION=1 } VIEWING; 

typedef struct {
	void *ptr;
	void *allocd;
} alloc16;

typedef struct
{ 
	unsigned long channel_noteflags[4];
	unsigned short channel_note_vces[128];
 	unsigned short channel_volume;
 	unsigned short channel_bend;
 	unsigned short channel_pan;
	unsigned char channel_used;
 	unsigned char channel_inst;
 	unsigned char noteon_ef;
 	unsigned char polypres_ef;
 	unsigned char controller_ef;
 	unsigned char progchange_ef;
 	unsigned char aftertouch_ef;
 	unsigned char pitchbend_ef;
} channel;

typedef struct 
{	
	alloc16	sample_pointer;
	unsigned char Patch_UsedFlag;
	unsigned char Patch_NoSamples;
	unsigned char Patch_StereoOffy;
	unsigned char Patch_has_loop;
} Patch_Info;

extern char *title;
extern Bool HQModeFlag;
extern Bool AutoLoadMapFlag;
extern Bool AutoTestPatchFlag;
extern Bool FilterFlag[16];
extern VIEWING Current_View;
extern int viewinst_selected;
extern int viewperc_selected;
extern int selected_channel;
extern char curr_songpath[256];  /* Current Song Path */
extern char curr_songname[256];  /* Current Song Filename */
extern char selected_song[256];
extern unsigned char def_channel_list[16];
extern unsigned char def_channel_type[16];
extern channel channels_info[16];
extern int no_patches;
extern int Patches_Loaded;	
extern Patch_Info PatchLIST[256];

#define NO_PERCUSSION (47)
#define NO_INSTRUMENT (128)
#define FNAME_LEN (64) 
#define PNAME_LEN (24)

extern char gm_instrument[NO_INSTRUMENT][PNAME_LEN];
extern char gm_percussion[NO_PERCUSSION][PNAME_LEN];
extern char gm_instrument_fnames[NO_INSTRUMENT][FNAME_LEN];
extern char gm_percussion_fnames[NO_PERCUSSION][FNAME_LEN];
extern unsigned long master_vol;
extern unsigned long master_bal;
extern unsigned char Insts_Used[NO_INSTRUMENT];
extern unsigned char Percs_Used[NO_INSTRUMENT];
extern unsigned char Insts_Used_In_Song[NO_INSTRUMENT];
extern unsigned char Percs_Used_In_Song[NO_INSTRUMENT];
extern unsigned char Insts_Used_In_SongOLD[NO_INSTRUMENT];
extern unsigned char Percs_Used_In_SongOLD[NO_INSTRUMENT];

#define DEFAULT_FREQUENCY 32780

typedef enum
{  NOERROR	= 0,
   OPEN_FAILED	= 1,
   READ_ERROR	= 2,
   WRITE_ERROR	= 3,
   WRONG_FORMAT	= 4,
   OUT_OF_MEMORY= 5
} DISK_STATUS;


/*
 *	Sample related stuff
 */ 


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
	UBYTE  layer_duplicate;
	UBYTE  layer;
	UBYTE layer_size[4];
	UBYTE  samples;
	UBYTE  lreserved[40];
} PATCHHEADER;

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
	UBYTE tremolo_sweep;
	UBYTE tremolo_rate;
	UBYTE tremolo_depth;
	UBYTE vibrato_sweep;
	UBYTE vibrato_rate;
	UBYTE vibrato_depth;
	UBYTE modes;
	UINT16 scale_frequency;
	UINT16 scale_factor;
	UBYTE reserved[36];
} SAMPLEPATCH;

