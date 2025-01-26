* STORM STOS BLITTER EXTENSION - COMPILER VERSION 1.0
*
* WRITTEN BY NEIL HALLIDAY 17/03/1994
* (C) 1995 STORM Developments LTD.
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
	
catalog	dc.w	lib2-lib1		; length of routine 1  (blit sinc)
	dc.w	lib3-lib2		; length of routine 2  (blit clr)
	dc.w	lib4-lib3		; length of routine 3  (blit dinc)
	dc.w	lib5-lib4		; length of routine 4  (blit fskopy)  
	dc.w	lib6-lib5		; length of routine 5  (blit address)
	dc.w	lib7-lib6		; length of routine 6  
	dc.w	lib8-lib7		; length of routine 7  (blit mask)
	dc.w	lib9-lib8		; length of routine 8  
	dc.w	lib10-lib9		; length of routine 9  (blit count)
	dc.w	lib11-lib10		; length of rountie 10 
	dc.w	lib12-lib11		; length of routine 11 (blit hop)
	dc.w	lib13-lib12		; length of routine 12 
	dc.w	lib14-lib13		; length of routine 13 (blit op)
	dc.w	lib15-lib14		; length of routine 14 
	dc.w	lib16-lib15		; length of routine 15 (blit skew)
	dc.w	lib17-lib16		; length of routine 16 
	dc.w	lib18-lib17		; length of routine 17 (blit nfsr)
	dc.w	lib19-lib18		; length of routine 18 
	dc.w	lib20-lib19		; length of routine 19 (blit fxsr) 
	dc.w	lib21-lib20		; length of routine 20 
	dc.w	lib22-lib21		; length of routine 21 (blit line)
	dc.w	lib23-lib22		; length of routine 22 
	dc.w	lib24-lib23		; length of routine 23 (blit smudge)	
	dc.w	lib25-lib24		; length of routine 24 
	dc.w	lib26-lib25		; length of routine 25 (blit hog)
	dc.w	lib27-lib26		; length of routine 26 
	dc.w	lib28-lib27		; length of routine 27 (blit it)
	dc.w	lib29-lib28		; length of routine 28
	dc.w	lib30-lib29		; length of routine 29 (blit fcopy)	
	dc.w	lib31-lib30		; length of routine 30
	dc.w	libex-lib31		; length of routine 31 (blit cls)			
	
para	dc.w	31			; number of library routines
	dc.w	31			; number of extension commands

	dc.w	l001-para		; offset for blit sinc
	dc.w	l002-para		; offset for blit clr 
	dc.w	l003-para		; offset for blit dinc
	dc.w	l004-para		; offset for blit fskopy
	dc.w	l005-para		; offset for blit address
	dc.w	l006-para		; 
	dc.w	l007-para		; offset for blit mask
	dc.w	l008-para		; 
	dc.w	l009-para		; offset for blit count
	dc.w	l010-para		; 
	dc.w	l011-para		; offset for blit hop
	dc.w	l012-para		; 
	dc.w	l013-para		; offset for blit op
	dc.w	l014-para		; 
	dc.w	l015-para		; offset for blit skew
	dc.w	l016-para		; 
	dc.w	l017-para		; offset for blit nfsr
	dc.w	l018-para		; 
	dc.w	l019-para		; offset for blit fxsr
	dc.w	l020-para		; 
	dc.w	l021-para		; offset for blit line
	dc.w	l022-para		; 
	dc.w	l023-para		; offset for blit smudge
	dc.w	l024-para		; 
	dc.w	l025-para		; offset for blit hog
	dc.w	l026-para		; 
	dc.w	l027-para		; offset for blit it
	dc.w	l028-para		;
	dc.w	l029-para		; offset for blit fcopy
	dc.w	l030-para		;
	dc.w	l031-para		; offset for blit cls

* Parameter defininitions

I	equ	0
F	equ	$40
S	equ	$80

