;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 		     Total Apathy MegaDemo From The BBC			 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									 ;;
;; 			****  *****  **** ***** *****			 ;;
;; 			*   * *     *     *       *			 ;;
;; 			****  ***    ***  ***     *			 ;;
;; 			*   * *         * *       *			 ;;
;; 			*   * ***** ****  *****   *			 ;;
;;									 ;;
;;	       Code: The Law   Music: Big Alec   Font: Xerud	 	 ;;
;;									 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 		     Total Apathy MegaDemo From The BBC			 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ramtop		equ $17e000
relocate	equ $120000
;set_reset

	lea $2000.w,a7
	clr.w -(a7)
	move.l #ramtop-$7d00,-(a7)
	move.l (a7),-(a7)
	move.w #5,-(a7)
	trap #14
	lea 12(a7),a7
	pea code(pc)
	move.w #$26,-(a7)
	trap #14
	addq.w #6,a7
	clr.l -(a7)
	trap #1

code

	lea crappy_genst_problem,a0
	lea crappy_genst_problem+40000,a1
	lea relocate,a2
.move	move.b (a0)+,(a2)+
	cmp.l a0,a1
	bne.s .move
	jmp relocate

crappy_genst_problem
	org relocate
INIT
	ifd set_reset
	move.l #$31415926,$426.w
	move.l #INIT,$42a.w
	endc
	lea ramtop+$1000,a7
	moveq.l #1,d0			; init the music
	bsr music
	bsr mfp
	tst.w fixtst
	bmi.s RESET
	moveq.l #1,d0			; init the music
	bsr music
	jsr fix_y			; fix the bounce table
	jsr make_text			; convert bitmap to colourmap
	neg.w fixtst

RESET	lea ramtop+$1000,a7
	ifd set_reset
	move.l #$31415926,$426.w
	move.l #RESET,$42a.w
	move.l #table,tpnt1
	move.l #ramtop-$7d00-(8*160),screen
	move.l #ramtop-$7d00-(8*160),horiz
	endc
	bsr mfp
	lea $fffffa07.w,a0
	moveq.l #0,d0
	movep.w d0,(a0)
	move.l screen1,a0		; erase screen
	move.l #$7d00/4,d0
.wipe	clr.l (a0)+
	subq.l #1,d0
	bne.s .wipe
	move.b screen1+1,$ffff8201.w	; set screen
	move.b screen1+2,$ffff8203.w

	move.l #table,tpnt1
	movem.l pall1,d0-1
	movem.l d0-1,$ffff8240.w
	move.l #vbl,$70.w		; set vbl
	move.w #$2300,sr

.main	move.l tpnt1,a0
	move.l (a0)+,d0
	bpl.s .write
	lea table(pc),a0
	move.l (a0)+,d0
.write	move.l a0,tpnt1
	move.l d0,tpnt
	move.l d0,-(a7)
	bsr blatt_text_on
	move.w #49,d0
.wait	bsr frame
	dbra d0,.wait
	move.l (a7)+,tpnt
	bsr blatt_text_off
	move.l pallptr,a0
	move.l (a0)+,d0
	bpl.s .ok
	lea palltab,a0
	move.l (a0)+,d0
.ok	move.l a0,pallptr
	move.l d0,a0
	movem.l (a0),d0-1
	movem.l d0-1,$ffff8240.w
	bra.s .main

mfp	move.w #$2700,sr
	lea $fffffa01.w,a0
	lea $fffffa31.w,a1
	lea buffer,a2
.loop	move.b (a2)+,(a0)
	addq.l #2,a0
	cmp.l a0,a1
	bne.s .loop	
	rts

buffer	dc.w $ff00,$001e,$6400,$0000,$001e,$6448
	dc.w $0000,$5150,$c6b7,$0200,$0000,$90ff

pallptr	dc.l palltab+4
palltab	dc.l pall1,pall2,pall3,pall4,-1
pall1	dc.l $00000232,$01210343
pall2	dc.l $00000400,$03000721
pall3	dc.l $00000035,$00230057
pall4	dc.l $00000333,$02220555

fixtst	dc.w 1

tpnt1	dc.l table
table	dc.l text0,text1,text1a,text2,text3,text4,text5,text6,text7,text8
	dc.l text9,texta,textb,textc,textd,texte,textf,textg,texth,texti
	dc.l textj,textk,textl
	dc.l goodbye1,goodbye2
	dc.l -1

