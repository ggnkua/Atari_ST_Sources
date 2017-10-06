/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "img_decl.h"
#include "vdi++.h"
#include "vdidef.h"
#include <aesbind.h>

const int DEFAULT_MICRONS=85;
const bool inplace_transforms=false; // They're just TOO slow.

static
void readIMG (unsigned char* bitmap,int patlen,int bW,int unused_at_line_end,int H,int D,FILE* f);
static short int BiosToVDIscale (short int rgb) __attribute__ ((unused));

static
MFDB* CreateMFDB(bool std, int w, int h, int d, bool with_data)
{
	MFDB* result=new MFDB;
	result->fd_w=w;
	result->fd_h=h;
	result->fd_wdwidth=Wpad(w);
	result->fd_nplanes=d;
	if (with_data) {
		result->fd_addr=(long)(new unsigned short[result->fd_wdwidth*h*d]);
	} else {
		result->fd_addr=0;
	}
	result->fd_stand=std;
	result->fd_r1=0;
	result->fd_r2=0;
	result->fd_r3=0;
	return result;
}

static
void EnsureWithData(MFDB* mfdb)
{
	if (!mfdb->fd_addr) {
		mfdb->fd_addr=(long)(new unsigned short[
			mfdb->fd_wdwidth * mfdb->fd_h * mfdb->fd_nplanes
		]);
	}
}


static
void DisposeMFDB(MFDB* mfdb)
{
	if (mfdb) {
		unsigned short* data=(unsigned short*)mfdb->fd_addr;
		delete data;
		delete mfdb;
	}
}

IMG::IMG() :
	device(DefaultVDI()),
	mfdb(CreateMFDB(true,0,0,0,true)),
	altmfdb(CreateMFDB(false,0,0,device.NumberOfPlanes(),false)),
	altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(false),
	palette(0),
	bitplane_transform(0)
{
}
 
IMG::IMG(int w,int h,int d) :
	device(DefaultVDI()),
	mfdb(CreateMFDB(true,w,h,d,true)),
	altmfdb(CreateMFDB(false,w,h,device.NumberOfPlanes(),false)),
	altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(false),
	palette(0),
	bitplane_transform(0)
{ }

IMG::IMG(int w,int h) :
	device(DefaultVDI()),
	mfdb(CreateMFDB(false,w,h,device.NumberOfPlanes(),true)),
	altmfdb(CreateMFDB(true,w,h,device.NumberOfPlanes(),false)),
	altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(false),
	palette(0),
	bitplane_transform(0)
{ }

IMG::IMG(unsigned short* at,int w,int h,int d) :
	device(DefaultVDI()),
	mfdb(CreateMFDB(true,w,h,d,false)),
	altmfdb(CreateMFDB(false,w,h,d,false)), altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(true),
	palette(0),
	bitplane_transform(0)
{
	mfdb->fd_addr=(long)at;
}

IMG::IMG(unsigned short* at,int w,int h) :
	device(DefaultVDI()),
	mfdb(CreateMFDB(false,w,h,device.NumberOfPlanes(),false)),
	altmfdb(CreateMFDB(true,w,h,device.NumberOfPlanes(),false)),
	altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(true),
	palette(0),
	bitplane_transform(0)
{
	mfdb->fd_addr=(long)at;
}

IMG::IMG(const IMG& source, const GRect& area) :
	device(source.device),
	mfdb(CreateMFDB(source.InStandardForm(),area.g_w,area.g_h,source.InStandardForm() ? source.Depth() : device.NumberOfPlanes(),true)),
	altmfdb(CreateMFDB(!source.InStandardForm(),area.g_w,area.g_h,source.InStandardForm() ? device.NumberOfPlanes() : source.Depth(),false)),
	altvalid(false),
	uW(source.uW), uH(source.uH),
	external(false),
	palette(0),
	bitplane_transform(source.bitplane_transform)
{
	Copy(source,area);
}

