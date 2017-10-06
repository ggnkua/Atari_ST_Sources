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
#ifndef fnameext_h
#define fnameext_h

char* basename(char* dest,const char*);
char* directory(char* dest,const char*);
char* extension(char* dest,const char*);
char* noextension(char* dest,const char*);

#endif
