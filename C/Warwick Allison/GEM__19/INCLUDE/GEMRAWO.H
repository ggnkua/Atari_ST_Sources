/////////////////////////////////////////////////////////////////////////////
//
//  GEMrawobject
//
//  A GEMrawobject is a C++ version of the standard GEM "OBJECT".  It is
//  constructed to have an identical bit image to that object, and as
//  such is only intended as a bridge between the fixed-sized objects
//  of GEM to the variable-sized objects we need for an Object Oriented
//  class hierarchy.  There is no point deriving from a GEMrawobject,
//  since GEM forms are still only arrays of OBJECTs.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMrawo_h
#define GEMrawo_h

#include <bool.h>
#include <gemfast.h>

class GEMobject;

class GEMrawobject : private OBJECT
// Since GEMrawobject is derived from OBJECT, and has no new data fields
// or virtual member functions (necessary?), it should be bit-compatible.
{
public:
	// The best thing to do with a GEMrawobject is Cook it.
	// Cook() returns 0 if no GEMobject has been declared for this object.
	GEMobject* Cook();

	GEMrawobject() { }

	// The top two flag bits define whether a GEMrawobject needs to
	// have a new copy of the object-specific data.
	//
	// If the object is EDITABLE, the logic below is negated, that is
	// ob_spec data is copied by default - setting bits negates the effect.
	//
	// Strings and BITBLKs with flag 15 or 14 set are copied.
	// ICONBLKs with flag 15 is set have the icon text copied.
	// ICONBLKs with flag 14 is set have the icon image copied.
	GEMrawobject(const GEMrawobject&);

	// The following are methods suited to different styles
	// Note that the "void" procedure could return the old value, but
	// this seems dangerous, as they would be too similar to the
	// other inspection-only parameterless methods.
	//  Too many choices?

	bool Selected(bool s)		{ return State(SELECTED,s); }
	bool Selected() const		{ return States(SELECTED); }
	void Select()				{ Selected(TRUE); }
	void Deselect()				{ Selected(FALSE); }
	bool Crossed(bool s)		{ return State(CROSSED,s); }
	bool Crossed() const		{ return States(CROSSED); }
	void Cross()				{ Crossed(TRUE); }
	void Uncross()				{ Crossed(FALSE); }
	bool Checked(bool s)		{ return State(CHECKED,s); }
	bool Checked() const		{ return States(CHECKED); }
	void Check()				{ Checked(TRUE); }
	void Uncheck()				{ Checked(FALSE); }
	bool Disabled(bool s)		{ return State(DISABLED,s); }
	bool Disabled() const		{ return States(DISABLED); }
	void Disable()				{ Disabled(TRUE); }
	void Enable()				{ Disabled(FALSE); }
	bool Outlined(bool s)		{ return State(OUTLINED,s); }
	bool Outlined() const		{ return States(OUTLINED); }
	void Outline()				{ Outlined(TRUE); }
	void Unoutline()			{ Outlined(FALSE); }
	bool Shadowed(bool s)		{ return State(SHADOWED,s); }
	bool Shadowed() const		{ return States(SHADOWED); }
	void Shadow()				{ Shadowed(TRUE); }
	void Unshadow()				{ Shadowed(FALSE); }

	bool Selectable(bool f)		{ return Flag(SELECTABLE,f); }
	bool Selectable() const		{ return Flags(SELECTABLE); }
	bool Default(bool f)		{ return Flag(DEFAULT,f); }
	bool Default() const		{ return Flags(DEFAULT); }
	bool Exit(bool f)			{ return Flag(EXIT,f); }
	bool Exit() const			{ return Flags(EXIT); }
	bool Editable(bool f)		{ return Flag(EDITABLE,f); }
	bool Editable() const		{ return Flags(EDITABLE); }
	bool RadioButton(bool f)	{ return Flag(RBUTTON,f); }
	bool RadioButton() const	{ return Flags(RBUTTON); }
	bool LastObject(bool f)		{ return Flag(LASTOB,f); }
	bool LastObject() const		{ return Flags(LASTOB); }
	bool TouchExit(bool f)		{ return Flag(TOUCHEXIT,f); }
	bool TouchExit() const		{ return Flags(TOUCHEXIT); }
	bool HideTree(bool f)		{ return Flag(HIDETREE,f); }
	bool HideTree() const		{ return Flags(HIDETREE); }
	bool Indirect(bool f)		{ return Flag(INDIRECT,f); }
	bool Indirect() const		{ return Flags(INDIRECT); }

	int Head() const			{ return ob_head; }
	int Tail() const			{ return ob_tail; }
	int Next() const			{ return ob_next; }

	unsigned long ObjectSpecific() const;
	void ObjectSpecific(unsigned long l);

	int Type() const			{ return ob_type&0xff; }
	int ExtType() const			{ return ob_type>>8; }
	void Type(int t)			{ ob_type=ob_type&0xff00|t; }
	void ExtType(int t)			{ ob_type=ob_type&0x00ff|(t<<8); }

	void MoveTo(short x, short y)	{ ob_x=x; ob_y=y; }
	void MoveBy(short x, short y)	{ ob_x+=x; ob_y+=y; }

	short States() const		{ return ob_state; }
	short Flags() const			{ return ob_flags; }

	short X() const								{ return ob_x; }
	short Y() const								{ return ob_y; }
	void Resize(short w, short h)				{ ob_width=w; ob_height=h; }
	short Width() const							{ return ob_width; }
	short Height() const						{ return ob_height; }

	char* ImageBitmap(bool Mask=FALSE) const;
	short ImageHeight() const;
	short ImageWidth() const;
	void SetImageBitmap(char* bitmap, short w, short h, bool Mask=FALSE);
	char* Text() const;
	void SetText(char* str);

	int FillPattern() const;
	void FillPattern(int);

	bool Transparent() const;
	void Transparent(bool);

	int Font() const;
	void Font(int font);

	int ForeCol() const;
	void ForeCol(int colourindex);

	int BackCol() const;
	void BackCol(int colourindex);

	int BorderCol() const;
	void BorderCol(int colourindex);

	int BorderWidth() const;
	void BorderWidth(int width);

private:
	bool State(short s, bool on) { bool t=ob_state&s; if (on)
			ob_state|=s; else ob_state&=~s; return !!t; }
	bool States(short s) const	{ return !!(ob_state&s); }

	bool Flag(short f, bool on) { bool t=ob_flags&f; if (on)
			ob_flags|=f; else ob_flags&=~f; return !!t;}
	bool Flags(short f) const	{ return !!(ob_flags&f); }
};

#endif
