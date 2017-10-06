#include "ex_desk.h"
#include <example.h>

#include <gemr.h>
//
// Demonstrates GEMdesktop
//
Desktop::Desktop(GEMactivity& in, const GEMrsc& rsc) :
	GEMdesktop(in,rsc,DESKTOP),
	display(*this,FILEDISPLAY),
	files(*this,FILES,display,rsc.String(FILEPROMPT))
{
}
