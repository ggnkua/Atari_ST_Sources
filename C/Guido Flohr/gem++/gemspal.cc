#include "gemspal.h"
#include "vdi++.h"

GEMsimplepalette::GEMsimplepalette(const int sz, VDI& vdi) :
	size (sz),
	nextfree (0),
	map (new RGBMap[sz]),
	device (vdi)
{
	for (int i=0; i<size; i++) {
		map[i].vdiindex=-1;
	}
}

GEMsimplepalette::~GEMsimplepalette ()
{
	delete map;
}

int GEMsimplepalette::GetFreeIndex () const
{
	// Slow

	int numcols = device.NumberOfPredefinedColors();

	for (int vdiindex = numcols-1; vdiindex >= 0; vdiindex--) {
	  int i;
		for (i = 0; i < nextfree && map[i].vdiindex != vdiindex; i++)
			;
		if (i == nextfree) {
			// Not used yet
			return vdiindex;
		}
	}

	// None left.  Return any.
	return numcols-1;
}

void GEMsimplepalette::SetColor (int vdiindex, VDIRGB& RGB)
{
  int i;
  
	for (i = 0; i < nextfree && map[i].vdiindex != vdiindex; i++)
		;

	if (i == nextfree) {
		if (nextfree == size) return;
		map[nextfree++].vdiindex = vdiindex;
	}

	Set (i,RGB);
}

void GEMsimplepalette::SetRGB(int index, int& vdiindex, const VDIRGB& RGB)
{
	map[index].rgb=RGB;
	vdiindex=map[index].vdiindex;
}

void GEMsimplepalette::GetRGB(int index, int& vdiindex, VDIRGB& RGB) const
{
	RGB=map[index].rgb;
	vdiindex=map[index].vdiindex;
}

int GEMsimplepalette::PaletteSize() const
{
	return nextfree;
}

VDI& GEMsimplepalette::Device() const
{
	return device;
}
