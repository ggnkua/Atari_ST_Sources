**********************************************************
*  chunk 2 Planar demo     *           coded by ray 2000 *
**********************************************************
* send qestions or comments to reimund.dratwa@freenet.de *		  
* and try http://rd-developments.de.gs                   *
**********************************************************
* thanx and greetings to cream , especially candyman     *
**********************************************************

                TEXT
		clr.l   -(SP)			* enter supervisor
		move	#$20,-(sp)		* mode
		trap    #1
		addq.l  #6,SP
		move.l  D0,OLD_SP		* don't forget :)


                clr.w   -(SP)			* open the chunk2planar
                pea     FNAME			* lookup-table file
                move.w  #$3D,-(SP)		* just make sure that
                trap    #1			* it is in the same dir
                addq.l  #8,SP			* as the assembled prog

                pea     C2PTBL			* load it into memory
                move.l  #16*16*16*16*4+4,-(SP)  * (it's 256kb huge so
                move.w  D0,-(SP)                *  i don't include it
                move.w  #$3F,-(SP)              *  and not every as-
                trap    #1			*  sembler does this,
                adda.l  #12,SP			*  either)
                

		move.l  $044E,PHYBASE		* save some stuff...
		moveq   #0,D0
		move.b  $FFFF8260,D0		
		move.w  D0,REZ

		lea     SYSPAL,A0
		lea     $FFFF8240,A1

		moveq   #16-1,D0
SAVEPAL:	move.w  (A1)+,(A0)+
		dbra    D0,SAVEPAL

		move.l  #SCREEN,D0		* address of screenbuffer
                move.b  #$00,D0			* align it to 256
                move.l  D0,SCREENADR		* save screenbase

		move.b  #0,$FFFF8260            * low rez
		
		lsr.l 	#8,D0			* set new phybase
		move.b	D0,$FFFF8203.w
		lsr.l   #8,D0
		move.b  D0,$FFFF8201.w		

		lea     PALETTE,A0		* set the new palette
		lea     $FFFF8240,A1

		moveq   #16-1,D0
SETPAL:		move.w  (A0)+,(A1)+
		dbra    D0,SETPAL


* here we convert the chunkybuffer
* so that's the interesting part....

C2P:            
		move    SR,-(SP)		* wvbl
		and     #$F8FF,sr
		move.l  $466,d0
VBL_LOOP:	cmp.l   $466,d0
		beq.s   VBL_LOOP
		move    (SP)+,SR

                movea.l SCREENADR,A2		* A2 : screenbase
		lea     CHUNKYBUFFER,A0		* A0 : chunkybuffer
                lea     C2PTBL,A1		* A1 : lookuptable

                move.w  #100-1,D2		* loop 100 times
DO100LINES:					* (for 100 'pseudo' scanlines)
                
                move.w  #20-1,D7		* convert one scanline
SETPIXEL:					* = 20 * 8 doublepixels

                moveq   #0,D0			* clear D0.l
                move.w  (A0)+,D0		* get first 2 bytes out of
                lsl.w   #4,D0			* the chunkybuffer
                or.w    (A0)+,D0		* since each byte is between
						* $0..$F we can 'pack' 4 bytes
						* in one word...read the 
						* tutorial

                lsl.l   #2,D0			* calculate offset in c2p.tbl 

                move.l  0(A1,D0.l),D0 		* get one longword

* that's the whole trick... 'movep.l'

                movep.l D0,0(A2)		* set 4 doublepixels
                movep.l D0,160(A2)		* same thing for next
						* scanline on the screen


                moveq   #0,D0			* do the next 4 doublepixels
                move.w  (A0)+,D0                * (odd bitplane-addresses)
                lsl.w   #4,D0
                or.w    (A0)+,D0
                lsl.l   #2,D0

                move.l  0(A1,D0.l),D0

                movep.l D0,1(A2)
                movep.l D0,161(A2)


                addq.w  #8,A2			* go to the next 4 bitplanes
		dbra    D7,SETPIXEL             * and do it 20 times = one scanline



                adda.w  #160,A2			* now we wanna do the next virtual
						* scanline and since the chunkypixels
						* are 2*2 pixels on the screen we 					
 						* need to skip one scanline						
						
                dbra    D2,DO100LINES		* do 100 pseudo scanlines




                lea     CHUNKYBUFFER,A3		* this part scrolls the crunky-
                lea     CHUNKYBUFFER,A4		* buffer horizontally
                addq.l  #1,A4

                move.w  #16000-1,D4		* imagine how you would do this
SCROLLLOOP:     move.b  (A4)+,(A3)+		* with planar-graphics !?!
                dbra    D4,SCROLLLOOP



		move.b  $0FFFFC02,D0
	        cmpi.b  #$39,D0			* someone pressed space ?
                bne     C2P			* no, then draw the next screen...


		move.l  OLD_SP,-(SP)		* switch back to user mode
		move.w  #$20,-(SP)
		trap	#1
		addq.l  #6,SP

                move.w  REZ,-(SP)		* restore the old
                move.l  PHYBASE,-(SP)		* screen using the
                move.l  PHYBASE,-(SP)		* old fashion way...
                move.w  #5,-(SP)
                trap    #14			* we aren't in super-
                adda.w  #12,SP			* visormode any more :( 

                pea     SYSPAL
                move.w  #6,-(SP)
                trap    #14
                addq.l  #6,SP

                clr.w   -(SP)			* ....go to Desktop
                trap    #1

                EVEN

                DATA
CHUNKYBUFFER:   REPT 1000		* 16000 bytes
                DC.L $010203		* got it ? - the chunky screen	 
                DC.L $04050607		* has a rez of 160 * 100 chunkypixels ?
                DC.L $08090A0B		* it's built up like this:
                DC.L $0C0D0E0F		* 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F...
                ENDR			* just the sixteen colors on and on

                DC.L $0A000000          * this color gets scrolled in

PALETTE:        DC.W $0000,$0100,$0200,$0300,$0400,$0500,$0600,$0700  * some nice
                DC.W $0710,$0720,$0730,$0740,$0750,$0760,$0770,$0777  * fire-colors


FNAME:          DC.B 'C2P.TBL'	        * filename of the lookup table
                EVEN

                BSS
                DS.B 256		* that's for the 256 alignment
SCREEN:         DS.B 32000		* and these are the 32000 screenbytes
                DS.B 256

SYSPAL:         DS.W 16			* for restoring the old screen params and stuff
REZ:		DS.W 1			* after term
PHYBASE:	DS.L 1

OLD_SP:		DS.L 1

SCREENADR:      DS.L 1
C2PTBL:         DS.L 16*16*16*16        * space for the chunk 2 planar lookup-tbl
                END