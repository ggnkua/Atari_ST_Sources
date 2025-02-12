extern int ScreenWidth;
extern int ScreenHeight;
extern int vid_mode;
extern int old_vid_mode;
extern void *old_phy_base;
extern void *old_log_base;
typedef long INT32;
typedef int INT16;
typedef char INT8;
typedef unsigned long UINT32;
typedef unsigned int UINT16;
typedef unsigned char UINT8;
 
#define SKIP_PICTURE -10
#define SKIP_TO_START_CODE -1
#define PARSE_OK 1
#define BOOLEAN int
#define TRUE 1
#define FALSE 0
#define RING_BUF_SIZE 5
#define I_TYPE 1
#define P_TYPE 2
#define B_TYPE 3
#define SEQ_END_CODE 0x000001b7
#define SEQ_START_CODE 0x000001b3
#define GOP_START_CODE 0x000001b8
#define PICTURE_START_CODE 0x00000100
#define SLICE_MIN_START_CODE 0x00000101
#define SLICE_MAX_START_CODE 0x000001af
#define EXT_START_CODE 0x000001b5
#define USER_START_CODE 0x000001b2
#define MB_QUANTUM 100
#define MB_STUFFING 34
#define MB_ESCAPE 35
#define DISPLAY_LOCK 0x01
#define PAST_LOCK 0x02
#define FUTURE_LOCK 0x04

extern int scan[][8];
typedef long TimeStamp;

/* Structure with reconstructed pixel values. */

typedef struct pict_image {
  unsigned char *luminance;              /* Luminance plane.   */
  unsigned char *Cr;                     /* Cr plane.          */
  unsigned char *Cb;                     /* Cb plane.          */
  unsigned char *display;                /* Display plane.     */
  int locked;                            /* Lock flag.         */
  TimeStamp show_time;                   /* Presentation time. */

} PictImage;

/* Group of pictures structure. */

typedef struct GoP {
  BOOLEAN drop_flag;                     /* Flag indicating dropped frame. */
  unsigned int tc_hours;                 /* Hour component of time code.   */
  unsigned int tc_minutes;               /* Minute component of time code. */
  unsigned int tc_seconds;               /* Second component of time code. */
  unsigned long tc_pictures;              /* Picture counter of time code.  */
  BOOLEAN closed_gop;                    /* Indicates no pred. vectors to
					    previous group of pictures.    */
  BOOLEAN broken_link;                   /* B frame unable to be decoded.  */
  char *ext_data;                        /* Extension data.                */
  char *user_data;                       /* User data.                     */
} GoP;

/* Picture structure. */

typedef struct pict {
  unsigned long temp_ref;                 /* Temporal reference.             */
  unsigned int code_type;                /* Frame type: P, B, I             */
  unsigned long vbv_delay;                /* Buffer delay.                   */
  BOOLEAN full_pel_forw_vector;          /* Forw. vectors specified in full
					    pixel values flag.              */
  unsigned int forw_r_size;              /* Used for vector decoding.       */
  unsigned int forw_f;                   /* Used for vector decoding.       */
  BOOLEAN full_pel_back_vector;          /* Back vectors specified in full 
					    pixel values flag.              */
  unsigned int back_r_size;              /* Used in decoding.               */
  unsigned int back_f;                   /* Used in decoding.               */
  char *extra_info;                      /* Extra bit picture info.         */
  char *ext_data;                        /* Extension data.                 */
  char *user_data;                       /* User data.                      */
} Pict;

/* Slice structure. */

typedef struct slice {
  unsigned int vert_pos;                 /* Vertical position of slice. */
  unsigned int quant_scale;              /* Quantization scale.         */
  char *extra_info;                      /* Extra bit slice info.       */
} Slice;

/* Macroblock structure. */

