*****************************
*
*   Blitter direkt
*
*   programmierung !
*
*****************************

;drÅcken einer beliebigen Taste scrollen um 31 Pixel
;drÅcken von SPACE = QUIT

                move.w  #4,-(SP)        ;getrez
                trap    #14
                addq.l  #2,(SP)
                move.l  D0,oldrez

                move.l  #0,D1
                jsr     setscreen(PC)

                pea     palette(PC)
                move.w  #6,-(SP)        ;Setpalette
                trap    #14
                addq.l  #6,SP

                lea     puffer(PC),A5


                move.l  #3999,D0

kopf:

                lea     muster(PC),A1
                move.l  (A1)+,(A5)+
                move.l  (A1)+,(A5)+

                dbra    D0,kopf

blitit:         pea     init(PC)
                move.w  #$26,-(SP)
                trap    #14
                addq.l  #6,-(SP)

                move.l  #$020002,-(SP)  ;Warte auf Tastendruck
                trap    #13
                addq.l  #4,-(SP)
                cmp.b   #32,D0
                bne.s   blitit

                move.l  oldrez(PC),D1
                jsr     setscreen(PC)


                clr.w   -(SP)           ;QUIT
                trap    #1


setscreen:                              ;XBIOS 5

                move.w  D1,-(SP)
                move.l  #-1,-(SP)
                move.l  #-1,-(SP)
                move.w  #5,-(SP)
                trap    #14
                lea     12(SP),SP

                rts
init:

                move.w  #2,-(SP)        ;logbase
                trap    #14
                addq.l  #2,SP

                movea.l D0,A6
                lea     puffer(PC),A5


**** Initialisierung des Blitters


;Quellparameter

                move.w  #8,$FFFF8A20.w
                clr.w   $FFFF8A22.w

;Bitmanipulation (MASKE)

                move.w  #%1111111111111111,$FFFF8A28.w
                move.w  #%1111111111111111,$FFFF8A2A.w
                move.w  #%1111111111111111,$FFFF8A2C.w

;Zielparameter

                move.w  #8,$FFFF8A2E.w
                clr.w   $FFFF8A30.w

;Abbruchparameter

                move.w  #20,$FFFF8A36.w
                move.b  #2,$FFFF8A3A.w
                move.b  #3,$FFFF8A3B.w




                move.b  #30,D3

scroll:                                 ;scrolling

                move.l  #7,D1
                move.l  D3,D4
                sub.b   15,D4
                or.b    #%11000000,D4


planes:                                 ;kopieren der vier Planes

                move.w  D1,D2
                ext.l   D2
                add.l   D2,D2
                move.l  A5,D5
                add.l   D2,D5
                move.l  A6,D6
                add.l   D2,D6

                move.w  #199,$FFFF8A38.w ;Zeilenanzahl
                move.l  D5,$FFFF8A24.w  ;Adresse Quelle
                move.l  D6,$FFFF8A32.w  ;Adresse Ziel
                move.b  D4,$FFFF8A3D.w  ;SKEW (Bitverschieben)
                move.b  #%11000000,$FFFF8A3C.w ;START und nur der Blitter

                dbra    D1,planes

                dbra    D3,scroll

                rts

oldrez:
                DS.L 1

muster:
                DC.W %1010101010101010,%1100110011001100
                DC.W %1111000011110000,%1111111000000000

palette:        DC.W $0100,$0201,$0301,$0402,$0502,$0603,$0703,$0604,$0605,$0505,$0506
                DC.W $0407,$0417,$0427,$0437,$0447,$0457

puffer:
                DS.L 8000

                END
