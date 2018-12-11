****************************
* Routines assembleur pour *
* Le d‚compactage LZW.     *
****************************

    .IMPORT cprs_buffer, pt_cprs
    .EXPORT gif_nextcode, tiff_nextcode, tiff_030nextcode
    .EXPORT output_gifcode, output_tiffcode, output_tiff030code
    .EXPORT lzw_optimization
    .EXPORT dstack, suffix, sizeofstring, prefix
    .EXPORT stackp
    .EXPORT out_value, slot, top_slot, newcodes
    .EXPORT code_size, start_size, bit_shift
    .EXPORT clear_code, eoi_code, old_code, code
    .EXPORT lzw_decompress
    .EXPORT pt_in, bit1, last_data


output_gifcode:
    MOVE.L    D3,-(SP)

    MOVE.W    #8,A1
    MOVE.W    bit1,D1
    MOVE.W    code_size,D2
    SUBQ.W    #1,D2
    MOVEQ.L   #0,D3
    LEA.L     cprs_buffer,A0
    ADD.W     pt_cprs,A0
out_loop:
    BTST      D3,D0
    BEQ       pas_un
    BSET      D1,(A0)
pas_un:
    ADDQ.W    #1,D3
    ADDQ.W    #1,D1
    CMP.W     A1,D1
    BNE       nch_octet
    ADDQ.L    #1,A0
    CLR.B     (A0)
    ADD.W     #1,pt_cprs
    MOVEQ.L   #0,D1
nch_octet:
    DBF       D2,out_loop

    MOVE.W    D1,bit1
    MOVE.L    (SP)+,D3
    RTS


output_tiffcode:
    MOVE.L    D3,-(SP)

    MOVE.W    #-1,A1
    MOVE.W    bit1,D1
    MOVE.W    code_size,D2
    SUBQ.W    #1,D2
    MOVE.W    D2,D3
    LEA.L     cprs_buffer,A0
    ADD.W     pt_cprs,A0
tout_loop:
    BTST      D3,D0
    BEQ       tpas_un
    BSET      D1,(A0)
tpas_un:
    SUBQ.W    #1,D3
    SUBQ.W    #1,D1
    CMP.W     A1,D1
    BNE       tnch_octet
    ADDQ.L    #1,A0
    CLR.B     (A0)
    ADD.W     #1,pt_cprs
    MOVEQ.L   #7,D1
tnch_octet:
    DBF       D2,tout_loop

    MOVE.W    D1,bit1
    MOVE.L    (SP)+,D3
    RTS

output_tiff030code:
    LEA.L     cprs_buffer,A0
    MOVE.L    bit_shift,D1
    MOVE.W    code_size,D2
    BFINS     D0,(A0){D1:D2}
    ADD.L     D2,D1
    MOVE.L    D1,bit_shift
    LSR.W     #3,D1
    MOVE.W    D1,pt_cprs
    RTS

gif_nextcode:
    MOVEM.L    D3-D6,-(SP)

    MOVE.L     last_data,A1  ; Dernier byte du bloc
    MOVEQ.L    #0,D3         ; Futur code
    MOVEQ.L    #0,D4         ; Bit int‚ress‚ pour new_code
    MOVEQ.L    #8,D5
    MOVEQ.L    #1,D6
    MOVE.L     pt_in,A0
    MOVE.B     (A0),D0
    MOVE.W     bit1,D1
    MOVE.W     code_size,D2
    SUB.W      D6,D2
odo_code:
    BTST.B     D1,D0
    BEQ        onot_one
    BSET       D4,D3
onot_one:
    ADD.W      D6,D4
    ADD.W      D6,D1
    CMP.B      D5,D1
    BNE        oend_loop
    MOVEQ.L    #0,D1
    CMPA.L     A1,A0
    BNE        ono_skip_count
    ADD.L      D6,A0         ; Saute le count du bloc suivant
ono_skip_count:
    ADD.L      D6,A0
    MOVE.B     (A0),D0
