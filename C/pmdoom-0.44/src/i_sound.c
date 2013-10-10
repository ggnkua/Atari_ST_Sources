// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//	System interface for sound.
//
//-----------------------------------------------------------------------------

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <math.h>
#include <stdio.h>
#include <string.h>

#include <SDL.h>

#include "z_zone.h"

#include "i_system.h"
#include "i_audio.h"
#include "i_sound.h"
#include "m_argv.h"
#include "m_misc.h"
#include "w_wad.h"

#include "doomdef.h"

extern sysaudio_t sysaudio;

// The number of internal mixing channels,
//  the samples calculated for each mixing step,
//  the size of the 16bit, 2 hardware channel (stereo)
//  mixing buffer, and the samplerate of the raw data.

// The channel step amount...
unsigned int	channelstep[NUM_CHANNELS];
// ... and a 0.16 bit remainder of last step.
unsigned int	channelstepremainder[NUM_CHANNELS];


// The channel data pointers, start and end.
unsigned char*	channels[NUM_CHANNELS];
unsigned char*	channelsend[NUM_CHANNELS];


// Time/gametic that the channel started playing,
//  used to determine oldest, which automatically
//  has lowest priority.
// In case number of active sounds exceeds
//  available channels.
int		channelstart[NUM_CHANNELS];

// The sound in channel handles,
//  determined on registration,
//  might be used to unregister/stop/modify,
//  currently unused.
int 		channelhandles[NUM_CHANNELS];

// SFX id of the playing sound effect.
// Used to catch duplicates (like chainsaw).
int		channelids[NUM_CHANNELS];			

// Pitch to stepping lookup, unused.
int		steptable[256];

// Volume lookups.
int *vol_lookup=NULL;

// Hardware left and right channel volume lookup.
int*		channelleftvol_lookup[NUM_CHANNELS];
int*		channelrightvol_lookup[NUM_CHANNELS];



//
// This function loads the sound data from the WAD lump,
//  for single sound.
//
void*
I_LoadSfx
( char*         sfxname,
  int*          len )
{
    unsigned char*      sfx;
    unsigned char*      paddedsfx;
    int                 i;
    int                 size;
    int                 paddedsize;
    char                name[20];
    int                 sfxlump;
    
	if (!sysaudio.enabled)
		return NULL;

    // Get the sound data from the WAD, allocate lump
    //  in zone memory.
    sprintf(name, "ds%s", sfxname);

    // Now, there is a severe problem with the
    //  sound handling, in it is not (yet/anymore)
    //  gamemode aware. That means, sounds from
    //  DOOM II will be requested even with DOOM
    //  shareware.
    // The sound list is wired into sounds.c,
    //  which sets the external variable.
    // I do not do runtime patches to that
    //  variable. Instead, we will use a
    //  default sound for replacement.
    if ( W_CheckNumForName(name) == -1 )
      sfxlump = W_GetNumForName("dspistol");
    else
      sfxlump = W_GetNumForName(name);
    
    size = W_LumpLength( sfxlump );

    // Debug.
    // fprintf( stderr, "." );
    //fprintf( stderr, " -loading  %s (lump %d, %d bytes)\n",
    //	     sfxname, sfxlump, size );
    //fflush( stderr );
    
    sfx = (unsigned char*)W_CacheLumpNum( sfxlump, PU_STATIC );

    // Pads the sound effect out to the mixing buffer size.
    // The original realloc would interfere with zone memory.
    paddedsize = ((size-8 + (sysaudio.obtained.size-1)) / sysaudio.obtained.size) * sysaudio.obtained.size;

    // Allocate from zone memory.
    paddedsfx = (unsigned char*)Z_Malloc( paddedsize+8, PU_STATIC, 0 );
    // ddt: (unsigned char *) realloc(sfx, paddedsize+8);
    // This should interfere with zone memory handling,
    //  which does not kick in in the soundserver.

    // Now copy and pad.
    memcpy(  paddedsfx, sfx, size );
    for (i=size ; i<paddedsize+8 ; i++)
        paddedsfx[i] = 128;

    // Remove the cached lump.
    Z_Free( sfx );
    
    // Preserve padded length.
    *len = paddedsize;

    // Return allocated padded data.
    return (void *) (paddedsfx + 8);
}

