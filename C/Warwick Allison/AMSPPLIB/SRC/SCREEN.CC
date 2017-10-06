//////////////////////////////////////////////////////////////////////////////
//
//  This file is part of the Atari Machine Specific Library,
//  and is Copyright 1992 by Warwick W. Allison.
//
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.
//
//////////////////////////////////////////////////////////////////////////////

#include "Screen.h"
#include "Resolution.h"
#include "ca_pack.h"
#include "ca_unpac.h"
#include <stdio.h>
#include <osbind.h>
#include <alloc.h>
#include <builtin.h>
#include <dirent.h>
#include <fnameext.h>

// TERMINATION code:

// used to ensure MyDisplayRestorer is linked in if possibly necessary
#define EnsureRestoration MyDisplayRestorerPtr=&MyDisplayRestorer


class DisplayRestorer
{
public:
	DisplayRestorer() {
		InitialPhysbase=(char*)Physbase();
		InitialLogbase=(char*)Logbase();
		for (int c=0; c<16; c++) InitialPalette[c]=Setcolor(c,-1);
	}
	~DisplayRestorer() {
		for (int c=0; c<16; c++) Setcolor(c,InitialPalette[c]);
		Setscreen(InitialLogbase,InitialPhysbase,-1);
	}

private:
	char* InitialPhysbase;
	char* InitialLogbase;
	int InitialPalette[16];
};

static DisplayRestorer MyDisplayRestorer;
static DisplayRestorer* MyDisplayRestorerPtr;



static char *Page(char *adr)
{
	unsigned long a=(unsigned long)adr;
	return (char *)((a+0xfe) & 0xffffff00);
}

static char* AllocScreenRAM(long size)
{
	long ret=Mxalloc(size,0); // Ask for ST RAM

	// Did GEMDOS understand that call?  If not, use Malloc instead.
	// (ie. assume it is an old ST without the notion of FastRAM)
	if (ret==-32)
		ret=Malloc(size);

	return (char*)ret;
}

static void FreeScreenRAM(char* adr)
{
	Mfree(adr);
}

Screen::Screen(const char* filename) :
	location(0),
	AllocArea(0),
	Palette(0)
{
	EnsureRestoration;
	if (!Load(filename)) {
		FreeScreenRAM(AllocArea);
		delete Palette;
		location=0;
		AllocArea=0;
	}
}

Screen::Screen(const Screen& Same) :
	Res(Same.Res),
	AllocSize(Res.BytesPerLine()*Res.Height()+0x100),
	AllocArea(AllocScreenRAM(AllocSize)),
	location(Page(AllocArea)),
	Palette(new short[Res.NumberOfColours()])
{
	EnsureRestoration;
	memcpy(location,Same.location,Res.BytesPerLine()*Res.Height());
	memcpy(Palette,Same.Palette,sizeof(Palette[0])*Res.NumberOfColours());
}

Screen::Screen(Resolution res) :
	Res(res),
	AllocSize(Res.BytesPerLine()*Res.Height()+0x100),
	AllocArea(AllocScreenRAM(AllocSize)),
	location(Page(AllocArea)),
	Palette(new short[Res.NumberOfColours()])
{
	EnsureRestoration;
}

Screen::Screen(short LinesAbove, short LinesBelow) :
	Res(),
	AllocSize(Res.BytesPerLine()*(Res.Height()+LinesAbove+LinesBelow)+0x100),
	AllocArea(AllocScreenRAM(AllocSize)),
	location(Page(AllocArea)),
	Palette(new short[Res.NumberOfColours()])
{
	EnsureRestoration;
}

Screen::Screen() :
	Res(),
	AllocSize(Res.BytesPerLine()*Res.Height()+0x100),
	AllocArea(AllocScreenRAM(AllocSize)),
	location(Page(AllocArea)),
	Palette(new short[Res.NumberOfColours()])
{
	EnsureRestoration;
}

Screen::Screen(long *At) :
	Res()
{
	EnsureRestoration;

	AllocSize=0;
	AllocArea=0;
	if (At) {
		location=(char*)At;
	} else {
		location=(char*)Physbase();
	}
	Palette=new short[Res.NumberOfColours()];
	for (int i=0; i<Res.NumberOfColours(); i++) {
		Palette[i]=Setcolor(i,-1);
	}
}

Screen::Screen(Resolution res, short LinesAbove, short LinesBelow) :
	Res()
{
	EnsureRestoration;

	short BPL=res.BytesPerLine();
	int BaseSize=BPL*res.Height()+0x100;

	AllocSize=BaseSize+(LinesAbove+LinesBelow)*BPL;
	AllocArea=AllocScreenRAM(AllocSize),
	location=Page(AllocArea+BPL*LinesAbove);
	Palette=new short[res.NumberOfColours()];
	Res=res;
}

Screen::~Screen()
{
	if (AllocArea) FreeScreenRAM(AllocArea);
	delete Palette;
}