IMG::IMG(VDI& dev) :
	device(dev),
	mfdb(CreateMFDB(false,dev.Width(),dev.Height(),dev.NumberOfPlanes(),false)),
	altmfdb(CreateMFDB(true,dev.Width(),dev.Height(),dev.NumberOfPlanes(),false)),
	altvalid(false),
	uW(DEFAULT_MICRONS), uH(DEFAULT_MICRONS),
	external(true),
	palette(0),
	bitplane_transform(0)
{
	if (dev.PaletteBased() && Depth()<15) { // Only believe less than 32K color CLUT.
		palette=new GEMimgpalette(*this);

		for (int i=(1<<Depth()); i--; ) {
			int rgb[3];
			dev.q_color(Color_BitmapToVDI(i),1,rgb);
			VDIRGB vdirgb(rgb[0],rgb[1],rgb[2]);
			palette->Set(i,vdirgb);
		}
	}
}

static short BiosToVDIscale(short rgb)
{
	if (rgb&8) rgb=((rgb^8)<<1)|1;
	else rgb=rgb<<1;

	return rgb*1000/15;
}

IMG::IMG(const char *fn) :
	device(DefaultVDI()),
	mfdb(0),
	altmfdb(0), altvalid(false),
	external(false),
	palette(0),
	bitplane_transform(0)
{
	Read(fn);
}

int IMG::Read(const char* fn)
{
	DisposeMFDB(mfdb); mfdb=0;
	DisposeMFDB(altmfdb); altmfdb=0;
	delete palette; palette=0;

	FILE *f=fopen(fn,"rb");

	if (!f) return 0;

	IMGfileheader header;
	fread(&header,sizeof(header),1,f);

	mfdb=CreateMFDB(true,header.W,header.H,header.planes,true);
	altmfdb=CreateMFDB(false,header.W,header.H,device.NumberOfPlanes(),false);
	uW=header.uW;
	uH=header.uH;

	if (header.length*sizeof(short)!=sizeof(header)) {
		// Must be extended format.
		//
		// We only support XIMG.
		//
		XIMGextension ximg_ext;

		fread(&ximg_ext,sizeof(ximg_ext),1,f);
		if (ximg_ext.magic[0]==XIMGmagic[0]
		 && ximg_ext.magic[1]==XIMGmagic[1]
		 && ximg_ext.magic[2]==XIMGmagic[2]
		 && ximg_ext.magic[3]==XIMGmagic[3]) {
			// XIMG format recognized.

			switch (ximg_ext.col_format) {
			 case XIMGrgb:
				// Only read palette if length indicates there is one. (eg. not like if header.planes==24!)
				if ((size_t) header.length >= (sizeof(IMGfileheader)+sizeof(XIMGextension))/sizeof(short)+(3 << header.planes)) {
					palette=new GEMimgpalette(*this);
					for (int i=0;i < (1 << header.planes); i++) {
						VDIRGB rgb;
						fread(&rgb,sizeof(VDIRGB),1,f);
						palette->Set(i,rgb);
					}
				}
			break; default:
				; // Sorry, don't know any other format.
			}
		}

		fseek(f,header.length*sizeof(short),SEEK_SET);
	}

	readIMG((unsigned char*)Location(),header.patternlen,WordWidth()*2,WordWidth()*2-Bpad(Width()),Height(),Depth(),f);

	fclose(f);

	return 1;
}

IMG::~IMG()
{
	if (!external) {
		DisposeMFDB(mfdb);
	} else {
		delete mfdb;
	}

	// The alternate is never external.
	DisposeMFDB(altmfdb);

	delete palette;
}


