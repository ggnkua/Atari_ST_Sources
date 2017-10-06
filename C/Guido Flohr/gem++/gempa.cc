/////////////////////////////////////////////////////////////////////////////
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#include "gempa.h"
#include "contract.h"
#include <minmax.h>


GEMpanarea::GEMpanarea() :
  actualTopLine(0),actualLeftColumn(0),
  visibleLines(1),visibleColumns(1),
  totalLines(1),totalColumns(1)
{
}

GEMpanarea::GEMpanarea(int vl, int tl, int vc, int tc) :
  actualTopLine(0),actualLeftColumn(0),
  visibleLines(vl),visibleColumns(vc),
  totalLines(tl),totalColumns(tc)
{
}

GEMpanarea::~GEMpanarea()
{
}

void GEMpanarea::SetVisibleLines(int noOfLines)
{
  // Require(noOfLines >= 0);
  // Require(noOfLines <= totalLines);
  if (noOfLines < 0)
    noOfLines = 0;
  else if (noOfLines > totalLines)
    totalLines = noOfLines;
  
  visibleLines = noOfLines;
  
  if (actualTopLine > totalLines - visibleLines)
    actualTopLine = totalLines - visibleLines;
}

void GEMpanarea::SetTotalLines(int noOfLines)
{
  // Require(noOfLines >= 0);
  if (noOfLines < 0)
    noOfLines = 0;

  totalLines=noOfLines;

  if (noOfLines < visibleLines) {
    visibleLines=totalLines;
  }

  if (actualTopLine > totalLines - visibleLines) {
    actualTopLine=totalLines - visibleLines;
  }
}

void GEMpanarea::SetTopLine(int noOfLine)
{
  if (noOfLine < 0)
    noOfLine=0;

  if (noOfLine > totalLines - visibleLines)
    noOfLine=totalLines - visibleLines;
  
  if (actualTopLine != noOfLine) {
    actualTopLine=noOfLine;
  }
}

void GEMpanarea::SetVisibleColumns(int noOfColumns)
{
  // Require(noOfColumns >= 0);
  // Require(noOfColumns <= totalColumns);
  if (noOfColumns < 0)
    noOfColumns = 0;
  else if (noOfColumns > totalColumns)
    totalColumns = noOfColumns;
    
  if (visibleColumns != noOfColumns) {
    visibleColumns=noOfColumns;
    
    if (actualLeftColumn > totalColumns - visibleColumns)
      actualLeftColumn=totalColumns - visibleColumns;
  }
}

void GEMpanarea::SetTotalColumns(int noOfColumns)
{
  // Require(noOfColumns >= 0);
  if (noOfColumns < 0)
    noOfColumns = 0;
    
  totalColumns=noOfColumns;

  if (noOfColumns < visibleColumns) {
    visibleColumns=totalColumns;
  }

  if (actualLeftColumn > totalColumns - visibleColumns) {
    actualLeftColumn=totalColumns - visibleColumns;
  }
}

void GEMpanarea::SetLeftColumn(int noOfColumn)
{
  if (noOfColumn < 0)
    noOfColumn=0;

  if (noOfColumn > totalColumns - visibleColumns)
    noOfColumn=totalColumns - visibleColumns;
  
  if (actualLeftColumn != noOfColumn) {
    actualLeftColumn=noOfColumn;
  }
}


void GEMpanarea::LineUp()
{
  SetTopLine(actualTopLine-VLineAmount());
}

void GEMpanarea::LineDown()
{
  SetTopLine(actualTopLine+VLineAmount());
}

void GEMpanarea::PageUp()
{
  SetTopLine(actualTopLine-VPageAmount());
}

void GEMpanarea::PageDown()
{
  SetTopLine(actualTopLine+VPageAmount());
}

  
void GEMpanarea::ColumnLeft()
{
  SetLeftColumn(actualLeftColumn-HColumnAmount());
}

void GEMpanarea::ColumnRight()
{
  SetLeftColumn(actualLeftColumn+HColumnAmount());
}

void GEMpanarea::PageLeft()
{
  SetLeftColumn(actualLeftColumn-HPageAmount());
}

void GEMpanarea::PageRight()
{
  SetLeftColumn(actualLeftColumn+HPageAmount());
}

int GEMpanarea::VLineAmount()
{
  return 1;
}

int GEMpanarea::HColumnAmount()
{
  return 1;
}

int GEMpanarea::VPageAmount()
{
  return visibleLines;
}

int GEMpanarea::HPageAmount()
{
  return visibleColumns;
}

void GEMpanarea::HGetScaledValue(int scale, int& size, int& position)
{
  size=
    totalColumns
      ? long(scale)*visibleColumns/totalColumns
      : scale;

  position=
    totalColumns==visibleColumns
      ? 0
      : actualLeftColumn*(scale-size)/(totalColumns-visibleColumns);
}

void GEMpanarea::VGetScaledValue(int scale, int& size, int& position)
{
  size=
    totalLines
      ? long(scale)*visibleLines/totalLines
      : scale;

  position=
    totalLines==visibleLines
      ? 0
      : actualTopLine*(scale-size)/(totalLines-visibleLines);
}

