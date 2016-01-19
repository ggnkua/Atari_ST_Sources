;CPDRV.S - the driver copier
;for GEN-Assembler
;(C) Harun Scheutzow 1997-06-21

;This driver takes the name of a U:\DEV\-device as input and installs
;a copy of this device under a new name and BIOS number.
;The copied driver calls the original driver directly.
;This requires an original driver with byte4.bit0 =1 in the RSVF object.

;Modes of operation:

;hard copy
;It looks for the first and the second given driver by name. It replaces
;the GEMDOS and the BIOS routines table of the second
;driver by a copy of the first driver's tables.
;There is no change in RSVF and no notice given to the drivers.
;It relies on MagiC's and DRVIN's property not to copy the GEMDOS table.


;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;;	OPT	O6+,OW6+


;DRVIN*.PRG or a replacement must be resident.

;	INCDIR "E:\AHSMOD\CURR\LIB\"	;-I on command line used
          INCLUDE "MISC_DEF.S"
          INCLUDE "IOREC.S"
          INCLUDE "ERRNO.S"
	INCLUDE "SER_MACS.S"




;Zum Entwanzen
illegal   MACRO
          DC.w $4afc
          ENDM 

;MagiC 3 Offsets in GerÑtetreiber-Tabelle
mdev_open           = 0
mdev_close          = 4
mdev_read           = 8
mdev_write          = 12
mdev_stat           = 16
mdev_lseek          = 20
mdev_datime         = 24             ;darf 0-ptr sein
mdev_ioctl          = 28
mdev_delete         = 32
mdev_getc           = 36             ;darf 0-ptr sein
mdev_getline        = 40             ;darf 0-ptr sein
mdev_putc           = 44             ;darf 0-ptr sein


          TEXT 

start:    
          bra       starti	;for a short resident part


;Sammlung der Variablen

ENTWANZP = 0

          IFNE ENTWANZP               ;Entwanzungszeug, Logbuch
entw_sptr:          DC.l entw_xxx   ;Zeiger auf Pufferanfang
entw_eptr:          DC.l entw_xxx+$4000          ;Zeiger hinter Puffer
entw_pptr:          DC.l entw_xxx   ;Zeiger auf nÑchste Schreibposition

entw_xxx: 
          REPT ENTWANZP
          DC.l 0
          ENDR 

          ENDC 






entw_ic   MACRO
          cmpa.l    entw_eptr,a0
          bcs       .\~a
          movea.l   entw_sptr,a0
.\~a:     
          ENDM 

;Alle Entwanzmakros Ñndern keine Register
;Zeiger: Schreiben, dann erhîhen

ENTW_MARKE   MACRO
;marke
          IFNE ENTWANZP
;schreibe Marke und Zeit
          move.l    a0,-(sp)
          movea.l   entw_pptr,a0
          move.l    #\1,(a0)+
          entw_ic 
          move.l    _hz_200,(a0)+
          entw_ic 
          move.l    a0,entw_pptr
          movea.l   (sp)+,a0
          ENDC 
          ENDM 

ENTW_MA_L  MACRO
;marke,longval
          IFNE ENTWANZP
;schreibe Marke, Zeit, und LONG (nicht a0)
          move.l    a0,-(sp)
          movea.l   entw_pptr,a0
          move.l    #\1,(a0)+
          entw_ic 
          move.l    _hz_200,(a0)+
          entw_ic 
          move.l    {\2},(a0)+
          entw_ic 
          move.l    a0,entw_pptr
          movea.l   (sp)+,a0
          ENDC 
          ENDM 









;####### folgendes ist schon angepaût

;Original
udevonam: DC.b "U:\DEV\"            ;Vorsatz fÅr Devicename
udevon:   DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0       ;Devicename (13 Zeichen max)

;Copy
udevcnam: DC.b "U:\DEV\"            ;Vorsatz fÅr Devicename
udevcn:   DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0       ;Devicename (13 Zeichen max)


