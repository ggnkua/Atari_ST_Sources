/* $Id: nsynth.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *nsynth_id = "$Id: nsynth.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";

/* Copyright            1982                    by Dennis H. Klatt
 *
 *      Klatt synthesizer
 *         Modified version of synthesizer described in
 *         J. Acoust. Soc. Am., Mar. 1980. -- new voicing
 *         source.
 *
 * Edit history
 * 000001 10-Mar-83 DK  Initial creation.
 * 000002  5-May-83 DK  Fix bug in operation of parallel F1
 * 000003  7-Jul-83 DK  Allow parallel B1 to vary, and if ALL_PARALLEL,
 *                      also allow B2 and B3 to vary
 * 000004 26-Jul-83 DK  Get rid of mulsh, use short for VAX
 * 000005 24-Oct-83 DK  Split off parwavtab.c, change short to int
 * 000006 16-Nov-83 DK  Make samrate a variable, use exp(), cos() rand()
 * 000007 17-Nov-83 DK  Convert to float, remove  cpsw, add set outsl
 * 000008 28-Nov-83 DK  Add simple impulsive glottal source option
 * 000009  7-Dec-83 DK  Use spkrdef[7] to select impulse or natural voicing
 *                       and update cascade F1,..,F6 at update times
 * 000010 19-Dec-83 DK  Add subroutine no_rad_char() to get rid of rad char
 * 000011 28-Jan-84 DK  Allow up to 8 formants in cascade branch F7 fixed
 *                       at 6.5 kHz, F8 fixed at 7.5 kHz
 * 000012 14-Feb-84 DK  Fix bug in 'os' options so os>12 works
 * 000013 17-May-84 DK  Add G0 code
 * 000014 12-Mar-85 DHW modify for Haskins environment
 * 000015 11-Jul-87 LG  modificiations for PC
 * 000016 20-Apr-91 ATS Modified for SPARCSTATION
 */

#define SUSPECT
#define KLATT_USE_OUTS

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "proto.h"
#include "nsynth.h"
#ifndef PI
#define PI               3.1415927
#endif

extern int rand PROTO((void));
#ifndef linux
#ifndef NeXT
extern int srand PROTO((unsigned int));
#endif
#endif

typedef struct
 {
  char *name;
  float a;
  float b;
  float c;
  float p1;
  float p2;
 }
resonator_t, *resonator_ptr;

/* N.I-S 23rd June 1993
   Moved definitions of some globalss here, and hence to parawav.o as
   they are needed by all users.
   We can set sensible defaults ...
*/

int time_count = 0;
static warnsw;
 /* JPI added for f0 flutter */

/* COUNTERS */

static long nper;
 /* Current loc in voicing period   40000 samp/s */

/* COUNTER LIMITS */

static long T0;  /* Fundamental period in output samples times 4 */
static long nopen;
 /* Number of samples in open phase of period    */
static long nmod;
 /* Position in period to begin noise amp. modul */

/* VARIABLES THAT HAVE TO STICK AROUND FOR AWHILE, AND THUS LOCALS */
/* ARE NOT APPROPRIATE */

/* Incoming parameter Variables which need to be updated synchronously  */

static long F0hz10;
                                /* Voicing fund freq in Hz                      */
static long AVdb;
                                /* Amp of voicing in dB,    0 to   70           */
static long Kskew;
                                /* Skewness of alternate periods,0 to   40      */

/* Various amplitude variables used in main loop */

static float amp_voice;
                                /* AVdb converted to linear gain            */
static float amp_bypas;
                                /* AB converted to linear gain              */
static float par_amp_voice;
                                /* AVpdb converted to linear gain           */
static float amp_aspir;
                                /* AP converted to linear gain              */
static float amp_frica;
                                /* AF converted to linear gain              */
static float amp_breth;
                                /* ATURB converted to linear gain           */

/* State variables of sound sources */

static long nrand;
 /* Varible used by random number generator      */
static long skew;
 /* Alternating jitter, in half-period units     */

static float a;  /* Makes waveshape of glottal pulse when open   */
static float b;  /* Makes waveshape of glottal pulse when open   */
static float vwave;
                                /* Ditto, but before multiplication by AVdb     */
static float vlast;
                                /* Previous output of voice                     */
static float nlast;
                                /* Previous output of random number generator   */
static float glotlast;
                                /* Previous value of glotout                    */
static float decay;
                                /* TLTdb converted to exponential time const    */
