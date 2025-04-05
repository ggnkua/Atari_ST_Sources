          TEXT
anzahlflashvbls EQU 25
again:
          lea       starttext(pc),a0
          bsr       print
          bsr       getkey
          lea       modifytext(pc),a0
          bsr       print
          bsr.s     zeicheneinausgabe
          lea       bootsektor(pc),a0
          bsr       floprd
          tst.w     d0
          bne.s     fehler
          lea       bootsektor(pc),a0
          bsr       bootsektortest
          cmp.w     #$1234,d0
          bne.s     bootsektornichtausfÅhrb
          lea       bootausfÅhrbartext(pc),a0
          bsr.s     print
          bsr.s     yesno
          cmp.b     #"N",d0
          beq.s     again
bootsektornichtausfÅhrb:
          bsr       modifybootsektor

          lea       bootsektor(pc),a0
          bsr       flopwr
          tst.w     d0
          bne.s     fehler
          lea       readytext(pc),a0
          bsr.s     print
          bsr.s     yesno
          cmp.b     #"Y",d0
          beq.s     again

          clr.w     -(sp)
          trap      #1
;*********
fehler:
          lea       fehlertext(pc),a0
          bsr.s     print
          bsr.s     getkey
          bra.s     again
;*********
          >PART 'zeicheneinausgabe'
zeicheneinausgabe:
          bsr.s     getkey
          and.w     #%1011111,d0   ;in groûes oder kleines A/B wandeln
          cmp.b     #"A",d0
          beq.s     richtigeslaufwerk
          cmp.b     #"B",d0
          bne.s     zeicheneinausgabe
richtigeslaufwerk:
          move.b    d0,zeichen
          lea       zeichen(pc),a0
          bsr.s     print
          rts
          ENDPART
          >PART 'yesno'
yesno:
          bsr.s     getkey
          and.w     #%1011111,d0   ;in groûes oder kleines Y/N wandeln
          cmp.b     #"Y",d0
          beq.s     richtigeszeichen
          cmp.b     #"N",d0
          bne.s     yesno
richtigeszeichen:
          move.b    d0,yesnochar
          lea       yesnochar(pc),a0
          bsr.s     print
          moveq     #0,d0
          move.b    yesnochar(pc),d0
          rts
          ENDPART
          >PART 'print'
print:    movem.l   d0-a6,-(sp)
          pea       (a0)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp
          movem.l   (sp)+,d0-a6
          rts
          ENDPART
          >PART 'getkey'
getkey:   movem.l   d1-a6,-(sp)
          move.w    #8,-(sp)
          trap      #1
          addq.l    #2,sp
          movem.l   (sp)+,d1-a6
          rts
          ENDPART
          >PART 'floprd'
floprd:
;a0.l: Zeiger auf Buffer
          movem.l   d1-a6,-(sp)

          move.w    #1,-(sp)       ;Anzahl
          clr.w     -(sp)          ;Seite 0
          clr.w     -(sp)          ;Track 0
          move.w    #1,-(sp)       ;Sektornummer
          move.b    zeichen(pc),d0
          and.w     #%11,d0
          lsr.w     #1,d0
          move.w    d0,-(sp)       ;Laufwerk (0=A/1=B)
          clr.l     -(sp)          ;dummy
          pea       (a0)           ;Buffer
          move.w    #8,-(sp)
          trap      #14
          lea       $14(sp),sp

          movem.l   (sp)+,d1-a6
          rts
          ENDPART
          >PART 'flopwr'
flopwr:
;in:
;a0.l: Zeiger auf Buffer
          movem.l   d1-a6,-(sp)

          move.w    #1,-(sp)       ;Anzahl
          clr.w     -(sp)          ;Seite 0
          clr.w     -(sp)          ;Track 0
          move.w    #1,-(sp)       ;Sektornummer
          move.b    zeichen(pc),d0
          and.w     #%11,d0
          lsr.w     #1,d0
          move.w    d0,-(sp)       ;Laufwerk (0=A/1=B)
          clr.l     -(sp)          ;dummy
          pea       (a0)           ;Buffer
          move.w    #9,-(sp)
          trap      #14
          lea       $14(sp),sp

          movem.l   (sp)+,d1-a6
          rts
          ENDPART
          >PART 'protobt'
