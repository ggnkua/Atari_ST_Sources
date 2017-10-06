#include "gempal.h"
#include "vdidef.h"
#include "vdi++.h"

GEMpalette* GEMpalette::current=0;

GEMpalette::GEMpalette()
{
}

GEMpalette::~GEMpalette()
{
	if (current==this)
		current=0;
}


void GEMpalette::Show()
{
	if (current!=this) {
		current=this;
		ShowCurrent();
	}
}

void GEMpalette::ShowCurrent()
{
	if (current) {
		int i=current->PaletteSize();
		while (i--) {
			int vdiindex=0;
			VDIRGB vdirgb;
			current->GetRGB(i,vdiindex,vdirgb);
			int RGB[3]={vdirgb.Red(),vdirgb.Green(),vdirgb.Blue()};
			current->Device().s_color(vdiindex,RGB);
		}
	}
}

void GEMpalette::Set(int index, const VDIRGB& rgb)
{
	int vdiindex=0;
	SetRGB(index,vdiindex,rgb);
	if (this==current) {
		int RGB[3]={rgb.Red(),rgb.Green(),rgb.Blue()};
		Device().s_color(vdiindex,RGB);
	}
}

void GEMpalette::Get(int index, VDIRGB& rgb) const
{
	int vdiindex=0;
	GetRGB(index,vdiindex,rgb);
}

VDI& GEMpalette::Device() const
{
	return DefaultVDI();
}