static float onemd;
                                /* in voicing one-pole low-pass filter          */
static float minus_pi_t;
                                /* func. of sample rate */
static float two_pi_t;
                                /* func. of sample rate */


/* INTERNAL MEMORY FOR DIGITAL RESONATORS AND ANTIRESONATOR  */

static resonator_t rnpp =
{"parallel nasal pole"};
static resonator_t r1p =
{"parallel 1st formant"};
static resonator_t r2p =
{"parallel 2nd formant"};
static resonator_t r3p =
{"parallel 3rd formant"};
static resonator_t r4p =
{"parallel 4th formant"};
static resonator_t r5p =
{"parallel 5th formant"};
static resonator_t r6p =
{"parallel 6th formant"};
static resonator_t r1c =
{"cascade 1st formant"};
static resonator_t r2c =
{"cascade 2nd formant"};
static resonator_t r3c =
{"cascade 3rd formant"};
static resonator_t r4c =
{"cascade 4th formant"};
static resonator_t r5c =
{"cascade 5th formant"};
static resonator_t r6c =
{"cascade 6th formant"};
static resonator_t r7c =
{"cascade 7th formant"};
static resonator_t r8c =
{"cascade 8th formant"};
static resonator_t rnpc =
{"cascade nasal pole"};
static resonator_t rnz =
{"cascade nasal zero"};
static resonator_t rgl =
{"crit-damped glot low-pass filter"};
static resonator_t rlp =
{"downsamp low-pass filter"};
static resonator_t rout =
{"output low-pass"};

/*
 * Constant B0 controls shape of glottal pulse as a function
 * of desired duration of open phase N0
 * (Note that N0 is specified in terms of 40,000 samples/sec of speech)
 *
 *    Assume voicing waveform V(t) has form: k1 t**2 - k2 t**3
 *
 *    If the radiation characterivative, a temporal derivative
 *      is folded in, and we go from continuous time to discrete
 *      integers n:  dV/dt = vwave[n]
 *                         = sum over i=1,2,...,n of { a - (i * b) }
 *                         = a n  -  b/2 n**2
 *
 *      where the  constants a and b control the detailed shape
 *      and amplitude of the voicing waveform over the open
 *      potion of the voicing cycle "nopen".
 *
 *    Let integral of dV/dt have no net dc flow --> a = (b * nopen) / 3
 *
 *    Let maximum of dUg(n)/dn be constant --> b = gain / (nopen * nopen)
 *      meaning as nopen gets bigger, V has bigger peak proportional to n
 *
 *    Thus, to generate the table below for 40 <= nopen <= 263:
 *
 *      B0[nopen - 40] = 1920000 / (nopen * nopen)
 */
static const short B0[224] =
{
 1200, 1142, 1088, 1038, 991,
 948, 907, 869, 833, 799,
 768, 738, 710, 683, 658,
 634, 612, 590, 570, 551,
 533, 515, 499, 483, 468,
 454, 440, 427, 415, 403,
 391, 380, 370, 360, 350,
 341, 332, 323, 315, 307,
 300, 292, 285, 278, 272,
 265, 259, 253, 247, 242,
 237, 231, 226, 221, 217,
 212, 208, 204, 199, 195,
 192, 188, 184, 180, 177,
 174, 170, 167, 164, 161,
 158, 155, 153, 150, 147,
 145, 142, 140, 137, 135,
 133, 131, 128, 126, 124,
 122, 120, 119, 117, 115,
 113, 111, 110, 108, 106,
 105, 103, 102, 100, 99,
 97, 96, 95, 93, 92,
 91, 90, 88, 87, 86,
 85, 84, 83, 82, 80,
 79, 78, 77, 76, 75,
 75, 74, 73, 72, 71,
 70, 69, 68, 68, 67,
 66, 65, 64, 64, 63,
 62, 61, 61, 60, 59,
 59, 58, 57, 57, 56,
 56, 55, 55, 54, 54,
 53, 53, 52, 52, 51,
 51, 50, 50, 49, 49,
 48, 48, 47, 47, 46,
 46, 45, 45, 44, 44,
 43, 43, 42, 42, 41,
 41, 41, 41, 40, 40,
 39, 39, 38, 38, 38,
 38, 37, 37, 36, 36,
 36, 36, 35, 35, 35,
 35, 34, 34, 33, 33,
 33, 33, 32, 32, 32,
 32, 31, 31, 31, 31,
 30, 30, 30, 30, 29,
 29, 29, 29, 28, 28,
 28, 28, 27, 27
};

