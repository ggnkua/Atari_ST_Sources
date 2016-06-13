
* 512K version of R-TYPE. In order to make it working, files had
* to be split from the bigfile and placed to sectors since a file 
* loader routine can't work due to low address where game 
* executable has to be loaded ($400).

* I used Pack-Ice 2.40 to pack those files except the biggest file
* (sprites1.dat) because Pack-Ice depack routine depacks the files
* in place and requires some extra memory to do that, so that file 
* had to be left unpacked, but hey, its still single sided disk :)

* DMA loader is also needed to make this working with 512K.

* Ford Perfect's words "It was impossible to make it .....", no,
* it's not impossible if you really want to do it. You should have
* also tested your release properly back in days instead of giving
* out non-proper version, 1st level Boss is a mess and later in the
* game you see more mess :( 

* Also, Pompey Pirates Menu #015, that R-TYPE runs on 512K machine
* but see it yourself how it looks like.

* Big thanks goes to GGN :)

* NOTE: This release was NOT made of 512K version of RTYPE which
* comes with PowerPack 20 collection.
  
 text 
begin:
			movea.l	4(a7),a0
			move.l	a0,l0061
			
			movea.l	#l005d,a7
			move.l  $c(a0),d0 
			add.l   $18(a0),d0 
			add.l   $1c(a0),d0 
			add.l	#$100,d0

			move.l  d0,-(a7)
			move.l  a0,-(a7)
			pea     $4a0000 
			trap    #1
			adda.l  #12,a7

			dc.w    $a00a 

			clr.l    -(a7) 
			move.w  #$20,-(a7) 	;super
			trap    #1
			addq.l	#6,a7 
      
	 		clr.w   -(a7) 
      		pea		file1(pc)
      		move.w  #$3d,-(a7) 	;fopen
      		trap    #1
      		addq.l  #8,a7 
 	    	
 	    	move.w  d0,-(a7)
        	move.l  #$50000,-(a7)	;destination address
      		move.l  #45845,-(a7)	;amount of bytes
      		move.w  d0,-(a7)		;file handle
      		move.w  #$3f,-(a7)	 	;readfile
      		trap    #1
      		adda.l  #$c,a7
        	
        	move.w  #$3e,-(a7) 	;fclose 
      		trap    #1
      		addq.l  #4,a7 

			lea		$50000,a0
			bsr.w	depack2

			lea		$17ebc,a1
			move.l	#2,d5
			move.l 	#14,d6
			bsr.w	dmaload
			
			lea		$1865c,a1
			move.l	#1,d5
			move.l 	#12,d6
			bsr.w	dmaload

			lea		$20980,a1
			move.l	#9,d5
			move.l 	#13,d6
			bsr.w	dmaload

			lea		$18c80,a1
			move.l	#42,d5
			move.l 	#15,d6
			bsr.w	dmaload

**** NECESSARY EXE MODIFICATIONS ARE HERE *********************************

			move.b	#$60,($50000+$1192)	;collision cheat

;			move.w	#$4e71,($50000+$102)
			
;			move.l	#$4e714e71,($50000+$1b8)
;			move.w	#$4e71,($50000+$1b8+4)

;			move.l	#$4e714e71,($50000+$1cc)
;			move.w	#$4e71,($50000+$1cc+4)

;			move.l	#$4e714e71,($50000+$214)
;			move.w	#$4e71,($50000+$214+4)

;			move.l	#$4e714e71,($50000+$2b4)
;			move.w	#$4e71,($50000+$2b4+4)

;			move.l	#$4e754e71,($50000+$326)		
;			move.w	#$4e71,($50000+$326+4)

;			move.l	#$4e714e71,($50000+$3ae)		
;			move.l	#$4e714e71,($50000+$3ae+4)		
;			move.l	#$4e714e71,($50000+$3ae+8)		
			
			move.w	#$4ef9,($50000+$f00e)	;patch the exe to use external
			move.l	#$f1000,($50000+$f00e+2)	;loader code, jumps to $f1000
;	   		move.l  #$70004e75,($50000+$efd0)
***************************************************************************
      		
      		movea.l #l0004,a0 
      		movea.l #l0009,a1 
      		movea.l #$70000,a2
