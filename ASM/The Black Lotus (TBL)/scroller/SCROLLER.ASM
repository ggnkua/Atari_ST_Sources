;
; En helt fantastisk textscroll!! Behîver en fontfil som heter FONT.DOO
; vilken skall innehÜlla fonten. Den skall vara i ASCII-ordning!
;
; Skriven av CHRISTIAN DAHL. FîrbÑttrad 911026. Fungerar inte pÜ ST.
;
; Min adress:   CHRISTIAN DAHL
;               FOTBOLLSV. 11
;               73537  SURAHAMMAR
;               SWEDEN
;
; Koden Ñr skriven fîr METACOMCO's MACRO ASSEMBLER men bîr fungera pÜ
; andra assemblatorer utan stîrre Ñndraingar
;

A_LINE  EQU     64                      ; Bredden pÜ en blitterlinje

start:
        move.l  a7,a5
        move.l  4(a5),a5
        move.l  $c(a5),d0
        add.l   $14(a5),d0
        add.l   $1c(a5),d0
        add.l   #$100,d0
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        move.w  #0,-(sp)
        move.w  #$4a,-(sp)
        trap    #1                      ; Registrera programet
        add.l   #12,sp

        lea     sinus,a0                ; RÑkna om fÑrgkurvan
sloop:  cmp.l   #-99,(a0)
        beq.s   slutameds
        move.l  (a0),d1
        add.l   #32,d1
        add.l   d1,d1
        move.l  d1,(a0)+
        bra.s   sloop
slutameds:

        lea     farger,a6               ; Konvertera fÑrgerna sÜ att video
        move.w  #216+48-1,d7            ; shiftern fîrstÜr dem (fontfÑrg)
kljhgf1:move.w  (a6),d0
        bsr     change
        move.w  d0,(a6)+
        dbra    d7,kljhgf1

        lea     bak,a6                  ; Konvertera fÑrgerna sÜ att video
        move.w  #208-1,d7               ; shiftern fîrstÜr dem (rasterfÑrg)
kljhgf2:move.w  (a6),d0
        bsr     change
        move.w  d0,(a6)+
        dbra    d7,kljhgf2

        move.l  #96000,-(sp)
        move.w  #$48,-(sp)
        trap    #1                      ; BegÑr minne fîr scroll och font
        addq.l  #6,sp
        tst.l   d0
        bmi     err
        move.l  d0,sam
        move.l  d0,buffer
        add.l   #64000,d0
        move.l  d0,font

        move.l  sam,a0
        move.w  #96000/(4*16),d0
llll:   clr.l   (a0)+                   ; Tîm blitterminnet
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        dbra    d0,llll

        lea     bak,a1                  ; SÑtt ut bakraster
        move.l  sam,a0
        moveq   #2-1,d0
        move.w  #208-1,d1
        move.w  (a1),d2
        swap.w  d2
        move.w  (a1),d2
lll:    move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        dbra    d0,lll
        move.l  d2,(a0)+
        move.l  d2,(a0)+
        lea     128(a0),a0              ; En svart rad
        addq.l  #2,a1
        move.w  (a1),d2
        swap.w  d2
        move.w  (a1),d2
        moveq   #2-1,d0
        dbra    d1,lll

        move.l  #32000,laslangd
        move.l  font,lasbuffer
        move.l  #fontnamn,filnamn
        bsr     ladda                   ; Ladda font

        pea     musav                   ; StÑng av musen
        move.w  #2-1,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp

        move.w  #4,-(sp)
        trap    #14                     ; Upplîsning??
        addq.l  #2,sp
        move.w  d0,-(sp)

        move.w  #0,-(sp)
        move.l  #-1,-(sp)
        move.l  #-1,-(sp)
        move.w  #5,-(sp)
        trap    #14                     ; LÜgupplîsning
        add.w   #12,sp

        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1                      ; Super
        addq.w  #6,sp
        move.l  d0,-(sp)

        move.b  $ff820d,lag
        lea     $FF8205,A5              ; Ste ??????
        moveq   #-1,D1
        move.b  (A5),D0
        move.b  D1,(A5)
        cmp.b   (A5),D0
        beq     err
        move.b  D0,(a5)

        jsr     blittwait               ; StÑll in blittern som vi vill ha
        lea     $ff8a00,a0              ; den
        move.w  #16-1,d0