;	DC.B "01234567890123456789"

free	MACRO
	dc.b "                    ",-2
	ENDM

text0	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*  YOU JUST RESET  *",-2
	DC.B "*                  *",-2
	DC.B "*   TOTAL APATHY   *",-2
	DC.B "*                  *",-2
	DC.B "*  COPYRIGHT 1991  *",-2
	DC.B "*                  *",-2
	DC.B "*      THE BAD     *",-2
	DC.B "*     BREW CREW    *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free
	even

text1	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*  TO KEEP UP THE  *",-2
	DC.B "*    TRADITIONS    *",-2
	DC.B "*  THIS RESET WILL *",-2
	DC.B "*    CONTAIN THE   *",-2
	DC.B "*                  *",-2
	DC.B "*  **************  *",-2
	DC.B "*  *WHO DID WHAT*  *",-2
	DC.B "*  **************  *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text1a	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*  THIS RESET WAS  *",-2
	DC.B "* COMPLETED BY LAW *",-2
	DC.B "*  ON MY BIRTHDAY  *",-2
	DC.B "*  11TH SEPTEMBER  *",-2
	DC.B "*                  *",-2
	DC.B "* ONE FIFTH OF A   *",-2
	DC.B "* CENTURY GONE...  *",-2
	DC.B "* LOTS LEFT I HOPE *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text2	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* THE INTRO SCREEN *",-2
	DC.B "* **************** *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* GRAPHICS BY..... *",-2
	DC.B "* XERUD            *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text3	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* THE FILE LOADER  *",-2
	DC.B "* ***************  *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* LAW              *",-2
	DC.B "*                  *",-2
	DC.B "* PICCY AND FONT.. *",-2
	DC.B "* FLOYD            *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text4	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* THE MAIN MENU    *",-2
	DC.B "* *************    *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* GRAPHICS BY..... *",-2
	DC.B "* XERUD            *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text5	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* THE PARASPRITE   *",-2
	DC.B "* **************   *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* LAW              *",-2
	DC.B "*                  *",-2
	DC.B "* GRAPHICS BY..... *",-2
	DC.B "* XERUD            *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text6	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* VECTORBALLS      *",-2
	DC.B "* ***********      *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* BALLSPRITES BY.. *",-2
	DC.B "* XERUD            *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text7	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* ZOLYX            *",-2
	DC.B "* *****            *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* THIS IS THE GAME *",-2
	DC.B "* ANDY LIKES BEST. *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text8	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* UGLY             *",-2
	DC.B "* ****             *",-2
	DC.B "*                  *",-2
	DC.B "* UPCHUCKED BY.... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* FONT FROM AMIGA  *",-2
	DC.B "* BITS BY XERUD    *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

text9	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* BITBENDER        *",-2
	DC.B "* *********        *",-2
	DC.B "*                  *",-2
	DC.B "* CODING BY....... *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "* FONT RIPPED FROM *",-2
	DC.B "* THE AMIGA        *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

texta	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* LIGHT CYCLES     *",-2
	DC.B "* ************     *",-2
	DC.B "*                  *",-2
	DC.B "* CODED BY LAW     *",-2
	DC.B "* GRAFIX BY XERUD  *",-2
	DC.B "*                  *",-2
	DC.B "* LAWS FIRST GAME  *",-2
	DC.B "* AND HE HATES IT  *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textb	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* LOGOSCROLLER     *",-2
	DC.B "* ************     *",-2
	DC.B "*                  *",-2
	DC.B "* CODED BY LAW     *",-2
	DC.B "*                  *",-2
	DC.B "* GRAPHICS BY XER  *",-2
	DC.B "*                  *",-2
	DC.B "* ITS A DISKFILLER *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textc	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*   THE ZOOMROOM   *",-2
	DC.B "*   ************   *",-2
	DC.B "*                  *",-2
	DC.B "*     CODED BY     *",-2
	DC.B "*       LAW.       *",-2
	DC.B "*                  *",-2
	DC.B "* GFX AND SFX FROM *",-2
	DC.B "*     * FLOYD *    *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textd	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* ZIPPYS OVERSCAN  *",-2
	DC.B "* ***************  *",-2
	DC.B "*                  *",-2
	DC.B "* CODED BY........ *",-2
	DC.B "* ZIPPY            *",-2
	DC.B "*                  *",-2
	DC.B "* LOGO FROM XERUD  *",-2
	DC.B "* FONT BY *ANON*   *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