l0001:		move.l  (a0)+,(a2)+ 
      		cmpa.l  a0,a1 
      		bgt.s	l0001 

      		movea.l	#l0009,a0 
      		movea.l #l000f,a1 
 			movea.l	#$f1000,a2     		
;      		movea.l #($50000+$f00e),a2	;destination 
l0002:		move.l  (a0)+,(a2)+ 
      		cmpa.l  a0,a1 
      		bgt.s	l0002 
    		
    		
      		jmp     $70000

l0004:		move    #$2700,sr 
      		movea.l #$50000,a0 
      		movea.l #$400,a1
      		move.l  #$ac76,d0		;original size/2 
l0005:		move.w  (a0)+,(a1)+ 
      		dbf     d0,l0005

			jmp     $40a.l
			dc.l 0



l0009:		lea 	files(pc),a2
l000a:		movea.l a2,a3 
      		movea.l a0,a4 
      		move.w  #11,d0
l000b:		cmpm.b  (a3)+,(a4)+ 
      		bne.w   l000d 
      		dbf     d0,l000b
			bra.s	foundit
l000d: 		adda.l  #18,a2 
      		tst.b   (a2)
      		bne.w   l000a 
      		moveq   #$ff,d0 
l000e:		rts

foundit:	
;			move.l  (a3),d7 		;d7 has filesize for further use
			move.l	#0,d5
			move.l	#0,d6
			move.b	4(a3),d6		;starting track	
      		move.b	5(a3),d5		;amount of sectors
*******************************************************************
dmaload:		
			move.l	d0,d4
			move.l 	#1,d0				;starting sector
			move.l 	d5,d1				;numbers of sectors
			move.l 	d6,d2				;starting track
			
			movea.l	a1,a4		
			move.l	a0,d5
			move.l	a2,d6
			
			move.l 	#$0e0025000,$ffff8800.w	;side 0
			movea.l	a1,a5
			bsr		dmaloader

			movea.l	a4,a0
			bsr.w	depack2

			movea.l	a4,a1
			movea.l	d5,a0	
			movea.l	d6,a2
			move.l	d4,d0
			rts
	
**************[ DMA LOADER ]***********************************************	
max_sector equ 10
dmaloader
			lea       $ffff8606.w,a1 
			lea       -2(a1),a0
			bra.s     reader
byebye  	rts

charge  	lea     saver(pc),a3    		
			move.l  a5,(a3)        			
			move.b  3(a3),$ffff860d.w       
			move.b  2(a3),$ffff860b.w       
			move.b  1(a3),$ffff8609.w       
			move.w  #$90,(a1)
			move.w  #$190,(a1)
			move.w  #$90,(a1) 
			move.w  #1,(a0)                 
			move.w  #$84,(a1) 
			move.w  d0,(a0) 
			move.w  #$80,(a1)
			move.w  #$88,(a0) 
			lea     saver(pc),a6
			movem.l a5/d0-d2,(a6)
			lea     pipim(pc),a2    		
			subq.w  #1,d1           		* 1 secteur lu (donc -1 a lire !)
			bne.s   popom           		*
			lea     byebye(pc),a3   		* tout lu ?
			bra.s   waiter          		* si oui on termine la routine...

popom   	lea       charge(pc),a3   		*
			addq.w    #1,d0           		* +1 secteur sur la piste en cours
			lea       512(a5),a5      		* adresse data +512 octets
			cmpi.w    #max_sector+1,d0		* tous les secteurs de la piste
									  		* sont charges  (soit 10 sect.3) ?
			bne.s     waiter          		* si, non: alors on continue...
			moveq     #1,d0           		* si, oui: on repart sur secteur 1
			addq.w    #1,d2           		* de la piste suivante (+1 a piste)
			lea       reader(pc),a3   		*
			bra.s     waiter          		*

reader  	move.w    #$86,(a1)     		* fdc-dma/lecture reg de donnees
			move.w    d2,(a0)               * -> no de piste
			move.w    #$80,(a1)       		* fdc-dma/lecture reg d'etat
			move.w    #27,(a0)       		* -> 
			lea       charge(pc),a2   		*
waiter  	btst.b    #5,$fffffa01.w        * wait interrupt fdc
			bne.s     waiter          		*
			jmp       (a2)            * -> goto charge