oend_loop:
    DBF        D2,odo_code

    MOVE.L     A0,pt_in
    MOVE.W     D1,bit1
    MOVE.W     D3,code

    MOVEM.L   (SP)+,D3-D6
    RTS

tiff_030nextcode:
    MOVE.L    pt_in,A0
    MOVEQ.L   #0,D2
    MOVE.L    bit_shift,D1
    MOVE.W    code_size,D2

    BFEXTU    (A0){D1:D2},D0
    MOVE.W    D0,code
    ADD.L     D2,bit_shift

    RTS

tiff_nextcode:
*    MOVE.L    pt_in,A0
*    LEA.L     1+tampon,A1
*    MOVE.B    (A0)+,(A1)+
*    MOVE.B    (A0)+,(A1)+
*    MOVE.B    (A0)+,(A1)+
*    MOVE.L    tampon,D0
*    MOVE.W    code_size,D2

*    MOVE.W    bit1,D1
*    ADD.W     #17,D1
*    SUB.W     D2,D1

*    LSR.L     D1,D0
*    ADD.W     D2,D2
*    AND.W     mask(PC,D2),D0
*    MOVE.W    D0,code

*    SUBQ.W    #1,D1
*    CMPI.B    #15,D1
*    BGT       bit1ajust
*    CMPI.B    #7,D1
*    BLS       add2
*    ADDQ.L    #1,pt_in
*    BRA       bit1ajust
*add2:
*    ADDQ.L    #2,pt_in
*bit1ajust:
*    ANDI.B    #$07,D1
*    MOVE.W    D1,bit1

*    RTS


     .EVEN
lzw_rout:
    DC.L      lzwdgtif_000
    DC.L      lzwdgtif_000
    DC.L      lzwdgtif_000
    DC.L      lzwdtif_030

lzw_pgetcode:
    DC.L      G000_GETNEXTCODE
    DC.L      G000_GETNEXTCODE
    DC.L      T000_GETNEXTCODE
    DC.L      0                   ; Impl‚ment‚ en macro

; size_t lzw_decompress(unsigned char *in, unsigned char *out, size_t nb_bytein)
;                              A0.L                  A1.L                  D0.L
; Retourner dans D0.L le nombre d'octets aprŠs d‚compactage
; D2.W = code_size

lzw_decompress:
    MOVEM.L   D1-D7/A0-A6, -(SP)

;   Init des variables communes aux routines
    MOVE.L    A1,original_out
    MOVEQ.L   #0,D2
    MOVE.W    code_size(PC),D2
    MOVE.W    clear_code(PC),D4
    SWAP      D4
    MOVE.W    eoi_code(PC),D4
    SWAP      D4
    MOVE.L    sizeofstring(PC),A3
    MOVE.W    slot(PC),D5
    MOVE.W    top_slot(PC),D3
    SWAP      D3
    MOVE.L    prefix(PC),A4
    MOVEQ.L   #0,D6                     ; fini = 0
    MOVE.B    out_value(PC),D6
    SWAP      D6
    MOVE.W    old_code(PC),D6
    SWAP      D6
    MOVE.L    stackp(PC),A6
 
;   Calcul de l'adresse de la routine
    MOVE.W    lzw_optimization(PC),D3
    ADD.W     D3,D3
;   Init offset topslot (distinguo GIF-TIFF)
    MOVE.W    tab_offslot(PC,D3.W),offset_topslot
    ADD.W     D3,D3
    MOVE.L    lzw_pgetcode(PC,D3),lzw_adrgetcode
    MOVE.L    lzw_rout(PC,D3.W),A2

    JSR       (A2)

;   Calcul du nombre d'octets aprŠs d‚compactage
    MOVE.L    A1,D0
    SUB.L     original_out(PC),D0

;   Mise … jour des variables
    MOVE.W    D2,code_size
    MOVE.W    D3,code
    MOVE.W    D5,slot
    SWAP      D3
    MOVE.W    D3,top_slot
    MOVE.B    D6,out_value
    SWAP      D6
    MOVE.W    D6,old_code
    MOVE.L    A6,stackp
    MOVE.L    A0,pt_in


    MOVEM.L   (SP)+,D1-D7/A0-A6

    RTS



    .EVEN

