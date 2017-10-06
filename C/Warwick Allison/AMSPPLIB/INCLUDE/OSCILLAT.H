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

#ifndef Oscillator_h
#define Oscillator_h

#include <bool.h>

class Cycle {
public:
	Cycle() : Period(2), Throb(2) {}
	Cycle(int n) : Period(n), Throb(n) {}
	bool operator() () { if (!--Throb) Throb=Period; return Throb==Period; }
	void Rate(int R) { Period=R; Throb=R; }

public:
	int Period;
	int Throb;
};

class Oscillator {
public:
	Oscillator(int min,int max);
	operator int() { return Throb; }
	int Oscillate();

private:
	int Min,Max;
	int Throb;
	int Way;
};

#endif