pipim   	move.w	#$80,(a1)       	* fdc-dma/lecture reg d'etat
			move.w  (a0),d3         	*
			andi.w  #28,d3          	*
			bne.s   .ici            	*
			jmp     (a3)           		*
.ici    	movem.l saver(pc),a5/d0-d2	*
			bra.s   reader          	*
			rts

saver   dc.l 0,0,0,0,0
				   	
*****[ PACK-ICE v2.40 DEPACK ROUTINE ]*************************************
; a0 = Adress of packed data
depack2:
			link	a3,#-120
			movem.l	d0-a6,-(sp)
			lea		120(a0),a4
			move.l	a4,a6
			bsr		.getinfo
			cmpi.l	#'ICE!',d0
			bne		.not_packed
			bsr.s	.getinfo
			lea.l	-8(a0,d0.l),a5
			bsr.s	.getinfo
			move.l	d0,(sp)
			adda.l	d0,a6
			move.l	a6,a1

			moveq	#119,d0
.save:		move.b	-(a1),-(a3)
			dbf		d0,.save
			move.l	a6,a3
			move.b	-(a5),d7
			bsr.s	.normal_bytes
			move.l	a3,a5

			bsr		.get_1_bit
			bcc.s	.no_picture
			move.w	#$0f9f,d7
			bsr		.get_1_bit
			bcc.s	.ice_00
			moveq	#15,d0
			bsr		.get_d0_bits
			move.w	d1,d7
.ice_00:	moveq	#3,d6
.ice_01:	move.w	-(a3),d4
			moveq	#3,d5
.ice_02:	add.w	d4,d4
			addx.w	d0,d0
			add.w	d4,d4
			addx.w	d1,d1
			add.w	d4,d4
			addx.w	d2,d2
			add.w	d4,d4
			addx.w	d3,d3
			dbra	d5,.ice_02
			dbra	d6,.ice_01
			movem.w	d0-d3,(a3)
			dbra	d7,.ice_00
.no_picture
			movem.l	(sp),d0-a3

.move		move.b	(a4)+,(a0)+
			subq.l	#1,d0
			bne.s	.move
			moveq	#119,d0
.rest		move.b	-(a3),-(a5)
			dbf	d0,.rest
.not_packed:
			movem.l	(sp)+,d0-a6
			unlk	a3
			rts

.getinfo: 	moveq	#3,d1
.getbytes: 	lsl.l	#8,d0
			move.b	(a0)+,d0
			dbf	d1,.getbytes
			rts

.normal_bytes:	
			bsr.s	.get_1_bit
			bcc.s	.test_if_end
			moveq.l	#0,d1
			bsr.s	.get_1_bit
			bcc.s	.copy_direkt
			lea.l	.direkt_tab+20(pc),a1
			moveq.l	#4,d3
.nextgb:	move.l	-(a1),d0
			bsr.s	.get_d0_bits
			swap.w	d0
			cmp.w	d0,d1
			dbne	d3,.nextgb
.no_more: 	add.l	20(a1),d1
.copy_direkt:	
			move.b	-(a5),-(a6)
			dbf	d1,.copy_direkt
.test_if_end:	
			cmpa.l	a4,a6
			bgt.s	.strings
			rts	

.get_1_bit:
			add.b	d7,d7
			bne.s	.bitfound
			move.b	-(a5),d7
			addx.b	d7,d7
.bitfound:
			rts	

.get_d0_bits:	
			moveq.l	#0,d1
.hole_bit_loop:	
			add.b	d7,d7
			bne.s	.on_d0
			move.b	-(a5),d7
			addx.b	d7,d7
.on_d0:		addx.w	d1,d1
			dbf	d0,.hole_bit_loop
			rts	


.strings: 	lea.l	.length_tab(pc),a1
			moveq.l	#3,d2
.get_length_bit:	
			bsr.s	.get_1_bit
			dbcc	d2,.get_length_bit
.no_length_bit:	
			moveq.l	#0,d4
			moveq.l	#0,d1
			move.b	1(a1,d2.w),d0
			ext.w	d0
			bmi.s	.no_uber
.get_uber:
			bsr.s	.get_d0_bits
