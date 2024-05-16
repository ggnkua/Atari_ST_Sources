1. Initialisierungsteil:
     charset = $70000    ;Start address of the character set
     hoehe   = 32        ;Height of the characters

create:
     moveq   #5,d0       ;We have six lines in the charset
     lea     tabelle,a0
     move.l  #charset,d2
spalte:
     move.w   #9,d1      ;and 10 columns
zeile:
     move.l  d2,(a0)+    ;we create a table with
     add.l   #$10,d2     ;pointers to the invidual characters
     dbf     d1,zeile    ;(These are 32 pixels wide = $10)
     add.l   #hoehe*160-160,d2  ;(and 32 pixels in height)
     dbf     d0,spalte

     move.w  #hoehe,zanz ;the number of lines

;After this initialisation, the interrupt routine only has to
;to be merged into the system.
     move.l  #irq,$4d2   ;Using $4d2 only in supervisor mode

;Now, the main program can do what it wants. The interrupt
;will scroll on.

2.Die Interruptroutine:

scrollbase=$f8000        ;Pointer to screen

block0=$30000            ;Pointers to buffers
block1=$32000            ;Necessary size: height*160
block2=$34000
block3=$36000
block4=$38000
block5=$3a000
block6=$3c000
block7=$3e000

puff0=$40000             ;Pointer to data-add-on buffer
puff1=$40100             ;Necessary size: height*8
puff2=$40200
puff3=$40300
puff4=$40400
puff5=$40500
puff6=$40600
puff7=$40700

irq:
     move.w  nr,d2            ;nr is a counter
     addq.w  #1,nr
     and.w   #$f,nr           ;that is used as buffer pointer
                              ;15, because of the 32 pixels width
     asl.w   #2,d2
     move.l  #irqtab,a4
     move.l  0(a4,d2.w),a2    ;one routine for each buffer
     jmp     (a2)

no109:                   ;Routine for buffer 1 and 9
     move.l #block0,a6   ;Display buffer 0
     bsr    show
     move.l #block1,a6   ;Shift buffer 1
     move.l #puff1,a5    ;Pointer to data-add-on buffer
     bra    linksw

no210:                   ;analog to no109
     move.l #block1,a6
     bsr    show
     move.l #block2,a6
     move.l #puff2,a5
     bra    linksw

no311:
     move.l #block2,a6
     bsr    show
     move.l #block3,a6
     move.l #puff3,a5
     bra    linksw

no412:
     move.l #block3,a6
     bsr    show
     move.l #block4,a6
     move.l #puff4,a5
     bra    linksw

no513:
     move.l #block4,a6
     bsr    show
     move.l #block5,a6
     move.l #puff5,a5
     bra    linksw

no614:
     move.l #block5,a6
     bsr    show
     move.l #block6,a6
     move.l #puff6,a5
     bra    linksw

no715:
     move.l #block6,a6
     bsr    show
     move.l #block7,a6
     move.l #puff7,a5
     bra    linksw

no8:
     move.w #8,teil      ;Second half of the 32 pixels
     move.l #block7,a6
     bsr    show
     bsr    addpuff      ;Prepare data-add-on buffer
     move.l #block0,a6
     move.l #puff0,a5
     bra    linksw

no0:
     move.l #block7,a6
     bsr    show
     move.l #text,a0          ;Pointer to text start
     move.l #tabelle,a1       ;Pointer to conversion table
     clr.w  teil              ;Left half of 32 pixels
nochmal:
     move.w zeiger,d0         ;Counter in the text
     move.b 0(a0,d0.w),d1     ;Next character
noeffect:
     cmp.b  #$3f,d1           ;End found
     bne    noch2
     clr.w  zeiger            ;Start from beginning again
     bra    nochmal
noch2:
     ext.w  d1                ;Else, get pointer to character
     asl.w  #2,d1
     move.l 0(a1,d1.w),zeichen1
     addq.w #1,zeiger
     move.w zeiger,d0         ;Pointer to next character
notex:
     move.b 0(a0,d0.w),d1
     cmp.b  #$3f,d1           ;End found
     bne    noch3
     move.b (a0),d1           ;Then scroll in first character