static short* bm_to_vdi=0;
static short* vdi_to_bm=0;
static short table_depth=0;
static
void SetTable(VDI& device)
{
	int newdepth=device.NumberOfPlanes();
	if (table_depth!=newdepth) {
		table_depth=newdepth;

		delete bm_to_vdi;
		delete vdi_to_bm;

		int ncols=1<<table_depth;

		bm_to_vdi=new short[ncols];
		vdi_to_bm=new short[ncols];

		// Two techniques for building the color mapping tables are
		// implemented.  Both give the same result on VDIs tested.

#define SETTABLE_BY_GETPIXEL
#ifdef SETTABLE_BY_GETPIXEL

		// Plot each pixel color, examing get_pixel response.

		int pxy[]={0,0};

		wind_update(BEG_UPDATE);
		device.sm_type(1); // Single pixel
		while (ncols--) {
			int b,v;

			device.sm_color(ncols);
			device.pmarker(1,pxy);
			device.get_pixel(0,0,&b,&v);

			bm_to_vdi[b]=v;
			vdi_to_bm[v]=b;
		}
		wind_update(END_UPDATE);
#else
		// Do transformation on picture of palette

		// 1 pixel for each color = table_depth bits for each color.
		int size=(ncols > 16 ? ncols : 16)*table_depth/sizeof(short)/8;

		MFDB mf_solid,mf_dev,mf_std;

		// Solid color
		short one=0xffff;
		mf_solid.fd_addr=(long)(&one);
		mf_solid.fd_w=16;
		mf_solid.fd_h=1;
		mf_solid.fd_wdwidth=1;
		mf_solid.fd_stand=1;
		mf_solid.fd_nplanes=1;
		mf_solid.fd_r1=0;
		mf_solid.fd_r2=0;
		mf_solid.fd_r3=0;

		// Device
		mf_dev.fd_addr=(long)(new short[size]);
		mf_dev.fd_w=(ncols > 16 ? ncols : 16);
		mf_dev.fd_h=1;
		mf_dev.fd_wdwidth=(ncols > 16 ? ncols : 16)/16;
		mf_dev.fd_stand=0;
		mf_dev.fd_nplanes=table_depth;
		mf_dev.fd_r1=0;
		mf_dev.fd_r2=0;
		mf_dev.fd_r3=0;

		// Standard
		mf_std=mf_dev;
		mf_std.fd_stand=1;
		mf_std.fd_addr=(long)(new short[size]);

		// Draw picture on mf_dev
		for (int c=0; c<ncols; c++) {
			int colors[2]={c,0};
			int pxy[8]={0,0,0,0,c,0,c,0};
			device.rt_cpyfm(MD_REPLACE,pxy,mf_solid,mf_dev,colors);
		}

		// Transform
		device.r_trnfm(mf_dev,mf_std);

		for (int v=0; v<ncols; v++) {
			int b=0;

			short* bit=(short*)mf_std.fd_addr + v/16;
			short mask=0x8000>>(v&15);
			int mag=1;
			for (int plane=0; plane<table_depth; plane++) {
				if (*bit & mask) b|=mag;
				bit+=mf_std.fd_wdwidth;
				mag<<=1;
			}

			bm_to_vdi[b]=v;
			vdi_to_bm[v]=b;
		}

		delete (short*)mf_std.fd_addr;
		delete (short*)mf_dev.fd_addr;
#endif
	}
}

int IMG::Color_BitmapToVDI(int bm_col) const
{
	if (device.PaletteBased()) {
		SetTable(device);
		return bm_to_vdi[bm_col^bitplane_transform];
	} else {
		return bm_col;
	}
}

int IMG::Color_VDIToBitmap(int vdi_col) const
{
	if (device.PaletteBased()) {
		SetTable(device);
		return vdi_to_bm[vdi_col]^bitplane_transform;
	} else {
		return vdi_col;
	}
}

int IMG::Color_BitmapToTrueColor(int bm_col) const
{
	VDIRGB vdirgb;
	palette->Get(bm_col,vdirgb);
	int r8=vdirgb.Red()*255/1000;
	int g8=vdirgb.Green()*255/1000;
	int b8=vdirgb.Blue()*255/1000;

	switch (Depth()) {
	 case 15: case 16:
		return ((r8>>3)<<11)
			 | ((g8>>2)<<5)
			 | (b8>>3);
	break; case 24: case 32:
		return (r8<<16)
			 | (g8<<8)
			 | b8;
	break; case 8:
		// Pseudo TrueColor
		return 16+(r8*5/255)*36+(g8*5/255)*6+(b8*5/255);
	break; default:
		return 0;
	}
}

int* IMG::Color_MakeBitmapToVDITable() const
{
	int* result=new int[1<<Depth()];
	for (int i=1<<Depth(); i--; ) {
		result[i]=Color_BitmapToVDI(i);
	}
	return result;
}

int* IMG::Color_MakeVDIToBitmapTable() const
{
	int* result=new int[1<<Depth()];
	for (int i=1<<Depth(); i--; ) {
		result[i]=Color_VDIToBitmap(i);
	}
	return result;
}

