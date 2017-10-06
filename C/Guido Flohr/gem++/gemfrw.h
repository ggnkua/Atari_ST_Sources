#ifndef gemfrw_h
#define gemfrw_h

#include <gemfw.h>

class GEMformringwindow : public GEMformwindow {
public:
	GEMformringwindow(GEMformringwindow*& ring, GEMactivity& act, GEMrsc& rsc, int RSCindex);
	GEMformringwindow(GEMformringwindow*& ring, GEMactivity& act, GEMrsc& rsc, int RSCindex, int parts);
	GEMformringwindow(GEMformringwindow*& ring);

	~GEMformringwindow();

	GEMformringwindow* Next() const;
	GEMformringwindow* Prev() const;

	const GEMformringwindow* FindWindow(GEMwindow*) const;

protected:
	GEMformringwindow*& Ring() const { return head; }

private:
	GEMformringwindow*& head;
	GEMformringwindow* next;
	GEMformringwindow* prev;
};

#endif
