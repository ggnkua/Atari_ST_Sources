* Programm zum Abspielen zweier DMA Sounds auf je einem Kanal.
* fÅr Argon 4

********* benutzte Adressen und ihre "Namen"

dmabasis        EQU $FFFF8900
dmafreq         EQU $FFFF8920

inp_key         EQU $020002
superexec       EQU $26
xbtimer         EQU $1F0000
tim_d_c         EQU $080001     ;timer A im EVENT COUNT an


tadr            EQU $FFFFFA1F
tacr            EQU $FFFFFA19
isra            EQU $FFFFFA0F



** Voreinstellung von adr1 und adr2

start:          lea     adr1(PC),A0
                lea     puffer1(PC),A1
                move.l  A1,(A0)+
                move.l  A1,(A0)

** Timer A an mit XBIOS 31

                pea     fÅller(PC)
                move.l  #tim_d_c,-(SP)
                move.l  #xbtimer,-(SP)
                trap    #14
                lea     12(SP),SP


** DMA Soundchip anschalten
                pea     dma_init(PC)
                move.w  #superexec,-(SP) ;fÅhrt Routiene im Supervisormode durch
                trap    #14
                addq.l  #6,SP


                rts

*** initialisiert Sound je nach Kanal

init:


                lea     adr1(PC),A0
                move.l  D6,0(A0,D5.w)



                rts

** Anschalten des DMA Sound - Chips 12.5 Khz Stereo

dma_init:

****** Initiallisiert DMA Soundchip

                lea     puffer(PC),A2
                lea     puffer1(PC),A1
                move.l  A1,(A2)
                move.l  A1,D0
                lea     dmabasis.w,A2
                move.l  D0,-(SP)
                move.w  (SP),2(A2)
                move.w  1(SP),4(A2)
                move.w  2(SP),6(A2)
                addq.l  #4,SP
                add.l   #2048,D0
                move.l  D0,-(SP)
                move.w  (SP),14(A2)
                move.w  1(SP),16(A2)
                move.w  2(SP),18(A2)
                addq.l  #4,SP
                move.w  #%1,$20(A2)     ;12.5 kHz - Stereo
                ori.w   #%11,dmabasis.w ;DMA - an

                rts

************************************************
*      fÅllt die Puffer fÅr den DMA Soundchip  *
************************************************

;********** Register und ihre Verwendung

;A0,A1 Zeiger auf 1.u.2. Sample
;A2    Zeiger auf den Puffer
;D0    Zwischen Speicher der Sampledaten zur Åbertragung mit MOVEP
;D1    ZÑhler fÅr die Schleifen


fÅller:

                move    #$2300,SR
                movem.l D0-D1/A0-A2,-(SP) ;rette Register


                lea     puffer(PC),A0
                movea.l (A0),A2

*** wechselt auf jetzt zu fÅllenden Puffer


                lea     puffer2(PC),A1
                cmpa.l  A2,A1
                bne.s   over
                lea     puffer1(PC),A1
over:           move.l  A1,(A0)

***

                subq.l  #8,A2           ;abziehen, was spÑter dazu gezÑhlt wird

                movea.l adr1(PC),A0
                movea.l adr2(PC),A1

                moveq   #127,D1         ;  ZÑhler auf 128 mal



** fÅllt beide KanÑle mit Samples

loop1_2:

                addq.l  #8,A2
                move.l  (A0)+,D0
                beq.s   l_aus           ;springe falls 0 in D0
                movep.l D0,0(A2)        ;Puffer fÅllen rechts
                move.l  (A1)+,D0
                movep.l D0,1(A2)        ;puffer fÅllen links
                dbeq    D1,loop1_2
                beq.s   r_aus           ;springe falls 0 in D1

                bra.s   out

** fÅllt rechten Kanal des Puffers mit Sample

r_aus:
                lea     puffer3(PC),A1
                subq.l  #8,A2

rechts:         addq.l  #8,A2           ;Zeiger auf Puffer erhîhen
                clr.l   (A2)
                clr.l   4(A2)
                move.l  (A0)+,D0
                movep.l D0,0(A2)
                dbeq    D1,rechts
                bne.s   out

                bra.s   dma_aus


** fÅllt linkem Kanal des Puffer mit Sample

l_aus:
                lea     puffer3(PC),A0
                subq.l  #8,A2
links:
                addq.l  #8,A2
                clr.l   (A2)
                clr.l   4(A2)
                move.l  (A1)+,D0
                movep.l D0,1(A2)
                dbeq    D1,links
                bne.s   out             ; falls Inhalt 0

**********************************************

dma_aus:
                clr.l   (A2)+
                clr.l   (A2)+
                dbra    D1,dma_aus
                lea     puffer3(PC),A1  ;beide KanÑle aus
                lea     puffer3(PC),A0  ;" " " " " " " "


out:
**** DMA CHIP auf gefÅllten Puffer

                lea     puffer(PC),A2
                move.l  (A2),D0
                lea     dmabasis.w,A2
                move.l  D0,-(SP)
                move.w  (SP),2(A2)
                move.w  1(SP),4(A2)
                move.w  2(SP),6(A2)
                addq.l  #4,SP
                add.l   #1024,D0
                move.l  D0,-(SP)
                move.w  (SP),14(A2)
                move.w  1(SP),16(A2)
                move.w  2(SP),18(A2)
                addq.l  #4,SP


                lea     adr1(PC),A2
                move.l  A0,(A2)         ;Sample Leseadresse zurÅckschreiben
                move.l  A1,4(A2)        ;" " " " " " " " " " " " " " " " "
                movem.l (SP)+,D0-D1/A0-A2

                rte


adr1:           DS.L 1
adr2:           DS.L 1
puffer:         DS.L 1
puffer1:        DS.B 1024
puffer2:        DS.B 1024
puffer3:        DS.L 1

                END
