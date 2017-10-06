// Modular Atari Desktop Environment - MADe.
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


// One load sample.

#ifndef _LOADSAMPLE_DEFS_H
#define _LOADSAMPLE_DEFS_H

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#include <system.h>

class LoadSample {
public:
  LoadSample () : load (0), scaled_load (0), is_peak (false) {}
  
  inline void Load (double& l) { load = l; }
  inline const double& Load () const { return load; }
  
  inline void Scale (double factor) { scaled_load = (short int) (load * factor); }
  inline int ScaledLoad () const { return scaled_load; }
  
  void IsPeak (bool yes) { is_peak = yes; }
  bool IsPeak () const { return is_peak; }
  
  inline bool operator== (const LoadSample& TheOther1) 
      { return (TheOther1.load == load && TheOther1.is_peak == is_peak); }
  
  friend inline bool LoadSampleEQ (const LoadSample, const LoadSample);
    
private:
  double load;
  short int scaled_load;
  bool is_peak;
};

inline bool LoadSampleEQ (const LoadSample a, const LoadSample b)
{
  return (a.load == b.load);
}
#endif