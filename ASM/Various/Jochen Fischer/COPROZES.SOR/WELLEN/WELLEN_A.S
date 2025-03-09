******************************
*                            * 
*        Wellen_A.PRG        *
*                            *
*  Ω 1991 by Jochen Fischer  *
*                            *
******************************

macro     Physbase
          movem.l   d1-d2/a0-a2,-(sp)   ;Anfangsadresse des 
          move.w    #2,-(sp)            ;physikalischen Bildschirm-
          trap      #14                 ;speichers in D0
          addq.l    #2,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Getrez
          movem.l   d1-d2/a0-a2,-(sp)   ;Aktuelle Bildschirm- 
          move.w    #4,-(sp)            ;auflîsung in D0
          trap      #14
          addq.l    #2,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Cconws str
          movem.l   d1-d2/a0-a2,-(sp)   ;Ausgabe des Strings str
          pea       str                 ;auf den Bildschirm
          move.w    #9,-(sp)            ;unter Beachtung der
          trap      #1                  ;ESC-Sequenzen
          addq.l    #6,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Cconrs buf
          movem.l   d1-d2/a0-a2,-(sp)   ;Ausgabe des Strings str
          pea       buf                 ;auf den Bildschirm
          move.w    #10,-(sp)           ;unter Beachtung der
          trap      #1                  ;ESC-Sequenzen
          addq.l    #6,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Setcolor color,col_nr
          movem.l   d1-d2/a0-a2,-(sp)   ;Farbregister setzen oder
          move.w    color,-(sp)         ;abfragen, D0=bisheriger Wert
          move.w    col_nr,-(sp)
          move.w    #7,-(sp)
          trap      #14
          addq.l    #6,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Malloc amount
          movem.l   d1-d2/a0-a2,-(sp)   ;Speicherplatz reservieren
          move.l    amount,-(sp)        ;oder berechnen
          move.w    #$48,-(sp)
          trap      #1
          addq.l    #6,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Mshrink newsize,block         
          movem.l   d1-d2/a0-a2,-(sp)   ;Speicherblock verkleinern
          move.l    newsize,-(sp)
          move.l    block,-(sp)
          move.w    #0,-(sp)
          move.w    #$4a,-(sp)
          trap      #1
          adda.l    #12,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     Mfree saddr
          movem.l   d1-d2/a0-a2,-(sp)   ;Speicherblock freigeben
          move.l    saddr,-(sp)
          move.w    #$49,-(sp)
          trap      #1
          addq.l    #6,sp
          movem.l   (sp)+,d1-d2/a0-a2
endm
macro     rd_int buf,frage,len,pos
          pea       buf(pc)
          pea       frage(pc)
          move.w    len,-(sp)
          move.w    pos,-(sp)
          bsr       lies_int
          adda.l    #12,sp
endm             
macro     rd_card buf,frage,len,pos
          pea       buf(pc)
          pea       frage(pc)
          move.w    len,-(sp)
          move.w    pos,-(sp)
          bsr       lies_card
          adda.l    #12,sp
endm
* --------------------------------------------------------*
*                      Eingabeteil                        *
* --------------------------------------------------------*
          text
          movea.l   4(sp),a6            ;base_page
          movem.l   d0-d7/a0-a6,-(sp)   ;sÑmtliche Register retten
          fmovem.l  fpcr/fpsr/fpiar,-(sp)
          fmovem.x  fp0-fp7,-(sp)
          move.l    #$100,d6            ;ProgrammlÑnge berechnen
          add.l     12(a6),d6           ;Text Segment
          add.l     20(a6),d6           ;Data Segment
          add.l     28(a6),d6           ;Bss Segment
          Mshrink   d6,a6               ;Speicherblock verkÅrzen
          Physbase                      ;Bildschirmspeicheradresse
          lea       scr_adr(pc),a1      ;ermitteln und
          move.l    d0,(a1)             ;sichern
          Getrez                        ;Auflîsung feststellen
          tst.b     d0                  ;D0=0 ?
          beq       w_reso              ;ja -> exit
          btst      #0,d0               ;Bit 0 gesetzt ?
          bne       w_reso              ;ja -> exit
          move.w    #640,4(a1)          ;max_x=640
          move.w    #400,6(a1)          ;max_y=400
          move.w    #1,8(a1)            ;gr_mode=1 (ST Hoch)
          btst      #2,d0               ;Bit 2 gesetzt ?
          beq       weiter1             ;nein -> weiter
          move.w    #480,6(a1)          ;max_y=480
          move.w    #2,8(a1)            ;gr_mode=2 (TT Mittel)
