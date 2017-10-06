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
#include "fnameext.h"

#define FILESEP '/'
#define EXTSEP '.'

char* basename(char* dest,const char* src)
{
	// To end
	for (int i=0; src[i]; i++);

	// Back to start or after FILESEP
	while (i && src[i-1]!=FILESEP) i--;

	const char* result=&src[i];  // default = end of src

	// Copy from there to end
	for (int j=0; src[i]; i++) dest[j++]=src[i];

	// Null terminate
	dest[j]=0;

	return (char*)result; // Cast to char* - caller owns src[]
}

char* directory(char* dest,const char* src)
{
	// To end
	for (int i=0; src[i]; i++);

	// Back to start or after FILESEP
	while (i && src[i-1]!=FILESEP) i--;

	// Copy all before there
	for (int j=0; j<i; j++) dest[j]=src[j];

	// Null terminate
	dest[j]=0;

	return dest;
}

char* extension(char* dest,const char* src)
{
	// To end
	for (int i=0; src[i]; i++);

	const char* result=&src[i];  // default = end of src

	// Back to start, after EXTSEP, or after FILESEP
	while (i && src[i-1]!=FILESEP && src[i-1]!=EXTSEP) i--;

	if (i && src[i-1]==EXTSEP) {
		result=&src[i];

		// Copy from there to end
		for (int j=0; src[i]; i++) dest[j++]=src[i];

		// Null terminate
		dest[j]=0;
	} else {
		// None
		dest[0]=0;
	}

	return (char*)result; // Cast to char* - caller owns src[]
}

char* noextension(char* dest,const char* src)
{
	// To end
	for (int i=0; src[i]; i++);

	// Back to start or after FILESEP
	while (i && src[i-1]!=FILESEP) i--;

	// Copy from there to end or before EXTSEP
	for (int j=0; src[i] && src[i]!=EXTSEP; i++) dest[j++]=src[i];

	// Null terminate
	dest[j]=0;

	return dest;
}