void Screen::Clear()
{
/* Clear visible region? */
	int i=Res.BytesPerLine()*Res.Height()/sizeof(long);
	long * data=(long*) location;

/* ...or clear whole area?
	int i=AllocSize/sizeof(long);
	long *data=(long *)AllocArea;
*/

	while (i--) data[i]=0;
}

#define CHECK(x) {if ((x)<=0) {fclose(file); return 0;}}

int Screen::LoadDegasPalette(const char *filename)
{
	FILE *file;
	short res;

	file=fopen(filename,"rb");
	if (!file) return 0;

	CHECK(fread(&res,sizeof(res),1,file));
	Resolution NewRes(res);
	CHECK(fread(Palette,sizeof(short),Res.NumberOfColours(),file));

	fclose(file);

	return 1;
}

int Screen::LoadDegas(const char *filename)
{
	FILE *file;
	short res;
	short junk;

	file=fopen(filename,"rb");
	if (!file) return 0;

	CHECK(fread(&res,sizeof(res),1,file));
	Resolution NewRes(res);

	if (!Palette || NewRes.NumberOfColours()!=Res.NumberOfColours()) {
		if (Palette) delete Palette;
		Palette=new short[NewRes.NumberOfColours()];
	}

	Res=NewRes;

	CHECK(fread(Palette,sizeof(short),Res.NumberOfColours(),file));
	for (int ignore=16-Res.NumberOfColours(); ignore>0; ignore--)
		CHECK(fread(&junk,sizeof(short),1,file));

	if (!location || AllocSize < Res.BytesPerLine()*Res.Height()+0x100) {
		if (AllocArea) FreeScreenRAM(AllocArea);
		AllocSize=Res.BytesPerLine()*Res.Height()+0x100;
		AllocArea=AllocScreenRAM(AllocSize);
		location=Page(AllocArea);
	}

	CHECK(fread(location,1,Res.BytesPerLine()*Res.Height(),file));

	fclose(file);

	return 1;
}

int Screen::SaveDegas(const char *filename)
{
	FILE *file;
	short res;

	file=fopen(filename,"wb");
	if (!file) return 0;

	res=Res.OldMode();
	CHECK(fwrite(&res,sizeof(short),1,file));
	CHECK(fwrite(Palette,sizeof(short),Res.NumberOfColours(),file));
	if (Res.NumberOfColours() < 16) {
		short junk=0;
		for (int ignore=16-Res.NumberOfColours(); ignore; ignore--)
			CHECK(fwrite(&junk,sizeof(short),1,file));
	}

	CHECK(fwrite(location,1,Res.BytesPerLine()*Res.Height(),file));
	fclose(file);

	return 1;
}


PaletteChange::PaletteChange() :
	ncols(16),
	col(new short[ncols])
{
	for (int i=0; i<ncols; i++) {
		col[i]=Setcolor(i,-1);
	}
}

PaletteChange::~PaletteChange()
{
	Setpalette(col);

	delete col;
}

/////////////////////////////////////////////////
//                                             //
//  CrackArt I/O as per GFA basic code:        //
//                                             //
//    CRACK ART 'CA_PACK'                      //
//                                             //
//    Kompressionsroutine fr CA?-Bilder       //
//                                             //
//    ½ Detlef R”ttger & Jan Borchers 1989-91  //
//                                             //
/////////////////////////////////////////////////

int Screen::LoadCrackArtPalette(const char *Filename)
{
	FILE* fp=fopen(Filename,"rb");

	if (!fp) return 0;

	char Magic[2];
	fread(Magic,sizeof(char),2,fp);
	if (Magic[0]!='C' || Magic[1]!='A') {
		fclose(fp);
		return 0;
	}

	short res;
	fread(&res,sizeof(short),1,fp);
	Resolution NewRes(res&255);

	if (NewRes.NumberOfColours()!=Res.NumberOfColours()) {
		return 0;
	}

	// NB. CrackArt file format is WRONG for CA3 - it doesn't save a palette
	//     this is very wrong - especially on the TT.  So we can't load one.
	if (Res==STHigh) {
		Palette[0]=0x777;
		Palette[1]=0x000;
	} else {
		fread(Palette,sizeof(short),Res.NumberOfColours(),fp);
	}

	fclose(fp);

	return 1;
}

