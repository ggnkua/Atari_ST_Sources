; ---------------------------------------------
;                    NEWMATH.S 
; 
; Mathematische Bibliothek fÅr TURBO/PURE C,
; die die FPU 68882 des TT unterstÅtzt
;
;                 by Roman Hodek
;            (c) 1992 MAXON Computer
; ---------------------------------------------

; Labels, die nach auûen bekannt sein sollen:

EXPORT printfl,sprintfl,fprintfl
EXPORT fabs,ceil,floor,round,trunc,fmod
EXPORT exp,exp10,exp2,log,log10,log2
EXPORT frexp,ldexp,modf
EXPORT pow,pow10,sqrt
EXPORT sin,cos,tan,sincos,asin,acos,atan,atan2
EXPORT sinh,cosh,tanh,asinh,acosh,atanh
EXPORT ftest,fclrerr,ferr,fpumode

; fÅr printfl benîtigt:

IMPORT _StdOutF,fputc


fabs:    fabs.x    fp0,fp0
         rts       

ceil:    fmove     fpcr,d0      ; Rounding mode:
         move.l    d0,d1
         and.b     #%11001111,d0
         or.b      #%00110000,d0  ; to + infty
         fmove     d0,fpcr
         fint.x    fp0,fp0
         fmove     d1,fpcr
         rts
         
floor:   fmove     fpcr,d0      ; Rounding mode:
         move.l    d0,d1
         and.b     #%11001111,d0
         or.b      #%00100000,d0  ; to - infty
         fmove     d0,fpcr
         fint.x    fp0,fp0
         fmove     d1,fpcr
         rts

round:   fmove     fpcr,d0      ; Rounding mode:
         move.l    d0,d1
         and.b     #%11001111,d0
         or.b      #%00000000,d0  ; to nearest
         fmove     d0,fpcr
         fint.x    fp0,fp0
         fmove     d1,fpcr
         rts
         
trunc:   fintrz.x  fp0,fp0      ; Rounding mode:
         rts                    ; to zero
         
fmod:    frem.x    fp1,fp0
         rts
         

exp:     fetox.x   fp0,fp0
         rts
exp10:   ftentox.x fp0,fp0
         rts       
exp2:    ftwotox.x fp0,fp0
         rts       
log:     flogn.x   fp0,fp0
         rts
log10:   flog10.x  fp0,fp0
         rts
log2:    flog2.x   fp0,fp0
         rts


; fgetman liefert eine Mantisse zwischen 1.0
; und 2.0; frexp() soll aber Werte zwischen
; 0.5 und 1.0 zurÅckgeben ==>
; man /= 2 und exp += 1

frexp:   fgetexp.x fp0,fp1  
         fgetman.x fp0,fp0  
         fmove.w   fp0,(a0) 
         addq.w    #1,(a0)  
         fscale.w  #-1,fp0  
         rts

ldexp:   fscale.w  (a0),fp0
         rts
         
modf:    fintrz.x  fp0,fp1  ; FP1 <- Integerteil
         fmove.x   fp1,(a0) ; Nachkommateil =
         fsub.x    fp0,fp1  ; x - int(x)
         rts

; Potenzberechnung: a^b = exp(b*ln(a))
; Ist fÅr negative Basis nur bei ganzzahligen
; Exponenten definiert!      
         
pow:     ftst.x    fp0       ; Basis == 0 ->
         fbeq      pow_end   ; Ergebnis 0
         
         fmove.l   fp1,d0
         fcmp.l    d0,fp1
         fbne      pow_frac
                             ; ganzzahl. Exp.:
         ftst.x    fp0       ; Basis >= 0 -> 
         fbge      pow_frac  ; normale Behandl.
         
         fabs.x    fp0       ; Basis < 0 : 
         flogn.x   fp0,fp0   ; Betrag nehmen
         fmul.x    fp1,fp0
         fetox.x   fp0,fp0
         btst      #0,d0     ; und wenn Exponent
         beq       pow_end   ; ungerade:
         fneg.x    fp0       ; Ergebnis negativ
         bra       pow_end
         
pow_frac:flogn.x   fp0,fp0   ; ergibt bei negat.
         fmul.x    fp1,fp0   ; Exponenten
         fetox.x   fp0,fp0   ; E_DOMAIN
         
