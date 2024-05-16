;************************************************************************
;* Debugger an beliebige Adresse laden                                  *
;* Um den Debugger bereits aus dem AUTO-Ordner heraus z.B. ans Speicher-*
;* ende zu laden, muž diese Programm einmal in den AUTO-Ordner und zudem*
;* noch aužerhalb des AUTO-Ordners abgelegt werden, damit sich das Prg  *
;* selbst mit Fsfirst() finden kann (der Default-Pfad ist ja NICHT der  *
;* AUTO-Ordner). Somit muž auch nur das Programm aužerhalb des AUTO-    *
;* Ordners diesen eigenartigen Namen haben. Ach ja, der Debugger muž    *
;* unter dem Namen BUGABOO.PRG ebenfalls aužerhalb des AUTO-Ordners     *
;* liegen. Wem das st”rt, der kann die Suchpfade ja hier im Sourcetext  *
;* „ndern (siehe im DATA-Segment weiter unten)                          *
;* ½1988/9 ä-soft, von Markus Fritze                           09.01.90 *
;************************************************************************
                OPT F-                  ;kein Fast-Load (siehe 68000er 11/89)
start:
                pea     info(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                move.w  #7,-(SP)
                trap    #1
                addq.l  #2,SP
                cmp.b   #$20,D0
                bne     abbruch

                movea.l 4(SP),A6
                lea     own_stk(PC),SP
                pea     ende-start+$0100.w ;Programml„nge
                move.l  A6,-(SP)
                move.l  #$4A0000,-(SP)
                trap    #1              ;Mshrink()
                lea     12(SP),SP

                lea     dta_buf(PC),A5
                move.l  A5,-(SP)
                move.w  #$1A,-(SP)
                trap    #1              ;Fsetdta(dta_buf)
                addq.l  #6,SP

                clr.w   -(SP)
                pea     lfile(PC)
                move.w  #$4E,-(SP)
                trap    #1              ;Fsfirst(7,autofil)
                addq.l  #8,SP
                tst.l   D0
                bmi     abbruch         ;Datei nicht gefunden

                lea     32(A5),A0       ;Zeiger auf das 3.Zeichen des Filenamens
                moveq   #0,D6
                moveq   #5,D2           ;6 Hex-Ziffern holen
init0:          move.b  (A0)+,D0        ;Ladeadresse aus dem Filenamen holen
                subi.b  #'0',D0
                cmp.b   #9,D0
                bls.s   init1
                subq.b  #7,D0
init1:          tst.b   D0
                bmi     abbruch         ;Das war wohl nix
                cmp.b   #15,D0
                bhi     abbruch
                lsl.l   #4,D6           ;ein Nibble nach links
                or.b    D0,D6           ;Ziffer einsetzen
                dbra    D2,init0

                movea.l $2C(A6),A5      ;Adresse des Environment-Strings
                movea.l A5,A0
loop:           tst.b   (A5)+           ;2 Nullbytes suchen
                bne.s   loop
                tst.b   (A5)+
                bne.s   loop
                suba.l  A0,A5           ;L„nge des Environment-Strings

                pea     -1.w
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                trap    #1              ;Malloc(all)
                addq.l  #6,SP           ;Anfangsadresse des freien Speichers
                tst.l   D0
                beq.s   abbruch         ;Speicher reichte nicht

                sub.l   D0,D6           ;- Anfangsadr des freien Speichers
                ble.s   abbruch         ;Adresse zu grož? Ja! =>

                move.l  D0,-(SP)
                move.w  #$49,-(SP)
                trap    #1              ;Mfree(all)
                addq.l  #6,SP

                move.l  D6,-(SP)
                move.w  #$48,-(SP)
                trap    #1              ;Malloc(Differenz)
                addq.l  #6,SP
                tst.l   D0              ;ist oben kein Speicher mehr frei?
                beq.s   abbruch         ;scheint so =>
                movea.l D0,A5           ;Adresse merken

                move.l  $2C(A6),-(SP)   ;Zeiger auf den Envionment-String
                pea     $80(A6)         ;Zeiger auf die Commandline
                pea     fname(PC)
                move.l  #$4B0003,-(SP)
                trap    #1              ;Pexec(load only)
                lea     16(SP),SP
                move.l  D0,D7           ;Basepageadr merken
                bmi.s   abbruch
;
                movea.l D0,A1
                adda.l  #256,A1
                move.w  #$4E71,$A6(A1)
                move.b  #$60,$C4(A1)


                move.l  A5,-(SP)
                move.w  #$49,-(SP)
                trap    #1              ;Mfree(Differenz)
                addq.l  #6,SP

                move.l  D7,-(SP)
                clr.l   -(SP)
                move.l  #$4B0004,-(SP)
                trap    #1              ;Pexec(Start)
                lea     12(SP),SP
                subq.l  #1,D0           ;Exitcode = 1?
                bne.s   abbruch         ;Nein! =>
                clr.w   -(SP)           ;Debugger soll resident bleiben!
                pea     128.w           ;nur ein Teil der Basepage bleibt resident
                move.w  #$31,-(SP)      ;Ptermres()
                trap    #1              ;damit der Debugger nicht gel”scht wird

abbruch:        clr.w   -(SP)
                trap    #1              ;Pterm0()

                DATA
info:           DC.B 27,"H",27,"E","press space to start bugaboo ...",0
                EVEN
lfile:          DC.B 'L_*.PRG',0
fname:          DC.B 'BUGABOO.PRG',0    ;Das wird geladen (der Debugger)
                BSS
dta_buf:        DS.B 44
                DS.L 64
own_stk:        DS.L 0                  ;Jedem seinen Stack
ende:           END
