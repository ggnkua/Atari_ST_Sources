;---------------------------------------------------------
; PRO-PACK Unpack Source Code - Nintendo Gameboy, Method 1
;
; Converted from Atari Lynx 6502 to GameBoy by Jeff Frohwein, 26-Jul-99
;
; File: RNC_1.ASM
;
;---------------------------------------------------------

HDLEN   EQU 17

        PUSHS

        SECTION "RNC1 Vars",BSS

rawtab   DS $80
postab   DS $80
slntab   DS $80
tmptab   DS $10


        SECTION "RNC1 High Vars",HRAM

regx     DS 1
regy     DS 1
bitbufl  DS 2
bitbufh  DS 2
rncdat   DS 4
InPtr    DS 2           ; input data pointer
OutPtr   DS 2           ; output data pointer
hufftab  DS 2

cartdat  DS 2
counts   DS 2
blocks   DS 1
bufbits  DS 1
bitlen   DS 1
hufcde   DS 2
hufbse   DS 2
temp1    DS 1
temp2    DS 1
temp3    DS 1

        POPS

; ****** Unpack RNC format 1 data ******
; Entry: HL = Source packed data
;        DE = Destination for unpacked data

Unpack:
        ld      a,e
        ld      [OutPtr],a
        ld      a,d
        ld      [OutPtr+1],a

        ld      bc,HDLEN
        add     hl,bc

        ld      a,[hl+]
        ld      [blocks],a

        xor     a
        ld      [bufbits],a

        ld      a,[hl+]
        ld      [bitbufl],a

        ld      a,[hl+]
        ld      [bitbufl+1],a

        ld      a,l
        ld      [InPtr],a
        ld      a,h
        ld      [InPtr+1],a

        ld      a,2
        call    .GetBits

.rnc01:
        ld      a,rawtab%256
        ld      [hufftab],a
        ld      a,rawtab/256
        ld      [hufftab+1],a

        call    .MakeHuff

        ld      a,postab%256
        ld      [hufftab],a
        ld      a,postab/256
        ld      [hufftab+1],a

        call    .MakeHuff

        ld      a,slntab%256
        ld      [hufftab],a
        ld      a,slntab/256
        ld      [hufftab+1],a

        call    .MakeHuff

        ld      a,16
        call    .GetBits

        ld      a,[rncdat+1]
        ld      b,a

        ld      a,[rncdat]
        ld      [counts],a

        or      a
        jr      z,.rnc02

        inc     b
.rnc02:

        ld      a,b
        ld      [counts+1],a

        jp      .rnc10

.rnc03:
        ld      a,postab%256
        ld      [hufftab],a
        ld      a,postab/256
        ld      [hufftab+1],a

        call    .GetVal

        ld      a,[rncdat]
        ld      c,a
        ld      a,[rncdat+1]
        ld      b,a

        ld      a,[OutPtr]
        scf
        sbc     c
        ld      [temp1],a
        ld      a,[OutPtr+1]
        sbc     b
        ld      [temp2],a

        ld      a,slntab%256
        ld      [hufftab],a
        ld      a,slntab/256
        ld      [hufftab+1],a

        call    .GetVal

        ld      a,[rncdat+1]
        ld      b,a

        ld      a,[rncdat]
        add     2
        ld      c,a

        jr      z,.rnc04

        inc     b

.rnc04:
        jr      nc,.rnc05

        inc     b
.rnc05:
        ld      a,[temp1]
        ld      l,a
        ld      a,[temp1+1]
        ld      h,a

        ld      a,[OutPtr]
        ld      e,a
        ld      a,[OutPtr+1]
        ld      d,a

.rnc06:
        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      z,.rnc06a

        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.rnc06

.rnc06a:
        dec     b
        jr      nz,.rnc06

        ld      a,e
        ld      [OutPtr],a
        ld      a,d
        ld      [OutPtr+1],a

.rnc10:
        ld      a,rawtab%256
        ld      [hufftab],a
        ld      a,rawtab/256
        ld      [hufftab+1],a

        call    .GetVal

        ld      a,[rncdat]
        ld      b,a

        ld      a,[rncdat+1]
        or      b
        jp      z,.rnc22


        ld      a,[rncdat+1]
        ld      b,a

        ld      a,[rncdat]
        ld      c,a
        or      a
        jr      z,.rnc12

        inc     b
.rnc12:
        ld      a,b
        ld      [rncdat+1],a

        ld      b,3
        ld      hl,cartdat

        ld      a,[OutPtr]
        ld      e,a
        ld      a,[OutPtr+1]
        ld      d,a

.rnc13:
        dec     b
        jr      z,.rnc14

        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.rnc13

        ld      a,[rncdat+1]
        dec     a
        ld      [rncdat+1],a

        jr      nz,.rnc13

        dec     b
        jr      z,.rnc17

        ld      a,[cartdat+1]
        jr      .rnc18

.rnc14:
        ld      a,[InPtr]
        ld      l,a
        ld      a,[InPtr+1]
        ld      h,a

        ld      a,[rncdat+1]
        ld      b,a

