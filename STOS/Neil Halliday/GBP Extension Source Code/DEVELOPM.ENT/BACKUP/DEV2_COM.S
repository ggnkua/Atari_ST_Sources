* STORM Development Extension (Part II) - COMPILER VERSION 0.4(beta)
*
* WRITTEN BY NEIL HALLIDAY 1995
* (C)1995 STORM Developments.
*
* FULL VERSION!
*
* SET UP SYSTEM VARIABLES

debut	equ	$92c
error	equ	$93c
flagem	equ	$9a0

* Define extension addresses

start	dc.l	para-start		; parameter definitions
	dc.l	data-start		; reserve data area for program
	dc.l	lib1-start		; start of library
	
catalog	dc.w	lib2-lib1		; length of routine 1 
	dc.w	lib3-lib2		; length of routine 2  (auxin) 
	dc.w	lib4-lib3		; length of routine 3 
	dc.w	lib5-lib4		; length of routine 4  (pcdeek) 
	dc.w	lib6-lib5		; length of routine 5 
	dc.w	lib7-lib6		; length of routine 6  (pcleek) 
	dc.w	lib8-lib7		; length of routine 7 
	dc.w	lib9-lib8		; length of routine 8 
	dc.w	lib10-lib9		; length of routine 9 
	dc.w	lib11-lib10		; length of routine 10 
	dc.w	lib12-lib11		; length of routine 11 
	dc.w	lib13-lib12		; length of routine 12 
	dc.w	lib14-lib13		; length of routine 13 
	dc.w	lib15-lib14		; length of routine 14 
	dc.w	lib16-lib15		; length of routine 15 
	dc.w	lib17-lib16		; length of routine 16 
	dc.w	lib18-lib17		; length of routine 17 
	dc.w	lib19-lib18		; length of routine 18 
	dc.w	lib20-lib19		; length of routine 19 
	dc.w	lib21-lib20		; length of routine 20 
	dc.w	lib22-lib21		; length of routine 21 
	dc.w	lib23-lib22		; length of routine 22 
	dc.w	lib24-lib23		;
	dc.w	lib25-lib24		; length of routine 24 
	dc.w	lib26-lib25		;
	dc.w	lib27-lib26		; length of routine 26 
	dc.w	lib28-lib27		; 
	dc.w	lib29-lib28		; length of routine 28 
	dc.w	lib30-lib29		; 
	dc.w	lib31-lib30		; length of routine 30 
	dc.w	lib32-lib31		; 
	dc.w	libex-lib32		; length of routine 32 
			
para	dc.w	32			; number of library routines
	dc.w	32			; number of extension commands

	dc.w	l001-para		; 
	dc.w	l002-para		; auxin
	dc.w	l003-para		; 
	dc.w	l004-para		; pcdeek 
	dc.w	l005-para		; 
	dc.w	l006-para		; pcleek 
	dc.w	l007-para		; 
	dc.w	l008-para		; 
	dc.w	l009-para		; 
	dc.w	l010-para		; 
	dc.w	l011-para		; 		
	dc.w	l012-para		; 
	dc.w	l013-para		; 
	dc.w	l014-para		; 
	dc.w	l015-para		; 
	dc.w	l016-para		; 
	dc.w	l017-para		; 
	dc.w	l018-para		; 
	dc.w	l019-para		; 
	dc.w	l020-para		; 
	dc.w	l021-para		; 
	dc.w	l022-para		;  
	dc.w	l023-para		;
	dc.w	l024-para		; 
	dc.w	l025-para		;
	dc.w	l026-para		;
	dc.w	l027-para		;
	dc.w	l028-para		; 
	dc.w	l029-para		;
	dc.w	l030-para		; 
	dc.w	l031-para		;
	dc.w	l032-para		;

* Parameter defininitions

I	equ	0
F	equ	$40
S	equ	$80

* "," forces a comma between any commands
* 1   indicates the end of one set of parameters for an instrucion
* 1,0 indicates the end of the commands entire parameter definition

