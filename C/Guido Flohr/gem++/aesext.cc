/* GEM++
   Copyright (C) 1997 by Guido Flohr <gufl0000@stud.uni-sb.de>.

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published bythe Free
   Software Foundation; either version 2, or (at your option) any later
   version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.  */

/*  $Date: 1997/06/01 23:29:30 $  
 *  $Revision: 1.1 $  
 *  $State: Exp $  
 */

/* AES extensions.  I hope they all work alright.  */
/* The definitions for appl_xgetinfo, get_cookie and get_cookiejar are taken
 * from Christian Grunenbergs enhanced gem library EGEM.
 */

#ifdef HAVE_CONFIG_H
# include <config.h>
#endif

#ifndef __TCC_COMPAT__
# define __TCC_COMPAT__
#endif
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>
#include <common.h>
#include <osbind.h>

#include <stdio.h>

#include <system.h>

#include "aesext.h"  /* Implemented here.  */

#ifndef HAVE_APPL_GETINFO
int appl_getinfo (int type, int* out1, int* out2, int* out3, int* out4)
{
  int status;

  _int_in[0] = type;
#ifdef __cplusplus
  extern "C" {
#endif
  status = __aes__ (AES_CONTROL_ENCODE (130, 1, 5, 0));
#ifdef __cplusplus
  }
#endif

  *out1 = _int_out[1];
  *out2 = _int_out[2];
  *out3 = _int_out[3];
  *out4 = _int_out[4];

  return (status ? _int_out[0] : 0);
}
#endif

#ifndef HAVE_APPL_XGETINFO
int appl_xgetinfo (int type, int* out1, int* out2, int* out3, int* out4)
{
  long int junk;
  
  if (_global[0] > 0x0400
      || (_global[0] == 0x0400 && type < 4)
      || (_global[0] == 0x0399 && get_cookie ((long) ("MagX"), &junk))
      || appl_find ("?AGI") >= 0)
    return (appl_getinfo (type, out1, out2, out3, out4));
  else
    return 0;
}
#endif

#ifndef HAVE_GET_COOKIE
int get_cookie (long int cookie, long int* value) {
  void* save_stk;
  long int* cookie_jar;
    
  save_stk = (void*) Super (NULL);
  cookie_jar = *((long int**) 0x000005a0);
  (void) Super ((void*) save_stk);
  
  while (*cookie_jar) {
    if (*cookie_jar == cookie) {
      if (value)
        *value = cookie_jar[1];
      return 1;
    } else {
      cookie_jar += 2;
    }
  }
  /* Not found.  */
  return 0;
}
#endif