loopb:  move.w  #$ffff,(a0)+
        dbra    d0,loopb

        move.w  #$ffff,$ff8a28
        move.w  #$ffff,$ff8a2a
        move.w  #$ffff,$ff8a2c

        move.b  #2,$ff8a3a
        move.b  #0,$ff8a3d

        movem.l $ff8240,d0-d7           ; Spar gamla fÑrger
        movem.l d0-d7,-(sp)
        move.l  $70,-(sp)               ; Spar gammal VBL
        move.l  #blitt,$70              ; Initiera egen VBL

        move.l  #$00020002,-(sp)
        trap    #13                     ; VÑnta pÜ en tangent
        addq.l  #4,sp

        move.l  (sp)+,$70               ; Ladda upp gammal VBL
        movem.l (sp)+,d0-d7             ; och gamla fÑrger
        movem.l d0-d7,$ff8240

        move.b  lag,$ff820d

        move.w  #$20,-(sp)
        trap    #1                      ; User
        addq.w  #6,sp

        move.l  #-1,-(sp)
        move.l  #-1,-(sp)
        move.w  #5,-(sp)
        trap    #14                     ; Gammal upplîsning
        add.w   #12,sp

        pea     muspa                   ; SÑtt pÜ musen
        move.w  #1-1,-(sp)
        move.w  #25,-(sp)
        trap    #14
        addq.l  #8,sp

        move.l  buffer,-(sp)
        move.w  #$49,-(sp)
        trap    #1                      ; SlÑpp minne
        addq.l  #6,sp

        clr.w   -(sp)
        trap    #1                      ; Avsluta
        illegal

change:                                 ; Konverterar RGB till
        and.w   #$0FFF,d0               ; videoshifer
        move.w  d0,d1
        rol.w   #3,d1
        and.w   #$888,d1
        ror.w   #1,d0
        and.w   #$777,d0
        or.w    d1,d0
        rts

change_back:                            ; Konverterar videofÑrger till RGB
        and.w   #$0FFF,d0
        move.w  d0,d1
        ror.w   #3,d1
        and.w   #$111,d1
        rol.w   #1,d0
        and.w   #$EEE,d0
        or.w    d1,d0
        rts

ladda:  clr.w   -(sp)                   ; LÑser in en fil
        move.l  filnamn,-(sp)
        move.w  #$3d,-(sp)
        trap    #1                      ; ôppna fil
        addq.l  #8,sp
        tst.l   d0
        bmi     err
        move.w  d0,handle

        move.l  lasbuffer,-(sp)
        move.l  laslangd,-(sp)
        move.w  handle,-(sp)
        move.w  #$3f,-(sp)
        trap    #1                      ; LÑs fil
        lea     12(sp),sp
        cmp.l   laslangd,d0
        bne     err

        move.w  handle,-(sp)
        move.w  #$3e,-(sp)
        trap    #1                      ; StÑng fil
        addq.l  #4,sp

        rts

blitt:  or.w    #$700,sr                ; ScrollVBLen
        movem.l d0-d7/a0-a6,-(sp)

        ; ****** MèSTE vara fÑrdig innan bilden bîrjar !!! ******
        ;                 (annars rasar syncen)

        subq.w  #1,counter              ; Ladda up ny font
        bge     nonewfont               ; nej
        move.w  #15-1,counter
        move.l  weretext,a0
        tst.b   (a0)                    ; Slut pÜ meddelande
        bne.s   noreturn                ; nej
        lea     message,a0              ; Bîrja om med samma meddelande
