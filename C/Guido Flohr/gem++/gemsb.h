/////////////////////////////////////////////////////////////////////////////
//
//  GEMstream
//
//  A GEMstream is an C++ iostream for inter process communcation that
//  operates via the standard GEM application message passing interface.
//
//  This could me implemented as part of GEMapplication, but it is
//  quite expensive yet rarely used.
//
//  Concocted example:
//
//    GEMapplication Appl("myacc.acc");
//    iostream MyAcc(GEMstreambuf(Appl));
//    char AccSays[100];
//
//    MyAcc << "Hello, are you there?\n";
//    MyAcc >> AccSays;
//    cout << "myacc.acc say: " << AccSays << endl;
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef _GEMsb_h
#define _GEMsb_h

#include <streambuf.h>

#include <stddef.h>

class GEMstreambuf : public streambuf {
public:
	GEMstreambuf(int ApplID);
    virtual size_t sputn(const char* s, size_t n);
    virtual size_t sgetn(char* s, size_t n);

private:
	int ID;
};

#endif
