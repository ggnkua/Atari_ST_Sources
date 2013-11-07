;
; Heartland screen routines
; To go a bit faster and get more registers we will fall back to
; user mode so we can use a7
;

MAPLEN equ 540

EXPORT trap3_handler, draw_main_sprite, update_screen
EXPORT init_blocks, game_map2

IMPORT blocks, font, duo_block_table, ani_table, ani_duo_blocks
IMPORT game, game_map, mask_same, masks_0, masks_1, masks_2, masks_3

include "hland.mac"

TEXT

;*********************************************************************

;
; register gebruik
; D0 = deel factor
; D1 = score
; D2 = werk
;
; A0 = game struct pointer
; A1 = font pointer, later w_screen pointer
; A2 = lsd pointer
; A3 = lmsd pointer
; A4 = hmsd pointer
; A5 = msd pointer
; A6 = screen pointer

draw_score:
     lea       game,a0           ; game pointer
     lea       font,a1           ; font pointer
     moveq     #0,d1             ; clear d1
     moveq     #10,d0            ; deler
;     move.w    x_pos(a0),d1      ; x-coordinate
     move.w    score(a0),d1      ; score
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a2     ; lsd
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a3     ; lmsd
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a4     ; mhsd
     divu      d0,d1             ; score/10
     swap      d1                ; rest
     lsl.w     #3,d1             ; maal 8
     lea       0(a1,d1.w),a5     ; msd
     move.l    w_screen(a0),a1   ; w_screen
     lea       30414(a1),a6      ; positie van score
     move.b    (a5)+,(a6)+       ; regel 1
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 2
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 3
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 4
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 5
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 6
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150(a6),a6        ; next line
     move.b    (a5)+,(a6)+       ; regel 7
     move.b    (a4)+,(a6)+       ;
     addq.w    #6,a6             ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
; nu nog de balk tekenen
     lea       30926(a1),a1      ; balk pointer
     lea       160(a1),a2        ; balk2 pointer
     moveq     #0,d0             ; clear d0
     move.w    life(a0),d0       ; life
     moveq     #14,d1            ; dead
     move.l    d0,a3             ; copietje
     lsr.w     #4,d0             ; life/16
     sub.w     d0,d1             ; dead=14-life
     moveq     #-1,d2            ; data
     bra.s     .life_test        ; start loop
.draw_life:
     move.w    d2,(a1)+          ; teken life
     move.w    d2,(a2)+          ; teken life
     addq.w    #6,a1             ; skip other planes
     addq.w    #6,a2             ; skip other planes
.life_test:
     dbra      d0,.draw_life     ; next life
     move.l    a3,d0             ;
     clr.w     d2                ; clear 16 bits
     and.w     #$f,d0            ; laagste 16 bits
     lsr.l     d0,d2             ; low life part
     move.w    d2,(a1)+          ; teken life
     move.w    d2,(a2)+          ; teken life
     addq.w    #6,a1             ; skip other planes
     addq.w    #6,a2             ; skip other planes
     moveq     #0,d2             ; new data
     bra.s     .dead_test        ; start loop
.draw_dead:
     move.w    d2,(a1)+          ; teken dead
     move.w    d2,(a2)+          ; teken dead
     addq.w    #6,a1             ; skip other planes
     addq.w    #6,a2             ; skip other planes
.dead_test:
     dbra      d1,.draw_dead     ; next dead



if 0
;code voor y-coordinaat afbeelden
     lea       game,a0           ; game pointer
     lea       font,a1           ; font pointer
     lea       384(a1),a1        ; begin cijfers
     moveq     #0,d1             ; clear d1
     moveq     #10,d0            ; deler
     move.w    y_pos(a0),d1      ; x-coordinate
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a2     ; lsd
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a3     ; lmsd
     divu      d0,d1             ; score/10
     move.l    d1,d2             ;
     moveq     #0,d1             ; clear d1
     move.w    d2,d1             ; volgende score
     swap      d2                ; rest
     lsl.w     #3,d2             ; maal 8
     lea       0(a1,d2.w),a4     ; mhsd
     divu      d0,d1             ; score/10
     swap      d1                ; rest
     lsl.w     #3,d1             ; maal 8
     lea       0(a1,d1.w),a5     ; msd
     move.l    w_screen(a0),a1   ; w_screen
     lea       30414+8*3-6(a1),a6 ; positie van score
     moveq     #0,d0
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 1
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6      ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 2
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6      ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 3
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6        ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 4
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6        ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 5
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6        ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 6
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     lea       150-6(a6),a6        ; next line
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a5)+,(a6)+       ; regel 7
     move.b    (a4)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
     move.b    (a3)+,(a6)+       ;
     move.b    (a2)+,(a6)+       ;
     move.l    d0,(a6)+
     move.w    d0,(a6)+          ; skip bitplanes
