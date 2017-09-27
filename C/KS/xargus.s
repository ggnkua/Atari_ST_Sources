;-------------------------------------------------------------------------
;
;  XARGUS : Hooks itself into XBIOS trap vector, and checks for calls
;  to the Floprd function. It displays its parameters in the upper right
;  screen corner.
;  Find out for yourself about possible applications ...
;
;  N.B. Like all software, this program is free. Copy it as you like.
;       Modify it (I will do, too). Enhance it. Add bells & whistles.
;
;       I'm not asking you here to send me money. Instead, if you've
;       done a nice enhancement (or got a nice piece of software
;       working 'better' with ARGUS's help), give them to the person
;       you got ARGUS from.
;       Sooner or later, this will reach me, too, and even have some
;       people benefit of the system during the transit.
;
;       Happy hacking, greetings to Arthur Dent,
;
;                            --- KS ---
;
;------------------------------------------------------------------------

start: jmp entry

xid:     dc.l $405678

;---------------------------------------
;       define some constants
;---------------------------------------
vduhireg   = $ff8201
vdumidreg  = $ff8203

homeline   = 1
homecol    = 50

uparrow    = 1
rightarrow = 3
clock      = 9


;---------------------------------------
;    define memory storage locations
;---------------------------------------
oldtrap14:  dc.l 0 ; init stores former trap 14 vector here
oldrts:     dc.l 0 ; indirect return vector stored here
vduaddress: dc.l $f8000 ; holds video address
fontbase:   dc.l 0 ; init stores font character data address here

device:     dc.w 0 ; drive 0->A,1->B ...
side:       dc.w 0 ; disk side
track:      dc.w 0
sector:     dc.w 0
bufad:      dc.l 0 ; adress of buffer where to store sectors
count:      dc.w 0 ; number of sectors to read

colpos:    dc.l 0 ; cursor column
linpos:    dc.l 0 ; cursor line

           even

;-----------------------------------
;    define utility routines
;-----------------------------------

calcvdu: ;
         ; compute video memory start adress,return in d0
         ; and store in vduaddress
         move.l #clcvdu1,-(sp)
         move.w #38,-(sp)
         trap #14
         addq.l #6,sp
         rts
clcvdu1: clr.l d0
         move.b vduhireg,d0
         asl.w #8,d0
         move.b vdumidreg,d0
         asl.l #8,d0
         move.l d0,vduaddress
         rts

calchar: ; compute 8x8 system font base address & store
         dc.w $a000 ; line A call (get params,a1 points to fonts)
         move.l  4(a1),a0 ; 8x8 font's adress is second in table
         move.l 76(a0),a0 ; at offset 76 is the pointer to font data
         move.l a0,fontbase ; store
         rts

writec:  ; output character in d0 (ascii) to screen.
         ; suppose vdu start and font start are setup OK
         movem.l d0/a0/a1,-(sp) ; those will be modified
         and.l #$ff,d0 ; mask off upper bits
         move.l fontbase,a0
         add.l d0,a0   ; a0 points to character bits
         move.l linpos,d0
         mulu  #640,d0
         add.l colpos,d0
         add.l vduaddress,d0
         move.l d0,a1  ; a1 points into video ram
         move.b     (a0), 80(a1)
         move.b $100(a0),160(a1)
         move.b $200(a0),240(a1)
         move.b $300(a0),320(a1)
         move.b $400(a0),400(a1)
         move.b $500(a0),480(a1)
         move.b $600(a0),560(a1)
         move.b $700(a0),640(a1)
         move.b       #0,720(a1) ; empty scanline below for better readout
         addq.l #1,colpos
         cmp.l #80,colpos
         bne writec1
         clr.l colpos
         addq.l #1,linpos
         cmp.l #25,linpos
         bne writec1
         clr.l linpos
writec1: movem.l (sp)+,d0/a0/a1
         rts

writes:  ; write (null terminated) string pointed at by a0
         movem.l d0/a0,-(sp)
         move.b (a0)+,d0
         beq qwrites
         jsr writec
qwrites: movem (sp)+,d0/a0
         rts

hextab:  dc.b '0123456789ABCDEF' ; quick&dirty

writen:  ; write nibble in lower 4 bits of d0
         movem.l d0/a0,-(sp)
         and.l  #$0f,d0
         move.l #hextab,a0
         add.l d0,a0
         move.b (a0),d0
         jsr writec
         movem.l (sp)+,d0/a0
         rts

writeb:  ; write lower d0 byte
         ror.b #4,d0
         jsr writen
         ror.b #4,d0
         jsr writen
         rts

writew:  ; write lower word in d0
         ror.w #8,d0
         jsr writeb
         ror.w #8,d0
         jsr writeb
         rts

writel:  ; write d0 as longword
         swap d0
         jsr writew
         swap d0
         jsr writew
         rts

entry:   move.l #init,-(sp)
         move.w #38,-(sp)  ; have to call init with supervisor mode.
         trap #14
         addq.l #6,sp
         move.w #0,-(sp)
         move.l #500+last-start,-(sp) ; nonorthodox, but should work here
         move.w #$31,-(sp) ; terminate & stay resident
         trap #1

init:    jsr calcvdu
         jsr calchar
         move.l #$b8,a0
         move.l (a0),oldtrap14
         move.l #mytrap14,(a0)
         rts

mytrap14:  move.l a7,a1
           btst #13,(sp) ; called from user mode ?
           bne supermode
           move.l usp,a1 ; yes, get params from user stack !
           subq.l #6,a1  ; adjust pointer for following offsets to be OK

supermode: cmp.w #8,6(a1)
           beq myfloprd
           move.l oldtrap14,a0
           jmp (a0)

myfloprd:  move.w 24(a1),count
           move.w 22(a1),side
           move.w 20(a1),track
           move.w 18(a1),sector
           move.w 16(a1),device
           move.w  8(a1),bufad

           move.l  2(sp),oldrts ; get caller's address
           move.l #myrts,2(sp) ; we have to do this trick to
                               ; get the error# returned in d0 !
           movem.l d0-d7/a0-a6,-(sp) ; safety first
           move.l #homeline,linpos
           move.l #homecol ,colpos
           move.b #'$',d0
           jsr writec
           move.l oldrts,d0
           jsr writel
           move.b #$20,d0
           jsr writec
           move.b #'A',d0
           add.w  device,d0
           jsr writec
           move.b #':',d0
           jsr writec
           move.b #uparrow,d0
           add.w  side,d0
           jsr writec
           move.b #'T',d0
           jsr writec
           move.w track,d0
           jsr writeb
           move.b #',',d0
           jsr writec
           move.b #'S',d0
           jsr writec
           move.w sector,d0
           jsr writeb
           move.b #$20,d0
           jsr writec
           move.b #'#',d0
           jsr writec
           move.w count,d0
           jsr writew
           move.b #rightarrow,d0
           jsr writec
           move.b #clock,d0
           jsr writec
           move.b #$20,d0
           jsr writec
           subq.l #2,colpos

           movem.l (sp)+,d0-d7/a0-a6
           move.l oldtrap14,a0
           jmp (a0)

myrts:     movem.l d0-d7/a0-a6,-(sp)
           jsr writeb
           movem.l (sp)+,d0-d7/a0-a6
           move.l oldrts,a0
           jmp (a0)
last:
           end

