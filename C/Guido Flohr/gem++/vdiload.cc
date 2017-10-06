// Modular AES Desktop Environment - MADe.
// Copyright (C) 1997 by Guido Flohr <gufl0000@stud.uni-sb.de>.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
//
// $Date$  
// $Revision$  
// $State$  


// MADload.
 
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <math.h>
#include <support.h>
#include <unistd.h>

#include <system.h>

#include "vdiload.h" // Implemented here.

#include <grect.h>
#include <vdi++.h>
#include <bool.h>

#include "LoadSample.DLList.h"

VDILoadWindow::VDILoadWindow (VDI& vdi, 
                              LoadSampleDLList& list, int minscale) :
  Vdi (vdi),
  LoadList (list),
  MinimumScale (minscale),
  Work (0, 0, 0, 0),
  BackgroundColor (BLACK),
  ForegroundColor (WHITE),
  Scale (0),
  PeakSample (0)
{
  if (Vdi.NumberOfPredefinedColors () > 1)
    HighlightColor = 2;
  else
    HighlightColor = 1;
}

void VDILoadWindow::Redraw (const GRect& area)
{
  Vdi.swr_mode (MD_REPLACE);
  int ListLength = LoadList.length ();
  // Although it might seem a little odd we paint from right to left.
  // All methods employed here work faster in this direction.
  
  // If there's space left to the right, draw a box in the background
  // color.
  if (ListLength < Work.g_w) {
    GRect rightbox (Work);
    rightbox.g_x = Work.g_x + ListLength;
    rightbox &= area;
    Vdi.sf_color (BackgroundColor);
    if (rightbox)
      Vdi.bar(rightbox);
  }

  if (ListLength > 0) {
    // Folks, this is C++...  We pervert a GRect to a single line.
    GRect Line = Work;
    Line.g_w = 1;
    Line.g_x += ListLength;
    // First redraw the top parts of the load lines.
    Vdi.sl_color (BackgroundColor);
    for (Pix i = LoadList.last (); i != 0; LoadList.prev (i)) {
      Line.MoveLeft ();
      if (area.g_x > Line.g_x)
        break;
      Line.g_h = Work.g_h - (LoadList (i)).ScaledLoad ();
      GRect Visible = Line & area;
      if (Visible > 0)
        Vdi.pline (2, Visible);
                            // Oops, the prototype for the pline method is
                            // something like "pline (int count, int xy[4])",
                            // so, what's that?  The GRect object is smart
                            // enough that it knows itself when to mutate
                            // to an int-Array! :-)
    }
    // Now redraw the bottom parts of the load lines.
    Line = Work;
    Line.g_x += ListLength;
    Line.g_w = 1;
    Vdi.sl_color (ForegroundColor);
    for (Pix i = LoadList.last (); i != 0; LoadList.prev (i)) {
      if (area.g_x > Line.g_x)
        break;
      Line.MoveLeft ();
      Line.g_y = Work.g_y + Work.g_h - (LoadList (i)).ScaledLoad ();
      GRect Visible = Line & area;
      if (Visible > 0)
        Vdi.pline (2, Visible);
    }
  }

  // Now for the scale lines.
  Vdi.sl_color (HighlightColor);
  if (HighlightColor == ForegroundColor || HighlightColor == BackgroundColor)
    Vdi.swr_mode (MD_XOR);

  GRect Line = Work;
  Line.g_h = 1;
  
  for (int division = 1; division < Scale; division++) {
    // Seems to be better to simply move down the line with a constant offset
    // in every run thru the loop but we want to avoid cumulation of rounding
    // errors in small windows.
    Line.g_y = Work.g_y + (division * Work.g_h) / Scale;
    Line &= area;
    if (Line > 0)
      Vdi.pline (2, Line);
  }
}

void VDILoadWindow::GetLoad ()
{
  double load;
  if (/*getloadavg (&load, 1)*/ -1 < 0)
    load = 0;
      
  LoadSample Sample;
  Sample.Load (load);
  double DScale = (double) (Work.g_h);
  DScale /= Scale;
  Sample.Scale (DScale);
  
  Pix Appended = LoadList.append (Sample);

  if (load > Scale) {
    Scale = (int) (ceil) (load);
    if (PeakSample)
      (LoadList (PeakSample)).IsPeak (false);
    PeakSample = Appended;
    (LoadList (Appended)).IsPeak (true);
    Rescale ();
  }
  
  if (LoadList.length () > Work.g_w)
    CutList (Work.g_w);
}

void VDILoadWindow::Rescale ()
{
  if (PeakSample != 0)
    Scale = (int) (ceil ((LoadList (PeakSample)).Load ()));
  else
    Scale = MinimumScale;
  
  if (Scale < MinimumScale)
    Scale = MinimumScale;
  
  double DFactor = (double) (Work.g_h);
  DFactor /= Scale;
  
  for (Pix i = LoadList.first (); i != 0; LoadList.next (i)) 
    (LoadList (i)).Scale (DFactor);
}

void VDILoadWindow::SetWorkRect (const GRect& NewWork)
{ 
  int SavedHeight = Work.g_h;
  Work = NewWork;
  if (LoadList.length () > Work.g_w)
    CutList (Work.g_w);
  if (SavedHeight != Work.g_h) 
    Rescale (); 
}

void VDILoadWindow::CutList (int length)
{
  int SavedScale = Scale;
  
  bool KickedOutPeak = false;
  while (LoadList.length () > length) {
    const LoadSample& KickOutSample = LoadList.remove_front ();
    if (KickOutSample.IsPeak ()) {
      Scale = 1;
      PeakSample = 0;
      KickedOutPeak = true;
    }
  }
  
  if (KickedOutPeak) {
    // Traverse the list and find out the last element with a load
    // higher than the current scale.  This doesn't necessarily have
    // to be the maximum member.  If the two maximum measured loads were
    // e. g. 2.99 at position 100 and 2.01 at position 200 the latter
    // will get the IsPeak flag since it is the last one to be kicked
    // out and both will lead to a value of 3 for scale.  This will
    // save some expansive list traversals.
    for (Pix i = LoadList.first (); i != 0; LoadList.next (i)) {
      double the_load = (LoadList (i)).Load ();
      if (the_load >= Scale - 1) {
        Scale = (int) (floor (the_load + 1));
        PeakSample = i;
      }
      (LoadList (PeakSample)).IsPeak (true);
    }
  }
  if (SavedScale != Scale)
    Rescale ();
}

