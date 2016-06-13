/**
 * STune - The battle for Aratis
 * stunegem.h : This file provides a compiler/library independent access to
 *              the GEM library.
 * Copyright (C) 2003 Matthias Alles, Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#ifndef STUNE_GEM_H
#define STUNE_GEM_H

#include <aes.h>
#include <vdi.h>

#ifndef WM_ONTOP
#define WM_ONTOP 31
#endif

#ifndef AP_RESCHG
#define AP_RESCHG 57
#define AP_TERM 50
#endif

#ifdef SOZOBON
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
#endif

#ifdef __TURBOC__
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
#define objc_edit(t,o,c,iv,k,ip)  objc_edit(t,o,c,ip,k)
#endif

#ifdef _GEMLIB_H_
/* Die evnt_multi von GNU-C hat ein Timer-Feld, die von Sozobon hat zwei */
#define evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n, o,p,q,r,s,t,u,v,w) evnt_multi(a,b,c,d,e,f,g,h,i,j,k,l,m,n, o,(((short)(p))|(((long)q)<<16)),r,s,t,u,v,w)
#define evnt_timer(t1,t2)  evnt_timer(((short)(t1))|(((long)t2)<<16))
#define objc_edit(t,o,c,iv,k,ip)  objc_edit(t,o,c,ip,k)
#define graf_rubbox graf_rubbbox
#endif

#endif /* STUNE_GEM_H */