tab_offslot:
    DC.W      0, 0, 1, 1

lzw_vars:
lzw_optimization:
              DS.W      1

lzw_adrgetcode:
              DC.L      0      ; pointeur sur routine
dstack:       DC.L      0      ; unsigned char *
suffix:       DC.L      0      ; unsigned char *
sizeofstring: DC.L      0      ; int *
prefix:       DC.L      0      ; unsigned int *
stackp:       DC.L      0      ; unsigned char *
slot:         DC.W      0      ; int
top_slot:     DC.W      0      ; int
newcodes:     DC.W      0      ; int
code_size:    DC.W      0      ; int
code:         DC.W      0      ; int

original_out: DC.L      0      ; unsigned char *
last_bit:     DC.L      0      ; long
bit_shift:    DC.L      0      ; long
last_data:    DC.L      0      ; unsigned char *
clear_code:   DC.W      0      ; int
eoi_code:     DC.W      0      ; int
start_size:   DC.W      0      ; int
old_code:     DC.W      0      ; int
out_value:    DC.B      0      ; unsigned char


    .EVEN
* Routines sp‚cifiques aux formats TIFF, GIF avec ou sans optimisation 68030
* A0.L = pt_in     --> Donn‚es en entr‚es
* A1.L = pt_out    --> Donn‚es en sortie
* D0.L = nb_bytein --> Nombre d'octets … d‚compacter

* Routine TIFF avec optimisation 68030
* D1.L  = bit_shift
* D2.W  = code_size
* D3.W  = code
* ED3.W = top_slot
* D4.W  = clear_code
* ED4.W = eoi_code
* D5.W  = slot
* D6.B  = out_value
* Bit #8 de D6 = fini
* Bit #9 de D6 = fastloop
* ED6.W = old_code
* A2.L  = suffix
* A3.L  = sizeofstring
* A4.L  = prefix
* A5.W  = fcode
* A6.L  = stackp
* D7    = variable temporaire

MACRO T030_GETNEXTCODE

    BFEXTU    (A0){D1:D2},D7
    ADD.L     D2,D1
    MOVE.W    D7,D3
     
ENDM

lzwdtif_030:
     LSL.L    #3,D0            ; D0 = last_bit = nb_bytein << 3
     MOVE.L   bit_shift(PC),D1 ; D1 = bit_shift
     MOVE.L   suffix(PC),A2
lzwdtif_030cont:
     T030_GETNEXTCODE          ; --> D3 = code
     CMP.W    D4,D3            ; code = clear_code ?
     BNE      not_clear_code
; Cas code = CLEAR_CODE
     MOVE.W   start_size(PC),D2 ; code_size = start_size
     MOVE.W   newcodes(PC),D5   ; slot = newcodes
     CLR.W    (A3,D5.W*2)       ; sizeofstring[slot] = 0
     SWAP     D3
     MOVE.W   #1,D3
     LSL.W    D2,D3
     SUBQ.W   #1,D3             ; top_slot--
     SWAP     D3                ; ED3.W = top_slot = 1 << code_size  - 1
still_clear_code:
     T030_GETNEXTCODE          ; --> D3 = code
     CMP.W    D4,D3            ; code = clear_code ?
     BEQ      still_clear_code
     CMP.W    D5,D3            ; code >= slot ?
     BMI      after_raz
     CLR.W    D3               ; Oui : code = 0
after_raz:
     MOVE.W   D3,A5            ; fcode = code
     MOVE.B   D3,D6            ; out_value = code
     SWAP     D6
     MOVE.W   D3,D6
     SWAP     D6               ; ED6.W = old_code = code
     MOVE.B   D3,(A6)+         ; *stackp++ = code
     BRA      done_study_code
; Fin Cas code = CLEAR_CODE

not_clear_code:
     SWAP     D4
     CMP.W    D4,D3            ; code = eoi_code ?
     BNE      no_special_code
     SWAP     D4               ; D4.W = clear_code, ED4.W = eoi_code
