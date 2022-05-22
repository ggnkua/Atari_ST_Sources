
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ext.h>
#include <math.h>
#include "patch.h"
#include "types.h"

#define NO_SAMPS (10)
#define PAD_SIZE 8192

PATCH_HEADER header;
INSTRUMENT_DATA ins;
LAYER_DATA layer;
PATCHDATA sample[NO_SAMPS];
int no_samples;
short patchdata[NO_SAMPS][250000l];
short thispatch[250000l];

typedef struct
{	long	num_samples;
	char	id[12];	
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

NEW_PATCH_MAIN_HEADER new_patch;
NEW_SAMPLE_HEADER new_sample[128];
alloc16 new_patchdata[128];

/*
 *	Allocate memory on a 16 byte boundary.
 */
 
void *malloc16(long l,alloc16 *a)
{		if	(a != NULL)
		{	if ((a->allocd = calloc(1l,l+16l)) != NULL)
			{	a->ptr = ((long) (a->allocd)+15) & 0xfffffff0;
				return (a->ptr);
			}
		}
		return NULL;
}

/*
 *	Free a memory block on a 16 byte boundary.
 */

void free16(alloc16 *a)
{	if (a->allocd != NULL)
	{	free(a->allocd);
		a->allocd = NULL;
		a->ptr = NULL;
	}
}


/*
 * Find least common multiple of the two sample rates.
 * Construct the signal at the LCM by interpolating successive
 * input samples as straight lines.  Pull output samples from
 * this line at output rate.
 *
 * Of course, actually calculate only the output samples.
 *
 * LCM must be 32 bits or less.  Two prime number sample rates
 * between 32768 and 65535 will yield a 32-bit LCM, so this is 
 * stretching it.
 *
 *  Generate a master sample clock from the LCM of the two rates.
 *  Interpolate linearly along it.  Count up input and output skips.
 *
 *  Input:   |inskip |       |       |       |       |
 *
 *  LCM:     |   |   |   |   |   |   |   |   |   |   |
 *
 *  Output:  |  outskip  |           |           | 
 *                                                                      
 */


long gcd(long a, long b) 
{	if (b == 0)
		return a;
	else
		return gcd(b, a % b);
}

long lcm(long a, long b) 
{	return (a * b) / gcd(a, b);
}

typedef struct  {
	unsigned long lcmrate;		
	unsigned long inskip, outskip;	
	unsigned long intot, outtot;	
	long	lastsamp;
} ratestuff;

ratestuff rate;



/*
 * Processed signed long samples from ibuf to obuf.
 * Return number of samples processed.
 */

long lcm_freq_shifter(short *ibuf, short*obuf, long isamp, long osamp,long in__rate,long out_rate)
{	long len, done;
	short *istart = ibuf;
	short last;
	rate.lcmrate = lcm((long)in__rate, (long)out_rate);
	rate.inskip =  rate.lcmrate / in__rate;
	rate.outskip = rate.lcmrate / out_rate; 
	rate.intot = rate.outtot = 0;
	last = *obuf++ = *ibuf++;
	rate.outtot += rate.outskip;
	while ((rate.intot + rate.inskip) <= rate.outtot){
		last = *ibuf++;
		rate.intot += rate.inskip;
	}
	len = (isamp*rate.inskip)/rate.outskip;
	if (len > osamp)
		len = osamp;
	for(done=1; done < len; done++) {
		*obuf = last;
		*obuf += ((float)((*ibuf)-last)*((float)rate.outtot-rate.intot))/rate.inskip;
		obuf++;
		rate.outtot += rate.outskip;
		while ((rate.intot + rate.inskip) <= rate.outtot){
			last = *ibuf++;
			rate.intot += rate.inskip;
			if (ibuf - istart == isamp)
				return done;
		}
		if (rate.outtot == rate.intot)
			rate.outtot = rate.intot = 0;
	}
	return done;
}

int match_sample_patch(long freq)
{	int i,j=-1;
	long k,min = 0x7fffffff;
	for ( i = 0; i < layer.samples; i++ )
	{	if ((freq >= sample[i].low_frequency) && (freq <= sample[i].high_frequency))
			return i;
		k = freq-(sample[i].root_frequency);
		if ( k < 0)
			k = -k;
		
		if ( k < min )
		{	min = k;
			j = i;
		}
	}
	return j;
}


void conv_patch(char *patch)
{	int i,m,l=0,match;
    FILE *fil;
	long j = sizeof(NEW_PATCH_MAIN_HEADER),mnote;
	long div_midi_note = 16; 
	new_patch.num_samples = 6;
	mnote = 32;
    for ( i = 0; i < new_patch.num_samples; i++ )
	{		double ratio,freq;
			mnote += div_midi_note;
	
			freq = ( (double) 6.875*1000.0*pow(2.0,((double)mnote)/12.0) );
			match = match_sample_patch((long) freq);
 			ratio = ( (double) sample[match].sample_rate/32780.0) * 
 					( freq / (double) sample[match].root_frequency);
			for (m=l ; m < mnote ; m++)
			{		double this_freq = ( (double) 6.875*1000.0*pow(2.0,((double)m)/12.0) );
					new_patch.sample_offsets[m] = j;
					new_patch.sample_freqshs[m] = (this_freq/freq*65536.0*256.0) ;
			}
			new_sample[i].wave_size = ((long) ( (double) sample[match].wave_size / ratio)) & 0xfffffffe;
			new_sample[i].start_loop = ((long) ( (double) sample[match].start_loop / ratio)) & 0xfffffffe;
			new_sample[i].end_loop = ((long) ( (double) sample[match].end_loop / ratio)) & 0xfffffffe;
			new_sample[i].tune = sample[match].tune;
			new_sample[i].scale_frequency = sample[match].scale_frequency;
			new_sample[i].scale_factor = sample[match].scale_factor;
			new_sample[i].sample_rate = sample[match].sample_rate;
			memcpy (&new_sample[i].envelope_rate[0],&(sample[match].envelope_rate[0]),ENVELOPES);
			memcpy (&new_sample[i].envelope_offset[0],&(sample[match].envelope_offset[0]),ENVELOPES);
			new_sample[i].balance = sample[match].balance;
			new_sample[i].modes = sample[match].modes;

			if (malloc16(new_sample[i].wave_size,&(new_patchdata[i])) == NULL)
			{	printf("\nOUT OF MEMORY\n");
				exit (-2);
			}	
			
			printf("%d %ld %2.2f ",match,new_sample[i].wave_size,ratio);

			new_sample[i].wave_size = lcm_freq_shifter(
 							&patchdata[match][0],
 							new_patchdata[i].ptr,
 							sample[match].wave_size >> 1,
 							new_sample[i].wave_size >> 1,
 							(long) 16384,
 							(long) (16384.0/ratio)) * 2;
 							
 			if (new_sample[i].start_loop > new_sample [i].wave_size)
	 			new_sample[i].start_loop = new_sample [i].wave_size;

 			if (new_sample[i].end_loop > new_sample [i].wave_size)
	 			new_sample[i].end_loop = new_sample [i].wave_size;
 						
			{	long s = new_sample[i].wave_size >> 1;
				long ls = new_sample[i].start_loop >> 1;
				long le = new_sample[i].end_loop >> 1;
				long c,cl = ls;
				short *new_pdata = (short *) new_patchdata[i].ptr;
		        if ( sample[match].modes & 4 )
		        {	for (c = s ; c < s+PAD_SIZE ; c++)
					{	new_pdata[c] = new_pdata[cl];
						cl++;
						if (cl >= le)
							cl = ls;
					}
				}
				else
				{	new_sample[i].start_loop = s;
					new_sample[i].end_loop   = s;
								for (c = s ; c < s+PAD_SIZE ; c++)
						new_pdata[c] = 0;
				}
			}
			j += sizeof(NEW_SAMPLE_HEADER)+new_sample[i].wave_size+(PAD_SIZE*2);
			l = mnote;
	}

	if ( (fil = fopen( patch, "wb" )) != NULL )
	{
 	   fwrite( &new_patch, sizeof(NEW_PATCH_MAIN_HEADER), 1, fil );
	   for ( i = 0; i < new_patch.num_samples; i++ )
	   { 	fwrite( &new_sample[i], sizeof(new_sample[i]), 1, fil );
	  		fwrite( new_patchdata[i].ptr, new_sample[i].wave_size +(PAD_SIZE*2), 1, fil );
			free16(&new_patchdata[i]);
	   }
	   fclose(fil);
	} else
	    printf( "Couldn't open file for writing.\n" );
}

/* reads and displays information from the .PAT file */

void read_patch( char *patch )
{ FILE *fil;
  int i,j;
 
  if ( (fil = fopen( patch, "rb" )) != NULL )
  {
    /* Unix based routines, assume big-endian machine */
    /* read header */
    fread( &header.header, sizeof(header.header), 1, fil );
    fread( &header.gravis_id, sizeof(header.gravis_id), 1, fil );
    fread( &header.description, sizeof(header.description), 1, fil );
    fread( &header.instruments, sizeof(header.instruments), 1, fil );
    fread( &header.voices, sizeof(header.voices), 1, fil );
    fread( &header.channels, sizeof(header.channels), 1, fil );
    fread( &header.wave_forms, sizeof(header.wave_forms), 1, fil );
    fread( &header.master_volume, sizeof(header.master_volume), 1, fil );
    fread( &header.data_size, sizeof(header.data_size), 1, fil );
    fread( &header.reserved, sizeof(header.reserved), 1, fil );
    header.wave_forms = swapi( header.wave_forms );
    header.master_volume = swapi( header.master_volume );
    header.data_size = swapl( header.data_size );
    /* read instrument header */
    fread( &ins.instrument, sizeof(ins.instrument), 1, fil );
    fread( &ins.instrument_name, sizeof(ins.instrument_name), 1, fil );
    fread( &ins.instrument_size, sizeof(ins.instrument_size), 1, fil );
    fread( &ins.layers, sizeof(ins.layers), 1, fil );
    fread( &ins.reserved, sizeof(ins.reserved), 1, fil );
    ins.instrument_size = swapl( ins.instrument_size );
    /* read layer header */
    fread( &layer.layer_duplicate, sizeof(layer.layer_duplicate), 1, fil );
    fread( &layer.layer, sizeof(layer.layer), 1, fil );
    fread( &layer.layer_size, sizeof(layer.layer_size), 1, fil );
    fread( &layer.samples, sizeof(layer.samples), 1, fil );
    fread( &layer.reserved, sizeof(layer.reserved), 1, fil );
    layer.layer_size = swapl( layer.layer_size );
 
    printf( "\n\n" );

    {
      printf( "%s\n", strupr( patch ) );
      printf( "Name: %s\n", ins.instrument_name );
      printf( "Description: %s\n", header.description );
      printf( "Number of samples: %u\n", header.wave_forms );
      printf( "Total patch size: %lu bytes\n", header.data_size );
	  no_samples = layer.samples;
 
      /* read sample information */
      for ( i = 0; i < layer.samples; i++ )
      {	
        fread( &sample[i].wave_name, sizeof(sample[i].wave_name), 1, fil );
        fread( &sample[i].fractions, sizeof(sample[i].fractions), 1, fil );
        fread( &sample[i].wave_size, sizeof(sample[i].wave_size), 1, fil );
        fread( &sample[i].start_loop, sizeof(sample[i].start_loop), 1, fil );
        fread( &sample[i].end_loop, sizeof(sample[i].end_loop), 1, fil );
        fread( &sample[i].sample_rate, sizeof(sample[i].sample_rate), 1, fil );
        fread( &sample[i].low_frequency, sizeof(sample[i].low_frequency), 1, fil );
        fread( &sample[i].high_frequency, sizeof(sample[i].high_frequency), 1, fil );
        fread( &sample[i].root_frequency, sizeof(sample[i].root_frequency), 1, fil );
        fread( &sample[i].tune, sizeof(sample[i].tune), 1, fil );
        fread( &sample[i].balance, sizeof(sample[i].balance), 1, fil );
        fread( &sample[i].envelope_rate, sizeof(sample[i].envelope_rate), 1, fil );
        fread( &sample[i].envelope_offset, sizeof(sample[i].envelope_offset), 1, fil );
        fread( &sample[i].tremolo_sweep, sizeof(sample[i].tremolo_sweep), 1, fil );
        fread( &sample[i].tremolo_rate, sizeof(sample[i].tremolo_rate), 1, fil );
        fread( &sample[i].tremolo_depth, sizeof(sample[i].tremolo_depth), 1, fil );
        fread( &sample[i].vibrato_sweep, sizeof(sample[i].vibrato_sweep), 1, fil );
        fread( &sample[i].vibrato_rate, sizeof(sample[i].vibrato_rate), 1, fil );
        fread( &sample[i].vibrato_depth, sizeof(sample[i].vibrato_depth), 1, fil );
        fread( &sample[i].modes, sizeof(sample[i].modes), 1, fil );
        fread( &sample[i].scale_frequency, sizeof(sample[i].scale_frequency), 1, fil );
        fread( &sample[i].scale_factor, sizeof(sample[i].scale_factor), 1, fil );
        fread( &sample[i].reserved, sizeof(sample[i].reserved), 1, fil );
        sample[i].wave_size = swapl( sample[i].wave_size );
        sample[i].start_loop = swapl( sample[i].start_loop );
        sample[i].end_loop = swapl( sample[i].end_loop );
        sample[i].sample_rate = swapi( sample[i].sample_rate );
		sample[i].low_frequency = swapl(sample[i].low_frequency);
		sample[i].high_frequency = swapl(sample[i].high_frequency);
		sample[i].root_frequency = swapl(sample[i].root_frequency);
		sample[i].tune = swapi(sample[i].tune);
		sample[i].scale_frequency = swapi(sample[i].scale_frequency);
        sample[i].scale_factor = swapi( sample[i].scale_factor );

        if ( sample[i].scale_factor == 0 ) printf( "Percussion " );
        printf( "Wave name: %s [%ld bytes]\n", sample[i].wave_name, sample[i].wave_size );
        printf( "  %s bit, %u Hz\n", (sample[i].modes & 1) ? "16" : "8", sample[i].sample_rate );
        if ( sample[i].modes & 32 ) printf( "  Sustained, " );
        else
          printf( "  " );
        if ( sample[i].modes & 64 ) printf( "Enveloped, " );
        if ( sample[i].modes & 4 == 0 ) printf( "Non-looping" );
        else
        if ( sample[i].modes & 8 ) printf( "Bidirectional-looping" );
        else
        if ( sample[i].modes & 16 ) printf( "Backward-looping" );
        else
        if ( sample[i].modes & 4 ) printf( "Looping" );

        if ( sample[i].tremolo_depth ) printf( ", Tremolo ON" );
        if ( sample[i].vibrato_depth ) printf( ", Vibrato ON" );

	
        fread( &thispatch[0], sample[i].wave_size, 1, fil );
		if (sample[i].modes & 1) 
		{	unsigned long l;
			short *src = &thispatch[0];
			short *dst = &patchdata[i][0];
			long len = (sample[i].wave_size >> 1);
			for (l = 0 ; l < len; l++ )
			{	short a = swapi(src[l]);
				if (sample[i].modes & 2)
					a ^= 0x8000;
				dst [l] = a;
			}
      	}  else
		{	unsigned long l;
			char *src = &thispatch[0];
			short *dst = &patchdata[i][0];
			long len = sample[i].wave_size;
			sample[i].wave_size *= 2;
			sample[i].start_loop *= 2;
			sample[i].end_loop *= 2;
			for (l = 0 ; l < len; l++ )
			{	unsigned short a = ((unsigned short) src[l]) << 8;
				if (sample[i].modes & 2)
					a ^= 0x8000;
				dst [l] = a;
			}
		} 			

		printf("\nlow:%lX high:%lX root:%lX scale:%X factor:%X tune:%X\n",
			sample[i].low_frequency,sample[i].high_frequency,sample[i].root_frequency,sample[i].scale_frequency,sample[i].scale_factor,sample[i].tune);
	
		for (j=0 ; j <= 5 ; j++)
			printf("%X %X ",sample[i].envelope_offset[j],sample[i].envelope_rate[j]);
        printf( "\n" );

      }
    }
    fclose( fil );
  }
  else
    printf( "Error accessing file!\n" );
}
 
/* main program */
void main( char argc, char **argv )
{	long	i;
/*	for (i = 0 ; i < NO_INSTRUMENT ; i++)
	{	read_patch(gm_instrument_fnames[i]);
		gm_instrument_fnames[i][0] = 'g';
		gm_instrument_fnames[i][5] = '2';
		conv_patch(gm_instrument_fnames[i]);
	} 
*/	
		read_patch("f:\\gm1.set\\acpiano.pat");
		conv_patch("g:\\gm2.set\\acpiano.pat");
		read_patch("f:\\gm1.set\\halopad.pat");
		conv_patch("g:\\gm2.set\\halopad.pat");
		read_patch("f:\\gm1.set\\bowglass.pat");
		conv_patch("g:\\gm2.set\\bowglass.pat");
}