/*
 * Convertion table, db to linear, 87 dB --> 32767
 *                                 86 dB --> 29491 (1 dB down = 0.5**1/6)
 *                                 ...
 *                                 81 dB --> 16384 (6 dB down = 0.5)
 *                                 ...
 *                                  0 dB -->     0
 *
 * The just noticeable difference for a change in intensity of a vowel
 *   is approximately 1 dB.  Thus all amplitudes are quantized to 1 dB
 *   steps.
 */

static const float amptable[88] =
{
 0., 0., 0., 0., 0.,
 0., 0., 0., 0., 0.,
 0., 0., 0., 6., 7.,
 8., 9., 10., 11., 13.,
 14., 16., 18., 20., 22.,
 25., 28., 32., 35., 40.,
 45., 51., 57., 64., 71.,
 80., 90., 101., 114., 128.,
 142., 159., 179., 202., 227.,
 256., 284., 318., 359., 405.,
 455., 512., 568., 638., 719.,
 811., 911., 1024., 1137., 1276.,
 1438., 1622., 1823., 2048., 2273.,
 2552., 2875., 3244., 3645., 4096.,
 4547., 5104., 5751., 6488., 7291.,
 8192., 9093., 10207., 11502., 12976.,
 14582., 16384., 18350., 20644., 23429.,
 26214., 29491., 32767.
};

const char *par_name[] =
{
 "F0hz10",
 "AVdb",
 "F1hz",
 "B1hz",
 "F2hz",
 "B2hz",
 "F3hz",
 "B3hz",
 "F4hz",
 "B4hz",
 "F5hz",
 "B5hz",
 "F6hz",
 "B6hz",
 "FNZhz",
 "BNZhz",
 "FNPhz",
 "BNPhz",
 "AP",
 "Kopen",
 "Aturb",
 "TLTdb",
 "AF",
 "Kskew",
 "A1",
 "B1phz",
 "A2",
 "B2phz",
 "A3",
 "B3phz",
 "A4",
 "B4phz",
 "A5",
 "B5phz",
 "A6",
 "B6phz",
 "ANP",
 "AB",
 "AVpdb",
 "Gain0"
};

static void flutter PROTO((klatt_global_ptr globals, klatt_frame_ptr pars));
static float resonator PROTO((resonator_ptr r, float input));
static float antiresonator PROTO((resonator_ptr r, float input));
static float impulsive_source PROTO((long nper));
static float natural_source PROTO((long nper));
static void setabc PROTO((long int f, long int bw, resonator_ptr rp));
static void setzeroabc PROTO((long int f, long int bw, resonator_ptr rp));
static float gen_noise PROTO((void));
static float DBtoLIN PROTO((klatt_global_ptr globals, long int dB));
static float dBconvert PROTO((long int arg));
static void overload_warning PROTO((klatt_global_ptr globals, long int arg));
static short clip PROTO((klatt_global_ptr globals, float input));
static void pitch_synch_par_reset PROTO((klatt_global_ptr globals,
                                         klatt_frame_ptr frame, long ns));
static void frame_init PROTO((klatt_global_ptr globals, klatt_frame_ptr frame));


/*
function FLUTTER

This function adds F0 flutter, as specified in:

"Analysis, synthesis and perception of voice quality variations among
female and male talkers" D.H. Klatt and L.C. Klatt JASA 87(2) February 1990.
Flutter is added by applying a quasi-random element constructed from three
slowly varying sine waves.

*/

static void
flutter(globals, pars)
klatt_global_ptr globals;
klatt_frame_ptr pars;
{
 double delta_f0;
 double fla, flb, flc, fld, fle;
 long original_f0 = pars->F0hz10 / 10;

 fla = (double) globals->f0_flutter / 50;
 flb = (double) original_f0 / 100;
 flc = sin(2 * PI * 12.7 * time_count);
 fld = sin(2 * PI * 7.1 * time_count);
 fle = sin(2 * PI * 4.7 * time_count);
 delta_f0 = fla * flb * (flc + fld + fle) * 10;
 F0hz10 = F0hz10 + (long) delta_f0;
}


/* Generic resonator function */
static float
resonator(r, input)
resonator_ptr r;
float input;
{
 register float x = r->a * input + r->b * r->p1 + r->c * r->p2;
 r->p2 = r->p1;
 r->p1 = x;
 return x;
}