protobt:
;in:
;d0.w: execflag
;d1.w: disktype
;d2.l: serialno.
;a0.l: Zeiger auf Bootsektor
          move.w    d0,-(sp)       ;execflag
          move.w    d1,-(sp)       ;disktype
          move.l    d2,-(sp)       ;serialno.
          pea       (a0)           ;Buffer
          move.w    #$12,-(sp)
          trap      #14
          lea       $0e(sp),sp
          rts
          ENDPART
          >PART 'bootsektortest'
bootsektortest:
;out:
;d0.w=$1234, wenn Bootsektor ausfÅhrbar
          movem.l   d1-a6,-(sp)
          lea       bootsektor(pc),a0
          moveq     #0,d0
          move.w    #512/2-1,d1
ausfÅhrbarteststart:
          add.w     (a0)+,d0
          dbra      d1,ausfÅhrbarteststart
          movem.l   (sp)+,d1-a6
          rts
          ENDPART
          >PART 'modifybootsektor'
modifybootsektor:
          lea       bootsektor(pc),a0
          move.w    #$601c,(a0)+   ;bra.s and den Anfang schreiben
          move.l    #"ANIM",(a0)+  ;statt "Loader"
          move.w    #"AL",(a0)+
          lea       22(a0),a0      ;die Bootsektorinformationen Åberspringen
          lea       filenamebuffer(pc),a1
          lea       prgfile(pc),a2
          moveq     #0,d0
          move.b    filenamebuffer0+1(pc),d0
          bra.s     copyfilenamedbra
copyfilenamestart:move.b (a1)+,(a2)+
copyfilenamedbra:dbra d0,copyfilenamestart
          clr.b     (a2)+          ;Endekennung eigentlich unnîtig hier

          lea       pathnamebuffer(pc),a1
          lea       directory(pc),a2
          moveq     #0,d0
          move.b    pathnamebuffer0+1(pc),d0
          bra.s     copypathnamedbra
copypathnamestart:move.b (a1)+,(a2)+
copypathnamedbra:dbra d0,copypathnamestart
          clr.b     (a2)+          ;Endekennung!

          lea       bootsektorprogramm(pc),a1
          lea       bootsektorprogrammende(pc),a2
copybootprogrammagain:
          move.w    (a1)+,(a0)+
          cmpa.l    a2,a1
          blt.s     copybootprogrammagain

          lea       bootsektor(pc),a0
          moveq     #1,d0          ;.w Bootsektor soll ausfÅhrbar sein
          moveq     #-1,d1         ;.w Diskettentyp nicht Ñndern
          moveq     #-1,d2         ;.l Seriennummer nicht Ñndern
          bsr       protobt

          rts
          ENDPART
          >PART 'bootsektorprogramm'
bootsektorprogramm:
unbenutztertrap EQU $0600
trap13    EQU $b4

          cmpi.l    #$deadface,unbenutztertrap.w ;wird der Loader destalliert?  Dann auch nicht nochmal laden!
          beq.s     loaderschoninstalliert

          cmpi.w    #"AM",$060a.w  ; der Loader ist schon resetfest installiert!
          beq.s     loaderschoninstalliert

          pea       bootsektortext(pc)
          move.w    #9,-(sp)
          trap      #1
          addq.l    #6,sp

          move.w    $ffff8240.w,-(sp)
          move.w    #$60,$ffff8240.w
          moveq     #anzahlflashvbls-1,d1
wartexvbls:move.w   $0466+2.w,d0
samevbl:  cmp.w     $0466+2.w,d0
          beq.s     samevbl
          dbra      d1,wartexvbls
          move.w    (sp)+,$ffff8240.w

          lea       oldtrap13(pc),a0
          move.l    trap13.w,(a0)

          lea       newtrap13copystart(pc),a0
;          movea.l   $044e.w,a1
;          lea       32000(a1),a1
          lea       $0600.w,a1
          move.l    a1,trap13.w    ;installieren des neuen TRAP #13
          addi.l    #newtrap13-newtrap13copystart,trap13.w
          lea       newtrap13ende(pc),a2
