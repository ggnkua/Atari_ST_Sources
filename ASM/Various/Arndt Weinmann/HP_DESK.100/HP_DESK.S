; HP-Deskjet+ Treiber fr den ATARI ST
; geschrieben von Arndt Weinmann
;                 Obere Schillerstraže 39
;                 D-7400 Tbingen
; Version 1.00 vom 30.04.1990
;
; Hinweis zur Anpassung an andere Assembler als den GFA-Assembler
; die Labels, die mit einem Punkt beginnen, stellen lokale Label 
; dar, die nur zwischen zwei globalen, d.h. Labeln ohne Punkt am
; Anfang, gltig sind. Zum einen muž dann der Punkt entfernt werden,
; und die Labelnamen mssen wahrscheinlich variiert werden, da
; ich wahrscheinlich oftmals die gleichen Namen benutzt habe.
;
;OFFSETS

_basepage      equ 4
_text          equ 12
_data          equ 20
_bss           equ 28
_xb_magic      equ -12
_xb_id         equ -8
_xb_oldvec     equ -4

;GEMDOS

_term          equ 0
_cnecin        equ 8
_conws         equ 9
_dgetdrv       equ 25
_super         equ 32
_ptermres      equ 49
_fcreate       equ 60
_fclose        equ 62
_fwrite        equ 64
_mfree         equ 73

;BIOS

PRT            equ 0
CON            equ 2

bconstat       equ 1
bconin         equ 2
bcostat        equ 8
bconout        equ 3

;XBIOS

physbase       equ 2
getrez         equ 4

;SYSTEMVARIABLEN

critic         equ $404
conterm        equ $484
savptr         equ $4a2
dumpflg        equ $4ee
prtabt         equ $4f0
scr_dump       equ $502

;TASTEN (Scancodes)

ESC            equ 1
RETURN         equ 28
S              equ 31
H              equ 35
L              equ 38
F1             equ 59
F2             equ 60
F3             equ 61
F4             equ 62
F9             equ 67
F10            equ 68
UNDO           equ 97

;XBRA-Header

driver_start:  

xb_magic:      bra        installation_begin
xb_id:         .DC.b 'AlHP'
xb_oldvec:     .DS.l 1

driver_begin:  
               movem.l    d0-d7/a0-a6,-(sp)       ;Register retten
               move.l     sp,stack_save           ;Stack sichern
               move.w     conterm,conterm_save    ;conterm sichern
               bset       #3,conterm              ;kbshift zurckliefern
               subi.l     #$2e,savptr             ;neue Register-save-area
               move.w     #physbase,-(sp)         ;physbase erfragen
               trap       #14
               addq.l     #2,sp
               move.l     d0,physbase_save        ;und speichern

main_loop:     
               move.w     #CON,-(sp)              ;Tastatur
               move.w     #bconin,-(sp)           ;auf Tastendruck warten
               trap       #13
               addq.l     #4,sp
               swap.w     d0                      ;Scancode !

               cmpi.b     #ESC,d0
               beq        exit                    ;Abbruch
               cmpi.b     #S,d0
               beq        save                    ;abspeichern
               cmpi.b     #H,d0
               bne        .next_1
               move.w     #0,quality              ;hohe Qualit„t (Default)
.next_1:       
               cmpi.b     #L,d0
               bne        .next_2
               move.w     #-1,quality             ;niedrige Qualit„t
.next_2:       
               cmpi.b     #F1,d0
               beq        dpi_300                 ;300 dpi Hardcopy
               cmpi.b     #F2,d0
               beq        dpi_150                 ;150 dpi Hardcopy
               cmpi.b     #F3,d0
               beq        dpi_100                 ;100 dpi Hardcopy
               cmpi.b     #F4,d0
               beq        rdpi_75                 ;gedrehte Hardcopy
               cmpi.b     #F10,d0
               bne        .next_3
               move.w     #12,d6                  ;Seitenvorschub
               bsr        print_char
.next_3:       
               cmpi.b     #UNDO,d0
               beq        exit                    ;Abbruch
               bra        main_loop               ;und von neuem

