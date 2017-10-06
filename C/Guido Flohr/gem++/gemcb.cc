/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1994 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemcb.h"
#include "gemdir.h"
#include <osbind.h>
#include <string.h>
#include <aesbind.h>

extern "C" void exit(int);

const int MAXFILELENGTH=128;

GEMclipboard::GEMclipboard() :
	filename(new char[MAXFILELENGTH])
{
}

GEMclipboard::~GEMclipboard()
{
	delete filename;
}

static
void GetClipPath(char* path)
{
	bool rubbish=false;

	if (!scrp_read(path)) {
		rubbish=true;
	} else {
		// We didn't make this path, so we must check it is valid.
		int i=strlen(path);
		if (path[i-1]!='\\') {
			// No trailing backslash!  Is that a file?
			GEMdir hope_not(path);
			if (hope_not.Found()) {
				// Gad!  This application is surrounded by fools!
				while (i>0 && path[--i]!='\\')
					;
				if (path[i]!='\\') {
					// It's RUBBISH!
					rubbish=true;
				} else {
					// Truncate it there.
					path[i+1]=0;
				}
			}
		}

		// And make sure it exists (ignore errors - may already exist)
		(void) Dcreate (path);
	}

	if (rubbish) {
		// Looks like we have to do it ourselves.
		strcpy(path,"C:\\CLIPBRD");
		if (0!=Dcreate(path)) {
			strcpy(path,"D:\\CLIPBRD");
			if (0!=Dcreate(path)) {
				strcpy(path,"A:\\CLIPBRD");
				if (0!=Dcreate(path)) {
					// Give up.
					Cconws("Cannot create CLIPBRD directory or C, D, or A drives\r\n");
					exit(1);
				}
			}
		}
		strcat(path,"\\");

		scrp_write(path);
	}

	// Ah, at last, the universe is pure again.
	// At this point, path is correct.
}

void GEMclipboard::Clear()
{
	GetClipPath(filename);
	strcat(filename,"SCRAP.*");
	for (GEMdir all(filename); all.Found(); all.Next()) {
		(void) Fdelete (all.File());
	}
}

const char* GEMclipboard::FilenameToWrite(const char* extension)
{
	GetClipPath(filename);
	strcat(filename,"SCRAP.");
	strcat(filename,extension);
	return filename;
}

const char* GEMclipboard::FilenameToRead(const char* extension)
{
	GetClipPath(filename);
	strcat(filename,"SCRAP.");
	strcat(filename,extension);
	GEMdir one(filename);
	if (one.Found()) {
		return filename;
	} else {
		return 0;
	}
}

