;SERSOFST.TXT-Treiber fÅr MagicMac
;(C) Harun Scheutzow, 1995


;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68020
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;	OPT	O6+,OW6+



          INCDIR "E:\AHSMOD\LIB\"
          INCLUDE "MISC_DEF.S"
          INCLUDE "IOREC.S"
          INCLUDE "ERRNO.S"


;ioo_ucr und ioo_tsr zur Simulation der MFP-Register

;--------------------------------------------------------


          SECTION TEXT 
start:    bra       starti
;Sprung nach hinten, damit mîglichst wenig resident bleibt

;Im Kommandozeilenbereich liegen kurzzeitig die Sende&Empfangspuffer
;PufferlÑngen nur ganz kurz bedeutsam (zusammen max. 128 Byte)
recbuflen           = 16
trabuflen           = 16
m1_rbuf   = start-(recbuflen+trabuflen)           ;Empfangspuffer
m1_tbuf   = start-trabuflen          ;Sendepuffer


;==========================================================================

illegal   MACRO
          DC.w $4afc
          ENDM 


;MgMc-Cookie-Struktur-Offsets
MM_vers   = 0       ;.w Versionskennung im BCD-Format ($0214 entspräche 2.14).
MM_size   = 2       ;.w Grîûe der gesamten Struktur in Bytes.
MM_flags1           = 4              ;.l Screen-Flags (Bit 0: 640*400-Emulation, 1: Rechts-Shift möglich).
MM_scrnPMPtr        = 8              ;.l Zeiger auf Screen-Beschreibung (s. Inside Macintosh, PixMap)
MM_updatePalette    = 12             ;.l Zeiger auf Boolean, Ist zu setzen, um Farbtabellen zu restaurieren.
MM_modeMac          = 16             ;.l ProcPtr, Umschaltung der MMU auf Mac-Modus. Zerstört keine Regs.
MM_modeAtari        = 20             ;.l ProcPtr, Umschaltung der MMU auf Atari-Modus. Zerstört keine Regs.
MM_getBaseMode      = 24             ;.l ProcPtr Liefert in D0.W MMU-Modus (0:Atari, sonst Mac). Zerstört sonst keine Regs.
MM_getIntrCount     = 28             ;.l ProcPtr Liefert in D0.L Intr-Semaphore-Zähler (0:frei). Zerstört sonst keine Regs.
MM_intrLock         = 32             ;.l ProcPtr Erhöht Interrupt-Semaphore-Zähler. Zerstört keine Regs.
MM_intrUnlock       = 36             ;.l ProcPtr Erniedrigt Interrupt-Semaphore-Zähler. Zerstört keine Regs.
MM_callMacContext   = 40             ;.l ProcPtr Führt Routine im Mac-Kontext aus, Proc-Adr auf Stack. Zerstört D0-D2/A0/A1
MM_atariZeroPage    = 44             ;.l Ptr Zeiger auf den Atari-Speicherbereich $0-$800 im Mac-Adreßraum
MM_macA5  = 48      ;.l Wert des A5-Registers im Mac-Kontext
MM_macAppSwitch     = 52             ;.l ProcPtr Aufruf durch MagiC-Kernel (D0/4(A7): 0:Suspend, 1:Resume, 2:Quit)
MM_controlSwitch    = 56             ;.l ProcPtr Aufruf durch MagiC-Kernel (D0/4(A7): Atari-Screen 0:Hide, 1:Show)
MM_hardwareAttr1    = 60             ;.l z.Zt. undefiniert.
MM_hardwareAttr2    = 64             ;.l z.Zt. undefiniert.
MM_magiC_BP         = 68             ;.l Zeiger auf Base Page des MagiC OS.
MM_auxOutName       = 72             ;.l Zeiger auf Pascal-String für AUX-Ausgabe-Device
MM_auxInName        = 76             ;.l Zeiger auf Pascal-String für AUX-Eingabe-Device
MM_auxControl       = 80             ;.l ProcPtr Aufruf durch MagiC-Kernel (D0/4(A7): 0:Suspend, 1:Resume, 2:Quit)
;(ist 0, wenn keine Routine eingetragen)
;16 .l reserviert


;Momentane Implementation, umstÑndlich aber korrekt
switchmac MACRO
          bsr       my_swimac
          ENDM 

switchatari MACRO
          bsr       my_swiatari
          ENDM 


;Fehlermeldungen der Mac-Routinen sind wohl nur WORD, nicht unbedingt LONG


;SCC-Direktzugriffskonstanten des Macintosh
SCCRd     = $1d8
SCCWr     = $1dc
bCtl      = 0
aCtl      = 2
bData     = 4
aData     = 6
;Ich speichere die Adressen beim Start selbst in my_SCCRd, my_SCCWr,
;wobei der Kanal-Offset berÅcksichtigt wird, so daû nur noch
my_xData  = 4       ;als Datenregisteroffset benîtigt wird


;Device Manager Parameter Block Header
qLink     = 0       ;.l internally
qType     = 4       ;.w internally
ioTrap    = 6       ;.w internally
ioCmdAddr           = 8              ;.l internally
ioCompletion        = 12             ;.l completion routine
ioResult  = 16      ;.w result code
ioNamePtr           = 18             ;.l driver name
ioVRefNum           = 22             ;.w drive number

;specific to IOParam structure
ioRefNum  = 24      ;.w driver reference number
ioVersNum           = 26             ;.b not used
ioPermssn           = 27             ;.w read/write permission
ioMisc    = 28      ;.l not used
ioBuffer  = 32      ;.l pointer to data buffer
ioReqCount          = 36             ;.l requested number of bytes
ioActCount          = 40             ;.l actual number of bytes
ioPosMode           = 44             ;.w positioning mode
ioPosOffset         = 46             ;.w positioning offset

;specific to CntrlParam structure
ioCRefNum           = 24             ;.w driver reference number
csCode    = 26      ;.w type of control or status request
csParam   = 28      ;.22bytes control or status information


_Open     MACRO
          DC.w $a000
          ENDM 

_Close    MACRO
          DC.w $a001
          ENDM 

_Read     MACRO
          DC.w $a002
          ENDM 

_Write    MACRO
          DC.w $a003
          ENDM 

_Write_ASYNC          MACRO
          DC.w $a403
          ENDM 

_Control          MACRO
          DC.w $a004
          ENDM 

_Control_IMMEDIATE          MACRO
          DC.w $a204
          ENDM 

_Status          MACRO
          DC.w $a005
          ENDM 

_Status_IMMEDIATE          MACRO
          DC.w $a205
          ENDM 

_KillIO          MACRO
          DC.w $a006
          ENDM 


          EVEN 
Param_out:          
          DS.b 48  ;Platz fÅr Ausgabeparameterblock, nie asynchron benutzen
Param_in: 
          DS.b 48  ;Platz fÅr Eingabeparameterblock, nie asynchron benutzen
Param_aso:          
          DS.b 48  ;asynchroner Ausgabep.block fÅr Schreiben

P_aoiu:   DC.b 0   ;Bit7 =1 fÅr Param_aso noch benutzt
          EVEN 

          EVEN 
;mÅssen so hintereinander liegen
a_for_bios:         DC.b 0          ;<>0: Offen fÅr BIOS
a_for_gemdos:       DC.b 0          ;<>0: Offen fÅr GEMDOS

hwa_dcd:  DC.b 0   ;<>0: Hardwarezugriff fÅr DCD/GPi-Abfrage erlaubt


          EVEN 

macbufadr:          DC.l 0          ;Adresse des grîûeren MAC-Input-Puffers
macbuflen:          DC.w 0          ;LÑnge -"-
dontclose:          DC.w 0          ;<>0 bei Fclose Mac offen lassen

pbufadr:  DC.l 0   ;Adresse des vorsorglich-Lese-Buffers
pbufptr:  DC.l 0   ;Zeiger im -"- auf nÑchstes Byte
pbuflen:  DC.l 0   ;LÑnge des ...
pbufcnt:  DC.l 0   ;Anzahl noch vorhandener Bytes im ...


;Adresse des SCC-Control-Registers des benutzten Kanals
;(Data ist bei +4), initialisiert beim Start
my_SCCRd: DC.l 0   ;0 fÅr kein Zugriff mîglich
my_SCCWr: DC.l 0


;werden durch Startcode initialisiert

raux_conf:          DC.w -1         ;!= 0: AUX aus MagiCMac-MenÅ (dort auch schlieûbar)

;je 32 Byte fÅr den Namen des Mac-Schnittstellentreibers als Pascal-
;String (also 31 Byte Name max.)
Mac_XIn:  DC.l 0,0,0,0,0,0,0,0
Mac_XOut: DC.l 0,0,0,0,0,0,0,0

MgMc_adr: DC.l 0   ;Wert des MgMc-Cookies, Zeiger auf Struktur

;kopierte Konfig-Werte, werden bei hs_a_open ausgewertet
c_dir_conf:         DC.w 0
c_dcd_conf:         DC.w 0
c_hbd_conf:         DC.w 0
c_mbd_conf:         DC.w 0

my_swimac:          
;Umschaltung auf Mac
          DC.w $4ef9                ;JMP $xxxxxxxx
ZumMacA:  DC.l 0   ;Modifiz durch Init.

my_swiatari:        
;Umschaltung auf Atari
          DC.w $4ef9                ;JMP $xxxxxxxx
ZumAtariA:          DC.l 0          ;Modifiz durch Init.


          INCLUDE "CA_FLUSH.S"



print_faerr:
;meldet fatale Fehler zur Laufzeit - klatsch auf den Desktop
;in:   PC auf Stack, bei (PC) beginnt nullterminierter String
;kill: /
	movem.l	a0-a2/d0-d2,-(sp)	;6* LONG
	pea	.prolo	;Einleitung des Meckerns
	move.w	#9,-(sp)
	trap	#1	;GEMDOS Cconws
	addq.l	#6,sp
	move.l	6*4(sp),-(sp)	;eigentliche Meldung
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	6*4(sp),a0	;alter PC
.weiter:  tst.b     (a0)+
          sne       d0               ;0 wenn 0, $FF sonst
          and.b     (a0)+,d0         ;ein Byte aus dem WORD =0 --> Stringende
          bne       .weiter
          move.l    (a0),6*4(sp)	;neuer PC

	movem.l	(sp)+,a0-a2/d0-d2
	rts

.prolo:	dc.b cr,lf,"************ MACM1 Error: ",0
	EVEN


hs_clr_para:        
;lîsche Parameterblock
;kill: D0
          move.l    a0,-(sp)
          moveq.l   #11,d0           ;48 Byte als 12 Long
.rpt:     
          clr.l     (a0)+            ;nur auf 68000 ist clr langsam
          dbra      d0,.rpt
          movea.l   (sp)+,a0
          rts       


teste_scc:          
;Noch etwas hackig ####################
          movem.l   d0-d7/a0-a6,-(sp)
;Baudraten erstmal entschÑrfen
          move.l    #150,44+m1baudtab             ;original 150Bd
          move.w    #763,22+rsm1tps
          move.l    #200,40+m1baudtab             ;original 200Bd
          move.w    #571,20+rsm1tps
          move.l    #28800,56+m1baudtab           ;original 28800 Bd (Atari 75)
          move.w    #2,28+rsm1tps

          tst.w     c_dir_conf       ;SCC-Direktzugriff vom User erlaubt?
          beq       .kein_scc
