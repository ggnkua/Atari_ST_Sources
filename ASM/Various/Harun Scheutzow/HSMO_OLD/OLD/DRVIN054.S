;Routinen fÅr ein eigenstÑndiges, vor den Treibern zu ladendes Programm

;Bedingte Assemblierung. MAMA != 0 nur fÅr MagiCMac (MagiC3 ohne RSVF & XBIOS)
MAMA      = 0

EXTRASICHER         = 0              ;=0: D1/D2/A1/A2 im BIOS-Trap nicht sichern


;Generelle Einstellungen fÅr GEN-Assembler
	MACHINE	MC68000
	OPT	ATARI
	OPT	OW-,O1+,O2+,O3+,O4+,O5+,O8+,O9+
;folgendes wÅrde ein Warning je optimierbaren VorwÑrtssprung ergeben,
;der aber nicht optimiert wird, weil GEN es nicht kann.
;;;;;;;	OPT	O6+,OW6+


;LauffÑhig mit jeder TOS-Version, auch 1.00
;sowie mindestens mit Mag!X >=2.00

;MAPTABs mit jedem TOS (bei 1.00 ohne xco*-Vektoren)
;erweitertes XBIOS Bconmap zum EinhÑngen in MAPTABs, und zum DazuhÑngen


;Aus GeschwindigkeitsgrÅnden (BIOS-Hack) sollte es hinten im \AUTO\
;stehen, aber noch vor allen Programmen, die MODEM/SERIAL irgendwie nutzen.


          INCDIR "E:\AHSMOD\LIB\"
          INCLUDE "MISC_DEF.S"
          INCLUDE "ERRNO.S"        ;Fehlermeldungen


;Makros zur Realisierung der Extra-Reigsitersicherungen
;im BIOS-Trap wegen Fehlern anderer Programme
killreg_save MACRO 
          IFNE EXTRASICHER
          movem.l   d1/d2/a1/a2,-(sp)
          ENDC 
          ENDM

killreg_restore MACRO
          IFNE EXTRASICHER
          movem.l   (sp)+,d1/d2/a1/a2
          ENDC 
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


hsdev_name          = 4

;--------------------------------------------------------


          TEXT 
start:    
          bra       starti
;Sprung nach hinten, damit mîglichst wenig resident bleibt


;----------------------------------------------------------

          IFNE 0=MAMA

;fÅr 57600Bd auf 68000/8MHz Maschinen und anderen langsamen

;auf den folgenden Platz muû bei Initialisierung die
;Adresse der entsprechenden Routine geschrieben werden
next_tim  = -$3e    ;NEXT_TIM, LineA-Variable -$3E (allgemein)


;HÑngt sich in etv_timer (im \AUTO\) und wird durch VDI nach NEXT_TIM gehÑngt
;oder hÑngt sich gleich nach NEXT_TIM (Start im Desktop)
          DC.b 'XBRA','RSVE'