/* Generic anti-resonator function
   Same as resonator except that a,b,c need to be set with setzeroabc()
   and we save inputs in p1/p2 rather than outputs.
   There is currently only one of these - "rnz"
*/
/*  Output = (rnz.a * input) + (rnz.b * oldin1) + (rnz.c * oldin2) */

static float
antiresonator(r, input)
resonator_ptr r;
float input;
{
 register float x = r->a * input + r->b * r->p1 + r->c * r->p2;
 r->p2 = r->p1;
 r->p1 = input;
 return x;
}


static float
impulsive_source(nper)
long nper;
{
 static float doublet[] =
 {0., 13000000., -13000000.};
 if (nper < 3)
  {
   vwave = doublet[nper];
  }
 else
  {
   vwave = 0.0;
  }
 /* Low-pass filter the differenciated impulse with a critically-damped
    second-order filter, time constant proportional to Kopen */
 return resonator(&rgl, vwave);
}


/* Vwave is the differentiated glottal flow waveform, there is a weak
    spectral zero around 800 Hz, magic constants a,b reset pitch-synch */


static float
natural_source(nper)
long nper;
{
 float lgtemp;
 /* See if glottis open */
 if (nper < nopen)
  {
   a -= b;
   vwave += a;
   lgtemp = vwave * 0.028;
   return (lgtemp);
  }
 else
  {
   /* Glottis closed */
   vwave = 0.0;
   return (0.0);
  }
}

/* Convert formant freqencies and bandwidth into
   resonator difference equation coefficents
*/


static void
setabc(f, bw, rp)
long int f;          /* Frequency of resonator in Hz         */
long int bw;        /* Bandwidth of resonator in Hz         */
resonator_ptr rp;
 /* Are output coefficients              */
{
 float r;
 double arg;

/* Let r  =  exp(-pi bw t) */

 arg = minus_pi_t * bw;
 r = exp(arg);

/* Let c  =  -r**2 */

 rp->c = -(r * r);

/* Let b = r * 2*cos(2 pi f t) */

 arg = two_pi_t * f;
 rp->b = r * cos(arg) * 2.;

/* Let a = 1.0 - b - c */

 rp->a = 1.0 - rp->b - rp->c;
}

/* Convert formant freqencies and bandwidth into
 *      anti-resonator difference equation constants */


static void
setzeroabc(f, bw, rp)
long int f;          /* Frequency of resonator in Hz         */
long int bw;        /* Bandwidth of resonator in Hz         */
resonator_ptr rp;
 /* Are output coefficients              */
{
 float r;
 double arg;

/* First compute ordinary resonator coefficients */
/* Let r  =  exp(-pi bw t) */

 arg = minus_pi_t * bw;
 r = exp(arg);

/* Let c  =  -r**2 */

 rp->c = -(r * r);

/* Let b = r * 2*cos(2 pi f t) */

 arg = two_pi_t * f;
 rp->b = r * cos(arg) * 2.;

/* Let a = 1.0 - b - c */

 rp->a = 1.0 - rp->b - rp->c;

/* Now convert to antiresonator coefficients (a'=1/a, b'=b/a, c'=c/a) */

 rp->a = 1.0 / rp->a;
 rp->c *= -rp->a;
 rp->b *= -rp->a;
}


/* Random number generator (return a number between -8191 and +8191) */

static float
gen_noise()
{
 float noise;
 long temp = rand();
 nrand = (temp >> 17) - 8191;

/* Tilt down noise spectrum by soft low-pass filter having
 *    a pole near the origin in the z-plane, i.e.
 *    output = input + (0.75 * lastoutput) */

 noise = nrand + (0.75 * nlast);
 nlast = noise;
 return noise;
}

/* Convert from decibels to a linear scale factor */


static float
DBtoLIN(globals, dB)
klatt_global_ptr globals;
long int dB;
{
 /* Check limits or argument (can be removed in final product) */
 if (dB < 0)
  dB = 0;
 else if (dB >= 88)
  {
   if (!globals->quiet_flag)
    printf("Try to compute amptable[%ld]\n", dB);
   dB = 87;
  }
 return amptable[dB] * 0.001;
}

#define ACOEF           0.005
#define BCOEF           (1.0 - ACOEF) /* Slight decay to remove dc */


