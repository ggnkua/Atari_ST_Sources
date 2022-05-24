/***************************************************/
/* S3m player by Daniel Marks                      */
/* (C) 1994 By Daniel Marks                        */
/* This code (and this code only!) copyrighted     */
/* under the GNU Public License.  See the          */
/* accompanying file COPYING for terms of this     */
/* agreement.                                      */
/*                                                 */
/* Thank you to Carlos Hasan for helpful assembly  */
/* source for his mod player, and to VLA.          */
/***************************************************/

/* Daniel Marks */
/* MOD/S3M portable module */

#define NEAR_FAR_PTR

#ifdef linux
#define BIT_32
#undef NEAR_FAR_PTR
#endif

#ifdef BIT_32
typedef short int int16;
typedef unsigned short int uint16;
typedef int int32;
typedef unsigned int uint32;
typedef char int8;
typedef unsigned char uint8;
#else
typedef int int16;
typedef unsigned int uint16;
typedef long int int32;
typedef unsigned long int uint32;
typedef char int8;
typedef unsigned char uint8;
#endif

#ifdef NEAR_FAR_PTR
typedef uint8 near *sample8_near;
typedef uint16 near *sample16_near;
typedef uint8 far *sample8_far;
typedef uint16 far *sample16_far;
typedef uint8 far *pattern_ptr;
#else
typedef uint8 *sample8_near;
typedef uint16 *sample16_near;
typedef uint8 *sample8_far;
typedef uint16 *sample16_far;
typedef uint8 *pattern_ptr;
#endif

#define EFF_VOL_SLIDE 0x01
#define EFF_PORT_DOWN 0x02
#define EFF_PORT_UP   0x04
#define EFF_VIBRATO   0x08
#define EFF_ARPEGGIO  0x10
#define EFF_PORT_TO   0x20
#define EFF_TREMOLO   0x40
#define EFF_RETRIG    0x80

#define MIX_BUF_SIZE 2048
#define DEF_TEMPO_NTSC 6
#define DEF_TEMPO_PAL  6
#define DEF_BPM_NTSC 125
#define DEF_BPM_PAL 145
#define MIDCRATE 8448

#define MAX_SAMPLES 100
#define MAX_TRACKS 32

#define endian_switch(x) (((((uint16)(x)) & 0xFF00) >> 8) | \
			  ((((uint16)(x)) & 0xFF) << 8))

#define long_endian_switch(x) ( ((((uint32)(x)) & 0xFF00) << 8) | \
			        ((((uint32)(x)) & 0xFF) << 24) | \
			        ((((uint32)(x)) & 0xFF0000) >> 8) | \
			        ((((uint32)(x)) & 0xFF000000) >> 24))

#if __BYTE_ORDER == 4321
#define big_endian(x) (x)
#define long_big_endian(x) (x)
#define little_endian(x) (endian_switch(x))
#define long_little_endian(x) (long_endian_switch(x))
#else
#define big_endian(x) (endian_switch(x))
#define long_big_endian(x) (long_endian_switch(x))
#define little_endian(x) (x)
#define long_little_endian(x) (x)
#endif

#define S3M_MAGIC1 0x101A
#define S3M_MAGIC2 "SCRM"
#define S3M_INSTR2 "SCRS"

typedef struct _s3m_header
{
  int8              name[28];
  uint16            s3m_magic_1;
  uint16            npi1;
  uint16            seq_len;
  uint16            n_instr;
  uint16            n_patts;
  uint16            word_4;
  uint32            long_1;
  int8              s3m_magic_2[4];
  uint8             volume;
  uint8             tempo;
  uint8             bpm;
  uint8             fill_1[13];
  uint8             channel_maps[32];
} s3m_header;

typedef struct _s3m_instr
{
  uint8             flag;
  int8              name[13];
  uint16            position;
  uint32            size;
  uint32            rep_start;
  uint32            rep_end;
  uint16            volume;
  uint8             byte_1;
  uint8             looped;
  uint16            period_fine;
  uint8             fill_3[10];
  uint16            word_3;
  uint16            word_4;
  int8              comment[28];
  int8              id[4];
} s3m_instr;

