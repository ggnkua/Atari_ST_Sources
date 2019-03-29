The Big Night Out - Assembly Tutorial
Main code was written by a member of the Stampede team altered for
use (with font) by P.Bramwell
**************************************************************************

;This requires a full working version of Devpac to run

;the following code is aimed at new comers to the 68000.
;all the routines below may be freely used and we hope that
;you find the comments very useful.

;The program is a very basic scroll.


;first lets assign some variables using the EQUate function.

lowres     equ     0
medres     equ     1
hires     equ     2

;now the code begins. the entire program has been split up
;into routines which are called using BSR (branch to subroutine)
;and the routine is finished using RTS (return from subroutine)

codego     bsr     supermode     ;allow access to the hardware
     dc.w     $a00a          ;turn off mouse
;     bsr     setpalette     ;program palette set here
;     bsr     setscreen     ;set the screen mode
     bsr     getscreenbase     ;where we will place data
        bsr     message          ;show text message
     bsr     goscroller     ;activate scroller
     bsr     restorepalette     ;restore gem palette
     bsr     usermode     ;back to user mode
     clr.w     -(sp)          ;function 0-terminate program
     trap     #1          ;now go back to gem

;before any of the st's hardware registers can be used, we must
;place the 68000 into supervisor mode.
;the super mode instruction effects the status register bit #13.
;note: the trap #1 call with paramater $0020 actually toggles
;  the user mode/super mode status. so calling the routine
;  twice will restore the processor to its previous state.

supermode
     clr.l     -(sp)          ;push parameters for supermode
     move.w     #$0020,-(sp)     ;onto the stack
     trap     #1          ;call the gemdos routine
     addq.w     #6,sp          ;correct the stack
     move.l     d0,savesp     ;save the old stack value
     rts               ;exit the routine

;once the program has been executed, we place the 68000 back
;into usermode ready for the return to gem. this actually
;clears the supervisor mode bit in the status register.

usermode
     move.l     savesp,-(sp)     ;push on old stack value
     move.w     #$0020,-(sp)     ;function $0020-user mode
     trap     #1          ;put 68000 into user mode
     addq.w     #6,sp          ;correct stack after the 2 pushes
     rts

;dump the main message out onto the screen using printline

message
     pea     text
     move.w     #9,-(sp)
     trap     #1
     addq.w     #6,sp
     rts

;now the main scroller call routine. this simply calls the flyback
;routine then executes the scroll twice and checks the keyboard.
;if space is pressed then the program quits.

goscroller
     bsr     flyback          ;vertical blank
     bsr     doscroll     ;scroll the screen
     bsr     doscroll
     move.w     #$00ff,-(sp)
     move.w     #6,-(sp)
     trap     #1
     addq.w     #4,sp
     cmp.b     #" ",d0          ;space pressed ?
     bne     goscroller     ;no, loop again
     rts

;wait till the raster beam hits the vertical blanking area before
;we start the scroll. This is done through trap 14, function $25

flyback
     move.w     #$25,-(sp)
     trap     #14
     addq.w     #2,sp
     rts

;now comes the main scroll routine. this is broken down into 2 section,
;the shifter and the updater.

doscroll
     bsr     shift
     bsr     update
     rts

;now comes the main scroller routine. this uses a 68000 called roxl.
;the 'roxl' shift data in a special way. bits coming out from the left
;go into the carry and new data comes into the right hand side.
;2 address registers are used here, a0 for the screen data and a1
;is used to point to a buffer where the new scroll data is stored.
;shiftbuffer is actually a dummy area which is actually used to
;bring new data in. Note: the scroll area is 16 pixels high

shift
     move.l     screenbase,a0          ;screen start addr.
     lea     shiftbuffer,a1          ;buffer start
     moveq     #16-1,d7          ;height
scrolllp
     roxl.w     (a1)+               ;shift buffer data
     roxl.w     152(a0)               ;shift all screen data
     roxl.w     144(a0)
     roxl.w     136(a0)
     roxl.w     128(a0)
     roxl.w     120(a0)
     roxl.w     112(a0)
     roxl.w     104(a0)
     roxl.w     96(a0)
     roxl.w     88(a0)
     roxl.w     80(a0)
     roxl.w     72(a0)
     roxl.w     64(a0)
     roxl.w     56(a0)
     roxl.w     48(a0)
     roxl.w     40(a0)
     roxl.w     32(a0)
     roxl.w     24(a0)
     roxl.w     16(a0)
     roxl.w     8(a0)
     roxl.w     (a0)
     add.l     #160,a0               ;down to next line
     dbra     d7,scrolllp          ;loop for a
     rts

;once the data in the dummy buffer area has been shifted on using the
;roxl we must update the next character. each character is 16 pixels
;wide so we have a counter (charcount) which indicates which to change
;the buffer.

update
     addq.w     #1,charcount          ;adjust counter
     and.w     #$000f,charcount     ;clip value 0-15
;     cmp.w     #0,charcount          ;check for end of scroller
     bne.s     noupdate

     move.l     address,a0          ;string pointer
     moveq     #0,d0               ;clear out d0 ready for byte
     move.b     (a0)+,d0          ;string data
     bpl.s     notend               ;not end of string!
     lea     string,a0          ;reset pointer
     move.b     (a0)+,d0          ;pull first character
