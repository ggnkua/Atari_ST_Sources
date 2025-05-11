/////////////////////////////////////////////////////////////////////////////
//
//  GEMslider
//
//  A GEMslider is a GEMobject visualization of a GEMpanarea (ie. a slider)
//
//  This file is Copyright 1992, 1993 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMsl_h
#define GEMsl_h

#include <gemo.h>
#include <gempa.h>


class GEMslider : public GEMobject, public GEMpanarea
{
public:
	GEMslider(GEMform&, int RSCknob, int RSCrack);
	GEMslider(GEMform&, int RSCknob, int RSCrack, int RSCminus, int RSCplus);
	GEMslider(GEMform&, int RSCknob, int RSCrack,
		int RSChminus, int RSChplus,
		int RSCvminus, int RSCvplus);
	~GEMslider();

	// Methods similar to GEMwindow...

	virtual void HFlush();
	virtual void VFlush();

	void GEMtoDOC();

	GEMfeedback Touch(int x, int y, const GEMevent&);

	virtual void SetVisibleLines(int noOfLines);
	virtual void SetTotalLines(int noOfLines);
	virtual void SetTopLine(int noOfLine);
	virtual void SetVisibleColumns(int noOfColumns);
	virtual void SetTotalColumns(int noOfColumns);
	virtual void SetLeftColumn(int noOfColumn);

	int LineDelay(int ms);
	int PageDelay(int ms);

private:
	class SL_Knob* K;
	class SL_Up* U;
	class SL_Down* D;
	class SL_Left* L;
	class SL_Right* R;
	int page_delay,line_delay;
};


#endif
