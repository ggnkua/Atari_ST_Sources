*************************************************************************
*                                                                       *
*                              DISTORTING TEXT                          *
*                       CODED BY O.T.M. OF THE D.B.A.                   *
*                                                                       *
*************************************************************************

        section text

        bsr.s   init
        bsr     main
        bsr     quit

init:
        clr.l   -(sp)           ; supervisor
        move.w  #$20,-(sp)      ; get/set/inquire supervisor
        trap    #1              ; Gemdos
        addq    #6,sp           ; correct the stack
        move.l  d0,ssp          ; save ssp
        
        move.w  #2,-(sp)        ; get the physloc
        trap    #14             ; xbios
        addq.l  #2,sp           ; correct the stack
        move.l  d0,physloc      ; save the physloc

        move.w  #3,-(sp)        ; get the logloc
        trap    #14             ; xbios
        addq    #2,sp           ; correct the stack
        move.l  d0,logloc       ; save the logloc
        
        move.w  #4,-(sp)        ; get the resolution
        trap    #14             ; xbios
        addq    #2,sp           ; correct the stack
        move.w  d0,getrez       ; save the resolution

        cmp.w   #2,d0           ; check on high rez
        bne.s   rez_is_good     ; at least the resolution is good

        pea     high_text       ; naughty boy runs my program in high rez
        move.w  #9,-(sp)        ; show shit
        trap    #1              ; Gemdos (It's slow but good)
        addq    #6,sp           ; correct the stack again
        
        move.w  #7,-(sp)        ; wait for a key
        trap    #1              ; Gemdos (what the heck)
        addq    #2,sp           ; correct the stack
        bra     exit            ; and leave quite neatly

rez_is_good:
        clr.w   -(sp)           ; enter low rez at all circumstances
        move.l  #-1,-(sp)       ; keep the physloc
        move.l  #-1,-(sp)       ; keep the logloc
        move.w  #5,-(sp)        ; set screen
        trap    #14             ; xbios 
        lea     $c(sp),sp       ; correct the stack

        lea     $ffff8240,a0    ; the old palette
        lea     colbuf,a1       ; buffer to store it in
        move.w  #15,d0          ; counter for the number of the colours
sav_col:
        move.w  (a0)+,(a1)+     ; copy from one to another
        dbf     d0,sav_col

        pea     pic+2           ; get the new palette
        move.w  #6,-(sp)        ; setpalette
        trap    #14             ; xbios
        addq.l  #6,sp           ; correct the stack
        
        dc.w    $a00a
        
        move.l  #screen1,scr1   ; get the address, and not the value	
        move.l  #screen2,scr2   ; get the address, and not the value
	move.l	scr1,d0		; get the screenaddress
	addi.l	#255,d0		; put it in a wordboundery
	and.l	#$ffffff00,d0	; now it's ready for use
	move.l	scr2,d0		; and the same for the second screen
	addi.l	#255,d0		; put it in a wordboundery
	and.l	#$ffffff00,d0	; ready.


        move.w  #7999,d0        ; counter
        move.l  logloc,a0       ; the screen
        move.l  scr1,a1 ; this will be the physloc
        move.l  scr2,a2 ; this will be the logloc
cls:
        clr.l   (a0)+           ; clear it
        clr.l   (a1)+           ; clear this one two
        clr.l   (a2)+           ; and even this one 
        dbf     d0,cls          ; do until clean

        rts

main:
        bsr.s   vsync           ; wait till vsync happens and give rast(if wanted)
        bsr.s   swapscreen      ; no flickering logo's
        bsr     clear_piece     ; and clear some bits
        bsr     distort         ; do this piece of code
        moveq   #0,d0           ; cleare this register for no false rast
        cmp.b   #$62,$fffffc02.w; see if <HELP> is pressed
        bne.s   test_space      ; not pressed
        moveq   #-1,d0          ; it's pressed so do some rasts
test_space:
        cmp.b   #$39,$fffffc02.w; test if <SPACE> is pressed
        bne.s   main            ; thank God you did not!!
        rts                     ; let's quit

vsync:
        movem.l d0-a7,-(sp)     ; save the registers

        tst.w   d0              ; test d0
        beq.s   no_rast         ; HELP isn't pressed
        move.w  #$777,$ffff8240.w;white