notend     move.l     a0,address          ;restore pointer

;     mulu.w     #32,d0
     lsl.w     #5,d0               ;offset into font
     lea     font,a0               ;start of font data
     add.w     d0,a0               ;calculate data start
     lea     shiftbuffer,a1          ;buffer start
     moveq     #16-1,d7          ;height of character
cop     move.w     (a0)+,(a1)+          ;copy data
     dbra     d7,cop               ;do all data
noupdate
     rts                    ;quit updater

;now we set the screen mode using function 5-trap 14. this also
;allows us to set where the st fetches the data for the screen.

; setscreen
;     move.w     #lowres,-(sp)     ;place mode required on stack
;     move.l     #-1,-(sp)     ;dont effect screen address
;     move.l     #-1,-(sp)     ;dont effect screen address
;     move.w     #$0005,-(sp)     ;function 5-setscreen
;     trap     #14          ;set the screen resolution
;     add.w     #12,sp
;     rts

;the following two routines simply set the st's screen
;colours using trap #14, function 6. the colours are
;actually placed into the hardware locations $ffff8240.

; setpalette
;     move.l     #mypal,-(sp)     ;address of palette in memory
;     move.w     #$0006,-(sp)     ;function 6-setpalette
;     trap     #14          ;set the palette
;     addq.w     #6,sp
;     rts

restorepalette
     move.l     #gempal,-(sp)     ;address of palette in memory
     move.w     #$0006,-(sp)     ;function 6-setpalette
     trap     #14          ;set the palette
     addq.w     #6,sp
     rts

;for us to draw anything on the screen we must first located the
;top of the screen in memory. this is done using function 2-
;trap 14. the top of the screen is returned in a long word in
;data register d0. this will vary in different machines as the
;520 st's are located at $78000 and the 1040 st's are at $f8000.

getscreenbase
     move.w     #$0002,-(sp)     ;function 2-physbase
     trap     #14          ;calculate the address
     addq.w     #2,sp          ;correct the stack
     move.l     d0,screenbase     ;save the base address for later
     rts

**************************************************************************

;reserved space for variables

shiftbuffer
     ds.w     16
savesp
     dc.l     0     ;storage for stack in memory
screenbase
     dc.l     0     ;where the top of the screen is located
charcount
     dc.w     0     ;pixel no. 0-15

mypal
     dc.w     $007,$777,$000,$777,$000,$000,$000,$000
     dc.w     $707,$770,$000,$000,$000,$000,$000,$777

gempal
     dc.w     $777,$700,$070,$000,$111,$222,$333,$444
     dc.w     $555,$000,$001,$010,$100,$200,$020,$002

font
letta     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0000000000000000

lettb     dc.w     %0111111111111100
     dc.w     %0111111111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111100
     dc.w     %0111111111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111110
     dc.w     %0111111111111100
     dc.w     %0000000000000000

lettc     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0111111111111110
     dc.w     %0011111111111100
     dc.w     %0000000000000000

lettd     dc.w     %0111111111111000
     dc.w     %0111111111111100
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111100
     dc.w     %0111111111111000
     dc.w     %0000000000000000

lette   dc.w    %0011111111111100
        dc.w    %0111111111111110
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0111111111111110
        dc.w    %0111111111111110
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0110000000000000
        dc.w    %0111111111111110
        dc.w    %0011111111111100
        dc.w    %0000000000000000

lettf   dc.w    %0011111111111100
        dc.w    %0111111111111110
        dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w      %0110000000000000
     dc.w      %0110000000000000
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0000000000000000

lettg   dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000111111100
     dc.w     %0110000111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0000000000000000

letth   dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0000000000000000

letti     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0000001111000000
     dc.w     %0111111111111110
     dc.w     %0011111111111100
     dc.w     %0000000000000000

lettj     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0000000011000000
     dc.w     %0000000011000000
     dc.w     %0000000011000000
     dc.w     %0000000011000000
     dc.w     %0000000011000000
     dc.w     %0000000011000000
     dc.w     %0000000110000000
     dc.w     %0000000110000000
     dc.w     %0000001100000000
     dc.w     %0000001100000000
     dc.w     %0000011000000000
     dc.w     %0000110000000000
     dc.w     %0001100000000000
     dc.w     %0000000000000000

lettk     dc.w     %0110000000000110
     dc.w     %0110000000011100
     dc.w     %0110000001110000
     dc.w     %0110000111000000
     dc.w     %0110011100000000
     dc.w     %0111110000000000
     dc.w     %0111100000000000
     dc.w     %0111000000000000
     dc.w     %0111000000000000
     dc.w     %0111110000000000
     dc.w     %0110011100000000
     dc.w     %0110000111000000
     dc.w     %0110000001110000
     dc.w     %0110000000011100
     dc.w     %0110000000000110
     dc.w     %0000000000000000

lettl     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0000000000000000