//
// This function adds a sound to the
//  list of currently active sounds,
//  which is maintained as a given number
//  (eight, usually) of internal channels.
// Returns a handle.
//
int
addsfx
( int		sfxid,
  int		volume,
  int		step,
  int		seperation )
{
	static unsigned short	handlenums = 0;

	int		i;
	int		rc = -1;

	int		oldest = gametic;
	int		oldestnum = 0;
	int		slot;

	int		rightvol;
	int		leftvol;

	if (!sysaudio.enabled)
		return -1;

	// Chainsaw troubles.
	// Play these sound effects only one at a time.
	if ( sfxid == sfx_sawup || sfxid == sfx_sawidl || sfxid == sfx_sawful
		|| sfxid == sfx_sawhit || sfxid == sfx_stnmov || sfxid == sfx_pistol) {
		// Loop all channels, check.
		for (i=0 ; i<NUM_CHANNELS ; i++) {
			// Active, and using the same SFX?
			if ( (channels[i]) && (channelids[i] == sfxid) ) {
				// Reset.
				channels[i] = 0;
				// We are sure that iff,
				//  there will only be one.
				break;
			}
		}
	}

	// Loop all channels to find oldest SFX.
	for (i=0; (i<NUM_CHANNELS) && (channels[i]); i++) {
		if (channelstart[i] < oldest) {
			oldestnum = i;
			oldest = channelstart[i];
		}
	}

	// Tales from the cryptic.
	// If we found a channel, fine.
	// If not, we simply overwrite the first one, 0.
	// Probably only happens at startup.
	if (i == NUM_CHANNELS)
		slot = oldestnum;
	else
		slot = i;

	/* Decrease usefulness of sample on channel 'slot' */
	if (channels[slot]) {
		S_sfx[channelids[slot]].usefulness--;
	}

	// Okay, in the less recent channel,
	//  we will handle the new SFX.
	// Set pointer to raw data.
	channels[slot] = (unsigned char *) S_sfx[sfxid].data;
	// Set pointer to end of raw data.
	channelsend[slot] = channels[slot] + S_sfx[sfxid].length;

	// Reset current handle number, limited to 0..100.
	if (!handlenums)
		handlenums = 100;

	// Assign current handle number.
	// Preserved so sounds could be stopped (unused).
	channelhandles[slot] = rc = handlenums++;

	// Set stepping???
	// Kinda getting the impression this is never used.
	channelstep[slot] = step;
	// ???
	channelstepremainder[slot] = 0;
	// Should be gametic, I presume.
	channelstart[slot] = gametic;

	// Separation, that is, orientation/stereo.
	//  range is: 1 - 256
	seperation += 1;

	// Per left/right channel.
	//  x^2 seperation,
	//  adjust volume properly.
	leftvol = volume - ((volume*seperation*seperation) >> 16); ///(256*256);
	seperation = seperation - 257;
	rightvol = volume - ((volume*seperation*seperation) >> 16);	

	// Sanity check, clamp volume.
	if (rightvol < 0 || rightvol > 127)
		I_Error("rightvol out of bounds");

	if (leftvol < 0 || leftvol > 127)
		I_Error("leftvol out of bounds");

	// Get the proper lookup table piece
	//  for this volume level???
	channelleftvol_lookup[slot] = &vol_lookup[leftvol*256];
	channelrightvol_lookup[slot] = &vol_lookup[rightvol*256];

	// Preserve sound SFX id,
	//  e.g. for avoiding duplicates of chainsaw.
	channelids[slot] = sfxid;

	// You tell me.
	return rc;
}

void I_UpdateSounds(void)
{
	int i;

	for (i=0;i<NUM_CHANNELS;i++) {
		int sfxid;

		sfxid = channelids[i];
		if ((S_sfx[sfxid].usefulness <= 0) && S_sfx[sfxid].data) {
//		    Z_ChangeTag(S_sfx[sfxid].data - 8, PU_CACHE);
			Z_Free(S_sfx[sfxid].data - 8);
			S_sfx[sfxid].usefulness = -1;
		    S_sfx[sfxid].data = NULL;
	    }
	}
}



//
// SFX API
// Note: this was called by S_Init.
// However, whatever they did in the
// old DPMS based DOS version, this
// were simply dummies in the Linux
// version.
// See soundserver initdata().
//
void I_SetChannels()
{
	// Init internal lookups (raw data, mixing buffer, channels).
	// This function sets up internal lookups used during
	//  the mixing process. 
	int		i;
	int		j;

	if (!sysaudio.enabled)
		return;

	// Okay, reset internal mixing channels to zero.
	for (i=0; i<NUM_CHANNELS; i++)
	{
		channels[i] = NULL;
	}

	// This table provides step widths for pitch parameters.
	// I fail to see that this is currently used.
	for (i=-128 ; i<128 ; i++) {
		int newstep;

		newstep = (int)(pow(2.0, (i/64.0))*65536.0);
		/* FIXME: are all samples 11025Hz ? */
		newstep = (newstep*11025)/sysaudio.obtained.freq;
		steptable[i+128] = newstep;
	}


	// Generates volume lookup tables
	//  which also turn the unsigned samples
	//  into signed samples.
	vol_lookup = Z_Malloc(128*256*sizeof(int), PU_STATIC, NULL);

	for (i=0 ; i<128 ; i++)
		for (j=0 ; j<256 ; j++)
			vol_lookup[i*256+j] = (i*(j-128)*256)/127;
}	

 
void I_SetSfxVolume(int volume)
{
  // Identical to DOS.
  // Basically, this should propagate
  //  the menu/config file setting
  //  to the state variable used in
  //  the mixing.
  snd_SfxVolume = volume;
}