;teste ob Name .AOut oder .BOut anhand LÑnge und erste 3 Zeichen
          moveq.l   #0,d0            ;Offset 0 bei "PRINTER": .BOut SCC-B
          cmpi.l    #$052e424f,Mac_XOut           ;.BO* LÑnge 5
          beq       .Bprin
          moveq.l   #2,d0            ;Offset 2 bei "MODEM": .AOut SCC-A
          cmpi.l    #$052e414f,Mac_XOut           ;.AO* LÑnge 5
          bne       .kein_scc
.Bprin:   
          switchmac 
;#### eventuell mit Gestalt noch nach SCC fragen?????
;#### (ist aber laut Apple nicht sicher)
          movea.l   SCCRd,a0         ;Adressen des SCC
          adda.l    d0,a0            ;Kanaloffset
          movea.l   SCCWr,a1
          adda.l    d0,a1
;Vorbereitung fÅr Buserror-Test
          move.w    sr,d3
          ori.w     #$700,sr
          movea.l   $8,a3
          move.l    #.my_ber,$8      ;eigener Vektor
          movea.l   sp,a4
          nop                        ;Sync.
          tst.b     (a0)             ;SCC-Zugriff
          nop       
;kein Buserror, SCC vorhanden
          move.l    a3,$8            ;alter Buserror-Vektor
          move.w    d3,sr

          move.l    a0,my_SCCRd      ;SCC-Adr in meine Variablen
          move.l    a1,my_SCCWr
          switchatari 
          move.b    1+c_dcd_conf,hwa_dcd          ;kopiere DCD-Erlaubnis
          tst.w     c_hbd_conf
          beq       .no_hbd
          move.l    #115200,44+m1baudtab          ;ersetze 150Bd
          move.w    #$8008,22+rsm1tps             ;RTxC und /32
          move.l    #230400,40+m1baudtab          ;ersetze 200Bd
          move.w    #$8004,20+rsm1tps             ;RTxC und /16
.no_hbd:  
;##### spÑter das hbd-Zeug so Ñndern, daû auf Mac mit IOP wenigstens
;der entsprechende Call benutzt wird, und wenigstens 230400 erlaubt sind
;### 115200 aber nicht, siehe auch "rsm1_setbd:"
          tst.w     c_mbd_conf
          beq       .no_mbd
          move.l    #31250,56+m1baudtab           ;ersetze 28800 Bd
          move.w    #$8009,28+rsm1tps             ;TRxC und /32
.no_mbd:  
          bra       .kein_scc

.my_ber:  
;Buserror, SCC-Direktzugriff unmîglich
;die Flags stehen im Programm bereits auf "kein Zugriff"
          move.l    a3,$8            ;alter Buserror-Vektor
          movea.l   a4,sp            ;alter Stackpointer
          move.w    d3,sr
          switchatari 
.kein_scc:          
          movem.l   (sp)+,d0-d7/a0-a6
          rts       


;##########

my_camaco:
	dc.l		0	;wird durch Initialiserung gesetztt


zzz_open:
;Aufgerufen durch callMacContext
;in:  /
;out:  D4.W Mac-Fehlercode oder 0 fÅr OK
;      D5.L 0 fÅr Output-Open-Fehler, 4 fÅr Input-Open-Fehler
;kill: ???? noch raussuchen
          lea       Param_out,a0     ;zuerst Ausgabetreiber
          bsr       hs_clr_para
          move.l    #Mac_XOut,ioNamePtr(a0)       ;Zeiger -> Out-Name
          move.b    #2,ioPermssn(a0) ;nur Write (R&W geht nicht)
	_Open
          moveq.l   #0,d5            ;Kennzeichung Output-Open fÅr Fehlerbehandlung
          move.w    d0,d4
          bmi       .Oop_err
          lea       Param_in,a0      ;dann Eingabetreiber
          bsr       hs_clr_para
          move.l    #Mac_XIn,ioNamePtr(a0)        ;Zeiger -> In-Name
          move.b    #1,ioPermssn(a0) ;nur Read (R&W geht nicht)
	_Open
          moveq.l   #4,d5            ;Kennzeichung Input-Open fÅr Fehlerbehandlung
          move.w    d0,d4
          bmi       .Iop_err
;beides offen
          lea       Param_in,a0      ;Eingabepuffer setzen
          move.w    #9,csCode(a0)    ;SerSetBuf
          move.l    macbufadr,csParam(a0)
          move.w    macbuflen,4+csParam(a0)
          _Control_IMMEDIATE
          lea       Param_out,a0     ;(Ext.) Parity Error Replacement Zeug aus
          move.w    #20,csCode(a0)
          clr.w     csParam(a0)
          _Control_IMMEDIATE
	rts		;OK-RÅckkehr, D4.W ist 0

.Iop_err:
	lea       Param_out,a0	;Ausgabeport wieder schlieûen
	_Close 
.Oop_err:
	rts


hs_a_open:          
;ôffne Serial Port
          bsr       teste_scc
          switchmac 
	movem.l	d1-d7/a0-a6,-(sp)
	pea		zzz_open
	move.l	my_camaco,a1
;#### callMacContext killt D0-D2/A0-A1
	jsr		(a1)
	addq.l	#4,sp
	move.w	d4,d0		;Fehlercode kopieren
	movem.l	(sp)+,d1-d7/a0-a6
          switchatari 
	tst.w	d0		;Fehler?
	bne	.o_err		;hops bei Fehler

;lîsche Vorleseblock
          move.l    pbufadr,pbufptr
          clr.l     pbufcnt
;da sich die Mac-Einstellungen nicht lesen lassen, mÅssen jetzt die
;Atari-Standardeinstellungen gesetzt werden
          bsr       rsm1_setbd
          bsr       rsm1_seths
;########## eventuell noch solche SpÑûe wie DTR etc berÅcksichtigen
          lea       Param_out,a0     ;erzeuge asyn.Ausgabep.block
          lea       Param_aso,a1
          moveq.l   #11,d0           ;12 long
.c_lp:    
          move.l    (a0)+,(a1)+
          dbra      d0,.c_lp
          move.l    #ou_as_compl,ioCompletion+Param_aso

          moveq.l   #E_OK,d0         ;OK
          rts       

.o_err:
          moveq.l   #EACCDN,d0	;Fehler
          rts


zzz_close:
;Aufgerufen durch callMacContext
          lea       Param_in,a0      ;eventuelle async Requests lîschen
          _KillIO 
          lea       Param_out,a0
          _KillIO 
          lea       Param_in,a0      ;auf Original-Inputbuffer zurÅck
          move.w    #9,csCode(a0)    ;SerSetBuf
          clr.l     csParam(a0)
          clr.w     4+csParam(a0)
          _Control_IMMEDIATE
          lea       Param_in,a0      ;schlieûe Eingabe vor Ausgabe
          _Close 
          lea       Param_out,a0
          _Close 
	rts


hs_a_close:         
;Schlieûe Serial Port A
          switchmac 
	movem.l	d1-d7/a0-a6,-(sp)
	pea		zzz_close
	move.l	my_camaco,a1
;#### callMacContext killt D0-D2/A0-A1
	jsr		(a1)
	addq.l	#4,sp
	movem.l	(sp)+,d1-d7/a0-a6
          switchatari 
          moveq.l   #0,d0
          rts       


hs_a_SerGetBuf:     
;ermittle Anzahl Byte im Mac-Input-Buffer
;in:   /
;out:  D0.L: Anzahl Byte im MAC-Input-Buffer
;kill: /
          move.l    a0,-(sp)
          lea       Param_in,a0
          move.w    #2,csCode(a0)
          switchmac 
          _Status 
          switchatari 
          move.l    csParam+Param_in,d0
          movea.l   (sp)+,a0
          rts       


hs_a_SerXBrk:       
;Setze/lîsche Break
;in:   D2.B: ein "MFP-TSR", Bit3 =1 fÅr Break an
;out:  /
;kill: /
          movem.l   d0/a0,-(sp)
          move.b    d2,ioo_tsr+m1_iorec           ;"TSR" speichern
          lea       Param_out,a0
          moveq.l   #12,d0           ;SerSetBrk
          btst.l    #3,d2
          bne       .seb
          moveq.l   #11,d0           ;SerClrBrk
.seb:     
          move.w    d0,csCode(a0)
          switchmac 
          _Control_IMMEDIATE
          switchatari 
          movem.l   (sp)+,d0/a0
          rts       


co_rou:   
;FÅr ou_as_compl, Bconout, Fwrite   !!lÑuft im Mac-Modus!!
;Sendet nÑchsten Block, falls etwas da ist
;(wird nur aufgerufen, wenn Param_aso schon frei ist)
;in:   A0: Zeiger auf Param_aso
;      A1: Zeiger auf IOREC
;out:  Z-Flag, gesetzt wenn nichts gesendet wurde, weil Puffer leer
;kill: D0-D2,A0,A1
          moveq.l   #0,d1            ;ermittle Anzahl vorhandener Byte
          moveq.l   #0,d2
          move.w    ioo_trp(a1),d2   ;Lesez
          move.w    ioo_twp(a1),d1   ;Schreibz
          sub.w     d2,d1            ; minus Lesez
          bcc       .nc0
          add.w     ioo_tbl(a1),d1
.nc0:     
          beq       .ende            ;nichts mehr da, Z-Flag gesetzt
          addq.w    #1,d2            ;Lesez auf zu Lesendes
          cmp.w     ioo_tbl(a1),d2
          bcs       .nc1
          moveq.l   #0,d2
.nc1:     
          moveq.l   #0,d0
          move.w    ioo_tbl(a1),d0   ;Anzahl Bytes vom Lesez bis Pufferende
          sub.w     d2,d0            ;(immer >0)
          cmp.w     d1,d0            ;nimm kleinere Byteanzahl
          bcs       .nt
          move.w    d1,d0
.nt:      
          move.l    d0,ioReqCount(a0)
          add.l     ioo_tba(a1),d2   ;Adresse der Daten
          move.l    d2,ioBuffer(a0)
          _Write_ASYNC 
          moveq.l   #1,d0            ;lîsche Z-Flag
.ende:    
          rts


ou_as_compl:        
;Output-Completion routine  !!lÑuft im Mac-Modus!!
;(im Ernstfall wird die Routine einmal "rekursiv" aufgerufen, dann dÅrfte
;der Puffer leer sein)
;kill: / (was wÑre erlaubt?)
          movem.l   d0-d2/a0/a1,-(sp)
          lea       Param_aso,a0
          lea       m1_iorec,a1
          tst.w     ioResult(a0)     ;wichtig vor allem wegen KillIO
          spl       P_aoiu           ;Freigabe bei Fehlern
          bmi       .ende            ;wegen KillIO auch kein neuer Versuch
;(alle aufgelisteten Fehler verbieten neue Versuche)
          move.w    ioo_tbl(a1),d1
          move.w    ioo_trp(a1),d0   ;Lesezeiger holen zum Update
          add.w     2+ioActCount(a0),d0           ;ioActCount ist long
          cmp.w     d1,d0
          bcs       .noco
          sub.w     d1,d0            ;einmal rum