; Cas code = EOI_CODE
     MOVE.W   start_size(PC),D2 ; code_size = start_size
     MOVE.W   newcodes(PC),D5   ; slot = newcodes
     CLR.W    (A3,D5.W*2)       ; sizeofstring[slot] = 0
     SWAP     D3
     MOVE.W   #1,D3
     LSL.W    D2,D3
     SWAP     D3                ; ED3.W = top_slot = 1 << code_size
     BSET     #8,D6             ; fini = 1
     MOVE.L   dstack(PC),A6     ; stackp = dstack
     BRA      done_study_code
; Fin Cas code = EOI_CODE

no_special_code:
     MOVE.L   D1,-(SP)         ; Sauvegarde bit_shift
     MOVE.W   A5,D1            ; D1 = fcode (temporaire)
     SWAP     D4               ; D4.W = clear_code, ED4.W = eoi_code
     MOVE.L   D4,-(SP)         ; Sauvegarde D4
     MOVE.W   D3,D1            ; fcode (D1.W) = code (D3.W)
     CMP.W    D5,D1            ; fcode >= slot ?
     BMI      aftercmp
     BEQ      fcode_egal_slot
     MOVE.W   D1,D3            ; fcode > slot : code = slot
fcode_egal_slot:
     SWAP     D6
     MOVE.W   D6,D1            ; fcode = old_code
     SWAP     D6
     MOVE.B   D6,(A6)+         ; *stackp++ = out_value

aftercmp:
     BCLR     #9,D6            ; fastloop = 0
     MOVEQ.L  #0,D7
wfcodesupnbewcodes:
     CMP.W    newcodes(PC),D1  ; while ( fcode >= newcodes )
     BMI      end_wloop
     MOVE.W   (A3,D1.W*2),D7   ; D7.W = i = sizeofstring[fcode]
     MOVE.W   D7,D4            ; D4.W = j = sizeofstring[fcode]
     BEQ      inul
     BSET     #9,D6            ; fastloop = 1
do_j:
     MOVE.B   (A2,D1.W),(A1,D4.W) ; *(pt_out+j) = suffix[fcode]
     MOVE.W   (A4,D1.W*2),D1      ; fcode = prefix[fcode]
     SUBQ.W   #1,D4
     BGT      do_j
     MOVE.B   D1,(A1)+            ; *pt_out = fcode
     ADD.L    D7,A1               ; pt_out += ++i
     BRA      wfcodesupnbewcodes

inul:
     MOVE.B   (A2,D1.W),(A6)+     ; *stackp++ = suffix[fcode]
     MOVE.W   (A4,D1.W*2),D1      ; fcode = prefix[fcode]
     BRA      wfcodesupnbewcodes
     
end_wloop:
     BTST     #9,D6               ; fastloop = 1 ?
     BNE      next0
     MOVE.B   D1,(A6)+            ; fastloop = 0 : *stackp++ = fcode

next0:
     SWAP     D3                  ; D3.W = top_slot
     CMP.W    D3,D5               ; slot < top_slot ?
     BGE      slotsupetopslot
; slot < top_slot
     SWAP D6                      ; D6.W = old_code
     MOVE.W   (A3,D6.W*2),D7      ; D7 = sizeofstring[old_code]
     ADDQ.W   #1,D7
     MOVE.W   D7,(A3,D5.W*2)      ; sizeofstring[slot] = sizeofstring[old_code]+1
     MOVE.B   D1,(A2,D5.W)        ; suffix[slot] = fcode
     MOVE.W   D6,(A4,D5.W*2)      ; prefix[slot] = old_code
     ADDQ.W   #1,D5               ; slot++
     SWAP     D3                  ; D3.W = code
     MOVE.W   D3,D6               ; old_code = code
     SWAP     D6                  ; D6.B = out_value
     MOVE.B   D1,D6               ; out_value = fcode
     SWAP     D3
     
