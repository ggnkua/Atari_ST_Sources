#ifndef ex_fsel_h
#define ex_fsel_h

#include <gemo.h>
#include <gemfs.h>

//
// Demonstrates GEMfileselector
//
class FileChooser : public GEMobject, public GEMfileselector {
public:
	FileChooser(GEMform& f, int RSCibutn, GEMobject& disp, char* prmpt);

	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);

private:
	GEMobject& display;
	char* prompt;
};

#endif