;values for final installation
fi_biosblk:	dc.l	0	;pointer to BIOS routines block


;in/out for supervisor routines
iosu_nam:	dc.l 0	;in: pointer to devicename, without U:\DEV\
iosu_val:	dc.l 0  ;out: value of matching RSVF-object
iosu_ptr:	dc.l 0  ;out: pointer of matching RSVF-object

iosu_nr:	dc.l 0
iosu_dp:	dc.l 0

mamaptr:	dc.l 0  ;MAPTAB-Masterpointer (Bconmap(-2))
	
src_val:	dc.l 0
src_ptr:	dc.l 0

bi_ta:	dc.l 0,0,0,0,0,0	;copy of BIOS routines table


          DC.l 0   ;Sicherheitsabstand

prg_ende:           ;steht hinter immer residenten Teil

first_unresi:       
          DC.l prg_ende             ;fÅr zus. Speichervergabe


;-------------------
;
; nichtresidenter Teil
;

;Konfigurationsdaten
          EVEN 
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger

          DC.b "ORIG: Name des Originals in U:\DEV\, z.B. MODEM2",cr,lf,0
          EVEN 
          DC.w $020e                ;String mit 13 Zeichen (+1 $00) max
ko_onam:  DC.b "MODEM2",0,0,0,0,0,0,0,0

          DC.b "COPY: Name der Kopie in U:\DEV\, z.B. MODEM1",cr,lf,0
          EVEN 
          DC.w $020e                ;String mit 13 Zeichen (+1 $00) max
ko_cnam:  DC.b "MODEM1",0,0,0,0,0,0,0,0

          DC.b "BINR: feste BIOS-Nummer der Kopie, oder 0 fÅr variabel.",cr,lf,0
          EVEN 
          DC.w $0101                ;LONG-Liste mit 1 LONG
ko_cnr:   DC.l 0               ;BIOS-number

          DC.w 0	;end of config


string_ucomp:       
;vergleicht die Zeichenketten ab A0 und A1 miteinander ohne BerÅcksichtigung
;von GROSS/klein, mind. eine muû nullterminiert sein
;in:   A0, A1 Zeiger auf String 0, 1
;out:  D0 -1: gleich bis Ende (identisch, beide sind auch gleich lang)
;          0: total ungleich
;         >0: nur die ersten D0 Zeichen gleich (auch bei Ende eines Strings)
;kill: D1/D2
          moveq.l   #-1,d0
.next:    addq.l    #1,d0
          move.b    0(a1,d0.l),d1
          cmpi.b    #'a',d1
          bcs       .nl1
          cmpi.b    #'z',d1
          bhi       .nl1
          subi.b    #$20,d1
.nl1:     
          move.b    0(a0,d0.l),d2
          cmpi.b    #'a',d2
          bcs       .nl0
          cmpi.b    #'z',d2
          bhi       .nl0
          subi.b    #$20,d2
.nl0:     
          sub.b     d2,d1
          bne       .ende            ;sind ungleich
          tst.b     d2               ;gleich, D2 $00 heiût beide $00
          beq       .null
          add.b     d2,d1            ;D1 wieder herstellen
          bne       .next            ;D1 noch nicht $00 terminiert
          bra       .ende
.null:    
          moveq.l   #-1,d0
.ende:    
          rts       



su_premi: 
;1. Supervisorteil der Installation
;suche RSVF-Cookie
          move.l    #'RSVF',-(sp)
          bsr       cookie_find
          addq.l    #4,sp
          move.l    d0,d3
          moveq.l   #4,d0
          tst.l     d3
          beq       .ende            ;4: Fehler "kein RSVF-Cookie"
;suche Schnittstelle im RSVF
          moveq.l   #8,d0
          movea.l   d3,a0
          move.l    4(a0),d3
          beq       .ende            ;8: Fehler "kein (passendes) RSVF-Objekt"
