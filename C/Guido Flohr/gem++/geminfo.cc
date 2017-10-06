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
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */
//
// $Date$  
// $Revision$  
// $State$  


// The GEMinfo class.
 
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifdef STDC_HEADERS
# include <string.h>
#else
# include <strings.h>
#endif

#include <gemfast.h>
#include <aesbind.h>

#include <system.h>

#include "geminfo.h" // Implemented here.
#include "aesext.h"  // We need appl_xgetinfo ().

#include <iostream.h>

GEMinfo::GEMinfo ()
{
  if (IsCreated)
    return;
    
  // Get version information.
  Version = _AESversion;

  MajorVersion = 10 * ((Version & 0xf000) >> 12) 
      + ((Version & 0x0f00) >> 8);
  MinorVersion = 10 * ((Version & 0x00f0) >> 4) 
      + (Version & 0x000f);
  
  (void) wind_get (0, WF_WORKXYWH, &desktop.g_x, &desktop.g_y, 
                                   &desktop.g_w, &desktop.g_h);
  
  for (int opcode = 0; opcode < APPL_GETINFO_OPCODES; opcode++) {
    if (appl_getinfo (opcode, 
        (int*) features.RawOut[opcode],
        (int*) features.RawOut[opcode] + 1,
        (int*) features.RawOut[opcode] + 2,
        (int*) features.RawOut[opcode] + 3) == 0) {
	    // appl_getinfo () not available for that opcode.  Usually it will be
	    // sufficent to zero all entries.
	    memset (features.RawOut[opcode], 0, 4 * sizeof (unsigned));
	    switch (opcode) {
	      case APPL_GETINFO_FONT:
	        features.info.FontHeight = 16;
	        features.info.FontID = 1;       // Just a guess... should we return 0?
	        features.info.FontType = SYSTEM_FONT_TYPE;
	        break;
	      case APPL_GETINFO_SMALL_FONT:
	        features.info.FontHeight = 8;
	        features.info.FontID = 2;      // See above.
	        features.info.FontType = SYSTEM_FONT_TYPE;
	      case APPL_GETINFO_COLORS:
	        features.info.VDIDevice = 1;   // Or -1?
	        break;
	      case APPL_GETINFO_LANGUAGE:
	        features.info.Language = AES_LANG_DUMB;
	        break;
	      default:
	        // The memset above should be alright.  I'm not so sure about
	        // APPL_GETINFO_SHELL_WRITE however...
	        break;
	    }
    }
  }
  IsCreated = true;
}

unsigned int GEMinfo::AllWindowParts () const
{
  unsigned int retval = NAME | CLOSER | FULLER | MOVER | INFO | SIZER | UPARROW
    | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE;

/*
  if (features.info.HasHotCloseBox)
    retval |= HOTCLOSEBOX;
  
  if (features.info.HasBackdrop)
    retval |= BACKDROP;
*/
  
  if (features.info.HasIconifier)
    retval |= SMALLER;
  
  return retval;
}

// Static members.
bool GEMinfo::IsCreated = false;
unsigned short int GEMinfo::Version;
unsigned short int GEMinfo::MajorVersion;
unsigned short int GEMinfo::MinorVersion;
union ApplGetInfo GEMinfo::features;
GRect GEMinfo::desktop;

// Implementations.
unsigned int GEMinfo::FontHeight () const
{
  return ((unsigned int) features.info.FontHeight);
}

unsigned int GEMinfo::FontID () const
{
  return ((unsigned int) features.info.FontID);
}

unsigned int GEMinfo::FontType () const
{
  return ((unsigned int) features.info.FontType);
}

unsigned int GEMinfo::SmallFontHeight () const
{
  return ((unsigned int) features.info.SmallFontHeight);
}

unsigned int GEMinfo::SmallFontID () const
{
  return ((unsigned int) features.info.SmallFontID);
}

unsigned int GEMinfo::SmallFontType () const
{
  return ((unsigned int) features.info.SmallFontType);
}

unsigned int GEMinfo::VDIDevice () const
{
  return ((unsigned int) features.info.VDIDevice);
}

bool GEMinfo::ObjectColors () const
{
  return (features.info.ObjectColors ? true : false);
}

bool GEMinfo::HasColorIcons () const
{
  return (features.info.HasColorIcons ? true : false);
}

bool GEMinfo::NewResource () const
{
  return (features.info.NewResource ? true : false);
}

bool GEMinfo::PreemptiveMultitasking () const
{
  return (features.info.PreemptiveMultitasking ? true : false);
}

bool GEMinfo::ConvertingApplFind () const
{
  return (features.info.ConvertingApplFind ? true : false);
}

bool GEMinfo::HasApplSearch () const
{
  return (features.info.HasApplSearch ? true : false);
}

bool GEMinfo::HasRcFix () const
{
  return (features.info.HasRcFix ? true : false);
}

bool GEMinfo::HasObjcXFind () const
{
  return (features.info.HasObjcXFind ? true : false);
}

bool GEMinfo::HasMenuClick () const
{
  return (features.info.HasMenuClick ? true : false);
}

bool GEMinfo::HasShellRWDef () const
{
  return (features.info.HasShellRWDef ? true : false);
}

bool GEMinfo::HasApplXRead () const
{
  return (features.info.HasApplXRead ? true : false);
}

bool GEMinfo::HasShellXGet () const
{
  return (features.info.HasShellXGet ? true : false);
}

bool GEMinfo::HasMenuXBar () const
{
  return (features.info.HasMenuXBar ? true : false);
}

