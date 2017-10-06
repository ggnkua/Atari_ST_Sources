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

#include <String.h>
#include <strstream.h>

#include <sys/time.h>
#include <unistd.h>
#ifdef HAVE_ERRNO_H
# include <errno.h>
#endif
#include <limits.h>

#ifdef HAVE_STRING_H
# include <string.h>
#endif
extern int errno;

#include <time.h>

#include <gemap.h>
#include <gema.h>
#include <gemw.h>
#include <gemt.h>
#include <gemal.h>
#include <gemscreen.h>
#include <gemprot.h>
#include <geminfo.h>

#ifndef FIS_SOLID
# define FIS_SOLID 1
#endif

#include "LoadSample.DLList.h"

long int _stksize = 32 * 1024;  // We use the String class.

#include "vdiload.h"
#include "xtkopt.h"

class MADLoadWindow : public GEMwindow, public GEMtimer
{
public:
  MADLoadWindow (GEMactivity& in, ToolkitOptions& options);
  ~MADLoadWindow ();
  
  virtual bool Create ();
  virtual bool ScrollByBlitting () const;
  virtual GEMfeedback UserClosed ();
  virtual void Redraw (const GRect& area);
  virtual void UserResized (int w, int h);
  virtual void UserFulled ();
  virtual void UserMoved (int x, int y);
  virtual GEMfeedback Expire (const GEMevent&);
  void VCalculateGEMvalues() {};
  void VCalculateValues() {};
  virtual void VFlushSlider() {};
  void HCalculateGEMvalues() {};
  void HCalculateValues() {};
  virtual void HFlushSlider() {};
    
private:
  VDI Vdi;
  LoadSampleDLList LoadList;
  ToolkitOptions& Options;
  VDILoadWindow VLoadWindow;
  int ScanRate;
  char* Label;
  char* InfoLine;
  int CellHeight;
  int ForegroundColor;
  int BackgroundColor;
  int jumpscroll;
  clock_t last_update;
};

static GEMinfo AESinfo;

MADLoadWindow::MADLoadWindow (GEMactivity& in, ToolkitOptions& options) :
    GEMwindow (in, NAME | CLOSER | FULLER | MOVER | SIZER | HSLIDE | VSLIDE
        | (options.Info () ? INFO : 0)
        | (AESinfo.HasIconifier () ? SMALLER : 0)),
    GEMtimer (in, 0),
    Vdi (),
    LoadList (),
    Options (options),
    VLoadWindow (Vdi, LoadList, Options.Scale ()),
    ScanRate (Options.Update ()),
    InfoLine (NULL),
    last_update (clock ())
  {
    GRect Work = WorkRect ();
    LineHeight (1);
    ColumnWidth (1);
    SetTopLine (0);
    SetLeftColumn (0);
    SetTotalLines (INT_MAX);
    SetTotalColumns (INT_MAX);
    SetVisibleLines (INT_MAX);
    SetVisibleColumns (INT_MAX);
    Work.Resize (100, 100);
    SetWorkRect (Work);
    Move (32, 32);
    Label = Options.Label ();
    
    Vdi.sf_interior (FIS_SOLID);
    Vdi.sf_perimeter (0);
    int dummy;
    Vdi.st_alignment (TA_LEFT, TA_TOP, &dummy, &dummy);
    
    GRect Border = BorderRect ();
    if (Options.Width () > 0)
      Border.g_w = Options.Width ();
    if (Options.Height () > 0)
      Border.g_h = Options.Height ();
    GEMinfo Info;
    const GRect& Desktop = Info.Desktop ();

    if (Options.LeftRef ())
      Border.g_x = Options.XOffset ();
    else if (Options.RightRef ())
      Border.g_x = Desktop.g_x + Desktop.g_w - Options.XOffset () - Border.g_w;
      
    if (Options.TopRef ())
      Border.g_y = Options.YOffset ();
    else if (Options.BottomRef ())
      Border.g_y = Desktop.g_y + Desktop.g_h - Options.YOffset () - Border.g_h;
      
    SetBorderRect (Border);
    
    Work = WorkRect ();
    int attrib[10];
    Vdi.qt_attributes (attrib);
    CellHeight = attrib[9];
    Work.g_h -= CellHeight;
    Work.g_y += CellHeight;
    
    VLoadWindow.SetWorkRect (Work);
    
    BackgroundColor = Options.BackgroundColor ();
    ForegroundColor = Options.ForegroundColor ();
    VLoadWindow.SetBackgroundColor (BackgroundColor);
    VLoadWindow.SetForegroundColor (ForegroundColor);
    VLoadWindow.SetHighlightColor (Options.HighlightColor ());
    
    jumpscroll = Options.Jumpscroll ();
    
    if (Options.Title () != NULL)
      SetName (Options.Title ());
    if (Options.Info ())
      SetInfoText ("0.0");
}
    