weiter1:  movem.l   d0-d3/a0-a3,-(sp)
          aline     $a                  ;maus ausschalten
          movem.l   (sp)+,d0-d3/a0-a3
          Cconws    leer(pc)
          Cconws    clr_scr(pc)         ;Bildschirm lîschen
el1:      rd_card   Antwort,Frage1,#4,#$0202  ;max_x eingeben
          tst.w     d0                  ;keine Eingabe ?
          beq       el2                 ;ja -> max annehmen
          cmp.w     #160,d0             ;Eingabe <160 ?
          blt       el1                 ;ja -> neueingabe
          cmp.w     4(a1),d0            ;d0>=max_x ?
          bge       el2                 ;nein -> el2
          move.w    d0,4(a1)            ;sonst max_x=d0
el2:      move.w    4(a1),d0            ;d0=max_x
          lsr.w     #1,d0               ;d0/2
          move.w    d0,10(a1)           ;x_halbe=d0
          rd_card   Antwort,Frage2,#4,#$0302  ;max_y eingeben
          tst.w     d0                  ;keine Eingabe ?
          beq       el3                 ;ja -> max annehmen
          cmp.w     #100,d0             ;Eingabe <100 ?
          blt       el2                 ;ja -> Neueingabe
          cmp.w     6(a1),d0            ;d0>=max_y ?
          bge       el3                 ;nein -> el2
          move.w    d0,6(a1)            ;sonst max_y=d0
el3:      move.w    6(a1),d0            ;d0=max_y
          lsr.w     #1,d0               ;d0/2
          move.w    d0,12(a1)           ;y_halbe=d0
* Eingabe der Wellenparameter
          move.w    #$0702,d1           ;zeile 7, spalte 2
          moveq     #0,d2               ;indexregister
          pea       Antwort(pc)
          pea       Info1(pc)           ;Welle 1
          move.w    #$0502,-(sp)
          bsr       print_yx
          adda.l    #10,sp
          bra       ew_anf              ;-> Anfang
ew_loop:  pea       Antwort(pc)         ;(zweiter Durchgang)
          pea       Info2(pc)           ;Welle 2
          move.w    #$0C02,-(sp)
          bsr       print_yx
          adda.l    #10,sp
          move.w    #$0E02,d1           
ew_anf:   rd_int    Antwort,Frage3,#4,d1
          move.w    d0,14(a1,d2.w)      ;xmitte1_2=d0
          add.w     #$100,d1            ;eine Zeile tiefer
          addq.w    #2,d2               ;nÑchster Index
          rd_int    Antwort,Frage4,#4,d1
          move.w    d0,14(a1,d2.w)      ;ymitte1_2=d0       
          add.w     #$100,d1            ;eine Zeile tiefer
          addq.w    #2,d2               ;nÑchster Index

          rd_int    Antwort,Frage5,#3,d1 ;phase1 oder phase2 einlesen
          move.b    d0,14(a1,d2.w)
          add.w     #$100,d1            ;eine Zeile tiefer
          addq.w    #1,d2               ;nÑchster Index
          rd_card   Antwort,Frage6,#3,d1 ;Ampl1 oder Ampl2 einlesen
          move.b    d0,14(a1,d2.w)
          add.w     #$100,d1            ;eine Zeile tiefer
          addq.w    #1,d2               ;nÑchster Index

          cmpi.w    #$E00,d1            ;Zeile > 12 ?
          blt       ew_loop             ;nein -> nÑchste Welle
          add.w     #$100,d1
          rd_card   Antwort,Frage8,#3,d1  ;freq1 einlesen
          tst.b     d0
          bne       weiter2
          moveq     #8,d0
weiter2:  move.w    d0,16(a1,d2.w)
          add.w     #$200,d1
          rd_card   Antwort,Frage7,#1,d1  ;Step einlesen
          tst.b     d0
          bne       weiter3
          moveq     #2,d0
weiter3:  move.w    d0,14(a1,d2.w)
          Cconws    clr_scr(pc)    