save:          
               move.l     critic,critic_save      ;Critical Error Handler
               move.l     error,critic            ;auf interne Routine
               move.w     #_dgetdrv,-(sp)         ;aktuelles Laufwerk
               trap       #1
               addq.l     #2,sp
               addi.w     #'A',d0                 ;in ASCII konvertieren
               move.b     d0,dateiname            ;in den Dateinamen
               addq.b     #1,counter              ;n„chster Dateiname
               cmpi.b     #'9',counter            ;schon bei '9'?
               ble.s      .goon                   ;nein -> dann weiter
               move.b     #'0',counter            ;Zeichen vor der '0'
.goon:         
               clr.w      -(sp)                   ;keine Attribute
               pea        dateiname
               move.w     #_fcreate,-(sp)         ;Datei ”ffnen
               trap       #1
               addq.l     #8,sp
               tst.w      d0                      ;Fehler
               bmi.s      error
               move.w     d0,-(sp)                ;Handle fr _fclose
               move.l     physbase_save(pc),-(sp) ;physbase holen
               move.l     #32000,-(sp)            ;32000 Bytes speichern
               move.w     d0,-(sp)                ;Handle
               move.w     #_fwrite,-(sp)          ;schreiben
               trap       #1
               lea.l      12(sp),sp               ;schneller als adda.l ...
               tst.l      d0                      ;Fehler
               bmi.s      error                   ;-> das war wohl nichts
               move.w     #_fclose,-(sp)
               trap       #1
               addq.l     #4,sp
error:         
               move.l     critic_save(pc),critic  ;Handler zurckschreiben
               bra        exit

critic_save:   .DC.l 0
dateiname:     .DC.b 'A:\SCREEN_'
counter:       .DC.b '/.PIC',0

rdpi_75:       
               bsr        init                    ;end_raster_graphics + quality
               lea.l      y_offset(pc),a6
               bsr        print_string
               lea.l      x_offset(pc),a6
               bsr        print_string
               lea.l      d75(pc),a6
               bsr        print_string
               lea.l      set_rw_400(pc),a6
               bsr        print_string
               lea.l      start_raster_graphics(pc),a6
               bsr        print_string
               movea.l    physbase_save(pc),a5    ;physbase holen
               lea.l      399*80(a5),a5           ;in der linken unteren Ecke beginnen
print_portrait:           
               moveq.l    #79,d5                  ;Spalten
next_row:      
               moveq.l    #7,d4                   ;Bitspalten
next_bit_row:  
               lea.l      transfer_rg_50(pc),a6
               bsr        print_string
               moveq.l    #49,d3                  ;Anzahl Zeilen
next_line:     
               moveq.l    #7,d0                   ;Bits
               moveq.l    #0,d6                   ;das wird ausgegeben
next_bit:      
               btst.b     d4,(a5)                 ;Bit im Speicher gesetzt?
               beq        .weiter                 ;nein -> dann n„chstes Bit
               bset       d0,d6                   ;sonst Bit setzen
.weiter:       
               lea.l      -80(a5),a5
               dbra       d0,next_bit             ;n„chstes Bit
               bsr        print_char              ;und ausgeben
               dbra       d3,next_line            ;n„chste Zeile

               move.w     #CON,-(sp)              ;Taste gedrckt?
               move.w     #bconstat,-(sp)
               trap       #13
               addq.l     #4,sp
               cmpi.w     #-1,d0
               bne        .test
               move.w     #CON,-(sp)              ;Taste einlesen
               move.w     #bconin,-(sp)
               trap       #13
               addq.l     #4,sp
               swap.w     d0
               cmpi.b     #UNDO,d0
               bne        .test
               lea.l      end_raster_graphics(pc),a6
               bsr        print_string
               bra        exit
.test:         
               lea.l      32000(a5),a5
               dbra       d4,next_bit_row         ;n„chste Pixelspalte
               lea.l      1(a5),a5
               dbra       d5,next_row             ;n„chste Spalte
               lea.l      d300(pc),a6             ;Aufl”sung zurcksetzen
               bsr        print_string
               bra        exit                    ;ende von rdpi_74
dpi_300:       
               bsr        init
               lea.l      d300(pc),a6
               bsr        print_string
               lea.l      set_rw_640(pc),a6
               bsr        print_string
               bra        print_landscape