.r_cs:    
          movea.l   d3,a0
.r_cl:    move.l    4(a0),d3
          bmi       .r_i             ;Schnittstelle
          move.l    (a0),d3          ;war Sonderobjekt
          beq       .ende            ;Ende
          bra       .r_cs            ;nÑchste Liste
.r_i:     
          cmpi.l    #$e0000000,d3    ;es mÅssen Bit31,30,29 =1 sein
          bcc       .r_bh            ; ja
.r_cc:    
          addq.l    #8,a0
          bra       .r_cl            ;weiter in Liste
.r_bh:    
          movea.l   a0,a3            ;sichern
          movea.l   (a0),a0
          movea.l   iosu_nam,a1
          bsr       string_ucomp
          tst.l     d0
          bmi       .r_fd            ;gefunden
          moveq.l   #8,d0            ;wieder Fehlermeldung laden
          movea.l   a3,a0            ;zurÅck
          bra       .r_cc            ;weiter suchen
.r_fd:    
          move.l    d3,iosu_val
          move.l    (a3),iosu_ptr

          moveq.l   #-1,d0           ;alles OK
.ende:    
;D0.L als RÅckgabewert, negativ=OK, >=0 fÅr Fehler-Nummer
          rts       


su_macp:
;Supervisormode
;get a copy of the BIOS routines table of a device
;in:   mamaptr (delivered from Bconmap(-2))
;      iosu_nr BIOS device number
;      iosu_dp destination pointer for copy
;out:  / (copy done)
;kill: ...
	movea.l	mamaptr,a0
          movea.l   (a0),a0		;MAPTAB-address
	move.l	iosu_nr,d0	;BIOS device number
          subq.l    #6,d0		;offset 0 = number 6
          mulu.w    #24,d0		;24 byte per MAPTAB-entry
	lea	0(a0,d0.l),a0
	movea.l	iosu_dp,a1
	moveq.l	#5,d0		;6x 32bit
.cp:      move.l	(a0)+,(a1)+
	dbra	d0,.cp
	rts


su_geov:
;Supervisormode
;overwrite destination GEMDOS routines block - _DANGEROUS_
;RSVF-entries must be checked in advance for pointer to table
;in:   src_ptr pointer to RSVF-name of source
;      iosu_ptr pointer to RSVF-name of destination
;out:  /
;kill: ...
	movea.l	src_ptr,a0
	movea.l	iosu_ptr,a1
	movea.l	-4(a0),a0
	movea.l	-4(a1),a1
	moveq.l	#11,d0	;12x 32bit
.cp:	move.l	(a0)+,(a1)+
	dbra	d0,.cp
	rts


errs0:    DC.b "*** Cookie jar too large",7,7,cr,lf,0
errs4:    DC.b "*** No RSVF-cookie",7,7,cr,lf,0
errs8:    DC.b "*** RSVF-name not matching",7,7,cr,lf,0
errs12:   DC.b "*** Fopen-Error",7,7,cr,lf,0
errs16:   DC.b "*** No Fcntl TIOCFLUSH Nr.1",7,7,cr,lf,0
errs20:   DC.b "*** Baudrate not available",7,7,cr,lf,0
errs24:   DC.b "*** 8N1 & no handshake not available",7,7,cr,lf,0
errs28:   DC.b "*** Direct way impossible",7,7,cr,lf,0
          EVEN 
err_ptr:  DC.l errs0,errs4,errs8,errs12,errs16,errs20,errs24,errs28


;Installationssubroutinen erzeugen
	usmc_gd_drv_del
	usmc_gd_drv_ins


starti:
;Installation
          bsr       prints
          DC.b $1b,"p DRIVER COPIER ",$1b,"q",cr,lf
          DC.b "(C) Harun Scheutzow 1997-06-22",cr,lf,0
          EVEN 

 IFNE 0 ;####### MOX
          lea       ko_onam,a0       ;copy Original devicename
          lea       udevon,a1
