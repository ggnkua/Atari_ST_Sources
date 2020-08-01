; Hardwarenahe Funktionen des LPT1- Treibers

     SUPER

     XREF kernel

     XDEF lpt_dev_write
     XDEF lpt_dev_stat
     XDEF handle_busy

	INCLUDE "d:\xkaos\docs3\mgx_xfs.inc"

     TEXT

gpip              EQU $fffffa01           ;GPIP-Data-Register
giselect          EQU $ffff8800           ;Chip-Register anwÑhlen
isrb              EQU $fffffa11           ;Interrupt-In-Service-Register B

E_OK           EQU    0       ;   0     kein Fehler
ERROR          EQU   -1       ;  -1     allgemeiner Fehler
EDRVNR         EQU   -2       ;  -2     Laufwerk nicht bereit
EUNCMD         EQU   -3       ;  -3     unbekanntes Kommando
E_CRC          EQU   -4       ;  -4     PrÅfsummenfehler
EBADRQ         EQU   -5       ;  -5     Kommando nicht mîglich
E_SEEK         EQU   -6       ;  -6     Spur nicht gefunden
EMEDIA         EQU   -7       ;  -7     unbekanntes Medium
ESECNF         EQU   -8       ;  -8     Sektor nicht gefunden
EPAPER         EQU   -9       ;  -9     kein Papier mehr
EWRITF         EQU  -10       ; -$A     Schreibfehler
EREADF         EQU  -11       ; -$B     Lesefehler
EWRPRO         EQU  -13       ; -$D     Schreibschutz
E_CHNG         EQU  -14       ; -$E     unerlaubter Diskwechsel
EUNDEV         EQU  -15       ; -$F     unbekanntes GerÑt
EBADSF         EQU  -16       ; -$10    Verify- Fehler
EOTHER         EQU  -17       ; -$11    Disk wechseln (A<->B)

EINVFN         EQU  -32       ; -$20    ungÅltige Funktionsnummer
EFILNF         EQU  -33       ; -$21    Datei nicht gefunden
EPTHNF         EQU  -34       ; -$22    Pfad nicht gefunden
ENHNDL         EQU  -35       ; -$23    keine Handles mehr
EACCDN         EQU  -36       ; -$24    Zugriff nicht mîglich
EIHNDL         EQU  -37       ; -$25    ungÅltiges Handle
ENSMEM         EQU  -39       ; -$27    zuwenig Speicher
EIMBA          EQU  -40       ; -$28    ungÅltiger Speicherblock
EDRIVE         EQU  -46       ; -$2E    ungÅltiges Laufwerk
ENSAME         EQU  -48       ; -$30    nicht dasselbe Laufwerk
ENMFIL         EQU  -49       ; -$31    keine weiteren Dateien
ELOCKED        EQU  -58       ;          MiNT: GerÑt blockiert
ENSLOCK        EQU  -59       ;          MiNT: Unlock- Fehler
ERANGE         EQU  -64       ; -$40    ung. Dateizeiger- Bereich
EINTRN         EQU  -65       ; -$41    interner Fehler
EPLFMT         EQU  -66       ; -$42    UngÅltiges Programmformat
EGSBF          EQU  -67       ; -$43    Speicherblock vergrîûert
EBREAK         EQU  -68       ; -$44    KAOS: mit CTRL-C abgebrochen
EXCPT          EQU  -69       ; -$45    KAOS: 68000- Exception


**********************************************************************
*
*

unsel:    DC.L 0
appl:     DC.L 0

handle_busy:
 tst.l    unsel
 beq.b    hb_ende
 tst.l    appl
 beq.b    hb_ende
 movem.l  d0-d2/a0-a2,-(sp)

 moveq    #1,d0
 move.l   unsel(pc),a0
 clr.l    unsel                         ; Interrupt deaktivieren
 move.l   d0,(a0)                       ; als eingetroffen markieren

 move.l   appl(pc),a0
 move.l   kernel(pc),a1
 move.l   mxk_appl_IOcomplete(a1),a1
 jsr      (a1)
 movem.l  (sp)+,d0-d2/a0-a2
