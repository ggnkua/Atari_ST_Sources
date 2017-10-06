#include "gemro.h"
#include "vdi++.h"
#include "vdidef.h"

GEMrasterobject::GEMrasterobject(GEMform& form, int RSCindex, const char* filename) :
	GEMvdiobject(form,RSCindex,DefaultVDI()),
	IMG(filename),
	screen(DefaultVDI())
{
	GEMvdiobject::Resize(IMG::Width(),IMG::Height());
	TranslateTo(false);
	ClearCache();
}

GEMrasterobject::GEMrasterobject(GEMform& form, int RSCindex, int pixel_width, int pixel_height, int depth) :
	GEMvdiobject(form,RSCindex,DefaultVDI()),
	IMG(pixel_width,pixel_height,depth),
	screen(DefaultVDI())
{
	GEMvdiobject::Resize(IMG::Width(),IMG::Height());

	// Leave in std form
	//TranslateTo(false);
	//ClearCache();
}

GEMrasterobject::GEMrasterobject(GEMform& form, int RSCindex, int pixel_width, int pixel_height) :
	GEMvdiobject(form,RSCindex,DefaultVDI()),
	IMG(pixel_width,pixel_height),
	screen(DefaultVDI())
{
	GEMvdiobject::Resize(IMG::Width(),IMG::Height());
}

GEMrasterobject::GEMrasterobject(GEMform& form, int RSCindex) :
	GEMvdiobject(form,RSCindex,DefaultVDI()),
	IMG(GEMvdiobject::Width(),GEMvdiobject::Height()),
	screen(DefaultVDI())
{
}

int GEMrasterobject::Draw(int x, int y)
{
	screen.Copy(*this,x,y);
	return States();
}
