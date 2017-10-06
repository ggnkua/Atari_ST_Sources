/////////////////////////////////////////////////////////////////////////////
//
//  GEMdir
//
//  Encapsulation of GEMDOS directory access.
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef gemdir_h
#define gemdir_h

#include <bool.h>


class GEMdir {
public:
	// See <ostruct.h> for FA_* attributes.
	// Default = All files and subdirectories, but not volume labels.
	//
	GEMdir(const char* filespec, int attribs=0x37);
	~GEMdir();

	bool Found() const;

	const char* File() const;

	bool FileIsReadOnly() const;
	bool FileIsHidden() const;
	bool FileIsSystem() const;
	bool FileIsLabel() const;
	bool FileIsDir() const;
	bool FileIsChanged() const;

	void Next();

private:
	struct _dta* dta;
	struct _dta* olddta;
	bool found;
	char* filename;
	void CutBack();
};

#endif
