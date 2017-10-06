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
#ifndef _Sound_h
#define _Sound_h

#include <bool.h>

const short USE_ENVELOPE=16; // Pass as a "Volume".

void Sound(short Channel, short Pitch, short Volume);
void SetEnvelope(short WaveForm, short Period);
void SetNoisePeriod(short P);
void SoundOff();
void SetPitch(short Channel, short Pitch);
void SetVolume(short Channel, short Volume);
void SetNoisy(short Channel, bool Noisy);
void SetActive(short Channel, bool Active);

void SoundControl(short Active, short Noisy);

#endif