pow_end: rts

pow10:   fmove.w   d0,fp0
         ftentox.x fp0,fp0
         rts

sqrt:    fsqrt.x   fp0,fp0
         rts       
         
         
sin:     fsin.x    fp0,fp0
         rts
cos:     fcos.x    fp0,fp0
         rts
tan:     ftan.x    fp0,fp0
         rts
sincos:  fsincos.x fp0,fp1:fp0
         fmove.x   fp1,(a0)
         rts
asin:    fasin.x   fp0,fp0
         rts
acos:    facos.x   fp0,fp0
         rts
atan:    fatan.x   fp0,fp0
         rts

; atan2(y,x) berechnet den Arcustangens des
; Bruches y/x. Die Funktion ist vor allem zu
; Berechnungen des Arguments komplexer Zahlen
; gedacht und liefert Ergebnisse -pi .. pi
; 0 im Nenner wird korrekt gehandhabt und pi/2
; zurÅckgegeben.

atan2:   ftst.x    fp1       ; x == 0 => Erg.
         fbeq      atan2_pol ; +-pi/2
         
         moveq     #0,d0     ; sonst Korrektur:
         fbgt      atan2_fac ; x>0      : 0*pi
         moveq     #1,d0     ; x<0, y>=0: +1*pi
         ftst.x    fp0       ;  " , y< 0: -1*pi
         fbge      atan2_fac
         neg.w     d0
atan2_fac:
         fdiv.x    fp1,fp0   ; fp0 <- atan(y/x)
         fatan.x   fp0
         fmovecr.x #0,fp1    ; pi * Korrektur
         fmul.w    d0,fp1
         fadd.x    fp1,fp0   ; dazuaddieren
         rts
         
atan2_pol:                   ; Behandlung der
         fmove.x   fp0,fp1   ; Polstellen x == 0
         fabs.x    fp0
         fdiv.x    fp1,fp0   ; fp0 <- sign( y )
         fmovecr.x #0,fp1
         fmul.x    fp1,fp0   ; * pi
         fscale.w  #-1,fp0   ; / 2
         rts
         
sinh:    fsinh.x   fp0,fp0
         rts
cosh:    fcosh.x   fp0,fp0
         rts
tanh:    ftanh.x   fp0,fp0
         rts
asinh:   fmove.x   fp0,fp1   ; asinh(x) = 
         fmul.x    fp1,fp1   ; ln(x+sqrt(x^2+1))
         fadd.w    #1,fp1
         fsqrt.x   fp1
         fadd.x    fp1,fp0
         flogn.x   fp0
         rts
acosh:   fmove.x   fp0,fp1   ; acosh(x) = 
         fmul.x    fp1,fp1   ; ln(x+sqrt(x^2-1))
         fsub.w    #1,fp1
         fsqrt.x   fp1
         fadd.x    fp1,fp0
         flogn.x   fp0
         rts
atanh:   fatanh.x  fp0,fp0
         rts
         
; ---------------------------------------------
; neue Verwaltungsfunktionen

; ftest testet sein Argument, ob es Unendlich
; oder ein NAN ist. RÅckgabe: 
; +-1 => +-NAN ;  +-2 => +-Unendlich
; 0 => "normale" Zahl

ftest:   ftst.x    fp0       ; FP0 testen
         fmove.l   fpsr,d0   ; Condition Codes
         swap      d0        ; holen
         lsr.w     #8,d0
         btst      #3,d0     ; N-Flag -> d1
         sne       d1
         and.l     #3,d0     ; I- und NAN-Flags:
         tst.b     d1        ; 2 = Unendl.
         beq       ftest_e   ; 1 = NAN
         neg.l     d0        ; ev. negieren
ftest_e: rts
         
; fclrerr lîscht frÅher bemerkte Fehler 
         
fclrerr: fmove.l   fpsr,d0       ; Accrued Excep-
         and.l     #$ffffff00,d0 ; tion-Byte
         fmove.l   d0,fpsr       ; lîschen
         rts
         
; ferr testet, ob seit dem letzten fclrerr Fehler
; aufgetreten sind. RÅckgabe: s. Headerdatei
         
