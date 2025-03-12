;================================================
;                               Nearly-True-Color
;================================================
;(c)1994 by MAXON-Computer
;Autor: Mark Fechtner
;Dieses Listing ist Quick&Dirty, und erhebt
;keinerlei Anspruch auf irgendeine Konforme
;Programmierung.

  pea     0.w           ; Supervisormode an
  move.w  #$20,-(SP)
  trap    #1
  addq.w  #6,SP
  move.l  D0,savessp    ; SSP sichern

  move    #$2700,SR     ; keine Interrupts

  bsr     prepare       ; Bildbuffer vorbereiten

  bsr     savevr        ; Videoregister sichern

  move.l  #$01FF0197,$FFFF8282.w ;  Auflîsungs-
  move.l  #$50001F,$FFFF8286.w   ;  umschaltung:                 
  move.l  #$018F01B4,$FFFF828A.w ; RGB/TV 50.1Hz
  move.l  #$026F0263,$FFFF82A2.w ;   Truecolor
  move.l  #$170017,$FFFF82A6.w   ;    832*288
  move.l  #$02570269,$FFFF82AA.w
  move.w  #$0200,$FFFF820A.w
  move.w  #$0182,$FFFF82C0.w
  clr.w   $FFFF8266.w
  move.w  #$0100,$FFFF8266.w
  move.w  #$04,$FFFF82C2.w
  move.w  #$0340,$FFFF8210.w

  move.l  $70.w,save70
  move.l  #vbl,$70.w    ; Bildschirmflipping an
  move    #$2300,SR

key_wait:
  cmpi.b  #$39,$FFFFFC02.w ; auf Space warten
  bne.s   key_wait

  move    #$2700,SR
  move.l  save70(PC),$70.w

  bsr     backvr        ; Videoreinit

  move.l  savessp(PC),-(SP)
  move.w  #$20,-(SP)
  trap    #1
  addq.w  #6,SP

  clr.w   -(SP)         ; das war's.
  trap    #1

;=======================================
;                      Initialisierungen

prepare:
  lea     screenbuf,A0  ; Bildschirmbereich
  move.l  A0,scr0       ; Setzte Bildschirm 1
  adda.l  #832*288*2,A0 ; Platz fÅr Bildschirm 1
  move.l  A0,scr1       ; Setze Bildschirm 2

  bsr     preparepbuf   ; Testbildbuffer anlegen
                            
  lea     picbuf,A0     ; Zeiger auf zu
  bsr     prepareNTC    ; konvertierendes Bild
  rts

;=======================================
;        Vorbereitung eines 24-Bit Test-
;                            bildbuffers

preparepbuf:
  lea     picbuf(PC),A0
  move.w  #288-1,D0
  moveq   #0,D5        
ppbl0:
  move.w  #255-1,D1
  moveq   #0,D6
  moveq   #0,D7
ppbl1:
  move.b  D5,(A0)+
  move.b  D6,(A0)+
  move.b  D7,(A0)+
  addq.w  #1,D6
  dbra    D1,ppbl1
  move.w  #161-1,D1
ppbl2:
  move.b  D5,(A0)+
  move.b  D6,(A0)+
  move.b  D7,(A0)+
  addq.w  #1,D7
  subq.w  #1,D6
  dbra    D1,ppbl2
  cmp.b   #288-256,D0
  blt.s   ppblok
  subq.w  #2,D5
ppblok:
  addq.w  #1,D5
  dbra    D0,ppbl0
  rts

;=======================================
;   Konvertiere Bildbuffer in NTC-Format

prepareNTC:
  movea.l scr0(PC),A1
  movea.l scr1(PC),A2
  lea     coltab,A3
  movea.l A1,A5
  movea.l A2,A6
  move.w  #288-1,D0     ; 288 Zeilen
pNTCloopy:
  move.w  #416-1,D1 ; 416 Spalten
pNTCloopx:
  clr.l   (A1)
  clr.l   (A2)
  move.b  (A0)+,D2      ; 8Bit OriginalRotanteil
  and.w   #%11111110,D2 ; Rot: 7 Bit 
  lsl.w   #1,D2         ; Ofset in NTCtabelle
  cmp.w   #124*4,D2
  ble.s   pNTClxok1
  move.w  #124*4,D2
pNTClxok1:
  lea     0(A3,D2.w),A4
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 1
  lsl.w   #3,D2
  move.b  D2,(A1)
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 1
  lsl.w   #3,D2
  move.b  D2,2(A1)
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 2
  lsl.w   #3,D2
  move.b  D2,(A2)
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 2
  lsl.w   #3,D2
  move.b  D2,2(A2)

  moveq   #0,D2
  move.b  (A0)+,D2      ; 8Bit OriginalGrÅnanteil
  lsl.w   #2,D2         ; Offset in NTCtabelle
  lea     0(A3,D2.w),A4
  moveq   #0,D2
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 1
  lsl.w   #5,D2
  or.w    D2,(A1)
  moveq   #0,D2
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 1
  lsl.w   #5,D2
  or.w    D2,2(A1)
  moveq   #0,D2
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 2
  lsl.w   #5,D2
  or.w    D2,(A2)
  moveq   #0,D2
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 2
  lsl.w   #5,D2
  or.w    D2,2(A2)

  move.b  (A0)+,D2      ; 8Bit OriginalBlauanteil
  and.w   #%11111110,D2 ; Blau: 7 Bit
  lsl.w   #1,D2         ; Offset in NTCtabelle
  cmp.w   #124*4,D2
  ble.s   pNTClxok2
  move.w  #124*4,D2
