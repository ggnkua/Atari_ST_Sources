/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include <aesbind.h>
#include <minmax.h>
#include "gemrec.h"

static const RECORDSIZE=16;

GEMrecorder::GEMrecorder(int MaxRecordLength) :
	Mylar(new short[MaxRecordLength*RECORDSIZE]),
	MylarLength(MaxRecordLength)
{ }

GEMrecorder::~GEMrecorder()
{
	delete Mylar;
}

void GEMrecorder::Record()
{
	appl_trecord(Mylar,MylarLength);
}

void GEMrecorder::Record(int RecordLength)
{
	appl_trecord(Mylar,min(RecordLength,MylarLength));
}

void GEMrecorder::Stop()
{
	appl_trecord(0,0);
}

void GEMrecorder::Play()
{
	appl_tplay(Mylar,MylarLength,1);
}

void GEMrecorder::Play(int Speed)
{
	appl_tplay(Mylar,MylarLength,Speed);
}

void GEMrecorder::Play(int Speed, int Amount)
{
	appl_tplay(Mylar,min(Amount,MylarLength),Speed);
}

