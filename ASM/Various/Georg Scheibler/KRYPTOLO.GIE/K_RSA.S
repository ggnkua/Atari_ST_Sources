;Prozedur zum Ver- und EntschlÅsseln eines Textes
;nach dem Verfahren von R. Rivest, A. Shamir und
;L. Adleman (RSA-Verfahren).
;von Georg Scheibler, Lemgo
;(c) 1992 MAXON Computer GmbH
;aufruf:
;verschlÅsseln:
;crypt(*quelle,lÑnge,*ziel,*RSA_N,*RSA_S,true.w)
;entschlÅsseln:
;crypt(*quelle,lÑnge,*ziel,*RSA_N,*RSA_T,false.w)
;mit    *quelle: ptr. auf zu bearbeitenden Text
;       lÑnge: lÑnge des zu bearbeiten Textes [L]
;       *ziel:   ptr. puffer f. bearbeiteten Text
;       *RSA_N:  ptr. auf SchlÅsselzahl N
;       *RSA_S:  ptr. auf SchlÅsselzahl S
;       *RSA_T:  ptr. auf SchlÅsselzahl T
;       true: word<>0, Flag zum VerschlÅsseln
;       false: word=0, Flag zum EntschlÅsseln
;die SchlÅsselzahlen N,S,T sind 16 Byte-Interger!

;RÅckgabe: D0= LÑnge des Textes in Zielpuffer
; Fehler wenn kleinr 0:
;       -1 = 'N' kleiner als 256
;       -2 = exponent gleich 0 ('S' bzw. 'T')

;geschrieben mit dem 'DEVPAC'-Assembler ('GENST')

;Offsets relativ zu a6
;die Åbergebenen Variablen
source  equ     8
laenge  equ     source+4
dest    equ     laenge+4
RSA_N   equ     dest+4
expo    equ     RSA_N+4
modus   equ     expo+4

;die lokalen Variablen
p1      equ     -16     ;Teilergebnis [4L]
len_p   equ     p1-2
x1      equ     len_p-16 ;Zweierpotenz mod n
len_x   equ     x1-2
len_n   equ     len_x-2
len_e   equ     len_n-2 ;grîûe Exponent (in word)
len_s   equ     len_e-2 ;anzahl Byte holen
len_d   equ     len_s-2 ;anzahl Byte speichern

crypt:  link    a6,#len_d ;kleinste Zahl fÅr link
        movem.l d1-d7/a0-a5,-(a7)
        lea     p1(a6),a2
        lea     x1(a6),a3
        move.l  RSA_N(a6),a1

        move.l  a1,a0
        bsr     getLEN
        move.w  d0,len_n(a6)
        ble     err_N   ;RSA_N ist 0
        subq.l  #2,a0
crypt1: tst.b   (a0)+   ;wieviel Byte auf einmal
        dbne    d0,crypt1 ;codieren ?
        move.w  d0,d1
        subq.w  #1,d1
        ble     err_N   ;RSA_N ist zu klein
        tst.w   modus(a6)
        bne.s   crypt_d
        exg     d1,d0
crypt_d:move.w  d0,len_d(a6)
        move.w  d1,len_s(a6)

        move.l  expo(a6),a0
        bsr     getLEN
        asr.w   #1,d0           ;anzahl word's
        ble.s   err_exp         ;Exponent ist 0
        subq.w  #1,d0           ;wegen dbf
        move.w  d0,len_e(a6)

        move.l  source(a6),a5
        move.l  dest(a6),a4
        move.l  laenge(a6),d4

cryptloop:
        movea.l a2,a0           ;p1 auf 1
        moveq   #0,d0
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        moveq   #1,d0
        move.l  d0,(a0)
        moveq   #2,d0           ;und lÑnge auf 2
        move.w  d0,len_p(a6)    ;(=1 word)

        move.l  a3,a0           ;x1 lîschen
        moveq   #0,d0
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.l  d0,(a0)+
        move.w  len_s(a6),d0    ;highword ist 0!
        sub.l   d0,a0           ;daher .l mîglich
        sub.l   d0,d4   ;verbleibende lÑnge
        bpl.s   crypt3  ;fÅr nÑchsten Durchgang
        add.l   d4,d0   ;nur noch den Rest
        bra.s   crypt3
crypt2: move.b  (a5)+,(a0)+     ;die nÑchsten
crypt3: dbf     d0,crypt2       ;Zeichen holen
        move.l  a3,a0           ;(neues x1)
        bsr     getLEN
        move.w  d0,len_x(a6)
        bgt.s   crypt6          ;Zahl ist 0
        lea     16(a3),a0      ;dann nur kopieren
        bra.s   crypt7          ;ergibt sowieso 0