slotsupetopslot:
     CMP.W    D3,D5               ; slot >= top_slot ?
     BLT      slotinftopslot
     CMPI.W   #12,D2              ; Oui : code_size < 12 ?
     BGE      slotinftopslot
     ADDQ.W   #1,D2               ; Oui : ++code_size
     MOVE.W   #1,D3
     LSL.W    D2,D3               ; D3.W = 1 << code_size
     SUBQ.W   #1,D3               ; top_slot--
     
slotinftopslot:
     SWAP     D3               ; ED3.W = top_slot
     MOVE.L   (SP)+,D4         ; Restaure D4
     MOVE.W   D1,A5            ; Restaure fcode
     MOVE.L   (SP)+,D1         ; Restaure bit_shift

done_study_code:
     MOVE.L    dstack(PC),D7
cmp_stack:
     CMP.L     D7,A6           ; stackp > dstack ?
     BLE       stop_stack
     MOVE.B    -(A6),(A1)+     ; *pt_out++ = *(--stackp)
     BRA       cmp_stack

stop_stack:
     BTST      #8,D6           ; fini = 1 ?
     BEQ       tst_bshift
     BRA       t030_rts

tst_bshift:
     CMP.L     D1,D0           ; bit_shift (D1) > last_bit (D0) ?
     BGE       lzwdtif_030cont

t030_rts:
     RTS


    .EVEN
tampon:
    .DC.L     0
mask:
    .DC.W     $0000
    .DC.W     $0001
    .DC.W     $0003
    .DC.W     $0007
    .DC.W     $000F
    .DC.W     $001F
    .DC.W     $003F
    .DC.W     $007F
    .DC.W     $00FF
    .DC.W     $01FF
    .DC.W     $03FF
    .DC.W     $07FF
    .DC.W     $0FFF
    .DC.W     $1FFF
    .DC.W     $3FFF
    .DC.W     $7FFF
    .DC.W     $FFFF
pt_in:
     DC.L     0
bit1:
     DC.W     0
offset_topslot:
     DC.W     0

T000_GETNEXTCODE:

    MOVEM.L   D0-D2/A1,-(SP)

    MOVE.L    A0,A2
    LEA.L     1+tampon(PC),A1
    MOVE.B    (A2)+,(A1)+
    MOVE.B    (A2)+,(A1)+
    MOVE.B    (A2)+,(A1)+
    MOVE.L    tampon(PC),D0

    MOVE.W    bit1(PC),D1
    ADD.W     #17,D1
    SUB.W     D2,D1

    LSR.L     D1,D0
    ADD.W     D2,D2
    AND.W     mask(PC,D2),D0
    MOVE.W    D0,D3              ; D3 = code

    SUBQ.W    #1,D1
    CMPI.B    #15,D1
    BGT       bit1ajust
    CMPI.B    #7,D1
    BLS       add2
    ADDQ.L    #1,A0
    BRA       bit1ajust
add2:
    ADDQ.L    #2,A0
bit1ajust:
    ANDI.B    #$07,D1
    MOVE.W    D1,bit1

    MOVEM.L   (SP)+,D0-D2/A1
    RTS

G000_GETNEXTCODE:
    MOVEM.L    A1/D0/D1/D2/D4,-(SP)

    MOVE.L     D1,A1             ; Dernier byte du bloc
    CLR.W      D3                ; Futur code
    MOVEQ.L    #0,D4             ; Bit int‚ress‚ pour new_code
    MOVE.B     (A0),D0
    MOVE.W     bit1(PC),D1
    SUBI.W     #1,D2
do_code:
    BTST.B     D1,D0
    BEQ        not_one
    BSET       D4,D3
not_one:
    ADDQ.W     #1,D4
    ADDQ.W     #1,D1
    CMPI.B     #8,D1
    BNE        end_loop
    MOVEQ.L    #0,D1
    CMPA.L     A1,A0
    BNE        no_skip_count
    ADDQ.L     #1,A0         ; Saute le count du bloc suivant
no_skip_count:
    ADDQ.L     #1,A0
    MOVE.B     (A0),D0