* Berechnung des vorhandenen Speichers und Abfrage der Bildanzahl
          moveq     #0,d1               ;Grîûe eines Bildes berechnen
          move.w    max_x(pc),d1        ;max_x in d1        
          and.b     #$f0,d1             ;auf word-grenze runden
          lsr.l     #3,d1               ;Anzahl Bytes
          mulu      max_y(pc),d1        ;max_y * Anzahl bytes
          move.w    gr_mode(pc),d2      ;gr_mode ?
          cmpi.w    #1,d2               ;TT Mittel ?
          beq       weiter4             ;nein -> weiter
          lsl.l     #2,d1               ;ja -> Grîûe *4 (4 planes)
weiter4:  Malloc    #-1                 ;wieviel Speicher ?
          divu.l    d1,d0               ;wieviele Bilder passen hinein ?
          move.w    d0,d2               ;Wert in ASCII umrechnen
          move.l    d1,d3
          lea       Antwort(pc),a2
          moveq     #2,d1
anz_loop: and.l     #$0000ffff,d0
          divu.w    #10,d0
          swap      d0
          add.b     #$30,d0             ;offset fÅr ASCII
          move.b    d0,(a2,d1.w)
          swap      d0
          subq.b    #1,d1
          bpl       anz_loop
          move.b    #0,3(a2)
          Cconws    Meldung2(pc)        ;max Anzahl ausgeben
          Cconws    Antwort(pc)
          rd_card   Antwort,Frage9,#3,#$0402  ;gewÅnschte Anzahl lesen
          tst.w     d0
          bne       weiter5
          move.w    #10,d0
weiter5:  cmp.w     d2,d0               ;zuviele ?
          bge       weiter6
          move.w    d0,d2
weiter6:  lea       bild_anz(pc),a2
          move.w    d2,(a2)             ;anzahl sichern
          move.l    d3,2(a2)            ;Grîûe sichern
          mulu.l    d3,d2               ;benîtigten Speicher berechnen
          Malloc    d2                  ;und reservieren
          tst.l     d0                  ;fehler aufgetreten ?
          beq       ende                ;ja -> ende
          move.l    d0,6(a2)            ;anfangsadresse sichern          
          Cconws    cur_off(pc)    
          Cconws    clr_scr(pc)
* --------------------------------------------------------*
*                     Hauptprogramm                       *
* --------------------------------------------------------*
          move.w    gr_mode(pc),d0
          cmpi.w    #1,d0
          beq       sw_mode
          lea       farben(pc),a2       ;Adresse der Farbpalette
          moveq     #0,d1
f_loop:   Setcolor  (a2),d1             ;Farbpalette setzen
          move.w    d0,(a2)+
          addq.w    #1,d1
          cmpi.w    #16,d1
          bne       f_loop
* ---------------------------------
sw_mode:  
          fmove.l   FPCR,d0             
          and.b     #%00001111,d0       ;Round to nearest,extended
          fmove.l   d0,FPCR
          lea       freq1f(pc),a2       ;Zwischenspeicher fÅr Frequenzen
          fmove.w   #1,fp0
          fdiv.w    w_lngth(pc),fp0
          fmove.s   fp0,(a2)            ;freq1f=1/w_lngth
          fdiv.b    phase1(pc),fp0
          fmul.b    phase2(pc),fp0
          fmove.s   fp0,4(a2)           ;freq2f=freq1f/phase1*phase2

          movea.l   buf_adr(pc),a5      ;buffer adresse in a5
hpt_loop: Cconws    clr_scr(pc)         ;Bildschirm lîschen
          lea       ph1f(pc),a4
          lea       bild_anz(pc),a1
          add.w     #1,10(a1)           ;nÑchstes Bild     
          move.w    (a1),d0
          cmp.w     10(a1),d0           ;bild_nr>bild_anz ?
          blt       animation           ;ja -> bilder zeigen
          fmovecr   #0,fp0              ;fp0=PI
          fmul.b    #2,fp0              ;fp0=PI*2
          fdiv.w    (a1),fp0            ;fp0=fp0/bild_anz
          fmul.w    10(a1),fp0          ;fp0=fp0*bild_nr
          fmove     fp0,fp1
          fmul.b    phase1(pc),fp0
          fmove.s   fp0,(a4)            ;ph1f sichern
          fmul.b    phase2(pc),fp1
          fmove.s   fp1,4(a4)           ;ph2f sichern
          
          move.w    max_y(pc),d0
          move.w    max_x(pc),d1
          subq.w    #1,d1
          lea       ybild,a0