texte	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*  HIDDEN  SCREEN  *",-2
	DC.B "*  **************  *",-2
	DC.B "*                  *",-2
	DC.B "* OUR NIGHTMARE BY *",-2
	DC.B "* ANDY THE ARFLING *",-2
	DC.B "*                  *",-2
	DC.B "*    WE REALLY     *",-2
	DC.B "*  ARE THAT UGLY.  *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textf	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* BEEBRIS          *",-2
	DC.B "* *******          *",-2
	DC.B "*                  *",-2
	DC.B "* CODE BY LAW      *",-2
	DC.B "* GRFX BY XERUD    *",-2
	DC.B "*                  *",-2
	DC.B "* THIS HAS TAKEN   *",-2
	DC.B "* ME MANY HOURS    *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textg	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* TETRIS BY MOTLEY *",-2
	DC.B "* **************** *",-2
	DC.B "*                  *",-2
	DC.B "* SPECIFICALLY     *",-2
	DC.B "* CODED FOR TOTAL  *",-2
	DC.B "* APATHY BY MOTLEY *",-2
	DC.B "*                  *",-2
	DC.B "* YUP. ANOTHER ONE *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

texth	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "* UGLY 2. BITMANIA *",-2
	DC.B "* **************** *",-2
	DC.B "*                  *",-2
	DC.B "* CODE BY LAW      *",-2
	DC.B "* BBC LOGO BY ANDY *",-2
	DC.B "* FONT FROM AMIGA  *",-2
	DC.B "*                  *",-2
	DC.B "* A DISK FILLER    *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

texti	free
	DC.B "********************",-2
	DC.B "*                  *",-2
	DC.B "*    GREETINGS.    *",-2
	DC.B "*    **********    *",-2
	DC.B "*                  *",-2
	DC.B "* CODED BY ANDY    *",-2
	DC.B "* GRAFIX BY GFA    *",-2
	DC.B "*                  *",-2
	DC.B "* A VERY PRETTY    *",-2
	DC.B "* SCREEN INDEED.   *",-2
	DC.B "*                  *",-2
	DC.B "********************",-2
	DC.B -1
	free

textj	free
	DC.B "AND NOW THE PART ALL",-2
	DC.B "  YOU CODE RIPPERS  ",-2
	DC.B "    HATE US FOR.    ",-2
	DC.B "                    ",-2
	DC.B "   THE PROTECTION   ",-2
	DC.B "                    ",-2
	DC.B " LETS JUST SAY THAT ",-2
	DC.B "WE THINK THIS IS THE",-2
	DC.B "    MOST HEAVILY    ",-2
	DC.B " PROTECTED DEMODISK ",-2
	DC.B " THAT HAS EVER BEEN ",-2
	DC.B " RELEASED INTO P.D. ",-2
	DC.B -1
	free

textk	free
	DC.B "  CONSIDER THIS...  ",-2
	DC.B "                    ",-2
	DC.B "  * IT  CONTAINS *  ",-2
	DC.B "                    ",-2
	DC.B "4 SHELLS FROM ZIPPY ",-2
	DC.B "3 SHELLS FROM LAW   ",-2
	DC.B "2 SHELLS FROM ANDY  ",-2
	DC.B "                    ",-2
	DC.B "WITH SOME NEW TRICKS",-2
	DC.B "                    ",-2
	DC.B "IT MAKES UNION DEMOS",-2
	DC.B "LOOK LIKE A VACATION",-2
	DC.B -1
	free

textl	free
	DC.B "MODESTY ASIDE...    ",-2
	DC.B "                    ",-2
	DC.B "ONE OF BRITIANS BEST",-2
	DC.B "EVER CRACKERS AND 2 ",-2
	DC.B "EX-CRACKERS CODED IT",-2
	DC.B "AND WE KNOW WHAT YOU",-2
	DC.B "DONT LIKE CRACKING  ",-2
	DC.B "                    ",-2
	DC.B "SO GET YOUR THINKING",-2
	DC.B "HATS ON AND TRY IT  ",-2
	DC.B "WITHOUT USING A SCUM",-2
	DC.B "SUCKING CARTRIDGE...",-2
	DC.B -1
	free