ferr:    fmove.l   fpsr,d0   ; Accrued Exception
         and.l     #$ff,d0   ; Byte lesen
         lsr.l     #3,d0
         rts
         
; fpumode setzt Rechengenauigkeit und Rundungs-
; modus der FPU
         
fpumode: fmove.l  fpcr,d2

         tst.w     d0        ; wenn d0 = prec.
         bmi       fpm_01    ; != -1 :
         lsl.w     #6,d0     ; ins FPCR schreiben
         and.b     #%00111111,d2
         or.b      d0,d2

fpm_01:  tst.w     d1        ; wenn d1 = r.mode
         bmi       fpm_02    ; != -1 :
         lsl.w     #4,d0 
         and.b     #%11001111,d2  ; ins FPCR
         or.b      d0,d2

fpm_02:  fmove.l   d2,fpcr   ; FPCR zurÅckschr.
         rts
         
         
; ----------------------------------------------
; [fs]printfl zur Ausgabe von Flieûkommazahlen
; f,s: selbe Bedeutung wie bei printf            
; Ausgabeformat: Werte > 99999 und < 0.01  
; werden mit Exponent gedruckt, sonst ohne           
; RÅckgabewert: Anzahl der ausgegebenen Zeichen  

saving   reg d4-d7/a3-a5  ; zu rettende Register

packed   = -12            ; lokale Variable
buffer   = packed - 16

; Einsprungpunkte je nach AusgabegerÑt:
; a5 = Ausgabehandler                 
; a4 = Zeiger auf String/File         

printfl:
         link      a6,#buffer
         movem.l   #saving,-(sp)
         lea       put_scr(pc),a5
         bra       _printfl
         
sprintfl:
         link      a6,#buffer
         movem.l   #saving,-(sp)
         lea       put_str(pc),a5
         move.l    a0,a4
         bra       _printfl
         
fprintfl:
         link      a6,#buffer
         movem.l   #saving,-(sp)
         lea       put_file(pc),a5
         move.l    a0,a4
 
         
_printfl:ftst.x    fp0           ; Null abfangen
         fbne      pf_nnull
         moveq     #'0',d0
         jsr       (a5)
         bra       pf_end
         
         ; Zahl ins Packed-Decimal-Format