* "," forces a comma between any commands
* 1   indicates the end of one set of parameters for an instrucion
* 1,0 indicates the end of the commands entire parameter definition

l001	dc.b	0,I,",",I,1,1,0		; Blit sinc
l002	dc.b	0,I,1,1,0		; Blit clr
l003	dc.b	0,I,",",I,1,1,0		; Blit dinc
l004	dc.b	0,I,",",I,1,1,0         ; Blit fskopy
l005	dc.b	0,I,",",I,1,1,0		; Blit address 
l006	dc.b	0,1,1,0			; 
l007	dc.b	0,I,",",I,",",I,1,1,0	; Blit mask 
l008	dc.b	0,1,1,0		; 
l009	dc.b	0,I,",",I,1,1,0		; Blit count
l010	dc.b	0,1,1,0			; 
l011	dc.b	0,I,1,1,0		; Blit hop
l012	dc.b	0,1,1,0			; 
l013	dc.b	0,I,1,1,0		; Blit op
l014	dc.b	0,1,1,0			; 
l015	dc.b	0,I,1,1,0		; Blit skew
l016	dc.b	0,1,1,0			; 
l017	dc.b	0,I,1,1,0		; Blit nfsr
l018	dc.b	0,1,1,0			; 
l019	dc.b	0,I,1,1,0		; Blit fxsr
l020	dc.b	0,I,1,1,0		; 
l021	dc.b	0,I,1,1,0		; Blit line
l022 	dc.b	0,1,1,0			; 
l023	dc.b	0,I,1,1,0		; Blit smudge
l024	dc.b	0,1,1,0			;
l025	dc.b	0,I,1,1,0		; Blit hog
l026	dc.b	0,1,1,0			;
l027	dc.b	0,1,1,0			; Blit it
l028	dc.b	0,1,1,0			;
l029	dc.b	0,I,",",I,1,1,0		; Blit fcopy
l030	dc.b	0,1,1,0			;
l031	dc.b	0,I,1,1,0		; Blit cls

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



* Blit sinc

lib1	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.l	(a6)+,d4
	move.w	d3,$ff8a22		; Source y inc
	move.w	d4,$ff8a20		; Source x inc
	rts


	
* blit clr
	
lib2	dc.w	0			; no library calls
	move.l	(a6)+,a1		; destination screen
	move.l	a1,a0			; source screen
	move.w	#8,$ff8a20		; Source x inc
	move.w	#8,$ff8a22		; Source y inc
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#8,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#20,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#0,$ff8a3b		; Blit op   (all 0 bytes!)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	move.l	#0,-(a6)		; Return value always 0
	rts
	
	
	
* Blit dinc 

lib3	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.l	(a6)+,d4
	move.w	d3,$ff8a30		; Dest y inc
	move.w	d4,$ff8a2e		; Dest x inc
	rts



* Blit fskopy 

lib4	dc.w	0			; no library calls
	move.l	(a6)+,a1		; destination screen
	move.l	(a6)+,a0		; source screen
	move.w	#8,$ff8a20		; Source x inc
	move.w	#8,$ff8a22		; Source y inc
	move.w	#8,$ff8a2e		; Destination x inc
	move.w	#8,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#20,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#3,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	rts
	
	
	
* blit address

lib5	dc.w	0			; no library calls
	move.l	(a6)+,$ff8a32		; dest address
	move.l	(a6)+,$ff8a24		; source address
	rts


* 

lib6	dc.w	0			; No library calls
	rts



* Blit mask

lib7	dc.w	0			; no library calls
	move.l	(a6)+,d3		
	move.l	(a6)+,d4
	move.l	(a6)+,d5
	move.w	d3,$ff8a2c		; end mask 3
	move.w	d4,$ff8a2a		; end mask 2
	move.w	d5,$ff8a28		; end mask 1
	rts
	
	
	
* 

lib8	dc.w	0			; No library calls
	rts
	
	
	
