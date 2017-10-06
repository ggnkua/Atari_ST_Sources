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

#include "Sound.h"
#include "SoundEnvelope.h"
#include <values.h>

const ExtendedVolumeResolution=8; 
const short Simple=0;
const short Plotted=1;
short ActiveSounds=0;

struct SoundDataRec {
		short Type;
		short Priority,DPriority;
		short Pitch,DPitch;
		short Volume,DVolume;
		WavePoint* Data;
		short filler[7]; // Fill to 16 words

		SoundDataRec() :
			Priority(0)
		{}
	} SoundData[3];

static
bool GetChannel(short& Ch, short ApplicantPriority)
{
	short Meagreness;

	Meagreness=MAXSHORT;
	for (short Try=0; Try<3; Try++) {
		if (SoundData[Try].Priority <= Meagreness) {
			Ch=Try;
			Meagreness=SoundData[Try].Priority;
		}
	}
	if (Meagreness < ApplicantPriority) {
		if (Meagreness>0) {
			ActiveSounds--;
		}
		return TRUE;
	} else {
		return FALSE;
	}
}


SoundEnvelope::SoundEnvelope(short StartPitch, short PitchChange,
				short StartVolume,short VolumeChange,
				short StartPriority,short PriorityChange,
				bool Noisy) :
	P(StartPitch),dP(PitchChange),
	V(StartVolume << ExtendedVolumeResolution),dV(VolumeChange),
	Pr(StartPriority),dPr(PriorityChange),
	N(Noisy), Wave(FALSE)
{ }

SoundEnvelope::SoundEnvelope(WavePoint* WaveForm,
				short StartPriority,short PriorityChange,
				bool Noisy) :
	Pr(StartPriority), dPr(PriorityChange),
	N(Noisy),
	D(WaveForm), Wave(TRUE)
{ }

void SoundEnvelope::Start()
/* Initiate a sound.  Terminates when any<=0 or when overridden. */
{
	short Ch;

	if (GetChannel(Ch,Pr)) {
		SoundData[Ch].Priority=Pr;
		SoundData[Ch].DPriority=dPr;
		if (Wave) {
			SoundData[Ch].Type=Plotted;	
			SoundData[Ch].Data=D;
		} else {
			SoundData[Ch].Type=Simple;
			SoundData[Ch].Pitch=P;
			SoundData[Ch].DPitch=dP;
			SoundData[Ch].Volume=V;
			SoundData[Ch].DVolume=dV;
		}
		SetVolume(Ch,0);
		SetActive(Ch,TRUE);
		SetNoisy(Ch,N);
		ActiveSounds++;
	}
}



short DoSounds()
/* progress sound output, returns number playing */
{
	for (short Ch=0; Ch<3; Ch++) {
		SoundDataRec* S=&SoundData[Ch];
		if (S->Priority>0) {
			if (S->Type==Simple) {
				Sound(Ch,S->Pitch,S->Volume >> ExtendedVolumeResolution);
				S->Pitch=S->Pitch+S->DPitch;
				S->Volume=S->Volume+S->DVolume;
				if (S->Pitch<0 || S->Volume<0) S->Priority=0;
			} else {
				if (S->Data->Pitch<0) S->Priority=0;
				else {
					Sound(Ch,S->Data->Pitch,S->Data->Volume);
					S->Data++;
				}
			}
			S->Priority=S->Priority+S->DPriority;
			if (S->Priority<=0) {
				SetVolume(Ch,0);
				ActiveSounds--;
			}
		}
	}
	return ActiveSounds;
}