static float
dBconvert(arg)
long int arg;
{
 return 20.0 * log10((double) arg / 32767.0);
}


static void
overload_warning(globals, arg)
klatt_global_ptr globals;
long int arg;
{
 if (warnsw == 0)
  {
   warnsw++;
   if (!globals->quiet_flag)
    {
     printf("\n* * * WARNING: ");
     printf(" Signal at output of synthesizer (+%3.1f dB) exceeds 0 dB\n",
            dBconvert(arg));
    }
  }
}


static short
clip(globals, input)
klatt_global_ptr globals;
float input;
{
 long temp = input;
 long x = (temp < 0) ? -temp : temp;

 /* clip on boundaries of 16-bit word */
 if (temp < -32767)
  {
   overload_warning(globals, x);
   temp = -32767;
  }
 else if (temp > 32767)
  {
   overload_warning(globals, temp);
   temp = 32767;
  }
 return (temp);
}

/* Reset selected parameters pitch-synchronously */


static void
pitch_synch_par_reset(globals, frame, ns)
klatt_global_ptr globals;
klatt_frame_ptr frame;
long ns;
{
 long temp;
 float temp1;
 if (F0hz10 > 0)
  {
   T0 = (40 * globals->samrate) / F0hz10;
   /* Period in samp*4 */
   amp_voice = DBtoLIN(globals, AVdb);

   /* Duration of period before amplitude modulation */
   nmod = T0;
   if (AVdb > 0)
    {
     nmod >>= 1;
    }

   /* Breathiness of voicing waveform */

   amp_breth = DBtoLIN(globals, frame->Aturb) * 0.1;

   /* Set open phase of glottal period */
   /* where  40 <= open phase <= 263 */

   nopen = 4 * frame->Kopen;
   if ((globals->glsource == IMPULSIVE) && (nopen > 263))
    {
     nopen = 263;
    }

   if (nopen >= (T0 - 1))
    {
     nopen = T0 - 2;
     if (!globals->quiet_flag)
      {
       printf("Warning: glottal open period cannot exceed T0, truncated\n");
      }
    }

   if (nopen < 40)
    {
     nopen = 40;     /* F0 max = 1000 Hz */
     if (!globals->quiet_flag)
      {
       printf("Warning: minimum glottal open period is 10 samples.\n");
       printf("truncated, nopen = %ld\n", nopen);
      }
    }

   /* Reset a & b, which determine shape of "natural" glottal waveform */

   b = B0[nopen - 40];
   a = (b * nopen) * .333;

   /* Reset width of "impulsive" glottal pulse */

   temp = globals->samrate / nopen;
   setabc(0L, temp, &rgl);

   /* Make gain at F1 about constant */

   temp1 = nopen * .00833;
   rgl.a *= (temp1 * temp1);

   /* Truncate skewness so as not to exceed duration of closed phase
      of glottal period */

   temp = T0 - nopen;
   if (Kskew > temp)
    {
     if (!globals->quiet_flag)
      {
       printf("Kskew duration=%ld > glottal closed period=%ld, truncate\n",
              Kskew, T0 - nopen);
      }
     Kskew = temp;
    }
   if (skew >= 0)
    {
     skew = Kskew; /* Reset skew to requested Kskew */
    }
   else
    {
     skew = -Kskew;
    }

   /* Add skewness to closed portion of voicing period */

   T0 = T0 + skew;
   skew = -skew;
  }
 else
  {
   T0 = 4;               /* Default for f0 undefined */
   amp_voice = 0.;
   nmod = T0;
   amp_breth = 0.;
   a = 0.0;
   b = 0.0;
  }

/* Reset these pars pitch synchronously or at update rate if f0=0 */

 if ((T0 != 4) || (ns == 0))
  {
   /* Set one-pole low-pass filter that tilts glottal source */
   decay = (0.033 * frame->TLTdb);
   if (decay > 0.0)
    {
     onemd = 1.0 - decay;
    }
   else
    {
     onemd = 1.0;
    }
  }
}

void show_parms PROTO((klatt_global_ptr globals, int *pars));

void
show_parms(globals, pars)
klatt_global_ptr globals;
int *pars;
{
 int i;
 static int names;
 if ((names++ % 64) == 0)
  {
   for (i = 0; i < NPAR; i++)
    printf("%s ", par_name[i]);
   printf("\n");
  }
 for (i = 0; i < NPAR; i++)
  {
   printf("%*d ", (int) strlen(par_name[i]), pars[i]);
  }
 printf("\n");
}

