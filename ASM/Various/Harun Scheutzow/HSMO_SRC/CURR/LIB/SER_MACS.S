;SER_MACS.S
;Makros fÅr serielle BIOS/GEMDOS-Treiber
;Viele Funktionen sind fÅr alle Treiber gleich und gleichermaûen
;optimal realisierbar. Sie werden hier zusammengefaût.

;####### vor der Macro-Nutzung muû IOREC.S included worden sein ########

;Der Namensvorsatz ist
;usm_ = universal serial macro oder
;usmc_ for the subroutine generating macros

;History am Ende



usm_bcostat	MACRO
;Parameter: iorec_adr
;bcostat, Ausgabestatus
;iorec_adr ist die IOREC-Adresse in einer beliebigen, auch read-only,
;Adressierungsart, z.B. my_iorec, my_iorec(pc), (a0). Zum vollstÑndigen
;bcostat fehlt dem Macro nur das rts am Ende.
;Da bconout immer mindestens einen freien Platz im Puffer braucht,
;sagt bcostat schon voll, wenn nur noch ein Platz frei ist.
;Wird bconout dann doch aufgerufen, verhÑlt es sich wie bei vollem Puffer:
;Es wartet bis das Zeichen raus ist.
	move.w	ioo_trp+\1,d1	;freien Platz berechnen, Lesezeiger
	sub.w	ioo_twp+\1,d1	;minus Schreibzeiger
	bhi.s	.\@noc		;keine Korrektur
	add.w	ioo_tbl+\1,d1	;PufferlÑnge dazu
.\@noc:	subq.w	#3,d1		;Differenz muû >=3 sein fÅr frei
	scc	d0		;ja, noch mind. 2 PlÑtze frei
	ext.w	d0
	ext.l	d0
	ENDM



usm_bconstat	MACRO
;Parameter: iorec_adr
;bconstat, Eingabestatus
;iorec_adr ist die IOREC-Adresse in einer beliebigen, auch read-only,
;Adressierungsart, z.B. my_iorec, my_iorec(pc), (a0). Zum vollstÑndigen
;bconstat fehlt dem Macro nur das rts am Ende.
          move.w    ioo_rrp+\1,d1
          cmp.w     ioo_rwp+\1,d1
          sne       d0
          ext.w     d0
          ext.l     d0
          ENDM 



usm_fwrite	MACRO
;Parameter: buffer_transmit
;Fwrite fÅr Schnittstellen mit dem Åblichen Ringpuffer, der Åber IOREC
;verwaltet wird. Zu einem kompletten Fwrite fehlt dem Macro das Laden
;der IOREC-Adresse nach A2 am Anfang und das rts am Ende. A2 enthÑlt bis
;zum Aufruf von buffer_transmit die IOREC-Adresse. buffer_transmit ist
;der Name eines Macros, das das Senden aus dem Ringpuffer startet.
;Es darf D0-D2/A0-A2 killen und kann in D3-D7/A3-A6 beliebig Parameter
;erhalten, wenn das Drumherum um usm_fwrite so eingerichtet ist.
;öblicherweise ist buffer_transmit ein Aufruf in bconout rein.
;Fwrite-Parameter sind Mag!X-mÑûig, Registernutzung:
;in:   A0: Zeiger auf Filedeskriptor oder 0
;      A1: LONG buffer
;     (A2: Adresse IOREC - eigene Definition, nicht MagiC -)
;      D0: LONG len
;out:  D0: Anzahl wirklich geschriebener Byte oder Fehlercode
;kill: D0-D2/A0-A2
;       Das ist MagiC-Konvention und andere Register werden auch nicht
;       benutzt.
          moveq.l   #0,d1            ;Bit31-16 muû 0 bleiben
          move.w    ioo_tbl(a2),d2   ;PufferlÑnge
;freier Platz gilt fÅr nichtblockierende AusfÅhrung
          move.w    ioo_trp(a2),d1   ;freien Platz berechnen, Lesezeiger
          sub.w     ioo_twp(a2),d1   ;minus Schreibzeiger
          bhi.s     .\@fw0		;keine Korrektur
          add.w     d2,d1		;PufferlÑnge dazu
.\@fw0:   subq.l    #1,d1
          bpl.s     .\@fwxx
          moveq.l   #0,d1            ;Sicherheit, sollte nie negativ werden
.\@fwxx:              ;Anzahl freier PlÑtze in D1
          cmp.l     d0,d1
          bcc.s     .\@fw1             ;Minimum bilden
          move.l    d1,d0
.\@fw1:     
	move.l	d0,-(sp)		;sichern als returnvalue, setzt Flags!
	beq.s	.\@fwend		;nichts Åbertragen
;D0.W Anzahl Bytes fÅr Transfer (>=1), .W reicht wegen PufferlÑngenbeschrÑnkung

