
; Programm  : TeleOffice-Druckertreiber fÅr DMC Calamus 1.09N und SL
; Version   : 1.0
; Edition   : 3
; Autoren   : Michael Bernards
;             Jens Briesofsky
; Assembler : Turbo-C MAS
; Status    : Version 1.0
;


;                               Statusmeldungen
E_BREAK     =   1             ; Abbruch druch User
E_OK        =   0             ; Alles OK
E_NOMEM     =  -1             ; nicht genug Speicher vorhanden
E_INTERN    =  -2             ; interner Fehler
E_PRERR     =  -3             ; special printer error
E_TOUT      =  -4             ; printer timeout
E_POFF      =  -5             ; printer offline
E_PAOUT     =  -6             ; paper out

LINECOUNT   =  20             ; alle 20 Scanlines ein UNDO-Test
TIMEOUT     =  6000           ; 30 Sekunden Timeout

   text

indicator:     dc.b    "CALAMUSCPD"   ; Kennung
start:         link     a6,#0
               movem.l  d1-a5,-(a7)
               moveq.l  #E_OK,d0
               lea      functab(pc),a0
               move     8(a6),d1       ; Command auswerten
               lsl      #2,d1
               add      d1,a0
               move.l   (a0),a0
               jmp      (a0)

return:        movem.l  (a7)+,d1-a5    ; RÅcksprung
               unlk     a6
               rts

functab:       dc.l    return,get_info,pr_init,pr_reset,pr_page,return
               dc.l    get_error,return,return,return,return


;----------------------- GET DRIVER INFO ----------------------------------

get_info:
				move.l	#prt_info,d0
				move.l	fax_out,a0
				tst.l	cj
				bne		refresh_info
				bsr		getcj

				move.l	#error1,error
				moveq	#E_PRERR,d0					; internal error
				move.l	cj,a0
				tst.l	cj
				beq		return

i_loop:			tst.l	(a0)					; NULL-Cookie
				beq		return

				cmp.l	#'FxOP',(a0)
				beq		i_found
				addq.l	#8,a0
				bra		i_loop

i_found:		move.l	4(a0),fax_out			; pointer sichern
				move.l	4(a0),a0
refresh_info:
				move.l	#error2,error			; offline
				tst.w	2(a0)					; fax_ready
				beq		return
				move.l	#prt_info,d0

				lea		restab,a1
				move.w	4(a0),(a1)
				move.w	6(a0),2(a1)
				lea		formtab,a1
				move.l	8(a0),d1
				mulu	#7200,d1
				divu	#254,d1					; mm/10 -> dp
				ext.l	d1
				move.l	d1,24(a1)
				move.l	12(a0),d1
				mulu	#7200,d1
				divu	#254,d1
				ext.l	d1
				move.l	d1,20(a1)
				bra		return

cj:				dc.l	0

getcj:			move.l	$5a0.w,cj
				rts

               bra      return

;------------------------- PRINT INIT CODES ------------------------------

pr_init:		move.l	fax_out,a0
				move.l	22(a0),a0
				moveq.l	#0,d0
				moveq.l	#0,d1
				moveq.l	#0,d2
				clr.w	-(a7)
				jsr		(a0)
				addq.l	#2,a7
				ext.l	d0
				tst.w	d0
				beq		return
				move.l	#error2,error
				clr.l	d0
				move.w	#E_PRERR,d0
               bra      return

;----------------------------- PRINT RESET CODE ---------------------------

pr_reset:		move.l	fax_out,a0
				move.l	42(a0),a0
				jsr		(a0)
				move.l	fax_out,a0
				move.l	26(a0),a0
				jsr		(a0)
				clr.l	d0
				bra      return

;------------------------------ PRINT PAGE --------------------------------

pr_page:		move.l   10(a6),a0      ; Pointer auf Parameter holen
				move.l   (a0),a1        ; a1 = Pointer auf Seitenbuffer
				move.l   4(a0),d0       ; d0 = Scanlinebreite in Pixel
				move.l   16(a0),d1      ; d1 = Anzahl Scanlines
				move.l	d0,d2
				lsr.l	#4,d2			; width in words
				move.l	a1,a0
				move.l	fax_out,a1
				move.l	30(a1),a1
				jsr		(a1)

               bra      return

;--------------------------- GET FEED ----------------------------------

get_feed:      clr.l    d0
               move     #-1,d0         ; alle erlaubt !
               bra      return

get_error:		move.l	error,d0
				bra		return

;..................... PRINTER INFORMATION TABLE ........................

   data

prt_info:      dc.w    1000           ; Version 1.0
               dc.l    %10000000000000000000000100010010   ; Flags:
;                                        Druck darf stÅckweise erfolgen
;                                        Zeilenvorschubfunktion enthalten
;                                        Abbruch mit UNDO mîglich
;                                        Anzahl der Kopien einstellbar
;                                        Centronics-Ausgabe mîglich
               dc.w    99             ; Max. Anzahl von Kopien

               dc.w    1              ; 6 Seitenformate
p_formats:     dc.l    formtab        ; Pointer auf Seitenformattabelle
               dc.w    1              ; 4 Auflîsungen
p_restab:      dc.l    restab         ; Pointer auf Auflîsungstabelle
               dc.w    1              ; 3 Feeds
p_feedtab:     dc.l    feedtab        ; Pointer auf Feed-Tabelle
               dc.l    0              ; reserved long
               dc.b    "Tele Office FAX  V1.0",0   ; Name
               even

;----------------------- SEITENFORMATE

formtab:

;----------------------- 
               dc.w    0              ; Metric Index dp
               dc.w    1              ; Format A4
               dc.l    0              ; Seitenbreite und Hîhe
               dc.l    0
               dc.l    0            ; Linker Rand in dp
               dc.l    0            ; Oberer Rand in dp
               dc.l    6346           ; Maximale Breite in dp 
               dc.l    8972           ; Maximale Hîhe in dp
               dc.l    0              ; keine feste Anzahl horz. und vert.
               dc.l    0              ;  Pixels
               dc.w    16              ; horz. und vert. Modulo-Wert
               dc.w    16
               dc.w    1              ; Left margin modulo
               dc.w    1              ; Top margin modulo
               dc.l    %00000000000000000000000000000000
               dc.l    0              ; reserved long

;--------------------- AUFLôSUNGEN

restab:                                ; Auflîsungen
               dc.w    196
               dc.w    196
feedtab:
               dc.w    0
               dc.l    feedname1

feedname1:     dc.b    "TKR Faxmodem",0

error1:			dc.w	1
				dc.w	29
				dc.b	"FAX_OUT ist nicht installiert",0

error2:			dc.w	1
				dc.w	38
				dc.b	"Es wurde noch kein EmpfÑnger angegeben",0

fax_out:		dc.l	0

   bss
   even

error:			ds.l	1

   end                                ; das war's !