.noco:    
          move.w    d0,ioo_trp(a1)

          move.l    ioActCount(a0),d0
          cmp.l     ioReqCount(a0),d0
          beq       .weit		;auftragsgemÑûe Menge gesendet
;#################### gesendete Anzahl stimmt nicht mit Auftrag Åberein ####
;Dies hier ist zwar eine schwere Fehlerbedingung, aber mir fÑllt
;erstmal keine vernÅnftige Reaktion ein, die nicht "illegal" heiût,
;also erstmal garnichts tun.

.weit:    
          bsr       co_rou
          bne       .ende
          clr.b     P_aoiu           ;Param_aso frei
.ende:    
          movem.l   (sp)+,d0-d2/a0/a1
          rts       


;------------

;Da es sich um Ringpuffer handelt, ist folgende exakte Definition fÅr Puffer
;voll und Puffer leer notwendig:
;- Puffer leer: Schreibzeiger = Lesezeiger
;- Puffer voll: ((Schreibzeiger + 1) modulo PufferlÑnge) = Lesezeiger

;Ein Zeiger wird erst erhîht und dann benutzt (an dieser Position gelesen /
;geschrieben). Wird beim Erhîhen das Pufferende erreicht
;(Zeiger = PufferlÑnge), so wird der Zeiger auf 0 gesetzt.

;Lese minus Schreibzeiger
;BHI Åberspringe nÑchstes
;plus LÑnge
;ergibt Anzahl freier PlÑtze

;Schreib minus Lesezeiger
;BCC Åberspringe nÑchstes
;plus LÑnge
;ergibt Anzahl belegter PlÑtze

;--------------------------------------


;Die BIOS-Routinen bconout, bcostat, bconin, bconstat fÅr Modem1

;Benutzte Register: d0, d1, d2, a0, a1 (a2 nicht, obwohl erlaubt)
;Diese Register kînnen auch ohne vorherige Sicherung immer benutzt werden,
;auch wenn sie der BIOS-Dispatcher nicht gesichert hat.


do_b_open:          
;ôffnet Schnittstelle fÅr BIOS (wird nur aufgerufen wenn noch nicht
;fÅr BIOS offen)
;!! kehrt bei Fehler eine Ebene hîher zurÅck mit D0=0 !!
          tst.b     a_for_gemdos     ;generell offen?
          beq       .nog             ; nein
.suc:     
          st        a_for_bios       ;markiere als BIOS-benutzt
          rts       
.nog:     
          bsr       hs_a_open        ;MAC-seitig îffnen
          tst.l     d0
          beq       .suc             ;erfolgreich
          moveq.l   #0,d0            ;Fehler
          addq.l    #4,sp            ;Åberspringe eine Ebene bei RÅckkehr
          rts       


m1_bconstat:        
;BIOS: Eingabestatus
          tst.b     a_for_bios       ;Schnittstelle schon BIOS-offen?
          bne       .al_bop          ; ja
          bsr       do_b_open        ; nein, îffnen
.al_bop:  
          move.l    pbufcnt,d0       ;was da?
          bne       .da              ; im Vorlesepuffer
          bsr       hs_a_SerGetBuf   ; erst MAC fragen
          tst.l     d0
.da:      
          sne       d0
          ext.w     d0
          ext.l     d0
          rts       


m1_bconin:          
;BIOS: Zeicheneingabe
          tst.b     a_for_bios       ;Schnittstelle schon BIOS-offen?
          bne       .al_bop          ; ja
          bsr       do_b_open        ; nein, îffnen
.al_bop:  
.warte:   
          move.l    pbufcnt,d0
          beq       .pem             ;Vorlesepuffer leer
          subq.l    #1,d0
          movea.l   pbufptr,a0
          move.l    d0,pbufcnt       ;Anzahl update
          moveq.l   #0,d0            ;bit31..8 lîschen
          move.b    (a0)+,d0
          move.l    a0,pbufptr       ;Zeiger update
          rts                        ;Ende (1)
.pem:     
          bsr       hs_a_SerGetBuf
          tst.l     d0
          beq       .warte           ;#### ich verbrate die Zeit selbst
;Vorlesepuffer leer, und Mac-Puffer hat Daten
          move.l    pbuflen,d1       ;bilde minimum(PufferlÑnge, MAC_bytes_da)
          cmp.l     d0,d1
          bls       .nch
          move.l    d0,d1
.nch:     
          lea       Param_in,a0
          move.l    pbufadr,ioBuffer(a0)
          move.l    d1,ioReqCount(a0)
          switchmac 
          _Read 
          switchatari 

          cmp.l     ioActCount+Param_in,d1
          beq       .eok
	bsr	print_faerr
	dc.b	"Read-B1",cr,lf,0
	EVEN
.eok:

          subq.l    #1,d1            ;1 Byte lese ich jetzt
          movea.l   pbufadr,a0       ;Pufferanfang
          moveq.l   #0,d0            ;Bit 31..8 lîschen
          move.b    (a0)+,d0
          move.l    d1,pbufcnt
          move.l    a0,pbufptr       ;aktueller Lesezeiger
          rts                        ;Ende (2)


m1_bconout:         
;Zeichenausgabe
;Aufruf auch bei anfang+4 mîglich, mit Parameter als WORD bei (A0)
          lea       6(sp),a0         ;muû sein
          tst.b     a_for_bios       ;Schnittstelle schon BIOS-offen?
          bne       .al_bop          ; ja
          bsr       do_b_open        ; nein, îffnen
.al_bop:  
          move.w    (a0),d0          ;Zeichen holen
m1_ibconout:                         ;interner Aufruf, Zeichen in D0.B
          lea       m1_iorec,a1
          moveq     #0,d1            ;Bit31-16 muû 0 bleiben!
          move.w    ioo_twp(a1),d1   ;Schreibzeiger holen
          addq.w    #1,d1            ;erhîhen, auf 64KByte beschrÑnkt durch .w
          cmp.w     ioo_tbl(a1),d1   ;im Puffer umlaufen lassen
          bcs       .conbx
          moveq     #0,d1
.conbx:   
          movea.l   ioo_tba(a1),a0   ;Pufferadresse
          move.b    d0,0(a0,d1.l)    ;Byte -> Puffer
          move.w    d1,ioo_twp(a1)   ;Schreibzeiger aktualisieren
.cobfu:   
          bset.b    #7,P_aoiu        ;arbeitet Async-Sender noch?
          bne       .condl           ; ja, also wird Completion-Routine kommen
;Parameterblock fÅr async-Ausgabe war frei, belege, setze neue Werte
          lea       Param_aso,a0
          switchmac 
          bsr       co_rou
          bne       .cwrks
          clr.b     P_aoiu           ;keine Routine anhÑngig
.cwrks:   
          switchatari 
          lea       m1_iorec,a1
.condl:   
;Anzahl noch freier PlÑtze im Puffer ermitteln
          move.w    ioo_trp(a1),d1   ;Lesezeiger
          sub.w     ioo_twp(a1),d1   ;minus Schreibzeiger
          bhi       .coxnx           ;keine Korrektur
          add.w     ioo_tbl(a1),d1   ;plus PufferlÑnge
.coxnx:   subq.w    #1,d1            ;minus 1 statt cmp #1
          beq       .cobfu           ;voll, warten auf Leerung(smîglichkeit)
.coend:   
          rts       


m1_bcostat:         
;BIOS: Ausgabestatus
;Da bconout immer mindestens einen freien Platz im Puffer braucht,
;sagt bcostat schon voll, wenn nur noch ein Platz frei ist.
;Wird bconout dann doch aufgerufen, verhÑlt es sich wie bei vollem Puffer:
;Es wartet bis das Zeichen raus ist.
          tst.b     a_for_bios       ;Schnittstelle schon BIOS-offen?
          bne       .al_bop          ; ja
          bsr       do_b_open        ; nein, îffnen
.al_bop:  
          move.w    ioo_trp+m1_iorec,d1           ;freien Platz berechnen
          sub.w     ioo_twp+m1_iorec,d1           ;Lesez. minus Schreibzeiger
          bhi       .noco            ;keine Korrektur
          add.w     ioo_tbl+m1_iorec,d1           ;PufferlÑnge dazu
.noco:    subq.w    #3,d1            ;Differenz muû >=3 sein fÅr frei
          scc       d0               ;ja, noch mind. 2 PlÑtze frei
          ext.w     d0
          ext.l     d0
          rts       





;Das neue MODEM1 Rsconf.

ubd_ofs   = 2*16    ;Abstand der Klartextraten vom Beginn der Tabelle

m1_rsconf:          
;Rsconf fÅr Modem1
;kill: D0-D2/A0/A1
          tst.b     a_for_bios       ;Schnittstelle schon BIOS-offen?
          bne       .al_bop          ; ja
          bsr       do_b_open        ; nein, îffnen
.al_bop:  
d_m1_rsconf:        
;Direktaufruf durch GEMDOS-Treiberteil
          cmpi.w    #SETUSPEED,4(sp)
          bne       rsm1uno          ;nicht die erweiterte Funktion
          move.l    ioo_ubd+m1_iorec,d0           ;aktuelle uspeed
          move.l    2+4(sp),d1       ;Parameter uspeed
          bmi       rsm1ende         ;nur abfragen
          move.l    d1,d0
          lea       rsm1tps,a1       ;Baudratentabelle
          bsr       rsm1_suchbaud
          tst.l     d0               ;gefunden?
          bmi       rsm1ende         ; nein
          move.l    ioo_ubd+m1_iorec,d2           ;alte uspeed
          move.l    d0,ioo_ubd+m1_iorec           ;neue uspeed vermerken
          move.l    d2,d0            ;alte uspeed als Returnwert
          move.b    d1,ioo_bd+m1_iorec            ;neuer Index
          bsr       rsm1_setbd       ;(Baudrate) einstellen
          bra       rsm1ende
rsm1uno:  
          moveq     #0,d0
          cmpi.w    #$fffe,4(sp)     ;Parameter speed
          bne       rsm1nob
          move.b    ioo_bd+m1_iorec,d0            ;bei speed = -2 nur die eingestellte
          rts                        ;Baudrate zurÅckgeben
rsm1nob:  
          moveq.l   #16,d1           ;RÅckgabewert basteln (D1.bit31 =0)
          move.b    ioo_ucr+m1_iorec,d0
          lsl.l     d1,d0            ;am Ende!: ucr in Bit31..24
          move.b    ioo_tsr+m1_iorec,d0
          lsl.l     #8,d0            ;tsr in Bit15..8 (Break-Bit)
;D1.bit31 ist Flag fÅr "etwas einstellen", wenn =1

          move.w    4(sp),d1         ;Parameter speed
          cmpi.w    #$000f,d1
          bhi.s     rsm1nosp         ;hops bei speed zu groû (bzw. negativ)
          move.b    d1,ioo_bd+m1_iorec            ;merke Baudratenindex
          lsl.w     #2,d1            ;Klartexttab mit longs
          lea       rsm1tps,a1       ;Baudratentabelle
          move.l    ubd_ofs(a1,d1.w),ioo_ubd+m1_iorec       ;merke auch als Klartext
          bset.l    #31,d1           ;Einstellen erforderlich
