#ifndef simpal_h
#define simpal_h

#include <gempal.h>
#include <yd.h>

class GEMsimplepalette : public GEMpalette {
public:
	GEMsimplepalette(const int sz, VDI& vdi);
	~GEMsimplepalette();

	int GetFreeIndex() const;

	void SetColor(int vdiindex, VDIRGB& RGB);

protected:
	virtual void SetRGB(int index, int& vdiindex, const VDIRGB& RGB);
	virtual void GetRGB(int index, int& vdiindex, VDIRGB& RGB) const;
	virtual int PaletteSize() const;
	virtual VDI& Device() const;

private:
	class RGBMap {
	public:
		int vdiindex;
		VDIRGB rgb;
	};

	int size;
	int nextfree;
	RGBMap* map;
	VDI& device;
};

#endif
