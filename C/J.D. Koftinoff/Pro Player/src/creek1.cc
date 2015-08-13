/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"
#pragma hdrstop

#include "creek.hh"

#ifdef atarist
 creekvt52 con(2);      // the default console

#else

 #ifndef _WINDOWS
  creekpc con;
 #endif
#endif



