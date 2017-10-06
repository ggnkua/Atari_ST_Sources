#include "gemrubo.h"
#include <minmax.h>
#include <limits.h>

GEMrubberobject::GEMrubberobject(GEMform& form, int RSCindex) :
	GEMobject(form,RSCindex)
{
}

void GEMrubberobject::Fit(int margin)
{
	Fit(margin,margin,margin,margin);
}

void GEMrubberobject::Fit(int tmargin, int bmargin, int lmargin, int rmargin)
{
	// Change size & component positions so as to be larger than
	// components by the given margin on all four sides.
	int minx = INT_MAX;
	int maxx = INT_MIN;
	int miny = INT_MAX;
	int maxy = INT_MIN;

	int i;

	for (i=FirstChild(); i>=0; i=NextChild(i)) {
		if (!Child(i)->HideTree()) {
			int x1=Child(i)->X();
			int y1=Child(i)->Y();
			int x2=x1+Child(i)->Width()-1;
			int y2=y1+Child(i)->Height()-1;

			minx=min(minx,x1);
			miny=min(miny,y1);
			maxx=max(maxx,x2);
			maxy=max(maxy,y2);
		}
	}

	if (minx == INT_MIN) {
		// No unhidden children
		Resize(lmargin+rmargin,tmargin+bmargin);
	} else {
		Resize(maxx-minx+1+lmargin+rmargin,maxy-miny+1+tmargin+bmargin);

		if (lmargin-minx || tmargin-miny) {
			MoveTo(X()+minx-lmargin,Y()+miny-tmargin);
			for (i=FirstChild(); i>=0; i=NextChild(i)) {
				if (!Child(i)->HideTree()) {
					Child(i)->MoveBy(lmargin-minx,tmargin-miny);
				}
			}
		}
	}
}
