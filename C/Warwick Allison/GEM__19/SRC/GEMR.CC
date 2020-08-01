/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemr.h"
#include "rsc_fix.h"
#include "rsc_gobj.h"
#include <aesbind.h>
#include <stdio.h>
#include <stdlib.h> // For getenv()
#include <support.h> // For findfile()

GEMrsc::GEMrsc(const char *filename)
{
	if (rsrc_load((char*)filename)>0) { // XXX - rsrc_load() should take const
		ok=TRUE;
	} else {
		ok=FALSE;
	}
	header=0;
}

GEMrsc::GEMrsc(const char *filename, int rscw, int rsch)
// Reimplementation of rsrc_load(filename)
{
	// XXX - should search on $PATH XXX  Or $RSC first maybe?
	FILE* fd=fopen(filename,"rb");

	if (!fd) {
		char* path=getenv("RSCPATH"); // My idea.  I think $PATH is a STUPID place.
		if (!path) path=getenv("PATH");
		if (path) {
			char* ext[]={"rsc","RSC",0};
			char* name=findfile((char*)filename,path,ext); // XXX - findfile() should take const
			if (name) {
				fd=fopen(name,"rb");
			}
		}
	}

	ok=FALSE;

	if (fd) {
		header=new RSHDR;
		if (fread(header,sizeof(RSHDR),1,fd)==1) {
			int size=header->rsh_rssize-sizeof(RSHDR);
			data=new char[size];
			if (fread(data,1,size,fd)==size) {
				rsc_fix(header,long(data)-sizeof(RSHDR),rscw,rsch);
				ok=TRUE;
			} else {
				delete header;
				delete data;
			}
		} else {
			delete header;
		};
		fclose(fd);
	}
}

GEMrsc::~GEMrsc()
{
	if (ok) {
		if (header) {
			delete header;
			delete data;
		} else {
			rsrc_free();
		}
	}
}

GEMrawobject* GEMrsc::Tree(int RSCindex) const
{
	if (!ok) return 0;

	GEMrawobject* result=0;

	if (header)
		result=(GEMrawobject*)rsc_gobj(header,(long)data-sizeof(RSHDR),R_TREE,RSCindex);
	else
		if (!rsrc_gaddr(R_TREE,RSCindex,&result)) result=0;

	return result;
}

char* GEMrsc::String(int RSCindex) const
{
	if (!ok) return 0;

	char* result=0;

	if (header)
		result = (char*)rsc_gobj(header,(long)data-sizeof(RSHDR),R_STRING,RSCindex);
	else
		if (!rsrc_gaddr(R_STRING,RSCindex,&result)) result=0;

	return result;
}