/* Get variable parameters from host computer,
   initially also get definition of fixed pars
*/

static void
frame_init(globals, frame)
klatt_global_ptr globals;
klatt_frame_ptr frame;
{
 long Gain0;         /* Overall gain, 60 dB is unity  0 to   60      */
 float amp_parF1;
 /* A1 converted to linear gain              */
 float amp_parFNP;
 /* AP converted to linear gain              */
 float amp_parF2;
 /* A2 converted to linear gain              */
 float amp_parF3;
 /* A3 converted to linear gain              */
 float amp_parF4;
 /* A4 converted to linear gain              */
 float amp_parF5;
 /* A5 converted to linear gain              */
 float amp_parF6;
 /* A6 converted to linear gain              */

#if 0
 show_parms((int *) frame);
#endif

 /*
   Read  speech frame definition into temp store
   and move some parameters into active use immediately
   (voice-excited ones are updated pitch synchronously
   to avoid waveform glitches).
 */

 F0hz10 = frame->F0hz10;
 AVdb = frame->AVdb - 7;
 if (AVdb < 0)
  AVdb = 0;

 amp_aspir = DBtoLIN(globals, frame->ASP) * .05;


 amp_frica = DBtoLIN(globals, frame->AF) * 0.25;
 Kskew = frame->Kskew;
 par_amp_voice = DBtoLIN(globals, frame->AVpdb);

 amp_parF1 = DBtoLIN(globals, frame->A1) * 0.4;
 amp_parF2 = DBtoLIN(globals, frame->A2) * 0.15;
 amp_parF3 = DBtoLIN(globals, frame->A3) * 0.06;
 amp_parF4 = DBtoLIN(globals, frame->A4) * 0.04;
 amp_parF5 = DBtoLIN(globals, frame->A5) * 0.022;
 amp_parF6 = DBtoLIN(globals, frame->A6) * 0.03;
 amp_parFNP = DBtoLIN(globals, frame->ANP) * 0.6;

 amp_bypas = DBtoLIN(globals, frame->AB) * 0.05;

 if (globals->nfcascade >= 8)
  {
   /* Inside Nyquist rate ? */
   if (globals->samrate >= 16000)
    setabc(7500, 600, &r8c);
   else
    globals->nfcascade = 6;
  }

 if (globals->nfcascade >= 7)
  {
   /* Inside Nyquist rate ? */
   if (globals->samrate >= 16000)
    setabc(6500, 500, &r7c);
   else
    globals->nfcascade = 6;
  }

 /* Set coefficients of variable cascade resonators */

 if (globals->nfcascade >= 6)
  setabc(frame->F6hz, frame->B6hz, &r6c);

 if (globals->nfcascade >= 5)
  setabc(frame->F5hz, frame->B5hz, &r5c);

 setabc(frame->F4hz, frame->B4hz, &r4c);
 setabc(frame->F3hz, frame->B3hz, &r3c);
 setabc(frame->F2hz, frame->B2hz, &r2c);
 setabc(frame->F1hz, frame->B1hz, &r1c);

 /* Set coeficients of nasal resonator and zero antiresonator */
 setabc(frame->FNPhz, frame->BNPhz, &rnpc);
 setzeroabc(frame->FNZhz, frame->BNZhz, &rnz);

 /* Set coefficients of parallel resonators, and amplitude of outputs */
 setabc(frame->F1hz, frame->B1phz, &r1p);
 r1p.a *= amp_parF1;
 setabc(frame->FNPhz, frame->BNPhz, &rnpp);
 rnpp.a *= amp_parFNP;
 setabc(frame->F2hz, frame->B2phz, &r2p);
 r2p.a *= amp_parF2;
 setabc(frame->F3hz, frame->B3phz, &r3p);
 r3p.a *= amp_parF3;
 setabc(frame->F4hz, frame->B4phz, &r4p);
 r4p.a *= amp_parF4;
 setabc(frame->F5hz, frame->B5phz, &r5p);
 r5p.a *= amp_parF5;
 setabc(frame->F6hz, frame->B6phz, &r6p);
 r6p.a *= amp_parF6;

 /* output low-pass filter - resonator with freq 0 and BW = globals->samrate
    Thus 3db point is globals->samrate/2 i.e. Nyquist limit.
    Only 3db down seems rather mild...
  */

 setabc(0L, (long) globals->samrate, &rout);

 /* fold overall gain into output resonator */
 Gain0 = frame->Gain0 - 3;
 if (Gain0 <= 0)
  Gain0 = 57;
 rout.a *= DBtoLIN(globals, Gain0);
}

