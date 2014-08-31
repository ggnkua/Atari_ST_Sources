; ----------------------------------------------------------------------------
; File name:	TermWinC.S		Revision date:  1993.05.23
; Created by:	Ulf Ronald Andersson	Creation date:  1993.04.02
; ----------------------------------------------------------------------------
; File purpose:	Devpac source code to assemble a library of functions that
;		implement terminal handling (VT_52 etc.) for GEM windows,
;		as an object module for linking with C programs.
;
; ----------------------------------------------------------------------------
; Copyright:	(c)1993 by Ulf Ronald Andersson
;
;		Release terms are given in the file TermWind.Doc,
;		which must always accompany other TermWind files.
;
; ----------------------------------------------------------------------------
;
GFA_BASIC	set	0
_deblev		=	0
;
	include	TermWin.S
;
; ----------------------------------------------------------------------------
; End of file:  TermWinC.S
; ----------------------------------------------------------------------------