.omvna:   move.b    (a0)+,(a1)+
          bne       .omvna

          lea       ko_cnam,a0       ;copy Copy devicename
          lea       udevcn,a1
.cmvna:   move.b    (a0)+,(a1)+
          bne       .cmvna

;####### look for the Original device

;1. Supervisorteil der Installation
          pea       su_premi
          move.w    #38,-(sp)        ;XBIOS Supexec
          trap      #14
          addq.l    #6,sp
          tst.l     d0
          bpl       .ma_err          ;Fehlermeldung

;####### copy its data as much as necessary

 ENDC ;####### MOX


	IFNE 0	;##### FIRST TRY
;####### install the Copy, in GEMDOS, RSVF, BIOS

;1.) GEMDOS-Devices lîschen, damit sich eventuell vorhandene alte
;Treiber sauber lîschen kînnen.
          moveq.l   #0,d7            ;Fehler wenn am Ende <>0
          lea       m1_iname,a0      ;MODEM2
          bsr       gd_drv_del
          tst.l     d0
          beq       .gd_ok
          bsr       prints
          DC.b "*** Error: Fdelete failed",bell,bell,cr,lf,0
          EVEN
          bra       init_end        ;Fehler
.gd_ok:   

;2.) here is no hardware to take or to initialize

;3.) GEMDOS-Treiber eintragen.
;############ hier fehlen noch die Fehlerchecks!!!!!######
;sollte aber keine Dcntl-Fehler geben, oder?
          lea       m1_drvr,a0       ;Datenblock
          lea       m1_iname,a1      ;Name
          bsr       gd_drv_ins


;4.) Die Schnittstellen im BIOS/XBIOS eintragen.
	move.l	fi_biosblk,-(sp)	;pointer to routines
          IFNE FOR_STMFP|FOR_FALCON|FOR_TTMFP      ;Maptab Åberschreiben
          move.w    #6,-(sp)         ;Kanal 6
          move.w    #MAPT_OVE,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (erweitert)
          lea       10(sp),sp
          ENDC 
          IFNE FOR_BASTEL             ;an Maptab anhÑngen
          move.w    #MAPT_APP,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (ext: MAPT_APP)
          addq.l    #8,sp
          ENDC 
          tst.l     d0
          bne       .ib_ok
          bsr       prints
	DC.b "***	Error: Load DRVIN.PRG first!?",bell,bell,cr,lf,0
          EVEN 
          bra       init_end         ;Fehler
.ib_ok:   
          move.b    d0,rsvf_binr     ;BIOS-Nummer in RSVF-Objekt


;5.) Die Schnittstellen per RSVF bekannt machen.
          pea       sursini          ;RSVF
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          tst.b     ok_rsvf
          bne       .rs_ok
          bsr       prints
          DC.b "*** Error: RSVF not found",bell,bell,cr,lf,0
          EVEN 
.rs_ok:   


init_end:



;Konfigurationsdaten kopieren
          move.l    ko_bd,udev_bd    ;Baudrate
          move.l    ko_nr,d0         ;eingestellte Kennung
          move.b    d0,my_ininum
          add.b     d0,disp_inr      ;zum Anzeigen
          moveq.l   #0,d1
          bset.l    d0,d1
          move.b    d1,my_inibnum    ;Bitmaske ermittelt


          pea       udevname         ;eingestellten Namen ausgeben
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp
          bsr       prints
          .DC.b $1b,"q",cr,lf,0
          .EVEN 
          bsr       prints
          .DC.b "Init-Nr.: "
disp_inr: .DC.b "0" ;wird dazu addiert
          .DC.b cr,lf,0
          .EVEN 


          move.l    d4,d0            ;Fehlerstringnummer
          tst.l     d3               ;Fehler aufgetreten?
          bmi       .ma_err          ; ja, nichtresidentes Ende

