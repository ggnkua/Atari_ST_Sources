#include "vdi.h"
#include "gemfn.h"
#include "gemfl.h"
#include <vdibind.h>

static const int ARBSIZE=0x80;

GEMfont::GEMfont(VDI& v, int cde, int sz) :
	vdi(v),
	code(cde),
	size(sz),
	flags(0)
{
	GEMfontlist list(vdi);
	if (list.ArbitrarilySizable(list.IndexOfFontCoded(code))) {
		flags|=ARBSIZE;
	} else {
		flags&=~ARBSIZE;
	}
}

GEMfont::GEMfont(VDI& v, const GEMfont& font) :
	vdi(v),
	code(font.code),
	size(font.size),
	flags(font.flags)
{
}

GEMfont::GEMfont(VDI& v) :
	vdi(v)
{
	int attrib[10];

	vdi.qt_attributes(attrib);

	code=attrib[0];
	size=attrib[7];
}

int GEMfont::Code() const
{
	return code;
}

void GEMfont::Code(int i)
{
	code=i;
	GEMfontlist list(vdi);
	if (list.ArbitrarilySizable(list.IndexOfFontCoded(code))) {
		flags|=ARBSIZE;
	} else {
		flags&=~ARBSIZE;
	}
}

char* GEMfont::Name() const
{
	GEMfontlist list(vdi);
	return list.FontName(list.IndexOfFontCoded(code));
}

int GEMfont::PointSize() const
{
	return size;
}

void GEMfont::PointSize(int sz)
{
	size=sz;
}

bool GEMfont::ArbitrarilySizable() const
{
	return (flags&ARBSIZE)!=0;
}

bool GEMfont::Larger()
{
	GEMfont originalfont(vdi);

	int prevsize=size;
	int trysize=size+1;

	while (prevsize==size && trysize<=size*4) {
		int j;
		size=vdi.st_point(trysize,&j,&j,&j,&j);
		trysize++;
	}

	originalfont.Use();

	return prevsize!=size;
}

bool GEMfont::Smaller()
{
	GEMfont originalfont(vdi);

	int prevsize=size;
	int trysize=size-1;

	while (prevsize==size && trysize>0) {
		int j;
		size=vdi.st_point(trysize,&j,&j,&j,&j);
		trysize--;
	}

	originalfont.Use();

	return prevsize!=size;
}

void GEMfont::Use() const
{
	vdi.st_font(code);

	// XXX At present, this information is not retained.
	int actualheight;
	int cw,ch,bw,bh;

	if (ArbitrarilySizable()) {
		actualheight=vdi.st_arbpt(size,&cw,&ch,&bw,&bh);
	} else {
		actualheight=vdi.st_point(size,&cw,&ch,&bw,&bh);
	}
}