endif
     bra       draw_main_jumpin  ; nu nog de sprite tekenen

;*********************************************************************
;
;*********************************************************************
;
; blok routines
;
; 20 blokken naar het beeldscherm, 7, 7 en 6 tegelijk
;

;void update_screen(void);
; er is een aparte routine voor x-offset 0; die heeft geen
; gepreshifte blokken nodig
;    offset=0: 16 lines
;    offset=1: 12 lines
;    offset=2:  8 lines
;    offset=3:  4 lines
;
; Register gebruik
; D0: block lookup, bovenste 3 bytes zijn schoon
; D1: blok 1 buffer, A1 swap store
; D2: blok 2 buffer, A2 swap store
; D3: vrij
; D4: mask register
; D5: duoblok tabel copy (A3)
; D6: duoblok mask = 0x7fff80
; D7: duoblok data copy (A7)
; A0: screen
; A1: map
; A2: map2
; A3: duoblok tabel, -128:ani_ptr
; A4:
; A5:
; A6:
; A7: duoblok data, en bw store
;

duo_block_ptr:
     dc.l duo_block1-128, duo_block2-128, duo_block3-128

update_screen:
     movem.l   d3-d7/a2-a6,-(sp); save registers
     move.l    sp,stack         ; save stack
     lea       game,a6          ; game struct
;init registers
     moveq     #0,d0            ;
     move.l    w_screen(a6),a0  ; screen
     moveq     #0,d1            ;
     lea       14*160(a0),a0    ; eerste lijn met blokken
     moveq     #0,d3            ;
     move.w    y_pos(a6),d3     ; y_pos
     lea       game_map,a1      ; game map
     move.w    x_pos(a6),d1     ; x_pos
     mulu      #MAPLEN,d3       ; y_pos*map_len
     add.l     d1,d3            ; y_pos*map_len+x_pos
     add.l     d3,a1            ; eerste positie in game map
     and       #$fff,sr         ; go user!
     move.l    sp,save_usp      ;
     move.w    x_offs(a6),d0    ; x_offset
     beq       no_duoblocks     ; aparte code voor x_offs = 0
; duoclock code
     add.w     d0,d0            ; *2
     lea       duo_block_table,a3;
     move.l    a3,d5            ; copy
     lea       game_map2,a2     ; map 2
     add.l     d3,a2            ; positie op map
     and.w     #1,d3            ; oneven positie?
     beq.s     .pos_even        ; nope
     exg       a1,a2            ; verwissel a1 en a2
.pos_even:
     addq.l    #1,a2            ; fix oneven register
     add.w     d0,d0            ; *4
     move.l    duo_block_ptr-4(pc,d0.w),d7 ; adres blok data
     move.w    #10,linecount    ; te tekenen lijnen met blokken
     move.l    d7,a7            ; duoblocks
     moveq     #0,d0            ; clear d0
     move.l    #$7fff80,d6      ; mask
     move.w    y_offs(a6),d0    ; y-offset
     add.w     d0,d0            ;
     add.w     d0,d0            ; x4
     move.l    start_table(pc,d0.w),a5; return adres
     move.w    ani_count(a6),d0 ; anicount
     add.w     d0,d0            ;
     add.w     d0,d0            ; x4
     bra       ani_duo_blocks   ;

start_table:
dc.l start0, start1, start2, start3

;*********************************************************************
; teken 20 blokken op een lijn

