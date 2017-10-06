// GEM++.
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
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
//
// $Date$
// $Revision$
// $State$
//
//
// A GEMinfo is an object that provides useful information mostly for the
// library core itself but also for the client programmer.  It basically
// gives the information that appl_getinfo() (if available) offers.
//
// Looks like a monster class but it's actually easy to use.

#ifndef _GEMINFO_H
#define _GEMINFO_H

#ifndef _LIBGEMPP
#include <unioninf.h>
#include <yd.h>
#include <grect.h>
#else
#include "unioninf.h"
#include "yd.h"
#include "grect.h"
#endif

class GEMinfo
{
public:
  GEMinfo ();

  unsigned int AESVersion () const { return ((unsigned) Version); }
  unsigned int AESMajorVersion () const { return ((unsigned int) MajorVersion); }
  unsigned int AESMinorVersion () const { return ((unsigned int) MinorVersion); }

  unsigned int AllWindowParts () const; // Returns all possible window parts.
  
  const GRect& Desktop () const { return desktop; }

  //////////////////////////////////////////////////////////////////////////////////
  // Low-level interface                                                          //
  // ===================                                                          //
  // These methods provide the values made available by appl_info          //
  // or default values if appl_info itself is not available.  Sometimes           //
  // I'm not so sure what the values really mean.  Most of the information        //
  // is taken from the TOS hypertext by Rolf Kotzian (Rolf_Kotzian@pb2.maus.de).  //
  // As you can see it's quite a lot of information.  The private implementation  //
  // calls appl_getinfo with all possible opcodes and stuffs the returned values  //
  // in the corresponding fields of the array member of the union FEATURES.  Be   //
  // prepared that I've mixed up some of the fields (they're too many of them     //
  // to check every single value).  If you use a value, test it first and let     //
  // me know if I have to change the order of the members in the union resp.      //
  // in the bitfield member of the union.                                         //
  //////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////
  // Dept. of system fonts.  //
  /////////////////////////////
  unsigned int FontHeight () const; // AES-Font height in pixel.
  unsigned int FontID () const;   // Corresponding VDI handle.
  enum { SYSTEM_FONT_TYPE = 0, FSM_FONT_TYPE = 1 };
  unsigned int FontType () const; // Font type (see enumeration for range).

  //////////////////////////////////////////
  // The same for the small system font.  //
  //////////////////////////////////////////
  unsigned int SmallFontHeight () const;
  unsigned int SmallFontID () const;
  unsigned int SmallFontType () const;

  ///////////////////////
  // Dept. of colors.  //
  ///////////////////////
  unsigned int VDIDevice () const;    // Handle of the AES' VDI workstation.
  bool ObjectColors () const;   // Object colors available?
  bool HasColorIcons () const;        // Color icons available?
  bool NewResource () const;    // New resource format understood?

  /////////////////////////////
  // Crude AES NLS support.  //
  /////////////////////////////
  enum {
    AES_LANG_ENGLISH = 0,
    AES_LANG_DEUTSCH = 1,
    AES_LANG_FRANCAIS = 2,
    AES_LANG_DUMB = 3,
    AES_LANG_ESPANOL = 4,
    AES_LANG_ITALIANO = 5,
    AES_LANG_SVENSKA = 6
  };
  unsigned int Language() const;// Returns the language of the AES.  Remember
                                       // that this doesn't necessarily correspond
                                       // the the user's native language.  My TT
                                       // was bought in France...  Use the
                                       // documented NLS envariables instead!

  ///////////////////////////////////////////////////
  // Features of the underlying operating system.  //
  ///////////////////////////////////////////////////
  bool PreemptiveMultitasking () const; // Returns true for preemptive multitasking.
  bool ConvertingApplFind () const;   // True if appl_find() converts MiNT/AES-IDs.
  bool HasApplSearch () const;  // True if appl_search() available.
  bool HasRcFix () const;       // True if rsrc_rcfix() available.
  bool HasObjcXFind () const;   // True if objc_xfind() available.
  bool HasMenuClick () const;   // True if menu_click() available.
  bool HasShellRWDef () const;  // True if shel_rdef() and shel_wdef() available.
  bool HasApplXRead () const;   // True if appl_read(-1) works.
  bool HasShellXGet () const;   // True if shel_get(-1) works.
  bool HasMenuXBar () const;    // True if menu_bar(-1) works.
#ifndef MENU_INSTL
# define MENU_INSTL 100                // Actually, I'm not so sure...
#endif
  bool HasInstallMenuBar () const;    // True if menu_bar(MENU_INSTL) works.

  //////////////
  // Souris.  //
  //////////////
  bool HasGrafXMouse () const;  // True if graf_mouse modes 258 - 260 available.
  bool HasIndividualMouseForm () const; // True if AES tracks mouse form for each
                                         // individual application

