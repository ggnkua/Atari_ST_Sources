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

#include "SmallGraphics.h"
#include <linea.h>

static short Pattern[4]={0xffff,0xffff,0xffff,0xffff};

void InitSmallGraphics()
{
	linea0();
	__aline->_LNMASK=0xffff;
	__aline->_PTSIN[0]=0;
	__aline->_PTSIN[1]=0;
	__aline->_WMODE=0;
	__aline->_LNMASK=0xffff;
	__aline->_LSTLIN=-1;
	__aline->_PATPTR=Pattern;
	__aline->_PATMSK=4;
	__aline->_MFILL=0;
	__aline->_CLIP=0;
}

void Colour(int C)
{
	__aline->_INTIN[0]=C;
	__aline->_COLBIT0=C&1;
	__aline->_COLBIT1=C&2;
	__aline->_COLBIT2=C&4;
	__aline->_COLBIT3=C&8;
}

void Plot(int x, int y)
{
	__aline->_PTSIN[0]=x;
	__aline->_PTSIN[1]=y;
	__aline->_X2=x;
	__aline->_Y2=y;
	linea1();
}

void Plot(int x, int y, int C)
{
	Colour(C);
	__aline->_PTSIN[0]=x;
	__aline->_PTSIN[1]=y;
	__aline->_X2=x;
	__aline->_Y2=y;
	linea1();
}

int ColourAt(int x, int y)
{
	__aline->_PTSIN[0]=x;
	__aline->_PTSIN[1]=y;
	return linea2();
}

void Line(int x, int y)
{
/*
	__aline->_PTSIN[2]=__aline->_PTSIN[0];
	__aline->_PTSIN[3]=__aline->_PTSIN[1];
	__aline->_PTSIN[0]=x;
	__aline->_PTSIN[1]=y;
*/
	__aline->_X1=__aline->_X2;
	__aline->_Y1=__aline->_Y2;
	__aline->_X2=x;
	__aline->_Y2=y;
	linea3();
}

void Line(int x1, int y1, int x2, int y2)
{
/*
	__aline->_PTSIN[0]=x1;
	__aline->_PTSIN[1]=y1;
	__aline->_PTSIN[2]=x2;
	__aline->_PTSIN[3]=y2;
*/
	__aline->_X1=x1;
	__aline->_Y1=y1;
	__aline->_X2=x2;
	__aline->_Y2=y2;
	linea3();
}

void Rectangle(int x1, int y1, int x2, int y2)
{
	__aline->_PTSIN[0]=x1;
	__aline->_PTSIN[1]=y1;
	__aline->_PTSIN[2]=x2;
	__aline->_PTSIN[3]=y2;
	linea5();
}

void Fill(int x, int y)
{
	__aline->_PTSIN[0]=x;
	__aline->_PTSIN[1]=y;
	lineae();
}

int MaxX()
{
	return V_X_MAX;
}

int MaxY()
{
	return V_Y_MAX;
}
