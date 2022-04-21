     ;** Sous-programme BASIC : Routines de formattage  S.D. **

run:
     move    4(sp),d0
     cmp     #4,d0            ;4 Parametre ?
     bne     quit             ;non => Fin
     move.l  6(sp),a5         ;Pointeur sur Parameterbloc

     lea     faces(pc),a4
     move.l  (a5)+,d1
     move    d1,(a4)          ;Faces
     move.l  (a5)+,d1
     move    d1,2(a4)         ;Tracks
     move.l  (a5)+,d1
     move    d1,4(a4)         ;Sectors pro Track
     move.l  (a5)+,d1
     move    d1,6(a4)         ;Numero de lecteur

     move    tracks(pc),8(a4)
     subq    #1,8(a4)

floop:
     move    faces(pc),10(a4) ;D‚terminer les faces
floop1:
     bsr     fmttr            ;format Track
     bne     quit
     sub     #1,10(a4)        ;Face -1
     bpl     floop1
     sub     #1,8(a4)
     bpl     floop            ;Piste suivante

setboot:
     clr     -(sp)            ;Execute-Flag
     moveq   #2,d0
     or      faces(pc),d0
     move    d0,-(sp)         ;Disktyp, face
     move.l  #$1000000,-(sp)  ;Cr‚er num‚ro de s‚rie
     pea     12(a4)           ;buffer-Adress
     move    #$12,-(sp)
     trap    #14              ;Cr‚er le Boot-Sector 
     add.l   #14,sp

     lea     12(a4),a0
     clr.l   d0
     cmp     #9,4(a4)         ;9 Secteurs par piste ?
     beq     sok              ;oui
     move.b  #10,24(a0,d0)    ;Mettre 10 SPT 
     move    tracks(pc),d1
     tst     (a4)             ;1 face ?
     beq     sd11             ;oui
     lsl     #1,d1            ;Sinon doubler 
sd11:
     bsr     addsec           ;SEC + nombre de pistes

sok:
     cmp     #80,2(a4)        ;80 Tracks ?
     beq     trok
     move    #18,d1
     tst     (a4)             ;1 face ?
     beq     sd12             ;oui
     lsl     #1,d1            ;Sinon doubler
sd12:
     bsr     addsec           ;SEC + 2*9 ou 4*9

trok:
     move    #1,-(sp)         ;1 Secteur
     clr.l   -(sp)            ;Face 0, Track 0
     move    #1,-(sp)         ;Secteur 1
     move    drive(pc),-(sp)  ;Lecteur
     clr.l   -(sp)
     pea     12(a4)           ;Tampon
     move    #9,-(sp)
     trap    #14              ;flopwr
     add.l   #20,sp

quit: rts                     ;Retour au BASIC

addsec:                       ;SEC = SEC + D1
     move.b  20(a0,d0),d2     ;HI
     lsl     #8,d2
     move.b  19(a0,d0),d2     ;LO
     add     d1,d2
     move.b  d2,19(a0,d0)     ;set LO
     lsr     #8,d2
     move.b  d2,20(a0,d0)     ;set HI
     rts

fmttr:                        ;Formattage d'une piste
     clr     -(sp)            ;Donn‚es vierges
     move.l  #$87654321,-(sp) ;Nombre magique
     move    #1,-(sp)         ;interleave
     move    face(pc),-(sp)  ;Seite
     move    tracks1(pc),-(sp) ;Track
     move    secptr(pc),-(sp) ;Sectors/Track
     move    drive(pc),-(sp)  ;Lecteur
     clr.l   -(sp)
     pea     12(a4)
     move    #10,-(sp)
     trap    #14              ;flopfmt
     add.l   #26,sp
     tst     d0               ;Test si erreur
     rts

faces:  dc.w 1
tracks:  dc.w 80
secptr:  dc.w 9
drive:   dc.w 0
tracks1: dc.w 80
face:   dc.w 0
tampon:  dc.b $200
