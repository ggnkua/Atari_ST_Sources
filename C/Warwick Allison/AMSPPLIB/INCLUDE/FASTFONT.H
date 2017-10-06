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

#ifndef FastFont_h
#define FastFont_h

// 16-pixel, single plane (but still works in colour) text.

class Screen;

class FastFont {
public:
	FastFont(Screen& s, int w, int h, char from, char to);
	FastFont(const char*);
	~FastFont();

	int operator! ();
	int Save(const char*);

	void Plane(short);

	void Put(char, int& x, int y);
	void Put(const char*, int& x, int y);

	short Width(char);
	int Width(const char*);
	void SetWidth(char,short); // Default=width of bitmap
	void SetSpacing(short); // Default=1

private:
	char min,max;
	unsigned short** data;
	unsigned short* width;
	short height;
	short plane;
	short space;
};

#endif
