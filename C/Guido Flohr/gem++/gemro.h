#ifndef gem_ro_h
#define gem_ro_h

#include <gemvo.h>
#include <img.h>

class GEMrasterobject : public GEMvdiobject, public IMG {
public:
	// Device form IMG with dimensions of object.
	GEMrasterobject(GEMform& form, int RSCindex);

	// Device form IMG with dimensions given.
	GEMrasterobject(GEMform& form, int RSCindex, int pixel_width, int pixel_height);

	// From file with dimensions of image.
	GEMrasterobject(GEMform& form, int RSCindex, const char* filename);

	// Standard form IMG with dimensions given.
	GEMrasterobject(GEMform& form, int RSCindex, int pixel_width, int pixel_height, int depth);

protected:
	virtual int Draw(int x, int y);

private:
	IMG screen;
};

#endif
