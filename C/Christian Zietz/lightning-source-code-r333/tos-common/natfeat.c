/*
 * Adapted for Aranym's USB host controller TOS driver by DavidGZ
 */

/*
 * ARAnyM native features interface.
 * (c) 2005-2008 ARAnyM development team
 *
 * In 2006 updated with FreeMiNT headers and code.
 * In 2008 converted from "__NF" cookie to direct usage of NF instructions
 *
 **/

/*
 * Copied from FreeMiNT source tree where Native Features were added recently
 * 
 * Copyright 2003 Frank Naumann <fnaumann@freemint.de>
 * All rights reserved.
 * 
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 * 
 * Author: Frank Naumann <fnaumann@freemint.de>
 * Started: 2003-12-13
 * 
 */

# include <compiler.h>
# include <mint/osbind.h>
#include "mint/arch/nf_ops.h"


#define NATFEAT_ID   0x7300
#define NATFEAT_CALL 0x7301


#pragma GCC optimize "-fomit-frame-pointer"
#pragma GCC diagnostic ignored "-Wclobbered"

#define ASM_NATFEAT3(opcode) "\t.word " #opcode "\n"
#define ASM_NATFEAT2(opcode) ASM_NATFEAT3(opcode)
#define ASM_NATFEAT(n) ASM_NATFEAT2(n)

/**
 * Use this function to intialize Native Features.
 *
 * @return the pointer to 'struct nf_ops' or NULL when
 *         not available.
 **/
const struct nf_ops *nf_init(void);


static long __attribute__((noinline)) __CDECL _nf_get_id(const char *feature_name)
{
	register long ret __asm__ ("d0");
	(void)(feature_name);
	__asm__ volatile(
		ASM_NATFEAT(NATFEAT_ID)
	: "=g"(ret)  /* outputs */
	: /* inputs  */
	: __CLOBBER_RETURN("d0") "d1", "cc" AND_MEMORY /* clobbered regs */
	);
	return ret;
}


static long __attribute__((noinline)) __CDECL _nf_call(long id, ...)
{
	register long ret __asm__ ("d0");
	(void)(id);
	__asm__ volatile(
		ASM_NATFEAT(NATFEAT_CALL)
	: "=g"(ret)  /* outputs */
	: /* inputs  */
	: __CLOBBER_RETURN("d0") "d1", "cc" AND_MEMORY /* clobbered regs */
	);
	return ret;
}


static struct nf_ops const _nf_ops = { _nf_get_id, _nf_call, { 0, 0, 0 } };
static const struct nf_ops *nf_ops;

extern int detect_native_features(void);

const struct nf_ops *nf_init(void)
{
	if (Supexec(detect_native_features))
	{
		nf_ops = &_nf_ops;
		return nf_ops;
	}

	return 0UL;
}