start3:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a6   ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a5   ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a4   ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       96(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       96(a2),a2        ;
     lea       96(a7,d3.l),a3   ; duoblok data
     lea       96(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 12
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 13-15
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a6   ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a5   ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a4   ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       96(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       96(a2),a2        ;
     lea       96(a7,d3.l),a3   ; duoblok data
     lea       96(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 12
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 13-15
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a6   ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a5   ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d4.l),a4   ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       96(a7,d1.l),a2   ; duoblok data
     lea       96(a7,d3.l),a3   ; duoblok data
     lea       96(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 12
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 13-15
REPT 3
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     lea       MAPLEN-20+6(a2),a2 ; next line on map
     subq.w    #1,linecount     ; next line?
     bra       start0           ; always!

;*********************************************************************
; teken 20 blokken op een lijn
start2:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a6   ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a5   ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a4   ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       64(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       64(a2),a2        ;
     lea       64(a7,d3.l),a3   ; duoblok data
     lea       64(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 8
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 9-15
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a6   ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a5   ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a4   ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       64(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       64(a2),a2        ;
     lea       64(a7,d3.l),a3   ; duoblok data
     lea       64(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 8
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 9-15
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a6   ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a5   ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d4.l),a4   ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       64(a7,d1.l),a2   ; duoblok data
     lea       64(a7,d3.l),a3   ; duoblok data
     lea       64(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 8
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 9-15
REPT 7
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     lea       MAPLEN-20+6(a2),a2 ; next line on map
     subq.w    #1,linecount     ; next line?
     bra       start0           ; always!

;*********************************************************************
; teken 20 blokken op een lijn

start1:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a6   ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a5   ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a4   ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       32(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       32(a2),a2        ;
     lea       32(a7,d3.l),a3   ; duoblok data
     lea       32(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 4
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 5-15
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a6   ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a5   ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a4   ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     lea       32(a1),a1        ;
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       32(a2),a2        ;
     lea       32(a7,d3.l),a3   ; duoblok data
     lea       32(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 4
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 5-15
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a6   ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a5   ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d4.l),a4   ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       32(a7,d1.l),a2   ; duoblok data
     lea       32(a7,d3.l),a3   ; duoblok data
     lea       32(a7,d4.l),a7   ; duoblok data
; teken de blokken
; lijn 5
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 5-15
REPT 11
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     lea       MAPLEN-20+6(a2),a2 ; next line on map
     subq.w    #1,linecount     ; next line?
     bra       start0           ; always!

;*********************************************************************
; teken 20 blokken op een lijn

start0:
.block_loop:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-15
REPT 15
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -15*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-15
REPT 15
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -15*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d1.l),a2    ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-15
REPT 15
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     lea       MAPLEN-20+6(a2),a2 ; next line on map
     subq.w    #1,linecount     ; next line?
     bne       .block_loop
     move.w    game+y_offs,d0   ; y-offset
     beq       einde            ; y_offs == 0
     cmp.w     #2,d0            ; d0==2?
     beq       einde2           ; d0==2
     bcs       einde1           ; d0==1
                                ; d0==3

;*********************************************************************
; teken 20 blokken op een lijn
; einde3, 12 lijnen

einde3:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-11
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-11
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     and.l     0(a3,d0.w),d6    ; adres in doublok data
     lea       0(a7,d1.l),a2    ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d6,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-11
REPT 11
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     bra       einde            ; done

;*********************************************************************
; teken 20 blokken op een lijn
; einde2, 8 lijnen

einde2:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-8
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-7
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     and.l     0(a3,d0.w),d6    ; adres in doublok data
     lea       0(a7,d1.l),a2    ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d6,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-7
REPT 7
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     bra       einde            ; done

;*********************************************************************
; teken 20 blokken op een lijn
;    init blok 0
; einde1, 4 lijnen
einde1:
; blok 1
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 2
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 3
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 4
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 5
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 6
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 7
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-3
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 8
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 9
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 10
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 11
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 12
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d2            ; mask
     and.l     0(a3,d0.w),d2    ; adres in doublok data
; blok 13
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 14
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     add.l     a7,d1            ;
     exg       d1,a1            ; duoblok data
     add.l     a7,d2            ;
     exg       d2,a2            ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d4,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-3
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a1)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d2,a2            ;
     move.l    d5,a3            ;
     move.l    d7,a7            ;
; blok 15
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a6    ; duoblok data
; blok 16
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a5    ; duoblok data
; blok 17
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d4            ; mask
     and.l     0(a3,d0.w),d4    ; adres in doublok data
     lea       0(a7,d4.l),a4    ; duoblok data
; blok 18
     move.w    (a2)+,d0         ; map2 data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d3            ; mask
     and.l     0(a3,d0.w),d3    ; adres in doublok data
; blok 19
     move.w    (a1)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     move.l    d6,d1            ; mask
     and.l     0(a3,d0.w),d1    ; adres in doublok data
; blok 20
     move.w    (a2)+,d0         ; map data
     add.b     d0,d0            ; offset in duoblok tabel
     and.l     0(a3,d0.w),d6    ; adres in doublok data
     lea       0(a7,d1.l),a2    ; duoblok data
     lea       0(a7,d3.l),a3    ; duoblok data
     add.l     d6,a7            ; duoblok data
; teken de blokken
; lijn 0
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-3
REPT 3
     lea       160-48(a0),a0    ; next line
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a6)+,(a0)+      ; blok 1
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a5)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a3)+,(a0)+      ; blok 4
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a2)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     bra       einde            ; done

;*********************************************************************

no_duoblocks:     ; aparte code voor x_offs = 0
; Register gebruik
; D0: block lookup
; D1: blok 1 buffer, A1 swap store
; D2: blok 2 buffer
; D3: blok 3 buffer
; D4: blok 4 buffer
; D5: ani_ptr copy (A2)
; D6: block_line counter
; D7: block data copy (A7)
; A0: screen
; A1: map
; A2: ani_ptr
; A3:
; A4:
; A5:
; A6:
; A7: block data
     lea       ani_table,a2     ; ani table
     move.l    #blocks,d7       ; adres blockdata
     move.l    a2,d5            ; store a2
     moveq     #9,d6            ; teken 10 lijnen met blokken
     move.l    d7,a7            ; block pointer
     move.w    y_offs(a6),d0    ; y-offset
     beq       start00          ; y_offs == 0
     cmp.w     #2,d0            ; d0==2?
     beq       start02          ; d0==2
     bcs       start01          ; d0==1
                                ; d0==3

;*********************************************************************

start03:
; teken 20 blokken op een lijn
; 4 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a3   ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a4   ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a5   ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a6   ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #96,d1           ; skip 12 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       96(a7,d2.w),a2   ; blok data
     lea       96(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 12
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 13-15
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a3   ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a4   ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a5   ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a6   ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #96,d1           ; skip 12 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       96(a7,d2.w),a2   ; blok data
     lea       96(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 12
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 13-15
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a3   ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a4   ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a5   ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d0.w),a6   ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       96(a7,d2.w),a2   ; blok data
     lea       96(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 12
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 13-15
REPT 3
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d5,a2            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     dbra      d6,start00       ; volgende reeks blokken

;*********************************************************************

start02:
; teken 20 blokken op een lijn
; 8 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a3   ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a4   ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a5   ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a6   ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #64,d1           ; skip 4 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       64(a7,d2.w),a2   ; blok data
     lea       64(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 8
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 9-15
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a3   ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a4   ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a5   ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a6   ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #64,d1           ; skip 4 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       64(a7,d2.w),a2   ; blok data
     lea       64(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 4
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 9-15
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a3   ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a4   ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a5   ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d0.w),a6   ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       64(a7,d2.w),a2   ; blok data
     lea       64(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 8
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 9-15
REPT 7
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d5,a2            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     dbra      d6,start00       ; volgende reeks blokken

;*********************************************************************

start01:
; teken 20 blokken op een lijn
; 12 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a3   ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a4   ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a5   ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a6   ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #32,d1           ; skip 4 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       32(a7,d2.w),a2   ; blok data
     lea       32(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 5-15
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a3   ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a4   ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a5   ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a6   ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.w     #32,d1           ; skip 4 lines
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       32(a7,d2.w),a2   ; blok data
     lea       32(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 4
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 5-15
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a3   ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a4   ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a5   ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d0.w),a6   ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       32(a7,d2.w),a2   ; blok data
     lea       32(a7,d0.w),a7   ; blok data
; teken de blokken
; lijn 4
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 5-15
REPT 11
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d5,a2            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     subq.w    #1,d6

;*********************************************************************

start00:
.block_loop:
; teken 20 blokken op een lijn
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-15
REPT 15
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -15*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-15
REPT 15
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -15*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-15
REPT 15
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
; restore registers
     move.l    d5,a2            ;
     move.l    d7,a7            ;
     lea       MAPLEN-20(a1),a1 ; next line on map
     dbra      d6,.block_loop   ; volgende reeks blokken
     move.w    game+y_offs,d0   ; y-offset
     beq       einde            ; y_offs == 0
     cmp.w     #2,d0            ; d0==2?
     beq       eind02           ; d0==2
     bcs       eind01           ; d0==1
                                ; d0==3

;*********************************************************************

eind03:
; teken 20 blokken op een lijn
; 12 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-11
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0   ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-11
REPT 11
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -11*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d2.w),a2     ; blok data
     lea       0(a7,d0.w),a7     ; blok data
; teken de blokken
; lijn 0
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-11
REPT 11
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
     bra       einde           ; end

;*********************************************************************

eind02:
; teken 20 blokken op een lijn
; 8 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-7
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-7
REPT 7
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -7*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 8
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-7
REPT 7
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM
     bra       einde            ; end

;*********************************************************************

eind01:
; teken 20 blokken op een lijn
; 4 lijnen per blok
; blok 1
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 2
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 3
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 4
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 5
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 6
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 7
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 0
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-3
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 8
     moveq     #0,d1            ;
     move.b    (a1)+,d1         ; map data
     move.b    0(a2,d1.w),d1    ; animated sprite
     lsl.w     #7,d1            ; offset in blok tabel
; blok 9
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 10
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 11
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 12
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 13
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 14
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     add.l     a7,d1            ;
     exg       d1,a1            ; blok data
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 4
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
; lijn 1-3
REPT 3
     lea       160-56(a0),a0    ; next line
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a1)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a2)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a3)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a4)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a5)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a6)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 7
     move.l    (a7)+,(a0)+      ; blok 7
ENDM
     lea       -3*160(a0),a0    ; next
; restore registers
     move.l    d1,a1            ;
     move.l    d5,a2            ;
     move.l    d7,a7            ;
; blok 15
     moveq     #0,d2            ;
     move.b    (a1)+,d2         ; map data
     move.b    0(a2,d2.w),d2    ; animated sprite
     lsl.w     #7,d2            ; offset in blok tabel
; blok 16
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a3    ; blokdata
; blok 17
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a4    ; blokdata
; blok 18
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a5    ; blokdata
; blok 19
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d0.w),a6    ; blokdata
; blok 20
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a2,d0.w),d0    ; animated sprite
     lsl.w     #7,d0            ; offset in blok tabel
     lea       0(a7,d2.w),a2    ; blok data
     lea       0(a7,d0.w),a7    ; blok data