crypt6: bsr.s   ahbmodn
        lea     16(a2),a0
crypt7: move.w  len_d(a6),d0    ;lÑnge Ergebnis
        suba.w  d0,a0
        bra.s   crypt5

crypt4: move.b  (a0)+,(a4)+     ;Ergebnis
crypt5: dbf     d0,crypt4       ;speichern

        tst.l   d4
        bgt     cryptloop
        move.l  a4,d0           ;lÑnge berechnen
        sub.l   dest(a6),d0
        bra.s   crypt_E
err_N:  moveq   #-1,d0
        bra.s   crypt_E
err_exp:moveq   #-2,d0
crypt_E:movem.l (a7)+,d1-d7/a0-a5
        unlk    a6
        rts

;a6 wird vor dem Aufruf festgelegt !!
;nur zur optischen Trennung als Unterprogramm
ahbmodn:move.w  len_e(a6),d7
        move.l  expo(a6),a0
        lea     16(a0),a0 ;ptr hinter Exponent
ahbmnlp:move.w  -(a0),d6 ;word vom Exponent
        moveq   #15,d5   ;bitzÑhler f. Exponenten
ahbmnli:lsr.w   d6       ;nÑchste Potens testen
        bcc.s   ahbmnli1
;Ergebnis mit Zweipotenz multiplizieren(u. mod n)
        move.w  len_x(a6),-(a7) ;p=(p*x) mod n
        move.l  a3,-(a7)        ;x
        move.w  len_p(a6),-(a7)
        move.l  a2,-(a7)        ;p
        move.w  len_n(a6),-(a7)
        move.l  a1,-(a7)        ;n
        move.l  a2,-(a7)        ;Ergebnis in p
        bsr     abmodn
        lea     22(a7),a7
        move.w  d0,len_p(a6)

ahbmnli1:
        tst.w   d7              ;wird nÑchste
        bne.s   ahbmnli2        ;Zweierpotenz
        tst.w   d6              ;noch benîtigt?
        beq.s   ahbmn_E
ahbmnli2:       ;nÑchste Zweierpotenz bestimmen
        move.w  len_x(a6),-(a7) ;x=(x*x) mod n
        move.l  a3,-(a7)
        move.w  len_n(a6),-(a7)
        move.l  a1,-(a7)        ;n
        move.l  a3,-(a7)        ;Ergebnis in x
        bsr     ah2modn
        lea     16(a7),a7
        move.w  d0,len_x(a6)
        dbf     d5,ahbmnli
        dbf     d7,ahbmnlp
ahbmn_E:rts

;offsets relativ zu a6
ptrRET: equ     8
ptrN:   equ     ptrRET+4
lenN:   equ     ptrN+4
ptrF1:  equ     lenN+2
lenF1:  equ     ptrF1+4
ptrF2:  equ     lenF1+2
lenF2:  equ     ptrF2+4

lenP8L: equ     -2
P8L:    equ     lenP8L-32 ;[8L]-Puffer f. Produkt

ah2modn:link    a6,#P8L ;berechne a hoch 2 mod n
        movem.l d1-d7/a0-a5,-(a7)
        lea     P8L(a6),a4
        move.l  ptrF1(a6),a1
        move.w  lenF1(a6),d0
        movea.w #16,a3  ;max.LÑnge-genutzte LÑnge
        suba.w  d0,a3   ; = 0-Bytes am Anfang
        movea.l a3,a2   ;aber immer grade !!
        adda.w  a2,a2   ;LÑnge * 4 (fÅr PC-rel.
        adda.w  a2,a2   ;Verzweigung benîtigt)
        add.w   d0,d0
        move.w  d0,lenP8L(a6) ;LÑnge Ergebnis fÅr
        movem.w (a1),d0-d7    ; MOD merken
        jmp     ah2_mul(pc,a3.w)
ah2_mul:mulu    d0,d0   ;das Produkt mit sich
        mulu    d1,d1   ;selbst nur einmal
        mulu    d2,d2
        mulu    d3,d3
        mulu    d4,d4
        mulu    d5,d5
        mulu    d6,d6
        mulu    d7,d7
        movem.l d0-d7,(a4)
        adda.w  a3,a1
        lea     18(a4,a3.w),a4
        adda.w  ah2_cor(pc,a3.w),a4
        bra     ah2_e
ah2_cor:dc.w    0,2,0,2,0,2,0
ah2:    movem.w (a1),d0-d7
        jmp     ah2mul2(pc,a3.w)