dim_loop: move.w    d0,(a0)+            ;Feld Ybild mit max_y fÅllen
          dbra      d1,dim_loop

          movea.l   #0,a1
          moveq     #0,d7
          move.b    ampl1(pc),d7
          add.b     ampl2(pc),d7        ;ampl errechnen
          movea.w   d7,a1               ;ampl fÅr Farbber. in a1 sichern
          moveq     #0,d5
          move.b    ampl2(pc),d5        ;unteres word von d5=ampl2
          swap      d5
          move.b    ampl1(pc),d5        ;oberes word von d5=ampl1

          move.w    y_halbe(pc),d0      ;d0 ist ykoor
          sub.w     d7,d0               ;d0=d0-ampl
          sub.w     y_halbe(pc),d7      ;schleifenende bei ampl-y_halbe
          lea       yl_ende(pc),a0
          move.w    d7,(a0)             ;schleifenende sichern
          lea       ybild,a2            ;anfangsadresse von ybild in a2
yk_loop:  move.w    d0,d6               ;d6=ykoor
          sub.w     ymitte1(pc),d6      ;ykoor=ykoor-ymitte1
          fmove.w   d6,fp0
          fsglmul   fp0,fp0             ;Yquad1
          move.w    d0,d6               ;d6=ykoor
          sub.w     ymitte2(pc),d6      ;ykoor=ykoor-ymitte2
          fmove.w   d6,fp1
          fsglmul   fp1,fp1             ;Yquad2
          move.w    x_halbe(pc),d1
          neg.w     d1                  ;d1 ist xkoor
          clr.l     d7                  ;index- u. koord.zÑhler
          move.w    #-1,d7
xk_loop:  move.w    d1,d6               ;d6=xkoor
          sub.w     xmitte1(pc),d6      ;xkoor=xkoor-xmitte1
          fmove.w   d6,fp2
          fsglmul   fp2,fp2             ;Xquad1
          move.w    d1,d6               ;d6=xkoor
          sub.w     xmitte2(pc),d6      ;xkoor=xkoor-xmitte2
          fmove.w   d6,fp3
          fsglmul   fp3,fp3             ;Xquad2

          fadd      fp0,fp2             ;abst1=xquad1+yquad1
          fsqrt     fp2                 ;abst1=sqrt(abst1)
          swap      d7                ;Indexteil 
          lea       0(a2,d7.w),a3     ;adresse von ybild() berechnen  
          fsglmul.s freq1f(pc),fp2      ;abst1=abst1*freq1
          fadd.s    (a4),fp2            ;abst1=abst1+phase1
          fadd      fp1,fp3             ;abst2=xquad2+yquad2
          fsqrt     fp3                 ;abst2=sqrt(abst2)
          addq.w    #2,d7             ;nÑchster index
          swap      d7                ;koordinatenteil
          addq.w    #1,d7             ;nÑchste x koordinate fÅr punkt
          fsglmul.s freq2f(pc),fp3      ;abst2=abst2*freq2
          fadd.s    4(a4),fp3           ;abst2=abst2+phase2
          fsin      fp2                 ;hoehe=sin(abst1)
          move.w    d0,d6             ;d6=ykoor
          add.w     y_halbe(pc),d6    ;d6=d6+y_halbe
          fsin      fp3                 ;hoehe2=sin(abst2)
          move.w    (a3),d4           ;d4=ybild()
          addq.w    #1,d1             ;xkoor=xkoor+1
          moveq     #0,d3             ;d3 lîschen  
          fsglmul.w d5,fp2              ;hoehe=hoehe*ampl1
          swap      d5
          fsglmul.w d5,fp3              ;hoehe2=hoehe2*ampl2
          fadd      fp3,fp2             ;hoehe=hoehe+hoehe2
          swap      d5
          fmove.w   fp2,d3              ;d3=hoehe
          add.w     d3,d6               ;d6=d6+hoehe
          cmp.w     d6,d4               ;d6<d4 ?

          ble       kein_punkt          ;nein -> kein_punkt
          move.w    d6,(a3)             ;ybild()=neuer punkt          
          move.w    gr_mode(pc),d4      ;Bitplaneanzahl in d4
          cmpi.b    #1,d4               ;sw_modus ?
          beq       sw_punkt            ;ja -> sw_punkt setzen
          add.w     a1,d3               ;hoehe=hoehe+ampl
          mulu      #14,d3              ;d3*Farbanzahl
          lsr.w     #1,d3               ;d3/2
          move.w    a1,d4               ;ampl in d4
          divu.w    d4,d3               ;d3/ampl
          addq.w    #1,d3
          bsr       point               ;farbigen Punkt setzen
          bra       kein_punkt          