pNTClxok2:
  lea     0(A3,D2.w),A4
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 1
  or.b    D2,1(A1)
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 1
  or.b    D2,3(A1)
  move.b  (A4)+,D2      ; Ditherpixel 1, Screen 2
  or.b    D2,1(A2)
  move.b  (A4)+,D2      ; Ditherpixel 2, Screen 2
  or.b    D2,3(A2)

  addq.w  #4,A1
  addq.w  #4,A2

  dbra    D1,pNTCloopx
  lea     416*2*2(A5),A5 ; Zeilenpointer Screen1
  lea     416*2*2(A6),A6 ; Zeilenpointer Screen2
  exg     A5,A6          ; ZeilenverschrÑnkung
  movea.l A5,A1
  movea.l A6,A2
  dbra    D0,pNTCloopy
  rts

;=======================================
;              VBL:  Bildschirmswitching

vbl:
  movem.l D0-A6,-(SP)
  cmpi.b  #1,$FFFFFC02.w ; mit <ESC> Bildschirm-
  beq.s   vbl_noflip     ; switching Åbergehen
  move.l  scr0,D0        ; Screens wechseln
  move.l  scr1,D1
  move.l  D0,scr1
  move.l  D1,scr0
vbl_noflip:
  move.b  scr0+1,$FFFF8201.w  ; Hi Screenadresse
  move.b  scr0+2,$FFFF8203.w ; Mid
  move.b  scr0+3,$FFFF820D.w ; Low
  movem.l (SP)+,D0-A6
  rte

;=======================================
;                          Videohandling

savevr:
  lea     savevidregs(PC),A0 ; Videoeinstellung
  move.l  $FFFF8282.w,(A0)+  ;      merken
  move.l  $FFFF8286.w,(A0)+
  move.l  $FFFF828A.w,(A0)+
  move.l  $FFFF828E.w,(A0)+
  move.l  $FFFF82A2.w,(A0)+
  move.l  $FFFF82A6.w,(A0)+
  move.l  $FFFF82AA.w,(A0)+
  move.w  $FFFF82C0.w,(A0)+
  move.w  $FFFF8266.w,(A0)+
  move.w  $FFFF8260.w,(A0)+
  move.w  $FFFF8210.w,(A0)+
  move.w  $FFFF82C2.w,(A0)+
  move.l  $FFFF8200.w,(A0)+
  move.w  $FFFF820C.w,(A0)+
  rts

backvr:
  lea     savevidregs(PC),A0 ; Videoeinstellung 
  move.l  (A0)+,$FFFF8282.w  ;     zurÅck
  move.l  (A0)+,$FFFF8286.w
  move.l  (A0)+,$FFFF828A.w
  move.l  (A0)+,$FFFF828E.w
  move.l  (A0)+,$FFFF82A2.w
  move.l  (A0)+,$FFFF82A6.w
  move.l  (A0)+,$FFFF82AA.w
  move.w  (A0)+,$FFFF82C0.w
  move.w  (A0)+,$FFFF8266.w
  cmpi.w  #$50,savevidregs
  blt.s   backvrok
  addq.w  #2,A0
  bra.s   backvrno
backvrok:
  move.w  (A0)+,$FFFF8260.w
backvrno:
  move.w  (A0)+,$FFFF8210.w
  move.w  (A0)+,$FFFF82C2.w
  move.l  (A0)+,$FFFF8200.w
  move.w  (A0)+,$FFFF820C.w
  rts

;=============================
;        Konvertierungstabelle

            DATA
coltab:
z           SET 0
            REPT 63
            DC.B z,z,z,z,z,z,z+1,z,z+1
            DC.B z,z+1,z,z+1,z,z+1,z+1
z           SET z+1
            ENDR
            REPT 16
            DC.B 63
            ENDR
            BSS
savevidregs:DS.L 20     ; Sicherung Videoregister
save70:     DS.L 1      ; Sicherung VBL-Vektor
savessp:    DS.L 1      ; Sicherung SSP

scr0:       DS.L 1      ; Adresse Bildschirm 1
scr1:       DS.L 1      ; Adresse Bildschirm 2

picbuf:     DS.W 832*288 ; Testbildbuffer
            DS.L 16
screenbuf:  DS.L 832*288 ; Buffer fÅr 2 Screens
            END