.rnc14a:
        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      z,.rnc14b

        ld      a,[hl+]
        ld      [de],a
        inc     de

        dec     c
        jr      nz,.rnc14a

.rnc14b:
        dec     b
        jr      nz,.rnc14a

        ld      a,b
        ld      [rncdat+1],a

        ld      a,l
        ld      [InPtr],a
        ld      a,h
        ld      [InPtr+1],a

.rnc17:
        ld      a,[InPtr]
        ld      l,a
        ld      a,[InPtr+1]
        ld      h,a

        ld      a,[hl+]
        ld      [temp1],a
        ld      [cartdat],a

        jr      .rnc18a

.rnc18:
        ld      [temp1],a
        ld      [cartdat],a

        ld      a,[InPtr]
        ld      l,a
        ld      a,[InPtr+1]
        ld      h,a

.rnc18a:
        ld      a,[hl+]
        ld      [temp2],a
        ld      [cartdat+1],a

        ld      a,l
        ld      [InPtr],a
        ld      a,h
        ld      [InPtr+1],a

        ld      a,e
        ld      [OutPtr],a
        ld      a,d
        ld      [OutPtr+1],a

.rnc19:
        ld      a,[temp1]
        ld      e,a
        ld      a,[temp2]
        ld      d,a

        ld      hl,0

        ld      a,[bufbits]
        or      a
        jr      z,.rnc21

        ld      b,a
.rnc20:
        sla     e
        rl      d
        rl      l
        rl      h

        dec     b
        jr      nz,.rnc20

.rnc21:
        ld      a,l
        ld      [bitbufh],a
        ld      a,h
        ld      [bitbufh+1],a

        ld      a,[bitbufl]
        ld      c,a
        ld      a,[bitbufl+1]
        ld      b,a

        ld      a,[bufbits]
        add     a

        ld      l,.msktab%256
        add     l
        ld      l,a
        ld      a,.msktab/256
        adc     0
        ld      h,a

        ld      a,[hl]
        and     c
        or      e
        ld      [bitbufl],a

        inc     hl

        ld      a,[hl]
        and     b
        or      d
        ld      [bitbufl+1],a
.rnc22:
        ld      hl,counts
        dec     [hl]

        jp      nz,.rnc03

        ld      hl,counts+1
        dec     [hl]

        jp      nz,.rnc03


        ld      hl,blocks
        dec     [hl]

        jp      nz,.rnc01

        ret             ; Done!!!!


;**********************************

.GetVal:
        ld      a,[hufftab]
        ld      l,a
        ld      a,[hufftab+1]
        ld      h,a

        dec     hl
.GetVal2:

        inc     hl

.GetVal3:
        ld      a,[bitbufl]
        and     [hl]
        ld      b,a
        ld      [rncdat],a

        inc     hl

        ld      a,[bitbufl+1]
        and     [hl]
        ld      c,a
        ld      [rncdat+1],a

        inc     hl

        ld      a,b
        cp      [hl]
        inc     hl

        jr      nz,.GetVal2

        ld      a,c
        cp      [hl]
        inc     hl

        jr      nz,.GetVal3

        ld      a,l
        add     15*4
        ld      l,a
        jr      nc,.nocarry
        inc     h
.nocarry:

        ld      a,[hl+]
        push    af

        ld      a,[hl]

        call    .GetBits

        pop     af
        cp      2
        jr      nc,.GetVal4

        ld      [rncdat],a

        ld      hl,rncdat+1
        ld      [hl],0

        ret

.GetVal4:
        dec     a
        push    af
        call    .GetBits
        pop     af

        cp      8
        jr      c,.GetVal5

        ld      l,(.bittabl-8)%256
        add     l
        ld      l,a
        ld      a,(.bittabl-8)/256
        adc     0
        ld      h,a

        ld      a,[rncdat+1]
        or      [hl]
        ld      [rncdat+1],a

        ret

.GetVal5:
        ld      l,(.bittabl)%256
        add     l
        ld      l,a
        ld      a,(.bittabl)/256
        adc     0
        ld      h,a

        ld      a,[rncdat]
        or      [hl]
        ld      [rncdat],a
        ret

.bittabl:
        DB      1,2,4,8,16,32,64,128

;*********************************

.GetBits:
        ld      [regx],a
        add     a

        ld      l,.msktab%256
        add     l
        ld      l,a
        ld      a,.msktab/256
        adc     0
        ld      h,a

        ld      a,[bitbufh]
        ld      e,a
        ld      a,[bitbufh+1]
        ld      d,a

        ld      a,[bitbufl]
        ld      c,a
        and     [hl]
        ld      [rncdat],a

        inc     hl

        ld      a,[bitbufl+1]
        ld      b,a
        and     [hl]
        ld      [rncdat+1],a

        ld      a,[bufbits]
        or      a
        jr      nz,.GetBits4