lettm     dc.w     %0010000000000100
     dc.w     %0110000000000110
     dc.w     %0111000000001110
     dc.w     %0111100000011110
     dc.w     %0110110000110110
     dc.w     %0110011001100110
     dc.w     %0110001111000110
     dc.w     %0110000110000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0000000000000000

lettn     dc.w     %0010000000000100
     dc.w     %0110000000000110
     dc.w     %0111000000000110
     dc.w     %0111100000000110
     dc.w     %0110110000000110
     dc.w     %0110011000000110
     dc.w     %0110001100000110
     dc.w     %0110000110000110
     dc.w     %0110000011000110
     dc.w     %0110000001100110
     dc.w     %0110000000110110
     dc.w     %0110000000011110
     dc.w     %0110000000001110
     dc.w     %0110000000000110
     dc.w     %0010000000000100
        dc.w    %0000000000000000

letto     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0111000000001110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111000000001110
     dc.w     %0111111111111110
     dc.w     %0011111111111100
     dc.w    %0000000000000000

lettp     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0111000000001110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111000000001110
     dc.w     %0111111111111110
     dc.w     %0111111111111100
     dc.w     %0110000000000000
     dc.w     %0110000000000000
        dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0000000000000000

lettq     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0111000000001110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000110110
     dc.w     %0111000000011110
     dc.w     %0111111111111110
     dc.w     %0011111111111110
     dc.w     %0000000000000000

lettr     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0111000000001110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111000000001110
     dc.w     %0111111111111110
     dc.w     %0111111111111100
     dc.w     %0111100000000000
     dc.w     %0110111000000000
        dc.w     %0110001110000000
     dc.w     %0110000011100000
     dc.w     %0110000000111000
     dc.w     %0110000000001110
     dc.w     %0110000000000110
     dc.w     %0000000000000000


letts      dc.w     %0011111111111000
     dc.w     %0111111111111100
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0110000000000000
     dc.w     %0111111111111100
     dc.w     %0011111111111110
     dc.w     %0000000000000110
     dc.w     %0000000000000110
     dc.w     %0000000000000110
     dc.w     %0000000000000110
     dc.w     %0000000000000110
     dc.w     %0111111111111110
     dc.w     %0011111111111100
     dc.w     %0000000000000000

lettt     dc.w     %0011111111111100
     dc.w     %0111111111111110
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000000000000

lettu     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0111000000001110
     dc.w     %0111111111111110
     dc.w     %0011111111111100
     dc.w     %0000000000000000

lettv     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0001100000011000
     dc.w     %0001100000011000
     dc.w     %0001100000011000
     dc.w     %0000110000110000
     dc.w     %0000110000110000
     dc.w     %0000110000110000
     dc.w     %0000011001100000
     dc.w     %0000011001100000
     dc.w     %0000001111000000
     dc.w     %0000000110000000

lettw      dc.w     %0110000000000110
     dc.w     %0110000000000110
        dc.w     %0110000000000110
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0001100110011000
     dc.w     %0001101111011000
     dc.w     %0001111001111000
     dc.w     %0000110000110000
     dc.w     %0000110000110000
     dc.w     %0000110000110000
     dc.w     %0000011001100000
     dc.w     %0000011001100000
     dc.w     %0000011001100000
     dc.w     %0000000000000000

lettx     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0001100000011000
     dc.w     %0000110000110000
     dc.w     %0000011001100000
     dc.w     %0000001111000000
     dc.w     %0000011001100000
     dc.w     %0000110000110000
     dc.w     %0001100000011000
     dc.w     %0011000000001100
     dc.w     %0011000000001100
     dc.w     %0110000000000110
     dc.w     %0110000000000110
     dc.w     %0000000000000000

letty     dc.w     %0110000000000110
     dc.w     %0011000000000110
     dc.w     %0001100000001100
     dc.w     %0000110000011000
     dc.w     %0000011000110000
     dc.w     %0000001101100000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000111000000
     dc.w     %0000000000000000

lettz     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0000000000000110
     dc.w     %0000000000001100
     dc.w     %0000000000011000
     dc.w     %0000000000110000
     dc.w     %0000000011100000
     dc.w     %0000001110000000
     dc.w     %0000011000000000
     dc.w     %0000110000000000
     dc.w     %0001100000000000
     dc.w     %0011000000000000
     dc.w     %0011000000000000
     dc.w     %0111111111111110
     dc.w     %0111111111111110
     dc.w     %0000000000000000

lettsp  dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000

lettdt     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000000000000000
     dc.w     %0000111111100000
     dc.w     %0000111111100000
     dc.w     %0000111111100000
     dc.w     %0000000000000000

address
     dc.l     string

text     dc.b     13,10,10,10
     dc.b     "",13,10,10
     dc.b     "",13,10
     dc.b     "",13,10
     dc.b     "",13,10,10

     dc.b     "",13,10
     dc.b     0

string
        dc.b    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
        dc.b    16,17,18,19,20,21,22,23,24,25,26,27,28
        dc.b     $ff
        even

; The above codes represent each letter in the font eg:
; 0 - a 1 - b  2 - c  3  - d etc. 27 - " "  28 - "."
; Got that!
