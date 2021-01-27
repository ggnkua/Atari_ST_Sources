/* Copyright (c) 2013 - present by H. Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* AAAA_CFG.H
 * ==========
 */

#ifndef AAAA_CFG_H
#define AAAA_CFG_H


#if defined MMENU	/* Mandelbrot */
	#define CAN_CLICK 1
	#define MFRAC 1
	#define IMGS 1
	#define WMENU 1
	#define FILES 1
#endif

#if defined FMENU
	#define CAN_CLICK 1
	#define FSVIEW 1
	#define TREEWIN 1
	#define WMENU 1
#endif

#if defined DMENU
	#define CAN_CLICK 1
	#define DPVIEW 1
	#define TREEWIN 1
	#define WMENU 1
#endif

#if defined TMENU		/* full text editor */
	#define WINTEXT 1	/* window text functions */
	#define TEXTFILE 1
	#define FILES 1

	#define SELECTION 1
	#define CAN_CLICK 1
	#if MTEDITOR
		#define DRAGSELECTION 1
		#define TEXTEDIT 1
	#endif
	#define WMENU 1
#endif

#if defined BMENU	/* binary file editor */
	#define BINARY 1
	#define CAN_CLICK 1
	#define BSELECTION 1
	#define FILES 1
	#define WMENU 1
#endif

#if defined OMENU   /* disassembler */
	#define DIGGER 1
	#define CAN_CLICK 1
	#define FILES 1
	#define WMENU 1
#endif

#define TREVIEW 1

#if defined MNWKS	/* worksheets */
	#define WKS 1
	#define WIN_OB 1	/* dialogue's are part of a work window */
	#define CAN_CLICK 1
	#define FILES 1
	#define WMENU 1
#endif

#if defined JOURNAL	/* viz. */
	#ifdef MNJCALC
		#define MINICONS 1	/* journal needs some console functions */
	#endif
	#define WINTEXT 1		/* journal needs some text functions */
	#ifdef MNJFIND
		#ifndef MNFIND
		#define MNFIND MNJFIND
		#endif
	#endif
#endif

/*
#ifdef ADDO			/* ADDO_X's mechanical calculator's scroll emulator */
#error Incomplete ADDO_XL ???
#endif
*/
#endif /* AAAA_CFG_H */