.GetBits3:

        ld      a,[InPtr]
        ld      l,a
        ld      a,[InPtr+1]
        ld      h,a

        ld      a,[hl+]
        ld      [cartdat],a
        ld      e,a

        ld      a,[hl+]
        ld      [cartdat+1],a
        ld      d,a

        ld      a,l
        ld      [InPtr],a
        ld      a,h
        ld      [InPtr+1],a

        ld      a,16
        ld      [bufbits],a

.GetBits4:

        ld      a,[regx]
        ld      hl,bufbits

.GetBits4a:
        srl     d
        rr      e
        rr      b
        rr      c

        dec     a
        jr      z,.GetBits5

        dec     [hl]
        jr      nz,.GetBits4a

        ld      [regx],a

        jr      .GetBits3

.GetBits5:
        ld      a,c
        ld      [bitbufl],a
        ld      a,b
        ld      [bitbufl+1],a

        ld      a,e
        ld      [bitbufh],a
        ld      a,d
        ld      [bitbufh+1],a

        ld      hl,bufbits
        dec     [hl]
        ret

.msktab:
        dw      0,1,3,7,$f,$1f,$3f,$7f,$ff,$1ff,$3ff
        dw      $7ff,$fff,$1fff,$3fff,$7fff,$ffff

;***********************

.MakeHuff:
        ld      a,5
        call    .GetBits

        ld      a,[rncdat]
        or      a
        ret     z

        ld      [temp1],a
        ld      [temp2],a

        ld      hl,tmptab

.MakeHuff2:
        push    hl
        ld      a,4
        call    .GetBits

        ld      hl,temp2
        dec     [hl]

        pop     hl

        ld      a,[rncdat]
        ld      [hl+],a

        jr      nz,.MakeHuff2

        xor     a
        ld      [regy],a
        ld      [hufcde],a
        ld      [hufcde+1],a
        ld      [hufbse],a

        inc     a

        ld      [bitlen],a

        ld      a,$80
        ld      [hufbse+1],a
.MakeHuff3:
        ld      a,[temp1]
        ld      [temp2],a

        xor     a
        ld      [temp3],a

.MakeHuff4:
        ld      a,[temp3]
        ld      [regx],a

        ld      l,tmptab%256
        add     l
        ld      l,a
        ld      a,tmptab/256
        adc     0
        ld      h,a

        ld      a,[bitlen]
        cp      [hl]
        jp      nz,.MakeHuff8

        ld      [regx],a
        add     a

        ld      l,.msktab%256
        add     l
        ld      l,a
        ld      a,.msktab/256
        adc     0
        ld      h,a

        ld      b,[hl]

        ld      a,[regy]
        ld      c,a
        add     2
        ld      [regy],a

        ld      a,[hufftab]
        add     c
        ld      e,a
        ld      a,[hufftab+1]
        adc     0
        ld      d,a

        ld      a,b
        ld      [de],a

        inc     hl
        inc     de

        ld      a,[hl]
        ld      [de],a

        ld      a,[rncdat]
        ld      c,a
        ld      a,[rncdat+1]
        ld      b,a

        ld      a,[hufcde]
        ld      e,a

        ld      a,[hufcde+1]
        ld      d,a

        ld      a,[regx]

.MakeHuff5:
        sla     e
        rl      d
        rr      b
        rr      c

        dec     a
        jr      nz,.MakeHuff5

        ld      hl,rncdat+3
        ld      a,d
        ld      [hl-],a
        ld      a,e
        ld      [hl-],a

        ld      a,[bitlen]
        ld      e,a

        ld      a,16
        sub     e
        jr      z,.MakeHuff7

        ld      d,a

.MakeHuff6:
        srl     b
        rr      c

        dec     d
        jr      nz,.MakeHuff6

.MakeHuff7:
        ld      a,b
        ld      [hl-],a
        ld      a,c
        ld      [hl],a

        ld      a,[regy]
        ld      b,a
        add     2
        ld      [regy],a

        ld      a,[hufftab]
        add     b
        ld      l,a
        ld      a,[hufftab+1]
        adc     0
        ld      h,a

        ld      a,[rncdat]
        ld      [hl+],a

        ld      a,[rncdat+1]
        ld      [hl+],a

        ld      a,l
        add     15*4
        ld      l,a

        jr      nc,.nocarry2
        inc     h
.nocarry2:

        ld      a,[temp3]
        ld      [hl],a

        inc     hl

        ld      a,[bitlen]
        ld      [hl],a

        ld      a,[hufbse]
        ld      c,a
        ld      a,[hufbse+1]
        ld      b,a

        ld      a,[hufcde]
        add     c
        ld      [hufcde],a
        ld      a,[hufcde+1]
        adc     b
        ld      [hufcde+1],a

.MakeHuff8:
        ld      hl,temp3
        inc     [hl]

        ld      hl,temp2
        dec     [hl]
        jp      nz,.MakeHuff4

        ld      hl,hufbse+1
        srl     [hl]
        dec     hl
        rr      [hl]

        ld      a,[bitlen]
        inc     a
        ld      [bitlen],a

        cp      17
        jp      nz,.MakeHuff3

        ret