goodbye1
	free
	DC.B "  FOR NOW FAREWELL  ",-2
	DC.B "FROM ALL THE MEMBERS",-2
	DC.B "OF THE BAD BREW CREW",-2
	DC.B "                    ",-2
	DC.B "    WE HOPE THAT    ",-2
	DC.B "  YOU ENJOYED THIS  ",-2
	DC.B "    * MEGADEMO *    ",-2
	DC.B "                    ",-2
	DC.B " MAYBE YOU WILL SEE ",-2
	DC.B " US AGAIN SOON ON A ",-2
	DC.B " DISK IN YOUR BOX.. ",-2
	DC.B "                    ",-2
	DC.B -1
	free

goodbye2
	free
	DC.B " ***** *    * ***** ",-2
	DC.B "   *   *    * *     ",-2
	DC.B "   *   ****** ***   ",-2
	DC.B "   *   *    * *     ",-2
	DC.B "   *   *    * ***** ",-2
	DC.B "        GAME        ",-2
	DC.B "        OVER        ",-2
	DC.B " ***** *    * ****  ",-2
	DC.B " *     **   * *   * ",-2
	DC.B " ***   * ** * *   * ",-2
	DC.B " *     *   ** *   * ",-2
	DC.B " ***** *    * ****  ",-2
	DC.B -1
	free

frame	move.l d0,-(a7)
	move.w timer,d0
.del	cmp.w timer,d0
	beq.s .del
	move.l (a7)+,d0
	rts

screen1	dc.l ramtop-$7d00

key	move.b $fffffc02.w,mkey
	bclr.b #6,$fffffa11.w
	rts
mkey	dc.w 0

music	incbin sanxion.al		; chip sonix
	even

txt	incbin text_1.grf		; 1 plane bitmap image
	even

screen	dc.l ramtop-$7d00-(160*8)

blatt_text_off
	move.l tpnt,text_start
	move.l #-32*80,d7
	move.l #16*160,d5
	move.l #font+(80*32*6),d2
	lea ascii,a2		; pointer to offset table
	lea horiz,a3
	bra.s skip_consts

blatt_text_on
	move.l tpnt,text_start
	move.l #32*80,d7	; offset to next scale of font
	move.l #16*160,d5	; offset to next line
	moveq.l #8,d4		; offset to next char
	move.l #font,d2		; pointer to start of font
	lea ascii,a2		; pointer to offset table
	lea horiz,a3

skip_consts
	move.l d2,d6 
	move.l tscrn,a0		; address to plot next character at
	add.l d4,tscrn		; ready for next vbl!
	move.l tpnt,a1		; pointer to characters
	addq.l #1,tpnt		; ready for next vbl!

	bsr frame

	moveq.l #6,d0		; do six character this frame!
.char	moveq.l #0,d1
	move.b (a1)+,d1
	bpl.s .norm
	addq.b #1,d1
	bne.s .cr_lf
	move.l text_start,a1
	move.l screen,a0
	cmp.b #6,d0
	bne.s .char
	move.l a1,tpnt
	move.l a0,(a3)
	move.l a0,tscrn
	rts

.cr_lf	move.l (a3),a0
	add.l d5,a0
	cmp.b #6,d0
	bne.s .char
	move.l a0,(a3)
	move.l a0,tscrn
	bra.s .char

.norm	sub.b #' ',d1
	add.w d1,d1
	add.w d1,d1
	move.l (a2,d1),a4	; now contains offset 
	add.l d6,a4
x	set 0
y	set 0
	rept 16
	move.l y(a4),x(a0)
x	set x+160
y	set y+80
	endr
	add.l d7,d6		; jump to next font
	add.l d4,a0		; next place for character
	dbra d0,.char
	bra skip_consts

text_start	dc.l 0
horiz	dc.l ramtop-$7d00-(160*8)
new_pal	incbin pallette.bin

blank_char	equ (16*80)+76

