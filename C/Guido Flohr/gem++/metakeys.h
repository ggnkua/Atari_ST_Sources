//////////////////////////////////////////////////////////////////////////////
//
//  Meta-Key codes for use with GEMevent.Meta().
//
//  This file is Copyright 1995 by Chris Herborth (chrish@qnx.com).
//  This file is part of Warwick Allison's gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
//////////////////////////////////////////////////////////////////////////////

#ifndef _metakeys_h
#define _metakeys_h

#define METAKEY_RSHIFT          0x01    // Right-shift
#define METAKEY_LSHIFT          0x02    // Left-shift
#define METAKEY_CONTROL         0x04
#define METAKEY_ALTERNATE       0x08

#define METAKEY_SHIFT           0x03    // R-shift | L-shift
#define METAKEY_ANY                     0x0f    // Shift | Control | Alternate
#define METAKEY_NONE            0x00

#endif // _metakeys_h

