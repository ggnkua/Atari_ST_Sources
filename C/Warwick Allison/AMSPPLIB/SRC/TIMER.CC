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

#include "Timer.h"
#include <stdio.h>
#include <osbind.h>
#include <builtin.h>
#include <sysvars.h>


// TERMINATION code:

// used to ensure DisplayRestorer is linked in if possibly necessary
#define EnsureRestoration { volatile TimerRestorer* x=&MyTimerRestorer; }

class TimerRestorer
{
public:
	TimerRestorer() { };
	~TimerRestorer() {
		HaltTimerA();
	};
};

static TimerRestorer MyTimerRestorer;



unsigned long hz200;

void GetHz200()
{
	hz200=*_hz_200;
}

unsigned long Hz200()
{
	Supexec(GetHz200);
	return hz200;
}


void Delay(unsigned long msec)
{
	msec=msec/5;

	unsigned long Start=Hz200();
	while (Start+msec > Hz200());
}




const MainClock=2457600; /* As gleaned from $FC21DC in BIOS */

const short Subdivider[]={000,4,10,16,50,64,100,200}; // First unused

TimerSpeed::TimerSpeed(int Hz)
{
	if (Hz==0) {
		Control=0;
		Data=0;
	} else {
		unsigned Granularity;
		unsigned MaxError,Error,DataRequired;
		short Mode;

		MaxError=99999999;
		Data=255;	// Best we can do is 82Hz
		Control=7;

		for (Mode=1; Mode<=7; Mode++) {
			Granularity=MainClock / Subdivider[Mode];
			DataRequired=Granularity / Hz;
			if (DataRequired < 256) {
				Error=abs(Granularity / DataRequired - Hz);
				if (Error < MaxError) {
					Control=Mode;
					Data=DataRequired;
					MaxError=Error;
				}
			}
		}
	}
}

TimerSpeed::operator int()
{
	unsigned Granularity=MainClock / Subdivider[Control];
	return Granularity / Data;
}

void HaltTimerA()
{
	Xbtimer(0,0,0,0);
}

void SetTimerA(void ISR(), TimerSpeed& S)
{
	EnsureRestoration;
	Xbtimer(0,S.Control,S.Data,ISR);
}

void SetTimerA(void ISR(), int Hz)
{
	if (Hz) SetTimerA(ISR,TimerSpeed(Hz));
	else HaltTimerA();
}
