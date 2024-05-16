;
;       Ingen ram till v„nster eller till h”ger och ingen l†gram.
;       Endast den ”vre „r kvar!
;
;
;       Programmet „r skrivet f”r STe. Anv„nder sig av STens f„rger
;       och extra videofunktioner. ($ff8264,$ff820e,$ff820d, samt att
;       man kan skriva till adresserna $ff8205,$ff8207 och $ff8209)
;       Kan omarbetas s† att det fungerar p† en ST.
;
;       Skriven f”r METACOMCO's MACRO ASSEMBLER men b”r kunna assembleras
;       av andra assemblatorer utan st”rre omarbetningar...
;
;       Koden skriven av:
;                               Christian Dahl
;                               Fotbollsv„gen 11
;                               735 37  Surahammar
;                               Sweden
;
;
;
;       Tekniken f”r att kunna ta bort h”ger och v„nster-ramarna „r
;       enkel att f”rklara men sv†r att f† att fungera i praktiken.
;
;       Det h„r programmet v„ntar in rastret och syncar in CPUn med
;       videoshiftern. Sedan v„ntar CPUn in rastret till det har kommit
;       till v„nsterbordern. D† h”jer CPUn rastrets svepfrekvens till
;       70 Hz och sedan tillbaka till 50 Hz. D† f”rsvinner v„nsterramen.
;       Sedan v„ntar CPUn in tills rastret har kommit h”gerramen. D†
;       h”jer den svepfrekvensen till 60 Hz och tillbaka till 50 Hz.
;       D† f”rsvinner h”gerramen. S† h†ller CPUn p† tills den har n†tt
;       sista rasterraden innan den l„gre bordern. N„r rastret har
;       kommit till v„nsterramen d„r s† ”kas svepfrekvensen till 60->
;       70->60->50 Hz. Denna procedur „r till f”r att ta bort v„nster
;       ramen och den nedre ramen. Sedan forts„tter programmet med
;       tidigare utf”rt schema f”r att ta bort fortsatta h”ger och
;       v„nsterramar.
;

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
        trap    #1                      ; Allocera minne till programmet
        add.l   #12,sp

        move.l  #350*576,-(sp)
        move.w  #$48,-(sp)
        trap    #1                      ; Beg„r minne f”r overscanbilden
        addq.l  #6,sp
        tst.l   d0
        bmi     fel
        move.l  d0,bildminne
        move.l  #32000,-(sp)
        move.w  #$48,-(sp)
        trap    #1                      ; Beg„r minne f”r bilden
        addq.l  #6,sp
        tst.l   d0
        bmi     fel
        move.l  d0,bild

        move.l  #32000,laslangd
        move.l  bild,lasbuffer
        move.l  #namn,filnamn
        bsr     ladda                   ; Ladda bild

        move.l  bild,a0
        move.l  bildminne,a1
        add.l   #118+350*119,a1
        move.l  a1,a2                   ; Fixa till overscanbilden
        move.w  #200-1,d0
yfixa:  move.w  #(160/4)-1,d1
xfixa:  move.l  (a0)+,(a1)+
        dbra    d1,xfixa
        lea     350(a2),a2
        move.l  a2,a1
        dbra    d0,yfixa

        lea     sinuskurva,a0
sinusloop:                              ; R„kna om sinuskurvan
        move.w  (a0),d0
        cmp.w   #-200,d0
        beq.s   slutpasinus
        add.w   #130,d0
        move.w  d0,(a0)+
        bra     sinusloop
