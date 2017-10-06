/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gemfs.h"
#include <osbind.h>
#include <aesbind.h>
#include <mintbind.h>
#include <string.h>


static const PATHLEN=128;
static const FILELEN=32;

GEMfileselector::GEMfileselector(int maxlen) :
	filename(new char[maxlen]),
	filespec(new char[maxlen]),
	file(new char[FILELEN]),
	len(maxlen),
	mint_aware(false)
{
	CWD();
}

GEMfileselector::GEMfileselector(char* filename) :
	filename(new char[PATHLEN]),
	filespec(new char[PATHLEN]),
	file(new char[FILELEN]),
	len(PATHLEN),
	mint_aware(false)
{
	if (filename) {
		Filename(filename);
	} else {
		CWD();
	}
}

GEMfileselector::~GEMfileselector()
{
	if (len) delete filename;
	delete filespec;
	delete file;
}


const char* GEMfileselector::CWD()
{
	int drive=Dgetdrv();
	filespec[0]=drive+'A';
	filespec[1]=':';
	(void) Dgetpath (&filespec[2], drive + 1); // +1 since drv0 = current drive!
	strcat(filespec,"\\*.*");
	strcpy(file,"");
	Merge();

	return filename;
}


// Returns result both ways.  NULL if cancelled.
const char* GEMfileselector::Get(const char* pr=0, char* into=0)
{
	int okay;

#ifdef __MINT__
	int old_domain = Pdomain (-1);
	(void) Pdomain (mint_aware);
#endif

	if (pr) {
		if (fsel_exinput(filespec,file,&okay,(char*)pr) < 0)
			fsel_input(filespec,file,&okay);
	} else
		fsel_input(filespec,file,&okay);

#ifdef __MINT__
	(void) Pdomain (old_domain);
#endif

	Merge();

	if (okay) {
		if (into) strcpy(into,filename);
		return filename;
	} else {
		return 0;
	}
}

void GEMfileselector::Merge()
{
	strcpy(filename,filespec);
	int i;
	for (i=0; filename[i]; i++);
	while (i && filename[i]!='\\') i--;
	if (filename[i]=='\\') strcpy(&filename[i+1],file);
	else strcpy(filename,file);
}

void GEMfileselector::Path(const char* path)
{
	// Find '\'
	int i;
	for (i=0; path[i]; i++);
	int to=i-1;
	for (; i && path[i]!='\\'; i--);

	if (path[i]=='\\') {
		while (to && path[to]=='\\') to--; // ignore trailing '\'

    int j;
    
		for (j=0; filespec[j]; j++);
		while (j && filespec[j]!='\\') j--;
		if (j) {
			strcpy(&filespec[to+2],&filespec[j+1]);
			strncpy(filespec,path,to+1);
			filespec[to+1]='\\';
		} else {
			strncpy(filespec,path,to+1);
			strcpy(filespec+to+1,"\\*.*");
		}
	} else {
		strncpy(filespec,path,to+1);
		strcpy(filespec+to+1,"\\*.*");
	}

	Merge();
}

void GEMfileselector::File(const char* f)
{
	strcpy(file,f);
	Merge();
}

const char* GEMfileselector::File() const
{
	return file;
}

void GEMfileselector::Filespec(const char* fspec)
{
  int i;
	for (i=0; fspec[i]; i++);
	while (i && fspec[i]!='\\') i--;

	if (fspec[i]=='\\') {
		strcpy(filespec,fspec);
	} else {
	  int j;
	  
		for (j=0; filespec[j]; j++);
		while (j && filespec[j]!='\\') j--;
		if (filespec[j]=='\\') {
			strcpy(&filespec[j+1],fspec);
		} else {
			strcpy(filespec,fspec);
		}
	}
}

const char* GEMfileselector::Filespec() const
{
	return filespec;
}

void GEMfileselector::Filename(const char* fname)
// eg. Filename("foo.bar"); Filename("E:\foo\foo.bar"); oldgot=Filename();
{
  int i;
  
	for (i=0; fname[i]; i++);
	while (i && fname[i]!='\\') i--;

	if (fname[i]!='\\') {
		File(fname);
	} else {
		File(&fname[i+1]);
		strcpy(filename,fname);
		filename[i]=0;
		Path(filename);
		Merge();
	}
}

const char* GEMfileselector::Filename() const
{
	return filename;
}