* blit count

lib9	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.l	(a6)+,d4
	move.w	d3,$ff8a38		; y count
	move.w	d4,$ff8a36		; x count
	rts



	
*

lib10	dc.w	0			; no library calls
	rts


	
* blit hop

lib11	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.b	d3,$ff8a3a		; blit hop	
	rts



* 

lib12	dc.w	0			; no library calls
	rts
	



* blit op

lib13	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.b	d3,$ff8a3b		; Blit op
	rts



* 

lib14	dc.w	0			; no library calls
	rts
	
	
	
	
* Blit skew

lib15	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.b	d3,$ff8a3d		; Skew value
	rts				



* 

lib16	dc.w	0			; no library calls
	rts


	
* blit nfsr

lib17	dc.w	0			; no library calls
	move.l	(a6)+,d3
	
	btst	#0,d3
	beq	.set_to_zero
	
	bset	#6,$ff8a3d		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#6,$ff8a3d
.out	rts




* 

lib18	dc.w	0			; no library calls
	rts
	
	
	
	
* blit fxsr

lib19	dc.w	0			; no library calls
	move.l	(a6)+,d3
	
	btst	#0,d3
	beq	.set_to_zero
	
	bset	#7,$ff8a3d		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#7,$ff8a3d
.out	rts




*

lib20	dc.w	0			; no library calls
	rts



* blit line

lib21	dc.w	0			; no library calls
	move.l	(a6)+,d3
	move.b	d3,$ff8a3c		; blit line start
	rts



*

lib22	dc.w	0			; No library calls
	rts




* blit smudge

lib23	dc.w	0			; No library calls
	move.l	(a6)+,d3
	
	btst	#0,d3
	beq	.set_to_zero
	
	bset	#5,$ff8a3c		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#5,$ff8a3c
.out	rts




* 

lib24	dc.w	0			; No library calls
	rts



* blit hog	

lib25	dc.w	0
	move.l	(a6)+,d3
	
	btst	#0,d3
	beq	.set_to_zero
	
	bset	#6,$ff8a3c		; Set bit
	bra	.out
	
.set_to_zero
	bclr	#6,$ff8a3c
.out	rts
	
	
	
	
* 

lib26	dc.w	0			; no library calls
	rts



* blit it

lib27	dc.w	0			; No library calls
	bset	#7,$ff8a3c		; Set bit
	rts				


*

lib28	dc.w	0			; no library calls
	rts



* blitfcopy
	
lib29	dc.w	0			; no library calls
	move.l	(a6)+,a1		; destination screen
	move.l	(a6)+,a0		; source screen
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#3,$ff8a3b		; Blit op
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	
	rts
	

*

lib30	dc.w	0			; no library calls
	rts
	


* blitcls
	
lib31	dc.w	0			; no library calls
	move.l	(a6)+,a1		; destination screen
	move.l	a1,a0			; source screen
	move.w	#2,$ff8a20		; Source x inc
	move.w	#2,$ff8a22		; Source y inc
	move.w	#2,$ff8a2e		; Destination x inc
	move.w	#2,$ff8a30		; Destination y inc
	move.l	a0,$ff8a24		; Source address
	move.l	a1,$ff8a32		; Destination address
	move.w	#80,$ff8a36		; X count
	move.w	#200,$ff8a38		; Y count
	move.w	#$ffff,$ff8a28		; Endmask 1
	move.w	#$ffff,$ff8a2a		; Endmask 2
	move.w	#$ffff,$ff8a2c		; Endmask 3
	move.b	#2,$ff8a3a		; Blit hop
	move.b	#0,$ff8a3b		; Blit op   (all 0 bytes!)
	move.b	#0,$ff8a3d		; Skew,nfsr,fxsr
	move.b	#192,$ff8a3c		; Line,smudge,hog,busy	


	rts


libex	dc.w	0			; end of library  