noreturn:
        moveq   #0,d0
        moveq   #0,d1
        move.b  (a0)+,d0
        move.l  a0,weretext
        add.l   d0,d0
        lea     text_tabell,a2
        move.w  0(a2,d0),d1
        move.l  font,a2
        add.l   d1,a2
        lea     fontbuffer,a0   
        move.w  #16-1,d0
fontcp: move.l  (a2),(a0)+              ; Ladda in ny font och skala om den
        move.l  (a2),(a0)+
        move.l  (a2),(a0)+
        move.l  (a2),(a0)+
        move.l  (a2),(a0)+
        move.l  (a2),(a0)+
        move.w  (a2),(a0)+

        lea     160(a2),a2
        dbra    d0,fontcp

nonewfont:
        addq.l  #2,sam
        subq.w  #1,number               ; Dags att flippa bild??
        bne.s   notback                 ; nej
        move.l  buffer,sam              ; Bîrja om vid bufferstart
        move.w  #65,number
notback:
        lea     fontbuffer,a3
        move.l  sam,a0
        lea     128(a0),a1
        subq.l  #2,a0
        lea     farger,a6
        addq.l  #4,fargpek              ; Fixa fontfÑrger
        move.l  fargpek,a5
        cmp.l   #-99,(a5)
        bne.s   norestartofsinus
        move.l  #sinus,fargpek
        lea     sinus,a5
norestartofsinus:
        add.l   (a5),a6
        move.w  #208-1,d0
        lea     bak,a5
        move.w  (a5),((256+8)*0)(a1)    ; LÑgg nÜgra rasters innan fonten
        move.w  (a5)+,((256+8)*0)(a0)   ; bîrjar..
        move.w  (a5),((256+8)*1)(a1)
        move.w  (a5)+,((256+8)*1)(a0)
        move.w  (a5),((256+8)*2)(a1)
        move.w  (a5)+,((256+8)*2)(a0)
        move.w  (a5),((256+8)*3)(a1)
        move.w  (a5)+,((256+8)*3)(a0)
        move.w  (a5),((256+8)*4)(a1)
        move.w  (a5)+,((256+8)*4)(a0)
        lea     ((256+8)*5)(a0),a0
        lea     ((256+8)*5)(a1),a1
col_copy:
        move.w  (a5),(a1)               ; Rensa gammal font
        move.w  (a5)+,(a0)
        asl.w   (a3)+                   ; Ny fÑrg??
        bcc.s   nocol                   ; nej
        move.w  (a6),(a1)               ; Upp med ny fÑrg
        move.w  (a6)+,(a0)
        bra.s   ioio
nocol:  addq.l  #2,a6                   ; Hoppa îver fÑrg
ioio:
        lea     (256+8)(a0),a0          ; NÑsta rad
        lea     (256+8)(a1),a1
        dbra    d0,col_copy             ; 208 gÜnger

        lea     $ff8209,a1              ; Synca proffesorn med videoshiftern
        lea     $37(a1),a0
        clr.w   (a0)
        clr.w   $3(a1)                  ; Ser till att syncrutinen stÑmmer

d40016: move.b  (a1),d0
        bpl.s   d40016
d4001a: move.b  (a1),d0
        bmi.s   d4001a
        cmpi.b  #8,d0
        beq.s   d4003e
        cmpi.b  #6,d0
        beq.s   d40050
        cmpi.b  #4,d0
        beq.s   d40060
        cmpi.b  #2,d0
        beq.s   d4006a
        cmpi.b  #0,d0
        beq.s   d40070
        nop
d4003e: move.w  $20000,$300
        move.w  $20000,$300
        bra.s   d40076
d40050: move.w  $20000,d1
        move.w  $20000,d1
        nop
d4005e: bra.s   d40076
d40060: move.w  $20000,$300
        bra.s   d40076
d4006a: move.w  $300,d1
        bra.s   d40076
d40070: bra.s   d40076
        nop
        nop
d40076:
        move.w  #35,d0                  ; VÑnta tills vi Ñr ute i vÑnster