ascii	rept 10
	dc.l blank_char
	endr
	dc.l (16*80)+64		; '*'
	dc.l blank_char
	dc.l blank_char
	dc.l blank_char
	dc.l (16*80)+68		; '.'
	dc.l blank_char
	dc.l (16*80)+60		; '0'
xxx	set 24
	rept 9
	dc.l (16*80)+xxx	; 1-9
xxx	set xxx+4
	endr
	rept 7
	dc.l blank_char
	endr
xxx	set 0
	rept 20
	dc.l xxx		; a-t
xxx	set xxx+4
	endr
xxx	set 0
	rept 6
	dc.l (16*80)+xxx	; u-z
xxx	set xxx+4
	endr
	rept 20
	dc.l blank_char
	endr

tscrn	dc.l ramtop-$7d00-(160*8)
tpnt	dc.l 0

	ds.b 32*80
font	incbin zoom.fnt
	ds.b 32*80

bounce	dc.l bouncy			; wave table
bouncy	incbin bounce_y.bin
	dc.l $ffffffff
	even

vbl	clr.b $ffff8260.w		; set low-rez
	move.b #2,$ffff820a.w
	movem.l d0-a6,-(a7)
	move.w #$2700,sr
	move.b screen1+1,$ffff8201.w
	move.b screen1+2,$ffff8203.w

	move.l #chars*16,d7		; length of rastertext-line
	sub.w #80,d7			; offset to next from screen end

	move.l #(8*20)+32,d6		; lines to burn up on col-changing

	subq.w #1,jmp_cnt		; use nops to move?
	bpl.s .skp
	move.w #2,jmp_cnt		; no! reset pointer

	subq.w #1,count			; still moving?
	bpl.s .ok			; yes!
	move.w #chars*8-(4*8)-16,count	; length to scroll
	neg.l direct			; swap directions
	move.l ptr1,d0			; swap directional nops
	move.l ptr2,ptr1
	move.l d0,ptr2
.ok	move.l direct,d0
	add.l d0,col_ptr
.skp	move.l col_ptr,a2
	move.w jmp_cnt,d5		; get nop value (0,1,2)
	add d5,d5			; convert to long access
	add d5,d5
	move.l ptr1,a4
	move.l (a4,d5),a4		; get jmp address

	move.l bounce,a0		; get bounce pointer
	move.l (a0)+,d0			; get height
	cmp.w #-1,d0
	bne.s .write
	lea bouncy(pc),a0		; wrap bounce table
	move.l (a0),d0
.write	move.l a0,bounce
	add.l d0,a2
	
	lea $ffff8240.w,a1		; background col (const)
	lea $ffff8209.w,a0		; wait for sync
	moveq.l #16,d1
	moveq.l #0,d0
.hang	move.b (a0),d0
	beq.s .hang
	sub.w d0,d1			; correct
	lsl d1,d0			; sync

;;;; !WARNING! *** CLOCK CYCLE COUNTING BELOW HERE *** !WARNING! ;;;;

	jmp (a4)			; jmp into nop table
ptr1	dc.l jmptab1
ptr2	dc.l jmptab2
jmptab1	dc.l nops+4,nops+2,nops		; right to left offsets
jmptab2	dc.l nops,nops+2,nops+4		; left to right offsets
jmp_cnt	dc.w 2				; vbl's till nop reset
nops	rept 96				; wait for next scanline
	nop
	endr

.cols	rept 40
	move.w (a2)+,(a1)		; copy buffer to screen
	endr
	add.w d7,a2			; next line of colour
	nop				; waste 8 clocks
	nop
	subq.w #1,d6			; 4 clocks
	bne .cols			; 10 clocks
	clr.w (a1)			; black!

	bsr music+4			; play music
	addq.w #1,timer

	movem.l (a7)+,d0-a6
	rte

timer	dc.w 0

fix_y	move.l #chars*16,d7		; rasterline = chars*16 bytes
	lea bouncy,a0			; start of table
.loop	move.l (a0),d0
	bmi.s .done
	mulu d7,d0			; now offset value
	move.l d0,(a0)+
	bra.s .loop
.done	rts

sikbd	move.b d0,$fffffc02.w		; send to key-chip
	move.w #$2000,d0
.del	dbra d0,.del
	rts

chars	equ 38				; # of characters to convert
line	equ chars*16			; length of one line
make_text
	lea txt,a0			; start of bitmap
	lea col_tab,a1			; start building here
	move.l #chars*8*80,d0		; 80 lines
