// GEM++.
// Copyright (C) 1992, 1993 by Warwick W. Allison.
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

#ifndef _GEMBOOL_H
#define _GEMBOOL_H

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

// Check if the compiler already knows the type bool.
#ifndef HAVE_BUILTIN_BOOL
# ifndef bool
typedef int bool;
# endif
# ifndef true
const bool true = 1;
# endif
# ifndef false
const bool false = 0;
# endif
#endif // HAVE_BUILTIN_BOOL

#endif