wwait:  dbra    d0,wwait                ; ram

                                        ; Ok, ladda upp blittern med data
        move.l  sam,$ff8a24             ; Sorce adress
        move.l  #$ff8240,$ff8a32        ; Dest adress
        move.b  #3,$ff8a3b              ; Writing mode
        move.w  #2,$ff8a20              ; Sorce add x (bytes)
        move.w  #A_LINE,$ff8a36         ; X length
        move.w  #208+5,$ff8a38          ; Y length
        move.w  #(A_LINE*2)+10,$ff8a22  ; Sorce add y (bytes)
        move.w  #0,$ff8a2e              ; Dest add x (bytes)
        move.w  #0,$ff8a30              ; Dest add y (bytes)
        move.b  #$80+$40,$ff8a3c        ; Starta blitter
        clr.w   $ff8240                 ; Ingen fÑrg pÜ ramen

        movem.l (sp)+,d0-d7/a0-a6
        rte

blittwait:                              ; VÑnta pÜ att blittern skall
        btst.b  #7,$ff8a3c              ; bli fÑrdig
        bne     blittwait
        rts

err:    illegal                         ; Vid fel, hoppa ur med bomber

        DATA

lag:    dc.w    0
handle: dc.w    0
filnamn:dc.l    0
lasbuffer:
        dc.l    0
laslangd:
        dc.l    0
now:    dc.w    0
sam:    dc.l    0                       ; Pekare till scrollen
number: dc.w    65                      ; ShiftrÑknare
font:   dc.l    0                       ; Fontpekare
counter:dc.w    0                       ; FontrÑknare
buffer: dc.l    0                       ; HÑr hÜlls scrollen (offset 0) och
                                        ; fonten (offset 64000)
weretext:
        dc.l    message                 ; Scrolltexten...
message:dc.b    'VÑlkommen till en STOR scroll, '
        dc.b    'fonten Ñr hela 208 rader hîg!! '
        dc.b    'Den hÑr scrollen Ñr gjord av CHRISTIAN DAHL och kÑllkoden '
        dc.b    'Ñr nu PD.   Anledningen till att jag gjorde den hÑr scrollen '
        dc.b    'var att en av mina Amigakompisar hade skrivit en copper'
        dc.b    'scroll till Amigan. Jag blev inspirerad och sÜ blev det hÑr '
        dc.b    'programmet till. Eftersom STE:n inte har nÜgon copper sÜ '
        dc.b    'anvÑnder jag blittern till att byta fÑrger! Enkelt och snabbt. '
        dc.b    'Fîr att scrolla texten anvÑnder jag en enkel hÜrdvaruscroll... '
        dc.b    'Jag vill tacka MANNE som gjorde scrollen pÜ Amigan, den var '
        dc.b    'snygg!  (Men den hÑr Ñr snyggare och stîrre!!!) '
        dc.b    '    Vill Ni Ñndra pÜ fontens utseende sÜ ladda in filen '
        dc.b    'FONT.DOO i Neochrome sÜ ser Ni hur den Ñr uppbyggd ('
        dc.b    'vanlig ASCII) och ser ut. '
        dc.b    'det Ñr bara att Ñndra i bilden!        Tack och ADJô'
        dc.b    '                                                    '
        dc.b    0

fontnamn:                       ; Fontfilen
        dc.b    'font.doo',0

musav:  dc.b    $12,$1a
muspa:  dc.b    $8

        CNOP    0,4             ; JÑmn adress (motsvarar EVEN)