  /////////////////////////////////////////
  // Amuse gueule and other menu stuff.  //
  /////////////////////////////////////////
  bool HasSubMenu () const;     // True if sub menus available.
  bool HasPopUp () const;       // True if popups available.
  bool HasScrollMenu () const;  // True if scrollable menues available.
  bool HasMenuXSelected () const;     // True if extended MN_SELECTED message
                                       // supported.

  ////////////////////////////////////
  // Beurk!  AES "Shell-Handling".  //
  ////////////////////////////////////
  unsigned char MTOSCompWDoExecuteBits () const; // Maximum value for sh_wdoex & 0x00ff.
  unsigned char MaxShellWDoExecute () const; // Bits of sh_wdoex & 0xff00 that are treated
                                       // like MultiTOS does.
  bool DumbDeafBlindShellWrite () const; // shel_write (0) invalidates preceding
                                          // calls, i. e. the desktop proceeds
                                          // the current process.
  bool BlockingShellWrite () const;   // sh_write (1) waits for program
                                       // termination.
  bool ARGVShellWrite () const; // True if ARGV via sh_wiscr supported.

  ///////////////////////////////////////////////////
  // In this case it's "Look _at_ the window...".  //
  ///////////////////////////////////////////////////
  bool WFTopGets2ndWindow () const;   // True if wind_get (WF_TOP) returns handle
                                       // of second top window?
                                       // Possible arguments to wind_get/set():
  bool HasWFNewdesk () const;   // WF_NEWDESK.
  bool HasWFColor () const;     // WF_COLOR.
  bool HasWFDColor () const;    // WF_DCOLOR.
  bool HasWFOwner () const;     // WF_OWNER.
  bool HasWFBEvent () const;    // WF_BEVENT.
                                       // Possible arguments to wind_set():
  bool HasWFBottom () const;    // WF_BOTTOM.
  bool HasWFIconify () const;   // WF_ICONIFY.
  bool HasWFUniconify () const; // WF_UNICONIFY.
                                       // Additional window gadgets:
  bool HasIconifier () const;   // SMALLER.
  bool HasHotCloseBox () const; // HOTCLOSEBOX.
  bool HasBackdrop () const;    // BACKDROP.
  bool HasShiftClickBackdrop () const; // Use Shift-Click for backdrop.
  bool HasWindowUpdateCheckSet () const; // True if update `check and set'
                                          // possible: Call it with
                                          // wind_update (BEG_UPDATE | 0x0100)
                                          // resp. BEG_MCTRL | 0x0100.
  bool HasToolBar () const      // Toolbar support.
    { return (MajorVersion >= 4 && MinorVersion >= 1); }

  ///////////////////////////
  // The wicked messages.  //
  ///////////////////////////
                                       // Additional AES messages:
  bool HasWMNewtop () const;    // WM_NEWTOP.
  bool HasWMUntopped () const;  // WM_UNTOPPED.
  bool HasWMOntop () const;     // WM_ONTOP.
  bool HasAPTerm () const;      // AP_TERM.
  bool HasMTOSChRes () const;   // MultiTOS resolution changes.
  bool HasChExit () const;      // CH_EXIT.
  bool HasWMBottom () const;    // WM_BOTTOM.
  bool HasWMIconify () const;   // WM_ICONIFY.
  bool HasWMUniconify () const; // WM_UNICONIFY.
  bool HasWMAlliconify () const;// WM_ALLICONIFY.
  bool HasIconCoordinates () const;   // True if WM_ICONIFY sends
                                       // coordinates of iconified window.
  /////////////////
  // OBJECTs...  //
  /////////////////
  bool Has3DObjects () const;   // True if 3D objects via ob_flags available.
  bool HasObjcSysVar () const;  // True if objc_sysvar() available.
  bool HasGDOSTedInfo () const; // True if GDOS fonts allowed in text fields.
  bool HasG_PopUp () const;     // G_POPUP available.
  bool HasG_SWButton () const;  // G_SWBUTTON available.
  bool HasWhiteBakUnderscore () const; // True if WHITEBAK controls underscores and
                                        // buttons.

  /////////////
  // Forms.  //
  /////////////
  bool HasFlyDials () const;    // "Flydials" available.
  bool HasKeyTables () const;   // Keytables available.
  bool HasLastCursorPos () const;     // Last cursor position returned.

private:
  // Version info.
  static unsigned short int Version;
  static unsigned short int MajorVersion;
  static unsigned short int MinorVersion;
  
  // Calculate desktop dimensions only once.
  static GRect desktop;
  
  // Returns from appl_getinfo.
  static union ApplGetInfo features;
  static bool IsCreated;
};
#endif  not _GEMINFO_H