MADLoadWindow::~MADLoadWindow () 
{ 
  if (InfoLine) delete InfoLine; 
}
  
bool MADLoadWindow::Create ()
{
  bool retval = GEMwindow::Create ();
  if (IsCreated ()) {
    (void) wind_set (Handle (), WF_HSLSIZE, 1000, 0, 0, 0);
    (void) wind_set (Handle (), WF_VSLSIZE, 1000, 0, 0, 0);
    (void) wind_set (Handle (), WF_HSLIDE, 0, 0, 0, 0);      
    (void) wind_set (Handle (), WF_VSLIDE, 0, 0, 0, 0);
  }
  return retval;
}
  
bool MADLoadWindow::ScrollByBlitting () const
{
  return false;
}
    
GEMfeedback MADLoadWindow::UserClosed () 
{ 
  return EndInteraction; 
}
  
void MADLoadWindow::Redraw (const GRect& area)
{
  Vdi.s_clip (1, area);
  if (IsIconified ()) {
    GRect Work;
    wind_get (Handle (), WF_WORKXYWH, &Work.g_x, &Work.g_y, &Work.g_w, &Work.g_h);
    Vdi.swr_mode (MD_REPLACE);
    Vdi.sf_color (BackgroundColor);
    Vdi.bar (area);
    // Draw some more or less random graph.
    Vdi.sf_color (BackgroundColor);
    int xy[20];
    xy[0] = Work.g_x;
    xy[1] = Work.g_y + (3 * Work.g_h) / 4;
    xy[2] = Work.g_x + Work.g_w / 8;
    xy[3] = Work.g_y + Work.g_h / 2;
    xy[4] = Work.g_x + Work.g_w / 4;
    xy[5] = Work.g_y + (3 * Work.g_h) / 8;
    xy[6] = Work.g_x + Work.g_w / 2;
    xy[7] = Work.g_y + (3 * Work.g_h) / 4;
    xy[8] = Work.g_x + (5 * Work.g_w) / 8;
    xy[9] = Work.g_y + Work.g_h / 4;
    xy[10] = Work.g_x + (3 * Work.g_w) / 4;
    xy[11] = Work.g_y + Work.g_h / 2;
    xy[12] = Work.g_x + (7 * Work.g_w) / 8;
    xy[13] = Work.g_y + Work.g_h / 8;
    xy[14] = Work.g_x + Work.g_w;
    xy[15] = Work.g_y + (3 * Work.g_h) / 8;
    xy[16] = Work.g_w + Work.g_w;
    xy[17] = Work.g_y + Work.g_h;
    xy[18] = Work.g_x;
    xy[19] = Work.g_y + Work.g_h;
    Vdi.fillarea (10, xy);
    // 3 scale lines.
    Vdi.swr_mode (MD_XOR);
    GRect ScaleLine (Work);
    ScaleLine.g_h = 1;
    ScaleLine.g_y = Work.g_y;
    for (int i = 0; i < 3; i++) {
      ScaleLine.MoveDown (((i + 1) * Work.g_h) / 4);
      GRect Visible = ScaleLine & area;
      if (Visible)
        Vdi.pline (2, Visible);
    }
    return;
  }
  GRect Work = WorkRect ();
  GRect MyRedrawArea = Work;
  MyRedrawArea.g_h = CellHeight;
  MyRedrawArea &= area;
  if (MyRedrawArea) {
    Vdi.swr_mode (MD_REPLACE);
    Vdi.sf_color (BackgroundColor);
    Vdi.bar (MyRedrawArea);
    if (Label) {
      if (ForegroundColor == WHITE || ForegroundColor == BackgroundColor) {
        Vdi.swr_mode (MD_XOR);
      } else {
        Vdi.swr_mode (MD_TRANS);
      }
      Vdi.st_color (ForegroundColor);
      Vdi.gtext (Work.g_x, Work.g_y, Label);
    }
  }
  if (Label) {
    Work.g_y += CellHeight;
    Work.g_h -= CellHeight;
  }
  Work &= area;
  VLoadWindow.Redraw (Work);
}

void MADLoadWindow::UserResized (int w, int h)
{
  GEMwindow::UserResized (w, h);
  GRect Work = WorkRect ();
  if (Label) {
    Work.g_y += CellHeight;
    Work.g_h -= CellHeight;
  }
  VLoadWindow.SetWorkRect (Work);
  RedrawOverlaps (WorkRect ());
}
    