fargpek:dc.l    sinus
farger:                         ; FontfÑrger
        dc.w    $FFF,$FFE,$FFD,$FFC,$FFB,$FFA,$FF9,$FF8
        dc.w    $FF7,$FF6,$FF5,$FF4,$FF3,$FF2,$FF1,$FF0
        dc.w    $FE1,$FD2,$FC3,$FB4,$FA5,$F96,$F87,$F88
        dc.w    $F79,$F6A,$F5B,$F4C,$F3D,$F2E,$F1F,$F0F
        dc.w    $F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07
        dc.w    $F06,$F05,$F04,$F03,$F02,$F01,$F00,$F00
        dc.w    $E10,$D20,$C30,$B40,$A50,$960,$870,$880
        dc.w    $790,$6A0,$5B0,$4C0,$3D0,$2E0,$1F0,$0F0
        dc.w    $0E1,$0D2,$0C3,$0B4,$0A5,$096,$087,$078
        dc.w    $069,$05A,$04B,$03C,$02D,$01E,$00F,$00F
        dc.w    $01F,$02F,$03F,$04F,$05F,$06F,$07F,$08F
        dc.w    $09F,$0AF,$0BF,$0CF,$0DF,$0EF,$0FF,$0FF
        dc.w    $1FF,$2FF,$3FF,$4FF,$5FF,$6FF,$7FF,$8FF
        dc.w    $9FF,$AFF,$BFF,$CFF,$DFF,$EFF,$EFF,$FFF
        dc.w    $FFF,$FFE,$FFD,$FFC,$FFB,$FFA,$FF9,$FF8
        dc.w    $FF7,$FF6,$FF5,$FF4,$FF3,$FF2,$FF1,$FF0
        dc.w    $FE1,$FD2,$FC3,$FB4,$FA5,$F96,$F87,$F88
        dc.w    $F79,$F6A,$F5B,$F4C,$F3D,$F2E,$F1F,$F0F
        dc.w    $F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07
        dc.w    $F06,$F05,$F04,$F03,$F02,$F01,$F00,$F00
        dc.w    $E10,$D20,$C30,$B40,$A50,$960,$870,$880
        dc.w    $790,$6A0,$5B0,$4C0,$3D0,$2E0,$1F0,$0F0
        dc.w    $0E1,$0D2,$0C3,$0B4,$0A5,$096,$087,$078
        dc.w    $069,$05A,$04B,$03C,$02D,$01E,$00F,$00F
        dc.w    $01F,$02F,$03F,$04F,$05F,$06F,$07F,$08F
        dc.w    $09F,$0AF,$0BF,$0CF,$0DF,$0EF,$0FF,$0FF
        dc.w    $1FF,$2FF,$3FF,$4FF,$5FF,$6FF,$7FF,$8FF
        dc.w    $9FF,$AFF,$BFF,$CFF,$DFF,$EFF,$EFF,$FFF
        dc.w    $FFF,$FFE,$FFD,$FFC,$FFB,$FFA,$FF9,$FF8
        dc.w    $FF7,$FF6,$FF5,$FF4,$FF3,$FF2,$FF1,$FF0
        dc.w    $FE1,$FD2,$FC3,$FB4,$FA5,$F96,$F87,$F88
        dc.w    $F79,$F6A,$F5B,$F4C,$F3D,$F2E,$F1F,$F0F
        dc.w    $F0E,$F0D,$F0C,$F0B,$F0A,$F09,$F08,$F07
        dc.w    $F06,$F05,$F04,$F03,$F02,$F01,$F00,$F00
        dc.w    $E10,$D20,$C30,$B40,$A50,$960,$870,$880
        dc.w    $790,$6A0,$5B0,$4C0,$3D0,$2E0,$1F0,$0F0
        dc.w    $0E1,$0D2,$0C3,$0B4,$0A5,$096,$087,$078
        dc.w    $069,$05A,$04B,$03C,$02D,$01E,$00F,$00F
        dc.w    $01F,$02F,$03F,$04F,$05F,$06F,$07F,$08F
        dc.w    $09F,$0AF,$0BF,$0CF,$0DF,$0EF,$0FF,$0FF
        dc.w    $1FF,$2FF,$3FF,$4FF,$5FF,$6FF,$7FF,$8FF
        dc.w    $9FF,$AFF,$BFF,$CFF,$DFF,$EFF,$EFF,$0FF
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

                        ; Bakraster
bak:    dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.l    $011,$022,$033,$044,$055,$044,$033,$022,$011
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000
        dc.w    $000,$000,$000,$000,$000,$000,$000,$000,$000,$000,$000

