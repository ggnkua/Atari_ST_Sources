;
;  VIR_SPY  V 1.4a
;  by  TSE
;  Gerrit Gehnen  
;  (c) 1992 MAXON Computer GmbH
;
; Viren-Spion : Protokolliert alle Versuche, die Gemdosfunktionen
; FOPEN, FCREATE, PEXEC,SFIRST zu benutzen auf dem Drucker mit.
; Dadurch kann man leicht Zugriffe auf fremde Dateien ( Infektionen )
; feststellen
;
; Ausgabe:      FOPEN:  Read:   R Filename
;                       Write:  W Filename
;                       Update: U Filename
;               FCREATE:        C Filename
;               PEXEC:          E Filename (nur bei Load'n Go und Load)
;               SFIRST:         S Filename
;
; Kann durch nochmaligen Aufruf ein- und ausgeschaltet werden.
;
; Versionshistory (wen's interessiert):
; 1.0 (MÑrz 88) : erste LauffÑhige Version
; 1.1 (April 88): Programm verkÅrzt und Deaktivierer mittels Zusatzprogramm
; 1.2    ''     : SFIRST mit aufgenommen
; 1.3 (3.7.88)  : Zusatzprogramm entfÑllt
; 1.4 (17.12.88): XBRA-Protokoll
; 1.4a (30.1.89): XBRA-Installation verbessert und berichtigt

SUPER

FOPEN     equ $3d
FCREAT    equ $3c
EXEC      equ $4b
SFIRST    equ $4e
P_TERMRES equ $31




DEVICE    equ 0                         ; Devicenummer: 0=Drucker,2=Schirm

CR        equ 13
LF        equ 10

                text
start:  bra             install
aktiv_flag:
                dc.w    0                       ; Programmeigenes Flag fÅr
                                                        ; Aktivierungsfunktion, kann via
                                                        ; XBRA extern manipuliert werden

                dc.b    'XBRA'          ; XBRA-Formalismus
                dc.b    '4SPY'
oldvect:ds.l    1


patch:  movea.l sp,a0                   ; Untersuche, ob Aufruf aus dem
                btst    #5,(a0)                 ; Supermodus stattfand
                beq             from_user
                addq.l  #6,a0                   ; ja: Addiere Offset
                bra             is_it_me
from_user:
                move.l  usp,a0

is_it_me:
                cmpi.w  #0,aktiv_flag   ; Darf ich Åberhaupt ?
                bne             exit
                cmpi.w  #FOPEN,(a0)             ; Aber ja doch !
                beq             los_op                  ; Bin ich denn wirklich gemeint ?
                cmpi.w  #FCREAT,(a0)
                beq             los_cr
                cmpi.w  #EXEC,(a0)
                beq             los_ex
                cmpi.w  #SFIRST,(a0)
                beq             los_sf
                bra             exit
                
los_ex: cmpi.w  #0,2(a0)                ; Exec wurde aufgerufen:
                beq             con_ex                  ; Ermittle, ob Load'n Go
                cmpi.w  #3,2(a0)                ; oder Load gemeint ist
                bne             exit                    ; wenn nicht, dann war's wohl nix
con_ex: move.b  #'E',d0                 ; setze Moduszeichen
                movea.l 4(a0),a0                ; und Filenamen
                bra             druckstat

los_cr: move.b  #'C',d0                 ; Create wurde aufgerufen:
                bra             loscont                 ; setze Modus auf 'C' und gib
                                                                ; Filenamen weiter

los_sf: move.b  #'S',d0                 ; Sfirst wurde aufgerufen:
                                                                ; setze Modus auf 'S' und gib
loscont:movea.l 2(a0),a0                ; Filenamen weiter
                bra             druckstat

los_op: move.l  d1,-(sp)                ; Open wurde aufgerufen:
                move.w  6(a0),d0                ; Ermittle Modus
                movea.l 2(a0),a0                ; Ermittle Adresse des Namens
                move.b  #'W',d1                 ; Setze Modus entsprechend dem
                cmpi.w  #1,d0                   ; Aufruf
                beq             druckd1
                move.b  #'R',d1
                cmpi.w  #0,d0
                beq             druckd1
                move.b  #'U',d1

druckd1:move.b  d1,d0                   ; Gib das Moduszeichen in d1 aus 
                move.l  (sp)+,d1
druckstat:
                bsr             druckchar               ; Alles etwas umstÑndlich,
                move.b  #' ',d0                 ; aber dafÅr flexibel...
                bsr             druckchar               ; (Hyper-)Space ausgeben
                bsr             druckstring
exit:   move.l  oldvect,-(sp)   ; .. und schon fertig
                rts                                             ; RÅcksprung in die Orginal-
                                                                ; GEMDOS Routine

druckchar:          
                movem.l d0-d2/a0-a2,-(sp)       ; Register retten
                move.w  d0,-(sp)
                move.w  #DEVICE,-(sp)   ; und raus damit
                move.w  #3,-(sp)
                trap    #13
                addq.l  #6,sp
                movem.l (sp)+,d0-d2/a0-a2
                rts       

druckstring:        
                move.b  (a0)+,d0                ; Gib String, der mit \0 beendet wird
                cmpi.b  #0,d0                   ; und an Adresse (a0) steht aus
                beq             loopend
                bsr             druckchar
                bra             druckstring
loopend:move.b  #CR,d0                  ; Jetzt nur noch in neue Zeile
                bsr             druckchar               ; gehen..
                move.b  #LF,d0
                bsr             druckchar
                rts

install:pea.l   supinst                 ;Supermodus zum Vektorzugriff
                move.w  #38,-(sp)
                trap    #14
                addq.l  #6,sp
                move.w  aktiv_flag,d0   ; falls ich schon installiert bin,
                cmpi.w  #0,d0
                beq             nicht_inst
                clr.w   -(sp)
                trap    #1                              ; dann wars das schon.


supinst:lea.l   33*4,a1                 ; Inhalt des Gemdosvektors
                movea.l (a1),a0                 ; holen und auf XBRA untersuchen
                movea.l a0,a2
find_next:
                cmpi.l  #'4SPY',-8(a2)  ; Bin ich schon da ?
                beq             installed               ; ....Leider ja
                cmpi.l  #'XBRA',-12(a2) ; Ist ein anderes XBRA-Programm da?
                bne             war_nix
                move.l  -(a2),a2                ; in der Kette
                bra             find_next               ; PrÅfe nÑchstes Programm

war_nix:move.l  (a1),(oldvect)  ; Kein Vir_spy gefunden !
                move.l  #patch,(a1)
                rts


installed:
                eori.w  #$ffff,-14(a2)  ; Aktivflag im Programm umsetzen
                eori.w  #$ffff,aktiv_flag   ; Eigenes Flag setzen
                rts       


nicht_inst:         
                pea             meldung                 ; Noch nicht installiert !
                move    #9,-(a7)
                trap    #1
                addq.l  #6,a7
                clr.w   -(sp)
                move.l  #install-start+256,-(sp)  ; und resident bleiben !
                move.w  #P_TERMRES,-(sp)    ; Gag: Installationsprogramm
                trap    #1                  ; wird gelîscht !

                data

meldung:dc.b 'VIR-SPY 1.4a installiert',CR,LF
                dc.b 'by TSE (Gerrit Gehnen)',CR,LF
                dc.b '(c) 1992 MAXON Computer GmbH',0

