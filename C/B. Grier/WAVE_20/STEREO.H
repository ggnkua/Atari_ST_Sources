/* 
    This include file contains the C definitions
    for the STe Digitized Sound subsystem of the
    STe/TT.
*/

typedef struct {
           char  fill_0 ;
  unsigned char  DMA_cntrl ;
           char  fill_1 ;

  unsigned char  Frame_base_high ;
           char  fill_2 ;
  unsigned char  Frame_base_med ;
           char  fill_3 ;
  unsigned char  Frame_base_low ;
           char  fill_4 ;

  unsigned char  Frame_addr_high ;
           char  fill_5 ;
  unsigned char  Frame_addr_med ;
           char  fill_6 ;
  unsigned char  Frame_addr_low ;
           char  fill_7 ;

  unsigned char  Frame_end_high ;
           char  fill_8 ;
  unsigned char  Frame_end_med ;
           char  fill_9 ;
  unsigned char  Frame_end_low ;
           char  fill_A[12] ;

  unsigned char  Mode_cntrl ;
           char  fill_B ;
} SOUND_REGS ;

typedef struct {
  unsigned char  Data_REG ;
           char  fill_1 ;
  unsigned char  Mask_REG ;
           char  fill_2 ;
} MICROWIRE ;

#define SOUND_REGS_ADDR 0xff8900
#define MICROWIRE_ADDR  0xff8922

/* values for Sound Sub-System (SSS) DMA_cntrl register */
#define SSS_DMA_DISABLE   0x0
#define SSS_DMA_ONCE      0x1
#define SSS_DMA_FOREVER   0x3

/* sample rates */
#define SSS_RATE_06258Hz  0x0
#define SSS_RATE_12517Hz  0x1
#define SSS_RATE_25033Hz  0x2
#define SSS_RATE_50066Hz  0x3

#define SSS_RATE_6kHz   6258l
#define SSS_RATE_12kHz  12517l
#define SSS_RATE_25kHz  25033l
#define SSS_RATE_50kHz  50066l

#define SSS_STEREO  0x0000
#define SSS_MONO    0x0080