slutpasinus:

        clr.l   -(sp)
        move.w  #$20,-(sp)
        trap    #1                      ; Supermode
        addq.l  #6,sp
        move.l  d0,-(sp)

        move.w  $484,-(sp)
        clr.b   $484

        LEA     $FF8205,A5            ; Ste ??????
        MOVEQ   #-1,D1
        MOVE.B  (A5),D0
        MOVE.B  D1,(A5)
        CMP.B   (A5),D0
        BEQ     fel
        MOVE.B  D0,(a5)

        move.w  #4,-(sp)
        trap    #14                     ; Uppl”sning ??
        addq.l  #2,sp
        move.w  d0,-(sp)

        move.w  #2,-(sp)
        trap    #14                     ; Fysikaliskt bildminne ??
        addq.l  #2,sp
        move.l  d0,-(sp)
        move.l  d0,picmem

        lea     $ff8240,a0              ; Kom ih†g gamla f„rger
        lea     sexton,a1
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        lea     $ff8240,a0
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+

        move.w  #2,-(sp)
        trap    #14                     ; Logiskt bildminne ??
        addq.l  #2,sp
        move.l  d0,-(sp)

        move.w  $ff820a,-(sp)           ; Sync ??
        move.l  $70,-(sp)               ; Kom ih†g vbl
        move.l  $118,-(sp)              ; Kom ih†g tangbordsinterupt

        clr.w   -(sp)
        move.l  bildminne,-(sp)
        move.l  bildminne,-(sp)
        move.w  #5,-(sp)
        trap    #14
        lea     12(sp),sp

        move.l  #ingenmusjoy,-(sp)
        move.w  #1,-(sp)
        move.w  #25,-(sp)
        trap    #14                     ; Ingen mus
        addq.l  #8,sp
        and.b   #%10001111,$fffa09      ; Ingen timer C & D och inget tang.bord

        move.w  #$07ff,$ff8924
        jsr     wait_for_finish
        move.w  #%0000010001001000,$ff8922      ; +4db bas
        jsr     wait_for_finish
        move.w  #%0000010010001001,$ff8922      ; +6db diskant
        jsr     wait_for_finish
        move.w  #%0000010011101000,$ff8922      ; -0db mastervolyme
        jsr     wait_for_finish
        move.w  #%0000010000000010,$ff8922      ; Don't mix Gi sound chip

        move.l  #vbl,$70
        bset    #6,$fffa09              ; Tangentbord p†

loopa:
        move.w  #1,-(sp)
        trap    #1                      ; VŽNTA
        addq.l  #2,sp

        clr.w   $ff8900
        move.w  #13,-(sp)
        move.w  #26,-(sp)
        trap    #14                     ; Bort med timer A
        addq.l  #4,sp
        move.w  #8,-(sp)
        move.w  #26,-(sp)
        trap    #14                     ; Bort med timer B
        addq.l  #4,sp

        move.l  (sp)+,$118              ; Gammal tangbordsinterupt
        move.l  (sp)+,$70               ; Gammal vbl
        or.b    #%01110000,$fffa09      ; Timer C & D och tang.bord ig†ng
        move.l  #musjoy,-(sp)
        move.w  #1,-(sp)
        move.w  #25,-(sp)
        trap    #14                     ; S„tt p† mus igen
        addq.l  #8,sp
        move.w  (sp)+,$ff820a           ; Gammal sync
        clr.w   $ff820c                 ; Ingen low
        clr.w   $ff820e                 ; Ingen offset
        clr.w   $ff8264                 ; Ingen horisontalf”rskjutning

        move.w  #5,-(sp)
        trap    #14                     ; R„tt uppl”sning
        lea     12(sp),sp

        move.w  #$07ff,$ff8924
        jsr     wait_for_finish
        move.w  #%0000010001000110,$ff8922      ; +0db bas
        jsr     wait_for_finish
        move.w  #%0000010010000110,$ff8922      ; +0db diskant
        jsr     wait_for_finish
        move.w  #%0000010011101000,$ff8922      ; -0db mastervolyme
        jsr     wait_for_finish
        move.w  #%0000010000000001,$ff8922      ; Mix Gi sound chip

        move.w  (sp)+,$484

        lea     $ff8240,a1              ; Ladda upp gamla f„rger
        lea     sexton,a0
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+

        move.l  #$C0DE,$42a             ; Ingen mer resetrutin
        move.l  #$C0DE,$426

        move.w  #$20,-(sp)
        trap    #1                      ; Usermode
        addq.l  #6,sp


        clr.w   -(sp)
        trap    #1                      ; Avsluta !!!!
fel:    illegal

