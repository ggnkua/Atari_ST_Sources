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
#include "Oscillator.h"
#include <bool.h>

Oscillator::Oscillator(int min,int max) :
	Min(min), Max(max), Throb(Min), Way(-1)
{ }

int Oscillator::Oscillate()
{
	if (Throb==Min || Throb==Max) Way=-Way;

	return Throb+=Way;
}