dpi_150:       
               bsr        init
               lea.l      d150(pc),a6
               bsr        print_string
               lea.l      set_rw_640(pc),a6
               bsr        print_string
               bra        print_landscape
dpi_100:       
               bsr        init
               lea.l      d100(pc),a6
               bsr        print_string
               lea.l      set_rw_640(pc),a6
               bsr        print_string
print_landscape:          
               lea.l      start_raster_graphics(pc),a6
               bsr        print_string
               movea.l    physbase_save(pc),a5
               move.w     #399,d5
.line:         
               lea.l      transfer_rg_80(pc),a6
               bsr        print_string
               moveq.l    #79,d4
.bytes:        
               moveq.l    #0,d6
               move.b     (a5)+,d6
               bsr        print_char
               dbra       d4,.bytes

               move.w     #CON,-(sp)              ;Taste gedrckt?
               move.w     #bconstat,-(sp)
               trap       #13
               addq.l     #4,sp
               cmpi.w     #-1,d0
               bne        .test
               move.w     #CON,-(sp)              ;Taste einlesen
               move.w     #bconin,-(sp)
               trap       #13
               addq.l     #4,sp
               swap.w     d0
               cmpi.b     #UNDO,d0
               bne        .test
               lea.l      end_raster_graphics(pc),a6
               bsr        print_string
               bra        exit
.test:         
               dbra       d5,.line
.dpi_300_ende: 
               lea.l      end_raster_graphics(pc),a6
               bsr        print_string
               lea.l      d300(pc),a6
               bsr        print_string
               moveq.l    #13,d6
               bsr        print_char
               moveq.l    #10,d6
               bsr        print_char
               bra        exit                    ;ende von dpi_300

init:          
               lea.l      end_raster_graphics(pc),a6
               bsr        print_string
               tst.w      quality
               beq        .high
               lea.l      draft_quality(pc),a6
               bsr        print_string
               bra        .goon
.high:         
               lea.l      letter_quality(pc),a6
               bsr        print_string
.goon:         
               rts        
print_string:  
               moveq.l    #0,d6
               move.b     (a6)+,d6
               bsr        print_char
               tst.b      (a6)
               bne        print_string
.end_print_string:        
               rts        
print_char:    

               move.w     #30000,d7               ;30000 mal probieren
.ready:        
               move.w     #PRT,-(sp)              ;Drucker bereit?
               move.w     #bcostat,-(sp)
               trap       #13
               addq.l     #4,sp
               cmpi.w     #-1,d0                  ;kann ausgegeben werden?
               beq        .printchar              ;ja -> ausgeben
               dbra       d7,.ready               ;nein -> nochmal versuchen
               bra        exit                    ;das wars wohl nicht
               rts        
.printchar:    
               move.w     d6,-(sp)
               move.w     #PRT,-(sp)
               move.w     #bconout,-(sp)          ;ausgeben
               trap       #13
               addq.l     #6,sp
               rts                                ;Ende von print_char
exit:          
               move.w     conterm_save(pc),conterm          ;conterm restaurieren
               addi.l     #$2e,savptr             ;alte Register-save-area
               move.w     #-1,dumpflg             ;Hardcopy fertig
               movea.l    stack_save(pc),sp       ;Stack zurck
               movem.l    (sp)+,d0-d7/a0-a6       ;Register zurcksetzen
               rts        

start_raster_graphics:    
               .DC.b 27,'*r1A',0
end_raster_graphics:      
               .DC.b 27,'*rB',0
draft_quality: .DC.b 27,'*r1Q',0
letter_quality:           
               .DC.b 27,'*r2Q',0
d300:          .DC.b 27,'*t300R',0
d150:          .DC.b 27,'*t150R',0
d100:          .DC.b 27,'*t100R',0
d75:           .DC.b 27,'*t75R',0
set_rw_640:    
               .DC.b 27,'*r640S',0
set_rw_400:    
               .DC.b 27,'*r400S',0
transfer_rg_80:           
               .DC.b 27,'*b80W',0
transfer_rg_50:           
               .DC.b 27,'*b50W',0
y_offset:      
               .DC.b 27,'*p+259Y',0
x_offset:      
               .DC.b 27,'*p408X',0

               .EVEN 