no_rast:
        move.w  #$25,-(sp)      ; official vsync
        trap    #14             ; xbios
        addq    #2,sp           ; correct the stack

        clr.w   $ffff8240.w     ; black

        movem.l (sp)+,d0-a7     ; give the regs back
        rts                     ; and the subroutine is done

swapscreen:
        movem.l d0-a7,-(sp)     ; save the regs
        move.l  scr1,d0         ; save the first screen
        move.l  scr2,scr1       ; swap the two screens
        move.l  d0,scr2         ; and now the first is the second

        move.w  #-1,-(sp)       ; keep low rez
        move.l  scr1,-(sp)      ; physloc
        move.l  scr2,-(sp)      ; logloc
        move.w  #5,-(sp)        ; setscreen
        trap    #14             ; xbios
        lea     $c(sp),sp       ; correct the stack

        movem.l (sp)+,d0-a7     ; give the regs back
        rts

clear_piece:
        move.w  #35,d0          ; number of lines to clear
        move.w  #19,d1          ; this is on line
        move.l  scr1,a0         ; screen in place
clear_it:
        clr.w   (a0)            ; clear it
        addq.l  #8,a0           ; next word in same plane
        dbf     d1,clear_it     ; do until line complete
        move.w  #19,d1          ; new line-counter
        dbf     d0,clear_it     ; do until complete
        rts

distort:
        lea     pic+34,a1       ; get the original logo
        move.l  scr1,a2         ; and finally the screen.
        addq.l  #8,a2           ; this one is to centre the text 
        move.w  #17,d0          ; number of letters (18)
do_distort:
        moveq   #0,d2           ; clear the register
        move.w  #16,d1          ; counter for the lines
        movea.l sinpoint,a0     ; get the data
        move.b  (a0),d2         ; get the current offset in the data
        addq.l  #1,sinpoint     ; increase it
        cmp.b   #-1,d2          ; test on overflow
        bne.s   continue        ; no overflow
        move.l  #data,sinpoint  ; on overflow restart
        add.l   #18,sinpoint    ; correct it 
        moveq   #0,d2           ; and don't bomb
continue:
        mulu.w  #160,d2         ; calculate the offset for screenuse
        adda.l  d2,a2           ; add offset to the screen
place_lettre:
        move.w  (a1),(a2)       ; copy the letter
        adda    #$a0,a1         ; next line in the same plane
        adda    #$a0,a2         ; next line in dito plane
        dbf     d1,place_lettre ; do until complete
        suba.l  #17*160-8,a1    ; go to the next letter
        suba.l  #17*160-8,a2    ; go to the next letter
        suba.l  d2,a2           ; back to the top of the screen
        dbf     d0,do_distort   ; do until all letters are done
        sub.l   #17,sinpoint    ; correct the pointer for nicer sine
        rts                     ; that should be about it so return.

quit:
        lea     colbuf,a0       ; get the old colours
        lea     $ffff8240,a1    ; get the address for the colours
        move.w  #15,d0          ; counter for the colours
old_col:
        move.w  (a0)+,(a1)+     ; copy them 
        dbf     d0,old_col      ; do until all colours are copied.

        move.w  getrez,-(sp)    ; restore the resolution
        move.l  physloc,-(sp)   ; keep physbase
        move.l  logloc,-(sp)    ; keep logloc
        move.w  #5,-(sp)        ; setscreen
        trap    #14             ; xbios
        lea     $c(sp),sp       ; correct the stack

        dc.w    $a009           ; you can use your mouse now

        move.l  ssp,-(sp)       ; old stack on stack
        move.w  #$20,-(sp)      ; set the stack back
        trap    #1              ; stack is user now
        addq    #6,sp           ; correct the "new" stack

exit:
        clr.w   -(sp)           ; stop the program
        trap    #1              ; Gemdos
        addq    #2,sp           ; this is useless

        section  data

high_text:
        dc.b    27,"E Hello, you fool, this program doesn't support mono so bugger off.",0

data:   incbin  'a:\sinus.dat'   
        dc.b    -1
        even
sinpoint:
        dc.l    data
pic:    incbin  'a:\disttest.pi1'

        section bss

ssp:    ds.l    1
physloc:ds.l    1
logloc: ds.l    1
getrez: ds.w    1
colbuf: ds.b    32
screen1:ds.b    32000           ; the two screens 
screen2:ds.b    32000
scr1:   ds.l    1               ; the addresses of the two screens
scr2:   ds.l    1

        end