ah2mul2:mulu    d0,d7   ;zwei Byte pro Befehl
        mulu    d0,d6
        mulu    d0,d5
        mulu    d0,d4
        mulu    d0,d3
        mulu    d0,d2
        mulu    d0,d1

        move.l  a4,a0
;D0.L und X-Flag lîschen (ohne Zugriff auf CCR)
        sub.l   d0,d0
        jmp     ah2_W(pc,a2.w)
;ggf. mit NOP's auf 8 Byte auffÅllen
ah2_W:  move.w  d6,d0   ;7 Reg.
        swap    d0
        addq.l  #4,a4
        bra.s   ah2_w6
        move.l  d6,d7   ;6 Reg.
        swap    d7
        clr.w   d7
        bra.s   ah2_w6
        moveq   #0,d6   ;5 Reg.
        addq.l  #4,a4
        bra.s   ah2_w6
        nop
        move.l  d4,d5   ;4 Reg.
        swap    d5
        clr.w   d5
        bra.s   ah2_w4
        moveq   #0,d4   ;3 Reg.
        addq.l  #4,a4
        bra.s   ah2_w4
        nop
        move.l  d2,d3   ;2 Reg.
        swap    d3
        clr.w   d3
        bra.s   ah2_w2
        addq.l  #4,a4   ;1 Reg.
        bra.s   ah2_w1

ah2_w6: move.w  d4,d6
        swap    d6
ah2_w4: move.w  d2,d4
        swap    d4
ah2_w2: clr.w   d2
        swap    d2
        jmp     ah2_a(pc,a3.w)
ah2_a:  add.l   d0,d7   ;Teilergebnisse addieren
        nop
        addx.l  d6,d5
        nop
        addx.l  d4,d3
        addx.l  d2,d1   ;kein Åbertrag mîglich
        moveq   #0,d0   ;daher nur d0 lîschen
        jmp     ah2_dup(pc,a3.w)
ah2_dup:nop
        add.l   d7,d7
        nop
        addx.l  d5,d5
        nop
        addx.l  d3,d3
ah2_w1: addx.l  d1,d1
        addx.w  d0,d0  ;X-Flag speichern +lîschen

        moveq   #0,d2
        jmp     ah2_ad(pc,a3.w)
ah2_ad: nop
        add.l   d7,-(a0)
        addx.l  d2,d5
        add.l   d5,-(a0)
        addx.l  d2,d3
        add.l   d3,-(a0)
        addx.l  d2,d1
        add.l   d1,-(a0)
        addx.w  d2,d0
        add.w   d0,-(a0)
        bcc.s   ah2_nx
ah2_x:  addq.w  #1,-(a0)        ;X-Flag so lange
        bcs.s   ah2_x           ;wie nîtig add.
ah2_nx: addq.l  #2,a1           ;fÅr nÑchstes
        addq.w  #8,a2           ;word vorbereiten
        addq.w  #2,a3
ah2_e:  cmpa.w  #14,a3
        bne     ah2
        bra     modulo

abmodn: link    a6,#P8L       ;berechne a*b mod n
        movem.l d1-d7/a0-a5,-(a7)
        move.l  ptrF1(a6),a1
        move.l  ptrF2(a6),a2

        moveq   #0,d0     ;Ergebnispuffer lîschen
        moveq   #7,d1
        lea     P8L(a6),a4      ;[8L]-Puffer
abMulC: move.l  d0,(a4)+
        dbf     d1,abMulC       ;a4 jetzt hinter
        move.w  lenF1(a6),d0    ; Ergebnispuffer
        move.w  lenF2(a6),d1
        move.w  d0,d2
        add.w   d1,d2           ;lÑnge Ergebnis 
        move.w  d2,lenP8L(a6)   ;fÅr MOD merken
        cmp.w   d0,d1
        bhi.s   abMulV
        exg     d0,d1           ;ggf. Faktoren
        exg     a1,a2           ;vertauschen
abMulV: lea     16(a1),a1       ;hinter kleineren
        neg     d1              ; Faktor
        lea     abMul+16(pc,d1.w),a5
        lsr.w   #1,d0
        movea.w d0,a3   ;SchleifenzÑhler

;grîûeren Faktor in Reg. laden (word-weise)
abMulL: movem.w (a2),d0-d6
        move.w  -(a1),d7 ;word von kleinen Faktor

        jmp     (a5)    ;nicht mehr Multiplika-
abMul:  mulu    d7,d0   ;tionen als nîtig
        mulu    d7,d1
        mulu    d7,d2
        mulu    d7,d3
        mulu    d7,d4
        mulu    d7,d5
        mulu    d7,d6
        mulu    14(a2),d7 ;noch mit LSW mult.

        add.w   d7,-(a4)        ;beachte: '.w'
        bcc.s   abMulA
        addq.l  #1,d6   ;[W]*[W] max. $FFFE0001 !