static
void readIMG(unsigned char* bitmap,int patlen,int bW,int unused_at_line_end,int H,int D,FILE* f)
{
	int c;
	int linerep=0;
	const int planesep=H*bW;
	int thisln=bW-unused_at_line_end;
	int plane=0;

	while (EOF!=(c=fgetc(f))) {
		if (H<0) {
			// IMG file too long.
			return;
		}
		switch (c) {
			case 0:
				int n;
				if (EOF!=(n=fgetc(f))) {
					if (n) { // Repeating pattern
						fread(bitmap,patlen,1,f);
						bitmap+=patlen;
						thisln-=patlen;
						while (--n) {
							unsigned char *from=bitmap-patlen;
							for (int pn=patlen; pn; pn--) *bitmap++=*from++;
							thisln-=patlen;
						}
					} else { // Next scanline repeats
						n=fgetc(f); // Should be 0xff
						n=fgetc(f);
						linerep+=n-1; // REPEATs, not total number
					}
				}
		break;	case 0x80: // Literal
				int nl;
				if (EOF!=(nl=fgetc(f))) {
					fread(bitmap,nl,1,f);
					bitmap+=nl;
					thisln-=nl;
				}
		break;	default: // Solid run
				unsigned char pat=((c&0x80) ? 0xff : 0);
				int nsol=c&0x7f;
				thisln-=nsol;
				while (nsol--) *bitmap++=pat;
		}
		if (thisln<=0) {
			// End of line of plane

			// Clear unused bits.
			for (int i=0; i<unused_at_line_end; i++)
				*bitmap++=0;

			// Next plane, same line
			thisln=bW-unused_at_line_end;
			plane++;
			bitmap+=planesep-bW;
		}
		if (plane>=D) {
			// End of scanline

			H--;

			// Move back to first plane, next line
			bitmap-=planesep*D-bW;
			plane=0;

			// Repeat line however many time is required.
			while (linerep) {
				unsigned char *from=bitmap-bW; // Find start.
				for (int p=0; p<D; p++) {
					for (int lineb=0; lineb<bW; lineb++) {
						*bitmap++ = *from++;
					}
					from+=planesep-bW;
					bitmap+=planesep-bW;
				}
				// Move back to first plane, next line
				bitmap-=planesep*D-bW;
				H--;
				linerep--;
			}
		}
	}
}


void IMG::Clear()
{
	Blit(0,*this);
}


void IMG::SetAltMFDB(bool std_not_dev)
// Set altmfdb to same as mfdb, but in "std_not_dev" form,
// assuming mfdb is not in "std_not_dev" form.
{
	EnsureWithData(altmfdb);

	if (std_not_dev) {
		// XXX Huh?  How will this be sufficient?
		device.r_trnfm(*mfdb,*altmfdb);
	} else {
		if (device.NumberOfPlanes()==Depth()) {
			device.r_trnfm(*mfdb,*altmfdb);
		} else if (device.NumberOfPlanes()>Depth()) {
			int size=WordWidth()*sizeof(short)*Height()*Depth();
			int destsize=WordWidth()*sizeof(short)*Height()*device.NumberOfPlanes();

			MFDB* stdaltmfdb (0);

			if (!inplace_transforms) {
				// Copy mfdb to altmfdb and transform via stdaltmfdb.
				stdaltmfdb=CreateMFDB(true,Width(),Height(),device.NumberOfPlanes(),true);
			} else {
				// Copy mfdb to altmfdb and transform in-place.
				MFDB* stdaltmfdb=new MFDB;
				*stdaltmfdb=*altmfdb; // Same as altmfdb...
				stdaltmfdb->fd_stand=true; // ... except std form.
			}

			memcpy((void*)(stdaltmfdb->fd_addr),Location(),size);
			memset((void*)(stdaltmfdb->fd_addr+size),0,destsize-size);

			unsigned int trans=bitplane_transform;
			short* cursor=(short*)(stdaltmfdb->fd_addr);
			int planesize=WordWidth()*Height();

			while (trans) {
				if (trans&1) {
					// needs to be flipped.
					short* flip=cursor;
					int count=planesize;
					while (count--) {
						*flip^=0xffff;
						flip++;
					}
				}
				trans>>=1;
				cursor+=planesize;
			}

			device.r_trnfm(*stdaltmfdb,*altmfdb);

			if (stdaltmfdb->fd_addr == altmfdb->fd_addr) { // ie. (inplace_transforms)
				delete stdaltmfdb; // Since the fd_addr doesn't belong to it.
			} else {
				DisposeMFDB(stdaltmfdb);
			}
		} else {
			// Transform first bitplanes of mfdb to altmfdb
			MFDB smallmfdb=*mfdb; // Same as mfdb...
			smallmfdb.fd_nplanes=device.NumberOfPlanes(); // ... except less planes.
			device.r_trnfm(smallmfdb,*altmfdb);
		}
	}

	altvalid=true;
}