; teken de blokken
; lijn 4
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
; lijn 1-3
REPT 3
     lea       160-48(a0),a0    ; next line
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a2)+,(a0)+      ; blok 1
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a3)+,(a0)+      ; blok 2
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a4)+,(a0)+      ; blok 3
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a5)+,(a0)+      ; blok 4
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a6)+,(a0)+      ; blok 5
     move.l    (a7)+,(a0)+      ; blok 6
     move.l    (a7)+,(a0)+      ; blok 6
ENDM

;*********************************************************************

einde:
     bra       draw_score       ; ga score tekenen

;*********************************************************************
;*********************************************************************

; void init_blocks(void)
; register gebruik
; D0: msblock
; D1: lsblock
; D2: indei, msb
; D3: werk indei
; D4: shift buffer
; D7: duoblok mask = 0i7fff80

; A0: duo_block_table
; A1: duo_block1
; A2: duo_block2
; A3: duo_block3
; A4: blocks
; A5: msb pointer
; A6: lsb pointer

init_blocks:
     movem.l   d3-d7/a2-a6,-(sp); save registers
     lea       duo_block_table,a0; duo block table
     lea       duo_block1-128,a1; duo block1
     lea       duo_block2-128,a2; duo block1
     lea       duo_block3-128,a3; duo block1
     lea       blocks,a4        ; blocks
     move.l    #$7fff80,d7      ; block mask
     moveq     #127,d0          ; 128 blokken