pf_nnull:fmove.p   fp0,packed(a6){#17}
         
         btst      #5,packed(a6) ; NAN oder
         bne       pf_nan        ; Unendl. ?

         ; mit oder ohne Exponent ?
         moveq     #0,d5         ; d5 = Kommapos.
         sf        d4            ; d4 = Exp.flag
         move.b    packed+2(a6),d0
         and.b     #$f0,d0
         bne       pf_mitex
         move.w    packed(a6),d0
         move.w    d0,d1
         and.w     #$0ff0,d1     ; |Exp.| > 9 ->
         bne       pf_mitex      ; mit Exp. ausg.
         and.w     #$f,d0
         btst      #6,packed(a6) ; Vorzeichenbit
         beq       pf_01
         neg.w     d0            ; d0 = Exponent
pf_01:                         
         cmp.w     #-2,d0        ; -2<=Exp.<=5 =>
         blt       pf_mitex      
         cmp.w     #5,d0
         bgt       pf_mitex
         st        d4            ; keinen Exp.!
         move.w    d0,d5         ; d5 = Komma-
                                 ;      stelle

pf_mitex:moveq     #0,d7         ; d7 = Zeichen-
                                 ;      zÑhler
         btst      #7,packed(a6) ; wenn negativ,
         beq       pf_02         ; '-' ausgeben
         moveq     #'-',d0
         jsr       (a5)
pf_02:
         tst.w     d5            ; wenn Exp.flag
         bpl       pf_start
         moveq     #'0',d0       ; Exp. == -1 ->
         jsr       (a5)          ; "0" ausg.
         moveq     #'.',d0       ; Exp. == -2 ->
         jsr       (a5)          ; "0.0" ausg.
         cmp.w     #-1,d5
         beq       pf_start
         moveq     #'0',d0
         jsr       (a5)

pf_start:move.b    packed+3(a6),d0 ; erste Ziffer
         and.b     #$0f,d0         ; ausgeben
         or.b      #$30,d0
         jsr       (a5)
         
         lea       packed+12(a6),a0 ; restliche
         lea       buffer+16(a6),a1 ; Ziffern
         moveq     #7,d0            ; entpacken
pf_03:   unpk      -(a0),-(a1),#$3030
         dbra      d0,pf_03
         
         lea       buffer+16(a6),a0 ; Nullen
         lea       -16(a0),a1       ; rechts weg-
pf_04:   cmp.b     #$30,-(a0)       ; streichen
         bne       pf_05
         clr.b     (a0)
         cmp.l     a0,a1
         bne       pf_04
pf_05:
         lea       buffer(a6),a3 ; Nachkommateil     
         addq.w    #1,d5         ; ausgeben
         moveq     #15,d6        

pf_loop: cmp.w     #1,d5         ; Abbruch, wenn
         bgt       pf_06         ; schon Komma
         tst.b     (a3)          ; und Nullbyte
         beq       pf_exp
pf_06:   subq.w    #1,d5
         bne       pf_07         ; Kommaz. == 0
         moveq     #'.',d0       ; => '.' ausgeb.
         jsr       (a5)
pf_07:   move.b    (a3)+,d0      ; Ziffer ausgeb.
         or.b      #$30,d0
         jsr       (a5)
         dbra      d6,pf_loop
                                 ; Exponent ausg.
pf_exp:  tst.b     d4            ; nur wenn d4
         bne       pf_end        ; != 0
         
         move.w    packed(a6),d0 ; Exp. extra-
         and.w     #$fff,d0      ; hieren
         move.w    packed+2(a6),d1
         and.w     #$f000,d1     ; Erweiterungs-
         or.w      d1,d0         ; stelle!

         lea       buffer(a6),a3
         unpk      d0,d1,#$3030  ; Exp. entpacken
         move.w    d1,2(a3)
         lsr.w     #8,d0
         unpk      d0,d1,#$3030
         move.w    d1,(a3)
         
         moveq     #'e',d0       ; 'e'-Zeichen
         jsr       (a5)
         
         moveq     #'+',d0       ; Vorzeichen
         btst      #6,packed(a6) ; ausgeben
         beq       pf_08
         moveq     #'-',d0
pf_08:   jsr       (a5)
         
         moveq     #3,d6
pf_09:   subq.w    #1,d6
         cmp.b     #$30,(a3)+    ; fÅhrende 0en
         beq       pf_09         ; Åberspringen
         subq.l    #1,a3
         addq.w    #1,d6
         
pf_10:   move.b    (a3)+,d0      ; und Exponent
         jsr       (a5)          ; ausgeben
         dbra      d6,pf_10
         bra       pf_end
         
         
pf_nan:  tst.l     packed+4(a6)  ; Unterscheidung
         bne       pf_na         ; NAN oder Unen.
         tst.l     packed+8(a6)
         bne       pf_na
         move.b    packed+3(a6),d0
         and.b     #15,d0
         bne       pf_na
         
         moveq     #'+',d0       ; +- Unendlich
         btst      #7,packed(a6)
         beq       pf_11
         moveq     #'-',d0
pf_11:   jsr       (a5)
         move.b    #$df,d0       ; Unendlich-
         jsr       (a5)          ; Zeichen
         bra       pf_end        ; ausgeben

pf_na:   moveq     #'N',d0       ; "NAN" ausgeben
         jsr       (a5)
         moveq     #'A',d0
         jsr       (a5)
         moveq     #'N',d0
         jsr       (a5)


pf_end:  cmp.l     #put_str,a5   ; bei Ausg. in
         bne       pf_12         ; String \0 an-
         clr.b     (a4)          ; hÑngen

pf_12:   move.w    d7,d0         ; RÅckgabewert
         movem.l   (sp)+,#saving
         unlk      a6
         rts

; Ausgabehandler fÅr Strings, Files und STDOUT

put_str: move.b    d0,(a4)+
         addq.w    #1,d7
         rts

put_scr: lea       _StdOutF,a0
         bsr       fputc
         addq.w    #1,d7
         rts

put_file:          move.l    a4,a0
         bsr       fputc
         addq.w    #1,d7
         rts
