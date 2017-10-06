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
//
//   - Falcon resolutions are not supported by this module, due to lack of info
//   - TTHigh not tested.
//   - Need to care for Falcon emulation of TTMedium (and TTLow?), if possible.
//

#include "Resolution.h"
#include "Cookie.h"
#include <osbind.h>
#include <falcon.h>

const int NUMRES=8;
										/* STL STM STH ??? TTM  ???  TTH TTL */
static short StdWidth[NUMRES]			= {320,640,640,640,640,1280,1280,320};
static short StdHeight[NUMRES]			= {200,200,400,400,480, 960, 960,480};
static short StdDepth[NUMRES]			= {  4,  2,  1,  1,  4,   1,   1,  8};
static short StdTTOnly[NUMRES]			= {  0,  0,  0,  0,  1,   1,   1,  1};

const long NO_MODE=0x20000;
const long FALC_MODE=0x10000;

// TERMINATION code:

// used to ensure MyRezRestorer is linked in if possibly necessary
#define EnsureRestoration { volatile RezRestorer* x=&MyRezRestorer; }

class RezRestorer
{
public:
	RezRestorer() { }
	~RezRestorer() {
		Resolution Now;
		if (Now!=InitialResolution) InitialResolution.Use();
	}
private:
	Resolution InitialResolution;
};

static RezRestorer MyRezRestorer;


static
long ModeFor(int w, int h, int d)
{
	for (int m=0; m<NUMRES; m++) {
		if (w==StdWidth[m] && h==StdHeight[m] && d==StdDepth[m]) {
			if (StdTTOnly[m]) {
				if (GetCookieNamed("_VDO") == 0x20000) {
					// It's a TT.
					return m;
				}
			} else {
				return m;
			}
		}
	}

	montypes mon=Montype();

	if (int(mon)==-32 || int(mon)==89) {
		// Not a Falcon.
		return NO_MODE;
	}

	long mode=FALC_MODE|(Vsetmode(-1)&PAL); // PAL if already PAL.

	switch (w) {
	 case 640:
		mode|=COL80;
	break; case 320:
		mode|=0;
	break; case 384:
		mode|=OVERSCAN;
	break; case 768:
		mode|=COL80|OVERSCAN;
	break; default:
		return NO_MODE;
	}

	switch (h) {
	 case 200:
		mode|=STMODES;
	break; case 240:
		mode|=0;
	break; case 288:
		mode|=OVERSCAN;
	break; case 400:
		mode|=STMODES;
	break; case 480:
		mode|=0;
	break; case 576:
		mode|=OVERSCAN;
	break; default:
		return NO_MODE;
	}

	if (h<400 && (mon==VGAcolor || mon==STmono)     // Line doubled
	 || h>399 && (mon==STcolor || mon==TVcolor)) {  // or Interlaced
		mode|=VERTFLAG;
	}

	switch (d) {
	 case 1:
		mode|=BPS1;
	break; case 2:
		mode|=BPS2;
	break; case 4:
		mode|=BPS4;
	break; case 8:
		mode|=BPS8;
	break; case 16:
		mode|=BPS16;
	break; default:
		return NO_MODE;
	}

	return mode;
}

static void SetMode(long mode)
{
	switch (mode) {
	 case 0: case 1:
	 case 2: case 7:
	 case 4: case 5:
		Setscreen(-1,-1,mode,0);
	break; case NO_MODE:
		; // ignore
	break; 
		if (mode&FALC_MODE) {
			// Falcon...
			Vsetmode(mode^FALC_MODE);
		}
	}
}

Resolution::Resolution(short r)
{
	EnsureRestoration;

	switch (r) {
	 case 0: case 1: case 2: case 7: case 4: case 5:
		w=StdWidth[r];
		h=StdHeight[r];
		d=StdDepth[r];
		mode=ModeFor(w,h,d);
	break; default:
		mode=NO_MODE;
	}
}

Resolution::Resolution()
// Current
{
	EnsureRestoration;

	int r=Getrez();

	switch (r) {
	 case 0: case 1: case 2: case 7: case 4: case 5:
		w=StdWidth[r];
		h=StdHeight[r];
		d=StdDepth[r];
		mode=ModeFor(w,h,d);
	break;
		// Falcon...  Mode stored in lower 16 bits of mode.  Bit 16 set.
		mode=FALC_MODE|Vsetmode(-1);
	break; default:
		mode=NO_MODE;
	}
}

Resolution::Resolution(int width, int height, int depth) :
	w(width),h(height),d(depth),
	mode(ModeFor(w,h,d))
{
	EnsureRestoration;
}



bool Resolution::Usable() const
{
	return mode!=NO_MODE;
}

void Resolution::Use() const
{
	SetMode(mode);
}


unsigned int Resolution::NumberOfColours() const
{
	static unsigned int Lookup[17]={1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,32768,65536};
	if (d<=16) return Lookup[d];

	unsigned int r=65536*2;
	unsigned int td=d-17;
	while (td--) r=r*2;

	return r;
}

long Resolution::Size() const
{
	if (mode&FALC_MODE) {
		return VgetSize(mode^FALC_MODE);
	} else {
		return w*h*d/8;
	}
}

const Resolution STLow(320,200,4);
const Resolution STMedium(640,200,2);
const Resolution STHigh(640,400,1);

const Resolution TTLow(320,480,8);
const Resolution TTMedium(640,480,4);
const Resolution TTHigh(1280,960,1);

// const Resolution MaximumResolution;  How to implement?