noch3:
     ext.w  d1
     asl.w  #2,d1             ;Else pointer to 2nd character
     move.l 0(a1,d1.w),zeichen2

     bsr    addpuff           ;Prepare data-add-on buffer
     move.l #block0,a6        ;Scroll block 1
     move.l #puff0,a5

linksw:
     move.w zanz,d0           ;Number of lines
     subq.w #1,d0             ;As dbf counter
zeilen:
     movem.l 8(a6),d1-d7/a0-a4     ;16 pixels to the left
     movem.l d1-d7/a0-a4,(a6)      ;scroll
     movem.l 56(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,48(a6)
     movem.l 104(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,96(a6)
     add.l  #144,a6
     move.l 8(a6),(a6)+
     move.l 8(a6),(a6)+
     move.l (a5)+,(a6)+            ;Merge data-add-on buffer
     move.l (a5)+,(a6)+
     dbf   d0,zeilen
     rts

;Display ready buffer on the screen
show:
     move.w zanz,d0
     subq.w #1,d0
     move.l #scrollbase,a5
szeilen:
     movem.l (a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,(a5)
     movem.l 48(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,48(a5)
     movem.l 96(a6),d1-d7/a0-a4
     movem.l d1-d7/a0-a4,96(a5)
     movem.l 144(a6),d4-d7
     movem.l d4-d7,144(a5)
     add.l   #160,a6
     add.l   #160,a5
     dbf     d0,szeilen
     rts

;Prepare data-add-on buffer
addpuff:
     movem.l d0-d7/a0/a1,-(sp)
     move.w  zanz,d7
     subq.w  #1,d7             ;Line number as dbf
     move.w  teil,d6
     moveq   #8,d5
     move.l  zeichen1,d4
     cmp.w   #8,d6
     bne     puffer0
     move.l  zeichen2,d5
     sub.l   d4,d5
puffer0:                      ;buffer 0 is never shifted
     move.w d7,d0
     move.l #puff0,a0
     move.l d4,a1
puff0b:                       ;only left or right half of 32
     move.l 0(a1,d6.w),(a0)+  ;pixels copied
     move.l 4(a1,d6.w),(a0)+
     add.l  #160,a1
     dbf    d0,puff0b

     move.w #$e,d2            ;7 buffers, each 2 pixels
puff1a:
     move.w d2,d0
     move.w d2,d3
     asl.w #1,d0
     move.l #puffer,a0
     move.l 0(a0,d0.w),a0     ;Buffer address to A0
     move.l d4,a1             ;Character address to A1
     move.w d7,d0             ;Line number to D0

puff1b:
     move.w 0(a1,d5.l),d1     ;Shift plane 0
     swap   d1
     move.w 0(a1,d6.w),d1
     rol.l  d3,d1
     move.w d1,(a0)+

     move.w 2(a1,d5.l),d1     ;Shift plane 1
     swap   d1
     move.w 2(a1,d6.w),d1
     rol.l  d3,d1
     move.w d1,(a0)+

     move.w 4(a1,d5.l),d1     ;Shift plane 2
     swap   d1
     move.w 4(a1,d6.w),d1
     rol.l  d3,d1
     move.w d1,(a0)+

     move.w 6(a1,d5.l),d1     ;Shift plane 3
     swap   d1
     move.w 6(a1,d6.w),d1
     rol.l  d3,d1
     move.w d1,(a0)+

     add.l  #160,a1
     dbf    d0,puff1b         ;All lines

     subq.w #2,d2
     bne    puff1a            ;All 7 buffers

     movem.l (sp)+,d0-d7/a0/a1
     rts

;The following variables are needed
nr: dc.w 0
zanz: dc.l 0
teil: dc.l 0
zeiger:dc.w 0
zeichen1:dc.l 0
zeichen2:dc.l 0
tabelle: blk.l 64,0      ;Space for 64 pointers to the characters

puffer: dc.l puff0,puff1,puff2,puff3,puff4,puff5,puff6,puff7
     
irqtab: dc.l no0,no109,no210,no311,no412,no513,no614,no715
        dc.l no8,no109,no210,no311,no412,no513,no614,no715

text: dc.b 0,1,2,3,4,5,6,7,8,9,10,$3f
even

