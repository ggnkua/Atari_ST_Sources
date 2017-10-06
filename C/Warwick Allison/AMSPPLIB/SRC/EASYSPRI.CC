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

#include "EasySprite.h"

Incarnation* GetIncarnation(Screen& S,int x,int y,int h,int attr)
{
	Incarnation* Result;

	if (attr&SP_COLOUR) {
		if (attr&SP_WIDE) Result=new WideColourIncarnation(h);
		else if (attr&SP_FAST) Result=new PreshiftedColourIncarnation(h);
		else Result=new ColourIncarnation(h);
	} else {
		if (attr&SP_WIDE) Result=new WideMonochromeIncarnation(h);
		else if (attr&SP_FAST) Result=new PreshiftedMonochromeIncarnation(h);
		else Result=new MonochromeIncarnation(h);
	}

	Result->GetImage(S,x,y);

	if (attr&SP_HOTCENTRE) Result->SetHotSpot(Result->Width()/2,Result->Height()/2);

	return Result;
}

Sprite* GetSprite(Screen& S,int x,int y,int h,int attr,int n=1,int dx=16,int dy=0)
{
	Sprite* Result=new Sprite(n);
	for (int i=0; i<n; i++) {
		Result->SetImage(i,GetIncarnation(S,x,y,h,attr));
		x+=dx;
		y+=dy;
	}

	return Result;
}

MobileSprite* GetMobileSprite(Screen& S,int x,int y,int h,int attr,int n=1,int dx=16,int dy=0)
{
	MobileSprite* Result=new MobileSprite(n);
	for (int i=0; i<n; i++) {
		Result->SetImage(i,GetIncarnation(S,x,y,h,attr));
		x+=dx;
		y+=dy;
	}

	return Result;
}