.no_uber:	move.b	6(a1,d2.w),d4
			add.w	d1,d4
			beq.s	.get_offset_2


			lea.l	.more_offset(pc),a1
			moveq.l	#1,d2
.getoffs: bsr.s	.get_1_bit
			dbcc	d2,.getoffs
			moveq.l	#0,d1
			move.b	1(a1,d2.w),d0
			ext.w	d0
			bsr.s	.get_d0_bits
			add.w	d2,d2
			add.w	6(a1,d2.w),d1
			bpl.s	.depack_bytes
			sub.w	d4,d1
			bra.s	.depack_bytes


.get_offset_2:	
			moveq.l	#0,d1
			moveq.l	#5,d0
			moveq.l	#-1,d2
			bsr.s	.get_1_bit
			bcc.s	.less_40
			moveq.l	#8,d0
			moveq.l	#$3f,d2
.less_40: 	bsr.s	.get_d0_bits
			add.w	d2,d1

.depack_bytes:
			lea.l	2(a6,d4.w),a1
			adda.w	d1,a1
			move.b	-(a1),-(a6)
.dep_b:		move.b	-(a1),-(a6)
			dbf	d4,.dep_b
			bra	.normal_bytes


.direkt_tab:
			dc.l $7fff000e,$00ff0007,$00070002,$00030001,$00030001
			dc.l     270-1,	15-1,	 8-1,	 5-1,	 2-1

.length_tab:
			dc.b 9,1,0,-1,-1
			dc.b 8,4,2,1,0

.more_offset:
			dc.b	  11,   4,   7,  0	; Bits lesen
			dc.w	$11f,  -1, $1f	; Standard Offset

ende_ice_decrunch_2:
;end of unpacking routine

 
files:	DC.B      'CSPRITES.DAT',$00,$00,$03,$60,12,1
      	DC.B      'EDLOGO  .NEO',$00,$00,$7d,$80,13,9
      	DC.B      'FONT    .DAT',$00,$00,$07,$A0,14,2
      	DC.B      'LOADSCRN.NEO',$00,$00,$7d,$80,15,42
      	DC.B      'EGG2    .DAT',$00,$00,$02,$30,20,1
      	DC.B      'LEV1    .DAT',$00,$00,$74,$00,21,27
      	DC.B      'LEV1    .MAP',$00,$00,$02,$D4,24,1
      	DC.B      'LEV2    .DAT',$00,$00,$54,$00,25,26
      	DC.B      'LEV2    .MAP',$00,$00,$02,$20,28,1
      	DC.B      'LEV3    .DAT',$00,$00,$18,$00,29,6
      	DC.B      'LEV3    .MAP',$00,$00,$02,$20,30,1
      	DC.B      'LEV4    .DAT',$00,$00,$44,$00,31,17
      	DC.B      'LEV4    .MAP',$00,$00,$02,$20,33,1
      	DC.B      'LEV5    .DAT',$00,$00,$0C,$00,34,4
      	DC.B      'LEV5    .MAP',$00,$00,$02,$EC,35,1
      	DC.B      'LEV6    .DAT',$00,$00,$34,$00,36,8
      	DC.B      'LEV6    .MAP',$00,$00,$02,$20,37,1
      	DC.B      'LEV7    .DAT',$00,$00,$44,$00,38,20
      	DC.B      'LEV7    .MAP',$00,$00,$02,$20,40,1
      	DC.B      'LEV8    .DAT',$00,$00,$24,$00,41,11
      	DC.B      'LEV8    .MAP',$00,$00,$01,$6c,43,1
      	DC.B      'SHIP    .DAT',$00,$00,$3f,$C0,44,12
      	DC.B      'SPRITES1.DAT',$00,$01,$e0,$50,46,117
      	DC.B      'SPRITES2.DAT',$00,$01,$6d,$d8,58,183
      	DC.B      'TAIL    .INF',$00,$00,$06,$0C,77,3
      	dc.b      $00,$00 
		dc.b      $00,$00 
      	dc.b      $00 
l000f:	nop
		nop
		nop

file1	dc.b	'rtype.exe',0

 bss
l005c:ds.b		512
l005d:ds.l		1
l0061:ds.l      1 