int Screen::LoadCrackArt(const char *Filename)
{
	FILE* fp=fopen(Filename,"rb");

	if (!fp) return 0;

	char Magic[2];
	fread(Magic,sizeof(char),2,fp);
	if (Magic[0]!='C' || Magic[1]!='A') {
		fclose(fp);
		return 0;
	}

	short res;
	fread(&res,sizeof(short),1,fp);
	Resolution NewRes(res&255);

	if (!Palette || NewRes.NumberOfColours()!=Res.NumberOfColours()) {
		if (Palette) delete Palette;
		Palette=new short[NewRes.NumberOfColours()];
	}

	// NB. CrackArt file format is WRONG for CA3 - it doesn't save a palette
	//     this is very wrong - especially on the TT.  We could load one,
	//     expecting CrackArt to correct the problem, if they ever support
	//     mono rez, but then we couldn't load them!  Perhaps we could add a
	//     hack to set a bit in the reserved byte after Rez, but it's not
	//     our format!  Now the question is, do we make CrackArt's mistake
	//     again and not support a palette in TTHigh?  No.
	if (NewRes==STHigh) {
		Palette[0]=0x777;
		Palette[1]=0x000;
	} else {
		fread(Palette,sizeof(short),NewRes.NumberOfColours(),fp);
	}

	Res=NewRes;

	if (!location || AllocSize < Res.BytesPerLine()*Res.Height()+0x100) {
		if (AllocArea) FreeScreenRAM(AllocArea);
		AllocSize=Res.BytesPerLine()*Res.Height()+0x100;
		AllocArea=AllocScreenRAM(AllocSize);
		location=Page(AllocArea);
	}

	LoadCrackArtData((unsigned char*)location,Res.BytesPerLine()*Res.Height(),fp);

	fclose(fp);

	return 1;
}


int Screen::SaveCrackArt(const char *Filename, int Compression=3)
{
	FILE* fp=fopen(Filename,"wb");

	if (!fp) return 0;

	fwrite("CA",sizeof(char),2,fp);

	short res=256+Res.OldMode();
	fwrite(&res,sizeof(short),1,fp);

	// NB. CrackArt file format is WRONG for CA3 - it doesn't save a palette
	//     this is very wrong - especially on the TT.  So we don't save one.
	if (Res!=STHigh) fwrite(Palette,sizeof(short),Res.NumberOfColours(),fp);

	SaveCrackArtData((unsigned char*)location,Res.BytesPerLine()*Res.Height(),fp,Compression);

	fclose(fp);

	return 1;
}

int DegasExtension(char *ext)
{
	return (ext[0]=='p' && ext[1]=='i' && ext[2]>='1' && ext[2]<='8');
}

int CrackArtExtension(char *ext)
{
	return (ext[0]=='c' && ext[1]=='a' && ext[2]>='1' && ext[2]<='8');
}

enum FileType { Unknown,Degas,CrackArt };

FileType FindAppropriateFile(const char* filename, char* appropriate)
{
	char ext[strlen(filename)+1];
	extension(ext,filename);

	if (!ext[0]) {
		FileType Type=Unknown;

		char dir[strlen(filename)+1];
		char name[strlen(filename)+1];

		basename(name,filename);
		noextension(name,name);

		strlwr(dir);
		strlwr(name);

		directory(dir,filename);
		DIR* D=opendir(dir);

		dirent* entry;

		int found=0;
		int result;

		while (!found && (entry=readdir(D))) {
			char base[strlen(entry->d_name)+1];
			char ext[strlen(entry->d_name)+1];

			noextension(base,entry->d_name);
			extension(ext,entry->d_name);

			strlwr(base);
			strlwr(ext);

			if (0==strcmp(base,name)) {
				found=1; // Yes... maybe.
				if (DegasExtension(ext)) {
					strcpy(appropriate,dir);
					strcat(appropriate,entry->d_name);
					Type=Degas;
				} else if (CrackArtExtension(ext)) {
					strcpy(appropriate,dir);
					strcat(appropriate,entry->d_name);
					Type=CrackArt;
				} else {
					found=0; // Oh, no it wasn't.
				}
			}
		}

		closedir(D);

		return Type;
	} else {
		strlwr(ext);
		if (DegasExtension(ext)) {
			strcpy(appropriate,filename);
			return Degas;
		} else if (CrackArtExtension(ext)) {
			strcpy(appropriate,filename);
			return CrackArt;
		}
	}
	return Unknown;
}

int Screen::Load(const char* filename)
{
	char RealName[strlen(filename)+10];
	switch (FindAppropriateFile(filename,RealName)) {
	 case Degas:
		return LoadDegas(RealName);
	break; case CrackArt:
		return LoadCrackArt(RealName);
	break; default:
		return 0;
	}
}

int Screen::LoadPalette(const char* filename)
{
	char RealName[strlen(filename)+10];
	switch (FindAppropriateFile(filename,RealName)) {
	 case Degas:
		return LoadDegasPalette(RealName);
	break; case CrackArt:
		return LoadCrackArtPalette(RealName);
	break; default:
		return 0;
	}
}

int Screen::Save(const char* filename)
{
	char ext[strlen(filename)+1];
	extension(ext,filename);
	strlwr(ext);

	if (DegasExtension(ext)) {
		return SaveDegas(filename);
	} else if (CrackArtExtension(ext)) {
		return SaveCrackArt(filename);
	} else {
		return 0;
	}
}


void Screen::operator= (Screen& orig)
{
	if (orig.Res==Res) {
		int i=Res.BytesPerLine()*Res.Height()/sizeof(long);
		long* to=(long*) location;
		long* from=(long*) orig.location;

		while (i--) to[i]=from[i];
	}
}

// This is needed because my copy of GNU.OLB leaves DIRENTSIZ undefined!
int DIRENTSIZ(int x)
{
	return __DIRENTSIZ(x);
}