sw_punkt: bsr       sw_point            ;sw routine aufrufen
kein_punkt:
          cmp.w     x_halbe(pc),d1      ;xkoor>x_halbe ?
          blt       xk_loop             ;nein -> nochmal
          sub.w     step(pc),d0         ;ykoor=ykoor-step             
          cmp.w     yl_ende(pc),d0      ;ykoor<yl_ende ?
          bgt       yk_loop             ;nein -> nochmal

          movea.l   a5,a0
          bsr       moveblk1            ;bild sichern
          adda.l    bild_gr(pc),a5      ;a5+bild_gr
          bra       hpt_loop
* ----------------------------------
animation:moveq     #2,d4               ;3 mal vbl abwarten          
          move.w    #640,d0             ;Mittige Lage errechnen
          sub.w     max_x(pc),d0        ;(damit Bilder in der Mitte
          lsr.w     #4,d0               ;gezeigt werden)
          bclr      #0,d0               ;word-grenze
          move.w    #400,d1
          move.w    #80,d2              ;multiplikator
          lea       gr_mode(pc),a1
          cmpi.w    #1,(a1)             ;ST-Hoch ?
          beq       ml_w1
          move.w    #480,d1             ;nein -> 480 in d1
          move.w    #320,d2             ;multiplikator
          lsl.w     #2,d0               ;d0*4
ml_w1:    sub.w     max_y(pc),d1
          lsr.w     #1,d1
          mulu      d2,d1
          add.w     d0,d1
          move.l    d1,d5               ;Mittelposition in d5
                              
zeigen:   movea.l   a5,a0               ;letzte Bildadr. in a0
          move.l    bild_gr(pc),d1
          moveq     #0,d2
z_loop:   move.w    d4,d3              
p_loop:   movem.l   d0-d3/a0,-(sp)
          move.w    #$25,-(sp)          ;auf vbl warten
          trap      #14
          addq.l    #2,sp
          movem.l   (sp)+,d0-d3/a0          
          dbra      d3,p_loop
          suba.l    d1,a0               ;a0=a0-bild_gr
          bsr       moveblk2            ;bild zeigen
          addq.w    #1,d2
          cmp.w     bild_anz(pc),d2     ;alle bilder gezeigt ?
          bne       z_loop              ;nein -> loop

          move.w    #2,-(sp)            ;Taste gedrÅckt ?
          move.w    #1,-(sp)
          trap      #13
          addq.l    #4,sp
          tst.b     d0
          beq       zeigen              ;nein -> zeigen
          move.w    #2,-(sp)            ;welche Taste ?
          move.w    #2,-(sp)
          trap      #13
          addq.l    #4,sp          
          swap      d0                  ;scancode untersuchen
          cmp.b     #1,d0               ;ESC gedrÅckt ?
          beq       schluss             ;ja -> schluss
          cmp.b     #72,d0              ;Pfeil nach oben ?
          bne       a_tast              ;nein -> andere Taste
          subq.w    #1,d4               ;schneller zeigen
          bpl       zeigen             
          moveq     #0,d4               ;wenn d4<0 -> d4=0
          bra       zeigen
a_tast:   addq.w    #1,d4               ;langsamer zeigen
          bra       zeigen          
* --------------------------------------------------------*
*                 Ende des Hauptteils                     *
* --------------------------------------------------------*    
schluss:  Mfree     buf_adr(pc)         ;Speicherplatz freigeben
          move.w    gr_mode(pc),d0
          cmpi.w    #1,d0
          beq       ende                ;wenn sw-modus -> warten
          lea       farben(pc),a2       ;farbspeicheradresse
          moveq     #0,d2               ;erstes Farbregister              
f2_loop:  move.w    (a2)+,d1            ;alte Farbe in d1
          Setcolor  d1,d2
          addq.w    #1,d2
          cmp.w     #16,d2
          bne       f2_loop
* ---------------------------------
          bra       ende      
w_reso:   Cconws    Meldung1(pc)        ;Meldung fÅr falschen Modus          
          move.w    #7,-(sp)            ;auf Taste warten
          trap      #1
          addq.l    #2,sp
          jsr       ende
ende:     fmovem.x  (sp)+,fp0-fp7
          fmovem.l  (sp)+,fpcr/fpsr/fpiar
          movem.l   (sp)+,d0-d7/a0-a6
          clr.w     -(sp)
          trap      #1
* --------------------------------------------------------*
*              universelle Unterprogramme                 *
* --------------------------------------------------------*
point:    movem.l   d5-d7/a2,-(sp)      ;Routine fÅr Punkte mit 16 Farben
          movea.l   scr_adr(pc),a2      ;(nur TT Mittel)
          and.l     #$0000ffff,d7
          and.l     #$0000ffff,d6
          move.l    d6,d5               ;d6*320
          lsl.l     #8,d5               
          lsl.l     #6,d6
          add.l     d5,d6
          adda.l    d6,a2               ;scr_adr+d6
          move.l    d7,d5               ;pixelposition in d5
          and.w     #$f,d5
          and.w     #$fff0,d7           ;nr des bytes in d7     
          lsr.w     #1,d7
          adda.l    d7,a2               ;scr_adr+d7
          move.w    #$8000,d6
          lsr.w     d5,d6
          move.w    d6,d5
          not.w     d5
          btst      #0,d3
          beq       btl1
          or.w      d6,(a2)+
          bra       pln2
btl1:     and.w     d5,(a2)+
pln2:     btst      #1,d3
          beq       btl2
          or.w      d6,(a2)+
          bra       pln3
btl2:     and.w     d5,(a2)+
pln3:     btst      #2,d3
          beq       btl3
          or.w      d6,(a2)+
          bra       pln4
btl3:     and.w     d5,(a2)+     
pln4:     btst      #3,d3
          beq       btl4 
          or.w      d6,(a2)+
          bra       pln_e
btl4:     and.w     d5,(a2)+
pln_e:    movem.l   (sp)+,d5-d7/a2
          rts
* --------------------------------
sw_point: movem.l   d5-d7/a2,-(sp)      ;Routine fÅr s/w Punkt
          movea.l   scr_adr(pc),a2      ;(nur ST Hoch)
          and.l     #$0000ffff,d7       
          and.l     #$0000ffff,d6
          move.w    d6,d5               ; d6 * 80
          lsl.w     #4,d6               
          lsl.w     #6,d5               
          add.w     d5,d6               
          adda.l    d6,a2               ;adr+d6
          move.b    d7,d6
          and.l     #7,d6               ;pixelposition in d6
          lsr.w     #3,d7               ;nr des bytes in d7
          adda.l    d7,a2               ;adr+d7
          move.b    #128,d5                         
          lsr.b     d6,d5
          or.b      d5,(a2)             
          movem.l   (sp)+,d5-d7/a2
          rts
* ----------------------------------
* in a0 wird bufferadresse Åbergeben    ;Routine zum Verschieben
moveblk1: movem.l   d1-d3/a0-a2,-(sp)   ;von Speicherblîcken
          lea       max_x(pc),a1        ;(Bild->Speicher)
          move.w    (a1),d0             ;max_x in D0
          and.b     #$F0,d0             ;auf word-grenze runden
          lsr.w     #4,d0               ;wieviele word's ?
          move.w    2(a1),d1            ;max_y in D1
          move.l    #40,d2              ;max word's
          cmpi.w    #1,4(a1)            ;welcher gr_modus ?
          beq       m1_sw
          lsl.w     #2,d0               ;4 planes
          lsl.w     #2,d2
m1_sw:    movea.l   -4(a1),a2           ;scr_adr in a2
          sub.w     d0,d2               ;differenz
          lsl.w     #1,d2               ;anzahl bytes ->offset
m1_loop1: moveq     #0,d3               ;word zÑhler
m1_loop2: move.w    (a2)+,(a0)+         ;Bild verschieben
          addq.w    #1,d3
          cmp.w     d3,d0               ;eine Zeile fertig ?
          bgt       m1_loop2
          adda.l    d2,a2               ;an Zeilenanfang
          sub.w     #1,d1               ;eine Zeile weniger
          bne       m1_loop1      
          movem.l   (sp)+,d1-d3/a0-a2
          rts
* ----------------------------------
* a0 = bufferadresse, d5=Mittelposition ;Routine zum Verschieben
moveblk2: movem.l   d1-d3/a0-a2,-(sp)   ;von Speicherblîcken
          lea       max_x(pc),a1        ;(Speicher->Bild)
          move.w    (a1),d0             ;max_x in D0
          and.b     #$F0,d0             ;auf word-grenze runden
          lsr.w     #4,d0               ;wieviele word's ?
          move.w    2(a1),d1            ;max_y in D1
          move.l    #40,d2              ;max word's
          cmpi.w    #1,4(a1)            ;welcher gr_modus ?
          beq       m2_sw
          lsl.w     #2,d0               ;4 planes
          lsl.w     #2,d2
m2_sw:    movea.l   -4(a1),a2           ;scr_adr in a2
          adda.l    d5,a2               ;a2 + Mittelposition 
          sub.w     d0,d2               ;differenz
          lsl.w     #1,d2               ;anzahl bytes ->offset
m2_loop1: moveq     #0,d3               ;word zÑhler
m2_loop2: move.w    (a0)+,(a2)+         ;Bild verschieben
          addq.w    #1,d3
          cmp.w     d3,d0               ;eine Zeile fertig ?
          bgt       m2_loop2
          adda.l    d2,a2               ;an Zeilenanfang
          sub.w     #1,d1               ;eine Zeile weniger
          bne       m2_loop1      
          movem.l   (sp)+,d1-d3/a0-a2
          rts          
* ----------------------------------
* (buffer,text,lÑnge,y,x)->(sp)
lies_card:movem.l   d1-d3/a0-a2,-(sp)
          movea.l   36(sp),a0           ;Bufferadr in A0
          move.w    #$1b59,(a0)         ;ESC Y in Buffer
          move.w    28(sp),2(a0)        ;Koordinaten in Buffer
          addi.w    #$2020,2(a0)        ;jeweils 32 addieren
          move.b    #0,4(a0)            ;Stringende
          Cconws    (a0)                ;String ausgeben    
          Cconws    clr_line(pc)        ;Zeile lîschen
          movea.l   32(sp),a1           ;Textadr in A1
          Cconws    (a1)                ;Text ausgeben
          move.b    31(sp),(a0)         ;LÑnge in Buffer
          Cconrs    (a0)                ;String eingeben
          move.b    1(a0),d1            ;Anzahl Zeichen in D1
          beq       lcl_exit            ;Anzahl=0 -> exit
          ext.w     d1
          subq.w    #1,d1
          clr.w     d2
          clr.w     d0
lc_loop:  mulu      #10,d0              ;Zahl mal 10
          move.b    2(a0,d2.w),d3       ;Zeichen in D3
          subi.b    #$30,d3             ;48 von ASCII abziehen
          bmi       lcl_exit            ;keine Ziffer -> exit
          cmpi.b    #9,d3               ;Wert>9 ?
          bgt       lcl_exit            ;keine Ziffer -> exit
          ext.w     d3
          add.w     d3,d0               ;d0=d0+Ziffer
          addq.b    #1,d2               ;nÑchste Ziffer
          dbf       d1,lc_loop          ;bis zur letzten Ziffer
          bra       lc_ende
lcl_exit: moveq.l   #0,d0               ;Fehler aufgetreten
lc_ende:  movem.l   (sp)+,d1-d3/a0-a2
          rts                           
* ----------------------------------
* (buffer,text,lÑnge,y,x)->(sp)
lies_int: movem.l   d1-d3/a0-a2,-(sp)
          movea.l   36(sp),a0           ;Bufferadr in A0
          move.w    #$1b59,(a0)         ;ESC Y in Buffer
          move.w    28(sp),2(a0)        ;Koordinaten in Buffer
          addi.w    #$2020,2(a0)        ;jeweils 32 addieren
          move.b    #0,4(a0)            ;Stringende
          Cconws    (a0)                ;String ausgeben    
          Cconws    clr_line(pc)        ;Zeile lîschen
          movea.l   32(sp),a1           ;Textadr in A1
          Cconws    (a1)                ;Text ausgeben
          move.b    31(sp),(a0)         ;LÑnge in Buffer
          Cconrs    (a0)                ;String eingeben
          move.b    1(a0),d1            ;wurde Zeichen gelesen ?
          beq       lil_exit            ;nein -> exit
          ext.w     d1
          move.b    2(a0),d0            ;erstes Zeichen in D0
          clr.l     d3                  ;Zahl positiv
          cmp.b     #'+',d0             ;'+' erstes Zeichen ?
          beq       li_plus
          cmp.b     #'-',d0             ;'-' erstes Zeichen ?
          beq       li_minus
          bra       li_ziffer           ;erstes Zeichen Ziffer
li_minus: or.l      #$10000,d3          ;Zahl negativ
li_plus:  moveq     #1,d2               ;erstes Zeichen fÑllt weg
          subq.b    #2,d1               ;ein Zeichen weniger
          bra       li_pl_mi
li_ziffer:subq.w    #1,d1
          clr.w     d2
li_pl_mi: clr.w     d0
li_loop:  mulu      #10,d0              ;Zahl mal 10
          move.b    2(a0,d2.w),d3       ;Zeichen in D3
          subi.b    #$30,d3             ;48 von ASCII abziehen
          bmi       lil_exit            ;keine Ziffer -> exit
          cmpi.b    #9,d3               ;Wert>9 ?
          bgt       lil_exit            ;keine Ziffer -> exit
          ext.w     d3
          add.w     d3,d0               ;d0=d0+Ziffer
          addq.b    #1,d2               ;nÑchste Ziffer
          dbf       d1,li_loop          ;bis zur letzten Ziffer
          swap      d3
          btst      #0,d3               ;Zahl negativ ?
          beq       li_ende             ;nein -> ende
          neg.w     d0                  ;sonst negieren
          bra       li_ende             ;-> ende
lil_exit: moveq.l   #0,d0               ;Fehler aufgetreten
li_ende:  movem.l   (sp)+,d1-d3/a0-a2
          rts
* ----------------------------------
* (buffer,text,y,x)->sp
print_yx: move.l    a0,-(sp)
          movea.l   14(sp),a0           ;Bufferadr in A0
          move.w    #$1b59,(a0)         ;ESC Y in Buffer
          move.w    8(sp),2(a0)         ;Koordinaten in Buffer
          addi.w    #$2020,2(a0)        ;jeweils 32 addieren
          move.b    #0,4(a0)            ;Stringende
          Cconws    (a0)                ;String ausgeben    
          movea.l   10(sp),a0           ;Textadr in A0
          Cconws    (a0)                ;text ausgeben
          movea.l   (sp)+,a0
          rts
* --------------------------------------------------------*
*                     Datenbereich                        * 
* --------------------------------------------------------*
scr_adr:  dc.l      0
max_x:    dc.w      0
max_y:    dc.w      0
gr_mode:  dc.w      0
x_halbe:  dc.w      0
y_halbe:  dc.w      0
xmitte1:  dc.w      0
ymitte1:  dc.w      0
phase1:   dc.b      0
ampl1:    dc.b      0
xmitte2:  dc.w      0
ymitte2:  dc.w      0
phase2:   dc.b      0
ampl2:    dc.b      0
step:     dc.w      0
w_lngth:  dc.w      0
yl_ende:  dc.w      0
*
freq1f:   dc.l      0
freq2f:   dc.l      0
ph1f:     dc.l      0
ph2f:     dc.l      0
*
bild_anz: dc.w      0
bild_gr:  dc.l      0
buf_adr:  dc.l      0
bild_nr:  dc.w      0
* Farbpalette
farben:   dc.w      $0,$5f,$cf,$4f,$bf,$3f,$af,$1f,$8f,$f,$7,$e,$6,$d,$5,$c
*
Meldung1: dc.b      27,'E'
          asciiz    'Falscher Graphikmodus: WÑhle ST-Hoch oder TT-Mittel !'
Meldung2: dc.b      27,'Y',34,34
          asciiz    'Maximale Anzahl :'
* Texte zu den Eingaben
Frage1:   asciiz    'Breite in Pixeln :'
Frage2:   asciiz    'Hîhe   in Pixeln :'
Info1:    asciiz    'Welle 1 :'
Info2:    asciiz    'Welle 2 :'
Frage3:   asciiz    'X-koordinate   :'
Frage4:   asciiz    'Y-koordinate   :'
Frage5:   asciiz    'Phase      1-3 :'
Frage6:   asciiz    'Amplitude <=20 :'
Frage7:   asciiz    'Step (1-5) :'
Frage8:   asciiz    'WellenlÑnge der 1. Welle  5-15 :'
Frage9:   asciiz    'Anzahl der Bilder :'
* Gelesene Eingaben
Antwort:  dc.b      0,0,0,0,0,0,0,0
* Steuerzeichen
clr_scr:  dc.b      27,'E',0
cur_off:  dc.b      27,'f',0
cur_on:   dc.b      27,'e',0  
clr_line: dc.b      27,'K',0
leer:     asciiz    '     '
* ---------------------------
          bss
ybild:    ds.w      640
          end