.wip	clr.w (a1)+			; that are now black!
	subq.l #1,d0
	bne.s .wip
	bsr make_line			; one line white border
	moveq.l #7,d1			; conv 7 lines of bitmaps
.outr	moveq.l #chars,d0		; numbr to convert
	move.l a1,-(a7)
.loop	move.b (a0)+,d7
	bsr process			; change bitmap to rgb
	subq.l #1,d0
	bne.s .loop
	bsr update_col	
	lea 40-chars(a0),a0		; next line in bitmap
	move.l (a7)+,a1
	lea line*16(a1),a1		; next line in rgb
	subq.l #1,d1
	bne.s .outr
	bsr make_line			; one line white border
	move.l #30000,d0		; then make black footer
.wipe	clr.w (a1)+
	subq.w #1,d0
	bne.s .wipe
	rts
process	moveq.l #7,d6			; 8 bits/byte (never....)
proc	btst d6,d7
	beq .off
	bsr .block			; bit set
	bra.s .skip
.off	bsr .clear			; bit clear
.skip	dbra d6,proc
	rts
.clear	bsr update_col			; next colour table
	move.l #$00020002,d5		; fill with grey
	move.w d5,line*0(a1)
	move.w d5,line*1(a1)
	move.w d5,line*2(a1)
	move.w d5,line*3(a1)
	move.w d5,line*4(a1)
	move.w d5,line*5(a1)
	move.w d5,line*6(a1)
	move.w d5,line*7(a1)
	move.w d5,line*8(a1)
	move.w d5,line*9(a1)
	move.w d5,line*10(a1)
	move.w d5,line*11(a1)
	move.w d5,line*12(a1)
	move.w d5,line*13(a1)
	move.w d5,line*14(a1)
	move.w d5,line*15(a1)
	addq.l #2,a1
	rts

.block	bsr update_col			; next colour table
	move.w (a6)+,line*0(a1)		; fill with colours
	move.w (a6)+,line*1(a1)
	move.w (a6)+,line*2(a1)
	move.w (a6)+,line*3(a1)
	move.w (a6)+,line*4(a1)
	move.w (a6)+,line*5(a1)
	move.w (a6)+,line*6(a1)
	move.w (a6)+,line*7(a1)
	move.w (a6)+,line*8(a1)
	move.w (a6)+,line*9(a1)
	move.w (a6)+,line*10(a1)
	move.w (a6)+,line*11(a1)
	move.w (a6)+,line*12(a1)
	move.w (a6)+,line*13(a1)
	move.w (a6)+,line*14(a1)
	move.w (a6)+,line*15(a1)
	addq.l #2,a1
	rts
make_line	
	move.l #chars*8,d5		; make a line of white
.loop	move.w #$777,(a1)+
	subq.w #1,d5
	bne.s .loop
	rts

update_col
	add.l #32,pal_ptr		; cycle through colours
	move.l pal_ptr,a6
	tst.l (a6)
	bpl.s .ok
	lea pal(pc),a6
.ok	move.l a6,pal_ptr
	rts

pal_ptr	dc.l pal-32
pal	dc.w $100,$200,$300,$400,$500,$600,$700,$700
	dc.w $700,$700,$600,$500,$400,$300,$200,$100
	dc.w $010,$020,$030,$040,$050,$060,$070,$070
	dc.w $070,$070,$060,$050,$040,$030,$020,$010
	dc.w $001,$002,$003,$004,$005,$006,$007,$007
	dc.w $007,$007,$006,$005,$004,$003,$002,$001
	dc.w $101,$202,$303,$404,$505,$606,$707,$707
	dc.w $707,$707,$606,$505,$404,$303,$202,$101
	dc.w $110,$220,$330,$440,$550,$660,$770,$770
	dc.w $770,$770,$660,$550,$440,$330,$220,$110
	dc.w $011,$022,$033,$044,$055,$066,$077,$077
	dc.w $077,$077,$066,$055,$044,$033,$022,$011
	dc.l -1
	even

direct	dc.l 2
count	dc.w 8*chars-(4*8)-16
col_ptr	dc.l col_tab+8
col_tab	dc.l 0			; ram trashed from here on up!