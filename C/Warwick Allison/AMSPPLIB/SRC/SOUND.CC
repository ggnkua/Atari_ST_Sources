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
#include <osbind.h>


const int ToneRegister=0;
const int VolumeRegister=8;
const int SustainRegisterLow=11;
const int SustainRegisterHigh=12;
const int WaveformRegister=13;
const int ControlRegister=7;
const int NoisePeriodRegister=6;

#define GiWrite(v, r) Giaccess((v),128+(r))
#define GiRead(r) Giaccess(0,(r))

void Sound(short Channel, short Pitch, short Volume)
{
	short VolumeReg=Channel+VolumeRegister;
	short ToneReg=Channel+Channel+ToneRegister;

	GiWrite(Volume,VolumeReg);
	GiWrite(Pitch&255,ToneReg);
	GiWrite(Pitch>>8,ToneReg+1);
	//GiWrite(GiRead(ControlRegister)&~(1<<Channel),ControlRegister);
}


void SoundControl(short Active, short Noisy)
{
	GiWrite(GiRead(ControlRegister)&192 | ((~Active)&7) | (((~Noisy)&7)<<3),ControlRegister);
}


void SetEnvelope(short WaveForm, short Period)
{
	GiWrite(Period&255,SustainRegisterLow);
	GiWrite(Period>>8,SustainRegisterHigh);
	GiWrite(WaveForm,WaveformRegister);
}


void SetNoisePeriod(short P)
{
	GiWrite(P,NoisePeriodRegister);
}


void SoundOff()
{
	SetNoisePeriod(0);
	Sound(0,0,0);
	Sound(1,0,0);
	Sound(2,0,0);
	SoundControl(0,0);
}


void SetPitch(short Channel, short Pitch)
{
	short ToneReg=Channel*2+ToneRegister;
	GiWrite(Pitch&255,ToneReg);
	GiWrite(Pitch>>8,ToneReg+1);
}


void SetVolume(short Channel, short Volume)
{
	GiWrite(Volume,VolumeRegister+Channel);
}


void SetNoisy(short Channel, bool Noisy)
{
	short NoiseBit=8<<Channel;

	if (Noisy) {
		GiWrite(GiRead(ControlRegister) & ~NoiseBit,ControlRegister);
	} else {
		GiWrite(GiRead(ControlRegister) | NoiseBit,ControlRegister);
	}
}


void SetActive(short Channel, bool Active)
{
	short ActiveBit=1<<Channel;

	if (Active) {
		GiWrite(GiRead(ControlRegister) & ~ActiveBit,ControlRegister);
	} else {
		GiWrite(GiRead(ControlRegister) | ActiveBit,ControlRegister);
	}
}
