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

#ifndef _Screen_h
#define _Screen_h

#include "Resolution.h"
#include <osbind.h>

#define DESKSCREEN ((long *)0)


class Screen {
private:
	char *AllocArea;
	long AllocSize;
	char *location;
	Resolution Res;
	short *Palette;

public:
	Screen();
	Screen(const Screen&);
	Screen(Resolution);
	Screen(Resolution, short LinesAbove, short LinesBelow);
	Screen(short LinesAbove, short LinesBelow);
	Screen(const char *filename); // May cause ! to be true.
	Screen(long *At); // DESKSCREEN = current screen, else specify desired location
	~Screen();

	void Clear();

	int Load(const char*);
	int LoadPalette(const char *);

	int Save(const char*);

	int LoadDegas(const char *);
	int SaveDegas(const char *);
	int LoadDegasPalette(const char *);
	int LoadCrackArtPalette(const char *);
	int LoadCrackArt(const char *);
	int SaveCrackArt(const char *, int Compression=3);

	int operator !();

	void ShowPalette();
	void Show();
	void Use();

	void operator= (Screen&);
	void Copy(Screen& s) { operator=(s); }

	short* Colour();
	short* Color() { return Colour(); }

	char *Location();
	Resolution Rez();
};

class PaletteChange // Resolution sensitive
{
public:
	PaletteChange();
	~PaletteChange();

private:
	short *col;
	short ncols;
};


// Always inline:

inline	char* Screen::Location() { return location; }
inline	Resolution Screen::Rez() { return Res; }
inline	void Screen::ShowPalette() { Setpalette(Palette); }
inline	void Screen::Show() { Setscreen(-1,location,-1); }
inline	void Screen::Use() { Setscreen(location,-1,-1); }
inline 	short* Screen::Colour() { return Palette; }
inline	int Screen::operator !() { return !location; }


#endif