wait_for_finish:
        cmp.w   #$07ff,$ff8924
        bne.s   wait_for_finish
        rts

ladda:  clr.w   -(sp)
        move.l  filnamn,-(sp)
        move.w  #$3d,-(sp)
        trap    #1                      ; ™ppna fil
        addq.l  #8,sp
        tst.l   d0
        bmi     fel
        move.w  d0,handle

        move.l  lasbuffer,-(sp)
        move.l  laslangd,-(sp)
        move.w  handle,-(sp)
        move.w  #$3f,-(sp)
        trap    #1                      ; L„s fil
        lea     12(sp),sp
        cmp.l   laslangd,d0
        bne     fel

        move.w  handle,-(sp)
        move.w  #$3e,-(sp)
        trap    #1                      ; St„ng fil
        addq.l  #4,sp
        rts

vbl:
        movem.l d0-d7/a0-a6,-(sp)

        add.l   #2,fargpek
        subq.w  #1,fargflipp            ; Scroll rasterbalkarna
        bgt.s   intedaxattflippafarger
        move.w  #32,fargflipp
        move.l  #farger,fargpek
intedaxattflippafarger:

        move.l  bildminne,d0
        move.l  ypek,a0
        tst.w   (a0)                    ; Addera ysinus till bildpekaren
        bge.s   ejslutpasinusfory
        lea     sinuskurva,a0
        move.l  a0,ypek
ejslutpasinusfory:
        move.w  (a0),d1
        addq.l  #2,ypek
        mulu    #350,d1
        add.l   d1,d0
        move.l  xpek,a0
        tst.w   (a0)                    ; Addera xsinus till bildpekaren
        bge.s   ejslutpasinusforx
        lea     sinuskurva,a0
        move.l  a0,xpek
ejslutpasinusforx:
        move.w  (a0),d1
        addq.l  #2,xpek
        move.w  d1,d2
        and.l   #$FFF0,d1
        lsr.w   #1,d1
        add.l   d1,d0
        and.w   #$F,d2
        move.w  d2,delay
        bne.s   ejnoll
        move.w  #60,delay+2
        subq.l  #6,d0                   ; Magisk konstant
        bra     varnoll
ejnoll: move.w  #60-1,delay+2
varnoll:
        move.l  d0,dummybild            ; Bildminnet som kommer att visas

        moveq   #0,d7
        move.l  #198-1,d4               ; Antal rader innan det „r dax att
                                        ; sl† s”nder l†gbordern
        moveq   #38,d3                  ; Antal rader i l†gbordern
        lea     delay,a5                ; Pekaren till delay och sk„rmoffset
        lea     bildfarger,a4           ; Pekare till paletten
        lea     dummybild,a6            ; Pekare till det nya bildminne
        move.w  #$8200,a3               ; Pekare till videoshiftern
        move.l  (a4)+,$40(a3)           ; Ladda nya f„rger
        move.l  (a4)+,$44(a3)
        move.l  (a4)+,$48(a3)
        move.l  (a4)+,$4c(a3)
        move.l  (a4)+,$50(a3)
        move.l  (a4)+,$54(a3)
        move.l  (a4)+,$58(a3)
        move.l  (a4)+,$5c(a3)
        move.l  fargpek,a4              ; Pekare till rasterf„rgerna
        move.b  epek+1,$05(a3)          ; Tomt bildminne f”rst
        move.b  epek+2,$07(a3)
        clr.b   $09(a3)                 ; Se till att syncrutinen fungerar
        clr.w   $0e(a3)                 ; Ingen sk„rmoffset
        clr.w   $64(a3)                 ; Ingen delay
        move.w  #$2700,sr               ; Inga andra interupter
        move.w  #$8209,a1
d40016: move.b  (a1),d0
        bpl.s   d40016                  ; Synca CPUn med videoshiftern
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
        move.w  (a5),$64(a3)    ; Ny delay
        move.w  2(a5),$0e(a3)   ; Ny sk„rmoffset
        move.b  1(a6),$05(a3)   ; Nytt bildminne
        move.b  2(a6),$07(a3)
        move.b  3(a6),$09(a3)

