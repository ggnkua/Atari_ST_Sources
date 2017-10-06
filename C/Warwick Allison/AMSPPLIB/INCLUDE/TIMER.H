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
#ifndef _Timer_h
#define _Timer_h

unsigned long Hz200();
void Delay(unsigned long msec);

class TimerSpeed
{
public:
	TimerSpeed(int Hz); // Ask for given speed
	operator int(); // closest approximation

private:
	int Control,Data;
	friend void SetTimerA(void ISR(), TimerSpeed&); // Should be member?
};

void HaltTimerA();

void SetTimerA(void ISR(), TimerSpeed&);

void SetTimerA(void ISR(), int Hz); // Slow.


#endif