quality:       .DC.w 0
stack_save:    .DC.l 0
physbase_save: .DC.l 0
conterm_save:  .DC.l 0
driver_end:    

installation_begin:       
               move.w     #getrez,-(sp)           ;getrez
               trap       #14
               addq.l     #2,sp
               cmpi.w     #2,d0                   ;Highres?
               beq        .goon                   ;ja -> weitermachen
               pea        high_res_only(pc)       ;falsche Aufl”sung -> Meldung
               move.w     #_conws,-(sp)
               trap       #1
               addq.l     #6,sp
               bra        quit
.goon:         
               move.l     #0,-(sp)                ;im Supervisormodus
               move.w     #_super,-(sp)
               trap       #1
               addq.l     #6,sp
               move.l     d0,user_stack
evaluate_xbra: 
               movea.l    scr_dump,a0             ;Hardcopy-Adresse
               movea.l    #scr_dump,a1
.loop:         
               cmpi.l     #'XBRA',_xb_magic(a0)   ;XBRA-Kette?
               bne        install_routine
               cmpi.l     #'AlHP',_xb_id(a0)      ;Alman HP-Deskjet-Treiber?
               beq        already_installed
               movea.l    _xb_oldvec(a0),a0       ;neuen Pointer
               movea.l    a0,a1                   ;alten Pointer merken
               bra        .loop
install_routine:          
               pea        treiber_txt(pc)         ;Meldung ausgeben
               move.w     #_conws,-(sp)
               trap       #1
               addq.l     #6,sp

               pea        installed(pc)
               move.w     #_conws,-(sp)
               trap       #1
               addq.l     #6,sp

               lea.l      driver_begin(pc),a0
               move.l     #'XBRA',_xb_magic(a0)   ;selbstmodifizierend !
               move.l     scr_dump,_xb_oldvec(a0) ;Vektor sichern

               move.l     #driver_begin,scr_dump

               move.l     #user_stack,-(sp)       ;wieder in den Usermodus
               move.w     #_super,-(sp)
               trap       #1

               move.w     #0,-(sp)                ;Programm resident
               move.l     #driver_end-driver_start+256,-(sp)
               move.w     #_ptermres,-(sp)
               trap       #1

already_installed:        

               cmpi.l     #'XBRA',_xb_magic(a1)   ;von XBRA-Struktur ?
               bne        .first
               move.l     _xb_oldvec(a0),_xb_oldvec(a1)
               bra        .free_memory
.first:        
               move.l     _xb_oldvec(a0),(a1)     ;Ausgangspointer !
.free_memory:  
               move.l     #driver_start-256,-(sp) ;Speicher freigeben
               move.w     #_mfree,-(sp)
               trap       #1
               addq.l     #6,sp

               pea        treiber_txt(pc)         ;Meldung
               move.w     #_conws,-(sp)
               trap       #1
               addq.l     #6,sp

               pea        not_install(pc)
               move.w     #_conws,-(sp)
               trap       #1
               addq.l     #6,sp

installation_exit:        

               move.l     #user_stack,-(sp)       ;wieder in den Usermodus
               move.w     #_super,-(sp)
               trap       #1

quit:          
               move.w     #_cnecin,-(sp)          ;auf Tastendruck warten
               trap       #1
               addq.l     #2,sp

               move.w     #_term,-(sp)            ;Programm verlassen
               trap       #1

installation_end:         

               .DATA 

treiber_txt:   .DC.b 13,10,27,'p  Alman HP-Deskjet+ Driver, Version 1.0  ',27,'q',13,10
               .DC.b 27,'p PD #001, written 1990 by Arndt Weinmann ',27,'q',13,10,0
installed:     .DC.b 27,'p >>>>>>>>>>>>> installed <<<<<<<<<<<<<<< ',27,'q',13,10,0
not_install:   .DC.b 27,'p >>>>>>>>>>> not installed <<<<<<<<<<<<< ',27,'q',13,10,0
high_res_only: .DC.b 27,'p       Alman HP-Deskjet+ Driver          ',27,'q',13,10
               .DC.b 27,'p         works in HIGHRES only           ',27,'q',13,10,0

               .BSS 
user_stack:    .DS.l 1

               .END 

