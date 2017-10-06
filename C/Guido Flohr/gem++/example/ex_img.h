#ifndef ex_img_h
#define ex_img_h

#include <gemvb.h>
#include <gemfiw.h>
#include <gemro.h>
#include <gemfs.h>
#include <vdi.h>

//
// Demonstrates the IMG class.
//
class MicroDraw : public GEMformiconwindow {
public:
	MicroDraw(GEMactivity& in, const GEMrsc& rsc);

	virtual GEMfeedback DoItem(int item, const GEMevent& e);

	void SetColour(int c);

	void Load();
	void Save();

private:
	GEMrasterobject drawbox;
	int colour;
	VDI vdi;
	GEMvdibox col0;
	GEMvdibox col1;
	GEMvdibox col2;
	GEMvdibox col3;
	GEMvdibox col4;
	GEMvdibox col5;
	GEMfileselector file;
};

#endif
