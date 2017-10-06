/////////////////////////////////////////////////////////////////////////////
//
//  IMG - Standard GEM image format
//
//  An IMG is a bitmap.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef IMG_h
#define IMG_h

#include <bool.h>
#include <gemfast.h>
#include <aesext.h>
#include <grect.h>

#include <gempal.h>
#include <imgcurs.h>
#include <yd.h>

class VDI;

class IMG {
public:
	// Empty image, no size
	IMG();

	// Contents undefined, but writable.
	// Standard form - any depth.
	IMG(int width,int height,int depth);	
	// Device form - depth of device.
	IMG(int width,int height);

	// Contents defined as bitmap At given location, with given dimensions.
	// Standard form - any depth.
	IMG(unsigned short* At, int width, int height, int depth);
	// Device form - depth of device.
	IMG(unsigned short* At, int width, int height);

	// Copy from sub-area of other image.
	IMG(const IMG&, const GRect& area);

	// IMG of device.  NOTE:  No Cursor allowed.
	// Always in non-stdform.
	IMG(VDI& device);

	// Read from IMG file.
	IMG(const char *);

	virtual ~IMG();

	int operator!() const; // creation failure (memory or file) test

	int Read(const char *);
	int Write(const char *,int PatLen=2);

	int Width() const;
	int Height() const;
	int Depth() const;

	// Resizing makes contents invalid (eg. use Clear() afterwards)
	void Resize(int width, int height); // depth unchanged
	void Resize(int width, int height, int depth);

	int WordWidth() const;

	void BitplaneTransformation(unsigned int transform);
	unsigned int BitplaneTransformation() const;

	IMGcursor Cursor(); // Top corner.
	IMGcursor Cursor(int x, int y, int z=0); // Any position.

	void Clear();

	// Source overwrites destination.
	void Copy(const IMG& from);
	void Copy(const IMG& from, int to_x, int to_y);
	void Copy(const IMG& from, const GRect& fromarea);
	void Copy(const IMG& from, const GRect& fromarea, int to_x, int to_y);

	// Arbitrary combination of src & dest. (see VDI::SRC, VDI::DST)
	void Blit(int operation, const IMG& from);
	void Blit(int operation, const IMG& from, const GRect& fromarea);
	void Blit(int operation, const IMG& from, int to_x, int to_y);
	void Blit(int operation, const IMG& from, const GRect& fromarea, int to_x, int to_y);

	// Arbitrary combination of monochrome-src & dest.
	void MonoBlit(int wr_mode, const IMG& monofrom, int colors[2]);
	void MonoBlit(int wr_mode, const IMG& monofrom, const GRect& fromarea, int colors[2]);
	void MonoBlit(int wr_mode, const IMG& monofrom, int to_x, int to_y, int colors[2]);
	void MonoBlit(int wr_mode, const IMG& monofrom, const GRect& fromarea, int to_x, int to_y, int colors[2]);

	bool InStandardForm() const;
	void TranslateTo(bool std);
	void InvalidateCache();
	void ClearCache();
	void TranslateArea(const GRect& damaged);

	MFDB* DevMFDB() const;
	MFDB* StdMFDB() const;
	MFDB* AnyMFDB() const;

	GEMpalette& Palette();
	void ShowPalette();

	int Color_BitmapToVDI(int pixel_index) const;
	int Color_VDIToBitmap(int vdi_index) const;
	int Color_BitmapToTrueColor(int pixel_index) const;

	// Or get a table of them...
	int* Color_MakeBitmapToVDITable() const;
	int* Color_MakeVDIToBitmapTable() const;

  friend class GEMimageobject;
  
protected:
	inline unsigned short int* Location() const;
	
private:
	static VDI* default_device;

	VDI& device;

	MFDB* mfdb;
	MFDB* altmfdb;
	bool altvalid;

	int uW,uH;
	bool external;
	class GEMimgpalette* palette; // if any.

	unsigned int bitplane_transform;

	void SetAltMFDB(bool std);
};

inline MFDB* IMG::AnyMFDB() const { return mfdb; }
inline int IMG::Width() const { return AnyMFDB()->fd_w; }
inline int IMG::WordWidth() const { return AnyMFDB()->fd_wdwidth; }
inline int IMG::Height() const { return AnyMFDB()->fd_h; }
inline int IMG::operator!() const { return !AnyMFDB(); }
inline unsigned short* IMG::Location() const { return (unsigned short*)(AnyMFDB()->fd_addr); }
inline IMGcursor IMG::Cursor() { return IMGcursor((unsigned short*)StdMFDB()->fd_addr,WordWidth(),WordWidth()*Height()); }
inline IMGcursor IMG::Cursor(int x, int y, int z=0) {
		IMGcursor result((unsigned short*)StdMFDB()->fd_addr,WordWidth(),WordWidth()*Height());
		result.MoveBy(x,y,z);
		return result;
	}

#endif