rsm1nosp: 
          move.w    $8(sp),d2        ;Parameter ucr
          bmi       rsm1fcu0         ;Sprung fÅr nicht Ñndern
          move.b    d2,ioo_ucr+m1_iorec           ;Byte ins "ucr-Register"
          bset.l    #31,d1           ;Einstellen erforderlich
rsm1fcu0: 
;kein rsr (bei $a(sp))
          move.w    $c(sp),d2        ;Parameter tsr
          bmi       rsm1fct0         ;Sprung fÅr nicht Ñndern
          bsr       hs_a_SerXBrk     ;Break beeinflussen und merken
rsm1fct0: 
;kein scr (bei $e(sp))

          tst.l     d1
          bpl       rsm1nose         ;kein Setzen
          bsr       rsm1_setbd       ;macht mehr als nur bd
rsm1nose: 
          move.w    6(sp),d2         ;Parameter flowctl
          cmpi.w    #3,d2
          bhi       rsm1ende         ;flowctl ist zu groû
          bne       rsm1fcnb         ;flowctl nicht XON/XOFF & RTS/CTS
          moveq.l   #1,d2            ;"beides" Ñndere auf XON/XOFF
rsm1fcnb: 
          move.b    d2,ioo_hsm+m1_iorec           ;flowctl speichern
          bsr       rsm1_seths       ;und setzen
rsm1ende: 
          rts       


rsm1_suchbaud:      
;aufgerufen durch m1_rsconf
;in:   D0.l: zu suchende Klartext-Baudrate
;      A1:   Zeiger auf Baudratentabelle (Teilertab, Klartexttab davor)
;out:  D0.l: mîgliche Klartextspeed
;      D0.bit31: 0= Rate vorhanden
;                1= andere Rate in D0(bit30..0) vorgeschlagen
;      D1.w: wenn Rate vorhanden: Indexnummer zur Klartextspeed
;kill: D0/D1
;Suche neue Baudrate. So kompliziert, damit die Tabelle unsortiert sein kann.
          movem.l   d2-d5,-(sp)
          moveq.l   #-1,d3           ;maximaler Differenzwert (unsigned)
          moveq.l   #-1,d4           ;noch keine kleinere Rate gefunden, Index
          moveq.l   #-1,d5           ;fÅr allerkleinste Rate aus Tabelle
          move.w    #(4*(16-1)),d1   ;index in D1.W, count down, Faktor 4 long
;D1-Highword soll 0 bleiben
.sea:     
          move.l    d0,d2            ;speed
          cmp.l     ubd_ofs(a1,d1.w),d5           ;suche nebenbei kleinste
          bls       .nogsm           ; Baudrate der ganzen Tabelle
          move.l    ubd_ofs(a1,d1.w),d5           ;in D5.l
.nogsm:   
          sub.l     ubd_ofs(a1,d1.w),d2           ;ermittle Differenz
          beq       .ende            ;Rate genau gefunden
          bcs       .nex             ;grîûere Rate
;eine kleinere Rate gefunden
          cmp.l     d3,d2            ;kleinere Rate, mit geringerer Differenz?
          bcc       .nex             ; nein
          move.l    d2,d3            ;merke neues Minimum der Differenz
          move.w    d1,d4            ;merke Indexwert dazu
.nex:     subq.w    #4,d1            ;Index weiter
          bcc       .sea             ;weiter suchen
;keine genaue Rate gefunden
          move.l    d5,d0            ;niedrigste Bdrate aus ganzer Tab.
          tst.w     d4               ;Index fÅr kleinere Rate gefunden?
          bmi       .lowest          ; nein, niedrigstmîgliche liefern
          move.l    ubd_ofs(a1,d4.w),d0           ; ja, nÑchstniedrigere Bdrate
          move.w    d4,d1            ;Indexwert dazu
.lowest:  
          bset.l    #31,d0
.ende:    
          lsr.w     #2,d1            ;ermittle aus Index die Rsconf-Nummer
          movem.l   (sp)+,d2-d5
          rts       


rsm1_seths:         
;Handshake und zugehîriges im Mac einstellen
;in:   / (ioo_hsm im IOREC)
;out:  /
;kill: /
          movem.l   d0/a0,-(sp)
          lea       Param_out,a0     ;Out sollte reichen
          move.w    #14,csCode(a0)   ;SerShk
          move.l    #$00001113,csParam(a0)
          clr.l     4+csParam(a0)
          move.b    ioo_hsm+m1_iorec,d0
          subq.b    #1,d0
          seq       csParam(a0)      ;setze evtl out-XON/XOFF-Flag
          seq       6+csParam(a0)    ;setze evtl in-XON/XOFF-Flag
          subq.b    #1,d0
          seq       1+csParam(a0)    ;setze evtl (out-)CTS-Flag
          seq       7+csParam(a0)    ;setze evtl (in-)DTR-Flag
          switchmac 
          _Control_IMMEDIATE 
          switchatari 
          movem.l   (sp)+,d0/a0
          rts       


rsm1_setbd:         
;Baudrate, ParitÑt, Datenbits, Stopbits im Mac einstellen
;in:   / (ioo_ucr, ioo_bd im IOREC)
;out:  /
;kill: /
          movem.l   d0/d1/d7/a0,-(sp)
          moveq.l   #0,d1
          move.b    ioo_bd+m1_iorec,d1            ;Parameter speed
          add.w     d1,d1
          lea       rsm1tps,a0       ;auch fÅr spÑter
          moveq.l   #$40,d0          ;(Dummy)Teiler bei hoher Baudrate