;Wieviel Bytes sind es bis Pufferende (wrap-around)?
          move.w    ioo_twp(a2),d1	;alter Schreibzeiger
	addq.w	#1,d1	;Index fÅr Datenablage
	sub.w	d1,d2	;D2.W: Byteanzahl bis wrap-around
	beq.s	.\@fwi0	;wrap-around! d.h. alles in einem Block danach
;Es passen D2.W (>0) Bytes vor wrap-around.
	cmp.w	d0,d2	;ist D0.W  <= D2.W ?
	bcc.s	.\@fwet	;ja, alles vor warp-around, in einem Block

;Schreibe D2.W Bytes (>0) ab Index D1.L vor wrap-around,
;und D0.W-D2.W (>0) danach.
	sub.w	d2,d0	;D0.W Bytes im zweiten Block schreiben
	subq.w	#1,d2	;wegen dbra
	movea.l	ioo_tba(a2),a0	;Interruptpufferadresse
	adda.l	d1,a0		;D1.Bit31..16 muû noch 0 sein
.\@fwcpc:	move.b	(a1)+,(a0)+	;Byte kopieren
	dbra	d2,.\@fwcpc
;twp-Update im RAM hier unnîtig, da es immer "tbl-1" wÅrde,
;als nÑchstes ab Index 0 geschrieben wird, was folgt.

.\@fwi0:
;D0.W Bytes (>0) ab Index 0 schreiben
	moveq.l	#0,d1		;Index 0
.\@fwet:
;Schreibe einen Block mit D0.W (>0) Bytes ab Index D1.L.
	movea.l	ioo_tba(a2),a0	;Interruptpufferadresse
	adda.l	d1,a0		;addiere Index
	subq.w	#1,d0		;wegen dbra und nÅtzlich fÅr twp
	add.w	d0,d1		;twp-Update, nur im Register
.\@fwcpa:	move.b	(a1)+,(a0)+	;Byte kopieren
	dbra	d0,.\@fwcpa
	move.w	d1,ioo_twp(a2)	;Schreibzeiger (twp) Update im RAM

.\@fwby:    
	\1	;Aufruf Macro buffer_transmit
.\@fwend:
          move.l    (sp)+,d0         ;Byteanz. holen
	ENDM



usm_fread	MACRO
;Parameter: actualize_input_handshake
;Fread fÅr Schnittstellen mit dem Åblichen Ringpuffer, der Åber IOREC
;verwaltet wird. Zu einem kompletten Fread fehlt dem Macro das Laden
;der IOREC-Adresse nach A2 am Anfang und das rts am Ende. A2 enthÑlt bis
;zum Aufruf von actualize_input_handshake die IOREC-Adresse.
;actualize_input_handshake ist der Name eines Macros, das einen eventuell
;eingestellten Handshake in Input-Richtung nach dem Lesen aktualisiert.
;Es darf D0-D2/A0-A2 killen und kann in D3-D7/A3-A6 beliebig Parameter
;erhalten, wenn das Drumherum um usm_fread so eingerichtet ist.
;öblicherweise ist actualize_input_handshake ein Aufruf in bconin rein.
;Fread-Parameter sind Mag!X-mÑûig, Registernutzung:
;in:   A0: Zeiger auf Filedeskriptor oder 0
;      A1: LONG buffer
;     (A2: Adresse IOREC - eigene Definition, nicht MagiC -)
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
;       Das ist MagiC-Konvention und andere Register werden auch nicht
;       benutzt.
          moveq.l   #0,d1            ;Bit31-16 muû 0 bleiben
          move.w    ioo_rbl(a2),d2   ;PufferlÑnge
          move.w    ioo_rwp(a2),d1   ;Schreibz
          sub.w     ioo_rrp(a2),d1   ;Lesez
          bcc.s     .\@fr0
          add.w     d2,d1            ;LÑnge
.\@fr0:               ;D1 = vorhandene Byte
          cmp.l     d0,d1
          bcc.s     .\@fr1
          move.l    d1,d0
.\@fr1:               ;Åbertragbar, <65536 : D0 = min(geforderte, vorhandene)
          move.l    d0,-(sp)         ;sichern als returnvalue, setzt Flags!
          beq.s     .\@frend           ;0 zu Åbertragen -> ende
;D0: Anzahl Bytes fÅr Transfer (>=1)

	move.w	ioo_rrp(a2),d1	;
	addq.w	#1,d1		;read index
	sub.w	d1,d2		;space before wrap-around
	beq.s	.\@fri0		;wrap-around! Read single block after.
	cmp.w	d0,d2		;compare bytes and space
	bcc.s	.\@fret		;Read a single block before wrap-around.
	
;Read D2.W bytes (>0) before wrap-around starting at index D1.L and
;read D0.W-D2.W bytes after wrap-around, starting at index 0.
	sub.w	d2,d0		;D0.W: bytes in second block
	subq.w	#1,d2		;because of dbra
	movea.l	ioo_rba(a2),a0	;interruptbufferaddress
	adda.l	d1,a0		;D1.Bit31.16 must be 0 still