eee:
        nop
        nop
        nop
        nop
        nop
        nop
        move.w  (a4)+,$40(a3)   ; Ny rasterf„rg
        move.b  #2,$60(a3)      ; 70 Hz         Sl† s”nder v„nster ram
        move.b  #0,$60(a3)      ; 50 Hz

        moveq   #27,d0
waitsomemore:                   ; V„nta till h”gerbordern
        dbra    d0,waitsomemore

        move.b  #0,$0A(a3)      ; 60 Hz         Ingen h”ger ram
        move.b  #2,$0A(a3)      ; 50 Hz
        nop
        nop

        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        dbra    d4,eee          ; Loopa de f”rsta 198 raderna
        move.b  #0,$0A(a3)      ; 60 Hz
        nop
        nop
        nop


        move.b  #2,$ff8260      ; 70 Hz         Sl† s”nder v„nster ram
        move.b  #0,$ff8260      ; 60 Hz         och nedre bordern
        move.w  (a4)+,$40(a3)   ; Ny rasterf„rg
        nop
        move.b  #2,$0A(a3)      ; 50 Hz

        moveq   #23,d0
dfgkkf: dbra    d0,dfgkkf       ; V„nta till h”gerbordern

        nop
        nop
        nop
        move.b  #0,$0A(a3)      ; 60 Hz
        move.b  #2,$0A(a3)      ; 50 Hz
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
eee2:
        move.w  (a4)+,$40(a3)   ; Ny rasterf„rg
        move.b  #2,$ff8260      ; 70 Hz         Sl† s”nder v„nster ram
        move.b  #0,$ff8260      ; 50 Hz

        nop
        moveq   #26,d0
waitsomemoreagain:              ; V„nta till h”gerbordern
        dbra    d0,waitsomemoreagain

        nop
        nop
        move.b  #0,$0A(a3)      ; 60 Hz         Ingen h”ger ram
        move.b  #2,$0A(a3)      ; 50 Hz
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        nop
        dbra    d3,eee2         ; Loopa de resterande 38 raderna
        move.b  epek+1,$ff8205  ; Tomt bildminne
        move.b  epek+2,$ff8207
        move.b  epek+3,$ff8209
        clr.w   $ff820e         ; ingen offset till n„sta rad
        clr.w   $ff8264         ; Ingen delay
        move.w  #$2300,sr       ; Interupter till†tna

        movem.l (sp)+,d0-d7/a0-a6
        rte

dummybild:
        dc.l    0               ; Pekare till tillf„lligt bildminne
bild:   dc.l    0               ; Pekare till inladdad bild
handle: dc.w    0               ; Filhandle
filnamn:dc.l    0               ; Filnamnpekare
lasbuffer:
        dc.l    0               ; L„sbufferpekare
laslangd:
        dc.l    0               ; L„sl„ngd
picmem: dc.l    0               ; Pekare till gammalt bildminne
delay:  dc.w    0               ; Delay   ($ff8264)
        dc.w    0               ; Sk„rmoffset   ($ff820e)
bildminne:
        dc.l    0               ; Pekare till overscanbilden
epek:   dc.l    empty           ; Pekare till tomt bildminne
        dcb.b   256,0
empty:                          ; Tomt bildminne
        dcb.b   6*238,0

sexton: ds.w    16              ; Gamla f„rger

bildfarger:                     ; Bildf„rger
        dc.w    $0000,$0403,$0B8B,$0314,$0A9C,$0225,$0235,$09BD
        dc.w    $0146,$08CE,$0057,$0999,$0333,$0CCC,$0666,$0FFF

fargpek:dc.l    farger          ; Pekare till rasterf„rgerna
fargflipp:
        dc.w    0               ; Variabel som styr scrollningen av rasterna
farger:                         ; Rasterf„rger
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000
        dc.w    $000,$808,$101,$909,$202,$a0a,$303,$b0b
        dc.w    $404,$c0c,$505,$d0d,$606,$e0e,$707,$f0f
        dc.w    $f0f,$707,$e0e,$606,$d0d,$505,$c0c,$404
        dc.w    $b0b,$303,$a0a,$202,$909,$101,$808,$000

