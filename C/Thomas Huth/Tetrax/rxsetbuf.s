***********************************************
*                  RXSETBUF                   *
*            Reentrante Setbuffer()           *
*       XBIOS Funktionen fÅr den Falcon       *
*      Geschrieben von Thomas Huth, 2000      *
***********************************************

_sysbase    equ $04F2
_longframe  equ $059E
_p_cookies  equ $05A0
frmbase     equ $FFFF8903         ; Frame-Basis-Address
frmend      equ $FFFF890F         ; Frame-End-Address
frmcnt      equ $FFFF8909         ; Frame-Address-Counter
sdmacntr    equ $FFFF8901         ; Sound DMA Control - Register
smodcntr    equ $FFFF8921         ; Sound Mode Control - Register
mwmask      equ $FFFF8924         ; Microwire Mask-Register
mwdata      equ $FFFF8922         ; Microwire Data-Register


            text

start:
            bra.s   init            ; Routine initialisieren


;### Traphandler ###
            dc.b "XBRARXBF"       ; XBRA-Kennung
oldtrap14:  ds.l 1                ; Alter Vektor
mytrap14:
            btst    #5,(sp)         ; Im Supervisormodus?
            beq.s   goxbios         ; Nein: Altes XBIOS anspringen
            lea     6(sp),a0        ; A0 auf Parameter
            tst.w   _longframe.w    ; Ist Prozessor > 68000?
            beq.s   go              ; Nein: A0 ist OK
            addq.l  #2,a0           ; 2 Zusatzparameter mehr
go:         cmpi.w  #131,(a0)+      ; Funktionsnummer testet, A0 auf Daten
            beq.s   setbuffer
goxbios:
            movea.l oldtrap14(pc),a0 ; Alten Vektor laden
            jmp     (a0)            ; und springen



;*** Setbuffer ***
setbuffer:  tst.w   (a0)            ; Setzen des Abspielbuffers?
            bne.s   goxbios         ; Nein: Aufnahmebuffer setzen
            lea     frmbase.w,a1
            addq.l  #3,a0
            move.b  (a0)+,(a1)      ; Base-Adr. setzen
            move.b  (a0)+,2(a1)
            move.b  (a0),4(a1)
            lea     frmend.w,a1
            addq.l  #2,a0
            move.b  (a0)+,(a1)
            move.b  (a0)+,2(a1)
            move.b  (a0),4(a1)
            moveq   #0,d0
            rte
;setrecbuf:
;            moveq   #-1,d0          ; Noch nicht eingebaut
;            rte


; Bis hier ist das Prg resident.

;### Routine initialisieren ###
init:
            clr.l   -(sp)
            move.w  #$20,-(sp)      ; In Supervisor umschalten
            trap    #1
            addq.l  #6,sp
            move.l  d0,save_sp      ; Alten Stack merken

            movea.l _sysbase.w,a0
            move.w  2(a0),d0        ; TOS-Version ermitteln
            cmp.w   #$0400,d0       ; Nur bei TOS V4.00 sinnvoll
            blt     error1

            movea.l $B8.w,a0        ; Alten Xbiosvektor nach A0
xbraloop:   cmpi.l  #'XBRA',-12(a0) ; Nach XBRA-Kette suchen
            bne.s   notyetinstaled
            cmpi.l  #'RXBF',-8(a0)
            beq     error3          ; Wenn schon installiert: Fehlermeldung
            movea.l -4(a0),a0
            bra.s   xbraloop
notyetinstaled:
            move.l  #'_SND',d0      ; Nach Cookie suchen
            bsr.s   hunt_cookie
            tst.l   d0              ; D0 zeigt an, ob Cookie gefunden
            bne.s   error2          ; Kein Cookie = Kein DMA
            btst    #1,d1           ; DMA-Sound mîglich?
            beq.s   error2          ; Wenn kein DMA-Sound, Fehler melden

            move.l  save_sp(pc),-(sp) ; In User-Mode zurÅck
            move.w  #$20,-(sp)
            trap    #1
            addq.w  #6,sp

            pea     mytrap14(pc)
            move.w  #$2E,-(sp)      ; Kennung Xbios
            move.w  #5,-(sp)        ; Routine einklinken
            trap    #13             ; Setexec
            addq.l  #8,sp
            move.l  d0,oldtrap14    ; Alter Wert sichern

            pea     installedtxt(pc)
            move.w  #9,-(sp)        ; Einschaltmeldung ausgeben
            trap    #1
            addq.l  #6,sp
            clr.w   -(sp)
            move.l  #$0100+init-start,-(sp) ; LÑnge residenten Codes
            move.w  #$31,-(sp)
            trap    #1              ; PRG via Ptermres beenden



; Cookie suchen (siehe ST-Magazin 3/90)
hunt_cookie:
            move.l  d0,d2
            move.l  _p_cookies.w,d0
            beq.s   cookie_ex
            movea.l d0,a0
cookie_l:
            move.l  (a0)+,d3
            move.l  (a0)+,d1
            cmp.l   d2,d3
            beq.s   cookie_f
            tst.l   d3
            bne.s   cookie_l
cookie_ex:
            moveq   #-1,d0
            rts
cookie_f:
            moveq   #0,d0
            rts




; Meldung, dass TOS-Version falsch ist
error1:
            pea     err1txt(pc)
            bra.s   error
; Meldung, dass kein DMA-Sound vorhanden
error2:
            pea     err2txt(pc)
            bra.s   error
; Meldung, dass schon installiert
error3:
            pea     err3txt(pc)
; Fehlermeldung ausgeben
error:
            move.w  #9,-(sp)        ; Cconws
            trap    #1
            addq.l  #6,sp
            move.w  #7,-(sp)        ; Crawcin
            trap    #1
            clr.w   (sp)            ; Programm verlassen
            trap    #1


            data

err1txt:    dc.b 13,10,"RXSETBUF ist nur mit TOS 4.00 sinnvoll!",13,10,0
err2txt:    dc.b 13,10,"Kein DMA-Sound vorhanden!",13,10,0
err3txt:    dc.b 13,10,"RXSETBUF ist schon installiert!",13,10,0
installedtxt:
            dc.b 13,10,13,10,"RXSETBUF wurde installiert."
            dc.b 13,10,189," by Thomas Huth, 2000",13,10,0

            bss
save_sp:    ds.l 1
            end