l001	dc.b	0,1,1,0			; 
l002	dc.b	I,1,1,0			; Auxin
l003	dc.b	0,1,1,0			;
l004	dc.b	I,I,1,1,0		; Pcdeek
l005	dc.b	0,1,1,0			;
l006	dc.b	I,I,1,1,0		; Pcleek
l007	dc.b	0,1,1,0			;
l008	dc.b	I,1,1,0			;
l009	dc.b	0,1,1,0			;
l010	dc.b	I,1,1,0			;
l011	dc.b	0,1,1,0			;
l012	dc.b	I,1,1,0			;
l013	dc.b	0,1,1,0			;
l014	dc.b	I,1,1,0			;
l015	dc.b	0,1,1,0			;
l016	dc.b	I,1,1,0			;
l017	dc.b	0,1,1,0			;
l018	dc.b	I,1,1,0			; 
l019	dc.b	0,1,1,0			; 
l020	dc.b	I,1,1,0			; 
l021	dc.b	0,1,1,0			;
l022	dc.b	I,1,1,0			;
l023	dc.b	0,1,1,0			;
l024	dc.b	I,1,1,0			;
l025	dc.b	0,1,1,0			;
l026	dc.b	I,1,1,0			;
l027	dc.b	0,1,1,0			;
l028	dc.b	I,1,1,0			;
l029	dc.b	0,1,1,0			;
l030	dc.b	I,1,1,0			;
l031	dc.b	0,1,1,0			;
l032	dc.b	I,1,1,0			;


* End of parameter definition

	even
	
* Initialisation section
* This code is loaded into memory during initialisation
* It can be accessed using address placed in the DEBUT variable

data	bra	init

init	lea	end(pc),a2		; load position of end into A2
	rts
	
end	rts



* Extension library

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib1:	dc.w	0			; no library routines
	rts
	even
	
	
**     COMMAND: AUXIN	
**  	SYNTAX: x=AUXIN
**
** DESCRIPTION: Get a byte from the AUX port	

lib2	dc.w	0			; No library calls
	move.w	#1,-(sp)		; Bconstat
	move.w	#2,-(sp)
	trap	#13
	lea	4(sp),sp
	move.l	d0,-(a6)		; Return number
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib3	dc.w	0			; no library calls
	rts
	even
	
	
**     COMMAND: PCDEEK	
**  	SYNTAX:	X=PCDEEK
**
** DESCRIPTION: Get a word from a PC data file	

lib4	dc.w	0			; No library calls
	move.l	(a6)+,a0		; Get address
	clr.l	.wrk
	move.l	#.wrk,a1		; Work address
	move.b	(a0)+,3(a1)		; Swap data around
	move.b	(a0),2(a1)
	move.l	.wrk,-(a6)		
	rts
.wrk	dc.l	0



**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib5	dc.w	0			; no library calls
	rts
	even

	
**     COMMAND: PCLEEK	
**  	SYNTAX:	x=PCLEEK(addr)
**
** DESCRIPTION: Return a long word from a PC data file	

lib6	dc.w	0			; No library calls
	move.l	(a6)+,a0			
	clr.l	.wrk
	move.l	#.wrk,a1		; Work address
	move.b	3(a0),(a1)
	move.b	2(a0),1(a1)
	move.b	1(a0),2(a1)
	move.b	(a0),3(a1)
	move.l	.wrk,-(a6)		
	rts
.wrk	dc.l	0

	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	
**		

lib7:	dc.w	0			; No library calls
	rts
	even
	
	
**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib8	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib9:	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib10	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib11	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib12	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib13	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib14	dc.w	0			; No library calls
	rts
	even

*

lib15	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	


lib16	dc.w	0			; No library calls
	rts
	even

*

lib17	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib18	dc.w	0			; No library calls
	rts
	even

*

lib19	dc.w	0			; No library calls
	rts
	even



**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION: 

lib20:	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION: 

lib21	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib22	dc.w	0			; No library calls
	rts
	even

*

lib23	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib24	dc.w	0			; No library calls
	rts
	even


*

lib25	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib26	dc.w	0			; No library calls
	rts
	even

*

lib27	dc.w	0			; No library calls
	rts
	even


**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib28	dc.w	0			; No library calls
	rts
	even

*

lib29	dc.w	0			; No library calls
	rts
	even

**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib30	dc.w	0			; No library calls
	rts
	even
	
*

lib31	dc.w	0			; No library calls
	rts
	even
	
	
**     COMMAND:	
**  	SYNTAX:	
**
** DESCRIPTION:	

lib32	dc.w	0			; No library calls
	rts
	even

libex	dc.w	0			; end of library  
