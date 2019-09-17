********************************
*     new form_do-Routine      *
*  mit erweiterten Functions   *
*        by Uwe Seimet         *
* (c) 1992 MAXON Computer GmbH *
******************************** 


*for the few System calls
GEMDOS   = 1
MSHRINK  = 74
BIOS     = 13
BCONOUT  = 3


         move.l sp,a0
         lea stack+400,sp           ;Stackpointer initialisation
         move.l 4(a0),a0            ;Pointer to the Basepage
         move.l 12(a0),a1           ;Length of the TEXT-Segments
         add.l 20(a0),a1            ;Length of the DATA-Segments
         add.l 28(a0),a1            ;Length of the BSS-Segments
         lea $100(a1),a1            ;256 Bytes for the Basepage
         move.l a1,-(sp)
         move.l a0,-(sp)
         clr -(sp)
         move #MSHRINK,-(sp)
         trap #GEMDOS               ;memory not required given back
         lea 12(sp),sp
         tst.l d0                   ;Error?
         bne error                  ;yes-
         lea intin,a5               ;Pointer to the INTIN-Array
         lea intout,a6              ;Pointer to the INTOUT-Array
         moveq #10,d0               ;appl_init
         move.l #$00010000,d1
         bsr aes
         bmi.s error                ;Error-
         moveq #77,d0               ;graf_handle
         move.l #$00050000,d1
         bsr aes
         move.l a5,a0
         moveq #9,d0
.opn:    move #1,(a0)+
         dbra d0,.opn
         move #2,(a0)
         moveq #100,d0              ;v_opnvwk
         lea contrl+2,a3
         clr.l (a3)+
         move #11,(a3)
         move (a6),6(a3)            ;graf_handle
         bsr vdiinit
         move 6(a3),vdi_h           ;remember vdi_handle 
         move #7,(a5)               ;enter Object number
fix:     moveq #114,d0              ;rsrc_obfix
         move.l #$01010100,d1
         lea objc000(pc),a0         ;Address of the Object data
         bsr aesobj                 ;Calculate co-ordinates
         subq #1,(a5)
         bpl fix                    ;next Object, if available
         clr (a5)                   ;Arrow as Mouse cursor
         moveq #78,d0               ;graf_mouse
         move.l #$01010100,d1
         bsr aes
         lea objc000(pc),a4         ;Address of the Dialogue-box
         moveq #2,d4                ;Number of the first input field
         bsr.s form_do              ;Carry out Dialogue
         moveq #19,d0               ;appl_exit
         move.l #$00010000,d1
         bsr aes
error:   clr -(sp)                  ;that was it
         trap #GEMDOS

form_do:
         moveq #54,d0               ;form_center
         move.l #$00050100,d1
         move.l a4,a0
         bsr aesobj
         movem.l 2(a6),d5/d6        ;form_xy and form_wh
         clr d2                     ;FMD_START
         movem.l d5/d6,2(a5)
         movem.l d5/d6,10(a5)
         bsr.s form_dial
         moveq #1,d0                ;draw up until 1 level
         move.l d0,(a5)
         movem.l d5/d6,4(a5)
         moveq #42,d0               ;objc_draw
         move.l #$06010100,d1
         move.l a4,a0
         bsr aesobj                 ;represent Dialogue-box 
         bsr.s _form_do             ;to the new Dialogue-routine
         moveq #3,d2                ;FMD_FINISH
         movem.l d5/d6,2(a5)
         movem.l d5/d6,10(a5)
form_dial:
         moveq #51,d0               ;form_dial
         move.l #$09010100,d1
         move d2,(a5)
         bra aes

*new form_do-Routine, Exit-Button will be supplied back in D7
_form_do:
         moveq #1,d0                ;Turn on Cursor 
         bsr objcedit
         move 2(a6),d3              ;Position of the Cursor
dloop:   move #1,2(a5)              ;wait on a Mouse click
         move #1,4(a5)              ;wait on the left Mouse button 
         move #1,6(a5)              ;pressed Mouse button
         moveq #25,d0               ;evnt_multi
         move.l #$10070100,d1
         move #3,(a5)               ;MU_KEYBD|MU_BUTTON
         lea ev_buff,a0
         bsr aesobj                 ;wait for user action
         btst #1,1(a6)              ;MU_BUTTON?
         bne.s button               ;yes-
         move 10(a6),d0             ;Scan- and ASCII-Code of the Keys
         tst.b d0                   ;ASCII-character?
         bne.s noalt                ;yes-
         lsr #8,d0                  ;Scancode in the low Byte
         move.l a4,a0