MFDB* IMG::DevMFDB() const
{
	if (!mfdb->fd_stand) {
		// mfdb is dev mfdb
		return mfdb;
	}

	if (!altvalid) {
		// altmfdb is to be dev mfdb
		// Cast off constness - this is ABSTRACT const (due to cache).
		((IMG*)this)->SetAltMFDB(false);
	}

	return altmfdb;
}

MFDB* IMG::StdMFDB() const
{
	if (mfdb->fd_stand) {
		// mfdb is std mfdb
		return mfdb;
	}

	if (!altvalid) {
		// altmfdb is to be dev mfdb
		// Cast off constness - this is ABSTRACT const (due to cache).
		((IMG*)this)->SetAltMFDB(true);
	}

	return altmfdb;
}

void IMG::Copy(const IMG& from)
{
	Blit(VDI::SRC,from);
}

void IMG::Copy(const IMG& from, int to_x, int to_y)
{
	Blit(VDI::SRC,from,to_x,to_y);
}

void IMG::Copy(const IMG& from, const GRect& fromarea)
{
	Blit(VDI::SRC,from,fromarea);
}

void IMG::Copy(const IMG& from, const GRect& fromarea, int to_x, int to_y)
{
	Blit(VDI::SRC,from,fromarea,to_x,to_y);
}

void IMG::Blit(int operation, const IMG& from)
{
	GRect fromarea(0,0,from.Width(),from.Height());
	Blit(operation,from,fromarea,0,0);
}

void IMG::Blit(int operation, const IMG& from, int to_x, int to_y)
{
	GRect fromarea(0,0,from.Width(),from.Height());
	Blit(operation,from,fromarea,to_x,to_y);
}

void IMG::Blit(int operation, const IMG& from, const GRect& fromarea)
{
	Blit(operation,from,fromarea,0,0);
}

static
int min(int a, int b)
{
	if (a>b) return b;
	else return a;
}

void vro_cpystdfm(VDI& device, int operation, int pxy[], const MFDB& src, const MFDB& dst)
{
	int nplanes=min(src.fd_nplanes,dst.fd_nplanes);

	MFDB from=src;
	MFDB to=dst;

	from.fd_stand=0;
	to.fd_stand=0;
	from.fd_nplanes=1;
	to.fd_nplanes=1;

	int from_planesep=from.fd_wdwidth*sizeof(short)*from.fd_h;
	int to_planesep=to.fd_wdwidth*sizeof(short)*to.fd_h;

	while (nplanes--) {
		device.ro_cpyfm(operation,pxy,from,to);
		to.fd_addr+=to_planesep;
		from.fd_addr+=from_planesep;
	}
}

