;
; Starfield voor Heartland
; STARCOUNT is deelbaar door acht
; 320x160 veld
; 32x16 source
; z-buffer=STARCOUNT -> STARCOUNT stars
;
; x'=x*(0.9/STARCOUNT*z+0.1)
; y'=y*(0.9/STARCOUNT*z+0.1)
;
; lookup tabel: 32768*(0.9/STARCOUNT*z+.1)
;


EXPORT starfield

STARCOUNT equ 400

; Register gebruik:
; d0 = offset
; d1 = 0
; d2 = screen offset
; d3 = const: $fff8
; d4 = const: $ffe0
; d5 = const: $000f
; d6 = inner loop counter
; d7 = outer loop counter
;
; a0 = coordinaten pointer (x, y*64) == aanroep
; a1 = midden scherm                 == aanroep
; a2 = z-factor pointer    32768*(0.9/STARCOUNT*z+.1)
; a3 = x pixel tabel       1,2,3,4,8,16,32,64,128,256,512,1024,2048....
; a4 = coordinaten buffer  STARCOUNT words
; a5 =
; a6 = .new_offset
; a7 = sp

; void starfield(void* coord, void* scr)
starfield:                    ; 291 tikken per ster
     movem.l  d3-d7/a2-a6,-(sp) ; save registers
     moveq    #0,d1           ; leeg
     moveq    #(STARCOUNT/8)-1,d6 ; count
     lea      .new_offset(pc),a6 ; new offset
     move.l   (a6),a4         ; coordinaten buffer
.wis_loop:                    ; 204 tikken voor 8 sterren
     REPT 8
     move.w   (a4)+,d0        ; scherm offset           8
     move.w   d1,0(d0,a1)     ; wis                     16
     ENDM
     dbra     d6,.wis_loop    ; next                    12

; Register gebruik:
; d0 = x-coordinaat
; d1 = y-coordinaat
; d2 = screen offset
; d3 = const: $fff8
; d4 = const: $ffe0
; d5 = const: $000f
; d6 = inner loop counter
; d7 = outer loop counter
;
; a0 = coordinaten pointer (x, y*64)
; a1 = midden scherm
; a2 = z-factor pointer    (28.8 * z + 3276.8)
; a3 = x pixel tabel       1,2,3,4,8,16,32,64,128,256,512,1024,2048....
; a4 = coordinaten buffer
; a5 =
; a6 = .new_offset
; a7 = sp
     move.w   #$fff8,d3       ; and factor
     move.w   #$ffe0,d4       ; and factor
     moveq    #$000f,d5       ; and factor
     move.l   (a6),a4         ; coordinaten buffer
     lea      .z_factor(pc),a2 ; z-factor
     lea      .x_pixel,a3     ; x-pixel tabel
     moveq    #(STARCOUNT/8)-1,d6 ; count
.inner_loop:                  ; 2124 tikken per 8 sterren
     REPT 8
     move.w   (a2)+,d2        ; z-factor              8  dit kan een sub.w worden
     move.w   (a0)+,d0        ; x-coordinaat          8
     move.w   (a0)+,d1        ; y-coordinaat          8
     muls     d2,d0           ; x'                   70
     muls     d2,d1           ; y'                   70
     move.l   d0,d2           ; basis                 4
     swap     d1              ; y'                    4
     swap     d2              ; basis                 4
     add.l    d0,d0           ; x'                    8
     and.w    d3,d2           ; x' basis & $fff8      4
     and.w    d4,d1           ; y'*32                 4
     swap     d0              ; x'                    4
     add.w    d1,d2           ; y'                    4
     add.w    d1,d1           ; y'*2                  4
     and.w    d5,d0           ; pixel offset          4
     add.w    d1,d1           ; y'*4                  4
     add.w    d0,d0           ; offset in tabel       4
     add.w    d1,d2           ; screen offset         4
     move.w   0(d0.w,a3),d0   ; pixel waarde         16
     or.w     d0,0(d2.w,a1)   ; or screen            20
     move.w   d2,(a4)+        ; store offset          8
     ENDM
     dbra     d6,.inner_loop  ;                      12
     move.l   (a6),d0         ; new_offset
     move.l   4(a6),(a6)+     ; new_offset = old_offset
     move.l   d0,(a6)         ; old_offset = new_offset
     movem.l  (sp)+,d3-d7/a2-a6 ; restore registers
     rts

.new_offset:
     dc.l     .offset_a
.old_offset:
     dc.l     .offset_b

.x_pixel:                      ; tabel voor x-pixels
     count = 32768
     REPT 16
       dc.w count
       count=count/2
     ENDM

.z_factor:                     ; lookup tabel: 32768*(0.9/STARCOUNT*z+.1)
     count = STARCOUNT-1
     REPT STARCOUNT
       dc.w (count*26214)/STARCOUNT + 6553
       count = count - 1
     ENDM


     BSS

.offset_a:
     ds.w    STARCOUNT        ; coordinaten tabel
.offset_b:
     ds.w    STARCOUNT        ; coordinaten tabel

     END