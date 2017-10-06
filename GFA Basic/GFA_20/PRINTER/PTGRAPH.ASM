* Druckeranpassung fÅr beliebige Drucker fÅr GFA-BASIC 2.0
* bei Ausgabe mit Lprint, Llist oder OPEN ..."PRN:"
*
* Geschrieben von: Frank Ostrowski, GFA Systemtechnik GmbH
*
* Quelltextformat fÅr GST Macroassembler, kann durch ersetzen von
* section text durch .text und end durch .end an andere Assembler
* angepaût werden. 
*
* Die Druckeranpassungen, die hiermit erzeugt werden, sind
* frei kopierbar, sofern der Name GFA und der des Anpassenden
* nicht geÑndert werden. 
*
* Der Programmteil ab subinit wird nach AusfÅhrung gelîscht, so das eine
* KÅrzung in diesem Bereich aus SpeicherplatzgrÅnden sinnlos ist.
*
*
* Vorschlag fÅr GEMDOS-Patches
* Vor das Ziel des TRAP #1-Vektors eine Kennung ($12348765) schreiben und
* davor den alten Inhalt des TRAP #1-Vektors, so das Patches durch
* wiederholten Aufruf desaktiviert werden. 
*
        section text
kenn:   equ     $12348765
init:   bra     subinit
        dc.l    kenn     ;magic
neugemdos: move.w  (sp),d0
        move.l  usp,a0
        btst    #13,d0          ;Supervisor
        beq.s   neugem1
        lea     6(sp),a0
neugem1: cmp.w   #$40,(a0)+     ;write
        bne.s   normgem         ;nein
        cmp.w   #-3,(a0)+       ;Prn:
        bne.s   normgem         ;nein
        move.l  (a0)+,d1        ;len
        beq.s   normgem
        move.w  d7,-(sp)
        pea     (a1)
        move.l  (a0),a1
        pea     (a1)
        bra.s   neuge7
neuge0: move.b  (a1)+,d0
        bra.s   neugex        ;convert
neuge5: move.b  d0,(a0)+
neuge6  cmp.l   #puffer+80,a0
        blo.s   neuge2
        bsr.s   ausgabe
        tst.b   d7
        bne.s   neuge8        
neuge7: lea     puffer(pc),a0
neuge2: subq.l  #1,d1
        bpl.s   neuge0
        bsr.s   ausgabe
neuge8  suba.l  (sp)+,a1
        tst.b   d7
        bne.s   neuge9
        move.l  a1,d0
neuge9: move.l  (sp)+,a1
        move.w  (sp)+,d7
        rte
ausgabe: pea     (a1)
        move.l  d1,-(sp)
        lea     puffer,a1
        sub.l   a1,a0
        pea     (a1)
        pea     (a0)
        move.w  #-3,-(sp)
        move.w  #$40,-(sp)
        pea     retpc(pc)
        move.w  sr,-(sp)
normgem: jmp     $12345678
oldgem: equ     normgem+2

neugex: pea     (a2)
        lea     conv(pc),a2
        clr.w   d7
neux1:  move.b  (a2)+,d7
        bmi.s   neux2   ;nicht konvertieren
        cmp.b   (a2)+,d0
        beq.s   neux9   ;gefunden
        adda.w  d7,a2
        bra.s   neux1
neux2   move.l  (sp)+,a2
        bra.s   neuge5
neux8   move.b  (a2)+,(a0)+
neux9   dbra    d7,neux8
        move.l  (sp)+,a2
        bra.s   neuge6

retpc:  addq.l  #4,sp
        cmp.l   (sp)+,d0
        sne     d7
        addq.l  #4,sp
        move.l  (sp)+,d1
        move.l  (sp)+,a1
        rts
* Convertierungstabelle
* Aufbau:
* LÑnge, Original, Kopie
* Ende: LÑnge<0
conv:   dc.b    7,'é',27,'R',2,$5b,27,'R',0
        dc.b    7,'ô',27,'R',2,'\',27,'R',0
        dc.b    7,'ö',27,'R',2,$5d,27,'R',0
        dc.b    7,'Ñ',27,'R',2,'{',27,'R',0
        dc.b    7,'î',27,'R',2,'|',27,'R',0
        dc.b    7,'Å',27,'R',2,'}',27,'R',0
        dc.b    7,'û',27,'R',2,'~',27,'R',0
        dc.b    7,225,27,'R',2,'~',27,'R',0     ;Beta
        dc.b    0,128                           ;ignore code 128
        dc.b    12,'A',27,'K',8,0,$00,$ff,$ff,$cc,$cc,$ff,$ff,0
;       a fat A
        dc.b    -1       ;den Rest unverÑndert senden!

puffer: equ     init-128
endprog:
subinit: lea     -1,a1
        bsr.s   trapini
        cmp.l   #kenn,-(a0)
        bne.s   doinit
        move.l  -(a0),a1
        bsr.s   trapini
        lea     noinst(pc),a0
        bsr.s   message
        clr.w   -(sp)
        trap    #1

doinit: lea     neugemdos(pc),a1
        bsr.s   trapini
        move.l  a0,init
        move.l  a0,oldgem
        lea     inst(pc),a0
        bsr.s   message        
        clr.w   -(sp)           ;kein Fehler
        move.l  #endprog-init+256,-(sp) ;programmlÑnge+basepage
        move.w  #$31,-(sp)
        trap    #1

trapini: pea     (a1)
        move.w  #33,-(sp)
        move.w  #5,-(sp)
        trap    #13
        move.l  d0,a0
        addq.l  #8,sp
        rts


message pea     (a0)
        lea     text1(pc),a0
        bsr.s   messsub
        move.l  (sp)+,a0
        bsr.s   messsub
        moveq   #-1,d0
wait1   dbra    d0,wait1
wait2   dbra    d0,wait2
        rts
messsub pea     (a0)
        move.w  #9,-(sp)
        trap    #1
        addq.l  #6,sp
        rts

text1   dc.b    13,10,'GFA patch for PRN:'
        dc.b    13,10,'1986 GFA Systemtechnik, Frank Ostrowski'
        dc.b    13,10,'PTGRAPH ',0
;
; hier sollte der Druckername eingesetzt werden und evtl. der Name des
; Anpassenden. (z.B. pt KYOCERA F~1010   -   A. Nonym)
;
noinst  dc.b    'not '
inst    dc.b    'installed',13,10,0

        end

