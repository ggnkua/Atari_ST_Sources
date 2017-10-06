/////////////////////////////////////////////////////////////////////////////
//
//  GEMpanarea
//
//  A GEMpanarea is an abstract sliding window.
//
//  This file is Copyright 1992 by Warwick W. Allison,
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////


#ifndef GEMpa_h
#define GEMpa_h


class GEMpanarea
{
public:
	GEMpanarea();
	GEMpanarea(int visiblelines, int totallines, int visiblecolumns, int totalcolumns);
	virtual ~GEMpanarea();

	virtual void SetVisibleLines(int noOfLines);
	virtual void SetTotalLines(int noOfLines);
	virtual void SetTopLine(int noOfLine);
	virtual void SetVisibleColumns(int noOfColumns);
	virtual void SetTotalColumns(int noOfColumns);
	virtual void SetLeftColumn(int noOfColumn);

	int TotalLines() const { return totalLines; }
	int TotalColumns() const { return totalColumns; }

	int VisibleLines() const { return visibleLines; }
	int VisibleColumns() const { return visibleColumns; }

	int TopLine() const { return actualTopLine; }
	int LeftColumn() const { return actualLeftColumn; }

	void LineUp();
	void LineDown();
	void PageUp();
	void PageDown();
	virtual int VPageAmount();
	virtual int VLineAmount();
	
	void ColumnLeft();
	void ColumnRight();
	void PageLeft();
	void PageRight();
	virtual int HPageAmount();
	virtual int HColumnAmount();

	void VGetScaledValue(int scale, int& size, int& position);
	void HGetScaledValue(int scale, int& size, int& position);

private:
	int actualTopLine,actualLeftColumn;
	int visibleLines,visibleColumns;
	int totalLines,totalColumns;
};


#endif
