/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		scratt.c: screen attributes

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <osbind.h>

#define REZS		(3)

int scrdimx()
{
	static int screendimx[REZS] =	{ 320, 640, 640 };
	return screendimx[Getrez()];
}

int scrdimy()
{
	static int screendimy[REZS] = 	{ 200, 200, 400 };
	return screendimy[Getrez()];
}

int planes()
{
	static int nplanes[REZS] =	{ 4, 2, 1 };
	return nplanes[Getrez()];
}