void IMG::Blit(int operation, const IMG& from, const GRect& fromarea, int to_x, int to_y)
{
	GRect fromareatouse=fromarea;

	// Clip to non-negative quadrant.

	if (fromareatouse.g_x < 0) {
		to_x+=-fromareatouse.g_x;
		fromareatouse.g_w-=-fromareatouse.g_x;
		fromareatouse.g_x=0;
	}
	if (fromareatouse.g_y < 0) {
		to_y+=-fromareatouse.g_y;
		fromareatouse.g_h-=-fromareatouse.g_y;
		fromareatouse.g_y=0;
	}

	if (to_x < 0) {
		fromareatouse.g_x+=-to_x;
		fromareatouse.g_w-=-to_x;
		to_x=0;
	}
	if (to_y < 0) {
		fromareatouse.g_y+=-to_y;
		fromareatouse.g_h-=-to_y;
		to_y=0;
	}

	// Clip to size of source rectangle.
	if (fromareatouse.g_x+fromareatouse.g_w > from.Width()) {
		fromareatouse.g_w=from.Width()-fromareatouse.g_x;
	}
	if (fromareatouse.g_y+fromareatouse.g_h > from.Height()) {
		fromareatouse.g_h=from.Height()-fromareatouse.g_y;
	}

	// Clip to size of destination rectangle.
	if (to_x+fromareatouse.g_w > Width()) {
		fromareatouse.g_w=Width()-to_x;
	}
	if (to_y+fromareatouse.g_h > Height()) {
		fromareatouse.g_h=Height()-to_y;
	}

	int pxy[8]={
		fromareatouse.g_x,fromareatouse.g_y,
		fromareatouse.g_x+fromareatouse.g_w-1,fromareatouse.g_y+fromareatouse.g_h-1,
		to_x,to_y,
		to_x+fromareatouse.g_w-1,to_y+fromareatouse.g_h-1,
	};

	if (InStandardForm()) {
		vro_cpystdfm(device,operation,pxy,*from.StdMFDB(),*mfdb);
	} else {
		device.ro_cpyfm(operation,pxy,*from.DevMFDB(),*mfdb);
	}
}

void IMG::MonoBlit(int wr_mode, const IMG& from, int colors[2])
{
	GRect fromarea(0,0,from.Width(),from.Height());
	MonoBlit(wr_mode,from,fromarea,0,0,colors);
}

void IMG::MonoBlit(int wr_mode, const IMG& from, int to_x, int to_y, int colors[2])
{
	GRect fromarea(0,0,from.Width(),from.Height());
	MonoBlit(wr_mode,from,fromarea,to_x,to_y,colors);
}

void IMG::MonoBlit(int wr_mode, const IMG& from, const GRect& fromarea, int colors[2])
{
	MonoBlit(wr_mode,from,fromarea,0,0,colors);
}

void IMG::MonoBlit(int wr_mode, const IMG& from, const GRect& fromarea, int to_x, int to_y, int colors[2])
{
	// COPYIED FROM IMG::Blit above
	// COPYIED FROM IMG::Blit above
	// COPYIED FROM IMG::Blit above >>>

	GRect fromareatouse=fromarea;

	// Clip to non-negative quadrant.

	if (fromareatouse.g_x < 0) {
		to_x+=-fromareatouse.g_x;
		fromareatouse.g_w-=-fromareatouse.g_x;
		fromareatouse.g_x=0;
	}
	if (fromareatouse.g_y < 0) {
		to_y+=-fromareatouse.g_y;
		fromareatouse.g_h-=-fromareatouse.g_y;
		fromareatouse.g_y=0;
	}

	if (to_x < 0) {
		fromareatouse.g_x+=-to_x;
		fromareatouse.g_w-=-to_x;
		to_x=0;
	}
	if (to_y < 0) {
		fromareatouse.g_y+=-to_y;
		fromareatouse.g_h-=-to_y;
		to_y=0;
	}

	// Clip to size of source rectangle.
	if (fromareatouse.g_x+fromareatouse.g_w > from.Width()) {
		fromareatouse.g_w=from.Width()-fromareatouse.g_x;
	}
	if (fromareatouse.g_y+fromareatouse.g_h > from.Height()) {
		fromareatouse.g_h=from.Height()-fromareatouse.g_y;
	}

	// Clip to size of destination rectangle.
	if (to_x+fromareatouse.g_w > Width()) {
		fromareatouse.g_w=Width()-to_x;
	}
	if (to_y+fromareatouse.g_h > Height()) {
		fromareatouse.g_h=Height()-to_y;
	}

	int pxy[8]={
		fromareatouse.g_x,fromareatouse.g_y,
		fromareatouse.g_x+fromareatouse.g_w-1,fromareatouse.g_y+fromareatouse.g_h-1,
		to_x,to_y,
		to_x+fromareatouse.g_w-1,to_y+fromareatouse.g_h-1,
	};

	// <<< COPYIED FROM IMG::Blit above
	//     COPYIED FROM IMG::Blit above
	//     COPYIED FROM IMG::Blit above

	// XXX StdMFDB... is that right?
	device.rt_cpyfm(wr_mode,pxy,*from.StdMFDB(),*mfdb,colors);
}


