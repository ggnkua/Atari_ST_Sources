#ifndef gemrubo_h
#define gemrubo_h

#include <gemo.h>

class GEMrubberobject : public GEMobject {
public:
	GEMrubberobject(GEMform& form, int RSCindex);

	// Change size & component positions so as to be larger than
	// non-hidden components by the given margin on all four sides.
	void Fit(int margin);

	// Change size & component positions so as to be larger than
	// non-hidden components by the given margins.
	void Fit(int tmargin, int bmargin, int lmargin, int rmargin);
};

#endif