end_loop:
    DBF        D2,do_code

    MOVE.W     D1,bit1

    MOVEM.L    (SP)+,A1/D0/D1/D2/D4
    RTS


    MACRO      GT000_GETNEXTCODE
    
    MOVE.L   A2,-(SP)
    MOVE.L   lzw_adrgetcode(PC),A2
    JSR      (A2)                  ; --> D3 = code
    MOVE.L   (SP)+,A2
     
    ENDM

lzwdgtif_000:
     MOVE.L   A0,D1
     ADD.L    D0,D1
     SUBQ.L   #1,D1            ; D1 = last_data = in+nb_bytein-1
     MOVE.L   D1,last_data
     MOVE.L   suffix(PC),A2
     MOVE.L   pt_in(PC),A0     ; GIF DOIT GARDER CETTE INFO
lzwdtif_000cont:
     GT000_GETNEXTCODE         ; --> D3 = code
     CMP.W    D4,D3            ; code = clear_code ?
     BNE      not_clear_codet000
; Cas code = CLEAR_CODE
     MOVE.W   start_size(PC),D2 ; code_size = start_size
     MOVE.W   newcodes(PC),D5   ; slot = newcodes
     MOVE.W   D5,D7
     ADD.W    D7,D7
     CLR.W    (A3,D7.W)         ; sizeofstring[slot] = 0
     SWAP     D3
     MOVE.W   #1,D3
     LSL.W    D2,D3
     SUB.W    offset_topslot(PC),D3  ; Eventuel top_slot--
     SWAP     D3                ; ED3.W = top_slot = 1 << code_size  - 1
still_clear_codet000:
     GT000_GETNEXTCODE         ; --> D3 = code
     CMP.W    D4,D3            ; code = clear_code ?
     BEQ      still_clear_codet000
     CMP.W    D5,D3            ; code >= slot ?
     BMI      after_razt000
     CLR.W    D3               ; Oui : code = 0
after_razt000:
     MOVE.W   D3,A5            ; fcode = code
     MOVE.B   D3,D6            ; out_value = code
     SWAP     D6
     MOVE.W   D3,D6
     SWAP     D6               ; ED6.W = old_code = code
     MOVE.B   D3,(A6)+         ; *stackp++ = code
     BRA      done_study_codet000
; Fin Cas code = CLEAR_CODE

not_clear_codet000:
     SWAP     D4
     CMP.W    D4,D3            ; code = eoi_code ?
     BNE      no_special_codet000
     SWAP     D4               ; D4.W = clear_code, ED4.W = eoi_code
; Cas code = EOI_CODE
     MOVE.W   start_size(PC),D2 ; code_size = start_size
     MOVE.W   newcodes(PC),D5   ; slot = newcodes
     MOVE.W   D5,D7
     ADD.W    D7,D7
     CLR.W    (A3,D7.W)         ; sizeofstring[slot] = 0
     SWAP     D3
     MOVE.W   #1,D3
     LSL.W    D2,D3
     SUB.W    offset_topslot(PC),D3  ; Eventuel top_slot--
     SWAP     D3                ; ED3.W = top_slot = 1 << code_size
     BSET     #8,D6             ; fini = 1
     MOVE.L   dstack(PC),A6     ; stackp = dstack
     BRA      done_study_codet000
; Fin Cas code = EOI_CODE

no_special_codet000:
     MOVE.L   D1,-(SP)         ; Sauvegarde last_data
     MOVE.W   A5,D1            ; D1 = fcode (temporaire)
     SWAP     D4               ; D4.W = clear_code, ED4.W = eoi_code
     MOVE.L   D4,-(SP)         ; Sauvegarde D4
     MOVE.W   D3,D1            ; fcode (D1.W) = code (D3.W)
     CMP.W    D5,D1            ; fcode >= slot ?
     BMI      aftercmpt000
     BEQ      fcode_egal_slott000
     MOVE.W   D1,D3            ; fcode > slot : code = slot
fcode_egal_slott000:
     SWAP     D6
     MOVE.W   D6,D1            ; fcode = old_code
     SWAP     D6
     MOVE.B   D6,(A6)+         ; *stackp++ = out_value

aftercmpt000:
     BCLR     #9,D6            ; fastloop = 0
     MOVEQ.L  #0,D7
