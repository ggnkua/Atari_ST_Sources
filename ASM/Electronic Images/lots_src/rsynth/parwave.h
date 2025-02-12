/* $Id: parwave.h,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
/*
file: PARWAVE.H
date: 15/11/93
version: 3.0

Contains structure definitions used in parwave.c
*/


#define CASCADE_PARALLEL 1         /* Type of synthesis model */
#define ALL_PARALLEL     2 
#define NPAR		 40        /* Number of control parameters */

#ifndef TRUE 
#define TRUE             1
#endif

#ifndef FALSE
#define FALSE            0
#endif

#define IMPULSIVE        1         /* Type of voicing source */
#define NATURAL          2
#define SAMPLED          3


/* typedef's that need to be exported */

typedef int flag;

/* Resonator Structure */

typedef struct
{
  float a;
  float b;
  float c;
  float p1;
  float p2;
} resonator_t, *resonator_ptr;

/* Structure for Klatt Globals */

typedef struct
{
  flag synthesis_model; /* cascade-parallel or all-parallel */
  flag outsl;           /* Output waveform selector                      */
  flag glsource;        /* Type of glottal source */
  flag quiet_flag;      /* set to TRUE for error messages */
  long samrate;         /* Number of output samples per second           */
  long FLPhz ;          /* Frequeny of glottal downsample low-pass filter */
  long BLPhz ;          /* Bandwidth of glottal downsample low-pass filter */
  long nfcascade;       /* Number of formants in cascade vocal tract    */
  int f0_flutter;       /* Percentage of f0 flutter 0-100 */
  long nspfr;           /* number of samples per frame */
  long nper;            /* Counter for number of samples in a pitch period */
  long ns;              /* Counter for number of samples in a frame */
  long T0;              /* Fundamental period in output samples times 4 */
  long nopen;           /* Number of samples in open phase of period    */
  long nmod;            /* Position in period to begin noise amp. modul */
  long nrand;           /* Varible used by random number generator      */
  float pulse_shape_a;  /* Makes waveshape of glottal pulse when open   */
  float pulse_shape_b;  /* Makes waveshape of glottal pulse when open   */
  float minus_pi_t;
  float two_pi_t;
  float onemd;
  float decay;
  float amp_bypas;      /* AB converted to linear gain              */
  float amp_voice;      /* AVdb converted to linear gain            */
  float par_amp_voice;  /* AVpdb converted to linear gain       */
  float amp_aspir;      /* AP converted to linear gain              */
  float amp_frica;      /* AF converted to linear gain              */
  float amp_breth;      /* ATURB converted to linear gain           */
  float amp_gain0;      /* G0 converted to linear gain              */
  int num_samples;      /* number of glottal samples */
  float sample_factor;  /* multiplication factor for glottal samples */
  int *natural_samples; /* pointer to an array of glottal samples */
  long original_f0;     /* original value of f0 not modified by flutter */
  float vlast;
  float glotlast;
  float nlast;

  /* internal storage for resonators */
  resonator_t rnpp; 
  resonator_t r1p;
  resonator_t r2p;
  resonator_t r3p;
  resonator_t r4p;
  resonator_t r5p;
  resonator_t r6p;
  resonator_t r1c;
  resonator_t r2c;
  resonator_t r3c;
  resonator_t r4c;
  resonator_t r5c;
  resonator_t r6c;
  resonator_t r7c;
  resonator_t r8c;
  resonator_t rnpc;
  resonator_t rnz;
  resonator_t rgl;
  resonator_t rlp;
  resonator_t rout;
} klatt_global_t, *klatt_global_ptr;
  
/* Structure for Klatt Parameters */

typedef struct
{
  long F0hz10; /* Voicing fund freq in Hz                          */        
  long AVdb;   /* Amp of voicing in dB,            0 to   70       */        
  long F1hz;   /* First formant freq in Hz,        200 to 1300     */        
  long B1hz;   /* First formant bw in Hz,          40 to 1000      */        
  long F2hz;   /* Second formant freq in Hz,       550 to 3000     */        
  long B2hz;   /* Second formant bw in Hz,         40 to 1000      */        
  long F3hz;   /* Third formant freq in Hz,        1200 to 4999    */        
  long B3hz;   /* Third formant bw in Hz,          40 to 1000      */        
  long F4hz;   /* Fourth formant freq in Hz,       1200 to 4999    */        
  long B4hz;   /* Fourth formant bw in Hz,         40 to 1000      */        
  long F5hz;   /* Fifth formant freq in Hz,        1200 to 4999    */        
  long B5hz;   /* Fifth formant bw in Hz,          40 to 1000      */        
  long F6hz;   /* Sixth formant freq in Hz,        1200 to 4999    */        
  long B6hz;   /* Sixth formant bw in Hz,          40 to 2000      */        
  long FNZhz;  /* Nasal zero freq in Hz,           248 to  528     */        
  long BNZhz;  /* Nasal zero bw in Hz,             40 to 1000      */        
  long FNPhz;  /* Nasal pole freq in Hz,           248 to  528     */        
  long BNPhz;  /* Nasal pole bw in Hz,             40 to 1000      */        
  long ASP;    /* Amp of aspiration in dB,         0 to   70       */        
  long Kopen;  /* # of samples in open period,     10 to   65      */        
  long Aturb;  /* Breathiness in voicing,          0 to   80       */        
  long TLTdb;  /* Voicing spectral tilt in dB,     0 to   24       */        
  long AF;     /* Amp of frication in dB,          0 to   80       */        
  long Kskew;  /* Skewness of alternate periods,   0 to   40 in sample#/2  */
  long A1;     /* Amp of par 1st formant in dB,    0 to   80       */        
  long B1phz;  /* Par. 1st formant bw in Hz,       40 to 1000      */        
  long A2;     /* Amp of F2 frication in dB,       0 to   80       */        
  long B2phz;  /* Par. 2nd formant bw in Hz,       40 to 1000      */        
  long A3;     /* Amp of F3 frication in dB,       0 to   80       */        
  long B3phz;  /* Par. 3rd formant bw in Hz,       40 to 1000      */        
  long A4;     /* Amp of F4 frication in dB,       0 to   80       */        
  long B4phz;  /* Par. 4th formant bw in Hz,       40 to 1000      */        
  long A5;     /* Amp of F5 frication in dB,       0 to   80       */        
  long B5phz;  /* Par. 5th formant bw in Hz,       40 to 1000      */        
  long A6;     /* Amp of F6 (same as r6pa),        0 to   80       */        
  long B6phz;  /* Par. 6th formant bw in Hz,       40 to 2000      */        
  long ANP;    /* Amp of par nasal pole in dB,     0 to   80       */        
  long AB;     /* Amp of bypass fric. in dB,       0 to   80       */        
  long AVpdb;  /* Amp of voicing,  par in dB,      0 to   70       */        
  long Gain0;  /* Overall gain, 60 dB is unity,    0 to   60       */        
 } klatt_frame_t, *klatt_frame_ptr;




/* function prototypes that need to be exported */

void parwave PROTO((klatt_global_ptr,klatt_frame_ptr,short *));
void parwave_init PROTO((klatt_global_ptr));