.msb_loop:
     moveq     #127,d1          ; 128 blokken
     move.l    d0,d2            ; msb
     lsl.w     #7,d2            ; shift
.lsb_loop:
     move.l    d2,d3            ; msb
     add.w     d1,d3            ; msb+lsb
     add.w     d3,d3            ; offset
     move.l    0(a0,d3.w),d3    ; table entry
     and.l     d7,d3            ; any data?
     beq       .no_data         ; nope
     lea       0(a4,d2.w),a5    ; msb ptr
     move.w    d1,d4            ; lsb
     lsl.w     #7,d4            ; indei
     lea       0(a4,d4.w),a6    ; msb ptr
i=0
REPT 64
     move.w    (a6)+,d4         ; lsb
     swap      d4               ;
     move.w    (a5)+,d4         ; msb
     rol.l     #4,d4            ; shift
     move.w    d4,i*2(a1,d3.l)  ; store data
     rol.l     #4,d4            ; shift
     move.w    d4,i*2(a2,d3.l)  ; store data
     rol.l     #4,d4            ; shift
     move.w    d4,i*2(a3,d3.l)  ; store data
     i=i+1
ENDM
.no_data:
     dbra      d1,.lsb_loop     ; next
     dbra      d0,.msb_loop     ; next
     movem.l   (sp)+,d3-d7/a2-a6; restore registers
     rts