old_gd_clock:       DC.l 0
my_gd_clock:        
;Heruntersetzen des IPL auf 4.
;(KÅrzeste Methode fÅr 6(und nichts anderem) auf 4 wÑre eori.w #$200,sr)
          ori.w     #$700,sr         ;IPL7, 20Takte lang der Befehl!
          andi.w    #$fcff,sr        ;IPL5, 20Takte
          move.l    old_gd_clock,-(sp)
          rts       

          ENDC 

;----------------------------------------------------------------------

my_env:   DC.b "_PNAM=DRVIN.PRG",0,0             ;eigenes residentes Envi
          EVEN 


;Realisiert unter allen TOS-Versionen eine eigenstÑndige Verwaltung
;fÅr MAPTABs
;XBIOS-Teil fÑngt ab:
;Bconmap
;Rsconf
;Iorec fÅr AUX
;BIOS-Teil fÑngt ab:
;fÅr GerÑt 1 (AUX) und GerÑt >=6: Bconstat, Bconin, Bcostat, Bconout




mapt_max  = 10      ;soviel MAPTABs max.


vabtabs:  
;VAPTABs: Vergleichs-MAPTABs
;mÅssen direkt vor den normalen MAPTABs liegen, werden mit dem Zweikomplement
;des Offsets und zusÑtzlichen -4 adressiert, sind sozusagen an der 0-Linie
;gespiegelte MAPTABs
          REPT mapt_max
          DC.l 0,0,0,0,0,0
          ENDR 


maptabs:  
;Platz und Dummy-Besetzung fÅr MAPTABs
          REPT mapt_max
          DC.l only_rts             ;Dummy-Routinen
          DC.l only_rts             ;irgendwie muû man das fÅllen
          DC.l only_rts
          DC.l only_rts
          DC.l only_rts
          DC.l 0   ;Dummy IOREC-Zeiger
          ENDR 


only_rts: rts       
;Ein Kanal ist in der MAPTAB immer als vorhanden gekennzeichnet, so
;daû der MODEM1-Treiber sich immer mit MAPT_OVE initialisiert.



;Erweiterte BCONMAP-Struktur:
;(Erweiterung:)
          DC.w mapt_max             ;Anzahl der PlÑtze fÅr MAPTABs
str_bconmap:        
;(Dokumentiertes folgt:)
          DC.l maptabs              ;Zeiger auf erste MAPTAB
          DC.w 1   ;Anzahl der KanÑle (belegten MAPTABs)
;(Undokumentiertes, bei TOS und Mag!X so:)
          DC.w 6   ;aktuell auf AUX eingestellte Kanalnummer
          DC.l only_rts             ;Zeiger auf aktuell eingestellte Rsconf-Funktion
          DC.l 0   ;Zeiger auf IOREC des aktuellen Kanals



;XBIOS-Teil, wird in XBIOS-Trap#14 eingehÑngt
          DC.b 'XBRA','RSVE'
oldxbiosv:          DC.l 0
t14_xbios:          
          move.l    usp,a0           ;da die Daten meist auf Userstack liegen
          btst      #5,(sp)          ;diese Reihenfolge
          beq.s     t14_dus          ;Daten auf Userstack, ab (a0)
t14_xP:   
          lea       8(sp),a0         ;wird beim Start evtl. auf 6 gepatcht
t14_dus:  
;teste ob abzufangende Funktion
          cmpi.l    #$000e0000,(a0)  ;Iorec fÅr 0, also AUX?
          beq       t14_iorec        ;ja
          cmpi.w    #15,(a0)         ;Rsconf?
          beq       t14_rsconf       ;ja
          cmpi.w    #44,(a0)         ;Bconmap?
          beq.s     t14_bconmap      ;ja
          movea.l   oldxbiosv,a0
          jmp       (a0)             ;altes XBIOS anspringen


t14_bconmap:        
;Bconmap
;kill: D0, D1, D2, A0, A1
          moveq.l   #0,d0            ;vor allem Highword lîschen
          move.w    2(a0),d1         ;Parameter
          beq       t14_b_en         ;0: Test auf Vorhandensein
          cmpi.w    #6,d1
          bge       t14_b_sd         ;>=6 (signed): GerÑt einstellen
          cmpi.w    #-1,d1
          bne.s     t14_b_1
          move.w    6+str_bconmap,d0 ;-1: akt. Kanalnummer liefern
          rte       
t14_b_1:  
          cmpi.w    #-2,d1
          bne.s     t14_b_2
          move.l    #str_bconmap,d0  ;-2: Zeiger auf BCONMAP-Struktur liefern
          rte       
t14_b_2:  
          cmpi.w    #MAPT_OVE,d1     ;MAPT_OVE: GerÑt Åberschreiben
          bne.s     t14_b_3
          moveq.l   #-15,d0          ;Fehler EUNDEV, G# existiert nicht
          move.w    4(a0),d1         ;Parameter: G#
          move.w    d1,d2            ;sichern
          subq.w    #6,d1            ;G# ab 0
          cmp.w     4+str_bconmap,d1 ;Anzahl install. G
          bcc.s     t14_b_2e         ;G existiert nicht
          moveq.l   #0,d0
          move.w    d2,d0            ;G# als positive RÅckmeldung
          mulu.w    #24,d1
          movea.l   6(a0),a0         ;Parameter: Adr. des Zeigerblocks
          move.w    sr,d2
          swap.w    d2               ;Highword nicht nutzen
          ori.w     #$700,sr         ;INTERRUPTSPERRE (als Multitasksicherung)
          movea.l   str_bconmap,a1
          lea       0(a1,d1.w),a2    ;Zeiger auf gesuchte MAPTAB (post-inc)
          move.w    d1,d2
          neg.w     d2
          lea       0(a1,d2.w),a1    ;Zeiger auf gesuchte VAPTAB (pre-dec)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          swap.w    d2
          move.w    d2,sr            ;INTERRUPTS FREI
          cmp.w     6+str_bconmap,d0 ;aktuelles == modifiziertes G?
          bne.s     t14_b_2e         ; nein, Ende
          move.w    d0,d1            ; ja
          bra.s     t14_b_sd         ;in AUX-Vektoren kopieren
t14_b_2e: 
          rte       

t14_b_3:  
          cmpi.w    #MAPT_APP,d1     ;MAPT_APP: GerÑt hinten anhÑngen
          bne.s     t14_b_4
          moveq.l   #-12,d0          ;Fehlercode EGENRL, kein Platz mehr
          move.w    sr,-(sp)
          ori.w     #$700,sr         ;INTERRUPTSPERRE (als Multitasksicherung)
          move.w    4+str_bconmap,d1 ;Anzahl installierter G
          cmp.w     -2+str_bconmap,d1             ;Anzahl PlÑtze gesamt
          bcc.s     t14_b_3e         ;Ende, da kein Platz mehr
          movea.l   4(a0),a0         ;Parameter: Adr. des Zeigerblocks
          moveq.l   #24,d0
          mulu.w    d1,d0
          movea.l   str_bconmap,a1
          lea       0(a1,d0.w),a2    ;Adr. hinter alte MAPTABs
          neg.w     d0
          lea       0(a1,d0.w),a1    ;Adr. auf freie VAPTAB
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          move.l    (a0),(a2)+
          move.l    (a0)+,-(a1)
          addq.w    #1,d1            ;ein G mehr installiert
          move.w    d1,4+str_bconmap
          moveq.l   #5,d0
          add.w     d1,d0            ;gewÑhlte G# als positive RÅckmeldung
t14_b_3e: 
          move.w    (sp)+,sr         ;INTERRUPTS FREI
          rte       
t14_b_4:  
;hier kînnten noch Erweiterungen rein, die negative Subfunktionsnummern haben
          moveq.l   #0,d0            ;Original-RÅckmeldung: falscher Parameter
t14_b_en: 
          rte       
t14_b_sd: 
;wird auch von MAPT_OVE benutzt, wenn akt. G modifiziert (setzt voraus, daû
;alte xco* nicht gesichert werden)
          move.w    d1,d2            ;neue G# merken
          subq.w    #6,d1            ;GerÑtenummer ab 0
          cmp.w     4+str_bconmap,d1 ;Anzahl der MAPTABs
          bcc       t14_b_en         ;Fehler, G# zu groû (in D0.L ist noch 0)
;** Die alten xco* werden NICHT in die MAPTAB gesichert. Wer sich nur
;** in die xco* einhÑngt, fliegt eben raus.
          mulu.w    #24,d1           ;6 LONG pro MAPTAB, wir haben Zeit
          movea.l   str_bconmap,a0
          lea       0(a0,d1.w),a0    ;geht schneller
          movea.l   a0,a1            ;wegen TOS1.00-Patch
;trage neue AUX-Vektoren aus MAPTAB ein
          move.w    sr,d1
          ori.w     #$700,sr         ;INTERRUPTSPERRE
t14_b_s0: 
;die vier xco*-Zugriffe werden fÅr TOS1.00 durch NOPs Åberschrieben
          move.l    (a0)+,$51e+4     ;xconstat AUX
          move.l    (a0)+,$53e+4     ;xconin AUX
          move.l    (a0)+,$55e+4     ;xcostat AUX
          move.l    (a0)+,$57e+4     ;xconout AUX
t14_b_e0: 
          move.l    16(a1),8+str_bconmap          ;Rsconf
          move.l    20(a1),12+str_bconmap         ;IOREC AUX
          move.w    6+str_bconmap,d0 ;ehemals akt. G# als return
          move.w    d2,6+str_bconmap ;neue G# eintragen
          move.w    d1,sr            ;INTERRUPTS FREI
          rte       

t14_rsconf:         
;nicht zeitkritisch, deshalb Register immer sichern
          movem.l   d3-d7/a3-a6,-(sp)
          move.l    10(a0),-(sp)     ;6 words auf Stack umschaufeln
          move.l    6(a0),-(sp)
          move.l    2(a0),-(sp)
;da nur d0-d2/a0-a2 gekillt werden, keine Sicherung erforderlich
          movea.l   8+str_bconmap,a0 ;Adr. Rsconf des akt. GerÑtes
          jsr       (a0)             ;aufrufen
          lea       12(sp),sp
          movem.l   (sp)+,d3-d7/a3-a6
          rte       

t14_iorec:          
;Gibt es nur fÅr GerÑt AUX, liefere Adresse des IOREC des per Bconmap
;fÅr AUX eingestellten GerÑtes
;(beseitigt nebenbei den TOS2.05 Iorec-Fehler)
          move.l    12+str_bconmap,d0
          rte       




;BIOS-Teil, wird in BIOS-Trap#13 gehÑngt
;Mit Hack, um die Datenrate wesentlich zu steigern.

          DC.b 'XBRA','RSVE'
oldbiosv: DC.l 0
t13_bios: 
          move.l    usp,a0           ;da die Daten meist auf Userstack liegen
          btst      #5,(sp)          ;diese Reihenfolge
          beq.s     t13_dus          ;Daten auf Userstack, ab (a0)
t13_bP:   
          lea       8(sp),a0         ;wird beim Start evtl. auf 6 gepatcht
t13_dus:  
          killreg_save 
          move.w    (a0)+,d1         ;Funktions#
          cmpi.w    #9,d1
          bcs.s     t13_cafu         ;0..8: weiter testen
t13_bto:  
          killreg_restore 
          movea.l   oldbiosv(pc),a0
          jmp       (a0)             ;altes BIOS
t13_ofta: 
;Offset der BIOS-Fkt 0..8 in MAPTAB, negativ fÅr ungÅltig
          DC.b -1,0,4,12
          DC.b -1,-1,-1,-1
          DC.b 8
          EVEN 
t13_cafu: 
          move.b    t13_ofta(pc,d1.w),d0          ;Offset in erster MAPTAB
          bmi       t13_bto          ;keine MAPTAB-Fkt
          ext.w     d0               ;D1.W wird spÑter noch gebraucht
          move.w    (a0)+,d2         ;hole Kanalnummer
          subq.w    #1,d2
          bne.s     t13_nau          ;nicht Kanal 1, AUX
          move.w    6+str_bconmap(pc),d2          ;Nummer des akt. AUX
          subq.w    #6,d2
          bra.s     t13_dir
t13_nau:  
          subq.w    #5,d2
          bcs       t13_bto          ;Kanal < 6, altes BIOS
          cmp.w     4+str_bconmap(pc),d2
          bcc       t13_bto          ;Kanal > vorhanden, altes BIOS
t13_dir:  
          movea.l   str_bconmap(pc),a1            ;A1 zeigt auf 1.MAPTAB
          lsl.w     #3,d2            ;Kanal*24 = Kanal*8 *3
          add.w     d2,d0            ;3* zum Offset dazu
          add.w     d2,d0
          add.w     d2,d0
          movea.l   0(a1,d0.w),a2    ;Adr. der Routine
          neg.w     d0               ;Zweierkomplement Offset
          cmpa.l    -4(a1,d0.w),a2   ;Adr. unverÑndert?
          bne.s     t13_mod          ; nein

          subq.w    #3,d1            ;BIOS(3,..) =Bconout
          beq.s     t13_bco          ;Bconout -> extra Offset
          jsr       (a2)             ;Routine aufrufen
          killreg_restore 
          rte       
t13_bco:  
;Bconout: A0 zeigt schon auf WORD mit Zeichen
          jsr       4(a2)            ;Aufruf mit Offset 4
          killreg_restore 
          rte       

t13_mod:  
;irgendwer hat nichtfreundliche Routinen reingehÑngt
          movem.l   d3-d7/a3-a6,-(sp)             ;Aufruf mit Registersicherung
          subq.w    #3,d1            ;BIOS(3,..) =Bconout
          beq.s     t13_mbco         ;Bconout -> Parameter laden
          jsr       (a2)
          movem.l   (sp)+,d3-d7/a3-a6
          killreg_restore 
          rte       
t13_mbco: 
          move.w    (a0),d0          ;Parameter Zeichen
          move.l    d0,-(sp)         ;LONG! wegen dummy-Kanalnr
          jsr       (a2)
          addq.l    #4,sp
          movem.l   (sp)+,d3-d7/a3-a6
          killreg_restore 
          rte       




rsvf_list:          
          DC.l 0,0 ;NIL-Zeiger als RSVF-Listen-Ende (leere RSVF-Liste)

          DC.w 0   ;sicherheitsabstand

;-----------------------------------

          IFNE 0=MAMA

gemdospart:         
;AB HIER NICHTRESIDENT bei Mag!X >= 3.00


;GEMDOS Trap#1

m1_handle           = $4246          ;festes handle fÅr erstes GerÑt
;weitere handle werden in aufsteigender Reihenfolge vergeben


;Hack zum EinhÑngen in den GEMDOS-Trap #1 zum EinfÅgen der MinT/Mag!X
;-kompatiblen Routinen

;ZugestÑndnis an Scheiûprogramme (Modula(A1/A2/D1/A2), TurboC(A2)):
;killt nur A0/D0

          DC.b 'XBRA'
          DC.b 'RSVE'
oldgemdosv:         DC.l 0

t1_gemdos:          
          move.l    usp,a0           ;da die Daten meist auf Userstack liegen
          btst      #5,(sp)          ;diese Reihenfolge
          beq.s     t1_bss           ;Daten schon auf Superstack
t1_gP:    
          lea       8(sp),a0         ;wird beim Start evtl. auf 6 gepatcht
t1_bss:   
          move.w    (a0)+,d0         ;Funktionsnummer
          cmpi.w    #n_dcntl,d0
          beq       t1_dcntl
          cmpi.w    #n_fopen,d0
          beq       t1_fopen
          cmpi.w    #n_fcntl,d0      ;teste Funktionsnummern
          beq.s     t1_fcntl         ;Fcntl
          cmpi.w    #n_fclose,d0
          beq.s     t1_fclose
          cmpi.w    #n_fread,d0
          beq.s     t1_fread
          cmpi.w    #n_fwrite,d0
          beq       t1_fwrite
          cmpi.w    #$41,d0          ;Fdelete ########
          beq       t1_fdelete

t1_old:   movea.l   oldgemdosv(pc),a0
          jmp       (a0)             ;altes GEMDOS anspringen


t1_fcntl: 
          move.w    (a0)+,d0         ;teste handle
          subi.w    #m1_handle,d0
          bcs       t1_old           ;zu klein, raus hier & weiter
          cmp.w     max_dev,d0
          bcc       t1_old           ;zu groû, raus hier & weiter
;Internes Handle=GerÑtenummer in D0.W
          movem.l   d1/d2/a1/a2,-(sp)             ;sichern
          lsl.w     #3,d0            ;2*LONG-Tabelle
          movea.l   ptr2dev0,a2      ;Zeiger auf Adr.Tabelle
          movea.l   0(a2,d0.w),a2    ;Zeiger auf Treiberblock
          movea.l   mdev_ioctl(a2),a2             ;Zeiger auf Routine
          movea.l   (a0)+,a1
          move.w    (a0),d0          ;Parameter umschaufeln
          suba.l    a0,a0            ;## Fileptr (Mag!X) als Nullptr
          jsr       (a2)
          movem.l   (sp)+,d1/d2/a1/a2             ;zurÅckholen
          rte       


t1_fclose:          
          move.w    (a0),d0          ;teste handle
          subi.w    #m1_handle,d0
          bcs       t1_old           ;zu klein, raus hier & weiter
          cmp.w     max_dev,d0
          bcc       t1_old           ;zu groû, raus hier & weiter
;Internes Handle=GerÑtenummer in D0.W
          movem.l   d1/d2/a1/a2,-(sp)             ;sichern
          lsl.w     #3,d0            ;2*LONG-Tabelle
          movea.l   ptr2dev0,a2      ;Zeiger auf Adr.Tabelle
          movea.l   hsdev_name(a2,d0.w),a1        ;Zeiger auf Namen
          clr.b     -1(a1)           ;lîsche Open-Statusbyte
          movea.l   0(a2,d0.w),a2    ;Zeiger auf Treiberblock
          movea.l   mdev_close(a2),a2             ;Zeiger auf Routine
          suba.l    a0,a0            ;Fileptr #### erstmal Nullzeiger
          jsr       (a2)
          movem.l   (sp)+,d1/d2/a1/a2             ;zurÅckholen
          rte       


t1_fread: 
          move.w    (a0)+,d0         ;teste handle
          subi.w    #m1_handle,d0
          bcs       t1_old           ;zu klein, raus hier & weiter
          cmp.w     max_dev,d0
          bcc       t1_old           ;zu groû, raus hier & weiter
;Internes Handle=GerÑtenummer in D0.W
          movem.l   d1/d2/a1/a2,-(sp)             ;sichern
          lsl.w     #3,d0            ;2*LONG-Tabelle
          movea.l   ptr2dev0,a2      ;Zeiger auf Adr.Tabelle
          movea.l   0(a2,d0.w),a2    ;Zeiger auf Treiberblock
          movea.l   mdev_read(a2),a2 ;Zeiger auf Routine
          move.l    (a0)+,d0         ;Parameter umschaufeln
          movea.l   (a0),a1
          suba.l    a0,a0             ;Fileptr #### erstmal Nullzeiger
          jsr       (a2)
          movem.l   (sp)+,d1/d2/a1/a2             ;zurÅckholen
          rte       


t1_fwrite:          
          move.w    (a0)+,d0         ;teste handle
          subi.w    #m1_handle,d0
          bcs       t1_old           ;zu klein, raus hier & weiter
          cmp.w     max_dev,d0
          bcc       t1_old           ;zu groû, raus hier & weiter
;Internes Handle=GerÑtenummer in D0.W
          movem.l   d1/d2/a1/a2,-(sp)             ;sichern
          lsl.w     #3,d0            ;2*LONG-Tabelle
          movea.l   ptr2dev0,a2      ;Zeiger auf Adr.Tabelle
          movea.l   0(a2,d0.w),a2    ;Zeiger auf Treiberblock
          movea.l   mdev_write(a2),a2             ;Zeiger auf Routine
          move.l    (a0)+,d0         ;Parameter umschaufeln
          movea.l   (a0),a1
          suba.l    a0,a0            ;Fileptr #### erstmal Nullzeiger
          jsr       (a2)
          movem.l   (sp)+,d1/d2/a1/a2             ;zurÅckholen
          rte       


t1_fopen: 
;Fopen, teste ob "U:\DEV\known_device", case-insensitiv
          movem.l   d1-d3/a1-a3,-(sp)             ;sichern
          movea.l   (a0)+,a2         ;Zeiger auf Filenamen
          move.w    (a0),d3          ;Parameter mode merken (### fÅr Zukunft
          bsr.s     udev_test        ;teste ob Filename mit 'U:\DEV\' beginnt
          beq.s     .na1_ok
.not_udev:          
          movem.l   (sp)+,d1-d3/a1-a3             ;zurÅckholen
          bra       t1_old           ;nicht meine GerÑte
.na1_ok:  
;'U:\DEV\' stimmt, dahinter weiter testen
          movea.l   a2,a0            ;Zeiger auf eigentlichen Devicename
          movea.l   ptr2dev0,a3      ;erster GerÑteeintrag
.next:    
          tst.l     (a3)+            ;setzt Flags
          movea.l   (a3)+,a1         ;(keine Flags) Zeiger auf Name
          beq.s     .pl_leer
          bsr       string_ucomp     ;A0, A1 unverÑndert
          tst.l     d0
          bmi.s     .found           ;gefunden
.pl_leer: 
          cmpa.l    ptrbldev,a3
          bcs       .next            ;nÑchstes prÅfen
          bra       .not_udev        ;keine öbereinstimmung, altes
.found:   
;A3 zeigt auf nÑchstes GerÑt
;A1 zeigt auf Namen im NamenRAM
          subq.l    #8,a3            ;auf gefundenes GerÑt
          tst.w     evexop
          beq.s     .no_ex           ;immer nicht exclusives Fopen
;Exclusives Fopen, GerÑt darf nur einmal geîffnet sein
          moveq.l   #EACCDN,d0       ;vorsorglich Fehler
          bset.b    #7,-1(a1)        ;teste & setze Statusbyte
          bne.s     .ende
.no_ex:   
          movea.l   (a3),a2          ;Zeiger auf Treiberblock
          movea.l   mdev_open(a2),a2 ;Zeiger auf Routine
          suba.l    a0,a0            ;Fileptr #### erstmal Nullzeiger
          jsr       (a2)             ;kann Fehler in D0.l melden
          tst.l     d0
          bne.s     .ende            ;Fehler!
;OK, D0 ist 0 (Bit31..16 =0)
          suba.l    ptr2dev0,a3      ;ermittle Nummer aus Zeiger
          move.w    a3,d0
          lsr.w     #3,d0            ;da 8 Byte pro GerÑt
          addi.w    #m1_handle,d0    ;plus Grundwert handle
.ende:    
          movem.l   (sp)+,d1-d3/a1-a3             ;zurÅckholen
          rte       



udev_test:          
;teste auf U:\DEV\ (fÅr Fopen, Dcntl, Fdelete, ...)
;in:   A2 Zeiger auf String, GROSS/klein egal
;out:  wenn es String "U:\DEV\" ist: A2 dahinter, Z-Flag gesetzt
;       sonst: A2 undef., Z-Flag gelîscht
;kill: D0
          moveq.l   #$df,d0
          and.b     (a2)+,d0
          cmpi.b    #'U',d0
          bne.s     .no
          cmpi.b    #':',(a2)+
          bne.s     .no
          cmpi.b    #'\',(a2)+
          bne.s     .no
          moveq.l   #$df,d0
          and.b     (a2)+,d0
          cmpi.b    #'D',d0
          bne.s     .no
          moveq.l   #$df,d0
          and.b     (a2)+,d0
          cmpi.b    #'E',d0
          bne.s     .no
          moveq.l   #$df,d0
          and.b     (a2)+,d0
          cmpi.b    #'V',d0
          bne.s     .no
          cmpi.b    #'\',(a2)+
.no:      
          rts       


t1_dcntl: 
;GEMDOS $130: Dcntl
;(nicht ganz Multitask-sicher, aber wer im Interrupt (und anders wird der
;Supermode nicht unterbrochen) Devices installiert -> selbst schuld)
          cmpi.w    #DEV_M_INSTALL,(a0)+          ;Mag!X-Device-Install?
          bne       t1_old           ; nein
          movem.l   d1-d3/a1-a4,-(sp)             ;sichern
          movea.l   (a0)+,a2         ;A2: Zeiger auf Filename (Parameter)
          movea.l   (a0),a4          ;A4: Zeiger auf Driverstruktur (Parameter)
          bsr       udev_test        ;Filename "U:\DEV\..."?
;A2 zeigt hinter U:\DEV\ auf eigentlichen Namen
          beq.s     .ist_udev
          moveq.l   #EPTHNF,d0
          bra.s     .ende            ;Fehler, kein U:\DEV\devname
.ist_udev:          
;Existiert bereits ein GerÑt gleichen Namens? (ja -> EACCDN)
;suche gleichzeitig ersten freien Platz
          moveq.l   #0,d3            ;Zeiger auf freien Platz (0: keiner)
          movea.l   a2,a0            ;Zeiger auf eigentlichen Devicename
          movea.l   ptr2dev0,a3      ;erster GerÑteeintrag
.next:    
          tst.l     (a3)+            ;setzt Flags
          movea.l   (a3)+,a1         ;(keine Flags) Zeiger auf Name
          beq.s     .pl_leer
          bsr       string_ucomp     ;A0, A1 unverÑndert
          tst.l     d0
          bpl.s     .na_neq          ;nicht (genau) gleich
          moveq.l   #EACCDN,d0       ;GerÑt existiert schon
          bra.s     .ende            ;Fehler
.pl_leer: 
          tst.l     d3               ;schon freien gefunden?
          bne.s     .na_neq          ; ja
          move.l    a3,d3            ; nein, aber jetzt, merke ptr+8
.na_neq:  
          cmpa.l    ptrbldev,a3
          bcs       .next            ;nÑchstes prÅfen
;keine öbereinstimmung mit schon installierten GerÑten
          moveq.l   #ENSMEM,d0       ;vorsorglich: kein-Platz-frei-Fehler
          tst.l     d3
          beq.s     .ende            ;nichts war frei
          subq.l    #8,d3            ;ptr+8 korrigieren auf den Platz selbst
          movea.l   d3,a1
          movea.l   ptr2fnram,a0     ;auf freien Namen-RAM
          cmpa.l    ptr_b_nram,a0    ;hinter Namen-RAM
          bcc.s     .ende            ;kein Platz im Namen-RAM
          clr.b     (a0)+            ;Statusbyte (vor dem Namen) lîschen
          move.l    a0,d2            ;D2: Zeiger auf Namen (Zielpos.)
.kop_nam: 
          cmpa.l    ptr_b_nram,a0    ;hinter Namen-RAM
          bcc.s     .ende            ;kein Platz im Namen-RAM
          move.b    (a2)+,(a0)+      ;kopiere inklusive Nullbyte
          bne       .kop_nam
          move.l    a0,ptr2fnram     ;neuer freier Platz fÅr Namen
          move.l    a4,(a1)+         ;endlich: Zeiger auf Treiberblock
          move.l    d2,(a1)          ; Zeiger auf Namen  eintragen
          moveq.l   #0,d0            ;OK, 0 anstelle Zeiger auf Struktur ####
.ende:    
          movem.l   (sp)+,d1-d3/a1-a4
          rte       


t1_fdelete:         
;Fdelete, teste ob "U:\DEV\known_device", case-insensitiv
          movem.l   d1-d3/a1-a3,-(sp)             ;sichern
          movea.l   (a0),a2          ;Zeiger auf Filenamen
          bsr       udev_test        ;teste ob Filename mit 'U:\DEV\' beginnt
          beq.s     .na1_ok
.not_udev:          
          movem.l   (sp)+,d1-d3/a1-a3             ;zurÅckholen
          bra       t1_old           ;nicht meine GerÑte
.na1_ok:  
;'U:\DEV\' stimmt, dahinter weiter testen
          movea.l   a2,a0            ;Zeiger auf eigentlichen Devicename
          movea.l   ptr2dev0,a3      ;erster GerÑteeintrag
.next:    
          tst.l     (a3)+            ;setzt Flags
          movea.l   (a3)+,a1         ;(keine Flags) Zeiger auf Name
          beq.s     .pl_leer
          bsr.s     string_ucomp     ;A0, A1 unverÑndert
          tst.l     d0
          bmi.s     .found           ;gefunden
.pl_leer: 
          cmpa.l    ptrbldev,a3
          bcs       .next            ;nÑchstes prÅfen
          bra       .not_udev        ;keine öbereinstimmung, altes
.found:   
;A3 zeigt auf nÑchstes GerÑt
;A1 zeigt auf Namen im NamenRAM
          subq.l    #8,a3            ;auf gefundenes GerÑt

;########## es wird nur im exclusiv-Mode getestet, ob das GerÑt
;offen ist (da es nur dort bekannt ist) und dann Lîschen verhindert
          tst.w     evexop
          beq.s     .no_ex           ;immer nicht exclusiv
;Exclusives Fopen
          moveq.l   #EACCDN,d0       ;vorsorglich Fehler
          bset.b    #7,-1(a1)        ;teste & setze Statusbyte
          bne.s     .ende
.no_ex:   
          movea.l   (a3),a2          ;Zeiger auf Treiberblock
          movea.l   mdev_delete(a2),a2            ;Zeiger auf Routine
          suba.l    a0,a0            ;Fileptr #### erstmal Nullzeiger
          jsr       (a2)             ;kann Fehler in D0.l melden
          tst.l     d0
          bne.s     .ende            ;Fehler!
;OK, D0 ist 0
;GerÑt aus Liste der Zeiger rauswerfen
          clr.l     (a3)+            ;Zeiger auf Treiberblock
          movea.l   (a3),a0          ;Zeiger auf Namen
          clr.l     (a3)             ; lîschen
;Platz im Namen-RAM freigegeben
;######## nicht multitask / interruptsicher #########
          lea       -1(a0),a1        ;wegen Statusbyte vor Namen
.su_n0:   
          tst.b     (a0)+
          bne       .su_n0           ;suche Namensende
;A0: erstes nicht zu lîschendes Byte
;A1: erstes zu lîschendes Byte
;merke Differenz A0-A1 und A0 selbst
          move.l    a0,d2            ;Zeiger in NamenRAM >= D2 korrigieren
          move.l    a0,d1
          sub.l     a1,d1            ;merke LÑnge des gelîschten
.mo_lp:   
          move.b    (a0)+,(a1)+
          cmpa.l    ptr_b_nram,a0
          bcs       .mo_lp
          move.l    a1,ptr2fnram     ;neuer freier Platz
;korrigiere die Zeiger in den GerÑteeintrÑgen
          movea.l   ptr2dev0,a0
.ko_lp:   
          cmp.l     4(a0),d2
          bcc.s     .noko            ;keine Korrektur
          sub.l     d1,4(a0)         ;Korrektur
.noko:    
          addq.l    #8,a0
          cmpa.l    ptrbldev,a0
          bcs       .ko_lp
.ende:    
          movem.l   (sp)+,d1-d3/a1-a3             ;zurÅckholen
          rte       


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
          bcs.s     .nl1
          cmpi.b    #'z',d1
          bhi.s     .nl1
          subi.b    #$20,d1
.nl1:     
          move.b    0(a0,d0.l),d2
          cmpi.b    #'a',d2
          bcs.s     .nl0
          cmpi.b    #'z',d2
          bhi.s     .nl0
          subi.b    #$20,d2
.nl0:     
          sub.b     d2,d1
          bne.s     .ende            ;sind ungleich
          tst.b     d2               ;gleich, D2 $00 heiût beide $00
          beq.s     .null
          add.b     d2,d1            ;D1 wieder herstellen
          bne       .next            ;D1 noch nicht $00 terminiert
          bra.s     .ende
.null:    
          moveq.l   #-1,d0
.ende:    
          rts       


evexop:   DC.w 0   ;<>0 fÅr immer exlusives Fopen

in_max_dev          = 16             ;soviel GEMDOS-GerÑte maximal

ptr2dev0: DC.l devdrv_field         ;Zeiger auf ersten Treibereintrag
ptrbldev: DC.l devdrv_endf          ;Zeiger hinter letzten Treiberplatz
max_dev:  DC.w in_max_dev

ptr2fnram:          DC.l namen_ram  ;Zeiger auf freien Platz im Namen-RAM
ptr_b_nram:         DC.l namen_e_ram             ;Zeiger hinter Ende

;kînnte spÑter extra angelegt werden und "genullt" werden #####
devdrv_field:       
          REPT in_max_dev*2         ;Platz fÅr je 2 Zeiger (LONG)
          DC.l 0
          ENDR 
devdrv_endf:        
namen_ram:          
          REPT in_max_dev*16        ;Platz durchschnittlich 15 Byte je Name
          DC.b 0   ;plus 1 Byte davor als Statusinfo
          ENDR 
namen_e_ram:                         ;Marke hinterm namen_ram

          ENDC    ;!MAMA

;Adr. des ersten nichtresidenten Byte, fÅr zus. Speichervergabe
first_unresi:       DC.l prg_ende   ;Anfangswert


;----------------------------------------------------------

          DC.l 0
prg_ende:           ;muû hinter dem letzten Residenten


;Supervisorteil fÅr Init.

suwinit:  
;OS-Version und CPU ermitteln
          move.l    #'MagX',-(sp)    ;Mag!X/MagiC ?
          bsr       cookie_find      ;extra weil echte Version woanders steht
          addq.l    #4,sp
          tst.l     d0
          beq       .no_ma
          movea.l   d0,a0
          tst.l     4(a0)            ;test Zeiger auf die Datenstruktur
          beq       .no_ma           ;Cookie mit Nullzeiger ist Unsinn
;Die Datenstruktur, auf die der Cookie zeigt, zeigt erst nach Start
;des AES auf die AESVARS (vorher ist dieser ptr=0). Im /AUTO/-Ordner zeigt
;aber os_magic im OS-Header bereits auf die AESVARS.
          movea.l   _sysbase,a0
          movea.l   20(a0),a0        ;A0: AESVARS
          cmpi.l    #$87654321,(a0)
          bne       .no_ma           ;Fehler
          cmpi.l    #'MAGX',12(a0)
          bne       .no_ma
          move.w    48(a0),d0        ;MagiC-Versionsnummer
          ori.l     #$ffff0000,d0    ;Highword =$ffff fÅr Mag!X
          move.l    d0,mytosver
          bra       .cpu_t
.no_ma:   
          movea.l   _sysbase,a0
          moveq.l   #0,d0            ;Highword =0 fÅr TOS
          move.w    2(a0),d0
          move.l    d0,mytosver      ;TOS-Versionsnr. kopieren
.cpu_t:   
          tst.w     _longframe
          bne       .lang            ;8 Byte Stackframe, steht schon drin
;Annahme: CPUs mit kurzem Stackframe haben nie Probleme mit modifizierendem
;Code ohne Cacheflushes
          moveq.l   #6,d0            ;6 byte (nur 68000)
          move.w    d0,2+t1_gP       ;Offsets in lea-Befehlen anpassen
          move.w    d0,2+t13_bP
          move.w    d0,2+t14_xP
.lang:    

          IFNE 0=MAMA

;modifizierten 200Hz-TimerC-Interrupt & etv_timer einhÑngen
          tst.w     yes_fastint
          beq       .no_ti           ;keine mod. Timerinterrupts
          move.l    #'MagX',-(sp)
          bsr       cookie_find      ;Mag!X installiert?
          addq.l    #4,sp
          tst.l     d0
          bne       .no_ti           ; bei Mag!X keine Modifikation
;Gemdos-uhr mit IPL5
          DC.w $a000                ;LineA-Init, Adr in A0 holen
          lea       etv_timer,a1
          movea.l   (a1),a2
          cmpi.l    #$3f2f0004,(a2)  ;"move.w 4(a7),-(a7)" typischer Anfang
          beq       .aus_auto        ;der GEMDOS-Uhr, Start aus \AUTO\
;gestartet vom Desktop, da Uhr nicht mehr in etv_timer
;also in USER_TIM davorhÑngen, richtet jedenfalls keinen Schaden an.
          lea       next_tim(a0),a1
.aus_auto:          
          move.l    (a1),old_gd_clock
          move.l    #my_gd_clock,(a1)
.no_ti:   

          ENDC    ;!MAMA

          rts       


starti:   
;Installation
          bsr       prints
          DC.b $1b,'p',' DEVICE DRIVER SUPPORT 1996-12-24 ',$1b,'q',cr,lf
          IFNE EXTRASICHER
          DC.b ' extra save D1/D2/A1/A2 in BIOS-trap',cr,lf
          ENDC 
          DC.b '(C) Harun Scheutzow.',cr,lf,0
          EVEN 

;Environment freigeben und umlegen auf eigenen Namen
          lea       (start-$100)+$2c,a0
          move.l    (a0),-(sp)       ;adr. Env-Strings
          move.l    #my_env,(a0)     ;neues Env nur mit _PNAM
          move.w    #$49,-(sp)
          trap      #1               ;GEMDOS Mfree
          addq.l    #6,sp

          IFNE 0=MAMA
          move.w    c_evexop,evexop  ;Exclusiv-Flag kopieren
          ENDC    ;!MAMA

          pea       suwinit          ;TOS und CPU ermitteln
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp


          move.l    mytosver,d7      ;bleibt hier drin fÅr Vergleiche
          IFNE 0=MAMA
          cmpi.l    #$00000100,d7    ;TOS1.00?
          bne       .no100
;Da TOS1.00 nie auf CPU >68000 lÑuft, ist modifizierender Code ok.
          lea       t14_b_s0,a0
          lea       t14_b_e0,a1
.o100nop: 
          move.w    #$4e71,(a0)+     ;Zugriffe auf xco* mit NOP Åberschreiben
          cmpa.l    a1,a0
          bcs       .o100nop
;TOS1.00, die Leute MöSSEN den MODEM1-Treiber nachladen, sonst VIEL érger
          move.l    #$000e0000,-(sp) ;AUX
          trap      #14              ;XBIOS Iorec
          addq.l    #4,sp
          move.l    d0,20+maptabs    ;kopiere wenigstens IOREC-Zeiger
;aber mehr lÑût sich kaum machen
          bra       .done

.no100:   
          tst.l     d7
          bpl       .nomag           ;muû TOS sein
;also Mag!X/MagiC liegt vor, nur noch WORD-Test
          cmpi.w    #$0200,d7
          bcs       .nog200          ;Mag!X vor 2.00 wie TOS<2.00
;Mag!X >2.00 waren nur Betas, nie im Verkauf, hatten zwar Dcntl, aber
;mit anderem Aufbau als >=3.00, also doch mein Gemdos
          cmpi.w    #$0300,d7
          bcs       .v200            ;alle 2.xx gleich behandeln
;MagiC 3.00 ist Dcntl und richtiges U:\DEV\ vorhanden
          st        no_gemdos        ;GEMDOS aus (nie an)
          bsr       prints
          DC.b 'No extra Gemdos. ',0
          EVEN 
          move.l    #gemdospart,first_unresi      ;ERSTER first_unresi Zugriff


.v200:              ;Mag!X >= 2.00, mÅûte Bconmap haben, aber nochmal testen
          move.l    #$002c0000,-(sp) ;0, teste ob Bconmap da
          trap      #14              ;XBIOS Bconmap
          addq.l    #4,sp
          tst.l     d0
          bne       .nog200          ;kein Bconmap(!!), also wie olles TOS

          ENDC    ;!MAMA

          move.l    #$002cfffe,-(sp) ;-2, Zeiger auf Struktur holen
          trap      #14              ;XBIOS Bconmap
          addq.l    #4,sp
          movea.l   d0,a0
          movea.l   (a0),a1          ;A1: alte MAPTAB(s)
          move.w    4(a0),d0         ;D0.w: Anzahl GerÑte

          cmpi.w    #5,d0
          bcs       .maggn
          moveq.l   #4,d0            ;aber max. 4 GerÑte Åbernehmen
.maggn:   
          move.w    d0,4+str_bconmap ;G-Anzahl bei mir eintragen
          subq.w    #1,d0            ;fÅr dbra
          movea.l   str_bconmap,a2   ;meine MAPTABs (post-inc)
          movea.l   a2,a3            ;meine VAPTABs (pre-dec)
.magmov:  
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          move.l    (a1),(a2)+
          move.l    (a1)+,-(a3)
          dbra      d0,.magmov

          IFNE 0=MAMA

          bra       .done

.nomag:   
          cmpi.w    #$0200,d7
          bcs       .nog200          ;hops bei TOS<2.00
;TOS >= 2.00
          move.l    #$002c0000,-(sp) ;0, teste ob Bconmap da
          trap      #14              ;XBIOS Bconmap
          addq.l    #4,sp
          tst.l     d0
          bne       .nog200          ;kein Bconmap(!!), also wie olles TOS

          move.l    #$002cfffe,-(sp) ;-2, Zeiger auf Struktur holen
          trap      #14              ;XBIOS Bconmap
          addq.l    #4,sp
          movea.l   d0,a0
          movea.l   (a0),a1          ;A1: alte MAPTAB(s)
          move.w    4(a0),d0         ;D0.w: Anzahl GerÑte
          cmpi.w    #4,d0            ;begrenze auf 4
          bls       .n200ds
          moveq.l   #4,d0
.n200ds:  
          move.w    d0,d1            ;(alles multitask-sicher!)

          movea.l   str_bconmap,a2   ;auf erste neue MAPTAB
;aber kein Eintrag in VAPTABs
.n200lp:  
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+
          move.l    (a1)+,(a2)+      ;IOREC
          subq.w    #1,d1
          bge       .n200lp

          move.w    d0,4+str_bconmap ;Anzahl fÅr eigenes Bconmap
          bra       .done


.suwini2: 
;im Super, fÅr 1.00 < TOS-V < 2.00
          movea.l   str_bconmap,a0   ;kopiere Bco*-Vektoren aus xco*-
          move.l    $51e+4,(a0)+
          move.l    $53e+4,(a0)+
          move.l    $55e+4,(a0)+
          move.l    $57e+4,(a0)+
;### fehlt Rsconf zur Vollkommenheit, Åber XBRA den XBIOS-Tabanfang suchen ???
          rts       


.nog200:  
;1.00 < TOS-Version < 2.00
;Die Leute MöSSEN eben den MODEM1-Treiber nachladen, sonst érger (kein Rsconf)
          move.l    #$000e0000,-(sp) ;AUX
          trap      #14              ;XBIOS Iorec
          addq.l    #4,sp
          move.l    d0,20+maptabs    ;kopiere IOREC-Zeiger
          pea       .suwini2         ;hole xco*-
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp

          ENDC    ;!MAMA

.done:    
          movea.l   str_bconmap,a0   ;MAPTAB-Eintrag von G#6
          move.l    16(a0),8+str_bconmap          ;akt. Rsconf
          move.l    20(a0),12+str_bconmap         ;akt. IOREC
;Kopieren der Routinen in ordentlich-sinnloser Weise nach xco*
;erfolgt (da Super nîtig) erst genau vor dem EinhÑngen in XBIOS

platz_end:                           ;bis hierher darf suwinit1 Cookies anlegen

          pea       suwinit1         ;in BIOS, XBIOS, GEMDOS hÑngen
          move.w    #38,-(sp)
          trap      #14              ;XBIOS Supexec
          addq.l    #6,sp



          bsr       prints
          DC.b 'Installed',cr,lf,cr,lf,0
          EVEN 

          clr.w     -(sp)
          move.l    first_unresi,d0
          subi.l    #(start-$100),d0
          move.l    d0,-(sp)         ;residente LÑnge
          move.w    #$31,-(sp)
          trap      #1               ;GEMDOS Ptermres


;Supervisorteil
suwinit1: 
;XBIOS-Modifikation einhÑngen
;(erst noch Vektoren nach xco*)
          movea.l   str_bconmap,a0   ;Maptab-Eintrag von G#6
          cmpi.l    #$00000100,mytosver
          beq       .noxco           ;nicht bei TOS1.00
          move.l    (a0)+,$51e+4
          move.l    (a0)+,$53e+4
          move.l    (a0)+,$55e+4
          move.l    (a0)+,$57e+4
.noxco:   
          move.l    va_xbios,oldxbiosv
          move.l    #t14_xbios,va_xbios
;leeren RSVF-Cookie anlegen, falls RSVF noch nicht existiert
          move.l    #'RSVF',-(sp)
          bsr       cookie_find
          addq.l    #4,sp
          tst.l     d0
          bne       .rsvf_da
          move.l    #platz_end,d0
          sub.l     first_unresi,d0
          move.l    d0,-(sp)
          move.l    first_unresi,-(sp)
          pea       rsvf_list
          move.l    #'RSVF',-(sp)
          bsr       cookie_insert
          lea       16(sp),sp
          tst.l     d0
          bmi       .coo_err
          add.l     d0,first_unresi  ;(schadet bei D0 =0 auch nicht)
.coo_err:           ;keine Reaktion auf Anlegefehler
.rsvf_da: 

;BIOS-Hack einhÑngen
          move.l    va_bios,oldbiosv
          move.l    #t13_bios,va_bios

          IFNE 0=MAMA

;GEMDOS-Zusatz einhÑngen
          tst.b     no_gemdos
          bne       .no_g
          move.l    va_gemdos,oldgemdosv
          move.l    #t1_gemdos,va_gemdos
.no_g:    

          ENDC    ;!MAMA

          rts       


;------------------------------------------


          INCLUDE "PRINTS.S"       ;nette Druckroutine

          INCLUDE "COOKIE.S"       ;Cookie-Jar Routinen


;------------------------------------------

          DATA 

          IFNE 0=MAMA

;Konfigurationszeug
          EVEN     ;wichtig!!!
magisch:  DC.b "hAruNs cONfigER",0  ;Magischer String
          DC.l magisch              ;Sicherheitszeiger
          DC.b "FASTINT: Soll die Timerinterruptmodifikation fÅr 57600Bd auf",cr,lf
          DC.b "8MHz-STs installiert werden?",cr,lf
          DC.b "(Bei TT/Falcon kann es auch helfen.)",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
yes_fastint:        DC.w -1         ;-1 fÅr "schnelle" Interrupts installieren
          DC.b "EXOPEN: Sollen sich GerÑte nur einmal îffnen lassen?",cr,lf,0
          EVEN 
          DC.w 0   ;Cmd Entscheidung
c_evexop: DC.w 0   ;nicht exclusiv
          DC.b 0   ;Nullstring als Ende
          EVEN 


no_gemdos:          DC.b 0          ;<>0 dann kein GEMDOS

          ENDC    ;!MAMA

          BSS 
          EVEN 
mytosver: DS.l 1   ;aufbereitete TOS/MagiC Versionsnummer

          DS.l $400                 ;Stack-Platz nur fÅr Initialisierung