hb_ende:
 move.b   #$fe,isrb                     ; service- Bit lîschen
 rte


/******************************************************************
*
* schreiben:
* long lpt_dev_write  (MX_DOSFD *f, void *buf,  long len  );
*
******************************************************************/

lpt_dev_write:
 movem.l  d7/d6/a6,-(sp)
 move.l   a1,a6			; a6 = buf
 move.l   d0,d7			; d7 = count
 moveq    #0,d6
 bra      dw_nxt
dw_loop:

* Interrupt sperren und Bedingung testen

 move     sr,d1
 ori      #$700,sr
 btst.b   #0,gpip                  ; MFP-BUSY (parallele Schnittstelle)
 beq.b    dw_send                  ; nein, abschicken

* Interrupt aufsetzen

 pea      dev_unsel(pc)
 move.l   kernel,a1
 move.l   mxk_act_appl(a1),a0
 move.l   (a0),appl
 move.l   sp,unsel

* Interrupt freigeben

 move.w   d1,sr

* Auf Interrupt warten

 move.l   mxk_evnt_IO(a1),a2
 move.l   sp,a0
 move.l   #500,d0                  ; 10s
 jsr      (a2)
 addq.l   #4,sp
 tst.l    d0                       ; OK ?
 beq      dw_end                   ; nein
 bra      dw_loop                  ; ##### ??? ######

dw_send:
 lea      giselect,a1              ; Soundchip: Register selektieren/lesen
 lea      2(a1),a2                 ; Soundchip: Register schreiben
 move.b   #7,(a1)                  ; Register 7 auswÑhlen
 move.b   (a1),d0                  ; Wert holen
 ori.b    #%11000000,d0            ; Port A (Centr.Strobe) und
 move.b   d0,(a2)                  ; Port B (Centr.Data) auf Ausgang
 move.b   #15,(a1)                 ; Register 15 wÑhlen: Port B
 move.b   (a6)+,(a2)               ; Zeichen ausgeben
 move.b   #14,(a1)                 ; Register 14 wÑhlen: Port A
 move.b   (a1),d0
 andi.b   #%11011111,d0            ; Strobe low
 move.b   d0,(a2)                  ; Strobe low -> Drucker
;hier ggf. Verzîgerung
 ori.b    #%00100000,d0            ; Strobe high
 move.b   d0,(a2)                  ; Strobe high -> Drucker
 move     d1,sr


; move.l  #1000,d2                 ; #### ??? #####
;dw_delay:
; subq.l  #1,d2
; bne.b   dw_delay

 addq.l   #1,d6

dw_nxt:
 subq.l   #1,d7
 bcc      dw_loop
dw_end:
 move.l   d6,d0
 movem.l  (sp)+,d6/d7/a6
 rts


/******************************************************************
*
* Status:
* long lpt_dev_stat   (MAGX_FD *f, int  rwflag, void *unsel, long apcode)
*
******************************************************************/

lpt_dev_stat:
 tst.w    d0             ; lesen ?
 beq      st_err         ; ja, Fehler

 btst.b   #0,gpip        ; MFP-BUSY (parallele Schnittstelle)
 beq.b    st_ok          ; nein, bereit

 tst.l	d1
 beq		st_ende		; wollte Polling, gib 0 zurÅck

 move.l   a1,unsel
 move.l   d1,appl
 move.l   #dev_unsel,d0
 bra      st_ende

st_ok:
 moveq    #1,d0
 bra.b    st_ende
st_err:
 moveq    #EWRITF,d0

st_ende:
 move.l   a1,d1
 beq.b    st_e2
 move.l   d0,(a1)
st_e2:
 rts


**********************************************************************
*
* void dev_unsel( a0 = long *unselect, a1 = void *apcode );
*
*

dev_unsel:
 clr.l    unsel
 clr.l    appl
 clr.l    (a0)
 rts
