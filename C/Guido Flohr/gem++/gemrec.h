/////////////////////////////////////////////////////////////////////////////
//
//  GEMrecorder
//
//  A GEMrecorder records what is happening in a GEM session and can
//  replay the events.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMrec_h
#define GEMrec_h


class GEMrecorder
{
public:
	GEMrecorder(int MaxRecordLength);
	~GEMrecorder();

	void Record();
	void Record(int RecordLength);
	void Stop();
	void Play();
	void Play(int Speed);
	void Play(int Speed, int Amount);

private:
	short *Mylar;
	int MylarLength;
};

#endif
