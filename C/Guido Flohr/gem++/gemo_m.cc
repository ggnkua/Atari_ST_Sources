/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

//
//  Include file for methods common to GEMrawobject and GEMobject.
//

union Bfobspec {
	long packed;
	struct bfobspec bits;
};

struct colspec {
    unsigned short framecol    :  4;
    unsigned short textcol     :  4;
    unsigned short textmode    :  1;
    unsigned short fillpattern :  3;
    unsigned short interiorcol :  4;
};

struct iconcolspec {
    unsigned short datacol     :  4;
    unsigned short maskcol     :  4;
    unsigned short character   :  8;
};

char* CLASS::ImageBitmap(bool Mask=false) const
{
	switch (Type()) {
	 case G_IMAGE:
		return (char*)((BITBLK*)ObjectSpecific())->bi_pdata;
	break;
	 case G_ICON:
		if (Mask)
			return (char*)((ICONBLK*)ObjectSpecific())->ib_pmask;
		else
			return (char*)((ICONBLK*)ObjectSpecific())->ib_pdata;
	break;
	 default:
		return 0;
	}
	return 0;
}

short CLASS::ImageWidth() const
{
	switch (Type()) {
	 case G_IMAGE:
		return ((BITBLK*)ObjectSpecific())->bi_wb*8;
	break;
	 case G_ICON:
		return ((ICONBLK*)ObjectSpecific())->ib_wicon;
	break;
	 default:
		return 0;
	}
	return 0;
}

short CLASS::ImageHeight() const
{
	switch (Type()) {
	 case G_IMAGE:
		return ((BITBLK*)ObjectSpecific())->bi_hl;
	break;
	 case G_ICON:
		return ((ICONBLK*)ObjectSpecific())->ib_hicon;
	break;
	 default:
		return 0;
	}
	return 0;
}

void CLASS::SetImageBitmap(char* d, short w, short h, bool Mask=false)
{
	switch (Type()) {
	 case G_IMAGE:
		((BITBLK*)ObjectSpecific())->bi_pdata=(short *)d;
		((BITBLK*)ObjectSpecific())->bi_wb=w/8;
		((BITBLK*)ObjectSpecific())->bi_hl=h;
	break;
	 case G_ICON:
		if (Mask)
			((ICONBLK*)ObjectSpecific())->ib_pmask=(short*)d;
		else
			((ICONBLK*)ObjectSpecific())->ib_pdata=(short*)d;
		((ICONBLK*)ObjectSpecific())->ib_wicon=w;
		((ICONBLK*)ObjectSpecific())->ib_hicon=h;
	}
}

char* CLASS::Text() const
{
	static char boxchar_char;

	switch (Type()) {
	 case G_ICON:
		return ((ICONBLK*)ObjectSpecific())->ib_ptext;
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((TEDINFO*)ObjectSpecific())->te_ptext;
	break;
	 case G_BOXCHAR: // This usage is dubious.
		Bfobspec os;
		os.packed=ObjectSpecific();
		boxchar_char=os.bits.character;
		return &boxchar_char;
	break;
	 case G_STRING:
	 case G_BUTTON:
		return (char*)ObjectSpecific();
	break;
	 default:
		return "";
	}
}

void CLASS::Font(int font)
{
	switch (Type()) {
		case G_BOXTEXT:
		case G_TEXT:
		case G_FTEXT:
		case G_FBOXTEXT:
			((TEDINFO*)ObjectSpecific())->te_font=font;
	}
}

int CLASS::Font() const
{
	switch (Type()) {
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((TEDINFO*)ObjectSpecific())->te_font;
	break;
	 case G_ICON:
		return SMALL;
	break;
	 default:
		return IBM;
	}
}

int CLASS::ForeCol() const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).textcol;
	break;
	 case G_IMAGE:
		return ((BITBLK*)ObjectSpecific())->bi_color;
	break;
	 case G_ICON:
		return ((iconcolspec&)(((ICONBLK*)ObjectSpecific())->ib_char)).datacol;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.textcol;
	break;
	 default:
		return BLACK; // eg. G_BUTTON always black on white.
	}
}

int CLASS::BackCol() const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).interiorcol;
	break;
	 case G_IMAGE:
		return ((BITBLK*)ObjectSpecific())->bi_color;
	break;
	 case G_ICON:
		return ((iconcolspec&)(((ICONBLK*)ObjectSpecific())->ib_char)).maskcol;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.interiorcol;
	break;
	 default:
		return WHITE; // eg. G_BUTTON always black on white.
	}
}