abMulA: move.w  d5,d7   ;nidigeres Teilergebnis
        swap    d7      ;anpassen an hîheres
        move.w  d3,d5   ;Teilergebnis
        swap    d5
        move.w  d1,d3
        swap    d3
        clr.w   d1
        swap    d1
        add.l   d7,d6   ;Teilergebnisse addieren
        addx.l  d5,d4
        addx.l  d3,d2
        addx.l  d1,d0   ;kein Åbertrag mîglich
        move.l  a4,a0
        moveq   #0,d7
        add.l   d6,-(a0)
        addx.l  d7,d4
        add.l   d4,-(a0)
        addx.l  d7,d2
        add.l   d2,-(a0)
        addx.l  d7,d0
        add.l   d0,-(a0) ;kein Åbertrag mîglich !

        subq.w  #1,a3
        cmpa.w  #0,a3
        bne.s   abMulL

;die modulo-division

modulo: lea     P8L(a6),a2      ;Ergebnis [8L]
        move.l  ptrN(a6),a3     ;Divisor [4L] 'n'
;LÑngenunterschied von 'Ergebnis' und 'n' in Byte
        move.w  lenP8L(a6),d0
        move.w  lenN(a6),d1
        sub.w   d1,d0           ;Ergebnis kleiner
        bmi     mod_low         ;als n, fertig
        suba.w  d0,a2
        adda.w  #16,a2
        lsr.w   #1,d0
        movea.w d0,a4
        neg.w   d1
        tst.w   16(a2,d1.w)     ;MSW = 0, dann
        bne.s   mod_0           ;ein word weniger
        cmpa.w  #0,a4           ;Ergebnis < n ?
        bls.s   mod_0
        subq.w  #1,a4
        addq.l  #2,a2
mod_0:  move.w  16(a3,d1.w),d0  ;MSW vom Divisor
        cmp.w   16(a2,d1.w),d0 ;> MSW 'ergebnis'?
        bhi.s   mod_d
        addq.w  #1,a4         ;dann ein word mehr
        subq.l  #2,a2
mod_d:  movem.l (a3),d5-d7/a0   ;Divisor
;der folgende Befehle so nur mîglich, wenn a,b<n
;sonst sind 8 zusÑtzliche 0-Word's vor P8L nîtig
;damit die 'oberen [4L]' vom Ergebnis kleiner n
        movem.l (a2)+,d0-d3 ;4MSL von 'ergebnis'
        suba.w  a5,a5   ;a5 nur fÅr 'CMPA A5,An'
        bra.s   modW    ; statt 'CMPA #0,An'

;die innere Schleife (ab mod1) wird bis zu 512
;mal durchlaufen ! da lohnt sich jede Optimierung
mod:    move.w  (a2)+,d4 ;nÑchstes word vom
        movea.w #15,a1         ;'Ergebnis'
mod1:   add.w   d4,d4   ;Teil von 'Ergebnis'
        addx.l  d3,d3   ;rotieren
        addx.l  d2,d2
        addx.l  d1,d1
        addx.l  d0,d0
;       bcs.s   modS    ;nîtig falls n 128 bit
mod_V:  cmp.l   d5,d0   ;Rest grîûer Divisor?
        bcs.s   modL
        bhi.s   modS
        cmp.l   d6,d1
        bcs.s   modL
        bhi.s   modS
        cmp.l   d7,d2
        bcs.s   modL
        bhi.s   modS
        cmp.l   a0,d3
        bcs.s   modL
modS:   sub.l   a0,d3   ;dann subtrahieren
        subx.l  d7,d2
        subx.l  d6,d1
        subx.l  d5,d0
modL:   subq.w  #1,a1
        cmpa.w  a5,a1
        bpl.s   mod1
modW:   subq.w  #1,a4   ;nÑchstes word
        cmpa.w  a5,a4
        bpl.s   mod
        bra.s   modl2
mod_low:lea     P8L+16(a6),a0
        movem.l (a0),d0-d3
modl2:  move.l  ptrRET(a6),a0
        movem.l d0-d3,(a0) ;Endergebnis speichern
        bsr.s   getLEN
        movem.l (a7)+,d1-d7/a0-a5
        unlk    a6
        rts
getLEN: moveq   #8,d0   ;Grîûe einer [4L]-Zahl in
getLEN1:tst.w   (a0)+   ;[B] ermitteln
        dbne    d0,getLEN1
        add.w   d0,d0   ;aber immer grade!!
        rts             ;Fehler wenn d0.w <=0