void MADLoadWindow::UserFulled ()
{
  GEMwindow::UserFulled ();
  GRect Work = WorkRect ();
  Work.g_y += CellHeight;
  Work.g_h -= CellHeight;
  VLoadWindow.SetWorkRect (Work);
  RedrawOverlaps (WorkRect ());
}
    
void MADLoadWindow::UserMoved (int x, int y)
{
  GEMwindow::UserMoved (x, y);
  GRect Work = WorkRect ();
  Work.g_y += CellHeight;
  Work.g_h -= CellHeight;
  VLoadWindow.SetWorkRect (Work);
  RedrawOverlaps (WorkRect ());
}  
    
GEMfeedback MADLoadWindow::Expire (const GEMevent& event)
{
  bool jumped = false;
  bool do_redraw = (IsOpen () && !IsIconified ());
  
  int SavedScale = VLoadWindow.GetScale ();
  if (ScanRate * 1000 != Interval ())
    Interval (ScanRate * 1000);
  
  if (LoadList.length () >= (WorkRect ()).g_w) {
    int jump = jumpscroll;
    if (jumpscroll <= 0)
      jump = (WorkRect ()).g_w / 2;
    if (jump <= 0)
      jump = 1;
      
    VLoadWindow.CutList ((WorkRect ()).g_w - jump);
    
    if (do_redraw && SavedScale == VLoadWindow.GetScale ()) {
      GRect BlitArea (WorkRect ());
      GEMinfo Info;
      BlitArea &= Info.Desktop ();
      if (Label) {
        BlitArea.g_y += CellHeight;
        BlitArea.g_h -= CellHeight;
      }
      Vdi.s_clip (0, BlitArea);
     
      graf_mouse (M_OFF, NULL);  // Turn off mouse pointer.
      wind_update (BEG_UPDATE);  // Give the finger to intruders.
        
      GRect box;                 // For the rectangle list.
        
      wind_get (Handle (), WF_FIRSTXYWH, &box.g_x, &box.g_y,
                                         &box.g_w, &box.g_h);
        
      while (box) {  // Fails if box is empty.
        GEMscreen BlitChunk (Vdi, (int*) (box & BlitArea)); // Get Intersection.
        BlitChunk.g_x += jump;
        BlitChunk.g_w -= jump;
        if (BlitChunk)
          BlitChunk.MoveLeft (jump); // Push it to the left.
        wind_get (Handle (), WF_NEXTXYWH, &box.g_x, &box.g_y,  // Next please!
                                          &box.g_w, &box.g_h);
      }
        
      graf_mouse (M_ON, NULL);
      wind_update (END_UPDATE);
        
      jumped = true;
    }
  }

  VLoadWindow.GetLoad ();
  if (Options.Info ()) {
    if (InfoLine)
      delete InfoLine;
    ostrstream os;
    if (Options.Fixed ())
      os.setf (ios::fixed, ios::floatfield);
    os.precision (Options.Precision ());
    os << (LoadList.rear ()).Load () << ends;
    InfoLine = os.str ();
    SetInfoText (InfoLine);
  }
  if (do_redraw && SavedScale == VLoadWindow.GetScale ()) {
    GRect area = WorkRect ();
    area.g_x += LoadList.length () - 1;
    if (jumped)
      area.g_w -= (LoadList.length () - 1);
    else
      area.g_w = 1;
    if (Label) {
      area.g_y += CellHeight;
      area.g_h -= CellHeight;
    }
    RedrawOverlaps (area);
  } else {
    RedrawOverlaps (WorkRect ());
  }
  
  // Check if we've missed any timer events.
  last_update += ScanRate * CLOCKS_PER_SEC;
  clock_t now = clock ();
  if ((double) (now) - (double) (last_update) 
      >= (double) (ScanRate * CLOCKS_PER_SEC))
    return (Expire (event));
  else
    last_update = now;
  
  return ContinueInteraction;
}

int main (int argc, char* const* argv)
{
  GEMapplication LoadApp;
  GEMactivity LoadAct;
  AESprotocol MyAESprotocol (LoadAct);
  
  ToolkitOptions Options (argc, argv);
  
  double testload;
  if (/*getloadavg (&testload, 1)*/ 1 < 0) {
    GEMalert GetLoadAvgFailed ("getloadavg:|%s", "Error");
    GetLoadAvgFailed.Alertf (1, strerror (errno));
    return EXIT_FAILURE;
  }
  
  MADLoadWindow LoadWindow (LoadAct, Options);
  
  LoadWindow.Open ();
  
  if (!LoadWindow.IsOpen ())
    return EXIT_FAILURE;

  LoadAct.Do ();
  return EXIT_SUCCESS;
}
