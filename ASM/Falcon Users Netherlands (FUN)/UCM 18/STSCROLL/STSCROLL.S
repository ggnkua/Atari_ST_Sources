* ST horizontal scroller.
* A little demonstration by earx/fun.
* Thanx to atari for the font.
* Please run in ST-LOW.

* Change to supervisor-mode.
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

* Save old screenaddress.
	move	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,old_screenaddress

* Save old palette.
	lea	$ffff8240.w,a1
	lea	old_palette_table,a0
	moveq	#16-1,d7
save_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,save_palette_loop

* Set new color.
	clr.w	$ffff8240.w

* Initialize screenaddresses.
	move.l	#screen_buffer+255,d0		* Get bufferaddress+255 in d0.
	sub.b	d0,d0				* Make it 256 byte aligned.
	move.l	d0,physical_screen		* Store first address.
	addi.l	#160*200,d0			* Move to next screenaddress.
	move.l	d0,logical_screen		* Store second address.

* Execute the main loop.
main_loop:
* Draw graphics onto the logical screen.
        bsr     DRAW_SCROLLUPDATE

* Swap screenbuffers.
	move.l	logical_screen,d0
	move.l	physical_screen,logical_screen
	move.l	d0,physical_screen

* Set new screenaddress.
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Wait for the VBL...
	move.w	#37,-(sp)
	trap	#14
	addq	#2,sp

	cmpi.b	#$39,$fffffc02.w		* Spacebar pressed?
	bne	main_loop			* If not, keep looping.

* Restore old palette.
	lea	$ffff8240.w,a0
	lea	old_palette_table,a1
	moveq	#16-1,d7
restore_palette_loop:
	move.w	(a1)+,(a0)+
	dbra	d7,restore_palette_loop

* Restore old screenaddress.	
	move.l	old_screenaddress,d0
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w

* Terminate program.
	clr.w	-(sp)
	trap	#1

* [=>>> Funky 1bit scrolleR <<<=] *

DRAW_SCROLLUPDATE:
* First copy the previous scroller left 8 pixels on the actual screen.
* This is done by copying from the physical to the logical screen.
        movea.l logical_screen,a0               * a0 = logical screenaddress
        movea.l physical_screen,a1              * a1 = physical screenaddress
        addq    #1,a1                           * next charposition
        moveq   #8-1,d7                         * 8 lines in character

yloop:  REPT    40-1                            * screenblocks todo
        move.b  (a1),(a0)+                      * Copy next to actual.
        addq    #8-1,a1                         * Increase to next block.
        move.b  (a1)+,(a0)                      * Copy next to actual.
        addq    #8-1,a0                         * Increase to next block.
        ENDR
        move.b  (a1),(a0)                       * Do last character.
        addq    #8,a1                           * next screenline
        addq    #8,a0                           * next screenline
        dbra    d7,yloop                        * until screenlines done

* Now draw the new character on the right side of the screen.
        movea.l logical_screen,a0               * a0 = logical screenaddress
        lea     160-7(a0),a0                    * last charposition
        lea     font_dat,a1                     * a1 = fontbuffer-address
        lea     scroll_txt,a2                   * a2 = scrolltext-address
        adda.w  textposition,a2                 * Get actual textaddress
        moveq   #0,d0                           * / Calculate offset
        move.b  (a2)+,d0                        * | into
        lsl.l   #3,d0                           * \ fontbuffer.
        adda.l  d0,a1
        move.b  (a1)+,(a0)                      * Draw first line.
        move.b  (a1)+,160(a0)                   * Draw second.
        move.b  (a1)+,320(a0)                   * Draw third..
        move.b  (a1)+,480(a0)                   * etc....
        move.b  (a1)+,640(a0)
        move.b  (a1)+,800(a0)
        move.b  (a1)+,960(a0)
        move.b  (a1)+,1120(a0)
        addq.w  #1,textposition			* Update textposition.
	tst.b	(a2)				* Test next character.
        beq.s   null                            * If nullchar > go out!
        rts
null:   clr.w   textposition                    * Wrap scroller!
        rts

        DATA

textposition:
        DC.W    0                               * Start at character 0.

* Nullterminated text. (0-character denotes end-of-text)
scroll_txt:                                     
        DC.B    "Hello, this is just your average lame scroller! "
        DC.B    "Most writers would have written loads of bollocks in here... "
        DC.B    "Maybe I should do the same???? "
        DC.B    "Naaahhh... Let's wrap it up.... =)              ",0
        EVEN

font_dat:
        INCBIN  FONT.DAT

	BSS

old_screenaddress:
	DS.L	1				* Here we store the old GEM screenaddress.
old_palette_table:
	DS.W	16				* Here we store the old GEM palette.
logical_screen:
	DS.L	1				* Address of logical (invisible) screen.
physical_screen:
	DS.L	1				* Address of physical (visible) screen.
screen_buffer:
	DS.B	256				* This for alignment on 256-byte boundary.
	DS.B	32000				* Memory to hold one ST-LOW screen.
	DS.B	32000				* Memory to hold one ST-LOW screen.