;##### ?????????????
;Wenn man hier anstelle von $40 ($80 geht auch, aber nicht mit moveq laden)
;(wie es auch in rsm1tps "zufÑlligerweise" steht,
;eine 0 oder 1 (welche Werte noch, habe ich nicht getestet) lÑdt,
;dann sendet der SCC nach der Umschaltung auf 115200/230400 per Direktzugriff
;stÑndig Schrott, was sich auch nicht durch BaudratenÑnderung beheben lÑût,
;sondern nur durch "Neustart".
;##### was ist da los???? Nutzt MacOS irgendwie den BaudratenzÑhler-Interrupt
;oder spinnt der SCC selbst (der ESCC bei meinem ST_ESCC tut es nicht, und
;die ganzen SCC in den TTs wohl auch nicht######
          move.w    0(a0,d1.w),d7    ;Teilerwert, in D7 fÅr spÑter
          bmi       .hi1             ;hohe Rate spÑter einstellen
          move.w    d7,d0            ;Teiler aus Tab ist ok
.hi1:     
          move.b    ioo_ucr+m1_iorec,d1
          lsr.b     #1,d1            ;Bit0 wegwerfen
;ParitÑt: UCR Bit1 -> Bit13, UCR Bit2 -> Bit12
          lsr.b     #1,d1            ;Bit1
          bcc       .nb1
          bset.l    #13,d0
.nb1:     
          lsr.b     #1,d1            ;Bit2
          bcc       .nb2
          bset.l    #12,d0
.nb2:     
;Stopbits: UCR Bit4,3 -> Bit15,14
          lsr.b     #1,d1            ;Bit3
          bcc       .nb3
          bset.l    #14,d0
.nb3:     
          lsr.b     #1,d1            ;Bit4
          bcc       .nb4
          bset.l    #14,d0
.nb4:     
;Datenbits: UCR Bit6,5 -> Bit11,10   aber negiere bei 00 und 11
          andi.w    #3,d1
          move.b    -4(a0,d1.w),d1   ;nach Bit7,6
          lsl.w     #4,d1
          or.w      d1,d0
;Wert fÅr csParam in D0.W fertig
;Parameterblock vorbereiten, Apple sagt: je einmal fÅr Out und in
          lea       Param_out,a0
          move.w    #8,csCode(a0)    ;SerReset
          move.w    d0,csParam(a0)
          move.w    #8,csCode+Param_in            ;SerReset
          move.w    d0,csParam+Param_in
          switchmac 
;SerReset setzt WR4 und WR11 immer wieder "richtig"
;(es wird wohl auch immer das VIA-Bit auf RTxC von intern setzen)
          _Control_IMMEDIATE 
          lea       Param_in,a0
          _Control_IMMEDIATE
;Spezielle Raten, wie z.B.: 115200/230400 durch Direktzugriff einstellen?
;Die passenden Werte sind nur in der Tabelle, wenn Direktzugriff erlaubt ist.
          move.w    d7,d0
          bpl       .no_hi           ;keine hohe Rate
          tst.l     my_SCCWr         ;0 wenn Direktzugriff verboten
          beq       .no_hi           ;###### ERSTMAL
;#### SPéTER KANN MAN wenigstens 230400 Åber die MacOS-Funktion
;#### einstellen, 115200 geht wohl nicht dann bei IOPs, oder doch????
          move.b    1+csParam+Param_in,d1         ;das Konfig-Word von SerReset
          lsr.b     #4,d1            ;mit Bit15..12 gehîrt nach WR4 Bit3..0
;D0 Bit3..2 -> WR4 Bit7..6, D0 Bit1..0 -> WR11 Bit6..5 und 4..3
          moveq.l   #$c,d7
          and.b     d0,d7
          lsl.b     #4,d7
          or.b      d7,d1            ;D1.b fÅr WR4
          andi.b    #3,d0
          lsl.b     #3,d0
          move.b    d0,d7
          lsl.b     #2,d7
          or.b      d7,d0
          ori.b     #1,d0            ;D0.b fÅr WR11

          move.w    sr,-(sp)
          ori.w     #$700,sr
          movea.l   my_SCCWr,a0
;### diese "dichten" Zugriffe kînnen bei uralten Macs danebengehen
;### bei allen Macs ist RTxCA mit 3.672MHz (eventuell auf extern umschaltbar)
;verbunden
;### RTxCB ist aber bei den alten Macs mit PCLK verbunden, und nur beim
;IIci scheint PCLK nicht 3.672MHz, sondern 7.38336MHz zu sein (Hardwaredoku)
;beim Performa630 ist PCLK mit 8MHz angegeben, aber sicher ist RTxCB dort
;nicht mit PCLK verbunden??????
          move.b    #11,(a0)         ;WR11
          move.b    d0,(a0)          ;Taktquelle fÅr Rx und Tx
          move.b    #4,(a0)          ;WR4
          move.b    d1,(a0)          ;Teiler (/16, /32, /64)
          move.w    (sp)+,sr
.no_hi:   
          switchatari 
          movem.l   (sp)+,d0/d1/d7/a0
          rts       


;direkt vor BaudratenÅbersetzungstabelle die Datenbitkonvertierung:
          DC.b $c0,$40,$80,$0
;BaudratenÅbersetzungstabelle fÅr MAC
;einige sind nicht besonders genau, Teiler > 1023 sind unmîglich,
; deshalb 75 und 50 ersetzt durch "ungewîhnliche" Werte
;Formel: konstante = (114709/baudrate)-2
rsm1tps:  DC.w 4,10,22,30
          DC.w 46,55,62,94
          DC.w 189,380,571,763
          DC.w 0,1,2,6
;die angehÑngte Klartexttabelle:
m1baudtab:          
          DC.l 19200,9600,4800,3600
          DC.l 2400,2000,1800,1200
          DC.l 600,300,200,150
          DC.l 57600,38400,28800,14400



;IOREC fÅr MODEM1
;Initialisierungswerte: 19200Bd, 8N1, kein Handshake
m1_iorec: DC.l m1_rbuf
          DC.w recbuflen
          DC.w 0
          DC.w 0
          DC.w recbuflen/4
          DC.w (recbuflen*3)/4
          DC.l m1_tbuf
          DC.w trabuflen
          DC.w 0
          DC.w 0
          DC.w trabuflen/4          ;eigentlich sinnlos
          DC.w (trabuflen*3)/4      ;eigentlich sinnlos
          DC.b $88,0                ;UCR, TSR
          DC.b 0,0 ;ioo_re,ioo_te
          DC.b 0,0 ;kein Handshake, x
          DC.b 0   ;Baudrate
          DC.b 0   ;Fehlersammlung
          DC.l 19200                ;Klartextrate


;----------------------------------------------------------------------

m1_lseek: moveq.l   #0,d0            ;Position 0 nach seek
          rts                        ;immer so fÅr U:\DEV\-Treiber


m1_fopen: 
          moveq.l   #E_OK,d0
          tst.w     a_for_bios       ;teste gleichzeitig ...gemdos
          bne       .al_op
          bsr       hs_a_open        ;îffne wenn noch nicht offen
          tst.l     d0
          bmi       .ende            ;Fehler
.al_op:   
          addq.b    #1,a_for_gemdos  ;erhîhe ReferenzzÑhler
.ende:    
          rts       


m1_fclose:          
          moveq.l   #E_OK,d0
          subq.b    #1,a_for_gemdos  ;erniedrige ReferenzzÑhler
          tst.w     a_for_bios       ;teste auch ...gemdos
          bne       .ende            ;noch was offen
          tst.w     dontclose        ;oder doch nicht schlieûen?
          beq       .clo             ; schlieûen erlaubt
          st        a_for_bios       ;markiere auf jeden Fall als offen
          rts       
.clo:     
          bsr       hs_a_close
.ende:    
          rts       


;!!XX!! #### QUICKIE-Definitionen fÅr das noch nicht vorhandene

m1_stat:  
          moveq.l   #1,d0            ;beim Pollen immer bereit
          tst.l     d1               ;=0 bedeutet Polling
          beq       .poll_ok
          moveq.l   #0,d0            ;Meldung: kann nur Polling
.poll_ok: 
          move.l    a1,d1            ;(kein tst.l aX auf 68000)
          beq       .no_ptr
          move.l    d0,(a1)          ;Returnwert auch in Struktur
.no_ptr:  
          rts       


m1_delete:          
;### gewÅnschte Funktion ###: Device lîschen
;### aktuelle Funktion: nur MacOS-seitig Interface schlieûen
          tst.w     a_for_bios       ;teste auch a_for_gemdos
          beq       .zu              ;schon alles zu
          clr.w     a_for_bios       ;schlieûe "gewaltsam" bios/gemdos
          bsr       hs_a_close
.zu:      
          moveq.l   #EINVFN,d0       ;####### macht mein Device nicht lîschbar
          rts       


;Dcntl merkt sich nur Zeiger hierhin, also Name und Zeiger resident halten
m1_iname: 
          DC.b "U:\DEV\"
wgna_1:   DC.b "MODEM1",0,0,0,0,0,0,0,0
          EVEN 
m1_drvr:  
          DC.l m1_fopen,m1_fclose,m1_fread,m1_fwrite
          DC.l m1_stat,m1_lseek
          DC.l 0   ;datime, darf Nullzeiger sein
          DC.l m1_fcntl,m1_delete   ;(ioctl)
          DC.l 0,0,0                ;getc, getline, putc


sh_a_f_b: DC.w 0   ;Schatten fÅr a_for_bios (und a_for_gemdos)

          DC.b "XBRA","MAM1"
          DC.l 0
mama_auxc:          
;EingehÑngt in AuxControl
;D0.W =2: MacOS-Schlieûen wegen MagiCMac-Ende
;D0.W =1: (nur AUX) mit 0 geschlossenes MacOS îffnen
;D0.W =0: (nur AUX) MacOS schlieûen wegen Nutzeranforderung (MenÅpunkt)
          movem.l   d0-d7/a0-a6,-(sp)
          cmpi.w    #2,d0
          bne       .no2
;schlieûe dauerhaft wegen Ende
          tst.w     a_for_bios       ;teste auch a_for_gemdos
          beq       .ende            ;schon alles zu
          clr.w     a_for_bios       ;schlieûe "gewaltsam" bios/gemdos
          bsr       hs_a_close
          bra       .ende
.no2:     
          tst.w     raux_conf
          beq       .ende            ;keine Funktionen 0, 1 da nicht AUX
          cmpi.w    #1,d0
          bne       .no1
;wieder îffnen
          tst.w	sh_a_f_b
          beq       .ende            ;hops: es wurde nichts geschlossen
          bsr       hs_a_open		;Mac-Seite îffnen
	tst.l	d0
	bmi	.op_err		;hops: ôffnen fehlgeschlagen
	move.w	sh_a_f_b,a_for_bios	;merken dass offen
          bra       .ende
.op_err:
;Mac-Schnittstelle lieû sich nicht îffnen -> Nutzer vollmeckern
	bsr	print_faerr
	dc.b "Re-Open failed",cr,lf,0
	EVEN
	bra	.ende
.no1:     
          tst.w     d0
          bne       .ende
;schlieûe vorÅbergehend
          move.w    a_for_bios,sh_a_f_b
          beq       .ende            ;schon alles zu
          clr.w     a_for_bios
          bsr       hs_a_close

.ende:    
          movem.l   (sp)+,d0-d7/a0-a6
          move.l    (mama_auxc-4)(pc),-(sp)
          bne       .spr
          addq.l    #4,sp            ;keine weitere Routine
.spr:     
          rts                        ;weiterspringen oder RÅckkehr


;----------------------------------------------------------------------
          SECTION TEXT 

;############ akademische(?, immerhin kînnte sogar Mac-Programm dazwischen
;fummeln) Gefahr bei SerGetBuf und anschlieûendem synchronen Lesen:
;jemand kommt dazwischen und klaut die Daten raus #################


;Die Block-I/O-Routinen fÅr die serielle öbertragung
;Sie arbeiten nichtblockierend und lesen/schreiben nie mehr Byte, als
;im Puffer sind / in den Puffer passen.


m1_fread: 
;Fread fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich gelesener Byte oder Fehlercode
;kill: D0-D2/A0-A2
          move.l    d3,-(sp)
          moveq.l   #0,d3            ;bisher 0 Byte gelesen
          move.l    pbufcnt,d1
          beq       .a_em            ;nichts vorgelesen
          cmp.l     d0,d1
          bls       .a_nch
          move.l    d0,d1
.a_nch:
;minimum(noch_da, gefordert) in D1
          sub.l     d1,pbufcnt       ;"entnimm" schon mal symbolisch dem Puffer
          sub.l     d1,d0            ;verringere Anzahl (noch) geforderter Byte
          add.l     d1,d3            ;erhîhe Anzahl gelesener Byte
          subq.l    #1,d1            ;fÅr dbra, mîglich da Puffer immer <65000
          movea.l   pbufptr,a0       ;kopiere Bytes
.a_cp:    
          move.b    (a0)+,(a1)+
          dbra      d1,.a_cp
          move.l    a0,pbufptr
.a_em:    
          move.l    d0,d2            ;(noch) geforderte Anzahl sichern
          beq       .ende            ;kînnte ja 0 (geworden) sein
;jetzt ist der Vorlesepuffer auf jeden Fall leer
          bsr       hs_a_SerGetBuf
          cmp.l     pbuflen,d2       ;Forderung >= PufferlÑnge?
          bcc       .no_buf          ; ja, nicht puffern, sondern direkt
          cmp.l     d0,d2            ;im MAC vorhandenes > Forderung?
          bcc       .no_buf          ;  nein, nicht puffern
;lese minimum(PufferlÑnge, im_MAC_vorhandenes)
          cmp.l     pbuflen,d0
          bls       .a_ncc
          move.l    pbuflen,d0       ;PufferlÑnge ist kleineres
.a_ncc:   
          move.l    d0,d1            ;lies in Puffer
          lea       Param_in,a0
          move.l    pbufadr,ioBuffer(a0)
          move.l    d1,ioReqCount(a0)
          switchmac 
          _Read 
          switchatari 

          cmp.l     ioActCount+Param_in,d1
          beq       .a_eok
	bsr	print_faerr
	dc.b "Read-X1",cr,lf,0
	EVEN
.a_eok:

;jetzt ist mehr im Puffer (Anzahl in D1), als noch gefordert wird (in D2)
          movea.l   pbufadr,a0       ;ab Pufferanfang
          sub.l     d2,d1            ;soviel bleibt im Puffer
          add.l     d2,d3            ;soviel geben wir jetzt her
          subq.l    #1,d2            ;fÅr dbra
.a_2cp:   
          move.b    (a0)+,(a1)+
          dbra      d2,.a_2cp
          move.l    a0,pbufptr       ;aktueller Zeiger
          move.l    d1,pbufcnt       ;aktueller FÅllstand
          bra       .ende            ;fertig, und sogar Puffer gefÅllt

.no_buf:  
          cmp.l     d2,d0
          bcc       .gab             ;lese geforderte Anzahl, ist mehr da
          move.l    d0,d2            ;ganzen MAC-Puffer, weniger als verlangt
.gab:     
          tst.l     d2
          beq       .ende            ;nichts da
          lea       Param_in,a0
          move.l    a1,ioBuffer(a0)
          move.l    d2,ioReqCount(a0)
          switchmac 
          _Read 
          switchatari 

          cmp.l     ioActCount+Param_in,d2
          beq       .e2ok
	bsr	print_faerr
	dc.b "Read-X2",cr,lf,0
	EVEN
.e2ok:

          add.l     d2,d3            ;zum gelesenen dazu
.ende:    
          move.l    d3,d0
          move.l    (sp)+,d3
          rts       



m1_fwrite:          
;Fwrite fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG buffer
;      D0: LONG len
;out:  D0: Anzahl wirklich geschriebener Byte oder Fehlercode
;kill: D0-D2/A0-A2
          moveq.l   #0,d1            ;Bit31-16 muû 0 bleiben
          lea       m1_iorec,a2      ;Adr. IOREC
          move.w    ioo_tbl(a2),d2   ;PufferlÑnge
;freier Platz gilt fÅr nichtblockierenden bconout-Aufruf
          move.w    ioo_trp(a2),d1   ;freien Platz berechnen, Lesezeiger
          sub.w     ioo_twp(a2),d1   ;minus Schreibzeiger
          bhi       .fw0             ;keine Korrektur
          add.w     d2,d1            ;PufferlÑnge dazu
.fw0:     subq.l    #2,d1
          bpl       .fwxx
          moveq.l   #0,d1            ;Sicherheit, sollte nie negativ werden
.fwxx:              ;Anzahl freier PlÑtze in D1
          cmp.l     d0,d1
          bcc       .fw1             ;Minimum bilden
          move.l    d1,d0
.fw1:     tst.l     d0               ;Anzahl Åbertragbarer Bytes in D0
          beq       .fwend           ;nichts Åbertragen

          move.l    d0,-(sp)         ;Byteanzahl sichern
          movea.l   ioo_tba(a2),a0   ;Interruptpufferadresse
          move.w    ioo_twp(a2),d1   ;Schreibz

          bra       .fwbeg           ;letztes/einziges Byte per Bconout!
.fwcop:   addq.w    #1,d1            ;Schreibz umlaufend
          cmp.w     d2,d1            ;D2: PufferlÑnge
          bcs       .fwbt
          moveq     #0,d1
.fwbt:    move.b    (a1)+,0(a0,d1.l) ;Byte kopieren
.fwbeg:   subq.l    #1,d0
          bne       .fwcop
.fwlst:   
          move.w    d1,ioo_twp(a2)   ;Schreibz update
          move.b    (a1),d0          ;letztes Byte
          bsr       m1_ibconout      ;Byte schreiben, startet evtl Senden
          move.l    (sp)+,d0         ;Byteanz. holen
.fwend:   
          rts       



m1_fcntl: 
;Fcntl = ioctl fÅr MODEM1
;Mag!X-mÑûig
;in:   A0: Zeiger auf Filedeskriptor, ### derzeit Null
;      A1: LONG argument (meist ein Zeiger)
;      D0: WORD command
;out:  D0: Fehlercode
;kill: D0-D2/A0-A2
          cmpi.w    #FIONREAD,d0
          beq       .m000
          cmpi.w    #FIONWRITE,d0
          beq       .m001
          cmpi.w    #TIOCCBRK,d0
          beq       .m002
          cmpi.w    #TIOCSBRK,d0
          beq       .m003
          cmpi.w    #TIOCIBAUD,d0
          beq       .m004
          cmpi.w    #TIOCOBAUD,d0
          beq       .m005
          cmpi.w    #TIOCGFLAGS,d0
          beq       .m006
          cmpi.w    #TIOCSFLAGS,d0
          beq       .m007
          cmpi.w    #TIOCCTLMAP,d0
          beq       .m008
          cmpi.w    #TIOCCTLGET,d0
          beq       .m009
          cmpi.w    #TIOCCTLSET,d0
          beq       .m010
          cmpi.w    #TIONOTSEND,d0
          beq       .m011
          cmpi.w    #TIOCFLUSH,d0
          beq       .m012
          moveq.l   #EINVFN,d0       ;invalid function number, ## ??? passende Meldung
          bra       .ende
.ok_ende: 
          moveq.l   #0,d0            ;OK
.ende:    
          rts       

.m000:    
;FIONREAD
;Anzahl der ohne Warten lesbaren Byte auf der Adresse hinterlassen
          bsr       hs_a_SerGetBuf
          add.l     pbufcnt,d0       ;Bytes im Vorlesepuffer
          move.l    d0,(a1)          ;Anzahl vorhandene Byte
          bra       .ok_ende

.m001:    
;FIONWRITE
;Anzahl der ohne Warten schreibbaren Byte auf der Adresse hinterlassen
          moveq.l   #0,d1
          move.w    ioo_trp+m1_iorec,d1           ;Lesez
          sub.w     ioo_twp+m1_iorec,d1           ;Schreibz
          bhi       .m001a
          add.w     ioo_tbl+m1_iorec,d1
.m001a:   subq.l    #2,d1
          bpl       .m001b
          moveq.l   #0,d1            ;nur zur Sicherheit, dÅrfte nie - werden
.m001b:   move.l    d1,(a1)          ;Anzahl freier PlÑtze
          bra       .ok_ende

.m002:    
;TIOCCBRK
;Break inaktivieren
          moveq.l   #0,d2
          bsr       hs_a_SerXBrk     ;Break-Bit im TSR rÅcksetzen
          bra       .ok_ende

.m003:    
;TIOCSBRK
;Break aktivieren
          moveq.l   #8,d2
          bsr       hs_a_SerXBrk     ;Break-Bit im TSR setzen
          bra       .ok_ende


.m004:    
;TIOCIBAUD, genau wie TIOCOBAUD
.m005:    
;TIOCOBAUD
;Baudrate erfragen/setzen, DTR beeinflussen
          move.l    (a1),d0          ;speed
          bpl       .m005a
.m005ar:  
;nur erfragen
          move.l    a1,-(sp)         ;sichern
          moveq.l   #-1,d0           ;uspeed erfragen
          move.l    d0,-(sp)
          move.w    #SETUSPEED,-(sp)
          bsr       d_m1_rsconf      ;Direktaufruf Spezialfunktion
          addq.l    #6,sp
          movea.l   (sp)+,a1
          move.l    d0,(a1)
          bra       .ok_ende
.m005a:   
          bne       .m005b
          bsr       .dtr_reset       ;DTR inaktiv
          bra       .m005ar          ;noch Speed erfragen
.m005b:   
;setzen bzw. niedrigere liefern
          move.l    a1,-(sp)         ;sichern
          move.l    d0,-(sp)
          move.w    #SETUSPEED,-(sp)
          bsr       d_m1_rsconf
          addq.l    #6,sp
          movea.l   (sp)+,a1
          bclr.l    #31,d0           ;test and clear
          beq       .m005bo          ;ok, speed eingestellt
          move.l    d0,(a1)          ;speed-Vorschlag sichern
          moveq.l   #ERANGE,d0       ;Fehlermeldung
          bra       .ende
.m005bo:  
          move.l    d0,(a1)          ;alte speed sichern
          bsr       .dtr_set         ;DTR aktiv
          bra       .ok_ende


.m006:    
;TIOCGFLAGS
;Lesen der öbertragungsprotokollparameter
;da Rsconf den Handshakemodus nicht liefert, wird alles direkt zugegriffen
          moveq.l   #$f,d1           ;bit7-0 als AND-Maske
          move.b    ioo_ucr+m1_iorec,d0           ;UCR
          btst.l    #2,d0
          beq       .m006np          ;keine ParitÑt
          bset.l    #15,d1           ;set odd
          btst.l    #1,d0
          beq       .m006np          ;really odd parity
          bclr.l    #15,d1           ;clear odd parity flag
          bset.l    #14,d1           ;even parity
.m006np:  lsr.b     #3,d0            ;Bit/Char & Stoppbits nach Bit3-0
          and.b     d0,d1
          moveq.l   #3,d0            ;mask
          and.b     ioo_hsm+m1_iorec,d0           ;get direct: handshake mode
          moveq.l   #12,d2
          lsl.w     d2,d0            ;XON/XOFF & RTS/CTS
          or.w      d0,d1
          move.w    d1,(a1)          ;Wert ablegen
          bra       .ok_ende


.m007:    
;TIOCSFLAGS
;Setzen der öbertragungsprotokollparameter
;Rsconf ist umstÑndlich, aber der einzige Weg, den Handshake zu initialisieren
          move.w    (a1),d2          ;Wert holen
          moveq.l   #ERANGE,d0       ;vorsorglich Fehler
          moveq.l   #3,d1            ;teste Stoppbitanzahl
          and.w     d2,d1
          beq       .ende            ;Synchronmode nicht unterstÅtzt!
          moveq.l   #-1,d0
          move.l    d0,-(sp)         ;SCR und TSR nicht Ñndern
          move.w    d0,-(sp)         ;RSR nicht Ñndern
          moveq.l   #$f,d1           ;mask
          and.w     d2,d1
          lsl.b     #3,d1            ;Bit3-0 -> 6-3, Stopps & Bit/Char
          btst.l    #15,d2           ;odd parity?
          beq       .m007no          ;no
          bset.l    #2,d1            ;parity used, odd
.m007no:  btst.l    #14,d2           ;even parity?
          beq       .m007ne          ;no
          ori.b     #$06,d1          ;parity used, even
.m007ne:  bset.l    #7,d1            ;divide by 16, always in async mode
          move.w    d1,-(sp)         ;fÅr das UCR
          moveq.l   #12,d1
          lsr.w     d1,d2            ;Handshakebits nach Bit1-0
          andi.w    #3,d2
          move.w    d2,-(sp)         ;fÅr flowctl
          move.w    d0,-(sp)         ;-1 fÅr speed nicht Ñndern
;Direktaufruf wegen gleicher Registerkillkonvention mîglich
          bsr       d_m1_rsconf
          moveq.l   #0,d0            ;OK
.m007er:  
          lea       12(sp),sp
          bra       .ende


.m008:    
;TIOCCTLMAP
;Erfrage I/O-Lines and Signals
          move.l    #(TIOCM_BRK|TIOCM_RER),d0
          cmpi.b    #2,ioo_hsm+m1_iorec
          beq       .m008a
          ori.w     #TIOCM_DTR,d0    ;nur wenn kein Hardwarehandshake
.m008a:   
          tst.b     hwa_dcd
          beq       .m008b
          ori.w     #TIOCM_CD,d0     ;GPi/DCD-Zugriff erlaubt
.m008b:   
          move.l    d0,(a1)+
          moveq.l   #0,d0            ;zum lîschen
          move.l    d0,(a1)+         ;no callback activate
          move.l    d0,(a1)+         ;no callback inactivate
          move.l    d0,(a1)+         ;no signal
          move.l    d0,(a1)+         ;no signal
          move.l    d0,(a1)+         ;no extension
          bra       .ok_ende


.m009:    
;TIOCCTLGET
;Abfragen der I/O
;"Fehlerbits" dÅrfen nur zurÅckgesetzt werden, wenn sie erfragt wurden
;(also nicht beim freiwilligen ungefragten Mitliefern)
;hole Fehlerbits und Break-Status und speichere sie selbst
          lea       Param_in,a0
          move.w    #8,csCode(a0)
          switchmac 
          _Status_IMMEDIATE          ;lîscht Fehler auf Mac-Seite
          moveq.l   #0,d0
          tst.b     hwa_dcd          ;GPi-Zugriff erlaubt?
          beq       .m009e           ; nein
          move.w    sr,d2
          ori.w     #$700,sr
          movea.l   my_SCCRd,a0
          btst.b    #3,(a0)          ;RR0 SCC-X
          beq       .m009f
          ori.w     #TIOCM_CD,d0
.m009f:   
          move.w    d2,sr
.m009e:   
          switchatari 
          move.b    csParam+Param_in,d1
          or.b      ioo_xx0+m1_iorec,d1           ;eigene Fehlersammlung dazu
          move.l    #TIOCM_BRK,d2
          btst.l    #3,d1            ;Break?
          beq       .m009a
          or.w      d2,d0
.m009a:   
          and.l     (a1),d2          ;war Break gefragt?
          beq       .m009b           ;nein
          bclr.l    #3,d1            ; ja, lîschen (nicht lÑnger merken)
.m009b:   
          moveq.l   #$72,d2          ;Bit1, 4, 5, 6 sind Fehlerbits
          and.b     d1,d2            ;Empfangsfehler?
          beq       .m009c
          ori.w     #TIOCM_RER,d0
.m009c:   
          move.l    #TIOCM_RER,d2
          and.l     (a1),d2
          beq       .m009d           ; war nicht gefragt
          andi.b    #$8d,d1          ; war gefragt, also lîschen
.m009d:   
          move.b    d1,ioo_xx0+m1_iorec           ;(nichterfragtes) merken
          move.l    d0,(a1)          ;Bitsammlung ablegen
          bra       .ok_ende


.m010:    
;TIOCCTLSET
;Setzen der I/O-Lines: nur DTR beeinfluûbar
          move.l    (a1),d0
          andi.w    #TIOCM_DTR,d0
          beq       .m010a
          move.l    4(a1),d0
          andi.w    #TIOCM_DTR,d0
          bne       .m010aa          ;aktivieren
          bsr       .dtr_reset       ;inaktivieren
          bra       .m010a
.m010aa:  bsr       .dtr_set
.m010a:   
          bra       .ok_ende


.dtr_set: 
;DTR aktivieren, nur wenn kein Hardwarehandshake
          movem.l   d0/a0,-(sp)
          moveq.l   #17,d0           ;Assert DTR
          bra       .dtr_both

.dtr_reset:         
;DTR deaktivieren, nur wenn kein Hardwarehandshake
          movem.l   d0/a0,-(sp)
          moveq.l   #18,d0           ;Negate DTR
.dtr_both:          
          cmpi.b    #2,ioo_hsm+m1_iorec
          beq       .dtr_no
          lea       Param_out,a0
          move.w    d0,csCode(a0)
          switchmac 
          _Control_IMMEDIATE
          switchatari 
.dtr_no:  
          movem.l   (sp)+,d0/a0
          rts       


.m011:    
;TIONOTSEND
          bsr       m1_tionotsend
          move.l    d0,(a1)          ;Anzahl ungesendeter Byte
          bra       .ok_ende


.m012:    
;TIOCFLUSH
;verschiedene Arten des Pufferlîschens
          move.l    a1,d0            ;Parameter (hier kein Zeiger)
          bmi       .m012a           ;send all with user defined timeout
          beq       .m012b           ;send all with system timeout
          cmpi.l    #4,d0
          bcs       .m012c           ;1..3: clear buffers
          moveq.l   #EINVFN,d0       ;error: subsubfunction not supported
          bra       .ende

.m012a:   
;send all with user defined timeout
          moveq.l   #0,d2
          sub.l     d0,d2            ;(sub because -tout)
.m012ax:  
;send all with timeout in D2.l
          add.l     _hz_200,d2       ;wait max. until D2.l
.m012a0:  
          bsr       m1_tionotsend
          tst.l     d0
          beq       .ok_ende
;### simple wait loop in this implementation
          cmp.l     _hz_200,d2
          bcc       .m012a0          ;continue waiting
          moveq.l   #EDRVNR,d0
          bra       .ende            ;error: timeout

.m012b:   
;send all with system timeout
          move.l    #4000,d2         ;#### fest auf 20 Sekunden,
;#### spÑter baudraten- und DatenmengenabhÑngig
          bra       .m012ax

.m012c:   
;1..3: clear buffers
          move.l    d0,d2
          btst.l    #1,d2
          beq       .m012c1
;Bit1 =1: clear transmitter buffer (2, 3)
          lea       Param_out,a0
          switchmac 
          _KillIO   ;eventuell laufende Mac-Routine beenden
;####### das killt auch Eingaberoutinen, falls welche laufen wÅrden
          switchatari 
          clr.l     ioo_trp+m1_iorec ;Rest lîschen
.m012c1:  
          btst.l    #0,d2
          beq       .m012c6
;Bit0 =1: clear receiver buffer (1, 3)
          clr.l     pbufcnt          ;Vorlesepuffer leeren
          move.l    pbufadr,pbufptr
;Mac-Buffer lÑût sich nur durch Lesen lîschen, benutze Vorlesepuffer
          bsr       hs_a_SerGetBuf
          move.l    d0,d2
          beq       .m012c6          ;Mac ist leer
.m012c3:  
          cmp.l     pbuflen,d0       ;minimum(PufferlÑnge, Mac_bytes_da)
          bls       .m012c2
          move.l    pbuflen,d0
.m012c2:  
          sub.l     d0,d2
          lea       Param_in,a0
          move.l    pbufadr,ioBuffer(a0)
          move.l    d0,ioReqCount(a0)
          switchmac 
          _Read 
          switchatari 
          move.l    d2,d0            ;lies notfalls mehrere StÅcke, um alles
          bne       .m012c3          ;zu holen, was die Abfrage sagte
.m012c6:  
          bra       .ok_ende


m1_tionotsend:      
;Anzahl der noch nicht gesendeten Byte ermitteln, z.B. fÅr TIONOTSEND
;(Zeichen stehen im Puffer, bis async. Mac-Routine sich fertig meldet)
          moveq.l   #0,d0            ;Anzahl der Byte im Puffer
          move.w    ioo_twp+m1_iorec,d0           ;Schreibz
          sub.w     ioo_trp+m1_iorec,d0           ;Lesez
          bcc       .ns0
          add.w     ioo_tbl+m1_iorec,d0
.ns0:     
;####### man kînnte es genauer machen, in dem man noch ioActCount+Param_aso
;versucht zu subtrahieren, allerdings mÅûte man dann immer fÅr GÅltigkeit
;dieses Parameters sorgen, z.B. durch Nullsetzen beim Starten des Auftrags
;und wer sagt, daû ioActCount in der Zwischenzeit immer aktualisiert wird?
          rts       


;----------------------------------------------------------------------

;Datenstruktur des RSVF-Cookies
          EVEN 
          DC.l m1_drvr              ;Zeiger auf Routinentabelle
m1_name:  
wgna_0:   
          DC.b 'MODEM1',0,0,0,0,0,0,0,0          ;Name zum Objekt

          EVEN 

rsvflist: 
          DC.l m1_name              ;Zeiger auf Namen
          DC.b $e1,0
rsvf_binr:          DC.b 6          ;Bios-GerÑte-Nummer wird eingetragen
          DC.b 0
rsvf_next:          
          DC.l 0   ;erstmal NIL-Zeiger, Ende der Liste
          DC.b 0,0,0,0

;RAUSWERFEN{ wenn Magic soweit ist
leerlist: DC.l 0,0
;}RAUSWERFEN

;Adr. des ersten nichtresidenten Byte, fÅr zus. Speichervergabe
first_unresi:       DC.l prg_ende   ;Anfangswert

;----------------------------------------------------------------------
          DC.l 0
prg_ende:           ;muû hinter dem Letzten resident zu haltenden stehen


su_i_p0:  
;Supervisor: MgMc-Cookie suchen und etwas auswerten
          move.l    #'MgMc',-(sp)
          bsr       cookie_find
          addq.l    #4,sp
          tst.l     d0
          beq       .ende            ;nicht gefunden
          movea.l   d0,a0
          move.l    4(a0),d0         ;Cookie-Wert
          beq       .ende            ;unsinniger Wert
          move.l    d0,MgMc_adr      ;Cookie-Wert kopieren
          movea.l   d0,a0
          move.l    MM_modeAtari(a0),ZumAtariA
          move.l    MM_modeMac(a0),ZumMacA
;############
	move.l	MM_callMacContext(a0),my_camaco

          bsr       ca_flush         ;obiges sofort brauchbar machen
          moveq.l   #1,d0            ;OK
.ende:    
          rts       



sursini:  
;Supervisorteil RSVF-Ini, und anderes
;EinhÑngen in RSVF: hÑnge mich vor die Kette davor.
;Lasse absichtlich alte End- und Verkettungsobjekte drin.
;(interessanterweise darf man bei MagicMac auf $0-$7ff auch im Usermode)
          move.l    #'RSVF',-(sp)
          bsr       cookie_find
          addq.l    #4,sp
          tst.l     d0
          beq       .kein_rs
          movea.l   d0,a0
          move.l    4(a0),rsvf_next  ;hÑnge alte Obj. an mich (evtl NIL-ptr)
          move.l    #rsvflist,4(a0)  ;und meine Adr. in Cookie
.kein_rs: 
          rts       


ini_vnaco:          
;kopiere Name aus Cookie, von (A0) nach (A1), Pascal-Strings
          move.b    (a0),d0          ;hier noch kein increment
          beq       .ende            ;nichts da
          cmpi.b    #32,d0           ;max. 31 Zeichen
          bcc       .ende            ;zu lang
;(kopiere zuerst das nicht mitgezÑhlte LÑngenbyte, deshalb bis "cs")
.cop:     
          move.b    (a0)+,(a1)+
          subq.b    #1,d0
          bcc       .cop
.ende:    
          rts       


ini_knaco:          
;kopiere Name aus Konfig, von (A0) nach (A1), C-String -> Pascal
          moveq.l   #0,d0
.cop:     
          move.b    (a0)+,d1
          beq       .ende            ;0-byte = C-Ende
          move.b    d1,1(a1,d0.w)
          addq.w    #1,d0
          bra       .cop
.ende:    
          move.b    d0,(a1)          ;Pascal-LÑnge ablegen
          rts       



;Installation
starti:   
          bsr       prints
          DC.b $1b,"p ",0
          EVEN 
          pea       gn_conf
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp
          bsr       prints
          DC.b "-Routines for MagicMac ",$1b,"q",cr,lf,0
          EVEN 
          tst.w     aux_conf
          beq       .pt_0
          bsr       prints
          DC.b "using Mac-drivername from MagiCMac menu.",0
          EVEN 
          bra       .pt_1
.pt_0:    
          bsr       prints
          DC.b "MacOS Out: ",0
          EVEN 
          pea       xo_conf
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp
          bsr       prints
          DC.b cr,lf,"MacOS In: ",0
          EVEN 
          pea       xi_conf
          move.w    #9,-(sp)
          trap      #1               ;GEMDOS Cconws
          addq.l    #6,sp

.pt_1:    
          bsr       prints
          DC.b cr,lf,"(C) Harun Scheutzow 1996-02-17",cr,lf,0
          EVEN 

          move.w    dir_conf,c_dir_conf           ;Konfigs kopieren
          move.w    dcd_conf,c_dcd_conf
          move.w    hbd_conf,c_hbd_conf
          move.w    mid_conf,c_mbd_conf

          pea       su_i_p0          ;MgMc Cookie suchen und auswerten
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          tst.l     d0
          bne       .mgmc            ;OK
          bsr       prints
          DC.b "*** Error: MgMc-Cookie not present. Terminated.",bell,bell,cr,lf,cr,lf,0
          EVEN 
.nrend:   
;nichtresidentes Ende
          clr.w     -(sp)
          trap      #1               ;GEMDOS Pterm0

.mgmc:    
          move.w    aux_conf,raux_conf            ;kopieren und testen
          bmi       .nomana
;kopiere Mac-Treibernamen aus Konfig
          lea       xi_conf(pc),a0
          lea       Mac_XIn(pc),a1
          bsr       ini_knaco
          lea       xo_conf(pc),a0
          lea       Mac_XOut(pc),a1
          bsr       ini_knaco
          bra       .gname
.nomana:  
;kopiere Mac-Treibernamen aus MgMc-Cookie (MagiCMac-Einstellung)
          movea.l   MgMc_adr,a3
          movea.l   MM_auxOutName(a3),a0
          lea       Mac_XOut(pc),a1
          bsr       ini_vnaco
          movea.l   MM_auxInName(a3),a0
          lea       Mac_XIn(pc),a1
          bsr       ini_vnaco

.gname:   
;kopiere GEMDOS-Namen aus Konfig an zwei Stellen
          lea       gn_conf(pc),a0
          lea       wgna_0(pc),a1
          lea       wgna_1(pc),a2
.cop_gn:  
          move.b    (a0)+,d0
          move.b    d0,(a1)+
          move.b    d0,(a2)+
          bne       .cop_gn


          move.w    op_conf,dontclose             ;Konfig kopieren


          tst.w     nr6_conf
          beq       .mapa

;Maptab Åberschreiben
          pea       m1_routtab       ;Routinen eintragen
          move.w    #6,-(sp)         ;Kanal 6
          move.w    #MAPT_OVE,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (erweitert)
          lea       10(sp),sp
          tst.l     d0
          bne       m1ini1
          bsr       prints
          DC.b "*** MAPT_OVE-Error",bell,bell,bell,cr,lf,0
          EVEN 
          bra       .nrend           ;nichtresidentes Ende geht hier noch

.mapa:    
;an Maptab anhÑngen
          pea       m1_routtab       ;Routinen eintragen
          move.w    #MAPT_APP,-(sp)
          move.w    #44,-(sp)
          trap      #14              ;XBIOS Bconmap (erweitert)
          lea       10(sp),sp
          tst.l     d0
          bne       m1ini1
          bsr       prints
          DC.b "*** MAPT_APP-Error. Terminated.",bell,bell,bell,cr,lf,0
          EVEN 
          bra       .nrend           ;nichtresidentes Ende geht hier noch

m1ini1:   
          move.b    d0,rsvf_binr     ;BIOS-Nummer in RSVF-Objekt

          moveq.l   #1,d7            ;erster-Versuch-Flag
          bra       m1iniins         ;erst Installationsversuch, dann:
m1inidel: 
          pea       m1_iname         ;Dev. lîschen, falls Inst.Fehler,
          move.w    #65,-(sp)        ;weil es wohl schon existiert
          trap      #1               ;GEMDOS Fdelete
          addq.l    #6,sp
m1iniins: 
          pea       m1_drvr          ;Dev. in U:\DEV\ installieren
          pea       m1_iname
          move.w    #DEV_M_INSTALL,-(sp)
          move.w    #n_dcntl,-(sp)
          trap      #1               ;GEMDOS Dcntl (Mag!X)
          lea       12(sp),sp
          tst.l     d0               ;Fehler-negativ, sonst >=0 (evtl. Zeiger)
          dbpl      d7,m1inidel


          pea       sursini          ;RSVF
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          tst.l     d0
          bne       .rs_ok
          bsr       prints
          DC.b "*** Cookie RSVF not found",bell,bell,cr,lf,0
          EVEN 
.rs_ok:   

platz_end:          

init_end: 
          bsr       prints
          DC.b cr,lf,0              ;Leerzeile am Ende
          EVEN 

          movea.l   MgMc_adr,a0      ;in auxControl einhÑngen
          lea       mama_auxc,a1     ;um MagiCMac-Ende zu erfahren
          move.l    MM_auxControl(a0),-4(a1)      ;*** eigentlich kurz IPL 7 rein
          move.l    a1,MM_auxControl(a0)


;jetzt erfolgend keine Textausgaben mehr, da die Routine durch IOREC-
;Vergrîûerung zermatscht werden kînnte

;verschiebe die Routinen nach hinten, letztes Byte zuerst
          lea       start_moveable,a0
          lea       dest_move,a1
          move.l    #end_moveable-start_moveable-1,d0       ;Anzahl Bytes
spacmove: move.b    0(a0,d0.l),0(a1,d0.l)
          subq.l    #1,d0
          bpl       spacmove
          pea       ca_flush         ;Cache beachten
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp
          jmp       dest_move

;!!! Die verschobenen Routinen und Daten mÅssen in sich verschiebbar (relativ)
;und mit absoluten BezÅgen auf die auûerhalb "start_moveable".."end_moveable"
;liegenden Dinge sein.
;Sie werden nur am Label "dest_move" angesprungen.



;------------------------------------------


          INCLUDE "PRINTS.S"

          INCLUDE "COOKIE.S"


;------------------------------------------


m1_routtab:         
;Initialwerte fÅr Modem1 MAPTAB zum Kopieren in MAPTAB
          DC.l m1_bconstat
          DC.l m1_bconin
          DC.l m1_bcostat
          DC.l m1_bconout
          DC.l m1_rsconf
          DC.l m1_iorec             ;IOREC-Struktur Adresse


;Konfigurationszeug
          EVEN     ;wichtig!!!
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger

          DC.b "NR6: BIOS-Nummer 6 benutzen? (Nur fÅr einen Treiber sinnvoll.",cr,lf
          DC.b "Bei <Nein> werden freie Nummern ab 7 aufwÑrts genommen.)",cr,lf,0
          EVEN 
          DC.w 0   ;Entscheidung
nr6_conf: DC.w -1  ;-1 = Ja

          DC.b "USEAUX: Namenseinstellungen des MagiCMac-MenÅs benutzen?",cr,lf
          DC.b "(nur fÅr einen Treiber sinnvoll, wenn mehrere benutzt)",cr,lf,0
          EVEN 
          DC.w 0   ;Entscheidung
aux_conf: DC.w -1  ;-1 = Ja

          DC.b "INDRV: Mac-Inputdriver Name (max. 31 Zeichen),",cr,lf
          DC.b "bedeutungslos bei USEAUX = Ja",cr,lf,0
          EVEN 
          DC.w $0220                ;C-String mit 32 Zeichen gesamt
xi_conf:  DC.b ".BIn",0,0,0,0,0,0,0,0,0,0,0,0
          DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

          DC.b "OUTDRV: Mac-Outputdriver Name (max. 31 Zeichen)",cr,lf
          DC.b "bedeutungslos bei USEAUX = Ja",cr,lf,0
          EVEN 
          DC.w $0220                ;C-String mit 32 Zeichen gesamt
xo_conf:  DC.b ".BOut",0,0,0,0,0,0,0,0,0,0,0
          DC.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

          DC.b "GNAME: GEMDOS-Name des Treibers (max. 12 Zeichen),",cr,lf
          DC.b "z.B. MODEM1",cr,lf,0
          EVEN 
          DC.w $020e                ;C-String insgesamt 14 Zeichen
gn_conf:  DC.b "MODEM1",0,0,0,0,0,0,0,0

          DC.b "DTR: Einstellung des DTR-Signals beim Treiberstart",cr,lf
          DC.b "Ja   = aktiv (wie bei TOS)",cr,lf
          DC.b "Nein = inaktiv",cr,lf
          DC.b "(Funktioniert momentan (noch) nicht)",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
dtr_conf: DC.w -1  ;-1 fÅr aktiv

          DC.b "MACBUF: Einstellung der MAC-Empfangspuffergrîûe in Byte.",cr,lf
          DC.b "Sinnvoll ist 1024 bis 8192, Maximum 32000",cr,lf,0
          EVEN 
          DC.w $0101
mab_conf: DC.l 8192

          DC.b "RBL: Einstellung der Empfangspuffergrîûe in Byte.",cr,lf
          DC.b "Standard: 256,  Minimum: 16,  Maximum: 65534",cr,lf
          DC.b "(Hat momentan nur eine Bedeutung: belegt sinnlos RAM)",cr,lf,0
          EVEN 
          DC.w $0101                ;Cmd LONG-Liste, 1 StÅck
rbl_conf: DC.l 256

          DC.b "TBL: Einstellung der Sendepuffergrîûe in Byte.",cr,lf
          DC.b "Standard: 2048,  Minimum: 16,  Maximum: 65534",cr,lf,0
          EVEN 
          DC.w $0101                ;Cmd LONG-Liste, 1 StÅck
tbl_conf: DC.l 2048

          DC.b "EOP: Mac-Schnittstelle nach erster Nutzung offen halten?",cr,lf
          DC.b "Ja = entspricht dem Atari-Verhalten.",cr,lf
          DC.b "Nein = auf bei Fopen, zu bei Fclose. Zu Atari inkompatibel.",cr,lf,0
          EVEN 
          DC.w $0000
op_conf:  DC.w -1  ;ja, offen

          DC.b "DIR: SCC-Direktzugriff mîglich?",cr,lf
          DC.b "Ja  = normalerweise",cr,lf
          DC.b "Nein = bei Mac mit IOP, z.B. IIfx, Quadra 900",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
dir_conf: DC.w 0   ;nein

          DC.b "DCD: GPi-Line auf MODEM vorhanden?",cr,lf
          DC.b "Ja   = es gibt GPi, nutze als DCD",cr,lf
          DC.b "Nein = kein GPi, z.B. bei IIfx",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
dcd_conf: DC.w 0   ;nein

          DC.b "HBD: Hohe Baudraten erlauben?",cr,lf
          DC.b "Ja   = 115200 und 230400Bd einstellbar",cr,lf
          DC.b "Nein = kein Zugriff, z.B. bei IIfx",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
hbd_conf: DC.w 0   ;nein

          DC.b "MIDI: MIDI-Baudrate mit externer Taktung erlauben?",cr,lf
          DC.b "Ja   = 31250 mîglich mit externem Takt",cr,lf
          DC.b "Nein = keine 31250, sondern 28800 mit internem Takt",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
mid_conf: DC.w 0   ;nein

          DC.b 0   ;Nullstring als Ende-Kennung
          EVEN 



start_moveable:     
;zu verschiebende Routinen, nur absolute Referenzen auf auûerhalb Liegendes
;nur relative Referenzen intern
          move.l    #1024,d0
          move.l    mab_conf,d1      ;Mac-EmpfangspufferlÑnge
          cmpi.l    #64,d1
          bcs       .ma_def
          cmpi.l    #32700,d1
          bcc       .ma_def
          move.l    d1,d0
.ma_def:  
          move.l    first_unresi,macbufadr        ;Adresse
          add.l     d0,first_unresi  ;reserviere Platz
          move.w    d0,macbuflen     ;LÑnge

          move.l    #128,d0          ;VorlesepufferlÑnge
          move.l    d0,pbuflen
          move.l    first_unresi,d1
          move.l    d1,pbufadr
          move.l    d1,pbufptr
          add.l     d0,d1
          move.l    d1,first_unresi
          clr.l     pbufcnt

          move.l    rbl_conf,d0      ;EmpfangspufferlÑnge
          move.l    tbl_conf,d7      ;SendepufferlÑnge
          lea       m1_iorec,a0      ;Zeiger auf EmpfangsIOREC
          bsr       make_buf
          lea       ioo_tba+m1_iorec,a0           ;Zeiger auf SendeIOREC
          move.l    d7,d0
          bsr       make_buf

          clr.w     -(sp)
          move.l    first_unresi,d0
          subi.l    #(start-$100),d0
          move.l    d0,-(sp)         ;residente LÑnge
          move.w    #$31,-(sp)
          trap      #1               ;GEMDOS Ptermres


make_buf: 
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


end_moveable:       
;Ende des zu verschiebenden Bereiches


          SECTION BSS 
          EVEN 
          DS.b 65536*2+32800        ;Sicherheitsabstand fÅr zwei max. Puffer
          EVEN 
dest_move:                           ;Verschiebeziel
          DS.b end_moveable-start_moveable       ;Platz fÅr Routinen

          DS.l $400                 ;Stack-Platz nur fÅr Initialisierung

