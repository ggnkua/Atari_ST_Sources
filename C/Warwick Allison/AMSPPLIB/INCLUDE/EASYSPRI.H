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

#ifndef _EasySprite_h
#define _EasySprite_h
#include "MobileSprite.h"
//
//  Simplified sprite creation routines.
//

Incarnation* GetIncarnation(Screen& S,int x,int y,int h,int attr);

MobileSprite* GetMobileSprite(Screen&,int x,int y,int h,int attr,int n=1,int dx=16,int dy=0);
Sprite* GetSprite(Screen&,int x,int y,int h,int attr,int n=1,int dx=16,int dy=0);

// Attributes:
//
#define SP_SIMPLE		0x0		// No special features
#define SP_MONO			0x0		// Monochrome
#define SP_COLOUR		0x1		// 16-Colour
#define SP_WIDE			0x2		// 32 pixels wide
#define SP_FAST			0x4		// Faster, but use more memory
#define SP_HOTCENTRE	0x8		// Hot spot of incarnations in there centre

#endif