;*********************************************************************

BSS

duo_block1:                     ; duo block data, array begint bij 1
     ds.b 128*1173
duo_block2:
     ds.b 128*1173
duo_block3:
     ds.b 128*1173

;*********************************************************************
;
;*********************************************************************
;
; werking van de sprite routine:
;
; i_sprite_data --------------|   |
;                             | & |
; sprite_mask   ----|   |-----|   |---------|   |
;                   | & |                   | ^ |------ Scherm
; i_block_mask  ----|   |-----|   |---------|   |
;                             | | |
; scherm data   --------------|   |
;
;void draw_main_sprite(void)
;
; Register gebruik
; D0: block lookup
; A0: screen
; A1: map
; A2: egg_data
; A3: mask_data
; A4: mask_same
; A5: ani_ptr/ block c.h
; A6: block b
; A7: block a.l

TEXT

mask_ptrs:
dc.l masks_0, masks_1, masks_2, masks_3

draw_main_sprite:
     movem.l   d3-d7/a2-a6,-(sp); save registers
     move.l    sp,stack         ; save stack
     and       #$fff,sr         ; go user!
     move.l    sp,save_usp
draw_main_jumpin:
;init registers
     lea       game,a6          ; game struct
     move.w    #1,vbl_count(a6) ; game.vbl_count=1 floating vbl
     move.l    w_screen(a6),a0  ; scherm adres
     lea       (13+6*16)*160+72(a0),a0; linker benedenhoek sprite
     lea       game_map,a1      ; map...
     moveq     #6,d0            ;
     moveq     #9,d1            ;
     add.w     y_pos(a6),d0     ; game.y_pos
     add.w     x_pos(a6),d1     ; game.x_pos
     mulu      #MAPLEN,d0       ; y_pos*maplen
     add.l     d1,d0            ; offset
     add.l     d0,a1            ; map linker benedenhoek sprite
     move.l    egg_ptr(a6),a2   ; egg pointer
     move.w    x_offs(a6),d0    ; x_offset
     add.w     d0,d0            ; i2
     add.w     d0,d0            ; i4
     move.l    mask_ptrs(pc,d0.w),a3
     lea       ani_table,a5     ; animaties
     lea       mask_same,a4     ; mask same pointer
; fix punt ani binnen mask_same
     moveq     #$1e,d0          ; punt
     moveq     #0,d1            ;
     move.b    0(a5,d0.w),d1    ; punt ani
     move.b    0(a4,d1.w),0(a4,d0.w); punt ani gefixed in mask same, a5 is vrij!
;jump naar juiste teken routine
     move.w    y_offs(a6),d0    ; y_offset
     beq       y_offs_0         ; y_offset=0
     cmp.w     #2,d0            ;
     beq       y_offs_2         ; y_offset=2
     bcs       y_offs_1         ; y_offset=1

;*********************************************************************

y_offs_3:
; nulde set blokken
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       18(a3,d0.w),a7   ; block a.l, skip 4 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       16(a3,d0.w),a6   ; block b, skip 4 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       16(a3,d0.w),a5   ; block c, skip 4 lijnen
; nu de lijnen
; lijn 0
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 1-11
i=1
REPT 11
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     lea       -160(a0),a0      ; shift screen pos
; eerste set blokken
     moveq     #0,d0            ;
     lea       -MAPLEN-3(a1),a1 ; next block
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 12
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 13-21
i=1
REPT 9
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     move.l    save_usp,sp
     trap      #3               ; return to super mode

