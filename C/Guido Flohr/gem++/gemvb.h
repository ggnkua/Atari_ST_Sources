#ifndef gemvb_h
#define gemvb_h

#include <gemvo.h>

class GEMvdibox : public GEMvdiobject {
public:
	GEMvdibox(GEMform& form, int RSCindex, class VDI& vdi);

	void Color(int col);

	int Color() const;

private:
	virtual int Draw(int x, int y);

	int color;
};

#endif