bool IMG::InStandardForm() const
{
	return mfdb->fd_stand;
}

void IMG::ShowPalette()
{
	if (palette) palette->Show();
}

void IMG::InvalidateCache()
{
	altvalid=false;
}

void IMG::ClearCache()
{
	unsigned short* data=(unsigned short*)altmfdb->fd_addr;
	delete data;
	altmfdb->fd_addr=0;
	altvalid=false;
}

void IMG::TranslateTo(bool std)
{
	if (std!=mfdb->fd_stand) {
		if (!altvalid) {
			SetAltMFDB(std);
		}

		MFDB* tmp=mfdb;
		mfdb=altmfdb;
		altmfdb=tmp;

		if (palette)
			palette->ImageChanged(false);
	}
}

void IMG::BitplaneTransformation(unsigned int transform)
{
	bitplane_transform=transform&((1<<device.NumberOfPlanes())-1);
}

unsigned int IMG::BitplaneTransformation() const
{
	return bitplane_transform;
}

GEMpalette& IMG::Palette()
{
	if (!palette) palette=new GEMimgpalette(*this);

	return *palette;
}

void IMG::Resize(int w, int h)
{
	Resize(w,h,Depth());
}

void IMG::Resize(int w, int h, int d)
{
	bool std=InStandardForm();

	if (!external) {
		DisposeMFDB(mfdb);
		DisposeMFDB(altmfdb);
	}

	bool depth_changed=(d!=Depth());

	mfdb=CreateMFDB(std,w,h,d,true);
	altmfdb=CreateMFDB(std,w,h,d,false);
	altvalid=false;
	external=false;

	if (palette && depth_changed)
		palette->ImageChanged(depth_changed);
}



GEMimgpalette::GEMimgpalette(IMG& image) :
	rgb(0),
	img(image)
{
	ImageChanged(true);
}

GEMimgpalette::~GEMimgpalette()
{
	delete [] rgb;
}

void GEMimgpalette::SetRGB(int index, int& vdiindex, const VDIRGB& in)
{
#if 0
	if (img.InStandardForm()) {
		vdiindex=img.Color_BitmapToVDI(index);
	} else {
		vdiindex=index;
	}
#else
	vdiindex=img.Color_BitmapToVDI(index);
#endif
	rgb[index]=in;
}

void GEMimgpalette::GetRGB(int index, int& vdiindex, VDIRGB& out) const
{
#if 0
	if (img.InStandardForm()) {
		vdiindex=img.Color_BitmapToVDI(index);
	} else {
		vdiindex=index;
	}
#else
	vdiindex=img.Color_BitmapToVDI(index);
#endif
	out=rgb[index];
}

int GEMimgpalette::PaletteSize() const
{
	return img.Depth() < 15 ? (1<<img.Depth()) : 256;
}

void GEMimgpalette::ImageChanged(bool depth_changed)
{
	VDI& device=DefaultVDI();
	int size=img.Depth() < 15 ? (1<<img.Depth()) : 256;

	if (depth_changed) {
		delete rgb;
		rgb=new VDIRGB[size];
	}

	for (int i=size; i--; ) {
		int index=i;

		if (img.InStandardForm()) {
			index=img.Color_BitmapToVDI(i);
		}

		if (depth_changed) {
			int RGB[3];
			device.q_color(index,1,RGB);
			rgb[i].Set(RGB[0],RGB[1],RGB[2]);
		}
	}
}

int IMG::Depth() const
{
	if (InStandardForm()) {
		return mfdb->fd_nplanes;
	} else {
		return altmfdb->fd_nplanes;
	}
}

void IMG::TranslateArea(const GRect& damaged)
{
	// Copy through new area so transformation is minimal.
	//
	TranslateTo(!InStandardForm());
	IMG area_from(*this,damaged);
	TranslateTo(!InStandardForm());
	Copy(area_from,damaged.g_x,damaged.g_y);
}
