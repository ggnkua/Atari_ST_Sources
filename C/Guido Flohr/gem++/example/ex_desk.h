#ifndef ex_desk_h
#define ex_desk_h

#include "ex_fsel.h"
#include <gemd.h>

//
// Demonstrates GEMdesktop
//
class Desktop : public GEMdesktop {
public:
	Desktop(GEMactivity& in, const GEMrsc& rsc);

private:
	GEMobject display;
	FileChooser files;
};

#endif
