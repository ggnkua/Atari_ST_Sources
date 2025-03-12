/*****************************************************************************
Author     : Peter Persson
Description: Atari Falcon-specific sound wrapper, uses YM-blippeblipp sound
Version    : 0.0.1 (2006-01-07)
******************************************************************************/


#include "types.h"
#include "mint/falcon.h"

unsigned char wave_noise[16] ={0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 1};
unsigned char wave_tone[16] =	{0, 1, 0, 0, 1, 1, 1, 1,	0, 1, 1, 0, 1, 1, 1, 1};
unsigned int base_freq[16] = {0, 2096, 68, 68, 15720, 15720, 1014, 1014, 62, 1014, 1014, 0, 5240, 5240, 338, 338};


int c0, c1, f0, f1;
int frq1, frq2;	
int per1, per2;
int tonemask = 0x3f;


void
sound_init (void)
{
	/* mute all soundchannels */
	Giaccess((Giaccess(0,7) | 0x003f) | tonemask,7+128);
}

void
sound_close (void)
{
	/* mute all soundchannels */
	Giaccess((Giaccess(0,7) | 0x003f) | tonemask,7+128);
}

void
sound_freq (int channel, BYTE freq)
{
	if(channel)
	{
		f0 = freq & 0x01f;
		frq1 = base_freq[c0] / f0;
		per1 = 125000/frq1;
		Giaccess(per1 & 0x00FF , 0+128);	/* pitch ch1 */
		Giaccess(per1 >> 8 , 1+128);
		
	} else
	{
		f1 = freq & 0x01f;
		frq2 = base_freq[c1] / f1;
		per2 = 125000/frq2;
		Giaccess(per2 & 0x00FF , 2+128);	/* pitch ch2 */
		Giaccess(per2 >> 8 , 3+128);		
	}
	
	Giaccess( (frq1+frq2) >> 8 , 6 +128); /* noise pitch */
}

void
sound_volume (int channel, BYTE vol)
{
	if(channel)
		Giaccess(vol & 0x0F,128+8);
	else
		Giaccess(vol & 0x0F,128+9);
}

void
sound_waveform (int channel, BYTE val)
{
	if(channel)
	{
		c0 = val & 0x0f;
		if(wave_noise[c0])	tonemask &= ~0x08; else tonemask |= 0x08;
		if(wave_tone[c0])	tonemask &= ~0x01; else tonemask |= 0x01;
		frq1 = base_freq[c0] / f0;
		per1 = 125000/frq1;
		Giaccess(per1 & 0x00FF , 0+128);	/* pitch ch1 */
		Giaccess(per1 >> 8 , 1+128);
		
	} else
	{
		c1 = val & 0x0f;
		if(wave_noise[c1])	tonemask &= ~0x10; else tonemask |= 0x10;
		if(wave_tone[c1])	tonemask &= ~0x02; else tonemask |= 0x02;
		frq2 = base_freq[c1] / f1;
		per2 = 125000/frq2;
		Giaccess(per2 & 0x00FF , 2+128);	/* pitch ch2 */
		Giaccess(per2 >> 8 , 3+128);		
	}		
	
	Giaccess( (frq1+frq2) >> 8 , 6 +128); /* noise pitch */
	Giaccess((Giaccess(0,7) & 0x00C0) | tonemask,7+128);
}

void
sound_flush (void)
{
}

void
sound_update (void)
{
}