.\@frcpc:	move.b	(a0)+,(a1)+	;copy byte
	dbra	d2,.\@frcpc
;rrp-update in RAM not necessary, because it would become "rbl-1",
;because next action is always reading from index 0.

.\@fri0:
;read D0.W (>0) bytes from index 0
	moveq.l	#0,d1		;index 0
.\@fret:
;read D0.W (>0) bytes from index D1.L
	movea.l	ioo_rba(a2),a0	;interruptbufferaddress
	adda.l	d1,a0		;add index
	subq.w	#1,d0		;because of dbra and useful for rrp
	add.w	d0,d1		;rrp-update, only in register
.\@frcpa:	move.b	(a0)+,(a1)+	;copy byte
	dbra	d0,.\@frcpa
	move.w	d1,ioo_rrp(a2)	;update read index in RAM

	\1			;actualize input handshake
.\@frend:   
          move.l    (sp)+,d0		;returnvalue: number of bytes
	ENDM



usmc_gd_drv_del	MACRO
;Erzeugt die gd_drv_del Routine.

gd_drv_del:         
;Lîsche ein GEMDOS-Device mit Fdelete
;in:   A0	Zeiger auf kompletten Namen
;out:  D0	0 fÅr fehlerfrei (EFILNF wird zu fehlerfrei gewandelt!)
;        <>0 ist Fehlercode.
;      Z-Flag entsprechend D0-Inhalt gesetzt
;kill: A0-A2/D0-D2
	move.l	a0,-(sp)		;Zeiger auf Namen
	move.w	#$41,-(sp)	;GEMDOS Fdelete
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	beq	.ende	;fehlerfrei
	cmpi.l	#-33,d0
	bne	.ende	;fehlerhaft
	moveq.l	#0,d0	;EFILNF -33 ist auch fehlerfrei
.ende:    
	rts
	ENDM



usmc_gd_drv_ins	MACRO
;Erzeugt die gd_drv_ins Routine.

gd_drv_ins:         
;Installiert ein GEMDOS-device
;in:   A0	Zeiger auf Zeigerblock
;      A1	Zeiger auf Name
;out:  D0	returncode (nur negativ ist ein Fehler!!!)
;      Flags gesetzt (Sign und Z) nach D0-Inhalt
;kill: A0-A2/D0-D2
	move.l	a0,-(sp)	;driver function block
	move.l	a1,-(sp)	;driver name
	move.w	#DEV_M_INSTALL,-(sp)
	move.w	#n_dcntl,-(sp)
	trap	#1	;GEMDOS Dcntl (Mag!X)
	lea	12(sp),sp
	tst.l	d0
	rts
	ENDM



usm_ins_move_high	MACRO
;Parameter: start_of_source,first_behind_source,destination
;Moves memory, used during installation to make room for buffers.
          lea       \1,a0
          lea       \3,a1
          move.l    #\2-\1-1,d0       ;Anzahl Bytes
.\@mv:	move.b    0(a0,d0.l),0(a1,d0.l)
          subq.l    #1,d0
          bpl       .\@mv
	ENDM



usmc_make_buf	MACRO
;generate the make_buf routine

make_buf: 
;put the right buffer length and water mark values into IOREC
;in:   D0.L length of buffer in byte (or $80000000 default-falg)
;      A0   pointer to receive or transmit part of IOREC
;out:  /
;kill: D0,D1
          move.l    #256,d1          ;Standardgrîûe (unbedingt long)
          andi.l    #$fffffffe,d0    ;auf gerade LÑnge
          cmpi.l    #$80000000,d0    ;ungÅltig?
          beq       .st_len          ;ja, Standard
          cmpi.l    #65534,d0        ;Max.grîûe Åberschritten?
          bhi       .st_len          ;ja
          cmpi.l    #16,d0           ;Min.grîûe unterschritten?
          bcs       .st_len          ;ja
          move.w    d0,d1            ;nutzerdefinierte Grîûe
.st_len:  move.l    first_unresi,ioo_rba(a0)      ;Adresse
          add.l     d1,first_unresi  ;reserviere Platz
          move.w    d1,ioo_rbl(a0)   ;LÑnge
          clr.l     ioo_rrp(a0)      ;lîsche beide Zeiger
          move.w    d1,d0
          lsr.w     #2,d1            ;untere Marke bei 1/4
          move.w    d1,ioo_rlw(a0)
          sub.w     d1,d0            ;obere Marke bei 3/4
          move.w    d0,ioo_rhw(a0)
          rts       
	ENDM


;History:
;1997-03-15 die gd_drv_* Macros eingefÅgt
;1997-07-27 added usm_fread, changed wrong out:D0 description in usm_fwrite
