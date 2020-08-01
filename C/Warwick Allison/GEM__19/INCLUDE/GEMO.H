/////////////////////////////////////////////////////////////////////////////
//
//  GEMobject
//
//  A GEMobject is a true C++ object which are components of GEMforms.
//  It has basic abilities similar to the abilities of GEM OBJECTs, but
//  with the ability to be "called back", or "touched", and so to act
//  on this stimulus.  As a base class, a GEMobject does not actually
//  do anything in response - this is for derived classes.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMo_h
#define GEMo_h

#include <gemrawo.h>
#include <gemf.h>

class GEMevent;

class GEMobject
// A GEMobject represents an extension of the OBJECT concept.
// But, because GEM uses ARRAYS of OBJECTs, we cannot extend them :-(.
// We make do by coping functionality.
{
public:
	GEMobject(GEMform&, int RSCindex);
	virtual ~GEMobject();

	bool Selected(bool s)						{ return me().Selected(s); }
	bool Selected() const						{ return me().Selected(); }
	void Select()								{ me().Select(); }
	void Deselect()								{ me().Deselect(); }
	bool Crossed(bool s)						{ return me().Crossed(s); }
	bool Crossed() const						{ return me().Crossed(); }
	void Cross()								{ me().Cross(); }
	void Uncross()								{ me().Uncross(); }
	bool Checked(bool s)						{ return me().Checked(s); }
	bool Checked() const						{ return me().Checked(); }
	void Check()								{ me().Check(); }
	void Uncheck()								{ me().Uncheck(); }
	bool Disabled(bool s)						{ return me().Disabled(s); }
	bool Disabled() const						{ return me().Disabled(); }
	void Disable()								{ me().Disable(); }
	void Enable()								{ me().Enable(); }
	bool Outlined(bool s)						{ return me().Outlined(s); }
	bool Outlined() const						{ return me().Outlined(); }
	void Outline()								{ me().Outline(); }
	void Unoutline()							{ me().Unoutline(); }
	bool Shadowed(bool s)						{ return me().Shadowed(s); }
	bool Shadowed() const						{ return me().Shadowed(); }
	void Shadow()								{ me().Shadow(); }
	void Unshadow()								{ me().Unshadow(); }

	bool Selectable(bool f)						{ return me().Selectable(f); }
	bool Selectable() const						{ return me().Selectable(); }
	bool Default(bool f)						{ return me().Default(f); }
	bool Default() const						{ return me().Default(); }
	bool Exit(bool f)							{ return me().Exit(f); }
	bool Exit() const							{ return me().Exit(); }
	bool Editable(bool f)						{ return me().Editable(f); }
	bool Editable() const						{ return me().Editable(); }
	bool RadioButton(bool f)					{ return me().RadioButton(f); }
	bool RadioButton() const					{ return me().RadioButton(); }

	bool LastObject(bool f)						{ return me().LastObject(f); }
	bool LastObject() const						{ return me().LastObject(); }

	bool TouchExit(bool f)						{ return me().TouchExit(f); }
	bool TouchExit() const						{ return me().TouchExit(); }
	bool HideTree(bool f)						{ return me().HideTree(f); }
	bool HideTree() const						{ return me().HideTree(); }

	short States() const						{ return me().States(); }
	short Flags() const							{ return me().Flags(); }

	void MoveTo(short x, short y)				{ me().MoveTo(x,y); }
	void MoveBy(short x, short y)				{ me().MoveBy(x,y); }

	short X() const								{ return me().X(); }
	short Y() const								{ return me().Y(); }
	void Resize(short w, short h);
	short Width() const							{ return me().Width(); }
	short Height() const						{ return me().Height(); }
	virtual void SetWidth(short w);
	virtual void SetHeight(short h);

	// The ob_spec functions below call the above type/ob_spec methods.

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

	bool ContainsPoint(int x, int y) const;

	virtual int Type() const;
	virtual void Type(int);
	virtual int ObjectSpecific() const;
	virtual void ObjectSpecific(int);

	void RedrawParent();
	void Redraw();

	// Child stuff...
	void Detach(); // Remove from parent child-list
	void Attach(GEMobject& o); // Attach child to self
	void Attach(int RSCindex); // Attach child to self

	// RSCindex-based
	int NumberOfChildren() const;
	int FirstChild() const; // -1 = none
	int NextChild(int after) const; // -1 = none.
	GEMrawobject* Child(int) const;
	int Index() const { return myindex; }

	// GEMobject-based
	int NumberOfComponents() const;
	GEMobject* FirstComponent() const;
	GEMobject* NextComponent(const GEMobject*) const;

	// Call backs...  (x,y) are relative, GEMevent contains absolute.
	virtual GEMfeedback Touch(int x, int y, const GEMevent& e);

	void GetAbsoluteXY(int& x, int& y) const;

protected:
	unsigned long original_ob_spec;
	GEMform& form;
	int myindex;

private:
	GEMrawobject& me() const { return form[myindex]; }
};


#endif
