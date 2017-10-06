/////////////////////////////////////////////////////////////////////////////
//
//  GEMfeedback
//
//  Communication units between event producers (GEMactivity/GEMform) and
//  event handlers (GEMwindow, GEMkeysink, GEMtimer, GEMobject, etc.)
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMFeedback_h
#define GEMFeedback_h

// Macro for compatibility with older versions.

#define IgnoredClick IgnoredEvent
enum GEMfeedback { EndInteraction, ContinueInteraction, RedrawMe, RedrawMyParent, IgnoredEvent };

#endif