sinus:                  ; FÑrg"sinus"
        dc.l    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
        dc.l    21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40
        dc.l    39,38,37,36,35,34,33,32,31,30,29,28,27,26,25,24,23,22,21
        dc.l    20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0
        dc.l    -99,-99

text_tabell:            ; Data îver var fonten ligger i .DOO-filen
        dc.w    0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
        dc.w    0+2560,8+2560,16+2560,24+2560,32+2560,40+2560,48+2560,56+2560,64+2560,72+2560,80+2560
        dc.w    88+2560,96+2560,104+2560,112+2560,120+2560,128+2560,136+2560,144+2560,152+2560
        dc.w    0+5120,8+5120,16+5120,24+5120,32+5120,40+5120,48+5120,56+5120,64+5120,72+5120,80+5120
        dc.w    88+5120,96+5120,104+5120,112+5120,120+5120,128+5120,136+5120,144+5120,152+5120
        dc.w    0+7680,8+7680,16+7680,24+7680,32+7680,40+7680,48+7680,56+7680,64+7680,72+7680,80+7680
        dc.w    88+7680,96+7680,104+7680,112+7680,120+7680,128+7680,136+7680,144+7680,152+7680
        dc.w    0+10240,8+10240,16+10240,24+10240,32+10240,40+10240,48+10240,56+10240,64+10240,72+10240,80+10240
        dc.w    88+10240,96+10240,104+10240,112+10240,120+10240,128+10240,136+10240,144+10240,152+10240
        dc.w    0+12800,8+12800,16+12800,24+12800,32+12800,40+12800,48+12800,56+12800,64+12800,72+12800,80+12800
        dc.w    88+12800,96+12800,104+12800,112+12800,120+12800,128+12800,136+12800,144+12800,152+12800
        dc.w    0+15360,8+15360,16+15360,24+15360,32+15360,40+15360,48+15360,56+15360,64+15360,72+15360,80+15360
        dc.w    88+15360,96+15360,104+15360,112+15360,120+15360,128+15360,136+15360,144+15360,152+15360
        dc.w    0+17920,8+17920,16+17920,24+17920,32+17920,40+17920,48+17920,56+17920,64+17920,72+17920,80+17920
        dc.w    88+17920,96+17920,104+17920,112+17920,120+17920,128+17920,136+17920,144+17920,152+17920
        dc.w    0+20480,8+20480,16+20480,24+20480,32+20480,40+20480,48+20480,56+20480,64+20480,72+20480,80+20480
        dc.w    88+20480,96+20480,104+20480,112+20480,120+20480,128+20480,136+20480,144+20480,152+20480
        dc.w    0+23040,8+23040,16+23040,24+23040,32+23040,40+23040,48+23040,56+23040,64+23040,72+23040,80+23040
        dc.w    88+23040,96+23040,104+23040,112+23040,120+23040,128+23040,136+23040,144+23040,152+23040
        dc.w    0+25600,8+25600,16+25600,24+25600,32+25600,40+25600,48+25600,56+25600,64+25600,72+25600,80+25600
        dc.w    88+25600,96+25600,104+25600,112+25600,120+25600,128+25600,136+25600,144+25600,152+25600
        dc.w    0+28160,8+28160,16+28160,24+28160,32+28160,40+28160,48+28160,56+28160,64+28160,72+28160,80+28160
        dc.w    88+28160,96+28160,104+28160,112+28160,120+28160,128+28160,136+28160,144+28160,152+28160
        dc.w    0+30720,8+30720,16+30720,24+30720,32+30720,40+30720,48+30720,56+30720,64+30720,72+30720,80+30720
        dc.w    88+30720,96+30720,104+30720,112+30720,120+30720,128+30720,136+30720,144+30720,152+30720

fontbuffer:             ; HÑr hamnar en bokstav nÑr den har blivit omskalad

        ds.w    2*16
        ds.w    512

        END