uloop:   cmp.b 6(a0),d0             ;Button found for pressed key ?
         beq.s default              ;yes-
         tst (a0)                   ;last Object in the Tree reached?
         beq.s noalt                ;yes-
         lea 24(a0),a0              ;test next Object
         bra uloop
default: sub.l a4,a0
         move.l a0,d7
         divu #24,d7                ;produces Object number
         move #1,12(a6)             ;for Simulation of a Mouse click
         bra.s obj
noalt:   move 10(a6),2(a5)          ;inputted characters
         move d4,(a5)               ;actual input field
         clr 4(a5)
         moveq #55,d0               ;form_keybd
         move.l #$03030100,d1
         move.l a4,a0
         bsr aesobj
         move 2(a6),d7              ;new input field
         tst (a6)                   ;Exit-Object operated?
         beq exit                   ;yes-
         tst 4(a6)                  ;Change of the input fields?
         beq.s newinput             ;yes-
         move 10(a6),2(a5)          ;characters given in
         move d3,4(a5)              ;actual Cursor position
         moveq #2,d0                ;Characters given out
         bsr.s objcedit
         move 2(a6),d3              ;new Cursor position
         bra dloop
button:  clr (a5)
         move #1,2(a5)              ;search up to 1 level
         move.l 2(a6),4(a5)         ;actual Mouse position
         moveq #43,d0               ;objc_find
         move.l #$04010100,d1
         move.l a4,a0
         bsr.s aesobj
         move (a6),d7               ;Object number
         bpl.s obj                  ;Object has been found-
         move #$07,-(sp)            ;BELL
         move #2,-(sp)
         move #BCONOUT,-(sp)
         trap #BIOS                 ;Bell tone as error message
         addq.l #6,sp
         bra dloop
obj:     moveq #56,d0               ;form_button
         move.l #$02020100,d1
         move d7,(a5)               ;Object clicked on
         move 12(a6),2(a5)          ;Number of Mouse clicks
         move.l a4,a0
         bsr.s aesobj
         tst (a6)                   ;was Exit-Object clicked on ?
         beq.s exit                 ;yes-
         move d7,d0
         mulu #24,d0
         btst #3,9(a4,d0)           ;Object editable?
         beq dloop                  ;no-
         cmp d7,d4                  ;Change of the input fields?
         beq dloop                  ;no-
newinput:bsr.s exit                 ;switch off Cursor
         move d7,d4                 ;new input field
         bra _form_do               ;Carry on Dialogue
exit:    move d3,4(a5)              ;Cursor position
         moveq #3,d0
objcedit:move d4,(a5)               ;Number of input fields
         move d0,6(a5)
         moveq #46,d0               ;objc_edit
         move.l #$04020100,d1
         move.l a4,a0
aesobj:  move.l a0,addrin
aes:     lea contrl,a0
         move d0,(a0)
         movep.l d1,3(a0)
         move.l #aespb,d1
         move #$c8,d0
         trap #2                    ;AES-call
         rts

vdi:     move vdi_h,contrl+12
vdiinit: move d0,contrl
         move.l #vdipb,d1
         moveq #$73,d0
         trap #2                    ;VDI-call
         rts

*Draw User defined Object 
draw:
         move.l 4(sp),a0
         move.l 10(a0),d0           ;x/y-Co-ordinates
         sub.l #$00030000,d0
         move.l d0,ptsin
         add.l #$00060000,d0
         add.l 14(a0),d0
         move.l d0,ptsin+4
         lea contrl,a0
         move.l #$02000000,d0
         movep.l d0,3(a0)
         move #8,contrl+10
         moveq #11,d0               ;v_rbox
         bsr vdi                    ;Draw rounded off Box 
         move.l 4(sp),a0
         move.l 26(a0),a1           ;Pointer to the Text string
         lea intin,a2
         clr d0
         clr d1
.loop:   move.b (a1)+,d0
         beq.s .end
         move d0,(a2)+
         addq #1,d1
         bra .loop
