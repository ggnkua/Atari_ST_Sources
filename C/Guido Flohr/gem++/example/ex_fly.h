#ifndef ex_fly_h
#define ex_fly_h

#include <gemf.h>

//
// Demonstrates flying dialog boxes.
//
class GEMflyform : public GEMform {
public:
	GEMflyform(const GEMrsc& rsc, int RSCindexform, int RSCindexknob=0, bool opaq=false);

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);
	void Opaque(bool opaq=true);

private:
	bool opaque;
	int knob;
};

class Flying : public GEMflyform {
public:
	Flying(const GEMrsc& rsc);

protected:
	virtual GEMfeedback DoItem(int item, const GEMevent& e);
};

#endif