bool GEMinfo::HasInstallMenuBar () const
{
  return (features.info.HasInstallMenuBar ? true : false);
}

bool GEMinfo::HasGrafXMouse () const
{
  return (features.info.HasGrafXMouse ? true : false);
}

bool GEMinfo::HasIndividualMouseForm () const
{
  return (features.info.HasIndividualMouseForm ? true : false);
}

bool GEMinfo::HasSubMenu () const
{
  return (features.info.HasSubMenu ? true : false);
}

bool GEMinfo::HasPopUp () const
{
  return (features.info.HasPopUp ? true : false);
}

bool GEMinfo::HasScrollMenu () const
{
  return (features.info.HasScrollMenu ? true : false);
}

bool GEMinfo::HasMenuXSelected () const
{
  return (features.info.HasMenuXSelected ? true : false);
}

unsigned char GEMinfo::MTOSCompWDoExecuteBits () const
{
  return ((unsigned char) features.info.MTOSCompWDoExecuteBits);
}

unsigned char GEMinfo::MaxShellWDoExecute () const
{
  return ((unsigned char) features.info.MTOSCompWDoExecuteBits);
}

bool GEMinfo::DumbDeafBlindShellWrite () const
{
  return (features.info.DumbDeafBlindShellWrite ? true : false);
}

bool GEMinfo::BlockingShellWrite () const
{
  return (features.info.BlockingShellWrite ? true : false);
}

bool GEMinfo::ARGVShellWrite () const
{
  return (features.info.ARGVShellWrite ? true : false);
}

bool GEMinfo::WFTopGets2ndWindow () const
{
  return (features.info.WFTopGets2ndWindow ? true : false);
}

bool GEMinfo::HasWFNewdesk () const
{
  return (features.info.HasWFNewdesk ? true : false);
}

bool GEMinfo::HasWFColor () const
{
  return (features.info.HasWFColor ? true : false);
}

bool GEMinfo::HasWFDColor () const
{
  return (features.info.HasWFDColor ? true : false);
}

bool GEMinfo::HasWFOwner () const
{
  return (features.info.HasWFOwner ? true : false);
}

bool GEMinfo::HasWFBEvent () const
{
  return (features.info.HasWFBEvent ? true : false);
}

bool GEMinfo::HasWFBottom () const
{
  return (features.info.HasWFBottom ? true : false);
}

bool GEMinfo::HasWFIconify () const
{
  return (features.info.HasWFIconify ? true : false);
}

bool GEMinfo::HasWFUniconify () const
{
  return (features.info.HasWFUniconify ? true : false);
}

bool GEMinfo::HasIconifier () const
{
  return (features.info.HasIconifier ? true : false);
}

bool GEMinfo::HasHotCloseBox () const
{
  return (features.info.HasHotCloseBox ? true : false);
}

bool GEMinfo::HasBackdrop () const
{
  return (features.info.HasBackdrop ? true : false);
}

bool GEMinfo::HasShiftClickBackdrop () const
{
  return (features.info.HasShiftClickBackdrop ? true : false);
}

bool GEMinfo::HasWindowUpdateCheckSet () const
{
  return (features.info.HasWindowUpdateCheckSet ? true : false);
}

bool GEMinfo::HasWMNewtop () const
{
  return (features.info.HasWMNewtop ? true : false);
}

bool GEMinfo::HasWMUntopped () const
{
  return (features.info.HasWMUntopped ? true : false);
}

bool GEMinfo::HasWMOntop () const
{
  return (features.info.HasWMOntop ? true : false);
}

bool GEMinfo::HasAPTerm () const
{
  return (features.info.HasAPTerm ? true : false);
}

bool GEMinfo::HasMTOSChRes () const
{
  return (features.info.HasMTOSChRes ? true : false);
}

bool GEMinfo::HasChExit () const
{
  return (features.info.HasChExit ? true : false);
}

bool GEMinfo::HasWMBottom () const
{
  return (features.info.HasWMBottom ? true : false);
}

bool GEMinfo::HasWMIconify () const
{
  return (features.info.HasWMIconify ? true : false);
}

bool GEMinfo::HasWMUniconify () const
{
  return (features.info.HasWMUniconify ? true : false);
}

bool GEMinfo::HasWMAlliconify () const
{
  return (features.info.HasWMAlliconify ? true : false);
}

bool GEMinfo::HasIconCoordinates () const
{
  return (features.info.HasIconCoordinates ? true : false);
}

bool GEMinfo::Has3DObjects () const
{
  return (features.info.Has3DObjects ? true : false);
}

bool GEMinfo::HasObjcSysVar () const
{
  return (features.info.HasObjcSysVar ? true : false);
}

bool GEMinfo::HasGDOSTedInfo () const
{
  return (features.info.HasGDOSTedInfo ? true : false);
}

bool GEMinfo::HasG_PopUp () const
{
  return (features.info.HasG_PopUp ? true : false);
}

bool GEMinfo::HasG_SWButton () const
{
  return (features.info.HasG_SWButton ? true : false);
}

bool GEMinfo::HasWhiteBakUnderscore () const
{
  return (features.info.HasWhiteBakUnderscore ? true : false);
}

bool GEMinfo::HasFlyDials () const
{
  return (features.info.HasFlyDials ? true : false);
}

bool GEMinfo::HasKeyTables () const
{
  return (features.info.HasKeyTables ? true : false);
}

bool GEMinfo::HasLastCursorPos () const
{
  return (features.info.HasLastCursorPos ? true : false);
}