typedef struct _mod_voice
{
  int8              sample_name[22];
  uint16            sample_length;
  uint8             finetune_value;
  uint8             volume;
  uint16            repeat_point;
  uint16            repeat_length;
} mod_voice;

typedef struct _song_data
{
  int8              name[20];
  uint8             tracks;
  uint8             track_shift;
  pattern_ptr       patterns[256];
  sample8_far       samples[MAX_SAMPLES];
  uint16            sample_length[MAX_SAMPLES];
  uint32            finetune_rate[MAX_SAMPLES];
  uint16            period_low_limit[MAX_SAMPLES];
  uint16            period_high_limit[MAX_SAMPLES];
  uint16            finetune_value[MAX_SAMPLES];
  uint16            volume[MAX_SAMPLES];
  uint16            repeat_point[MAX_SAMPLES];
  uint16            repeat_length[MAX_SAMPLES];
  uint8             positions[256];
  uint8             song_length_patterns;
  uint8             song_repeat_patterns;
  uint16            bpm;
  uint16            tempo;
  uint8             s3m;
} song_data;

typedef struct _song_15
{
  uint8             song_length_patterns;
  uint8             song_repeat_patterns;
  uint8             positions[128];
} song_15;

typedef struct track_info
{
  sample8_far   samples;
  uint16        position;
  uint16        length;
  uint16        repeat;
  uint16        replen;
  int8          volume;
  int8          error;
  uint16        pitch;
  uint16        old_position;


  int8          samp;
  int8          note_hit;  /* for the GUS */
  int8          note;      /* for the GUS */
  int16         panning;   /* for the GUS  -127 to 127 */
  int16         playing_period; /* for GUS */
  int8          playing_volume; /* for GUS */
  int16         start_period; /* the period at the start of the 
				 track
				 */
  int16         period;
  uint16        step;
  uint8         effect;
  uint16        portto;
  uint8         vibpos;
  uint8         trempos;
  uint16        oldsampofs;
  int16         arp[3];
  uint16        arpindex;

  int16         oldperiod;
  int16         vol_slide;
  uint16        port_inc;
  uint16        port_up;
  uint16        port_down;
  uint16        vib_rate;
  uint16        vib_depth;
  uint16        trem_rate;
  uint16        trem_depth;
  uint8         retrig;

  uint32        finetune_rate;
  uint16        period_low_limit;
  uint16        period_high_limit;
} track_info;

#ifdef NEAR_FAR_PTR
typedef track_info near *track_info_ptr;
#else
typedef track_info *track_info_ptr;
#endif

int load_mod(char *filename, song_data *data, int8 noprint);
int16 load_s3m(char *filename, song_data *data, int8 noprint);
void startplaying(int loud);
void updatetracks(void);
extern song_data mod;
extern track_info tracks[];
extern track_info old_tracks[];
extern int16 mod_done;
extern uint8 order_pos;
extern uint8 row;
extern uint32 mixspeed;
extern uint16 bpm_samples;
extern uint8 *note;
extern int bit16;
extern int stereo;
extern uint8 loop_mod;
extern uint8 sintable[];
void mixtrack_8_stereo(track_info *track, uint8 *buffer, uint16 buflen, uint32 channel);
void mixtrack_8_mono(track_info *track, uint8 *buffer, uint16 buflen);
void mixtrack_16_stereo(track_info *track, uint16 *buffer, uint16 buflen, uint32 channel);
void mixtrack_16_mono(track_info *track, uint16 *buffer, uint16 buflen);

extern song_data               mod;
extern uint8                   order_pos;
extern uint8                   tempo;
extern uint8                   tempo_wait;
extern uint8                   bpm;
extern uint8                   row;
extern uint8                   break_row;
extern uint16                  bpm_samples;
extern uint8                  *buf_ptr;
extern uint16                  buf_len;
extern uint16                  buf_rep;
extern pattern_ptr             note;
extern track_info              tracks[];
extern track_info              old_tracks[];
extern uint32                  mixspeed;
extern int16                   mod_done;
extern uint8                   loop_mod;

extern uint16 period_set[];


union vol_union
{
  int8                   vol_table[16640];
  int16                  vol_table16[16640];
};

extern union vol_union vol;