int CLASS::BorderCol() const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).framecol;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.framecol;
	break;
	 default:
		return BLACK; // eg. G_BUTTON always has black frame
	}
}

int CLASS::BorderWidth() const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_FTEXT:
		return 0;
	break;
	 case G_BOXTEXT:
	 case G_FBOXTEXT:
		return ((TEDINFO*)ObjectSpecific())->te_thickness;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.framesize;
	break;
	 case G_BUTTON:
		if (Default()) return -3;
		if (Exit()) return -2;
		return -1;
	break;
	 default:
		return 0;
	}
}

int CLASS::TextAlignment() const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((TEDINFO*)ObjectSpecific())->te_just;
	break;
	 case G_BOXCHAR:
	 case G_BUTTON:
		return 2; // Center
	break;
	 default: // including G_STRING
		return 0; // Left
	}
}

void CLASS::TextAlignment(int align) const
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((TEDINFO*)ObjectSpecific())->te_just=align;
	}
}

void CLASS::ForeCol(int colorindex)
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).textcol=colorindex;
	break;
	 case G_IMAGE:
		((BITBLK*)ObjectSpecific())->bi_color=colorindex;
	break;
	 case G_ICON:
		((iconcolspec&)(((ICONBLK*)ObjectSpecific())->ib_char)).datacol=colorindex;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.textcol=colorindex;
		ObjectSpecific(os.packed);
	break;
	 default:
		;
	}
}

void CLASS::BackCol(int colorindex)
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).interiorcol=colorindex;
	break;
	 case G_IMAGE:
		((BITBLK*)ObjectSpecific())->bi_color=colorindex;
	break;
	 case G_ICON:
		((iconcolspec&)(((ICONBLK*)ObjectSpecific())->ib_char)).maskcol=colorindex;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.interiorcol=colorindex;
		ObjectSpecific(os.packed);
	break;
	 default:
		;
	}
}

void CLASS::BorderCol(int colorindex)
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).framecol=colorindex;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.framecol=colorindex;
		ObjectSpecific(os.packed);
	break;
	 default:
		;
	}
}

void CLASS::BorderWidth(int width)
{
	switch (Type()) {
	 case G_TEXT:
	 case G_BOXTEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((TEDINFO*)ObjectSpecific())->te_thickness=width;
	break;
	 case G_BOX:
	 case G_IBOX:
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.framesize=width;
		ObjectSpecific(os.packed);
	break;
	 default:
		;
	}
}

void CLASS::SetText(char* t)
{
	switch (Type()) {
	 case G_ICON:
		((ICONBLK*)ObjectSpecific())->ib_ptext=t;
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((TEDINFO*)ObjectSpecific())->te_ptext=t;
	break;
	 case G_STRING:
	 case G_BUTTON:
		ObjectSpecific((long)t);
	break;
	 case G_BOXCHAR:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.character=*t;
		ObjectSpecific(os.packed);
	}
}

int CLASS::FillPattern() const
{
	switch (Type()) {
	 case G_BOXCHAR:
	 case G_BOX:
	 case G_IBOX:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.fillpattern;
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).fillpattern;
	break;
	 default:
		return 0;
	}
}

void CLASS::FillPattern(int f)
{
	switch (Type()) {
	 case G_BOXCHAR:
	 case G_BOX:
	 case G_IBOX:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.fillpattern=f;
		ObjectSpecific(os.packed);
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).fillpattern=f;
	break;
	 default:
		;
	}
}

bool CLASS::Transparent() const
{
	switch (Type()) {
	 case G_BOXCHAR:
	 case G_BOX:
	 case G_IBOX:
		Bfobspec os;
		os.packed=ObjectSpecific();
		return os.bits.textmode;
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		return ((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).textmode;
	break;
	 default:
		return false;
	}
}

void CLASS::Transparent(bool yes)
{
	switch (Type()) {
	 case G_BOXCHAR:
	 case G_BOX:
	 case G_IBOX:
		Bfobspec os;
		os.packed=ObjectSpecific();
		os.bits.textmode=yes;
		ObjectSpecific(os.packed);
	break;
	 case G_BOXTEXT:
	 case G_TEXT:
	 case G_FTEXT:
	 case G_FBOXTEXT:
		((colspec&)(((TEDINFO*)ObjectSpecific())->te_color)).textmode=yes;
	break;
	 default:
		;
	}
}
