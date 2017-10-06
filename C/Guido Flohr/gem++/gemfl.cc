#include "vdi++.h"
#include "gemfl.h"
#include <vdibind.h>
#include <string.h>

static const int ARBSIZE=0x80;

GEMfontlist::GEMfontlist(VDI& v) :
	vdi(v),
	numfonts(vdi.NumberOfTextFaces()),
	name(new char*[numfonts]),
	code(new int[numfonts]),
	arb(new bool[numfonts])
{
	for (int i=0; i<numfonts; i++) {
		name[i]=new char[33];
		code[i]=vdi.qt_name(i+1,name[i]);
		arb[i]=name[i][32]==1;
		if (arb[i]) name[i][32]=0;
	}
}

GEMfontlist::~GEMfontlist()
{
	for (int i=0; i<numfonts; i++) {
		delete name[i];
	}
	delete name;
	delete code;
	delete arb;
}

int GEMfontlist::NumberOfFonts() const
{
	return numfonts;
}

char* GEMfontlist::FontName(int index) const
{
	return name[index];
}

int GEMfontlist::FontCode(int index) const
{
	return code[index];
}

bool GEMfontlist::ArbitrarilySizable(int index) const
{
	return arb[index];
}

int GEMfontlist::IndexOfFontCoded(int cde) const
{
	for (int i=0; i<numfonts; i++) {
		if (code[i]==cde) {
			return i;
		}
	}
	return -1;
}

int GEMfontlist::CodeOfFontNamed(char* fname) const
{
	for (int i=0; i<numfonts; i++) {
		if (strcmp(fname,name[i])==0) {
			return code[i];
		}
	}
	return -1;
}

GEMfont GEMfontlist::Font(int index) const
{
	return GEMfont(vdi,FontCode(index),12);
}
