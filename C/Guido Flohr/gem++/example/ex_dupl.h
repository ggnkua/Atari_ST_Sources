#ifndef ex_dupl_h
#define ex_dupl_h

#include <gemfiw.h>

//
// Demonstrates a sophisticated duplicatable window with shared objects
//
class GEMringfiw : public GEMformiconwindow {
public:
	static bool OpenNew(GEMactivity& act, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& head);
	static void DeleteAll(GEMringfiw*& head);

private:
	GEMringfiw*& head;
	GEMringfiw* next;
	GEMringfiw* prev;

protected:
	virtual GEMfeedback UserClosed();

	GEMringfiw(GEMactivity& in, const GEMrsc& rsc, int RSCform, int RSCicon, GEMringfiw*& h);
	GEMringfiw(GEMringfiw& copy, GEMringfiw*& h);
	~GEMringfiw();
};

#endif