copyagaintrap13:
          move.l    (a0)+,(a1)+
          cmpa.l    a2,a0
          blt.s     copyagaintrap13

loaderschoninstalliert:
          rts
;*********
newtrap13copystart:
          DC.L "XBRA"              ;XBRA-Scheiûe machen (Wir wollen ja korrekt sein)
          DC.L "AM13"              ;ANIMAL MINE BIOS-Kennung
oldtrap13:DC.L 0                   ;hier wird der alte Vektor auch zwischengespeichert
newtrap13:
;Register d0-d2/a0-a2 dÅrfen ja zerstîrt werden!!!
;Jetzt muû erst geschaut werden, auf welchem Stack die Parameter liegen:
          btst      #5,(sp)        ;Supervisormodus abtesten
          bne.s     eswarschonsupermode
          move      usp,a0
          bra.s     newtrap13start
eswarschonsupermode:
;Der Prozessor war schon vor dem TRAP im Supervisormodus:
          lea       6(sp),a0       ;der alte Stack lag 6 Bytes hîher (beim 68000er)
          tst.w     $059e.w        ;_longframe Systemvariable (0=68000er Exceptionformat,<>0=68020/030)
          beq.s     newtrap13start ;ist ein 68000er
          addq.l    #2,a0          ;ist ein 68020 oder 68030, dann lag der Stack noch 2 Bytes hîher
newtrap13start:

          cmpi.w    #$0b,(a0)      ;Kbshift
          beq.s     newkbshift

originalroutine:

;FÅr alle anderen Funktionen wird die Originalroutine benutzt.
          move.l    oldtrap13(pc),-(sp)
          rts                      ;und Ansprung der Originalroutine
newkbshift:
          tst.w     2(a0)          ;wird Kbshift gesetzt?
          bpl.s     originalroutine
;Jetzt werden die Shift- und Alternate etc.-Tasten abgfragt:

          move.w    #%1000,d0      ;Druck von Alternate wird simuliert
          move.l    oldtrap13(pc),trap13.w

nachfunktionsabfrage:
          rte                      ;und raus aus dem Trap...
newtrap13ende:
bootsektortext:
          DC.B "E            pANIMAL MINE 1993q",13,10,10
          DC.B "         VIRUS FREE BOOTSECTOR!",13,10,10,10,10,10,10,10
          DC.B "      Don't erase this bootsector!",13,10
          DC.B 0
          EVEN
prgfile:  DS.B 13
directory:
          REPT 35
          DC.B "ANIMAL MINE! "
          ENDR
bootsektorprogrammende:
          ENDPART
          DATA
          >PART 'data'
yesnochar:DC.B 0,13,10,0
zeichen:  DC.B 0,":",13,10,0
starttext:
          DC.B "Ep            ANIMAL MINE 1993            q",13,10
          DC.B "(C) SETHOS of ANIMAL MINE, 30.08.1993",13,10,10
          DC.B "This program writes a bootsector to disc",13,10
          DC.B "which simluates a pressing of the ALTER-",13,10
          DC.B "NATE key.",13,10
          DC.B "Whenever your GSC-bootsector has been   ",13,10
          DC.B "destroyed by a virus, use this programme",13,10
          DC.B "to recreate the bootsector.             ",13,10,10
          DC.B "(Control + C for exit...)",13,10
          DC.B "p                                        q",13,10,10
          DC.B 0
modifytext:DC.B "Please enter drive where bootsector",13,10
          DC.B "will be modified (A/B): ",0
fehlertext:DC.B "pERROR!q Key for restart.",13,10,0
bootausfÅhrbartext:DC.B "Bootsector is pEXECUTABLEq!",13,10
          DC.B "Continue (y/n)? ",0
readytext:DC.B "Ready modifying bootsector.",13,10
          DC.B "Want to start again (y/n)? ",0
          EVEN
pathnamebuffer0:DC.B 255,0
pathnamebuffer:DS.B 256
filenamebuffer0:DC.B 13,0
filenamebuffer:DS.B 13
          ENDPART
          BSS
bootsektor:DS.B 512*2
          END
