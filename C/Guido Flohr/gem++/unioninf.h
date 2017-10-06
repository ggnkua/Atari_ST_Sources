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

#ifndef _UNIONINF_H
#define _UNIONINF_H

// FIXME: Macro BLOWMEUP should go into sysdeps.h.
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <system.h>

#include <yd.h>

// Depending on what you want to know you have to pass certain opcodes to
// appl_getinfo knows certain opcodes as its first argument.  Normally a
// client programmer doesn't have to care about that but for future extensions
// that aren't treated by this class it might be important.
enum appl_getinfo_opcode {
  // Dept. of (large) system fonts.
  APPL_GETINFO_FONT = 0,
  // Small system font.
  APPL_GETINFO_SMALL_FONT = 1,
  // Dept. of colors.
  APPL_GETINFO_COLORS = 2,
  // AES crude NLS.
  APPL_GETINFO_LANGUAGE = 3,
  // OS features.
  APPL_GETINFO_OS1 = 4,
  APPL_GETINFO_OS2 = 5,
  APPL_GETINFO_OS3 = 6,
  APPL_GETINFO_RESERVED = 7,
  // Souris.
  APPL_GETINFO_MOUSE = 8,
  // Amuse gueule and other menu stuff.
  APPL_GETINFO_MENU = 9,
  // Beurk!  AES "Shell-Handling".
  APPL_GETINFO_SHELL_WRITE = 10,
  // In this case it's "Look _at_ the window...".
  APPL_GETINFO_WINDOWS = 11,
  // AES messages.
  APPL_GETINFO_MESSAGES = 12,
  // Objects.
  APPL_GETINFO_OBJECTS = 13,
  // Forms.
  APPL_GETINFO_FORMS = 14,
  // Number of opcodes.
  APPL_GETINFO_OPCODES = 15
};

union ApplGetInfo {
  struct {
    // Dept. of fonts.
    unsigned FontHeight;   // Font height in pixels.
    unsigned FontID;       // VDI font handle.
    unsigned FontType;     // Type of font (see enumeratioin above.
    unsigned junk1;        // All junk members are reserved for future use.
    // Small system font.
    unsigned SmallFontHeight;
    unsigned SmallFontID;
    unsigned SmallFontType;
    unsigned junk2;

    // Dept. of colors.
    unsigned VDIDevice;
    unsigned ObjectColors;
    unsigned HasColorIcons;
    unsigned NewResource;
    // Crude NLS.
    unsigned Language;
    unsigned junk3[3];

    // OS features.
    unsigned PreemptiveMultitasking;
    unsigned ConvertingApplFind;
    unsigned HasApplSearch;
    unsigned HasRcFix;
    unsigned HasObjcXFind;
    unsigned junk4;
    unsigned HasMenuClick;
    unsigned HasShellRWDef;
    unsigned HasApplXRead;
    unsigned HasShellXGet;
    unsigned HasMenuXBar;
    unsigned HasInstallMenuBar;
    unsigned junk5[4];

    // Souris.
    unsigned HasGrafXMouse;
    unsigned HasIndividualMouseForm;
    unsigned junk6[2];

    // Amuse gueule and other menu stuff.
    unsigned HasSubMenu;
    unsigned HasPopUp;
    unsigned HasScrollMenu;
    unsigned HasMenuXSelected;
    // Beurk!  AES "Shell-Handling".
    BLOW_ME_UP
    unsigned MTOSCompWDoExecuteBits: 8;
    unsigned MaxShellWDoExecute: 8;
    unsigned DumbDeafBlindShellWrite;
    unsigned BlockingShellWrite;
    unsigned ARGVShellWrite;
    // In this case it's "Look _at_ the window...".
    BLOW_ME_UP   // out1.
    unsigned junk7: 7;
    unsigned HasWFUniconify: 1;
    unsigned HasWFIconify: 1;
    unsigned HasWFBottom: 1;
    unsigned HasWFBEvent: 1;
    unsigned HasWFOwner: 1;
    unsigned HasWFDColor: 1;
    unsigned HasWFColor: 1;
    unsigned HasWFNewdesk: 1;
    unsigned WFTopGets2ndWindow: 1;
    unsigned junk8;   // out2.
    BLOW_ME_UP        // out3.
    unsigned junk9: 12;
    unsigned HasHotCloseBox: 1;
    unsigned HasShiftClickBackdrop: 1;
    unsigned HasBackdrop: 1;
    unsigned HasIconifier: 1;
    unsigned HasWindowUpdateCheckSet;  // out4.
    // The wicked messages.
    BLOW_ME_UP
    unsigned junk10: 6;
    unsigned HasWMAlliconify: 1;
    unsigned HasWMUniconify: 1;
    unsigned HasWMIconify: 1;
    unsigned HasWMBottom: 1;
    unsigned HasChExit: 1;
    unsigned HasMTOSChRes: 1;
    unsigned HasAPTerm: 1;
    unsigned HasWMOntop: 1;
    unsigned HasWMUntopped: 1;
    unsigned HasWMNewtop: 1;
    unsigned junk11[2];
    unsigned HasIconCoordinates;
    // Objects.
    unsigned Has3DObjects;
    unsigned HasObjcSysVar;
    unsigned HasGDOSTedInfo;
    BLOW_ME_UP
    unsigned junk12: 13;
    unsigned HasWhiteBakUnderscore: 1;
    unsigned HasG_PopUp: 1;
    unsigned HasG_SWButton: 1;
    // Forms.
    unsigned HasFlyDials;
    unsigned HasKeyTables;
    unsigned HasLastCursorPos;
    unsigned junk14;  // Thanks Marx the compiler doesn't insist on #13.
  } info;
  unsigned RawOut[APPL_GETINFO_OPCODES][4];
};
#endif  not _UNIONINF_H
