/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemdir.h"
#include <osbind.h>
#include <string.h>


GEMdir::GEMdir(const char* filespec,int attribs) :
	dta(new _DTA),
	olddta(Fgetdta()),
	filename(new char[128])
{
	Fsetdta(dta);
	found = 0==Fsfirst(filespec,attribs);
	if (found) {
		strcpy(filename,filespec);
		CutBack();
		strcat(filename,dta->dta_name);
	} else {
		filename[0]=0;
	}
}

void GEMdir::CutBack()
{
	// Cut off filename part, leaving pathspec.
	//
	int i=strlen(filename);
	while (i>0 && filename[--i]!='\\')
		;
	filename[i+1]=0;
}

GEMdir::~GEMdir()
{
	Fsetdta(olddta);
	delete dta;
}

bool GEMdir::Found() const
{
	return found;
}

const char* GEMdir::File() const
{
	return found ? filename : 0;
}

void GEMdir::Next()
{
	found = 0==Fsnext();
	if (found) {
		CutBack();
		strcat(filename,dta->dta_name);
	} else {
		filename[0]=0;
	}
}

bool GEMdir::FileIsReadOnly() const
{
	return !!(dta->dta_attribute&FA_RDONLY);
}

bool GEMdir::FileIsHidden() const
{
	return !!(dta->dta_attribute&FA_HIDDEN);
}

bool GEMdir::FileIsSystem() const
{
	return !!(dta->dta_attribute&FA_SYSTEM);
}

bool GEMdir::FileIsLabel() const
{
	return !!(dta->dta_attribute&FA_LABEL);
}

bool GEMdir::FileIsDir() const
{
	return !!(dta->dta_attribute&FA_DIR);
}

bool GEMdir::FileIsChanged() const
{
	return !!(dta->dta_attribute&FA_CHANGED);
}

