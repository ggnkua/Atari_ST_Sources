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
#ifndef SmallGraphics_h
#define SmallGraphics_h

void InitSmallGraphics();

void Colour(int C);
inline void Color(int C) { Colour(C); }

void Plot(int x, int y);
void Plot(int x, int y, int C);

int ColourAt(int x, int y);
inline int ColorAt(int x, int y) { return ColourAt(x,y); }

void Line(int x, int y);
void Line(int x1, int y1, int x2, int y2);

void Rectangle(int x1, int y1, int x2, int y2);
void Fill(int x, int y);

int MaxX();
int MaxY();

#endif
