#include "ex_fly.h"
#include <example.h>

//
// Demonstrates flying dialog boxes.
//
GEMflyform::GEMflyform(const GEMrsc& rsc, int RSCindexform, int RSCindexknob=0, bool opaq=false) :
	GEMform(rsc,RSCindexform),
	opaque(opaq),
	knob(RSCindexknob)
{
}

GEMfeedback GEMflyform::DoItem(int item, const GEMevent& e)
{
	if (item==knob) {
		Fly(opaque);
		return ContinueInteraction;
	}

	return GEMform::DoItem(item,e);
}

void GEMflyform::Opaque(bool opaq=true)
{
	opaque=opaq;
}

Flying::Flying(const GEMrsc& rsc) :
	GEMflyform(rsc,FLYING,FLYKNOB)
{
	Opaque(Object(OPAQUE).Selected());
}

GEMfeedback Flying::DoItem(int item, const GEMevent& e)
{
	if (item==OPAQUE) {
		Opaque(Object(OPAQUE).Selected());
		return ContinueInteraction;
	}

	return GEMflyform::DoItem(item,e);
}