typedef struct macroblock {
  int mb_address;                        /* Macroblock address.              */
  int past_mb_addr;                      /* Previous mblock address.         */
  int motion_h_forw_code;                /* Forw. horiz. motion vector code. */
  unsigned int motion_h_forw_r;          /* Used in decoding vectors.        */
  int motion_v_forw_code;                /* Forw. vert. motion vector code.  */
  unsigned int motion_v_forw_r;          /* Used in decdoinge vectors.       */
  int motion_h_back_code;                /* Back horiz. motion vector code.  */
  unsigned int motion_h_back_r;          /* Used in decoding vectors.        */
  int motion_v_back_code;                /* Back vert. motion vector code.   */
  unsigned int motion_v_back_r;          /* Used in decoding vectors.        */
  unsigned int cbp;                      /* Coded block pattern.             */
  BOOLEAN mb_intra;                      /* Intracoded mblock flag.          */
  BOOLEAN bpict_past_forw;               /* Past B frame forw. vector flag.  */
  BOOLEAN bpict_past_back;               /* Past B frame back vector flag.   */
  int past_intra_addr;                   /* Addr of last intracoded mblock.  */
  int recon_right_for_prev;              /* Past right forw. vector.         */
  int recon_down_for_prev;               /* Past down forw. vector.          */
  int recon_right_back_prev;             /* Past right back vector.          */
  int recon_down_back_prev;              /* Past down back vector.           */
} Macroblock;

/* Block structure. */

typedef struct block {
  int dct_recon[8][8];            /* Reconstructed dct coeff matrix. */
  int dct_dc_y_past;               /* Past lum. dc dct coefficient.   */
  int dct_dc_cr_past;              /* Past cr dc dct coefficient.     */
  int dct_dc_cb_past;              /* Past cb dc dct coefficient.     */
} Block;

/* Video stream structure. */

typedef struct vid_stream {
  unsigned int h_size;                         /* Horiz. size in pixels.     */
  unsigned int v_size;                         /* Vert. size in pixels.      */
  unsigned int mb_height;                      /* Vert. size in mblocks.     */
  unsigned int mb_width;                       /* Horiz. size in mblocks.    */
  unsigned char aspect_ratio;                  /* Code for aspect ratio.     */
  unsigned char picture_rate;                  /* Code for picture rate.     */
  unsigned long bit_rate;                       /* Bit rate.                  */
  unsigned long vbv_buffer_size;                /* Minimum buffer size.       */
  BOOLEAN const_param_flag;                    /* Contrained parameter flag. */
  unsigned char intra_quant_matrix[8][8];      /* Quantization matrix for
						  intracoded frames.         */
  unsigned char non_intra_quant_matrix[8][8];  /* Quanitization matrix for 
						  non intracoded frames.     */
  char *ext_data;                              /* Extension data.            */
  char *user_data;                             /* User data.                 */
  GoP group;                                   /* Current group of pict.     */
  Pict picture;                                /* Current picture.           */
  Slice slice;                                 /* Current slice.             */
  Macroblock mblock;                           /* Current macroblock.        */
  Block block;                                 /* Current block.             */
  long state;                                   /* State of decoding.         */
  long bit_offset;                              /* Bit offset in stream.      */
  unsigned long *buffer;                        /* Pointer to next byte in
						  buffer.                    */
  long buf_length;                              /* Length of remaining buffer.*/
  unsigned long *buf_start;                     /* Pointer to buffer start.   */
  long max_buf_length;                          /* Max lenght of buffer.      */
  PictImage *past;                             /* Past predictive frame.     */
  PictImage *future;                           /* Future predictive frame.   */
  PictImage *current;                          /* Current frame.             */
  PictImage *ring[RING_BUF_SIZE];              /* Ring buffer of frames.     */
} VidStream;

extern VidStream *curVidStream;

/* Definition of Contant integer scale factor. */

#define CONST_BITS 13
/* Misc DCT definitions */
#define DCTSIZE		8	/* The basic DCT block is 8x8 samples */
#define DCTSIZE2	64	/* DCTSIZE squared; # of elements in a block */

#define GLOBAL			/* a function referenced thru EXTERNs */
  
typedef char DCTELEM;
typedef DCTELEM DCTBLOCK[DCTSIZE2];

extern jmp_buf env;
