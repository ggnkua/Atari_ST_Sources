//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////
#ifndef _SoundEnvelope_h
#define _SoundEnvelope_h

#include <bool.h>

struct WavePoint {
	short Pitch;
	short Volume;
};

class SoundEnvelope {
public:
	SoundEnvelope(
			short StartPitch, short PitchChange,
			short StartVolume, short VolumeChange,
			short StartPriority, short PriorityChange,
			bool Noisy
		);

	SoundEnvelope(WavePoint* WaveForm,
			short StartPriority, short PriorityChange,
			bool Noisy
		);

	void Start();

private:
	short P,dP,V,dV,Pr,dPr;
	bool N,Wave;
	WavePoint* D;
};

short DoSounds();

#endif