/*
function PARWAV

CONVERT FRAME OF PARAMETER DATA TO A WAVEFORM CHUNK
Synthesize globals->nspfr samples of waveform and store in jwave[].
*/

void
parwave(globals, frame, jwave)
klatt_global_ptr globals;
klatt_frame_ptr frame;
short int *jwave;
{
 long ns;
 float out = 0.0;
 /* Output of cascade branch, also final output  */

 /* Initialize synthesizer and get specification for current speech
    frame from host microcomputer */

 frame_init(globals, frame);

 if (globals->f0_flutter != 0)
  {
   time_count++;   /* used for f0 flutter */
   flutter(globals, frame);
   /* add f0 flutter */
  }

 /* MAIN LOOP, for each output sample of current frame: */

 for (ns = 0; ns < globals->nspfr; ns++)
  {
   int n4;
   float noise = gen_noise();
   /* Get low-passed random number for aspiration and frication noise */
   float sourc;     /* Sound source if all-parallel config used     */
   float glotout; /* Output of glottal sound source               */
   float par_glotout;
   /* Output of parallelglottal sound sourc        */
   float voice;     /* Current sample of voicing waveform           */
   float frics;     /* Frication sound source                       */
   float aspiration;
   /* Aspiration sound source                      */

   /* Amplitude modulate noise (reduce noise amplitude during
      second half of glottal period) if voicing simultaneously present
   */
   if (nper > nmod)
    {
     noise *= 0.5;
    }

   /* Compute frication noise */
   frics = amp_frica * noise;

   /* Compute voicing waveform */
   /* (run glottal source simulation at 4 times normal sample rate to minimize
    *    quantization noise in period of female voice) */

   for (n4 = 0; n4 < 4; n4++)
    {
     if (globals->glsource == IMPULSIVE)
      {
       /* Use impulsive glottal source */
       voice = impulsive_source(nper);
      }
     else
      {
       /* Or use a more-natural-shaped source waveform with excitation
          occurring both upon opening and upon closure, stronest at closure */
       voice = natural_source(nper);
      }
     /* Reset period when counter 'nper' reaches T0 */
     if (nper >= T0)
      {
       nper = 0;
       pitch_synch_par_reset(globals, frame, ns);
      }

     /* Low-pass filter voicing waveform before downsampling from 4*globals->samrate */
     /* to globals->samrate samples/sec.  Resonator f=.09*globals->samrate, bw=.06*globals->samrate    */
     voice = resonator(&rlp, voice);
     /* in=voice, out=voice */

     /* Increment counter that keeps track of 4*globals->samrate samples/sec */
     nper++;
    }

   /* Tilt spectrum of voicing source down by soft low-pass filtering, amount
      of tilt determined by TLTdb
   */
   voice = (voice * onemd) + (vlast * decay);
   vlast = voice;

   /* Add breathiness during glottal open phase */
   if (nper < nopen)
    {
     /* Amount of breathiness determined by parameter Aturb */
     /* Use nrand rather than noise because noise is low-passed */
     voice += amp_breth * nrand;
    }

   /* Set amplitude of voicing */
   glotout = amp_voice * voice;

   /* Compute aspiration amplitude and add to voicing source */
   aspiration = amp_aspir * noise;
   glotout += aspiration;

   par_glotout = glotout;

   if (globals->synthesis_model != ALL_PARALLEL)
    {
     /* Cascade vocal tract, excited by laryngeal sources.
        Nasal antiresonator, then formants FNP, F5, F4, F3, F2, F1
     */
     float rnzout = antiresonator(&rnz, glotout);
     /* Output of cascade nazal zero resonator       */
     float casc_next_in = resonator(&rnpc, rnzout);
     /* in=rnzout, out=rnpc.p1 */

     /* Do not use unless samrat = 16000 */
     if (globals->nfcascade >= 8)
      casc_next_in = resonator(&r8c, casc_next_in);

     /* Do not use unless samrat = 16000 */
     if (globals->nfcascade >= 7)
      casc_next_in = resonator(&r7c, casc_next_in);

     /* Do not use unless long vocal tract or samrat increased */
     if (globals->nfcascade >= 6)
      casc_next_in = resonator(&r6c, casc_next_in);

     if (globals->nfcascade >= 5)
      casc_next_in = resonator(&r5c, casc_next_in);

     if (globals->nfcascade >= 4)
      casc_next_in = resonator(&r4c, casc_next_in);

     if (globals->nfcascade >= 3)
      casc_next_in = resonator(&r3c, casc_next_in);

     if (globals->nfcascade >= 2)
      casc_next_in = resonator(&r2c, casc_next_in);

     if (globals->nfcascade >= 1)
      out = resonator(&r1c, casc_next_in);
     else
      out = 0.0;
     /* Excite parallel F1 and FNP by voicing waveform */
     /* Source is voicing plus aspiration */
     /* Add in phase, boost lows for nasalized */
     out += (resonator(&rnpp, par_glotout) + resonator(&r1p, par_glotout));
    }
   else
    {
     /* Feed glottal source through nasal resonators
      */
     par_glotout = antiresonator(&rnz, par_glotout);
     par_glotout = resonator(&rnpc, par_glotout);
     /* And just use r1p NOT rnpp */
     out = resonator(&r1p, par_glotout);
    }

   /* Sound sourc for other parallel resonators is frication plus */
   /* first difference of voicing waveform */

   sourc = frics + (par_glotout - glotlast);
   glotlast = par_glotout;

   /* Standard parallel vocal tract
      Formants F6,F5,F4,F3,F2, outputs added with alternating sign
   */
   out = resonator(&r6p, sourc) - out;
   out = resonator(&r5p, sourc) - out;
   out = resonator(&r4p, sourc) - out;
   out = resonator(&r3p, sourc) - out;
   out = resonator(&r2p, sourc) - out;

   out = amp_bypas * sourc - out;

   out = resonator(&rout, out);
   /* Convert back to integer */
   *jwave++ = clip(globals, out);
  }
}

