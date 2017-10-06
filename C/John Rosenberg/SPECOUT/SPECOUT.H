/*
 *	specout.h  --  header file for specout.c (version 1)
 *
 *	Written by John Rosenberg
 *	CIS [73607,3464]; Genie J.ROSENBERG5
 */

extern	FILE	*SpecFile;		/* output file descriptor	      */
extern	int	SpecScreenMem[200][80];	/* 200(Y) x 80 words screen memory    */
extern	int	SpecPallettes[200][48];	/* 200(Y) x 48 pallette words	      */
extern	int	SpecBitIndex[16];

extern	int	SpecOpen();		/* open Spectrum 512 output file      */
extern	void	SpecWriteOut();		/* write Spectrum info, close file    */
extern	void	SpecClearAll();		/* clear screen memory & pallettes    */
extern	int	SpecInt2Color();	/* convert int [0:511] to color word  */
extern	void	SpecSetPixel();		/* set pixel to some color [0:15]     */
extern	int	SpecAddColor();		/* add color word [0xRGB] to pallette */
extern	int	SpecColorAccessableP(); /* can column x use pallette index i? */
extern	void	SpecCleanupPallettes();	/* tidy up pallettes before writing   */
extern	void	SpecWriteMap();		/* write out memory map to file       */
extern	void	SpecWritePallettes();	/* write out pallettes		      */