.end:    move.l #$01000000,d0
         lea contrl,a1
         movep.l d0,3(a1)
         move d1,contrl+6
         move.l 10(a0),ptsin
         add #17,ptsin+2
         moveq #8,d0                ;v_gtext
         bra vdi

user:    dc.l draw
         dc.l spec000

*Data for the Dialogue box
*----------------------------------------------------------------------------
* Object types used
BOX      = 20
BUTTON   = 26
STRING   = 24
FTEXT    = 29


objc000:.dc.w $ffff
        .dc.w $0001,$0007
        .dc.w BOX
        .dc.w $0000,$0010
        .dc.l $00021100
        .dc.w $0007,$0004
        .dc.w $002b,$000f

        .dc.w $0002
        .dc.w $ffff,$ffff
        .dc.w STRING
        .dc.w $0000,$0011
        .dc.l user              ;" Test dialogue for new form_do-Routine"
        .dc.w $0003,$0001
        .dc.w $0025,$0801

        .dc.w $0003
        .dc.w $ffff,$ffff
        .dc.w FTEXT
        .dc.w $0008,$0000
        .dc.l spec001           ;"Input-field 1: __________"
        .dc.w $0009,$0005
        .dc.w $0019,$0001

        .dc.w $0004
        .dc.w $ffff,$ffff
        .dc.w FTEXT
        .dc.w $0008,$0000
        .dc.l spec002           ;"Input-field 2: __________"
        .dc.w $0009,$0007
        .dc.w $0019,$0001

        .dc.w $0005
        .dc.w $ffff,$ffff
        .dc.w $781a
        .dc.w $0011,$0001
        .dc.l spec003           ;"Radiobutton 1"
        .dc.w $0007,$000a
        .dc.w $000e,$0001

        .dc.w $0006
        .dc.w $ffff,$ffff
        .dc.w $791a
        .dc.w $0011,$0000
        .dc.l spec004           ;"Radiobutton 2"
        .dc.w $0016,$000a
        .dc.w $000e,$0001

        .dc.w $0007
        .dc.w $ffff,$ffff
        .dc.w BUTTON
        .dc.w $0007,$0000
        .dc.l spec005           ;"OK"
        .dc.w $000c,$000d
        .dc.w $0009,$0001

        .dc.w $0000
        .dc.w $ffff,$ffff
        .dc.w $611a
        .dc.w $0025,$0000
        .dc.l spec006           ;"CANCEL"
        .dc.w $0016,$000d
        .dc.w $0009,$0001

spec000:.dc.b " Test dialogue for new form_do-Routine",0,0

spec001:.dc.l txt001,plt001,val001
        .dc.w $0003
        .dc.w $0006
        .dc.w $0000
        .dc.w $1180
        .dc.w $0000
        .dc.w $ffff
        .dc.w $000b,$001a
txt001: .dc.b "@         ",0
plt001: .dc.b "Input-field 1: __________",0
val001: .dc.b "XXXXXXXXXX",0

spec002:.dc.l txt002,plt002,val002
        .dc.w $0003
        .dc.w $0006
        .dc.w $0000
        .dc.w $1180
        .dc.w $0000
        .dc.w $ffff
        .dc.w $000b,$001a
txt002: .dc.b "@         ",0
plt002: .dc.b "Input-field 2: __________",0
val002: .dc.b "XXXXXXXXXX",0

spec003:.dc.b "Radiobutton 1",0

spec004:.dc.b "Radiobutton 2",0

spec005:.dc.b "OK",0

spec006:.dc.b "CANCEL",0

*****************************
* Converted through RSCCONV *
*    Author: Uwe Seimet     *
*      (C) 1989 by CCD      *
*****************************

*----------------------------------------------------------------------------


         DATA

aespb:   dc.l contrl,global,intin,intout,addrin,addrout

vdipb:   dc.l contrl,intin,ptsin,intout,ptsout


         bss

*sundry AES- and VDI-Arrays

contrl:  ds.w 11

global:  ds.w 15

intin:   ds.w 64

intout:  ds.w 64

addrin:  ds.w 64

addrout: ds.w 64

ptsin:   ds.w 64

ptsout:  ds.w 64

ev_buff: ds.w 8   ;Buffer for evnt_multi

vdi_h:   ds.w 1   ;VDI-Handle

         even

stack:   ds.l 100 ;your Stack area