;*********************************************************************

y_offs_2:
; nulde set blokken
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       34(a3,d0.w),a7   ; block a.l, skip 8 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       32(a3,d0.w),a6   ; block b, skip 8 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       32(a3,d0.w),a5   ; block c, skip 8 lijnen
; nu de lijnen
; lijn 0
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 1-7
i=1
REPT 7
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     lea       -160(a0),a0      ; shift screen pos
; eerste set blokken
     moveq     #0,d0            ;
     lea       -MAPLEN-3(a1),a1 ; next block
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 8
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 9-21
i=1
REPT 13
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     move.l    save_usp,sp
     trap      #3               ; return to super mode

;*********************************************************************

y_offs_1:
; nulde set blokken
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       50(a3,d0.w),a7   ; block a.l, skip 12 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       48(a3,d0.w),a6   ; block b, skip 12 lijnen
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       48(a3,d0.w),a5   ; block c, skip 12 lijnen
; nu de lijnen
; lijn 0
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 1-3
i=1
REPT 3
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     lea       -160(a0),a0      ; shift screen pos
; eerste set blokken
     moveq     #0,d0            ;
     lea       -MAPLEN-3(a1),a1 ; next block
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 4
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 5-19
i=1
REPT 15
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     lea       -160(a0),a0      ; shift screen pos
; tweede set blokken
     moveq     #0,d0            ;
     lea       -MAPLEN-3(a1),a1 ; next block
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 20
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 21
i=1
REPT 1
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     move.l    save_usp,sp
     trap      #3               ; return to super mode

;*********************************************************************

y_offs_0:
     lea       -MAPLEN(a1),a1   ; skip onderste block
; nulde set blokken
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 0
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 1-15
i=1
REPT 15
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     lea       -160(a0),a0      ; shift screen pos
; eerste set blokken
     moveq     #0,d0            ;
     lea       -MAPLEN-3(a1),a1 ; next block
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       2(a3,d0.w),a7    ; block a.l
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a6    ; block b
     moveq     #0,d0            ;
     move.b    (a1)+,d0         ; map data
     move.b    0(a4,d0.w),d0    ; mask_same tabel
     lsl.w     #6,d0            ; offset in mask tabel
     lea       0(a3,d0.w),a5    ; block c
; nu de lijnen
; lijn 16
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    (a5),d0          ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
; lijn 17-21
i=1
REPT 5
     lea       -160(a0),a0      ; shift screen pos
     move.l    (a7)+,d0         ; i_mask a.l zit nu in d0.h
     move.w    i*4(a5),d0       ; i_mask c.l
     or.l      (a6)+,d0         ; i_mask data
     and.l     (a2)+,d0         ; sprite mask
     move.l    d0,d2            ; sprite mask
     move.w    d0,d1            ; sprite mask
     swap      d2               ;
     move.w    d2,d0            ; long mask deel 1
     move.w    d1,d2            ; long mask deel 2
     movem.l   (A0),d4-d7       ; scherm data
     move.l    d0,d1            ; i_sprite_mask
     move.l    d2,d3            ; i sprite mask
     or.l      d0,d4            ; mask sprite
     or.l      d1,d5            ; mask sprite
     or.l      d2,d6            ; mask sprite
     or.l      d3,d7            ; mask sprite
     and.l     (a2)+,d0         ; sprite data
     and.l     (a2)+,d1         ; sprite data
     and.l     (a2)+,d2         ; sprite data
     and.l     (a2)+,d3         ; sprite data
     eor.l     d0,d4            ; screen data
     eor.l     d1,d5            ; screen data
     eor.l     d2,d6            ; screen data
     eor.l     d3,d7            ; screen data
     movem.l   d4-d7,(a0)       ; write screen
i=i+1
ENDM
     move.l    save_usp,sp
     trap      #3               ; return to super mode

;*********************************************************************


trap3_handler:
     move.l    stack,sp         ; restore stack
     movem.l   (sp)+,d3-d7/a2-a6; restore registers
     rts
BSS

linecount:
     ds.w 1
stack:
     ds.l 1
save_usp:
     ds.l 1
EVEN
     ds.b 1
game_map2:
     ds.b 54001
EVEN