xpek:   dc.l    sinuskurva      ; Xcordinatens pekare till sinustabellen
ypek:   dc.l    sinuskurva+64*2 ; Ycordinatens pekare till sinustabellen
sinuskurva:                     ; Sinuskruva
        dc.w    $00,$03,$06,$09,$0C,$0F,$12,$15
        dc.w    $18,$1B,$1E,$21,$24,$27,$2A,$2D
        dc.w    $30,$33,$36,$39,$3B,$3E,$41,$43
        dc.w    $46,$49,$4B,$4E,$50,$52,$55,$57
        dc.w    $59,$5B,$5E,$60,$62,$64,$66,$67
        dc.w    $69,$6B,$6C,$6E,$70,$71,$72,$74
        dc.w    $75,$76,$77,$78,$79,$7A,$7B,$7B
        dc.w    $7C,$7D,$7D,$7E,$7E,$7E,$7E,$7E
        dc.w    $7E,$7E,$7E,$7E,$7E,$7E,$7D,$7D
        dc.w    $7C,$7B,$7B,$7A,$79,$78,$77,$76
        dc.w    $75,$74,$72,$71,$70,$6E,$6C,$6B
        dc.w    $69,$67,$66,$64,$62,$60,$5E,$5B
        dc.w    $59,$57,$55,$52,$50,$4E,$4B,$49
        dc.w    $46,$43,$41,$3E,$3B,$39,$36,$33
        dc.w    $30,$2D,$2A,$27,$24,$21,$1E,$1B
        dc.w    $18,$15,$12,$0F,$0C,$09,$06,$03
        dc.w    $00,$FFFD,$FFFA,$FFF7,$FFF4,$FFF1,$FFEE,$FFEB
        dc.w    $FFE8,$FFE5,$FFE2,$FFDF,$FFDC,$FFD9,$FFD6,$FFD3
        dc.w    $FFD0,$FFCD,$FFCA,$FFC7,$FFC5,$FFC2,$FFBF,$FFBD
        dc.w    $FFBA,$FFB7,$FFB5,$FFB2,$FFB0,$FFAE,$FFAB,$FFA9
        dc.w    $FFA7,$FFA5,$FFA2,$FFA0,$FF9E,$FF9C,$FF9A,$FF99
        dc.w    $FF97,$FF95,$FF94,$FF92,$FF90,$FF8F,$FF8E,$FF8C
        dc.w    $FF8B,$FF8A,$FF89,$FF88,$FF87,$FF86,$FF85,$FF85
        dc.w    $FF84,$FF83,$FF83,$FF82,$FF82,$FF82,$FF82,$FF82
        dc.w    $FF82,$FF82,$FF82,$FF82,$FF82,$FF82,$FF83,$FF83
        dc.w    $FF84,$FF85,$FF85,$FF86,$FF87,$FF88,$FF89,$FF8A
        dc.w    $FF8B,$FF8C,$FF8E,$FF8F,$FF90,$FF92,$FF94,$FF95
        dc.w    $FF97,$FF99,$FF9A,$FF9C,$FF9E,$FFA0,$FFA2,$FFA5
        dc.w    $FFA7,$FFA9,$FFAB,$FFAE,$FFB0,$FFB2,$FFB5,$FFB7
        dc.w    $FFBA,$FFBD,$FFBF,$FFC2,$FFC5,$FFC7,$FFCA,$FFCD
        dc.w    $FFD0,$FFD3,$FFD6,$FFD9,$FFDC,$FFDF,$FFE2,$FFE5
        dc.w    $FFE8,$FFEB,$FFEE,$FFF1,$FFF4,$FFF7,$FFFA,$FFFD
        dc.w    -200,-200

namn:   dc.b    'noborder.doo',0        ; Bildfilens namn

ingenmusjoy:
        dc.b    $12,$1a
musjoy: dc.b    $8,0

        END                             ; Slut!
