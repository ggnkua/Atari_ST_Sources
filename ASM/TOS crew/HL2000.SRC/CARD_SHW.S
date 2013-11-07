EXPORT scr2sb, sb2scr, card2scr

IMPORT game

include "hland.mac"

     TEXT

LIJNEN      equ 160    ; #lijnen op scherm
KAARTHOOGTE equ 40     ; hoogte van een kaart

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************     

; D0 = line offset
; A0 = source, kaart data
; A1 = destination kolom, screen pos
;
; tijd needed = 92 tikken per lijn = +/- 3600 tikken voor volle kaart 
; we hebben 13 kaarten -> 13*3600 = 47000 tikken voor kaarten set
; -> 131000 tikken voor kaarten zonder randen, gaat dus in 1 vbl
; void card2scr(int count, void* src, void* dst)
card2scr:
     move.l  d3,-(sp)              ; save d3
     move.l  d4,-(sp)              ; save d4
     tst.w   d0                    ; d0<0?
     bmi.s   .kleiner_0            ; yep
     move.w  #LIJNEN-1,d4          ; #lijnen
     sub.w   d0,d4                 ; #lijnen over
     bmi.s   .einde                ; kleiner dan 0 -> valt niet op scherm
     move.w  d0,d1                 ; #lijnen to skip
     add.w   d0,d0                 ; 2*lijnen
     add.w   d0,d0                 ; 4*lijnen
     add.w   d1,d0                 ; 5*lijnen
     lsl.w   #5,d0                 ; *32=160=lijnoffset
     add.w   d0,a1                 ; tel bij dst offset op
     bsr.s   .doe_rand             ; doe bovenste rand van kaart
     moveq   #KAARTHOOGTE-2,d0     ; lines to do
     sub.w   d0,d4                 ; lines die we gaan doen
     bgt.s   .no_problem           ; >=0, geen probleem
     add.w   d4,d0                 ; corrigeer d0
     bsr.s   .main_card            ; maak kaart
     bra.s   .einde                ; done
.no_problem:
     bsr.s   .main_card            ; maak kaart
.rand:
     bsr.s   .doe_rand             ; ook ruimte voor rand
     bra.s   .einde                ; done
.kleiner_0:
     move.w  d0,d4                 ; copie lijn aantal
     neg.w   d0                    ; #lijnen to skip
     lsl.w   #4,d0                 ; offset in card data
     add.w   d0,a0                 ; juiste offset in kaart data
     moveq   #KAARTHOOGTE-1,d0     ; #lijnen-1
     add.w   d4,d0                 ; #lijnen over -1
     bgt.s   .no_problem           ; done
     beq.s   .rand                 ; alleen rand over
.einde:
     move.l  (sp)+,d4              ; restore d4
     move.l  (sp)+,d3              ; restore d3
     rts                           ; done
.doe_rand:
     move.l  #$80008000,d2         ; alleen de bovenste bits
     move.l  (a1),d3               ; screen data
     and.l   d2,d3                 ; and mask
     or.l    (a0)+,d3              ; card data
     move.l  d3,(a1)+              ; screen
     move.l  (a1),d3               ; screen data
     and.l   d2,d3                 ; and mask
     or.l    (a0)+,d3              ; card data
     move.l  d3,(a1)+              ; screen
     rol.l   #1,d2                 ; schuif masker
     move.l  (a1),d3               ; screen data
     and.l   d2,d3                 ; and mask
     or.l    (a0)+,d3              ; card data
     move.l  d3,(a1)+              ; screen
     move.l  (a1),d3               ; screen data
     and.l   d2,d3                 ; and mask
     or.l    (a0)+,d3              ; card data
     move.l  d3,(a1)+              ; screen
     lea     160-16(a1),a1         ; corrigeer a1
     rts
.main_card:
     moveq   #KAARTHOOGTE-2,d1     ; max count
     sub.w   d0,d1                 ; 38-count
     move.l  d1,d0                 ; newcount
     add.w   d0,d0                 ; 2*count
     add.w   d1,d0                 ; 3*count
     add.w   d0,d0                 ; 6*count
     add.w   d0,d0                 ; 12*count
     jmp     .start(pc,d0.w)       ; jump into loop
.start:
     REPT 38
     movem.l (a0)+,d0-d3           ; source data 12+8*4 = 44
     movem.l d0-d3,(a1)            ; dst          8+8*4 = 40
     lea     160(a1),a1            ; dst+=160              8 = 92 tikken per lijn
     ENDM
     rts

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************     

; A0 = source, screen begin screen data
; A1 = destination, save_block
;
; we moeten 160 lijnen van 14*16 pixels lang redden
; void scr2sb(void *src, void *dst)
;
scr2sb:
     movem.l d3-d7/a2-a6,-(sp)    ; save registers
     lea     3*4*2(a0),a0         ; skip 1e 3*16 pixels
     lea     17920(a1),a1         ; einde van save block
     moveq   #(LIJNEN/2)-1,d0     ; 80*2 lijnen
.loop:
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     movem.l (a0)+,d1-d4          ; 16 bytes
     movem.l d1-d4,-(a1)          ; store
     lea     48(a0),a0            ; 1 lijn done
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     movem.l (a0)+,d1-d4          ; 16 bytes
     movem.l d1-d4,-(a1)          ; store
     lea     48(a0),a0            ; 2 lijnen done
     dbra    d0,.loop             ; next
     movem.l (sp)+,d3-d7/a2-a6    ; restore registers
     rts                          ; done

;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************     
     
; A0 = source, save_block
; A1 = destination, screen begin screen data
;
; we moeten 160 lijnen van 14*16 pixels lang terug zetten
; routine needs 1044*80 = +/- 84000 tikken
;
; void sb2scr(void *src, void *dst)
sb2scr:
     movem.l d3-d7/a2-a6,-(sp)    ; save registers
     lea     LIJNEN*160-3*2*4(a1),a1 ; ga naar einde screen block
     moveq   #(LIJNEN/2)-1,d0     ; 80*2 lijnen
.loop:
     movem.l (a0)+,d1-d4          ; 16 bytes  12+8*4  =  44
     movem.l d1-d4,-(a1)          ; store      8+8*4  =  40
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes  12+8*12 = 108
     movem.l d1-d7/a2-a6,-(a1)    ; store      8+8*12 = 104
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes  12+8*12 = 108
     movem.l d1-d7/a2-a6,-(a1)    ; store      8+8*12 = 104
     lea     -48(a1),a1           ; 1 lijn done           8
     movem.l (a0)+,d1-d4          ; 16 bytes
     movem.l d1-d4,-(a1)          ; store
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     movem.l (a0)+,d1-d7/a2-a6    ; 48 bytes
     movem.l d1-d7/a2-a6,-(a1)    ; store
     lea     -48(a1),a1           ; 2 lijnen done      1032 tikken
     dbra    d0,.loop             ; next               1044 tikken
     movem.l (sp)+,d3-d7/a2-a6    ; restore registers
     rts                          ; done
     
;d0,d1,d2,d3,d4,d5,d6,d7,a0,a1,a2,a3,a4,a5,a6,a7,sp
*******************************************************************************     


     END


