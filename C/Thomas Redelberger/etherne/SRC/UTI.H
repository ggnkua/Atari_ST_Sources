/************************************************************************/
/*																		*/
/*	Helper functions for assembler programming and debugging			*/
/*	Copyright 2002 Dr. Thomas Redelberger								*/
/*	Use it under the terms of the GNU General Public License			*/
/*	(See file COPYING.TXT)												*/
/*																		*/
/* Software interface file												*/
/*																		*/
/* Tabsize 4, developed with Turbo-C ST 2.0								*/
/*																		*/
/************************************************************************/
/*
$Id: uti.h 1.1 2002/03/24 13:46:52 Thomas Exp Thomas $
 */

#define myPling()	prntStr("\7")


/**** entry points in UTI.S ****/

/* printing functions via the BIOS concole */

extern	void	cdecl	prntStr(char* string);
extern	void	cdecl	prntLong(uint32);
extern	void	cdecl	prntWord(uint16);
extern	void	cdecl	prntByte(uint8);
extern	void	cdecl	prntSR(void);

