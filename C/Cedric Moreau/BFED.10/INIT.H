/*********************************************
	file: init.h
	utility: header file of init.c
	date: 16 dec 96
	author: C.Moreau
	modifications:
	comments: 
*********************************************/

#ifndef _INIT_H
#define _INIT_H

/*********************************************
	includes
*********************************************/
#ifdef __PUREC__
#include <vdi.h>	/* defs for MFDB */
#else
#include <vdibind.h>
#endif

/*********************************************
	defines
*********************************************/

/*********************************************
	types definitions
*********************************************/

/*********************************************
	globals variables declarations
*********************************************/
extern int phys_handle;
extern int gl_hchar, gl_wchar;
extern int xdesk, ydesk, wdesk, hdesk;
extern int ver_aes, ver_tos;
extern int pxyarray[8];	/* for vdi calls */

/*********************************************
	globals functions declarations
*********************************************/
extern void init(int *argc, char **argv[]);
extern int open_vwork(register MFDB	*form);

#endif