wfcodesupnbewcodest000:
     CMP.W    newcodes(PC),D1  ; while ( fcode >= newcodes )
     BMI      end_wloopt000
     MOVE.W   D1,D7
     ADD.W    D1,D7
     MOVE.W   (A3,D7.W),D7     ; D7.W = i = sizeofstring[fcode]
     MOVE.W   D7,D4            ; D4.W = j = sizeofstring[fcode]
     BEQ      inult000
     BSET     #9,D6            ; fastloop = 1
do_jt000:
     MOVE.B   (A2,D1.W),(A1,D4.W) ; *(pt_out+j) = suffix[fcode]
     ADD.W    D1,D1
     MOVE.W   (A4,D1.W),D1        ; fcode = prefix[fcode]
     SUBQ.W   #1,D4
     BGT      do_jt000
     MOVE.B   D1,(A1)+            ; *pt_out = fcode
     ADD.L    D7,A1               ; pt_out += ++i
     BRA      wfcodesupnbewcodest000

inult000:
     MOVE.B   (A2,D1.W),(A6)+     ; *stackp++ = suffix[fcode]
     ADD.W    D1,D1
     MOVE.W   (A4,D1.W),D1        ; fcode = prefix[fcode]
     BRA      wfcodesupnbewcodest000
     
end_wloopt000:
     BTST     #9,D6               ; fastloop = 1 ?
     BNE      next000
     MOVE.B   D1,(A6)+            ; fastloop = 0 : *stackp++ = fcode

next000:
     SWAP     D3                  ; D3.W = top_slot
     CMP.W    D3,D5               ; slot < top_slot ?
     BGE      slotsupetopslott000
; slot < top_slot
     SWAP D6                      ; D6.W = old_code
     MOVE.W   D6,D7
     ADD.W    D7,D7
     MOVE.W   (A3,D7.W),D7        ; D7 = sizeofstring[old_code]
     ADDQ.W   #1,D7
     MOVE.B   D1,(A2,D5.W)        ; suffix[slot] = fcode
     ADD.W    D5,D5               ; D5 = 2*D5
     MOVE.W   D7,(A3,D5.W)        ; sizeofstring[slot] = sizeofstring[old_code]+1
     MOVE.W   D6,(A4,D5.W)        ; prefix[slot] = old_code
     LSR.W    #1,D5               ; Restaure D5
     ADDQ.W   #1,D5               ; slot++
     SWAP     D3                  ; D3.W = code
     MOVE.W   D3,D6               ; old_code = code
     SWAP     D6                  ; D6.B = out_value
     MOVE.B   D1,D6               ; out_value = fcode
     SWAP     D3
     
slotsupetopslott000:
     CMP.W    D3,D5               ; slot >= top_slot ?
     BLT      slotinftopslott000
     CMPI.W   #12,D2              ; Oui : code_size < 12 ?
     BGE      slotinftopslott000
     ADDQ.W   #1,D2               ; Oui : ++code_size
     MOVE.W   #1,D3
     LSL.W    D2,D3               ; D3.W = 1 << code_size
     SUB.W    offset_topslot(PC),D3  ; Eventuel top_slot--
     
slotinftopslott000:
     SWAP     D3               ; ED3.W = top_slot
     MOVE.L   (SP)+,D4         ; Restaure D4
     MOVE.W   D1,A5            ; Restaure fcode
     MOVE.L   (SP)+,D1         ; Restaure bit_shift

done_study_codet000:
     MOVE.L    dstack(PC),D7
cmp_stackt000:

     CMP.L     D7,A6           ; stackp > dstack ?
     BLE       stop_stackt000
     MOVE.B    -(A6),(A1)+     ; *pt_out++ = *(--stackp)
     BRA       cmp_stackt000

stop_stackt000:
     BTST      #8,D6           ; fini = 1 ?
     BEQ       tst_bshiftt000
     BRA       t000_rts

tst_bshiftt000:
     CMP.L     A0,D1           ; pt_in (A0) > last_data (D1) ?
     BGE       lzwdtif_000cont

t000_rts:
     RTS