void
parwave_init(globals)
klatt_global_ptr globals;
{
 long FLPhz = (950 * globals->samrate) / 10000;
 long BLPhz = (630 * globals->samrate) / 10000;

 minus_pi_t = -PI / globals->samrate;
 two_pi_t = -2.0 * minus_pi_t;

 setabc(FLPhz, BLPhz, &rlp);
 srand(1);             /* Init ran # generator */
 nper = 0;             /* LG */
 T0 = 0;                 /* LG */

 rnpp.p1 = 0;       /* parallel nasal pole  */
 rnpp.p2 = 0;

 r1p.p1 = 0;         /* parallel 1st formant */
 r1p.p2 = 0;

 r2p.p1 = 0;         /* parallel 2nd formant */
 r2p.p2 = 0;

 r3p.p1 = 0;         /* parallel 3rd formant */
 r3p.p2 = 0;

 r4p.p1 = 0;         /* parallel 4th formant */
 r4p.p2 = 0;

 r5p.p1 = 0;         /* parallel 5th formant */
 r5p.p2 = 0;

 r6p.p1 = 0;         /* parallel 6th formant */
 r6p.p2 = 0;

 r1c.p1 = 0;         /* cascade 1st formant  */
 r1c.p2 = 0;

 r2c.p1 = 0;         /* cascade 2nd formant  */
 r2c.p2 = 0;

 r3c.p1 = 0;         /* cascade 3rd formant  */
 r3c.p2 = 0;

 r4c.p1 = 0;         /* cascade 4th formant  */
 r4c.p2 = 0;

 r5c.p1 = 0;         /* cascade 5th formant  */
 r5c.p2 = 0;

 r6c.p1 = 0;         /* cascade 6th formant  */
 r6c.p2 = 0;

 r7c.p1 = 0;
 r7c.p2 = 0;

 r8c.p1 = 0;
 r8c.p2 = 0;

 rnpc.p1 = 0;       /* cascade nasal pole   */
 rnpc.p2 = 0;

 rnz.p1 = 0;         /* cascade nasal zero   */
 rnz.p2 = 0;

 rgl.p1 = 0;         /* crit-damped glot low-pass filter */
 rgl.p2 = 0;

 rlp.p1 = 0;         /* downsamp low-pass filter    */
 rlp.p2 = 0;

 vlast = 0;           /* Previous output of voice                     */
 nlast = 0;           /* Previous output of random number generator   */
 glotlast = 0;     /* Previous value of glotout                   */
 warnsw = 0;

}