;nichtresident beenden wegen Fehler
.ma_err:  
          lea       err_ptr,a0
          move.l    0(a0,d0.l),-(sp)
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp
          clr.w     -(sp)
          trap      #1               ;GEMDOS Pterm0

L110:     
;Direktzugriff auf IOREC Åber MAPTAB
          move.l    #$002cfffe,-(sp) ;(wenn RSVF da, ist auch Bconmap da)
          trap      #14              ;XBIOS Bconmap (Adresse)
          movea.l   d0,a0
          movea.l   (a0),a0          ;MAPTAB-Adr aus BCONMAP
          moveq.l   #0,d1
          move.b    2+rs_val,d1      ;BIOS-Nummer
          subq.b    #6,d1            ;Offset 0 = Nummer 6
          mulu.w    #24,d1           ;24 Byte pro MAPTAB-Eintrag
          movea.l   20(a0,d1.w),a3   ;Zeiger auf IOREC


;resident bleiben
          clr.w     -(sp)
          move.l    first_unresi,d0
          subi.l    #(start-$100),d0
          move.l    d0,-(sp)         ;residente LÑnge
          move.w    #$31,-(sp)
          trap      #1               ;GEMDOS Ptermres
          clr.w     -(sp)

	ENDC	;########## FIRST TRY



;"hard copy" mode: never resident, because not necessary
	move.l	#ko_onam,iosu_nam	;source name
          pea       su_premi		;look for source device
          move.w    #38,-(sp)        ;XBIOS Supexec
          trap      #14
          addq.l    #6,sp
          tst.l     d0
;;;;;;          bpl       .ma_err          ;Fehlermeldung

	move.l	iosu_val,d1
          moveq.l   #28,d0           ;28: Fehler "direkter Weg unmîglich"
          btst.l    #24,d1           ;byte4.bit0 set?
;;;;;;          beq       .ende            ;no
	move.l	d1,src_val
	move.l	iosu_ptr,src_ptr
	
	move.l	#ko_cnam,iosu_nam	;destination name
          pea       su_premi		;look for destination device
          move.w    #38,-(sp)        ;XBIOS Supexec
          trap      #14
          addq.l    #6,sp
          tst.l     d0
;;;;;;          bpl       .ma_err          ;Fehlermeldung

	move.l	iosu_val,d1
          moveq.l   #28,d0           ;28: Fehler "direkter Weg unmîglich"
          btst.l    #24,d1           ;byte4.bit0 set?
;;;;;;          beq       .ende            ;no

          move.l    #$002cfffe,-(sp) ;(wenn RSVF da, ist auch Bconmap da)
          trap      #14              ;XBIOS Bconmap (Adresse)
	addq.l	#4,sp
          move.l    d0,mamaptr	;MAPTAB Masterpointer

	moveq.l	#0,d0
	move.b	2+src_val,d0	;BIOS number
	move.l	d0,iosu_nr
	move.l	#bi_ta,iosu_dp
          pea       su_macp		;get copy of BIOS routines table
          move.w    #38,-(sp)        ;XBIOS Supexec
          trap      #14
          addq.l    #6,sp

;overwrite destination MAPTAB entry, use offical function
	move.l	#bi_ta,-(sp)	;pointer to routines
	moveq.l	#0,d0
	move.b	2+iosu_val,d0	;BIOS number
          move.w    d0,-(sp)
          move.w    #MAPT_OVE,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (extended)
          lea       10(sp),sp

;overwrite destination GEMDOS routines block - dangerous
;src_ptr and iosu_ptr as inputs
          pea       su_geov		;supervisor code
          move.w    #38,-(sp)        ;XBIOS Supexec
          trap      #14
          addq.l    #6,sp

          clr.w     -(sp)
          trap      #1               ;GEMDOS Pterm0


;------------------------------------------


          INCLUDE "PRINTS.S"

          INCLUDE "COOKIE.S"


;------------------------------------------

          BSS 
abstandshalter:     
          DS.b 256000               ;viel Platz bis zum Stack