//
// Retrieve the raw data lump index
//  for a given SFX name.
//
int I_GetSfxLumpNum(sfxinfo_t* sfx)
{
    char namebuf[9];
    sprintf(namebuf, "ds%s", sfx->name);
    return W_GetNumForName(namebuf);
}

//
// Starting a sound means adding it
//  to the current list of active sounds
//  in the internal channels.
// As the SFX info struct contains
//  e.g. a pointer to the raw data,
//  it is ignored.
// As our sound handling does not handle
//  priority, it is ignored.
// Pitching (that is, increased speed of playback)
//  is set, but currently not used by mixing.
//
int
I_StartSound
( int		id,
  int		vol,
  int		sep,
  int		pitch,
  int		priority )
{
	// UNUSED
	priority = 0;

	// Returns a handle (not used).
	id = addsfx( id, vol, steptable[pitch], sep );

	return id;
}



void I_StopSound (int handle)
{
	// You need the handle returned by StartSound.
	// Would be looping all channels,
	//  tracking down the handle,
	//  an setting the channel to zero.

	// UNUSED.
	handle = 0;
}


int I_SoundIsPlaying(int handle)
{
	// Ouch.
	return gametic < handle;
}




//
// This function loops all active (internal) sound
//  channels, retrieves a given number of samples
//  from the raw sound data, modifies it according
//  to the current (internal) channel parameters,
//  mixes the per channel samples into the global
//  mixbuffer, clamping it to the allowed range,
//  and sets up everything for transferring the
//  contents of the mixbuffer to the (two)
//  hardware channels (left and right, that is).
//
// This function currently supports only 16bit.
//
void I_UpdateSound(void *unused, Uint8 *stream, int len)
{
	// Mix current sound data.
	// Data, from raw sound, for right and left.
	unsigned int	sample;
	int		dl, dr;

	// Pointers in global mixbuffer, left, right, end.
	Sint16 *mixout, *mixend;

	// Mixing channel index.
	int				chan;

	// Left and right channel
	//  are in global mixbuffer, alternating.
	mixout = (Sint16 *)stream;

	// Determine end, for left channel only
	//  (right channel is implicit).
	mixend = mixout + (len>>1);

	// Mix sounds into the mixing buffer.
	// Loop over step*SAMPLECOUNT,
	//  that is 512 values for two channels.
	while (mixout != mixend) {
		// Reset left/right value. 
		dl = mixout[0];
		dr = mixout[1];

		// Love thy L2 chache - made this a loop.
		// Now more channels could be set at compile time
		//  as well. Thus loop those  channels.
		for ( chan = 0; chan < NUM_CHANNELS; chan++ ) {
			// Check channel, if active.
			if (channels[ chan ]) {
				// Get the raw data from the channel. 
				sample = *channels[ chan ];
				// Add left and right part
				//  for this channel (sound)
				//  to the current data.
				// Adjust volume accordingly.
				dl += channelleftvol_lookup[ chan ][sample];
				dr += channelrightvol_lookup[ chan ][sample];
				// Increment index ???
				channelstepremainder[ chan ] += channelstep[ chan ];
				// MSB is next sample???
				channels[ chan ] += channelstepremainder[ chan ] >> 16;
				// Limit to LSB???
				channelstepremainder[ chan ] &= 65536-1;

				// Check whether we are done.
				if (channels[ chan ] >= channelsend[ chan ]) {
					channels[ chan ] = 0;
					S_sfx[channelids[chan]].usefulness--;
				}
			}
		}

		// Clamp to range. Left hardware channel.
		// Has been char instead of short.

		if (dl > 0x7fff)
			dl = 0x7fff;
		else if (dl < -0x8000)
			dl = -0x8000;

		*mixout++ = dl;

		// Same for right hardware channel.
		if (dr > 0x7fff)
			dr = 0x7fff;
		else if (dr < -0x8000)
			dr = -0x8000;

		*mixout++  = dr;
	}
}


void
I_UpdateSoundParams
( int	handle,
  int	vol,
  int	sep,
  int	pitch)
{
  // I fail too see that this is used.
  // Would be using the handle to identify
  //  on which channel the sound might be active,
  //  and resetting the channel parameters.

  // UNUSED.
  handle = vol = sep = pitch = 0;
}

void I_ShutdownSound(void)
{    
	int i;
	int done = 0;

	// Wait till all pending sounds are finished.
	while ( !done ) {
		for( i=0 ; i<8 && !channels[i] ; i++) {
		}

		// FIXME. No proper channel output.
		//if (i==8)
			done=1;
	}
}

void I_InitSound(void)
{ 
}
