;known issues:
;-f030: in ST compatible highrez mode (aka an RGB adapter connected with a SM124 or a mono adapter) $fffffa01 isn't hinting to the mono monitor correctly
;-ultradev: a -prg less than 60 bytes does not load (several exceptions or only an "le" line is shown)
;-ultradev: a 60 byte prg with only NOPs in it's TEXT section does laod, but only shows 1 nop @TEXT
udSymboltablelen        equ $1a
udSymboltable           equ $10
udMyBasePage			      equ $16
udBugaBooCmdListPos     equ $20

;UDCartridgeRamPos   equ $fa4038
;UDKeyStroke         equ $fa4054

ultradev       EQU 01                              ;0=disable ultraDev extension (shouldn't be needed since UD is auto-detected) ==> will write binary as "BUGABOOF.PRG"!
                  IFNE ultradev
                  include   "UDDefines.s"
                  ENDC

sprache        EQU 01                          ;0=Deutsch, 1=Englisch
version        EQU $01071400                      ;Die Versionsnummer (Macroversion >= $200000)
etv_exit       EQU $040C                          ;etv_exit()-Vektor
xbra_id        EQU 'BUG1'
symtab         EQU 0                              ;enable debugging aka don't install illgal/bus error handlers etc
;>               OPT X-,F-,O+,W+ ;opimizations, warnings

              MACRO CHECKEXTENSION_NOUD
              IFNE ultradev
                btst.b  #0,extension_flags(A4)
                beq.s   \1
              ENDC                
              ENDM
              MACRO CHECKEXTENSION_HASUD
              IFNE ultradev
                btst.b  #0,extension_flags(A4)
                bne.s   \1
              ENDC                
              ENDM

********************************************************************************
* TurboAss Bugaboo                                                             *
* von Markus Fritze                                                            *
********************************************************************************
               MACRO RSEVEN
               IFNE __RS&1 
               RS.B 1
               ENDC
               ENDM

               ;>PART 'Header'
               IFEQ ultradev
               OUTPUT 'BUGABOOF.PRG'                ;Falcon patched Bugaboo w/o any UD code/probing
               ELSE
               OUTPUT 'BUGABOFC.PRG'                ;Falcon patched Bugaboo with UD code/probing, runs in cart- and in hd-mode (only cart-mode will support the ud-specific commands like UDMIRROR, tho)
               ENDC
;>               IF ^^SYMTAB
;>               DEFAULT 1
;>               ELSE
;>               DEFAULT 2
;>               ENDC
               TEXT
anfang:         jsr     init_all
;>               DATA
               DC.L 0 ;>DC.L ^^RANDOM                      ;ohne Funktion
               DC.L 0 ;>DC.L ^^RANDOM                      ;ohne Funktion
               DC.L $110000                       ;Interne Versionsnummer der Debuggers
               DC.L 0 ;>DC.L ^^RANDOM
               ;>DXSET 31,0
               DC.B 'Shareware-Basisversion         '
               DC.B 'Markus Fritze, Birkhahnkamp 38 '
               DC.B '2000 Norderstedt 1             '
               EVEN
               ;>ENDPART
               ;>PART 'start'
                bra     start
               DC.B "Falcon030-3Hour-Adapting done by Chris of Aura and The Innovator of NEWline on 01.08.93"
               DC.B "at the 680XX Convention in Hamburg/Germany between 1:07am and 4:50am."
               DC.B "We included just a few Falcon-fixes to get BugaBoo workable on Falcon. Bye from The Independent.    "
               DC.B "Some improvements by chris of aura / 24.10.93!"
               DC.B "Recreated as sourcecode in 2020 by tIn"
               EVEN
start:          move.l  SP,old_usp(A4)            ;USP merken
                pea     @_trap3(A4)
                move.l  #$050023,-(SP)
                trap    #13                       ;Trap #3 setzen (Supervisor-Mode an)
                addq.l  #8,SP
                move.l  D0,old_trap3
                movea.l D0,A0                     ;Alten Trap #3-Vektor holen
                cmpi.l  #'TASS',-8(A0)            ;Start durch den Assembler?
                seq     D0                        ;dann D0=-1
                trap    #3                        ;Supervisormode an
                move.l  SP,old_stack(A4)          ;und den Stackpointer merken
                move.b  D0,ass_load(A4)           ;Flag für Laden durch den Assembler
                bne.s   start1                    ;dann automatisch resident werden

                st      le_allowed(A4)            ;LE ist erlaubt

                move.l  #$0A000100,D0             ;appl_init()
                jsr     aes
                move.l  #$13000100,D0             ;appl_exit()
                jsr     aes
                move.w  spaced2+32(A4),D2         ;AES-Versionsnummer merken
                sne     D2                        ;D2 = $FF, wenn die AES vorhanden ist

                move.b  do_resident(A4),D1        ;resident-Flag

                movea.l kbshift_adr(A4),A0
                moveq   #4,D0
                and.b   (A0),D0                   ;Control gedrückt?
                sne     D0                        ;D0=$FF, wenn gedrückt

                eor.b   D0,D1                     ;B = A xor B
                or.b    D2,D0                     ;A = A or C
                not.b   D0                        ;A = not A
                and.b   D2,D1                     ;B = B and C
                or.b    D1,D0                     ;A = not(A or C)or(C and (A xor B))
               IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                clr.l   D0                        ;don't allow bugaboo to start in resident mode 
.noUD:                
               ENDC
                move.b  D0,do_resident(A4)
                beq.s   start2                    ;nicht resident
                pea     resident_text(PC)
                move.w  #9,-(SP)
                trap    #1                        ;Message für Resident ausgeben
                addq.l  #6,SP
start1:         st      do_resident(A4)           ;automatisch resident werden
start2:         jsr     @init(A4)                 ;alles m”gliche initialisieren
                bra.s   start4

resident_text: DC.B 13,10,'Bugaboo V'
               DC.B (version>>24)&$0F+'0'
               DC.B '.'
               IF (version>>20)&$0F<>0
               DC.B (version>>20)&$0F+'0'
               ENDC
               DC.B (version>>16)&$0F+'0'
               DC.B '.'
               IF (version>>12)&$0F<>0
               DC.B (version>>12)&$0F+'0'
               ENDC
               DC.B (version>>8)&$0F+'0'
               IF version&$FF
               DC.B version&$FF
               ENDC
               DC.B ' resident',13,10,0
               EVEN

;allgemeiner Debuggereinsprung
newstart:       lea     varbase,A4

                move.l  A0,first_free(A4)         ;1.freie Adresse im RAM
                move.l  A1,quit_stk(A4)           ;Rücksprungadr
                move.l  A1,D0
                beq.s   newstart1                 ;keine Rücksprungadresse
                cmpi.l  #$DEADFACE,-(A1)          ;Magic?
                bne.s   newstart1                 ;Nein!
                move.l  -(A1),cmd_line_adr(A4)    ;Adresse der Commandline
                move.l  A1,ass_vector(A4)         ;Zeiger auf Sprungtabelle merken
newstart1:      st      le_allowed(A4)            ;LE ist erlaubt
                clr.b   help_allow(A4)
                move.l  A2,prg_base(A4)           ;Adr des akt.Prgs
                beq.s   newstart2                 ;auto-load => LE verboten
                sf      le_allowed(A4)            ;LE ist nicht erlaubt
                move.b  (A2),help_allow(A4)
newstart2:      clr.l   merk_svar(A4)
                tst.b   help_allow(A4)            ;CTRL-HELP erlaubt?
                bpl.s   newstart3                 ;Nein! =>
                move.l  A3,D0
                subq.l  #8,D0
                bmi.s   newstart3                 ;auch im RAM?
                move.l  A3,merk_svar(A4)
newstart3:      clr.l   end_of_mem(A4)
                trap    #3
                movea.l default_stk(A4),SP        ;ist ja bereits initialisiert
                moveq   #-1,D0
                move.l  D0,line_back(A4)
                jsr     @init(A4)

start4:         clr.l   etv_exit.w                ;etv_exit()-Vektor l”schen

                movea.l act_pd(A4),A0
                movea.l (A0),A0                   ;Zeiger auf die Basepage des akt.Prgs
                move.l  A0,merk_act_pd(A4)        ;aktuelles Programm merken
                lea     128(A0),A0
                move.b  (A0),D0                   ;existiert noch eine Commandline?
                beq.s   start5                    ;Nein =>
                clr.b   (A0)+                     ;Commandline verwerfen
                bsr     do_cmdline                ;Commandline in den Eingabe-Buffer
start5:
                sf      auto_sym(A4)              ;Symboltabelle durch den Assembler?
                st      autodo_flag(A4)           ;CTRL+M-Befehl ausführen

                lea     gemdos_break(A4),A0
                lea     end_of_breaks(A4),A1
start6:         tst.b   (A0)                      ;Abbruch beim Trap?
                sne     (A0)+                     ;dann Flag setzen
                cmpa.l  A1,A0
                blo.s   start6

                suba.l  A1,A1
                movea.l $2C.w,A0                  ;Linef-Vektor holen
                move.l  A0,D7
                btst    #0,D7                     ;Englisches Vobis-TOS (85)
                bne.s   start8                    ;=> raus
                lea     20(A0),A0
                cmpi.w  #$207C,(A0)+              ;MOVE.L #,A0 ?
                bne.s   start8
                movea.l (A0),A1                   ;Basisadr der Tabelle holen
                move.l  A1,linef_base(A4)
                subq.l  #4,A1
                moveq   #-4,D7
start7:         addq.l  #4,A1
                addq.w  #4,D7
                tst.b   (A1)
                beq.s   start7
                move.w  D7,max_linef(A4)          ;maximal erlaubter Line-F-Opcode
start8:

                movea.l #sekbuff,A0               ;internen SSP setzen
                adda.l  A4,A0
                movea.l A0,SP
                move.l  A0,default_stk(A4)        ;und merken

                bsr     initreg                   ;Register initialisieren
                jsr     set_reg                   ;Traceback-Buffer initialisieren
                tst.b   ass_load(A4)              ;Laden durch den Assembler?
                bne     cmd_resident2             ;automatisch resident
                jsr     @set_ins_flag(A4)         ;Insert/Overwrite anzeigen
                jsr     @redraw_all(A4)           ;Bildschirm neu aufbauen
f_direct:       move.l  first_free(A4),default_adr(A4) ;1.freie Adresse im RAM
                st      testwrd(A4)               ;Ausgabe nach A0 umlenken
                moveq   #'1',D0
                add.b   prozessor(A4),D0          ;Prozessor einsetzen
                move.b  D0,__star2
                sf      testwrd(A4)               ;Ausgabe wieder auf den Schirm
                jsr     @c_clrhome(A4)            ;Bildschirm l”schen
                pea     __star(PC)                ;Text der Startmeldung
                jsr     @print_line(A4)           ;ausgeben
                tst.b   install_load(A4)
                beq.s   initvi2
                pea     __star4(PC)
                jsr     @print_line(A4)           ;Installation wurde geladen
initvi2:        sf      install_load(A4)

;####################################                
                jsr     probe_extensions_print
;####################################                

                jsr     @c_eol(A4)                ;Zeile l”schen
                jsr     @crout(A4)                ;CR ausgeben
                jsr     @c_eol(A4)                ;Zeile l”schen
                move.l  trace_pos(A4),reg_pos(A4)
               IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                move.l  a6,-(a7)
                move.l  UDCartridgeRamPos,a6
                move.l  $4000+udBugaBooCmdListPos(a6),a6
                beq     .noCmdList
                move.l  a6,input_pnt(A4)     ;get 1st command from UD
.noCmdList:
                move.l  (a7)+,a6
.noUD:                
               ENDC
all_normal:
                lea     main_loop(PC),A0
                move.l  A0,jmpdispa(A4)           ;Sprungdispatcher auf Hauptschleife
                jmp     (A4)

               IFEQ sprache
__star:        DC.B " ä-Soft's Bugaboo V"
               DC.B (version>>24)&$0F+'0'
               DC.B '.'
               IF (version>>20)&$0F<>0
               DC.B (version>>20)&$0F+'0'
               ENDC
               DC.B (version>>16)&$0F+'0'
               DC.B '.'
               IF (version>>12)&$0F<>0
               DC.B (version>>12)&$0F+'0'
               ENDC

               DC.B (version>>8)&$0F+'0'
               IF version&$FF
               DC.B version&$FF
               ENDC
               DC.B ' von Markus Fritze und S”ren Hellwig'
              IFNE ultradev
               DC.B " (ultraDev support)"
              ENDC
               DC.B 13
               DC.B ">Falcon030-Improvements by Chris/AURA and The Innovator/NEWline<",13
               DC.B "  There are still some errors, please don't fuck us!",13
               DC.B "  Version F0.2d (01/04/94-21:21pm) [F030 refix test v0.012]",13
               DC.B ' Ein 680'
__star2:       DC.B '00 Prozessor ist aktiv.',13,0
__star4:       DC.B ' Parameter wurden geladen.',13,0
               ELSE
__star:        DC.B ' Bugaboo V'
               DC.B (version>>24)&$0F+'0'
               DC.B '.'
               IF (version>>20)&$0F<>0
               DC.B (version>>20)&$0F+'0'
               ENDC
               DC.B (version>>16)&$0F+'0'
               DC.B '.'
               IF (version>>12)&$0F<>0
               DC.B (version>>12)&$0F+'0'
               ENDC
               DC.B (version>>8)&$0F+'0'
               IF version&$FF
               DC.B version&$FF
               ENDC
               DC.B ' by ä-Soft'
              IFNE ultradev
               DC.B " (+ultraDev support)"
              ENDC
               DC.B 13
               DC.B ' The Bozos: Markus Fritze and S”ren Hellwig',13
               DC.B ">Falcon030-Improvements by Chris/AURA and The Innovator/NEWline<",13
               DC.B "  There are still some errors, please don't fuck us!",13
               DC.B "  Version F0.2d (01/04/94-21:21pm) [F030 refix test v0.012]",13
               DC.B ' 680'
__star2:       DC.B '00 Processor is active',13,0
__star4:       DC.B ' parameter-file loaded',13,0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* Sprungverteiler der Funktionen                                               *
********************************************************************************
               ;>PART 'inp_loop'
ret_jump:       lea     varbase,A4
                movea.l default_stk(A4),SP        ;Stackpointer zurückholen
                jsr     @my_driver(A4)            ;eigene Treiber rein (für CLR 8,4FF)
                jsr     set_reg
                moveq   #14,D0
                jsr     disable_irq               ;Ring-Indicator aus
                move.b  #'$',hexbase
                clr.l   trace_count(A4)           ;Tracecount l”schen
                moveq   #0,D0
                jsr     graf_mouse                ;Pfeil einschalten
                andi.b  #$10,kbshift(A4)
                clr.b   direct(A4)
                lea     screen+1920(A4),A0
                jsr     @get_line(A4)             ;letzte Zeile auswerten
                tst.b   D0                        ;steht was in der letzten Zeile?
                beq.s   ret_jump1                 ;Nein!=>
                tst.b   ignore_autocrlf(A4)       ;CR/LF unterdrücken?
                bne.s   ret_jump1                 ;Ja! =>
                jsr     @crout(A4)                ;CR/LF
                jsr     @c_eol(A4)
ret_jump1:      andi    #$FB00,SR                 ;IRQs freigeben
                move.l  jmpdispa(A4),-(SP)
                rts
               ;>ENDPART
********************************************************************************
* Die Hauptschleife                                                            *
********************************************************************************
               ;>PART 'main_loop'
main_loop:      jsr     @page1(A4)                ;Debuggerscreen an
                sf      untrace_flag(A4)          ;Kein Untrace mehr an
                clr.l   untrace_count(A4)         ;Untracecounter l”schen
                clr.b   device(A4)                ;Keine Druckerausgabe
                sf      testwrd(A4)               ;Ausgabe auf den Schirm (nicht nach A0)
                clr.l   breakpnt+12*16(A4)        ;Break#16 l”schen
                move.l  default_adr(A4),D1
                jsr     @anf_adr(A4)
                tst.b   assm_flag(A4)             ;Eingabe durch den Line-Assembler?
                beq.s   main_loop2                ;Nein!
                lea     _zeile2(A4),A0            ;UNDO-Buffer
                jsr     @get_line(A4)             ;Zeile auswerten
                cmp.b   #'|',D0
                beq.s   main_loop1                ;Do-Befehl?
                cmp.b   #'!',D0
                bne.s   main_loop2                ;Line-Assembler?
main_loop1:     jsr     @chrout(A4)               ;automatisch wieder ausgeben
                sf      assm_flag(A4)             ;Eingabe mit dem Line-Assembler beenden
main_loop2:     tst.b   illegal_flg(A4)           ;CTRL+Cursor left für Illegal
                beq.s   main_loop3
                sf      illegal_flg(A4)
                jsr     @cache_up(A4)             ;und einen Eintrag im Cache zurück
                jsr     @cursor_off(A4)           ;Cursor ja wieder ausschalten
main_loop3:     move.l  $04BA.w,D0
                move.l  hz200_time(A4),D1
                cmp.l   D1,D0
                bhs.s   main_loop4                ;Timer-Unterlauf verhindern (Harddisk!)
                move.l  D1,D0
                move.l  D0,$04BA.w
main_loop4:     move.l  D0,hz200_time(A4)
                bsr     rgout                     ;Register ausgeben
                jsr     @desel_menue(A4)           ;evtl. selektierten Menüeintrag deselektieren
                tst.l   prg_base(A4)              ;Prg automatisch laden
                bne     autoload
                tst.b   do_resident(A4)           ;'RESIDENT' automatisch ausführen?
                bne     cmd_resident2             ;=> AUTO-Ordner-Version
                clr.b   akt_maust(A4)
                clr.b   maus_merk(A4)             ;Maustasten sind nicht gedrückt!
                clr.b   maus_merk2(A4)
                move.w  #-1,maus_flag(A4)         ;Flag wieder zurücksetzen
                st      mausprell(A4)
                st      mausprell2(A4)
                clr.b   maustast(A4)
main_loop5:     st      first_call(A4)
                tst.b   autodo_flag(A4)
                bne     autodo                    ;CTRL+M-Befehl automatisch ausführen
                bclr    #0,help_allow(A4)         ;Bit 0: Direktstart
                beq.s   main_loop6                ;Nein =>
                jmp     cmd_go                    ;Direktstart =>
main_loop6:     tst.b   fast_exit(A4)
                beq.s   main_loop7                ;<>0 => sofort mit CTRL+HELP raus
                jmp     do_help

main_loop7:     move.l  input_pnt(A4),D0          ;BREAKPT-Directive?
                beq.s   call_scr_edit             ;Nein! => Screen-Editor
                movea.l D0,A0
                moveq   #':',D1                   ;der Zeilentrenner
main_loop71:    move.b  (A0)+,D0                  ;noch was im Buffer?
                beq.s   call_scr_edit             ;Nein! => Screen-Editor
                cmp.b   #' ',D0                   ;Führungsspaces ignorieren
                beq.s   main_loop71
                cmp.b   D1,D0                     ;Zeilentrenner am Anfang?
                beq.s   main_loop71               ;ja! => ignorieren
                lea     _zeile(A4),A1
                moveq   #0,D2                     ;Flag für Anführungszeichen
                bra.s   main_loop83
main_loop8:     move.b  (A0)+,D0
                beq.s   main_loop9                ;Stringende =>
main_loop83:    cmp.b   #'"',D0                   ;Anführungszeichen?
                bne.s   main_loop81               ;Nein! =>
                not.b   D2                        ;Flag dafür toggeln
main_loop81:    tst.b   D2                        ;innerhalb von Anführungszeichen?
                bne.s   main_loop82               ;Ja! => nicht auf ':' testen
                cmp.b   D1,D0                     ;Zeilentrenner?
                bne.s   main_loop82               ;Ja! =>
                cmp.b   (A0),D1                   ;noch einen Zeilentrenner?
                bne.s   main_loop10               ;Nein => Ende der Eingabe
                bra.s   main_loop8
main_loop82:    move.b  D0,(A1)+                  ;in den Eingabebuffer kopieren
                bra.s   main_loop8
main_loop9:     suba.l  A0,A0                     ;Flag dafür l”schen
main_loop10:    clr.b   (A1)                      ;Eingabebuffer abschliežen
                move.l  A0,input_pnt(A4)
                cmpi.b  #'-',(A0)                 ;folgt noch ein "-"?
                bne.s   main_loop11               ;Nee =>
                addq.l  #1,input_pnt(A4)
                bra.s   main_loop13               ;dann nix ausgeben!
main_loop11:    pea     _zeile(A4)
                jsr     @print_line(A4)
                jsr     @crout(A4)                ;Befehl ausgeben
                bra.s   main_loop13               ;und auswerten

call_scr_edit:  clr.l   input_pnt(A4)             ;Batch-Pointer zurücksetzen
                sf      batch_flag(A4)            ;Batch-Mode aus

                jsr     @scr_edit(A4)             ;Auf Eingabe warten

main_loop13:    lea     _zeile(A4),A0
inp_loop1:      bsr     get
                tst.b   D0
                beq     ret_jump                  ;Leereingabe
                cmp.b   #'0',D0
                blo.s   inp_loop2                 ;nix
                cmp.b   #'9',D0                   ;Zeichen eine Zahl?
                bls.s   inp_loop3                 ;ja
inp_loop2:      bsr     numbas                    ;Zahlenbasis auswerten
                bmi.s   inp_loop4                 ;nein, keine Zahl!
                bsr     get
inp_loop3:      bsr     get_zahl                  ;Zahl einlesen
                move.l  D1,default_adr(A4)        ;neue Defaultadresse
inp_loop4:      cmp.b   #'>',D0
                beq.s   inp_loop5
                cmp.b   #'¯',D0                   ;Prompt ignorieren!
                beq.s   inp_loop5
                cmp.b   #'',D0
                bne.s   inp_loop6
inp_loop5:      bsr     get                       ;PC-Markierung berlesen
inp_loop6:      tst.b   D0
                beq     ret_jump
                subq.l  #1,A0
                movea.l A0,A6
                movea.l A0,A5
                lea     cmdtab(PC),A1
                lea     cmdadr-2(PC),A2
inp_loop7:      addq.l  #2,A2
                movea.l A6,A0
inp_loop8:      move.b  (A0),D0
                cmp.b   #' ',D0                   ;Space
                beq.s   inp_loop11
                cmpa.l  A0,A5                     ;1.Zeichen?
                beq.s   inp_loop9                 ;Ja! =>
                cmp.b   #'A',D0                   ;Punkt erst ab der 2.Stelle testen
                blo.s   inp_loop11
                cmp.b   #'Z',D0
                bls.s   inp_loop9
                cmp.b   #'a',D0                   ;Sonderzeichen: z.B. M^A0
                blo.s   inp_loop11
                cmp.b   #'z',D0
                bhi.s   inp_loop11
inp_loop9:      tst.b   D0                        ;Zeilenende
                beq.s   inp_loop11
                tst.b   (A1)                      ;Befehlsende
                beq.s   inp_loop11
                bmi     no_bef
                bsr     get
                cmp.b   (A1)+,D0
                beq.s   inp_loop8
inp_loop10:     tst.b   (A1)+
                bne.s   inp_loop10
                bra.s   inp_loop7
inp_loop11:     moveq   #0,D1
                move.w  (A2),D1                   ;unsigned word
                adda.l  D1,A2                     ;Adresse der Routine ermitteln
               IFEQ symtab ;^^SYMTAB
                lea     intern_bus,A6
                move.l  A6,8.w                    ;Interne Busfehler abfangen
               ENDC
                clr.b   direct(A4)
                jmp     (A2)
               ;>ENDPART
               ;>PART 'cmdtab'
cmdtab:        DC.B ' ',0                         ;Dummy, wird berlesen
               DC.B '&',0
               DC.B '#',0
               DC.B '@',0
               DC.B '!',0
               DC.B '|',0
               DC.B '?',0
               DC.B '/',0
               DC.B ')',0
               DC.B ']',0
               DC.B '.',0
               DC.B ',',0
               DC.B $22,0
               DC.B 'PRN',0
               DC.B 'P',0
               DC.B 'BREAKPOINTS',0
               DC.B 'SAVE',0
               DC.B 'SYMBOLTABLE',0
               DC.B 'SYSINFO',0
               DC.B 'SYSTEM',0
               DC.B 'SET',0
               DC.B 'MEMORY',0
               DC.B 'LIST',0
               DC.B 'LL',0
               DC.B 'DISASSEMBLE',0
               DC.B 'DUMP',0
               DC.B 'LEXECUTE',0
               DC.B 'LOAD',0
               DC.B 'GO',0
               DC.B 'UNTRACE',0
               DC.B 'INFO',0
               DC.B 'TRACE',0
               DC.B 'CALL',0
               DC.B 'IF',0
               DC.B 'MOVE',0
               DC.B 'COMPARE',0
               DC.B 'COPY',0
               DC.B 'DIRECTORY',0
               DC.B 'HUNT',0
               DC.B 'FIND',0
               DC.B 'FILL',0
               DC.B 'CLS',0
               DC.B 'ASCII',0
               DC.B 'ASCFIND',0
               DC.B 'LET',0
               DC.B 'EXIT',0
               DC.B 'QUIT',0
               DC.B 'TYPE',0
               DC.B 'SHOWMEMORY',0
               DC.B 'MOUSEON',0
               DC.B 'MON',0
               DC.B 'SHOWMOUSE',0
               DC.B 'MOUSEOFF',0
               DC.B 'MOFF',0
               DC.B 'HIDEMOUSE',0
               DC.B 'READSEKTOR',0
               DC.B 'RSEKTOR',0
               DC.B 'WRITESEKTOR',0
               DC.B 'WSEKTOR',0
               DC.B 'READSECTOR',0
               DC.B 'RSECTOR',0
               DC.B 'WRITESECTOR',0
               DC.B 'WSECTOR',0
               DC.B 'READTRACK',0
               DC.B 'RTRACK',0
               DC.B 'ERASE',0
               DC.B 'KILL',0
               DC.B 'FREE',0
               DC.B 'MKDIRECTORY',0
               DC.B 'RMDIRECTORY',0
               DC.B 'NAME',0
               DC.B 'FORMAT',0
               DC.B 'GETREGISTER',0
               DC.B 'LINE',0
               DC.B 'CR',0
               DC.B 'FOPEN',0
               DC.B 'FCLOSE',0
               DC.B 'CLR',0
               DC.B 'CACHECLR',0
               DC.B 'CACHEGET',0
               DC.B 'RESET',0
               DC.B 'CHECKSUMME',0
               DC.B 'FILE',0
               DC.B 'SWITCH',0
               DC.B 'RESIDENT',0
               DC.B 'CURSOR',0
               DC.B 'INITREGISTER',0
               DC.B 'BSSCLEAR',0
               DC.B 'OBSERVE',0
               DC.B 'DO',0
               DC.B 'SYNC',0
               DC.B 'RWABS',0
               DC.B 'CONTINUE',0
               DC.B 'FATTRIBUT',0
               DC.B 'LABELBASE',0
               DC.B 'HELP',0
               DC.B 'READFDC',0
               DC.B 'COOKIE',0
               DC.B 'OVERSCAN',0
               DC.B 'B',0
               DC.B 'F',0
               DC.B '~',0
               IFNE ultradev
               DC.B 'UDMIRROR',0
               ENDC
               DC.B 'ABOUT',0
               DC.B -1
               EVEN
;>               OPT W-
;>               BASE DC.W,*
cmdadr:        DC.W ret_jump-*
               DC.W cmd_und-*                       ;&
               DC.W cmd_number-*                    ;#
               DC.W cmd_atsign-*                    ;@
               DC.W cmd_assem-*                     ;!
               DC.W cmd_dobef-*                     ;|
               DC.W cmd_calc-*                      ;?
               DC.W cmd_dchng-*                     ;/
               DC.W cmd_achng-*                     ;)
               DC.W cmd_schng-*                     ;]
               DC.W cmd_chng-*                      ;.
               DC.W cmd_mchng-*                     ;,
               DC.W cmd_send-*                      ;"
               DC.W cmd_prnt-*                      ;PRN
               DC.W cmd_prnt-*                      ;P
               DC.W cmd_bkpt-*                      ;BREAKPOINTS
               DC.W cmd_save-*                      ;SAVE
               DC.W cmd_symbol-*                    ;SYMBOLTABLE
               DC.W cmd_sysinfo-*                   ;SYSINFO
               DC.W cmd_exit-*                      ;SYSTEM
               DC.W cmd_set-*                       ;SET
               DC.W cmd_dump-*                      ;MEMORY
               DC.W cmd_list-*                      ;LIST
               DC.W cmd_listf-*                     ;LIST+
               DC.W cmd_disass-*                    ;DISASSEMBLE
               DC.W cmd_dump-*                      ;DUMP
               DC.W cmd_lexec-*                     ;LEXEC
               DC.W cmd_load-*                      ;LOAD
               DC.W cmd_go-*                        ;GO
               DC.W cmd_untrace-*                   ;UNTRACE
               DC.W cmd_info-*                      ;INFO
               DC.W cmd_trace-*                     ;TRACE
               DC.W cmd_call-*                      ;CALL
               DC.W cmd_if-*                        ;IF
               DC.W cmd_move-*                      ;MOVE
               DC.W cmd_compare-*                   ;COMPARE
               DC.W cmd_move-*                      ;COPY
               DC.W cmd_dir-*                       ;DIRECTORY
               DC.W cmd_hunt-*                      ;HUNT
               DC.W cmd_find-*                      ;FIND
               DC.W cmd_fill-*                      ;FILL
               DC.W cmd_cls-*                       ;CLS
               DC.W cmd_asc-*                       ;ASCII
               DC.W cmd_findasc-*                   ;ASCFIND
               DC.W cmd_set-*                       ;LET
               DC.W cmd_exit-*                      ;EXIT
               DC.W cmd_exit-*                      ;QUIT
               DC.W cmd_type-*                      ;TYPE
               DC.W cmd_showmem-*                   ;SHOWMEMORY
               DC.W cmd_mon-*                       ;MOUSEON
               DC.W cmd_mon-*                       ;MON
               DC.W cmd_mon-*                       ;SHOWM
               DC.W cmd_moff-*                      ;MOUSEOFF
               DC.W cmd_moff-*                      ;MOFF
               DC.W cmd_moff-*                      ;HIDEM
               DC.W cmd_dread-*                     ;READSEKTOR
               DC.W cmd_dread-*                     ;RSEKTOR
               DC.W cmd_dwrite-*                    ;WRITESEKTOR
               DC.W cmd_dwrite-*                    ;WSEKTOR
               DC.W cmd_dread-*                     ;READSECTOR
               DC.W cmd_dread-*                     ;RSECTOR
               DC.W cmd_dwrite-*                    ;WRITESECTOR
               DC.W cmd_dwrite-*                    ;WSECTOR
               DC.W cmd_rtrack-*                    ;READTRACK
               DC.W cmd_rtrack-*                    ;RTRACK
               DC.W cmd_erase-*                     ;KILL
               DC.W cmd_erase-*                     ;ERASE
               DC.W cmd_free-*                      ;FREE
               DC.W cmd_mkdir-*                     ;MKDIR
               DC.W cmd_rmdir-*                     ;RMDIR
               DC.W cmd_name-*                      ;NAME
               DC.W cmd_format-*                    ;FORMAT
               DC.W cmd_getreg-*                    ;GETREGISTER
               DC.W cmd_line-*                      ;LINE
               DC.W cmd_crout-*                     ;CR
               DC.W cmd_fopen-*                     ;FOPEN
               DC.W cmd_fclose-*                    ;FCLOSE
               DC.W cmd_clr-*                       ;CLR
               DC.W cmd_clrcach-*                   ;CACHECLR
               DC.W cmd_getcach-*                   ;CACHEGET
               DC.W cmd_reset-*                     ;RESET
               DC.W cmd_checksum-*                  ;CHECKSUMME
               DC.W cmd_file-*                      ;FILE
               DC.W cmd_switch-*                    ;SWITCH
               DC.W cmd_resident-*                  ;RESIDENT
               DC.W cmd_swchcur-*                   ;CURSOR
               DC.W cmd_ireg-*                      ;INITREGISTER
               DC.W cmd_bclr-*                      ;BSSCLEAR
               DC.W cmd_obser-*                     ;OBSERVE
               DC.W cmd_do-*                        ;DO
               DC.W cmd_sync-*                      ;SYNC
               DC.W cmd_rwabs-*                     ;RWABS
               DC.W cmd_cont-*                      ;CONTINUE
               DC.W cmd_fattrib-*                   ;FATTRIBUT
               DC.W cmd_labelbase-*                 ;LABELBASE
               DC.W cmd_help-*                      ;HELP
               DC.W cmd_fdc-*                       ;READFDC
               DC.W cmd_cookie-*                    ;COOKIE
               DC.W cmd_overscan-*                  ;OVERSCAN
               DC.W cmd_bkpt-*                      ;B
               DC.W cmd_file-*                      ;F
               DC.W cmd_set-*                       ; ~
               IFNE ultradev 
               DC.W cmd_udmirror-*
               ENDC
               DC.W cmd_about-*
               ;>ENDPART
********************************************************************************
* Sprungleiste der Menüfunktionen                                              *
********************************************************************************
               ;>PART 'f_jumps'
;>               BASE DC.W,f_jumps
f_jumps:       DC.W f_trace-f_jumps                       ;F1    - Trace (Fast Traps)
               DC.W f_do_pc-f_jumps                       ;F2    - Do PC
               DC.W f_trarts-f_jumps                      ;F3    - Trace until RTS
               DC.W f_traall-f_jumps                      ;F4    - Trace all
               DC.W f_skip-f_jumps                        ;F5    - Skip
               DC.W f_dir-f_jumps                         ;F6    - Directory
               DC.W f_hexdump-f_jumps                     ;F7    - Hexdump
               DC.W f_disass-f_jumps                      ;F8    - Disassemble
               DC.W f_list-f_jumps                        ;F9    - List
               DC.W f_switch-f_jumps                      ;F10   - Switch Screen
               DC.W f_68020emu-f_jumps                    ;S+F1  - 68020 Emulator (für Trace)
               DC.W f_trasub-f_jumps                      ;S+F2  - Don't trace Subroutine
               DC.W f_trarte-f_jumps                      ;S+F3  - Trace until RTE/RTR
               DC.W go_pc-f_jumps                         ;S+F4  - Go
               DC.W f_togmode-f_jumps                     ;S+F9  - Overwrt/Insert
               DC.W f_marker-f_jumps                      ;S+F6  - Marker
               DC.W f_break-f_jumps                       ;S+F7  - Breakpoints anzeigen
               DC.W f_info-f_jumps                        ;S+F8  - Info
               DC.W f_direct-f_jumps                      ;S+F5  - Direct
               DC.W f_quit-f_jumps                        ;S+F10 - Quit
;>               OPT W+
               ;>ENDPART
********************************************************************************
* S+F6 - Marker anzeigen                                                       *
********************************************************************************
               ;>PART 'f_marker'
f_marker:       movea.l #allg_buffer,A0
                adda.l  A4,A0
                lea     mark_va(PC),A1
                moveq   #'1',D1
                moveq   #9,D0
f_marker1:      move.l  A0,(A1)+                  ;RSC-Texte im Buffer aufbauen
                addq.l  #6,A1
                move.b  #'M',(A0)+
                move.b  D1,(A0)+
                move.b  #':',(A0)+
                move.b  #'$',(A0)+
                moveq   #15,D2
f_marker3:      move.b  #' ',(A0)+
                dbra    D2,f_marker3
                clr.b   (A0)+
                addq.w  #1,D1
                cmp.w   #':',D1
                bne.s   f_marker2
                moveq   #'0',D1
f_marker2:      dbra    D0,f_marker1

                st      testwrd(A4)
                movea.l basep(A4),A0              ;Adresse des Basepage
                move.l  8(A0),D2                  ;Anfangsadr des TEXT-Segments
                move.l  $18(A0),D3                ;Anfangsadr des BSS-Segments
                add.l   $1C(A0),D3                ;+ L„nge des BSS-Segments
                lea     simple_vars(A4),A5
                lea     mark_va(PC),A2
                lea     mark_vb(PC),A3
                moveq   #9,D7
f_mark1:        movea.l (A2)+,A0                  ;Adresse des Strings holen
                addq.l  #4,A0
                move.l  (A5)+,D1
                bsr     hexlout                   ;Variablenwert einsetzen
                addq.l  #1,A0
                moveq   #4,D0
f_mark2:        move.b  #'?',(A0)+                ;Zeilennummer unbekannt
                dbra    D0,f_mark2
                lea     marker_25(PC),A6          ;Default-Symbol = " "
                cmp.l   D2,D1
                blo.s   f_mark3                   ;<TEXT-Segment
                cmp.l   D3,D1
                bhs.s   f_mark3                   ;>BSS-Segment
                tst.l   sym_size(A4)              ;Symboltabelle berhaupt da?
                beq.s   f_mark3                   ;keine Symbole da!
                andi.w  #$FFEF,4(A3)              ;Light aus!
                bsr     hunt_symbol
                bne.s   f_mark8
                ori.w   #$10,4(A3)                ;Light an
f_mark8:        movea.l (A1),A6                   ;Symbolnamesadresse holen
f_mark3:        move.l  A6,(A3)+                  ;Adresse einsetzen
                addq.l  #6,A3
                addq.l  #6,A2
                dbra    D7,f_mark1
                move.l  merk_svar(A4),D0
                beq.s   f_mark6                   ;Keine šbergabe durch den Assembler
                movea.l D0,A1
                moveq   #9,D7
                lea     mark_va(PC),A2
f_mark4:        movea.l (A2)+,A0                  ;Adresse des Strings holen
                lea     12(A0),A0                 ;Zeiger auf die Zeilennummer
                moveq   #0,D1
                move.w  (A1)+,D1
                addq.w  #1,D1
                beq.s   f_mark5                   ;Zeilennummer -1 ist illegal
                subq.w  #1,D1
                moveq   #5,D4
                bsr     dezw_out                  ;Zeilennummer einsetzen
f_mark5:        addq.l  #6,A2
                addq.l  #4,A1
                dbra    D7,f_mark4
f_mark6:        sf      testwrd(A4)
                lea     marker_rsc(PC),A0
                jsr     @form_do(A4)
                subq.w  #2,D0
                bmi.s   f_mark7
                lsl.l   #2,D0
                lea     simple_vars(A4),A0
                move.l  0(A0,D0.w),D1             ;Variablenwert holen
                jsr     do_dopp                   ;"Doppelklick" ausführen
f_mark7:        rts

marker_rsc:    DC.W 0,0,49,15,1
               DC.W 5,4
mark_va:       DC.L 0
               DC.W 8
               DC.W 5,5
               DC.L 0
               DC.W 8
               DC.W 5,6
               DC.L 0
               DC.W 8
               DC.W 5,7
               DC.L 0
               DC.W 8
               DC.W 5,8
               DC.L 0
               DC.W 8
               DC.W 5,9
               DC.L 0
               DC.W 8
               DC.W 5,10
               DC.L 0
               DC.W 8
               DC.W 5,11
               DC.L 0
               DC.W 8
               DC.W 5,12
               DC.L 0
               DC.W 8
               DC.W 5,13
               DC.L 0
               DC.W 8

               DC.W 25,4
mark_vb:       DC.L 0                             ;Labeladressen einsetzen
               DC.W 8
               DC.W 25,5
               DC.L 0                             ;wenn keins definiert, "marker_25" einsetzen
               DC.W 8
               DC.W 25,6
               DC.L 0
               DC.W 8
               DC.W 25,7
               DC.L 0
               DC.W 8
               DC.W 25,8
               DC.L 0
               DC.W 8
               DC.W 25,9
               DC.L 0
               DC.W 8
               DC.W 25,10
               DC.L 0
               DC.W 8
               DC.W 25,11
               DC.L 0
               DC.W 8
               DC.W 25,12
               DC.L 0
               DC.W 8
               DC.W 25,13
               DC.L 0
               DC.W 8

               DC.W 40,1
               DC.L marker_13
               DC.W $26

               DC.W 1,4
               DC.L marker_25                     ;Die Buttons
               DC.W $24
               DC.W 3,5
               DC.L marker_25
               DC.W $24
               DC.W 1,6
               DC.L marker_25
               DC.W $24
               DC.W 3,7
               DC.L marker_25
               DC.W $24
               DC.W 1,8
               DC.L marker_25
               DC.W $24
               DC.W 3,9
               DC.L marker_25
               DC.W $24
               DC.W 1,10
               DC.L marker_25
               DC.W $24
               DC.W 3,11
               DC.L marker_25
               DC.W $24
               DC.W 1,12
               DC.L marker_25
               DC.W $24
               DC.W 3,13
               DC.L marker_25
               DC.W $24

               DC.W 9,3
               DC.L marker_10
               DC.W 8
               DC.W 18,3
               DC.L marker_11
               DC.W 8
               DC.W 32,3
               DC.L marker_12
               DC.W 8
               DC.W 15,1
               DC.L marker_24
               DC.W 8
               DC.W -1

marker_25:     DC.B ' ',0
               IFEQ sprache
marker_10:     DC.B 'Adresse:',0
marker_11:     DC.B 'Zeile:',0
marker_12:     DC.B 'Labelname:',0
marker_24:     DC.B 'Markerliste:',0
marker_13:     DC.B '  OK  ',0
               ELSE
marker_10:     DC.B '  adr:',0
marker_11:     DC.B 'line:',0
marker_12:     DC.B 'labelname:',0
marker_24:     DC.B 'Marker',0
marker_13:     DC.B '  OK  ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* S+F7 - Breakpoints anzeigen                                                  *
********************************************************************************
               ;>PART 'f_break'
f_break:        lea     breakpnt(A4),A2
                lea     cond_breaks(A4),A3
                lea     break_rsc_base(PC),A5
                movea.l #allg_buffer,A0
                adda.l  A4,A0
                st      testwrd(A4)
                moveq   #15,D7
f_brea1:        move.l  A0,(A5)+                  ;Adresse einsetzen
                addq.l  #6,A5
                lea     42(A0),A1
                move.b  #'B',(A0)+
                move.b  #'0',(A0)+
                move.w  D7,D0
                neg.w   D0
                add.w   #15+'0',D0
                cmp.b   #'9',D0
                bls.s   f_brea10
                addq.w  #7,D0
f_brea10:       move.b  D0,(A0)+
                move.b  #'=',(A0)+
                move.b  #'$',(A0)+
                move.l  (A2)+,D1                  ;Breakpointadr
                bne.s   f_brea2
                moveq   #7,D0
f_brea4:        move.b  #'0',(A0)+                ;Breakpoint nicht gesetzt
                dbra    D0,f_brea4
                addq.l  #8,A2
                bra.s   f_brea3
f_brea2:        bsr     hexlout
                move.w  (A2)+,D1                  ;Breakpointtyp
                move.l  (A2),D2                   ;Z„hler, ...
                addq.l  #6,A2                     ;zeigt nun auf den n„chsten Breakpoint
                subq.w  #1,D1
                beq.s   f_brea5
                bcs.s   f_brea6
                bmi.s   f_brea7
                move.b  #',',(A0)+
                move.b  #'?',(A0)+
                move.l  A3,-(SP)
                moveq   #27,D0                    ;max. 28 Zeichen ausgeben
f_brea9:        move.b  (A3)+,(A0)+
                dbeq    D0,f_brea9
                movea.l (SP)+,A3
                bra.s   f_brea3
f_brea7:        tst.l   D2
                bls.s   f_brea3
                move.b  #',',(A0)+
                bra.s   f_brea8
f_brea6:        move.b  #',',(A0)+
                move.b  #'=',(A0)+
f_brea8:        move.l  D2,D1
                bsr     dezout                    ;Dezimalzahl ausgeben
                bra.s   f_brea3
f_brea5:        move.b  #',',(A0)+
                move.b  #'*',(A0)+
f_brea3:        clr.b   (A0)
                lea     80(A3),A3
                movea.l A1,A0
                dbra    D7,f_brea1
                sf      testwrd(A4)
                lea     break_rsc(PC),A0
                jmp     @form_do(A4)

break_rsc:     DC.W 0,0,44,20,1
               DC.W 18,18
               DC.L ok_button
               DC.W $26
               DC.W 1,1
break_rsc_base:DC.L 0
               DC.W 8
               DC.W 1,2
               DC.L 0
               DC.W 8
               DC.W 1,3
               DC.L 0
               DC.W 8
               DC.W 1,4
               DC.L 0
               DC.W 8
               DC.W 1,5
               DC.L 0
               DC.W 8
               DC.W 1,6
               DC.L 0
               DC.W 8
               DC.W 1,7
               DC.L 0
               DC.W 8
               DC.W 1,8
               DC.L 0
               DC.W 8
               DC.W 1,9
               DC.L 0
               DC.W 8
               DC.W 1,10
               DC.L 0
               DC.W 8
               DC.W 1,11
               DC.L 0
               DC.W 8
               DC.W 1,12
               DC.L 0
               DC.W 8
               DC.W 1,13
               DC.L 0
               DC.W 8
               DC.W 1,14
               DC.L 0
               DC.W 8
               DC.W 1,15
               DC.L 0
               DC.W 8
               DC.W 1,16
               DC.L 0
               DC.W 8
               DC.W -1
               ;>ENDPART
********************************************************************************
* F1 - Trace                                                                   *
********************************************************************************
               ;>PART 'f_trace'
f_trace:        bsr     init_trace
                bra     do_trace                  ;Befehl ausführen
f_trac1:        bsr     exit_trace
f_trac2:        move.w  trace_delay(A4),D0
f_trac5:        move    #0,CCR
                dbra    D0,f_trac5                ;Trace-Verz”gerung
                clr.l   merk_pc(A4)
                jsr     hunt_pc                   ;Bildschirm aufgebaut & PC auf dem Schirm?
                move.w  D7,-(SP)
                bpl.s   f_trac4                   ;dann nicht neu ausgeben
                clr.w   (SP)                      ;Cursor in Zeile 0
                move.w  trace_flag(A4),D0         ;List oder Disassemble
                subq.w  #1,D0
                bmi.s   f_trac3                   ;=0 => List
                beq.s   f_trac6                   ;=1 => Disassemble
                tst.l   ass_vector(A4)            ;Assembler da?
                beq.s   f_trac3                   ;Nein! => dann Listen
                bsr     f_dir                     ;Source-List
                bra.s   f_trac4
f_trac6:        bsr     f_disass                  ;Ab PC disassemblieren
                bra.s   f_trac4
f_trac3:        bsr     f_list                    ;Ab PC listen
f_trac4:        move.w  (SP)+,zeile(A4)
                clr.w   spalte(A4)
                move.l  _pc(A4),default_adr(A4)
                bra     all_normal                ;Das war's
               ;>ENDPART
********************************************************************************
* S+F2 - Don't trace Subroutine                                                *
********************************************************************************
               ;>PART 'f_trasub'
f_trasub:       movea.l _pc(A4),A6
                move.b  (A6),D0
                cmp.b   #$61,D0
                beq.s   f_do_pc                   ;BSR ausführen
                move.w  (A6),D0                   ;zu tracender Opcode
                and.w   #$FFC0,D0
                cmp.w   #$4E80,D0
                beq.s   f_do_pc                   ;JSR ausführen
                bra.s   f_trace                   ;Befehl tracen
               ;>ENDPART
********************************************************************************
* F2 - Do PC                                                                   *
********************************************************************************
               ;>PART 'f_do_pc'
f_do_pc:        lea     f_trac2(PC),A0
                move.l  A0,jmpdispa(A4)           ;Rücksprungadr setzen
                bsr     in_trace_buff             ;Register in den Trace-Buffer
                bra     cmd_call1                 ;N„chsten Befehl ausführen
               ;>ENDPART
********************************************************************************
* F3 - Trace until RTS   Shift+F3 - Trace until RTE/R                          *
********************************************************************************
               ;>PART 'f_trarts/e'
f_trarte:       moveq   #2,D7                     ;Stackoffset für RTE/RTR
                bra.s   f_trara
f_trarts:       moveq   #0,D7                     ;Kein Stackoffset für RTS
f_trara:        lea     f_trac1(PC),A0
                move.l  A0,jmpdispa(A4)           ;Rücksprungadr setzen
                bsr     in_trace_buff             ;Register in den Trace-Buffer
                movea.l _ssp(A4),A0
                btst    #5,_sr(A4)                ;User- oder Supervisor-Stack?
                bne.s   f_trar1
                movea.l _usp(A4),A0
f_trar1:        move.l  0(A0,D7.w),merk_stk(A4)
                lea     login_trace,A1
                move.l  A1,0(A0,D7.w)             ;Rücksprungadresse berschreiben
                bra     go_pc                     ;Los geht's
               ;>ENDPART
********************************************************************************
* F4 - Trace all                                                               *
********************************************************************************
               ;>PART 'f_traall'
f_traall:       bsr     init_trace
                bsr     do_trace_all              ;Befehl ausführen
                bra     f_trac1
               ;>ENDPART
********************************************************************************
* F5 - Skip PC                                                                 *
********************************************************************************
               ;>PART 'f_skip'
f_skip:         bsr     in_trace_buff             ;Register in den Trace-Buffer
                movea.l _pc(A4),A6                ;Befehlsl„nge am PC ermitteln
                jsr     get_dlen                  ;Befehlsl„nge ermitteln
                move.l  A6,_pc(A4)                ;neuen PC setzen
                bsr     set_reg                   ;und neu setzen
                bra     f_trac2
               ;>ENDPART
********************************************************************************
* F6 - Hexdump                                                                 *
********************************************************************************
               ;>PART 'f_hexdump'
f_hexdump:      movem.l D0-A6,-(SP)
                movea.l reg_pos(A4),A5
                move.l  64(A5),D1                 ;aktuellen PC holen
                bclr    #0,D1
                movea.l D1,A6
                move.w  #-1,zeile(A4)             ;Cursor home (s.u.)
                move.w  down_lines(A4),D7
                subq.w  #1,D7
f_hexd0:        move.w  D7,-(SP)
                addq.w  #1,zeile(A4)
                moveq   #0,D3
                bsr     cmd_dump7                 ;Hexdump ausgeben
                move.w  (SP)+,D7
                dbra    D7,f_hexd0
                clr.w   zeile(A4)
                move.w  #10,spalte(A4)            ;Cursor in die 1.Zeile
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* F7/F8 - List/Disassemble                                                     *
********************************************************************************
               ;>PART 'f_list/disass'
f_list:         st      list_flg(A4)
                clr.w   trace_flag(A4)
                bra.s   f_list0
f_disass:       sf      list_flg(A4)
                move.w  #1,trace_flag(A4)
f_list0:        movem.l D0-A6,-(SP)
                movea.l reg_pos(A4),A5
                move.l  64(A5),D1                 ;aktuellen PC holen
                btst    #0,D1
                beq.s   f_disa1
                addq.l  #1,D1
f_disa1:        movea.l D1,A6
                move.w  #-1,zeile(A4)             ;Cursor home (s.u.)
                move.w  down_lines(A4),D7
                subq.w  #1,D7
f_disa0:        move.l  D7,-(SP)
                addq.w  #1,zeile(A4)
                bsr     do_disass
                move.l  (SP)+,D7
                dbra    D7,f_disa0
                clr.w   zeile(A4)
                move.w  #10,spalte(A4)            ;Cursor in die 1.Zeile
                movem.l (SP)+,D0-A6
                sf      list_flg(A4)
                rts
               ;>ENDPART
********************************************************************************
* F9 - Sourcecode-List                                                         *
********************************************************************************
               ;>PART 'f_dir'
f_dir:          tst.l   ass_vector(A4)            ;Assembler da?
                beq.s   f_list                    ;Nein! => dann Listen
                move.w  #2,trace_flag(A4)
                movem.l D0-A6,-(SP)
                movea.l reg_pos(A4),A5
                movea.l 64(A5),A6                 ;aktuellen PC holen
                move.l  A6,D0
                addq.l  #1,D0
                and.b   #-2,D0                    ;EVEN
                movea.l D0,A6
                jsr     check_read                ;Zugriff erlaubt?
                bne.s   src_list1                 ;Ende, wenn nicht
                movea.l basep(A4),A0              ;Basepage des zu debuggenden Programms
                cmp.l   $18(A0),D0                ;BSS-Segment-Adr erreicht?
                bhs.s   src_list2                 ;dann Ende
                sub.l   8(A0),D0                  ;- TEXT-Segment-Start
                bmi.s   src_list2                 ;kleiner als TEXT-Segment => Ende
                movea.l ass_vector(A4),A5
                jsr     -6(A5)                    ;Offset => Zeilennummer
                move.w  D0,D6                     ;Zeilennummer merken
                clr.w   zeile(A4)                 ;Cursor home
                st      testwrd(A4)               ;Ausgabe in den Buffer A0
                move.w  down_lines(A4),D7
                subq.w  #1,D7                     ;Zeilenanzahl auf dem Screen
src_list0:      move.w  D6,D0                     ;Zeilennummer setzen
                jsr     -18(A5)                   ;Zeile D0 nach A0
                addq.l  #1,D0
                bne.s   src_list3
                lea     src_list_null(PC),A0      ;Leerstring ausgeben
                bra.s   src_list4
src_list3:      move.l  A0,-(SP)
                lea     spaced2(A4),A0
                movem.l D0-D7/A1-A6,-(SP)
                move.l  A6,D1
                jsr     @anf_adr(A4)              ;Adresse am Zeilenanfang
                movem.l (SP)+,D0-D7/A1-A6
                movea.l (SP)+,A1
                move.b  #'&',(A0)+                ;Kennung = Sourcetext Listing
                moveq   #4,D4                     ;5 Stellen
                moveq   #0,D1
                move.w  D6,D1                     ;Zeilennummer
                bsr     dezw_out_b                ;Zahl ausgeben
                moveq   #65,D1                    ;max.Zahl an Zeichen = 66
src_list1:      move.b  (A1)+,(A0)+               ;Buffer umkopieren
                dbeq    D1,src_list1
                clr.b   (A0)                      ;Zeilenende erzwingen
src_list4:      lea     spaced2(A4),A0
                move.w  zeile(A4),D0
                jsr     write_line                ;Ergebnis des Disassemblers ausgeben
                addq.w  #1,D6                     ;n„chste Zeile
                addq.w  #1,zeile(A4)              ;Zeilennummer+1
                dbra    D7,src_list0              ;schon alle Zeilen?
src_list2:      clr.w   zeile(A4)
                move.w  #10,spalte(A4)            ;Cursor in die 1.Zeile
                sf      testwrd(A4)               ;Ausgabe wieder normal
                movem.l (SP)+,D0-A6
                rts
src_list_null: DC.B '&',0
               ;>ENDPART
********************************************************************************
* Zeilen in D0 ausgeben                                                        *
********************************************************************************
               ;>PART 'src_out'
src_out:        move.l  D0,D7                     ;Zeilennummer merken
                jsr     -12(A5)                   ;Zeilennummer => Offset
                movea.l basep(A4),A6
                movea.l 8(A6),A6                  ;TEXT-Segment-Adresse
                tst.l   D0
                bmi.s   src_out0
                adda.l  D0,A6                     ;+TEXT-Segment-Adresse
src_out0:       move.l  D7,D0                     ;Zeilennummer zurück
                jsr     -18(A5)                   ;Zeile D0 nach A0
                addq.l  #1,D0                     ;Ende des Sourcetextes?
                beq.s   src_out1                  ;Ja! => raus
                st      testwrd(A4)               ;Ausgabe in den Buffer A0
                move.l  A0,-(SP)
                lea     spaced2(A4),A0
                movem.l D0-D7/A1-A6,-(SP)
                move.l  A6,D1
                jsr     @anf_adr(A4)              ;Adresse am Zeilenanfang
                movem.l (SP)+,D0-D7/A1-A6
                movea.l (SP)+,A1
                move.b  #'&',(A0)+                ;Kennung = Sourcetext Listing
                moveq   #4,D4                     ;5 Stellen
                moveq   #0,D1
                move.w  D7,D1                     ;Zeilennummer
                bsr     dezw_out_b                ;Zahl ausgeben
                moveq   #65,D1                    ;max.Zahl an Zeichen = 66
src_out2:       move.b  (A1)+,(A0)+               ;Buffer umkopieren
                dbeq    D1,src_out2
                clr.b   (A0)                      ;Zeilenende erzwingen
                lea     spaced2(A4),A0
                move.w  zeile(A4),D0
                jsr     write_line                ;Ergebnis des Disassemblers ausgeben
                sf      testwrd(A4)               ;Ausgabe in den Buffer A0
                move    #$FF,CCR                  ;Z-Flag setzen
                rts
src_out1:       move    #0,CCR                    ;Z-Flag l”schen
                rts
               ;>ENDPART
********************************************************************************
* F10 - IFEQ Screen                                                          *
********************************************************************************
               ;>PART 'f_switch'
f_switch:       jsr     @desel_menue(A4)           ;evtl. selektierten Menüeintrag deselektieren
                lea     debugger_scr(A4),A0
                jsr     check_screen              ;der Debugger-Screen an?
                bne.s   f_switch1                 ;Nein! =>
                jmp     @page2(A4)                ;Originale Grafikseite
f_switch1:      jmp     @page1(A4)                ;Debuggerscreen
               ;>ENDPART
********************************************************************************
* S+F1 - 68020 Emulator                                                        *
********************************************************************************
               ;>PART 'f_68020emu'
f_68020emu:     lea     emu68020(PC),A0
                move.l  A0,$24.w                  ;68020-Trace-Vektor
                bsr     init_trace
                bsr     do_trace1                 ;los geht's
                bra     f_trac1                   ;und fertig mit Trace

emu68020:       move    #$2700,SR                 ;Bitte nicht st”ren... (IRQs aus)
                movem.l D0/A0,-(SP)               ;Register retten
                movea.l 10(SP),A0                 ;Den PC holen
                move.w  (A0),D0                   ;Den Befehl am PC holen
                cmp.w   #$4E73,D0                 ;RTE
                beq.s   emu680203
                cmp.w   #$4E75,D0                 ;RTS
                beq.s   emu680203
                cmp.w   #$4E77,D0                 ;RTR
                beq.s   emu680203
                andi.w  #$F0F8,D0                 ;Condition & Register ausmaskieren
                cmp.w   #$50C8,D0                 ;DBcc
                beq.s   emu680203
                andi.w  #$F000,D0                 ;Condition & sprungweite ausmaskieren
                cmp.w   #$6000,D0                 ;Bcc
                beq.s   emu680203
                move.w  (A0),D0                   ;Den Befehl am PC nochmal holen
                andi.w  #$FFF0,D0                 ;TRAP-Nummer ausmaskieren
                cmp.w   #$4E40,D0                 ;TRAP
                beq.s   emu680203
                andi.w  #$FFC0,D0                 ;EA erstmal ausmaskieren
                cmp.w   #$4EC0,D0                 ;JMP
                beq.s   emu680202
                cmp.w   #$4E80,D0                 ;JSR
                beq.s   emu680202
emu680201:      movem.l (SP)+,D0/A0               ;Register zurück
                bset    #7,(SP)                   ;Trace wieder an (nicht vergessen)
                rte                               ;und weiter
emu680202:      move.w  (A0),D0
                and.w   #%111111,D0               ;EA isolieren
                cmp.w   #%111011,D0
                bhi.s   emu680201                 ;#, etc (68020) ist nicht erlaubt
                cmp.w   #%101000,D0               ;d(An), absolut, etc. => Abbruch
                bhs.s   emu680203                 ;Hier war ein Fehler => bls.s !!!
                and.w   #%111000,D0               ;Modus isolieren
                cmp.w   #%10000,D0
                bne.s   emu680201                 ;wenn nicht (An) dann weiter
emu680203:      movem.l (SP)+,D0/A0               ;Hier soll nun abgebrochen werden
                bra     do_trace_excep            ;und beenden
               ;>ENDPART
********************************************************************************
* S+F9 - Info                                                                  *
********************************************************************************
               ;>PART 'f_info'
f_info:         lea     info_rsc(PC),A1
                move.w  #10,6(A1)                 ;10 Zeilen hoch
                move.w  #8,12(A1)                 ;Button in Zeile 8
                move.w  #-1,info_r1               ;Baum kürzen
                st      testwrd(A4)
                lea     info_txt1+28(PC),A0
                move.l  basepage(A4),D1
                bsr     hexlout
                lea     info_txtx+28(PC),A0
                move.l  end_adr(A4),D1
                bsr     hexlout
                lea     info_txt2+28(PC),A0
                move.l  first_free(A4),D1
                bsr     hexlout
                lea     info_txta+28(PC),A0
                move.l  save_data+1070(A4),D1
                bsr     hexlout
                move.l  basep(A4),D0
                beq     f_info1
                movea.l D0,A2                     ;Programmbasepage merken
                move.w  #14,6(A1)                 ;14 Zeilen hoch
                move.w  #12,12(A1)                ;Button in Zeile 12
                move.w  #1,info_r1
                move.w  #1,info_r2                ;Baum wieder verl„ngern
                lea     info_txt5(PC),A0
                move.l  A0,info_r3
                lea     28(A0),A0
                move.l  8(A2),D1
                bsr     hexlout                   ;TEXT-Base einsetzen
                lea     info_txt6(PC),A0
                move.l  A0,info_r4
                lea     28(A0),A0
                move.l  $10(A2),D1
                bsr     hexlout                   ;DATA-Base einsetzen
                lea     info_txt7+28(PC),A0
                move.l  $18(A2),D1
                bsr     hexlout                   ;BSS-Base einsetzen
                lea     info_txt8+28(PC),A0
                move.l  $18(A2),D1
                add.l   $1C(A2),D1
                bsr     hexlout                   ;Last used Adr
                move.w  #-1,info_r5
                move.l  sym_size(A4),D2
                beq     f_info2                   ;Das war vorerst alles
                move.w  #15,6(A1)                 ;15 Zeilen hoch
                move.w  #13,12(A1)                ;Button in Zeile 13
                move.w  #1,info_r5
                lea     info_txt9+27(PC),A0
                movea.l A0,A2
                moveq   #4,D0                     ;max.5 Ziffern
f_info3:        move.b  #' ',(A0)+                ;Symbolwert l”schen
                dbra    D0,f_info3
                movea.l A2,A0
                moveq   #14,D1
                bsr     ldiv                      ;ein Eintrag ist 14 Bytes lang
                move.l  D2,D1
                moveq   #10,D2                    ;Dezimalsystem
                bsr     numoutx
                move.l  #'    ',D0
                moveq   #' ',D1
                tst.b   gst_sym_flag(A4)
                beq.s   f_info4
                move.l  #'(GST',D0
                moveq   #')',D1
f_info4:        move.l  D0,info_txts
                move.b  D1,info_txts+4
                bra.s   f_info2
f_info1:        move.l  merk_anf(A4),D1
                beq.s   f_info2
                move.w  #12,6(A1)                 ;12 Zeilen hoch
                move.w  #10,12(A1)                ;Button in Zeile 10
                move.w  #1,info_r1
                move.w  #-1,info_r2               ;Baum auf halblang
                lea     info_txt3(PC),A0
                move.l  A0,info_r3
                lea     28(A0),A0
                bsr     hexlout                   ;Startadresse einsetzen
                lea     info_txt4(PC),A0
                move.l  A0,info_r4
                lea     28(A0),A0
                move.l  merk_end(A4),D1
                subq.l  #1,D1
                bsr     hexlout                   ;Endadresse einsetzen
f_info2:        clr.b   testwrd(A4)
                movea.l A1,A0
                jmp     @form_do(A4)

info_rsc:      DC.W 0,0,38,10,1
               DC.W 16,12
               DC.L ok_button
               DC.W $26
               DC.W 11,1
               DC.L info_txt0
               DC.W 8
               DC.W 1,3
               DC.L info_txt1
               DC.W 8
               DC.W 1,4
               DC.L info_txtx
               DC.W 8
               DC.W 1,5
               DC.L info_txt2
               DC.W 8
               DC.W 1,6
               DC.L info_txta
               DC.W 8
info_r1:       DC.W 1,7
info_r3:       DC.L info_txt5
               DC.W 8
               DC.W 1,8
info_r4:       DC.L info_txt6
               DC.W 8
info_r2:       DC.W 1,9
               DC.L info_txt7
               DC.W 8
               DC.W 1,10
               DC.L info_txt8
               DC.W 8
info_r5:       DC.W 1,11
               DC.L info_txt9
               DC.W 8
               DC.W -1

               IFEQ sprache
info_txt9:     DC.B 'Symbolanzahl  '
info_txts:     DC.B '            :     ',0
info_txt0:     DC.B 'Speicherbelegung:',0
info_txt1:     DC.B 'Start des Debuggers       :$xxxxxxxx',0
info_txtx:     DC.B 'Ende des Debuggers        :$xxxxxxxx',0
info_txt2:     DC.B 'Start des freien Speichers:$xxxxxxxx',0
info_txta:     DC.B 'Ende des freien Speichers :$xxxxxxxx',0
info_txt3:     DC.B 'Start des Programms       :$xxxxxxxx',0
info_txt4:     DC.B 'Ende des Programms        :$xxxxxxxx',0
info_txt5:     DC.B 'Start des TEXT-Segments   :$xxxxxxxx',0
info_txt6:     DC.B 'Start des DATA-Segments   :$xxxxxxxx',0
info_txt7:     DC.B 'Start des BSS-Segments    :$xxxxxxxx',0
info_txt8:     DC.B 'Erste freie Adresse       :$xxxxxxxx',0
ok_button:     DC.B '  OK  ',0
               ELSE
info_txt9:     DC.B 'Number of Symbols '          ;~
info_txts:     DC.B '            :     ',0
info_txt0:     DC.B 'Memorytable:',0
info_txt1:     DC.B 'Start of the debugger     :$xxxxxxxx',0
info_txtx:     DC.B 'End of the debugger       :$xxxxxxxx',0
info_txt2:     DC.B 'Start of free memory      :$xxxxxxxx',0
info_txta:     DC.B 'End of free memory        :$xxxxxxxx',0
info_txt3:     DC.B 'Start of program          :$xxxxxxxx',0
info_txt4:     DC.B 'End of program            :$xxxxxxxx',0
info_txt5:     DC.B 'Start of TEXT-segment     :$xxxxxxxx',0
info_txt6:     DC.B 'Start of DATA-segment     :$xxxxxxxx',0
info_txt7:     DC.B 'Start of BSS-segment      :$xxxxxxxx',0
info_txt8:     DC.B 'first free adress         :$xxxxxxxx',0
ok_button:     DC.B '  OK  ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* S+F9 - Toggle Mode (Overwrite/Insert)                                        *
********************************************************************************
               ;>PART 'f_togmode'
f_togmode:      not.b   ins_mode(A4)              ;Mode umschalten
                jmp     set_ins_flag
               ;>ENDPART
********************************************************************************
* S+F10 - Quit?                                                                *
********************************************************************************
               ;>PART 'f_quit'
f_quit:         lea     quit_rsc(PC),A0
                jsr     @form_do(A4)
                subq.w  #2,D0                     ;Kein Ende
                bne     cmd_exit1                 ;Das war's
                rts

quit_rsc:      DC.W 0,0,27,6,1
               DC.W 1,1
               DC.L stop_icn
               DC.W $3303
               DC.W 7,1
               DC.L quit_txt1
               DC.W 8
               DC.W 7,2
               DC.L quit_txt2
               DC.W 8
               DC.W 7,4
               DC.L quit_txt3
               DC.W $26
               DC.W 17,4
               DC.L quit_txt4
               DC.W $24
               DC.W -1
               IFEQ sprache
quit_txt1:     DC.B 'M”chten Sie den',0
quit_txt2:     DC.B 'Debugger verlassen?',0
quit_txt3:     DC.B '  JA  ',0
quit_txt4:     DC.B ' NEIN ',0
               ELSE
quit_txt1:     DC.B 'Wanna quit this',0
quit_txt2:     DC.B 'adventure?',0
quit_txt3:     DC.B ' SURE ',0
quit_txt4:     DC.B ' OH NO ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* Ausgaberoutinen (Systemunabh„ngig)                                           *
********************************************************************************
********************************************************************************
* Hexausgabe in D1                                                             *
********************************************************************************
               ;>PART 'hex???out'
hexa2out:       moveq   #'$',D0
                jsr     @chrout(A4)
hexlout:        swap    D1                        ;Longword in D1 ausgeben
                bsr.s   hexwout
                swap    D1
hexwout:        rol.w   #8,D1                     ;Word in D1 ausgeben
                bsr.s   hexbout
                rol.w   #8,D1
hexbout:        movem.l D0-D2/A6,-(SP)            ;Byte in D1 ausgeben
                lea     hex2tab(PC),A6
                tst.w   small(A4)
                bne.s   hexbbut
                lea     hex_tab(PC),A6
hexbbut:        moveq   #0,D0
                moveq   #$0F,D2
                and.w   D1,D2
                rol.b   #4,D1
                and.w   #$0F,D1
                move.b  0(A6,D1.w),D0
                jsr     @chrout(A4)
                move.b  0(A6,D2.w),D0
                jsr     @chrout(A4)
                movem.l (SP)+,D0-D2/A6
                rts
hex_tab:       DC.B '0123456789ABCDEF'
hex2tab:       DC.B '0123456789abcdef'
               ;>ENDPART
********************************************************************************
* Zahl bzw. Label in D1 ausgeben                                               *
********************************************************************************
               ;>PART 'symbol_numout'
symbol_numout:  bsr.s   hunt_symbol
                beq     numout                    ;Z=1 => Kein Label
                moveq   #'.',D0
                jsr     @chrout(A4)
               ;>ENDPART
********************************************************************************
* Label ab A1 ausgeben                                                         *
********************************************************************************
               ;>PART 'labelout'
labelout:       move.l  (A1),-(SP)
                jsr     @print_line(A4)
                rts
               ;>ENDPART
********************************************************************************
* Testen ob ein Label den Wert D1 hat, dann Z=0 und A1=Zeiger auf Label        *
* (Bin„re Suchroutine)                                                         *
********************************************************************************
               ;>PART 'hunt_symbol'
hunt_symbol:    movem.l D0-D5,-(SP)
                tst.l   sym_size(A4)              ;Symboltabelle berhaupt da?
                beq.s   hunt_symbol4              ;Nein! => kein Label m”glich
                movea.l sym_adr(A4),A1            ;Anfangsadresse der Symboltabelle
                moveq   #0,D5                     ;Linke Grenze=0
                move.l  D1,D4
                move.l  sym_size(A4),D2           ;Rechte Grenze
                moveq   #14,D1
                bsr     ldiv                      ;ein Eintrag ist 14 Bytes lang
                move.l  D4,D1
hunt_symbol1:   move.w  D5,D4                     ;linke Grenze
                add.w   D2,D4                     ;+rechte Grenze
                lsr.w   #1,D4                     ;durch 2
                moveq   #0,D0                     ;evtl. ist die Label > 64k
                move.w  D4,D0                     ;= neuer Index
                mulu    #14,D0                    ;mal Breite eines Eintrags
                cmp.l   10(A1,D0.l),D1            ;Wert vergleichen
                bhi.s   hunt_symbol3              ;gesuchte Adr > Tabellenadr
                blo.s   hunt_symbol2              ;gesuchte Adr < Tabellenadr
                lea     0(A1,D0.l),A1             ;Gefunden!
                move    #0,CCR
                movem.l (SP)+,D0-D5
                rts
hunt_symbol2:   move.w  D4,D2                     ;Rechte Grenze=Index
                cmp.w   D5,D2
                beq.s   hunt_symbol4              ;Linke=rechte Grenze => nicht gefunden
                bra.s   hunt_symbol1              ;Weiter suchen
hunt_symbol3:   move.w  D4,D5
                addq.w  #1,D5                     ;Linke Indexgrenze erh”hen
                cmp.w   D5,D2                     ;Linke=rechte Grenze => nicht gefunden
                bne.s   hunt_symbol1              ;Weiter suchen
hunt_symbol4:   lea     0(A1,D0.l),A1             ;letzte Position
                move    #$FF,CCR                  ;Nichts gefunden => normale Zahl
                movem.l (SP)+,D0-D5
                rts
               ;>ENDPART
********************************************************************************
* Dezimal-Zahl in D1 ausgeben                                                  *
* Anzahl der Stellen in D4                                                     *
********************************************************************************
               ;>PART 'dezw_out'
dezw_out:       movem.l D0-D5/A3,-(SP)
                lea     dez_tab(PC),A3            ;Zeiger auf die Tabelle (s.u.)
                move.w  D4,D5                     ;Anzahl der Stellen-1
                add.w   D5,D5
                add.w   D5,D5                     ;mal 4 (schneller als LSL.W #2,D5 !)
                lea     4(A3,D5.w),A3             ;Tabellenzeiger auf die Stellenzahl
                moveq   #' ',D5                   ;führende Nullen als Space
dezw_o1:        move.l  -(A3),D3                  ;Wert aus der Tabelle holen
                moveq   #-'0',D2                  ;wird zu -'1',-'2',-'3', ...
dezw_o2:        sub.l   D3,D1                     ;Tabellenwert n mal abziehen
                dbmi    D2,dezw_o2                ;Unterlauf? Nein! =>
                neg.b   D2                        ;z.B. -'1' => '1'
                move.b  D2,D0
                cmp.b   #'0',D0                   ;eine Null?
                beq.s   dezw_o4                   ;Ja! =>
                moveq   #'0',D5                   ;ab nun werden Nullen als "0" ausgegeben
dezw_o3:        jsr     @chrout(A4)               ;das Zeichen in D0 ausgeben
                add.l   D3,D1                     ;den Unterlauf (s.o.) zurücknehmen
                dbra    D4,dezw_o1                ;schon alle Stellen ausgeben? Nein! =>
                movem.l (SP)+,D0-D5/A3
                rts
dezw_o4:        move.w  D5,D0                     ;Zeichen für die Null holen
                tst.w   D4                        ;letzte Ziffer?
                bne.s   dezw_o3                   ;Nein! => ausgeben
                moveq   #'0',D0                   ;wenn der Wert 0 ist, zumindest eine '0'
                bra.s   dezw_o3                   ;ausgeben!

dez_tab:       DC.L 1,10,100,1000,10000,100000
               DC.L 1000000,10000000,100000000,1000000000
               ;>ENDPART
********************************************************************************
* Dezimal-Zahl in D1 ausgeben (mit Führungsnullen!)                            *
* Anzahl der Stellen in D4                                                     *
********************************************************************************
               ;>PART 'dezw_out_b'
dezw_out_b:     movem.l D0-D5/A3,-(SP)
                lea     dez_tab(PC),A3
                move.w  D4,D5
                lsl.w   #2,D5
                lea     4(A3,D5.w),A3
                moveq   #' ',D5
dezw_o1_b:      move.l  -(A3),D3
                moveq   #$D0,D2
dezw_o2_b:      sub.l   D3,D1
                dbmi    D2,dezw_o2_b
                neg.b   D2
                move.b  D2,D0
                moveq   #'0',D5
                jsr     @chrout(A4)
                add.l   D3,D1
                dbra    D4,dezw_o1_b
                movem.l (SP)+,D0-D5/A3
                rts
               ;>ENDPART
********************************************************************************
* Zahl D1 im Dezimalsystem ausgeben                                            *
********************************************************************************
               ;>PART 'dezout'
dezout:         moveq   #10,D2                    ;Zahlensystem auf dezimal
               ;>ENDPART
********************************************************************************
* Zahl (D1) mit Zahlenbasiszeichen (Basis = D2) ausgeben                       *
********************************************************************************
               ;>PART 'numout'
numout:         cmp.w   #$10,D2
                beq.s   hexout                    ;falls Hexadezimal => in eigene Ausgabe
                movem.l D0-D4/A6,-(SP)
                moveq   #10,D4
                cmp.w   D4,D2
                bne.s   numoutb                   ;Dezimalzahl?
                cmp.l   D4,D1                     ;und die Zahl kleiner 10 ist
                blo.s   numout0                   ;keine Zahlenbasis ausgeben
numoutb:        bsr     basout                    ;Zahlenbasiszeichen nach D0 holen
                jsr     @chrout(A4)               ;und ausgeben
                bra.s   numout0                   ;Zahl gem„ž der Basis ausgeben
               ;>ENDPART
********************************************************************************
* Hexzahl in D1 ausgeben                                                       *
********************************************************************************
               ;>PART 'hexout'
hexout:         movem.l D0-D4,-(SP)
                moveq   #0,D4
                moveq   #-1,D2
                moveq   #7,D3                     ;max.8 Ziffern
                cmp.l   #10,D1                    ;und die Zahl kleiner 10 ist
                blo.s   hexouta                   ;keine Zahlenbasis ausgeben
                move.b  hexbase(PC),D0
                jsr     @chrout(A4)
hexouta:        rol.l   #4,D1
                move.b  D1,D0
                andi.w  #$0F,D0
                tst.b   D2                        ;1.Ziffer <> "0" bereits ausgegeben?
                beq.s   hexoutb
                tst.b   D0
                beq.s   hexoutd                   ;Führungsnullen unterdrücken
                moveq   #0,D2                     ;ab nun alle Ziffern ausgeben
hexoutb:        addi.w  #$30,D0
                cmp.b   #'9',D0
                bls.s   hexoutc                   ;Nibble in D0 nach Hexziffer
                addq.w  #7,D0
hexoutc:        jsr     @chrout(A4)               ;und Ziffer ausgeben
                moveq   #-1,D4
hexoutd:        dbra    D3,hexouta
                tst.w   D4
                bne.s   hexoute                   ;Nichts ausgeben?
                moveq   #'0',D0
                jsr     @chrout(A4)               ;Zumindest doch eine Null
hexoute:        movem.l (SP)+,D0-D4
                rts
               ;>ENDPART
********************************************************************************
* Zahl (D1) zur Zahlenbasis D2 ausgeben                                        *
********************************************************************************
               ;>PART 'numoutx'
numoutx:        movem.l D0-D4/A6,-(SP)
numout0:        movea.l SP,A6                     ;Zahlenbasiszeichen (z.b. $) vorangestellt
numout1:        bsr     div                       ;durch Zahlenbasis teilen
                move.w  D3,-(SP)                  ;BCD-Ziffer auf Stack
                tst.l   D1
                bne.s   numout1                   ;Zahl komplett auf dem Stack?
numout3:        move.w  (SP)+,D0                  ;BCD-Ziffer holen
                add.b   #'0',D0
                cmp.b   #$3A,D0
                blo.s   numout2
                addq.b  #7,D0                     ;in ASC-Ziffer oder Buchstaben wandeln
numout2:        jsr     @chrout(A4)               ;Zeichen ausgeben
                cmpa.l  SP,A6
                bne.s   numout3                   ;schon alles?
                movem.l (SP)+,D0-D4/A6
                rts
               ;>ENDPART
********************************************************************************
* Zeichenholroutinen (Systemunabh„ngig)                                        *
********************************************************************************
********************************************************************************
* Liest ein Zeichen nach D0 (šberlesen von Spaces, ...)                        *
********************************************************************************
               ;>PART 'get'
get:            moveq   #0,D0
                move.b  (A0)+,D0                  ;Zeichen holen
                beq.s   get2
                cmp.b   #':',D0                   ;Zeilentrenner
                beq.s   get3
                cmp.b   #';',D0                   ;Auch 'ne Endekennung
                beq.s   get2
                cmp.b   #' ',D0                   ;Spaces werden berlesen
                beq.s   get
                cmp.b   #'a',D0
                blo.s   get1                      ;kein Kleinbuchstabe
                cmp.b   #'z',D0
                bhi.s   get1                      ;kein Kleinbuchstabe
                and.b   #$DF,D0
get1:           tst.b   D0
                rts
get3:           move.l  A0,input_pnt(A4)          ;dort geht es weiter...
get2:           moveq   #0,D0
                subq.l  #1,A0                     ;Žndert ja keine Flags
                rts
               ;>ENDPART
********************************************************************************
* Liegt D0 im Zahlensystem D2 ?                                                *
********************************************************************************
               ;>PART 'chkval'
chkval:         sub.b   #'0',D0                   ;prüft d0 auf Gültigkeit im Zahlensystem d2
                cmp.b   #10,D0                    ;kleiner 10?
                blo.s   chkval0                   ;ja,ok
                subq.b  #7,D0                     ;nein, 7 weg
                cmp.b   #10,D0                    ;jetzt kleiner 10?
                blo.s   chkval1                   ;ja, Fehler, Carry l”schen
chkval0:        cmp.b   D2,D0                     ;vergleichen mit Zahlenbasis
                bhs.s   chkval1
                rts
chkval1:        addi.b  #$37,D0                   ;restaurieren, da keine zahl
                move    #0,CCR
                rts
               ;>ENDPART
********************************************************************************
* Testen, ob ein Komma oder Nullbyte folgt                                     *
********************************************************************************
               ;>PART 'chkcom'
chkcom:         tst.b   D0
                beq.s   chkcom1
                cmp.b   #',',D0
                bne.s   syn_err                   ;Fehler, wenn nicht
                bsr.s   get                       ;N„chstes Zeichen holen
                move    #0,CCR                    ;Alle Bits l”schen, da Komma vorhanden
chkcom1:        rts
syn_err:        bra     synerr
               ;>ENDPART
********************************************************************************
* Zahlenbasis gem„ž des Zahlenbasiszeichens (in D0) nach D3 holen              *
********************************************************************************
               ;>PART 'numbar'
numbas:         moveq   #3,D3                     ;wenn das Zzeichen in d0 ein Zahlbasiszeichen
numbas1:        cmp.b   numtab(PC,D3.w),D0        ;ist, Rückkehr mit der Zahlenbasis in d3
                dbeq    D3,numbas1                ;sonst negative=1
                tst.w   D3
                bmi.s   numbas2
                move.b  numtab1(PC,D3.w),D3
numbas2:        rts
               DC.B 'Ý'
numtab:        DC.B '%@.'
hexbase:       DC.B '$'
numtab1:       DC.B 2,8,10,16
               EVEN
               ;>ENDPART
********************************************************************************
* Zahlenbasiszeichen gem„ž der Zahlenbasis (in D2) nach D0 holen               *
********************************************************************************
               ;>PART 'basout'
basout:         moveq   #3,D0                     ;holt zeichen für zahlbasis ($,@,...) in d0
basout1:        cmp.b   numtab1(PC,D0.w),D2       ;Space wenn keine gültige Zahlenbasis
                dbeq    D0,basout1
                move.b  numtab(PC,D0.w),D0
                rts
               ;>ENDPART
********************************************************************************
* Parameter nach A2 und A3 holen                                               *
* C=0, wenn 1.Parameter vorhanden                                              *
* V=0, wenn 2.Parameter vorhanden                                              *
********************************************************************************
               ;>PART 'get_parameter'
get_parameter:  suba.l  A2,A2                     ;holt zwei Zahlenwerte in A2 und A3
                suba.l  A3,A3                     ;wenn nicht angegeben, ist er null
                move.w  #3,-(SP)                  ;Flagbyte für kein Parameter angegeben
                bsr     get                       ;1.Zeichen holen
                beq.s   get_parameter2            ;fertig, da keine Parameter
                cmp.b   #',',D0
                beq.s   get_parameter1            ;ja
                bsr     get_term
                movea.l D1,A2                     ;1.Parameter nach A2
                andi.w  #$FE,(SP)                 ;C l”schen
                cmp.b   #',',D0                   ;Komma?
                bne.s   get_parameter2            ;nein, also kein 2.Parameter
get_parameter1: bsr     get                       ;Komma berlesen
                bsr     get_term
                movea.l D1,A3                     ;2.Parameter nach A3
                andi.w  #$FD,(SP)                 ;V l”schen
get_parameter2: move    (SP)+,CCR
                rts
               ;>ENDPART
********************************************************************************
* Parameter für Disassemble/Dump holen                                         *
* A2 - Startadresse                                                            *
* A3 - Endadresse (gültig, wenn D2=0)                                          *
* D2 - Zeilenanzahl                                                            *
********************************************************************************
               ;>PART 'get2(x)adr'
get2adr:        movea.l default_adr(A4),A2        ;Default-Startadresse
                suba.l  A3,A3                     ;Default-Endadresse
get2xadr:       move.w  def_lines(A4),D2          ;Default-Zeilenanzahl
                subq.w  #1,D2
                bsr     get                       ;1.Zeichen holen
                beq.s   get2ad0                   ;fertig, da keine Parameter
                cmp.b   #'#',D0                   ;Zeilenanzahl?
                beq.s   get2ad2
                cmp.b   #'[',D0                   ;Byteanzahl?
                beq.s   get2ad6
                cmp.b   #',',D0                   ;Endadresse?
                beq.s   get2ad1
                bsr     get_term                  ;Neue Startadresse
                movea.l D1,A2
                tst.b   D0
                beq.s   get2ad0
                cmp.b   #'[',D0                   ;Byteanzahl?
                beq.s   get2ad6
                cmp.b   #'#',D0
                beq.s   get2ad2
                cmp.b   #',',D0                   ;Jetzt muž es aber ein Komma sein!
                bne     syn_err
get2ad1:        bsr     get
                cmp.b   #'#',D0                   ;Zeilenanzahl als 2.Parameter holen?
                beq.s   get2ad2
                cmp.b   #'[',D0                   ;Byteanzahl?
                beq.s   get2ad6
                bsr     get_term                  ;Neue Endadresse holen
                movea.l D1,A3
get2ad01:       moveq   #0,D2                     ;Zeilenanzahl l”schen
get2ad0:        move.l  A2,default_adr(A4)        ;Neue Defaultadr setzen
                tst.w   D2
                beq.s   get2ad4                   ;Keine Zeilen listen?
                suba.l  A3,A3                     ;Endadresse ungültig machen
get2ad4:        rts
get2ad2:        bsr     get
                beq.s   get2ad3                   ;Wenn nichts folgt => 1 Zeile ist Default
                bsr     get_term                  ;Zeilenanzahl holen
                subq.l  #1,D1                     ;für DBRA
                move.l  D1,D2
                swap    D1
                tst.w   D1
                bne.s   get2ad5                   ;max.65535 Zeilen listen
                bra.s   get2ad0
get2ad3:        moveq   #0,D2                     ;Zeilenanzahl = 1
                move.l  A2,default_adr(A4)        ;Neue Defaultadr setzen
                suba.l  A3,A3                     ;Endadresse ungültig machen
                rts
get2ad6:        bsr     get
                beq     synerr                    ;Wenn nix folgt => Fehler
                bsr     get_term                  ;Byteanzahl holen
                cmp.b   #']',D0
                bne.s   get2ad7
                bsr     get                       ;evtl. "]" berlesen
get2ad7:        lea     0(A2,D1.l),A3             ;Endadresse berechnen
                bra.s   get2ad01
get2ad5:        bra     illequa
               ;>ENDPART
********************************************************************************
* Parameter für Find und Fill holen                                            *
********************************************************************************
               ;>PART 'get_such_para'
get_such_para:  cmp.b   #',',D0
                bne     syn_err
                moveq   #0,D3                     ;ein Byte eingegeben
                move.b  #2,find_cont0(A4)
                lea     data_buff(A4),A1
get_such_para1: bsr.s   get_such_para4
                cmp.b   #',',D0
                beq.s   get_such_para1
                tst.b   D0
                bne     syn_err
get_such_para2: move.l  A1,D3
                lea     data_buff(A4),A1
                sub.l   A1,D3
                subq.w  #1,D3                     ;L„nge-1
                rts
get_such_para3: movem.l D1-D2/D4-D7/A2-A6,-(SP)
                moveq   #0,D3                     ;ein Byte eingegeben
                lea     data_buff(A4),A1
                bsr.s   get_such_para4
                movem.l (SP)+,D1-D2/D4-D7/A2-A6
                bra.s   get_such_para2
get_such_para4: bsr     get                       ;1.Zeichen nach D0
                cmp.b   #$22,D0                   ;Anführungszeichen?
                beq.s   get_such_para11           ;ja, ASCII holen
                cmp.b   #$27,D0
                beq.s   get_such_para11           ;ja, ASCII
                cmp.b   #'!',D0
                beq.s   get_such_para10           ;ist Mnemonic
                bsr     get_term                  ;Term nach D1 holen
                cmp.b   #'.',D0
                bne.s   get_such_para9            ;Gr”že ermitteln
                bsr     get                       ;Extension holen
                move.w  D0,D2                     ;und retten
                bsr     get                       ;schon mal das Folgezeichen holen
                cmp.b   #'W',D2
                beq.s   get_such_para6
                cmp.b   #'L',D2
                beq.s   get_such_para5
                cmp.b   #'A',D2
                beq.s   get_such_para8
                cmp.b   #'B',D2
                beq.s   get_such_para7
                bra     syn_err
get_such_para5: swap    D1
                bsr.s   get_such_para6
                swap    D1
get_such_para6: ror.w   #8,D1                     ;Word
                move.b  D1,(A1)+
                ror.w   #8,D1
get_such_para7: move.b  D1,(A1)+                  ;Bytezahl
                rts
get_such_para8: addi.w  #1,D3                     ;3-Byte-Adresse
                swap    D1
                move.b  D1,(A1)+
                swap    D1
                bra.s   get_such_para6

get_such_para9: move.l  D1,D2
                swap    D2
                tst.w   D2
                bne.s   get_such_para5            ;mehr als ein Word => Long!
                swap    D2
                andi.w  #$FF00,D2
                bne.s   get_such_para6            ;Word erkannt
                bra.s   get_such_para7            ;Nur ein Byte

get_such_para10:movea.l A1,A6                     ;hier soll hinassembliert werden
                bsr     code_line                 ;und den Befehl assemblieren
                movea.l A6,A1                     ;n„chste Adresse
                rts

get_such_para11:moveq   #-1,D5                    ;Noch keine Eingabe
                moveq   #63,D4                    ;maximal 64 Zeichen ASCII sind erlaubt
                move.w  D0,D2                     ;" bzw. ' merken (String muž auch so enden)
get_such_para12:move.b  (A0)+,D0                  ;ASCII-Zeichen einlesen
                beq.s   get_such_para13           ;Zeilenende = Abbruch
                cmp.w   D2,D0                     ;Endekriterium erreicht?
                beq.s   get_such_para13           ;dann Abbruch
                moveq   #0,D5
                move.b  D0,(A1)+
                dbra    D4,get_such_para12
                bra     syn_err                   ;zu lang!
get_such_para13:tst.w   D5                        ;berhaupt was eingelesen?
                bne     syn_err                   ;nein!
                bra     get
               ;>ENDPART
********************************************************************************
* Ausdruck auswerten, Ergebnis nach D1                                         *
********************************************************************************
               ;>PART 'get_term'
get_term:       moveq   #'-',D1
                cmp.b   D0,D1                     ;'--' ist gar nichts
                bne.s   get_term2
                cmp.b   (A0),D1
                bne.s   get_term2
get_term1:      bsr     get                       ;'-' bis zum Komma berlesen (2,4 oder 8)
                beq.s   get_term0
                cmp.b   #',',D0
                bne.s   get_term1
get_term0:      rts
get_term2:      tst.b   D0
                beq     syn_err
                movem.l D2-D7/A1-A6,-(SP)
                bsr.s   get_term4
                moveq   #-1,D2
get_term3:      addq.w  #1,D2
                move.b  get_term_tab(PC,D2.w),D3
                addq.b  #1,D3                     ;Tabellenende = -1
                beq     synerr                    ;=> Falsches Formelende
                cmp.b   get_term_tab(PC,D2.w),D0  ;Formelendezeichen gefunden?
                bne.s   get_term3                 ;Nein, weiter suchen
                movem.l (SP)+,D2-D7/A1-A6
                rts
get_term_tab:  DC.B ',(.#=[]',$22,0,-1            ;Erlaubte Zeichen als Formelende
               EVEN

get_term4:      move.l  D2,-(SP)
                bsr     w_eausd
                move.l  D1,D2
get_term5:      cmp.b   #'+',D0                   ;Addition
                bne.s   get_term6
                bsr     get
                bsr.s   w_eausd
                add.l   D1,D2
                bvs.s   overflo
                bra.s   get_term5
overflo:        bra     overfl
get_term6:      cmp.b   #'-',D0                   ;Subtraktion
                bne.s   get_term7
                bsr     get
                bsr.s   w_eausd
                sub.l   D1,D2
                bvs.s   overflo
                bra.s   get_term5
get_term7:      cmp.b   #'|',D0                   ;OR
                bne.s   get_term8
                bsr     get
                bsr.s   w_eausd
                or.l    D1,D2
                bra.s   get_term5
get_term8:      cmp.b   #'^',D0                   ;EOR
                bne.s   get_term9
                bsr     get
                bsr.s   w_eausd
                eor.l   D1,D2
                bra.s   get_term5
get_term9:      cmp.b   #'<',D0                   ;SHL
                bne.s   get_term10
                cmpi.b  #'<',(A0)
                bne.s   get_term10
                addq.l  #1,A0
                bsr     get
                bsr.s   w_eausd
                lsl.l   D1,D2
                bra.s   get_term5
get_term10:     cmp.b   #'>',D0                   ;SHR
                bne.s   get_term11
                cmpi.b  #'>',(A0)
                bne.s   get_term11
                addq.l  #1,A0
                bsr     get
                bsr.s   w_eausd
                lsr.l   D1,D2
                bra.s   get_term5
get_term11:     move.l  D2,D1
                move.l  (SP)+,D2
                rts

w_eausd:        move.l  D2,-(SP)
                bsr.s   w_term
                move.l  D1,D2
w_eal:          cmp.b   #'*',D0                   ;Multiplikation
                bne.s   w_ea1
                bsr     get
                bsr.s   w_term
                bsr     lmult                     ;D2=D1*D2
                bra.s   w_eal
w_ea1:          cmp.b   #'/',D0                   ;Division
                bne.s   w_ea2
                bsr     get
                bsr.s   w_term
                bsr     ldiv                      ;D2.L = D2.L/D1.L
                bra.s   w_eal
w_ea2:          cmp.b   #'&',D0                   ;AND
                bne.s   w_ea3
                bsr     get
                bsr.s   w_term
                and.l   D1,D2
                bra.s   w_eal
w_ea3:          cmp.b   #'%',D0                   ;MODULO
                bne.s   w_eaend
                bsr     get
                bsr.s   w_term
                bsr     ldiv                      ;D1.L = D2 MOD D1
                move.l  D1,D2
                bra.s   w_eal
w_eaend:        move.l  D2,D1
                move.l  (SP)+,D2
                rts

w_term:         cmp.b   #'!',D0                   ;Logical NOT
                bne.s   w_term0
                bsr     get
                bsr.s   w_term0
                tst.l   D1
                beq.s   w_term4
                moveq   #0,D1
                rts
w_term4:        moveq   #1,D1
                rts
w_term0:        cmp.b   #'~',D0                   ;NOT
                bne.s   w_term1
                bsr     get
                bsr.s   w_term1
                not.l   D1
                rts
w_term1:        cmp.b   #'-',D0
                beq.s   w_term3
                cmp.b   #'+',D0
                bne.s   w_term2
                bsr     get                       ;Positives Vorzeichen berlesen
w_term2:        bsr.s   w_fakt
                rts
w_term3:        bsr     get                       ;Negatives Vorzeichen
                bsr.s   w_fakt
                neg.l   D1
                rts

w_fakt:         move.l  D2,-(SP)
                cmp.b   #'(',D0
                beq.s   w_fakt1
                cmp.b   #'{',D0
                beq.s   w_fakt2
                bsr     get_zahl                  ;Zahl nach D1 holen
                move.l  (SP)+,D2
                rts
w_fakt1:        bsr     get                       ;Klammer berlesen
                bsr     get_term4                 ;Ausdruck in der Klammer auswerten
                cmp.b   #')',D0
                bne.s   mistbra                   ;Klammer zu muž folgen
                bsr     get
                move.l  (SP)+,D2
                rts
mistbra:        bra     misbrak
w_fakt2:        bsr     get
                bsr     get_term4
                cmp.b   #'}',D0                   ;indirekt
                bne.s   mistbra
                bsr     get
                moveq   #0,D2                     ;Word ist Default
                cmp.b   #'.',D0                   ;Breite angegeben?
                bne.s   w_fakt4                   ;Nein! => Word
                bsr     get
                move.b  D0,D3
                bsr     get
                moveq   #-1,D2                    ;Long
                cmp.b   #'L',D3
                beq.s   w_fakt4
                moveq   #0,D2                     ;Word
                cmp.b   #'W',D3
                beq.s   w_fakt4
                moveq   #1,D2                     ;Byte
                cmp.b   #'B',D3
                bne     synerr                    ;dat war nix!
w_fakt4:        movea.l $08.w,A1
                movea.l $0C.w,A2
                lea     w_fakt3(PC),A3
                move.l  A3,$08.w                  ;Busfehler abfangen
                move.l  A3,$0C.w                  ;Adressfehler abfangen
                movea.l D1,A3
                moveq   #0,D1
                tst.b   D2
                bmi.s   w_fakt5                   ;Long
                beq.s   w_fakt7                   ;Word
                move.b  (A3),D1                   ;Byte
                bra.s   w_fakt6
w_fakt7:        move.w  (A3),D1                   ;Word holen
                bra.s   w_fakt6
w_fakt5:        move.l  (A3),D1                   ;Long holen
w_fakt6:        move.l  A1,8.w
                move.l  A2,$0C.w
                move.l  (SP)+,D2
                rts
w_fakt3:        move.l  A1,$08.w
                move.l  A2,$0C.w
                bra     illequa                   ;B„h, ein Fehler
               ;>ENDPART
********************************************************************************
* Zahl nach D1.L holen                                                         *
********************************************************************************
               ;>PART 'get_zahl'
get_zahl:       movem.l D2-D7/A1-A6,-(SP)
                move.w  D0,D2                     ;aktuelles 1.Zeichen merken
                lea     vartab(PC),A1
                lea     w_legalc(PC),A3
                movea.l A0,A2                     ;Zeiger auf evtl.Variable oder Zahl merken
w_zahl0:        moveq   #-1,D1
                move.w  D2,D0                     ;1.Zeichen zurückholen
                tst.b   (A1)                      ;Ende der Tabelle erreicht?
                bmi     w_zahlh                   ;es muž eine normale Zahl sein
w_zahl1:        addq.w  #1,D1
                cmpi.b  #' ',0(A1,D1.w)           ;Eintrag gefunden?
                beq.s   w_zahl3                   ;Ja!
                tst.b   0(A1,D1.w)
                beq.s   w_zahl3                   ;Eintrag ebenfalls gefunden
                tst.w   D1                        ;1.Zeichen des Labels
                beq.s   w_zah10                   ;da ist noch alles erlaubt
                ext.w   D0
                bmi.s   w_zahl1                   ;Zeichen >127 sind nicht erlaubt
                tst.b   0(A3,D0.w)                ;Zeichen noch erlaubt?
                bne.s   w_zah11                   ;Nein! => Abbruch, da ungleich
w_zah10:        cmp.b   0(A1,D1.w),D0             ;Immer noch gleich?
w_zah11:        move    SR,D3
                bsr     get                       ;schon mal das n„chste Zeichen holen
                move.w  D0,D4                     ;Retten, falls es das letzte Zeichen war
                move    D3,CCR
                beq.s   w_zahl1                   ;wenn gleich, n„chstes Zeichen testen
                lea     16(A1),A1                 ;Zeiger auf die n„chste Variable
                movea.l A2,A0                     ;Zeiger zurück
                bra.s   w_zahl0                   ;Weiter suchen

w_zahl3:        moveq   #0,D1
                move.w  8(A1),D0                  ;Art der Variable
                move.w  10(A1),D1                 ;šbergabeparameter
                movea.l 12(A1),A1                 ;Pointer/Wert der Variablen
                adda.l  A4,A1
                tst.w   D0
                beq.s   w_zahl6                   ;Direkter Wert (auch bei direkten Werten!)
                cmp.w   #2,D0
                blo.s   w_zahl5                   ;Pointer auf den Wert
                beq.s   w_zahl7                   ;Zeiger auf Pointer (+Offset)
                cmp.w   #4,D0
                beq.s   w_zahl8                   ;Pointer auf Word
                suba.l  A4,A1                     ;-Varbase, absolute Adresse
                move.w  D4,D0                     ;Das letzte Zeichen zurückholen
                jsr     (A1)                      ;Routine ermittelt den Variablenwert
                bra.s   w_zahla
w_zahl5:        move.l  0(A1,D1.w),D1             ;Zeiger auf Long
                bra.s   w_zahl9
w_zahl6:        move.l  A1,D1                     ;Direkter Variablenwert
                bra.s   w_zahl9
w_zahl7:        move.w  D1,D2
                move.l  (A1),D1                   ;Pointer holen
                beq.s   w_zahl9
                movea.l D1,A1
                move.l  0(A1,D2.w),D1             ;Variablenwert holen
                bra.s   w_zahl9
w_zahl8:        move.w  0(A1,D1.w),D1             ;Pointer auf Word
w_zahl9:        move.w  D4,D0                     ;Letztes Zeichen zurückholen
w_zahla:        movem.l (SP)+,D2-D7/A1-A6
                move    #0,CCR                    ;alle Flags null, da keine Leereingabe
                rts
w_zahlb:        lea     regs+32(A4),A1
                moveq   #8,D2
                bsr     chkval
                bcc     syn_err
                cmp.w   #7,D0
                bne.s   w_zahlg                   ;A7 = Stackpointer holen
                bsr     get                       ;N„chstes Zeichen schon mal holen
w_zahlc:        btst    #5,_sr(A4)                ;Supervisor-Mode?
                bne.s   w_zahld
                move.l  _usp(A4),D1
                rts
w_zahlbk:       bsr     get_term4                 ;Breakpointnummer holen (rekursiv!)
                tst.l   D1
                bmi.s   ill_brk
                cmp.l   #15,D1
                bhi.s   ill_brk
                lea     breakpnt(A4),A1
                mulu    #12,D1                    ;mal 12 als Index in die Tabelle
                move.l  0(A1,D1.w),D1             ;Adresse des Breakpoints holen
                beq.s   ill_brk
                rts
ill_brk:        bra     illbkpt
w_zahld:        move.l  _ssp(A4),D1
                rts
w_zahle:        moveq   #0,D1
                move.w  _sr(A4),D1                ;SR holen
                andi.w  #$FF,D1                   ;Für's CCR nur die unteren 8 Bits
                rts
w_zahlf:        lea     regs(A4),A1
                moveq   #8,D2
                bsr     chkval
                bcc     syn_err
w_zahlg:        cmp.w   #8,D0                     ;Register>7 ?
                bcc     syn_err
                lsl.w   #2,D0
                move.l  0(A1,D0.w),D1             ;Register holen
                bra     get                       ;N„chstes Zeichen holen & Ende

w_zahlme:       moveq   #10,D2
                bsr     chkval
                bcc     syn_err
                subq.w  #1,D0
                bpl.s   w_zahlmx
                moveq   #9,D0
w_zahlmx:       lea     simple_vars(A4),A1
                asl.w   #2,D0
                move.l  0(A1,D0.w),D1             ;Register holen
                bra     get                       ;N„chstes Zeichen holen & Ende

w_zahlsy:       moveq   #14,D1
                move.l  sym_size(A4),D2
                bra     ldiv                      ;ein Eintrag ist 14 Bytes lang
w_zahlcache:    moveq   #0,D1
                tst.b   prozessor(A4)             ;68000 oder 68010?
                ble.s   w_zahlcachee              ;dann raus hier
               DC.W $4E7A,$1002                   ;CACR holen
w_zahlcachee:   bra     get

w_zahlh:        moveq   #0,D0
                move.b  D2,D0                     ;1.Zeichen zurückholen
                movea.l A2,A0                     ;Zeiger zurück auf die Zahl
                cmp.b   #$27,D0                   ;ASCII-String?
                beq.s   w_zahll
                cmp.b   #$22,D0                   ;ASCII-String?
                beq.s   w_zahll
                moveq   #$10,D2                   ;Hexadezimal ist Default
                bsr     numbas                    ;?Zahlenbasiszeichen
                bmi.s   w_zahli                   ;nein
                move.w  D3,D2                     ;ja, neue Zahlenbasis setzen
                bsr     get                       ;und n„chstes Zeichen
w_zahli:        bsr     chkval                    ;lfd. zeichen gültig?
                bcc.s   w_zahlo                   ;nein, Fehler (evtl. Label?)
                moveq   #0,D1                     ;Vorbesetzung von D1
w_zahlj:        move.l  D1,D3                     ;D1.L * D2.B = D1.L
                swap    D3
                mulu    D2,D3
                mulu    D2,D1
                swap    D3
                tst.w   D3
                bne     overfl
                add.l   D3,D1
                bcs     overfl
                add.l   D0,D1                     ;und addieren der Stelle
                bcs     overfl
                bsr     get                       ;n„chste Stelle
                bsr     chkval                    ;gültig?
                bcs.s   w_zahlj                   ;ja, weiter
w_zahlk:        movem.l (SP)+,D2-D7/A1-A6
                move    #0,CCR                    ;alle Flags null, da keine Leereingabe
                rts
w_zahll:        moveq   #0,D1
w_zahlm:        cmp.b   (A0)+,D0                  ;Zeichen gleich dem Anfangszeichen ' oder ` ?
                beq.s   w_zahln                   ;ja, fertig
                rol.l   #8,D1                     ;Ergebnisregister 8 bit nach links shiften
                tst.b   D1                        ;waren die h”chsten 8bit schon belegt?
                bne     illequa                   ;ja, mehr als 4 byte ASCII, Error
                move.b  -1(A0),D1
                beq.s   w_zahlz                   ;null, Ende der Datei
                cmp.b   #13,D1                    ;CR beendet ASCII
                bne.s   w_zahlm
w_zahlz:        subq.l  #1,A0                     ;wieder eins abziehen,damit GET 0 bzw. CR holt
                lsr.l   #8,D1
w_zahln:        bsr     get
                bra.s   w_zahlk                   ;alles OK, Ende

w_zahlo:        cmp.w   #10,D2
                bne     illequa                   ;.Label => Dezimalsystem
;Symboltabelle des nachgeladenen Programms durchsuchen
                lea     w_legalc(PC),A5
                movea.l A0,A3
                subq.l  #1,A3                     ;Pointer auf 1.Zeichen des Labels
                tst.l   sym_size(A4)
                beq.s   w__zahl                   ;keine Symboltabelle => interne durchsuchen
                movea.l A3,A2
                movea.l sym_adr(A4),A1            ;Anfangsadresse der Symboltabelle
                moveq   #0,D7
                moveq   #0,D1
w_zahlp:        movea.l (A1),A6                   ;Zeiger auf das Label
w_zahlq:        move.b  (A2)+,D1                  ;Zeichen der Eingabe holen
                bmi.s   w_zahlx                   ;Zeichen >127 sind stets erlaubt
                tst.b   0(A5,D1.w)                ;Ist das Zeichen im Label erlaubt?
                bne.s   w_zahlr                   ;Nein => gefunden
w_zahlx:        cmp.b   (A6)+,D1                  ;Pažt der Kram berhaupt noch?
                beq.s   w_zahlq                   ;Weiter, wenn ja!
w_zahqq:        movea.l A3,A2                     ;Pointer zurück
                lea     14(A1),A1                 ;n„chstes Label
                cmpa.l  sym_end(A4),A1
                blo.s   w_zahlp                   ;Ende erreicht? Nein!
                bra.s   w__zahl                   ;eigene Symboltabelle durchsuchen
w_zahlr:        tst.b   (A6)                      ;Label noch nicht zuende
                bne.s   w_zahqq                   ;das n„chste Label testen
                lea     -1(A2),A0                 ;Zeiger auf das erste Folgezeichen
                bsr     get                       ;das Folgezeichen holen
                move.l  10(A1),D1                 ;Wert des Labels holen
                bra.s   w_zahlk                   ;das war's schon

;Interne Symboltabelle durchsuchen
w__zahl:        movea.l A3,A2
                move.l  sym_buffer(A4),D0         ;Symboltabelle geladen?
                beq     illequa                   ;Fehler, falls keine Symboltabelle
                movea.l D0,A1
                moveq   #0,D7
                moveq   #0,D1
                move.w  sym_anzahl(A4),D0
                bra.s   w__zahll
w__zahlp:       lea     8(A1),A6                  ;Zeiger auf das Label
w__zahlq:       move.b  (A2)+,D1                  ;Zeichen der Eingabe holen
                bmi.s   w__zahlx                  ;Zeichen >127 sind stets erlaubt
                tst.b   0(A5,D1.w)                ;Ist das Zeichen im Label erlaubt?
                bne.s   w__zahlr                  ;Nein => gefunden
w__zahlx:       cmp.b   (A6)+,D1                  ;Pažt der Kram berhaupt noch?
                beq.s   w__zahlq                  ;Weiter, wenn ja!
w__zahqq:       movea.l A3,A2                     ;Pointer zurück
                lea     32(A1),A1                 ;n„chstes Symbol
w__zahll:       dbra    D0,w__zahlp               ;alle Symbole durch? Nein =>
                bra     illlabel                  ;Symbol nicht gefunden
w__zahlr:       tst.b   (A6)                      ;Symbol noch nicht zuende
                bne.s   w__zahqq                  ;das n„chste Symbol testen
                lea     -1(A2),A0                 ;Zeiger auf das erste Folgezeichen
                bsr     get                       ;das Folgezeichen holen
                move.l  (A1),D1                   ;Wert des Symbols holen
                bra     w_zahlk                   ;das war's schon

w_legalc:      DC.B 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
               DC.B 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
               DC.B 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
               DC.B 0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1
               DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0
               DC.B 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1

;>               DXSET 8,' '
vartab:        DC.B 'SYMFLAG '
               DC.W 4,0
               DC.L bugaboo_sym
               DC.B 'USERSCR '
               DC.W 0,0
               DC.L user_scr
               DC.B 'INITSCR '
               DC.W 0,0
               DC.L user_scr
               DC.B 'RING    '
               DC.W 4,0
               DC.L ring_flag
               DC.B 'SWITCH  '
               DC.W 4,0
               DC.L smart_switch
               DC.B 'SYMTAB  '
               DC.W 1,0
               DC.L sym_buffer
               DC.B 'TRACE   '
               DC.W 4,0
               DC.L trace_flag
               DC.B 'TDELAY  '
               DC.W 4,0
               DC.L trace_delay
               DC.B 'MIDI    '
               DC.W 4,0
               DC.L midi_flag
               DC.B 'OVERSCAN'
               DC.W 4,0
               DC.L overscan
               DC.B 'CACHE   '
               DC.W 3,0
               DC.L w_zahlcache
               DC.B 'SHIFT   '
               DC.W 4,0
               DC.L shift_flag
               DC.B 'MEMCHECK'
               DC.W 4,0
               DC.L all_memory
               DC.B 'CONVERT '
               DC.W 0,0
               DC.L convert_tab
               DC.B 'ACT_PD  '
               DC.W 2,0
               DC.L act_pd
               DC.B 'CLICK   '
               DC.W 4,0
               DC.L format_flag
               DC.B 'KLICK   '
               DC.W 4,0
               DC.L format_flag
               DC.B 'IKBD    '
               DC.W 0,0
               DC.L ikbd_string
               DC.B 'SCROLLD '
               DC.W 4,0
               DC.L scroll_d
               DC.B 'UTRACE  '
               DC.W 0,0
               DC.L user_trace_buf
               DC.B 'UT      '
               DC.W 0,0
               DC.L user_trace_buf
               DC.B 'COL0    '
               DC.W 4,0
               DC.L col0
               DC.B 'CONTERM '
               DC.W 4,0
               DC.L conterm
               DC.B 'AESFLAG '
               DC.W 4,0
               DC.L no_aes_check
               DC.B 'COL1    '
               DC.W 4,0
               DC.L col1
               DC.B 'CHECKSUM'
               DC.W 4,0
               DC.L checksum
               DC.B 'SMALL   '
               DC.W 4,0
               DC.L small
               DC.B 'SIZE    '
               DC.W 4,0
               DC.L def_size
               DC.B 'LINES   '
               DC.W 4,0
               DC.L def_lines
               DC.B 'TEXT    '
               DC.W 2,8
               DC.L basep
               DC.B 'DATA    '
               DC.W 2,16
               DC.L basep
               DC.B 'BSS     '
               DC.W 2,24
               DC.L basep
               DC.B 'MEMBASE '
               DC.W 1,0
               DC.L first_free
               DC.B 'START   '
               DC.W 1,0
               DC.L merk_anf
               DC.B 'SAVEAREA'
               DC.W 0,0
               DC.L default_stk
               DC.B 'END     '
               DC.W 1,0
               DC.L merk_end
               DC.B 'BASEPAGE'
               DC.W 1,0
               DC.L basep
               DC.B 'BP      '
               DC.W 1,0
               DC.L basep
               DC.B 'PC      '
               DC.W 1,0
               DC.L _pc
               DC.B 'USP     '
               DC.W 1,0
               DC.L _usp
               DC.B 'SP      '
               DC.W 3,0
               DC.L w_zahlc
               DC.B 'SYMBOLS '
               DC.W 3,0
               DC.L w_zahlsy
               DC.B 'SSP     '
               DC.W 1,0
               DC.L _ssp
               DC.B 'SR      '
               DC.W 4,0
               DC.L _sr
               DC.B 'CCR     '
               DC.W 3,0
               DC.L w_zahle
               DC.B '*       '
               DC.W 1,0
               DC.L default_adr
               DC.B '^D      '
               DC.W 3,0
               DC.L w_zahlf
               DC.B '^A      '
               DC.W 3,0
               DC.L w_zahlb
               DC.B '^M      '
               DC.W 3,0
               DC.L w_zahlme
               DC.B '^B      '
               DC.W 3,0
               DC.L w_zahlbk
               DC.B 'DISBASE '
               DC.W 4,0
               DC.L disbase
               DC.B 'BUFFER  '
               DC.W 1,0
               DC.L dsk_adr
               DC.B 'SEKBUFF '
               DC.W 0,0
               DC.L sekbuff
               DC.B 'TRKBUFF '
               DC.W 0,0
               DC.L first_free
               DC.B 'TRACK   '
               DC.W 4,0
               DC.L dsk_track
               DC.B 'SEKTOR  '
               DC.W 4,0
               DC.L dsk_sektor
               DC.B 'SECTOR  '
               DC.W 4,0
               DC.L dsk_sektor
               DC.B 'SIDE    '
               DC.W 4,0
               DC.L dsk_side
               DC.B 'DRIVE   '
               DC.W 4,0
               DC.L dsk_drive
               DC.B 'S       '
               DC.W 0,0
               DC.L default_stk
               DC.B -1
               EVEN
               ;>ENDPART
********************************************************************************
* Filenamen nach fname holen (Pfad & Laufwerk setzen)                          *
********************************************************************************
               ;>PART 'getnam'
getnam:         bsr     get                       ;Zeichen nach D0 holen
getnam_cont:    cmp.b   #'"',D0                   ;ein gültiger Pfad/Filename?
                bne     synerr                    ;Nein! =>
                lea     fname(A4),A1              ;Platz für den Namen
getnam1:        move.b  (A0)+,D0
                beq     synerr                    ;Anführungszeichen fehlen!
                cmp.b   #'"',D0                   ;Ende des Filenamens/Pfades?
                beq.s   getnam3                   ;Ja! =>
                cmp.b   #'a',D0
                blo.s   getnam2                   ;kein Kleinbuchstabe
                cmp.b   #'z',D0
                bhi.s   getnam2                   ;kein Kleinbuchstabe
                and.b   #$DF,D0                   ;in Grožbuchstaben wandeln
getnam2:        move.b  D0,(A1)+
                bra.s   getnam1
getnam3:        movea.l A0,A3                     ;Zeiger auf folgendes Zeichen
                clr.b   (A1)                      ;Pfad/Filename mit Nullbyte abschlieáen
                lea     fname(A4),A0
                cmpi.b  #':',1(A0)                ;Laufwerkskennung?
                bne.s   getnam5                   ;Nein! =>
                moveq   #0,D0
                move.b  (A0),D0                   ;Laufwerksbuchstaben holen
                cmp.w   #'P',D0
                bhi     illdrv
                sub.w   #'A',D0                   ;Laufwerksoffset abziehen
                bmi     illdrv
                move.l  A0,-(SP)
                move.w  D0,-(SP)
                move.w  #$0E,-(SP)                ;Dsetdrv()
                tst.l   basep(A4)                 ;Andere Programm geladen?
                beq.s   getnam4                   ;Nein
                trap    #1                        ;Pfad für's andere Programm setzen
getnam4:        jsr     do_trap_1                 ;Pfad für den Debugger setzen
                addq.l  #4,SP
                movea.l (SP)+,A0
                addq.l  #2,A0                     ;Zeiger hinter die Laufwerkskennung
getnam5:        movea.l A0,A2
                movea.l A0,A1
getnam6:        tst.b   (A0)
                beq.s   getnam7
                cmpi.b  #'\',(A0)+
                bne.s   getnam6                   ;Pfad?
                movea.l A0,A1                     ;evtl.Anfang des Filenamen merken
                bra.s   getnam6
getnam7:        cmpa.l  A0,A2
                beq.s   getnam9                   ;nur Laufwerksbezeichnung angegeben
                cmpi.b  #'.',(A1)                 ;Filename: "."?
                bne.s   getnam71
                addq.l  #1,A1
                cmpi.b  #'.',(A1)                 ;Filename: ".."?
                bne.s   getnam71
                addq.l  #1,A1
getnam71:       cmpa.l  A1,A2
                beq.s   getnam9                   ;Kein Pfad angegeben
                move.b  (A1),D7                   ;1.Zeichen des Filenamens retten
                clr.b   (A1)                      ;Pfad mit Nullbyte terminieren
                bsr.s   do_mediach                ;Media-Change ausl”sen
                move.l  A2,-(SP)
                move.w  #$3B,-(SP)                ;Dsetpath()
                tst.l   basep(A4)                 ;Andere Programm geladen?
                beq.s   getnam8                   ;Nein
                trap    #1                        ;Pfad für's andere Programm setzen
getnam8:        jsr     do_trap_1                 ;Pfad für den Debugger setzen
                addq.l  #6,SP
                tst.w   D0
                bmi     toserr
                move.b  D7,(A1)
getnam9:        lea     fname(A4),A0
                movea.l A0,A2                     ;Zeiger auf den Filenamen zurückgeben
getnam10:       move.b  (A1)+,(A0)+               ;Filenamen nach vorne kopieren
                bne.s   getnam10
                clr.b   (A0)                      ;Noch ein Nullbyte dran
                tst.b   (A2)                      ;kein Filenamen angegeben? Flag setzen
                movea.l A3,A0
                rts
               ;>ENDPART
********************************************************************************
* Media-Change auf dem aktuellen Laufwerk n”tig? Dann ausführen                *
********************************************************************************
               ;>PART 'do_mediach'
do_mediach:     movem.l D0-D2/A0-A2,-(SP)
                move.w  #$19,-(SP)
                jsr     do_trap_1                 ;Dgetdrv()
                addq.l  #2,SP
                move.w  D0,a_mediach_drv
                move.w  D0,-(SP)                  ;Laufwerk D0
                addq.w  #1,D0
                move.w  D0,-(SP)                  ;Laufwerk D0+1
                pea     a_mediach_buf(PC)
                move.w  #$47,-(SP)
                jsr     do_trap_1                 ;Dgetpath()
                addq.l  #8,SP
                lea     a_mediach_buf(PC),A0
do_mediach00:   tst.b   (A0)+                     ;Ende des Pfades suchen
                bne.s   do_mediach00
                clr.b   (A0)
                move.b  #'\',-(A0)                ;und den Pfad abschlieáen
                clr.w   -(SP)                     ;Sektor 0 lesen
                move.w  #1,-(SP)                  ;einen Sektor
                move.l  A4,-(SP)
                addi.l  #allg_buffer,(SP)         ;Bufferadresse
                clr.w   -(SP)                     ;Lesen mit Media-Test
                move.w  #4,-(SP)                  ;Rwabs()
                trap    #13
                lea     14(SP),SP
                move.w  a_mediach_drv(PC),D1      ;das Laufwerk zurückholen
                tst.l   D0                        ;ein Fehler?
                bmi.s   do_mediach1               ;Ja! => Sofort einen Media-Change
                movea.l #allg_buffer,A0
                adda.l  A4,A0
                move.l  8(A0),D0                  ;die Seriennummer des Bootsektors
                lsl.w   #2,D1                     ;Laufwerk mal 4
                movea.l #drv_table,A0
                adda.l  A4,A0
                cmp.l   0(A0,D1.w),D0             ;Seriennummer noch gleich?
                beq.s   do_mediach3               ;Ja! => kein Media-Change => raus
                move.l  D0,0(A0,D1.w)             ;neue Seriennummer merken
                lsr.w   #2,D1                     ;Laufwerkno wieder restaurieren
do_mediach1:    add.b   #'A',D1
                move.b  D1,do_mediach10
                move.l  $0472.w,a_mediach_bpb
                move.l  $047E.w,a_mediach_med
                move.l  $0476.w,a_mediach_rw
                move.l  #do_mediach4,$0472.w
                move.l  #do_mediach6,$047E.w
                move.l  #do_mediach8,$0476.w
                clr.w   -(SP)
                pea     do_mediach10(PC)
                move.w  #$3D,-(SP)
                trap    #1                        ;Fopen()
                addq.w  #8,SP
                tst.l   D0
                bmi.s   do_mediach2
                move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.w  #4,SP
do_mediach2:    cmpi.l  #do_mediach4,$0472.w
                bne.s   do_mediach3
                move.l  a_mediach_bpb(PC),$0472.w
                move.l  a_mediach_med(PC),$047E.w
                move.l  a_mediach_rw(PC),$0476.w
do_mediach3:    move.w  #$19,-(SP)
                jsr     do_trap_1                 ;Dgetdrv()
                addq.l  #2,SP
                move.w  D0,-(SP)                  ;Laufwerk retten
                move.w  a_mediach_drv(PC),-(SP)
                move.w  #$0E,-(SP)
                jsr     do_trap_1                 ;Dsetdrv(Changedrive)
                addq.l  #4,SP
                pea     a_mediach_buf(PC)
                move.w  #$3B,-(SP)
                jsr     do_trap_1                 ;Dsetpath(OldPath)
                addq.l  #6,SP
                move.w  #$0E,-(SP)
                jsr     do_trap_1                 ;Dsetdrv(OldAktDrive)
                addq.l  #4,SP
                movem.l (SP)+,D0-D2/A0-A2
                rts

do_mediach4:    move.w  a_mediach_drv(PC),D0
                cmp.w   4(SP),D0
                bne.s   do_mediach5
                move.l  a_mediach_bpb(PC),$0472.w
                move.l  a_mediach_med(PC),$047E.w
                move.l  a_mediach_rw(PC),$0476.w
do_mediach5:    movea.l a_mediach_bpb(PC),A0
                jmp     (A0)

do_mediach6:    move.w  a_mediach_drv(PC),D0
                cmp.w   4(SP),D0
                bne.s   do_mediach7
                moveq   #2,D0
                rts
do_mediach7:    movea.l a_mediach_med(PC),A0
                jmp     (A0)

do_mediach8:    move.w  a_mediach_drv(PC),D0
                cmp.w   14(SP),D0
                bne.s   do_mediach9
                moveq   #-14,D0
                rts
do_mediach9:    movea.l a_mediach_rw(PC),A0
                jmp     (A0)

do_mediach10:  DC.B 'x:\X',0
               EVEN
a_mediach_drv: DS.W 1
a_mediach_bpb: DS.L 1
a_mediach_med: DS.L 1
a_mediach_rw:  DS.L 1
a_mediach_buf: DS.B 128
               ;>ENDPART
********************************************************************************
* Extension eines Befehls (L„ngenangabe) nach D3 holen.                        *
********************************************************************************
               ;>PART 'get_extension'
get_extension:  cmp.b   #'.',D0
                bne.s   get_ex2                   ;keine L„ngenangabe
                cmpi.b  #' ',-2(A0)               ;wenn Space vor dem Dezimalpunkt,dann Label
                beq.s   get_ex2                   ;nix gut, keine L„ngenangabe
                movem.l D0/A0,-(SP)
                bsr     get                       ;Befehlsl„nge einlesen
                moveq   #3,D3
get_ex1:        cmp.b   ext_tab(PC,D3.w),D0
                beq.s   get_ex3                   ;gefunden
                dbra    D3,get_ex1
                movem.l (SP)+,D0/A0               ;war eine Dezimalzahl, pointer zurück
get_ex2:        moveq   #0,D3                     ;Byte für Mem.x als Default
                move    #$FF,CCR                  ;alle Flags eins
                rts
get_ex3:        addq.l  #8,SP
                bsr     get                       ;n„chstes Zeichen holen
                move    #0,CCR                    ;CCR auf null setzen, da gefunden
                rts

ext_tab:       DC.B 'BW L'                        ;Byte/Word/Long (Space ist nicht erlaubt)
               ;>ENDPART
********************************************************************************
* Rechenroutinen                                                               *
********************************************************************************
********************************************************************************
* Div-Long D1.L/D2.B -> D1.L  Rest nach D3.W                                   *
********************************************************************************
               ;>PART 'div'
div:            move.l  D1,D3                     ;div dividiert d1.l durch d2.b nach d1.l
                ext.w   D2                        ;rest in d3, d2 unver„ndert
                clr.w   D3
                swap    D3
                divu    D2,D3
                move.l  D4,-(SP)
                move.w  D3,D4
                move.w  D1,D3
                divu    D2,D3
                swap    D4
                move.w  D3,D4
                swap    D3
                move.l  D4,D1
                move.l  (SP)+,D4
                rts
               ;>ENDPART
*******************************************************************************
* LONG-Division      : D2=D2/D1  D1=D2 MOD D1                                 *
*******************************************************************************
               ;>PART 'ldiv'
ldiv:           movem.l D0/D3-D4,-(SP)
                tst.l   D1
                beq     illequa
                exg     D1,D2
                clr.w   D4
                tst.l   D1
                bge.s   ldiv1
                addq.w  #3,D4
                neg.l   D1
ldiv1:          tst.l   D2
                bge.s   ldiv2
                addq.w  #1,D4
                neg.l   D2
ldiv2:          moveq   #1,D3
ldiv4:          cmp.l   D1,D2
                bhs.s   ldiv3
                add.l   D2,D2
                add.l   D3,D3
                bra.s   ldiv4
ldiv3:          moveq   #0,D0
ldiv6:          cmp.l   D1,D2
                bhi.s   ldiv5
                or.l    D3,D0
                sub.l   D2,D1
ldiv5:          lsr.l   #1,D2
                lsr.l   #1,D3
                bhs.s   ldiv6
                cmp.w   #3,D4
                blt.s   ldiv7
                neg.l   D1
ldiv7:          lsr.l   #1,D4
                bcc.s   ldiv8
                neg.l   D0
ldiv8:          move.l  D0,D2
                movem.l (SP)+,D0/D3-D4
                rts
               ;>ENDPART
********************************************************************************
* Long-Mult D2.L*D1.L -> D2.L                                                  *
********************************************************************************
               ;>PART 'lmult'
lmult:          movem.l D0-D1/D4-D5,-(SP)
                moveq   #0,D0
                tst.l   D1                        ;Multiplikatior stets positiv
                bpl.s   lmult1
                addq.b  #1,D0
                neg.l   D1
lmult1:         tst.l   D2                        ;Multiplikant stets positiv
                bpl.s   lmult2
                addq.b  #1,D0
                neg.l   D2
lmult2:         move.l  D2,D4                     ;1.Faktor merken
                mulu    D1,D2                     ;low-words multiplizieren
                move.l  D4,D5                     ;1.Faktor nochmal merken
                swap    D4                        ;high des 2.Faktors
                mulu    D1,D4
                swap    D4                        ;Ergebnis umdrehen
                tst.w   D4                        ;h”heres Word testen
                bne     overfl
                add.l   D4,D2                     ;und aufaddieren
                bcs     overfl
                move.l  D5,D4                     ;1.Faktor reproduzieren
                swap    D1
                mulu    D1,D4                     ;h-word d3 mal l-word d1
                swap    D4                        ;Ergebnis swappen (wie oben)
                tst.w   D4                        ;wieder h”heres Word testen
                bne     overfl
                add.l   D4,D2                     ;wieder aufaddieren
                bcs     overfl
                swap    D5                        ;2.Faktor h-word nach unten
                mulu    D1,D5                     ;h-words multiplizieren
                bne     overfl                    ;nicht null, erg. > $ffffffff
                btst    #0,D0
                beq.s   lmult3
                neg.l   D2
lmult3:         movem.l (SP)+,D0-D1/D4-D5
                rts
               ;>ENDPART
********************************************************************************
* Fehlermeldung ausgeben                                                       *
********************************************************************************
               ;>PART 'Fehler ausgeben'
dskfull:        tst.l   D0                        ;allgemeine Fehlermeldung?
                bmi.s   toserr
                moveq   #-117,D0                  ;Disk full
                bra.s   toserr
illdrv:         moveq   #-46,D0                   ;Illegales Laufwerk
                bra.s   toserr
timeouterr:     moveq   #-11,D0                   ;Read-Fault
                bra.s   toserr
seekerr:        moveq   #-6,D0                    ;Seek-Error
                bra.s   toserr
ioerr:          move.w  D0,-(SP)
                cmpi.w  #-17,(SP)                 ;Bei Hardwarefehlern
                bhs.s   ioerr3                    ;das File NICHT schliežen
                tst.w   _fhdle(A4)
                blo.s   ioerr3
                move.w  _fhdle(A4),-(SP)
                move.w  #$3E,-(SP)
                jsr     do_trap_1                 ;Fclose()
                addq.l  #4,SP
                bsr     do_mediach                ;Media-Change ausl”sen
ioerr3:         move.w  (SP)+,D0
toserr:         ext.w   D0
                ext.l   D0
                move.l  D0,D1
                clr.w   $043E.w                   ;Floppy-VBL wieder freigeben
                lea     terrtxt(PC),A0
                bra.s   toserr1
toserr2:        tst.b   (A0)+                     ;Fehlertext berlesen
                bne.s   toserr2
toserr1:        tst.b   (A0)
                beq.s   toserr3                   ;Fehler nicht gefunden (Ende der Tabelle)
                cmp.b   (A0),D0
                bne.s   toserr2                   ;auf zum n„chsten Fehler
toserr3:        addq.l  #1,A0                     ;Zeiger auf den Fehlertext
                tst.w   spalte(A4)
                beq.s   toserr31
                jsr     crout
toserr31:       clr.b   device(A4)                ;Druckerausgabe aus
                move.l  A0,-(SP)                  ;und merken
                moveq   #'-',D0
                jsr     @chrout(A4)
                neg.l   D1
                moveq   #10,D2                    ;Dezimalsystem
                bsr     numoutx                   ;Fehlernummer ausgeben
                jsr     @space(A4)
                moveq   #':',D0
                jsr     @chrout(A4)
                jsr     @space(A4)
                jsr     @print_line(A4)
                bra.s   err1                      ;Fehler beim Filezugriff
batch_mode_err: lea     batch_errtxt(PC),A0
                bra.s   err
illbkpt:        lea     ill_bkpt(PC),A0
                bra.s   err
prn_err:        lea     prn_e(PC),A0
                bra.s   err
overfl:         lea     errtab(PC),A0
                bra.s   err
synerr:         lea     syntax(PC),A0
                bra.s   err
int_err:        lea     interr(PC),A0
                bra.s   err
misbrak:        lea     _misbra(PC),A0
                bra.s   err
no_syms:        lea     no_symt(PC),A0
                bra.s   err
file_er:        lea     file_e(PC),A0
                bra.s   err
fileer2:        lea     file_e2(PC),A0
                bra.s   err
illlabel:       lea     _illlab(PC),A0
                bra.s   err
no_prg:         lea     no_prg_(PC),A0
                bra.s   err
noallow:        lea     n_allow(PC),A0
                bra.s   err
no_bef:         lea     no_befx(PC),A0
                bra.s   err
illequa:        lea     illeqa(PC),A0
err:            tst.b   err_flag(A4)
                beq.s   err2
                movea.l err_stk(A4),SP
                jmp     mausc9z
err2:           clr.b   device(A4)                ;Druckerausgabe ausschalten
                move.w  zeile(A4),D0
                jsr     write_line
err1:           jsr     @crout(A4)
                jsr     clr_keybuff               ;Tastaturbuffer leeren
                sf      do_resident(A4)           ;AUTO-Resident l”schen
                bra     all_normal

               IFEQ sprache
batch_errtxt:  DC.B '?Im Batch-Mode nicht erlaubt',0
no_befx:       DC.B '?Unbekannter Befehl',0
interr:        DC.B '?Interner Fehler (Bitte Eingabe notieren!)',0
n_allow:       DC.B '?Nicht erlaubt',0
ill_bkpt:      DC.B '?Illegaler Breakpoint',0
errtab:        DC.B '?šberlauf',0
syntax:        DC.B '?Syntax-Fehler',0
illeqa:        DC.B '?Wert nicht erlaubt',0
_misbra:       DC.B '?Klammer fehlt',0
_illlab:       DC.B '?Label existiert nicht',0
no_symt:       DC.B '?Keine Symboltabelle',0
prn_e:         DC.B '?Welcher Drucker',0
file_e:        DC.B '?Datei nicht mit FOPEN ge”ffnet',0
file_e2:       DC.B '?Datei wurde bereits ge”ffnet',0
no_prg_:       DC.B '?Es ist kein Programm geladen',0
terrtxt:       DC.B -1,'Error',0
               DC.B -2,'Drive not ready',0
               DC.B -3,'Unknown command',0
               DC.B -4,'CRC-error',0
               DC.B -5,'Bad request',0
               DC.B -6,'Seek error',0
               DC.B -7,'Unknown media',0
               DC.B -8,'Sector not found',0
               DC.B -9,'No paper',0
               DC.B -10,'Write fault',0
               DC.B -11,'Read fault',0
               DC.B -12,'General mishap',0
               DC.B -13,'Write protect',0
               DC.B -14,'Media change',0
               DC.B -15,'Unknown device',0
               DC.B -16,'Bad sectors',0
               DC.B -17,'Insert disk',0
               DC.B -32,'EINVFN',0
               DC.B -33,'Datei nicht gefunden',0
               DC.B -34,'Pfad nicht gefunden',0
               DC.B -35,'ENHNDL',0
               DC.B -36,'Zugriff verw„hrt',0
               DC.B -37,'EIHNDL',0
               DC.B -39,'Speicher voll',0
               DC.B -40,'EIMBA',0
               DC.B -46,'Illegales Laufwerk',0
               DC.B -48,'ENSAME',0
               DC.B -49,'ENMFIL',0
               DC.B -64,'ERANGE',0
               DC.B -65,'EINTRN',0
               DC.B -66,'Illegales Programmformat',0
               DC.B -67,'EGSBF',0
               DC.B -117,'Disk voll',0
               DC.B -118,'Datei zu kurz',0
               DC.B 0,'Unbekannter TOS Fehler',0
               ELSE
batch_errtxt:  DC.B '?Not allowed in batch-mode',0
no_befx:       DC.B '?Unknown Command',0
interr:        DC.B '?Internal Error (Write down your input!)',0
n_allow:       DC.B '?Not allowed',0
ill_bkpt:      DC.B '?Illegal Breakpoint',0
errtab:        DC.B '?Overflow',0
syntax:        DC.B '?Syntax error',0
illeqa:        DC.B '?Value not allowed',0
_misbra:       DC.B '?Braket missing',0
_illlab:       DC.B "?Label don't existiert",0
no_symt:       DC.B '?No Symboltable',0
prn_e:         DC.B '?No Printer',0
file_e:        DC.B "?Can't open file with FOPEN",0
file_e2:       DC.B '?file already opened',0
no_prg_:       DC.B '?No programm',0
terrtxt:       DC.B -1,'Error',0
               DC.B -2,'Drive not ready',0
               DC.B -3,'Unknown command',0
               DC.B -4,'CRC-error',0
               DC.B -5,'Bad request',0
               DC.B -6,'Seek error',0
               DC.B -7,'Unknown media',0
               DC.B -8,'Sector not found',0
               DC.B -9,'No paper',0
               DC.B -10,'Write fault',0

               DC.B -11,'Read fault',0
               DC.B -12,'General mishap',0
               DC.B -13,'Write protect',0
               DC.B -14,'Media change',0
               DC.B -15,'Unknown device',0
               DC.B -16,'Bad sectors',0
               DC.B -17,'Insert disk',0
               DC.B -32,'EINVFN',0
               DC.B -33,'File not found',0
               DC.B -34,'Path not found',0
               DC.B -35,'ENHNDL',0
               DC.B -36,'Access denied',0
               DC.B -37,'EIHNDL',0
               DC.B -39,'Less memory',0
               DC.B -40,'EIMBA',0
               DC.B -46,'Illegal Drive',0
               DC.B -48,'ENSAME',0
               DC.B -49,'ENMFIL',0
               DC.B -64,'ERANGE',0
               DC.B -65,'EINTRN',0
               DC.B -66,'Illegal program format',0
               DC.B -67,'EGSBF',0
               DC.B -117,'Disk full',0
               DC.B -118,'File too short',0
               DC.B 0,'Unknown TOS-Error',0
               ENDC
               EVEN
               ;>ENDPART

********************************************************************************
* 68020/30/40 Cache l”schen                                                    *
********************************************************************************
               ;>PART 'clr_cache'
clr_cache:      movem.l D0/A0/A4-A6,-(SP)
                move    SR,-(SP)
                movea.l SP,A6                     ;SP retten
                lea     $10.w,A5
                movea.l (A5),A4                   ;Illegal-Vektor retten
                lea     clr_cache1(PC),A0
                move.l  A0,(A5)                   ;neuen einsetzen
                ori     #$0700,SR
               DC.L $4E7A0002                     ;MOVE CACR,D0
                or.w    #$0808,D0                 ;Cache l”schen
               DC.L $4E7B0002                     ;MOVE D0,CACR
clr_cache1:     move.l  A4,(A5)                   ;Illegal-Vektor zurück
                movea.l A6,SP                     ;SP zurück
                move    (SP)+,SR
                movem.l (SP)+,D0/A0/A4-A6
                rts
               ;>ENDPART
********************************************************************************
* Die einzelnen Befehle                                                        *
********************************************************************************
********************************************************************************
* OVERSCAN - OverScan-Aufl”sung umschalten                                     *
********************************************************************************
               ;>PART 'cmd_overscan'
cmd_overscan:   move.w  #4200,-(SP)
                trap    #14                       ;Oscanis()
                addq.l  #2,SP
                cmp.w   #4200,D0                  ;OverScan-Software vorhanden?
                beq.s   cmd_overscan1             ;Nein! => raus
                jsr     @page2(A4)
                move.l  #$106EFFFF,-(SP)
                trap    #14                       ;Oscanswitch(-1:Modus abfragen)
                addq.l  #4,SP
                bchg    #0,D0                     ;Modus toggeln
                move.w  D0,-(SP)
                move.w  #$106E,-(SP)
                trap    #14                       ;Oscanswitch(newMode)
                addq.l  #2,SP
                move.b  #$96,$FFFFFC00.w          ;OverScan sofort wieder aus
                jsr     @page1(A4)
                moveq   #1,D0
                and.w   (SP)+,D0
                move.w  D0,overscan(A4)           ;OverScan-Flag neu setzen
cmd_overscan1:  jmp     (A4)
               ;>ENDPART
********************************************************************************
* COOKIE - Cookie-Jar anzeigen                                                 *
********************************************************************************
               ;>PART 'cmd_cookie'
cmd_cookie:     move.l  $05A0.w,D0                ;Cookie-Ptr holen
                bne.s   cmd_cookie1               ;alles ok =>
                pea     no_cookie(PC)
                jsr     @print_line(A4)           ;Cookie nicht vorhanden...
                jmp     (A4)
cmd_cookie1:    movea.l D0,A3                     ;Cookie-Ptr merken
                pea     cookie_init(PC)
                jsr     @print_line(A4)
cmd_cookie2:    tst.l   (A3)                      ;Ende der Liste?
                beq.s   cmd_cookiex               ;Ja! =>
                pea     cookie_1(PC)
                jsr     @print_line(A4)
                move.b  (A3)+,D0
                jsr     @chrout(A4)
                move.b  (A3)+,D0
                jsr     @chrout(A4)               ;Namen ausgeben
                move.b  (A3)+,D0
                jsr     @chrout(A4)
                move.b  (A3)+,D0
                jsr     @chrout(A4)
                pea     cookie_2(PC)
                jsr     @print_line(A4)
                move.l  (A3)+,D1
                bsr     hexlout
                bra.s   cmd_cookie2
cmd_cookiex:    pea     cookie_end(PC)
                jsr     @print_line(A4)
                jmp     (A4)
               IFEQ sprache
no_cookie:     DC.B '?kein Cookie-Jar vorhanden',13,0
cookie_init:   DC.B 'Cookie-Jar:',13
               DC.B 'ÿÿÿÿÿÿÿÿÿÿÿ',0
cookie_1:      DC.B 13,'Name : "',0
cookie_2:      DC.B '" = $',0
cookie_end:    DC.B 13,0
               ELSE
no_cookie:     DC.B '?no cookie-jar',13,0
cookie_init:   DC.B 'cookie-jar:',13
               DC.B '-----------',0
cookie_1:      DC.B 13,'name : "',0
cookie_2:      DC.B '" = $',0
cookie_end:    DC.B 13,0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* #cmd - Batch-Unterbefehle                                                    *
********************************************************************************
               ;>PART 'cmd_number'
cmd_number:     moveq   #3,D2                     ;4 Zeichen holen
cmd_numberloop: lsl.l   #8,D1
                move.b  (A0)+,D0                  ;Groábuchstaben holen
                cmp.b   #$20,D0
                bhs.s   cmd_numberloop1           ;CR oder LF? Nein =>
                moveq   #' ',D0                   ;als Space bernehmen
                bra.s   cmd_numberloop2
cmd_numberloop1:and.w   #$DF,D0
cmd_numberloop2:or.b    D0,D1                     ;und zu den anderen
                dbra    D2,cmd_numberloop
cmd_numberloop3:moveq   #$DF,D0
                and.b   (A0),D0                   ;Folgezeichen holen
                cmp.b   #'A',D0
                blo.s   cmd_number1               ;immer noch ein Buchstabe?
                cmp.b   #'Z',D0
                bhi.s   cmd_number1               ;Nein! =>
                addq.l  #1,A0                     ;Buchstaben ignorieren
                bra.s   cmd_numberloop3           ;und weiter
cmd_number1:    lea     cmd_num_table-2(PC),A1
cmd_number2:    addq.l  #2,A1                     ;Sprungoffset bergehen
                move.l  (A1)+,D0                  ;Befehl aus der Tabelle
                bmi     synerr                    ;Ende der Tabelle => Fehler
                cmp.l   D0,D1                     ;Befehl gefunden?
                bne.s   cmd_number2               ;Nein! => weiter
                adda.w  (A1),A1                   ;Befehlsadresse errechnen
                jsr     (A1)                      ;Befehl anspringen
                st      batch_flag(A4)            ;Batch-Mode an
                jmp     (A4)                      ;und wieder zurück

;>               BASE DC.W,*
cmd_num_table: DC.L 'LOAD'                        ;Batch-Datei laden
               DC.W cmd_num_load-cmd_num_table
               DC.L 'END '                        ;Ende der Batch-Datei
               DC.W cmd_num_end-cmd_num_table
               DC.B -1
               EVEN

cmd_num_end:    clr.l   input_pnt(A4)             ;Batch-Pointer zurücksetzen
                sf      batch_flag(A4)            ;Flag für z.B. "DIR" l”schen
                jmp     (A4)                      ;und in die Hauptschleife

cmd_num_load:   bsr     getnam                    ;Filenamen holen
                movea.l #allg_buffer,A6
                adda.l  A4,A6                     ;in den 10k-Buffer lesen
                movea.l #allg_buf_end,A5
                adda.l  A4,A5                     ;Zeiger auf das Bufferende
                bsr     _clear                    ;den Buffer l”schen
                move.l  A5,-(SP)
                jsr     readimg                   ;die Batch-Datei einlesen
                movea.l (SP)+,A5
                move.l  A6,input_pnt(A4)          ;Eingabezeile setzen
                movea.l A6,A0
cmd_num_load1:  cmpi.b  #'%',(A0)                 ;Kommentarzeile?
                bne.s   cmd_num_load3             ;Nein! =>
cmd_num_load2:  move.b  #':',(A0)+
                cmpi.b  #$20,(A0)                 ;CR/LF?
                bhs.s   cmd_num_load2             ;Nein! =>
                addq.l  #1,A0                     ;Zeiger auf das LF
                bra.s   cmd_num_load4
cmd_num_load3:  cmpi.b  #$20,(A0)+                ;Steuerzeichen im Buffer suchen
                bhs.s   cmd_num_load1             ;kein Steuerzeichen =>
cmd_num_load4:  move.b  -(A0),D0
                beq.s   cmd_num_load5             ;Bufferende =>
                move.b  #':',(A0)+                ;Zeichen durch Trenner ersetzen
                bra.s   cmd_num_load1             ;und weiter...
cmd_num_load5:  rts
               ;>ENDPART
********************************************************************************
* HELP - Alle Befehle ausgeben                                                 *
********************************************************************************
               ;>PART 'cmd_help'
cmd_help:       lea     cmdtab(PC),A6
cmd_help1:      move.b  (A6)+,D0
                bmi.s   cmd_help4
                beq.s   cmd_help2
cmd_help3:      jsr     @chrout(A4)
                bra.s   cmd_help1
cmd_help2:      moveq   #' ',D0
                bra.s   cmd_help3
cmd_help4:      jsr     @crout(A4)
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* & - noch nix tun                                                             *
********************************************************************************
               ;>PART 'cmd_und'
cmd_und:        jmp     (A4)
               ;>ENDPART
********************************************************************************
* LABELBASE P/S - Labelbasis setzen (Programm/Segment)                         *
********************************************************************************
               ;>PART 'cmd_labelbase'
cmd_labelbase:  bsr     get
                cmp.b   #'S',D0
                beq.s   cmd_labelbase1
                cmp.b   #'P',D0
                bne     syn_err
                moveq   #$18,D1                   ;Symbole auch DATA- & BSS-relativ
                moveq   #$10,D2
                lea     cmd_labelbase3(PC),A0
                bra.s   cmd_labelbase2
cmd_labelbase1: moveq   #8,D1                     ;Symbole stets TEXT-relativ
                moveq   #8,D2
                lea     cmd_labelbase4(PC),A0
cmd_labelbase2: move.b  D1,reloc_symbols12+1
                move.b  D2,reloc_symbols13+1
               IFEQ sprache
                pea     cmd_labelbase5(PC)
                jsr     @print_line(A4)
                move.l  A0,-(SP)
                jsr     @print_line(A4)
                pea     cmd_labelbase6(PC)
                jsr     @print_line(A4)
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                jmp     (A4)
cmd_labelbase3:DC.B 'programm',0
cmd_labelbase4:DC.B 'segment',0
cmd_labelbase5:DC.B 'Symbolformat nun ',0
cmd_labelbase6:DC.B 'relativ.',0
               ELSE
                pea     cmd_labelbase5(PC)
                jsr     @print_line(A4)
                move.l  A0,-(SP)
                jsr     @print_line(A4)
                pea     cmd_labelbase6(PC)
                jsr     @print_line(A4)
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                jmp     (A4)
cmd_labelbase3:DC.B 'programm',0
cmd_labelbase4:DC.B 'segment',0
cmd_labelbase5:DC.B 'Symbolformat now ',0
cmd_labelbase6:DC.B 'relative.',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* SHOWMEMORY Formel[,[.Nummer|[B|W|L][,][size]]]                               *
********************************************************************************
               ;>PART 'cmd_showmem'
cmd_showmem:    movea.l A0,A1
                bsr     get
                cmp.b   #',',D0
                beq.s   cmd_showmem0
                movea.l A1,A0
                move.w  upper_line(A4),D1
                cmpi.w  #15,D1
                beq     ret_jump                  ;Keine weiteren Zeilen m”glich
                subq.w  #5,D1
                movea.l #spez_format,A1
                adda.l  A4,A1
                adda.w  D1,A1
                move.w  def_size(A4),D2
                beq.s   cmd_showmem00
                subq.b  #1,D2
cmd_showmem00:  lsl.b   #4,D2                     ;Size setzen
                move.b  D2,(A1)                   ;Ausgabedefault ist Byte-Breite
                lsl.w   #8,D1                     ;* 256 Bytes (pro Formel)
                movea.l #spez_buff,A1
                adda.l  A4,A1
                adda.w  D1,A1
                bsr     convert_formel
                tst.b   D0
                beq     cmd_showmem1
                cmp.b   #',',D0                   ;Folgen noch Parameter
                bne     syn_err
cmd_showmem0:   bsr     get
                cmp.b   #'.',D0                   ;Eintrag l”schen?
                bne.s   cmd_showmem4
                bsr     get_term                  ;Nummer holen
                moveq   #0,D0
                move.w  upper_line(A4),D0
                subq.w  #6,D0
                bmi     illequa
                cmp.l   D0,D1
                bhi     illequa                   ;Term > max.Eintrag

                movea.l #spez_format,A1
                adda.l  A4,A1
                lea     9(A1),A2
                adda.w  D1,A1
cmd_showmem21:  cmpa.l  A2,A1
                bhs.s   cmd_showmem22
                move.b  1(A1),(A1)+
                bra.s   cmd_showmem21
cmd_showmem22:  lsl.w   #8,D1
                movea.l #spez_buff,A1
                adda.l  A4,A1
                lea     $0900(A1),A2              ;Zeiger auf das letzte Bufferelement
                adda.w  D1,A1                     ;Adresse des Eintrags
                lea     $0100(A1),A3
cmd_showmem2:   cmpa.l  A2,A3
                bhs.s   cmd_showmem3
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                move.l  (A3)+,(A1)+
                bra.s   cmd_showmem2
cmd_showmem3:   subq.w  #1,upper_line(A4)
                addq.w  #1,down_lines(A4)
                subi.w  #80,upper_offset(A4)
                move.l  zeile(A4),-(SP)
                clr.l   zeile(A4)
                jsr     c_clrli
                move.l  (SP)+,zeile(A4)
                bsr     rgout
                jmp     (A4)

cmd_showmem4:   moveq   #0,D2                     ;Byte ist Default
                cmp.b   #'B',D0
                beq.s   cmd_showmem7
                cmp.b   #'W',D0
                bne.s   cmd_showmem6
                moveq   #1,D2                     ;Word
                bra.s   cmd_showmem7
cmd_showmem6:   cmp.b   #'L',D0
                bne.s   cmd_showmem5
                moveq   #3,D2                     ;Long
cmd_showmem7:   bsr     get
cmd_showmem5:   move.w  upper_line(A4),D1
                subq.w  #5,D1
                movea.l #spez_format,A1
                adda.l  A4,A1
                adda.w  D1,A1
                or.b    D2,(A1)                   ;Ausgabebreite angeben
                tst.w   D0
                beq.s   cmd_showmem1
                cmp.b   #',',D0
                bne.s   cmd_showmem8              ;Komma berlesen
                bsr     get
cmd_showmem8:   bsr     get_term                  ;Size holen
                moveq   #$10,D2
                cmp.l   D2,D1
                bhi     illequa                   ;1-16 ist erlaubt!
                tst.l   D1
                beq     illequa
                subq.b  #1,D1
                lsl.b   #4,D1
                andi.b  #3,(A1)
                or.b    D1,(A1)                   ;Size-Wert einsetzen (Bit 4-7)
cmd_showmem1:   jsr     scroll_dn                 ;Bildschirm nach unten scrollen
                addq.w  #1,upper_line(A4)
                subq.w  #1,down_lines(A4)
                addi.w  #80,upper_offset(A4)
                bsr     rgout                     ;Registerliste neu ausgeben
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* CLR [Anfadr,Endadr] -Speicherbereich l”schen                                 *
********************************************************************************
               ;>PART 'cmd_clr'
cmd_clr:        move.l  A0,-(SP)
                lea     clr_text(PC),A0
                jsr     ask_user                  ;Sicherheitsabfrage
                movea.l (SP)+,A0
                movea.l first_free(A4),A5         ;Ab hier wird gel”scht
                movea.l end_of_mem(A4),A6         ;genau bis hier
                bsr     get
                beq.s   cmd_clr2                  ;keine Parameter => alles l”schen
                cmp.b   #',',D0
                beq.s   cmd_clr0
                bsr     get_term                  ;Anfangsadresse holen
                movea.l D1,A5
                cmp.b   #',',D0
                bne.s   cmd_clr1
cmd_clr0:       bsr     get
                bsr     get_term                  ;Endadresse holen
                movea.l D1,A6
                bra.s   cmd_clr1
cmd_clr2:       bsr     kill_programm             ;um S”ren's Absturz zu verhindern
cmd_clr1:       move.l  A6,D1
                beq.s   cmd_clr3                  ;Endadresse fehlt! =>
                bsr.s   _clear                    ;und l”schen ...
cmd_clr3:       jmp     (A4)

               IFEQ sprache
clr_text:      DC.B 'Wollen Sie l”schen? (j/n) ',0
               ELSE
clr_text:      DC.B 'Execute CLR? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* clear(a5,a6) - fast-clear des TOS                                            *
********************************************************************************
               ;>PART '_clear'
_clear:         ori     #$0700,SR
                movem.l D0-D7/A2-A3,-(SP)
                cmpa.l  A5,A6
                blo.s   _clear4
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                moveq   #0,D6
                moveq   #0,D7
                movea.l D7,A3
                move.l  A5,D0
                btst    #0,D0
                beq.s   _clear1
                move.b  D1,(A5)+
_clear1:        move.l  A6,D0
                sub.l   A5,D0
                clr.b   D0
                tst.l   D0
                beq.s   _clear3
                lea     0(A5,D0.l),A5
                movea.l A5,A2
                lsr.l   #8,D0
_clear2:        movem.l D1-D7/A3,-(A2)            ;256 Byte l”schen
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                movem.l D1-D7/A3,-(A2)
                subq.l  #1,D0
                bne.s   _clear2
_clear3:        cmpa.l  A5,A6
                beq.s   _clear4
                move.b  D1,(A5)+
                bra.s   _clear3
_clear4:        movem.l (SP)+,D0-D7/A2-A3
                rts
               ;>ENDPART
********************************************************************************
* @Befehl - Befehl in den Auto-Command-Buffer                                  *
********************************************************************************
               ;>PART 'cmd_atsign'
cmd_atsign:     tst.b   (A0)                      ;Leereingabe
                beq.s   cmd_atsign2               ;dann den Batch-Befehl l”schen
                lea     _zeile3(A4),A1
                move.b  #'@',(A1)+
cmd_atsign1:    move.b  (A0)+,(A1)+               ;Zeile in Buffer
                bne.s   cmd_atsign1
                jmp     (A4)
cmd_atsign2:    clr.l   _zeile3(A4)               ;Batch-Befehl l”schen
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* RWABS - Sektoren lesen/schreiben                                             *
********************************************************************************
               ;>PART 'cmd_rwabs'
cmd_rwabs:      bsr     get
                beq     syn_err
                bsr     get_term                  ;Lese-/Schreib-Flag
                bsr     chkcom                    ;folgt auch ein Komma?
                moveq   #15,D2
                cmp.l   D2,D1
                bhi     illequa                   ;>15 => Fehler
                move.w  D1,D7                     ;Flag merken
                bsr     get_term
                bsr     chkcom                    ;folgt auch ein Komma?
                movea.l D1,A6                     ;Pufferadresse merken
                bsr     get_term
                bsr     chkcom                    ;folgt auch ein Komma?
                swap    D1                        ;Sektoranzahl >65535?
                tst.w   D1
                bne     illequa
                swap    D1
                move.w  D1,D6                     ;Sektoranzahl
                bsr     get_term
                bsr     chkcom                    ;folgt auch ein Komma?
                swap    D1                        ;Startsektor >65535?
                tst.w   D1
                bne     illequa
                swap    D1
                move.w  D1,D5                     ;Startsektor merken
                bsr     get_term                  ;Laufwerk holen
                moveq   #15,D2
                cmp.l   D2,D1
                bhi     illequa                   ;>15 => Fehler
                moveq   #1,D0
                jsr     graf_mouse                ;Mauszeiger zur Diskette
                move.w  D1,-(SP)                  ;driv
                move.w  D5,-(SP)                  ;recn
                move.w  D6,-(SP)                  ;secn
                move.l  A6,-(SP)                  ;buf
                move.w  D7,-(SP)                  ;rwfl
                move.w  #4,-(SP)                  ;rwabs()
                trap    #13
                lea     14(SP),SP
                tst.l   D0
                bmi     toserr                    ;Das war wohl nix
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* SHOW Filename - ASCII-Datei anzeigen                                         *
********************************************************************************
               ;>PART 'cmd_type'
cmd_type:       bsr     get
                beq.s   cmd_type7                 ;Default File anzeigen
                bsr     getnam_cont               ;Filenamen holen

cmd_type7:      lea     fname(A4),A0
                tst.b   (A0)
                beq     synerr                    ;Kein File-/Orndername angegeben
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     fopen                     ;Datei ”ffnen
                move.b  ins_mode(A4),D5           ;Insert-Mode-Flag merken
                sf      ins_mode(A4)              ;Insert-Mode aus
cmd_type0:      movea.l #allg_buffer,A6           ;Buffer für 8k Text
                adda.l  A4,A6
                move.l  #8192,D1                  ;8192 Bytes auf einmal lesen
                bsr     fread                     ;und 8k lesen
                cmp.l   D1,D0
                seq     D7                        ;D7<>0, wenn Dateiende noch nicht erreicht
                move.w  D0,D1                     ;Anzahl der tats„chlich gelesenen Bytes
                beq.s   cmd_type5
                subq.w  #1,D1
cmd_type1:      move.b  (A6)+,D0                  ;Zeichen aus dem Buffer holen
                cmp.b   #10,D0                    ;LF ignorieren
                beq.s   cmd_type3
                cmp.b   #13,D0                    ;CR ausführen
                beq.s   cmd_type2
                cmp.b   #9,D0                     ;Tab
                beq.s   cmd_type6
                jsr     @chrout(A4)               ;"normales" Zeichen ausgeben
                moveq   #0,D6
                bra.s   cmd_type3
cmd_type6:      jsr     c_tab                     ;Tab ausführen
                bra.s   cmd_type3
cmd_type2:      jsr     @c_eol(A4)
                jsr     @crout(A4)                ;Zeilenrest l”schen & CR ausgeben
                moveq   #-1,D6
cmd_type3:      jsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_type4                 ;ja!
                dbra    D1,cmd_type1              ;Buffer schon leer?
                tst.b   D7
                bne.s   cmd_type0
cmd_type4:      tst.w   D6                        ;Text mit CR abgeschlossen?
                bne.s   cmd_type5                 ;dann kein CR mehr ausgeben
                jsr     @c_eol(A4)
                jsr     @crout(A4)                ;nochmal ein CR als Abschluž
cmd_type5:      move.b  D5,ins_mode(A4)           ;Insert-Mode-Flag zurück
                bsr     fclose                    ;Datei wieder schliežen
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* SYNC - Synchronisation zwischen 50Hz und 60Hz umschalten                     *
********************************************************************************
               ;>PART 'cmd_sync'
cmd_sync:       lea     user_scr(A4),A0
                bchg    #1,scr_sync(A0)           ;Synchronisationsfrequenz „ndern
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* |Mnemonic - Befehl ausführen                                                 *
********************************************************************************
               ;>PART 'cmd_dobef'
cmd_dobef:      st      ignore_autocrlf(A4)       ;CR/LF nach der Funktion unterdrücken
                movea.l A0,A1
                bsr     get
                movea.l A1,A0
                beq     ret_jump                  ;Ende, da Leereingabe
                move.b  #2,find_cont0(A4)
                lea     data_buff(A4),A6          ;Zwischenbuffer für den Code
                move.l  default_adr(A4),(A6)+     ;Default-Adr merken
                move.l  _pc(A4),(A6)+             ;PC retten
                bsr.s   code_line                 ;Zeile assemblieren
                lea     data_buff+8(A4),A6        ;Zwischenbuffer für den Code
                move.l  A6,_pc(A4)                ;tempor„ren PC setzen
                bsr     get_dlen                  ;Befehlsl„nge ermitteln
                move.l  A6,breakpnt+12*16(A4)     ;Break #16 setzen
                move.w  #-1,breakpnt+12*16+4(A4)  ;Stop-Breakpoint
                clr.l   breakpnt+12*16+6(A4)      ;nur einmal ausführen
                st      dobef_flag(A4)            ;Flag für den Exceptionhandler
                bra     go_pc
               ;>ENDPART
********************************************************************************
* !Mnemonic - Line-Assembler                                                   *
********************************************************************************
               ;>PART 'cmd_assem'
cmd_assem:      st      ignore_autocrlf(A4)       ;CR/LF nach der Funktion unterdrücken
                movea.l default_adr(A4),A6        ;nach A6 assemblieren
                movea.l A0,A1
                bsr     get
                movea.l A1,A0
                beq     ret_jump                  ;Ende, da Leereingabe
                bsr.s   code_line                 ;Zeile assemblieren
                subq.w  #1,zeile(A4)              ;und eine Zeile zurück
                st      list_flg(A4)              ;Ausgabe symbolisch
                movea.l default_adr(A4),A6
                bsr     do_disass                 ;Zeile nochmal ausgeben
                move.l  A6,default_adr(A4)
                jsr     @crout(A4)                ;und mit einem CR anschliežen
                st      assm_flag(A4)             ;Eingabe mit dem Line-Assembler
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* Mnemonic ab A0 nach A6 assemblieren                                          *
********************************************************************************
               ;>PART 'code_line'
code_line:      movem.l D1-D7/A1-A5,-(SP)
                move.l  SP,D7                     ;Rücksprungadresse sichern
                bclr    #0,default_adr+3(A4)      ;Damit sie sicher gerade ist!
                moveq   #0,D5                     ;Nummer des Operanten
                lea     op_buffer(A4),A3          ;A3 zeigt auf Zeilen-Info
                lea     16(A3),A2                 ;A2 zeigt auf Operanten des Opcodes
                moveq   #0,D0
                move.w  D0,(A3)                   ;Puffer l”schen
                move.l  D0,14(A3)
                move.l  D0,18(A3)
                move.l  D0,22(A3)
code_l3:        bsr     cut_space
                cmpi.b  #'?',(A0)                 ;'???'
                beq.s   code_l1
                bsr     search                    ;Befehl in der Tabelle suchen
                move.l  A1,D2
                bne.s   code_l5                   ;gleich null, Unbekannter Befehl
code_l4:        move.b  (A0)+,D0
                beq.s   syntax_error              ;Zeilenende erreicht!
                cmp.b   #':',D0                   ;Label berlesen
                bne.s   code_l4
                cmpi.b  #':',(A0)
                bne.s   code_l3                   ;2.Doppelpunkt für GLOBAL?
                addq.l  #1,A0                     ;berlesen
                bra.s   code_l3
code_l5:        bsr     cut_space
                moveq   #0,D2
                moveq   #0,D0
                move.b  (A0),D0                   ;n„chste Zeichen
                move.w  14(A1),14(A3)             ;Befehlsbits in Puffer schreiben
                move.w  #2,(A3)                   ;L„nge der Zeile auf 2 setzen
                move.w  12(A1),D4                 ;Daten für unmittelbaren Operanten
                movea.l 8(A1),A1                  ;Adresse der Routine holen
                jsr     (A1)                      ;Sprung zur Operantenauswertung
                bsr     get                       ;Folgezeichen holen
                move.w  (A3),D1                   ;L„nge des Befehls
                lea     14(A3),A3                 ;Ab hier liegt der Befehl
                subq.w  #1,D1
code_l0:        move.b  (A3)+,(A6)+               ;Befehl kopieren
                dbra    D1,code_l0
code_l2:        movem.l (SP)+,D1-D7/A1-A5
                rts
code_l1:        addq.l  #2,A6                     ;2 Byte - '???'-Befehl
                bra.s   code_l2                   ;das war's

operant_err:    cmp.w   #-5,D0
                bne.s   unknow_error
                movea.l D7,SP
                movem.l (SP)+,D1-D7/A1-A6
                bra     overfl                    ;šberlauf
unknow_error:
syntax_error:   movea.l D7,SP
                movem.l (SP)+,D1-D7/A1-A6
                bra     synerr                    ;falsches Zeichen

;************************************************************************
;* Operantenchecks der Befehle                                          *
;************************************************************************
t_abcd:         cmp.b   #'D',D0
                beq.s   t_abcd2
                cmp.b   #'d',D0
                beq.s   t_abcd2
                cmp.b   #'-',D0
                bne     op_error
                bsr     get_indirect
                bset    #3,D0
                or.b    D0,15(A3)
                bsr     chk_com
                cmpi.b  #'-',(A0)
                bne     op_error
                bsr     get_indirect
t_abcd3:        add.w   D0,D0
                or.b    D0,14(A3)
                rts
t_abcd2:        bsr     get_regnr
                or.b    D0,15(A3)
                bsr     chk_com
                bsr     get_datareg
                bmi     op_error
                bra.s   t_abcd3

t_add:          move.w  #$1C00,D1
                bsr     get_ea
                bsr     chk_com
                bsr     get_adrreg
                bpl.s   t_add4
                bsr     get_datareg
                bmi.s   t_add2
                move.w  14(A3),D1                 ;Opcode holen
                andi.w  #$3F,D1                   ;EA ausmaskieren
                cmp.w   #$3C,D1                   ;Quelloperand unmittelbar ?
                beq.s   t_add6                    ;ja!
t_add3:         add.w   D0,D0
                or.b    D0,14(A3)
                rts
t_add6:         move.b  14(A3),D1                 ;ADDI #xx,xx
                rol.b   #3,D1                     ;ADD zu ADDI und SUB zu SUBI wandeln
                andi.b  #7,D1
                move.b  D1,14(A3)
                andi.b  #$C0,15(A3)
                or.b    D0,15(A3)                 ;Datenregister einsetzen
                rts
t_add2:         move.w  14(A3),D0                 ;Opcode holen
                andi.w  #$3F,D0                   ;EA ausmaskieren
                cmp.w   #$3C,D0                   ;Quelloperand unmittelbar ?
                beq.s   t_add5                    ;ja!
                move.w  #$1F03,D1                 ;ADD Dx,xx
                move.w  14(A3),D0
                andi.w  #$FFC0,14(A3)
                bsr     get_ea
                andi.w  #$3F,D0
                cmp.w   #7,D0
                bgt.s   op_error
                add.w   D0,D0
                bset    #0,D0
                or.b    D0,14(A3)
                rts
t_add4:         move.w  14(A3),D1                 ;ADDA xx,Ax
                add.w   D1,D1
                andi.w  #$0100,D1
                ori.w   #$C0,D1
                or.w    D1,14(A3)
                bra.s   t_add3
t_add5:         move.b  14(A3),D0                 ;ADDI #xx,xx
                rol.b   #3,D0                     ;ADD zu ADDI und SUB zu SUBI wandeln
                andi.b  #7,D0
                move.b  D0,14(A3)
                move.w  #$1F02,D1
                bsr     get_ea
                rts

chk_com:        bsr     cut_space
                cmpi.b  #',',(A0)+
                bne.s   chk_com2
                moveq   #2,D5
                bsr     cut_space
                rts
chk_com2:       moveq   #-9,D0
                bra     operant_err

op_error:       moveq   #-7,D0
                bra     operant_err

t_adda:         move.w  #$1C00,D1
                bsr     get_ea
                bsr.s   chk_com
                bsr     get_adrreg
                bmi.s   op_error
                add.w   D0,D0
                or.b    D0,14(A3)
                rts

t_addi:         cmpi.b  #'#',(A0)+
                bne.s   op_error
                bsr     get_wert
                bsr     set_imidiate
                bsr.s   chk_com
                move.w  #$1F02,D1
                bsr     get_ea
                rts

t_addq:         cmpi.b  #'#',(A0)+
                bne.s   op_error
                bsr     get_wert
                tst.b   2(A3,D5.w)
                bne.s   t_addq3
                tst.l   D3
                beq     val_error
                cmp.l   #8,D3
                bhi     val_error
                andi.w  #7,D3
                add.b   D3,D3
                or.b    D3,14(A3)
t_addq2:        bsr.s   chk_com
                move.w  #$1F00,D1
                bsr     get_ea
                rts
t_addq3:        bsr     get_quick
                bra.s   t_addq2

t_and:          move.w  #$1C02,D1
                bsr     get_ea
                move.w  14(A3),D0                 ;EA holen
                andi.w  #$3F,D0
                cmp.w   #$3C,D0                   ;Quelloperant = unmittelbar
                beq.s   t_and3                    ;Ja !
                bsr     chk_com
                bsr     get_datareg
                bmi     t_add2
                add.b   D0,D0
                or.b    D0,14(A3)
                rts
t_and3:         bsr     chk_com
                move.b  14(A3),D0
                ror.b   #5,D0
                move.b  D0,14(A3)
                andi.w  #$02C0,14(A3)             ;AND zu ANDI und OR zu ORI wandeln
                bra.s   t_andi2

t_andi:         cmpi.b  #'#',(A0)+
                bne     op_error
t_andi3:        bsr     get_wert
                bsr     set_imidiate
                bsr     chk_com
t_andi2:        move.w  #$1302,D1
                bsr     get_ea
                rts

t_asl:          cmp.b   #'#',D0
                beq.s   t_asl3
                bsr     get_datareg
                bmi.s   t_asl2
                andi.b  #$F1,14(A3)
                bsr     cut_space
                cmpi.b  #',',(A0)
                bne.s   t_asl6
                add.w   D0,D0
                or.b    D0,14(A3)
                bset    #5,15(A3)
t_asl4:         bsr     chk_com
                bsr     get_datareg
                bmi     op_error
                or.b    D0,15(A3)
                rts
t_asl6:         ori.b   #2,14(A3)                 ;#1 einsetzen
                or.b    D0,15(A3)                 ;Register einsetzen
                rts
t_asl3:         addq.l  #1,A0
                bsr     get_wert
                tst.w   2(A3)
                bne.s   t_asl5
                andi.w  #7,D3
                add.w   D3,D3
                andi.b  #$F1,14(A3)
                or.b    D3,14(A3)
                bra.s   t_asl4
t_asl2:         move.b  #$C0,15(A3)
                move.w  #$1F03,D1
                bsr     get_ea
                rts
t_asl5:         bsr     get_quick
                bra.s   t_asl4

t_bccs:         subq.l  #1,A0
                bsr     get_wert
                sub.l   default_adr(A4),D3
                subq.l  #2,D3
                move.l  D3,D1
                ext.w   D1
                ext.l   D1
                cmp.l   D1,D3
                bne     val_error
                move.b  D3,15(A3)
                rts

t_bcc:          subq.l  #1,A0
                bsr     get_wert
                sub.l   default_adr(A4),D3
                subq.l  #2,D3
                move.l  D3,D1
                ext.l   D1
                cmp.l   D1,D3
                bne     val_error
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                rts

t_bchg:         cmp.b   #'D',D0
                beq.s   t_bchg2
                cmp.b   #'d',D0
                beq.s   t_bchg2
                cmpi.b  #'#',(A0)+
                bne     op_error
                bsr     get_wert
                cmp.w   #$1F,D3
                bhi     op_error
                move.b  #%1000,14(A3)
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                bsr     chk_com
                move.w  #$1F02,D1
                bsr     get_ea
                rts
t_bchg2:        bsr     get_regnr
                add.b   D0,D0
                or.b    D0,14(A3)
                bsr     chk_com
                move.w  #$1F02,D1
                bsr     get_ea
                rts

t_btst:         cmp.b   #'D',D0
                beq.s   t_btst2
                cmp.b   #'d',D0
                beq.s   t_btst2
                cmpi.b  #'#',(A0)+
                bne     op_error
                bsr     get_wert
                cmp.w   #$1F,D3
                bhi     op_error
                move.b  #%1000,14(A3)
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                bsr     chk_com
                move.w  #$1E02,D1
                bra     get_ea
t_btst2:        bsr     get_regnr
                add.b   D0,D0
                or.b    D0,14(A3)
                bsr     chk_com
                move.w  #$1E02,D1
                bra     get_ea

t_chk:          move.w  #$1C02,D1
                bsr     get_ea
                bsr     chk_com
                bsr     get_datareg
                bmi     op_error
                add.b   D0,D0
                or.b    D0,14(A3)
                rts

t_clr:          move.w  #$1F00,D1
                bsr     get_ea
                move.b  15(A3),D0                 ;EA holen
                andi.w  #$3F,D0
                cmp.w   #7,D0
                bls.s   t_clr2
                cmp.w   #$0F,D0
                bhi.s   t_clr2
                move.w  14(A3),D1                 ;Befehl holen
                add.w   D1,D1                     ;Breitenbit an richtige Stelle
                andi.w  #$0100,D1                 ;und ausmaskieren
                ori.w   #$90C0,D1                 ;zu SUBA wandeln
                or.b    D0,D1                     ;Adressregister einsetzen
                move.w  D1,14(A3)
                add.w   D0,D0
                or.b    D0,14(A3)                 ;Adressregister einsetzen
t_clr2:         rts

t_cmp:          move.w  #$1C00,D1
                bsr     get_ea
                bsr     chk_com
                move.w  14(A3),D0                 ;Befehl retten
                move.w  #$1F00,D1
                bsr     get_ea                    ;Ziel-EA holen (CMPI/CMPA)
                move.b  15(A3),D1
                andi.w  #$3F,D1
                cmp.w   #7,D1
                bls.s   t_cmp3                    ;CMP x,Dx
                cmp.b   #$0F,D1
                bls.s   t_cmp2                    ;CMPA x,Ax
                move.b  D0,D3
                andi.w  #$3F,D3
                cmp.w   #$3C,D3                   ;Quelloperand unmittelbar ?
                bne     op_error                  ;Nein !
                andi.w  #$C0,D0
                ori.w   #$0C00,D0                 ;CMPI #x,x
                or.w    D1,D0
                move.w  D0,14(A3)
                rts
t_cmp2:         move.w  D0,D3
                add.w   D0,D0
                andi.w  #$0100,D0
                ori.w   #$C0,D0
                or.w    D3,D0
t_cmp3:         move.w  D0,14(A3)
                andi.w  #7,D1
                add.b   D1,D1
                or.b    D1,14(A3)
                rts

t_cmpm:         bsr     get_indirect2
                cmpi.b  #'+',(A0)+
                bne     op_error
                or.b    D0,15(A3)
                bsr     chk_com
                bsr     get_indirect2
                cmpi.b  #'+',(A0)+
                bne     op_error
                add.b   D0,D0
                or.b    D0,14(A3)
                rts

t_dbcc:         bsr     get_datareg
                bmi     op_error
                or.b    D0,15(A3)
                bsr     chk_com
                bsr     get_wert
                sub.l   default_adr(A4),D3
                subq.l  #2,D3
                move.l  D3,D1
                ext.l   D1
                cmp.l   D1,D3
                bne     val_error
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                rts

t_eor:          cmpi.b  #'#',(A0)
                beq.s   t_eor2                    ;Quelle unmittelbar
                bsr     get_datareg
                bmi     op_error
                add.b   D0,D0
                or.b    D0,14(A3)
                bsr     chk_com
                move.w  #$1F02,D1
                bsr     get_ea
                rts
t_eor2:         move.b  #%1010,14(A3)             ;EORI einsetzen
                addq.w  #1,A0
                bra     t_andi3

t_exg:          cmp.b   #'D',D0
                beq.s   t_exg2
                cmp.b   #'d',D0
                beq.s   t_exg2
                bsr     get_adrreg
                bmi     op_error
                add.b   D0,D0
                or.b    D0,14(A3)
                move.b  #%1001000,15(A3)
                bsr     chk_com
                cmpi.b  #'D',(A0)
                beq.s   t_exg4
                cmpi.b  #'d',(A0)
                beq.s   t_exg4
                bsr     get_adrreg
                bmi     op_error
                or.b    D0,15(A3)
                rts
t_exg4:         lsr.b   #1,D0                     ;Adressregister zurückholen
                andi.w  #7,D0
                ori.w   #$C188,D0                 ;Bits für Daten/Adressregister setzen
                move.w  D0,14(A3)
                bsr     get_regnr
                add.b   D0,D0
                or.b    D0,14(A3)
                rts
t_exg2:         bsr     get_regnr
                add.b   D0,D0
                or.b    D0,14(A3)
                bsr     chk_com
                cmpi.b  #'D',(A0)
                beq.s   t_exg3
                cmpi.b  #'d',(A0)
                beq.s   t_exg3
                bsr     get_adrreg
                bmi     op_error
                move.b  #%10001000,15(A3)
                or.b    D0,15(A3)
                rts
t_exg3:         bsr     get_regnr
                move.b  #%1000000,15(A3)
                or.b    D0,15(A3)
                rts

t_ext:          bsr     get_datareg
                bmi     op_error
                or.b    D0,15(A3)
                rts

t_jmp:          move.w  #$1E1B,D1
                bsr     get_ea
                rts

t_lea:          move.w  #$1E1B,D1
                bsr     get_ea
                bsr     chk_com
                bsr     get_adrreg
                bmi     op_error
                add.b   D0,D0
                or.b    D0,14(A3)
                rts

t_link:         bsr     get_adrreg
                bmi     op_error
                or.b    D0,15(A3)
                bsr     chk_com
                cmpi.b  #'#',(A0)+
                bne     op_error
                bsr     get_wert
                tst.b   2(A3,D5.w)
                beq.s   t_link2
                move.b  #$12,3(A3,D5.w)
t_link2:        move.w  D3,(A2)
                addq.w  #2,(A3)
                rts

t_move:         move.w  #$0400,D1
                bsr     get_ea
                bsr     chk_com
                cmpi.b  #%1111100,15(A3)          ;SR
                beq.s   t_move2
                cmpi.b  #$3F,15(A3)               ;USP
                beq     t_move5
                move.w  14(A3),D0
                move.w  #$0300,D1
                bsr     get_ea
                move.b  15(A3),D1                 ;EA holen
                cmp.b   #%1111100,D1              ;SR
                beq.s   t_move3
                cmp.b   #%111100,D1               ;CCR
                beq.s   t_move3
                cmp.b   #$3F,D1                   ;USP
                beq     t_move6
                cmp.b   #7,D1
                bls.s   t_move11                  ;Dx
                cmp.b   #$0F,D1
                bls     t_move7                   ;Ax
t_move11:       move.b  15(A3),D1
                andi.w  #$3F,D1
                move.w  D0,14(A3)                 ;Quell-EA zurückschreiben
                lsl.w   #3,D1
                move.w  D1,D0
                andi.w  #$01C0,D1
                or.w    D1,14(A3)                 ;Ziel-EA (Modus) einsetzen
                lsr.w   #2,D0
                andi.w  #$0E,D0
                or.b    D0,14(A3)                 ;Ziel-EA (Register) einsetzen
                rts
t_move2:        move.w  #$40C0,14(A3)             ;MOVE von SR
                move.w  #$1302,D1
                bsr     get_ea
                rts
t_move3:        move.w  14(A3),D1
                rol.b   #3,D1
                andi.w  #2,D1
                andi.w  #$3F,D0                   ;MOVE to CCR
                cmp.w   #8,D0
                blt.s   t_move4
                cmp.w   #$10,D0
                blt     op_error
                cmp.w   #$3C,D0
                bgt     op_error
t_move4:        ori.w   #$44C0,D0
                move.w  D0,14(A3)
                or.b    D1,14(A3)
                rts
t_move5:        bsr     get_adrreg

                bmi     op_error
                ori.w   #$4E68,D0
                move.w  D0,14(A3)
                rts
t_move6:        andi.w  #7,D0
                ori.w   #$4E60,D0
                move.w  D0,14(A3)
                rts
t_move7:        ori.w   #$2040,D0
                move.w  D0,14(A3)
                andi.w  #7,D1
                add.w   D1,D1
                or.b    D1,14(A3)
                rts

t_movem:        moveq   #0,D3
                moveq   #0,D0
                lea     18(A3),A2
                bsr     get_datareg
                bpl.s   t_movem2
                bsr     get_adrreg
                bpl.s   t_movem21
                addq.w  #2,(A3)
                move.w  #$1E13,D1
                bsr     get_ea
                ori.w   #$4C80,14(A3)
                bsr     chk_com
                moveq   #0,D3
                bra.s   t_movem3
t_movem21:      addq.w  #8,D0
                moveq   #8,D4
t_movem2:       bsr.s   t_movem31
                addq.w  #2,(A3)
                bsr     chk_com
                move.w  #$1F0B,D1
                bsr     get_ea
                ori.w   #$4880,14(A3)
                move.w  14(A3),D0
                andi.w  #$38,D0
                cmp.w   #$20,D0
                bne.s   t_movem8
                move.w  16(A3),D3
                moveq   #15,D0
t_loop:         addx.w  D3,D3
                roxr.w  16(A3)
                dbra    D0,t_loop
t_movem8:       rts
t_movem3:       bsr.s   t_movem4
                moveq   #8,D4
                and.w   D0,D4
t_movem31:      bset    D0,D3
                move.w  D0,D1
                move.b  (A0)+,D0
                cmp.w   #'/',D0
                beq.s   t_movem3
                cmp.w   #'-',D0
                bne.s   t_movem5
                bsr.s   t_movem4
                moveq   #8,D4
                and.w   D0,D4
                cmp.w   D0,D1
                bge     op_error
t_movem6:       bset    D0,D3
                subq.w  #1,D0
                cmp.w   D1,D0
                bgt.s   t_movem6
                move.b  (A0)+,D0
                cmp.w   #'/',D0
                beq.s   t_movem3
t_movem5:       cmp.w   #'0'-1,D0
                bhi     op_error
                subq.l  #1,A0
                move.w  D3,16(A3)
                rts
t_movem4:       bsr     get_datareg
                bpl.s   t_movem7
                bsr     get_adrreg
                bmi.s   t_movem70
                ori.w   #8,D0
t_movem7:       rts
t_movem70:      bsr     get_datareg3
                or.w    D4,D0
                rts

t_movep:        bsr     get_datareg
                bmi.s   t_movep2
                add.w   D0,D0
                or.b    D0,14(A3)
                bset    #7,15(A3)
                bsr     cut_space
                cmpi.b  #',',(A0)+
                bne     ea_error
                bsr     cut_space
                moveq   #2,D5
                bsr.s   t_movep4
                or.b    D0,15(A3)
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                rts
t_movep2:       move.w  #$1FEF,D1                 ;Speicher zu Register
                bsr.s   t_movep4
                or.b    D0,15(A3)
                move.w  D3,(A2)+
                addq.w  #2,(A3)
                bsr     chk_com
                bsr     get_datareg
                bmi     op_error
                add.w   D0,D0
                or.b    D0,14(A3)
                rts
t_movep4:       moveq   #0,D3
                cmpi.b  #'(',(A0)
                beq     get_indirect2
                bsr     get_wert
                cmp.l   #$FFFF,D3
                bhi     val_error
                bra     get_indirect2

t_moveq:        cmpi.b  #'#',(A0)+
                bsr     get_wert
                tst.b   2(A3,D5.w)
                bne.s   t_moveq2
                move.b  D3,15(A3)
t_moveq3:       bsr     chk_com
                bsr     get_datareg
                bmi     op_error
                add.w   D0,D0
                or.b    D0,14(A3)
                rts
t_moveq2:       bsr.s   get_quick
                bra.s   t_moveq3

get_quick:      move.w  D3,2(A3,D5.w)
                ori.b   #$C0,2(A3,D5.w)
                rts

t_nop:          rts

t_pea:          move.w  #$1E1B,D1
                bsr     get_ea
                rts

t_stop:         cmpi.b  #'#',(A0)+
                bne     op_error
                bsr     get_wert
                move.w  D3,(A2)
                move.b  #4,1(A3)
                rts

t_linea:        cmpi.b  #'#',(A0)
                bne.s   t_line2
                addq.l  #1,A0
t_line2:        bsr     get_wert
                tst.b   2(A3,D5.w)
                bne     syntax_error
                cmp.l   #15,D3
                bhi     val_error
                or.b    D3,15(A3)
                bsr     cut_space
t_line3:        move.b  (A0)+,D0
                beq.s   t_line4
                cmp.b   #';',D0
                bne.s   t_line3
t_line4:        subq.w  #1,A0
                rts

t_trap:         cmpi.b  #'#',(A0)
                bne.s   t_trap2
                addq.l  #1,A0
t_trap2:        bsr     get_wert
                tst.b   2(A3,D5.w)
                bne.s   t_trap3
                cmp.l   #15,D3
                bhi     op_error
                or.b    D3,15(A3)
                rts
t_trap3:        bsr     get_quick
                rts

t_unlk:         bsr.s   get_adrreg
                bmi     op_error
                or.b    D0,15(A3)
                rts

;************************************************************************
;*  holt ein Adressregister ab A0 nach D0                               *
;*  wenn Fehler, D0 = -1 und A0 wird rekonstruiert                      *
;************************************************************************
get_adrreg:     move.b  (A0)+,D0
                cmp.b   #'A',D0
                beq.s   get_adrreg4
                cmp.b   #'a',D0
                beq.s   get_adrreg4
                cmp.b   #'s',D0
                beq.s   get_adrreg2
                cmp.b   #'S',D0
                beq.s   get_adrreg2
                subq.w  #1,A0                     ;kein Adressregister -> -1
                moveq   #-1,D0
                rts
get_adrreg2:    move.b  (A0)+,D0
                cmp.b   #'p',D0
                beq.s   get_adrreg3
                cmp.b   #'P',D0
                beq.s   get_adrreg3
                subq.w  #2,A0
                moveq   #-1,D0
                rts
get_adrreg3:    moveq   #7,D0
                cmpi.b  #'0',(A0)
                bls.s   get_adrreg6               ;folgendes Zeichen < '0'->kein Label
get_adrreg5:    subq.w  #2,A0
                moveq   #-1,D0
                rts
get_adrreg4:    moveq   #0,D0
                move.b  (A0)+,D0
                subi.w  #'0',D0
                bmi.s   get_adrreg5               ;keine Ziffer
                cmp.w   #7,D0
                bgt.s   get_adrreg5               ;keine Ziffer
                cmpi.b  #'0',(A0)
                bhi.s   get_adrreg5
get_adrreg6:    tst.w   D0
                rts

;************************************************************************
;* holt ein Datenregister ab A0 nach D0                                 *
;************************************************************************
get_datareg:    cmpi.b  #'D',(A0)
                beq.s   get_datareg2
                cmpi.b  #'d',(A0)
                beq.s   get_datareg2
                moveq   #-1,D0                    ;kein Datenregister
                rts
get_datareg2:   addq.w  #1,A0
get_datareg3:   moveq   #0,D0
                move.b  (A0)+,D0
                subi.w  #'0',D0
                bmi.s   get_adrreg5
                cmp.w   #7,D0
                bgt.s   get_adrreg5
                cmpi.b  #'0',(A0)
                bhi.s   get_adrreg5
                tst.w   D0
                rts

get_regnr:      addq.l  #1,A0
                move.b  (A0)+,D0
                subi.b  #$30,D0
                bmi.s   regnr_err
                cmp.b   #7,D0
                bgt.s   regnr_err
                andi.w  #7,D0
                rts
regnr_err:      moveq   #-10,D0
                bra     operant_err
get_regnr2:     move.b  1(A0),D0
                sub.b   #$30,D0
                bmi.s   get_regnr3
                cmp.b   #7,D0
                bgt.s   get_regnr3
                cmpi.b  #'0',2(A0)                ;Folgezeichen testen
                bhs.s   get_regnr3
                addq.l  #2,A0
                rts
get_regnr3:     addq.w  #4,SP
                bra     failed

;************************************************************************
;*  testet unmittelbaren Wert auf die vom Opcode gegebenen Breite und   *
;*  schreibt Wert in Puffer                                             *
;************************************************************************
set_imidiate:   move.b  D4,D0                     ;Daten für unmittelbaren Operanten aus
                beq.s   set_imi1                  ;Befehlstabelle
                bmi.s   set_imi3
                cmp.b   #3,D0
                bhi.s   set_imi3
                beq.s   tst_word
                cmp.w   #1,D0
                beq.s   tst_byte
                bra.s   set_imi2
set_imi3:       btst    #0,14(A3)
                beq.s   tst_word
                bra.s   set_imi2
set_imi1:       move.b  15(A3),D0
                rol.b   #2,D0
                andi.w  #3,D0
                beq.s   tst_byte
                cmp.b   #1,D0
                beq.s   tst_word
                cmp.b   #2,D0
                bne     syn_error
set_imi2:       tst.b   2(A3,D5.w)
                beq.s   kein_lab4
                move.b  1(A3),3(A3,D5.w)
                ori.w   #$20,2(A3,D5.w)
kein_lab4:      addq.w  #4,(A3)
                move.l  D3,(A2)+
                rts
tst_byte:       tst.b   2(A3,D5.w)
                beq.s   tst_by1
                move.b  1(A3),3(A3,D5.w)
                bra.s   tst_esc
tst_by1:        move.l  D3,D0
                clr.b   D0
                tst.l   D0
                beq.s   tst_esc
                move.l  D3,D0
                ext.w   D0
                ext.l   D0
                cmp.l   D0,D3
                bne.s   val_error
                and.w   #$FF,D3
                bra.s   tst_esc
tst_word:       tst.b   2(A3,D5.w)
                beq.s   tst_wo1
                move.b  1(A3),3(A3,D5.w)
                ori.w   #$10,2(A3,D5.w)
                bra.s   tst_esc
tst_wo1:        move.l  D3,D0
                swap    D0
                tst.w   D0
                beq.s   tst_esc
                move.l  D3,D0
                ext.l   D0
                cmp.l   D0,D3
                bne.s   val_error
tst_esc:        addq.w  #2,(A3)
                move.w  D3,(A2)+
                rts
val_error:      moveq   #-5,D0

                bra     operant_err

;************************************************************************
;* holt Adressregister in Klammern                                      *
;************************************************************************
get_indirect:   addq.l  #1,A0
get_indirect2:  cmpi.b  #'(',(A0)+
                bne     op_error
                bsr     get_adrreg
                bmi     op_error
                cmpi.b  #')',(A0)+
                bne     op_error
                rts

;************************************************************************
;* holt <EA>, und odert sie in den Opcode                               *
;* Bitplane in D1 gibt die erlaubten EAs an                             *
;************************************************************************
get_ea:         moveq   #0,D3
                move.l  D0,-(SP)
                andi.w  #$FFC0,14(A3)             ;EA-Bits l”schen
                move.b  (A0),D0
                cmp.b   #'#',D0
                beq     immidiate
                cmp.b   #'D',D0
                beq     data_reg
                cmp.b   #'d',D0
                beq     data_reg
                cmp.b   #'A',D0
                beq     adr_reg
                cmp.b   #'a',D0
                beq     adr_reg
                cmp.b   #'(',D0
                beq     indirect
                cmp.b   #'-',D0
                beq     predecrement
                cmp.b   #'C',D0
                beq     __ccr
                cmp.b   #'c',D0
                beq     __ccr
                cmp.b   #'S',D0
                beq     __sr
                cmp.b   #'s',D0
                beq     __sr
                cmp.b   #'U',D0
                beq     __usp
                cmp.b   #'u',D0
                beq     __usp
failed:         bsr     get_wert
                cmpi.b  #'(',(A0)
                beq     indirect2
                tst.b   D1
                bmi     ea_error
                cmpi.b  #'.',(A0)
                bne.s   adr_long
                addq.l  #1,A0
                move.b  (A0)+,D0
                cmp.b   #'L',D0
                beq.s   adr_long
                cmp.b   #'l',D0
                beq.s   adr_long
                cmp.b   #'W',D0
                beq.s   adr_short
                cmp.b   #'w',D0
                beq.s   adr_short
                cmp.b   #'s',D0
                beq.s   adr_short
                cmp.b   #'S',D0
                bne     syn_error
adr_short:      ori.b   #%111000,15(A3)
                tst.b   2(A3,D5.w)
                beq.s   kein_lab3b
                move.b  1(A3),3(A3,D5.w)
                ori.w   #$10,2(A3,D5.w)
kein_lab3b:     addq.w  #2,(A3)
                move.w  D3,(A2)+
                move.l  (SP)+,D0
                rts
adr_long:       ori.b   #%111001,15(A3)
                tst.b   2(A3,D5.w)
                beq.s   kein_lab3
                move.b  1(A3),3(A3,D5.w)
                ori.w   #$20,2(A3,D5.w)
kein_lab3:      addq.w  #4,(A3)
                move.l  D3,(A2)+
                move.l  (SP)+,D0
                rts
__usp:          cmpi.b  #'s',1(A0)
                beq.s   _usp2
                cmpi.b  #'S',1(A0)
                bne     failed
_usp2:          cmpi.b  #'p',2(A0)
                beq.s   _usp3
                cmpi.b  #'P',2(A0)
                bne     failed
_usp3:          cmpi.b  #'0'-1,3(A0)
                bhi     failed
                btst    #12,D1
                bne     ea_error
                move.b  #$3F,15(A3)
                addq.l  #3,A0
                move.l  (SP)+,D0
                rts
__ccr:          cmpi.b  #'c',1(A0)
                beq.s   _ccr2
                cmpi.b  #'C',1(A0)
                bne     failed
_ccr2:          cmpi.b  #'r',2(A0)
                beq.s   _ccr3
                cmpi.b  #'R',2(A0)
                bne     failed
_ccr3:          cmpi.b  #'0'-1,3(A0)
                bhi     failed
                btst    #10,D1
                bne     ea_error
                move.b  #%111100,15(A3)
                addq.l  #3,A0
                move.l  (SP)+,D0
                rts
__sr:           cmpi.b  #'P',1(A0)
                beq.s   _sp
                cmpi.b  #'p',1(A0)
                beq.s   _sp
                cmpi.b  #'r',1(A0)
                beq.s   _sr2
                cmpi.b  #'R',1(A0)
                bne     failed
_sr2:           cmpi.b  #'0'-1,2(A0)
                bhi     failed
                btst    #11,D1
                bne     ea_error
                move.b  #%1111100,15(A3)
                addq.l  #2,A0
                move.l  (SP)+,D0
                rts
_sp:            cmpi.b  #'0'-1,2(A0)
                bhi     failed
                moveq   #7,D0
                addq.l  #2,A0
                bra.s   adr_re2
data_reg:       bsr     get_regnr2
                btst    #0,D1
                bne     ea_error
                or.b    D0,15(A3)
                move.l  (SP)+,D0
                rts
adr_reg:        bsr     get_regnr2
adr_re2:        btst    #1,D1
                bne.s   ea_error
                ori.b   #%1000,D0
                or.b    D0,15(A3)
                move.l  (SP)+,D0
                rts
immidiate:      addq.l  #1,A0
                btst    #9,D1
                bne.s   ea_error
                bsr     get_wert
                bsr     set_imidiate
                ori.w   #%111100,14(A3)
                move.l  (SP)+,D0
                rts
_sp2:           addq.l  #1,A0
                move.b  (A0)+,D0
                cmp.b   #'p',D0
                beq.s   _sp3
                cmp.b   #'P',D0
                bne     syn_error
_sp3:           moveq   #7,D0
                bra.s   ind_sp
indirect:       addq.l  #1,A0
                cmpi.b  #'S',(A0)
                beq.s   _sp2
                cmpi.b  #'s',(A0)
                beq.s   _sp2
                cmpi.b  #'a',(A0)
                beq.s   adr_rel
                cmpi.b  #'A',(A0)
                bne.s   pc_rel
adr_rel:        bsr     get_regnr
ind_sp:         cmpi.b  #')',(A0)+
                bne     second_reg
                cmpi.b  #'+',(A0)
                beq.s   increment
                btst    #2,D1
                bne.s   ea_error
                ori.b   #%10000,D0
                or.b    D0,15(A3)
                move.l  (SP)+,D0
                rts
ea_error:       moveq   #-7,D0
                bra     operant_err
increment:      addq.l  #1,A0
                btst    #3,D1
                bne.s   ea_error
                ori.b   #%11000,D0
                or.b    D0,15(A3)
                move.l  (SP)+,D0
                rts
predecrement:   cmpi.b  #'(',1(A0)
                beq.s   pre2
                bra     failed
pre2:           btst    #4,D1
                bne.s   ea_error
                addq.w  #2,A0
                bsr     get_adrreg
                bmi     op_error
                cmpi.b  #')',(A0)+
                bne.s   syn_error
                ori.b   #%100000,D0
                or.b    D0,15(A3)
                move.l  (SP)+,D0
                rts
syn_error:      moveq   #-8,D0
                bra     operant_err
pc_rel:         cmpi.b  #'p',(A0)
                beq.s   pc_rel2
                cmpi.b  #'P',(A0)
                beq.s   pc_rel2
                subq.w  #1,A0
                bra     failed
pc_rel2:        btst    #8,D1
                bne.s   ea_error
                addq.w  #1,A0
                move.b  (A0)+,D0
                cmp.b   #'c',D0
                beq.s   pc_rel3
                cmp.b   #'C',D0
                bne.s   syn_error
pc_rel3:        cmpi.b  #')',(A0)+
                beq.s   no_second
                sub.l   default_adr(A4),D3
                moveq   #0,D0
                move.w  (A3),D0                   ;akt.-L„nge holen
                sub.l   D0,D3
                move.b  D3,D0
                ext.w   D0
                ext.l   D0
                cmp.l   D3,D0
                bne     val_error
                bsr     get_second
                ori.b   #%111011,15(A3)
                addq.w  #2,(A3)                   ;xx(PC,Xn)
                move.l  (SP)+,D0
                rts
no_second:      ori.b   #%111010,15(A3)
                sub.l   default_adr(A4),D3
                moveq   #0,D0
                move.w  (A3),D0
                sub.l   D0,D3
                move.w  D3,D0
                ext.l   D0
                cmp.l   D3,D0
                bne     val_error
                move.w  D3,(A2)+
                addq.w  #2,(A3)                   ;xxxx(PC)
                move.l  (SP)+,D0
                rts
indirect2:      addq.l  #1,A0
                bsr.s   tst_sp
                cmp.w   #7,D0
                beq.s   indirect4
                cmpi.b  #'a',(A0)
                beq.s   indirect3
                cmpi.b  #'A',(A0)
                beq.s   indirect3
                bne     pc_rel
indirect3:      bsr     get_regnr
indirect4:      cmpi.b  #')',(A0)+
                beq.s   no_second2
second_reg:     btst    #6,D1
                bne     ea_error
                ori.b   #%110000,D0
                or.b    D0,15(A3)                 ;xx(Ax,Xn)
                bsr.s   get_second
                addq.w  #2,(A3)
                move.l  (SP)+,D0
                rts

no_second2:     btst    #5,D1
                bne     ea_error
                ori.b   #%101000,D0
                or.b    D0,15(A3)
                swap    D3
                tst.w   D3
                beq.s   no_sec3                   ;0 oder -1 sind im oberen Byte erlaubt
                addq.w  #1,D3
                bne     val_error
no_sec3:        swap    D3
                move.w  D3,(A2)+                  ;xxxx(Ax)
                addq.w  #2,(A3)
                move.l  (SP)+,D0
                rts

tst_sp:         moveq   #0,D0
                cmpi.b  #'S',(A0)
                beq.s   _sp5
                cmpi.b  #'s',(A0)
                beq.s   _sp5
                rts
_sp5:           addq.w  #1,A0
                move.b  (A0)+,D0
                cmp.b   #'P',D0
                beq.s   _sp4
                cmp.b   #'p',D0
                bne     syn_error
_sp4:           moveq   #7,D0
                rts

get_second:     cmpi.b  #'D',(A0)
                beq.s   dat_reg
                cmpi.b  #'d',(A0)
                beq.s   dat_reg
                bset    #7,(A2)
                bsr.s   tst_sp
                cmp.w   #7,D0
                beq.s   sp_reg
                cmpi.b  #'a',(A0)
                beq.s   dat_reg
                cmpi.b  #'A',(A0)
                bne     syn_error
dat_reg:        bsr     get_regnr
sp_reg:         lsl.b   #4,D0
                or.b    D0,(A2)
                cmpi.b  #')',(A0)
                beq.s   end_reg
                cmpi.b  #'.',(A0)+
                bne     syn_error
                cmpi.b  #'W',(A0)
                beq.s   end_re2
                cmpi.b  #'w',(A0)
                beq.s   end_re2
                cmpi.b  #'l',(A0)
                beq.s   end_re3
                cmpi.b  #'L',(A0)
                bne     syn_error
end_re3:        bset    #3,(A2)
end_re2:        addq.l  #1,A0
                cmpi.b  #')',(A0)
                bne     syn_error
end_reg:        addq.l  #1,A0
                tst.b   2(A3,D5.w)
                bne.s   end_reg2
                cmp.l   #$FF,D3
                bls.s   end_reg2
                move.b  D3,D0
                ext.w   D0
                ext.l   D0
                cmp.l   D3,D0
                bne     val_error
end_reg2:       move.b  D3,1(A2)
                addq.l  #2,A2
                rts

;************************************************************************
;* Bin„re Suchroutine                                                   *
;************************************************************************
search:         movem.l D0-D7/A2-A6,-(SP)
                movea.l A0,A6                     ;Textpointer merken
                lea     spaced(A4),A3
                move.l  #'    ',(A3)
                move.l  #'    ',4(A3)             ;Buffer l”schen
                lea     search_tab(PC),A5
                moveq   #7,D0                     ;max.7 Zeichen holen
                moveq   #0,D1
search1:        move.b  (A0)+,D1                  ;Zeichen holen
                move.b  0(A5,D1.w),D1             ;& konvertieren
                beq.s   search4                   ;
                move.b  D1,(A3)+                  ;Ab in den Buffer
                dbra    D0,search1
                bra.s   search3
search4:        subq.l  #1,A0                     ;Pointer zurück (auf das 1.Zeichen dahinter)
search3:        move.l  spaced(A4),D5             ;die vorderen 4 Zeichen holen (=> Buffer)
                move.l  spaced+4(A4),D6           ;die hinteren 4 Zeichen holen
                lea     code_tab(PC),A1
                moveq   #0,D1
                move.w  tablen(A4),D2
search2:        move.w  D1,D4
                add.w   D2,D4
                lsr.w   #1,D4
                move.w  D4,D0
                lsl.w   #4,D0                     ;mal 16 (L„nge eines Eintrags)
                cmp.l   0(A1,D0.w),D5
                bhi.s   search6
                bne.s   search5
                cmp.l   4(A1,D0.w),D6
                bhi.s   search6
                bne.s   search5
                lea     0(A1,D0.w),A1
                movem.l (SP)+,D0-D7/A2-A6
                rts
search5:        move.w  D4,D2
                cmp.w   D1,D2
                bne.s   search2
                bra.s   search7
search6:        move.w  D4,D1
                addq.w  #1,D1
                cmp.w   D1,D2
                bne.s   search2
search7:        suba.l  A1,A1
                movea.l A6,A0                     ;Pointer zurück
                movem.l (SP)+,D0-D7/A2-A6
                rts

search_tab:    DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,'.',0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,'ABCDEFGHIJKLMNO'
               DC.B 'PQRSTUVWXYZ',0,0,0,0,0
               DC.B 0,'ABCDEFGHIJKLMNO'
               DC.B 'PQRSTUVWXYZ',0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;************************************************************************
;* holt einen Wert (Zahl oder Variable) nach d3                         *
;************************************************************************
get_wert:       movem.l D0-D2/D4-D7/A1-A6,-(SP)
                bsr     get
                bsr     get_term
                move.b  D0,-(A0)
                move.l  D1,D3
                movem.l (SP)+,D0-D2/D4-D7/A1-A6
                rts

;************************************************************************
;* Spaces ab A0 berlesen                                               *
;************************************************************************
cut_space:      cmpi.b  #' ',(A0)+
                beq.s   cut_space
                subq.w  #1,A0
                rts

;************************************************************************
;* Hier steht die Tabelle aller Befehle & Opcodes                       *
;************************************************************************
;>               DXSET 8,' '
code_tab:      DC.B 'ABCD    '
               DC.L t_abcd
               DC.B 0,0,$C1,0
               DC.B 'ADD     '
               DC.L t_add
               DC.B 0,0,$D0,$40
               DC.B 'ADD.B   '
               DC.L t_add
               DC.B 0,0,$D0,0
               DC.B 'ADD.L   '
               DC.L t_add
               DC.B 0,0,$D0,$80
               DC.B 'ADD.W   '
               DC.L t_add
               DC.B 0,0,$D0,$40
               DC.B 'ADDA    '
               DC.L t_adda
               DC.B 0,$80,$D0,$C0
               DC.B 'ADDA.L  '
               DC.L t_adda
               DC.B 0,$80,$D1,$C0
               DC.B 'ADDA.W  '
               DC.L t_adda
               DC.B 0,$80,$D0,$C0
               DC.B 'ADDI    '
               DC.L t_addi
               DC.B 0,0,6,$40
               DC.B 'ADDI.B  '
               DC.L t_addi
               DC.B 0,0,6,0
               DC.B 'ADDI.L  '
               DC.L t_addi
               DC.B 0,0,6,$80
               DC.B 'ADDI.W  '
               DC.L t_addi
               DC.B 0,0,6,$40
               DC.B 'ADDQ    '
               DC.L t_addq
               DC.B 0,0,$50,$40
               DC.B 'ADDQ.B  '
               DC.L t_addq
               DC.B 0,0,$50,0
               DC.B 'ADDQ.L  '
               DC.L t_addq
               DC.B 0,0,$50,$80
               DC.B 'ADDQ.W  '
               DC.L t_addq
               DC.B 0,0,$50,$40
               DC.B 'ADDX    '
               DC.L t_abcd
               DC.B 0,0,$D1,$40
               DC.B 'ADDX.B  '
               DC.L t_abcd
               DC.B 0,0,$D1,0
               DC.B 'ADDX.L  '
               DC.L t_abcd
               DC.B 0,0,$D1,$80
               DC.B 'ADDX.W  '
               DC.L t_abcd
               DC.B 0,0,$D1,$40
               DC.B 'AND     '
               DC.L t_and
               DC.B 0,0,$C0,$40
               DC.B 'AND.B   '
               DC.L t_and
               DC.B 0,0,$C0,0
               DC.B 'AND.L   '
               DC.L t_and
               DC.B 0,0,$C0,$80
               DC.B 'AND.W   '
               DC.L t_and
               DC.B 0,0,$C0,$40
               DC.B 'ANDI    '
               DC.L t_andi
               DC.B 0,0,2,$40
               DC.B 'ANDI.B  '
               DC.L t_andi
               DC.B 0,0,2,0
               DC.B 'ANDI.L  '
               DC.L t_andi
               DC.B 0,0,2,$80
               DC.B 'ANDI.W  '
               DC.L t_andi
               DC.B 0,0,2,$40
               DC.B 'ASL     '
               DC.L t_asl
               DC.B 0,0,$E1,$40
               DC.B 'ASL.B   '
               DC.L t_asl
               DC.B 0,0,$E1,0
               DC.B 'ASL.L   '
               DC.L t_asl
               DC.B 0,0,$E1,$80
               DC.B 'ASL.W   '
               DC.L t_asl
               DC.B 0,0,$E1,$40
               DC.B 'ASR     '
               DC.L t_asl
               DC.B 0,0,$E0,$40
               DC.B 'ASR.B   '
               DC.L t_asl
               DC.B 0,0,$E0,0
               DC.B 'ASR.L   '
               DC.L t_asl
               DC.B 0,0,$E0,$80
               DC.B 'ASR.W   '
               DC.L t_asl
               DC.B 0,0,$E0,$40
               DC.B 'BCC     '
               DC.L t_bcc
               DC.B 0,0,$64,0
               DC.B 'BCC.S   '
               DC.L t_bccs
               DC.B 0,0,$64,0
               DC.B 'BCC.W   '
               DC.L t_bcc
               DC.B 0,0,$64,0
               DC.B 'BCHG    '
               DC.L t_bchg
               DC.B 0,0,1,$40
               DC.B 'BCHG.B  '
               DC.L t_bchg
               DC.B 0,0,1,$40
               DC.B 'BCHG.L  '
               DC.L t_bchg
               DC.B 0,0,1,$40
               DC.B 'BCLR    '
               DC.L t_bchg
               DC.B 0,0,1,$80
               DC.B 'BCLR.B  '
               DC.L t_bchg   
               DC.B 0,0,1,$80
               DC.B 'BCLR.L  '
               DC.L t_bchg
               DC.B 0,0,1,$80
               DC.B 'BCS     '
               DC.L t_bcc
               DC.B 0,0,$65,0
               DC.B 'BCS.S   '
               DC.L t_bccs
               DC.B 0,0,$65,0
               DC.B 'BCS.W   '
               DC.L t_bcc
               DC.B 0,0,$65,0
               DC.B 'BEQ     '
               DC.L t_bcc
               DC.B 0,0,$67,0
               DC.B 'BEQ.S   '
               DC.L t_bccs
               DC.B 0,0,$67,0
               DC.B 'BEQ.W   '
               DC.L t_bcc
               DC.B 0,0,$67,0
               DC.B 'BGE     '
               DC.L t_bcc
               DC.B 0,0,$6C,0
               DC.B 'BGE.S   '
               DC.L t_bccs
               DC.B 0,0,$6C,0
               DC.B 'BGE.W   '
               DC.L t_bcc
               DC.B 0,0,$6C,0
               DC.B 'BGT     '
               DC.L t_bcc
               DC.B 0,0,$6E,0
               DC.B 'BGT.S   '
               DC.L t_bccs
               DC.B 0,0,$6E,0
               DC.B 'BGT.W   '
               DC.L t_bcc
               DC.B 0,0,$6E,0
               DC.B 'BHI     '
               DC.L t_bcc
               DC.B 0,0,$62,0
               DC.B 'BHI.S   '
               DC.L t_bccs
               DC.B 0,0,$62,0
               DC.B 'BHI.W   '
               DC.L t_bcc
               DC.B 0,0,$62,0
               DC.B 'BHS     '
               DC.L t_bcc
               DC.B 0,0,$64,0
               DC.B 'BHS.S   '
               DC.L t_bccs
               DC.B 0,0,$64,0
               DC.B 'BHS.W   '
               DC.L t_bcc
               DC.B 0,0,$64,0
               DC.B 'BLE     '
               DC.L t_bcc
               DC.B 0,0,$6F,0
               DC.B 'BLE.S   '
               DC.L t_bccs
               DC.B 0,0,$6F,0
               DC.B 'BLE.W   '
               DC.L t_bcc
               DC.B 0,0,$6F,0
               DC.B 'BLO     '
               DC.L t_bcc
               DC.B 0,0,$65,0
               DC.B 'BLO.S   '
               DC.L t_bccs
               DC.B 0,0,$65,0
               DC.B 'BLO.W   '
               DC.L t_bcc
               DC.B 0,0,$65,0
               DC.B 'BLS     '
               DC.L t_bcc
               DC.B 0,0,$63,0
               DC.B 'BLS.S   '
               DC.L t_bccs
               DC.B 0,0,$63,0
               DC.B 'BLS.W   '
               DC.L t_bcc
               DC.B 0,0,$63,0
               DC.B 'BLT     '
               DC.L t_bcc
               DC.B 0,0,$6D,0
               DC.B 'BLT.S   '
               DC.L t_bccs
               DC.B 0,0,$6D,0
               DC.B 'BLT.W   '
               DC.L t_bcc
               DC.B 0,0,$6D,0
               DC.B 'BMI     '
               DC.L t_bcc
               DC.B 0,0,$6B,0
               DC.B 'BMI.S   '
               DC.L t_bccs
               DC.B 0,0,$6B,0
               DC.B 'BMI.W   '
               DC.L t_bcc
               DC.B 0,0,$6B,0
               DC.B 'BNE     '
               DC.L t_bcc
               DC.B 0,0,$66,0
               DC.B 'BNE.S   '
               DC.L t_bccs
               DC.B 0,0,$66,0
               DC.B 'BNE.W   '
               DC.L t_bcc
               DC.B 0,0,$66,0
               DC.B 'BNZ     '
               DC.L t_bcc
               DC.B 0,0,$66,0
               DC.B 'BNZ.S   '
               DC.L t_bccs
               DC.B 0,0,$66,0
               DC.B 'BNZ.W   '
               DC.L t_bcc
               DC.B 0,0,$66,0
               DC.B 'BPL     '
               DC.L t_bcc     
               DC.B 0,0,$6A,0 
               DC.B 'BPL.S   '
               DC.L t_bccs    
               DC.B 0,0,$6A,0 
               DC.B 'BPL.W   '
               DC.L t_bcc     
               DC.B 0,0,$6A,0 
               DC.B 'BRA     '
               DC.L t_bcc     
               DC.B 0,0,$60,0 
               DC.B 'BRA.S   '
               DC.L t_bccs    
               DC.B 0,0,$60,0 
               DC.B 'BRA.W   '
               DC.L t_bcc     
               DC.B 0,0,$60,0 
               DC.B 'BSET    '
               DC.L t_bchg    
               DC.B 0,0,1,$C0 
               DC.B 'BSET.B  '
               DC.L t_bchg    
               DC.B 0,0,1,$C0 
               DC.B 'BSET.L  '
               DC.L t_bchg    
               DC.B 0,0,1,$C0 
               DC.B 'BSR     '
               DC.L t_bcc     
               DC.B 0,0,$61,0 
               DC.B 'BSR.S   '
               DC.L t_bccs    
               DC.B 0,0,$61,0 
               DC.B 'BSR.W   '
               DC.L t_bcc     
               DC.B 0,0,$61,0 
               DC.B 'BTST    '
               DC.L t_btst    
               DC.B 0,0,1,0   
               DC.B 'BTST.B  '
               DC.L t_btst
               DC.B 0,0,1,0
               DC.B 'BTST.L  '
               DC.L t_btst    
               DC.B 0,0,1,0   
               DC.B 'BVC     '
               DC.L t_bcc     
               DC.B 0,0,$68,0 
               DC.B 'BVC.S   '
               DC.L t_bccs    
               DC.B 0,0,$68,0 
               DC.B 'BVC.W   '
               DC.L t_bcc     
               DC.B 0,0,$68,0 
               DC.B 'BVS     '
               DC.L t_bcc     
               DC.B 0,0,$69,0 
               DC.B 'BVS.S   '
               DC.L t_bccs    
               DC.B 0,0,$69,0 
               DC.B 'BVS.W   '
               DC.L t_bcc     
               DC.B 0,0,$69,0 
               DC.B 'BZ      '
               DC.L t_bcc     
               DC.B 0,0,$67,0 
               DC.B 'BZ.S    '
               DC.L t_bccs    
               DC.B 0,0,$67,0 
               DC.B 'BZ.W    '
               DC.L t_bcc     
               DC.B 0,0,$67,0 
               DC.B 'BZE     '
               DC.L t_bcc     
               DC.B 0,0,$67,0 
               DC.B 'BZE.S   '
               DC.L t_bccs    
               DC.B 0,0,$67,0 
               DC.B 'BZE.W   '
               DC.L t_bcc     
               DC.B 0,0,$67,0 
               DC.B 'CHK     '
               DC.L t_chk
               DC.B 0,3,$41,$80
               DC.B 'CLR     '
               DC.L t_clr
               DC.B 0,0,$42,$40
               DC.B 'CLR.B   '
               DC.L t_clr
               DC.B 0,0,$42,0
               DC.B 'CLR.L   '
               DC.L t_clr
               DC.B 0,0,$42,$80
               DC.B 'CLR.W   '
               DC.L t_clr
               DC.B 0,0,$42,$40
               DC.B 'CMP     '
               DC.L t_cmp
               DC.B 0,0,$B0,$40
               DC.B 'CMP.B   '
               DC.L t_cmp
               DC.B 0,0,$B0,0
               DC.B 'CMP.L   '
               DC.L t_cmp
               DC.B 0,0,$B0,$80
               DC.B 'CMP.W   '
               DC.L t_cmp
               DC.B 0,0,$B0,$40
               DC.B 'CMPA    '
               DC.L t_adda
               DC.B 0,$80,$B0,$C0
               DC.B 'CMPA.L  '
               DC.L t_adda
               DC.B 0,$80,$B1,$C0
               DC.B 'CMPA.W  '
               DC.L t_adda
               DC.B 0,$80,$B0,$C0
               DC.B 'CMPI    '
               DC.L t_addi
               DC.B 0,0,$0C,$40
               DC.B 'CMPI.B  '
               DC.L t_addi
               DC.B 0,0,$0C,0
               DC.B 'CMPI.L  '
               DC.L t_addi
               DC.B 0,0,$0C,$80
               DC.B 'CMPI.W  '
               DC.L t_addi
               DC.B 0,0,$0C,$40
               DC.B 'CMPM    '
               DC.L t_cmpm
               DC.B 0,0,$B1,$48
               DC.B 'CMPM.B  '
               DC.L t_cmpm
               DC.B 0,0,$B1,8
               DC.B 'CMPM.L  '
               DC.L t_cmpm
               DC.B 0,0,$B1,$88
               DC.B 'CMPM.W  '
               DC.L t_cmpm
               DC.B 0,0,$B1,$48
               DC.B 'DBCC    '
               DC.L t_dbcc
               DC.B 0,0,$54,$C8
               DC.B 'DBCS    '
               DC.L t_dbcc
               DC.B 0,0,$55,$C8
               DC.B 'DBEQ    '
               DC.L t_dbcc
               DC.B 0,0,$57,$C8
               DC.B 'DBF     '
               DC.L t_dbcc
               DC.B 0,0,$51,$C8
               DC.B 'DBGE    '
               DC.L t_dbcc
               DC.B 0,0,$5C,$C8
               DC.B 'DBGT    '
               DC.L t_dbcc
               DC.B 0,0,$5E,$C8
               DC.B 'DBHI    '
               DC.L t_dbcc
               DC.B 0,0,$52,$C8
               DC.B 'DBHS    '
               DC.L t_dbcc
               DC.B 0,0,$54,$C8
               DC.B 'DBLE    '
               DC.L t_dbcc
               DC.B 0,0,$5F,$C8
               DC.B 'DBLO    '
               DC.L t_dbcc
               DC.B 0,0,$55,$C8
               DC.B 'DBLS    '
               DC.L t_dbcc
               DC.B 0,0,$53,$C8
               DC.B 'DBLT    '
               DC.L t_dbcc
               DC.B 0,0,$5D,$C8
               DC.B 'DBMI    '
               DC.L t_dbcc
               DC.B 0,0,$5B,$C8
               DC.B 'DBNE    '
               DC.L t_dbcc
               DC.B 0,0,$56,$C8
               DC.B 'DBNZ    '
               DC.L t_dbcc
               DC.B 0,0,$56,$C8
               DC.B 'DBPL    '
               DC.L t_dbcc
               DC.B 0,0,$5A,$C8
               DC.B 'DBRA    '
               DC.L t_dbcc
               DC.B 0,0,$51,$C8
               DC.B 'DBT     '
               DC.L t_dbcc
               DC.B 0,0,$50,$C8
               DC.B 'DBVC    '
               DC.L t_dbcc
               DC.B 0,0,$58,$C8
               DC.B 'DBVS    '
               DC.L t_dbcc
               DC.B 0,0,$59,$C8
               DC.B 'DBZE    '
               DC.L t_dbcc
               DC.B 0,0,$57,$C8
               DC.B 'DIVS    '
               DC.L t_chk
               DC.B 0,3,$81,$C0
               DC.B 'DIVU    '
               DC.L t_chk
               DC.B 0,3,$80,$C0
               DC.B 'EOR     '
               DC.L t_eor
               DC.B 0,0,$B1,$40
               DC.B 'EOR.B   '
               DC.L t_eor
               DC.B 0,0,$B1,0
               DC.B 'EOR.L   '
               DC.L t_eor
               DC.B 0,0,$B1,$80
               DC.B 'EOR.W   '
               DC.L t_eor
               DC.B 0,0,$B1,$40
               DC.B 'EORI    '
               DC.L t_andi
               DC.B 0,0,$0A,$40
               DC.B 'EORI.B  '
               DC.L t_andi
               DC.B 0,0,$0A,0
               DC.B 'EORI.L  '
               DC.L t_andi
               DC.B 0,0,$0A,$80
               DC.B 'EORI.W  '
               DC.L t_andi
               DC.B 0,0,$0A,$40
               DC.B 'EXG     '
               DC.L t_exg
               DC.B 0,0,$C1,0
               DC.B 'EXG.L   '
               DC.L t_exg
               DC.B 0,0,$C1,0
               DC.B 'EXT     '
               DC.L t_ext
               DC.B 0,0,$48,$80
               DC.B 'EXT.L   '
               DC.L t_ext
               DC.B 0,0,$48,$C0
               DC.B 'EXT.W   '
               DC.L t_ext
               DC.B 0,0,$48,$80
               DC.B 'ILLEGAL '
               DC.L t_nop
               DC.B 0,0,$4A,$FC
               DC.B 'JMP     '
               DC.L t_jmp
               DC.B 0,0,$4E,$C0
               DC.B 'JSR     '
               DC.L t_jmp
               DC.B 0,0,$4E,$80
               DC.B 'LEA     '
               DC.L t_lea
               DC.B 0,0,$41,$C0
               DC.B 'LINEA   '
               DC.L t_linea
               DC.B 0,0,$A0,0
               DC.B 'LINK    '
               DC.L t_link
               DC.B 0,0,$4E,$50
               DC.B 'LSL     '
               DC.L t_asl
               DC.B 0,0,$E3,$48
               DC.B 'LSL.B   '
               DC.L t_asl
               DC.B 0,0,$E3,8
               DC.B 'LSL.L   '
               DC.L t_asl
               DC.B 0,0,$E3,$88
               DC.B 'LSL.W   '
               DC.L t_asl
               DC.B 0,0,$E3,$48
               DC.B 'LSR     '
               DC.L t_asl
               DC.B 0,0,$E2,$48
               DC.B 'LSR.B   '
               DC.L t_asl
               DC.B 0,0,$E2,8
               DC.B 'LSR.L   '
               DC.L t_asl
               DC.B 0,0,$E2,$88
               DC.B 'LSR.W   '
               DC.L t_asl
               DC.B 0,0,$E2,$48
               DC.B 'MOVE    '
               DC.L t_move
               DC.B 0,3,$30,0
               DC.B 'MOVE.B  '
               DC.L t_move
               DC.B 0,1,$10,0
               DC.B 'MOVE.L  '
               DC.L t_move
               DC.B 0,2,$20,0
               DC.B 'MOVE.W  '
               DC.L t_move
               DC.B 0,3,$30,0
               DC.B 'MOVEA   '
               DC.L t_adda
               DC.B 0,3,$30,$40
               DC.B 'MOVEA.L '
               DC.L t_adda
               DC.B 0,2,$20,$40
               DC.B 'MOVEA.W '
               DC.L t_adda
               DC.B 0,3,$30,$40
               DC.B 'MOVEM   '
               DC.L t_movem
               DC.B 0,0,$48,$80
               DC.B 'MOVEM.L '
               DC.L t_movem
               DC.B 0,0,$48,$C0
               DC.B 'MOVEM.W '
               DC.L t_movem
               DC.B 0,0,$48,$80
               DC.B 'MOVEP   '
               DC.L t_movep
               DC.B 0,0,1,8
               DC.B 'MOVEP.L '
               DC.L t_movep
               DC.B 0,0,1,$48
               DC.B 'MOVEP.W '
               DC.L t_movep
               DC.B 0,0,1,8
               DC.B 'MOVEQ   '
               DC.L t_moveq
               DC.B 0,0,$70,0
               DC.B 'MOVEQ.B '
               DC.L t_moveq
               DC.B 0,0,$70,0
               DC.B 'MULS    '
               DC.L t_chk
               DC.B 0,3,$C1,$C0
               DC.B 'MULU    '
               DC.L t_chk
               DC.B 0,3,$C0,$C0
               DC.B 'NBCD    '
               DC.L t_clr
               DC.B 0,0,$48,0
               DC.B 'NEG     '
               DC.L t_clr
               DC.B 0,0,$44,$40
               DC.B 'NEG.B   '
               DC.L t_clr
               DC.B 0,0,$44,0
               DC.B 'NEG.L   '
               DC.L t_clr
               DC.B 0,0,$44,$80
               DC.B 'NEG.W   '
               DC.L t_clr
               DC.B 0,0,$44,$40
               DC.B 'NEGX    '
               DC.L t_clr
               DC.B 0,0,$40,$40
               DC.B 'NEGX.B  '
               DC.L t_clr
               DC.B 0,0,$40,0
               DC.B 'NEGX.L  '
               DC.L t_clr
               DC.B 0,0,$40,$80
               DC.B 'NEGX.W  '
               DC.L t_clr
               DC.B 0,0,$40,$40
               DC.B 'NOP     '
               DC.L t_nop
               DC.B 0,0,$4E,$71
               DC.B 'NOT     '
               DC.L t_clr
               DC.B 0,0,$46,$40
               DC.B 'NOT.B   '
               DC.L t_clr
               DC.B 0,0,$46,0
               DC.B 'NOT.L   '
               DC.L t_clr
               DC.B 0,0,$46,$80
               DC.B 'NOT.W   '
               DC.L t_clr
               DC.B 0,0,$46,$40
               DC.B 'OR      '
               DC.L t_and
               DC.B 0,0,$80,$40
               DC.B 'OR.B    '
               DC.L t_and
               DC.B 0,0,$80,0
               DC.B 'OR.L    '
               DC.L t_and
               DC.B 0,0,$80,$80
               DC.B 'OR.W    '
               DC.L t_and
               DC.B 0,0,$80,$40
               DC.B 'ORI     '
               DC.L t_andi
               DC.B 0,0,0,$40
               DC.B 'ORI.B   '
               DC.L t_andi
               DC.B 0,0,0,0
               DC.B 'ORI.L   '
               DC.L t_andi
               DC.B 0,0,0,$80
               DC.B 'ORI.W   '
               DC.L t_andi
               DC.B 0,0,0,$40
               DC.B 'PEA     '
               DC.L t_pea
               DC.B 0,0,$48,$40
               DC.B 'RESET   '
               DC.L t_nop
               DC.B 0,0,$4E,$70
               DC.B 'ROL     '
               DC.L t_asl
               DC.B 0,0,$E7,$58
               DC.B 'ROL.B   '
               DC.L t_asl
               DC.B 0,0,$E7,$18
               DC.B 'ROL.L   '
               DC.L t_asl
               DC.B 0,0,$E7,$98
               DC.B 'ROL.W   '
               DC.L t_asl
               DC.B 0,0,$E7,$58
               DC.B 'ROR     '
               DC.L t_asl
               DC.B 0,0,$E6,$58
               DC.B 'ROR.B   '
               DC.L t_asl
               DC.B 0,0,$E6,$18
               DC.B 'ROR.L   '
               DC.L t_asl
               DC.B 0,0,$E6,$98
               DC.B 'ROR.W   '
               DC.L t_asl
               DC.B 0,0,$E6,$58
               DC.B 'ROXL    '
               DC.L t_asl
               DC.B 0,0,$E5,$50
               DC.B 'ROXL.B  '
               DC.L t_asl
               DC.B 0,0,$E5,$10
               DC.B 'ROXL.L  '
               DC.L t_asl
               DC.B 0,0,$E5,$90
               DC.B 'ROXL.W  '
               DC.L t_asl
               DC.B 0,0,$E5,$50
               DC.B 'ROXR    '
               DC.L t_asl
               DC.B 0,0,$E4,$50

               DC.B 'ROXR.B  '
               DC.L t_asl
               DC.B 0,0,$E4,$10
               DC.B 'ROXR.L  '
               DC.L t_asl
               DC.B 0,0,$E4,$90
               DC.B 'ROXR.W  '
               DC.L t_asl
               DC.B 0,0,$E4,$50
               DC.B 'RTE     '
               DC.L t_nop
               DC.B 0,0,$4E,$73
               DC.B 'RTR     '
               DC.L t_nop
               DC.B 0,0,$4E,$77
               DC.B 'RTS     '
               DC.L t_nop
               DC.B 0,0,$4E,$75
               DC.B 'SBCD    '
               DC.L t_abcd
               DC.B 0,0,$81,0
               DC.B 'SCC     '
               DC.L t_clr
               DC.B 0,0,$54,$C0
               DC.B 'SCS     '
               DC.L t_clr
               DC.B 0,0,$55,$C0
               DC.B 'SEQ     '
               DC.L t_clr
               DC.B 0,0,$57,$C0
               DC.B 'SF      '
               DC.L t_clr
               DC.B 0,0,$51,$C0
               DC.B 'SF.B    '
               DC.L t_clr
               DC.B 0,0,$51,$C0
               DC.B 'SGE     '
               DC.L t_clr
               DC.B 0,0,$5C,$C0
               DC.B 'SGT     '
               DC.L t_clr
               DC.B 0,0,$5E,$C0
               DC.B 'SHI     '
               DC.L t_clr
               DC.B 0,0,$52,$C0
               DC.B 'SLE     '
               DC.L t_clr
               DC.B 0,0,$5F,$C0
               DC.B 'SLS     '
               DC.L t_clr
               DC.B 0,0,$53,$C0
               DC.B 'SLT     '
               DC.L t_clr
               DC.B 0,0,$5D,$C0
               DC.B 'SMI     '
               DC.L t_clr
               DC.B 0,0,$5B,$C0
               DC.B 'SNE     '
               DC.L t_clr
               DC.B 0,0,$56,$C0
               DC.B 'SPL     '
               DC.L t_clr
               DC.B 0,0,$5A,$C0
               DC.B 'ST      '
               DC.L t_clr
               DC.B 0,0,$50,$C0
               DC.B 'ST.B    '
               DC.L t_clr
               DC.B 0,0,$50,$C0
               DC.B 'STOP    '
               DC.L t_stop
               DC.B 0,0,$4E,$72
               DC.B 'SUB     '
               DC.L t_add
               DC.B 0,0,$90,$40
               DC.B 'SUB.B   '
               DC.L t_add
               DC.B 0,0,$90,0
               DC.B 'SUB.L   '
               DC.L t_add
               DC.B 0,0,$90,$80
               DC.B 'SUB.W   '
               DC.L t_add
               DC.B 0,0,$90,$40
               DC.B 'SUBA    '
               DC.L t_adda
               DC.B 0,$80,$90,$C0
               DC.B 'SUBA.L  '
               DC.L t_adda
               DC.B 0,$80,$91,$C0
               DC.B 'SUBA.W  '
               DC.L t_adda
               DC.B 0,$80,$90,$C0
               DC.B 'SUBI    '
               DC.L t_addi
               DC.B 0,0,4,$40
               DC.B 'SUBI.B  '
               DC.L t_addi
               DC.B 0,0,4,0
               DC.B 'SUBI.L  '
               DC.L t_addi
               DC.B 0,0,4,$80
               DC.B 'SUBI.W  '
               DC.L t_addi
               DC.B 0,0,4,$40
               DC.B 'SUBQ    '
               DC.L t_addq
               DC.B 0,0,$51,$40
               DC.B 'SUBQ.B  '
               DC.L t_addq
               DC.B 0,0,$51,0
               DC.B 'SUBQ.L  '
               DC.L t_addq
               DC.B 0,0,$51,$80
               DC.B 'SUBQ.W  '
               DC.L t_addq
               DC.B 0,0,$51,$40
               DC.B 'SUBX    '
               DC.L t_abcd
               DC.B 0,0,$91,$40
               DC.B 'SUBX.B  '
               DC.L t_abcd
               DC.B 0,0,$91,0
               DC.B 'SUBX.L  '
               DC.L t_abcd
               DC.B 0,0,$91,$80
               DC.B 'SUBX.W  '
               DC.L t_abcd
               DC.B 0,0,$91,$40
               DC.B 'SVC     '
               DC.L t_clr
               DC.B 0,0,$58,$C0
               DC.B 'SVS     '
               DC.L t_clr
               DC.B 0,0,$59,$C0
               DC.B 'SWAP    '
               DC.L t_ext
               DC.B 0,0,$48,$40
               DC.B 'SWAP.L  '
               DC.L t_ext
               DC.B 0,0,$48,$40
               DC.B 'TAS     '
               DC.L t_clr
               DC.B 0,0,$4A,$C0
               DC.B 'TAS.B   '
               DC.L t_clr
               DC.B 0,0,$4A,$C0
               DC.B 'TRAP    '
               DC.L t_trap
               DC.B 0,0,$4E,$40
               DC.B 'TRAPV   '
               DC.L t_nop
               DC.B 0,0,$4E,$76
               DC.B 'TST     '
               DC.L t_clr
               DC.B 0,0,$4A,$40
               DC.B 'TST.B   '
               DC.L t_clr
               DC.B 0,0,$4A,0
               DC.B 'TST.L   '
               DC.L t_clr
               DC.B 0,0,$4A,$80
               DC.B 'TST.W   '
               DC.L t_clr
               DC.B 0,0,$4A,$40
               DC.B 'UNLINK  '
               DC.L t_unlk
               DC.B 0,0,$4E,$58
               DC.B 'UNLK    '
               DC.L t_unlk
               DC.B 0,0,$4E,$58
               DC.B 'XOR     '
               DC.L t_eor
               DC.B 0,0,$B1,$40
               DC.B 'XOR.B   '
               DC.L t_eor
               DC.B 0,0,$B1,0
               DC.B 'XOR.L   '
               DC.L t_eor
               DC.B 0,0,$B1,$80
               DC.B 'XOR.W   '
               DC.L t_eor
               DC.B 0,0,$B1,$40
               DC.B 'XORI    '
               DC.L t_andi
               DC.B 0,0,$0A,$40
               DC.B 'XORI.B  '
               DC.L t_andi
               DC.B 0,0,$0A,0
               DC.B 'XORI.L  '
               DC.L t_andi
               DC.B 0,0,$0A,$80
               DC.B 'XORI.W  '
               DC.L t_andi
               DC.B 0,0,$0A,$40
               DC.B -1
               EVEN
               ;>ENDPART
********************************************************************************
* DO - Befehl am PC ausführen                                                  *
********************************************************************************
               ;>PART 'cmd_do'
cmd_do:         bra     cmd_call1
               ;>ENDPART
********************************************************************************
* TRAP - Trap-Breakpoints verwalten                                            *
********************************************************************************
               ;>PART 'cmd_obser'
break_tab:     DC.W 1,gemdos_break,$7E
               DC.W 13,bios_break,$0B
               DC.W 14,xbios_break,$57
               DC.W $2A,aes_break,125
               DC.W $2B,vdi_break,131
               DC.W $13,bios_break,$0B
               DC.W $14,xbios_break,$57
               DC.W -1

cmd_obser:      bsr     get                       ;Folgen noch Parameter?
                beq     cmd_o90                   ;Alle Trap-Breakpoints anzeigen
                cmp.b   #'O',D0
                beq     cmd_oboff
                sf      observe_off(A4)           ;Observe anschalten
                cmp.b   #'K',D0
                beq     cmd_ob4                   ;Alle Trap-Breakpoints l”schen
                bsr     get_term                  ;Trapnummer holen
                swap    D1
                tst.w   D1
                bne     illequa                   ;Nummer viel zu grož!
                swap    D1
                lea     break_tab-4(PC),A1
cmd_ob1:        addq.l  #4,A1
                move.w  (A1)+,D2
                bmi     illequa                   ;Trap nicht gefunden
                cmp.w   D1,D2
                bne.s   cmd_ob1
                move.w  D1,D7
                move.w  (A1)+,D2                  ;Offset für A4
                moveq   #0,D3
                move.w  (A1)+,D3                  ;max.Funktionsnummer
                tst.w   D0
                beq.s   cmd_ob6                   ;Trap-Breakpoints des entspr.Traps setzen
                cmp.b   #'.',D0
                beq.s   cmd_ob2                   ;Trap-Breakpoints des entspr.Traps l”schen
cmd_ob0:        tst.w   D0
                beq     ret_jump
                cmp.b   #',',D0
                bne     synerr
                bsr     get                       ;Folgen noch Parameter?
                cmp.b   #'?',D0
                beq     cmd_ob9                   ;Parameter anzeigen
                cmp.b   #'*',D0
                beq.s   cmd_ob6                   ;alle Breakpoints setzen
                bsr     get_term                  ;Funktionsnummer holen
                addq.l  #1,D1
                bmi     illequa                   ;<-1 ist nicht erlaubt
                subq.l  #1,D1
                bmi.s   cmd_ob6                   ;-1 = alle Breakpoints setzen
                cmp.l   D3,D1
                bhi     illequa                   ;zu grož für diesen Trap
                lea     0(A4,D2.w),A1
                cmp.b   #'.',D0                   ;Eintrag l”schen?
                beq.s   cmd_ob8                   ;Ja! =>
                st      0(A1,D1.w)                ;einzelnen Trap-Breakpoint setzen
                bra.s   cmd_ob0
cmd_ob8:        lea     0(A1,D1.w),A2
                sf      (A2)                      ;einzelnen Trap-Breakpoint setzen
                bsr     get
                bra.s   cmd_ob0

cmd_ob2:        lea     0(A4,D2.w),A0
cmd_ob3:        sf      0(A0,D3.w)                ;alle enspr.Breakpoints l”schen
                dbra    D3,cmd_ob3
                jmp     (A4)

cmd_ob6:        lea     0(A4,D2.w),A0
cmd_ob7:        st      0(A0,D3.w)                ;alle enspr.Breakpoints setzen
                dbra    D3,cmd_ob7
                jmp     (A4)

cmd_ob4:        lea     gemdos_break(A4),A1
                lea     end_of_breaks(A4),A0
cmd_ob5:        clr.b   (A1)+                     ;Alle Trap-Breakpoints l”schen
                cmpa.l  A0,A1
                blo.s   cmd_ob5
                jmp     (A4)

cmd_o90:        lea     break_tab(PC),A6
                moveq   #4,D5                     ;5 Traps ausgeben
cmd_o91:        pea     _trap(PC)
                jsr     @print_line(A4)
                jsr     @space(A4)
                moveq   #'#',D0
                jsr     @chrout(A4)
                moveq   #0,D1
                move.w  (A6)+,D1
                move.w  D1,D7
                bsr     hexout
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                move.w  (A6)+,D2
                move.w  (A6)+,D3
                bsr.s   cmd_o3o
                dbra    D5,cmd_o91
                jmp     (A4)

cmd_ob9:        bsr.s   cmd_o3o
                jmp     (A4)

cmd_o3o:        moveq   #-1,D1
                lea     0(A4,D2.w),A1
                cmp.w   #$2A,D7
                beq     cmd_o40
                cmp.w   #$2B,D7
                beq.s   cmd_o50
                lea     gemdos_befs,A2
                cmp.w   #1,D7
                beq.s   cmd_o30
                lea     bios_befs,A2
                cmp.w   #$13,D7
                beq.s   cmd_o30
                cmp.w   #$0D,D7
                beq.s   cmd_o30
                lea     xbios_befs,A2
cmd_o30:        moveq   #';',D0
                jsr     @chrout(A4)
                moveq   #25,D6
                bra.s   cmd_o32
cmd_o31:        moveq   #',',D0
                jsr     @chrout(A4)
cmd_o32:        addq.w  #1,D1
                cmp.w   D3,D1
                bhi.s   cmd_o33
                cmp.b   (A2),D1
                bne.s   cmd_o32
                addq.l  #1,A2
                move.b  (A2)+,D0                  ;Stackformat berlesen
                rol.b   #2,D0
                andi.b  #3,D0
                beq.s   cmd_o35
                addq.l  #1,A2
cmd_o35:        tst.b   (A2)+
                bne.s   cmd_o35                   ;Funktionsnamen berlesen
                tst.b   0(A1,D1.w)
                beq.s   cmd_o32
                bmi.s   cmd_o34
                moveq   #'*',D0
                jsr     @chrout(A4)
cmd_o34:        bsr     hexbout
                dbra    D6,cmd_o31
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                bra.s   cmd_o30                   ;N„chste Zeile
cmd_o33:        jsr     c_cleft
                jsr     @c_eol(A4)
                jmp     @crout(A4)

cmd_o50:        lea     vdi_all,A2
                bra.s   cmd_o45
cmd_o40:        lea     aes_all,A2
cmd_o45:        moveq   #';',D0                   ;AES-Observe
                jsr     @chrout(A4)
                moveq   #25,D6
                bra.s   cmd_o42
cmd_o41:        moveq   #',',D0
                jsr     @chrout(A4)
cmd_o42:        moveq   #0,D1
                move.b  (A2)+,D1                  ;erlaubte Funktionsnummer holen
                beq.s   cmd_o43                   ;Ende erreicht
                tst.b   0(A1,D1.w)                ;auf Breakpoint testen
                beq.s   cmd_o42                   ;keiner da
                bmi.s   cmd_o44                   ;normaler Breakpoint
                moveq   #'*',D0
                jsr     @chrout(A4)               ;dort wurde abgebrochen
cmd_o44:        bsr     hexbout
                dbra    D6,cmd_o41
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                bra.s   cmd_o45                   ;N„chste Zeile
cmd_o43:        jsr     c_cleft
                jsr     @c_eol(A4)
                jmp     @crout(A4)

cmd_oboff:      st      observe_off(A4)           ;Observe ausschalten
                move.l  old_gemdos(PC),$84.w
                move.l  old_aesvdi(PC),$88.w      ;Alte Vektoren wieder rein
                move.l  old_bios(PC),$B4.w
                move.l  old_xbios(PC),$B8.w
                move.l  old_critic(PC),$0404.w
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* BSSCLEAR - BSS-Bereich des geladenen Programms l”schen                       *
********************************************************************************
               ;>PART 'cmd_bclr'
cmd_bclr:       move.l  basep(A4),D0
                beq     no_prg
                movea.l D0,A0
                move.l  $1C(A0),D0                ;L„nge des BSS-Bereichs
                movea.l $18(A0),A0                ;Anfangsadresse des BSS-Bereichs
                bra.s   cmd_bc2
cmd_bc1:        clr.b   (A0)+                     ;BSS-Bereich l”schen
cmd_bc2:        subq.l  #1,D0
                bpl.s   cmd_bc1
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* INITREGISTER - Register neu initialisieren                                   *
********************************************************************************
               ;>PART 'cmd_ireg'
cmd_ireg:       bsr.s   initreg
                bsr     set_reg
                jmp     (A4)
               ;>ENDPART
               ;>PART 'initreg'
initreg:        move.l  first_free(A4),_pc(A4)
                move.w  #$0300,_sr(A4)
                movea.l #debug_sstack,A0
                adda.l  A4,A0
                move.l  A0,_ssp(A4)               ;SSP setzen
                movea.l merk_act_pd(A4),A1
                movea.l 4(A1),A0                  ;TPA-Ende ermitteln
;crashes on real hw with -dbg? TOS 1.0?

                move.l  A1,-(A0)                  ;Basepageadr
                clr.l   -(A0)                     ;Keine Rücksprungadr
                move.l  A0,_usp(A4)               ;USP setzen
                move.l  A0,rega7(A4)
                lea     regs(A4),A0
                moveq   #14,D0
cmd_ir1:        clr.l   (A0)+                     ;Alle anderen Register l”schen
                dbra    D0,cmd_ir1
                rts
               ;>ENDPART
********************************************************************************
* CURSOR [Art] - Cursorform „ndern                                             *
********************************************************************************
               ;>PART 'cmd_swchcur'
cmd_swchcur:    moveq   #0,D1                     ;Invers ist Default
                bsr     get
                beq.s   cmd_swc
                bsr     get_term
                cmp.l   #3,D1                     ;max.4 Cursorformen
                bhi     illequa
                lsl.w   #4,D1                     ;mal 16 (L„nge einer Cursorform)
cmd_swc:        move.w  D1,cursor_form(A4)        ;neue Cursorform
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* IFEQ - Monitorumschaltung                                                  *
********************************************************************************
               ;>PART 'cmd_switch'
cmd_switch:     move    SR,-(SP)
                ori     #$0700,SR                 ;IRQs sperren
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A1
                move.w  #1999,D0
cmd_switch1:    clr.l   (A1)+                     ;Die Hires l”schen
                clr.l   (A1)+
                clr.l   (A1)+
                clr.l   (A1)+
                dbra    D0,cmd_switch1
                bchg    #6,scr_moni(A0)           ;Monitor umschalten
                move.b  scr_rez(A0),D0
                lsr.b   #1,D0
                bne.s   cmd_switch2               ;1=>2 bzw. 2=>1
                moveq   #2,D0
cmd_switch2:    move.b  D0,scr_rez(A0)            ;die Aufl”sung umschalten
                lea     no_overscan(A4),A1
                jsr     restore_scr
                jsr     @redraw_all(A4)           ;Bildschirm neu aufbauen
                move    (SP)+,SR                  ;IRQs wieder freigeben
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* CHECKSUMME [Adr][,[Value][,[Wordanz][,Art]]]                                 *
********************************************************************************
               ;>PART 'cmd_checksum'
cmd_checksum:   movea.l dsk_adr(A4),A6            ;Defaultadr
                move.w  #$1234,D7                 ;Defaultchecksum
                moveq   #0,D4
                move.w  #$FF,D4                   ;Defaultwords
                moveq   #0,D5                     ;Defaultart (0=ADD, 1=EOR)
                bsr     get
                moveq   #-1,D6
                bsr     get_it                    ;Adresse (alles erlaubt)
                beq.s   cmd_ch1
                bvc.s   cmd_c1h
                movea.l D1,A6
                bsr     chkcom
                beq.s   cmd_ch1                   ;Ende der Eingabe
cmd_c1h:        move.l  #$FFFF,D6
                bsr     get_it                    ;Value
                beq.s   cmd_ch1
                bvc.s   cmd_c2h
                move.w  D1,D7
                bsr     chkcom
                beq.s   cmd_ch1                   ;Ende der Eingabe
cmd_c2h:        move.l  #$FFFFFF,D6
                bsr     get_it                    ;Anzahl
                beq.s   cmd_ch1
                bvc.s   cmd_c3h
                move.l  D1,D4
                bsr     chkcom
                beq.s   cmd_ch1                   ;Ende der Eingabe
cmd_c3h:        cmp.b   #'A',D0                   ;ADD
                beq.s   cmd_ch1
                moveq   #1,D5
                cmp.b   #'X',D0                   ;XOR
                beq.s   cmd_ch1
                cmp.b   #'E',D0                   ;EOR
                bne     synerr
cmd_ch1:        subq.w  #1,D6
                beq     illequa
                tst.w   D5
                beq.s   cmd_ch2
                moveq   #0,D1
cmd_ch5:        move.w  (A6)+,D0
                eor.w   D0,D1
                subq.l  #1,D4
                bpl.s   cmd_ch5
                bra.s   cmd_ch4
cmd_ch2:        moveq   #0,D1
cmd_ch3:        add.w   (A6)+,D1                  ;Checksum errechnen
                subq.l  #1,D4
                bpl.s   cmd_ch3
                neg.w   D1
                add.w   D7,D1                     ;Prüfsumme nun in D1
cmd_ch4:        pea     cmd_cht(PC)
                jsr     @print_line(A4)
                moveq   #'$',D0
                jsr     @chrout(A4)
                bsr     hexwout                   ;Checksum ausgeben
                jsr     @c_eol(A4)                ;Zeilenrest l”schen
                jsr     @crout(A4)                ;CR
                jmp     (A4)

               IFEQ sprache
cmd_cht:       DC.B 'Prüfsumme = ',0
               ELSE
cmd_cht:       DC.B 'Checksum = ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* RESET [ALL|VEK] - Vektoren zurücksetzen                                      *
********************************************************************************
               ;>PART 'cmd_reset'
cmd_reset:      lea     cmd_rst1(PC),A6
                bsr     get
                beq.s   cmd_reset3                ;VEK ist Default
                cmp.b   #'V',D0                   ;VEK?
                beq.s   cmd_reset3
                cmp.b   #'A',D0                   ;ALL?
                bne     synerr
                tst.b   le_allowed(A4)            ;LE erlaubt?
                beq     cmd_cont1                 ;Nein! =>
                tst.b   help_allow(A4)            ;CTRL-HELP erlaubt?
                bmi     cmd_cont1                 ;Ja! =>
                move.l  A6,-(SP)
                jsr     @print_line(A4)
                lea     cmd_rst2(PC),A0
                jsr     ask_user

                move.w  _fhdle2(A4),D0            ;Protokoll-Datei gibt's nicht
                bls.s   cmd_reset1
                move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.l  #4,SP
cmd_reset1:     jsr     set_vek                   ;Vektoren neu setzen

                jsr     reset_all

                move.l  old_trap3,$8C.w
                movea.l old_stack(A4),SP
                move    #$0300,SR                 ;USER-Mode an
                movea.l old_usp(A4),SP
                moveq   #0,D7
                bra     start

cmd_reset3:     move.l  A6,-(SP)
                jsr     @print_line(A4)
                lea     cmd_rst3(PC),A0
                jsr     ask_user
                jsr     set_vek                   ;Vektoren neu setzen
                jmp     (A4)

               IFEQ sprache
cmd_rst1:      DC.B 'Sicher, daž Sie ',0
cmd_rst2:      DC.B 'alles zurücksetzen wollen? (j/n) ',0
cmd_rst3:      DC.B 'die Systemvektoren zurücksetzen wollen? (j/n) ',0
               ELSE
cmd_rst1:      DC.B 'Sure you want to reset ',0
cmd_rst2:      DC.B 'all? (y/n) ',0
cmd_rst3:      DC.B 'the systemvectors? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* "..." String ausgeben                                                        *
********************************************************************************
               ;>PART 'cmd_send'
cmd_send:       move.b  (A0)+,D0
                beq.s   cmd_sd1                   ;Zeilenende (Pointer zurück)
                cmp.b   #'"',D0
                beq.s   cmd_sd0                   ;Ende der Eingabe
                cmp.b   #'\',D0
                bne.s   cmd_sd2
                movea.l A0,A1                     ;Pointer merken
                bsr     get                       ;Das 1.Folgezeichen holen
                cmp.b   #'\',D0
                beq.s   cmd_sd2                   ;'\' doch ausgeben
                moveq   #$10,D2                   ;Hexadezimal
                bsr     chkval                    ;pažt's?
                bcc.s   cmd_sd3                   ;dann '\' ausgeben
                lsl.w   #4,D0
                move.w  D0,D1
                bsr     get                       ;Das 2.Folgezeichen holen
                bsr     chkval                    ;Hexadezimal?
                bcc.s   cmd_sd3                   ;Zeiger wieder zurück, '\' ausgeben
                or.w    D1,D0                     ;Code zusammensetzen
                or.w    #$FF00,D0                 ;Code direkt zum Drucker (oder in die Datei)
                bra.s   cmd_sd2                   ;ausgeben
cmd_sd3:        movea.l A1,A0                     ;Pointer zurück
                moveq   #'\',D0                   ;'\' ausgeben
cmd_sd2:        jsr     @chrout(A4)               ;Zeichen ausgeben
                bra.s   cmd_send
cmd_sd1:        subq.l  #1,A0
cmd_sd0:        move.b  (A0),D0
                cmp.b   #';',D0                   ;Bei ';' kein CR ausgeben
                beq.s   cmd_sd5
                jsr     @crout(A4)
cmd_sd5:        jmp     (A4)
               ;>ENDPART
********************************************************************************
* GETCACHE                                                                     *
********************************************************************************
               ;>PART 'cmd_getcach'
cmd_getcach:    bsr.s   getcache
                jmp     (A4)
               ;>ENDPART
               ;>PART 'getcache'
getcache:       move.l  reg_pos(A4),D0
                move.l  D0,trace_pos(A4)          ;angezeigte Reg = aktuelle Reg
                lea     regs(A4),A5
                movea.l D0,A6
                moveq   #38,D0
getcache1:      move.w  (A6)+,(A5)+               ;Spurende setzen
                dbra    D0,getcache1
                bra     rgout                     ;und ausgeben (wegen dem Closer)
               ;>ENDPART
********************************************************************************
* CLRCACHE                                                                     *
********************************************************************************
               ;>PART 'cmd_clrcach'
cmd_clrcach:    movea.l #trace_buff,A0
                adda.l  A4,A0
                move.l  A0,trace_pos(A4)          ;Position im Tracebuffer
                move.l  A0,reg_pos(A4)
                movea.l #trace_buffend,A1
                adda.l  A4,A1
cmd_cc1:        clr.w   (A0)+                     ;Befehlsbuffer l”schen
                cmpa.l  A1,A0
                blo.s   cmd_cc1
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* SYMBOLTABLE [Symbol]                                                         *
********************************************************************************
               ;>PART 'cmd_symbol'
cmd_symbol:     tst.l   sym_size(A4)
                beq     no_syms                   ;Fehler, wenn keine Symboltabelle vorhanden
                movea.l default_adr(A4),A5
                suba.l  A2,A2                     ;Anfangsadresse
                moveq   #-1,D0
                movea.l D0,A3                     ;Endadresse
                move.l  basep(A4),D0              ;Programm geladen?
                beq.s   cmd_sy0
                movea.l D0,A2                     ;dann nur Symbolwerte>Basepage ausgeben
                movea.l $18(A2),A3
                adda.l  $1C(A2),A3                ;Zeiger hinter das BSS-Segment
cmd_sy0:        bsr     get2xadr
                move.l  A3,D1
                movea.l sym_adr(A4),A6            ;Anfangsadresse der Symboltabelle
cmd_sy1:        cmpa.l  sym_end(A4),A6
                bhs.s   cmd_sy3                   ;Ende erreicht!
                cmpa.l  10(A6),A2                 ;akt.Label < Anfangsadresse
                bhi.s   cmd_sy4                   ;noch nicht gefunden
                tst.l   D1                        ;Endadresse vorhanden?
                beq.s   cmd_sy5                   ;šberspringen, wenn nicht!
                cmpa.l  10(A6),A3                 ;akt.Label > Endadresse
                bls.s   cmd_sy3                   ;dann fertig
cmd_sy5:        bsr.s   sym_out                   ;Symbol ausgeben
                movem.l D1,-(SP)
                jsr     @crout(A4)                ;Noch ein CR dranh„ngen
                bsr     check_keyb                ;Taste gedrückt?
                movem.l (SP)+,D1
                bmi.s   cmd_sy3
                tst.l   D1
                bne.s   cmd_sy1                   ;Endadresse existiert => Zeilenanz egal
                dbra    D2,cmd_sy1                ;Schon alle Labels ausgegeben?
cmd_sy3:        move.l  A5,default_adr(A4)        ;Default-Adr zurücksetzen
                jmp     (A4)
cmd_sy4:        lea     14(A6),A6                 ;Label berlesen
                bra.s   cmd_sy1

sym_out:        movem.l D0-A5,-(SP)
                move.l  A6,D1
                jsr     @anf_adr(A4)
                moveq   #'(',D0
                jsr     @chrout(A4)
                moveq   #'.',D0
                jsr     @chrout(A4)
                move.l  (A6),-(SP)
                jsr     @print_line(A4)           ;Labelnamen ausgeben
                moveq   #34,D0
                jsr     spacetab
                addq.l  #8,A6
                move.w  (A6)+,D5
                move.l  (A6)+,D1
                bsr     hexlout                   ;Wert des Symbols ausgeben
                jsr     @space(A4)
                lea     symtxt(PC),A5
                lea     symtxt1(PC),A3
                moveq   #' ',D0
                cmp.b   #$48,D5
                bne.s   sym_ou2
                moveq   #'L',D0                   ;Long-Label
sym_ou2:        jsr     @chrout(A4)
                lsr.w   #8,D5                     ;Informationen von Bit 15-8 nach 7-0
                moveq   #-1,D4                    ;normalerweise: kein indirekter Wert
                moveq   #7,D6                     ;Bei Bit 7 anfangen
sym_ou3:        moveq   #' ',D0
                btst    D6,D5                     ;Flag gesetzt?
                beq.s   sym_ou4                   ;Nein => Text berlesen
                tst.b   (A3)
                beq.s   sym_ou31
                moveq   #0,D4                     ;indirekter Wert vorhanden
sym_ou31:       move.b  (A5),D0                   ;Flag-Text ausgeben
sym_ou4:        jsr     @chrout(A4)
                addq.l  #1,A5
                addq.l  #1,A3
                dbra    D6,sym_ou3                ;alle Bits?
                tst.b   D4                        ;<>0 wenn Konstante
                bne.s   sym_ou6                   ;dann keinen indirekten Wert ausgeben
                move.l  A6,-(SP)
                moveq   #54,D0
                jsr     spacetab
                movea.l -(A6),A6                  ;Wert des Symbols nochmal holen
                moveq   #11,D2                    ;max.12 Bytes ausgeben
sym_ou8:        bsr     check_read                ;Adresse lesbar?
                bne.s   sym_ou5                   ;Nein!
                move.b  (A6)+,D1                  ;Byte holen
                bsr     hexbout                   ;und ausgeben
                bra.s   sym_ou7                   ;weiter...
sym_ou5:        addq.l  #1,A6                     ;Byte berspringen
                moveq   #'-',D0
                jsr     chrout                    ;"--" ausgeben
                jsr     chrout
sym_ou7:        dbra    D2,sym_ou8                ;schon alle 12 Bytes?
                movea.l (SP)+,A6
sym_ou6:        movem.l (SP)+,D0-A5
                rts

symtxt:        DC.B '+KGRXDTB'
symtxt1:       DC.B 0,0,0,0,0,1,1,1
               EVEN
               ;>ENDPART
********************************************************************************
* FOPEN Filename                                                               *
********************************************************************************
               ;>PART 'cmd_fopen'
cmd_fopen:      move.w  _fhdle2(A4),D0            ;Protokoll-Datei existiert bereits
                bhi     fileer2
                bsr     getnam                    ;Filenamen holen
                beq     synerr
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     do_mediach                ;Media-Change ausl”sen
                clr.w   -(SP)
                move.l  A2,-(SP)
                move.w  #$3C,-(SP)
                bsr     do_trap_1                 ;Fcreate()
                addq.l  #8,SP
                tst.w   D0
                bmi     toserr
                move.w  D0,_fhdle2(A4)            ;Handle der Protokoll-Datei
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* FCLOSE                                                                       *
********************************************************************************
               ;>PART 'cmd_fclose'
cmd_fclose:     move.w  _fhdle2(A4),D0            ;Protokoll-Datei gibt's nicht
                bls     file_er
                move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                bsr     do_trap_1                 ;Fclose()
                addq.l  #4,SP
                bsr     do_mediach                ;Media-Change ausl”sen
                clr.w   _fhdle2(A4)               ;Handle ungültig machen
                tst.w   D0
                bmi     toserr
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* FILEbefehl                                                                   *
********************************************************************************
               ;>PART 'cmd_file'
cmd_file:       move.w  _fhdle2(A4),D0            ;Protokol-Datei gibt's nicht
                bls     file_er
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                clr.w   prn_pos(A4)               ;Zeiger zurücksetzen
                move.b  #1,device(A4)             ;Flag für Protokolldatei an
                bra     inp_loop1                 ;zum n„chsten Zeichen
               ;>ENDPART
********************************************************************************
* LINE                                                                         *
********************************************************************************
               ;>PART 'cmd_line'
cmd_line:       moveq   #78,D1
cmd_li1:        moveq   #'-',D0
                jsr     @chrout(A4)
                dbra    D1,cmd_li1
                jsr     @crout(A4)
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* CR [lines]                                                                   *
********************************************************************************
               ;>PART 'cmd_crout'
cmd_crout:      moveq   #0,D1                     ;ein CR ist Default
                bsr     get
                beq.s   cmd_cr1
                bsr     get_term
                subq.l  #1,D1                     ;für DBRA
                bmi     illequa
                cmp.l   #99,D1
                bhi     illequa                   ;mehr als 100 geht nicht!
cmd_cr1:        moveq   #13,D0                    ;D1+1 CRs ausgeben
                jsr     @crout(A4)
                dbra    D1,cmd_cr1
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* GETREGISTER [Adr]                                                            *
********************************************************************************
               ;>PART 'cmd_getreg'
cmd_getreg:     lea     $0300.w,A6
                bsr     get
                beq.s   cmd_gr1
                bsr     get_term
                movea.l D1,A6
                bsr     check_write
                bne     illequa
cmd_gr1:        lea     regs(A4),A5
                moveq   #38,D0                    ;39 Words kopieren
cmd_gr2:        move.w  (A6)+,(A5)+
                dbra    D0,cmd_gr2
                jmp     (A4)

               ;>ENDPART
********************************************************************************
* FREE [Drv]                                                                   *
********************************************************************************
               ;>PART 'cmd_free'
cmd_free:       bsr     get
                bne.s   cmd_free1
                moveq   #-1,D0
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                bsr     do_trap_1
                addq.l  #6,SP
                move.l  D0,D1
                bsr     dezout
                pea     free_txt(PC)
                jsr     @print_line(A4)
                jmp     (A4)
cmd_free1:      move.w  D0,D7                     ;Drive merken
                sub.w   #'A',D7
                bmi     illdrv
                cmp.w   #$0F,D7
                bhi     illdrv
                bsr     do_mediach                ;Media-Change ausl”sen
                bsr.s   drive_free1
                jmp     (A4)

               IFEQ sprache
free_txt:      DC.B ' Bytes frei.',13,0
dfree_txt:     DC.B ' Bytes auf dem Laufwerk '
dfr_drv:       DC.B 'X: frei.',13,0
               ELSE
free_txt:      DC.B ' Bytes free.',13,0
dfree_txt:     DC.B ' Bytes on drive '
dfr_drv:       DC.B 'X: free.',13,0
               ENDC
               EVEN
drive_free:     move.w  #$19,-(SP)
                bsr     do_trap_1                 ;Dgetdrv()
                addq.l  #2,SP
                move.l  D0,D7
drive_free1:    moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                addq.w  #1,D7
                lea     dfr_drv(PC),A0
                move.b  D7,(A0)
                ori.b   #$40,(A0)                 ;Drive in den Text einsetzen
                lea     spaced2(A4),A6
                bsr.s   dfree
                tst.l   D0
                bmi     toserr
                move.l  (A6),D1                   ;Anzahl der freien Cluster
                move.l  8(A6),D2                  ;Bytes/Sektor
                bsr     lmult
                move.l  12(A6),D1                 ;Sektoren/Cluster
                bsr     lmult
                move.l  D2,D1
                bsr     dezout
                pea     dfree_txt(PC)
                jsr     @print_line(A4)
                rts
               ;>ENDPART
********************************************************************************
* eigene Dfree-Funktion                                                        *
********************************************************************************
               ;>PART 'dfree'
dfree:          subq.w  #1,D7                     ;aktuelles Laufwerk
                bmi     dfree_error_own           ;geht an die Originalroutine

                move.w  D7,-(SP)
                move.w  #7,-(SP)
                trap    #13                       ;Getbpb()
                addq.l  #4,SP
                tst.l   D0
                bmi.s   dfree_error               ;Ger„t evtl. nicht da!

                movea.l D0,A0                     ;Adresse des BPB-Blocks
                move.w  10(A0),D6                 ;fatrec - Startsektor der 2.FAT
                move.w  14(A0),D5                 ;numcl - Gesamtanzahl der Cluster
                btst    #0,17(A0)
                beq.s   dfree_error_own           ;12-Bit-FAT => Geht noch nicht!

                clr.l   (A6)+
                clr.l   (A6)+
                clr.l   (A6)+                     ;šbergabefeld erstmal l”schen
                clr.l   (A6)
                lea     -12(A6),A6
                move.w  D5,6(A6)                  ;Gesamtanzahl der Cluster
                move.w  (A0)+,10(A6)              ;Bytes pro Sektor
                move.w  (A0),14(A6)               ;Sektoren pro Cluster

                movea.l #allg_buffer,A5
                adda.l  A4,A5                     ;Buffer für einen Sektor der FAT
                moveq   #0,D4                     ;Anzahl der freien Cluster=0
                moveq   #0,D3
dfree0:         move.w  D7,-(SP)                  ;Drive
                move.w  D6,-(SP)                  ;fatrec
                move.w  #2,-(SP)                  ;stets 2 Sektoren einlesen
                move.l  A5,-(SP)                  ;Buffer für den Sektor
                clr.w   -(SP)                     ;normales Lesen
                move.w  #4,-(SP)
                trap    #13                       ;Rwabs()
                lea     14(SP),SP
                tst.l   D0
                bmi.s   dfree_error               ;Lesefehler
                addq.w  #2,D6                     ;fatrec+2
                movea.l A5,A0
                move.w  #511,D0                   ;512 Cluster pro 2 Sektoren der FAT
                tas.b   D3                        ;1.Sektor mit den ersten drei Clustern?
                bne.s   dfree1                    ;Nein! =>
                addq.l  #6,A0                     ;die ersten der Cluster werden nicht
                subq.w  #3,D0                     ;mitgez„hlt!
                subq.w  #3,D5                     ;3 Cluster bereits abziehen
dfree1:         tst.w   (A0)+
                bne.s   dfree2
                addq.w  #1,D4                     ;einen freien Cluster gefunden
dfree2:         subq.w  #1,D5                     ;numcl-1
                dbeq    D0,dfree1
                bne.s   dfree0                    ;Ende noch nicht erreicht, weiter geht's
                move.l  D4,(A6)                   ;Anzahl der freien Cluster nach D0
dfree_error:    rts

dfree_error_own:addq.w  #1,D7
                move.w  D7,-(SP)
                move.l  A6,-(SP)                  ;Puffer für 4-Longs
                move.w  #$36,-(SP)
                bsr     do_trap_1                 ;Dfree(info,drive)
                addq.l  #8,SP
                rts
               ;>ENDPART
********************************************************************************
* FORMAT [DS/SS][,Drive]                                                       *
********************************************************************************
               ;>PART 'cmd_format'
cmd_format:     bsr     get
                moveq   #1,D5                     ;DS ist Default
                tst.b   D0
                beq.s   cmd_fm2
                cmp.b   #'D',D0
                beq.s   cmd_fm1
                moveq   #0,D5                     ;SS
                cmp.b   #'S',D0
                beq.s   cmd_fm1
                cmp.b   #',',D0
                bne     synerr
                moveq   #1,D5                     ;DS
                bsr     get
                bra.s   cmd_fm6
cmd_fm1:        bsr     get
                cmp.b   #'S',D0
                bne     synerr
                bsr     get
                bsr     chkcom                    ;folgt ein Komma?
                beq.s   cmd_fm2                   ;Keine Eingabe
cmd_fm6:        moveq   #1,D6
                bsr     get_it                    ;Drive (0 oder 1) holen
                beq     synerr
                bvc     synerr
                move.w  D1,dsk_drive(A4)
cmd_fm2:        lea     cmd_fm_txt(PC),A0
                jsr     ask_user                  ;Sicherheitsabfrage
                move.w  dsk_drive(A4),D7          ;Das Laufwerk
                movea.l #allg_buffer,A6
                adda.l  A4,A6                     ;Formatbuffer
                moveq   #1,D0
                jsr     graf_mouse                ;Mauszeiger als Diskette
                moveq   #79,D6                    ;80 Spuren
cmd_fm3:        move.w  D5,D4
cmd_fm4:        clr.w   -(SP)
                move.l  #$87654321,-(SP)
                move.w  #1,-(SP)
                move.w  D4,-(SP)
                move.w  D6,-(SP)
                move.w  #9,-(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.l  A6,-(SP)
                move.w  #10,-(SP)
                trap    #14                       ;flopmt()
                lea     26(SP),SP
                tst.l   D0
                bmi.s   cmd_fm5                   ;Das war wohl nichts
                dbra    D4,cmd_fm4                ;zwei Seiten?
                dbra    D6,cmd_fm3                ;80 Spuren
                clr.w   -(SP)                     ;Nicht ausführbar
                move.w  D5,-(SP)
                addq.w  #2,(SP)                   ;2= einseitig / 3= doppelseitig
                move.l  #'MRF',-(SP)             ;Zuf„llige Seriennummer
                move.l  A6,-(SP)
                move.w  #$12,-(SP)
                trap    #14
                lea     14(SP),SP
                moveq   #1,D0
                move.w  D0,-(SP)
                clr.l   -(SP)
                move.w  D0,-(SP)
                move.w  D7,-(SP)
                clr.l   -(SP)
                move.l  A6,-(SP)
                move.w  #9,-(SP)
                trap    #14
                lea     20(SP),SP
cmd_fm5:        move.l  D0,D7
                move.l  D7,D0
                tst.l   D0
                bmi     toserr
                jmp     (A4)

cmd_fm_txt:    IFEQ sprache
               DC.B 'Wollen Sie formatieren? (j/n) ',0
               ELSE
               DC.B 'Sure you want to format a disk? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* NAME Sourcefile,Destfile                                                     *
********************************************************************************
               ;>PART 'cmd_name'
cmd_name:       bsr     getnam
                beq     synerr
                lea     spaced(A4),A1
                move.l  (A2)+,(A1)+
                move.l  (A2)+,(A1)+               ;Filenamen kopieren
                move.l  (A2)+,(A1)+
                move.l  (A2),(A1)
                bsr     get
                bsr     chkcom                    ;ein Komma?
                bsr     getnam_cont
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     do_mediach                ;Media-Change ausl”sen
                move.l  A2,-(SP)                  ;New
                pea     spaced(A4)                ;Old
                move.l  #$560000,-(SP)            ;Frename()
                bsr     do_trap_1
                lea     12(SP),SP
                tst.l   D0
                bmi     toserr
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* FATTRIBUT [Name[,mode]]                                                      *
********************************************************************************
               ;>PART 'cmd_fattrib'
cmd_fattrib:    moveq   #0,D2                     ;Attribute holen
                bsr     get
                beq.s   cmd_ft1
                cmp.b   #',',D0
                beq.s   cmd_ft2
                bsr     getnam_cont               ;Namen holen
                bsr     get
cmd_ft1:        cmp.b   #',',D0
                bne.s   cmd_ft3
cmd_ft2:        moveq   #1,D2                     ;Attribute setzen
                bsr     get
                bsr     get_term                  ;Filemode holen
cmd_ft3:        lea     fname(A4),A2
                tst.b   (A2)
                beq     synerr                    ;Kein Filename angegeben

                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten

                bsr     do_mediach                ;Media-Change ausl”sen
                move.w  D1,-(SP)                  ;Filemode
                move.w  D2,-(SP)                  ;0=Lesen, 1=Schreiben
                move.l  A2,-(SP)                  ;Pfadname
                move.w  #$43,-(SP)
                bsr     do_trap_1                 ;Fattrib()
                lea     10(SP),SP
                move.l  D0,D2
                bmi     toserr
                pea     fmodes(PC)
                jsr     @print_line(A4)
                bsr     fatt_out                  ;Fileattribute ausgeben
                jmp     (A4)

               IFEQ sprache
fmodes:        DC.B 'File-Attribute:',0
               ELSE
fmodes:        DC.B 'File-attributes:',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* RMDIR Folder                                                                 *
********************************************************************************
               ;>PART 'cmd_rmdir'
cmd_rmdir:      moveq   #$3A,D6                   ;Ddelete()
                bsr     getnam                    ;Filenamen holen
                beq     synerr
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     do_mediach                ;Media-Change ausl”sen
                move.l  A2,-(SP)
                move.w  D6,-(SP)
                bsr     do_trap_1                 ;Wegen "-36 : Access denied"
                addq.l  #6,SP
                tst.w   D0
                beq     ret_jump
                cmp.w   #-36,D0
                bne     toserr
                bra.s   do_tos2
               ;>ENDPART
********************************************************************************
* MKDIR Folder                                                                 *
********************************************************************************
               ;>PART 'cmd_mkdir'
cmd_mkdir:      moveq   #$39,D6                   ;Dcreate()
                bsr     getnam                    ;Filenamen holen
                beq     synerr
do_tos2:        moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     do_mediach                ;Media-Change ausl”sen
                move.l  A2,-(SP)
                move.w  D6,-(SP)
                bsr     do_trap_1
                addq.l  #6,SP
                tst.w   D0
                bmi     toserr
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* Erase File                                                                   *
********************************************************************************
               ;>PART 'cmd_erafile'
cmd_erase:      movea.l A0,A6
                bsr     get
                beq.s   cmd_erase2                ;alles l”schen
                movea.l A6,A0
                bsr     getnam                    ;Filenamen holen
                beq     synerr
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
cmd_erase1:     bsr     do_mediach                ;Media-Change ausl”sen
                move.l  A2,-(SP)
                move.w  #$41,-(SP)
                bsr     do_trap_1                 ;Fdelete()
                addq.l  #6,SP
                tst.w   D0
                bpl.s   cmd_erase1
                jmp     (A4)
cmd_erase2:     bsr     kill_programm             ;Altes Programm entfernen
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* FDC - alle FDC-Register anzeigen                                             *
********************************************************************************
               ;>PART 'cmd_fdc'
cmd_fdc:        moveq   #';',D0
                jsr     @chrout(A4)               ;Remark aus der Zeile machen
                moveq   #8,D2
cmd_fdc1:       move.w  fdc_tab(PC,D2.w),$FFFF8606.w ;FDC-Register selektieren
                bsr     read1772                  ;Register auslesen
                move.w  D0,D1
                bsr     hexbout                   ;Hexbyte ausgeben
                jsr     space                     ;und noch ein Space
                subq.w  #2,D2                     ;schon alle Register?
                bpl.s   cmd_fdc1                  ;Nein! =>
                moveq   #0,D1
                move.b  $FFFF8609.w,D1
                swap    D1
                move.b  $FFFF860B.w,D1            ;DMA-Adresse auslesen
                lsl.w   #8,D1
                move.b  $FFFF860D.w,D1
                bsr     hexlout                   ;als Langwort ausgeben
                jsr     @c_eol(A4)                ;Zeilenrest l”schen
                jsr     @crout(A4)                ;CR ausgeben
                jmp     (A4)
fdc_tab:       DC.W $90,$86,$84,$82,$80           ;FDC-Tabelle
               ;>ENDPART
********************************************************************************
* READTRACK [Spurnr[,[Side][,[Adr][,[Drive]]]]]                                *
********************************************************************************
               ;>PART 'cmd_rtrack'
cmd_rtrack:     bsr     get
                moveq   #85,D6
                bsr     get_it                    ;Spur
                beq.s   cmd_rt4
                bvc.s   cmd_rt1
                move.w  D1,dsk_track(A4)
                bsr     chkcom
                beq.s   cmd_rt4
cmd_rt1:        moveq   #1,D6
                bsr     get_it                    ;Seite
                beq.s   cmd_rt4
                bvc.s   cmd_rt2
                move.w  D1,dsk_side(A4)
                bsr     chkcom
                beq.s   cmd_rt4
cmd_rt2:        moveq   #-1,D6
                bsr     get_it                    ;Adresse (alles erlaubt)
                beq.s   cmd_rt4
                bvc.s   cmd_rt3
                move.l  D1,dsk_adr2(A4)
                bsr     chkcom
                beq.s   cmd_rt4                   ;Ende der Eingabe
cmd_rt3:        moveq   #1,D6
                bsr     get_it                    ;Drive
                beq.s   cmd_rt4
                bvc.s   cmd_rt4
                move.w  D1,dsk_drive(A4)
cmd_rt4:        move.l  first_free(A4),D0
                cmp.l   dsk_adr2(A4),D0           ;An den Anfang des freien Speichers
                bne.s   cmd_rt5                   ;Ja! Dann ja nich' l”schen!
                bsr     kill_programm             ;Den Speicher brauch ich!
cmd_rt5:        st      $043E.w                   ;Floppy-VBL sperren
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                moveq   #2,D0                     ;Drive A
                tst.w   dsk_drive(A4)
                beq.s   cmd_rt6
                moveq   #4,D0                     ;Drive B
cmd_rt6:        or.w    dsk_side(A4),D0           ;Seite dazu
                eori.w  #7,D0                     ;Bits für Hardware invertieren
                andi.w  #7,D0                     ;nur die 3 Low-Bits werden beeinflužt
                move    SR,-(SP)                  ;Status retten
                ori     #$0700,SR                 ;Interrupts ausschalten
                move.b  #14,$FFFF8800.w           ;Port A des Sound-Chips selektieren
                move.b  $FFFF8800.w,D1            ;Port A lesen
                andi.w  #$F8,D1                   ;Bits 0-2 l”schen
                or.w    D0,D1                     ;neue Bits setzen
                move.b  D1,$FFFF8802.w            ;und auf Port A schreiben
                move    (SP)+,SR                  ;Restore Status
                move.w  #$82,$FFFF8606.w          ;Spur-Reg. selektieren
                bsr.s   read1772                  ;und lesen
                move.w  D0,D7                     ;Spur merken
                move.w  dsk_track(A4),D0
                bsr.s   seek                      ;Spur ansteuern
                bmi     seekerr                   ;Timeout
                move.l  dsk_adr2(A4),D0           ;Track hierhin lesen
                move.l  D0,default_adr(A4)
                move.b  D0,$FFFF860D.w            ;erst das Low-Byte
                lsr.w   #8,D0
                move.b  D0,$FFFF860B.w            ;dann das Mid-Byte
                swap    D0
                move.b  D0,$FFFF8609.w            ;und zuletzt das High-Byte schreiben
                move.w  #$90,$FFFF8606.w          ;DMA-R/W toggeln
                move.w  #$0190,$FFFF8606.w
                move.w  #$90,$FFFF8606.w          ;DMA-Sectorcount selektieren
                moveq   #14,D0                    ;mit 14 laden (entspricht 7kB)
                bsr.s   wrt1772
                move.w  #$80,$FFFF8606.w          ;Command-Reg. selektieren
                moveq   #$E0,D0
                bsr.s   wrt1772                   ;Command => Read Track
                bsr.s   fdcwait                   ;warten, bis FDC fertig
                bmi     timeouterr                ;Timeout
                move.w  D7,D0
                bsr.s   seek                      ;alte Spur wieder ansteuern
                bmi     seekerr                   ;Timeout
                sf      $043E.w                   ;Floppy-VBL wieder freigeben
                jmp     (A4)

************************************************************************
* D0 nach DMA-Access                                                   *
************************************************************************
wrt1772:        and.l   #$FF,D0
                move.w  D0,$FFFF8604.w            ;FDC-Reg. bzw. DMA-Sectorcount schreiben
                move    #0,CCR
                rts

************************************************************************
* FDC-Register nach D0 lesen                                           *
************************************************************************
read1772:       move    #0,CCR
                move.w  $FFFF8604.w,D0            ;FDC-Reg. bzw. DMA-Sectorcount lesen
                and.l   #$FF,D0
                rts

************************************************************************
* Spur D0 ansteuern                                                    *
************************************************************************
seek:           move.w  #$86,$FFFF8606.w          ;Daten-Reg. selektieren
                bsr.s   wrt1772                   ;Tracknr. schreiben
                move.w  #$80,$FFFF8606.w          ;Command-Reg. selektieren
                moveq   #$13,D0
                bsr.s   wrt1772                   ;Command => Seek

************************************************************************
* Auf Einstellung der FDC-Arbeit warten (D0=Status, D0<0 => Timeout)   *
************************************************************************
fdcwait:        move.w  #$01A0,D0                 ;etwas warten, bis Busy gesetzt
litlwt:         dbra    D0,litlwt
                move.l  #$060000,D0               ;d5 als Timeout-Z„hler
readmfp:        btst    #5,$FFFFFA01.w            ;ist das Kommando beendet ?
                beq.s   read1772
                subq.l  #1,D0
                bne.s   readmfp
                move.w  #$D0,$FFFF8604.w          ;Command => Force Interrupt
                move.w  #$0100,D0                 ;Verz”gerungsschleife
timeou1:        dbra    D0,timeou1
                moveq   #-1,D0                    ;Timeoutflag setzen
                rts
               ;>ENDPART
********************************************************************************
* DISKREAD/WRITE - Sektoren lesen/schreiben                                    *
********************************************************************************
               ;>PART 'cmd_dread/write'
cmd_dread:      moveq   #8,D7
                bra.s   cmd_dsk
cmd_dwrite:     move.l  A0,-(SP)
                lea     dwrite_text(PC),A0
                jsr     ask_user                  ;Sicherheitsabfrage
                movea.l (SP)+,A0
                moveq   #9,D7
cmd_dsk:        bsr.s   get_dsk_par               ;Parameter holen
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                move.w  #1,-(SP)                  ;1 Sektor
                move.w  dsk_side(A4),-(SP)        ;Seite
                move.w  dsk_track(A4),-(SP)       ;Track
                move.w  dsk_sektor(A4),-(SP)      ;Sektor
                move.w  dsk_drive(A4),-(SP)       ;Drive
                clr.l   -(SP)                     ;Dummy
                move.l  dsk_adr(A4),-(SP)         ;Adresse
                move.w  D7,-(SP)                  ;Floprd = 8 / Flopwr = 9
                trap    #14
                lea     20(SP),SP
                movea.l dsk_adr(A4),A0
                move.l  A0,default_adr(A4)        ;Neue Defaultadr
                moveq   #0,D2
                move.w  #255,D1
cmd_ds1:        add.w   (A0)+,D2                  ;Checksum errechnen
                dbra    D1,cmd_ds1
                move.w  D2,checksum(A4)           ;und merken
                tst.w   D0
                bmi     toserr                    ;Fehler beim Lesen/Schreiben
                jmp     (A4)

               IFEQ sprache
dwrite_text:   DC.B 'Wollen Sie schreiben? (j/n) ',0
               ELSE
dwrite_text:   DC.B 'Write the sector? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* Parameter für DISKREAD/WRITE holen                                           *
********************************************************************************
               ;>PART 'get_dsk_par'
get_dsk_par:    bsr     get
                moveq   #85,D6
                bsr.s   get_it                    ;Track holen (0 bis 85)
                beq.s   enddsk                    ;Ende der Eingabe
                bvc.s   nxtdsk1                   ;Kein Parameter
                move.w  D1,dsk_track(A4)
                bsr     chkcom
                beq.s   enddsk                    ;Ende der Eingabe
nxtdsk1:        moveq   #0,D6
                move.w  #$FF,D6
                bsr.s   get_it                    ;Sektor holen (0 bis 255)
                beq.s   enddsk
                bvc.s   nxtdsk2
                move.w  D1,dsk_sektor(A4)
                bsr     chkcom
                beq.s   enddsk                    ;Ende der Eingabe
nxtdsk2:        moveq   #1,D6
                bsr.s   get_it                    ;Seite holen (0 oder 1)
                beq.s   enddsk
                bvc.s   nxtdsk3
                move.w  D1,dsk_side(A4)
                bsr     chkcom
                beq.s   enddsk                    ;Ende der Eingabe
nxtdsk3:        moveq   #-1,D6
                bsr.s   get_it                    ;Adresse (alles erlaubt)
                beq.s   enddsk
                bvc.s   nxtdsk4
                move.l  D1,dsk_adr(A4)
                bsr     chkcom
                beq.s   enddsk                    ;Ende der Eingabe
nxtdsk4:        moveq   #1,D6
                bsr.s   get_it                    ;Drive (0 oder 1)
                beq.s   enddsk
                bvc     synerr
                move.w  D1,dsk_drive(A4)
enddsk:         rts

get_it:         tst.b   D0
                beq.s   get_it2
                cmp.b   #',',D0
                beq.s   get_it1
                bsr     get_term                  ;Parameter holen
                tst.l   D1
                bmi     illequa
                cmp.l   D6,D1
                bhi     illequa
                move    #2,CCR                    ;Eingabe vorhanden (V-Flags gesetzt)
                rts
get_it1:        bsr     get
                move    #0,CCR                    ;Keine Eingabe    (alle Flags gel”scht)
get_it2:        rts                               ;Ende der Eingabe (Z-Flag gesetzt)
               ;>ENDPART
********************************************************************************
* MOUSEON / MOUSEOFF                                                           *
********************************************************************************
               ;>PART 'cmd_mon'
cmd_mon:        bsr.s   cmd_mon1
                jmp     (A4)
cmd_mon1:       linea   0     ;>linea   #0 [ Init ]
                move.l  4(A0),D0
                bls.s   cmd_mon2                  ;Adresse gültig? Ende, wenn nicht
                movea.l D0,A1
                clr.w   2(A1)                     ;CONTRL(1)
                clr.w   6(A1)                     ;CONTRL(3)
                movea.l 8(A0),A1
                clr.w   (A1)                      ;INTIN(0) Sofort anschalten
                linea   9     ;>linea   #9 ;>[ Showm ]
cmd_mon2:       rts
               ;>ENDPART
               ;>PART 'cmd_moff'
cmd_moff:       linea   0     ;>linea   #0 [ Init ]
                movea.l 4(A0),A1
                bls.s   cmd_moff1
                clr.w   2(A1)                     ;CONTRL(1)
                clr.w   6(A1)                     ;CONTRL(3)
                movea.l 8(A0),A1
                clr.w   (A1)                      ;INTIN(0) Sofort ausschalten
                linea   10     ;>linea   #10 ;>[ Hidem ]
cmd_moff1:      jmp     (A4)
               ;>ENDPART
*********************************************************************************
* 'SAVE' - File schreiben                                                      *
********************************************************************************
               ;>PART 'cmd_save'
cmd_save:       bsr     get
                bne.s   cmd_save2                 ;Zeilenende
cmd_save1:      tst.b   fname(A4)                 ;Filename berhaupt da?
                beq     illequa
                tst.l   basep(A4)                 ;Prg mit LEXEC geladen?
                bne     illequa
                tst.b   D0
                beq.s   cmd_save3
                subq.l  #1,A0                     ;Pointer zurück
                bra.s   cmd_save3
cmd_save2:      cmp.b   #'&',D0
                beq     degas_write
                cmp.b   #'!',D0
                beq     install_write             ;Install-Datei schreiben
                cmp.b   #',',D0
                beq.s   cmd_save1
                bsr     getnam_cont               ;Filenamen holen
                beq     synerr
cmd_save3:      pea     cmd_save9(PC)
                jsr     @print_line(A4)
                pea     fname(A4)
                jsr     @print_line(A4)
                bsr     get
                cmp.b   #',',D0
                bne.s   cmd_save4                 ;Keine Parameter
                bsr     get_parameter
                bcc.s   cmd_save5                 ;Parameter da
                bvc     synerr                    ;2.Parameter da (sollte aber nicht sein!)
cmd_save4:      movea.l merk_anf(A4),A2           ;Gemerkte Anfangsadresse
                movea.l merk_end(A4),A3           ;Gemerkte Endadresse
                bra.s   cmd_save6
cmd_save5:      bvs     synerr                    ;2.Parameter fehlt
cmd_save6:      move.l  A2,merk_anf(A4)
                move.l  A3,merk_end(A4)
                move.l  A3,D0
                sub.l   A2,D0                     ;Ende-Start=L„nge
                bls     illequa                   ;Startadresse gr”žer Endadresse
                pea     cmd_save10(PC)
                jsr     @print_line(A4)
                move.l  A2,D1
                bsr     hexout                    ;' from Anfadr'
                pea     cmd_save11(PC)
                jsr     @print_line(A4)
                move.l  A3,D1
                bsr     hexout                    ;' to Endadr'
                jsr     @space(A4)
                jsr     gleich_out
                sub.l   A2,D1                     ;Programml„nge
                moveq   #10,D2
                bsr     numout                    ;in dezimal ausgeben
                pea     cmd_save12(PC)            ;' Bytes.'
                jsr     @print_line(A4)
                lea     cmd_save13(PC),A0
                jsr     ask_user                  ;Sicherheitsabfrage
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                suba.l  A2,A3                     ;Ende-Start=L„nge
                bsr     fcreate                   ;File er”ffnen
                bsr     fwrite                    ;File schreiben
                bsr     fclose
                jmp     (A4)                      ;In Eingabeschleife zurück

               IFEQ sprache
cmd_save9:     DC.B 'Speichere ',0
cmd_save10:    DC.B ' von ',0
cmd_save11:    DC.B ' bis ',0
cmd_save12:    DC.B ' Bytes.',13,0
cmd_save13:    DC.B 'Wollen Sie speichern? (j/n) ',0
               ELSE
cmd_save9:     DC.B 'Save ',0
cmd_save10:    DC.B ' from ',0
cmd_save11:    DC.B ' to ',0
cmd_save12:    DC.B ' Bytes.',13,0
cmd_save13:    DC.B 'Save this file? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* DEGAS-Bild schreiben                                                         *
********************************************************************************
               ;>PART 'degas_write'
degas_write:    bsr     getnam                    ;Filenamen holen. "&" wird berlesen
                beq     synerr
                pea     cmd_save9(PC)
                jsr     @print_line(A4)
                pea     fname(A4)
                jsr     @print_line(A4)
                bsr     get
                tst.b   D0
                bne     syn_error                 ;Keine Parameter
                lea     user_scr(A4),A0
                movea.l scr_adr(A0),A1            ;Adresse des Bildschirms
                pea     cmd_save10(PC)
                jsr     @print_line(A4)
                move.l  A1,D1
                bsr     hexout                    ;' from Anfadr'
                jsr     @crout(A4)
                lea     cmd_save13(PC),A0
                jsr     ask_user                  ;Sicherheitsabfrage
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                bsr     fcreate                   ;File er”ffnen
                lea     2.w,A3
                lea     user_scr(A4),A0
                moveq   #0,D0
                move.b  scr_rez(A0),D0
                move.w  D0,-(SP)
                movea.l SP,A2
                bsr     fwrite                    ;die Aufl”sung schreiben
                addq.l  #2,SP
                lea     user_scr(A4),A0
                lea     scr_colors(A0),A2
                lea     32.w,A3
                bsr     fwrite                    ;die Farbpalette schreiben
                movea.l A1,A2
                movea.w #32000,A3
                bsr     fwrite                    ;Das Bild schreiben
                bsr     fclose
                jmp     (A4)                      ;In Eingabeschleife zurück
               ;>ENDPART
********************************************************************************
* Install-Datei schreiben                                                      *
********************************************************************************
               ;>PART 'install_write'
install_write:  bsr     get
                moveq   #0,D7                     ;normales File
install_write1: cmp.b   #'H',D0
                bne.s   install_write2            ;'H' für
                moveq   #2,D7                     ;hidden File
                bsr     get
install_write2: cmp.b   #'R',D0                   ;'R' für
                bne.s   install_write3
                st      do_resident(A4)           ;AUTO-Resident
                bsr     get
                bne.s   install_write1            ;evtl. noch ein 'H'
install_write3: bsr.s   install_name
                bsr     do_mediach                ;Media-Change ausl”sen
                move.w  D7,-(SP)                  ;Hidden?
                pea     fname(A4)
                move.w  #$3C,-(SP)
                bsr     do_trap_1                 ;Fcreate()
                addq.l  #8,SP
                tst.l   D0
                bmi     ioerr                     ;Fehler beim ™ffnen
                move.w  D0,_fhdle(A4)             ;Filehandle merken
                lea     default_start(A4),A2      ;Anfangsadresse
                lea     default_end(A4),A3
                suba.l  A2,A3                     ;L„nge
                bsr     fwrite
                bsr     fclose
                sf      do_resident(A4)           ;AUTO-Resident l”schen
                jmp     (A4)
               ;>ENDPART
               ;>PART 'install_name'
install_name:   lea     fname(A4),A0
                movea.l basepage(A4),A2
                movea.l $2C(A2),A2                ;Adresse des Environment-String holen
install_name1:  lea     install_name10(PC),A1
                move.b  (A2)+,D0
                beq.s   install_name6             ;Ende des Environment-Strings, nix
                cmp.b   (A1)+,D0
                beq.s   install_name3             ;1.Zeichen ist gleich ! =>
install_name2:  tst.b   (A2)+                     ;String bis zum Nullbyte berlesen
                bne.s   install_name2
                bra.s   install_name1             ;N„chste Variable vergleichen
install_name3:  move.b  (A2)+,D0
                beq.s   install_name1             ;Ende der Variable, nix gefunden
                move.b  (A1)+,D1
                beq.s   install_name4             ;gefunden!
                cmp.b   D1,D0
                bne.s   install_name2             ;ungleich, n„chste Variable
                bra.s   install_name3             ;weiter vergleichen
install_name4:  move.b  D0,(A0)+
install_name5:  move.b  (A2)+,(A0)+               ;Pfad bis zum Nullbyte kopieren
                bne.s   install_name5
                subq.l  #1,A0
install_name6:  lea     install_name8(PC),A1
install_name7:  move.b  (A1)+,(A0)+
                bne.s   install_name7
                rts

install_name8: DC.B 'BUGABOO.'
install_name9: DC.B 'INF',0
install_name10:DC.B 'SIGMA=',0
               EVEN
               ;>ENDPART
********************************************************************************
* Installation 'BUGABOO.INF' einlesen, evtl. neu erstellen                     *
********************************************************************************
               ;>PART 'install_read'
install_read:   movem.l D0-A6,-(SP)
                jsr     init_save                 ;für's Bildschirm speichern
                IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                bra     install_read1   ;nix da bei cart
.noUD:                
                ENDC

                lea     install_name9(PC),A0
                move.l  #'INF'<<8,(A0)
                bsr.s   install_name              ;'BUGABOO.INF' als Namen setzen
                clr.w   -(SP)
                pea     fname(A4)                 ;Anfangsadresse des Namens
                move.w  #$3D,-(SP)
                trap    #1                        ;Fopen()
                addq.l  #8,SP
                move.w  D0,D7                     ;alles OK?
                bmi.s   install_read1             ;unable to fopen file
                lea     default_start(A4),A5      ;Anfangsadresse
                lea     default_end(A4),A6
                suba.l  A5,A6                     ;Dateil„nge
                move.l  A5,-(SP)
                move.l  A6,-(SP)
                move.w  D7,-(SP)                  ;Filehandle auf den Stack
                move.w  #$3F,-(SP)
                trap    #1                        ;Fread()
                lea     12(SP),SP
                move.l  D0,-(SP)
                move.w  D7,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.l  #4,SP
                move.l  (SP)+,D0
                cmpa.l  D0,A6
                bne.s   install_read1             ;L„nge stimmt nicht
                cmpi.l  #'ä-So',(A5)+
                bne.s   install_read1
                cmpi.w  #'ft',(A5)                ;Stimmt die Kennung?
                bne.s   install_read1
                st      install_load(A4)
                movem.l (SP)+,D0-A6
                rts
install_read1:  lea     default_start(A4),A0
                move.l  #'ä-So',(A0)+             ;Kennung der Datei
                move.w  #'ft',(A0)
                move.b  #'?',exquantor(A4)        ;Suchjoker
                move.b  #'*',alquantor(A4)        ;    "
                move.w  #$10,disbase(A4)          ;Zahlenbasis des Disassemblers
                move.w  #16,def_lines(A4)         ;Defaultzeilenzahl
                move.w  #16,def_size(A4)          ;Breite bei Dump
                move.w  #$0555,col0(A4)           ;Debuggerfarben definieren
                clr.w   col1(A4)
                move.w  #20000,scroll_d(A4)       ;Scrollverz”gerung
                lea     convert_tab(A4),A0        ;Konvertierungtabelle erstellen
                moveq   #31,D0
install_read2:  move.b  #'ú',(A0)+
                dbra    D0,install_read2
                moveq   #95,D0
                moveq   #32,D1
install_read3:  move.b  D1,(A0)+
                addq.w  #1,D1
                dbra    D0,install_read3
                moveq   #$7F,D0
install_read4:  move.b  #'ú',(A0)+
                dbra    D0,install_read4
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* 'LOAD' - Programm von Diskette einlesen                                      *
********************************************************************************
               ;>PART 'cmd_load'
cmd_load:       bsr     get
                beq.s   cmd_load2
                cmp.b   #',',D0
                beq.s   cmd_load1
                bsr     getnam_cont               ;Filenamen holen
                beq     synerr
                bsr     get
                cmp.b   #',',D0
                bne.s   cmd_load2                 ;Komma hinter dem Filenamen fehlt!
cmd_load1:      bsr     get_parameter             ;Anfangsadresse für LOAD
                bvc     synerr                    ;Kein 2.Parameter erlaubt!
                bcc.s   cmd_load3                 ;1.Parameter fehlt
cmd_load2:      bsr     kill_programm             ;Altes Programm erstmal l”schen
                movea.l first_free(A4),A2         ;Erste freie Adresse im RAM nehmen
cmd_load3:      cmpa.l  #$400000,A2
                bhs.s   cmd_load4                 ;Adresse zu grož!
                movea.l A2,A6
                pea     cmd_load5(PC)
                jsr     @print_line(A4)
                move.l  A2,D1
                bsr     hexout                    ;Anfangsadresse ausgeben
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                move.l  A2,-(SP)                  ;und zus„tzlich merken
                bsr     readimg                   ;File einlesen
                pea     cmd_load6(PC)
                jsr     @print_line(A4)
                move.l  D6,D1                     ;Anzahl der gelesenen Bytes
                bsr     dezout                    ;Anzahl ausgeben
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                move.l  (SP)+,D1                  ;Startadresse
                move.l  D1,merk_anf(A4)
                move.l  D1,default_adr(A4)
                add.l   D6,D1                     ;plus Anzahl geladene Bytes
                move.l  D1,merk_end(A4)
                pea     cmd_load7(PC)
                jsr     @print_line(A4)
                subq.l  #1,D1
                bsr     hexout                    ;Endadresse ausgeben
                jsr     @c_eol(A4)
                jsr     @crout(A4)
cmd_load4:      jmp     (A4)                      ;Das war's

               IFEQ sprache
cmd_load5:     DC.B 'Startadresse    :',0
cmd_load6:     DC.B 'L„nge           :',0
cmd_load7:     DC.B 'Endadresse      :',0
               ELSE
cmd_load5:     DC.B 'Startadress     :',0
cmd_load6:     DC.B 'Length          :',0
cmd_load7:     DC.B 'Endadress       :',0
               ENDC
               ;>ENDPART
********************************************************************************
* 'LEXEC' - Load File for Execute                                              *
********************************************************************************
               ;>PART 'cmd_lexec'
cmd_lexec:      
               IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                bra     cmd_lexec5
.noUD:                
               ENDC

                tst.b   le_allowed(A4)
                beq     noallow

                moveq   #1,D0
                jsr     graf_mouse                ;Diskette anschalten
                moveq   #79,D1
                lea     spaced(A4),A1
cmd_lexec1:     clr.b   (A1)+                     ;Cmdline l”schen
                dbra    D1,cmd_lexec1
                bsr     get
                beq.s   cmd_lexec5
                cmp.b   #',',D0                   ;nur eine neue Cmdline?
                beq.s   cmd_lexec2                ;Ja! =>
                bsr     getnam_cont               ;Filenamen holen
                bsr     get
                cmp.b   #',',D0
                bne.s   cmd_lexec5
cmd_lexec2:     bsr     get
                cmp.b   #$22,D0
                bne     synerr
                lea     spaced+1(A4),A1
                moveq   #0,D1                     ;L„nge der Cmdline=0
cmd_lexec3:     move.b  (A0)+,D0
                beq.s   cmd_lexec4
                cmp.b   #$22,D0
                beq.s   cmd_lexec4
                addq.w  #1,D1
                move.b  D0,(A1)+
                bra.s   cmd_lexec3
cmd_lexec4:     move.b  #13,(A1)+                 ;CR anh„ngen
                move.b  D1,spaced(A4)
cmd_lexec5:     bsr     kill_programm             ;Altes Programm bei Bedarf entfernen
                IFEQ    ultradev
                bsr     load_symbols              ;Symboltabelle einlesen (falls vorhanden)
                ELSE
                CHECKEXTENSION_HASUD .hasUD
                bsr     load_symbols              ;Symboltabelle einlesen (falls vorhanden)
.hasUD:                
                ENDC
                bsr     initreg                   ;Register initialisieren
                clr.l   merk_end(A4)              ;Speicherdefaults l”schen
                clr.l   merk_anf(A4)

               IFEQ ultradev
                bsr     do_mediach                ;Media-Change ausl?sen
               ELSE
                CHECKEXTENSION_HASUD .hasUD2
                bsr     do_mediach                ;Media-Change ausl?sen
.hasUD2:
                CHECKEXTENSION_NOUD .noUD
                movem.l D1-A6,-(SP)

                movem.l D0-A6,-(SP)
                jsr     $FA0026         ;load prg from cart
                movem.l (SP)+,D0-A6

                bsr     load_symbols    ;Symboltabelle einlesen (falls vorhanden)

                move.l  UDCartridgeRamPos,a6
                move.l  $4000+udMyBasePage(a6),d0
                movem.l (SP)+,D1-A6
                bra     cmd_lexec6a
.noUD:                
               ENDC
                clr.l   -(SP)                     ;Originalenvironment weiterreichen
                pea     spaced(A4)                ;Commandline
                pea     fname(A4)                 ;Pointer auf Name
                move.l  #$4B0003,-(SP)            ;Programm einlesen
                bsr     do_trap_1                 ;einlesen
                lea     16(SP),SP
                tst.l   D0
                bmi     ioerr                     ;Negativ => Lach, lach, lach (ERROR)
                btst    #0,D0                     ;Basepageadresse des geladenen Programms
                bne     ioerr                     ;das war wohl nix...
cmd_lexec6a:
                movea.l D0,A1                     ;Pointer auf die Basepage
                move.l  A1,basep(A4)              ;Startadresse des Programms

cmd_lexec6:     movea.l 8(A1),A3
                move.l  A3,_pc(A4)                ;PC für Trace umsetzen auf Text-Segm.
                move.l  A3,default_adr(A4)        ;Disassemble-Adr auf Textsegment

                movem.l D0-A6,-(SP)
                ori     #$0700,SR                 ;IRQs sperren
                move.l  SP,load3(A4)              ;Stackpnt retten
                move.w  (A3),load1(A4)            ;Ersten Befehl retten
                move.w  #$4AFC,(A3)               ;Illegal einsetzen
                move.l  $10,load2(A4)
                lea     cmd_lexec7(PC),A0
                move.l  A0,$10.w                  ;Illegal instruction patchen
                bsr     clr_cache

                lea     lstackend(A4),SP
                move.l  A1,-(SP)                  ;Basepageadr
                clr.l   -(SP)
                move.l  #$4B0004,-(SP)            ;Programm starten
                trap    #1                        ;mehr Parameter werden nicht gebraucht
                movea.l load4(A4),A0
                jmp     (A0)

cmd_lexec7:     move    USP,A0
                movea.l 4(A0),A3                  ;Basepage
                andi    #$FBFF,SR                 ;IRQs wieder freigeben
                lea     varbase,A4
                movea.l load3(A4),SP              ;Stackpointer zurück
                move.l  load2(A4),$10.w           ;Illegal instruction auf normal
                movea.l 8(A3),A0                  ;Zeiger auf TEXT-Segment
                move.w  load1(A4),(A0)            ;Ersten Befehl wieder zurück
                movea.l $24(A3),A3                ;Zeiger auf Debugger (hoffentlich)
                move.l  $7C(A3),load5(A4)         ;Stackpnt merken
                bsr     clr_cache
                movem.l (SP),D0-A6

                bsr     reloc_symbols             ;Symboltabelle relozieren
                clr.w   _sr(A4)                   ;SR=0 (wie im ROM!)
                movea.l basep(A4),A0              ;Basepageadr des Programms
                move.l  24(A0),regs+12*4(A4)      ;A4 auf BSS-Segment-Start setzen
                move.l  16(A0),regs+13*4(A4)      ;A5 auf DATA-Segment-Start setzen
                movea.l 4(A0),A1                  ;p_hitpa holen
                move.l  A0,-(A1)                  ;Basepageadr
                lea     login(PC),A2              ;Returnadresse
                move.l  A2,-(A1)                  ;auf den Stack
                move.l  A1,_usp(A4)               ;USP setzen
                move.l  A1,rega7(A4)              ;aktiven Stackpointer setzen
                moveq   #8,D0
cmd_lexec8:     clr.l   -(A1)                     ;9 mal 0L
                dbra    D0,cmd_lexec8
                move.l  8(A0),-(A1)               ;Startadresse
                move.l  8(A0),merk_pc_call(A4)
                clr.w   -(A1)                     ;SR = 0
                movea.l #debug_sstack,A2
                adda.l  A4,A2
                move.l  A2,_ssp(A4)               ;SSP in die Registerliste
                move.l  A2,-(A1)                  ;SSP auch auf den Stack
                move.l  A1,regs+14*4(A4)          ;A6 auf den USER-Stack

                bsr     prg_info                  ;Meldung machen

                movem.l (SP)+,D0-A6
                jmp     (A4)                      ;Das war's
               ;>ENDPART

********************************************************************************
* 'ABOUT' - Platz für nähere Infos zu dieser Version                           *
********************************************************************************
               ;>PART 'cmd_about'
cmd_about:
                pea     about_txt
                jsr     @print_line(A4)
                jsr     @crout(A4)
                jmp     (A4)
               ;>ENDPART

********************************************************************************
* 'UDMIRROR' - mirror Bugaboo onto ultraDev VGA screen (prototype, 40x25 only) *
********************************************************************************
               ;>PART 'cmd_udmirror'
                IFNE ultradev
cmd_udmirror:
                CHECKEXTENSION_NOUD .noUD
                not.b   udmirror_enable(A4)

                tst.b   udmirror_enable(A4)
                beq.s   .udmirror_off
                ;this comamnd just enabled UDMIRROR => activate user screen (aka program under debug)
                jsr     @page2_force(A4)
                ;this comamnd just enabled UDMIRROR => set 80x25 screen mode
                movem.l A0-A1/A4,-(SP)

                moveq   #2,D0
                bsr     UDVidSetVideoMode
                bsr     ultradev_mirror_vga_init

                movem.l (SP)+,A0-A1/A4
                jmp     (A4)
.udmirror_off:  
                ;this comamnd just disabled UDMIRROR => activate BUGABOO screen
                jsr     @page1_force(A4)
                jmp     (A4)
.noUD:
                ;"no ultraDev found"
                pea     udmirror_txt(PC)
                jsr     @print_line(A4)
                ;jsr     @crout(A4)
                jmp     (A4)
               IFEQ sprache
udmirror_txt:  DC.B '?kein ultraDev gefunden',13,0
               ELSE
udmirror_txt:  DC.B '?no ultraDev found',13,0
               ENDC
               EVEN
                ENDC
               ;>ENDPART

********************************************************************************
* automatisches "Laden" aus dem RAM (šbergabe durch den Assembler)             *
********************************************************************************
               ;>PART 'autoload'
autoload:       moveq   #-1,D0
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                bsr     do_trap_1                 ;max.freien Speicherplatz ermitteln
                addq.l  #6,SP
                movea.l prg_base(A4),A6           ;Adresse des Headers
                moveq   #64,D1                    ;Sicherheit für den Stack
                add.l   2(A6),D1                  ;+ TEXT
                add.l   6(A6),D1                  ;+ DATA
                add.l   10(A6),D1                 ;+ BSS
                sub.l   D1,D0
                bmi     autoload10                ;Speicher reicht nicht!

                clr.w   spalte(A4)                ;damit die Adr nicht stehen bleibt
                bsr     kill_programm             ;normalerweise unn”tig
                bsr     initreg                   ;Register initialisieren
                clr.l   -(SP)                     ;Originalenvironment
                move.l  cmd_line_adr(A4),-(SP)    ;Commandlineadresse
                clr.l   -(SP)                     ;Pointer auf Name
                move.l  #$4B0005,-(SP)            ;Basepage erzeugen
                bsr     do_trap_1                 ;Pexec()
                lea     16(SP),SP
                tst.l   D0
                bmi     ioerr                     ;Negativ => Lach, lach, lach (ERROR)
                btst    #0,D0                     ;Basepageadresse des geladenen Programms
                bne     ioerr                     ;das war wohl nix...
                movea.l D0,A5
                move.l  A5,basep(A4)

                movea.l prg_base(A4),A6           ;Adresse des Headers
                clr.l   prg_base(A4)              ;erneuten Aufruf verhindern

                move.l  2(A6),D0                  ;L„nge des TEXT-Segments
                add.l   6(A6),D0                  ;+ L„nge des DATA-Segments
                lea     28(A6),A0                 ;Ab hier liegt der Code
                movea.l A0,A3
                lea     256(A5),A1                ;Hier soll der Code hin
                add.l   A1,D0
                movea.l A1,A2                     ;Anfangsadr des TEXT-Segments
autoload1:      move.l  (A0)+,(A1)+               ;Das Programm kopieren
                cmpa.l  D0,A1
                blo.s   autoload1

                lea     8(A5),A0
                move.l  A2,(A0)+                  ;Anfangsadr des TEXT-Segment
                move.l  2(A6),D0
                move.l  D0,(A0)+                  ;L„nge des TEXT-Segments
                adda.l  D0,A2
                move.l  A2,(A0)+                  ;Anfangsadr des DATA-Segments
                move.l  6(A6),D0
                move.l  D0,(A0)+                  ;L„nge des DATA-Segments
                adda.l  D0,A2
                move.l  A2,(A0)+                  ;Anfangsadr des BSS-Segments
                move.l  10(A6),(A0)+              ;L„nge des BSS-Segments

                adda.l  2(A6),A3                  ;+TEXT-L„nge
                adda.l  6(A6),A3                  ;+DATA-L„nge
                move.l  A3,D6                     ;evtl.Anffangsadresse der Symboltabelle
                tst.w   26(A6)                    ;berhaupt ein Reloc-Info da?
                bne.s   autoload5                 ;Ende, wenn dem so ist
                adda.l  14(A6),A3                 ;+L„nge der Symboltabelle
                tst.l   (A3)                      ;Reloc-Info vorhanden?
                beq.s   autoload5                 ;Fertig, wenn nicht
                movea.l 8(A5),A2                  ;Anfangsadr des TEXT-Segments
                move.l  A2,D0
                adda.l  (A3)+,A2                  ;erste zu relozierende Adresse
                moveq   #0,D1
autoload2:      add.l   D0,(A2)
autoload3:      move.b  (A3)+,D1                  ;Das Programm relozieren
                beq.s   autoload5
                cmp.w   #2,D1
                blo.s   autoload4
                adda.w  D1,A2
                bra.s   autoload2
autoload4:      lea     254(A2),A2
                bra.s   autoload3

autoload5:      movea.l D6,A1                     ;Das oberste Byte muž, da eine Adresse
                tst.b   (A1)                      ;ist, eigendlich ein Nullbyte sein!
                bne.s   autoload6                 ;Sonst ist's ein Fehler
                move.l  14(A6),D7
                move.l  D7,sym_size(A4)           ;Gr”že der Symboltabelle merken
                beq.s   autoload6                 ;Nein, Ende
                st      auto_sym(A4)              ;Symboltabelle durch den Assembler
                move.l  D6,sym_adr(A4)            ;Adresse der Symboltabelle merken
                add.l   D7,D6
                move.l  D6,sym_end(A4)            ;Endadresse+1

autoload6:      movea.l basep(A4),A1              ;hier liegt nun die Basepage
                move.l  merk_svar(A4),D0
                beq.s   autoload9                 ;keine Variablen bergeben
                movea.l D0,A3
                lea     simple_vars(A4),A0
                moveq   #9,D0                     ;10 Variablen werden erwartet
autoload7:      clr.l   (A0)                      ;Variable erstmal l”schen
                move.w  (A3)+,D1                  ;gibt's das Label noch?
                addq.w  #1,D1
                beq.s   autoload8
                move.l  (A3),D1
                add.l   8(A1),D1                  ;TEXT relativ
                move.l  D1,(A0)                   ;nur dann kopieren
autoload8:      addq.l  #4,A3
                addq.l  #4,A0
                dbra    D0,autoload7
autoload9:      movea.l $18(A1),A5                ;Anfangsadresse des BSS-Bereichs
                movea.l A5,A6
                adda.l  $1C(A1),A6                ;Endadresse des BSS-Bereichs
                bsr     _clear
                bra     cmd_lexec6

;Speicher reicht nicht!
autoload10:     clr.l   prg_base(A4)              ;erneuten Aufruf verhindern
                clr.b   help_allow(A4)            ;CTRL-HELP verbieten!
                moveq   #-39,D0
                bra     toserr                    ;"Less memory!"
               ;>ENDPART
********************************************************************************
* Commandline ab A0 in den Eingabebuffer bertragen und l”schen                *
********************************************************************************
               ;>PART 'do_cmdline'
do_cmdline:     ext.w   D0
                movea.l A0,A2                     ;Anfang der Kommandline merken
                lea     _zeile(A4),A1
                move.l  A1,input_pnt(A4)          ;Batch-Pnt setzen
                cmpi.b  #'@',(A0)+                ;Klammeraffe für Direktbefehl
                beq.s   do_cmdline1
                move.l  #'LE "',(A1)+             ;sonst stets LE Programm
                subq.l  #1,A0
                bsr.s   do_cmdline1               ;Filenamen bertragen
                move.b  #'"',-1(A1)               ;mit " abschlieáen
                clr.b   (A1)                      ;und noch ein Nullbyte dran
                rts
do_cmdline1:    move.b  (A0)+,(A1)+               ;Commandline bertragen
                dbra    D0,do_cmdline1
                clr.b   (A2)                      ;Commandline nun ungültig
                rts
               ;>ENDPART
********************************************************************************
* Befehl beim Start ausführen                                                  *
********************************************************************************
               ;>PART 'autodo'
autodo:         sf      autodo_flag(A4)
                lea     _zeile3(A4),A1
                clr.b   79(A1)                    ;Zeile mit Nullbyte abschliežen
                cmpi.b  #'$',(A1)
                bne.s   autodo1
                addq.l  #8,A1                     ;die Adresse berlesen
autodo1:        cmpi.b  #'@',(A1)+
                bne     main_loop5                ;Autoline?
                lea     _zeile(A4),A0
                movea.l A0,A2
                moveq   #79,D0
autodo2:        move.b  (A1)+,(A2)+               ;max.80 Zeichen in den Eingabebuffer
                dbeq    D0,autodo2
                move.l  A0,-(SP)
                jsr     @print_line(A4)           ;Inhalt der Zeile ausgeben
                jsr     @crout(A4)                ;und den Cursor in die n„chste Zeile
                bra     inp_loop1                 ;Zeile auswerten
               ;>ENDPART
********************************************************************************
* Symboltabelle einlesen                                                       *
********************************************************************************
               ;>PART 'load_symbols'
load_symbols:
               IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                move.l  a6,-(a7)
                move.l	UDCartridgeRamPos,a6
                move.l  $4000+udSymboltable(a6),d0
                move.l  (a7)+,a6

                tst.l   d0
                beq     load_symbols9
                bra     load_symbols1a
.noUD:                
               ENDC

                bsr     fopen
                moveq   #28,D1
                lea     spaced2(A4),A6
                bsr     fread                     ;Dateiheader einlesen
                move.l  D0,D1
                moveq   #-118,D0                  ;FAT may be defect
                moveq   #28,D2
                cmp.l   D2,D1
                bne     toserr                    ;sind auch 28 Bytes eingelesen worden?
                moveq   #-66,D0                   ;Default Fehlermeldung
                cmpi.w  #$601A,(A6)
                bne     ioerr                     ;Kein Prg-File
                move.l  2(A6),D0
                or.l    6(A6),D0                  ;alle Segmente positiv?
                or.l    10(A6),D0
                bmi     ioerr
                move.l  22(A6),prg_flags(A4)
                move.l  14(A6),D7                 ;Symboltabelle vorhanden?
                beq     load_symbols9             ;Nein, Ende
                lsl.l   #2,D7                     ;viermal soviel Speicher belegen
                move.l  D7,-(SP)
                move.w  #$48,-(SP)
                bsr     do_trap_1                 ;Platz für die Symboltabelle reservieren
                addq.l  #6,SP
                move.l  D0,D6
                bls     toserr                    ;Fehler bei der Speicherbelegung
               IFNE ultradev
load_symbols1a:
                CHECKEXTENSION_NOUD .noUD
                move.l  a6,-(a7)

                move.l	UDCartridgeRamPos,a6
                move.l  $4000+udSymboltable(a6),d6
                move.l  $4000+udSymboltablelen(a6),d7
                lsl.l   #2,d7
                move.l  (a7)+,a6
                movea.l D6,A6
.noUD:                
               ENDC                
                lsr.l   #2,D7
                move.l  D6,sym_adr(A4)            ;Adresse der Symboltabelle merken
                move.l  D6,sym_end(A4)
                add.l   D7,sym_end(A4)            ;Endadresse der Symboltabelle + 1
               IFNE ultradev
                CHECKEXTENSION_NOUD .noUD2
                bra.s   load_symbols1b
.noUD2:      
               ENDC
                move.l  2(A6),D0                  ;L„nge des TEXT-Segments
                add.l   6(A6),D0                  ;+ L„nge des DATA-Segments
                move.w  #1,-(SP)
                move.w  _fhdle(A4),-(SP)
                move.l  D0,-(SP)
                move.w  #$42,-(SP)
                bsr     do_trap_1                 ;Fseek(Offset,Fhandle,relative)
                lea     10(SP),SP
                tst.l   D0
                bmi     ioerr                     ;Fehler beim Seek
                movea.l D6,A6                     ;Startadresse des Speichers für Symtab
                move.l  D7,D1                     ;Gr”že der Symboltabelle
                bsr     fread                     ;Symboltabelle einlesen
                move.l  D0,D2
                moveq   #-118,D0                  ;FAT may be defect
                cmp.l   D1,D2                     ;Alles gelesen?
                bne     toserr
                bsr     fclose                    ;und Datei wieder schliežen
load_symbols1b:
                sf      gst_sym_flag(A4)
                movea.l A6,A5                     ;A6=Anfangsadr der Symboltabelle
                adda.l  D7,A5                     ;A5=Anfangsadr der Symbolnamen
                movea.l A5,A3                     ;A5=A3: Adresse merken
                movea.l A6,A2                     ;A6=A2: Schreibzeiger auf die Symboltabelle

load_symbols1:  move.l  (A6)+,(A2)+
                move.l  (A6)+,(A2)+
                move.l  (A6)+,(A2)+               ;Symboleintrag kopieren
                move.w  (A6)+,(A2)+
                movea.l A6,A0
                lea     -14(A6),A6
                moveq   #7,D0
load_symbols2:  move.b  (A6)+,(A5)+               ;max. 8 Zeichen kopieren
                dbeq    D0,load_symbols2
                beq.s   load_symbols5             ;Label < 8 Zeichen => Weiter
                cmpi.b  #$48,-5(A2)               ;Extended GST-Format?
                bne.s   load_symbols4             ;Nein! =>
                st      gst_sym_flag(A4)          ;GST Symboltabelle
                movea.l A0,A6
                lea     14(A0),A0                 ;Zeiger auf den Folgeeintrag
                moveq   #13,D0
load_symbols3:  move.b  (A6)+,(A5)+               ;max. 14 Zeichen Erweiterung kopieren
                dbeq    D0,load_symbols3
                beq.s   load_symbols5
load_symbols4:  clr.b   (A5)+
load_symbols5:  movea.l A0,A6
                cmpa.l  sym_end(A4),A6
                blo.s   load_symbols1
                move.l  A2,sym_end(A4)            ;neues Ende setzen
load_symbols6:  move.b  (A3)+,(A2)+               ;Symbolnamen aufrücken
                cmpa.l  A5,A2
                blo.s   load_symbols6
                movea.l sym_adr(A4),A0
                movea.l sym_end(A4),A1
                move.l  A1,D7
                sub.l   A0,D7
                move.l  D7,sym_size(A4)           ;Gr”že der Symboltabelle errechnen
                movea.l A1,A2
load_symbols7:  move.l  A1,(A0)+                  ;Adresse setzen
                clr.l   (A0)
                lea     10(A0),A0                 ;Zeiger auf den n„chsten Eintrag
load_symbols8:  tst.b   (A1)+                     ;Label berlesen
                bne.s   load_symbols8
                cmpa.l  A2,A0                     ;Ende erreicht?
                blo.s   load_symbols7             ;Nein! => Weiter
                suba.l  sym_adr(A4),A1
                move.l  A1,-(SP)                  ;L„nge der Symboltabelle
                move.l  sym_adr(A4),-(SP)         ;Anfangsadresse
                move.l  #$4A0000,-(SP)
                bsr     do_trap_1                 ;Mshrink()
                lea     12(SP),SP
load_symbols9:  rts
               ;>ENDPART
********************************************************************************
* Symboltabelle relozieren                                                     *
********************************************************************************
               ;>PART 'reloc_symbols'
reloc_text1:   DC.B 'Symboltabelle muž ',0
reloc_text2:   DC.B 'segment-relativ',0
reloc_text3:   DC.B 'programm-relativ',0
reloc_text4:   DC.B ' sein.',13,0
reloc_text5:   DC.B 'fehlerhaft',0
               EVEN

reloc_symbols:  tst.l   sym_size(A4)              ;Gr”že der Symboltabelle merken
                beq.s   load_symbols9             ;Keine Symboltabelle
                movea.l basep(A4),A0              ;Basepageadr des Programms
                move.l  $0C(A0),D3                ;TEXT-Len
                move.l  $14(A0),D4                ;DATA-Len
                move.l  $1C(A0),D5                ;BSS-Len
                move.l  D3,D6
                add.l   D4,D6                     ;TEXT-Len + DATA-Len
                movea.l sym_adr(A4),A1            ;Anfangsadr der Symboltabelle
                movea.l sym_end(A4),A2            ;Endadr+1 der Symboltabelle
                moveq   #0,D2                     ;Labelbase nicht „ndern
reloc_symbols1: move.l  10(A1),D1                 ;Register-Equate bzw. Konstante
                move.b  8(A1),D0                  ;Symboltyp
                btst    #1,D0                     ;TEXT-relativ?
                beq.s   reloc_symbols2
                cmp.l   D3,D1                     ;Label => TEXT-Len?
                bls.s   reloc_symbols2            ;Nein =>
                moveq   #3,D2                     ;Fehler!
reloc_symbols2: btst    #2,D0                     ;DATA-relativ?
                beq.s   reloc_symbols4
                cmp.l   D4,D1                     ;Label > DATA-Len
                bls.s   reloc_symbols3
                bset    #0,D2                     ;S-unm”glich
                bra.s   reloc_symbols4
reloc_symbols3: cmp.l   D3,D1                     ;Label < TEXT-Len
                bhs.s   reloc_symbols4
                bset    #1,D2                     ;P-unm”glich
reloc_symbols4: btst    #0,D0                     ;BSS-relativ?
                beq.s   reloc_symbols6
                cmp.l   D5,D1                     ;Label > BSS-Len
                bls.s   reloc_symbols5
                bset    #0,D2                     ;S-unm”glich
                bra.s   reloc_symbols6
reloc_symbols5: cmp.l   D6,D1                     ;Label < TEXT-Len+DATA-Len
                bhs.s   reloc_symbols6
                bset    #1,D2                     ;P-unm”glich
reloc_symbols6: lea     14(A1),A1
                cmpa.l  A2,A1
                blo.s   reloc_symbols1            ;Ende der Symtab noch nicht erreicht

                tst.b   D2                        ;Symboltabellenformat nicht erkannt?
                beq.s   reloc_symbols10           ;genau! =>
                pea     reloc_text1(PC)
                jsr     @print_line(A4)
                lea     reloc_text5(PC),A1
                cmp.b   #3,D2
                beq.s   reloc_symbols9
                cmp.b   #1,D2                     ;Segment-relativ unm”glich?
                beq.s   reloc_symbols7            ;Ja! =>
                lea     reloc_text2(PC),A1
                moveq   #$18,D1                   ;Symbole auch DATA- & BSS-relativ
                moveq   #$10,D2
                bra.s   reloc_symbols8
reloc_symbols7: lea     reloc_text3(PC),A1
                moveq   #8,D1                     ;Symbole stets TEXT-relativ
                moveq   #8,D2
reloc_symbols8: move.b  D1,reloc_symbols12+1
                move.b  D2,reloc_symbols13+1
reloc_symbols9: move.l  A1,-(SP)
                jsr     @print_line(A4)
                pea     reloc_text4(PC)
                jsr     @print_line(A4)

reloc_symbols10:movea.l basep(A4),A0              ;Basepageadr des Programms
                movea.l sym_adr(A4),A1            ;Anfangsadr der Symboltabelle
                movea.l sym_end(A4),A2            ;Endadr+1 der Symboltabelle
reloc_symbols11:move.l  10(A1),D1                 ;Register-Equate bzw. Konstante
                move.b  8(A1),D0                  ;Symboltyp
reloc_symbols12:moveq   #$18,D2                   ;BSS-Offset
                btst    #0,D0                     ;BSS-relatives Label
                bne.s   reloc_symbols14
                moveq   #8,D2                     ;TEXT-Offset
                btst    #1,D0                     ;TEXT-relatives Label?
                bne.s   reloc_symbols14
reloc_symbols13:moveq   #$10,D2                   ;DATA-Offset
                btst    #2,D0                     ;DATA-relatives Label
                beq.s   reloc_symbols15
reloc_symbols14:add.l   0(A0,D2.w),D1             ;relozieren
reloc_symbols15:move.l  D1,10(A1)                 ;Wert wieder eintragen
                lea     14(A1),A1
                cmpa.l  A2,A1
                blo.s   reloc_symbols11           ;Ende noch nicht erreicht
                subq.l  #4,A2
                movea.l A2,A1                     ;rechte Grenze des Quicksort
                movea.l sym_adr(A4),A0            ;Anfangsadr der Symboltabelle
                lea     10(A0),A0                 ;linke Grenze des Quicksort
               ;>ENDPART
********************************************************************************
* Quicksort(A0,A1)                                                             *
********************************************************************************
               ;>PART 'quicks'
quicks:         movem.l A3-A4,-(SP)
                movea.l A0,A2
                movea.l A1,A3
                moveq   #0,D7
                move.l  (A0),D1
                move.l  (A1),D2
                move.l  D1,D0
                add.l   D2,D0
                roxr.l  #1,D0                     ;Mittelwert nehmen
quicks0:        cmp.l   D0,D1
                bhs.s   quicks1
                lea     14(A0),A0
                move.l  (A0),D1
                bra.s   quicks0

quicks1:        cmp.l   D0,D2
                bls.s   quicks2
                lea     -14(A1),A1
                move.l  (A1),D2
                bra.s   quicks1

quicks2:        cmpa.l  A1,A0
                bhi.s   quicks3
                move.l  D1,(A1)
                move.l  D2,(A0)
                lea     -10(A0),A0
                lea     -10(A1),A1
                movem.l (A0),D3-D4
                move.w  8(A0),D5
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.w  (A1)+,(A0)+
                movem.l D3-D4,-10(A1)
                move.w  D5,-2(A1)
                lea     14(A0),A0
                lea     -14(A1),A1
                move.l  (A0),D1
                move.l  (A1),D2
quicks3:        cmpa.l  A1,A0
                bls.s   quicks0

                movea.l A0,A4
                cmpa.l  A1,A2
                bhs.s   quicks4
                movea.l A2,A0
                bsr.s   quicks
quicks4:        cmpa.l  A3,A4
                bhs.s   quicks5
                movea.l A4,A0
                movea.l A3,A1
                bsr.s   quicks
quicks5:        movem.l (SP)+,A3-A4
                rts
               ;>ENDPART
********************************************************************************
* Altes Programm aus dem Speicher entfernen                                    *
********************************************************************************
               ;>PART 'kill_programm'
kill_programm:  movem.l D0-A6,-(SP)
                tst.l   basep(A4)                 ;Kein Programm geladen
                bls.s   kill_programm5
                bsr     clr_cache
                move    SR,merk_quit_sr(A4)
                move.l  $B8.w,load6(A4)
                lea     __rte(PC),A0
                move.l  A0,$B8.w                  ;XBIOS auf RTE (Uhrzeit holen...)
                ori     #$0700,SR                 ;IRQs sperren
                move.l  SP,load3(A4)
                movea.l act_pd(A4),A0
                move.l  basep(A4),(A0)            ;Nachgeladenes Prg in act_pd
                movea.l merk_act_pd(A4),A0
                move.l  load5(A4),$7C(A0)         ;Alter Stackpnt
                lea     kill_programm4(PC),A0
                move.l  A0,load4(A4)              ;Gemdos-Patch unterbinden (Zielsprung)
                clr.w   -(SP)
                trap    #1                        ;Das Childs terminieren

kill_programm4: move    merk_quit_sr(A4),SR
                movea.l load3(A4),SP
                movea.l act_pd(A4),A0
                move.l  merk_act_pd(A4),(A0)      ;aktives Prg zurücksetzen
                move.l  load6(A4),$B8.w           ;alten TRAP #14 zurück
                movea.l basep(A4),A6              ;Basepage des Child-Prozess
                move.l  $2C(A6),-(SP)
                move.w  #$49,-(SP)
                trap    #1                        ;Environment freigeben
                addq.l  #6,SP
                move.l  A6,-(SP)
                move.w  #$49,-(SP)
                trap    #1                        ;Child freigeben
                addq.l  #6,SP
                clr.l   basep(A4)                 ;Programm abmelden
                bsr     cmd_mon1                  ;Maus wieder an
kill_programm5: move.l  sym_adr(A4),D0
                beq.s   kill_programm6            ;Keine Symboltabelle vorhanden
                tst.b   auto_sym(A4)              ;Symboltabelle durch den Assembler?
                bne.s   kill_programm6
                move.l  D0,-(SP)
                move.w  #$49,-(SP)
                trap    #1                        ;Symboltabelle freigeben
                addq.l  #6,SP
                clr.l   sym_adr(A4)
                clr.l   sym_size(A4)
kill_programm6: movem.l (SP)+,D0-A6
                rts
__rte:          rte
               ;>ENDPART
********************************************************************************
* ';' - ASCII-Dump „ndern                                                      *
********************************************************************************
               ;>PART 'cmd_achng'
cmd_achng:      ori     #$0700,SR
                bsr     get
                cmp.b   #$22,D0
                bne     synerr                    ;Hochkomma am Anfang
                movea.l default_adr(A4),A6
                moveq   #63,D5                    ;64 Bytes einlesen
cmd_achng1:     move.b  (A0)+,D0
                cmp.b   #'ú',D0
                beq.s   cmd_achng2
                bsr     check_write
                bne.s   cmd_achng2
                move.b  D0,(A6)                   ;Byte bernehmen
cmd_achng2:     addq.l  #1,A6
                dbra    D5,cmd_achng1
                move.l  A6,default_adr(A4)        ;Neue Defaultadr
                bsr     get
                cmp.b   #$22,D0
                bne     synerr                    ;Hochkomma am Ende
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* 'ASCII' - ASCII-Dump                                                         *
********************************************************************************
               ;>PART 'cmd_asc'
cmd_asc:        bsr     get2adr                   ;max.2 Parameter holen
                move.w  D2,-(SP)                  ;Zeilenanzahl
                move.l  A3,-(SP)                  ;Endadresse
                movea.l A2,A6
                move.l  A6,default_adr(A4)
cmd_asc1:       bsr.s   asc_out                   ;ASCII-Dump ausgeben
                jsr     @crout(A4)                ;CR noch dran
                bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_asc3                  ;ja!
                tst.l   (SP)                      ;list n Zeilen?
                bne.s   cmd_asc2                  ;nein.List bis Adresse.
                subi.w  #1,4(SP)                  ;Counter decrement
                bpl.s   cmd_asc1                  ;noch nicht null,weiter listen
                bra.s   cmd_asc3                  ;und weiter wie blich
cmd_asc2:       cmpa.l  (SP),A6
                blo.s   cmd_asc1
cmd_asc3:       move.l  A6,default_adr(A4)
                jmp     (A4)                      ;Stack wird dort korrigiert
               ;>ENDPART
               ;>PART 'asc_out'
asc_out:        lea     spaced2(A4),A0
                st      testwrd(A4)
                move.l  A6,D1
                jsr     @anf_adr(A4)
                lea     convert_tab(A4),A3
                move.b  #')',(A0)+                ;id_char für ASCII-Dump
                move.b  #' ',(A0)+
                move.b  #$22,(A0)+                ;Hochkomma ausgeben
                moveq   #63,D3                    ;64 Zeichen ausgeben
asc_out1:       move.b  #'-',(A0)                 ;'-' <=> Zugriff nicht m”glich
                bsr     check_read
                bne.s   asc_out2
                moveq   #0,D0
                move.b  (A6),D0                   ;ASCII-Zeichen kopieren
                move.b  0(A3,D0.w),(A0)           ;Zeichen konvertieren
asc_out2:       addq.l  #1,A0
                addq.l  #1,A6
                dbra    D3,asc_out1
                move.b  #$22,(A0)+
                clr.b   (A0)
                sf      testwrd(A4)
                lea     spaced2(A4),A0
                move.w  zeile(A4),D0
                jmp     write_line                ;Zeile ausgeben
               ;>ENDPART
********************************************************************************
* 'DUMP' - Memory dump                                                         *
********************************************************************************
               ;>PART 'cmd_dump'
cmd_dump:       moveq   #0,D3                     ;Default = Byte
                bsr     get
                beq.s   cmd_dump1                 ;Leereingabe
                bsr     get_extension             ;Befehlsextension nach D3 holen
                tst.w   D0
                beq.s   cmd_dump1
                subq.l  #1,A0                     ;Pointer zurück
cmd_dump1:      bsr     get2adr                   ;Parameter holen
                bsr.s   cmd_dump2
                jmp     (A4)
               ;>ENDPART
               ;>PART 'cmd_dump2'
cmd_dump2:      move.w  D2,-(SP)                  ;Zeilenanzahl
                move.l  A3,-(SP)                  ;Endadresse
                move.l  A2,D0
                tst.w   D3

                beq.s   cmd_dump3                 ;Bei Bytebreite nicht beradigen
                btst    #0,D0                     ;Anfangsadresse muž gerade sein
                beq.s   cmd_dump3
                addq.l  #1,D0
cmd_dump3:      movea.l D0,A6
                move.l  A6,default_adr(A4)
cmd_dump4:      bsr.s   cmd_dump7                 ;Zeile auslisten
                jsr     @crout(A4)                ;CR noch dran
                bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_dump6                 ;ja!
                tst.l   (SP)                      ;list n Zeilen?
                bne.s   cmd_dump5                 ;nein.List bis Adresse.
                subi.w  #1,4(SP)                  ;Counter decrement
                bpl.s   cmd_dump4                 ;noch nicht null,weiter listen
                bra.s   cmd_dump6                 ;und weiter wie blich
cmd_dump5:      cmpa.l  (SP),A6
                blo.s   cmd_dump4
cmd_dump6:      move.l  A6,default_adr(A4)
                addq.l  #6,SP                     ;Stack korrigieren
                rts

cmd_dump7:      lea     spaced2(A4),A0
cmd_dump8:      st      testwrd(A4)
                lea     convert_tab(A4),A3
                tst.w   D3                        ;Byte-Dump?
                beq.s   cmd_dump12                ;Ja: Zeile ausgeben
                bra     cmd_dump22                ;Zeile mit .W/.L ausgeben

cmd_dump9:     DC.B '0123456789ABCDEF'
cmd_dump10:    DC.B '0123456789abcdef'

cmd_dump11:     sf      testwrd(A4)
                rts
cmd_dump12:     move.l  A6,D1
                jsr     @anf_adr(A4)
                lea     cmd_dump10(PC),A5
                tst.w   small(A4)
                bne.s   cmd_dump13
                lea     cmd_dump9(PC),A5
cmd_dump13:     moveq   #6,D6                     ;7.Spalte
                move.w  def_size(A4),D2           ;n Bytes pro Zeile
                moveq   #',',D7
                moveq   #0,D0
                subq.w  #1,D2
                bmi.s   cmd_dump11                ;Keine Bytes pro Zeile
cmd_dump14:     move.b  D7,(A0)+                  ;Komma einsetzen
                bsr     check_read                ;Zugriff erlaubt?
                bne.s   cmd_dump20                ;Nein! =>
                move.b  (A6)+,D0                  ;Byte aus dem Speicher holen
                move.b  D0,D1
                lsr.b   #4,D0
                move.b  0(A5,D0.w),(A0)+          ;Hexbyte einsetzen
                andi.w  #$0F,D1
                move.b  0(A5,D1.w),(A0)+
cmd_dump15:     addq.w  #3,D6                     ;6 Spalten mehr
                dbra    D2,cmd_dump14
cmd_dump16:     move.w  def_size(A4),D7
                neg.w   D6
                addi.w  #54,D6
                moveq   #' ',D1
cmd_dump17:     move.b  D1,(A0)+                  ;Tab
                dbra    D6,cmd_dump17
                suba.w  D7,A6
                subq.w  #1,D7
                moveq   #0,D0
                move.b  #$22,(A0)+
cmd_dump18:     bsr     check_read
                bne.s   cmd_dump21
                move.b  (A6)+,D0                  ;ASCII-Zeichen kopieren
                move.b  0(A3,D0.w),(A0)+          ;Zeichen konvertieren
cmd_dump19:     dbra    D7,cmd_dump18
                move.b  #$22,(A0)+
                clr.b   (A0)                      ;Zeilenabschluž
                sf      testwrd(A4)
                lea     spaced2(A4),A0
                move.w  zeile(A4),D0
                jmp     write_line
cmd_dump20:     addq.l  #1,A6
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                bra.s   cmd_dump15
cmd_dump21:     addq.l  #1,A6
                move.b  #'-',(A0)+
                bra.s   cmd_dump19

cmd_dump22:     move.l  A6,D1
                addq.l  #1,D1
                andi.b  #$FE,D1                   ;Adresse nun gerade
                movea.l D1,A6
                cmp.w   #1,D3
                bne.s   cmd_dump27                ;Ist also Long

                jsr     @anf_adr(A4)
                move.b  #'.',(A0)+
                move.b  #'w',(A0)+
                move.b  #' ',(A0)+
                moveq   #8,D6                     ;9.Spalte
                move.w  def_size(A4),D4
                addq.w  #1,D4
                lsr.w   #1,D4
                subq.w  #1,D4
                bpl.s   cmd_dump24
                bra     cmd_dump11
cmd_dump23:     move.b  #',',(A0)+                ;',' ausgeben
cmd_dump24:     bsr     check_read
                bne.s   cmd_dump26                ;Adresse nicht lesbar
                move.w  (A6)+,D1
                bsr     hexwout                   ;Word in Hex ausgeben
cmd_dump25:     addq.w  #5,D6
                dbra    D4,cmd_dump23
                move.w  def_size(A4),D4
                andi.w  #1,D4
                neg.w   D4
                beq     cmd_dump16
                addq.w  #2,D4
                suba.w  D4,A6
                bra     cmd_dump16                ;ASCII-Ausgabe
cmd_dump26:     addq.l  #2,A6
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                bra.s   cmd_dump25

cmd_dump27:     jsr     @anf_adr(A4)
                move.b  #'.',(A0)+
                move.b  #'l',(A0)+
                move.b  #' ',(A0)+
                moveq   #8,D6                     ;9.Spalte
                move.w  def_size(A4),D4
                addq.w  #3,D4
                lsr.w   #2,D4
                subq.w  #1,D4
                bpl.s   cmd_dump29
                bra     cmd_dump11
cmd_dump28:     move.b  #',',(A0)+
cmd_dump29:     bsr     check_read
                bne.s   cmd_dump32
                move.w  (A6)+,D1
                bsr     hexwout                   ;Word in Hex ausgeben
cmd_dump30:     bsr     check_read
                bne.s   cmd_dump33
                move.w  (A6)+,D1
                bsr     hexwout                   ;Word in Hex ausgeben
cmd_dump31:     addi.w  #9,D6
                dbra    D4,cmd_dump28
                move.w  def_size(A4),D4
                andi.w  #3,D4
                neg.w   D4
                beq     cmd_dump16
                addq.w  #4,D4
                suba.w  D4,A6
                bra     cmd_dump16                ;ASCII-Ausgabe
cmd_dump32:     addq.l  #2,A6
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                bra.s   cmd_dump30
cmd_dump33:     addq.l  #2,A6
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                move.b  #'-',(A0)+
                bra.s   cmd_dump31
               ;>ENDPART
********************************************************************************
* 'DISASSEMBLE' / 'LIST' - Disassemblieren eines Speicherbereichs              *
********************************************************************************
               ;>PART 'cmd_list/f/disass'
cmd_listf:      move.b  #'L',hexbase              ;Label statt Hex
cmd_list:       st      list_flg(A4)              ;Symbolisch
                bra.s   cmd_disass1
cmd_disass:     sf      list_flg(A4)              ;naja, nicht symbolisch
cmd_disass1:    bsr     get2adr                   ;2 Parameter holen (inkl.Zeilenanzahl)
                bsr.s   cmd_disass2
                jmp     (A4)                      ;Stack wird dort korrigiert
               ;>ENDPART
               ;>PART 'cmd_disass2'
cmd_disass2:    move.w  D2,-(SP)                  ;Zeilenanzahl
                move.l  A3,-(SP)                  ;Endadresse
                movea.l A2,A6
                move.l  A6,default_adr(A4)
cmd_disass3:    bsr     do_disass                 ;Zeile auslisten
                bne.s   cmd_disass4               ;Illegaler RAM-Bereich => keine Ausgabe
                jsr     @crout(A4)                ;CR noch dran
cmd_disass4:    bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_disass6               ;ja!
                tst.l   (SP)                      ;list n Zeilen?
                bne.s   cmd_disass5               ;nein.List bis Adresse.
                subi.w  #1,4(SP)                  ;Counter decrement
                bpl.s   cmd_disass3               ;noch nicht null,weiter listen
                bra.s   cmd_disass6               ;und weiter wie blich
cmd_disass5:    cmpa.l  (SP),A6
                blo.s   cmd_disass3
cmd_disass6:    move.l  A6,default_adr(A4)
                sf      list_flg(A4)
                addq.l  #6,SP                     ;Stack korrigieren
                rts
               ;>ENDPART
********************************************************************************
* '?' - Ausdruck auswerten, Zahlensysteme                                      *
********************************************************************************
               ;>PART 'cmd_calc'
cmd_calc:       bsr     get                       ;1.Zeichen des Ausdrucks holen
                bsr     get_term                  ;ganzen Ausdruck holen
                move.w  D0,D7
                movea.l A0,A6
                bsr     hexout
                jsr     @space(A4)                ;Space
                btst    #31,D1                    ;Zahl negativ?
                beq.s   cmd_calc1                 ;sonst nicht ausgeben
                moveq   #'(',D0
                jsr     @chrout(A4)
                moveq   #'-',D0
                jsr     @chrout(A4)
                neg.l   D1
                bsr     hexout                    ;negative Hexzahl ausgeben
                neg.l   D1
                moveq   #')',D0
                jsr     @chrout(A4)
                jsr     @space(A4)
cmd_calc1:      bsr     dezout
                jsr     @space(A4)                ;Space
                moveq   #2,D2
                bsr     numout                    ;Bin„r
                jsr     @space(A4)                ;Space
                moveq   #$22,D0
                jsr     @chrout(A4)               ;Hochkomma
                moveq   #3,D6                     ;4 ASCII-Zeichen
cmd_calc2:      rol.l   #8,D1                     ;mit dem obersten Byte anfangen
                move.b  D1,D0
                jsr     charcout                  ;als ASCII ausgeben
                dbra    D6,cmd_calc2
                moveq   #$22,D0
                jsr     @chrout(A4)               ;Hochkomma
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                movea.l A6,A0
                cmp.b   #',',D7                   ;Noch ein Term?
                beq.s   cmd_calc
                jmp     (A4)                      ;das war's
               ;>ENDPART
********************************************************************************
* 'CLS' - 2.Bildschirmseite l”schen                                            *
********************************************************************************
               ;>PART 'cmd_cls'
cmd_cls:        move.w  #27,-(SP)
                move.l  #$030002,-(SP)
                trap    #13
                addq.l  #6,SP
                move.w  #'E',-(SP)
                move.l  #$030002,-(SP)
                trap    #13
                addq.l  #6,SP
                jmp     (A4)                      ;zu l”schen (XBIOS & GEMDOS-Aufruf!)
               ;>ENDPART
********************************************************************************
* CONTINUE für Find                                                            *
********************************************************************************
               ;>PART 'cmd_cont'
cmd_cont:       lea     data_buff(A4),A1
                movea.l A1,A5
                movea.l find_cont1(A4),A2         ;akt.Adresse neu setzen
                movea.l find_cont2(A4),A3         ;Endadresse neu setzen
                move.w  find_cont3(A4),D3         ;L„nge des Suchstrings
                move.b  find_cont0(A4),D0
                subq.b  #1,D0
                beq     cmd_findasc5              ;Ascfind
                bpl.s   cmd_cont1

                move.b  find_cont0(A4),D5
                bra.s   cmd_find5                 ;Hunt & Find

cmd_cont1:      pea     cont_txt(PC)
                jsr     @print_line(A4)
                jsr     @crout(A4)
                jmp     (A4)

               IFEQ sprache
cont_txt:      DC.B '?Nicht m”glich',0
               ELSE
cont_txt:      DC.B '?Not possible',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* 'FIND' - Bytefolge suchen                                                    *
********************************************************************************
               ;>PART 'cmd_find'
cmd_find:       bsr     get
                cmp.b   #',',D0
                beq.s   cmd_find2
                subq.l  #1,A0                     ;Pointer zurück
                bsr     get_parameter
                bra.s   cmd_find4
cmd_find2:      move.l  basep(A4),D1              ;Programm mit LEXEC geladen
                beq.s   cmd_find3                 ;Keine Basepage, also nicht
                movea.l D1,A6
                movea.l 8(A6),A2                  ;Adresse des TEXT-Segments => Startadr
                movea.l 24(A6),A3                 ;Adresse des BSS-Segments => Endadr
                bra.s   cmd_find4
cmd_find3:      move.l  merk_anf(A4),D1           ;Prg mit LOAD geladen?
                beq     illequa                   ;Kein Suchbereich!
                movea.l D1,A2                     ;Anfangsadr
                movea.l merk_end(A4),A3           ;Endadr
cmd_find4:      bsr     get_such_para
cmd_find5:      move.b  (A1),D4                   ;1.Zeichen des Suchtextes
                cmp.b   (A2)+,D4
                beq.s   cmd_find8
cmd_find6:      cmpa.l  A3,A2
                blo.s   cmd_find5
                move.b  #2,find_cont0(A4)
cmd_find7:      move.l  A2,default_adr(A4)
                jsr     @crout(A4)
                jmp     (A4)                      ;fertig
cmd_find8:      bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_find13                ;Ausstieg
                move.l  A2,-(SP)                  ;1.Zeichen war gleich
                clr.w   D0                        ;Zeiger in den Suchtext
                subq.l  #1,A2                     ;vergleicht nochmal das gleiche
cmd_find9:      move.b  0(A1,D0.w),D4
                cmp.b   (A2)+,D4
                bne.s   cmd_find12                ;Notfound
                addq.w  #1,D0
                cmp.w   D0,D3                     ;Ende des Suchtexts?
                bhs.s   cmd_find9
                move.l  (SP),D1                   ;Suchadresse liegt auf dem Stack
                subq.l  #1,D1
                moveq   #' ',D0
                tst.w   spalte(A4)
                bne.s   cmd_find11
                moveq   #';',D0                   ;Für den Zeilenanfang
cmd_find11:     jsr     @chrout(A4)
                bsr     hexlout                   ;Adresse ausgeben
                jsr     @space(A4)
cmd_find12:     movea.l (SP)+,A2
                bra.s   cmd_find6
cmd_find13:     move.b  D5,find_cont0(A4)         ;Art der Suche (-1=Hunt,0=Find,1=Ascfind)
                move.l  A2,find_cont1(A4)         ;aktuelle Adresse
                move.l  A3,find_cont2(A4)         ;Endadresse
                move.w  D3,find_cont3(A4)         ;L„nge des Suchstrings
                bra.s   cmd_find7
               ;>ENDPART
********************************************************************************
* 'HUNT' - Bytefolge auf geraden Adressen suchen                               *
********************************************************************************
               ;>PART 'cmd_hunt'
cmd_hunt:       bsr     get
                cmp.b   #',',D0
                beq.s   cmd_hunt2
                subq.l  #1,A0                     ;Pointer zurück
                bsr     get_parameter
                bra.s   cmd_hunt4
cmd_hunt2:      move.l  basep(A4),D1              ;Programm mit LEXEC geladen
                beq.s   cmd_hunt3                 ;Keine Basepage, also nicht
                movea.l D1,A6
                movea.l 8(A6),A2                  ;Adresse des TEXT-Segments => Startadr
                movea.l 24(A6),A3                 ;Adresse des BSS-Segments => Endadr
                bra.s   cmd_hunt4
cmd_hunt3:      move.l  merk_anf(A4),D1           ;Prg mit LOAD geladen?
                beq     illequa                   ;Kein Suchbereich!
                movea.l D1,A2                     ;Anfangsadr
                movea.l merk_end(A4),A3           ;Endadr
cmd_hunt4:      bsr     get_such_para
                move.l  A2,D0
                addq.l  #1,D0                     ;EVEN auf die Anfangsadr
                and.w   #-2,D0
                movea.l D0,A2
cmd_hunt5:      move.b  (A1),D0                   ;1.Zeichen des Suchtextes
                cmp.b   (A2),D0
                beq.s   cmd_hunt8
cmd_hunt6:      addq.l  #2,A2
                cmpa.l  A3,A2
                blo.s   cmd_hunt5
                move.b  #2,find_cont0(A4)
                move.l  A2,default_adr(A4)
                jsr     @crout(A4)
                jmp     (A4)                      ;fertig

cmd_hunt8:      bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_find13                ;Ausstieg
                move.l  A2,-(SP)                  ;1.Zeichen war gleich
                clr.w   D0                        ;Zeiger in den Suchtext
cmd_hunt9:      move.b  0(A1,D0.w),D4
                cmp.b   (A2),D4
                bne.s   cmd_hunt12                ;Notfound
                addq.l  #1,A2
                addq.w  #1,D0
                cmp.w   D0,D3                     ;Ende des Suchtexts?
                bhs.s   cmd_hunt9
                move.l  (SP),D1                   ;Suchadresse liegt auf dem Stack
                moveq   #' ',D0
                tst.w   spalte(A4)
                bne.s   cmd_hunt11
                moveq   #';',D0                   ;Für den Zeilenanfang
cmd_hunt11:     jsr     @chrout(A4)
                bsr     hexlout                   ;Adresse ausgeben
                jsr     @space(A4)
cmd_hunt12:     movea.l (SP)+,A2                  ;Nach genauer Durchsicht doch nix
                bra.s   cmd_hunt6
               ;>ENDPART
********************************************************************************
* ASCFIND - Teil eine Mnemonic suchen (ASCII-Suche !)                          *
********************************************************************************
               ;>PART 'cmd_findasc'
cmd_findasc:    bsr     get
                cmp.b   #',',D0
                beq.s   cmd_findasc1
                subq.l  #1,A0                     ;Pointer zurück
                bsr     get_parameter
                bra.s   cmd_findasc3
cmd_findasc1:   move.l  basep(A4),D1              ;Programm mit LEXEC geladen
                beq.s   cmd_findasc2              ;Keine Basepage, also nicht
                movea.l D1,A6
                movea.l 8(A6),A2                  ;Adresse des TEXT-Segments => Startadr
                movea.l 24(A6),A3                 ;Adresse des BSS-Segments => Endadr
                bra.s   cmd_findasc3
cmd_findasc2:   move.l  merk_anf(A4),D1           ;Prg mit LOAD geladen?
                beq     illequa                   ;Kein Suchbereich!
                movea.l D1,A2                     ;Anfangsadr
                movea.l merk_end(A4),A3           ;Endadr
cmd_findasc3:   cmp.b   #',',D0
                bne     synerr                    ;Da fehlt doch ein Parameter!?!
                lea     data_buff(A4),A1
                movea.l A1,A5                     ;Zeiger auf den Patternstring
cmd_findasc4:   move.b  (A0)+,(A1)+               ;Patternstring retten
                bne.s   cmd_findasc4
cmd_findasc5:   movea.l A3,A1                     ;da A3 von match() benutzt wird
                move.b  exquantor(A4),D6          ;'?'-Joker
                move.b  alquantor(A4),D7          ;'*'-Joker
cmd_findasc6:   movea.l A2,A6
                movem.l D0-A6,-(SP)
                bsr     disass                    ;Zeile ab A6 disassemblieren
                movem.l (SP)+,D0-A6
                lea     spaced(A4),A6             ;hier steht der disassemblierte Code
                bsr.s   match
                tst.w   D0
                beq.s   cmd_findasc7              ;Nicht drin enthalten
                movem.l D0-A6,-(SP)
                movea.l A2,A6
                bsr     do_disass                 ;Zeile listen
                jsr     @crout(A4)
                movem.l (SP)+,D0-A6
cmd_findasc7:   bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_findasc8              ;dann Abbruch
                addq.l  #2,A2                     ;auf zum n„chsten Opcode
                cmpa.l  A1,A2
                blo.s   cmd_findasc6
                move.b  #2,find_cont0(A4)
                move.l  A2,default_adr(A4)
                jmp     (A4)
cmd_findasc8:   moveq   #1,D5                     ;für continue
                movea.l A1,A3
                bra     cmd_find13
               ;>ENDPART
********************************************************************************
* match(what,how,where,all,one) - Universelle Suchfunktion mit Jokern          *
* match(->A6,->A5,<-A3,D7,D6)                                                  *
********************************************************************************
               ;>PART 'match'

match:          movem.l D1-D2/A0/A5-A6,-(SP)
match_loop1:    move.b  (A5)+,D2
                beq.s   match_not                 ;Ende des how-Strings => nix gefunden
                cmp.b   D6,D2
                beq.s   match_loop1               ;Existenzquantoren und
                cmp.b   D7,D2                     ;Allquantoren am Anfang berlesen
                beq.s   match_loop1
                movea.l A6,A3
match_jump2:    movea.l A5,A0                     ;Zeiger auf den Anfang zurück
                movea.l A3,A6
match_loop2:    move.b  (A6)+,D1                  ;Ende des Strings erreicht?
                beq.s   match_not                 ;dann nichts gefunden
                cmp.b   D2,D1                     ;erstes gleiches Zeichen gefunden?
                bne.s   match_loop2               ;sonst weitersuchen ...
                movea.l A6,A3                     ;akt.Position merken
match_loop3:    move.b  (A0)+,D0
                beq.s   match_yeah                ;Ende des how-Strings => gefunden !!
                move.b  (A6)+,D1
                beq.s   match_jump3               ;Ende des Strings
                cmp.b   D6,D0                     ;Existenzquantor ignorieren
                beq.s   match_loop3
                cmp.b   D7,D0
                beq.s   match_jump1               ;Allquantorsuche
                cmp.b   D0,D1                     ;Zeichen gleich?
                bne.s   match_jump2               ;Nochmal suchen, wenn nicht
                bra.s   match_loop3
match_jump3:    cmp.b   D7,D0                     ;Kein Allquantor?
                bne.s   match_not                 ;=> Nix gefunden
                tst.b   (A0)                      ;Folgen noch Suchzeichen?
                bne.s   match_not                 ;dann nicht gefunden
                bra.s   match_yeah                ;sonst doch gefunden
match_jump1:    move.b  (A0)+,D0                  ;Allquantor-Suche
                beq.s   match_yeah                ;how-Stringende = gefunden
                cmp.b   D7,D0                     ;mehrere Allquantoren ignorieren
                beq.s   match_jump1
                tst.b   (A6)                      ;String zuende?
                beq.s   match_jump2               ;Stringende = nicht gefunden
match_loop4:    cmp.b   D0,D1                     ;Zeichen gleich?
                beq.s   match_loop3               ;Ja, weiter suchen
                move.b  (A6)+,D1                  ;n„chstes Zeichen holen
                bne.s   match_loop4               ;String noch nicht zuende => weiter suchen
                bra.s   match_jump2               ;Stringende, weiter geht's

match_yeah:     moveq   #-1,D0                    ;Gefunden!
                subq.l  #1,A3                     ;ab hier wurde der String gefunden
                bra.s   match_end
match_not:      moveq   #0,D0                     ;Nicht gefunden
match_end:      movem.l (SP)+,D1-D2/A0/A5-A6
                rts
               ;>ENDPART
********************************************************************************
* 'PRN' - Druckerausgabe                                                       *
********************************************************************************
               ;>PART 'cmd_prnt'
cmd_prnt:       btst    #0,$FFFFFA01.w            ;Busy-Flag des Druckers
                bne     prn_err                   ;Nichts zu machen
                clr.w   prn_pos(A4)               ;Zeiger zurücksetzen
                st      device(A4)                ;Flag für Drucker an
                bra     inp_loop1                 ;zum n„chsten Zeichen
               ;>ENDPART
********************************************************************************
* 'MOVE' - Speicherblock verschieben                                           *
********************************************************************************
               ;>PART 'cmd_move'
cmd_move:       bsr     get_parameter             ;Anfang und Ende holen
                bcs     synerr
                bvs     synerr                    ;Parameter müssen angegeben werden
                cmpa.l  A3,A2
                bhs     illequa                   ;Anfang>=Ende!
                cmp.b   #',',D0
                bne     synerr
                bsr     get
                bsr     get_term                  ;holt Zieladresse
                cmpa.l  D1,A2                     ;Ziel mit Anfang vergleichen

                beq     ret_jump
                ori     #$0700,SR
                blo.s   cmd_move2                 ;Ziel>Quelle
                movea.l D1,A6
cmd_move1:      move.b  (A2)+,(A6)+
                cmpa.l  A2,A3                     ;Ende erreicht?
                bne.s   cmd_move1
                jmp     (A4)
cmd_move2:      movea.l A3,A6                     ;a3 merken
                suba.l  A2,A3                     ;Wieviel Bytes sollen verschoben werden?
                adda.l  D1,A3                     ;plus Zieladresse (letzte Adr. des Zielbereichs)
cmd_move3:      move.b  -(A6),-(A3)
                cmpa.l  A6,A2                     ;Ende erreicht?
                bne.s   cmd_move3
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* 'FILL' - Speicherbereich mit Bytefolge füllen                                *
********************************************************************************
               ;>PART 'cmd_fill'
cmd_fill:       bsr     get_parameter
                bsr     get_such_para             ;holen, was er einfüllen soll
                ori     #$0700,SR
cmd_fill1:      moveq   #-1,D4
cmd_fill2:      addq.w  #1,D4
                move.b  0(A1,D4.w),(A2)+
                cmpa.l  A2,A3                     ;Ende erreicht?
                beq     ret_jump                  ;ja, fertig
                cmp.w   D3,D4                     ;L„nge erreicht?
                blo.s   cmd_fill2
                bra.s   cmd_fill1
               ;>ENDPART
********************************************************************************
* 'COMPARE' - Speicherbereiche vergleichen                                     *
********************************************************************************
               ;>PART 'cmd_compare'
cmd_compare:    bsr     get_parameter             ;Anfang und Ende holen
                bcs     synerr
                bvs     synerr                    ;Parameter müssen angegeben werden
                cmpa.l  A3,A2
                bhs     illequa                   ;Anfang>=Ende!
                cmp.b   #',',D0
                bne     synerr
                bsr     get
                bsr     get_term                  ;holt Zieladresse
                cmpa.l  D1,A2                     ;Ziel mit Anfang vergleichen
                beq     ret_jump                  ;Abbruch, wenn gleich
                movea.l D1,A1
cmd_compare1:   cmpm.b  (A1)+,(A2)+               ;Speicherstellen vergleichen
                beq.s   cmd_compare3
                move.l  A1,D1
                subq.l  #1,D1
                moveq   #' ',D0
                tst.w   spalte(A4)
                bne.s   cmd_compare2
                moveq   #';',D0                   ;Für den Zeilenanfang
cmd_compare2:   jsr     @chrout(A4)
                bsr     hexlout                   ;ungleiche Adresse ausgeben
                jsr     @space(A4)
cmd_compare3:   bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_compare4              ;dann Abbruch
                cmpa.l  A2,A3                     ;Ende erreicht
                bhs.s   cmd_compare1
cmd_compare4:   move.l  A2,default_adr(A4)
                jsr     @crout(A4)                ;und noch CR ans Ende
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* Disassemble (Hex „ndern)                                                     *
********************************************************************************
               ;>PART 'cmd_dchng'
cmd_dchng:      bclr    #0,default_adr+3(A4)      ;Damit sie sicher gerade ist!
                move.l  default_adr(A4),-(SP)
                ori     #$0700,SR
cmd_dchng1:     bsr     get
                bsr     get_term                  ;Ausdruck nach D1 holen
                move.l  D1,D2
                and.l   #$FFFF0000,D2
                bne     illequa                   ;Das war wohl nichts
                movea.l default_adr(A4),A6
                bsr     check_write
                bne.s   cmd_dchng2
                move.w  D1,(A6)                   ;rein damit
cmd_dchng2:     addq.l  #2,default_adr(A4)        ;Defaultadr neu setzen
                cmp.b   #',',D0                   ;geht es weiter?
                beq.s   cmd_dchng1                ;ja!
                movea.l (SP)+,A6
                subq.w  #1,zeile(A4)              ;Zeile zurück
                sf      list_flg(A4)              ;Ausgabe nicht symbolisch
                bsr     do_disass                 ;Zeile nochmal ausgeben
                jsr     @crout(A4)                ;und wieder CR
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* ']' - Speicher „ndern (Nur ein Parameter!)                                   *
********************************************************************************
               ;>PART 'cmd_schng'
cmd_schng:      bsr     get_such_para3            ;Ausdruck (Fill-Parameter) nach (A1) holen
                lea     default_adr(A4),A2
                movea.l (A2),A6
                ori     #$0700,SR
cmd_schng1:     move.b  (A1)+,D1                  ;alle Daten in den Speicher schreiben
                bsr     check_write
                bne.s   cmd_schng2
                move.b  D1,(A6)                   ;sind „nderbar, sonst nichts tun.
cmd_schng2:     addq.l  #1,A6
                dbra    D3,cmd_schng1
                move.l  A6,(A2)                   ;als neue default_adr aufnehmen
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* ',' - Speicher „ndern (Memory-Dump-Befehl)                                   *
********************************************************************************
               ;>PART 'cmd_mchng'
cmd_mchng:      move.l  default_adr(A4),-(SP)
                ori     #$0700,SR
                bsr     get_such_para3            ;Ausdruck (Fill-Parameter) nach (A1) holen
cmd_mchng1:     move.w  D3,D5                     ;L„nge des Ausdrucks merken
                lea     default_adr(A4),A2
                movea.l (A2),A6
cmd_mchng2:     move.b  (A1)+,D1                  ;alle Daten in den Speicher schreiben
                bsr     check_write
                bne.s   cmd_mchng3
                move.b  D1,(A6)                   ;sind „nderbar, sonst nichts tun.
cmd_mchng3:     addq.l  #1,A6
                dbra    D3,cmd_mchng2
                move.l  A6,(A2)                   ;als neue default_adr aufnehmen
cmd_mchng4:     cmp.b   #$22,D0                   ;Zeilenende erreicht?
                beq.s   cmd_mchng5                ;Ja!
                tst.b   D0
                beq.s   cmd_mchng5
                cmp.b   #',',D0
                bne     synerr
                bsr     get_such_para3            ;n Parameter berlesen
                dbra    D5,cmd_mchng4             ;und weiter testen
                bra.s   cmd_mchng1                ;Der Parameter ist wieder gültig
cmd_mchng5:     movea.l (SP)+,A6
                clr.w   spalte(A4)
                subq.w  #1,zeile(A4)              ;Zeile zurück
                moveq   #0,D3
                bsr     cmd_dump7                 ;Zeile nochmal ausgeben
                addq.w  #1,zeile(A4)
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* '.x' - Speicher „ndern (auch Word/Long-Basis)                                *
********************************************************************************
               ;>PART 'cmd_chng'
cmd_chng:       moveq   #'.',D0
                bsr     get_extension             ;Befehlsextensioncode nach D3
                bmi     synerr
                ori     #$0700,SR
                move.l  default_adr(A4),-(SP)
                move.w  D3,-(SP)                  ;L„nge merken
                bra.s   cmd_chng2
cmd_chng1:      bsr     get
cmd_chng2:      bsr     get_term                  ;Term holen
                move.w  (SP),D3                   ;L„nge holen
                beq     synerr                    ;.B ist verboten
                bclr    #0,default_adr+3(A4)
                movea.l default_adr(A4),A6
                bsr     check_write
                bne.s   cmd_chng4
                cmp.w   #1,D3                     ;L„nge abtesten
                bne.s   cmd_chng3                 ;.L!
                move.w  D1,(A6)
                bra.s   cmd_chng4
cmd_chng3:      move.l  D1,(A6)
cmd_chng4:      cmp.w   #1,D3
                beq.s   cmd_chng5
                addq.l  #2,A6                     ;Long 2+2=4 Byte
cmd_chng5:      addq.l  #2,A6                     ;Word =2 Byte
                move.l  A6,default_adr(A4)
                tst.b   D0
                beq.s   cmd_chng6
                cmp.b   #',',D0                   ;Folgt noch was?
                beq.s   cmd_chng1
cmd_chng6:      move.w  (SP)+,D3                  ;Zahlenbasis
                movea.l (SP)+,A6                  ;Defaultadr
                clr.w   spalte(A4)
                subq.w  #1,zeile(A4)              ;Zeile zurück
                bsr     cmd_dump7                 ;Zeile nochmal ausgeben
                addq.w  #1,zeile(A4)
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* 'RESIDENT' - Programmende (Speicher aber nicht wieder freigeben)             *
********************************************************************************
               ;>PART 'cmd_resident'
cmd_resident:   movea.l save_data+8(A4),A0        ;Busfehler-Vektor holen
                cmpi.w  #'ä-',-(A0)
                bne.s   cmd_resident1             ;Vektor des Debuggers?
                cmpi.l  #'Soft',-(A0)
                beq     cmd_exit                  ;Ende, wenn ja
cmd_resident1:  tst.b   resident(A4)
                bne     ret_jump                  ;Debugger ist bereits resident
                lea     resi_txt(PC),A0
                jsr     ask_user

cmd_resident2:  movea.l save_data(A4),A0          ;Busfehler-Vektor holen
                cmpi.w  #'ä-',-(A0)
                bne.s   cmd_resident3             ;Vektor des Debuggers?
                cmpi.l  #'Soft',-(A0)
                bne.s   cmd_resident3             ;Ende, wenn ja
                move.l  old_trap3(PC),$8C.w       ;alten Trap #3-Vektor zurückschreiben
                bra     cmd_exit1                 ;normaler Exit
cmd_resident3:  move.w  _fhdle2(A4),D0            ;Protokoll-Datei gibt's nicht
                bls.s   cmd_resident4
                move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.l  #4,SP
cmd_resident4:  tst.b   ass_load(A4)              ;Laden durch den Assembler?
                bne.s   cmd_resident5             ;Ja! =>
                bsr     reset_all                 ;alles zurücksetzen
                bra.s   cmd_resident6
cmd_resident5:  bsr     copy_sys_vars             ;Systemvariablen stets zurück kopieren
cmd_resident6:  bsr     set_spez_vek              ;Fehlervektoren wieder rein
                pea     @_trap3(A4)
                move.l  #$050023,-(SP)
                trap    #13                       ;Trap #3 setzen (auf OR.W #$2000,(SP):RTE)
                addq.l  #8,SP
                lea     8.w,A0
                lea     save_data(A4),A1
                movea.l A1,A2
                move.w  #361,D1
cmd_resident7:  move.l  (A0)+,(A1)+               ;$8-$5AF retten (mit eingesetzen Vektoren)
                dbra    D1,cmd_resident7

                move.l  $0502.w,old_alt_help
                tst.b   ass_load(A4)              ;Laden durch den Assembler?
                bne.s   cmd_resident8             ;Ja! =>
                move.l  #alt_help,$0502.w

cmd_resident8:  andi    #$FB00,SR                 ;IRQ wieder freigeben
                clr.l   $0426.w                   ;Reset-Vektor ungültig
;!!!!!!!!!!!!!!!!!!!!!!!!
                lea     f030_save_2588(A4),A0
                bsr     restoref030regs
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                sf      ass_load(A4)              ;Laden durch den Assembler beendet
                st      resident(A4)              ;Flag setzen, daž der Debugger resident
                sf      do_resident(A4)           ;automatisches 'RESIDENT' ausschalten
                move.l  old_stack(A4),-(SP)
                move.w  #$20,-(SP)
                trap    #1                        ;USER-Modus an
                addq.l  #6,SP
                movea.l old_usp(A4),SP

                bsr     cmd_mon1                  ;Maus wieder an

                sf      le_allowed(A4)            ;LE ist nun verboten

                move.w  #1,-(SP)                  ;Debugger ist resident
                move.l  end_adr(A4),D0
                sub.l   #anfang-256,D0            ;Programml„nge + Basepage
                move.l  D0,-(SP)                  ;soviel Speicher beleibt belegt
                move.w  #$31,-(SP)
                trap    #1                        ;Ptermres()

               IFEQ sprache
resi_txt:      DC.B 'Wollen Sie den Debugger resident halten? (j/n) ',0
               ELSE
resi_txt:      DC.B 'Keep the debugger resident? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* 'EXIT' / 'SYSTEM' / 'QUIT' - Programmende                                    *
********************************************************************************
               ;>PART 'cmd_exit'
cmd_exit:       lea     cmd_exit5(PC),A0
                jsr     ask_user

cmd_exit1:      lea     etv_exit.w,A0
                move.l  (A0),D0                   ;Bits 0-31 = 0?
                beq.s   cmd_exit10                ;=> kein Vektor
                btst    #0,D0                     ;Bit 0 = 1?
                bne.s   cmd_exit10                ;=> kein Vektor
                jsr     @org_driver(A4)           ;Original Tastaturtreiber rein
                movea.l $040C.w,A0
                jsr     (A0)                      ;Routine anspringen
                jsr     @my_driver(A4)            ;eigener Treiber
cmd_exit10:     clr.l   etv_exit.w                ;etv_exit()-Vektor l”schen
                sf      do_resident(A4)
                moveq   #6,D3                     ;alle noch offenen Dateien schliežen
cmd_exit2:      move.w  D3,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.l  #4,SP
                addq.w  #1,D3
                cmp.w   #80,D3
                bne.s   cmd_exit2

                bsr     reset_all

                clr.l   etv_exit.w                ;etv_exit()-Vektor l”schen
                moveq   #14,D0
                bsr     disable_irq               ;Ring-Indicator aus

                move.l  old_trap3(PC),$8C.w
                tst.b   resident(A4)
                beq.s   cmd_exit3
                lea     @_trap3(A4),A0            ;Trap #3 neu setzen
                move.l  A0,$8C.w

cmd_exit3:      movea.l kbshift_adr(A4),A0
                clr.b   (A0)                      ;Kbshift-Status l”schen
;!!!!!!!!!!!!!!!!!!!!!!!!!
                lea     f030_save_2588(A4),A0
                bsr     restoref030regs
;!!!!!!!!!!!!!!!!!!!!!!!!!
                sf      le_allowed(A4)            ;LE ist nun verboten

                bsr     cmd_mon1                  ;Maus wieder an

                move.l  quit_stk(A4),D1           ;Rücksprungadr?
                beq.s   cmd_exit4
                clr.l   quit_stk(A4)              ;Rücksprungadresse l”schen
                lea     spaced2(A4),A0
                move.l  line_back(A4),D0          ;PC-Offset
                move.l  D1,-(SP)
                rts                               ;und Quit
cmd_exit4:      andi    #$FBFF,SR

                move.l  old_stack(A4),-(SP)
                move.w  #$20,-(SP)
                trap    #1                        ;USER-Modus an
                addq.l  #6,SP
                movea.l old_usp(A4),SP

                clr.w   -(SP)                     ;Exit to GEMDOS
                trap    #1

               IFEQ sprache
cmd_exit5:     DC.B 'W„re es ihnen genehm, den Debugger zu verlassen? (j/n) ',0
               ELSE
cmd_exit5:     DC.B 'Wanna quit this adventure? (y/n) ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* 'SET' - Register „ndern                                                      *
********************************************************************************
               ;>PART 'cmd_set'
cmd_set:        bsr     get
                move.w  D0,D2                     ;aktuelles 1.Zeichen merken
                lea     varstab(PC),A1
                lea     w_legalc(PC),A3
                movea.l A0,A2                     ;Zeiger auf evtl.Variable oder Zahl merken
cmd_se0:        moveq   #-1,D1
                move.w  D2,D0                     ;1.Zeichen zurückholen
                tst.b   (A1)                      ;Ende der Tabelle erreicht?
                bmi     synerr                    ;nicht gefunden
cmd_se1:        addq.w  #1,D1
                cmpi.b  #' ',0(A1,D1.w)           ;Eintrag gefunden?
                beq.s   cmd_se5                   ;Ja!
                tst.b   0(A1,D1.w)
                beq.s   cmd_se5                   ;Eintrag ebenfalls gefunden
                tst.w   D1                        ;1.Zeichen des Labels
                beq.s   cmd_se2                   ;da ist noch alles erlaubt
                ext.w   D0
                bmi.s   cmd_se3                   ;Zeichen >127 sind nicht erlaubt!
                tst.b   0(A3,D0.w)                ;Zeichen noch erlaubt?
                bne.s   cmd_se3                   ;Nein! => Abbruch, da ungleich
cmd_se2:        cmp.b   0(A1,D1.w),D0             ;Immer noch gleich?
cmd_se3:        move    SR,D3
                bsr     get                       ;schon mal das n„chste Zeichen holen
                move.w  D0,D4                     ;Retten, falls es das letzte Zeichen war
                move    D3,CCR
                beq.s   cmd_se1                   ;wenn gleich, n„chstes Zeichen testen
                lea     16(A1),A1                 ;Zeiger auf die n„chste Variable
                movea.l A2,A0                     ;Zeiger zurück
                bra.s   cmd_se0                   ;Weiter suchen
cmd_se5:        move.w  D4,D0
                lea     12(A1),A2
                moveq   #0,D2
                move.w  8(A1),D4                  ;Art der Variable
                move.w  10(A1),D2                 ;šbergabeparameter
                movea.l (A2),A1                   ;Pointer
                cmp.w   #3,D4
                beq.s   cmd_se7                   ;A1 zeigt auf Subroutine
                cmp.b   #'=',D0                   ;Es muž einfach kommen
                bne     synerr
                bsr     get
                bsr     get_term                  ;Term nach D1 auswerten
                tst.w   D4                        ;Direkter Wert?
                beq.s   cmd_se8
                adda.l  A4,A1
                cmp.w   #4,D4
                beq.s   cmd_se6                   ;A1 zeigt auf Speicherzelle (Word)
;A1 zeigt auf Speicherzelle (Long)
                move.l  D1,(A1)
                bra.s   cmd_se9
cmd_se6:        cmp.l   D2,D1
                bhi     illequa                   ;Wert zu grož!
                move.w  D1,(A1)
                bra.s   cmd_se9
cmd_se8:        move.l  D1,(A2)                   ;Direkten Wert eintragen
                bra.s   cmd_se9
cmd_se7:        jsr     (A1)                      ;Subroutine aufrufen
cmd_se9:        jmp     (A4)
cmd_sec1:
                move.w  #col1,D7
                bra.s   cmd_secb
cmd_sec0:       move.w  #col0,D7
cmd_secb:       bsr     tstglzahl
                move.l  D1,D2
                and.l   #$FFFFF000,D2
                bne     illequa
                move.w  D1,0(A4,D7.w)
                lea     $FFFF8240.w,A1
                move.w  col0(A4),(A1)+
                moveq   #14,D1
cmd_secc:       move.w  col1(A4),(A1)+            ;Die Farben setzen
                dbra    D1,cmd_secc
                rts
cmd_sec:        bsr     tstglzahl                 ;SR setzen
                andi.w  #$7FFF,D1
                move.w  D1,_sr(A4)
                rts
cmd_sed:        bsr     tstglzahl                 ;CCR setzen
                andi.w  #$FF,D1
                move.b  D1,_sr+1(A4)
                rts
cmd_sebk:       bsr     get_term
                tst.l   D1
                bmi     illbkpt
                cmp.l   #15,D1
                bhi     illbkpt
                mulu    #12,D1
                lea     breakpnt(A4),A1
                adda.w  D1,A1
                bsr     tstglzahl                 ;Adresse der Breakpoints holen
                bclr    #0,D1
                tst.l   D1
                beq.s   cmd_sbk                   ;null als Argument erlaubt
                movea.l D1,A6
                bsr     check_write
                bne     illequa
cmd_sbk:        move.l  D1,(A1)+                  ;Adresse des Breakpoints holen
                move.w  #-1,(A1)+                 ;Stop-Breakpoint
                move.l  #1,(A1)                   ;nur einmal ausführen
                rts

w_zahlscache:   tst.b   prozessor(A4)             ;68000 oder 68010?
                ble.s   w_zahlscachee             ;dann raus hier
                bsr     tstglzahl                 ;CCR setzen
               DC.W $4E7B,$1002                   ;CACR setzen
w_zahlscachee:  rts

cmd_seme:       moveq   #10,D2                    ;max.10 Anwendervariablen
                bsr     chkval
                bcc     synerr
                subq.w  #1,D0
                bpl.s   cmd_semx
                moveq   #9,D0
cmd_semx:       move.l  merk_svar(A4),D1
                beq.s   cmd_semxy                 ;Keine šbergabe durch den Assembler
                movea.l D1,A1
                move.w  D0,D1
                mulu    #6,D1
                move.w  #-1,0(A1,D1.w)
cmd_semxy:      lea     simple_vars(A4),A1
                lsl.w   #2,D0
                adda.w  D0,A1
                bsr     get
                bsr.s   tstglzahl
                move.l  D1,(A1)
                rts

cmd_sef:        lea     regs(A4),A1               ;Dn setzen
                bra.s   cmd_seh
cmd_seg:        lea     regs+32(A4),A1            ;An setzen
cmd_seh:        moveq   #8,D2
                bsr     chkval                    ;max.7 ist erlaubt
                bcc     synerr
                lsl.w   #2,D0                     ;mal 4 (Long)
                adda.w  D0,A1
                bsr     get                       ;"=" holen (hoffendlich)
                lea     rega7(A4),A6
                cmpa.l  A6,A1                     ;A7 ge„ndert?
                beq.s   cmd_sea                   ;Ja! => SP „ndern
                bsr.s   tstglzahl
                move.l  D1,(A1)                   ;Register setzen
                rts
cmd_sea:        lea     _usp(A4),A1               ;SP setzen
                btst    #5,_sr(A4)                ;Supervisor-Mode?
                beq.s   cmd_seb
                lea     _ssp(A4),A1
cmd_seb:        bsr.s   tstglzahl
                move.l  D1,(A1)
                rts
cmd_sei:        bsr.s   tstglzahl                 ;DISBASE/DB „ndern
                cmp.w   #10,D1
                beq.s   cmd_sej
                cmp.w   #$10,D1
                bne     illequa                   ;nur Dezimal & Hexadezimal sind erlaubt
cmd_sej:        move.w  D1,disbase(A4)            ;DISBASE setzen
                rts
cmd_sek:        bsr.s   tstglzahl                 ;ALL setzen
                lea     regs(A4),A0
                moveq   #14,D0
cmd_sel:        move.l  D1,(A0)+
                dbra    D0,cmd_sel
                rts

tstglzahl:      cmp.b   #'=',D0                   ;Es muž einfach kommen
                bne     synerr
                bsr     get
                bra     get_term                  ;Term nach D1 auswerten

;>               DXSET 8,' '
varstab:       DC.B 'SYMFLAG '
               DC.W 4,-1
               DC.L bugaboo_sym
               DC.B 'RING    '
               DC.W 4,1
               DC.L ring_flag
               DC.B 'TRACE   '
               DC.W 4,2
               DC.L trace_flag
               DC.B 'TDELAY  '
               DC.W 4,-1
               DC.L trace_delay
               DC.B 'MIDI    '
               DC.W 4,1
               DC.L midi_flag
               DC.B 'OVERSCAN'
               DC.W 4,1
               DC.L overscan
               DC.B 'SWITCH  '
               DC.W 4,1
               DC.L smart_switch
               DC.B 'CACHE   '
               DC.W 3,1
               DC.L w_zahlscache
               DC.B 'MEMCHECK'
               DC.W 4,1
               DC.L all_memory
               DC.B 'SHIFT   '
               DC.W 4,1
               DC.L shift_flag
               DC.B 'CLICK   '
               DC.W 4,1
               DC.L format_flag
               DC.B 'KLICK   '
               DC.W 4,1
               DC.L format_flag
               DC.B 'AESFLAG '
               DC.W 4,1
               DC.L no_aes_check
               DC.B 'PC      '
               DC.W 1,0
               DC.L _pc
               DC.B 'SCROLLD '
               DC.W 4,-1
               DC.L scroll_d
               DC.B 'CONTERM '
               DC.W 4,1
               DC.L conterm
               DC.B 'COL0    '
               DC.W 3,0
               DC.L cmd_sec0
               DC.B 'COL1    '
               DC.W 3,0
               DC.L cmd_sec1
               DC.B 'SMALL   '
               DC.W 4,1
               DC.L small
               DC.B 'SIZE    '
               DC.W 4,16
               DC.L def_size
               DC.B 'LINES   '
               DC.W 4,255
               DC.L def_lines
               DC.B 'ALL     '
               DC.W 3,0
               DC.L cmd_sek
               DC.B 'USP     '
               DC.W 1,0
               DC.L _usp
               DC.B 'SP      '
               DC.W 3,0
               DC.L cmd_sea
               DC.B 'SSP     '
               DC.W 1,0
               DC.L _ssp
               DC.B 'SR      '
               DC.W 3,0
               DC.L cmd_sec
               DC.B 'CCR     '
               DC.W 3,0
               DC.L cmd_sed
               DC.B '*       '
               DC.W 1,0
               DC.L default_adr
               DC.B 'DISBASE '
               DC.W 3,0
               DC.L cmd_sei
               DC.B 'BUFFER  '
               DC.W 1,0
               DC.L dsk_adr
               DC.B 'TRACK   '
               DC.W 4,85
               DC.L dsk_track
               DC.B 'SEKTOR  '
               DC.W 4,255
               DC.L dsk_sektor
               DC.B 'SECTOR  '
               DC.W 4,255
               DC.L dsk_sektor
               DC.B 'SIDE    '
               DC.W 4,1
               DC.L dsk_side
               DC.B 'DRIVE   '
               DC.W 4,1
               DC.L dsk_drive
               DC.B 'D       '
               DC.W 3,0
               DC.L cmd_sef
               DC.B 'A       '
               DC.W 3,0
               DC.L cmd_seg
               DC.B 'B       '
               DC.W 3,0
               DC.L cmd_sebk
               DC.B 'M       '
               DC.W 3,0
               DC.L cmd_seme
               DC.B -1
               EVEN
               ;>ENDPART
********************************************************************************
* Register und Men ausgeben (bei Bedarf)                                      *
********************************************************************************
               ;>PART 'rgout'
rgout:          move.l  zeile(A4),-(SP)           ;Zeile und(!) Spalte retten
                move.w  entry_old(A4),D0
                cmp.w   entry(A4),D0
                beq.s   rgout1
                jsr     draw_menue
                moveq   #0,D7                     ;select
                move.w  entry(A4),D0
                jsr     sel_menue
rgout1:         jsr     hunt_pc                   ;evtl.Markierung am Zeilenanfang setzen
                move.w  upper_line(A4),D0
                neg.w   D0
                addq.w  #2,D0
                move.w  D0,zeile(A4)              ;-3 in Normalfall
                clr.w   spalte(A4)
                moveq   #'',D0                   ;Closer
                movea.l reg_pos(A4),A5
                movea.l trace_pos(A4),A1
                cmpa.l  A1,A5                     ;akt.Registersatz?
                bne.s   rgout11                   ;Nein!
                moveq   #' ',D0
rgout11:        jsr     @charout(A4)
                lea     _regtxt(PC),A1
                bsr     txtout2                   ;PC ausgeben
                andi.b  #$FE,_pc+3(A4)
                andi.b  #$FE,64+3(A5)
                move.l  64(A5),D1
                bsr     hexlout
                bsr     txtout2                   ;USP ausgeben
                andi.b  #$FE,68+3(A5)
                move.l  68(A5),D1
                bsr     hexlout
                bsr     txtout2                   ;SSP ausgeben
                andi.b  #$FE,72+3(A5)
                move.l  72(A5),D1
                bsr     hexlout
                bsr     txtout2                   ;SR ausgeben
                bsr     sr_out
                jsr     @space(A4)
                movea.l 64(A5),A6
                lea     spaced(A4),A0
                moveq   #19,D0
rgoutn0:        clr.l   (A0)+                     ;Buffer l”schen
                dbra    D0,rgoutn0
                bsr     disass
                clr.b   testwrd(A4)               ;Ausgabe nicht mehr in den Buffer
                lea     spaced(A4),A0
                move.l  A0,-(SP)
                lea     31(A0),A0
                moveq   #0,D1
                tst.b   (A0)
                beq.s   rgoutnn
                move.b  #'*',(A0)+
                clr.b   (A0)
                moveq   #-1,D1
rgoutnn:        jsr     @print_line(A4)           ;Ergebnis des Disassemblers ausgeben
                tst.w   D1                        ;Zeilenrest vorhanden?
                bne.s   rgoutnm                   ;Nein! =>
rgoutnm1:       moveq   #' ',D0
                jsr     @charout(A4)              ;Spaces bis zum Zeilenende ausgeben
                tst.w   spalte(A4)                ;n„chste Zeile erreicht?
                bne.s   rgoutnm1                  ;Nein! => weiter
rgoutnm:        move.w  upper_line(A4),D0
                neg.w   D0
                addq.w  #3,D0
                move.w  D0,zeile(A4)              ;-2 in Normalfall
                clr.w   spalte(A4)
                moveq   #'',D0                   ;Pfeil nach links
                jsr     @charout(A4)
                lea     _regtxt2(PC),A1
                bsr     txtout2                   ;D0-D7 ausgeben
                movea.l reg_pos(A4),A2
                moveq   #7,D6                     ;8 Register
rgoutn1:        move.l  (A2)+,D1                  ;Registerinhalt holen
                bsr     hexlout                   ;und ausgeben
                jsr     @space(A4)
                dbra    D6,rgoutn1
                moveq   #'',D0                   ;Pfeil nach rechts
                jsr     @charout(A4)
                bsr     txtout2                   ;A0-A7 ausgeben
                moveq   #6,D6                     ;7 Register
rgoutn5:        move.l  (A2)+,D1                  ;Registerinhalt holen
                bsr     hexlout                   ;und ausgeben
                jsr     @space(A4)
                dbra    D6,rgoutn5
                movea.l reg_pos(A4),A5
                move.l  68(A5),D1                 ;auf Verdacht Usermodus annehmen
                btst    #5,76(A5)                 ;Supervisor-Bit berprüfen
                beq.s   rgoutn4                   ;Usermode!
                move.l  72(A5),D1

rgoutn4:        move.l  D1,rega7(A4)              ;A7 setzen
                bsr     hexlout                   ;Stackpnt ausgeben
                moveq   #' ',D0
                jsr     @charout(A4)                   ;Spaces bis zum Zeilenende ausgeben
                moveq   #79,D0
                jsr     draw_line                 ;Horizontale Linie von Zeile 5 zeichnen
                move.w  upper_line(A4),D6
                neg.w   D6
                addq.w  #5,D6
                beq     rgoute5                   ;Keine Kopfzeilen vorhanden! =>
                move.w  def_size(A4),D7
                move.w  #16,def_size(A4)
                neg.w   D6
                subq.w  #1,D6
                movea.l #spez_buff,A0
                adda.l  A4,A0
                lea     regs(A4),A1               ;šbergabeparameter an User-Trace
rgoute6:        movem.l D1-A6,-(SP)
                jsr     (A0)                      ;Adresse ermitteln
                movem.l (SP)+,D1-A6
                movea.l D0,A6
                movem.l D0-A6,-(SP)
                move.l  zeile(A4),-(SP)
                move.w  upper_line(A4),D0
                subq.w  #5,D0
                sub.w   D0,D6
                move.w  D6,zeile(A4)
                lea     spaced2(A4),A0
                neg.w   D6
                movea.l #spez_format,A1
                adda.l  A4,A1
                adda.w  D6,A1
                moveq   #0,D3
                moveq   #3,D3
                and.b   -(A1),D3                  ;Ausgabebreite holen
                moveq   #0,D2
                move.b  (A1),D2
                lsr.b   #4,D2
                addq.b  #1,D2
                move.w  D2,def_size(A4)           ;Size setzen

                addi.b  #'0'-1,D6
                move.b  D6,(A0)+
                move.b  #':',(A0)+
                bsr     cmd_dump8                 ;Dump ausgeben
                move.l  (SP)+,zeile(A4)
                movem.l (SP)+,D0-A6
                lea     256(A0),A0
                dbra    D6,rgoute6
                move.w  D7,def_size(A4)

                move.w  upper_line(A4),D0
                lsl.w   #4,D0
                subq.w  #1,D0
                jsr     draw_line                 ;Anfang des freien Bildschirms
rgoute5:        move.l  (SP)+,zeile(A4)           ;Zeile und(!) Spalte zurück
                rts

_regtxt:       DC.B ' PC=',0,' USP=',0,' SSP=',0,' SR=',0
_regtxt2:      DC.B ' D0-D7 ',0
               DC.B ' A0-A7 ',0

txtout2:        move.l  A1,-(SP)
                jsr     @print_line(A4)
txtout2a:       tst.b   (A1)+
                bne.s   txtout2a
                rts

sr_out:         movem.l D0-D7,-(SP)
                move.w  zeile(A4),-(SP)
                move.w  #2,zeile(A4)
                move.w  #40,spalte(A4)
                bsr     clr_maus
                movea.l reg_pos(A4),A5
                move.w  76(A5),D5                 ;SR-Register holen
                moveq   #15,D4
sr_out0:        moveq   #-1,D1                    ;Nicht light
                moveq   #0,D2                     ;Nicht invers
                moveq   #0,D3                     ;Nicht unterstrichen
                btst    D4,D5
                bne.s   sr_out2
                moveq   #$55,D1                   ;Light an
sr_out2:        moveq   #0,D0
                move.b  sr_txt(PC,D4.w),D0
                beq.s   sr_out3
                jsr     light_char
                addq.w  #1,spalte(A4)
sr_out3:        dbra    D4,sr_out0
                bsr     set_maus
                move.w  (SP)+,zeile(A4)
                movem.l (SP)+,D0-D7
                rts

sr_txt:        DC.B 'CVZNX',0,0,0,'012',0,0,'S',0,'T'
               ;>ENDPART
********************************************************************************
* 'INFO' - Informationen ber die Speicherbelegung                             *
********************************************************************************
               ;>PART 'cmd_sysinfo'
cmd_sysinfo:    movea.l $04F2.w,A6                ;_sysbase
                pea     cmd_sysinfotxt1(PC)
                jsr     @print_line(A4)           ;"TOS-Version"
                movea.l 8(A6),A0                  ;Zeiger ins ROM
                move.w  $1C(A0),D1                ;os_conf holen
                lea     cmd_sysinfotab1(PC),A0
                btst    #0,D1
                beq.s   cmd_sysinfo1
                addq.l  #5,A0
cmd_sysinfo1:   move.l  A0,-(SP)                  ;NTSC/PAL
                jsr     @print_line(A4)
                moveq   #'-',D0
                jsr     @chrout(A4)
                lsr.w   #1,D1                     ;durch 2
                cmp.w   #15,D1
                blo.s   cmd_sysinfo2
                moveq   #15,D1                    ;'???' für unbekanntes Land
cmd_sysinfo2:   lsl.w   #2,D1                     ;mal 4
                lea     cmd_sysinfotab2(PC),A0
                adda.w  D1,A0
                move.l  A0,-(SP)                  ;das Land ausgeben
                jsr     @print_line(A4)
                jsr     @space(A4)
                moveq   #'0',D0
                add.b   2(A6),D0
                jsr     @chrout(A4)               ;TOS-Version ausgeben
                bsr     cmd_sysinfo_sub
                move.b  3(A6),D1
                bsr     hexbout
                pea     cmd_sysinfotxt2(PC)
                jsr     @print_line(A4)           ;" vom "
                move.b  $19(A6),D1
                bsr     hexbout
                bsr     cmd_sysinfo_sub
                move.b  $18(A6),D1
                bsr     hexbout
                bsr     cmd_sysinfo_sub
                move.w  $1A(A6),D1
                bsr     hexwout
                pea     cmd_sysinfotxt12(PC)      ;ROM-Base
                jsr     @print_line(A4)
                move.l  8(A6),D1                  ;Basisadresse des ROMs
                bsr     hexout                    ;ausgeben
                pea     cmd_sysinfotxt3(PC)       ;GEMDOS-Version
                jsr     @print_line(A4)
                move.w  #$30,-(SP)
                bsr     do_trap_1                 ;Sversion()
                addq.l  #2,SP
                move.w  D0,D3
                moveq   #10,D2                    ;Zahlenbasis
                moveq   #0,D1
                move.b  D3,D1
                bsr     numoutx
                jsr     @chrout(A4)               ;1.Ziffer
                bsr     cmd_sysinfo_sub
                lsr.w   #8,D3
                move.w  D3,D1
                bsr     numoutx                   ;2.Ziffer

                pea     cmd_sysinfotxt4(PC)       ;AES-Version
                jsr     @print_line(A4)
                move.l  #$0A000100,D0             ;appl_init()
                bsr     aes
                move.l  #$13000100,D0             ;appl_exit()
                bsr     aes
                moveq   #'0',D0
                add.b   spaced2+32(A4),D0         ;AES-Versionsnummer holen
                jsr     @chrout(A4)               ;1.Ziffer
                bsr     cmd_sysinfo_sub
                move.b  spaced2+33(A4),D0
                lsr.b   #4,D0
                add.b   #'0',D0
                jsr     @chrout(A4)               ;2.Ziffer
                pea     cmd_sysinfotxt5(PC)
                jsr     @print_line(A4)           ;"VDI-Version : GDOS ist "
                moveq   #-2,D0
                trap    #2                        ;vq_gdos() : GDOS da?
                addq.w  #2,D0
                bne.s   cmd_sysinfo3              ;GDOS ist da! =>
                pea     cmd_sysinfotxt8(PC)
                jsr     @print_line(A4)           ;"nicht "
cmd_sysinfo3:   pea     cmd_sysinfotxt6(PC)       ;"vorhanden"
                jsr     @print_line(A4)           ;"Taktfrequenz :"
                move.l  $04BA.w,D2
                move.w  #32767,D0
cmd_sysinfo4:   moveq   #$AA,D1
                divu    #$1111,D1
                dbra    D0,cmd_sysinfo4
                sub.l   $04BA.w,D2
                move.l  #-192,D1
                divs    D2,D1                     ;MHz
                and.w   #-2,D1
                ext.l   D1
                tst.b   tt_flag(A4)
                beq.s   cmd_sysinfo5
;!!!!!!!!!!!!!!!!!!!!!!
                tst.b   f030_flag(A4)
                beq.s   cmdsi5
                cmp.w   #$1E,D1
                bhi.s   cmd_sysinfo6
                moveq   #$10,D1
                btst    #$00,$FFFF8007.w          ;8 or 16 Mhz F030?
                bne.s   cmd_sysinfo6
                moveq   #$08,D1
                bra.s   cmd_sysinfo6
;!!!!!!!!!!!!!!!!!!!!!!
                moveq   #32,D1
cmdsi5:
cmd_sysinfo5:   cmp.w   #16,D1                    ;mehr als 16MHz?
                bhi.s   cmd_sysinfo6              ;Ja! =>
                cmp.w   #8,D1
                shs     D7                        ;D7=$FF, wenn Hypercache vorhanden, aber aus
                bhs.s   cmd_sysinfo6
                moveq   #8,D1                     ;min.8 MHz
cmd_sysinfo6:   moveq   #10,D2
                bsr     numoutx
                pea     cmd_sysinfotxt7(PC)
                jsr     @print_line(A4)           ;" MHz"

;tst.b   tt_flag(A4)     ;ein TT?
;!!!!!!!!!!!!!!!!!
                move.b  tt_flag(A4),D0            ;ein TT?
                or.b    f030_flag(A4),D0          ;ein F030?
;!!!!!!!!!!!!!!!!!
                bne.s   cmd_sysinfo7              ;Ja! => kein Speeder
                tst.b   D7                        ;16MHz-Speeder vorhanden?
                beq.s   cmd_sysinfo7              ;Nein! =>
                pea     cmd_sysinfotxt13(PC)
                jsr     @print_line(A4)           ;16MHz-Speeder vorhanden!
cmd_sysinfo7:

                lea     $08.w,A3
                move    SR,D1
                moveq   #-1,D0
                movea.l SP,A2
                ori     #$0700,SR
                movea.l (A3),A1
                lea     cmd_sysinfo8(PC),A0
                move.l  A0,(A3)
                move.b  $FFFFFC7F.w,D0            ;PC-Speed vorhanden?
cmd_sysinfo8:   move.l  A1,(A3)
                move    D1,SR
                movea.l A2,SP
                addq.b  #1,D0
                beq.s   cmd_sysinfo9              ;Nein! =>
                pea     cmd_sysinfotxt14(PC)
                jsr     @print_line(A4)           ;vorhanden!
cmd_sysinfo9:
                lea     cmd_sysinfo10(PC),A0
                move.l  A0,(A3)
                moveq   #0,D0
                move.b  $FFFF8E21.w,D0            ;Mega STE vorhanden?
                moveq   #-1,D0
cmd_sysinfo10:  move.l  A1,(A3)
                move    D1,SR
                movea.l A2,SP
                tst.b   D0
                beq.s   cmd_sysinfo11
                pea     cmd_sysinfotxt11(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo11:  move    SR,D1
                moveq   #0,D0
                movea.l SP,A2
                ori     #$0700,SR
                movea.l (A3),A1
                lea     cmd_sysinfo12(PC),A0
                move.l  A0,(A3)
                tst.w   $FFFF8A00.w               ;Blitter da?
                moveq   #-1,D0
cmd_sysinfo12:  move.l  A1,(A3)
                move    D1,SR
                movea.l A2,SP
                tst.w   D0
                beq.s   cmd_sysinfo13
                pea     cmd_sysinfotxt15(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo13:
;tst.b   ste_flag(A4)    ;STE-Hardware?
                move.b  ste_flag(A4),D0           ;STE-Hardware?
                or.b    f030_flag(A4),D0          ;F030-Hardware?
                bne.s   cmd_sysinfo15             ;Ja! => keine IMP-MMU
                move    SR,D1
                moveq   #0,D0
                movea.l SP,A2
                ori     #$0700,SR
                movea.l (A3),A1
                lea     cmd_sysinfo14(PC),A0
                move.l  A0,(A3)
                move.b  $FFFF820F.w,D0            ;STE-Register auslesen (IMP-MMU => Busfehler)
                moveq   #-1,D0
cmd_sysinfo14:  move.l  A1,(A3)
                move    D1,SR
                movea.l A2,SP
                tst.w   D0
                bne.s   cmd_sysinfo15
                pea     cmd_sysinfotxt16(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo15:  btst    #0,fpu_flag(A4)
                beq.s   cmd_sysinfo16
                pea     cmd_sysinfotxt17(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo16:  move.b  fpu_flag(A4),D0
                lsr.b   #1,D0
                beq.s   cmd_sysinfo17             ;keine FPU =>
                cmp.b   #3,D0
                beq.s   cmd_sysinfo17             ;68040-FPU =>
                add.b   #'0',D0
                move.b  D0,-(SP)
                pea     cmd_sysinfotxt21(PC)
                jsr     @print_line(A4)           ;6888x vorhanden!
                move.b  (SP)+,D0
                jsr     @chrout(A4)
                jsr     @space(A4)
cmd_sysinfo17:
                lea     $FB0000,A0
                move.l  (A0),D0
                moveq   #99,D1
cmd_sysinfo18:  tst.l   (A0)
                dbra    D1,cmd_sysinfo18
                cmp.l   (A0),D0                   ;der TT hat keine stabilen Bytes ohne Modul
                bne.s   cmd_sysinfo19             ;ja! =>
                tst.w   $FA0000
                move.l  (A0),D0                   ;Spectre GCR-Test
                tst.w   $FA001C
                cmp.l   (A0),D0
                beq.s   cmd_sysinfo19
                pea     cmd_sysinfotxt18(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo19:  lea     stacy_tab(PC),A0
                move.w  $FFFF827E.w,D3            ;Register retten
                moveq   #0,D2
                moveq   #5,D0                     ;6 Werte ausprobieren
cmd_sysinfo20:  move.b  (A0)+,D2                  ;Testwert holen
                move.w  D2,$FFFF827E.w            ;Wert ins Register schreiben
                moveq   #$0F,D1
                and.w   $FFFF827E.w,D1            ;Register wieder auslesen
                cmp.b   D2,D1                     ;stimmt der Wert?
                dbne    D0,cmd_sysinfo20          ;Abbruch, wenn nicht; sonst =>
                bne.s   cmd_sysinfo21             ;Fehler, keine Stacy =>
                move.w  D3,$FFFF827E.w            ;Register wieder zurück
                pea     cmd_sysinfotxt20(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo21:  tst.w   overscan(A4)              ;OverScan vorhanden?
                beq.s   cmd_sysinfo22
                pea     cmd_sysinfotxt19(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo22:
;!!!!!!!!!!!!!!!!!!!!!
                tst.b   f030_flag(A4)             ;TT-Hardware?
                beq.s   cmd_sysinfo22a            ;Nein! =>
                pea     cmd_sysinfotxt10a(PC)
                jsr     @print_line(A4)           ;vorhanden!
                bra.s   cmd_sysinfo24
cmd_sysinfo22a:
;!!!!!!!!!!!!!!!!!!!!!
                tst.b   tt_flag(A4)               ;TT-Hardware?
                beq.s   cmd_sysinfo23             ;Nein! =>
                pea     cmd_sysinfotxt10(PC)
                jsr     @print_line(A4)           ;vorhanden!
                bra.s   cmd_sysinfo24

cmd_sysinfo23:  tst.b   ste_flag(A4)              ;STE-Hardware?
                beq.s   cmd_sysinfo24             ;Nein! =>
                pea     cmd_sysinfotxt9(PC)
                jsr     @print_line(A4)           ;vorhanden!

cmd_sysinfo24:
;tst.b   tt_flag(A4)
;!!!!!!!!!!!!!!!!!!!!!
                move.b  tt_flag(A4),D0
                or.b    f030_flag(A4),D0
;!!!!!!!!!!!!!!!!!!!!!
                bne.s   cmd_sysinfo25
                pea     cmd_sysinfotxt(PC)
                jsr     @print_line(A4)           ;"Banks"
                moveq   #$03,D0
                and.b   $FFFF8001.w,D0
                bsr.s   bank_out
                moveq   #$0C,D0
                and.b   $FFFF8001.w,D0
                lsr.w   #2,D0
                bsr.s   bank_out
cmd_sysinfo25:  jsr     @c_eol(A4)
                jsr     @crout(A4)
                jmp     (A4)

bank_out:       cmp.b   #3,D0                     ;unbekannte Konfiguration?
                beq.s   bank_out1                 ;Ja! =>
                add.b   D0,D0
                addq.b  #7,D0
                moveq   #1,D1
                lsl.w   D0,D1                     ;Gr”áe der Bank
                moveq   #10,D2
                bsr     numoutx                   ;ausgeben
                moveq   #'k',D0
                bsr.s   cmd_syscout
                bra.s   bank_out2
bank_out1:      moveq   #'-',D0
                bsr.s   cmd_syscout               ;unbekannter Wert
bank_out2:      moveq   #' ',D0
                bra.s   cmd_syscout

cmd_sysinfo_sub:moveq   #'.',D0                   ;"." ausgeben
cmd_syscout:    jmp     @chrout(A4)

stacy_tab:     DC.B 1,2,4,8,5,10
               IFEQ sprache
cmd_sysinfotxt1:DC.B 'TOS-Version    : ',0
cmd_sysinfotxt2:DC.B ' vom ',0
cmd_sysinfotxt3:DC.B 13,'GEMDOS-Version : ',0
cmd_sysinfotxt4:DC.B 13,'AES-Version    : ',0
cmd_sysinfotxt5:DC.B 13,'VDI-Version    : GDOS ist ',0
cmd_sysinfotxt6:DC.B 'vorhanden',13
               DC.B 'Taktfrequenz   : ',0
cmd_sysinfotxt7:DC.B ' MHz',13
               DC.B 'zus. Hardware  : ',0
cmd_sysinfotxt8:DC.B 'nicht ',0
cmd_sysinfotxt:DC.B 13,'Banks          : ',0
cmd_sysinfotxt9:DC.B 'STE-Hardware ',0
cmd_sysinfotxt10:DC.B 'TT-Hardware ',0
cmd_sysinfotxt10a:DC.B 'F030-Hardware ',0
cmd_sysinfotxt11:DC.B 'Mega STE-hardware ',0
cmd_sysinfotxt12:DC.B 13,'OS-Basisadresse: ',0
               ELSE
cmd_sysinfotxt1:DC.B 'TOS-version    : ',0
cmd_sysinfotxt2:DC.B ' date ',0
cmd_sysinfotxt3:DC.B 13,'GEMDOS-version : ',0
cmd_sysinfotxt4:DC.B 13,'AES-version    : ',0
cmd_sysinfotxt5:DC.B 13,'VDI-version    : GDOS ',0
cmd_sysinfotxt6:DC.B 'loaded.',13
               DC.B 'clock          : ',0
cmd_sysinfotxt7:DC.B ' MHz',13
               DC.B 'add. hardware  : ',0
cmd_sysinfotxt8:DC.B 'not ',0
cmd_sysinfotxt:DC.B 13,'Banks          : ',0
cmd_sysinfotxt9:DC.B 'STE-hardware ',0
cmd_sysinfotxt10:DC.B 'TT-hardware ',0
cmd_sysinfotxt10a:DC.B 'F030-hardware ',0
cmd_sysinfotxt11:DC.B 'Mega STE-hardware ',0
cmd_sysinfotxt12:DC.B 13,'OS-Baseadr     : ',0
               ENDC
cmd_sysinfotxt13:DC.B '16MHz-Speeder ',0
cmd_sysinfotxt14:DC.B 'PC-Speed ',0
cmd_sysinfotxt15:DC.B 'Blitter ',0
cmd_sysinfotxt16:DC.B 'IMP-MMU ',0
cmd_sysinfotxt17:DC.B 'SFP004 ',0
cmd_sysinfotxt18:DC.B 'Spectre-GCR ',0
cmd_sysinfotxt19:DC.B 'AS-OverScan ',0
cmd_sysinfotxt20:DC.B 'Stacy ',0
cmd_sysinfotxt21:DC.B '6888',0
cmd_sysinfotab1:DC.B 'NTSC',0                     ;0
               DC.B 'PAL',0                       ;1
;>               DXSET 4,0
cmd_sysinfotab2:DC.B 'USA',0                        ;0
               DC.B 'FRG',0                         ;1
               DC.B 'FRA',0                         ;2
               DC.B 'UK',0,0                          ;3
               DC.B 'SPA',0                         ;4
               DC.B 'ITA',0                         ;5
               DC.B 'SWE',0                         ;6
               DC.B 'SWF',0                         ;7
               DC.B 'SWG',0                         ;8
               DC.B 'TUR',0                         ;9
               DC.B 'FIN',0                         ;10
               DC.B 'NOR',0                         ;11
               DC.B 'DEN',0                         ;12
               DC.B 'SAU',0                         ;13
               DC.B 'HOL',0                         ;14
               DC.B '???',0                         ;>14
               EVEN
               ;>ENDPART
********************************************************************************
* Mein eigener kleiner AES-Aufruf                                              *
********************************************************************************
               ;>PART 'aes'
aes:            movem.l D0-A6,-(SP)               ;besser retten, man kann nie wissen
                lea     spaced2(A4),A0
                clr.l   (A0)+
                clr.l   (A0)                      ;contrl-Array l”schen
                movep.l D0,-3(A0)                 ;und die neuen Daten eintragen
                lea     aes_pb(PC),A0
                move.l  A0,D1
aes1:           move.l  A4,D0                     ;Relozieren des Arrays
                add.l   D0,(A0)+
                add.l   D0,(A0)+
                add.l   D0,(A0)+
                add.l   D0,(A0)+
                add.l   D0,(A0)
                lea     aes1(PC),A0
                move.w  #$7000,(A0)               ;MOVEQ #0,D0 einsetzen
                bsr     clr_cache
                move.w  #200,D0
                trap    #2                        ;AES aufrufen
                movem.l (SP)+,D0-A6
                rts

aes_pb:        DC.L spaced2                       ;Der AES-Parameterblock
               DC.L spaced2+32                    ;Global-Parameter
               DC.L spaced2+32+30
               DC.L spaced2+32+30
               DC.L spaced2+32+30
               DC.L spaced2+32+30
               ;>ENDPART
********************************************************************************
* 'INFO' - Informationen ber die Speicherbelegung                             *
********************************************************************************
               ;>PART 'cmd_info'
cmd_info:       lea     cmd_info2(PC),A0
                bsr     print_info
                move.l  basepage(A4),D1
                bsr     hexa2out
                jsr     @c_eol(A4)
                lea     cmd_info3(PC),A0
                bsr     print_info
                move.l  end_adr(A4),D1
                bsr     hexa2out
                jsr     @c_eol(A4)
                lea     cmd_info4(PC),A0
                bsr     print_info
                move.l  first_free(A4),D1
                bsr     hexa2out
                jsr     @c_eol(A4)
                lea     cmd_info7(PC),A0
                bsr     print_info
                move.l  save_data+1070(A4),D1
                bsr     hexa2out
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                move.l  basep(A4),D0
                beq.s   cmd_info1                 ;Kein EXEC-Programm da
                movea.l D0,A1
                bsr     prg_info
                jmp     (A4)                      ;das war's
cmd_info1:      move.l  merk_anf(A4),D1
                beq     ret_jump                  ;Kein LOAD-Programm da
                lea     cmd_info5(PC),A0
                bsr     print_info
                bsr     hexa2out
                jsr     @c_eol(A4)
                lea     cmd_info6(PC),A0
                bsr     print_info
                move.l  merk_end(A4),D1
                subq.l  #1,D1
                bsr     hexa2out
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                jmp     (A4)

               IFEQ sprache

cmd_info2:     DC.B 'Start des Debuggers',0
cmd_info3:     DC.B 13,'Ende des Debuggers',0
cmd_info4:     DC.B 13,'Start des freien Speichers',0
cmd_info5:     DC.B 'Start des Programms',0
cmd_info6:     DC.B 13,'Ende des Programms',0
cmd_info7:     DC.B 13,'Ende des freien Speichers',0
               ELSE
cmd_info2:     DC.B 'Start of the debugger',0
cmd_info3:     DC.B 13,'End of the debugger',0
cmd_info4:     DC.B 13,'Start of free memory',0
cmd_info5:     DC.B 'Start of programm',0
cmd_info6:     DC.B 13,'End of programm',0
cmd_info7:     DC.B 13,'End of free memory',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* A0 ausgeben, Spaces bis Spalte 45 und ein Doppelpunkt folgen                 *
********************************************************************************
               ;>PART 'print_info'
print_info:     move.l  A0,-(SP)
                jsr     @print_line(A4)
                moveq   #27,D0
                bsr     spacetab
                moveq   #':',D0
                jmp     @chrout(A4)
               ;>ENDPART
********************************************************************************
* Informationen ber aktuelles Programm                                        *
********************************************************************************
               ;>PART 'prg_info'
prg_info:       movea.l basep(A4),A1              ;Basepageadr des Programms
                lea     prg_info9(PC),A0          ;Anfangsadresse des TEXT-Segments
                bsr.s   print_info
                moveq   #8,D2
                bsr     prg_info8                 ;L„nge des TEXT-Segments
                lea     prg_info10(PC),A0         ;Anfangsadresse des DATA-Segments
                bsr.s   print_info
                moveq   #$10,D2
                bsr     prg_info8                 ;L„nge des DATA-Segments
                lea     prg_info11(PC),A0         ;Anfangsadresse des BSS-Segments
                bsr.s   print_info
                moveq   #$18,D2
                bsr     prg_info8                 ;L„nge des BSS-Segments
                move.l  sym_size(A4),D2
                beq.s   prg_info3
                lea     prg_info12(PC),A0
                tst.b   gst_sym_flag(A4)
                beq.s   prg_info1
                lea     prg_info13(PC),A0
prg_info1:      bsr.s   print_info
                moveq   #14,D1                    ;ein Eintrag ist 14 Bytes lang
                bsr     ldiv
                move.l  D2,D1
                moveq   #' ',D0                   ;Singular
                subq.l  #1,D1
                beq.s   prg_info2
                moveq   #'e',D0                   ;Plural bilden
prg_info2:      move.b  D0,prg_info17
                addq.l  #1,D1
                moveq   #10,D2
                bsr     numoutx                   ;Dezimal ausgeben
                pea     prg_info16(PC)
                jsr     @print_line(A4)
                jsr     @c_eol(A4)
prg_info3:      lea     prg_info14(PC),A0         ;last used adress
                bsr.s   print_info
                move.l  $18(A1),D1
                add.l   $1C(A1),D1                ;gibt erste freie Adresse
                bsr     hexa2out
                jsr     @c_eol(A4)
                btst    #0,prg_flags+3(A4)        ;Fast-Load?
                beq.s   prg_info4                 ;Nein! =>
                lea     prg_info18(PC),A0
                bsr.s   prg_info7
prg_info4:      btst    #1,prg_flags+3(A4)        ;Prg in Fast-RAM?
                beq.s   prg_info5                 ;Nein! =>
                moveq   #0,D1
                move.b  prg_flags(A4),D1
                lsr.w   #4,D1
                addq.b  #1,D1
                lsl.w   #7,D1
                st      testwrd(A4)
                lea     prg_info20(PC),A0
                bsr     dezout
                sf      testwrd(A4)
                move.b  #'K',(A0)+
                clr.b   (A0)
                lea     prg_info19(PC),A0
                bsr.s   prg_info7
prg_info5:      btst    #2,prg_flags+3(A4)        ;Fast-RAM-Malloc()?
                beq.s   prg_info6                 ;Nein! =>
                lea     prg_info21(PC),A0
                bsr.s   prg_info7
prg_info6:      jmp     @crout(A4)

prg_info7:      move.l  A0,-(SP)
                jsr     @crout(A4)
                jsr     @print_line(A4)           ;z.B. "Fast-Load an" ausgeben
                jmp     @c_eol(A4)

prg_info8:      move.l  0(A1,D2.w),D1             ;Anfangsadresse holen
                bsr     hexa2out                  ;und ausgeben
                pea     prg_info15(PC)
                jsr     @print_line(A4)
                move.l  4(A1,D2.w),D1             ;L„nge holen
                bsr     hexlout                   ;und ausgeben
                jmp     @c_eol(A4)

               IFEQ sprache
prg_info9:     DC.B 'Start des TEXT-Segments',0
prg_info10:    DC.B 13,'Start des DATA-Segments',0
prg_info11:    DC.B 13,'Start des BSS-Segments',0
prg_info12:    DC.B 13,'Symboltabelle',0
prg_info13:    DC.B 13,'GST-Symboltabelle',0
prg_info14:    DC.B 13,'Erste freie Adresse',0
prg_info15:    DC.B '  L„nge:$',0
prg_info16:    DC.B ' Symbol'
prg_info17:    DC.B 'e',0
prg_info18:    DC.B 'Fast-Load: Nur das BSS-Segment wird gel”scht',0
prg_info19:    DC.B 'auch ins TT-Fast-RAM ladbar, TPAsize = '
prg_info20:    DC.B 'xxxxx',0
prg_info21:    DC.B 'Malloc() auch ins TT-Fast-RAM',0
               ELSE
prg_info9:     DC.B 'Start of TEXT segment',0
prg_info10:    DC.B 13,'Start of DATA segment',0
prg_info11:    DC.B 13,'Start of BSS segment',0
prg_info12:    DC.B 13,'Symboltable',0
prg_info13:    DC.B 13,'GST-Symboltable',0
prg_info14:    DC.B 13,'first free adress',0
prg_info15:    DC.B ' length:$',0
prg_info16:    DC.B ' symbol'
prg_info17:    DC.B 's',0
prg_info18:    DC.B "Fast-Load set: clear only the program's declared BSS",0
prg_info19:    DC.B 'loading to TT-Fast-RAM possible, TPAsize = '
prg_info20:    DC.B 'xxxxx',0
prg_info21:    DC.B 'Malloc() also to TT-Fast-RAM',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* Disassembler (Opcode ab A6 disassemblieren)                                  *
********************************************************************************
               ;>PART 'do_disass'
do_disass:      bsr     check_read                ;Zugriff erlaubt?
                bne     _return                   ;Ende, wenn nicht
                lea     spaced2(A4),A0
                movea.l A0,A5
                st      testwrd(A4)
                move.l  A6,D1
                addq.l  #1,D1
                andi.b  #$FE,D1
                movea.l D1,A6
                jsr     @anf_adr(A4)
                tst.b   list_flg(A4)
                beq.s   do_disass6                ;Nicht symbolisch
                move.b  #'!',(A0)+                ;Kennung für Opcode
                bsr     hunt_symbol
                beq.s   do_disass2                ;Z=1 => Kein Label
                bsr     labelout
                moveq   #':',D0
                btst    #5,8(A1)                  ;Global?
                beq.s   do_disass1
                move.b  D0,(A0)+                  ;Dann einen Doppelpunkt für Global ausgeben
do_disass1:     move.b  D0,(A0)+
                lea     26(A5),A2
                cmpa.l  A2,A0
                bhs.s   do_disass4                ;Tabulator bereits erreicht!
do_disass2:     pea     26(A5)
do_disass3:     move.b  #' ',(A0)+                ;Tab auf 25
                cmpa.l  (SP),A0
                blo.s   do_disass3
                addq.l  #4,SP
do_disass4:     movem.l A0/A3,-(SP)
                bsr     disass
                clr.b   testwrd(A4)               ;Ausgabe nicht mehr in den Buffer
                movem.l (SP)+,A0/A3
                lea     spaced(A4),A1
do_disass5:     move.b  (A1)+,(A0)+
                bne.s   do_disass5
                lea     spaced2(A4),A0
                move.w  zeile(A4),D0
                jsr     write_line                ;Ergebnis des Disassemblers ausgeben
                move    #$FF,CCR
                rts

do_disass6:     move.b  #'/',(A0)+
                movem.l A3/A5-A6,-(SP)
                bsr     get_dlen                  ;L„nge des Opcodes holen
                movem.l (SP)+,A3/A5-A6
                movea.l A6,A1
                moveq   #12,D3
                cmp.w   D3,D0
                bhs.s   do_disass8
                move.w  D0,D3
                bra.s   do_disass8
do_disass7:     move.b  #',',(A0)+                ;Opcode in Hex ausgeben
do_disass8:     move.w  (A1)+,D1
                bsr     hexwout
                subq.w  #2,D3
                bne.s   do_disass7
                pea     34(A5)
do_disass9:     move.b  #' ',(A0)+                ;Tab auf 33
                cmpa.l  (SP),A0
                blo.s   do_disass9
                addq.l  #4,SP
                move.b  #';',(A0)+
                move.b  #' ',(A0)+
                move.l  D7,-(SP)
                move.l  sym_size(A4),D7
                clr.l   sym_size(A4)              ;ohne Symboltabelle disassemblieren
                movem.l D7-A0/A3,-(SP)
                bsr     disass
                clr.b   testwrd(A4)               ;Ausgabe nicht mehr in den Buffer
                movem.l (SP)+,D7-A0/A3
                move.l  D7,sym_size(A4)
                move.l  (SP)+,D7
                lea     spaced(A4),A1
                bra.s   do_disass5
               ;>ENDPART
********************************************************************************
* Parameter für Go und Call holen                                              *
********************************************************************************
               ;>PART 'get_gopars'
get_gopars:     bsr     get_parameter             ;Parameter holen
                move    SR,D0
                bcc.s   get_gopars1               ;1.Parameter angegeben
                movea.l _pc(A4),A2                ;dann zum momentanen PC springen
get_gopars1:    move    D0,CCR
                bvs.s   get_gopars2               ;kein 2.Parameter
                move.l  A3,D0                     ;null (dann nur G ,)
                beq.s   get_gopars3               ;alten Break#16 lassen
                cmpa.l  #$0400,A3                 ;Endadresse <$400?
                blo     illequa
                move.l  A3,breakpnt+12*16(A4)     ;Adresse einschreiben
                move.w  #-1,breakpnt+12*16+4(A4)  ;Stop-Breakpoint
                move.l  #1,breakpnt+12*16+6(A4)   ;nur einmal ausführen
                bra.s   get_gopars3
get_gopars2:    clr.l   breakpnt+12*16(A4)        ;Break#16 l”schen
get_gopars3:    move.l  A2,_pc(A4)                ;PC setzen
                rts
               ;>ENDPART
********************************************************************************
* 'CALL' - Call Subroutine                                                     *
********************************************************************************
               ;>PART 'cmd_call'
cmd_call:       tst.b   (A0)                      ;nur C?
                bne.s   cmd_call2                 ;nein, Parameter kommen
cmd_call1:      movea.l _pc(A4),A6                ;Befehlsl„nge am PC ermitteln
                bsr     get_dlen
                move.l  A6,breakpnt+12*16(A4)     ;Break #16 setzen
                move.w  #-1,breakpnt+12*16+4(A4)  ;Stop-Breakpoint
                clr.l   breakpnt+12*16+6(A4)      ;nur einmal ausführen
                bra.s   go_pc

cmd_call2:      bsr.s   get_gopars                ;Parameter holen etc.
                movea.l _usp(A4),A0
                movea.l _ssp(A4),A1
                lea     loginc(PC),A2
                btst    #5,_sr(A4)                ;User- oder Supvisor-Stack?
                bne.s   cmd_call3
                move.l  A2,-(A0)                  ;Rücksprungadr auf den User-Stack
                bra.s   cmd_call4
cmd_call3:      move.l  A2,-(A1)                  ;Rücksprungadr auf den Supervisor-Stack
cmd_call4:      move.l  A1,_ssp(A4)
                move.l  A0,_usp(A4)
                move.l  _pc(A4),merk_pc_call(A4)
                bra.s   go_pc                     ;Breakpoint auf dem PC?
               ;>ENDPART
********************************************************************************
* 'GO' - Programm starten                                                      *
********************************************************************************
               ;>PART 'cmd_go'
cmd_go:         bsr     get_gopars                ;Parameter holen etc.
               ;>ENDPART
********************************************************************************
* Programm ab dem PC ausführen, inkl. Init                                     *
********************************************************************************
               ;>PART 'go_pc'
go_pc:          bsr     init_trace                ;Alles für's Programm vorbereiten
                bsr     breakset                  ;Breakpoints einsetzen (bzw.auf PC testen)
                movea.l _usp(A4),A0
                move    A0,USP                    ;USP setzen
                movea.l _ssp(A4),SP               ;SSP setzen
                tst.b   prozessor(A4)             ;68000?
                bmi.s   go_pc1                    ;ja! =>
                clr.w   -(SP)                     ;68010 oder 68020 braucht ein Wort mehr
go_pc1:         movea.l _pc(A4),A0
                move.l  A0,-(SP)                  ;PC auf den Stack
                move.w  _sr(A4),-(SP)             ;Flags auf den Stack
                tst.w   D7                        ;War ein Breakpoint auf dem PC?
                bne.s   go_pc2                    ;Nein! => Start
                move.l  A0,go_pc12+4              ;PC merken
                move.w  (A0),10(A6)               ;Befehl am PC schon mal im Breakpoint merken
                move.l  $24.w,go_pc11+2           ;Trace-Vektor merken
                bsr     clr_cache
                move.l  #go_pc10,$24.w            ;Eigene Trace-Routine rein
                bset    #7,(SP)                   ;Trace an
go_pc2:         movem.l regs(A4),D0-A6
                bset    #7,$FFFFFA07.w            ;Ring-Indikator an
                rte                               ;einen Befehl ausführen
go_pc10:        bclr    #7,(SP)                   ;Trace wieder aus
go_pc11:        move.l  #0,$24.w                  ;Alten Trace-Vektor zurück
go_pc12:        move.w  #$4AFC,$01234567          ;Breakpoint nun einsetzen
                bsr     clr_cache
                rte
               ;>ENDPART
********************************************************************************
* 'IF' - Quit if                                                               *
********************************************************************************
               ;>PART 'cmd_if'
cmd_if:         movea.l A0,A1
                bsr     get
                beq.s   cmd_if2                   ;Funktion ausgeben
                movea.l A1,A0
                lea     untrace_funk(A4),A2
                moveq   #79,D0
cmd_if1:        move.b  (A1)+,(A2)+               ;User-Trace-Funktion merken
                dbra    D0,cmd_if1
                movea.l #user_trace_buf,A1
                adda.l  A4,A1
                bsr     convert_formel
                bsr     clr_cache
                jmp     (A4)

cmd_if2:        move.l  default_adr(A4),D1
                jsr     @anf_adr(A4)
                moveq   #'I',D0
                jsr     @chrout(A4)
                moveq   #'F',D0
                jsr     @chrout(A4)
                lea     untrace_funk(A4),A1
                cmpi.b  #' ',(A1)
                beq.s   cmd_if3
                jsr     @space(A4)
cmd_if3:        move.b  (A1)+,D0
                beq.s   cmd_if4
                jsr     @chrout(A4)
                bra.s   cmd_if3
cmd_if4:        jsr     @c_eol(A4)
                jsr     @crout(A4)
                jmp     (A4)
               ;>ENDPART
********************************************************************************
* 'UNTRACE' - Untrace                                                          *
********************************************************************************
               ;>PART 'cmd_untrace'
cmd_untrace:    moveq   #-1,D1                    ;Untrace-Z„hler auf "endlos"
                bsr     get
                beq.s   cmd_untrace1              ;mit dem Tracen beginnen, da keine Parameter
                bsr     get_term                  ;Untrace-Z„hler holen
cmd_untrace1:   move.l  D1,untrace_count(A4)
                st      untrace_flag(A4)
                bra.s   cmd_trace2                ;und ab geht die Post...
               ;>ENDPART
********************************************************************************
* 'TRACE' - Programm tracen                                                    *
********************************************************************************
               ;>PART 'cmd_trace'
cmd_trace:      moveq   #1,D1                     ;Tracecount l”schen
                bsr     get
                beq.s   cmd_trace1                ;Trace ohne Parameter
                bsr     get_term
cmd_trace1:     move.l  D1,trace_count(A4)        ;Anzahl der zu tracenden Befehle
cmd_trace2:     bsr     init_trace                ;Alles setzen
                bsr     breakset                  ;Breakpoints setzen
                tst.w   D7                        ;Breakpoint auf dem PC?
                bne.s   cmd_trace3                ;Nein! =>
                movea.l _pc(A4),A0
                move.w  (A0),10(A6)               ;Inhalt vom PC holen und merken
                move.w  #$4AFC,(A0)               ;ILLEGAL einsetzen
                bsr     clr_cache
cmd_trace3:     andi    #$FB00,SR                 ;IRQs freigeben
cmd_trace4:     ori.w   #$8000,_sr(A4)            ;Trace an
                lea     trace_excep(PC),A0
                move.l  A0,$24.w
                bsr     in_trace_buff             ;Register in den Trace-Buffer
                movea.l _usp(A4),A0
                move    A0,USP                    ;USP setzen
                movea.l _ssp(A4),SP               ;SSP setzen
                movea.l _pc(A4),A0                ;Für TRAP, LINE-A/F 'ne Sonderbehandlung
                move.w  (A0),D0                   ;zu tracender Befehl
                and.w   #$FFF0,D0                 ;TRAP-Maske
                cmp.w   #$4E40,D0                 ;TRAP?
                beq.s   cmd_trace7                ;ja, direkt einspringen
                and.w   #$F000,D0                 ;LINE-A/F-Maske
                cmp.w   #$A000,D0                 ;LINE-A mužen gepatched werden, da
                beq.s   cmd_trace5                ;sonst der n„chste Befehl nicht getraced wird
                tst.b   prozessor(A4)             ;68000?
                bmi.s   cmd_trace41               ;ja! =>
                clr.w   -(SP)                     ;Null Format-Word
cmd_trace41:    move.l  A0,-(SP)                  ;PC auf den Stack
                move.w  _sr(A4),-(SP)             ;Flags auf den Stack
                movem.l regs(A4),D0-A6
                rte                               ;einen Befehl ausführen

cmd_trace5:     lea     cmd_trace6(PC),A1         ;Linea ausführen (linef geht nicht!!!)
                move.w  (A0)+,(A1)                ;Opcode kopieren
                move.l  A0,4(A1)                  ;PC+2 als Rücksprungadr setzen
                bsr     clr_cache
                move.w  _sr(A4),save_a4
                movem.l regs(A4),D0-A6
                move    save_a4(PC),SR            ;SR vom Stack holen
cmd_trace6:     nop                               ;Platz für den Opcode
                jmp     $56781234                 ;Jump back

cmd_trace7:     lea     cmd_trace8+2(PC),A1
                moveq   #$0F,D0
                and.w   (A0)+,D0                  ;Opcode holen (vom PC)
                asl.w   #2,D0
                lea     $80.w,A2                  ;Basisadresse der TRAPs
                move.l  0(A2,D0.w),(A1)           ;hinter den JMP einsetzen
                move.l  A0,6(A1)                  ;PC+2 in den 2.Jump einsetzen
                bsr     clr_cache
                tst.b   prozessor(A4)             ;68000?
                bmi.s   cmd_trace71               ;ja! =>
                clr.w   -(SP)                     ;Null Format-Word
cmd_trace71:    pea     cmd_trace9(PC)            ;Hier geht's zurück
                move.w  _sr(A4),D0                ;SR holen (Trace ist an!)
                move.w  D0,-(SP)                  ;SR wieder auf den Stack (mit Trace an!)
                or.w    #$2000,D0                 ;SSP setzen
                and.w   #$7FFF,D0                 ;Trace aus
                move    D0,SR                     ;Flags setzen
                movem.l regs(A4),D0-A6
cmd_trace8:     jmp     $56781234                 ;und ab in den Trap
cmd_trace9:     jmp     $56781234                 ;Jump an den alten PC
               ;>ENDPART
********************************************************************************
* Die Trace-Exception                                                          *
********************************************************************************
               ;>PART 'trace_exception'
save_a4:       DS.L 1

trace_excep:    move    #$2700,SR                 ;alle IRQs sperren
                bclr    #7,$FFFFFA07.w            ;Ring-Indikator aus
                move.l  A4,save_a4
                lea     varbase,A4
                movem.l D0-A6,regs(A4)            ;alle Register retten
                move.l  save_a4(PC),regs+48(A4)   ;nun A4 retten
                move.w  (SP)+,_sr(A4)
                move.l  (SP)+,_pc(A4)
                tst.b   prozessor(A4)             ;68000?
                bmi.s   trace_excep1              ;ja! =>
                addq.l  #6,SP                     ;Vector Offset + PC verwerfen
trace_excep1:   move    USP,A0
                move.l  A0,_usp(A4)               ;USP merken
                move.l  SP,_ssp(A4)               ;SSP merken
                movea.l default_stk(A4),SP        ;eigenen Stack wiederherstellen
                tst.b   untrace_flag(A4)          ;Untrace aktiviert?
                bne.s   trace_excep4              ;dann gibt's was zu tun
                subq.l  #1,trace_count(A4)        ;Trace-Counter schon abgelaufen?
                bhi     cmd_trace4                ;Nein, weiter tracen
trace_excep2:   bsr     breakclr                  ;Breakpoints entfernen
                bsr     do_vbl                    ;offene VBL Aufgaben durchführen
                bclr    #7,_sr(A4)                ;Tracebit l”schen
                movea.l _usp(A4),A0
                btst    #5,_sr(A4)                ;User-Mode an?
                beq.s   trace_excep3
                movea.l SP,A0                     ;Nein, Supervisormode
trace_excep3:   move.l  A0,rega7(A4)              ;A7 gem„ž des SR setzen
                move.l  _pc(A4),default_adr(A4)   ;Default-Adresse setzen
                jsr     @page1(A4)
                jsr     @my_driver(A4)            ;Eigener Tastaturtreiber
                bsr     update_pc
                bsr     set_reg                   ;Registersatz umkopieren
                andi    #$FB00,SR                 ;IRQs freigeben
                move.l  jmpdispa(A4),-(SP)
                rts
trace_excep4:   subq.l  #1,untrace_count(A4)
                beq.s   trace_excep2              ;Untrace-Counter abgelaufen
                lea     regs(A4),A1               ;šbergabeparameter an User-Trace
                movea.l #user_trace_buf,A0
                adda.l  A4,A0
                jsr     (A0)                      ;User-Trace-Routine aufrufen
                bne.s   trace_excep2              ;Abbruch gewünscht
                bra     cmd_trace4                ;weiter tracen
               ;>ENDPART
********************************************************************************
* Trace starten (alle Parameter setzen, Treiber wechseln)                      *
********************************************************************************
               ;>PART 'init_trace'
init_trace:     movem.l D0-A6,-(SP)
                movea.l _pc(A4),A6                ;PC holen
                bsr     check_read                ;Ist der PC an einer gültigen Adresse?
                bne     intern_bus                ;Abbruch, wenn nicht
                cmpa.l  #anfang-256,A6
                blo.s   init_trace1               ;steht der PC im Debugger?
                suba.l  A4,A6
                cmpa.l  #data_buff+8,A6           ;|-Befehl ausführen
                beq.s   init_trace1               ;das ist erlaubt!
                cmpa.l  #sekbuff,A6
                blo     ill_mem                   ;"Illegaler Speicherbereich" (im Debugger)
init_trace1:    bsr     set_buserror              ;Originalen Busfehlervektor wieder rein
                jsr     @org_driver(A4)           ;Original Tastaturtreiber rein
                movea.l kbshift_adr(A4),A0
                andi.b  #$10,(A0)                 ;Kbshift-Status l”schen, nicht CAPS
                movem.l (SP)+,D0-A6
                jmp     @page2(A4)                ;Originalscreen an
               ;>ENDPART
********************************************************************************
* Trace beenden                                                                *
********************************************************************************
               ;>PART 'exit_trace'
exit_trace:     movem.l D0-A6,-(SP)
                jsr     @page1(A4)
                bsr     update_pc
                bsr.s   set_reg                   ;Registersatz in den aktuellen
                bsr     breakclr                  ;Breakpoints wieder raus
                jsr     @my_driver(A4)            ;eigene Treiber wieder rein
                andi    #$FB00,SR                 ;IRQs freigeben
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Trace-Bufferende mit akt.Register versorgen                                  *
********************************************************************************
               ;>PART 'set_reg'
set_reg:        movem.l D0/A5-A6,-(SP)
                lea     regs(A4),A5
                movea.l trace_pos(A4),A6
                moveq   #38,D0
set_reg1:       move.w  (A5)+,(A6)+               ;eine "Spur" hinterlassen
                dbra    D0,set_reg1
                movem.l (SP)+,D0/A5-A6
                rts
               ;>ENDPART
********************************************************************************
* akt.Register in den Trace-Buffer                                             *
********************************************************************************
               ;>PART 'in_trace_buff'
in_trace_buff:  movea.l #trace_buffend,A1
                adda.l  A4,A1
                lea     regs(A4),A5
                movea.l trace_pos(A4),A6
                moveq   #38,D0
in_trace_buff1: move.w  (A5)+,(A6)+               ;eine "Spur" hinterlassen
                dbra    D0,in_trace_buff1
                cmpa.l  A1,A6
                blo.s   in_trace_buff2
                movea.l #trace_buff,A6            ;Pointer wieder auf den Anfang
                adda.l  A4,A6
in_trace_buff2: move.l  A6,trace_pos(A4)
                move.l  A6,reg_pos(A4)
                rts
               ;>ENDPART
********************************************************************************
* Einen Befehl am PC ausführen (ohne Behandlung von Linea & Traps)             *
********************************************************************************
               ;>PART 'do_trace_all'
do_trace_all:   movem.l D0-A6,-(SP)
                move.l  SP,_regsav2(A4)
                bsr     breakset                  ;Breakpoints setzen
                tst.w   D7
                bne.s   do_trace_all1
                movea.l _pc(A4),A0
                move.w  (A0),10(A6)               ;Inhalt vom PC holen und merken
                move.w  #$4AFC,(A0)               ;ILLEGAL einsetzen
do_trace_all1:  lea     do_trace_excep(PC),A0
                move.l  A0,$24.w
                bsr.s   in_trace_buff             ;Register in den Trace-Buffer
                movea.l _ssp(A4),SP               ;SSP nehmen
                tst.b   prozessor(A4)             ;68000?
                bmi.s   do_trace_all2             ;ja! =>
                clr.w   -(SP)                     ;68010 oder 68020 braucht ein Wort mehr
do_trace_all2:  move.l  _pc(A4),-(SP)             ;Der PC muž auf'm den Stack (Start mit RTE)
                move.w  _sr(A4),-(SP)             ;Status-Register schon mal auf'n Stack
                bset    #7,(SP)                   ;Tracebit setzen
                movea.l _usp(A4),A0
                move    A0,USP                    ;USP setzen
                movem.l regs(A4),D0-A6
                rte                               ;Routine anspringen
               ;>ENDPART
********************************************************************************
* Einen Befehl am PC ausführen                                                 *
********************************************************************************
               ;>PART 'do_trace'
do_trace:       lea     do_trace_excep(PC),A0
                move.l  A0,$24.w
do_trace1:      movem.l D0-A6,-(SP)
                move.l  SP,_regsav2(A4)
                bsr     breakset                  ;Breakpoints setzen
                tst.w   D7
                bne.s   do_trace2
                movea.l _pc(A4),A0
                move.w  (A0),10(A6)               ;Inhalt vom PC holen und merken
                move.w  #$4AFC,(A0)               ;ILLEGAL einsetzen
                bsr     clr_cache
do_trace2:      bsr     in_trace_buff             ;Register in den Trace-Buffer
                movea.l _ssp(A4),SP               ;SSP nehmen
                tst.b   prozessor(A4)             ;68000?
                bmi.s   do_trace3                 ;ja! =>
                clr.w   -(SP)                     ;68010 oder 68020 braucht ein Wort mehr
do_trace3:      move.l  _pc(A4),-(SP)             ;Der PC muž auf'm den Stack (Start mit RTE)
                move.w  _sr(A4),-(SP)             ;Status-Register schon mal auf'n Stack
                bset    #7,(SP)                   ;Tracebit setzen
                movea.l _usp(A4),A0
                move    A0,USP                    ;USP setzen
                movea.l _pc(A4),A0                ;Für TRAP, LINE-A/F 'ne Sonderbehandlung
                move.w  (A0),D0                   ;zu tracender Befehl
                and.w   #$FFF0,D0                 ;TRAP-Maske
                cmp.w   #$4E40,D0                 ;TRAP?
                beq.s   do_trace7                 ;ja, direkt einspringen
                and.w   #$F000,D0                 ;LINE-A-Maske
                cmp.w   #$A000,D0                 ;LINE-A muž gepatched werden, da
                beq.s   do_trace4                 ;sonst der n„chste Befehl nicht getraced wurd
                movem.l regs(A4),D0-A6
                rte                               ;Routine anspringen

do_trace4:      lea     do_trace6(PC),A1
                move.w  (A0)+,(A1)                ;Opcode kopieren
                addq.l  #6,SP
                tst.b   prozessor(A4)             ;68000?
                bmi.s   do_trace5                 ;ja! =>
                addq.l  #2,SP                     ;Format-Word verwerfen
do_trace5:      move.l  A0,4(A1)                  ;also als Rücksprungadr setzen
                bsr     clr_cache
                move.w  _sr(A4),-(SP)
                bset    #7,(SP)                   ;Tracebit setzen
                movem.l regs(A4),D0-A6
                move    (SP)+,SR                  ;SR vom Stack holen
do_trace6:      nop                               ;Platz für den Opcode
                jmp     $56781234                 ;Jump back

do_trace7:      lea     do_trace8+2(PC),A1
                moveq   #$0F,D0
                and.w   (A0)+,D0                  ;Opcode holen
                asl.w   #2,D0
                lea     $80.w,A2                  ;Basisadresse der TRAPs
                move.l  0(A2,D0.w),(A1)           ;hinter JMP
                move.w  (SP)+,D0                  ;SR vom Stack holen (Trace schon an!)
                addq.l  #2,(SP)                   ;PC+2
                move.l  (SP)+,6(A1)               ;PC in den 2.Jump einsetzen
                bsr     clr_cache
                pea     do_trace9(PC)             ;Hier geht's zurück
                move.w  D0,-(SP)                  ;SR wieder auf den Stack (mit Trace an!)
                or.w    #$2000,D0                 ;SSP setzen
                and.w   #$7FFF,D0                 ;Trace aus
                move    D0,SR                     ;Flags setzen
                movem.l regs(A4),D0-A6
do_trace8:      jmp     $56781234                 ;und ab in den Trap
do_trace9:      jmp     $56781234                 ;Jump an den alten PC

do_trace_excep: ori     #$0700,SR                 ;alle IRQs canceln
                move.l  A4,save_a4
                lea     varbase,A4
                movem.l D0-A6,regs(A4)            ;alle Register retten
                move.l  save_a4(PC),regs+48(A4)   ;nun A4 retten
                move.w  (SP)+,_sr(A4)             ;Statusregister
                bclr    #7,_sr(A4)                ;Tracebit l”schen
                move.l  (SP)+,_pc(A4)             ;PC (SP nun wieder normal!)
                tst.b   prozessor(A4)             ;68000 oder 68010?
                bmi.s   do_trace_excep1           ;ja! =>
                addq.l  #6,SP                     ;68010 oder 68020 hat ein Wort + PC mehr
do_trace_excep1:move.l  _pc(A4),default_adr(A4)   ;PC = Defaultadr
                move    USP,A2
                move.l  A2,_usp(A4)               ;USP merken
                move.l  SP,_ssp(A4)               ;SSP merken
                move.l  SP,rega7(A4)              ;als A7 merken
                btst    #5,_sr(A4)                ;Falls die Routine im User-Mode war,
                bne.s   do_trace_excep2
                move.l  _usp(A4),rega7(A4)        ;den USP als A7 merken
do_trace_excep2:movea.l _regsav2(A4),SP           ;Stack wiederherstellen
                bsr     do_vbl                    ;offene VBL Aufgaben durchführen
                bra     f_trac1
               ;>ENDPART
********************************************************************************
* Befehl 'B': Breakpoints behandeln                                            *
********************************************************************************
               ;>PART 'cmd_bkpt'
cmd_bkpt:       bsr     get                       ;Zeichen hinter B lesen
                lea     breakpnt(A4),A1
                cmp.b   #'K',D0                   ;Breakpoint-Clear?
                beq     cmd_bkpt10
                tst.b   D0                        ;Breakpoint-List
                beq     cmd_bkpt14
                bsr     get_term                  ;also Break-Set
                cmp.l   #16,D1
                bhs     illequa                   ;>15,gibt es nicht
                move.w  D1,-(SP)                  ;Break-Nr.merken
                tst.b   D0
                beq     cmd_bkpt13                ;Einzelnen Breakpoint ausgeben
                cmp.b   #'=',D0
                bne     synerr                    ;Bn=Adr
                bsr     get
                beq     synerr                    ;kommt nix mehr
                bsr     get_term                  ;Value holen!
                move.w  (SP)+,D3                  ;Break-Nr.holen
                move.w  D3,D7                     ;Nummer merken
                addq.l  #1,D1
                and.b   #$FE,D1                   ;Breakpoint auf gerade Adresse
                tst.l   D1
                beq.s   cmd_bkpt1                 ;null als Argument erlaubt
                movea.l D1,A6
                bsr     check_write
                bne     illbkpt
cmd_bkpt1:      mulu    #12,D3                    ;mal 12 als Index in die Tabelle
                lea     0(A1,D3.w),A6
                move.l  D1,(A6)+                  ;Adresse merken
                move.w  #-1,(A6)                  ;Default = Stop-Breakpoint mit Counter 1
                moveq   #1,D1
                move.l  D1,2(A6)                  ;Den Z„hler auf 1 initialisieren
                tst.b   D0
                beq.s   cmd_bkpt3
                cmp.b   #',',D0                   ;Es muž ein Komma folgen
                bne     synerr
                bsr     get                       ;Das Zeichen nach dem Komma
                beq     synerr                    ;Es folgte nichts
                cmp.b   #'=',D0
                beq.s   cmd_bkpt4                 ;Counter-Breakpoint
                cmp.b   #'*',D0
                beq.s   cmd_bkpt6                 ;Permanent-Breakpoint
                cmp.b   #'?',D0
                beq.s   cmd_bkpt7                 ;User-Breakpoint
cmd_bkpt2:      bsr     get_term                  ;Anzahl der Durchl„ufe für den Stop-Breakpoint
                tst.l   D1
                bmi     illequa                   ;Das geht doch zu weit
                move.l  D1,2(A6)                  ;Durchl„ufe setzen
cmd_bkpt3:      jmp     (A4)
cmd_bkpt4:      clr.w   (A6)                      ;Counter-Breakpoint setzen
cmd_bkpt5:      clr.l   2(A6)                     ;Z„hlerdefault=0
                bsr     get
                bne.s   cmd_bkpt2
                jmp     (A4)
cmd_bkpt6:      move.w  #1,(A6)                   ;Permanent setzen
                bra.s   cmd_bkpt5
cmd_bkpt7:      move.w  #2,(A6)                   ;User-Breakpoint setzen
                move.w  D7,D1
                mulu    #80,D1
                lea     cond_breaks(A4),A1
                adda.w  D1,A1
                movea.l A0,A2
                moveq   #79,D1
cmd_bkpt8:      move.b  (A2)+,(A1)+               ;Bedingung merken
                dbra    D1,cmd_bkpt8
                moveq   #9,D1
                lsl.w   D1,D7
                lea     0(A4,D7.w),A1
                adda.l  #cond_bkpt_jsr*1,A1       ;hier soll der Code hin
                move.l  A1,2(A6)                  ;Adresse der Routine
                bsr     convert_formel
                bsr     clr_cache
                move.w  -8(A1),D0
                and.w   #$F0FF,D0
                cmp.w   #$50C0,D0                 ;Sxx D0?
                bne.s   cmd_bkpt9
                subq.l  #4,A1                     ;RTS:EXT.L D0
                cmpi.w  #$48C0,(A1)
                bne.s   cmd_bkpt9                 ;kein EXT.L =>
                cmpi.w  #$4880,-(A1)
                bne.s   cmd_bkpt9                 ;kein EXT.W =>
                move.w  #$4E75,(A1)+
                clr.l   (A1)+
                clr.l   (A1)
cmd_bkpt9:      jmp     (A4)

cmd_bkpt10:     bsr     get                       ;'BK' - Breakpoints l”schen
                beq.s   cmd_bkpt11                ;Alle Breakpoints l”schen
                bsr     get_term                  ;also Break-Clr
                cmp.l   #16,D1
                bhs     illequa                   ;>15,gibt es nicht
                mulu    #12,D1
                clr.l   0(A1,D1.w)                ;BK+Nummer = best.Breakpoint l”schen
                jmp     (A4)
cmd_bkpt11:     lea     breakpnt_end(A4),A0
cmd_bkpt12:     clr.w   (A1)+                     ;Alle Breakpoints l”schen
                cmpa.l  A0,A1
                blo.s   cmd_bkpt12
                jmp     (A4)

cmd_bkpt13:     move.w  (SP)+,D2
                move.w  D2,D3
                mulu    #12,D3
                adda.w  D3,A1
                neg.w   D2
                addi.w  #15,D2
                bsr.s   cmd_bkpt21                ;Breakpoint ausgeben
                jmp     (A4)

cmd_bkpt14:     moveq   #15,D2                    ;alle 16 Breakpoints ausgeben
                moveq   #0,D7
cmd_bkpt15:     tst.l   (A1)
                beq.s   cmd_bkpt16                ;nur gesetzte Breakpoints ausgeben
                moveq   #-1,D7                    ;min. einen Breakpoint gefunden
                bsr.s   cmd_bkpt21
cmd_bkpt16:     lea     12(A1),A1
                dbra    D2,cmd_bkpt15
                tst.w   D7
                bne.s   cmd_bkpt17
                pea     cmd_bkpt20(PC)            ;Keinen gefunden
                jsr     @print_line(A4)
cmd_bkpt17:     jmp     (A4)
               IFEQ sprache
cmd_bkpt20:    DC.B '?keine Breakpoints',13,0
               ELSE
cmd_bkpt20:    DC.B '?no Breakpoints',13,0
               ENDC
               EVEN

cmd_bkpt21:     move.l  (A1),D1
                jsr     @anf_adr(A4)
                moveq   #'B',D0                   ;Prompt ausgeben
                jsr     @chrout(A4)
                move.w  D2,D1
                neg.w   D1
                addi.w  #15,D1
                move.w  D1,D6                     ;Breakpointnummer merken
                bsr     hexbout
                moveq   #'=',D0
                jsr     @chrout(A4)
                move.l  (A1),D1
                bsr     hexlout                   ;Adresse ausgeben
                move.w  4(A1),D1                  ;Typ holen
                subq.w  #1,D1
                beq.s   cmd_bkpt22                ;Permanent
                blo.s   cmd_bkpt23                ;Counter
                bpl.s   cmd_bkpt26                ;User
                moveq   #' ',D0
                move.l  6(A1),D1                  ;Anzahl der Durchl„ufe für Stop
                bmi.s   cmd_bkpt29
                cmp.l   #1,D1
                bls.s   cmd_bkpt29                ;1 Durchlauf => Ende
                moveq   #',',D0
                bra.s   cmd_bkpt24
cmd_bkpt22:     bsr.s   cmd_bkpt31                ;Permanent-Breakpoints
                moveq   #'*',D0
                move.l  6(A1),D1                  ;Anzahl der Durchl„ufe für Stop
                bmi.s   cmd_bkpt29
                cmp.l   #1,D1
                bls.s   cmd_bkpt29                ;1 Durchlauf => Ende
                jsr     @chrout(A4)
                moveq   #' ',D0
                move.l  6(A1),D1                  ;Anzahl der Durchl„ufe für Stop
                bmi.s   cmd_bkpt29
                cmp.l   #1,D1
                bls.s   cmd_bkpt29                ;1 Durchlauf => Ende
                bra.s   cmd_bkpt25
cmd_bkpt23:     bsr.s   cmd_bkpt31                ;Counter-Breakpoints
                moveq   #'=',D0
                move.l  6(A1),D1
cmd_bkpt24:     jsr     @chrout(A4)
cmd_bkpt25:     move.l  D2,-(SP)
                bsr     dezout
                move.l  (SP)+,D2
                moveq   #' ',D0
                bra.s   cmd_bkpt29
cmd_bkpt26:     bsr.s   cmd_bkpt31
                moveq   #'?',D0                   ;User-Breakpoints
                jsr     @chrout(A4)
                mulu    #80,D6                    ;*80 (Platz für jeden Breakpoint)
                lea     cond_breaks(A4),A2
                adda.w  D6,A2
cmd_bkpt27:     cmpi.b  #' ',(A2)+                ;Spaces links von der Bedingung berlesen
                beq.s   cmd_bkpt27
                subq.l  #1,A2
cmd_bkpt28:     move.b  (A2)+,D0                  ;Bedingung ausgeben
                beq.s   cmd_bkpt30
                jsr     @chrout(A4)
                bra.s   cmd_bkpt28

cmd_bkpt29:     jsr     @chrout(A4)
cmd_bkpt30:     jsr     @c_eol(A4)
                jmp     @crout(A4)

cmd_bkpt31:     moveq   #',',D0
                jmp     @chrout(A4)
               ;>ENDPART
********************************************************************************
* Breakpoints einsetzen                                                        *
********************************************************************************
               ;>PART 'breakset'
breakset4:      moveq   #0,D7                     ;Flag für Breakpoint auf PC setzen
                movea.l A1,A6                     ;Adresse des Breakpoints merken
                bra.s   breakset2
breakset:       lea     breakpnt(A4),A1           ;Breakpoints einsetzen
                moveq   #-1,D7
                movea.l _pc(A4),A0
                moveq   #16,D1                    ;Z„hler für 17 Breakpoints
breakset1:      tst.l   (A1)
                beq.s   breakset2                 ;nix setzen
                movea.l (A1),A3                   ;Adresse holen
                cmpa.l  A0,A3                     ;Breakpoint auf dem PC?
                beq.s   breakset4                 ;Ja! =>
                move.l  A6,-(SP)
                movea.l A3,A6
                bsr     check_write               ;Breakpoint dort erlaubt?
                movea.l (SP)+,A6
                bne     illbkpt                   ;Nein! =>
                tst.b   breaks_flag(A4)           ;Breakpoints schon drin?
                bne.s   breakset2                 ;Ja! =>
                move.w  (A3),10(A1)               ;Inhalt von dort holen und merken
                move.w  #$4AFC,(A3)               ;ILLEGAL einsetzen
breakset2:      lea     12(A1),A1                 ;n„chster Breakpoint
                dbra    D1,breakset1
                tst.b   observe_off(A4)
                bne.s   breakset3                 ;kein Observe!!!
                move.l  #new_gemdos,$84.w         ;Trap #1
                move.l  #new_aesvdi,$88.w         ;Trap #2
                move.l  #new_bios,$B4.w           ;Trap #13
                move.l  #new_xbios,$B8.w          ;Trap #14
                move.l  #etv_term,$0408.w         ;Neuer etv_term-Handler
breakset3:      st      breaks_flag(A4)
                bra     clr_cache
               ;>ENDPART
********************************************************************************
* Breakpoints entfernen                                                        *
********************************************************************************
               ;>PART 'breakclr'
breakclr:       tst.b   breaks_flag(A4)           ;Breakpoints schon draužen?
                beq.s   breakclr3                 ;Ja! =>
                lea     breakpnt+12*16(A4),A1
                moveq   #16,D1
breakclr1:      move.l  (A1),D3
                beq.s   breakclr2                 ;den gibt's nicht
                movea.l D3,A0                     ;Adresse holen
                move.w  10(A1),(A0)               ;Befehl wieder einsetzen
                tst.w   4(A1)
                bpl.s   breakclr2                 ;Kein STOP-Breakpoint
                tst.l   6(A1)
                bhi.s   breakclr2                 ;Der Z„hler ist noch gr”žer als Null
                clr.l   (A1)                      ;Breakpoint entfernen
breakclr2:      lea     -12(A1),A1
                dbra    D1,breakclr1
                sf      breaks_flag(A4)
                tst.b   observe_off(A4)
                bne.s   breakclr3
                movem.l D0/A0-A3,-(SP)
                lea     save_data-8(A4),A0
                lea     breakclr6(PC),A3
                lea     $84.w,A1
                lea     old_gemdos(PC),A2
                bsr.s   breakclr4
                lea     old_aesvdi(PC),A2
                bsr.s   breakclr4
                lea     $B4.w,A1
                lea     old_bios(PC),A2
                bsr.s   breakclr4
                lea     old_xbios(PC),A2
                bsr.s   breakclr4
                move.l  $0408(A0),$0408.w         ;etv_term auf normal
                movem.l (SP)+,D0/A0-A3
breakclr3:      bra     clr_cache

breakclr4:      move.l  (A1),D0                   ;Alten Vektor holen
                cmp.l   (A3)+,D0
                beq.s   breakclr5                 ;Vektor stimmt noch
                move.l  D0,(A2)
breakclr5:      move.l  0(A0,A1.w),(A1)+          ;Originalvektor rein
                addq.l  #4,A2
                rts

breakclr6:     DC.L new_gemdos                    ;Zeiger auf die eigenen Unterprogramme
               DC.L new_aesvdi
               DC.L new_bios
               DC.L new_xbios
               ;>ENDPART
********************************************************************************
* 'DIRECTORY' - Directory anzeigen                                             *
********************************************************************************
               ;>PART 'cmd_dir'
cmd_dir:        tst.b   batch_flag(A4)
                bne     batch_mode_err
                bsr     get                       ;keine Parameter?
                beq.s   cmd_dir2
                bsr     getnam_cont               ;Namen nach fname
                beq.s   cmd_dir2                  ;Name wurde nicht angegeben
                lea     fname(A4),A1              ;Namens-Puffer
                lea     dir_ext(A4),A0
                moveq   #12,D0                    ;max.13 Zeichen Suchfile
cmd_dir1:       move.b  (A1)+,(A0)+               ;kopieren
                dbeq    D0,cmd_dir1
cmd_dir2:       moveq   #1,D0                     ;Diskette einschalten
                bsr     graf_mouse
                movem.l D1-A6,-(SP)
                pea     dir_ext(A4)
                movea.l #allg_buffer,A0
                adda.l  A4,A0
                move.l  A0,-(SP)
                bsr     read_dir                  ;Directory einlesen
                addq.l  #8,SP
                movem.l (SP)+,D1-A6
                move.l  D0,D7                     ;Anzahl der gefundenen Dateien
                bmi     toserr                    ;Fehler! =>
                bne.s   cmd_dir4
                pea     cmd_dir3(PC)
                jsr     @print_line(A4)
                bsr     drive_free
                jmp     (A4)
cmd_dir3:      IFEQ sprache
               DC.B '?Keine Dateien gefunden',13,0
               ELSE
               DC.B '?No files',13,0
               ENDC
               EVEN

cmd_dir4:       movea.l #allg_buffer,A6
                adda.l  A4,A6                     ;Zeiger auf den Directory-Buffer
                subq.w  #1,D7
cmd_dir5:       lea     cmd_drb(PC),A0            ;DIR "
                btst    #5,1(A6)                  ;File oder Ordner?
                beq.s   cmd_dir6                  ;Ordner =>
                lea     cmd_drd(PC),A0            ;LE  "
                lea     cmd_extensions(PC),A1
cmd_dir50:      move.l  (A1)+,D0                  ;n„chsten Eintrag aus der Tabelle
                cmp.l   12(A6),D0                 ;Extension in der Tabelle?
                beq.s   cmd_dir6                  ;Ja! => "LE"
                tst.l   D0                        ;Ende der Tabelle?
                bne.s   cmd_dir50                 ;Nein! =>
                lea     cmd_dra(PC),A0            ;LO  "
cmd_dir6:       move.l  A0,-(SP)
                jsr     @print_line(A4)           ;Zeilenanfang
                movea.l A6,A5
                addq.l  #3,A5                     ;'  ' bzw. '   '
cmd_dir7:       move.b  (A5)+,D0
                beq.s   cmd_dir10
                cmp.b   #' ',D0
                beq.s   cmd_dir7                  ;Spaces berlesen
                cmp.b   #'.',D0
                beq.s   cmd_dir9
cmd_dir8:       jsr     @chrout(A4)
                bra.s   cmd_dir7
cmd_dir9:       cmpi.b  #' ',(A5)                 ;Extension vorhanden?
                bne.s   cmd_dir8
cmd_dir10:      btst    #5,1(A6)
                bne.s   cmd_dir11
                moveq   #'\',D0
                jsr     @chrout(A4)               ;Ordnerkennung
cmd_dir11:      moveq   #'"',D0
                jsr     @chrout(A4)
                moveq   #20,D0
                bsr     spacetab
                moveq   #';',D0
                jsr     @chrout(A4)               ;(für Load)
                move.l  20(A6),D1
                bsr     dezout
                moveq   #30,D0
                bsr     spacetab

                move.w  24(A6),D1                 ;Zeit holen
                move.w  D1,D0
                rol.w   #5,D0                     ;Stunden
                and.w   #$1F,D0
                bsr     dirdez                    ;ausgeben
                moveq   #':',D0
                jsr     @chrout(A4)
                move.w  D1,D0
                lsr.w   #5,D0                     ;Minuten
                and.w   #$3F,D0
                bsr     dirdez                    ;ausgeben
                moveq   #':',D0
                jsr     @chrout(A4)
                moveq   #$1F,D0
                and.w   D1,D0                     ;Sekunden
                add.w   D0,D0
                bsr     dirdez                    ;ausgeben
                jsr     @space(A4)

                move.w  26(A6),D1                 ;Datum holen
                moveq   #$1F,D0
                and.w   D1,D0
                bsr     dirdez                    ;den Tag ausgeben
                moveq   #'-',D0
                jsr     @chrout(A4)
                move.w  D1,D0
                lsr.w   #5,D0
                and.w   #$0F,D0
                bsr     dirdez                    ;den Monat ausgeben
                moveq   #'-',D0
                jsr     @chrout(A4)
                moveq   #9,D0
                lsr.w   D0,D1
                moveq   #$7F,D0
                and.l   D0,D1
                add.w   #1980,D1
                moveq   #10,D2                    ;(dezimal)
                bsr     numoutx                   ;das Jahr ausgeben
                jsr     @space(A4)

                move.b  29(A6),D2                 ;Fileattribute holen
                bsr.s   fatt_out                  ;und ausgeben
                bsr     check_keyb                ;Taste gedrückt?
                bmi.s   cmd_dir16
                lea     32(A6),A6
                dbra    D7,cmd_dir5
                bsr     drive_free
cmd_dir16:      jmp     (A4)

cmd_extensions:DC.L 'PRG ','TOS ','TTP ','ACC ','APP ','PRX ','ACX ',0

fatt_out:       moveq   #0,D1                     ;Bitcounter
                moveq   #0,D3                     ;Adress-Counter
fatt_out1:      btst    D1,D2                     ;Entsprechendes Bit gesetzt?
                beq.s   fatt_out3
fatt_out2:      move.b  cmd_drc(PC,D3.w),D0       ;Zeichen nach D0
                jsr     @chrout(A4)
                addq.w  #1,D3
                cmp.b   #' ',D0
                bne.s   fatt_out2
                subq.w  #4,D3
fatt_out3:      addq.w  #4,D3
                addq.w  #1,D1
                cmp.w   #6,D1
                bne.s   fatt_out1
                jsr     @c_eol(A4)
                jmp     @crout(A4)

cmd_dra:       DC.B 'LO  "',0
cmd_drd:       DC.B 'LE  "',0
cmd_drb:       DC.B 'DIR "',0
cmd_drc:       DC.B 'r/o ','hid ','sys ','vol ','sub ','clo '
               EVEN
dirdez:         divu    #10,D0
                or.l    #' 0 0',D0
                jsr     @chrout(A4)
                swap    D0                        ;Die Stunden ausgeben
                jmp     @chrout(A4)
               ;>ENDPART
********************************************************************************
* File_anz = read_dir(*Zielbuffer,*Suchpfad)                                   *
********************************************************************************
               ;>PART 'read_dir'
read_dir:       movea.l 4(SP),A5                  ;Zielbuffer
                bsr     do_mediach                ;Media-Change ausl”sen
                clr.w   (A5)                      ;Tabelle leeren
                pea     data_buff(A4)
                move.w  #$1A,-(SP)
                bsr     do_trap_1                 ;Fsetdta(data_buff)
                addq.l  #6,SP
                lea     data_buff(A4),A6          ;Adresse des DTA-Buffers
                lea     r_dir_fold_flag(PC),A0
                st      (A0)
                lea     r_dir_joker(PC),A0
                moveq   #$37,D0                   ;Zuerst die Ordner einlesen
                bsr.s   read_dir2
                tst.l   D0
                bmi     read_dir25                ;Fehler, Abbruch =>
                lea     r_dir_fold_flag(PC),A0
                clr.w   (A0)
                movea.l 8(SP),A0                  ;Zeiger auf den Suchpfad
                tst.b   (A0)
                bne.s   read_dir1
                lea     r_dir_joker(PC),A0
read_dir1:      moveq   #$27,D0                   ;nun die Files einlesen
read_dir2:      lea     varbase,A4
                move.w  D0,-(SP)
                move.l  A0,-(SP)
                move.w  #$4E,-(SP)
                bsr     do_trap_1
                addq.w  #8,SP
                tst.l   D0
                bmi     read_dir23
read_dir3:      cmpi.b  #'.',30(A6)               ;Punkt als erster Buchstabe? => Ordner
                beq     read_dir22
                lea     r_dir_buffer(PC),A4       ;Hier gehn die Daten hin
                lea     21(A6),A0
                moveq   #0,D7
                move.b  (A0)+,D7                  ;Fileattribute
                move.w  D7,28(A4)
                lea     24(A4),A1
                move.l  (A0)+,(A1)                ;Zeit + Datum
                move.l  (A0)+,-(A1)               ;Gr”že vom Intel-Format in 68000er-Format
                move.b  #' ',(A4)+                ;Space vor den Filenamen
                move.b  #'',(A4)                 ;Flag für Ordner
                btst    #4,D7                     ;Ordner?
                bne.s   read_dir4
                move.b  #' ',(A4)                 ;Space statt Ordnerkennung
                lea     r_dir_fold_flag(PC),A1
                tst.w   (A1)
                bne     read_dir21                ;Dann aber weg!
read_dir4:      addq.w  #1,A4
                move.b  #' ',(A4)+                ;und noch ein Space dran
                moveq   #0,D6
                moveq   #7,D0
read_dir5:      move.b  (A0)+,D7
                beq.s   read_dir6
                cmp.b   #'.',D7
                beq.s   read_dir6
                move.b  D7,(A4)+                  ;max.8 Zeichen bis Nullbyte kopieren
                dbeq    D0,read_dir5
read_dir6:      tst.w   D0
                bmi.s   read_dir9
                tst.b   D7
                bne.s   read_dir7
                moveq   #-1,D6
read_dir7:      moveq   #' ',D1
read_dir8:      move.b  D1,(A4)+
                dbra    D0,read_dir8
read_dir9:      move.b  #'.',(A4)+                ;Ein Punkt hinter den Filenamen
                moveq   #2,D0
                tst.w   D6
                bne.s   read_dir11
read_dir10:     move.b  (A0)+,D7
                beq.s   read_dir11
                cmp.b   #'.',D7
                beq.s   read_dir10
                move.b  D7,(A4)+                  ;max.3 Zeichen bis Nullbyte kopieren
                dbeq    D0,read_dir10
read_dir11:     tst.w   D0
                bmi.s   read_dir13
                moveq   #' ',D1
read_dir12:     move.b  D1,(A4)+                  ;Extension mit Spaces auffüllen
                dbra    D0,read_dir12
read_dir13:     move.b  #' ',(A4)+                ;und noch ein Space anh„ngen
                clr.l   (A4)+                     ;bis zum 20.Byte l”schen

                movea.l A5,A4
                lea     r_dir_buffer(PC),A3       ;Hier liegen die Daten
                movem.l (A3),D3-A2                ;Buffer in Register holen (D3-D6=Filename)
                bra.s   read_dir15
read_dir14:     lea     32(A4),A4
read_dir15:     tst.b   (A4)
                beq.s   read_dir20                ;Ende der Tabelle erreicht
                cmp.l   (A4),D3
                bhi.s   read_dir14
                bne.s   read_dir16
                cmp.l   4(A4),D4
                bhi.s   read_dir14
                bne.s   read_dir16
                cmp.l   8(A4),D5                  ;Filenamen vergleichen
                bhi.s   read_dir14
                bne.s   read_dir16
                cmp.l   12(A4),D6
                bhi.s   read_dir14
                bne.s   read_dir16
                cmpa.l  20(A4),A0                 ;L„nge vergleichen
                bhi.s   read_dir14
                bne.s   read_dir16
                cmpa.l  24(A4),A0                 ;Datum/Uhrzeit vergleichen
                bhi.s   read_dir14
                beq.s   read_dir14
read_dir16:     movea.l A4,A3
                bra.s   read_dir18
read_dir17:     lea     32(A4),A4
read_dir18:     tst.b   32(A4)                    ;Das Tabellenende suchen
                bne.s   read_dir17
                clr.w   64(A4)
read_dir19:     movem.l (A4)+,D0-D7
                movem.l D0-D7,(A4)
                lea     -64(A4),A4
                cmpa.l  A3,A4
                bhs.s   read_dir19
                lea     r_dir_buffer(PC),A4       ;Hier liegen die Daten
                movem.l (A4),D0-D7                ;Buffer in Register holen (D0-D7=Filename)
                movem.l D0-D7,(A3)
                bra.s   read_dir21
read_dir20:     movem.l D3-A2,(A4)
                clr.w   32(A4)                    ;Folgeeintrag l”schen
read_dir21:     lea     30(A6),A0
                clr.l   (A0)+                     ;Filename l”schen
                clr.l   (A0)+
                clr.l   (A0)+
                clr.w   (A0)+
read_dir22:     move.l  A4,-(SP)
                lea     varbase,A4
                move.w  #$4F,-(SP)
                bsr     do_trap_1
                addq.w  #2,SP
                movea.l (SP)+,A4
                tst.l   D0
                bpl     read_dir3
read_dir23:     lea     -32(A5),A0
                moveq   #-49,D1
                cmp.l   D1,D0                     ;keine weiteren Dateien
                beq.s   read_dir24                ;alles ok =>
                moveq   #-33,D1
                cmp.l   D1,D0                     ;Datei nicht gefunden
                beq.s   read_dir24                ;alles ok =>
                rts                               ;mit Fehler abbrechen
read_dir24:     lea     32(A0),A0
                tst.b   (A0)                      ;Tabellenende suchen
                bne.s   read_dir24
                suba.l  A5,A0                     ;Gr”že der Tabelle
                move.l  A0,D0
                lsr.l   #5,D0                     ;durch 32 (Gr”že eines Eintrags)
read_dir25:     rts

r_dir_fold_flag:DC.W 0                            ;gesetzt, wenn NUR Ordner gesucht werden
r_dir_buffer:  DS.B 32                            ;Zwischenspeicher für einen Eintrag
r_dir_joker:   DC.B '*.*',0
               EVEN
               ;>ENDPART
********************************************************************************
* D0=get_dlen(A6) - Gültigkeit und L„nge des Opcodes ab A6 ermitteln           *
* Alle Flags sind gesetzt, falls der Opcode unbekannt ist                      *
********************************************************************************
               ;>PART 'get_dlen'
get_dlen:       movea.l A6,A5                     ;Anfangsadr des Opcodes merken
                bsr     check_read                ;Zugriff erlaubt?
                bne     getdl7                    ;Abbruch,wenn nicht
                move.b  (A6),D1
                lsr.b   #3,D1
                moveq   #30,D0
                and.w   D1,D0
                lea     distab_tab(PC),A1
                movea.l A1,A3
                adda.w  0(A1,D0.w),A1             ;Tabellenanfang
                adda.w  2(A3,D0.w),A3             ;Tabellenende
                move.w  (A6)+,D1                  ;zu disassemblierender Opcode
                bra.s   getdl1

getdtab:       DC.W $FFFF                         ;00,
               DC.W $FF00                         ;01,
               DC.W $FFFF                         ;02,add2
               DC.W $FFF0                         ;03,
               DC.W $F1FF                         ;04,
               DC.W $FFF8                         ;05,
               DC.W $FFF8                         ;06,
               DC.W $FF00                         ;07,relative Adressdistanz folgt
               DC.W $FFF8                         ;08,
               DC.W $FFF8                         ;09,
               DC.W $F1FF                         ;0A,
               DC.W $F1FF                         ;0B,
               DC.W $F03F                         ;0C,<ea> Bit 6-11
               DC.W $FFC0                         ;0D,alle
               DC.W $FFC0                         ;0E,„nderbar
               DC.W $FFC0                         ;0F,Daten „nderbar
               DC.W $FFC0                         ;10,Daten
               DC.W $FFC0                         ;11,Speicher „nderbar
               DC.W $FFC0                         ;12,alles aužer #
               DC.W $FFC0                         ;13,Kontrolle
               DC.W $F1FF                         ;14,
               DC.W $F1FF                         ;15,
               DC.W $FFFF                         ;16,
               DC.W $FFFF                         ;17,
               DC.W $FFFF                         ;18,
               DC.W $FFFF                         ;19,add2
               DC.W $FFFF                         ;1A,add2
               DC.W $FFFF                         ;1B,#-Wort mit L„nge x folgt
               DC.W $FFF8                         ;1C,add2
               DC.W $F1FF                         ;1D,add2
               DC.W $FFFF                         ;1E,add2
               DC.W $FFF8                         ;1F,
               DC.W $FFC0                         ;20,BTST-Befehl
               DC.W $FFF8                         ;21,BKPT-Befehl
               DC.W $F000                         ;22,Linea
               DC.W $F000                         ;23,Linef
               DC.W $FFFF                         ;24,Dn oder An     (movec)
               DC.W $FFFF                         ;25,add2 68010-Register (movec)

getdl1:         moveq   #$3F,D0                   ;Quelladressierungsart
                and.w   4(A1),D0                  ;Maske für Adressierarten aus Tabelle
                add.w   D0,D0                     ;mal zwei als Index
                move.w  getdtab(PC,D0.w),D3       ;Maske (Qperator) in D3
                move.w  4(A1),D0                  ;Maske nocheinmal holen
                ror.w   #7,D0                     ;Highbyte zum lowbyte machen
                and.w   #$7E,D0                   ;mal zwei als Index
                and.w   getdtab(PC,D0.w),D3       ;Operandenmaske einbringen
                move.w  4(A1),D0                  ;Word für Adressierarten
                bpl.s   getdl2
                and.w   #$FF3F,D3                 ;Operand negativ
getdl2:         tst.b   D0                        ;Conditionfeld?
                bpl.s   getdl3
                and.w   #$F0FF,D3                 ;Operator negativ
getdl3:         and.w   D1,D3                     ;prüfen, ob d1 in die Maske passt
                cmp.w   2(A1),D3                  ;Opcode aus Tabelle gleich?
                beq.s   getdl8                    ;ja, k”nnte das Richtige sein
getdl4:         addq.l  #6,A1                     ;Zeiger erh”hen
                cmpa.l  A3,A1                     ;Ende erreicht?
                bne.s   getdl1                    ;nein, weitersuchen
                move.w  D1,D0                     ;Vergleich auf MOVEM
                and.w   #$FB80,D0                 ;maske für MOVEM
                cmp.w   #$4880,D0                 ;Opcode für MOVEM
                bne.s   getdl7                    ;nein, Opcode nicht gefunden
                addq.l  #2,A6                     ;Registermaske = 1 Word berlesen
                btst    #10,D1                    ;Richtung des MOVEM
                bne.s   getdl5                    ;Speicher in Register!
                move.w  #$01F4,D2
                bsr     _chea
                tst.w   D7
                bne.s   getdl7
                bra.s   getdl6
getdl5:         move.w  #$07EC,D2
                bsr     _chea
                tst.w   D7
                bne.s   getdl7
getdl6:         move.l  A6,D0
                sub.l   A5,D0                     ;L„nge des Opcodes
                move    #0,CCR                    ;Alles OK
                rts
getdl7:         lea     2(A5),A6
                moveq   #2,D0                     ;L„nge des Opcodes
                move    #$FF,CCR                  ;Fehler
                rts

getdl8:         move.w  4(A1),D5                  ;Adressierungsarten-Word
                bpl.s   getdl9                    ;Bit für L„ngenangabe war gel”scht
                move.w  D1,D0                     ;zu disass. Wert
                and.w   #$C0,D0                   ;L„nge isolieren
                cmp.w   #$C0,D0                   ;beide Bits gesetzt => Fehler
                beq.s   getdl4                    ;N„chsten Opcode testen
getdl9:         andi.w  #$3F3F,D5                 ;šberflüssige Bits entfernen
                tst.w   D5
                beq.s   getdl6                    ;Wenn kein Operator/Operand folgt => Fertig
                move.w  D5,D0
                movem.l D1-D3,-(SP)
                bsr.s   eaoper                    ;Operator testen
                movem.l (SP)+,D1-D3
                tst.w   D7
                bne.s   getdl4                    ;KO
                move.w  D5,D0
                lsr.w   #8,D0
                tst.b   D0
                beq.s   getdl6                    ;kein Operand
                move.l  D1,-(SP)
                bsr.s   eaoper                    ;Operand testen
                move.l  (SP)+,D1
                tst.w   D7
                bne     getdl4                    ;KO
                bra.s   getdl6

eaoper:         moveq   #0,D7                     ;Fehlerflag l”schen
                and.w   #$3F,D0                   ;Den Rest weg
                add.w   D0,D0                     ;mal zwei als Index
                lea     da(PC),A2                 ;Suchzeiger auf Tabellenanfang
                adda.w  -2(A2,D0.w),A2
                jmp     (A2)

;>               BASE DC.W,da
da:            DC.W ret-da,add2-da,ret-da,ret-da,ret-da,ret-da,addrel-da
               DC.W ret-da,ret-da,ret-da,ret-da,chea1-da,chea2-da,chea3-da,chea4-da
               DC.W chea5-da,chea6-da,chea7-da,chea8-da,ret-da,ret-da,ret-da,ret-da
               DC.W ret-da,add2-da,add2-da,addim-da,add2-da,add2-da,add2-da,ret-da
               DC.W chea52-da,check_bkpt-da,ret-da,ret-da,ret-da,add2-da

check_bkpt:     cmpi.w  #$4848,-2(A6)             ;bkpt #0 -> breakpt 'String'
                bne     ret
check_bkpt1:    tst.b   (A6)+                     ;String berlesen
                bne.s   check_bkpt1
                move.l  A6,D0
                addq.l  #1,D0                     ;EVEN
                and.b   #$FE,D0
                movea.l D0,A6
                rts

chea1:          move.w  D1,D0
                lsr.w   #3,D0
                and.w   #$38,D0                   ;bits isolieren
                rol.w   #7,D1
                and.w   #7,D1
                or.w    D0,D1
                and.w   #$3F,D1                   ;gültige bits isolieren
                move.w  #$01FD,D2
                bra.s   _chea
chea2:          move.w  #$0FFF,D2
                bra.s   _chea
chea3:          move.w  #$01FF,D2
                bra.s   _chea
chea4:          move.w  #$01FD,D2
                bra.s   _chea
chea5:          move.w  #$0FFD,D2
                bra.s   _chea
chea52:         move.w  #$07FD,D2
                bra.s   _chea
chea6:          move.w  #$01FC,D2
                bra.s   _chea
chea7:          move.w  #$07FF,D2
                bra.s   _chea
chea8:          move.w  #$07E4,D2
_chea:          moveq   #0,D7                     ;Fehlerflag l”schen
                clr.w   D3                        ;Maske l”schen
                move.w  D1,D0
                and.w   #$38,D0
                cmp.w   #$38,D0
                beq.s   _eafnd1                   ;ist eine 111xxx-Art
                lsr.w   #3,D0
                and.w   #7,D0
                bra.s   _eafnd2
_eafnd1:        move.w  D1,D0
                and.w   #7,D0
                cmp.w   #5,D0
                bhs.s   _eafnd3
                addq.w  #7,D0
_eafnd2:        bset    D0,D3
_eafnd3:        and.w   D2,D3                     ;erlaubt-Maske mit Adressierart vergleichen
                beq.s   _chea1
                cmp.w   #1,D3                     ;Dn
                beq.s   ret
                cmp.w   #2,D3                     ;An
                beq.s   ret
                cmp.w   #4,D3                     ;(An)
                beq.s   ret
                cmp.w   #8,D3                     ;(An)+
                beq.s   ret
                cmp.w   #$10,D3                   ;-(An)
                beq.s   ret
                cmp.w   #$20,D3                   ;d(An)
                beq.s   add2
                cmp.w   #$40,D3                   ;d(An,Rx)
                beq.s   add2
                cmp.w   #$80,D3                   ;$xxxx
                beq.s   add2
                cmp.w   #$0100,D3                 ;$xxxxxxxx
                beq.s   add4
                cmp.w   #$0200,D3                 ;d(PC)
                beq.s   add2
                cmp.w   #$0400,D3                 ;d(PC,Rx)
                beq.s   add2
                cmp.w   #$0800,D3                 ;#
                beq.s   addim
_chea1:         moveq   #-1,D7                    ;Fehler aufgetreten
ret:            rts
addim:          addq.l  #2,A6
                tst.w   4(A1)                     ;adressierarten-Wort aus der Tabelle
                bmi.s   addim_1                   ;ist mit einem <ln>-Feld ausgestattet
                move.w  4(A1),D1
                btst    #14,D1                    ;Bit = 0 heižt .B
                beq.s   ret
                btst    #6,D1
                beq.s   ret                       ;ist .W
                bra.s   add2
addim_1:        andi.w  #$C0,D1                   ;<ln>-Feld isolieren
                beq.s   ret
                cmp.w   #$40,D1
                beq.s   ret                       ;ist .W
add2:           addq.l  #2,A6
                rts
addre1:         addq.b  #1,D1                     ;BRA.L ??
                bne.s   ret2                      ;Nein! =>
add4:           addq.l  #4,A6
                rts
addrel:         tst.b   D1                        ;relative Adressdistanz folgt
                bne.s   addre1                    ;evtl. Long-Distanz?
                addq.l  #2,A6                     ;Word-Distanz
ret2:           rts
               ;>ENDPART
********************************************************************************
* Disassembler                                                                 *
********************************************************************************
               ;>PART 'disass'
;>               BASE DC.W,distab
distab:
distab0:       DC.W _andi-distab,$023C,$161A
               DC.W _ori-distab,$3C,$161A
               DC.W _eori-distab,$0A3C,$161A
               DC.W _andi-distab,$027C,$1719
               DC.W _ori-distab,$7C,$1719
               DC.W _eori-distab,$0A7C,$1719
               DC.W _btst-distab,$0800,$2002
               DC.W _bclr-distab,$0880,$0F02
               DC.W _bset-distab,$08C0,$0F02
               DC.W _bchg-distab,$0840,$0F02
               DC.W _addi-distab,$0600,$8F1B
               DC.W _andi-distab,$0200,$8F1B
               DC.W _cmpi-distab,$0C00,$8F1B
               DC.W _eori-distab,$0A00,$8F1B
               DC.W _ori-distab,0,$8F1B
               DC.W _subi-distab,$0400,$8F1B
               DC.W _movep_w-distab,$0108,$0B1C
               DC.W _movep_l-distab,$0148,$0B1C
               DC.W _movep_w-distab,$0188,$1C0B
               DC.W _movep_l-distab,$01C8,$1C0B
               DC.W _btst-distab,$0100,$100B
               DC.W _bclr-distab,$0180,$0F0B
               DC.W _bset-distab,$01C0,$0F0B
               DC.W _bchg-distab,$0140,$0F0B
distab1:       DC.W _move_b-distab,$1000,$0C4D
distab2:       DC.W _movea_l-distab,$2040,$4A4D
               DC.W _move_l-distab,$2000,$4C4D
distab3:       DC.W _movea_w-distab,$3040,$4A0D
               DC.W _move_w-distab,$3000,$4C0D
distab4:       DC.W _bkpt-distab,$4848,$21
               DC.W _illegal-distab,$4AFC,0
               DC.W _nop-distab,$4E71,0
               DC.W _reset-distab,$4E70,0
               DC.W _rte-distab,$4E73,0
               DC.W _rtd-distab,$4E74,$19
               DC.W _rtr-distab,$4E77,0
               DC.W _rts-distab,$4E75,0
               DC.W _trapv-distab,$4E76,0
               DC.W _movec-distab,$4E7A,$2425
               DC.W _movec-distab,$4E7B,$2524
               DC.W _stop-distab,$4E72,$19
               DC.W _ext_w-distab,$4880,9
               DC.W _ext_l-distab,$48C0,9
               DC.W _link-distab,$4E50,$1908
               DC.W _move-distab,$4E60,$1808
               DC.W _move-distab,$4E68,$0818
               DC.W _swap-distab,$4840,9
               DC.W _trap-distab,$4E40,3
               DC.W _unlk-distab,$4E58,8
               DC.W _chk-distab,$4180,$4B10
               DC.W _move-distab,$42C0,$0F16
               DC.W _move-distab,$44C0,$1650
               DC.W _move-distab,$46C0,$5710
               DC.W _jmp-distab,$4EC0,$13
               DC.W _move-distab,$40C0,$0F17
               DC.W _jsr-distab,$4E80,$13
               DC.W _nbcd-distab,$4800,$0F
               DC.W _pea-distab,$4840,$13
               DC.W _lea-distab,$41C0,$0A13
               DC.W _clr-distab,$4200,$800F
               DC.W _neg-distab,$4400,$800F
               DC.W _negx-distab,$4000,$800F
               DC.W _not-distab,$4600,$800F
               DC.W _tas-distab,$4AC0,$0F
               DC.W _tst-distab,$4A00,$800F
               DC.W _extb-distab,$49C0,9
distab5:       DC.W _db-distab,$50C8,$1E89
               DC.W _s-distab,$50C0,$8F
               DC.W _addq-distab,$5000,$8E04
               DC.W _subq-distab,$5100,$8E04
distab6:       DC.W _bra-distab,$6000,7
               DC.W _bsr-distab,$6100,7
               DC.W _b-distab,$6000,$87
distab7:       DC.W _moveq_l-distab,$7000,$0B01
distab8:       DC.W _divu-distab,$80C0,$4B10
               DC.W _divs-distab,$81C0,$4B10
               DC.W _sbcd-distab,$8100,$0B09
               DC.W _sbcd-distab,$8108,$1405
               DC.W _or-distab,$8000,$8B10
               DC.W _or-distab,$8100,$8E0B
distab9:       DC.W _suba_w-distab,$90C0,$4A0D
               DC.W _suba_l-distab,$91C0,$4A4D
               DC.W _subx-distab,$9100,$8B09
               DC.W _subx-distab,$9108,$9405
               DC.W _sub-distab,$9000,$8B0D
               DC.W _sub-distab,$9100,$8E0B
distabA:       DC.W _linea-distab,$A000,$22
distabB:       DC.W _cmpa_w-distab,$B0C0,$4A0D
               DC.W _cmpa_l-distab,$B1C0,$4A4D
               DC.W _cmp-distab,$B000,$8B0D
               DC.W _cmpm-distab,$B108,$9506
               DC.W _eor-distab,$B100,$8F0B
distabC:       DC.W _mulu-distab,$C0C0,$4B10
               DC.W _muls-distab,$C1C0,$4B10
               DC.W _abcd-distab,$C100,$0B09
               DC.W _abcd-distab,$C108,$1405
               DC.W _exg-distab,$C140,$090B
               DC.W _exg-distab,$C148,$080A
               DC.W _exg-distab,$C188,$0B08
               DC.W _and-distab,$C000,$8B10
               DC.W _and-distab,$C100,$8E0B
distabD:       DC.W _adda_w-distab,$D0C0,$4A0D
               DC.W _adda_l-distab,$D1C0,$4A4D
               DC.W _addx-distab,$D100,$8B09
               DC.W _addx-distab,$D108,$9405
               DC.W _add-distab,$D000,$8B0D
               DC.W _add-distab,$D100,$8E0B
distabE:       DC.W _asl_w-distab,$E1C0,$11
               DC.W _asr_w-distab,$E0C0,$11
               DC.W _asl-distab,$E100,$8904
               DC.W _asr-distab,$E000,$8904
               DC.W _asl-distab,$E120,$890B
               DC.W _asr-distab,$E020,$890B
               DC.W _lsl_w-distab,$E3C0,$11
               DC.W _lsr_w-distab,$E2C0,$11
               DC.W _lsl-distab,$E108,$8904
               DC.W _lsr-distab,$E008,$8904
               DC.W _lsl-distab,$E128,$890B
               DC.W _lsr-distab,$E028,$890B
               DC.W _rol_w-distab,$E7C0,$11
               DC.W _ror_w-distab,$E6C0,$11
               DC.W _rol-distab,$E118,$8904
               DC.W _ror-distab,$E018,$8904
               DC.W _rol-distab,$E138,$890B
               DC.W _ror-distab,$E038,$890B
               DC.W _roxl_w-distab,$E5C0,$11
               DC.W _roxr_w-distab,$E4C0,$11
               DC.W _roxl-distab,$E110,$8904
               DC.W _roxr-distab,$E010,$8904
               DC.W _roxl-distab,$E130,$890B
               DC.W _roxr-distab,$E030,$890B
distabF:       DC.W _linef-distab,$F000,$23
disend:

disass:         lea     spaced(A4),A0
                cmpa.l  #anfang,A6
                blo.s   o_disanf
                cmpa.l  A4,A6                     ;Disassemble im Debugger ist verboten!
                bhs.s   o_disanf
                move.b  #'*',(A0)+                ;im Debugger
o_disanf:       move.w  disbase(A4),D2            ;Zahlenbasis für den Disassembler
                st      testwrd(A4)               ;Flagbyte für Ausgabe setzen
                movea.l A6,A5
                bsr     check_read                ;Zugriff erlaubt?
                bne     o_dserr                   ;Abbruch,wenn nicht
                move.b  (A6),D1
                lsr.b   #3,D1
                moveq   #30,D0
                and.w   D1,D0
                lea     distab_tab(PC),A1
                movea.l A1,A3
                adda.w  0(A1,D0.w),A1             ;Tabellenanfang
                adda.w  2(A3,D0.w),A3             ;Tabellenende
                move.w  (A6)+,D1                  ;zu disassemblierender Wert in D1
                bra     o_dis1

;>               BASE DC.W,distab_tab
distab_tab:    DC.W distab0-distab_tab
               DC.W distab1-distab_tab
               DC.W distab2-distab_tab
               DC.W distab3-distab_tab
               DC.W distab4-distab_tab
               DC.W distab5-distab_tab
               DC.W distab6-distab_tab
               DC.W distab7-distab_tab
               DC.W distab8-distab_tab
               DC.W distab9-distab_tab
               DC.W distabA-distab_tab
               DC.W distabB-distab_tab
               DC.W distabC-distab_tab
               DC.W distabD-distab_tab
               DC.W distabE-distab_tab
               DC.W distabF-distab_tab
               DC.W disend-distab_tab

_roxl_w:       DC.B 'ROXL.W',0
_roxr_w:       DC.B 'ROXR.W',0
_ror_w:        DC.B 'ROR.W',0
_rol_w:        DC.B 'ROL.W',0
_lsl_w:        DC.B 'LSL.W',0
_lsr_w:        DC.B 'LSR.W',0
_asl_w:        DC.B 'ASL.W',0
_asr_w:        DC.B 'ASR.W',0
_adda_l:       DC.B 'ADDA.L',0
_adda_w:       DC.B 'ADDA.W',0
_cmpa_w:       DC.B 'CMPA.W',0
_cmpa_l:       DC.B 'CMPA.L',0
_suba_w:       DC.B 'SUBA.W',0
_suba_l:       DC.B 'SUBA.L',0
_moveq_l:      DC.B 'MOVEQ',0
_ext_w:        DC.B 'EXT.W',0
_ext_l:        DC.B 'EXT.L',0
_move_b:       DC.B 'MOVE.B',0
_move_w:       DC.B 'MOVE.W',0
_move_l:       DC.B 'MOVE.L',0
_movea_w:      DC.B 'MOVEA.W',0
_movea_l:      DC.B 'MOVEA.L',0
_movep_w:      DC.B 'MOVEP.W',0
_movep_l:      DC.B 'MOVEP.L',0
_illegal:      DC.B 'ILLEGAL',0
_db:           DC.B 'DB',0
_s:            DC.B 'S',0
_b:            DC.B 'B',0

_add:          DC.B 'ADD',0
_and:          DC.B 'AND',0
_asl:          DC.B 'ASL',0
_asr:          DC.B 'ASR',0
_addq:         DC.B 'ADDQ',0
_addx:         DC.B 'ADDX',0
_abcd:         DC.B 'ABCD',0
_addi:         DC.B 'ADDI',0
_andi:         DC.B 'ANDI',0
_bsr:          DC.B 'BSR',0
_bra:          DC.B 'BRA',0
_btst:         DC.B 'BTST',0
_bclr:         DC.B 'BCLR',0
_bset:         DC.B 'BSET',0
_bchg:         DC.B 'BCHG',0
_cmp:          DC.B 'CMP',0
_clr:          DC.B 'CLR',0
_cmpm:         DC.B 'CMPM',0
_cmpi:         DC.B 'CMPI',0
_chk:          DC.B 'CHK',0
_divu:         DC.B 'DIVU',0
_divs:         DC.B 'DIVS',0
_eor:          DC.B 'EOR',0
_extb:         DC.B 'EXTB',0
_exg:          DC.B 'EXG',0
_eori:         DC.B 'EORI',0
_jmp:          DC.B 'JMP',0
_jsr:          DC.B 'JSR',0
_lea:          DC.B 'LEA',0
_lsr:          DC.B 'LSR',0
_lsl:          DC.B 'LSL',0
_link:         DC.B 'LINK',0
_move:         DC.B 'MOVE',0
_movec:        DC.B 'MOVEC',0
_mulu:         DC.B 'MULU',0
_muls:         DC.B 'MULS',0
_nop:          DC.B 'NOP',0
_neg:          DC.B 'NEG',0
_not:          DC.B 'NOT',0
_negx:         DC.B 'NEGX',0
_nbcd:         DC.B 'NBCD',0
_or:           DC.B 'OR',0
_ori:          DC.B 'ORI',0
_pea:          DC.B 'PEA',0
_rts:          DC.B 'RTS',0
_rtd:          DC.B 'RTD',0
_rol:          DC.B 'ROL',0
_ror:          DC.B 'ROR',0
_roxl:         DC.B 'ROXL',0
_roxr:         DC.B 'ROXR',0
_rte:          DC.B 'RTE',0
_rtr:          DC.B 'RTR',0
_reset:        DC.B 'RESET',0
_sub:          DC.B 'SUB',0
_subq:         DC.B 'SUBQ',0
_swap:         DC.B 'SWAP',0
_subx:         DC.B 'SUBX',0
_subi:         DC.B 'SUBI',0
_sbcd:         DC.B 'SBCD',0
_stop:         DC.B 'STOP',0
_tst:          DC.B 'TST',0
_trap:         DC.B 'TRAP',0
_trapv:        DC.B 'TRAPV',0
_tas:          DC.B 'TAS.B',0
_unlk:         DC.B 'UNLK',0
_bkpt:         DC.B 'BKPT',0
_linea:        DC.B 'LINEA',0
_linef:        DC.B 'LINEF',0
               EVEN
o_msktab:      DC.W $FFFF                         ;00, nichts
               DC.W $FF00                         ;01, unteres Byte=#-Daten (MOVEQ)
               DC.W $FFFF                         ;02, #-Bitnr. im folgenden Wort
               DC.W $FFF0                         ;03, reine #-Zahl für TRAP in Bits 0-3
               DC.W $F1FF                         ;04, data-# für ADDQ etc Bits 9-11
               DC.W $FFF8                         ;05, -(An) Bits 0-2
               DC.W $FFF8                         ;06, (An)+ Bits 0-2
               DC.W $FF00                         ;07, relative Adressdistanz folgt
               DC.W $FFF8                         ;08, An Bits 0-2
               DC.W $FFF8                         ;09, Dn Bits 0-2
               DC.W $F1FF                         ;0A, An Bits 9-11
               DC.W $F1FF                         ;0B, Dn Bits 9-11
               DC.W $F03F                         ;0C, <ea> Bit 6-11
               DC.W $FFC0                         ;0D, alle
               DC.W $FFC0                         ;0E, „nderbar
               DC.W $FFC0                         ;0F, Daten „nderbar
               DC.W $FFC0                         ;10, Daten
               DC.W $FFC0                         ;11, Speicher „nderbar
               DC.W $FFC0                         ;12, alles aužer #
               DC.W $FFC0                         ;13, Kontrolle
               DC.W $F1FF                         ;14, -(An) Bits 9-11
               DC.W $F1FF                         ;15, (An)+ Bits 9-11
               DC.W $FFFF                         ;16, CCR
               DC.W $FFFF                         ;17, SR
               DC.W $FFFF                         ;18, USP
               DC.W $FFFF                         ;19, #-Zahl mit 16 bit folg. Wort (to SR,STOP)
               DC.W $FFFF                         ;1A, #-Zahl mit 8bit folg.Wort (to CCR)
               DC.W $FFFF                         ;1B, #-Wort mit L„nge x folgt
               DC.W $FFF8                         ;1C, d(An) Bits 0-2
               DC.W $F1FF                         ;1D, d(An) Bits 9-11
               DC.W $FFFF                         ;1E, relative Adressdistanz im folgenden Wort (DBRA,..)
               DC.W $F000                         ;1F, # 12-Bit
               DC.W $FFC0                         ;20, Alles aužer # & An (BTST!)
               DC.W $FFF8                         ;21, # 3-Bit (BKPT!)
               DC.W $F000                         ;22, Linea
               DC.W $F000                         ;23, Linef
               DC.W $FFFF                         ;24, Dn oder An     (movec)
               DC.W $FFFF                         ;25, 68010-Register (movec)

o_dis1:         moveq   #$3F,D0                   ;Quelladressierungsart
                and.w   4(A1),D0                  ;Maske für Adressierarten aus Tabelle
                add.w   D0,D0                     ;mal zwei als Index
                move.w  o_msktab(PC,D0.w),D3      ;Maske (Qperator) in D3
                move.w  4(A1),D0                  ;Maske nocheinmal holen
                ror.w   #7,D0                     ;Highbyte zum lowbyte machen
                and.w   #$7E,D0                   ;mal zwei als Index
                and.w   o_msktab(PC,D0.w),D3      ;Operandenmaske einbringen
                move.w  4(A1),D0                  ;Word für Adressierarten
                bpl.s   o_dis10
                and.w   #$FF3F,D3                 ;Operand negativ
o_dis10:        tst.b   D0                        ;Conditionfeld?
                bpl.s   o_dis11
                and.w   #$F0FF,D3                 ;Operator negativ
o_dis11:        and.w   D1,D3                     ;prüfen, ob d1 in die Maske passt
                cmp.w   2(A1),D3                  ;Opcode aus Tabelle gleich?
                beq     o_dis_2                   ;ja, k”nnte das Richtige sein
o_dis8:         addq.l  #6,A1                     ;Zeiger erh”hen
                cmpa.l  A3,A1                     ;Ende erreicht?
                bne.s   o_dis1                    ;nein, weitersuchen

                move.w  D1,D0                     ;Vergleich auf MOVEM
                and.w   #$FB80,D0                 ;maske für MOVEM
                cmp.w   #$4880,D0                 ;Opcode für MOVEM
                bne.s   o_opcde                   ;nein, Opcode nicht gefunden

                lea     o_movem(PC),A2            ;"MOVEM.W"
o_mvm1:         move.b  (A2)+,(A0)+               ;in Buffer
                bne.s   o_mvm1
                subq.l  #1,A0                     ;Schreibzeiger auf die 0
                btst    #6,D1                     ;L„ngenbit testen
                beq.s   o_mvm2
                move.b  #'l',-2(A0)               ;war Langwort
o_mvm2:         btst    #10,D1                    ;Richtung des MOVEM
                bne.s   o_mvm3                    ;Speicher in Register!
                move.w  D1,-(SP)                  ;Opcode merken
                move.w  (A6)+,D1                  ;Registermaske holen
                moveq   #$38,D0
                and.w   (SP),D0                   ;Opcode
                cmp.w   #$20,D0
                beq.s   o_mvm_2                   ;Zieladressierart -(An)
                bsr.s   o_turn
o_mvm_2:        bsr.s   o_msko
                move.w  (SP)+,D1                  ;Opcode zurückholen
                move.b  #',',(A0)+                ;Komma zwischen Quelle und Ziel
                bsr.s   o_mvm4                    ;disassemblieren des Ziels
                tst.w   D7
                bne.s   o_opcde
                bra     o_disok
o_mvm4:         move.w  #$01F4,-(SP)
                bra     o_disea

o_mvm3:         move.w  (A6)+,-(SP)
                move.w  D1,-(SP)
                bsr.s   o_mvm5                    ;disassemblieren der Quelle
                move.b  #',',(A0)+
                move.w  (SP)+,D0
                move.w  (SP)+,D1                  ;Registermaske
                tst.w   D7
                bne.s   o_opcde
                bsr.s   o_turn
                bsr.s   o_msko
                bra     o_disok
o_mvm5:         move.w  #$07EC,-(SP)
                bra     o_disea

o_movem:       DC.B 'movem.w ',0
               EVEN

o_opcde:        move.b  #'d',(A0)+                ;'???'+Chr$(0)
                move.b  #'c',(A0)+
                move.b  #'.',(A0)+
                move.b  #'w',(A0)+
                move.b  #' ',(A0)+
                move.w  (A5),D1
                bsr     o_disa1f
                clr.b   (A0)+
                lea     2(A5),A6
                rts

o_turn:         movem.w D0/D4,-(SP)
                moveq   #15,D0
o_turn1:        add.w   D1,D1
                roxr.w  #1,D4
                dbra    D0,o_turn1
                move.w  D4,D1
                movem.w (SP)+,D0/D4
                rts

o_msko:         moveq   #15,D0
                movem.w D2-D3,-(SP)
                moveq   #0,D3                     ;Kein Register ausgegeben
o_msko2:        tst.w   D1
                beq.s   o_msko1
                bclr    D0,D1
                dbne    D0,o_msko2
                beq.s   o_msko1
                bsr.s   o_rgout
                bmi.s   o_msko1
                tst.w   D1
                beq.s   o_msko1
                btst    D0,D1
                beq.s   o_msko3
                move.b  #'-',(A0)+
o_msko4:        bclr    D0,D1
                dbeq    D0,o_msko4
                addq.w  #1,D0                     ;1 aufaddieren:jetzt ist D0 richtiges Reg
                bsr.s   o_rgout
                bmi.s   o_msko1
                tst.w   D1
                bne.s   o_msko3                   ;ja, es kommen noch andere Register
o_msko1:        movem.w (SP)+,D2-D3
                rts
o_msko3:        move.b  #'/',(A0)+
                bra.s   o_msko2

o_rgout:        add.w   D0,D0
                move.b  o_rgtab(PC,D0.w),D2
                tst.b   D3
                bmi.s   o_rgou2                   ;keine Register"header" mehr ausgeben
                cmp.b   #'D',D2
                beq.s   o_rgou1
                st      D3                        ;Datenregister nun nicht mehr
                bra.s   o_rgou3
o_rgou1:        tst.b   D3
                bne.s   o_rgou2
                moveq   #1,D3                     ;Datenregister ausgegeben
o_rgou3:        move.b  D2,(A0)+
o_rgou2:        move.b  o_rgtab+1(PC,D0.w),(A0)+
                lsr.w   #1,D0
                subq.w  #1,D0
                rts
o_rgtab:       DC.B 'A7A6A5A4A3A2A1A0D7D6D5D4D3D2D1D0'
               EVEN

o_dis_2:        bsr.s   o_dis2
                blo     o_dis8                    ;nein, stimmte nicht
                rts

o_dis2:         move.w  4(A1),D5                  ;D5=Adressierungsarten-Wort
                move.w  (A1),D0                   ;A1=Zeiger in die Mnemonic-Tabelle.
                lea     distab(PC),A2             ;Suchzeiger auf Tabellenanfang
                lea     0(A2,D0.w),A2
                move.l  A0,-(SP)
o_dis3:         move.b  (A2)+,D0                  ;A2=Zeiger aufs Mnemonic-Klartext
                beq.s   o_dis32                   ;fertig
                cmp.b   #'A',D0
                blo.s   o_dis31                   ;SPACE soll nicht gewandelt werden
                cmp.b   #'Z'+1,D0
                bhs.s   o_dis31
                add.b   #$20,D0                   ;in Kleinbuchstaben wandeln
o_dis31:        move.b  D0,(A0)+
                bra.s   o_dis3

o_contb:       DC.B 't f hilscccsneeqvcvsplmigeltgtle'
               EVEN

o_dis32:        movea.l (SP)+,A2                  ;Anfang des Mnemonics
                tst.b   D5                        ;Adressierungsarten-Word
                bpl.s   o_dis4                    ;Bit für Condition nicht gesetzt
                move.w  D1,D0                     ;zu disassemblierendes Datum
                bclr    #7,D5                     ;Bit für Condition jetzt l”schen
                and.w   #$0F00,D0                 ;die 4 Bit Condition isolieren
                lsr.w   #7,D0
                cmp.w   #2,D0
                bne.s   o_disco
                cmpi.b  #'d',-2(A0)
                bne.s   o_disco                   ;df wird zu dbra (wogegen sf nicht sra wird)
                cmpi.b  #'b',-1(A0)
                bne.s   o_disco
                move.b  #'r',(A0)+                ;dbra
                move.b  #'a',(A0)+
                bra.s   o_dis4
o_disco:        move.b  o_contb(PC,D0.w),(A0)+
                move.b  o_contb+1(PC,D0.w),(A0)+
o_dis4:         tst.w   D5                        ;Adressierungsarten-Word
                bpl.s   o_dis5                    ;Bit für L„ngenangabe war gel”scht
                move.b  #'.',(A0)+
                move.b  #'b',(A0)+                ;.B als Vorbesetzung
                move.w  D1,D0                     ;zu disass. Wert
                and.w   #$C0,D0                   ;L„nge isolieren
                beq.s   o_dis7                    ;.B,fertig
                cmp.w   #$C0,D0                   ;beide Bits gesetzt?
                beq.s   o_dserr                   ;ja, Abbruch
                cmp.w   #$40,D0                   ;.W?
                beq.s   o_dis6
                move.b  #'l',-1(A0)
                bra.s   o_dis7
o_dis6:         move.b  #'w',-1(A0)
o_dis7:         bclr    #15,D5
o_dis5:         tst.w   D5
                beq.s   o_disok                   ;Wenn kein Operator/Operand folgt => Ende
                suba.l  A0,A2
                move.l  A2,D0
                addq.l  #7,D0
o_dis55:        move.b  #' ',(A0)+
                dbra    D0,o_dis55
                tst.w   D5
                beq.s   o_disok                   ;fertig disassembliert, keine Parameter
                move.b  D5,D3                     ;in D3 schieben
                movem.l D1-D5/A1-A3,-(SP)
                bsr.s   o_dout
                movem.l (SP)+,D1-D5/A1-A3
                tst.w   D7
                bne.s   o_dserr
                move.w  D5,D3
                lsr.w   #8,D3
                tst.b   D3
                beq.s   o_disok                   ;kein Operand
                movem.l D1/D5,-(SP)
                move.b  #',',(A0)+
                bsr.s   o_dout
                movem.l (SP)+,D1/D5
                tst.w   D7
                bne.s   o_dserr
o_disok:        clr.b   (A0)+                     ;0 als Endezeichen
                move    #0,CCR
                rts
o_dserr:        move    #$FF,CCR                  ;Flags setzen als Zeichen für Fehler
                lea     spaced(A4),A0             ;A0 auf Anfangswert
                lea     2(A5),A6
                rts

o_dout:         clr.w   D7                        ;Fehlerflag l”schen
                moveq   #$3F,D0                   ;evtl. L„ngenflag isolieren
                and.w   D3,D0                     ;zu behandelndes Wort
                add.w   D0,D0                     ;mal zwei als Index
                lea     o_doutt(PC),A2            ;Tabellenanfang
                adda.w  -2(A2,D0.w),A2            ;plus Offsetadr
                jmp     (A2)                      ;und nix wie hin

;>               BASE DC.W,o_doutt
o_doutt:       DC.W o_disa1-o_doutt,o_disa2-o_doutt,o_disa3-o_doutt
               DC.W o_disa4-o_doutt,o_disa5-o_doutt,o_disa6-o_doutt,o_disa7-o_doutt
               DC.W o_disa8-o_doutt,o_disa9-o_doutt,o_disaa-o_doutt,o_disab-o_doutt
               DC.W o_disac-o_doutt,o_disad-o_doutt,o_disae-o_doutt,o_disaf-o_doutt
               DC.W o_disa10-o_doutt,o_disa11-o_doutt,o_disa12-o_doutt,o_disa13-o_doutt
               DC.W o_disa14-o_doutt,o_disa15-o_doutt,o_disa16-o_doutt,o_disa17-o_doutt
               DC.W o_disa18-o_doutt,o_disa19-o_doutt,o_disa1a-o_doutt,o_disa1b-o_doutt
               DC.W o_disa1c-o_doutt,o_disa1d-o_doutt,o_disa1e-o_doutt,o_disa1f-o_doutt
               DC.W o_disa2x-o_doutt,o_disa2y-o_doutt,o_linea-o_doutt,o_linef-o_doutt
               DC.W o_movec1-o_doutt,o_movec2-o_doutt

o_movec1:       move.b  (A6),D1                   ;Daten- bzw. Adrežregister ausgeben (movec)
                lsr.w   #4,D1
                cmpi.b  #',',-1(A0)
                bne.s   o_movc1
                addq.l  #2,A6                     ;wenn Zieladressierung, Word berlesen
o_movc1:        btst    #3,D1
                bne     o_disa8                   ;Adrežregister
                bra     o_disa9                   ;Datenregister
o_movec2:       move.w  (A6),D0
                cmpi.b  #',',-1(A0)
                bne.s   o_movc2
                addq.l  #2,A6                     ;wenn Zieladressierung, Word berlesen
o_movc2:        and.w   #$0FFF,D0
                lea     o_movr1(PC),A2
o_movc3:        tst.w   (A2)+                     ;Ende der Registerliste?
                bmi.s   o_movc4
                cmp.w   -2(A2),D0                 ;Registertyp gefunden?
                beq.s   o_movc4
o_movc5:        tst.b   (A2)+                     ;Registernamen berlesen
                bne.s   o_movc5
                move.l  A2,D1
                addq.l  #1,D1                     ;EVEN
                and.w   #$FFFE,D1
                movea.l D1,A2
                bra.s   o_movc3                   ;zum n„chsten Register
o_movc4:        move.b  (A2)+,(A0)+               ;Registernamen kopieren
                bne.s   o_movc4
                subq.l  #1,A0                     ;Pointer auf das Nullbyte zurück
                rts
o_movr1:       DC.B 0,0,'SFC',0
               EVEN
               DC.B 0,1,'DFC',0
               EVEN
               DC.B 0,2,'CACR',0
               EVEN
               DC.B 8,0,'USP',0
               EVEN
               DC.B 8,1,'VBR',0
               EVEN
               DC.B 8,2,'CAAR',0
               EVEN
               DC.B 8,3,'MSP',0
               EVEN
               DC.B 8,4,'ISP',0
               EVEN
               DC.B -1,-1,'???',0
               EVEN

o_linea:        move.w  D1,D0
                and.w   #$0FF0,D0
                bne.s   o_lina2
                bsr     o_disa3                   ;#3-Bit-Zahl
                lsl.w   #4,D1
                lea     o_lineat(PC,D1.w),A2
                move.b  #' ',(A0)+
                move.b  #';',(A0)+
o_lina3:        moveq   #15,D0
o_lina1:        move.b  (A2)+,(A0)+
                dbra    D0,o_lina1
                rts
o_lina2:        move.b  #'#',(A0)+
                and.l   #$0FFF,D1
                jmp     numout

;>               DXSET 16,' '
o_lineat:      DC.B 'Init            '
               DC.B 'Put pixel       '
               DC.B 'Get pixel       '
               DC.B 'Line            '
               DC.B 'Horizontal line '
               DC.B 'Filled rectangle'
               DC.B 'Filled polygon  '
               DC.B 'Bitblt          '
               DC.B 'Textblt         '
               DC.B 'Show mouse      '
               DC.B 'Hide mouse      '
               DC.B 'Transform mouse '
               DC.B 'Undraw sprite   '
               DC.B 'Draw sprite     '
               DC.B 'Copy raster form'
               DC.B 'Seedfill        '

o_linef:        move.w  D1,D0
                bsr     o_lina2                   ;12-Bit-Zahl ausgeben
                move.w  D1,D0
                move.b  #' ',(A0)+
                move.b  #';',(A0)+
                bclr    #0,D0                     ;RTS?
                bne.s   o_linf1                   ;ja! =>
                move.l  linef_base(A4),D1
                beq.s   o_linf2                   ;unbekannte TOS-Version
                movea.l D1,A2
                move.l  0(A2,D0.w),D1
                move.b  #'j',(A0)+
                move.b  #'s',(A0)+
                move.b  #'r',(A0)+
                move.b  #' ',(A0)+
                lea     _illegal(PC),A2
                cmp.w   max_linef(A4),D0
                bgt     o_lina3                   ;ungültig
                btst    #1,D0
                bne     o_lina3                   ;ungültig
                jmp     numout
o_linf1:        move.b  #'r',(A0)+
                move.b  #'t',(A0)+
                move.b  #'s',(A0)+
                tst.w   D0
                beq.s   o_disa5_2
                move.b  #' ',(A0)+
                lsl.w   #2,D0
                move.w  D0,D1
                bsr     o_turn                    ;und vorher noch einmal spiegeln
                bra     o_msko                    ;Registerliste ausgeben
o_linf2:        subq.l  #2,A0
                clr.b   (A0)+
                rts

o_disa1:        and.l   #$FF,D1
o_disff:        move.b  #'#',(A0)+
                bra     _numout

o_disa2:        moveq   #$3F,D1
                and.w   (A6)+,D1
                bra.s   o_disff

o_disa3:        moveq   #$0F,D0
                and.l   D0,D1
                bra.s   o_disff

o_disa1f:       and.l   #$FFFF,D1
                jmp     hexout                    ;z.B. DC.W $A000

o_disa4:        moveq   #7,D0
                rol.w   D0,D1
                and.l   D0,D1
                bne.s   o_disa1
                moveq   #8,D1
                bra.s   o_disa1

o_disa5:        move.b  #'-',(A0)+
o_disa5_1:      move.b  #'(',(A0)+
                bsr.s   o_disa8
                move.b  #')',(A0)+
o_disa5_2:      rts

o_disa6:        move.b  #'(',(A0)+
                bsr.s   o_disa8
                move.b  #')',(A0)+
                move.b  #'+',(A0)+
                rts

o_disa7:        move.b  #'.',-5(A0)
                move.b  #'w',-4(A0)
                tst.b   D1                        ;relative Adressdistanz folgt
                beq.s   o_disa1e
                cmp.b   #-1,D1
                beq.s   o_dislng
                move.b  #'s',-4(A0)
                ext.w   D1
                ext.l   D1
                add.l   A6,D1
                bra.s   _symbol_numout
o_dislng:       move.b  #'l',-4(A0)
                move.l  (A6),D1
                add.l   A6,D1
                addq.l  #4,A6
                bra.s   _symbol_numout
o_disa1e:       move.w  (A6),D1
                ext.l   D1
                add.l   A6,D1
                addq.l  #2,A6
_symbol_numout: jmp     symbol_numout

o_disa8:        moveq   #7,D0
                and.w   D0,D1
                cmp.w   D0,D1
                bne.s   o_disa8_1
                move.b  #'S',(A0)+
                move.b  #'P',(A0)+
                rts
o_disa8_1:      move.b  #'A',(A0)+
                add.w   #'0',D1
                move.b  D1,(A0)+
                rts

o_disa9:        move.b  #'D',(A0)+
                and.w   #7,D1
                add.w   #'0',D1
                move.b  D1,(A0)+
                rts

o_disaa:        rol.w   #7,D1
                bra.s   o_disa8

o_disab:        rol.w   #7,D1
                bra.s   o_disa9

o_disa14:       rol.w   #7,D1
                bra     o_disa5

o_disa15:       rol.w   #7,D1
                bra     o_disa6

o_disa16:       move.b  #'C',(A0)+
                move.b  #'C',(A0)+
                move.b  #'R',(A0)+
                rts

o_disa17:       move.b  #'S',(A0)+
                move.b  #'R',(A0)+
                rts

o_disa18:       move.b  #'U',(A0)+
                move.b  #'S',(A0)+
                move.b  #'P',(A0)+
                rts

o_disa19:       move.b  #'#',(A0)+
                moveq   #0,D1
                move.w  (A6)+,D1
                bra.s   _numout

o_disa2y:       cmpi.w  #$4848,-2(A6)             ;BKPT #0 ?
                bne.s   o_disa2y1
                subq.l  #8,A0
                move.b  #'B',(A0)+
                move.b  #'R',(A0)+
                move.b  #'E',(A0)+
                move.b  #'A',(A0)+                ;bkpt #0 in BREAKPT „ndern
                move.b  #'K',(A0)+
                move.b  #'P',(A0)+
                move.b  #'T',(A0)+
                move.b  #' ',(A0)+
                move.b  #'''',(A0)+
                moveq   #45,D1                    ;maximal 46 Zeichen bertragen
o_disa2y0:      move.b  (A6)+,(A0)+               ;Kommentar kopieren
                dbeq    D1,o_disa2y0
                beq.s   o_disa2y2                 ;Stringende? Ja! =>
o_disa2y3:      tst.b   (A6)+                     ;sonst bis zum Stringende durchhangeln
                bne.s   o_disa2y3
o_disa2y2:      move.b  #'''',-1(A0)
                move.l  A6,D1
                addq.l  #1,D1
                and.b   #$FE,D1                   ;EVEN
                movea.l D1,A6
                rts                               ;Fertig!
o_disa2y1:      moveq   #7,D0
                and.l   D0,D1
                bra.s   o_disa1aa
o_disa1a:       moveq   #0,D1
                move.w  (A6)+,D1
                and.w   #$FF,D1
o_disa1aa:      move.b  #'#',(A0)+
_numout:        jmp     numout                    ;Zahl ausgeben

o_disa1b:       tst.w   4(A1)                     ;adressierarten-Wort aus der Tabelle
                bmi.s   o_disa1b_1                ;ist mit einem <ln>-Feld ausgestattet
                move.w  4(A1),D1
                btst    #14,D1                    ;Bit = 0 heižt .B
                beq.s   o_disa1a
                btst    #6,D1
                beq     o_disa19                  ;ist .W
                bne.s   o_disa1b_2
o_disa1b_1:     and.w   #$C0,D1                   ;<ln>-Feld isolieren
                beq.s   o_disa1a
                cmp.w   #$40,D1
                beq     o_disa19                  ;ist .W
o_disa1b_2:     move.b  #'#',(A0)+
                move.l  (A6)+,D1                  ;ist .L
                bra     _symbol_numout

o_disa1d:       rol.w   #7,D1
o_disa1c:       move.w  D1,-(SP)
                move.w  (A6)+,D1
                bpl.s   o_disa1c1
                neg.w   D1                        ;signed!
                move.b  #'-',(A0)+
o_disa1c1:      bsr     o_disa1f
                move.w  (SP)+,D1
                move.b  #'(',(A0)+
                bsr     o_disa8
                move.b  #')',(A0)+
                rts

o_disea:        moveq   #0,D7                     ;Fehlerflag l”schen
                clr.w   D3                        ;Maske l”schen
                moveq   #$38,D0
                and.w   D1,D0
                cmp.w   #$38,D0
                beq.s   o_eafn1                   ;ist eine 111xxx-Art
                lsr.w   #3,D0
                bra.s   o_eafn2
o_eafn1:        moveq   #7,D0
                and.w   D1,D0
                cmp.w   #5,D0
                bhs.s   o_eafn3
                addq.w  #7,D0
o_eafn2:        bset    D0,D3
o_eafn3:        and.w   (SP)+,D3                  ;erlaubt-Maske mit Adressierart vergleichen
                beq.s   o_disea1
                cmp.w   #$01,D3                   ;Dn
                beq     o_disa9
                cmp.w   #$02,D3                   ;An
                beq     o_disa8
                cmp.w   #$04,D3                   ;(An)
                beq     o_disa5_1
                cmp.w   #$08,D3                   ;(An)+
                beq     o_disa6
                cmp.w   #$10,D3                   ;-(An)
                beq     o_disa5
                cmp.w   #$20,D3                   ;d(An)
                beq.s   o_disa1c
                cmp.w   #$40,D3                   ;d(An,Rx)
                beq.s   o_disa20
                cmp.w   #$80,D3                   ;$xxxx
                beq.s   o_disa21
                cmp.w   #$0100,D3                 ;$xxxxxxxx
                beq.s   o_disa22
                cmp.w   #$0200,D3                 ;d(PC)
                beq     o_disa23
                cmp.w   #$0400,D3                 ;d(PC,Rx)
                beq     o_disa24
                cmp.w   #$0800,D3                 ;#
                beq     o_disa1b
o_disea1:       st      D7                        ;Fehler aufgetreten
                rts

o_disa20:       move.w  D1,-(SP)                  ;d(An,Rn.x)
                move.w  (A6)+,D1
                move.w  D1,-(SP)
                and.l   #$FF,D1
                tst.b   D1
                bpl.s   o_disa200                 ;signed!
                neg.b   D1
                move.b  #'-',(A0)+
o_disa200:      jsr     numout
                move.w  2(SP),D1                  ;gemerktes D1(opcode) holen
                move.b  #'(',(A0)+
                bsr     o_disa8                   ;An ausgeben
                move.w  (SP)+,D1
                addq.l  #2,SP                     ;Stack normalisieren
                bra     o_disa24_1

o_disa21:       move.w  (A6)+,D1                  ;$xxxx
                ext.l   D1
                bsr.s   sym_numout
                move.b  #'.',(A0)+
                move.b  #'w',(A0)+
                rts

o_disa22:       move.l  (A6)+,D1                  ;$xxxxxxxx
sym_numout:     movem.l D0-D1/A1,-(SP)
                swap    D1
                cmp.w   #$FF,D1
                bne.s   sym_numout0
                ext.w   D1
sym_numout0:    swap    D1
                move.l  sym_buffer(A4),D0         ;Symboltabelle geladen?
                beq.s   sym_numout1               ;Nein! =>
                movea.l D0,A1
                move.w  bugaboo_sym(A4),D0        ;interne Symboltabelle nutzen?
                bne.s   sym_numout1               ;Nein! =>
                move.w  sym_anzahl(A4),D0
                bra.s   sym_numout5
sym_numout3:    cmp.l   (A1),D1                   ;Wert gefunden?
                bne.s   sym_numout4               ;Nein! =>
                addq.l  #8,A1
sym_numout6:    move.b  (A1)+,(A0)+               ;Symbolnamen kopieren
                bne.s   sym_numout6
                subq.l  #1,A0                     ;Zeiger auf das Nullbyte zurück
                movem.l (SP)+,D0-D1/A1
                rts                               ;das war's
sym_numout4:    lea     32(A1),A1                 ;Zeiger auf das n„chste Symbol
sym_numout5:    dbra    D0,sym_numout3            ;schon alle Eintr„ge getestet?
sym_numout1:    movem.l (SP)+,D0-D1/A1
sym_numout2:    bra     _symbol_numout

o_disa23:       move.w  (A6),D1                   ;d(PC)
                ext.l   D1
                add.l   A6,D1
                addq.w  #2,A6
                bsr.s   sym_numout2
                move.b  #'(',(A0)+
                move.b  #'P',(A0)+
                move.b  #'C',(A0)+
                move.b  #')',(A0)+
                rts

o_disa24:       move.w  (A6),D1                   ;d(PC,Rn.x)
                move.w  D1,-(SP)
                ext.w   D1
                ext.l   D1
                add.l   A6,D1
                addq.w  #2,A6
                bsr     _symbol_numout
                move.w  (SP)+,D1                  ;gemerktes D1(opcode) holen
                move.b  #'(',(A0)+
                move.b  #'P',(A0)+
                move.b  #'C',(A0)+
o_disa24_1:     move.b  #',',(A0)+
                move.b  #'D',(A0)+
                tst.w   D1
                bpl.s   o_disa24_2                ;ist Dn
                move.b  #'A',-1(A0)
o_disa24_2:     move.w  D1,D0
                rol.w   #4,D0
                and.w   #7,D0
                add.w   #'0',D0
                move.b  D0,(A0)+
                move.b  #'.',(A0)+
                move.b  #'W',(A0)+
                btst    #11,D1
                beq.s   o_disa24_3
                move.b  #'L',-1(A0)
o_disa24_3:     move.b  #')',(A0)+
                rts
o_disad:        move.w  #$0FFF,-(SP)
                bra     o_disea
o_disae:        move.w  #$01FF,-(SP)
                bra     o_disea
o_disaf:        move.w  #$01FD,-(SP)
                bra     o_disea
o_disa10:       move.w  #$0FFD,-(SP)
                bra     o_disea
o_disa11:       move.w  #$01FC,-(SP)
                bra     o_disea
o_disa12:       move.w  #$07FF,-(SP)
                bra     o_disea
o_disa2x:       move.w  #$07FD,-(SP)              ;Btst #x,n(PC)
                bra     o_disea
o_disa13:       move.w  #$07E4,-(SP)
                bra     o_disea
o_disac:        move.w  D1,D0
                lsr.w   #3,D0
                and.w   #$38,D0                   ;bits isolieren
                rol.w   #7,D1
                and.w   #7,D1
                or.w    D0,D1
                and.w   #$3F,D1                   ;gültige bits isolieren
                move.w  #$01FD,-(SP)
                bra     o_disea
               ;>ENDPART
********************************************************************************
* Ausdruck auswerten                                                           *
********************************************************************************
               ;>PART 'convert_formel'
convert_formel: movea.l #formel,A6
                adda.l  A4,A6
                movea.l #linebuf,A5
                adda.l  A4,A5
                moveq   #0,D7                     ;oberste Stackebene
                bsr     getb
                bsr.s   un_if
                move.w  #$4A80,(A1)+              ;TST.L D0
                move.w  #$4E75,(A1)+              ;und noch ein RTS anh„ngen
                clr.l   (A1)                      ;(weils besser aussieht)
                rts

un_if:          bsr     un_a
un_ifl0:        moveq   #0,D1
un_ifl:         cmp.b   #'=',D0                   ;Die Bedingung holen
                bne.s   un_ifl1
                bset    #1,D1
                bne     synerr
                bsr     getb
                bra.s   un_ifl
un_ifl1:        cmp.b   #'<',D0
                bne.s   un_ifl2
                bset    #2,D1
                bne     synerr
                bsr     getb
                bra.s   un_ifl
un_ifl2:        cmp.b   #'>',D0
                bne.s   un_ifl3
                bset    #3,D1
                bne     synerr
                bsr     getb
                bra.s   un_ifl

un_cond:       DC.W 0,$57C0,$54C0,$52C0,$53C0,$55C0,$56C0,$FFFF
;                       SEQ   SHS   SHI   SLS   SLO   SNE

un_ifl3:        move.w  un_cond(PC,D1.w),D1
                bmi     synerr                    ;<=> angegeben
                beq     un_ifen
                move.w  D1,un_ifl4+2
                bsr     un_opti
                move.b  #10,-(A6)
                move.b  D7,-(A6)
                bsr     un_a
                moveq   #19,D1
                bsr     un_put
                bne.s   un_ifl0

                movea.l -4(A5),A2                 ;Adresse des letzten Befehls
                cmpi.w  #$203C,(A2)               ;MOVE.L #,D0
                bne.s   un_ifl5
                move.l  2(A2),D1
                movea.l A2,A1
                bra.s   un_ifl7
un_ifl5:        cmpi.b  #$70,(A2)+                ;MOVEQ #,D0
                bne     un_ifl6                   ;dann wird eben nicht optimiert...
                move.b  (A2),D1
                ext.w   D1
                ext.l   D1
un_ifl7:        subq.l  #4,A5                     ;und den Befehl verwerfen
                lea     un_ifl4+2(PC),A3
                btst    #1,(A3)
                beq.s   un_if13                   ;BEQ bzw. BNE werden nicht invertiert
                btst    #2,(A3)
                bne.s   un_if12
un_if13:        bchg    #0,(A3)                   ;Condition invertieren
un_if12:        movea.l -4(A5),A2                 ;Adresse des vorletzten Befehls
                movea.l A2,A1
                cmpi.w  #$2F3C,(A2)               ;MOVE.L #,-(SP)
                beq     un_if11
                cmpi.w  #$2F29,(A2)               ;MOVE.L n(A1),-(SP)
                beq     un_ifl9
                cmpi.w  #$2F00,(A2)               ;MOVE.L D0,-(SP)
                bne     int_err                   ;wie konnte der Befehl nur auftreten???
                movea.l -8(A5),A2
                cmpi.w  #$48C0,(A2)               ;EXT.L D0
                bne.s   un_if15                   ;Nein!
                move.w  #$0C40,D2                 ;CMPI.W #,D0
                movea.l A2,A1
                subq.l  #8,A5
                movea.l -4(A5),A2
                cmpi.w  #$4880,(A2)               ;EXT.L D0 verwerfen
                bne.s   un_if16
                move.w  #$0C00,D2                 ;CMPI.B #,D0
                movea.l A2,A1
                subq.l  #4,A5
                andi.w  #$FF,D1                   ;auf Byte verkleinern
                movea.l -4(A5),A2
                cmpi.w  #$1010,(A2)               ;MOVE.B (A0),D0
                bne.s   un_if17
                move.w  #$0C10,D2                 ;CMPI.B #,(A0)
                movea.l A2,A1
                subq.l  #4,A5
un_if17:        move.l  A1,(A5)+
                move.w  D2,(A1)+
                move.w  D1,(A1)+
                bra.s   un_if14
un_if16:        movea.l -4(A5),A2
                cmpi.w  #$3010,(A2)               ;MOVE.W (A0),D0
                bne.s   un_if18
                move.w  #$0C50,D2                 ;CMPI.W #,(A0)
                movea.l A2,A1
                subq.l  #4,A5
un_if18:        move.l  A1,(A5)+
                move.w  D2,(A1)+
                move.w  D1,(A1)+
                bra.s   un_if14
un_if15:        move.w  #$0C80,D2                 ;CMPI.L #,D0
                cmpi.w  #$2010,(A2)               ;MOVE.L (A0),D0
                bne.s   un_if19
                move.w  #$0C90,D2                 ;CMPI.L #,(A0)
                subq.l  #4,A5
                movea.l A2,A1
un_if19:        move.l  A1,-(A5)
                addq.l  #4,A5
                move.w  D2,(A1)+
                move.l  D1,(A1)+
                bra.s   un_if14
un_if11:        move.w  #$203C,(A1)               ;MOVE.L #,D0
                addq.l  #6,A1                     ;Wert beibehalten
                move.l  A1,(A5)+
                move.w  #$0C80,(A1)+              ;CMPI.L #,D0
                move.l  D1,(A1)+
                bra.s   un_if14
un_ifl9:        move.w  #$0CA9,(A1)+              ;CMPI.L #,n(A1)
                move.w  (A1),D2
                move.l  D1,(A1)+
                move.w  D2,(A1)+
                bra.s   un_if14

un_ifl6:        move.l  A1,(A5)+
                move.w  #$B09F,(A1)+              ;CMP.L (SP)+,D0
un_if14:        move.l  A1,(A5)+
un_ifl4:        move.w  #$4E71,(A1)+              ;Scc D0
                move.l  A1,(A5)+
                move.w  #$4880,(A1)+              ;EXT.W D0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                bra     un_ifl0
un_ifen:        rts

un_a:           bsr     un_eausd
un_al:          cmp.b   #'+',D0                   ;Addition
                bne.s   un_a1
                bsr     un_opti
                move.b  #20,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_eausd
                moveq   #29,D1
                bsr     un_put
                bne.s   un_al
                move.w  #$D09F,D2                 ;ADD.L (SP)+,D0
                move.w  #$0680,D3                 ;ADDI.L #,D0
                move.w  #$5080,D4                 ;ADDQ.L #,D0
                moveq   #0,D5
                bsr     un_o_a
                bra.s   un_al
un_a1:          cmp.b   #'-',D0                   ;Subtraktion
                bne.s   un_a2
                bsr     un_opti
                move.b  #21,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_eausd
                moveq   #29,D1
                bsr     un_put
                bne.s   un_al
                move.w  #$909F,D2                 ;SUB.L (SP)+,D0
                move.w  #$0480,D3                 ;SUBI.L #,D0
                move.w  #$5180,D4                 ;SUBQ.L #,D0
                moveq   #0,D5
                bsr     un_o_a
                cmp.w   -2(A1),D2                 ;nicht optimierbar?
                bne.s   un_a10                    ;doch! =>
                move.w  #$4480,(A1)+              ;NEG.L D0
un_a10:         bra.s   un_al
un_a2:          cmp.b   #'|',D0                   ;OR
                bne.s   un_a3
                bsr     un_opti
                move.b  #22,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_eausd
                moveq   #29,D1
                bsr     un_put
                bne     un_al
                move.w  #$809F,D2                 ;OR.L (SP)+,D0
                move.w  #$80,D3                   ;ORI.L #,D0
                moveq   #0,D4
                moveq   #0,D5
                bsr     un_o_a
                bra     un_al
un_a3:          cmp.b   #'^',D0                   ;EOR
                bne.s   un_a4
                bsr     un_opti
                move.b  #23,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_eausd
                moveq   #29,D1
                bsr     un_put
                bne     un_al
                move.l  #$221FB181,D2             ;MOVE.L (SP)+,D1:EOR.L D0,D1
                move.w  #$0A80,D3
                moveq   #0,D4
                moveq   #-1,D5
                bsr     un_o_a
                bra     un_al
un_a4:          cmp.b   #'<',D0                   ;SHL
                bne.s   un_a5
                cmpi.b  #'<',(A0)
                bne.s   un_a5
                bsr     un_opti
                move.b  #24,-(A6)
                move.b  D7,-(A6)
                addq.l  #1,A0
                bsr     getb
                bsr.s   un_eausd
                moveq   #29,D1
                bsr     un_put
                bne     un_al
                move.l  #$221FE1A9,D2             ;MOVE.L (SP)+,D1:LSL.L D0,D1
                move.l  D2,D3
                move.l  #$E188,D4                 ;LSL.L #,D0
                moveq   #1,D5
                bsr     un_o_a
                bra     un_al
un_a5:          cmp.b   #'>',D0                   ;SHR
                bne.s   un_aend
                cmpi.b  #'>',(A0)
                bne.s   un_aend
                bsr     un_opti
                move.b  #25,-(A6)
                move.b  D7,-(A6)
                addq.l  #1,A0
                bsr     getb
                bsr.s   un_eausd
                moveq   #29,D1
                bsr     un_put
                bne     un_al
                move.l  #$221FE0A9,D2             ;MOVE.L (SP)+,D1:LSR.L D0,D1
                move.l  D2,D3
                move.l  #$E088,D4                 ;LSR.L #,D0
                moveq   #1,D5
                bsr     un_o_a
                bra     un_al
un_aend:        rts

un_eausd:       bsr     un_term
un_eal:         cmp.b   #'*',D0                   ;Multiplikation
                bne.s   un_ea1
                bsr     un_opti
                move.b  #30,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_term
                moveq   #39,D1
                bsr     un_put
                bne.s   un_eal
                move.l  A1,(A5)+
                move.w  #$221F,(A1)+              ;MOVE.L (SP)+,D1
                move.l  A1,(A5)+
                move.w  #$C0C1,(A1)+              ;MULU   D1,D0
                bra.s   un_eal
un_ea1:         cmp.b   #'/',D0                   ;Division
                bne.s   un_ea2
                bsr     un_opti
                move.b  #31,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr     un_term
                moveq   #39,D1
                bsr     un_put
                bne.s   un_eal
                move.l  A1,(A5)+
                move.w  #$221F,(A1)+              ;MOVE.L (SP)+,D1
                move.l  A1,(A5)+
                move.w  #$82C0,(A1)+              ;DIVU D0,D1
                move.l  A1,(A5)+
                move.w  #$2001,(A1)+              ;MOVE.L D1,D0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                bra.s   un_eal
un_ea2:         cmp.b   #'&',D0
                bne.s   un_ea3
                bsr     un_opti
                move.b  #32,-(A6)
                move.b  D7,-(A6)
                bsr     getb

                bsr.s   un_term
                moveq   #39,D1
                bsr     un_put
                bne     un_eal
                move.w  #$C09F,D2                 ;AND.L (SP)+,D0
                move.w  #$0280,D3                 ;ANDI.L #,D0
                moveq   #0,D4
                moveq   #0,D5
                bsr     un_o_a
                bra     un_eal
un_ea3:         cmp.b   #'%',D0
                bne.s   un_eaend
                bsr     un_opti
                move.b  #33,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr.s   un_term
                moveq   #39,D1
                bsr     un_put
                bne     un_eal
                move.l  A1,(A5)+
                move.w  #$221F,(A1)+              ;MOVE.L (SP)+,D1
                move.l  A1,(A5)+
                move.w  #$22C0,(A1)+              ;DIVU D0,D1
                move.l  A1,(A5)+
                move.w  #$2001,(A1)+              ;MOVE.L D1,D0
                move.l  A1,(A5)+
                move.w  #$4240,(A1)+              ;CLR.W D0
                move.l  A1,(A5)+
                move.w  #$4840,(A1)+              ;SWAP D0
                bra     un_eal
un_eaend:       rts

un_term:        cmp.b   #'!',D0
                bne.s   un_t1
                move.b  #40,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr.s   un_t1
                moveq   #49,D1
                bsr     un_put
                bne.s   un_t0
                move.l  A1,(A5)+
                move.w  #$57C0,(A1)+              ;SEQ D0
                move.l  A1,(A5)+
                move.w  #$4880,(A1)+              ;EXT.W D0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
un_t0:          rts

un_t1:          cmp.b   #'~',D0
                bne.s   un_ter1
                move.b  #41,-(A6)
                move.b  D7,-(A6)
                bsr     getb
                bsr.s   un_ter1
                moveq   #49,D1
                bsr     un_put
                bne.s   un_ter0
                cmpi.b  #$70,-2(A1)               ;MOVEQ?
                bne.s   un_ter10
                not.b   -1(A1)
                bra.s   un_ter0
un_ter10:       cmpi.w  #$203C,-6(A1)
                bne.s   un_ter11
                not.l   -4(A1)
                bra.s   un_ter0
un_ter11:       move.l  A1,(A5)+
                move.w  #$4680,(A1)+              ;NOT.L D0
un_ter0:        rts

un_ter1:        cmp.b   #'-',D0
                beq.s   un_ter3
                cmp.b   #'+',D0
                bne.s   un_ter2
                bsr     getb                      ;Positives Vorzeichen berlesen
un_ter2:        bsr.s   un_fakt
                rts
un_ter3:        bsr     getb                      ;Negatives Vorzeichen
                move.b  #42,-(A6)
                move.b  D7,-(A6)
                bsr.s   un_fakt
                moveq   #49,D1
                bsr     un_put
                bne.s   un_ter4
                cmpi.b  #$70,-2(A1)               ;MOVEQ?
                bne.s   un_ter30
                neg.b   -1(A1)
                bra.s   un_ter4
un_ter30:       cmpi.w  #$203C,-6(A1)
                bne.s   un_ter31
                neg.l   -4(A1)
                bra.s   un_ter4
un_ter31:       move.l  A1,(A5)+
                move.w  #$4480,(A1)+              ;NEG.L D0
un_ter4:        rts

un_fakt:        cmp.b   #'(',D0
                beq.s   un_fakt1
                cmp.b   #'{',D0
                beq.s   un_fakt3
                bsr     get_pointer               ;ist's ein Pointer auf eine Variable?
                beq.s   un_fakt0                  ;Ende, wenn ja! =>
                jsr     get_zahl                  ;sonst normale Zahl nach D1 holen
                move.l  D1,D2
                ext.w   D2
                ext.l   D2
                cmp.l   D1,D2
                bne.s   un_fakt2
                move.l  A1,(A5)+
                ori.w   #$7000,D1                 ;MOVEQ #Zahl,D0
                move.w  D1,(A1)+
un_fakt0:       rts
un_fakt2:       move.l  A1,(A5)+
                move.w  #$203C,(A1)+              ;MOVE.L #Zahl,D0
                move.l  D1,(A1)+                  ;Die Zahl einsetzen
                rts
un_fakt1:       bsr     getb                      ;Klammer berlesen
                addq.w  #1,D7                     ;Stackebene erh”hen
                bsr     un_if                     ;Ausdruck in der Klammer auswerten
                cmp.b   #')',D0
                bne.s   _misbrak                  ;Klammer zu muž folgen
                subq.w  #1,D7                     ;Eine Stackebene zurück
                bsr     getb
                cmp.b   #'.',D0
                beq.s   un_fak1                   ;Extension vorhanden
un_fak0:        rts
_misbrak:       jmp     misbrak
un_fak1:        bsr     getb
                cmp.b   #'L',D0
                beq.s   un_fak0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                cmp.b   #'W',D0
                beq.s   un_fak0
                move.l  A1,(A5)+
                subq.l  #2,A1
                move.l  #$488048C0,(A1)+          ;EXT.W D0:EXT.L D0
                cmp.b   #'B',D0
                bne     _synerr
                rts

un_fakt3:       bsr     getb
                addq.w  #1,D7
                bsr     un_if
                cmp.b   #'}',D0
                bne.s   _misbrak
                subq.w  #1,D7
                bsr     getb
                movea.l -4(A5),A2                 ;Adresse des letzten Befehls
                move.l  A1,(A5)+
                move.w  #$2040,(A1)+              ;MOVEA.L D0,A0 ist Default

                cmpi.w  #$203C,(A2)               ;MOVE.L #,D0?
                bne.s   un_fakt7
                subq.l  #4,A5                     ;MOVEA.L D0,A0 gleich wieder streichen
                movea.l A2,A1
                move.w  #$41F9,(A1)+              ;LEA Adr.L,A0 einsetzen
                move.w  (A1),D1                   ;oberes Word des Wertes holen
                beq.s   un_fakt9
                addq.b  #1,D1                     ;Short m”glich?
                bne.s   un_fak10
un_fakt9:       move.w  #$41F8,(A2)               ;zu LEA Adr.W,A0
                move.w  2(A1),(A1)+               ;Adresse auf short kürzen
                subq.l  #4,A1
un_fak10:       addq.l  #4,A1                     ;Adresse bleibt drin
                bra.s   un_fakt6

un_fakt7:       cmpi.w  #$2029,(A2)               ;MOVE.L n(A1),D0
                bne.s   un_fakt8
                ori.w   #$40,(A2)                 ;zu MOVEA.L n(A1),A0
                subq.l  #4,A5
                subq.l  #2,A1                     ;MOVEA.L D0,A0 wieder streichen
                bra.s   un_fakt6

un_fakt8:       cmpi.w  #$2010,(A2)               ;MOVE.L (A0),D0
                bne.s   un_fakt6
                ori.w   #$40,(A2)                 ;zu MOVEA.L (A0),A0
                subq.l  #4,A5
                subq.l  #2,A1                     ;MOVEA.L D0,A0 wieder streichen

un_fakt6:       move.l  A1,(A5)+
                move.w  #$3010,(A1)+              ;MOVE.W (A0),D0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                cmp.b   #'.',D0
                bne.s   un_fakt5
                bsr     getb
                cmp.b   #'W',D0
                beq.s   un_fakt4
                move.w  #$1010,-4(A1)             ;MOVE.B (A0),D0
                move.w  #$4880,-2(A1)             ;EXT.W D0
                move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                cmp.b   #'B',D0
                beq.s   un_fakt4
                move.w  #$2010,-6(A1)             ;MOVE.L (A0),D0
                subq.l  #8,A5                     ;EXT.W D0 & EXT.L D0 aus der Liste nehmen
                subq.l  #4,A1
                cmp.b   #'L',D0
                bne.s   synterr
un_fakt4:       bsr     getb
un_fakt5:       rts
synterr:        jmp     synerr

;Stack testen
un_put:         cmp.b   (A6),D7                   ;Stacktiefe gleich?
                bne.s   un_put1                   ;Ende, wenn nicht
                moveq   #0,D2
                move.b  1(A6),D2                  ;Die Operation holen
                cmp.b   D2,D1
                blo.s   un_put1                   ;Der Operation bin ich nicht gewachsen
                addq.l  #2,A6                     ;Stack bereinigen
                move    #4,CCR                    ;Z-Flag setzen
un_put1:        rts

un_opti:        movea.l -4(A5),A2                 ;Adresse des letzten Befehls holen
                cmpi.w  #$203C,(A2)               ;MOVE.L #,D0
                beq.s   un_opt1
                cmpi.w  #$2029,(A2)               ;MOVE.L n(A1),D0
                beq.s   un_opt2
                move.l  A1,(A5)+
                move.w  #$2F00,(A1)+              ;MOVE.L D0,-(SP)
                rts
un_opt1:        move.w  #$2F3C,(A2)               ;zu MOVE.L #,-(SP)
                rts
un_opt2:        move.w  #$2F29,(A2)               ;zu MOVE.L n(A1),-(SP)
                rts

un_o_a:         movea.l -4(A5),A2                 ;Adresse des letzten Befehls
                move.b  1(A2),D1
                ext.w   D1
                ext.l   D1
                cmpi.b  #$70,(A2)                 ;MOVEQ #,D0
                beq.s   un_o_a1
                move.l  2(A2),D1
                cmpi.w  #$203C,(A2)               ;MOVE.L #,D0
                bne.s   un_o_ae                   ;keine Optimierung m”glich
un_o_a1:        movea.l -8(A5),A2
                cmpi.w  #$2F00,(A2)               ;MOVE.L D0,-(SP)?
                bne.s   un_o_ae                   ;keine Optimierung m”glich
                subq.l  #4,A5
                movea.l A2,A1
                tst.l   D1
                bmi.s   un_o_a2                   ;0-8? zu Quick optimieren (0 f„llt weg)
                cmp.l   #9,D1
                blo.s   un_o_a3
un_o_a2:        subq.w  #1,D5
                beq.s   un_o_ag
                move.w  D3,(A1)+                  ;???I.L #,D0 nehmen
                move.l  D1,(A1)+
                rts
un_o_a3:        tst.w   D4                        ;Opcode für Quick vorhanden?
                beq.s   un_o_a2                   ;Nein! ^^^
                tst.l   D1
                beq.s   un_o_a4                   ;Null als Parameter?
                andi.w  #7,D1
                ror.w   #7,D1
                or.w    D1,D4
                move.w  D4,(A1)+                  ;ADDQ/SUBQ schreiben
                rts
un_o_a4:        subq.l  #4,A5                     ;Bei Null als Parameter keinen Opcoden
                movea.l A2,A1                     ;produzieren
                rts

un_o_ae:        tst.l   D5
                bne.s   un_o_af
                move.l  A1,(A5)+                  ;Adresse merken
                move.w  D2,(A1)+                  ;???.L (SP)+,D0 nehmen
                rts
un_o_af:        move.l  A1,(A5)+
                move.l  D2,(A1)+
                rts

un_o_ag:        movea.l -8(A5),A2
                cmpi.b  #$70,(A2)
                beq.s   un_o_ak
                cmpi.w  #$203C,(A2)
                bne.s   un_o_al
un_o_ak:        ori.b   #2,(A2)                   ;statt D0 nun D1
un_o_al:        move.l  A1,(A5)+
                move.l  D1,D2
                ext.w   D2
                ext.l   D2
                cmp.l   D1,D2
                bne.s   un_o_ah
                ori.w   #$7000,D1                 ;MOVEQ #,D1
                move.w  D1,(A1)+
                bra.s   un_o_ai
un_o_ah:        move.w  #$203C,(A1)+              ;MOVE.L #,D1
                move.l  D1,(A1)+
un_o_ai:        move.l  A1,(A5)+
                move.w  D3,(A1)+
                rts
               ;>ENDPART
********************************************************************************
* Ansprung der unteren Routinen in die "get"-Routine                           *
********************************************************************************
getb:           jmp     get

********************************************************************************
* Pointervariable? (Teil von convert_formel)                                   *
********************************************************************************
               ;>PART 'get_pointer'
get_pointer:    movea.l A0,A2                     ;akt.Position retten
                move.w  D0,D2                     ;akt.Zeichen retten
                cmp.b   #'P',D0
                bne.s   get_po1
                bsr.s   getb
                cmp.b   #'C',D0
                bne     get_poe                   ;Ende, da nicht gefunden
                moveq   #64,D1                    ;Offset für PC
                bra     get_pof                   ;gefunden und nun noch Code erzeugen
get_po1:        cmp.b   #'C',D0
                bne.s   get_po2
                bsr.s   getb
                cmp.b   #'C',D0
                bne.s   get_poe
                bsr.s   getb
                cmp.b   #'R',D0
                bne.s   get_poe
                bsr.s   getb
                move.l  A1,(A5)+
                move.l  #$1029004D,(A1)+          ;MOVE.B 77(A1),D0
                move.l  A1,(A5)+
                move.w  #$4880,(A1)+              ;EXT.W D0
get_poh:        move.l  A1,(A5)+
                move.w  #$48C0,(A1)+              ;EXT.L D0
                move    #$FF,CCR                  ;gefunden
                rts
get_po2:        cmp.b   #'U',D0
                bne.s   get_po3
                bsr.s   getb
                cmp.b   #'S',D0
                bne.s   get_poe
                bsr.s   getb
                cmp.b   #'P',D0
                bne.s   get_poe
                moveq   #68,D1                    ;Offset für USP
                bra     get_pof
get_po3:        cmp.b   #'S',D0
                bne.s   get_po6
                bsr.s   getb
                cmp.b   #'P',D0
                beq.s   get_po4
                cmp.b   #'S',D0
                beq.s   get_po5
                cmp.b   #'R',D0
                bne.s   get_poe
                bsr     getb
                move.l  A1,(A5)+
                move.l  #$3029004C,(A1)+          ;MOVE.W 76(A1),D0
                bra.s   get_poh
get_po4:        moveq   #60,D1                    ;Zeiger auf den SP
                bra     get_pof
get_po5:        bsr     getb
                cmp.b   #'P',D0
                bne.s   get_poe
                moveq   #72,D1                    ;Zeiger auf den SSP
                bra.s   get_pof
get_poe:        move.w  D2,D0                     ;Variablen zurücksetzen, da nichts gefunden
                movea.l A2,A0
                move    #0,CCR                    ;nichts gefunden
                rts
get_po6:        moveq   #0,D1                     ;Offset für die Datenregister
                cmp.b   #'^',D0
                bne.s   get_poe
                bsr     getb
                cmp.b   #'D',D0
                beq.s   get_po8
                cmp.b   #'A',D0
                beq.s   get_po7
                cmp.b   #'B',D0
                bne.s   get_poe
                bsr     getb
                cmp.b   #'C',D0
                bne.s   get_poe
                bsr     getb
                moveq   #16,D2
                jsr     chkval
                bhs.s   _synerr
                move.l  A1,(A5)+
                move.w  #$2029,(A1)+              ;MOVE.L n(A1),D0
                mulu    #12,D0
                addi.w  #breakpnt+6-regs,D0
                move.w  D0,(A1)+
                bsr     getb
                move    #$FF,CCR                  ;gefunden
                rts
_synerr:        jmp     synerr
get_po7:        moveq   #32,D1                    ;Offset für die Adrežregister
get_po8:        bsr     getb
                moveq   #8,D2
                jsr     chkval                    ;0-7 holen
                bcc.s   _synerr
                lsl.w   #2,D0                     ;mal 4 (Register sind Langworte)
                add.w   D0,D1
get_pof:        move.l  A1,(A5)+
                move.w  #$2029,(A1)+              ;MOVE.L n(A1),D0
                move.w  D1,(A1)+                  ;Offset einsetzen
                bsr     getb                      ;Folgezeichen holen
                cmp.b   #'.',D0
                beq.s   get_po9                   ;es folgt noch eine Extension
get_pog:        move    #$FF,CCR                  ;gefunden
                rts
get_po9:        bsr     getb                      ;Extension holen
                cmp.b   #'L',D0
                beq.s   get_p11                   ;bei Long nur noch das Folgezeichen holen
                move.w  -(A1),D1
                subq.l  #2,A1
                cmp.b   #'W',D0
                beq.s   get_p10
                cmp.b   #'B',D0
                bne.s   _synerr
                bsr     getb
                move.w  #$7000,(A1)+              ;MOVEQ #0,D0
                move.l  A1,(A5)+
                move.w  #$1029,(A1)+              ;MOVE.B n(A1),D0
                addq.w  #3,D1
                move.w  D1,(A1)+
                bra.s   get_pog
get_p10:        bsr     getb
                move.w  #$7000,(A1)+              ;MOVEQ #0,D0
                move.l  A1,(A5)+
                move.w  #$3029,(A1)+              ;MOVE.W n(A1),D0
                addq.w  #2,D1
                move.w  D1,(A1)+
                bra.s   get_pog
get_p11:        bsr     getb
                bra.s   get_pog
               ;>ENDPART
********************************************************************************
* Fcreate()                                                                    *
********************************************************************************
               ;>PART 'fcreate'
fcreate:        movem.l D0-A7,-(SP)
                jsr     do_mediach                ;Media-Change ausl”sen
                pea     fname(A4)
                move.w  #$41,-(SP)
                bsr     do_trap_1                 ;Fdelete()
                addq.l  #6,SP
                clr.w   -(SP)
                pea     fname(A4)
                move.w  #$3C,-(SP)
                bsr     do_trap_1                 ;Fcreate()
                addq.l  #8,SP
                tst.l   D0
                bmi.s   fread0                    ;Fehler beim ™ffnen
                move.w  D0,_fhdle(A4)             ;Filehandle merken
                movem.l (SP)+,D0-A7
                rts
               ;>ENDPART
********************************************************************************
* Fwrite: A3 Bytes ab A2 schreiben                                             *
********************************************************************************
               ;>PART 'fwrite'
fwrite:         move.l  A3,-(SP)                  ;L„nge zum Endvergleich retten
                move.l  A2,-(SP)                  ;Basisadresse
                move.l  A3,-(SP)                  ;L„nge
                move.w  _fhdle(A4),-(SP)
                move.w  #$40,-(SP)
                bsr.s   do_trap_1                 ;Fwrite()
                lea     12(SP),SP
                cmp.l   (SP)+,D0                  ;alle Bytes geschrieben?
                beq.s   fwrite1                   ;Schreibfehler
                jmp     dskfull
fwrite1:        rts
               ;>ENDPART
********************************************************************************
* Fclose                                                                       *
********************************************************************************
               ;>PART 'fclose'
fclose:         move.w  _fhdle(A4),-(SP)
                move.w  #$3E,-(SP)
                bsr.s   do_trap_1                 ;Fclose()
                addq.l  #4,SP
                tst.l   D0
                bmi.s   fread0
                rts
               ;>ENDPART
********************************************************************************
* Fopen(fname)                                                                 *
********************************************************************************
               ;>PART 'fopen'
fopen:          jsr     do_mediach                ;Media-Change ausl”sen
                clr.w   -(SP)                     ;fopen for read only
                pea     fname(A4)                 ;Anfangsadresse des Namens
                move.w  #$3D,-(SP)
                bsr.s   do_trap_1                 ;Fopen()
                addq.l  #8,SP
                tst.l   D0                        ;alles OK?
                bmi.s   fread0                    ;unable to fopen file
                move.w  D0,_fhdle(A4)             ;Filehandle merken
                rts
               ;>ENDPART
********************************************************************************
* Fread D1 Bytes ab A6                                                         *
********************************************************************************
               ;>PART 'fread'
fread:          move.l  A6,-(SP)                  ;Adresse, wohin gelesen werden soll
                move.l  D1,-(SP)                  ;D1 Bytes einlesen
                move.w  _fhdle(A4),-(SP)          ;Filehandle auf den Stack
                move.w  #$3F,-(SP)
                bsr.s   do_trap_1                 ;Fread()
                lea     12(SP),SP
                tst.l   D0
                bpl.s   fread1
fread0:         jmp     ioerr
fread1:         rts
               ;>ENDPART
********************************************************************************
* Liest ein File (Name ab fname) ab die Adresse A6                             *
* Anzahl nach D6.L                                                             *
********************************************************************************
               ;>PART 'readimg'
readimg:        movea.l A0,A5                     ;derzeitigen CHRGET merken
                bsr.s   fopen                     ;Datei ”ffnen
                move.l  #$01000000,D1             ;Alles einlesen
                bsr.s   fread                     ;Daten lesen
                move.l  D0,D6                     ;Anzahl gelesene Bytes merken
                bsr.s   fclose
                movea.l A5,A0                     ;CHRGET-Pointer wieder herstellen
                rts
               ;>ENDPART
********************************************************************************
* Allgemeiner Gemdos-Einsprung                                                 *
********************************************************************************
               ;>PART 'do_trap_1'
do_trap_1:      move.l  A0,D0
                lea     _regsav(A4),A0
                movem.l D0-D7/A1-A7,(A0)
                move.l  (SP)+,-(A0)               ;Rücksprungadr retten
                andi    #$FB00,SR                 ;IRQs freigeben
                movea.l act_pd(A4),A0
                move.l  merk_act_pd(A4),(A0)      ;Debugger aktiv
                trap    #1
                lea     varbase,A4
                tst.l   basep(A4)                 ;Andere Programm geladen?
                beq.s   do_trap1                  ;Nein
                movea.l act_pd(A4),A0
                move.l  basep(A4),(A0)            ;Sonst das andere Programm aktiv
do_trap1:       movea.l D0,A0
                movem.l _regsav(A4),D0-D7/A1-A7
                exg     A0,D0
                move.l  _regsav2(A4),(SP)
                rts
               ;>ENDPART

********************************************************************************
* Exceptionauswertung                                                          *
********************************************************************************
               ;>PART 'exception'
               DC.L newstart
except_start:
excep_no       SET 2
               OPT O-,W-
               REPT 62
               DC.L 'XBRA'
               DC.L xbra_id
               DS.L 1
                move.l  #excep_no<<24,-(SP)
                bra     except1
excep_no       SET excep_no+1
               ENDR
               OPT O+,W+
               DC.L 'XBRA'
               DC.L xbra_id
old_privileg:  DS.L 1
own_privileg:   movem.l D0-D2,-(SP)
                move.l  A1,-(SP)
                move.l  A0,-(SP)
                movea.l 22(SP),A0
                move.w  (A0),D0
                move.w  D0,D1
                and.w   #$FFC0,D0
                cmp.w   #$40C0,D0
                bne     own_privileg6
                move.l  #$30004E71,$03F2.w
                move.l  #$4E714E75,$03F6.w
                move.w  D1,D0
                and.w   #7,D0
                lsl.w   #8,D0
                lsl.w   #1,D0
                or.w    D0,$03F2.w
                move.w  D1,D0
                and.w   #$38,D0
                lsl.w   #3,D0
                or.w    D0,$03F2.w
                moveq   #2,D2
                cmp.w   #$0180,D0
                beq     own_privileg6
                tst.w   D0
                beq.s   own_privileg4
                cmp.w   #$0140,D0
                beq.s   own_privileg2
                cmp.w   #$01C0,D0
                bne.s   own_privileg3
                and.w   #7,D1
                beq.s   own_privileg1
                addq.w  #2,D2
                move.w  4(A0),$03F6.w
own_privileg1:  addq.w  #2,D2
                move.w  2(A0),$03F4.w
                bra.s   own_privileg5
own_privileg2:  addq.w  #2,D2
                move.w  2(A0),$03F4.w
own_privileg3:  and.w   #7,D1
                cmp.w   #7,D1
                bne.s   own_privileg5
                move    USP,A1
                andi.w  #$F3FF,$03F2.w
                add.l   D2,22(SP)
                move    SR,-(SP)
                ori     #$0700,SR
               DC.B 'Nz',$00,$02
                or.l    #$0808,D0
               DC.B 'N{',$00,$02
                move    (SP)+,SR
                move.w  20(SP),D0
                jsr     $03F2.w
                move    A1,USP
                movea.l (SP)+,A0
                movea.l (SP)+,A1
                movem.l (SP)+,D0-D2
                rte
own_privileg4:  add.l   D2,22(SP)
                ori.w   #$10,$03F2.w
                jsr     clr_cache
                lea     20(SP),A0
                movem.l 8(SP),D0-D2
                jsr     $03F2.w
                movea.l (SP)+,A0
                movea.l (SP)+,A1
                adda.w  #12,SP
                rte
own_privileg5:  add.l   D2,22(SP)
                jsr     clr_cache
                movea.l (SP)+,A0
                movea.l (SP)+,A1
                move.w  12(SP),D0
                jsr     $03F2.w
                movem.l (SP)+,D0-D2
                rte
own_privileg6:  movea.l (SP)+,A0
                movea.l (SP)+,A1
                movem.l (SP)+,D0-D2
own_privileg7:  jmp     $12344321

log_var:       DC.W 0

loginc:         subq.l  #4,SP
login:          illegal                           ;Supervisor-Mode an, aber SR retten!
               DC.L 'MRET'
                moveq   #232,D7                   ;Abbruch durch RTS
                bra.s   login_trace1
login_trace:    illegal                           ;Supervisor-Mode an, aber SR retten
               DC.L 'MRET'
                moveq   #234,D7                   ;Abbruch durch RTS bei Trace RTS
login_trace1:   clr.l   _pc(A4)                   ;PC ist ungültig!
                bra     except_cont_a             ;Format-Word vom Stack holen

except1:        move    #$2700,SR                 ;alle IRQs sperren
                move.l  A4,-(SP)
                lea     varbase(PC),A4
                movem.l D0-A6,regs(A4)            ;alle Register retten
                move.l  (SP)+,regs+48(A4)         ;nun A4 retten
                move.b  (SP),D7                   ;Exception-Number
                addq.l  #4,SP                     ;PC vom BSR.S (s.o.) ist egal
                move.w  (SP)+,_sr(A4)             ;SR holen
                move.l  (SP)+,D0                  ;PC holen
                move.l  D0,_pc(A4)
                move.w  D7,D6
                sub.w   #32,D6                    ;Defaultwert für D6 = Trapnummer
                cmp.b   #4,D7
                bne     except_cont_a             ;Keine 'Illegal Instruktion' (BKPT?)

                movea.l D0,A0
                cmpa.l  #start,A0
                blo.s   except_bkpt               ;innerhalb des Debuggers?
                cmpa.l  #varbase,A0
                bhs.s   except_bkpt
                cmpi.l  #'MRET',2(A0)
                bne     except_cont_a             ;unbekannte Illegal-Operation
                jmp     6(A0)                     ;zurück zum Aufrufer

;Breakpoint in der Liste suchen
except_bkpt:    moveq   #16,D6                    ;17 Breakpoints
                lea     breakpnt(A4),A0
except_bkpt1:   cmp.l   (A0)+,D0                  ;PC=Breakpoint?
                beq.s   except_bkpt2
                addq.l  #8,A0                     ;Typ, Z„hler & (PC) berlesen
                dbra    D6,except_bkpt1
                bra     except_cont_a             ;Illegal Instruction

except_bkpt2:   moveq   #234,D7                   ;'Break'
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift+Control gewünscht
                bne     except_bkpt12
                moveq   #236,D7                   ;Permanenter-Breakpoint als Defaultabbruch
                move.w  (A0)+,D0                  ;Breakpointtyp holen
                subq.w  #1,D0                     ;Flags setzen
                beq     except_bkpt12             ;Permanent
                bcs.s   except_bkpt9              ;Counter
                bpl.s   except_bkpt10             ;User
                subq.l  #1,(A0)+                  ;Z„hler abw„rts
                bls     except_bkpt11             ;<=Null? => Abbruch
except_bkpt3:   movea.l _pc(A4),A1
                move.l  A1,-(SP)
                move.w  _sr(A4),-(SP)
                move.w  #$4E71,D0                 ;NOP
                bset    #7,(SP)                   ;War Trace an? (& Trace an)
                bne.s   except_bkpt4              ;Kein RTE, wenn ja!
                move.w  #$4E73,D0                 ;RTE
except_bkpt4:   move.w  D0,except_bkpt8           ;NOP oder RTE einsetzen
                move.l  A1,except_bkpt7+4         ;PC merken
                move.w  (A0),(A1)                 ;Befehl am PC wieder einsetzen
                move.l  $24.w,except_bkpt6+2      ;Trace-Vektor merken

                move.l  #except_bkpt5,$24.w       ;Eigene Trace-Routine rein
                jsr     clr_cache
                movem.l regs(A4),D0-A6
                rte                               ;einen Befehl ausführen
except_bkpt5:   bclr    #7,(SP)                   ;Trace wieder aus
except_bkpt6:   move.l  #0,$24.w                  ;Alten Trace-Vektor zurück
except_bkpt7:   move.w  #$4AFC,$01234567          ;Breakpoint wieder einsetzen
                jsr     clr_cache
except_bkpt8:   nop                               ;RTE, falls Trace aus war
                move.l  $24.w,-(SP)               ;Trace nochmal aufrufen
                rts
except_bkpt9:   addq.l  #1,(A0)+                  ;Counter der Breakpoints erh”hen
                bra.s   except_bkpt3              ;Weiter geht's
except_bkpt10:  movea.l SP,A6
                movea.l default_stk(A4),SP        ;eigenen Stack setzen
                movem.l A0/A6,-(SP)
                lea     regs(A4),A1               ;šbergabeparameter an User-Breakpoints
                movea.l (A0),A0                   ;Adresse der Checkroutine holen
                jsr     (A0)                      ;Bedingung testen
                movem.l (SP)+,A0/A6
                addq.l  #4,A0
                movea.l A6,SP
                beq     except_bkpt3              ;User-Breakpoint tut nichts
                moveq   #237,D7                   ;User-Breakpoint
                bra.s   except_bkpt12
except_bkpt11:  moveq   #235,D7                   ;Z„hler ausgelaufen
except_bkpt12:  neg.w   D6
                add.w   #16,D6                    ;Breakpointnummer (0-16)
except_cont_a:  tst.b   prozessor(A4)             ;68000?
                bmi.s   except40                  ;ja! =>
                move.w  (SP)+,D0                  ;Vector Offset
                rol.w   #5,D0                     ;*4 *2
                and.w   #$1E,D0                   ;Stacktyp
                move.w  stack_f_tab(PC,D0.w),D0
                jmp     stack_f_tab(PC,D0.w)
;>               BASE DC.W,stack_f_tab
stack_f_tab:   DC.W stack_f_0-stack_f_tab,stack_f_1-stack_f_tab,stack_f_2-stack_f_tab,stack_f_exit-stack_f_tab
               DC.W stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab
               DC.W stack_f_8-stack_f_tab,stack_f_9-stack_f_tab,stack_f_A-stack_f_tab,stack_f_B-stack_f_tab
               DC.W stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab,stack_f_exit-stack_f_tab

stack_f_B:      moveq   #84,D0                    ;Long Bus Cycle Fault Stack Frame (46 Words)
                bra.s   stack_f_A0
stack_f_A:      moveq   #24,D0                    ;Short Bus Cycle Fault Stack Frame (16 Words)
stack_f_A0:     move.w  2(SP),_fcreg(A4)          ;Special Status Word
                move.l  8(SP),_zykadr(A4)         ;Data Cycle Fault Adress
                adda.l  D0,SP
                bra.s   except_cont_b
stack_f_9:
stack_f_8:      addq.l  #8,SP                     ;68010 Buserror-Format (10 Words)
stack_f_2:      addq.l  #4,SP                     ;Instruction Adress berlesen
stack_f_0:
stack_f_1:
stack_f_exit:   bra.s   except_cont_b

except40:       and.w   #$FF,D7
                cmp.b   #4,D7
                bhs.s   except_cont_b             ;Kein Bus- bzw. Adrežfehler
                move.w  _sr(A4),_fcreg(A4)        ;Functioncode-Register umkopieren
                move.l  _pc(A4),_zykadr(A4)       ;Zyklusadresse umkopieren
                move.w  (SP)+,_befreg(A4)         ;Befehlsregister
                move.w  (SP)+,_sr(A4)             ;nun kommt das SR
                move.l  (SP)+,_pc(A4)             ;und es folgt der PC
except_cont_b:  move.l  SP,_ssp(A4)               ;SSP merken
                move    USP,A0
                move.l  A0,_usp(A4)               ;und auch den USP
                bclr    #7,_sr(A4)                ;Trace aus!
                btst    #5,_sr(A4)                ;User-Mode an?
                beq.s   excep50
                movea.l SP,A0                     ;Nein, Supervisormode
excep50:        move.l  A0,rega7(A4)              ;A7 setzen
                move.l  merk_stk(A4),D0           ;Trace until RTS?
                beq.s   excep51                   ;Nein =>
                clr.l   merk_stk(A4)              ;Flag und Adr l”schen
                move.l  D0,_pc(A4)                ;richtige Rücksprungadr setzen
excep51:        movea.l default_stk(A4),SP        ;eigenen Stack wiederherstellen
                bsr     update_pc
                bsr     breakclr                  ;Breakpoints entfernen
                bsr     do_vbl                    ;offene VBL Aufgaben durchführen
                cmp.b   #232,D7
                bne.s   excep510                  ;Abbruch durch RTS?
                move.l  merk_pc_call(A4),_pc(A4)
excep510:       cmpi.l  #cmd_trace9,_pc(A4)       ;Abbruch im Trap bei Untrace?
                bne.s   excep52                   ;Nein! => weiter
                lea     cmd_trace9+2(PC),A0       ;Adresse des PCs
                move.l  (A0),_pc(A4)              ;richtigen PC holen
excep52:        cmp.w   #16,D6                    ;interner Breakpoint?
                beq     excep9g                   ;Ja! => nix dazu ausgeben
                move.w  D7,-(SP)
                bsr     exc_out                   ;Exceptiontext ausgeben
                move.w  (SP)+,D7
                cmp.b   #4,D7                     ;Bus- oder Adrežfehler?
                bhi     excep9g
                beq     excep9x

;Bus- bzw. Adrežfehlerbehandlung
                lea     exc_tx3(PC),A0            ;'schreibend auf '
                btst    #4,_fcreg+1(A4)           ;R/W-Bit prüfen
                beq.s   except6                   ;Schreibzugriff =>
                lea     exc_tx4(PC),A0            ;'lesend von '
except6:        move.l  A0,-(SP)
                jsr     @print_line(A4)
                move.l  _zykadr(A4),D1            ;Zugriffsadresse
                jsr     hexa2out                  ;Adresse ausgeben
                pea     exc_tx2(PC)
                jsr     @print_line(A4)           ;', Funktioncode:'
                moveq   #7,D0
                and.b   _fcreg+1(A4),D0
                or.w    #'0',D0
                jsr     @chrout(A4)               ;Funktionscode ausgeben
                moveq   #'-',D0
                jsr     @chrout(A4)
                moveq   #'B',D0
                btst    #3,_fcreg+1(A4)           ;Bei Befehlsausführung oder Exception?
                beq.s   except7
                moveq   #'E',D0
except7:        jsr     @chrout(A4)               ;entspr.Zeichen ausgeben
                move.l  _pc(A4),D0
                btst    #0,D0                     ;PC ungrade?
                bne.s   except90
                movea.l D0,A6
                tst.b   prozessor(A4)             ;68010 oder 68020?
                bpl.s   except70                  ;ja =>
                lea     -10(A6),A6
                bsr     check_read                ;10 Bytes vorher testen
                bne.s   except90                  ;Nichts zu machen
                lea     10(A6),A6
                bsr     check_read                ;PC lesbar?
                bne.s   except90                  ;Nicht zu machen
                addq.l  #2,A6                     ;PC+2
                move.w  _befreg(A4),D3            ;Befehlsregister holen
                moveq   #9,D1                     ;max.10 Words testen
except8:        cmp.w   -(A6),D3                  ;Befehl gefunden?
                dbeq    D1,except8
                bne.s   except90                  ;Nichts zu machen
except70:       move.l  A6,_pc(A4)                ;PC neu setzen
                move.l  A6,default_adr(A4)
except90:       jsr     @c_eol(A4)                ;Zeilenrest l”schen
                bsr     c_crlr                    ;noch ein CR ausgeben
                bra.s   excep9g
excep9x:        movea.l _pc(A4),A0                ;Illegaler Befehl
                move.w  (A0)+,D0
                cmp.w   #$4AFC,D0
                bne.s   excep9x1
                bsr     in_trace_buff             ;Illegal merken
                addq.l  #2,_pc(A4)                ;PC aus den n„chsten Befehl
                bra.s   excep9x2
excep9x1:       cmp.w   #$4848,D0                 ;BREAKPT "String"?
                bne.s   excep9g
                move.l  A0,input_pnt(A4)          ;Zeiger auf die Zeile merken
                bsr     in_trace_buff             ;Illegal merken
excep9x3:       tst.b   (A0)+
                bne.s   excep9x3                  ;String berlesen
                move.l  A0,D0
                addq.l  #1,D0
                and.b   #$FE,D0                   ;EVEN
                movea.l D0,A0
                move.l  A0,_pc(A4)                ;und neuen PC merken
excep9x2:       st      illegal_flg(A4)           ;Flag dafür merken
excep9g:        move.l  trace_pos(A4),reg_pos(A4) ;ALT-Home ausführen
                cmp.b   #10,D7
                bhs.s   excep9d
                lea     main_loop,A0
                move.l  A0,jmpdispa(A4)           ;Sprungdispatcher auf Hauptschleife
excep9d:        moveq   #0,D0
                move.b  trap_abort(A4),D0         ;Abbruch durch Trap?
                beq.s   excep9e                   ;Nein, kein Abbruch
                lea     traptab(PC),A0
                adda.w  -2(A0,D0.w),A0
                jsr     (A0)                      ;entspr.Unterprogramm aufrufen
                clr.b   trap_abort(A4)
excep9e:        tst.b   dobef_flag(A4)            ;|Befehl ausgeführt?
                beq.s   excep9q
                move.l  data_buff(A4),default_adr(A4) ;Default-Adr zurücksetzen
                move.l  data_buff+4(A4),_pc(A4)   ;PC zurücksetzen
                st      assm_flag(A4)             ;Eingabe mit dem Line-Assembler
                sf      dobef_flag(A4)
                cmp.b   #234,D7                   ;Abbruch durch Breakpoint?
                bhs.s   excep9q                   ;alles ok, wenn ja!
                sf      assm_flag(A4)             ;Eingabe mit dem Line-Assembler abbrechen
excep9q:        movea.l kbshift_adr(A4),A0        ;nur CAPS/LOCK beibehalten

                andi.b  #$10,(A0)
                sf      merk_shift(A4)
                lea     exc_back_tab(PC),A0
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift?
                bne.s   excep9s                   ;=> und Fast-Exit?
excep9r:        move.b  (A0)+,D0
                bmi.s   excep9y                   ;Autorücksprung-Vektor?
                cmp.b   D7,D0
                bne.s   excep9r                   ;gefunden???
excep9s:        btst    #1,help_allow(A4)         ;Bit 1: Auto-Return
                beq.s   excep9y                   ;Auto-Return? Nein =>
                st      fast_exit(A4)             ;Sofort mit CTRL+HELP raus
excep9y:        bclr    #1,help_allow(A4)
                sf      ssc_flag(A4)              ;Abbruch-Flag l”schen
                jmp     (A4)

exc_out:        sf      testwrd(A4)               ;Ausgabe unbedingt auf den Schirm
                tst.w   spalte(A4)
                beq.s   exc_ou0
                jsr     @crout(A4)
exc_ou0:        jsr     @space(A4)
                moveq   #0,D1
                move.b  D7,D1
                jsr     dezout                    ;Vektornummer ausgeben
                jsr     @space(A4)
                moveq   #'-',D0
                jsr     @chrout(A4)
                jsr     @space(A4)
                lea     extxtab(PC),A0
exc_ou1:        move.b  (A0)+,D0
                beq.s   exc_ou6
                cmp.b   #-1,D0
                beq.s   exc_ou3                   ;'Unbekannte Exception #'
                cmp.b   D7,D0
                bne.s   exc_ou1
exc_ou2:        tst.b   (A0)+                     ;Textanfang suchen
                bne.s   exc_ou2
exc_ou3:        move.l  A0,-(SP)
                jsr     @print_line(A4)           ;Fehlermeldung ausgeben
exc_ou5:        tst.b   (A0)+                     ;Ans Stringende
                bne.s   exc_ou5
                cmpi.b  #'#',-2(A0)               ;'#' vor dem Nullbyte?
                bne.s   exc_ou4
                move.w  D6,D1
;                tst.b   D7
;                bmi.s   exc_o50
                and.w   #$0F,D1
;exc_o50:        and.l   #$FF,D1
                jsr     hexout                    ;Sonst D6 noch ausgeben
exc_ou4:        pea     exc_tx1(PC)
                jsr     @print_line(A4)           ;' bei Adresse '
                move.l  _pc(A4),D1
                cmp.l   #do_trace9,D1
                bne.s   exc_o40                   ;do_trace beim Ausführen eines TRAPs?
                movea.l D1,A1
                move.l  2(A1),D1                  ;PC aus dem JMP ziehen
exc_o40:        moveq   #0,D0
                move.b  (A0),D0                   ;PC-Offset holen
                sub.l   D0,D1                     ;PC-Offset abziehen
                addq.l  #1,D1
                and.b   #$FE,D1                   ;PC nun gerade
                move.l  D1,_pc(A4)                ;PC neu setzen
                move.l  D1,default_adr(A4)
                jsr     hexa2out                  ;PC mit '$' ausgeben
                cmp.b   #3,D7
                bls.s   exc_o10
                jsr     @c_eol(A4)                ;Zeilenrest l”schen
                bra     c_crlr                    ;noch ein CR ausgeben
exc_ou6:        tst.b   (A0)+                     ;Text bis zum Nullbyte berlesen
                bne.s   exc_ou6
                addq.l  #1,A0                     ;PC-Offset berlesen
                bra.s   exc_ou1
exc_o10:        rts

exc_back_tab:  DC.B 232,233,$C1,$C2,-1
extxtab:       DC.B 2,0,'Bus Error',0,0
               DC.B 3,0,'Address Error',0,0
               DC.B 4,0,'Illegal Instruction',0,0
               DC.B 5,0,'Zero Divide',0,2
               DC.B 6,0,'CHK, CHK2 Instruction',0,2
               DC.B 7,0,'cpTRAPcc, TRAPcc, TRAPV Instruction',0,2
               DC.B 8,0,'Privilege Violation',0,0
               DC.B 9,0,'Trace',0,0
               DC.B 10,0,'Line 1010 Emulator',0,0
               DC.B 11,0,'Line 1111 Emulator',0,0
               DC.B 12,0,'Exception #12',0,0
               DC.B 13,0,'Coprocessor Protocol Violation',0,0
               DC.B 14,0,'Format Error',0,0
               DC.B 15,0,'Uninitialized Interrupt',0,0
               DC.B 16,0,'Exception #16',0,0
               DC.B 17,0,'Exception #17',0,0
               DC.B 18,0,'Exception #18',0,0
               DC.B 19,0,'Exception #19',0,0
               DC.B 20,0,'Exception #20',0,0
               DC.B 21,0,'Exception #21',0,0
               DC.B 22,0,'Exception #22',0,0
               DC.B 23,0,'Exception #23',0,0
               DC.B 24,0,'Spurious Interrupt',0,0
               DC.B 25,0,'Level 1 Interrupt Auto Vector',0,0
               DC.B 26,0,'Level 2 Interrupt Auto Vector (HBL)',0,0
               DC.B 27,0,'Level 3 Interrupt Auto Vector',0,0
               DC.B 28,0,'Level 4 Interrupt Auto Vector (VBL)',0,0
               DC.B 29,0,'Level 5 Interrupt Auto Vector',0,0
               DC.B 30,0,'Level 6 Interrupt Auto Vector',0,0
               DC.B 31,0,'Level 7 Interrupt Auto Vector',0,0
               DC.B 32,35,36,37,38,39,40,41,42,43,44,47,0,'Trap #',0,2
               DC.B 33,34,45,46,0,'Stopped at Trap #',0,2
               DC.B 48,0,'FPU Unordered Condition',0,0
               DC.B 49,0,'FPU Inexact result',0,0
               DC.B 50,0,'FPU Division by zero',0,0
               DC.B 51,0,'FPU Underflow',0,0
               DC.B 52,0,'FPU Operand Error',0,0
               DC.B 53,0,'FPU Overflow',0,0
               DC.B 54,0,'FPU Not a Number (NAN)',0,0
               DC.B 55,0,'Exception #55',0,0
               DC.B 56,0,'PMMU Configuration',0,0
               DC.B 57,0,'PMMU Illegal Operation',0,0
               DC.B 58,0,'PMMU Access Level',0,0
               DC.B 59,0,'Exception #59',0,0
               DC.B 60,0,'Exception #60',0,0
               DC.B 61,0,'Exception #61',0,0
               DC.B 62,0,'Exception #62',0,0
               DC.B 63,0,'Exception #63',0,0

               DC.B 78,0,'Externer Abruch',0,0

               DC.B $C1,$C2,0,'Programmende bei Trap #',0,2
               DC.B $D2,0,'Illegale Parameter bei Trap #',0,2
               DC.B 230,0,'Abbruch durch [SHIFT][SHIFT]',0,0
               DC.B 231,0,'[CTRL][ALT][HELP] gedrückt',0,0
               DC.B 232,233,0,'Ende durch RTS',0,0
               DC.B 234,0,'Abbruch bei Breakpoint #',0,0
               DC.B 235,0,'Stop-Breakpoint #',0,0
               DC.B 236,0,'Permanent-Breakpoint #',0,0
               DC.B 237,0,'User-Breakpoint #',0,0
               DC.B -1,'Unknown Exception #',0

exc_tx1:       DC.B ' at Address ',0
exc_tx2:       DC.B ', FC:',0
exc_tx3:       DC.B ' writing at ',0
exc_tx4:       DC.B ' reading from ',0
               EVEN
               ;>ENDPART
********************************************************************************
* PC aus dem Debugger raus setzen                                              *
********************************************************************************
               ;>PART 'update_pc'
update_pc:      move.l  A0,-(SP)
                movea.l _pc(A4),A0                ;akt. PC holen
                cmpa.l  #new_gemdos,A0
                bne.s   update_pc1
                movea.l old_gemdos(PC),A0         ;raus aus der GEMDOS-Routine
update_pc1:     cmpa.l  #new_bios,A0
                bne.s   update_pc2
                movea.l old_bios(PC),A0           ;raus aus der BIOS-Routine
update_pc2:     cmpa.l  #new_xbios,A0
                bne.s   update_pc3
                movea.l old_xbios(PC),A0          ;raus aus der XBIOS-Routine
update_pc3:     cmpa.l  #new_aesvdi,A0
                bne.s   update_pc4
                movea.l old_aesvdi(PC),A0         ;raus aus der AES-Routine
update_pc4:     cmpa.l  #login,A0
                bne.s   update_pc6
                movea.l merk_pc_call(A4),A0
update_pc6:     cmpa.l  _pc(A4),A0
                beq.s   update_pc5
                move.l  A0,_pc(A4)                ;evtl.korrigierten PC setzen
                movea.l rega7(A4),A0
                andi.w  #$7FFF,(A0)               ;Trace aus
update_pc5:     movea.l (SP)+,A0
                rts
               ;>ENDPART
********************************************************************************
* Der Gemdos-Handler                                                           *
********************************************************************************
               ;>PART 'new_gemdos'
               DC.L 'XBRA'
               DC.L xbra_id
old_gemdos:    DS.L 1
new_gemdos:     movem.l D0-A6,save_all_reg
                lea     varbase(PC),A4
                move.l  A0,merk_a0(A4)            ;Für Break bei "Lineinput"
                lea     6(SP),A0                  ;gibt auf SVSP den Platz der Funktionsnummer
                tst.b   prozessor(A4)             ;68000?
                bmi.s   new_gemdos1               ;ja! =>
                addq.l  #2,A0                     ;68010 oder 68020 hat ein Wort mehr
new_gemdos1:    btst    #5,(SP)                   ;Aufruf aus U-Mode?
                bne.s   new_gemdos2               ;nein,S-Mode
                move    USP,A0
new_gemdos2:    move.w  (A0),D0                   ;Funktionsnummer holen
                bmi.s   new_gemdos5               ;Negativ? => sofort weiter
                cmp.w   #$7E,D0                   ;max.Funktionsnummer berschritten?
                bhi.s   new_gemdos5               ;=> sofort weiter
                lea     gemdos_break(A4),A1
                lea     0(A1,D0.w),A2
                tst.b   (A2)                      ;Abbruch-Flag für die Funktion gesetzt?
                bmi.s   new_gemdos6               ;Ja! => Abbruch
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift+Control gewünscht?
                bne     new_gemdos8
                move.l  save_data+$0408-8(A4),$0408.w ;etv_term auf normal
                movea.l act_pd(A4),A0             ;aktives Programm
                move.l  (A0),D2
                cmp.l   merk_act_pd(A4),D2        ;Kein Programm geladen?
                beq.s   new_gemdos3
                move.l  basep(A4),D1              ;Basepage des direkten nachgeladenes Prg
                cmp.l   D2,D1                     ;Ist das eigene Child nicht aktiv?
                bne.s   new_gemdos4               ;dann Sicherheitsabfragen berspringen
new_gemdos3:    move.l  #etv_term,$0408.w         ;Eigenen etv_term-Handler
                tst.w   D0                        ;Pterm0
                beq.s   new_gemdos7
                cmp.w   #$31,D0                   ;Ptermres stets abbrechen (beim eigene Child)
                beq.s   new_gemdos7
                cmp.w   #$4C,D0                   ;Pterm
                beq.s   new_gemdos7
new_gemdos4:    tst.b   (A2)
                sne     (A2)                      ;Break-Flag zurücksetzen
new_gemdos5:    movem.l save_all_reg(PC),D0-A6
                move.l  old_gemdos(PC),-(SP)
                rts                               ;Normalen Trap #1 ausführen

new_gemdos6:    move.l  2(SP),D1                  ;den PC holen
                subq.l  #2,D1                     ;PC auf den Trap zurück
                cmp.l   first_free(A4),D1         ;Kleiner als der Speicheranfang?
                blo.s   new_gemdos4               ;=> sofort weitermachen
                cmp.l   save_data+$0436-8(A4),D1  ;Oberhalb des RAMs?
                bhs.s   new_gemdos4               ;=> sofort weitermachen
                lea     0(A1,D0.w),A2
                move.b  #1,(A2)                   ;BREAK setzen
                move.b  #2,trap_abort(A4)         ;Abbruch durch GEMDOS
                movem.l save_all_reg(PC),D0-A6
                move.l  #$21<<24,-(SP)
                pea     except1(PC)
                rts
new_gemdos7:    move.b  #2,trap_abort(A4)         ;Abbruch durch GEMDOS
                movem.l save_all_reg(PC),D0-A6
                move.l  #$C1<<24,-(SP)
                pea     except1(PC)
                rts                               ;Programmende
new_gemdos8:    move.l  2(SP),D1                  ;den PC holen
                subq.l  #2,D1                     ;PC auf den Trap zurück
                movea.l act_pd(A4),A2
                cmp.l   (A2),D1                   ;Kleiner als der Debugger?
                blo.s   new_gemdos4               ;=> sofort weitermachen
                cmp.l   save_data+$0436-8(A4),D1  ;Oberhalb des RAMs?
                bhs.s   new_gemdos4               ;=> sofort weitermachen
                move.b  #2,trap_abort(A4)         ;Abbruch durch GEMDOS
                movem.l save_all_reg(PC),D0-A6
                move.l  #$21<<24,-(SP)
                pea     except1(PC)
                rts
               ;>ENDPART
********************************************************************************
* Der XBIOS-Handler                                                            *
********************************************************************************
               ;>PART 'new_xbios'
               DC.L 'XBRA'
               DC.L xbra_id
old_xbios:     DS.L 1
new_xbios:      movem.l D0-A6,save_all_reg
                lea     varbase(PC),A4
                lea     6(SP),A0                  ;gibt auf SVSP den Platz der Funktionsnummer
                tst.b   prozessor(A4)             ;68000?
                bmi.s   new_xbios1                ;ja! =>
                addq.l  #2,A0                     ;68010 oder 68020 hat ein Wort mehr
new_xbios1:     btst    #5,(SP)                   ;Aufruf aus U-Mode?
                bne.s   new_xbios2                ;nein,S-Mode
                move    USP,A0
new_xbios2:     move.w  (A0),D0                   ;Funktionsnummer holen
                bmi.s   new_xbios4                ;Negativ? => sofort weiter
                cmp.w   #$57,D0                   ;max.Funktionsnummer berschritten?
                bhi.s   new_xbios4                ;=> sofort weiter
                lea     xbios_break(A4),A0
                lea     0(A0,D0.w),A0
                tst.b   (A0)                      ;Abbruch-Flag für die Funktion gesetzt?
                bmi.s   new_xbios6                ;Ja! => Abbruch
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift+Control gewünscht?
                bne.s   new_xbios5
new_xbios3:     tst.b   (A0)
                sne     (A0)                      ;Break-Flag zurücksetzen
new_xbios4:     movem.l save_all_reg(PC),D0-A6
                move.l  old_xbios(PC),-(SP)
                rts                               ;Normalen Trap #14 ausführen

new_xbios5:     lea     spaced2(A4),A0            ;Dummy
new_xbios6:     move.l  2(SP),D1                  ;den PC holen
                subq.l  #2,D1                     ;PC auf den Trap zurück
                cmp.l   first_free(A4),D1         ;Kleiner als der Speicheranfang?
                blo.s   new_xbios3                ;=> sofort weitermachen
                cmp.l   rom_base(A4),D1           ;Das Betriebssystem?
                bhs.s   new_xbios3                ;=> sofort weitermachen
                move.b  #1,(A0)                   ;auf BREAK setzen
                move.b  #6,trap_abort(A4)         ;Abbruch durch XBIOS
                bsr.s   do_vbl                    ;offene VBL Aufgaben durchführen
                movem.l save_all_reg(PC),D0-A6
                move.l  #$2E<<24,-(SP)
                pea     except1(PC)
                rts
               ;>ENDPART
********************************************************************************
* Offene VBL-Aufgaben durchführen                                              *
********************************************************************************
               ;>PART 'do_vbl'
do_vbl:         movem.l D0/A0-A1,-(SP)
                tst.l   $045A.w                   ;neue Farbpalette?
                beq.s   do_vbl2
                movea.l $045A.w,A0
                lea     $FFFF8240.w,A1
                moveq   #7,D0
do_vbl1:        move.l  (A0)+,(A1)+
                dbra    D0,do_vbl1
                clr.l   $045A.w
do_vbl2:        tst.l   $045E.w                   ;neue Bildschirmadresse
                beq.s   do_vbl3
                move.l  $045E.w,D0
                move.l  D0,$044E.w
                lsr.l   #8,D0
                move.b  D0,$FFFF8203.w
                lsr.w   #8,D0
                move.b  D0,$FFFF8201.w
do_vbl3:        movem.l (SP)+,D0/A0-A1
                rts
               ;>ENDPART
********************************************************************************
* Der Bios-Handler                                                             *
********************************************************************************
               ;>PART 'new_bios'
               DC.L 'XBRA'
               DC.L xbra_id
old_bios:      DS.L 1
new_bios:       movem.l D0-A6,save_all_reg
                lea     varbase(PC),A4
                lea     6(SP),A0                  ;gibt auf SVSP den Platz der Funktionsnummer
                tst.b   prozessor(A4)             ;68000?
                bmi.s   new_bios1                 ;ja! =>
                addq.l  #2,A0                     ;68010 oder 68020 hat ein Wort mehr
new_bios1:      btst    #5,(SP)                   ;Aufruf aus U-Mode?
                bne.s   new_bios2                 ;nein,S-Mode
                move    USP,A0
new_bios2:      move.w  (A0),D0                   ;Funktionsnummer holen
                bmi.s   new_bios4                 ;Negativ? => sofort weiter
                cmp.w   #$0B,D0                   ;max.Funktionsnummer berschritten?
                bhi.s   new_bios4                 ;=> sofort weiter
                lea     bios_break(A4),A0
                lea     0(A0,D0.w),A0
                tst.b   (A0)                      ;Abbruch-Flag für die Funktion gesetzt?
                bmi.s   new_bios6                 ;Ja! => Abbruch
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift+Control gewünscht?
                bne.s   new_bios5
new_bios3:      tst.b   (A0)
                sne     (A0)                      ;Break-Flag zurücksetzen
new_bios4:      movem.l save_all_reg(PC),D0-A6
                move.l  old_bios(PC),-(SP)
                rts                               ;Normalen Trap #13 ausführen

new_bios5:      lea     spaced2(A4),A0            ;Dummy
new_bios6:      move.l  2(SP),D1                  ;den PC holen
                subq.l  #2,D1                     ;PC auf den Trap zurück
                cmp.l   first_free(A4),D1         ;Kleiner als der Speicheranfang?
                blo.s   new_bios3                 ;=> sofort weitermachen
                cmp.l   rom_base(A4),D1           ;Das Betriebssystem?
                bhs.s   new_bios3                 ;=> sofort weitermachen
                move.b  #1,(A0)                   ;BREAK setzen
                move.b  #4,trap_abort(A4)         ;Abbruch durch BIOS
                movem.l save_all_reg(PC),D0-A6
                move.l  #$2D<<24,-(SP)
                pea     except1(PC)
                rts
               ;>ENDPART
********************************************************************************
* TRAP #2-Einsprung                                                            *
********************************************************************************
               ;>PART 'new_aesvdi'
save_all_reg:  DS.L 15

               DC.L 'XBRA'
               DC.L xbra_id
old_aesvdi:    DS.L 1
new_aesvdi:     movem.l D0-A6,save_all_reg
                movea.l SP,A6
                lea     varbase(PC),A4
                movea.l default_stk(A4),SP        ;eigenen Stack wiederherstellen
                move.l  2(A6),D7                  ;den PC holen
                subq.l  #2,D7                     ;PC auf den Trap zurück
                cmp.l   first_free(A4),D7         ;Kleiner als der Speicheranfang?
                blo     new_aesvdi9               ;=> sofort weitermachen
                cmp.l   rom_base(A4),D7           ;Das Betriebssystem?
                bhs     new_aesvdi9               ;=> sofort weitermachen
                tst.w   D0                        ;Programmende?
                beq     new_aesvdi10
                cmp.w   #-2,D0                    ;GDOS-Test?
                beq     new_aesvdi9               ;sofort ausführen
                cmp.w   #-1,D0                    ;Ihrgendein Test für GEM 2.2
                beq     new_aesvdi9               ;sofort ausführen
                bsr     check_d1                  ;Adresse für den User-Mode gültig?
                movea.l D1,A0                     ;Parameter-Block-Adresse
                movea.l (A0),A1                   ;control-Feld-Adresse holen
                cmp.w   #115,D0                   ;VDI
                beq.s   new_aesvdi1
                cmp.w   #200,D0                   ;AES
                beq.s   new_aesvdi5
                cmp.w   #201,D0                   ;AES
                beq.s   new_aesvdi5
                bra     new_aesvdi13              ;Müll
new_aesvdi1:    moveq   #4,D2                     ;VDI-Parameter-Block gültig?
                moveq   #0,D0
new_aesvdi2:    move.l  0(A0,D0.w),D1
                beq.s   new_aesvdi4
                bsr     check_d1                  ;Adresse für den User-Mode gültig?
new_aesvdi3:    addq.l  #4,D0
                dbra    D2,new_aesvdi2
                move.w  (A1),D2                   ;Opcode holen
                cmp.w   #132,D2
                bhi     new_aesvdi13
                lea     vdi_break(A4),A0
                bra.s   new_aesvdi8
new_aesvdi4:    cmp.w   #2,D2
                beq.s   new_aesvdi3
                bra     new_aesvdi13

new_aesvdi5:    moveq   #5,D2                     ;AES-Parameter-Block gültig?
                moveq   #0,D0
new_aesvdi6:    move.l  0(A0,D0.w),D1
                bsr     check_d1                  ;Adresse für den User-Mode gültig?
                addq.l  #4,D0
                dbra    D2,new_aesvdi6
                move.w  (A1),D2                   ;Opcode holen
                cmp.w   #131,D2
                bhi.s   new_aesvdi13
                lea     aes_all(PC),A0

new_aesvdi7:    move.b  (A0)+,D0                  ;gibt's die Funktion berhaupt?
                beq.s   new_aesvdi13
                cmp.b   D0,D2
                bne.s   new_aesvdi7
                lea     aes_break(A4),A0
new_aesvdi8:    tst.w   D2
                bmi.s   new_aesvdi13
                lea     0(A0,D2.w),A0
                tst.b   (A0)
                bmi.s   new_aesvdi14              ;Abbruch!
                tst.b   ssc_flag(A4)              ;Abbruch mit Shift+Shift+Control gewünscht?
                bne.s   new_aesvdi15
                tst.b   (A0)
                sne     (A0)                      ;Break-Flag zurücksetzen
new_aesvdi9:    movea.l A6,SP
                movem.l save_all_reg(PC),D0-A6
                move.l  old_aesvdi(PC),-(SP)
                rts

new_aesvdi10:   lea     gemdos_break+$4C(A4),A0
                tst.b   (A0)
                bpl.s   new_aesvdi11
                move.b  #1,(A0)                   ;BREAK setzen, wenn gewünscht
new_aesvdi11:   move.l  save_data+$0408-8(A4),$0408.w ;etv_term auf normal
                movea.l act_pd(A4),A0             ;aktives Programm
                move.l  (A0),D0
                cmp.l   merk_act_pd(A4),D0        ;Kein Programm geladen?
                beq.s   new_aesvdi12
                move.l  basep(A4),D7              ;Basepage des direkten nachgeladenes Prg
                cmp.l   D0,D7                     ;Ist das eigene Child nicht aktiv?
                bne.s   new_aesvdi9               ;dann ausführen berspringen
new_aesvdi12:   move.l  #etv_term,$0408.w         ;Eigenen etv_term-Handler
                clr.b   trap_abort(A4)            ;Abbruch durch AES/VDI
                movea.l A6,SP
                movem.l save_all_reg(PC),D0-A6
                move.l  #$C2<<24,-(SP)
                pea     except1(PC)
                rts                               ;Programmende bei Trap #2

new_aesvdi13:   tst.w   no_aes_check(A4)
                bne.s   new_aesvdi9
                clr.b   trap_abort(A4)            ;KEIN Abbruch durch AES/VDI
                movea.l A6,SP
                movem.l save_all_reg(PC),D0-A6
                move.l  #$D2<<24,-(SP)
                pea     except1(PC)
                rts                               ;Illegale Parameter bei Trap #2

new_aesvdi14:   move.b  #1,(A0)                   ;BREAK setzen
new_aesvdi15:   move.b  #8,trap_abort(A4)         ;Abbruch durch AES/VDI
                movea.l A6,SP
                movem.l save_all_reg(PC),D0-A6
                move.l  #$22<<24,-(SP)
                pea     except1(PC)
                rts

check_d1:       cmp.l   #$0800,D1                 ;Adresse zu klein?
                blo.s   check_d
                cmp.l   save_data+$0436-8(A4),D1  ;Adresse zu grož?
                bhs.s   check_d
                rts
check_d:        addq.l  #4,SP
                bra.s   new_aesvdi13
               ;>ENDPART
********************************************************************************
* Die Funktionen des Betriebssystems                                           *
********************************************************************************
               ;>PART 'do_(x)bios/gemdos/vdi/aes'
;>               BASE DC.W,traptab
traptab:       DC.W do_gemdos-traptab                     ;2
               DC.W do_bios-traptab                       ;4
               DC.W do_xbios-traptab                      ;6
               DC.W do_vdiaes-traptab                     ;8

do_bios:        lea     do_get4+1(PC),A0          ;(X)BIOS
                lea     bios_befs(PC),A1          ;Tabelle des Befehlsnamen
                bra.s   do_gem
do_xbios:       lea     do_get4(PC),A0            ;XBIOS
                lea     xbios_befs(PC),A1         ;Tabelle des Befehlsnamen
                bra.s   do_gem
do_gemdos:      lea     do_get1(PC),A0
                lea     gemdos_befs(PC),A1        ;Tabelle des Befehlsnamen
do_gem:         jsr     @space(A4)
                move.l  A0,-(SP)
                jsr     @print_line(A4)
                pea     do_get3(PC)
                jsr     @print_line(A4)
                movea.l rega7(A4),A0              ;Zeiger auf die Parameter
                move.w  (A0)+,D1                  ;Die Funktionsnummer
                jsr     hexbout                   ;Die Nummer ausgeben
                jsr     @space(A4)
                bsr     gleich_out                ;' = ' ausgeben
                jsr     @space(A4)
                move.w  D1,D0
                lsr.w   #8,D0                     ;Oberes Byte der Funktionsnummer <> 0?
                tst.b   D0
                bne     do_gemi                   ;dann Fehler =>
do_gem1:        move.b  (A1)+,D0
                bmi     do_gemi                   ;Tabellenende => nicht gefunden
                cmp.b   D0,D1
                beq.s   do_gem3                   ;Funktion gefunden =>
                move.b  (A1)+,D0                  ;Stackformat berlesen
                rol.b   #2,D0
                andi.b  #3,D0
                beq.s   do_gem2
                addq.l  #1,A1
do_gem2:        tst.b   (A1)+
                bne.s   do_gem2                   ;Funktionsnamen berlesen
                bra.s   do_gem1                   ;Weiter suchen
do_gem3:        moveq   #1,D2
                swap    D2                        ;9.Parameter für Flopfmt()=move.l #$10000,d2
                move.b  (A1)+,D2                  ;Stackformat holen
                move.b  D2,D0
                rol.b   #2,D0
                and.b   #3,D0
                beq.s   do_gem8
                move.b  (A1)+,D0                  ;extended Parameter
                lsl.w   #8,D0
                or.w    D0,D2
do_gem8:        move.l  A1,-(SP)
                jsr     @print_line(A4)           ;den Funktionsnamen ausgeben
                moveq   #'(',D0
                jsr     @chrout(A4)
                moveq   #0,D4                     ;noch kein Komma ausgeben
do_gem4:        move.l  D2,D3
                and.w   #3,D3
                beq     do_gemx                   ;Keine weiteren Parameter
                tst.b   D4
                beq.s   do_gem9
                moveq   #',',D0
                jsr     @chrout(A4)               ;Komma ausgeben
do_gem9:        btst    #1,D3
                bne.s   do_gem5
                moveq   #0,D1
                move.w  (A0)+,D1                  ;Word vom Stack holen
                cmp.w   #$FFFF,D1
                bne.s   do_ge90
                moveq   #-1,D1
do_ge90:        moveq   #'w',D0
                bra.s   do_gem6
do_gem5:        move.l  (A0)+,D1                  ;Long vom Stack holen
                moveq   #'l',D0                   ;für Long
do_gem6:        move.b  D0,-(SP)                  ;Extension merken
                jsr     @chrout(A4)               ;Extension ausgeben
                moveq   #':',D0
                jsr     @chrout(A4)
                addq.l  #1,D1                     ;-1?
                bne.s   do_gem7
                moveq   #'-',D0
                jsr     @chrout(A4)               ;Vorzeichen ausgeben
                moveq   #2,D1                     ;1 ausgeben (mit "-" davor, also -1)
do_gem7:        subq.l  #1,D1
                jsr     hexout                    ;Hexzahl ausgeben
                move.b  (SP)+,D0
                cmp.b   #'l',D0                   ;ein Long ausgegeben?
                bne.s   do_gem71                  ;Nein! =>
                tst.l   D1
                ble.s   do_gem71                  ;sicher eine ungültige Adresse =>
                move.l  A6,-(SP)
                movea.l D1,A6
                bsr     check_read                ;Adresse merken
                bne.s   do_gem74
                cmpa.l  #$FF0000,A6
                bhi.s   do_gem74                  ;garantiert ungültig =>
                moveq   #':',D0
                jsr     @chrout(A4)
                moveq   #'"',D0
                jsr     @chrout(A4)
                moveq   #31,D1                    ;max. 32 Zeichen ausgeben
do_gem72:       move.b  (A6)+,D0
                beq.s   do_gem73                  ;den String in Anführungszeichen ausgeben
                jsr     @chrout(A4)
                dbra    D1,do_gem72
do_gem73:       moveq   #'"',D0
                jsr     @chrout(A4)
do_gem74:       movea.l (SP)+,A6
do_gem71:       lsr.l   #2,D2                     ;n„chstes Parameter holen
                moveq   #-1,D4                    ;ab nun ein Komma nach jedem Parameter
                bra     do_gem4                   ;und testen =>
do_gemi:        pea     do_get2(PC)
                jsr     @print_line(A4)
do_gemx:        moveq   #')',D0                   ;Klammer zu, Ende
                jsr     @chrout(A4)
                jsr     @c_eol(A4)
                jmp     @crout(A4)

do_get1:       DC.B 'GEMDOS',0
do_get2:       DC.B 'illfunc(',0
               IFEQ sprache
do_get3:       DC.B ' - Funktion #$',0
               ELSE
do_get3:       DC.B ' - Function #$',0
               ENDC
do_get4:       DC.B 'XBIOS',0
               EVEN

do_vdiaes:      move.l  regs(A4),D0
                movea.l regs+4(A4),A6
                cmp.w   #115,D0
                beq     do_vdi
                pea     do_aet1(PC)
                jsr     @print_line(A4)           ;AES-Meldung ausgeben
                pea     do_get3(PC)
                jsr     @print_line(A4)
                movea.l (A6),A2                   ;contrl-Feld-Adr holen
                move.w  (A2),D1                   ;Funktionsnummer holen
                jsr     hexbout                   ;Funktionsnummer ausgeben
                jsr     @space(A4)
                bsr     gleich_out                ;' = ' ausgeben
                jsr     @space(A4)
                lea     aes_befs(PC),A0
do_aes1:        move.b  (A0)+,D2                  ;Funktionsnummer holen
                bmi     do_aesi                   ;Illegal, da Tabelle zuenden
                movea.l A0,A1                     ;Befehlsheader merken
do_aes2:        tst.b   (A0)+                     ;Befehlsheader berlesen
                bne.s   do_aes2
do_aes3:        addq.w  #1,D2                     ;Funktionsnummer erh”hen
                cmp.b   D2,D1
                beq.s   do_aes5                   ;gefunden
do_aes4:        tst.b   (A0)+                     ;Befehlsende berlesen
                bgt.s   do_aes4
                beq.s   do_aes3                   ;es war nur ein Befehl zuende => next one
                bra.s   do_aes1                   ;n„chsten Block testen
do_aes5:        move.l  A1,-(SP)
                jsr     @print_line(A4)           ;Befehlsheader ausgeben
                moveq   #'_',D0
                jsr     @chrout(A4)
do_aes6:        move.b  (A0)+,D0
                ble.s   do_aes7                   ;<=0 => Ende
                jsr     @chrout(A4)
                bra.s   do_aes6
do_aes7:        moveq   #'(',D0
                jsr     @chrout(A4)
do_aes8:        moveq   #')',D0                   ;Klammer zu, Ende
                jsr     @chrout(A4)
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                pea     do_aet2(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;control
                jsr     hexa2out
                pea     do_aet3(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;global
                jsr     hexa2out
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                pea     do_aet4(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;int_in
                jsr     hexa2out
                pea     do_aet5(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;int_out
                jsr     hexa2out
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                pea     do_aet6(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;addr_in
                jsr     hexa2out
                pea     do_aet7(PC)
                jsr     @print_line(A4)
                move.l  (A6),D1                   ;addr_out
                jsr     hexa2out
                jsr     @c_eol(A4)
                jmp     @crout(A4)
do_aesi:        pea     do_get2(PC)
                jsr     @print_line(A4)           ;"illfunc("
                bra     do_aes8                   ;")" und Ende
do_aet1:       DC.B ' AES',0
               IFEQ sprache
do_aet2:       DC.B '  control  ab ',0
do_aet3:       DC.B '  global   ab ',0
do_aet4:       DC.B '  int_in   ab ',0
do_aet5:       DC.B '  int_out  ab ',0
do_aet6:       DC.B '  addr_in  ab ',0
do_aet7:       DC.B '  addr_out ab ',0
               ELSE
do_aet2:       DC.B '  control  at ',0
do_aet3:       DC.B '  global   at ',0
do_aet4:       DC.B '  int_in   at ',0
do_aet5:       DC.B '  int_out  at ',0
do_aet6:       DC.B '  addr_in  at ',0
do_aet7:       DC.B '  addr_out at ',0
               ENDC
               EVEN

do_vdi:         pea     do_vdt1(PC)
                jsr     @print_line(A4)           ;VDI-Meldung ausgeben
                pea     do_get3(PC)
                jsr     @print_line(A4)
                movea.l (A6),A2                   ;contrl-Feld-Adr holen
                move.w  (A2),D1                   ;Funktionsnummer holen
                jsr     hexbout                   ;Funktionsnummer ausgeben
                jsr     @space(A4)
                bsr     gleich_out                ;' = ' ausgeben
                jsr     @space(A4)
                lea     vdi_befs(PC),A0
                tst.w   D1
                bls     do_vdii                   ;Nummer ist mist
                cmp.w   #11,D1
                beq     do_vdi6                   ;erweiterte Grafikfunktionen
                cmp.w   #39,D1
                bls.s   do_vdi5
                subi.w  #60,D1
                cmp.w   #40,D1
                blo     do_vdii                   ;Nummer ist mist
                cmp.w   #71,D1
                bhi     do_vdii                   ;Nummer ist mist
                bra.s   do_vdi5
do_vdi4:        tst.b   (A0)+                     ;String berlesen
                bne.s   do_vdi4
do_vdi5:        dbra    D1,do_vdi4
do_vdi3:        moveq   #'v',D0
                jsr     @chrout(A4)
                move.l  A0,-(SP)
                jsr     @print_line(A4)
                moveq   #'(',D0
                jsr     @chrout(A4)
do_vdi8:        moveq   #')',D0                   ;Klammer zu, Ende
                jsr     @chrout(A4)
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                pea     do_vdt2(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;control
                jsr     hexa2out
                pea     do_vdt3(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;intin
                jsr     hexa2out
                pea     do_vdt4(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;intout
                jsr     hexa2out
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                moveq   #22,D0
                bsr     spacetab
                pea     do_vdt5(PC)
                jsr     @print_line(A4)
                move.l  (A6)+,D1                  ;ptsin
                jsr     hexa2out
                pea     do_vdt6(PC)
                jsr     @print_line(A4)
                move.l  (A6),D1                   ;ptsout
                jsr     hexa2out
                jsr     @c_eol(A4)
                jmp     @crout(A4)
do_vdii:        pea     do_get2(PC)
                jsr     @print_line(A4)           ;"illfunc("
                bra.s   do_vdi8                   ;")" und Ende
do_vdi6:        lea     vdi2bef(PC),A0
                move.w  10(A2),D1                 ;erweiterte Funktionsnummer
                subq.w  #1,D1
                bmi.s   do_vdii
                cmp.w   #9,D1
                bhi.s   do_vdii
do_vdi7:        subq.w  #1,D1
                bmi     do_vdi3
do_vdi9:        tst.b   (A0)+
                bne.s   do_vdi9
                bra.s   do_vdi7

do_vdt1:       DC.B ' VDI',0
               IFEQ sprache
do_vdt2:       DC.B '  control ab ',0
do_vdt3:       DC.B '  intin   ab ',0
do_vdt4:       DC.B '  ptsin   ab ',0
do_vdt5:       DC.B 'intout  ab ',0
do_vdt6:       DC.B '  ptsout  ab ',0
               ELSE
do_vdt2:       DC.B '  control at ',0
do_vdt3:       DC.B '  intin   at ',0
do_vdt4:       DC.B '  ptsin   at ',0
do_vdt5:       DC.B 'intout  at ',0
do_vdt6:       DC.B '  ptsout  at ',0
               ENDC
               EVEN
               ;>ENDPART
********************************************************************************
* Sonstige Vektoren                                                            *
********************************************************************************
********************************************************************************
* ALT+Help-Vektor                                                              *
********************************************************************************
               ;>PART 'alt_help'
               DC.L 'XBRA'
               DC.L xbra_id
old_alt_help:  DS.L 1
alt_help:       lea     varbase(PC),A4
                movea.l kbshift_adr(A4),A0
                moveq   #4,D0                     ;Control?
                and.b   (A0),D0
                beq.s   alt_help1                 ;Nein! => Hardcopy
                sf      le_allowed(A4)            ;LE ist verboten
                sf      help_allow(A4)            ;CTRL+Help auch verbieten
                clr.l   merk_svar(A4)             ;keine Markerübergabe
                clr.l   prg_base(A4)              ;kein bergebenes Programm
                addq.l  #8,SP                     ;2 Unterprogrammebenen zurück
                addq.w  #1,$0452.w                ;VBL-Metaphore wieder freigeben
                move.w  #-1,$04EE.w               ;dumpflag zurücksetzen
                movem.l (SP)+,D0-A6
                andi.w  #$7FFF,(SP)               ;Trace aus!
                move.l  #231<<24,-(SP)
                pea     except1(PC)
                rts
alt_help1:      move.l  old_alt_help(PC),-(SP)
                rts
               ;>ENDPART
********************************************************************************
* etv_term beim zu debuggenden Programm abzufangen                             *
********************************************************************************
               ;>PART 'etv_term'
etv_term:       move    #$2700,SR                 ;alle IRQs sperren
                lea     varbase(PC),A4
                movea.l default_stk(A4),SP        ;eigenen Stack wiederherstellen
                movea.l act_pd(A4),A0
                movea.l (A0),A0                   ;Zeiger auf die Basepage des akt.Prgs
                movem.l $6C(A0),D0-D3
                movem.l D0-D3,regs+44(A4)
                move.l  $68(A0),regs(A4)          ;D0 zurückholen
                movea.l $7C(A0),A6                ;akt.Stack
                movea.l (A6)+,A5                  ;USP/SSP (Gegenteil von akt.Stack)
                move.w  (A6)+,_sr(A4)             ;Statusreg
                move.l  (A6)+,_pc(A4)
                movem.l (A6)+,D1-A2
                move.l  A6,rega7(A4)
                movem.l D1-A2,regs+4(A4)
                btst    #5,_sr(A4)                ;Supervisormodus aktiv?
                bne.s   etv_te2
                exg     A5,A6                     ;USP & SSP austauschen
etv_te2:        move.l  A5,_usp(A4)
                move.l  A6,_ssp(A4)
                move.l  merk_a0(A4),regs+32(A4)   ;A0 wieder einsetzen
                jsr     @page1(A4)                ;Debuggerscreen an
                bsr     breakclr                  ;Breakpoints entfernen
                moveq   #1,D6
                moveq   #$31,D7                   ;Programmende bei Trap #1
                bsr     exc_out                   ;Fehlertext und Adr ausgeben
                move.b  #2,trap_abort(A4)         ;Abbruch durch GEMDOS
                lea     main_loop,A0
                move.l  A0,jmpdispa(A4)           ;Sprungdispatcher auf Hauptschleife
                bra     excep9d                   ;Abschluž durch die Exceptionroutine
               ;>ENDPART
********************************************************************************
* Eigener etv_critic-Handler                                                   *
********************************************************************************
               ;>PART 'etv_critic'
               DC.L 'XBRA'
               DC.L xbra_id
old_critic:    DS.L 1
etv_critic:     move.l  4(SP),D0
                movem.l D1-A6,-(SP)
                lea     varbase(PC),A4
                move.l  D0,D1
                moveq   #0,D0
                bsr     graf_mouse                ;Mauszeiger als Pfeil
                move.l  D1,D0
                lea     etv_tx3(PC),A0
                lea     etv_txt(PC),A1            ;ab hier werden die Texte eingesetzt
                moveq   #3,D1                     ;4 Zeilen
etv_critic1:    move.l  A0,(A1)+                  ;Leertext einsetzen
                addq.l  #6,A1
                dbra    D1,etv_critic1
                move.w  D0,D1                     ;Laufwerk in D1
                addi.w  #'A',D1
                swap    D0                        ;Fehlernummer in D0
                lea     etv_tab(PC),A0
etv_critic2:    move.b  (A0)+,D2
                beq.s   etv_critic4               ;Tabellenende => Default nehmen
                bmi.s   etv_critic5               ;Wert negativ => Fehlernummer
etv_critic3:    cmpi.b  #-1,(A0)+                 ;bis -1 berlesen
                bne.s   etv_critic3
                bra.s   etv_critic2               ;und weitersuchen
etv_critic4:    lea     etv_dtab(PC),A0
                bra.s   etv_critic6
etv_critic5:    cmp.b   D0,D2                     ;Fehlernummer gefunden?
                bne.s   etv_critic2               ;Nein => weitersuchen
etv_critic6:    move.b  (A0)+,D3                  ;Bis zum positiven Wert alles lesen
                bmi.s   etv_critic6
                move.b  D3,etv_siz+1              ;Breite des Alerts einsetzen
                lea     etv_txt(PC),A1            ;ab hier werden die Texte eingesetzt
                movea.l A1,A2                     ;im Notfall zerst”rt durch Laufwerk
etv_critic7:    tst.b   (A0)                      ;1.Zeichen testen
                bmi.s   etv_critic9               ;Alles zuende, wenn negativ
                move.l  A0,(A1)+                  ;Zeilenadr einsetzen
                addq.l  #6,A1
etv_critic8:    move.b  (A0)+,D3
                beq.s   etv_critic7               ;Zeilenende?
                cmp.b   #'#',D3                   ;Kennung für's Laufwerk
                bne.s   etv_critic8
                lea     -1(A0),A2                 ;Adresse der Laufwerkskennung merken
                move.b  D1,(A2)                   ;Laufwerk einsetzen
                bra.s   etv_critic8
etv_critic9:    move.w  etv_siz(PC),D3
                subi.w  #11,D3
                move.w  D3,etv_but
                movem.l D0/A2,-(SP)
                lea     etv_critic_rsc(PC),A0
                jsr     @form_do(A4)              ;Alert ausgeben
                move.w  D0,D1
                movem.l (SP)+,D0/A2
                ext.w   D0
                ext.l   D0
                move.l  #$010000,D2               ;Flag für "Nochmal"
                cmp.w   #1,D1                     ;Abbruch?
                beq.s   etv_critic10              ;ja =>
                move.l  D2,D0                     ;Sonst nochmal probieren
etv_critic10:   cmp.w   #-17,D0                   ;Disk gewechselt?
                bne.s   etv_critic11
                move.l  D2,D0                     ;Dann stets nochmal probieren
etv_critic11:   move.b  #'#',(A2)                 ;Laufwerkskennung l”schen
                movem.l (SP)+,D1-A6
                rts

etv_critic_rsc:DC.W 0,0
etv_siz:       DC.W 18
               DC.W 8,1
               DC.W 1,1
etv_txt:       DC.L 0
               DC.W 8
               DC.W 1,2
               DC.L 0
               DC.W 8
               DC.W 1,3
               DC.L 0
               DC.W 8
               DC.W 1,4
               DC.L 0
               DC.W 8

               DC.W 2,6
               DC.L etv_tx1
               DC.W $24
etv_but:       DC.W 10,6
               DC.L etv_tx2
               DC.W $26                           ;Default
               DC.W -1

etv_tab:       DC.B -1,-9,-15
               IFEQ sprache
etv_dtab:      DC.B 31
               DC.B 'Ausgabeger„t antwortet nicht!',0
               DC.B 'Ist es eventuell nicht ange-',0
               DC.B 'geschaltet?',0,-1
               DC.B -2,-3,-5,-6
               DC.B 28
               DC.B 'Floppy #: antwortet nicht.',0
               DC.B 'Bitte berprüfen und eine',0
               DC.B 'Disk einlegen.',0,-1
               DC.B -4,-7,-8,-10,-11,-12,-16
               DC.B 29
               DC.B 'Daten auf Disk #: defekt?',0
               DC.B 'Prüfen Sie die Disk und die',0
               DC.B 'Verbindungskabel.',0,-1
               DC.B -13
               DC.B 27
               DC.B 'Disk in Floppy #: ist',0
               DC.B 'schreibgeschützt. Vor dem',0
               DC.B 'n„chsten Versuch',0
               DC.B 'Schreibschutz entfernen.',0,-1
               DC.B -14
               DC.B 29
               DC.B 'Die Anwendung kann die Disk',0
               DC.B 'in Floppy #: nicht lesen',0,-1
               DC.B -17
               DC.B 27
               DC.B 'Bitte Disk # in Floppy A:',0
               DC.B 'einlegen.',0,-1
               DC.B 0
etv_tx1:       DC.B ' ABBRUCH ',0
etv_tx2:       DC.B ' NOCHMAL ',0
               ELSE                             ;~
etv_dtab:      DC.B 31
               DC.B 'Ausgabeger„t antwortet nicht!',0
               DC.B 'Ist es eventuell nicht ange-',0
               DC.B 'geschaltet?',0,-1
               DC.B -2,-3,-5,-6
               DC.B 28
               DC.B 'Floppy #: antwortet nicht.',0
               DC.B 'Bitte berprüfen und eine',0
               DC.B 'Disk einlegen.',0,-1
               DC.B -4,-7,-8,-10,-11,-12,-16
               DC.B 29
               DC.B 'Daten auf Disk #: defekt?',0
               DC.B 'Prüfen Sie die Disk und die',0
               DC.B 'Verbindungskabel.',0,-1
               DC.B -13
               DC.B 27
               DC.B 'Disk in Floppy #: ist',0
               DC.B 'schreibgeschützt. Vor dem',0
               DC.B 'n„chsten Versuch',0
               DC.B 'Schreibschutz entfernen.',0,-1
               DC.B -14
               DC.B 29
               DC.B 'Die Anwendung kann die Disk',0
               DC.B 'in Floppy #: nicht lesen',0,-1
               DC.B -17
               DC.B 27
               DC.B 'Bitte Disk # in Floppy A:',0
               DC.B 'einlegen.',0,-1
               DC.B 0
etv_tx1:       DC.B ' CANCEL ',0
etv_tx2:       DC.B ' AGAIN ',0
               ENDC
etv_tx3:       DC.B ' ',0
               EVEN
               ;>ENDPART
********************************************************************************
* swv_vec - Vektor bei Bildschirmumschaltung (keine Umschaltung)               *
********************************************************************************
swv_vec:        rts

********************************************************************************
* Den gesamten Speicher l”schen & RESET                                        *
********************************************************************************
               ;>PART 'kill_all'
kill_all:       move    #$2700,SR
                lea     init_scr(A4),A0
                bsr     restore_scr               ;Bildschirm-Einstellung, wie beim Start
                lea     kill_a2(PC),A0
                moveq   #13,D0
                lea     8.w,A1
kill_a1:        move.l  (A0)+,(A1)+
                dbra    D0,kill_a1
                jmp     8.w
kill_a2:        lea     kill_a4(PC),A0
                move.l  A0,8.w
                lea     kill_a5(PC),A0
                moveq   #0,D0
                move.l  D0,D1
                move.l  D0,D2
                move.l  D0,D3
                move.l  D0,D4
                move.l  D0,D5
                move.l  D0,D6
                move.l  D0,D7
                movea.l D0,A1
                movea.l D0,A2
                movea.l D0,A3
                movea.l D0,A4
                movea.l D0,A5
                movea.l D0,A6
kill_a3:        movem.l D0-D7/A1-A6,(A0)
                lea     $38(A0),A0
                bra.s   kill_a3
kill_a4:        movea.l 4.w,A0
                jmp     (A0)
kill_a5:
               ;>ENDPART
********************************************************************************
* Testen, ob Speicher ab A6 lesebar ist (Z gel”scht, wenn nicht)               *
********************************************************************************
               ;>PART 'check_read'
check_read:     tst.w   all_memory(A4)            ;Speichertest?
                bne.s   check_read4               ;Nein! =>
                cmpa.l  #$400000,A6               ;bis hier kein Busfehler durch den MFP
                blo.s   check_read4
                cmpa.l  rom_base(A4),A6           ;Sicher im ROM? (für 1040 STE n”tig)
                bhs.s   check_read1               ;dann weiter =>
                cmpa.l  #$FA0000,A6               ;Lesen des ROM-Bereichs mgl.
                blo.s   check_read5
check_read1:    cmpa.l  #$FF0000,A6

                blo.s   check_read4
                tst.b   tt_flag(A4)               ;ein TT?
                beq.s   check_read2               ;Nein! =>
                cmpi.l  #$1357BD13,$05A8.w        ;kein Fast-Mem?
                bne.s   check_read2               ;genau =>
                cmpa.l  #$01000000,A6
                blo.s   check_read2               ;unterhalb des Fast-Mems
                cmpa.l  $05A4.w,A6
                blo.s   check_read4               ;im Fast-Mems
check_read2:    movem.l D0-D2/A0-A1,-(SP)
                move    SR,D1                     ;Statusreg retten
                movea.l SP,A0                     ;Stackpnt retten
                ori     #$0700,SR                 ;Alle IRQs sperren
                move.l  8.w,D2
                lea     check_read3(PC),A1
                move.l  A1,8.w
                moveq   #-1,D0
                tst.b   (A6)                      ;Zugriff erlaubt?
                moveq   #0,D0
check_read3:    move    D1,SR                     ;Statusreg zurück
                movea.l A0,SP                     ;Stackpnt zurück
                move.l  D2,8.w                    ;Busfehler-Vektor zurück
                tst.w   D0                        ;Flags setzen
                movem.l (SP)+,D0-D2/A0-A1
                rts
check_read4:    move    #$FF,CCR                  ;Z gesetzt, Zugriff erlaubt
                rts
check_read5:    move    #0,CCR                    ;Z gel”scht, da Zugriff nicht erlaubt
                rts
               ;>ENDPART
********************************************************************************
* Testen, ob der Speicher ab A6 beschreibbar ist (Z=1, wenn ja)                *
********************************************************************************
               ;>PART 'check_write'
check_write:    tst.w   all_memory(A4)            ;Speichertest?
                bne.s   check_write1              ;Nein! =>
                cmpa.w  #8,A6
                blo.s   check_write2              ;ROM-Bereich!
                cmpa.l  #$400000,A6
                blo.s   check_write1              ;unterhalb von phystop => ok!
                tst.b   tt_flag(A4)               ;ein TT?
                beq.s   check_write2              ;Nein! => schreiben nicht m”glich
                cmpi.l  #$1357BD13,$05A8.w        ;kein Fast-Mem?
                bne.s   check_write2              ;genau => schreiben nicht m”glich
                cmpa.l  #$01000000,A6
                blo.s   check_write2              ;unterhalb des Fast-Mems => Fehler
                cmpa.l  $05A4.w,A6
                bhs.s   check_write2              ;oberhalb des Fast-Mems
check_write1:   move    #$FF,CCR                  ;Z-Flag setzen
                rts
check_write2:   move    #0,CCR                    ;Z-Flag l”schen
                rts
               ;>ENDPART
********************************************************************************
* Tastenwarte-Routine                                                          *
********************************************************************************
               ;>PART 'check_keyb'
check_keyb:     tst.l   tmacro_pointer(A4)        ;TMacro aktiv?
                bne.s   check_3                   ;dann keinen Abbruch
                tst.l   tmacro_def_key(A4)        ;TMacro-Definition aktiv?
                bne.s   check_3                   ;dann keinen Abbruch
                jsr     @conin(A4)
                cmp.b   #27,D0                    ;ESC
                beq.s   check_4                   ;=> Abbruch
                cmp.b   #' ',D0                   ;kein Space
                bne.s   check_3                   ;=> Nix tun
                bsr     clr_keybuff               ;Tastaturbuffer l”schen
check_2:        jsr     @conin(A4)                ;auf Taste warten
                beq.s   check_2
                cmp.b   #27,D0                    ;ESC
                beq.s   check_4                   ;=> Abbruch
check_3:        move    #0,CCR                    ;Flags für Weiter setzen
                rts
check_4:        move    #$FF,CCR                  ;Flags für Abbruch setzen
                rts
               ;>ENDPART

********************************************************************************
* extensions wie ultraDev erkennen                                             *
********************************************************************************
               ;>PART 'probe_extensions'
probe_extensions:
              IFNE ultradev
                jsr   probe_ultradev              ;check if UD is present or not
              ENDC
                rts

probe_extensions_print:
                pea     .extensionsFound(PC)
                jsr     @print_line(A4)
              IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                jsr   probe_ultradev_print
.noUD:
              ENDC
                tst.b   extension_flags(A4)
                bne.s   .hasExtensions
                pea     .noExtensionsFound(PC)
                jsr     @print_line(A4)
.hasExtensions:                
                rts
.extensionsFound:
               IFEQ sprache
                DC.B "Erweiterungen gefunden: ",0
               ELSE
                DC.B "Extensions found: ",0
               ENDC
.noExtensionsFound:
               IFEQ sprache
                DC.B "keine",0
               ELSE
                DC.B "none",0
               ENDC

                EVEN
                IFNE ultradev
probe_ultradev:
                ;check if we were started with "le" only, dead giveaway UD started this
                ;simply probing for the hw won't suffice, because bugaboo only works in UD mode if started with "le" anyway
                cmp.l   #$abcdef42,$FA0000    ;bootable cartridge?
                bne.s   .noUltraDev
                cmp.l   #$deadbeef,$FA4012    ;UD?
                bne.s   .noUltraDev
                cmp.l   #"dumm",$FA0000+$18   ;just to be sure
                bne.s   .noUltraDev
                tst.w   $FA4022
                beq     .noUltraDev

                move.l  a6,-(a7)
                move.l  UDCartridgeRamPos,a6
                move.l  $4000+udBugaBooCmdListPos(a6),a6
                beq.s   .noCmdList
                cmp.b   #"l",(A6)+
                bne.s   .noUltraDev
                cmp.b   #"e",(A6)+
                bne.s   .noUltraDev
                cmp.b   #":",(A6)+
                bne.s   .noUltraDev
.noCmdList:
                move.l  (a7)+,a6
                or.b    #1,extension_flags(A4)
.noUltraDev:
                rts
probe_ultradev_print:
                pea     .ultraDevFound(PC)
                jsr     @print_line(A4)          
                rts
.ultraDevFound:
                DC.B    "ultraDev ",0
                EVEN 
ramValuePos     equ $0                
fontPosition    equ ramValuePos+$003e                
ultradev_mirror_vga_init:
                jsr   UDGetVarRamPos
                move.l  fontPosition(a6),a0

; uploads a font
; ->a0 font
; ->d0 char count to upload. max 256
; ->d1 start address in font memory 

  moveq   #0,D1
;  lsl   #3,d0
  move.w  #256,D0
  subq  #1,d0

  lea   $fb0000,a2

  move  UDRegWriteToFontAdr,d2  ; set font destination address
  add   d1,d1
  move  (a2,d1),d1

  move  UDRegWriteToFontAdrIncr,d2  ; set font increment to 1
  move  2(a2),d1

  move  UDRegWriteToFontMemory,d2 ; set write destination to font memory

.UDFontUploadLoop:
  REPT 8
  moveq #0,d1
  move.b  (A0),d1
  lea     256(A0),A0
  add   d1,d1
  move  (a2,d1),d1
  ENDR
  lea   -256*8+1(A0),A0
  dbf   d0,.UDFontUploadLoop

 REM
                lea     UDFont(PC),A0
                move.w  #112*2,D0
                moveq   #0,D1
                jsr     UDFontUpload
 EREM

                jsr     ultradev_mirror_prepare_cursor_char

                lea       $fb0000,A6
                move  UDRegWriteToScreenPos,D1
                move      (0+0)*2(A6),d1     ;set position to 0,0
                move      UDRegWriteToScreen,D1
                lea       menue(PC),A2
                lea   $200*5(A6),A6     ;font color (white)

                move.w    #80-1,D7
.menul1:                
                moveq     #0,D2       ;04
                move.b    (A2)+,D2    ;08 -32+char ascii (font starts with space)
                add.w     D2,D2       ;04
                move      (A6,D2),D3  ;16 write char+color
                dbra      D7,.menul1                

                lea       menue2(PC),A2
                move.w    #80-1,D7
.menul2:                
                moveq     #0,D2       ;04
                move.b    (A2)+,D2    ;08 -32+char ascii (font starts with space)
                add.w     D2,D2       ;04
                move      (A6,D2),D3  ;16 write char+color
                dbra      D7,.menul2

 REM
                lea     menue(PC),A0
                moveq   #0,D0
                moveq   #0,D1
                moveq   #7*2,D2
                bsr     UDDbgScrPrint
                lea     menue2(PC),A0
                moveq   #0,D0
                moveq   #1*2,D1 ;FIXME! this is meant to be Y=1, but since the lib still counts in 40col rows, we have to double this value
                moveq   #7*2,D2
                bsr     UDDbgScrPrint
 EREM
                rts

ultradev_mirror_vga:
                tst.b   udmirror_enable(A4)
                beq     .nomirror

                ;prepare cursor char
                jsr ultradev_mirror_prepare_cursor_char

; not.w $ffff8240.w
                movem.l   D0-A6,-(SP)
                lea       $fb0000,A6
                move  UDRegWriteToScreenPos,D1
                move  (0+80*2)*2(A6),d1     ;set position to 0,0

                move  UDRegWriteToScreen,D1

                lea   $200*7(A6),A6     ;font color (white)

                lea       screen+80*2(A4),A2
                lea       ultradev_chartab(PC),A3
                move.w    #25-1-2,D5
.yl:
                ;move.w    #80-1,D6
.xl:
                REPT 80
                moveq     #0,D7       ;04
                move.b    (A2)+,D7    ;08 -32+char ascii (font starts with space)
                add.w     D7,D7       ;04
                move.w    (A3,D7),D7  ;16 clamp all ASCII <32 to 32 (space) and replace ASCII 225 ß with ASCII 158 ß bcse they look the same - we need one char to emulate the cursor
                move      (A6,D7),D3  ;16 write char+color
                ;48
                ENDR

                ;dbra      D6,.xl
                dbra      D5,.yl                                

                ;print ASCII 225, our cursor char
                lea       ultradev_cursor_char(PC),A0
                move.w    spalte(A4),D0   ;x
                move.w    zeile(A4),D1    ;y
                addq      #5,D1
                add.w     D1,D1 ;FIXME: *2 because UDDbgScrPrint still "thinks" 40cols and thus multiplies Y by 40 instead of 80
                move.w    #$ff,D2         ;col
                jsr       UDDbgScrPrint

                movem.l   (SP)+,D0-A6
.nomirror:                
                rts    
ultradev_cursor_char:
                DC.B  225,0
                EVEN
ultradev_mirror_prepare_cursor_char:
                movem.l   D0-A6,-(SP)

                moveq     #0,D0
                btst      #6,curflag(A4)   ;1=on/0=off
                bne.s     .curoff
                moveq     #-1,D0
.curoff:
                move.w    zeile(A4),D1    ;y
                move.w    spalte(A4),D2   ;x
                lea       screen+80*5(A4),A2
                mulu      #80,D1
                add.w     D1,A2
                moveq     #0,D3
                move.b    (A2,D2),D3    ;get char at cursor

                ;now, copy this char into the 225 ASCI character we freed for our cursor
                lea       UDFont(PC),A2
                lea       ultradev_charbuff(PC),A3
                jsr       UDGetVarRamPos
                move.l    fontPosition(a6),a2
                add.w     D3,A2   ;char Y lines are interleaved, so 1 byte per char, then 256 bytes per y-line
z SET 0                
                REPT  8
                move.b    z(A2),(A3)
                eor.b     D0,(A3)+
z SET z+256                
                ENDR

                lea       ultradev_charbuff(PC),A0
                moveq     #1,D0
                move.w    #(225-32)*8,D1
                jsr       UDFontUpload
                movem.l   (SP)+,D0-A6
                rts

                include   "UDDebugScreen.s"
                include   "UDVideo.s"
                include   "UDFont.s"
                include   "UDCartridge.s"
                EVEN
                ENDC
               ;>ENDPART
ultradev_charbuff:
                DS.B  8
ultradev_chartab:
z SET 0
                REPT 256
                IF z>-1 ;32
                IF z=225 ; replace ASCII 225 ß with ASCII 158 ß bcse they look the same - we need one char to emulate the cursor
                DC.W 158*2
                ELSE
                DC.W (z-32*0)*2
                ENDC
                ELSE
                DC.W 0
                ENDC
z SET z+1
                ENDR               

********************************************************************************
* einmalige Initialisierung                                                    *
********************************************************************************
               ;>PART 'init_all'
init_all:       lea     varbase(PC),A4
                movea.l (SP),A3                   ;Zeiger auf Default-Daten (Rücksprungadr)
                move.l  #start-anfang-6,D0
                add.l   D0,(SP)                   ;Rücksprungadr hinter die Default-Daten
                pea     get_sysbase(PC)
                move.w  #$26,-(SP)
                trap    #14                       ;{{$4f2}+8} nach A0 holen
                addq.l  #6,SP
                movem.l $24(A0),A1-A2             ;kbshift und act_pd ab Blitter-TOS
                cmpi.w  #$0102,$02(A0)            ;Ist's das Blitter-TOS oder neuer?
                bge.s   init2                     ;JA!
                lea     $0E1B.w,A1                ;kbshift-Adr (vor dem Blitter-TOS)
;ULTRADEV: this does not work with TOS1.0+ultradev -dbg!
                lea     $602C.w,A2                ;act_pd (vor dem Blitter-TOS)
                move.w  $1C(A0),D0                ;os_conf holen
                lsr.w   #1,D0                     ;PAL/NTSC-Mode ignorieren
                subq.w  #4,D0                     ;Spanisches TOS 1.0?
                bne.s   init2                     ;Nein! =>
                lea     $873C-$602C(A2),A2        ;act_pd des spanischen TOS 1.0
init2:          move.l  A1,kbshift_adr(A4)
                move.l  A2,act_pd(A4)
                move.l  8(A3),serial(A4)          ;Seriennummer merken
                move.l  8(SP),basepage(A4)

                movea.l #ende,A3
                adda.l  A4,A3                     ;Zeiger auf das Programmende

                pea     probe_extensions(PC)
                move.w  #$26,-(SP)
                trap    #14                       ;{{$4f2}+8} nach A0 holen
                addq.l  #6,SP

                IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                bra     initcart
.noUD:                
                ENDC

                lea     install_name9(PC),A0
                move.l  #'SYM'<<8,(A0)
                bsr     install_name              ;'BUGABOO.SYM' als Namen setzen
                move.w  #$2F,-(SP)
                trap    #1                        ;Fgetdta()
                addq.l  #2,SP
                movea.l D0,A6                     ;Adr merken
                pea     dta_buffer(A4)
                move.w  #$1A,-(SP)
                trap    #1                        ;Fsetdta(neuer Buffer)
                addq.l  #6,SP
                move.w  #7,-(SP)
                pea     fname(A4)
                move.w  #$4E,-(SP)
                trap    #1                        ;Fopen()
                addq.l  #8,SP
                tst.l   D0
                bmi.s   init20                    ;Nicht gefunden =>
                clr.w   -(SP)
                pea     fname(A4)
                move.w  #$3D,-(SP)
                trap    #1                        ;Fopen(BUGABOO.SYM)
                addq.l  #8,SP
                move.l  D0,D7
                bmi.s   init20                    ;Fehler =>
                move.l  dta_buffer+26(A4),D6      ;Gr”že der Datei
                move.l  A3,sym_buffer(A4)
                move.l  A3,-(SP)
                move.l  D6,-(SP)
                addq.w  #1,D6
                and.b   #$FE,D6                   ;Programmende hochsetzen
                adda.l  D6,A3
                move.w  D7,-(SP)                  ;Filehandle auf den Stack
                move.w  #$3F,-(SP)
                trap    #1                        ;Fread()
                lea     12(SP),SP
                movea.l sym_buffer(A4),A0
                addq.l  #4,sym_buffer(A4)         ;Zeiger hinter den Header
                cmpi.l  #'äSYM',(A0)              ;ist das auch 'ne Symboltabelle?
                bne.s   init22                    ;Nein! =>
                cmp.l   D0,D6                     ;alle Bytes gelesen?
                beq.s   init21                    ;Ja! =>
init22:         clr.l   sym_buffer(A4)
init21:         subq.l  #4,D6                     ;Header abziehen
                lsr.l   #5,D6                     ;L„nge der Tabelle durch 32
                move.w  D6,sym_anzahl(A4)         ;Anzahl merken
                move.w  D7,-(SP)
                move.w  #$3E,-(SP)
                trap    #1                        ;Fclose()
                addq.l  #4,SP
init20:         move.l  A6,-(SP)
                move.w  #$1A,-(SP)
                trap    #1                        ;Fsetdta(alter Buffer)
                addq.l  #6,SP
initcart:
                move.l  A3,end_adr(A4)
                suba.l  #anfang-256,A3            ;Programml„nge + Basepage
                move.l  A3,-(SP)                  ;= L„nge
                move.l  basepage(A4),-(SP)        ;Anfangsadresse
                move.l  #$4A0000,-(SP)
                trap    #1                        ;Mshrink()
                lea     12(SP),SP

                moveq   #-2,D0                    ;Tastaturmacros l”schen
                move.l  D0,tmacro_tab(A4)
                move.l  D0,tmacro_tab_end(A4)

                pea     -1.w
                move.w  #$48,-(SP)
                trap    #1                        ;Adr des größten Speicherblocks erfragen
                addq.l  #6,SP
                move.l  D0,D7
                move.l  D0,-(SP)
                move.w  #$48,-(SP)
                trap    #1                        ;gesamten Speicher reservieren
                addq.l  #6,SP
                move.l  D0,first_free(A4)         ;merken (für 'Load for execute')
                add.l   D0,D7
                move.l  D7,end_of_mem(A4)
                move.l  D0,-(SP)
                move.w  #$49,-(SP)
                trap    #1                        ;Speicher wieder freigeben
                addq.l  #6,SP

                bra     install_read              ;Erstmal Installation einlesen

get_sysbase:    move    SR,D7                     ;Prozessor ermitteln
                ori     #$0700,SR
                movea.l SP,A6
                moveq   #-1,D1                    ;68000
                movea.l $10.w,A2                  ;Illegal retten
                lea     check_proz(PC),A0
                move.l  A0,$10.w                  ;neuen Illegal rein
               DC.W $42C0                         ;MOVE CCR,D0
                moveq   #0,D1                     ;68010
               DC.W $49C0                         ;EXTB.L D0
                moveq   #1,D1                     ;68020
               DC.W $4E7A,$02                     ;MOVE CACR,D0
                bset    #9,D0                     ;Daten-Cache an (?)

               DC.W $4E7B,$02                     ;MOVE D0,CACR
               DC.W $4E7A,$02                     ;MOVE CACR,D0
                bclr    #9,D0                     ;Ist der Daten-Cache an?
                beq.s   check_proz                ;Nein! =>
                moveq   #2,D1                     ;68030
               DC.W $4E7B,$02                     ;MOVE D0,CACR
check_proz:     movea.l A6,SP
                move.l  A2,$10.w                  ;alten Illegal-Vektor zurück
                lea     varbase(PC),A4
                move.b  D1,prozessor(A4)          ;Prozessor merken
                bgt.s   check_proz1               ;68020 oder h”her? Ja! =>
                move.w  _return(PC),clr_cache     ;68000/10 : Cache nicht l”schen
check_proz1:
                moveq   #0,D1                     ;keine FPU
                movea.l $08.w,A0
                move.l  #check_fpu,$08.w
                tst.w   $FFFFFA40.w               ;SFP004?
                addq.w  #1,D1
check_fpu:      movea.l A6,SP
                movea.l $2C.w,A1
                movea.l $34.w,A2
                move.l  #check_fpu3,$2C.w
                move.l  #check_fpu3,$34.w
               DC.L $F2800000                     ;FNOP
               DC.W $F327                         ;FSAVE -(SP)
                move.w  (SP),D0
                cmp.b   #24,D0                    ;68881?
                beq.s   check_fpu2                ;Ja! =>
                cmp.b   #60,D0                    ;68882?
                beq.s   check_fpu1                ;Ja! =>
                addq.w  #2,D1
check_fpu1:     addq.w  #2,D1
check_fpu2:     addq.w  #2,D1
check_fpu3:     movea.l A6,SP
                move.l  A0,$08.w
                move.l  A1,$2C.w
                move.l  A2,$34.w
                move.b  D1,fpu_flag(A4)

                movea.l $08.w,A5
                lea     check_ste(PC),A0
                move.l  A0,$08.w
                moveq   #0,D0                     ;kein STE
                move.w  $FFFF9202.w,D1            ;1040STE? (Joystickports lesen)
                moveq   #-1,D0                    ;STE vorhanden!
check_ste:      move.b  D0,ste_flag(A4)
                lea     check_tt(PC),A0
                move.l  A0,$08.w
                moveq   #0,D0                     ;kein TT
                move.w  $FFFF8400.w,D1            ;Farbregister des TT lesen
                moveq   #-1,D0                    ;TT vorhanden
check_tt:       move.b  D0,tt_flag(A4)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                lea     check_f030(PC),A0
                move.l  A0,$08.w
                moveq   #$00,D0
                move.w  $FFFF9800.w,D1
                moveq   #-$01,D0
check_f030:     move.b  D0,f030_flag(A4)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                move.l  A5,$08.w
                movea.l A6,SP
                move    D7,SR

                movea.l $04F2.w,A0                ;Sysbase holen
                movea.l 8(A0),A0                  ;Anfangsadresse des ROMs holen
                move.l  A0,rom_base(A4)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                tst.b   f030_flag(A4)
                beq     _nof030
                movem.l D0-A6,-(SP)
                lea     f030_save_2532(A4),A0     ;$2532(a4),a0
                bsr     savef030regs
                lea     f030_save_2588(A4),A0     ;$2588(a4),a0
                bsr     savef030regs
                move.w  $FFFF82A2.w,f030_vft(A4)  ;$0276(a4)
                move.b  $FFFF8006.w,D0
                lsr.b   #6,D0
                cmp.b   #$02,D0                   ;VGA check
                bne.s   T0CDE8
                move.l  #$170012,$FFFF8282.w
                move.l  #$01020E,$FFFF8286.w
                move.l  #$0D0011,$FFFF828A.w
                move.l  #$041903AF,$FFFF82A2.w
                move.l  #$8F008D,$FFFF82A6.w
                move.l  #$03AD0415,$FFFF82AA.w
                move.w  #$0200,$FFFF820A.w
                move.w  #$0186,$FFFF82C0.w
                clr.w   $FFFF8266.w
                move.b  #$01,$FFFF8260.w
                move.w  #$09,$FFFF82C2.w
                move.w  #$50,$FFFF8210.w
                bra     T0CE96

T0CDE8:         cmpi.w  #$0260,f030_vft(A4)       ;crude attempt to check for 50/60 Hz prbly
                blt.s   T0CE44
                move.l  #$3E0032,$FFFF8282.w
                move.l  #$09023F,$FFFF8286.w
                move.l  #$1C0034,$FFFF828A.w
T0CE08:         move.l  #$02710265,$FFFF82A2.w
                move.l  #$2F006F,$FFFF82A6.w
                move.l  #$01FF026B,$FFFF82AA.w
                move.w  #$0200,$FFFF820A.w
                move.w  #$82,$FFFF82C0.w
                clr.w   $FFFF8266.w
                move.b  #$01,$FFFF8260.w
                move.w  #$04,$FFFF82C2.w
                move.w  #$50,$FFFF8210.w
                bra.s   T0CE96

T0CE44:         move.l  #$3E0030,$FFFF8282.w
                move.l  #$080002,$FFFF8286.w
                move.l  #$1B0034,$FFFF828A.w
                move.l  #$020D0201,$FFFF82A2.w
                move.l  #$17004D,$FFFF82A6.w
                move.l  #$01DD0207,$FFFF82AA.w
                move.w  #$0200,$FFFF820A.w
                move.w  #$0182,$FFFF82C0.w
                clr.w   $FFFF8266.w
                move.b  #$01,$FFFF8260.w
                move.w  #$04,$FFFF82C2.w
                move.w  #$50,$FFFF8210.w

T0CE96:         lea     f030_save_24DC(A4),A0
                bsr.s   savef030regs
                lea     f030_save_2532(A4),A0
                bsr.s   restoref030regs
                lea     f030_save_24DC(A4),A0
                move.l  A0,f030_save_25DE(A4)
                movem.l (SP)+,D0-A6
_nof030:        rts

savef030regs:                                     ;T0CEB0
                movem.l D0/A0-A2,-(SP)
                tst.b   f030_flag(A4)
                beq.s   T0CEC8
                lea     f030_regtabl(PC),A2
                moveq   #$12,D0
T0CEC0:         movea.w (A2)+,A1
                move.w  (A1),(A0)+
                dbra    D0,T0CEC0
T0CEC8:         movem.l (SP)+,D0/A0-A2
                rts

restoref030regs:                                  ;T0CECE
                movem.l D0/A0-A2,-(SP)
                tst.b   f030_flag(A4)
                beq.s   T0CF0A
                lea     f030_regtabl(PC),A2
                moveq   #$0E,D0
T0CEDE:         movea.w (A2)+,A1
                move.w  (A0)+,(A1)
                dbra    D0,T0CEDE
                cmpi.w  #$50,$FFFF8282.w
                blt.s   T0CEF6
                addq.w  #2,A0
                move.w  (A0)+,$FFFF8266.w
                bra.s   T0CF02

T0CEF6:         move.w  $02(A0),$FFFF8266.w
                move.w  (A0)+,$FFFF8260.w
                addq.w  #2,A0
T0CF02:         move.w  (A0)+,$FFFF8210.w
                move.w  (A0)+,$FFFF82C2.w
T0CF0A:         movem.l (SP)+,D0/A0-A2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
_return:        rts
               ;>ENDPART
********************************************************************************
* Alles mgl. initialisieren                                                    *
********************************************************************************
               ;>PART 'init'
init:           ori     #$0700,SR
                lea     8.w,A0
                lea     save_data(A4),A1
                movea.l A1,A2
                move.w  #361,D1
init1:          move.l  (A0)+,(A1)+               ;$8-$5AF retten
                dbra    D1,init1
                move.l  D0,132(A2)                ;Trap #3 einsetzen
                move.l  $04BA.w,merk_it(A4)

                linea   0    ;>linea   #0 ;>[ Init ]
                movem.l (A1),A0-A2
                move.l  76(A2),s_w_font(A4)
                move.l  76(A1),farbfont(A4)

                moveq   #0,D1
;tst.b   tt_flag(A4)
;!!!!!!!!!!!!!!!!!
                move.b  tt_flag(A4),D0
                or.b    f030_flag(A4),D0
;!!!!!!!!!!!!!!!!!
                bne.s   init3
                bsr     vsync_test
                bsr     vsync_test
                bsr     vsync_test                ;OverScan abtesten
                sne     D1
                and.w   #1,D1
init3:          move.w  D1,overscan(A4)           ;Flag merken

                lea     init_scr(A4),A1
                movea.l A1,A2
                bsr     save_scr
                sf      scr_overscan(A2)          ;OverScan für das Anwenderprogramm nehmen

                lea     debugger_scr(A4),A1
                movea.l A1,A3
                move.w  col0(A4),(A3)+
                moveq   #14,D0
init4:          move.w  col1(A4),(A3)+
                dbra    D0,init4
                clr.b   scr_offset(A1)            ;STE-Register werden nicht benutzt
                clr.b   scr_hscroll(A1)
                move.b  scr_sync(A2),scr_sync(A1) ;Sync übernehmen
                st      scr_overscan(A1)          ;OverScan für den Debugger stets aus
                moveq   #2,D0                     ;die hohe Aufl”sung
                tst.b   tt_flag(A4)               ;ein TT?
                bne.s   init5                     ;Ja! => stets die hohe Aufl”sung
                move.b  scr_moni(A2),scr_moni(A1) ;der aktuelle Monitor
                beq.s   init5                     ;die hohe Aufl”sung =>
                moveq   #1,D0                     ;sonst die mittlere w„hlen
init5:          move.b  D0,scr_rez(A1)
                move.l  #hires+255,D0
                add.l   A4,D0
                clr.b   D0
                move.l  D0,scr_adr(A1)            ;Bildschirmseite für den Debugger

                move.w  #5,upper_line(A4)
                move.w  #400,upper_offset(A4)
                move.w  #20,down_lines(A4)

                move.w  #319,mausx(A4)
                move.w  #199,mausy(A4)
                st      mausflg(A4)
                st      mausmove(A4)
                st      _dumpflg(A4)

;Tastatur initialisieren
                move.w  #$1111,timer_c_bitmap(A4) ;200Hz-Timer-Teiler (auf 50Hz)
                lea     iorec_IKBD(A4),A0
                lea     iorec_puffer(A4),A1
                move.l  A1,(A0)+
                clr.l   (A0)                      ;Tastaturbuffer setzen und leeren

                move.l  #$0E0001,-(SP)
                trap    #14                       ;Iorec(Tastatur)
                addq.l  #4,SP
                movea.l D0,A0
                clr.l   6(A0)                     ;Tastaturbuffer l”schen

                moveq   #-1,D0
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.l  D0,-(SP)
                move.w  #$10,-(SP)
                trap    #14
                lea     14(SP),SP
                movea.l D0,A0
                lea     29(A0),A1
                move.l  A1,save_clrkbd(A4)
                clr.b   (A1)                      ;~akt.Taste l”schen (Auto-Repeat aus!)

                lea     std_keytab(A4),A1
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+               ;Tastaturtabellen setzen
                movea.l (A0),A0
                lea     caps_tab(A4),A2
                move.l  A2,(A1)
                moveq   #31,D0
init6:          move.l  (A0)+,(A2)+               ;CAPS/LOCK Tabelle kopieren
                dbra    D0,init6
                movea.l (A1),A0
                move.b  #'A',$63(A0)
                move.b  #'B',$64(A0)
                move.b  #'C',$65(A0)              ;Belegung des Zehnernblocks „ndern
                move.b  #'D',$66(A0)
                move.b  #'E',$4A(A0)
                move.b  #'F',$4E(A0)
                move.b  #',',$71(A0)

                lea     stab(PC),A0               ;Zeiger auf die Tastaturtabelle
init7:          tst.w   (A0)+
                beq.s   init10                    ;Ende der Tabelle
                tst.w   (A0)                      ;ASCII-Code=0?
                beq.s   init9                     ;=> weiter
                movea.l -4(A1),A2                 ;SHIFT-Tabelle
                cmpi.b  #1,2(A0)                  ;SHIFT?
                beq.s   init8                     ;Taste patchen
                movea.l -8(A1),A2                 ;normale Tabelle
init8:          moveq   #0,D0
                move.b  3(A0),D0                  ;ASCII-Code aus der Tabelle holen
                move.b  0(A2,D0.w),1(A0)          ;ASCII-Code kopieren
init9:          addq.l  #4,A0                     ;Zeiger auf die n„chste Taste
                bra.s   init7

init10:         move.w  #$22,-(SP)
                trap    #14
                addq.l  #2,SP
                movea.l D0,A0
                lea     kbdvbase(A4),A1
                moveq   #8,D0
init11:         move.l  (A0)+,(A1)+               ;Retten
                dbra    D0,init11

                pea     -1.w
                move.w  #$23,-(SP)
                trap    #14                       ;Kbrate()
                addq.l  #6,SP
                move.w  D0,kbd_r_init(A4)         ;Originalwerte nehmen

************************************************************************
* Vektoren retten/setzen                                               *
************************************************************************
                move.l  $84.w,old_gemdos
                move.l  $88.w,old_aesvdi
                move.l  $B4.w,old_bios
                move.l  $B8.w,old_xbios
                move.l  $0404.w,old_critic
                bsr     set_vek

                move.b  #2,find_cont0(A4)         ;CONT verbieten
                move.w  #1,dsk_sektor(A4)         ;Defaults für Sektor lesen/schreiben
                move.l  #sekbuff,D0
                add.l   A4,D0
                move.l  D0,dsk_adr(A4)            ;für Sektor-Read
                move.l  first_free(A4),dsk_adr2(A4) ;für Track-Read

                lea     merk_internal(A4),A0      ;$2334
                moveq   #15,D0
init12:         move.b  D0,$FFFF8800.w
                move.b  $FFFF8800.w,(A0)+         ;Sound-Chip-Register merken
                dbra    D0,init12
                lea     regtabl(PC),A2
                moveq   #20,D0
init13:         movea.w (A2)+,A1
                move.b  (A1),(A0)+                ;sonstige Register merken
                dbra    D0,init13

                clr.b   merk_user(A4)             ;$2408
                move.l  first_free(A4),default_adr(A4) ;als Default-Adresse
                move.l  #'*.*'<<8,dir_ext(A4)     ;Directory-Puffer mit '*.*' belegen
                movea.l #trace_buff,A0
                adda.l  A4,A0
                move.l  A0,trace_pos(A4)          ;Position im Tracebuffer
                move.l  A0,reg_pos(A4)
                movea.l #user_trace_buf,A0
                adda.l  A4,A0
                move.l  #$70004E75,(A0)           ;MOVEQ #0,D0:RTS
                jsr     clr_cache
                clr.l   untrace_funk(A4)          ;Text der Abbruchfunktion l”schen
                lea     code_tab,A0
                moveq   #-1,D0
init14:         addq.l  #1,D0
                move.w  D0,D1
                lsl.w   #4,D1
                tst.b   0(A0,D1.w)
                bpl.s   init14
                move.w  D0,tablen(A4)
                rts
               ;>ENDPART
********************************************************************************
* Alles zurück                                                                 *
********************************************************************************
               ;>PART 'reset_all'
copy_sys_vars:  move.l  $04BA.w,D1
                lea     save_data(A4),A0
                lea     8.w,A1
                move.w  #361,D0
copy_sys_vars1: move.l  (A0)+,(A1)+               ;Speicherblock zurück
                dbra    D0,copy_sys_vars1
                move.l  hz200_time(A4),D0
                cmp.l   D0,D1
                bhs.s   copy_sys_vars2            ;Timer-Unterlauf verhindern (Harddisk!)
                move.l  D0,D1
copy_sys_vars2: move.l  D1,hz200_time(A4)
                move.l  D1,$04BA.w                ;für Harddisk wichtig!
                rts

reset_all:      ori     #$0700,SR                 ;Alles Sperren

                moveq   #$13,D0
                jsr     @ikbd_send(A4)            ;Keyboard aus

                bsr.s   copy_sys_vars

                tst.b   resident(A4)
                beq.s   reset_all1
                lea     @_trap3(A4),A0
                move.l  A0,$8C.w                  ;eigenen Trap einsetzen
reset_all1:     bsr     kill_programm             ;evtl. geladenes Prg entfernen

                ori     #$0700,SR                 ;Alles Sperren
                lea     merk_internal(A4),A0
                moveq   #15,D0
reset_all2:     move.b  D0,$FFFF8800.w
                move.b  (A0)+,$FFFF8802.w         ;Sound-Chip-Register zurück
                dbra    D0,reset_all2
                lea     regtabl(PC),A2
                moveq   #20,D0
reset_all3:     movea.w (A2)+,A1                  ;sonstige Register zurück
                move.b  (A0)+,(A1)
                dbra    D0,reset_all3

                bsr     ikbd_reset                ;Keyboard-Reset
                move.b  #3,$FFFFFC04.w            ;MIDI-Reset
                move.b  #$95,$FFFFFC04.w

                move.w  #$22,-(SP)
                trap    #14
                addq.l  #2,SP
                movea.l D0,A1
                lea     kbdvbase(A4),A0
                moveq   #8,D0
reset_all4:     move.l  (A0)+,(A1)+               ;und wieder zurück
                dbra    D0,reset_all4

                bsr     update_pc

                lea     init_scr(A4),A0
                lea     no_overscan(A4),A1
                bsr     restore_scr

                moveq   #$80,D0
                jsr     @ikbd_send(A4)
                moveq   #1,D0                     ;Keyboard-RESET
                jmp     @ikbd_send(A4)
               ;>ENDPART
********************************************************************************
* Vektoren setzen                                                              *
********************************************************************************
               ;>PART 'set_vek'
set_vek:        lea     etv_critic(PC),A0
                move.l  A0,$0404.w                ;Neuer etv_critic-Handler
               IFEQ symtab ;^^SYMTAB
                bsr.s   set_spez_vek              ;Fehlervektoren rein
                IFEQ ultradev
                move.l  #$31415926,$0426.w        ;Resvalid setzen
                move.l  #do_reset,$042A.w         ;Reset-Vektor umbiegen
                ELSE
                CHECKEXTENSION_HASUD .hasUD
                move.l  #$31415926,$0426.w        ;Resvalid setzen
                move.l  #do_reset,$042A.w         ;Reset-Vektor umbiegen
.hasUD:
                ENDC
                lea     swv_vec(PC),A0
                move.l  A0,$046E.w                ;Neuer Vektor für Monitorumschaltung
               ENDC
                rts
               ;>ENDPART
********************************************************************************
* Fehlervektoren einsetzen                                                     *
********************************************************************************
               ;>PART 'set_spez_vek'

set_spez_vek:   lea     except_start+8(PC),A0
                lea     $08.w,A1
                movea.l $5C.w,A2                  ;ein sicherer Abgang...
                movea.l $04F2.w,A3
                movea.l 8(A3),A3                  ;Ptr auf das ROM
                moveq   #2,D1
set_spez_vek1:  moveq   #7,D2
                and.w   D1,D2                     ;Bitposition isolieren
                moveq   #7,D4                     ;Bit 7..0 in
                sub.w   D2,D4                     ;Bit 0..7 umrechnen
                move.w  D1,D3
                lsr.w   #3,D3                     ;Byteposition ermitteln
                btst    D4,set_spez_tab(PC,D3.w)
                bne.s   set_spez_vek3
                tst.b   tt_flag(A4)               ;ein TT?
                bne.s   set_spez_vek2             ;Ja! =>
                tst.b   (A1)                      ;Vektor schon belegt?
                bne.s   set_spez_vek3             ;Sicher nein! =>
set_spez_vek2:  cmpa.l  (A1),A2                   ;Vektor zeigt auf Bomben?
                bne.s   set_spez_vek4             ;Nein! =>
set_spez_vek3:  cmpa.w  #$2C,A1                   ;Line-F?
                beq.s   set_spez_vek4             ;dann nix tun =>
                move.l  (A1),(A0)+
                move.l  A0,(A1)                   ;in den Vektor einklinken
                subq.l  #4,A0
set_spez_vek4:  lea     22(A0),A0                 ;Routine berspringen
                addq.l  #4,A1                     ;zum n„chsten Vektor
                addq.w  #1,D1
                cmp.w   #64,D1
                bne.s   set_spez_vek1
                tst.b   tt_flag(A4)               ;ein TT?
                beq.s   set_spez_vek5             ;Nein! =>
                lea     old_privileg(PC),A1
                movea.l $20.w,A0                  ;jetziger Vektor (zeigt in den Bugaboo!)

                move.l  A0,own_privileg7+2-old_privileg(A1)
                move.l  -(A0),(A1)+               ;alten Vektor für XBRA kopieren
                move.l  A1,$20.w                  ;eigener Vektor für Privileg-Verletzung
set_spez_vek5:  rts

set_spez_tab:  DC.B %11111111                     ;$00-$1C   Bit = 1 : Vektor stets belegen
               DC.B %11001111                     ;$20-$3C
               DC.B %11111111                     ;$40-$5C   Bit = 0 : Vektor nur bei Bedarf belegen
               DC.B %11010111                     ;$60-$7C
               DC.B %0                            ;$80-$9C
               DC.B %0                            ;$A0-$BC
               DC.B %11111111                     ;$C0-$DC
               DC.B %11111111                     ;$E0-$FC
               ;>ENDPART
********************************************************************************
* Register, welche bei RESET neu gesetzt werden müssen                         *
********************************************************************************
regtabl:       DC.W $8001,$FA01,$FA03,$FA05,$FA07
               DC.W $FA09,$FA0B,$FA0D,$FA0F,$FA11,$FA13,$FA15,$FA17
               DC.W $FA19,$FA1B,$FA1D,$FA27,$FA29,$FA2B,$FA2D,$FA2F
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
               DC.W $8007
f030_regtabl:  DC.W $8282,$8284,$8286,$8288
               DC.W $828A,$828C,$828E,$8290
               DC.W $82A2,$82A4,$82A6,$82A8
               DC.W $82AA,$82AC,$82C0,$8260
               DC.W $8266,$8210,$82C2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


********************************************************************************
* RESET-Vektor (D0,A0,A5-A6 sind ungültig)                                     *
********************************************************************************
               ;>PART 'do_reset'
reset_txt:     DC.B '?RESET',13,0
               EVEN

do_reset:       lea     varbase(PC),A0            ;A0 ist sowieso hin
                move    SR,_sr(A0)                ;S=1,T=0
                movem.l D0-A6,regs(A0)            ;D0,A0,A5,A6 sind ver„ndert worden
                movea.l A0,A4                     ;Varbase richtig setzen
                move    USP,A0
                move.l  A0,_usp(A4)               ;Der ist auch unver„ndert
                clr.l   $0426.w                   ;Reset-Valid killen
                move.l  save_data+1178(A4),$04A2.w
                movea.l default_stk(A4),SP        ;Stackpointer zurückholen
                lea     merk_internal(A4),A0
                moveq   #15,D0
do_reset1:      move.b  D0,$FFFF8800.w
                move.b  (A0)+,$FFFF8802.w         ;Sound-Chip-Register zurück
                dbra    D0,do_reset1
                lea     regtabl(PC),A2
                moveq   #20,D0
do_reset2:      movea.w (A2)+,A1                  ;sonstige Register zurück
                move.b  (A0)+,(A1)
                dbra    D0,do_reset2

                move.b  #3,$FFFFFC00.w            ;Keyboard-Reset
                move.b  #$96,$FFFFFC00.w
                move.b  #3,$FFFFFC04.w            ;MIDI-Reset
                move.b  #$95,$FFFFFC04.w

                move.b  $FFFFFA01.w,D0            ;Farbmonitor?
                bmi.s   do_reset6                 ;Ja! =>
                lea     $FFFFFA21.w,A0            ;Timer B Data-Register
                lea     $FFFFFA1B.w,A1            ;Timer B Control-Register
                move.b  #$10,(A1)                 ;Timer B Ausgangspegel low setzen
                moveq   #1,D4
                move.b  #0,(A1)                   ;Timer B stoppen
                move.b  #240,(A0)                 ;Timer B auf 240 setzen
                move.b  #8,(A1)                   ;Timer B: Ereignisz„hlung
do_reset3:      move.b  (A0),D0
                cmp.b   D4,D0                     ;Z„hler = 1?
                bne.s   do_reset3                 ;Nein! =>
do_reset4:      move.b  (A0),D4                   ;Startwert lesen
                move.w  #615,D3                   ;616 mal muž der Wert konstant bleiben
do_reset5:      cmp.b   (A0),D4                   ;immer noch konstant?
                bne.s   do_reset4                 ;Nein! => nochmal
                dbra    D3,do_reset5              ;n„chster Durchlauf
                move.b  #$10,(A1)                 ;Timer B Ausgang low
                move.b  #2,$FFFF8260.w            ;monochrom setzen

do_reset6:      lea     no_overscan(A4),A1
                lea     init_scr(A4),A0
                bsr     restore_scr

                moveq   #$80,D0
                jsr     @ikbd_send(A4)
                moveq   #1,D0                     ;Keyboard-RESET
                jsr     @ikbd_send(A4)

                jsr     @cursor_off(A4)           ;Cursor aus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                move.w  #1999,D0
do_reset7:      clr.l   (A0)+                     ;Die Hires l”schen
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D0,do_reset7
                jsr     @redraw_all(A4)           ;Bildschirm neu aufbauen
                tst.w   spalte(A4)
                beq.s   do_reset8
                jsr     @crout(A4)                ;CR ausgeben, falls der Cursor nicht Spalte 0
do_reset8:      jsr     @c_eol(A4)                ;Zeile l”schen
                pea     reset_txt(PC)
                jsr     @print_line(A4)           ;Mal 'ne kleine Message
                bsr     breakclr                  ;eventuelle Breakpoints entfernen
                jsr     @page1(A4)                ;Debuggerscreen an
                clr.b   kbshift(A4)
                move.l  #$31415926,$0426.w        ;Resvalid setzen
                move.l  #do_reset,$042A.w         ;Reset-Vektor umbiegen
                jmp     (A4)
               ;>ENDPART

********************************************************************************
* Originalen Busfehler-Vektor wieder einsetzen                                 *
********************************************************************************
               ;>PART 'set_buserror'
set_buserror:   move.l  #except_start+12,$08.w
                rts
               ;>ENDPART

********************************************************************************
* Eigener Tastaturtreiber (bei Bedarf) an.                                     *
********************************************************************************
               ;>PART 'my_driver'
my_driver:      move    SR,-(SP)
                ori     #$0700,SR
                movem.l D0-A6,-(SP)
                lea     varbase(PC),A4
                tst.b   do_resident(A4)           ;nicht installieren, wenn resident
                bne     my_driver8                ;gewünscht ist

                lea     merk_user(A4),A0
                tas.b   (A0)+
                bne.s   my_driver3                ;Treiber sind schon drin
                moveq   #15,D0
my_driver1:     move.b  D0,$FFFF8800.w
                move.b  $FFFF8800.w,(A0)+         ;Sound-Chip-Register merken
                dbra    D0,my_driver1

                lea     regtabl(PC),A2
                moveq   #20,D0
my_driver2:     movea.w (A2)+,A1
                move.b  (A1),(A0)+                ;MFP Register (+GLUE) merken
                dbra    D0,my_driver2

                lea     $FFFF8800.w,A0
                lea     $FFFF8802.w,A1
                move.b  #7,(A0)
                move.b  D0,(A1)                   ;Tongeneratoren aus (D0=-1 s.o.)
                moveq   #0,D0
                move.b  #8,(A0)
                move.b  D0,(A1)
                move.b  #9,(A0)                   ;alle Lautst„rken auf Null
                move.b  D0,(A1)
                move.b  #10,(A0)
                move.b  D0,(A1)

                lea     $FFFFFA01.w,A0
                moveq   #0,D0
                movep.l D0,0(A0)
                movep.l D0,8(A0)
                movep.l D0,$10(A0)
                move.b  #$48,$FFFFFA17.w
                bset    #2,2(A0)
                move.b  #$C0,$FFFFFA23.w          ;Timer C auf 200Hz programmieren
                ori.b   #$50,$FFFFFA1D.w          ;Timer C starten

                moveq   #$60,D0
                move.b  D0,$FFFFFA09.w            ;Hz200 & Keyboard freigeben
                move.b  D0,$FFFFFA15.w

                bsr     ikbd_reset

my_driver3:     lea     mfp_irq(PC),A2
                cmpa.l  $0118.w,A2
                beq.s   my_driver4
                moveq   #6,D0
                bsr     install_irq
                lea     spez_keyb(PC),A2
                cmpa.l  A0,A2
                beq.s   my_driver4
                move.l  A0,old_spez_keyb
                move.l  A0,old_ikbd
                clr.b   kbstate(A4)
                clr.b   kbd_repeat_on(A4)

my_driver4:     lea     hz200_irq(PC),A2
                cmpa.l  $0114.w,A2
                beq.s   my_driver5
                moveq   #5,D0
                bsr     install_irq
                move.l  A0,old_hz200

my_driver5:     bsr     clr_keybuff
                andi.b  #$10,kbshift(A4)
                moveq   #$80,D0
                jsr     @ikbd_send(A4)            ;Keyboard-RESET
                moveq   #1,D0
                jsr     @ikbd_send(A4)
                move.b  $FFFFFC00.w,D0
                bpl.s   my_driver6
                move.b  $FFFFFC02.w,D0
                nop
                move.b  $FFFFFC02.w,D0
                nop
                move.b  $FFFFFC02.w,D0
                nop
                move.b  $FFFFFC02.w,D0
                nop
                move.b  $FFFFFC02.w,D0
                nop
my_driver6:     andi.b  #$9F,$FFFFFA11.w          ;200Hz-Timer & Keyboard freigeben
                move.l  $70.w,D0
                lea     my_vbl(PC),A0
                cmpa.l  D0,A0
                beq.s   my_driver7
                move.l  D0,old_vbl
                move.l  A0,$70.w

my_driver7:     lea     etv_critic(PC),A0
                movea.l $0404.w,A1
                cmpa.l  A1,A0
                beq.s   my_driver8
                move.l  A1,old_critic
                move.l  A0,$0404.w
my_driver8:     movem.l (SP)+,D0-A6
                move    (SP)+,SR
                rts
ikbd_reset:     moveq   #0,D1                     ;OverScan aus
                lea     debugger_scr(A4),A0
                bsr     check_screen              ;der Debugger-Screen an?
                beq.s   ikbd_reset1               ;Ja! =>
                move.w  overscan(A4),D1           ;OverScan
                lsl.w   #6,D1                     ;$00:kein OverScan, $40:OverScan
ikbd_reset1:    moveq   #3,D0
                or.b    D1,D0
                move.b  D0,$FFFFFC00.w            ;Keyboard-Reset
                moveq   #$96,D0
                or.b    D1,D0
                move.b  D0,$FFFFFC00.w
                rts
               ;>ENDPART
********************************************************************************
* Originaler Tastaturtreiber an.                                               *
********************************************************************************
               ;>PART 'org_driver'
org_driver:     move    SR,-(SP)
                ori     #$0700,SR
                movem.l D0-A6,-(SP)
                lea     varbase(PC),A4
                moveq   #6,D0
org_driver1:    move    #$2300,SR
org_driver2:    tst.b   kbstate(A4)               ;noch ein Paket unterwegs?
                bne.s   org_driver2               ;Ja! => warten
                move    #$2700,SR                 ;IRQs aus
                tst.b   kbstate(A4)               ;gerade noch ein Paket?
                bne.s   org_driver1               ;Ja! => weiter warten
                movea.l old_spez_keyb(PC),A2
                tst.w   shift_flag(A4)
                bne.s   org_driver3
                lea     spez_keyb(PC),A2
org_driver3:    bsr.s   install_irq               ;IKBD-Vektor
                moveq   #5,D0
                movea.l old_hz200(PC),A2
                bsr.s   install_irq               ;200Hz-Timer
                bsr     clr_keybuff
                move.l  old_vbl(PC),$70.w         ;VBL-Vektor
                move.l  old_critic(PC),$0404.w

                lea     merk_user(A4),A0
                clr.b   (A0)+                     ;Treiber nun draužen
                moveq   #15,D0
org_driver4:    move.b  D0,$FFFF8800.w
                move.b  (A0)+,$FFFF8802.w         ;Sound-Chip-Register zurück
                dbra    D0,org_driver4

                lea     regtabl(PC),A2
                moveq   #20,D0
org_driver5:    movea.w (A2)+,A1                  ;sonstige Register zurück
                move.b  (A0)+,(A1)
                dbra    D0,org_driver5

                lea     ikbd_string(A4),A0        ;String zum Keyboard?
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   org_driver7
                subq.w  #1,D0
org_driver6:    move.b  (A0)+,D0
                jsr     @ikbd_send(A4)            ;zum Keyboard
                dbra    D0,org_driver6

org_driver7:    tst.w   ring_flag(A4)             ;Ring-Indikatortest?
                bne.s   org_driver8               ;Nein =>
                moveq   #14,D0
                bsr.s   enable_irq                ;Ring-Indikator erlauben
org_driver8:    movea.l save_clrkbd(A4),A0
                clr.b   (A0)                      ;Auto-Repeat-Taste l”schen!
                movem.l (SP)+,D0-A6
                move    (SP)+,SR
                rts
               ;>ENDPART

********************************************************************************
* MFP-Routinen                                                                 *
********************************************************************************
********************************************************************************
* MFP Interruptvektor setzen                                                   *
* D0 = Vektornummer                                                            *
* A2 = Adresse der neuen IRQ-Routine                                           *
* >A0 = Adresse der alten IRQ-Routine                                          *
********************************************************************************
               ;>PART 'install_irq'
install_irq:    movem.l D0-D2/A1-A2,-(SP)
                bsr.s   disable_irq
                move.l  D0,D2
                lsl.w   #2,D2
                addi.l  #$0100,D2
                movea.l D2,A1
                movea.l (A1),A0                   ;alten Vektor merken
                move.l  A2,(A1)                   ;neuen Vektor setzen
                bsr.s   enable_irq
                movem.l (SP)+,D0-D2/A1-A2
                rts
               ;>ENDPART
********************************************************************************
* MFP-IRQ D0 sperren                                                           *
********************************************************************************
               ;>PART 'disable_irq'
disable_irq:    movem.l D0-D1/A0-A1,-(SP)
                lea     $FFFFFA01.w,A0
                lea     $12(A0),A1
                bsr.s   bselect
                bclr    D1,(A1)
                lea     6(A0),A1
                bsr.s   bselect
                bclr    D1,(A1)
                lea     $0A(A0),A1
                bsr.s   bselect
                bclr    D1,(A1)
                lea     $0E(A0),A1
                bsr.s   bselect
                bclr    D1,(A1)
                movem.l (SP)+,D0-D1/A0-A1
                rts
               ;>ENDPART
********************************************************************************
* MFP-IRQ D0 freigeben                                                         *
********************************************************************************
               ;>PART 'enable_irq'
enable_irq:     movem.l D0-D1/A0-A1,-(SP)
                lea     $FFFFFA01.w,A0
                lea     6(A0),A1
                bsr.s   bselect
                bset    D1,(A1)
                lea     $12(A0),A1
                bsr.s   bselect
                bset    D1,(A1)
                movem.l (SP)+,D0-D1/A0-A1
                rts
               ;>ENDPART
********************************************************************************
* Bit/Registernummer für MFP bestimmen                                         *
********************************************************************************
               ;>PART 'bselect'
bselect:        move.b  D0,D1
                cmp.b   #8,D1
                blt.s   bselec1
                subq.w  #8,D1
                rts
bselec1:        addq.l  #2,A1
                rts
               ;>ENDPART
********************************************************************************
* Das war's für den MFP                                                       *
********************************************************************************

********************************************************************************
* Den Debuggerscreen einschalten                                               *
********************************************************************************
               ;>PART 'page1'
page1_force:    movem.l A0-A1/A4,-(SP)
                lea     debugger_scr(A4),A0
                bra.s   page10          ;skip UDMIRROR check, force switch
page1:          movem.l A0-A1/A4,-(SP)

                IFNE ultradev
                ;don't enable debugger screen if UDMIRROR is active
                tst.b   udmirror_enable(A4)
                bne.s   page11
                ENDC

                lea     varbase(PC),A4
                tst.b   do_resident(A4)           ;automatisch resident werden?
                bne.s   page11                    ;dann nicht umschalten
                lea     debugger_scr(A4),A0
                bsr.s   check_screen              ;ist der Debugger-Screen an?
                beq.s   page11                    ;Ja! =>
page10:                
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                pea     (A0)
                lea     f030_save_2532(A4),A0
                bsr     savef030regs
                movea.l (SP)+,A0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                lea     user_scr(A4),A1
                bsr.s   set_screen                ;den Debugger-Screen anschalten
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                lea     f030_save_24DC(A4),A0
                bsr     restoref030regs
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
page11:         movem.l (SP)+,A0-A1/A4
                rts
               ;>ENDPART
********************************************************************************
* Die Grafikseite des Fremdprogramms einschalten                               *
********************************************************************************
               ;>PART 'page2'
page2_force:    movem.l A0-A1/A4,-(SP)
                lea     user_scr(A4),A0
                bra.s   page20         ;skip UDMIRROR check, force switch
page2:          movem.l A0-A1/A4,-(SP)

                IFNE ultradev
                ;don't enable screen switch if UDMIRROR is active
                tst.b   udmirror_enable(A4)
                bne.s   page21
                ENDC

                lea     varbase(PC),A4
                lea     user_scr(A4),A0
                bsr.s   check_screen              ;ist der User-Screen an?
                beq.s   page21                    ;Ja! =>
page20:                
                lea     debugger_scr(A4),A1
                bsr.s   set_screen                ;den User-Screen anschalten
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                lea     f030_save_2532(A4),A0
                bsr     restoref030regs
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
page21:         movem.l (SP)+,A0-A1/A4
                rts
               ;>ENDPART

********************************************************************************
* OverScan an- bzw. ausschalten (D0=$40 bzw. D0=$00)                           *
********************************************************************************
;>rs_save        SET ^^RSCOUNT
rs_save        SET __RS
               RSRESET
scr_colors:    RS.W 16                            ;die 16 Farben
scr_adr:       RS.L 1                             ;die Videoadresse
scr_offset:    RS.B 1                             ;Offset to next line (STE only)
scr_hscroll:   RS.B 1                             ;Horizontal Bit-wise Scroll (STE only)
scr_rez:       RS.B 1                             ;die Video-Aufl”sung
scr_sync:      RS.B 1                             ;das Sync-Bit des Shifters
scr_moni:      RS.B 1                             ;der Monitor ($00:s/w $40:Farbe)
scr_overscan:  RS.B 1                             ;OverScan ($00:Ja $FF:Nein)
               RSEVEN
scr_struct     EQU __RS ;*-scr_colors ;>EQU ^^RSCOUNT                      ;Gr”že der Bildschirmstruktur
;>               RSSET rs_save
               RSSET rs_save
               ;>PART 'check_screen'                ;Seite der Struktur A0 aktiv?
check_screen:   move.l  D0,-(SP)
                bsr     get_scradr                ;die aktuelle Bildschirmadresse holen
                cmp.l   scr_adr(A0),D0            ;stimmt die Adresse?
                movem.l (SP)+,D0                  ;Z=1, wenn ja
                rts
               ;>ENDPART
               ;>PART 'set_screen'                  ;nach Struktur A1 retten, Struktur A0 setzen
set_screen:     bsr.s   save_scr                  ;Bildschirm-Werte nach A1 retten
                bra     restore_scr               ;ab A0 setzen
               ;>ENDPART
               ;>PART 'save_scr'                    ;Bildschirm-Parameter ab A1 retten
save_scr:       movem.l D0-D1/A2-A3,-(SP)
                move    SR,-(SP)
                ori     #$0700,SR                 ;alle IRQs sperren
                tst.w   smart_switch(A4)          ;normales Umschalten?
                beq.s   save_scr0                 ;Ja! =>
                bsr     vsync_test                ;Strahlrücklauf abwarten
save_scr0:      move.w  #$0777,D0                 ;3 Farbbits bei alten STs
                move.b  tt_flag(A4),D1
                or.b    ste_flag(A4),D1
                beq.s   save_scr1                 ;kein STE/TT =>
                move.w  #$0FFF,D0                 ;4 Farbbits beim STE bzw. TT
save_scr1:      lea     $FFFF8240.w,A2
                lea     scr_colors(A1),A3
                moveq   #15,D1
save_scr2:      move.w  (A2)+,(A3)
                and.w   D0,(A3)+                  ;Die Farben retten
                dbra    D1,save_scr2
                bsr     get_scradr
                move.l  D0,scr_adr(A1)            ;die aktuelle Videoadresse retten
                clr.b   scr_offset(A1)
                clr.b   scr_hscroll(A1)
                move.b  $FFFF820A.w,scr_sync(A1)  ;das Sync-Bit retten
                tst.b   tt_flag(A4)               ;ein TT?
                beq.s   save_scr3                 ;Nein =>
                moveq   #7,D0
                and.b   $FFFF8262.w,D0
                move.b  D0,scr_rez(A1)            ;die TT-Aufl”sung retten
                bra.s   save_scr5
save_scr3:      tst.b   ste_flag(A4)
                beq.s   save_scr4                 ;kein STE =>
                move.b  $FFFF820F.w,scr_offset(A1) ;Offset to next line
                move.b  $FFFF8265.w,scr_hscroll(A1) ;Horizontal Bit-wise Scroll
save_scr4:      moveq   #3,D0
                and.b   $FFFF8260.w,D0
                moveq   #2,D1
                cmp.b   D1,D0                     ;Wert gültig?
                bls.s   save_scr6                 ;Ja! =>
                move.w  D1,D0                     ;sonst ST-High annehmen
save_scr6:      move.b  D0,scr_rez(A1)            ;die aktuelle Aufl”sung retten
                moveq   #$80,D0
                and.b   $FFFFFA01.w,D0
                lsr.b   #1,D0
                move.b  D0,scr_moni(A1)           ;der aktuelle Monitor
save_scr5:      move    (SP)+,SR
                movem.l (SP)+,D0-D1/A2-A3
                rts
               ;>ENDPART
               ;>PART 'restore_scr'                 ;Bildschirm-Parameter ab A0 neu setzen (A1:alte Einstellung)
restore_scr:    tst.w   smart_switch(A4)          ;normales Umschalten?
                beq.s   restore_it                ;Ja! =>
                move.l  $70.w,-(SP)
                move    SR,-(SP)
                move.l  #restore_vbl,$70.w
                sf      restore_vbl_flag
                andi    #~$0700,SR                ;IRQs wieder an
restore_scr0:   tst.b   restore_vbl_flag          ;ber VBL umschalten
                beq.s   restore_scr0
                move    (SP)+,SR
                move.l  (SP)+,$70.w
                rts

restore_vbl_flag:DC.W 0
restore_vbl:    bsr.s   restore_it
                st      restore_vbl_flag
                rte

restore_it:     movem.l D0-A2,-(SP)
                move    SR,-(SP)
                ori     #$0700,SR                 ;alle IRQs sperren
                tst.w   overscan(A4)              ;OverScan aktiv?
                beq.s   restore_scr4              ;Nein! =>
                moveq   #$96,D0                   ;OverScan ausschalten
                tst.b   scr_overscan(A0)          ;OverScan benutzen?
                bne.s   restore_scr3              ;Nein! =>
                tst.w   smart_switch(A4)          ;im VBL geschaltet?
                bne.s   restore_it0               ;Ja! =>
                bsr     vsync_test                ;Strahlrücklauf abwarten
;Es ist wichtig, das noch einige Takte verlorengehen, bevor umgeschaltet wird,
;denn sonst wird gerade noch "rechtzeitig" umgeschaltet, d.h. es flackert immer!
restore_it0:    moveq   #0,D0
                cmpi.b  #2,scr_rez(A0)            ;SM124?
                bne.s   restore_scr1              ;Nein! =>
                moveq   #-1,D0
restore_scr1:   moveq   #15,D1
                lea     $FFFF8240.w,A2
restore_scr2:   move.w  D0,(A2)+                  ;alle Farben auf Schwarz
                dbra    D1,restore_scr2
                moveq   #$D6,D0                   ;OverScan anschalten
restore_scr3:   move.b  D0,$FFFFFC00.w            ;OverScan schalten
restore_scr4:   tst.b   tt_flag(A4)               ;ein TT?
                beq.s   restore_scr5              ;Nein! =>
                moveq   #$F8,D0
                and.b   $FFFF8262.w,D0
                or.b    scr_rez(A0),D0            ;Aufl”sung des TT setzen
                move.b  D0,$FFFF8262.w
                bra.s   restore_scr6
restore_scr5:   lea     $FFFF8800.w,A2
                move.b  #14,(A2)
                moveq   #$BF,D0
                and.b   (A2),D0                   ;den Monitor umschalten
                or.b    scr_moni(A0),D0
                move.b  D0,2(A2)
                move.b  scr_rez(A0),$FFFF8260.w   ;Neue Aufl”sung setzen
restore_scr6:   move.l  scr_adr(A0),D0
                bsr.s   set_scradr                ;neue Videoadresse setzen
                move.b  scr_sync(A0),$FFFF820A.w  ;neue Sync setzen
                tst.b   ste_flag(A4)
                beq.s   restore_scr7              ;kein STE =>
                move.b  scr_offset(A0),$FFFF820F.w ;Offset to next line
                move.b  scr_hscroll(A0),$FFFF8265.w ;Horizontal Bit-wise Scroll
restore_scr7:   movem.l scr_colors(A0),D0-D7
                movem.l D0-D7,$FFFF8240.w         ;und die Farben setzen
;!!!!!!!!!!!!!!!!!!!!!!
                tst.b   f030_flag(A4)
                beq.s   restore_nof030
                movea.l f030_save_25DE(A4),A0
                bsr     restoref030regs
restore_nof030:
;!!!!!!!!!!!!!!!!!!!!!!
                move    (SP)+,SR
                movem.l (SP)+,D0-A2
                rts
               ;>ENDPART

;!!!!!!!!!!!!!!!!!!!!!!!!!
set_scradr:     move.w  D1,-(SP)                  ;T0D91A
                move.b  D0,D1
                lsr.w   #8,D0
                move.l  D0,$FFFF8200.w
                tst.b   tt_flag(A4)
                bne.s   T0D936
                tst.b   ste_flag(A4)
                bne.s   T0D936
                tst.b   f030_flag(A4)
                beq.s   T0D93A
T0D936:         move.b  D1,$FFFF820D.w
T0D93A:         move.w  (SP)+,D1
                rts
;!!!!!!!!!!!!!!!!!!!!!!!!!

               ;>PART 'set_scradr'                  ;Bildschirmadresse in D0 setzen
;set_scradr:     tst.b   tt_flag(A4)     ;ein TT?
;               bne.s   set_scradr0     ;Ja! =>
;                tst.b   ste_flag(A4)    ;ein STE vorhanden?
;                beq.s   set_scradr1     ;Nein! =>
;set_scradr0:    move.b  D0,$FFFF820D.w  ;low-Byte setzen
;set_scradr1:    lsr.w   #8,D0
;                move.b  D0,$FFFF8203.w  ;mid-Byte setzen
;                swap    D0
;                move.b  D0,$FFFF8201.w  ;high-Byte setzen
;                rts
               ;>ENDPART
               ;>PART 'get_scradr'                  ;Bildschirmadresse nach D0 holen
get_scradr:     moveq   #0,D0
                move.b  $FFFF8201.w,D0            ;high-Byte holen
                swap    D0
                move.b  $FFFF8203.w,D0            ;mid-Byte holen
                lsl.w   #8,D0
                tst.b   tt_flag(A4)               ;ein TT?
                bne.s   get_scradr0               ;Ja! =>
                tst.b   ste_flag(A4)              ;ein STE vorhanden?
;!!!!!!!!!!!!!!!!!
;                beq.s   get_scradr1     ;Nein! =>
                bne.s   get_scradr0               ;Nein! =>
                tst.b   f030_flag(A4)
                beq.s   get_scradr1
;!!!!!!!!!!!!!!!!!
get_scradr0:    move.b  $FFFF820D.w,D0            ;low-Byte noch holen
get_scradr1:    rts
               ;>ENDPART
               ;>PART 'vsync_test'                  ;Austastlücke abwarten, OverScan testen
vsync_test:     move.b  $FFFF8203.w,D0            ;Anfangsadresse des Video-Bildes
                moveq   #$7D,D1
                add.b   D0,D1                     ;Endadresse des normalen Bildschirms
vsync_test1:    cmp.b   $FFFF8207.w,D1            ;Warten, bis der Videocounter am
                bne.s   vsync_test1               ;Ende angekommen ist
vsync_test2:    cmp.b   $FFFF8207.w,D1            ;und weiter warten, bis er sich
                beq.s   vsync_test2               ;wieder „ndert
                cmp.b   $FFFF8207.w,D0            ;= Anfangsadresse des Video-Bildes?
                rts
               ;>ENDPART

********************************************************************************
* Schaltet mittels TRAP #3 in den Supervisormodus                              *
********************************************************************************
               ;>PART '_trap3'
               DC.L 'XBRA'
               DC.L xbra_id
old_trap3:     DS.L 1
_trap3:         bset    #5,(SP)                   ;Supervisor-Mode an
                rte
               ;>ENDPART

********************************************************************************
* Interner Busfehler-Vektor                                                    *
********************************************************************************
               ;>PART 'intern_bus'
               DC.L 'XBRA'
               DC.L xbra_id
old_intern_bus:DS.L 1
intern_bus:     ori     #$0700,SR                 ;alle IRQs aus!
                lea     varbase(PC),A4
                movea.l default_stk(A4),SP        ;Stack wiederherstellen
                sf      assm_flag(A4)             ;alle Flags zurücksetzen
                sf      illegal_flg(A4)

                clr.l   prg_base(A4)
                sf      do_resident(A4)
                sf      do_resident(A4)
                sf      autodo_flag(A4)
                sf      fast_exit(A4)
                sf      testwrd(A4)               ;Ausgabe unbedingt auf den Schirm
                tst.w   spalte(A4)
                beq.s   int_bus
                jsr     @crout(A4)                ;CR nur bei Bedarf
int_bus:        bsr     breakclr                  ;Breakpoints entfernen
ill_mem:        pea     int_bus_txt(PC)
                jsr     @print_line(A4)
                jsr     @crout(A4)
                jmp     all_normal                ;Befehl abbrechen

               IFEQ sprache
int_bus_txt:   DC.B 'Illegaler Speicherbereich!',0
               ELSE
int_bus_txt:   DC.B 'Illegal memory!',0
               ENDC
               EVEN
               ;>ENDPART

********************************************************************************
* Druckertreiber                                                               *
********************************************************************************
********************************************************************************
* CR + LF zum Drucker                                                          *
********************************************************************************
               ;>PART 'prncr'
prncr:          moveq   #13,D0
                bsr.s   prnout
                moveq   #10,D0
               ;>ENDPART
********************************************************************************
* Zeichen in D0 zum Drucker                                                    *
********************************************************************************
               ;>PART 'prnout'
prnout:         movem.l D2/A6,-(SP)
                btst    #0,$FFFFFA01.w            ;Busy-Flag des Druckers
                bne.s   prnout4                   ;Drucker besetzt
                andi.w  #$FF,D0
                lea     $FFFF8800.w,A6
                st      $043E.w
                moveq   #7,D2
                move.b  D2,(A6)                   ;Datenrichtungsreg selektieren
                lsl.w   #8,D2
                move.b  2(A6),D2                  ;Inhalt holen
                bset    #7,D2                     ;Port B auf Ausgabe
                movep.w D2,0(A6)                  ;Datenrichtungsregister schreiben
                ori.w   #$0F00,D0
                movep.w D0,0(A6)                  ;Zeichen auf Port B ausgeben
                moveq   #$0E,D2
                move.b  D2,(A6)                   ;Port A selektieren
                lsl.w   #8,D2
                move.b  (A6),D2                   ;Register lesen
                bclr    #5,D2                     ;Strobe-Bit l”schen
                movep.w D2,0(A6)                  ;Strobe low
                moveq   #19,D0
prnout1:        dbra    D0,prnout1
                movep.w D2,0(A6)                  ;Strobe low
                moveq   #19,D0
prnout2:        dbra    D0,prnout2
                bset    #5,D2                     ;Strobe-Bit setzen
                movep.w D2,0(A6)                  ;Strobe high
                clr.w   $043E.w
prnout3:        btst    #0,$FFFFFA01.w            ;Busy-Flag des Druckers testen
                bne.s   prnout3                   ;Warten, bis Drucker fertig
                moveq   #-1,D0                    ;alles ok
                movem.l (SP)+,D2/A6
                rts
prnout4:        moveq   #0,D0                     ;Fehler (Drucker busy)
                movem.l (SP)+,D2/A6
                rts
               ;>ENDPART

********************************************************************************
* Keyboardtreiber                                                              *
********************************************************************************
********************************************************************************
* Zeichen in D0 zum Tastaturprozessor                                          *
********************************************************************************
               ;>PART 'ikbd_send'
ikbd_send:      movem.l D0-D1/A0,-(SP)
                move.w  #5000,D1
                lea     $FFFFFC00.w,A0
ikbd_send0:     move.b  (A0),D2                   ;wie im ROM...
                btst    #1,D2
                dbne    D1,ikbd_send0             ;allerdings mit: Timeout
                move.w  #950,D0
ikbd_send1:     bsr.s   ikbd_send2                ;noch 'ne kleine Verz”gerung
                dbra    D0,ikbd_send1
                movem.l (SP)+,D0-D1/A0
                move.b  D0,$FFFFFC02.w            ;und ab das Byte...
ikbd_send2:     rts
               ;>ENDPART
********************************************************************************
* Tastaturbuffer l”schen (nach dem Umschalten der Treiber n”tig)               *
********************************************************************************
               ;>PART 'clr_keybuff'
clr_keybuff:    sf      akt_maust(A4)
                sf      kbd_repeat_on(A4)
                move.w  #-1,maus_flag(A4)         ;Flag wieder zurücksetzen
                clr.b   maus_merk(A4)
                clr.b   maus_merk2(A4)
                move.l  $04BA.w,D0
                move.l  D0,maus_time2(A4)
                move.l  D0,maus_time(A4)
                clr.b   kbd_r_key(A4)
                clr.b   kbd_r_verz(A4)            ;alles l”schen
                clr.b   kbd_r_cnt(A4)
                clr.l   iorec_IKBD+4(A4)          ;Tastaturbuffer l”schen
                rts
               ;>ENDPART
********************************************************************************
* akt.Tastencode nach D0 holen                                                 *
********************************************************************************
               ;>PART 'conin'
conin:          movem.l D1-D2/A0-A1,-(SP)
                move.l  tmacro_pointer(A4),D0     ;TMacro aktiv?
                bne.s   conin7                    ;Ja! =>
conin0:         lea     iorec_IKBD(A4),A0
                moveq   #0,D0
                move    SR,-(SP)
                ori     #$0700,SR
                move.w  4(A0),D1
                cmp.w   6(A0),D1
                beq.s   conin2                    ;Abbruch, wenn keine Taste gedrückt
                addq.b  #4,D1
                movea.l (A0),A1
                move.l  0(A1,D1.w),D0             ;Tastaturcode holen
                tst.l   tmacro_def_key(A4)
                beq.s   conin10                   ;keine aktive TMacro-Definition
                btst    #4,kbshift(A4)            ;CAPS?
                bne.s   conin3                    ;dann ohne Wandlung raus
                cmp.l   tmacro_def_key(A4),D0     ;TMacro-Definitionstaste? (rekursiv)
                beq.s   conin30                   ;dann Ende (keine Taste)
conin10:        lea     tmacro_tab(A4),A1
conin4:         move.l  (A1),D2
                addq.l  #2,D2                     ;-2
                beq.s   conin3                    ;Ende der Tabelle, kein TMacro
                move.l  (A1)+,D2
                cmp.l   D2,D0
                beq.s   conin6                    ;TMacro gefunden
conin5:         move.l  (A1)+,D2
                addq.l  #1,D2                     ;TMacro berlesen (bis -1)
                bne.s   conin5
                bra.s   conin4                    ;n„chstes TMacro
conin3:         move.w  D1,4(A0)
conin2:         move    (SP)+,SR
conin20:        movem.l (SP)+,D1-D2/A0-A1
                tst.l   D0
                rts
conin30:        moveq   #0,D0                     ;keine Taste
                bra.s   conin3                    ;Ende

conin6:         move.l  (A1),D0                   ;neuer Tastencode
                move.w  D0,D2
                lsr.w   #8,D2
                and.w   #$7F,D2
                move.w  D2,tmacro_repeat(A4)      ;Anzahl der Wiederholungen
                and.w   #$80FF,D0
                move.l  A1,tmacro_pointer(A4)     ;Pointer merken
                bra.s   conin3                    ;Ende

conin7:         movea.l D0,A1
                subq.w  #1,tmacro_repeat(A4)      ;Anzahl der Wiederholungen-1
                bpl.s   conin9                    ;Immer noch??? =>
                addq.l  #4,A1                     ;Zeiger auf die n„chste Taste
                move.l  (A1),D0                   ;N„chste Taste des TMacro holen
                move.w  D0,D2
                lsr.w   #8,D2
                and.w   #$7F,D2
                move.w  D2,tmacro_repeat(A4)      ;Anzahl der Wiederholungen
                addq.l  #1,D0
                beq.s   conin8                    ;Ende des TMacro
conin9:         move.l  (A1),D0                   ;Tastencode nochmal holen
                and.w   #$80FF,D0
                move.l  A1,tmacro_pointer(A4)     ;neuen Pointer merken
                bra.s   conin20                   ;dat war's
conin8:         clr.l   tmacro_pointer(A4)        ;TMacro ist zuende
                bra     conin0                    ;n„chste Taste holen
               ;>ENDPART
********************************************************************************
* Keyboard-IRQ des Mfp                                                         *
********************************************************************************
               ;>PART 'mfp_irq'
               DC.L 'XBRA'
               DC.L xbra_id
old_ikbd:      DS.L 1
mfp_irq:        movem.l D0-D3/A0-A5,-(SP)
                lea     varbase(PC),A4
k_mfp1:         lea     $FFFFFC04.w,A1
                bsr.s   k_dokbd                   ;MIDI-IRQ
                subq.l  #4,A1
                bsr.s   k_dokbd                   ;Keyboard-IRQ
                btst    #4,$FFFFFA01.w
                beq.s   k_mfp1                    ;Noch ein IRQ?
                movem.l (SP)+,D0-D3/A0-A5
                bclr    #6,$FFFFFA11.w            ;IRQ wieder freigeben
                rte

k_dokbd:        movem.l D2/A1,-(SP)
                move.b  (A1),D2
                bpl.s   k_isys3                   ;IRQ-Request?
                btst    #0,D2                     ;Receiver-Buffer full?
                beq.s   k_isys2
                tst.w   midi_flag(A4)             ;MIDI-Tastatur?
                beq.s   k_isys1                   ;Ja! =>
                cmpa.w  #$FC00,A1                 ;Tastatur?
                beq.s   k_isys1                   ;dann normal
                move.b  2(A1),D0                  ;Dummy-Zeichen holen
                bra.s   k_isys2                   ;und Ende
k_isys1:        bsr.s   k_avint
k_isys2:        andi.b  #$20,D2
                beq.s   k_isys3
                move.b  2(A1),D0
k_isys3:        movem.l (SP)+,D2/A1
                rts
               ;>ENDPART
********************************************************************************
* Zeichen von ACIA holen                                                       *
********************************************************************************
               ;>PART 'k_avint'
k_avint:        move.b  2(A1),D0                  ;Zeichen holen

                tst.b   kbstate(A4)               ;Ein Paket ist im Anrollen
                bne.s   k_arpak

                and.w   #$FF,D0
                cmp.w   #$F6,D0
                blo     k_arkey                   ;Nur ne' Taste

                sub.w   #$F6,D0
                move.b  k_kbsta1(PC,D0.w),kbstate(A4)
                move.b  k_kbind1(PC,D0.w),kbindex(A4)

                addi.w  #$F6,D0
                cmpi.w  #$F8,D0
                blt.s   k_avin1
                cmpi.w  #$FB,D0
                bgt.s   k_avin1
                move.b  D0,maus_paket_2(A4)
k_avin1:        rts

k_kbsta1:      DC.B 1,2,3,3,3,3,4,5,6,6
k_kbind1:      DC.B 7,5,2,2,2,2,6,2,1,1

k_arpak:        cmpi.b  #6,kbstate(A4)
                bhs.s   k_arpk2                   ;Joystickdaten ignorieren
                lea     k_arjmt(PC),A2
                moveq   #0,D2
                move.b  kbstate(A4),D2
                subq.b  #1,D2
                mulu    #12,D2
                movea.l 0(A2,D2.w),A0
                adda.l  A4,A0
                movea.l 4(A2,D2.w),A1
                adda.l  A4,A1
                movea.l 8(A2,D2.w),A2             ;Adresse der Routine
                moveq   #0,D2
                move.b  kbindex(A4),D2
                suba.l  D2,A1
                move.b  D0,(A1)
                subq.b  #1,kbindex(A4)            ;Paket komplett?
                bne.s   k_arpk1                   ;N”!
                jsr     (A2)                      ;IRQ-Routine anspringen
k_arpk2:        clr.b   kbstate(A4)               ;Paketflag wieder freigeben
k_arpk1:        rts

k_arjmt:       DC.L stat_paket,maus_paket_1,k_arpk1
               DC.L maus_paket_1,maus_paket_2,mausvek
               DC.L maus_paket_2,zeit_paket,mausvek
               DC.L zeit_paket,joydat0,k_arpk1
               DC.L joydat0,joydat2,k_arpk1
               ;>ENDPART
               ;>PART 'k_arkey'
k_arkey:        move.b  kbshift(A4),D1
                cmp.b   #$2A,D0
                bne.s   k_ark1
                bset    #1,D1                     ;Shift (links) gedrückt
                bra.s   k_ark10
k_ark1:         cmp.b   #$AA,D0
                bne.s   k_ark2
                bclr    #1,D1                     ;Shift (links) losgelassen
                bra.s   k_ark10
k_ark2:         cmp.b   #$36,D0
                bne.s   k_ark3
                bset    #0,D1                     ;Shift (rechts) gedrückt
                bra.s   k_ark10
k_ark3:         cmp.b   #$B6,D0
                bne.s   k_ark4
                bclr    #0,D1                     ;Shift (rechts) losgelassen
                bra.s   k_ark10
k_ark4:         cmp.b   #$1D,D0
                bne.s   k_ark5
                bset    #2,D1                     ;Control gedrückt
                bra.s   k_ark10
k_ark5:         cmp.b   #$9D,D0
                bne.s   k_ark6
                bclr    #2,D1                     ;Control losgelassen
                bra.s   k_ark10
k_ark6:         cmp.b   #$38,D0
                bne.s   k_ark7
                bset    #3,D1                     ;Alternate gedrückt
                bra.s   k_ark10
k_ark7:         cmp.b   #$B8,D0
                bne.s   k_ark8
                bclr    #3,D1                     ;Alternate losgelassen
                moveq   #0,D3
                move.b  kbalt(A4),D3              ;Alternate-Zehnerblocktaste?
                beq.s   k_ark10
                move.b  D1,kbshift(A4)            ;Neuer kbshift-Status
                move.w  D3,D0                     ;als aktuelle ASCII-Code
                moveq   #0,D1                     ;KEIN Scancode!
                moveq   #0,D2                     ;kbshift ebenfalls l”schen
                bra     k_insert                  ;und in den Keyboardbuffer
k_ark8:         cmp.b   #$3A,D0
                bne.s   k_ark11
                lea     clickdata(PC),A0
                bsr     do_sound                  ;CAPS LOCK- Klick
                bchg    #4,D1                     ;Bit invertieren
k_ark10:        move.b  D1,kbshift(A4)            ;Neuer kbshift-Status
k_arkxx:        rts
k_ark11:        tst.b   D0
                bmi.s   k_ark13                   ;Taste losgelassen
                tst.b   kbd_r_key(A4)
                bne.s   k_ark12                   ;Ein Taste wird bereits wiederholt
                move.b  D0,kbd_r_key(A4)
                move.b  kbd_r_init(A4),kbd_r_verz(A4)
                move.b  kbd_r_rate(A4),kbd_r_cnt(A4)
                cmp.b   #$53,D0                   ;DELETE gedrückt?
                bne.s   k_arkin                   ;Nein? => Weg
                cmpi.b  #%1100,kbshift(A4)        ;CTRL+ALT = Warmstart des Debuggers
                beq.s   k_aaa10
                cmpi.b  #%1101,kbshift(A4)        ;CTRL+ALT+RSHFT = Cold-Boot
                bne.s   k_arkin
                bra     kill_all
k_aaa10:        movea.l 4.w,A0
                jmp     (A0)                      ;und ab geht die Post

k_ark12:        clr.b   kbd_r_verz(A4)            ;Zurücksetzen
                clr.b   kbd_r_cnt(A4)
                sf      kbd_repeat_on(A4)
                bra.s   k_arkin

k_ark13:        moveq   #0,D1
                move.b  D1,kbd_r_key(A4)
                move.b  D1,kbd_r_verz(A4)         ;alles l”schen
                move.b  D1,kbd_r_cnt(A4)
                tst.b   kbd_repeat_on(A4)
                beq.s   k_arkxx                   ;Nur l”schen, wenn kein Auto-Repeat
                sf      kbd_repeat_on(A4)
                bra     clr_keybuff

k_arkin:        btst    #0,conterm+1(A4)
                beq.s   k_arkii
                lea     clickdata(PC),A0
                bsr     do_sound                  ;CAPS LOCK- Klick
k_arkii:        moveq   #0,D1
                move.b  D0,D1                     ;Scancode merken
                movea.l std_keytab(A4),A0         ;Normale Tabelle
                and.w   #$7F,D0                   ;Bit für losgelassen l”schen
                moveq   #$0C,D2                   ;CTRL oder ALT gedrückt?
                and.b   kbshift(A4),D2
                bne.s   k_ark16                   ;dann nicht wandeln
                btst    #4,kbshift(A4)            ;CAPS LOCK aktiv?
                beq.s   k_ark14
                movea.l caps_keytab(A4),A0        ;Caps-Tastaturtabelle
k_ark14:        btst    #0,kbshift(A4)
                bne.s   k_ark15                   ;Shift links?
                btst    #1,kbshift(A4)
                beq.s   k_ark16                   ;Shift rechts?
k_ark15:        movea.l shift_keytab(A4),A0       ;Shift-Tastaturtabelle

k_ark16:        move.b  0(A0,D0.w),D0             ;Zeichen aus der Tabelle holen
;ASCII-Code in D0 / Scancode in D1

                btst    #3,kbshift(A4)            ;Alternate gedrückt?
                beq.s   k_arkbu                   ;N”
                lea     keyboard_tab-2(PC),A0
k_ark17:        addq.l  #2,A0
                move.b  (A0)+,D2
                beq.s   k_ark19                   ;Ende der Tabelle => raus
                cmp.b   D2,D1                     ;Scancode gefunden
                bne.s   k_ark17                   ;weiter suchen
                moveq   #3,D2
                and.b   kbshift(A4),D2
                sne     D2                        ;Wenn SHIFT-Taste gedrückt, dann
                ext.w   D2
                move.b  1(A0,D2.w),D0             ;neuen ASCII-Code holen
                bra.s   k_arkbu

               IFEQ sprache
keyboard_tab:  DC.B $1A,'\','@'
               DC.B $27,'{','['
               DC.B $28,'}',']'
               DC.B 0
               ENDC
               IF sprache==1
keyboard_tab:  DC.B $1A,'\','@'
               DC.B $27,'{','['
               DC.B $28,'}',']'
               DC.B 0
               ENDC
               IF sprache==2
keyboard_tab:  DC.B $1A,'{','['
               DC.B $1B,'}',']'
               DC.B $28,0,'\'
               DC.B $2B,'~','@'
               DC.B 0
               ENDC
               EVEN

k_ark19:        cmp.b   #$62,D1
                bne.s   k_arkbu                   ;Help
                moveq   #3,D2
                and.b   kbshift(A4),D2            ;SHIFT?
                beq.s   k_ark1y                   ;=>
                move.b  _dumpflg(A4),D0
                subq.b  #1,D0
                beq.s   k_ark1y
                sf      _dumpflg(A4)              ;Hardcopy ausl”sen
k_ark1y:        andi.b  #$10,kbshift(A4)
                rts
k_arkbu:        and.w   #$FF,D1                   ;nur die unteren 8 Bits interessieren
                moveq   #0,D3
                moveq   #0,D2
                move.b  kbshift(A4),D2
                bclr    #4,D2                     ;CAPS/LOCK weg
                btst    #3,D2                     ;Alternate gedrückt?
                beq.s   k_arkbt                   ;Nein!
                cmp.b   #103,D1                   ;Tasten 0-9 am Zehnerblock gedrückt?
                blo.s   k_arkbt
                cmp.b   #112,D1
                bhi.s   k_arkbt
                subi.b  #'0',D0
                move.b  kbalt(A4),D3              ;alten Alternate-Wert holen
                mulu    #10,D3                    ;Zehnerposition nach links
                add.b   D0,D3                     ;neuen Wert rein
                cmp.w   #256,D3                   ;šberlauf?
                blo.s   k_arkbq
                moveq   #0,D3                     ;wenn ja, dann l”schen
k_arkbq:        move.b  D3,kbalt(A4)
                bra.s   k_arkex                   ;Abbruch
k_arkbt:        bclr    #1,D2                     ;Nur eine Shift-Taste weiterleiten
                beq.s   k_arkbv
                bset    #0,D2
k_arkbv:        cmp.b   #$3B,D1                   ;kleiner F1

                blo.s   k_arkbw
                cmp.b   #$44,D1                   ;gr”žer F10
                bhi.s   k_arkbw                   ;dann Abbruch
                subi.b  #$3B,D1
                move.w  D1,D0                     ;In den ASCII-Code
                moveq   #0,D1                     ;Scan-Code nun l”schen
                ori.b   #$80,D2                   ;F-Tastenflag ins kbshift
                btst    #0,D2                     ;Shift?
                beq.s   k_insert                  ;Nein!
                addi.w  #10,D0                    ;für F-Tasten mit Shift + 10
                andi.b  #$FE,D2                   ;Shift killen
                bra.s   k_insert
k_arkbw:        moveq   #$0C,D3
                and.b   D2,D3                     ;Alternate oder Control?
                beq.s   k_insert                  ;Anscheinend nicht!
                cmp.b   #2,D1
                blo.s   k_arkbx                   ;'1'
                cmp.b   #13,D1
                bhi.s   k_arkbx                   ;bis "'"
                subq.w  #2,D1
                move.w  D1,D0
                ori.w   #$8000,D0                 ;Flag für Marker-Tasten
                moveq   #0,D1                     ;Scancode l”schen
                bra.s   k_insert
k_arkbx:        cmp.b   #41,D1
                bne.s   k_insert                  ;'#'
                move.w  #$800C,D0                 ;s.o., nur alles auf einmal
                moveq   #0,D1                     ;Scancode l”schen
k_insert:       cmp.b   #$72,D1                   ;Enter?
                bne.s   k_arkby
                moveq   #$1C,D1                   ;Scancode für Return nehmen
k_arkby:        asl.w   #8,D2                     ;kbshift in die Bits 8-15
                or.w    D1,D2                     ;Scancode rein
                swap    D2                        ;ab in das obere Word
                or.w    D0,D2                     ;ASCII-Code reinmaskieren
                move.l  D2,D0
                bsr.s   into_kbd_buff
                beq.s   k_arkex                   ;Zeichen wurde nicht angenommen
                clr.b   kbalt(A4)                 ;Alternate-Taste l”schen
k_arkex:        rts
               ;>ENDPART
********************************************************************************
* Tastencode in D0 in den Keyboard-Buffer eintragen (Z=1 => kein Platz)        *
********************************************************************************
               ;>PART 'into_kbd_buff'
into_kbd_buff:  movem.l D0-D1/A0-A1,-(SP)
                tst.b   tmacro_def_flag(A4)       ;Taste nach Control-ESC?
                bne     into_kbd_buff50           ;ja! =>
                lea     iorec_IKBD(A4),A0
                move.w  6(A0),D1                  ;Tail-Index
                addq.b  #4,D1                     ;plus 4 (Gr”že eines Eintrags)
                cmp.w   4(A0),D1                  ;= Head-Index?
                beq     into_kbd_buff2            ;dann beenden
                movea.l (A0),A1                   ;Pufferadr holen
                cmp.l   #$0801001B,D0             ;Alt-ESC?
                beq.s   into_kbd_buff13           ;nicht bernehmen
                cmp.l   #$0401001B,D0             ;Control-ESC?
                beq.s   into_kbd_buff13           ;nicht bernehmen
                move.l  D0,0(A1,D1.w)             ;Tastencode eintragen
                move.w  D1,6(A0)                  ;Tail-Index neu setzen
into_kbd_buff13:tst.l   tmacro_def_key(A4)        ;TMacro-Definition aktiv
                beq.s   into_kbd_buff5            ;Nein! =>

                cmp.l   #$0801001B,D0             ;Alt-ESC
                bne.s   into_kbd_buff12
                movea.l tmacro_def_adr(A4),A0
                moveq   #-1,D1                    ;TMacro-Definition abschliežen
                move.l  D1,(A0)
                lea     tmacro_tab(A4),A0
into_kbd_buff14:move.l  (A0)+,D1                  ;Tabellenende suchen
                addq.l  #2,D1
                bne.s   into_kbd_buff14
                move.l  4(A0),D0
                addq.l  #1,D0                     ;TMacro l”schen?
                beq.s   into_kbd_buff16           ;ja! =>
into_kbd_buff15:move.l  (A0),-4(A0)               ;Tabellenende (-2) berkopieren
                move.l  (A0)+,D1
                addq.l  #1,D1
                bne.s   into_kbd_buff15
                moveq   #-2,D1
                move.l  D1,-(A0)                  ;neues Tabellenende setzen
into_kbd_buff16:clr.l   tmacro_def_key(A4)
                clr.l   tmacro_def_adr(A4)
                bra     into_kbd_buff3            ;Ende und raus (Puuuuuhhhhh!)

into_kbd_buff12:movea.l tmacro_def_adr(A4),A0
                cmp.l   -4(A0),D0                 ;gleiche Taste wie zuvor?
                bne.s   into_kbd_buff4            ;Nein! =>
                addq.b  #1,-2(A0)                 ;sonst nur die Anzahl erh”hen
                bpl.s   into_kbd_buff3            ;max.Anzahl (128) noch nicht erreicht
                move.b  #$7F,-2(A0)               ;max.Anzahl setzen und neuen Eintrag
into_kbd_buff4: lea     tmacro_tab_end(A4),A1
                cmpa.l  A1,A0                     ;Tabellenende erreicht?
                bhs.s   into_kbd_buff3            ;dann Tastencode nicht mehr nehmen
                move.l  D0,(A0)+                  ;Tastencode merken
                move.l  A0,tmacro_def_adr(A4)     ;erh”hten Pointer merken
                bra.s   into_kbd_buff3

into_kbd_buff5: cmp.l   #$0401001B,D0             ;Control-ESC
                bne.s   into_kbd_buff3            ;Nein! =>
                st      tmacro_def_flag(A4)       ;auch zu belegende Taste warten
                bra.s   into_kbd_buff3            ;raus hier =>

into_kbd_buff50:tst.l   D0
                beq.s   into_kbd_buff3
                cmp.l   #$0401001B,D0             ;Control-ESC
                beq.s   into_kbd_buff3            ;dat wird ignoriert
                cmp.l   #$0801001B,D0             ;Alt-ESC
                beq.s   into_kbd_buff3            ;dat wird auch ignoriert
                sf      tmacro_def_flag(A4)
                lea     tmacro_tab(A4),A0
                suba.l  A1,A1
into_kbd_buff8: move.l  (A0),D1
                addq.l  #2,D1                     ;Ende der Tabelle gefunden
                beq.s   into_kbd_buff7            ;ja! =>
                cmp.l   (A0)+,D0                  ;gibt's schon ein Macro mit dieser Taste?
                bne.s   into_kbd_buff10           ;nein! =>
                lea     -4(A0),A1                 ;Pointer merken
into_kbd_buff10:move.l  (A0)+,D1
                addq.l  #1,D1                     ;TMacro berlesen (bis -1)
                bne.s   into_kbd_buff10
                move.l  A1,D1
                beq.s   into_kbd_buff8            ;n„chstes TMacro
into_kbd_buff9: move.l  (A0),(A1)+                ;TMacro entfernen
                move.l  (A0)+,D1
                addq.l  #2,D1
                bne.s   into_kbd_buff9
                movea.l A1,A0
                bra.s   into_kbd_buff11
into_kbd_buff7: addq.l  #4,A0                     ;Pointer hinter das Tabellenende (-2)
into_kbd_buff11:lea     tmacro_tab_end(A4),A1
                cmpa.l  A1,A0
                bhs.s   into_kbd_buff3            ;Buffer voll =>
                move.l  D0,tmacro_def_key(A4)     ;TMacro-Definition starten
                move.l  D0,(A0)+                  ;Tastencode merken
                move.l  A0,tmacro_def_adr(A4)
into_kbd_buff3: moveq   #-1,D0                    ;Z-Flag l”schen
into_kbd_buff2: movem.l (SP)+,D0-D1/A0-A1
                rts
               ;>ENDPART
********************************************************************************
* Die 200Hz-Timer-Routine                                                      *
********************************************************************************
               ;>PART 'hz200_irq'
               DC.L 'XBRA'
               DC.L xbra_id
old_hz200:     DS.L 1
hz200_irq:      addq.l  #1,$04BA.w                ;200Hz-Timer erh”hen
                movem.l D0-A6,-(SP)
                lea     varbase(PC),A4
                rol.w   timer_c_bitmap(A4)
                bpl     hz200i4                   ;auf 50Hz runterteilen
                tst.b   kbd_r_key(A4)             ;Taste gedrückt?
                beq.s   hz200i2
                tst.b   kbd_r_verz(A4)            ;Verz”gerung abgelaufen?
                beq.s   hz200i1
                subq.b  #1,kbd_r_verz(A4)
                bne.s   hz200i2
hz200i1:        subq.b  #1,kbd_r_cnt(A4)
                bne.s   hz200i2
                st      kbd_repeat_on(A4)         ;Es l„uft der Auto-Repeat
                move.b  kbd_r_rate(A4),kbd_r_cnt(A4)
                move.b  kbd_r_key(A4),D0
                bsr     k_arkin                   ;Taste in den Tastaturbuffer
hz200i2:        move.b  akt_maust(A4),D2
                cmpi.w  #32,mausy(A4)             ;In den oberen 2 Zeilen
                blo.s   hz200i3                   ;Taste direkt bernehmen
                tst.b   no_dklick(A4)             ;Keine Doppelklickabfrage?
                bne.s   hz200i3                   ;Genau => Taste bernehmen
                subq.b  #1,maus_merk2(A4)
                bgt.s   hz200i8
                clr.b   maus_merk2(A4)
                andi.b  #3,D2
                beq.s   hz200i6                   ;keine Taste gedrückt
                tst.w   maus_flag(A4)
                beq.s   hz200i7                   ;Doppelklick melden
                move.l  $04BA.w,D0
                move.l  D0,maus_time2(A4)
                sub.l   maus_time(A4),D0          ;Solange wird die Taste schon gedrückt
                cmp.l   #40,D0
                bhs.s   hz200i3                   ;ein langer Klick! -> hz200i5 (!!!)
                sf      maus_flag(A4)
                move.b  D2,maus_merk(A4)          ;Taste merken
                bra.s   hz200i4
hz200i7:        lsl.b   #2,D2                     ;Doppelklick melden
                move.b  #5,maus_merk2(A4)         ;Timeout
                bra.s   hz200i3
;hz200i5:lsl.b   #4,d2                   ;langen Klick melden
;        bra.s   hz200i3
hz200i6:        move.l  $04BA.w,D0
                move.l  D0,maus_time(A4)
                sub.l   maus_time2(A4),D0         ;solange wurde die Taste gedrückt
                move.b  maus_merk(A4),D2          ;alten Maustastenstatus holen
                cmp.l   #30,D0
                bhs.s   hz200i3                   ;Es war ein Einfach-Klick (oder keiner)!
                sf      maus_flag+1(A4)
                bra.s   hz200i4                   ;noch nix melden=> Doppelklickgefahr
hz200i3:        move.b  D2,maustast(A4)           ;Maustastenstatus setzen
hz200i8:        move.w  #-1,maus_flag(A4)         ;Flag wieder zurücksetzen
                clr.b   maus_merk(A4)
hz200i4:        movem.l (SP)+,D0-A6
                bclr    #5,$FFFFFA11.w            ;IRQ wieder freigeben
                rte
               ;>ENDPART
********************************************************************************
* Neue Keyboard-Routine für den Abbruch                                        *
********************************************************************************
               ;>PART 'spez_keyb'
               DC.L 'XBRA'
               DC.L xbra_id
old_spez_keyb: DS.L 1
spez_keyb:      tst.b   prozessor+varbase         ;68000?
                bmi.s   spez_keyb1                ;ja! =>
                clr.w   -(SP)                     ;68010 oder 68020 braucht ein Wort mehr
spez_keyb1:     pea     spez_keyb2(PC)
                move    SR,-(SP)                  ;für den RTE
                move.l  old_spez_keyb(PC),-(SP)
                rts

spez_keyb2:     movem.l D0-D1/A0-A1,-(SP)
                lea     varbase(PC),A1
                movea.l kbshift_adr(A1),A0
                move.b  (A0),D0                   ;aktueller kbshift-Wert
                moveq   #3,D1
                and.w   D1,D0                     ;Shift-Status
                lea     merk_shift(A1),A0
                cmp.b   (A0),D1                   ;beide Shift-Tasten gedrückt?
                bne.s   spez_keyb3                ;Nein! =>
                cmp.b   D1,D0
                beq.s   spez_keyb3                ;und jetzt nicht mehr?
                st      ssc_flag(A1)              ;Abbruch-Flag setzen
                movea.l act_pd(A1),A0
                move.l  18(SP),D0                 ;PC holen
                cmp.l   (A0),D0                   ;vor dem aktuellen Programm?
                blo.s   spez_keyb4                ;dann noch nicht abbrechen
                cmp.l   rom_base(A1),D0           ;im ROM
                bhs.s   spez_keyb4                ;dann weg!
                movem.l (SP)+,D0-D1/A0-A1
                move.l  #230<<24,-(SP)
                pea     except1(PC)
                rts                               ;Exceptionnummer für Shift-Break und Abbruch
spez_keyb3:     move.b  D0,(A0)
spez_keyb4:     movem.l (SP)+,D0-D1/A0-A1
                rte
               ;>ENDPART
********************************************************************************
* IKBD Mouse-Handler                                                           *
********************************************************************************
               ;>PART 'mausvek'
mausvek:        movem.l D0-A6,-(SP)
                move.b  (A0)+,D0
                move.b  D0,D1
                and.b   #$F8,D1                   ;Mausheader ?
                cmp.b   #$F8,D1
                bne.s   mausve1
                and.w   #3,D0                     ;Maustasten isolieren
                move.b  D0,akt_maust(A4)          ;und merken

                move.b  (A0)+,D0                  ;Delta X
                or.b    (A0),D0                   ;Delta Y
                beq.s   mausve1                   ;Maus nicht bewegt

                lea     debugger_scr(A4),A1
                tst.b   scr_moni(A1)
                bne.s   mausve6                   ;ist Farbe => keine dynamische Maus
                move.l  $04BA.w,D0
                sub.l   mausf_time(A4),D0         ;Differenz zum letzten Aufruf bilden
                move.l  $04BA.w,mausf_time(A4)    ;200Hz-Timerwert merken
                subq.l  #3,D0                     ;>5ms zurück?
                bhs.s   mausve6                   ;dann Ende
                move.b  -(A0),D0
                add.b   D0,(A0)+                  ;sonst die Koordinaten verdoppeln
                move.b  (A0),D0
                add.b   D0,(A0)
mausve6:        move.w  mausx(A4),D0              ;Alte X-Position holen
                move.b  -(A0),D1
                ext.w   D1
                add.w   D1,D0                     ;neue X-Position
                tst.w   D0
                bpl.s   mausve2
                moveq   #0,D0
mausve2:        cmp.w   #631,D0
                blo.s   mausve3
                move.w  #630,D0
mausve3:        move.w  D0,mausx(A4)              ;X-Position retten

                move.w  mausy(A4),D0              ;Alte Y-Position
                move.b  1(A0),D1
                ext.w   D1
                add.w   D1,D0                     ;neue Y-Position
                tst.w   D0
                bpl.s   mausve4
                moveq   #0,D0
mausve4:        cmp.w   #399,D0
                blo.s   mausve5
                move.w  #399,D0
mausve5:        move.w  D0,mausy(A4)              ;Y-Position retten

                clr.b   mausmove(A4)              ;Maus wurde bewegt
mausve1:        movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* VBL-Routine                                                                  *
********************************************************************************
               ;>PART 'my_vbl'
               DC.L 'XBRA'
               DC.L xbra_id
old_vbl:       DS.L 1
my_vbl:         
                IFNE ultradev
                movem.l d0-a6,-(a7)
                lea     varbase(PC),A4
                CHECKEXTENSION_NOUD my_vbl_noKey
                move    UDKeyStroke,d0
                cmp.w   #$ff,d0
                beq.s   my_vbl_noKey

                cmp     #$0d,d0
                bne.s   my_vbl_noReturn
                move    #$1c,d0
                jsr     k_arkey
                bra.s   my_vbl_noKey
my_vbl_noReturn:
                cmp     #$1b,d0
                bne.s   my_vbl_noEsc
                move    #$01,d0
                jsr     k_arkey
                bra.s   my_vbl_noKey
my_vbl_noEsc:

                cmp     #$08,d0
                bne.s   my_vbl_noBackSpace
                move    #$0e,d0
                jsr     k_arkey
                bra.s   my_vbl_noKey
my_vbl_noBackSpace:
                cmp     #$48,d0
                beq.s   my_vbl_doCursor
                cmp     #$50,d0
                beq.s   my_vbl_doCursor
                cmp     #$4b,d0
                beq.s   my_vbl_doCursor
                cmp     #$4d,d0
                beq.s   my_vbl_doCursor
                bra.s   my_vbl_normalKey
my_vbl_doCursor
                jsr     k_arkey
                bra     my_vbl_noKey

my_vbl_normalKey:
                ext.l   d0
                jsr     into_kbd_buff
my_vbl_noKey:
                movem.l (a7)+,d0-a6
                ENDC

                addq.l  #1,vbl_count2+varbase
                bmi     vbl_exi
                movem.l D0-A6,-(SP)
                lea     varbase(PC),A4
                ori     #$0700,SR                 ;Bitte nicht st”ren!
                addq.l  #1,vbl_count1(A4)
                tst.w   $04A6.w                   ;berhaupt ein Laufwerk vorhanden?
                beq.s   vblk08                    ;Nein! =>
                tst.w   $043E.w                   ;Laufwerk gesperrt?
                bne.s   vblk08                    ;Ja! =>
                move.w  $FFFF8604.w,D0            ;FDC-Status lesen
                tst.b   D0
                bmi.s   vblk08                    ;Motor l„uft noch =>
                move.b  #14,$FFFF8800.w
                moveq   #7,D1
                or.b    $FFFF8800.w,D1            ;deselect alle Drives
                move.b  D1,$FFFF8802.w
vblk08:         bclr    #6,$FFFFFA0F.w            ;Ring-Indicator wieder freigeben
                bsr     kb_save                   ;Bildschirm evtl. speichern
                tst.b   curflag(A4)
                bpl.s   my_vbl2                   ;Cursor ist aus!
                subq.b  #1,curflag+1(A4)          ;Timer rückw„rts
                bne.s   my_vbl5
                move.b  #$20,curflag+1(A4)        ;Timer neu setzen
                bchg    #6,curflag(A4)            ;Cursorzustand (1=An/0=Aus)
                move.b  mausoff(A4),D0
                move.b  mausmove(A4),D1
                move.b  mausflg(A4),D2
                bsr     flash_cursor
                tst.b   D2
                beq.s   my_vbl5
                move.b  D0,mausoff(A4)
                move.b  D1,mausmove(A4)
my_vbl5:        tst.b   set_lock(A4)
                bne.s   my_vbl2                   ;Cursor im VBL setzen ist verboten
                btst    #1,maustast(A4)           ;Linke Maustaste (lange)
                bne.s   my_vbl1
my_vbl2:        tas.b   mausmove(A4)              ;Wurde die Maus bewegt?
                bne.s   my_vbl4
                tst.b   mausoff(A4)
                bne.s   my_vbl4
                bsr     undraw_sprite             ;Undraw, wenn n”tig
                move.w  mausx(A4),D0
                move.w  mausy(A4),D1
                bsr.s   draw_sprite               ;Maus neu setzen
my_vbl4:        tst.b   kbd_r_key(A4)             ;Taste gedrückt?
                beq.s   vbl_end
                bsr     undraw_sprite             ;dann die Maus ausschalten
vbl_end:        movem.l (SP)+,D0-A6
vbl_exi:        rte
my_vbl1:        move.w  upper_line(A4),D0
                lsl.w   #4,D0                     ;mal 16
                sub.w   mausy(A4),D0              ;Cursor neu positionieren
                neg.w   D0
                bmi.s   my_vbl2
                bset    #6,curflag(A4)
                beq.s   my_vbl3
                bsr     flash_cursor
my_vbl3:        lsr.w   #4,D0
                move.w  D0,zeile(A4)
                move.w  mausx(A4),D0
                lsr.w   #3,D0
                move.w  D0,spalte(A4)
                move.w  #$FF20,curflag(A4)
                bsr     flash_cursor              ;Cursor wieder an
                bra.s   my_vbl2

draw_sprite:    lea     mausbuffer(A4),A2
                move.w  sprite_no(A4),D2
                lsl.w   #7,D2                     ;mal 128 (Spritel„nge)
                lea     debugger_scr(A4),A0
                tst.b   scr_moni(A0)              ;Farbe?
                lea     sprite(PC),A0
                adda.w  D2,A0
                bne.s   draw_sprite2              ;ist Farbe =>
                move.w  D1,D2
                lsl.w   #2,D2
                add.w   D2,D1                     ;mal 80
                lsl.w   #4,D1
                moveq   #$0F,D2                   ;Der Divisionsrest
                and.w   D0,D2                     ;X-Koordinate
                lsr.w   #4,D0                     ;X durch 16 teilen
                add.w   D0,D0
                lea     debugger_scr(A4),A1
                movea.l scr_adr(A1),A1            ;Bildschirmadresse
                adda.w  D1,A1                     ;+ Y-Offset
                adda.w  D0,A1                     ;+ X-Offset
                move.l  A1,(A2)+
                moveq   #15,D1                    ;Anzahl der Zeilen (minus 1)
draw_sprite1:   move.l  (A0)+,D3                  ;Maske holen
                lsr.l   D2,D3                     ;in die richtige Position schieben
                not.l   D3
                move.l  (A1),(A2)+                ;Hintergrund retten
                and.l   D3,(A1)                   ;Maske reinknüpfen
                move.l  (A0)+,D3                  ;Spritedaten holen
                lsr.l   D2,D3                     ;in die richtige Position schieben
                or.l    D3,(A1)                   ;Daten reinknüpfen
                lea     80(A1),A1                 ;N„chste Zeile
                dbra    D1,draw_sprite1
                clr.b   mausflg(A4)               ;"Maus an"-Flag
                rts
draw_sprite2:   lsr.w   #1,D1                     ;Farbmaus
                move.w  D1,D2
                lsl.w   #2,D2
                add.w   D2,D1                     ;(Y/2)*160 = Y-Offset
                lsl.w   #5,D1
                moveq   #$0F,D2                   ;Der Divisionsrest
                and.w   D0,D2                     ;X-Koordinate
                lsr.w   #4,D0                     ;X durch 32 teilen
                lsl.w   #2,D0
                lea     debugger_scr(A4),A1
                movea.l scr_adr(A1),A1            ;Bildschirmadresse
                adda.w  D1,A1                     ;+ Y-Offset
                adda.w  D0,A1                     ;+ X-Offset
                move.l  A1,(A2)+
                moveq   #7,D1                     ;Anzahl der Zeilen (minus 1)
draw_sprite3:   tst.w   D1
                bne.s   draw_sprite4
                addq.l  #8,A0                     ;Noch 'ne Zeile berlesen
draw_sprite4:   move.l  (A0)+,D3                  ;Maske holen
                lsr.l   D2,D3                     ;in die richtige Position schieben
                not.l   D3
                move.l  (A1),(A2)+                ;Hintergrund retten
                move.l  4(A1),(A2)+
                and.w   D3,4(A1)
                and.w   D3,6(A1)
                swap    D3                        ;Maske reinknüpfen
                and.w   D3,(A1)
                and.w   D3,2(A1)
                move.l  (A0)+,D3                  ;Spritedaten holen
                lsr.l   D2,D3                     ;in die richtige Position schieben
                or.w    D3,4(A1)
                or.w    D3,6(A1)
                swap    D3                        ;Daten reinknüpfen
                or.w    D3,(A1)
                or.w    D3,2(A1)
                addq.l  #8,A0                     ;eine Zeile berlesen
                lea     160(A1),A1                ;N„chste Zeile
                dbra    D1,draw_sprite3
                clr.b   mausflg(A4)               ;"Maus an"-Flag
                rts

undraw_sprite:  tas.b   mausflg(A4)               ;War die Maus an?
                bne.s   undraw_sprite2
                movem.l D1/A0-A2,-(SP)
                lea     mausbuffer(A4),A0
                movea.l (A0)+,A1                  ;Bildschirmposition des Buffers
                lea     debugger_scr(A4),A2
                tst.b   scr_moni(A2)
                bne.s   undraw_sprite3            ;ist Farbe
                moveq   #15,D1                    ;Anzahl der Zeilen (minus 1)
undraw_sprite1: move.l  (A0)+,(A1)                ;Buffer zurückschreiben
                lea     80(A1),A1
                dbra    D1,undraw_sprite1
                movem.l (SP)+,D1/A0-A2
undraw_sprite2: rts
undraw_sprite3: moveq   #7,D1                     ;Anzahl der Zeilen (minus 1)
undraw_sprite4: move.l  (A0)+,(A1)+               ;Buffer zurückschreiben
                move.l  (A0)+,(A1)
                lea     156(A1),A1
                dbra    D1,undraw_sprite4
                movem.l (SP)+,D1/A0-A2
                rts

sprite:        DC.L %11000000000000000000000000000000 ;Der normale Mauszeiger
               DC.L %0
               DC.L %11100000000000000000000000000000
               DC.L %1000000000000000000000000000000
               DC.L %11110000000000000000000000000000
               DC.L %1100000000000000000000000000000
               DC.L %11111000000000000000000000000000
               DC.L %1110000000000000000000000000000
               DC.L %11111100000000000000000000000000
               DC.L %1111000000000000000000000000000
               DC.L %11111110000000000000000000000000
               DC.L %1111100000000000000000000000000
               DC.L %11111111000000000000000000000000
               DC.L %1111110000000000000000000000000
               DC.L %11111111100000000000000000000000
               DC.L %1111111000000000000000000000000
               DC.L %11111111110000000000000000000000
               DC.L %1111111100000000000000000000000
               DC.L %11111111111000000000000000000000
               DC.L %1111100000000000000000000000000
               DC.L %11111110000000000000000000000000
               DC.L %1101100000000000000000000000000
               DC.L %11101111000000000000000000000000
               DC.L %1000110000000000000000000000000
               DC.L %11001111000000000000000000000000
               DC.L %110000000000000000000000000
               DC.L %10000111100000000000000000000000
               DC.L %11000000000000000000000000
               DC.L %111100000000000000000000000
               DC.L %11000000000000000000000000
               DC.L %11100000000000000000000000
               DC.L %0
               DC.W 65535,0,65535,0,65535,0,65529,0,65535,0,65529,0,65535,0,65535,0
               DC.W 65535,0,65535,0,65535,0,65535,0,65535,0,65535,0,65535,0,65535,0
               DC.W 65535,0,65535,0,65535,0,63519,0,65535,0,64287,0,65535,0,64287,0
               DC.W 65535,0,64287,0,65535,0,64287,0,32767,0,30751,0,16382,0,16382,0
               ;>ENDPART
********************************************************************************
* Maus an/ausschalten                                                          *
********************************************************************************
               ;>PART 'clr_maus'
clr_maus:       st      mausoff(A4)               ;Maus muž ausgeschaltet werden
                bra     undraw_sprite             ;und weg von Bildschirm
               ;>ENDPART
               ;>PART 'set_maus'
set_maus:       tst.b   kbd_r_key(A4)             ;Taste gedrückt?
                bne.s   set_ma1                   ;=> Maus nicht sofort wieder darstellen
                clr.b   mausmove(A4)              ;Maus wurde bewegt => wird dargestellt
set_ma1:        clr.b   mausoff(A4)               ;Maus darf wieder an
                rts
               ;>ENDPART
               ;>PART 'graf_mouse'
graf_mouse:     bsr.s   clr_maus
                move.w  D0,sprite_no(A4)          ;Neuen Mauszeiger setzen
                bra.s   set_maus
               ;>ENDPART
********************************************************************************
* Mausabfrage (Irgendwas ausgel”st?)                                           *
********************************************************************************
               ;>PART 'mauschk'
mauschk:        btst    #1,maustast(A4)           ;Linke Taste gedrückt?
                beq.s   mausch1                   ;Nein!
                clr.b   mausprell(A4)             ;merken, daž gedrückt wurde
                bra     mausch4                   ;Ende
mausch1:        tas.b   mausprell(A4)             ;Wurde die Taste losgelassen?
                bne     mausch4                   ;N” => Ende
                moveq   #0,D0
                moveq   #0,D1
                move.w  mausx(A4),D0
                move.w  mausy(A4),D1
                lsr.w   #3,D0
                lsr.w   #4,D1                     ;In Zeichenkoordinaten umrechnen
                cmp.w   #1,D1                     ;Nicht in den Menüzeilen
                bhi.s   mausch2
                lsr.w   #3,D0                     ;x div 8 (0 bis 9)
                tst.w   D1
                beq.s   mauscc1
                add.w   #10,D0                    ;2.Zeile beginnt bei 10 (bis 19)
mauscc1:        moveq   #31,D1
                bset    D1,D0                     ;Flag für F-Taste
                move    #$FF,CCR                  ;Aktion aufgetreten
                rts
mausche:        move    #0,CCR                    ;Es wurde nichts getan
                rts
sr_tab:        DC.B 13,10,9,8,4,3,2,1,0
               EVEN
mausch2:        tst.w   D0
                beq     mausch5
                move.l  reg_pos(A4),D7
                cmp.l   trace_pos(A4),D7
                bne     mauschf                   ;Die müssen gleich sein
                move.w  D0,D7
                cmp.w   #2,D1                     ;Nicht in den spez.Registern
                bhi.s   mausch3
                pea     mausc22(PC)               ;Rücksprungadresse in A7-Ausgabe
                lea     _pc(A4),A0
                moveq   #5,D0                     ;X-Startkoord (Y-Koord = D1)
                cmp.w   D0,D7
                blo.s   mausche
                cmp.w   #13,D7                    ;PC „ndern
                blo     form_inp
                lea     _usp(A4),A0
                moveq   #18,D0
                cmp.w   D0,D7
                blo.s   mausche
                cmp.w   #26,D7                    ;USP „ndern
                blo     form_inp
                lea     _ssp(A4),A0
                moveq   #31,D0
                cmp.w   D0,D7
                blo.s   mausche
                cmp.w   #39,D7                    ;SSP „ndern
                blo     form_inp
                cmp.w   #41,D7
                blo.s   mausche
                cmp.w   #49,D7
                bhs.s   mausche                   ;Nicht das SR
                addq.l  #4,SP
                sub.w   #41,D7
                move.b  sr_tab(PC,D7.w),D1
                move.w  _sr(A4),D0
                bchg    D1,D0                     ;Flag invertieren (Trace-Flag nicht „nderbar)
                move.w  D0,_sr(A4)
mausc22:        bsr     set_reg
                bsr     rgout
                move    #0,CCR
                rts
mausch3:        cmp.w   #4,D1                     ;Nicht in den normalen Registern
                bhi.s   mauschf
                move.w  D1,D3
                subq.w  #3,D3
                lsl.w   #5,D3                     ;mal 32 (Offset Daten/Adressregister)
                subq.w  #8,D0
                bmi.s   mauschf
                divu    #9,D0
                move.w  D0,D4
                swap    D0
                cmp.w   #8,D0
                beq.s   mauschf
                move.w  D4,D0
                mulu    #9,D0
                addq.w  #8,D0                     ;X-Koordinate errechnen
                lsl.w   #2,D4
                add.w   D4,D3
                lea     regs(A4),A0
                adda.w  D3,A0                     ;Zeiger auf entsprechende Register
                bsr     form_inp
                bra.s   mausc22

mauschf:        tst.b   mausscroll_on(A4)
                bne.s   mauschf1                  ;es wird schon gescrollt
                btst    #0,maustast(A4)
                beq.s   mauschg                   ;Rechte Maustaste ist n”tig!
mauschf1:       move.w  mausy(A4),D0
                cmp.w   #8,D0
                bhi.s   mauschh
                move.l  #$05480000,D0             ;Shift+Control+Cursor up
                bra.s   mauschi
mauschh:        cmp.w   #391,D0
                blo.s   mauschg
                move.l  #$05500000,D0             ;Shift+Control+Cursor down
mauschi:        st      mausscroll_on(A4)
                sf      mausscroll_flg1(A4)       ;"Mausscrolling war an" aus
                btst    #0,maustast(A4)
                beq.s   mauschii                  ;Rechte Maustaste? Nein! =>
                st      mausscroll_flg1(A4)       ;Mausscrolling war an
mauschii:       move    #$FF,CCR                  ;Aktion aufgetreten
                rts
mauschg:        sf      mausscroll_on(A4)
                move    #0,CCR
                rts

mausch4:        btst    #0,maustast(A4)           ;Rechte Taste gedrückt?
                beq.s   mausc41                   ;Nein!
                sf      mausprell2(A4)            ;merken, daž gedrückt wurde
                bra.s   mauschf                   ;Ende
mausc41:        tas.b   mausprell2(A4)            ;Wurde die Taste losgelassen?
                bne     mausc90                   ;N” => Doppelklick?
                bclr    #7,mausscroll_flg1(A4)    ;War Mausscrolling an?
                bne.s   mauschf                   ;dann raus
                move.w  mausx(A4),D0
                move.w  mausy(A4),D1
                lsr.w   #3,D0
                lsr.w   #4,D1                     ;In Zeichenkoordinaten umrechnen
                cmp.w   #1,D1                     ;Nicht in den Menüzeilen
                bls.s   mauschf
                move.w  D0,D3                     ;X-Koordinate merken
                lea     screen(A4),A0
                move.w  D1,D2
                lsl.w   #2,D2                     ;mal 80
                add.w   D2,D1
                lsl.w   #4,D1
                adda.w  D0,A0
                adda.w  D1,A0
                lea     mauttab(PC),A1
                movea.l A1,A2
mausc42:        move.b  (A1)+,D0
                beq.s   mausc43                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc42                   ;Immer noch ungleich!
                bra     mauschf
mausc43:        movea.l A2,A1
                subq.w  #1,D3
                bmi.s   mausc45                   ;Linken Rand erreicht (String ab A0)
                subq.l  #1,A0
mausc44:        move.b  (A1)+,D0
                beq.s   mausc43                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc44                   ;Immer noch ungleich!
                addq.l  #1,A0
mausc45:        movea.l A0,A6                     ;Linken Rand merken
mausc46:        movea.l A2,A1
                addq.w  #1,D3
                cmp.w   #79,D3
                bhs.s   mausc48                   ;Rechten Rand erreicht (String ab A6)
                addq.l  #1,A0
mausc47:        move.b  (A1)+,D0
                beq.s   mausc46                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc47                   ;Immer noch ungleich!
                subq.l  #1,A0
mausc48:        lea     spaced2(A4),A1
                movea.l A1,A2
                move.b  #' ',(A1)+                ;Space vor den String
mausc49:        move.b  (A6)+,(A1)+               ;String retten
                cmpa.l  A0,A6
                bls.s   mausc49
                clr.b   (A1)+
                jsr     @cursor_off(A4)           ;Cursor ausschalten
mausc4b:        tst.b   (A2)
                beq.s   mausc4c
                tst.b   ins_mode(A4)
                beq.s   mausc4a
                bsr     c_ins                     ;Zeichen einfügen
mausc4a:        move.b  (A2)+,D0
                jsr     @chrout(A4)
                bra.s   mausc4b
mausc4c:        bsr     cursor_on
                bra     mauschf                   ;Ende

mauttab:       DC.B '!&`*\+{}[]-~|/ ^=,;:¯<>#()?',0
               EVEN

mausch5:        lea     reg_pos(A4),A6
                movea.l #trace_buffend,A5
                adda.l  A4,A5
                movea.l #trace_buff,A3
                adda.l  A4,A3
                move.l  (A6),D2
                move.l  D2,D3
                cmp.w   #2,D1                     ;Fuller
                beq.s   mausch7
                cmp.w   #3,D1                     ;Pfeil oben
                beq.s   mausch6
                cmp.w   #4,D1                     ;Pfeil unten
                bne.s   mausch9                   ;Dann lieber gar nichts
                cmp.l   trace_pos(A4),D2
                beq.s   mausch6b                  ;Ende erreicht? => Abbruch
                addi.l  #78,(A6)
                cmpa.l  (A6),A5
                bhi.s   mausch8
                move.l  A3,(A6)
                bra.s   mausch8
mausch6:        subi.l  #78,D2
                cmp.l   A3,D2
                bhs.s   mausch6a
                move.l  A5,(A6)
                move.l  A5,D2
                bra.s   mausch6
mausch6a:       move.l  D2,(A6)
                cmp.l   trace_pos(A4),D2
                bne.s   mausch8
                move.l  D3,(A6)
mausch6b:       bsr     c_bell                    ;Grenze erreicht
                bra.s   mausch9
mausch7:        move.l  trace_pos(A4),(A6)
mausch8:        jsr     @cursor_off(A4)
                bsr     rgout
                bsr     cursor_on
mausch9:        move    #0,CCR
                rts

;Doppelklick
mausc90:        btst    #3,maustast(A4)           ;Doppelklick links?
                beq     mauschf                   ;Nein! => Ende
                move.w  mausx(A4),D0
                move.w  mausy(A4),D1
                lsr.w   #3,D0
                lsr.w   #4,D1                     ;In Zeichenkoordinaten umrechnen
                cmp.w   #1,D1                     ;Nicht in den Menüzeilen
                bls     mauschf
                move.w  D0,D3                     ;X-Koordinate merken
                lea     screen(A4),A0
                move.w  D1,D2
                lsl.w   #2,D2                     ;mal 80
                add.w   D2,D1
                lsl.w   #4,D1
                adda.w  D0,A0
                adda.w  D1,A0
                lea     mauttab(PC),A1
                movea.l A1,A2
mausc92:        move.b  (A1)+,D0
                beq.s   mausc93                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc92                   ;Immer noch ungleich!
                bra     mauschf
mausc93:        movea.l A2,A1
                subq.w  #1,D3
                bmi.s   mausc95                   ;Linken Rand erreicht (String ab A0)
                subq.l  #1,A0
mausc94:        move.b  (A1)+,D0
                beq.s   mausc93                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc94                   ;Immer noch ungleich!
                addq.l  #1,A0
mausc95:        movea.l A0,A6                     ;Linken Rand merken
mausc96:        movea.l A2,A1
                addq.w  #1,D3
                cmp.w   #79,D3
                bhs.s   mausc9a                   ;Rechten Rand erreicht (String ab A6)
                addq.l  #1,A0
mausc97:        move.b  (A1)+,D0
                beq.s   mausc96                   ;Tabellenende & kein Trennzeichen erwischt
                cmp.b   (A0),D0
                bne.s   mausc97                   ;Immer noch ungleich!
                subq.l  #1,A0
mausc9a:        lea     spaced2(A4),A1
                movea.l A1,A2
mausc9b:        move.b  (A6)+,(A1)+               ;String retten
                cmpa.l  A0,A6
                bls.s   mausc9b
                clr.b   (A1)+                     ;String mit Null terminieren
                st      err_flag(A4)
                move.l  SP,err_stk(A4)            ;falls ein Fehler auftritt
                movea.l A2,A0
                moveq   #0,D0
                move.b  (A0)+,D0
                jsr     get_zahl
                jsr     @cursor_off(A4)
                bsr.s   do_dopp                   ;Doppelklick ausführen
                bsr     cursor_on
                bra     mauschf
mausc9z:        sf      err_flag(A4)
                move    #0,CCR
                rts                               ;Ende
               ;>ENDPART
********************************************************************************
* "Doppelklick"-Ausführung (D1-Anfangsadresse)                                 *
********************************************************************************
               ;>PART 'do_dopp'
do_dopp:        movea.l D1,A2
                sf      err_flag(A4)
                tst.l   sym_size(A4)
                sne     list_flg(A4)              ;symbolisch disassemblieren (wenn Symbole da)
                suba.l  A3,A3
                move.w  def_lines(A4),D2          ;Default-Zeilenanzahl
                subq.w  #1,D2
                move.l  basep(A4),D0              ;Programm mit LE geladen?
                beq.s   mausc9w                   ;Dump oder Disa
                movea.l D0,A0
                cmpa.l  8(A0),A2                  ;< TEXT-Segment
                blo.s   mausc9v                   ;Dump
                cmpa.l  16(A0),A2                 ;> DATA-Segment
                bhs.s   mausc9v                   ;Dump
mausc9u:        bsr     cmd_disass2               ;Disassemble ausgeben
                bra.s   mausc9x
mausc9w:        tst.w   format_flag(A4)
                bne.s   mausc9u                   ;Disassemble
mausc9v:        moveq   #0,D3                     ;Byte-Dump
                bsr     cmd_dump2                 ;Dump ausgeben
mausc9x:        move.l  default_adr(A4),D1
                jsr     @anf_adr(A4)
                clr.b   maustast(A4)
                rts
               ;>ENDPART
********************************************************************************
* Form-Input                                                                   *
* A0 - Zeiger auf Speicherstelle, wo die Eingabe abgelegt wird (Long)          *
* D0 - X-Koordinate                                                            *
* D1 - Y-Koordinate                                                            *
********************************************************************************
               ;>PART 'form_inp'
form_inp:       addq.b  #1,set_lock(A4)           ;Cursorsetzen im VBL verhindern
                jsr     @cursor_off(A4)
                bsr     clr_maus
                move.l  zeile(A4),-(SP)
                move.l  A0,-(SP)
                move.w  D0,D6                     ;Linke X-Koordinate
                move.w  D7,spalte(A4)             ;akt.Cursorposition
                move.w  D6,D7                     ;Rechte X-Koordinate
                addq.w  #7,D7                     ;8 Zeichen Eingabe
                sub.w   upper_line(A4),D1
                move.w  D1,zeile(A4)
form_inp1:      bsr     cursor_on
form_inp2:      moveq   #27,D0                    ;mit ESC vorbelegen
                btst    #0,maustast(A4)           ;Rechte Maustaste gedrückt?
                bne.s   form_inp3                 ;Ja! => ESC ausführen
                jsr     @conin(A4)                ;Tastencode holen
                beq.s   form_inp2                 ;Taste wurde gedrückt
form_inp3:      jsr     @cursor_off(A4)
form_inp4:      btst    #0,maustast(A4)
                bne.s   form_inp4                 ;Auf's loslassen warten
                bclr    #28,D0                    ;CAPS/LOCK weg
                cmp.l   #$4B0000,D0               ;Cursor left
                bne.s   form_inp5
                cmp.w   spalte(A4),D6
                beq.s   form_inp1                 ;Linker Rand bereits erreicht
                subq.w  #1,spalte(A4)
                bra.s   form_inp1
form_inp5:      cmp.l   #$4D0000,D0               ;Cursor right
                bne.s   form_inp6
                cmp.w   spalte(A4),D7
                beq.s   form_inp1                 ;Rechter Rand bereits erreicht
                addq.w  #1,spalte(A4)
                bra.s   form_inp1
form_inp6:      cmp.l   #$610000,D0
                beq.s   form_inp13                ;UNDO = Abbruch
                cmp.w   #27,D0
                beq.s   form_inp13                ;ESC = Abbruch
                cmp.w   #13,D0
                beq.s   form_inp10                ;Return = Zahl bernehmen
                cmp.w   #'0',D0
                blo.s   form_inp8
                cmp.w   #'9',D0
                bls.s   form_inp9
form_inp7:      cmp.w   #'A',D0                   ;Es sind nur Hexzahlen erlaubt!
                blo.s   form_inp8
                cmp.w   #'F',D0
                bls.s   form_inp9
                bclr    #5,D0
                bne.s   form_inp7
form_inp8:      bsr     c_bell                    ;Pling, da Taste nicht erlaubt
                moveq   #0,D0
form_inp9:      jsr     @chrout(A4)               ;Zeichen ausgeben / ausführen
                cmp.w   spalte(A4),D7
                bhs     form_inp1                 ;Ende der Eingabe erreicht
                move.w  D7,spalte(A4)
                bra     form_inp1
form_inp10:     move.w  D6,spalte(A4)             ;Cursor auf Eingabeanfang
                bsr     calc_crsr                 ;A0 zeigt auf Position im Bildschirmspeicher
                moveq   #0,D1
                moveq   #7,D7
form_inp11:     move.b  (A0)+,D0
                sub.b   #$30,D0
                cmp.w   #9,D0
                bls.s   form_inp12                ;Hex-Zahl holen

                subq.w  #7,D0
form_inp12:     rol.l   #4,D1                     ;Ein Nibble nach links
                or.b    D0,D1                     ;und die Ziffer einfügen
                dbra    D7,form_inp11
                movea.l (SP),A0
                move.l  D1,(A0)                   ;Register „ndern
form_inp13:     addq.l  #4,SP                     ;Registeradresse vom Stack
                move.l  (SP)+,zeile(A4)
                bsr.s   cursor_on
                bsr     set_maus
                subq.b  #1,set_lock(A4)           ;Cursorsetzen im VBL verhindern
                move    #0,CCR
                rts
               ;>ENDPART
********************************************************************************
* Cursor an-/ausschalten                                                       *
********************************************************************************
               ;>PART 'cursor_on'
cursor_on:      bsr.s   flash_cursor              ;Cursor darstellen
                move.w  #$FF20,curflag(A4)        ;Cursor ist an
cursor_:        rts
               ;>ENDPART
               ;>PART 'cursor_off'
cursor_off:     bclr    #7,curflag(A4)            ;Cursor sofort stoppen
                bclr    #6,curflag(A4)
                beq.s   cursor_
                bra.s   flash_cursor
               ;>ENDPART
********************************************************************************
* Cursor invertieren                                                           *
********************************************************************************
               ;>PART 'flash_cursor'
cursor_tab:    DC.B $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
               DC.B $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
               DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$FF
               DC.B $FF,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$81,$FF

flash_cursor:   movem.l D0-D3/A0-A2,-(SP)
                move.w  cursor_form(A4),D0
                lea     cursor_tab(PC,D0.w),A2
                bsr     clr_maus
                bsr     calc_crsr
                lea     debugger_scr(A4),A1
                tst.b   scr_moni(A1)
                bne.s   fcurso1                   ;Farbe =>
                lsl.w   #4,D2                     ;Cursorzeile * 1280
                add.w   D3,D2                     ;+ Cursorspalte
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                moveq   #15,D2
fcurso0:        move.b  (A2)+,D0
                eor.b   D0,(A1)
                lea     80(A1),A1
                dbra    D2,fcurso0
                bra.s   fcurso3
fcurso1:        lsl.w   #4,D2                     ;Cursorzeile * 1280
                move.w  D3,D1
                andi.w  #-2,D3
                add.w   D3,D3
                add.w   D3,D2                     ;+ (Spalte and -2) * 2
                andi.w  #1,D1
                add.w   D1,D2                     ;+ (Spalte and 1)
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                moveq   #7,D2
fcurso2:        move.b  (A2)+,D0
                or.b    (A2)+,D0
                eor.b   D0,(A1)
                lea     160(A1),A1
                dbra    D2,fcurso2
fcurso3:        bsr     set_maus
                movem.l (SP)+,D0-D3/A0-A2
 IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                jsr ultradev_mirror_vga
.noUD:                
 ENDC
                rts
               ;>ENDPART
********************************************************************************
* Bild (evtl.) als Screendump abspeichern                                      *
********************************************************************************
               ;>PART 'kb_save'
kb_save:        movem.l D0-A6,-(SP)
                tst.b   _dumpflg(A4)              ;Hardcopy (als Bild)?
                bne     kb_save3
                move.b  #1,_dumpflg(A4)

                lea     debugger_scr(A4),A3

                lea     prn_buff(A4),A1

                clr.b   (A1)+
                move.b  scr_rez(A3),(A1)+         ;Aufl”sung merken (0-2)
                lea     scr_colors(A3),A0
                moveq   #7,D0
kb_save1:       move.l  (A0)+,(A1)+               ;Farbe holen
                dbra    D0,kb_save1               ;schon alle Farbregister ausgelesen

                jsr     do_mediach                ;Media-Change ausl”sen
                moveq   #'1',D0
                add.b   scr_rez(A3),D0
                move.b  D0,kb_nam2                ;Extension setzen ("1"-"3")
                clr.w   -(SP)
                pea     kb_name(PC)
                move.w  #$3C,-(SP)
                bsr     do_trap_1                 ;Fopen("?:\BUG_?.PI?",0)
                addq.l  #8,SP
                move.w  D0,D7
                bmi.s   kb_save2                  ;Fehler aufgetreten
                pea     prn_buff(A4)
                pea     34.w
                move.w  D7,-(SP)
                move.w  #$40,-(SP)
                bsr     do_trap_1                 ;Fwrite(Handle,34.L,Aufl”sung+Farben)
                lea     12(SP),SP
                tst.w   D0
                bmi.s   kb_save2                  ;Fehler aufgetreten
                move.l  scr_adr(A3),-(SP)         ;= Bildschirmadresse
                pea     32000.w                   ;Gr”že des Bildschirms
                move.w  D7,-(SP)                  ;Filehandle
                move.w  #$40,-(SP)
                bsr     do_trap_1                 ;Fwrite(Handle,32000.L,Bildschirmadr)
                lea     12(SP),SP
                tst.l   D0
                bmi.s   kb_save2                  ;Fehler aufgetreten
                move.w  D7,-(SP)                  ;Filehandle
                move.w  #$3E,-(SP)
                bsr     do_trap_1                 ;Fclose(Handle)
                addq.l  #4,SP
kb_save2:       st      _dumpflg(A4)
                addq.b  #1,kb_nam1
                cmpi.b  #'Z',kb_nam1
                ble.s   kb_save3                  ;Filenamen für's n„chste mal „ndern
                move.b  #'A',kb_nam1
kb_save3:       movem.l (SP)+,D0-A6
                rts

init_save:      move.w  #$19,-(SP)
                trap    #1                        ;Dgetdrv() - aktuelles Laufwerk ermitteln
                addq.l  #2,SP
                addi.b  #'A',D0
                move.b  D0,kb_name                ;und merken
                rts
kb_name:       DC.B 'x:\BUG_'
kb_nam1:       DC.B 'A.PI'
kb_nam2:       DC.B 'x',0
               EVEN
               ;>ENDPART

********************************************************************************
* Zeichenausgabe + Screeneditor                                                *
********************************************************************************
********************************************************************************
* Der Bildschirmeditor                                                         *
********************************************************************************
               ;>PART 'scr_edit'
scr_edit:       st      ignore_autocrlf(A4)       ;CR/LF nach der Funktion unterdrücken
                moveq   #$11,D0
                jsr     @ikbd_send(A4)            ;Keyboard wieder an
                tst.l   quit_stk(A4)
                bne.s   scr_ed0
                move.l  #$04220067,D0             ;CTRL+G (GO!!!)
scr_ed0:        bsr     cursor_on                 ;Cursor anschalten
scr_ed1:        jsr     @conin(A4)                ;Tastencode holen
                bne.s   scr_ed2                   ;Taste wurde gedrückt
                bsr     mauschk                   ;Maus auswerten
                bpl.s   scr_ed1                   ;Keine Mausreaktion
scr_ed2:        jsr     @cursor_off(A4)           ;Cursor ausschalten
                move.l  D0,D7                     ;Tastencode merken
                bsr     do_fkeys                  ;F-Tasten?
                bmi.s   scr_edit                  ;Funktion ausgeführt
                bsr     do_scrkeys                ;Bildschirmseiten-Umschaltung
                bmi.s   scr_edit                  ;Funktion ausgeführt
                swap    D7
                move.b  D7,direct(A4)             ;Scan-Code merken / Direktmodus an
                lea     stab(PC),A0
                movea.l A0,A1
scr_ed3:        move.w  (A0)+,D0                  ;Nichts gefunden
                beq.s   scr_ed4                   ;ASCII-Code nicht gefunden => ausgeben
                cmp.l   (A0)+,D7                  ;Tastaturcodecode in der Tabelle?
                bne.s   scr_ed3                   ;Nein, weitersuchen!
                lea     0(A1,D0.w),A0
                jsr     (A0)                      ;Funktion ausführen
                clr.b   direct(A4)
                bra.s   scr_edit
scr_ed4:        tst.b   ins_mode(A4)
                beq.s   scr_ed5
                bsr     c_ins                     ;Zeichen einfügen
scr_ed5:        swap    D7
                move.w  D7,D0
                jsr     @chrout(A4)
                bra.s   scr_edit

;>               BASE DC.W,stab
stab:          DC.W cache_up-stab,0,$084B              ;Alt+left
               DC.W cache_down-stab,0,$084D            ;Alt+right
               DC.W cache_fix-stab,0,$0847             ;Alt+clr/home
               DC.W cache_get-stab,0,$0852             ;Alt+Insert
               DC.W c_cup-stab,0,$48                   ;Cursor up
               DC.W c_cdown-stab,0,$50                 ;Cursor down
               DC.W c_cleft-stab,0,$4B                 ;Cursor left
               DC.W c_cright-stab,0,$4D                ;Cursor right
               DC.W c_clrhome-stab,$37,$0147           ;Clr/Home
               DC.W c_home-stab,0,$47                  ;Home
               DC.W c_eop-stab,$1B,1                   ;ESC
               DC.W c_del-stab,$7F,$53                 ;Delete
               DC.W c_ins-stab,0,$52                   ;Insert
               DC.W c_eol-stab,$7F,$0153               ;Shift+Delete
               DC.W c_undo-stab,0,$61                  ;UNDO
               DC.W c_inson-stab,$30,$0152             ;Shift+Insert
               DC.W c_cdl-stab,$0D,$041C               ;Ctrl+Return
               DC.W c_clrli-stab,$7F,$0453             ;Ctrl+Delete
               DC.W c_insli-stab,0,$0452               ;Ctrl+Insert
               DC.W c_scrup-stab,$32,$0150             ;Shift+Down
               DC.W c_scrdown-stab,$38,$0148           ;Shift+Up
               DC.W c_asyup-stab,0,$0550               ;Shift+Control+Down
               DC.W c_asydown-stab,0,$0548             ;Shift+Control+Up
               DC.W c_scrlft-stab,0,$044B              ;Control+Left
               DC.W c_scrrgt-stab,0,$044D              ;Control+Right
               DC.W c_scrlft-stab,$34,$014B            ;Shift+Left
               DC.W c_scrrgt-stab,$36,$014D            ;Shift+Right
               DC.W c_end-stab,$0D,$1C                 ;Return
               DC.W c_tab-stab,9,$0F                   ;Tab
               DC.W c_bakspc-stab,8,$0E                ;Backspace
               DC.W c_bakspc-stab,8,$010E              ;Shift+Backspace
               DC.W set_pc-stab,$70,$0419              ;CTRL+p
               DC.W set_bkpt-stab,$62,$0430            ;CTRL+b
               DC.W set_go-stab,$67,$0422              ;CTRL+g
               DC.W c_lline-stab,$6D,$0832             ;Alt+M
               DC.W c_sline-stab,$6D,$0432             ;Control+M
               DC.W do_help-stab,0,$0462               ;CTRL+HELP
               DC.W sdo_help-stab,0,$0562              ;SHIFT+CTRL+HELP
               DC.W set_trace-stab,$59,$042C           ;CTRL-Y : F1
               DC.W set_skip-stab,$53,$041F            ;CTRL-S : F5
               DC.W set_do_pc-stab,$41,$041E           ;CTRL-A : F2
               DC.W 0

;************************************************************************
;* CTRL-Funktionen                                                      *
;************************************************************************
set_trace:      jmp     f_trace
set_skip:       jmp     f_skip
set_do_pc:      jmp     f_do_pc

set_go:         move.w  upper_offset(A4),D0
                lea     screen(A4),A0
                adda.w  D0,A0
                move.w  zeile(A4),D0
                mulu    #80,D0
                adda.w  D0,A0
                movea.l default_adr(A4),A6
                jsr     @get_line(A4)             ;etv.Adresse am Zeilenanfang holen
                move.l  A6,_pc(A4)
                bra     go_pc                     ;Programm starten

set_pc:         move.w  upper_offset(A4),D0
                lea     screen(A4),A0
                adda.w  D0,A0
                move.w  zeile(A4),D0
                mulu    #80,D0
                adda.w  D0,A0
                movea.l default_adr(A4),A6
                jsr     @get_line(A4)             ;etv.Adresse am Zeilenanfang holen
                move.l  A6,_pc(A4)
                bsr     set_reg
                bra     rgout                     ;PC setzen

set_bkpt:       jsr     @conin(A4)                ;Tastencode holen
                beq.s   set_bkpt                  ;Taste wurde gedrückt
                andi.w  #$FF,D0
                subi.w  #'0',D0
                bmi.s   set_bk2                   ;Code zu klein
                cmp.w   #9,D0
                bls.s   set_bk3
                subq.w  #7,D0
                bmi.s   set_bk2
                cmp.w   #15,D0                    ;kein 0-9/A-F
                bls.s   set_bk3
                subi.w  #32,D0                    ;Kleinbuchstaben
                cmp.w   #10,D0
                blo.s   set_bk2
                cmp.w   #15,D0
                bhi.s   set_bk2
set_bk3:        move.w  D0,D7
                mulu    #12,D7
                move.w  upper_offset(A4),D0
                lea     screen(A4),A0
                adda.w  D0,A0
                move.w  zeile(A4),D0
                mulu    #80,D0
                adda.w  D0,A0
                movea.l default_adr(A4),A6
                jsr     @get_line(A4)             ;etv.Adresse am Zeilenanfang holen
                move.l  A6,D1
                btst    #0,D1
                bne.s   set_bk2                   ;ungerade
                movea.l D1,A6
                bsr     check_write
                bne.s   set_bk2
                lea     breakpnt(A4),A1
                move.l  D1,0(A1,D7.w)
                move.w  #-1,4(A1,D7.w)            ;Stop-Breakpoint
                move.l  #1,6(A1,D7.w)             ;nur einmal ausführen
set_bk2:        rts

cache_get:      jmp     getcache
cache_fix:      pea     @cursor_off(A4)
                moveq   #2,D1
                bra     mausch5
cache_up:       pea     @cursor_off(A4)
                moveq   #3,D1
                bra     mausch5
cache_down:     pea     @cursor_off(A4)
                moveq   #4,D1
                bra     mausch5

sdo_help:       moveq   #-1,D7                    ;keine PC-Umrechnung
                bra.s   do_help00
do_help:        move.b  fast_exit(A4),D7
do_help00:      clr.b   fast_exit(A4)
                tst.b   help_allow(A4)            ;CTRL-HELP erlaubt?
                bpl     cmd_exit1                 ;zurück
                tst.l   quit_stk(A4)              ;2.Test: indirekter Aufruf?
                beq     cmd_exit1                 ;zurück
                clr.l   line_back(A4)             ;Zeilennr der Rückgabezeile=0
                movea.l basep(A4),A0              ;Adresse des Basepage
                movea.l 8(A0),A1                  ;Anfangsadr des TEXT-Segments
                move.l  $18(A0),D2                ;Anfangsadr des BSS-Segments
                add.l   $1C(A0),D2                ;+ L„nge des BSS-Segments
                moveq   #-1,D0
                tst.b   D7                        ;Programmende?
                bne.s   do_help0                  ;dann keine PC-Umrechnung
                move.l  _pc(A4),D0                ;der aktuelle PC
                bsr.s   do_help2
do_help0:       move.l  D0,line_back(A4)          ;PC-Offset errechnet
                lea     simple_vars(A4),A2
                lea     spaced2(A4),A3
                moveq   #9,D1
do_help1:       move.l  (A2)+,D0
                bsr.s   do_help2                  ;die 10 Anwendervariablen in Offsets wandeln
                move.l  D0,(A3)+
                dbra    D1,do_help1
                bra     cmd_exit1                 ;dann raus!

do_help2:       cmp.l   A1,D0
                blo.s   do_help3                  ;kleiner als das TEXT-Segment
                cmp.l   D2,D0                     ;Zeiger hinter das BSS-Segment
                bhs.s   do_help3                  ;gr”žer als das DATA-Segment
                sub.l   A1,D0
                rts
do_help3:       moveq   #-1,D0                    ;dat war wohl nix
                rts

;************************************************************************
;* F-Tasten-Verwaltung                                                  *
;************************************************************************
do_fkeys:       tst.l   D0                        ;F-Tasten?
                bpl.s   do_fke4                   ;Nein, Ende
                swap    D7
                andi.w  #$0C00,D7                 ;Control / Alternate testen
                bne.s   do_fke5                   ;gedrückt => Menüleiste
                addq.w  #1,D0                     ;1 bis 20
                moveq   #0,D7                     ;select
                bsr     sel_menue                  ;Eintrag selektieren
                add.w   D0,D0                     ;(F-Taste-1)*2
                lea     f_jumps,A0
                adda.w  -2(A0,D0.w),A0
                jsr     (A0)                      ;F-Taste ausführen
                jsr     @desel_menue(A4)           ;evtl. selektierten Menüeintrag deselektieren
do_fke5:        move    #$FF,CCR
do_fke4:        rts

;************************************************************************
;* Alternate / Control '1' bis '9'                                      *
;************************************************************************
do_scrkeys:     tst.w   D0
                bpl     do_sck4
                move.w  upper_offset(A4),D1
                lea     screen(A4),A1
                adda.w  D1,A1
                movea.l #scr_buff,A0
                adda.l  A4,A0
                andi.w  #$7FFF,D7
                mulu    #1606,D7
                adda.w  D7,A0                     ;Zeiger auf den Bildschirm
                swap    D0
                andi.w  #$0400,D0                 ;Control? = retten
                bne.s   do_sck2                   ;Ja
                tst.w   (A0)                      ;Bildschirm bereits gerettet?
                beq.s   do_sck5                   ;Nein => Ende
                addq.l  #2,A0
                move.l  (A0)+,zeile(A4)           ;Cursor setzen
                move.w  down_lines(A4),D0
                subq.w  #1,D0                     ;im Normalfall 19
do_sck1:        moveq   #4,D1
do_sck11:       move.l  (A0)+,(A1)+               ;Bildschirm zurück
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D1,do_sck11
                dbra    D0,do_sck1
                jsr     @redraw_all(A4)           ;Bildschirm neu aufbauen
                bra.s   do_sck5
do_sck2:        st      (A0)                      ;Bildschirm existiert
                addq.l  #2,A0
                move.l  zeile(A4),(A0)+           ;Cursor merken
                movea.l A0,A2
                move.l  #'    ',D1
                move.w  #399,D0
do_sck21:       move.l  D1,(A2)+
                dbra    D0,do_sck21
                move.w  down_lines(A4),D0
                subq.w  #1,D0                     ;im Normalfall 19
do_sck3:        moveq   #4,D1
do_sck31:       move.l  (A1)+,(A0)+               ;Bildschirm retten
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D1,do_sck31
                dbra    D0,do_sck3
do_sck5:        move    #$FF,CCR
do_sck4:        rts
               ;>ENDPART
********************************************************************************
* Text auf dem Stack bis zum Nullbyte ausgeben in Zeile D0                     *
********************************************************************************
               ;>PART 'print_inv_line'
print_inv_line: movem.l D0-D7/A1-A6,-(SP)
                move.l  zeile(A4),-(SP)
                movea.l 64(SP),A6                 ;Anfangsadresse des Textes
                clr.w   spalte(A4)
                move.w  D0,zeile(A4)
print_inv_line1:moveq   #0,D0
                move.b  (A6)+,D0
                beq.s   print_inv_line3
                moveq   #-1,D1
                moveq   #-1,D2
                bsr     light_char                ;8 Zeichen invertieren
                addq.w  #1,spalte(A4)
                bra.s   print_inv_line1
print_inv_line3:move.l  (SP)+,zeile(A4)
                movem.l (SP)+,D0-D7/A1-A6
                move.l  (SP)+,(SP)                ;Returnadresse ber Stringadresse kopieren
                rts
               ;>ENDPART
********************************************************************************
* Text auf dem Stack bis zum Nullbyte ausgeben                                 *
********************************************************************************
               ;>PART 'print_line'
print_line:     movem.l D0-D7/A1-A6,-(SP)
                movea.l 60(SP),A6                 ;Anfangsadresse des Textes
print_line1:    move.b  (A6)+,D0
                beq.s   print_line3
                cmp.b   #13,D0
                bne.s   print_line2
                jsr     @c_eol(A4)
                jsr     @crout(A4)
                bra.s   print_line1
print_line2:    bsr.s   chrout
                bra.s   print_line1
print_line3:    movem.l (SP)+,D0-D7/A1-A6
                move.l  (SP)+,(SP)                ;Returnadresse über Stringadresse kopieren
                rts
               ;>ENDPART
********************************************************************************
* Spaces bis Cursor in Spalte D0                                               *
********************************************************************************
               ;>PART 'spacetab'
spacetab:       tst.b   device(A4)                ;Drucker- oder Fileausgabe?
                bne.s   spacetab1                 ;Dann aber weg
                cmp.w   spalte(A4),D0
                beq.s   spacetab2                 ;Cursor in der Spalte
                bsr.s   space
                bra.s   spacetab
spacetab1:      cmp.w   prn_pos(A4),D0            ;Tab für'n Drucker
                beq.s   spacetab2
                bsr.s   space
                bra.s   spacetab1
spacetab2:      rts
               ;>ENDPART
********************************************************************************
* Ein paar globale Ausgaben                                                    *
********************************************************************************
               ;>PART 'crout'
crout:          movem.l D0-A6,-(SP)
                lea     prn_buff(A4),A0
                moveq   #0,D1
                move.w  prn_pos(A4),D1
                tst.b   device(A4)
                bmi     c_prncr                   ;zum Drucker
                bne.s   c_filecr                  ;oder in eine Datei
                clr.w   spalte(A4)
                bsr     c_cdown
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
               ;>PART 'space'
space:          move.l  D0,-(SP)
                moveq   #' ',D0
                bsr.s   chrout
                move.l  (SP)+,D0
                rts
               ;>ENDPART
               ;>PART 'gleich_out'
gleich_out:     moveq   #'=',D0
               ;>ENDPART
********************************************************************************
* Zeichen in D0 ausgeben                                                       *
********************************************************************************
               ;>PART 'chrout'
chrout:         tst.b   testwrd(A4)               ;Ausgabe in den Buffer?
                bne.s   chrout1                   ;Ja!
                tst.b   D0
                beq.s   chrout2                   ;Nullbytes werden nicht ausgegeben
                bra     charout                   ;dann ausgeben
chrout1:        move.b  D0,(A0)+                  ;Zeichen in Ausgabebuffer
chrout2:        rts
               ;>ENDPART
********************************************************************************
* Fileausgabe                                                                  *
********************************************************************************
               ;>PART 'c_file'
c_file:         lea     prn_buff(A4),A0
                moveq   #0,D1
                move.w  prn_pos(A4),D1
                cmp.b   #32,D0
                blo.s   c_file1
                cmp.b   #'ú',D0
                bne.s   c_file0
c_file1:        moveq   #'.',D0
c_file0:        move.b  D0,0(A0,D1.w)             ;Ab in den Buffer
                addq.w  #1,prn_pos(A4)
                cmpi.w  #80,prn_pos(A4)
                bhs.s   c_prncr
                movem.l (SP)+,D0-A6
                rts

c_filecr:       move.b  #13,0(A0,D1.w)            ;CR
                move.b  #10,1(A0,D1.w)            ;LF
                move.w  _fhdle2(A4),D0            ;Handle<=0 => Fehler
                bls.s   c_filec1
                pea     prn_buff(A4)
                addq.l  #2,D1
                move.l  D1,-(SP)
                move.w  D0,-(SP)
                move.w  #$40,-(SP)
                bsr     do_trap_1
                lea     12(SP),SP
                clr.w   prn_pos(A4)               ;Zeiger zurücksetzen
                cmp.l   D0,D1
                bne.s   c_filec2
                movem.l (SP)+,D0-A6
                rts
c_filec1:       jmp     file_er
c_filec2:       jmp     dskfull
               ;>ENDPART
********************************************************************************
* Druckerausgabe                                                               *
********************************************************************************
               ;>PART 'c_prn'
c_prn:          lea     prn_buff(A4),A0
                move.w  prn_pos(A4),D1
                cmp.b   #32,D0
                blo.s   c_prn1
                cmp.b   #'ú',D0
                bne.s   c_prn0
c_prn1:         moveq   #'.',D0
c_prn0:         move.b  D0,0(A0,D1.w)             ;Ab in den Buffer
                addq.w  #1,prn_pos(A4)
                cmpi.w  #80,prn_pos(A4)
                bhs.s   c_prncr
                movem.l (SP)+,D0-A6
                rts

c_prncr:        clr.b   0(A0,D1.w)
                btst    #0,$FFFFFA01.w            ;Drucker busy =>
                bne.s   c_prn5                    ;nichts zu machen
                lea     prn_buff(A4),A5
c_prn3:         move.b  (A5)+,D0
                beq.s   c_prn4                    ;Ende der Zeile
                bsr     prnout                    ;Zeichen zum Drucker
                bra.s   c_prn3                    ;Weiter geht's
c_prn4:         bsr     prncr                     ;CR+LF zum Drucker
                clr.w   prn_pos(A4)               ;Zeiger zurücksetzen
                movem.l (SP)+,D0-A6
                rts
c_prn5:         jmp     prn_err
               ;>ENDPART
********************************************************************************
* Zeichen in D0 mit Zeichenconvertierung ausgeben                              *
********************************************************************************
               ;>PART 'charcout'
charcout:       movem.l D0-A6,-(SP)
                lea     convert_tab(A4),A0
                andi.w  #$FF,D0
                move.b  0(A0,D0.w),D0             ;Zeichen konvertieren
                bra.s   c_char1
               ;>ENDPART
********************************************************************************
* Zeichen in D0 ohne Steuerzeichen ausgeben                                    *
********************************************************************************
               ;>PART 'charout'
charout:        movem.l D0-A6,-(SP)
c_char1:        tst.b   device(A4)
                bmi.s   c_prn
                bne     c_file
                bsr     char_out
                bsr.s   c_cright
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Steuerzeichen                                                                *
********************************************************************************
               ;>PART 'c_cxxx'
c_cright:       addq.w  #1,spalte(A4)
                cmpi.w  #79,spalte(A4)
                ble.s   c_cdow2
c_crlr:         clr.w   spalte(A4)
c_cdown:        addq.w  #1,zeile(A4)
                move.w  zeile(A4),D1
                addq.w  #1,D1
                cmp.w   down_lines(A4),D1
                ble.s   c_cdow2
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                bra     scrollup
c_cdow2:        rts

c_inson:        not.b   ins_mode(A4)              ;Autoinsert an/aus
                bra     set_ins_flag

c_tab:          tst.b   ins_mode(A4)
                bne.s   c_tab2                    ;Insert-Mode an! =>
                move.w  spalte(A4),D6
                addq.w  #8,D6
                andi.w  #248,D6
                cmp.w   #80,D6
                bne.s   c_tab1
                subq.w  #1,D6
c_tab1:         move.w  D6,spalte(A4)
                rts
c_tab2:         bsr     c_ins                     ;Zeichen einfügen
                bsr.s   c_cright                  ;Cursor eine Position nach rechts
                moveq   #7,D6
                and.w   spalte(A4),D6
                bne.s   c_tab2                    ;Tab-Position erreicht?
                rts

c_eol:          tst.b   device(A4)                ;Ausgabeumlenkung?
                bne     c_rts                     ;dann nix ausgeben
                movem.l D1-A0,-(SP)
                bsr     calc_crsr                 ;Position in A0, Spalte in D3
                neg.w   D3
                add.w   #79,D3
c_eol1:         move.b  #' ',(A0)+
                dbra    D3,c_eol1
                movem.l (SP)+,D1-A0
                move.w  zeile(A4),D0
                bra     update_line

;Rest des Bildschirms l”schen
c_eop:          bsr     calc_crsr                 ;Position in A0, Spalte in D3
                lea     screen+2080(A4),A1
c_eop1:         move.b  #' ',(A0)+                ;Rest der Seite l”schen
                cmpa.l  A1,A0
                blo.s   c_eop1
                move.w  zeile(A4),D0
c_eop2:         bsr     update_line               ;Seitenrest neu ausgeben
                addq.w  #1,D0
                cmp.w   down_lines(A4),D0
                blo.s   c_eop2
                rts

c_del:          bsr     calc_crsr                 ;Adresse in A0, Spalte in D3
                neg.w   D3
                add.w   #78,D3                    ;D3 = 78-D3
                bmi.s   c_del1
                lea     1(A0),A1
c_del2:         move.b  (A1)+,(A0)+
                dbra    D3,c_del2
c_del1:         move.b  #' ',(A0)+                ;Space ans Zeilenende
                move.w  zeile(A4),D0
                bra     update_line               ;Zeile neu ausgeben

c_bakspc:       bsr     calc_crsr                 ;Adresse in A0, Spalte in D3
                tst.w   D3
                beq.s   c_rts
                cmpi.w  #10,spalte(A4)
                bne.s   c_baksp1
                cmpi.b  #'>',-1(A0)
                beq.s   c_rts
                cmpi.b  #'¯',-1(A0)
                beq.s   c_rts
                cmpi.b  #'',-1(A0)
                beq.s   c_rts
c_baksp1:       subq.w  #1,spalte(A4)
                neg.w   D3
                add.w   #79,D3                    ;D3 = 79-D3
                lea     -1(A0),A1
c_baksp2:       move.b  (A0)+,(A1)+
                dbra    D3,c_baksp2
                move.b  #' ',(A1)+                ;Space ans Zeilenende
                move.w  zeile(A4),D0
                bra     update_line               ;Zeile neu ausgeben
c_rts:          rts

c_ins:          bsr     calc_crsr                 ;Adresse in A0, Spalte in D3
                neg.w   D3
                add.w   #79,D3                    ;D3 = 79-D3
                lea     0(A0,D3.w),A1
                lea     1(A0,D3.w),A0
                beq.s   c_ins2                    ;Insert in der letzten Spalte
                subq.w  #1,D3
c_ins1:         move.b  -(A1),-(A0)
                dbra    D3,c_ins1
c_ins2:         move.b  #' ',-(A0)                ;Space einsetzen
                move.w  zeile(A4),D0
                bra     update_line               ;Zeile neu ausgeben

c_cleft:        subq.w  #1,spalte(A4)
                bpl.s   c_rts
                move.w  #79,spalte(A4)
c_cup:          subq.w  #1,zeile(A4)
                bpl.s   c_rts
                clr.w   zeile(A4)
                bra     scrolldwn

c_bell:         lea     bell_data(PC),A0

;************************************************************************
;* Sound ab A0 "erklingen" lassen                                       *
;************************************************************************
do_sound:       movem.l D0/A1,-(SP)
                lea     $FFFF8800.w,A1
do_sound1:      move.w  (A0)+,D0
                bmi.s   do_sound2
                movep.w D0,0(A1)
                bra.s   do_sound1
do_sound2:      movem.l (SP)+,D0/A1
                rts

;************************************************************************
;* Sounddaten                                                           *
;************************************************************************
bell_data:     DC.W $34,$0100,$0200,$0300,$0400,$0500,$0600
               DC.W $07FE,$0810,$0900,$0A00,$0B00,$0C10,$0D09,-1
clickdata:     DC.W $3B,$0100,$0200,$0300,$0400,$0500,$0600
               DC.W $07FE,$0810,$0D03,$0B80,$0C01,-1

;************************************************************************
;* weiter Bildschirm-Befehle                                            *
;************************************************************************
c_clrhome:      bsr     clr_maus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                move.w  upper_offset(A4),D0
                lsl.w   #4,D0
                adda.w  D0,A0
                move.w  down_lines(A4),D0
c_clho1:        moveq   #79,D1
c_clho3:        clr.l   (A0)+                     ;20 Zeilen l”schen
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D1,c_clho3
                dbra    D0,c_clho1
                bsr     set_maus
                move.l  D2,-(SP)
                move.w  upper_offset(A4),D0
                lea     screen(A4),A0
                adda.w  D0,A0
                move.w  down_lines(A4),D0         ;20 Zeilen l”schen
                move.l  #'    ',D2
c_clho2:        moveq   #4,D1
c_clho4:        move.l  D2,(A0)+
                move.l  D2,(A0)+
                move.l  D2,(A0)+
                move.l  D2,(A0)+
                dbra    D1,c_clho4
                dbra    D0,c_clho2
                move.l  (SP)+,D2
c_home:         clr.l   zeile(A4)
                rts

c_undo:         lea     _zeile2(A4),A6
                tst.b   (A6)
                beq.s   c_undo2
                clr.w   spalte(A4)
                jsr     @c_eol(A4)                ;Zeile l”schen
c_undo1:        move.b  (A6)+,D0                  ;Buffer in die Zeile ergiežen
                beq.s   c_undo2
                bsr     charout                   ;Zeichen ausgeben
                bra.s   c_undo1
c_undo2:        rts

c_lline:        move.w  spalte(A4),-(SP)
                lea     _zeile3(A4),A6
                tst.b   (A6)
                beq.s   c_llin2                   ;Keine Zeile im Buffer
                moveq   #0,D0
                clr.w   spalte(A4)
                moveq   #78,D7
c_llin1:        move.b  (A6)+,D0                  ;Buffer in die Zeile ergiežen
                bsr     charout                   ;Zeichen ausgeben
                dbra    D7,c_llin1
c_llin2:        move.w  (SP)+,spalte(A4)
                rts

c_sline:        move.w  spalte(A4),-(SP)
                clr.w   spalte(A4)
                bsr     calc_crsr
                lea     _zeile3(A4),A1
                moveq   #19,D0
c_slin1:        move.l  (A0)+,(A1)+               ;Zeile in Buffer
                dbra    D0,c_slin1
                move.w  (SP)+,spalte(A4)
                rts

c_cdl:          move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                clr.w   spalte(A4)
                bsr     calc_crsr
                cmpi.b  #'$',(A0)
                bne.s   c_cdl1
                move.w  #8,spalte(A4)
c_cdl1:         rts

c_clrli:        move.w  zeile(A4),D0
                bra     scroll_up2

c_insli:        move.w  zeile(A4),D0
                bra     scroll_dn2

c_end:          clr.b   direct(A4)
                clr.w   spalte(A4)
                bsr     calc_crsr
                lea     _zeile(A4),A1
                moveq   #19,D0
c_end1:         move.l  (A0)+,(A1)+               ;Zeile in Buffer
                dbra    D0,c_end1
c_end2:         cmpi.b  #' ',-(A1)                ;Spaces am Zeilenende entfernen
                beq.s   c_end2
                addq.w  #1,A1
                clr.b   (A1)
                lea     _zeile(A4),A0
                lea     _zeile2(A4),A1
c_end3:         move.b  (A0)+,(A1)+               ;Zeile in den UNDO-Buffer kopieren
                bne.s   c_end3
                jsr     @crout(A4)                ;CR noch ausgeben
                addq.l  #4,SP                     ;Stack zurück
                rts

c_scrup:        move.l  zeile(A4),-(SP)
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                bsr     c_cdown
                move.l  (SP)+,zeile(A4)
                rts


c_scrdown:      move.l  zeile(A4),-(SP)
                clr.w   zeile(A4)
                bsr     c_cup
                move.l  (SP)+,zeile(A4)
                rts

c_asyup:        move.l  zeile(A4),-(SP)
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                bsr     c_cdown
                move.l  (SP)+,zeile(A4)
                move.w  zeile(A4),D0
                subq.w  #1,D0
                bpl.s   c_asyu1
                moveq   #0,D0
c_asyu1:        move.w  D0,zeile(A4)
                rts

c_asydown:      move.l  zeile(A4),-(SP)
                clr.w   zeile(A4)
                bsr     c_cup
                move.l  (SP)+,zeile(A4)
                move.w  zeile(A4),D0
                addq.w  #1,D0
                cmp.w   down_lines(A4),D0
                blo.s   c_asyd1
                move.w  down_lines(A4),D0
                subq.w  #1,D0
c_asyd1:        move.w  D0,zeile(A4)
                rts

c_scrlft:       clr.w   spalte(A4)
                bsr     calc_crsr
                moveq   #0,D0
                cmpi.b  #'$',(A0)
                bne.s   c_scrl1
                moveq   #10,D0
c_scrl1:        move.w  D0,spalte(A4)
                rts

c_scrrgt:       move.w  #79,spalte(A4)
                bsr     calc_crsr
                moveq   #78,D0
c_scrr1:        cmpi.b  #' ',-(A0)
                dbne    D0,c_scrr1
                bne.s   c_scrr2
                moveq   #78,D0
c_scrr2:        addq.w  #1,D0
                move.w  D0,spalte(A4)
                rts
               ;>ENDPART
********************************************************************************
* Asc-Zeichen in D0 auf Bildschirm                                             *
********************************************************************************
               ;>PART 'char_out'
char_out:       movem.l D0-D3/A0-A1,-(SP)
                and.w   #$FF,D0
                bsr     clr_maus
                bsr     calc_crsr
                move.b  D0,(A0)                   ;ASCII-Zeichen einsetzen
                lea     debugger_scr(A4),A1
                tst.b   scr_moni(A1)
                bne     char_o3                   ;Farbmonitor
                movea.l s_w_font(A4),A0           ;Fontadresse
                adda.w  D0,A0                     ;plus ASCII-Code (= Zeichenadr)
                lsl.w   #4,D2                     ;Cursorzeile * 1280
                add.w   D3,D2                     ;+ Cursorspalte
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                move.b  (A0),(A1)
                move.b  $0100(A0),$50(A1)
                move.b  $0200(A0),$A0(A1)
                move.b  $0300(A0),$F0(A1)
                move.b  $0400(A0),$0140(A1)
                move.b  $0500(A0),$0190(A1)
                move.b  $0600(A0),$01E0(A1)
                move.b  $0700(A0),$0230(A1)       ;Das Zeichen ausgeben
                move.b  $0800(A0),$0280(A1)
                move.b  $0900(A0),$02D0(A1)
                move.b  $0A00(A0),$0320(A1)
                move.b  $0B00(A0),$0370(A1)
                move.b  $0C00(A0),$03C0(A1)
                move.b  $0D00(A0),$0410(A1)
                move.b  $0E00(A0),$0460(A1)
                move.w  upper_line(A4),D0
                neg.w   D0
                addq.w  #4,D0
                cmp.w   zeile(A4),D0
                beq.s   char_o2
                move.w  zeile(A4),D0
                addq.w  #1,D0
                beq.s   char_o2
                move.b  $0F00(A0),$04B0(A1)
char_o2:        bsr     set_maus
                movem.l (SP)+,D0-D3/A0-A1
                rts
char_o3:        movea.l farbfont(A4),A0
                adda.w  D0,A0                     ;Adresse des Zeichens holen
                lsl.w   #4,D2                     ;Cursorzeile * 1280
                move.w  D3,D1
                andi.w  #-2,D3
                add.w   D3,D3
                add.w   D3,D2                     ;+ (Spalte and -2) * 2
                andi.w  #1,D1
                add.w   D1,D2                     ;+ (Spalte and 1)
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                move.b  (A0),(A1)
                move.b  $0100(A0),$A0(A1)
                move.b  $0200(A0),$0140(A1)
                move.b  $0300(A0),$01E0(A1)
                move.b  $0400(A0),$0280(A1)       ;Zeichen ausgeben
                move.b  $0500(A0),$0320(A1)
                move.b  $0600(A0),$03C0(A1)
                move.b  $0700(A0),$0460(A1)
                bsr     set_maus
                movem.l (SP)+,D0-D3/A0-A1
                rts
               ;>ENDPART
********************************************************************************
* Cursorposition errechnen (Zeiger in A0)                                      *
********************************************************************************
               ;>PART 'calc_crsr'
calc_crsr:      lea     screen(A4),A0
                move.w  zeile(A4),D2
                add.w   upper_line(A4),D2
                move.w  D2,D1
                lsl.w   #2,D1                     ;mal 80
                add.w   D1,D2
                lsl.w   #4,D2
                move.w  spalte(A4),D3
                adda.w  D2,A0
                adda.w  D3,A0
                rts
               ;>ENDPART
********************************************************************************
* Draw line (Zeile in D0)                                                      *
********************************************************************************
               ;>PART 'draw_line'
draw_line:      movem.l D0-D4,-(SP)
                bsr     clr_maus
                moveq   #2,D3
                lea     debugger_scr(A4),A0
                cmpi.b  #2,scr_rez(A0)
                beq.s   draw_line1                ;s/w =>
                moveq   #4,D3
                and.b   #$FE,D0
draw_line1:     mulu    #80,D0
                movea.l scr_adr(A0),A0
                lea     0(A0,D0.w),A0
                moveq   #-1,D1
                moveq   #39,D2
draw_line2:     move.w  D1,(A0)
                adda.w  D3,A0                     ;Plane-Offset drauf
                dbra    D2,draw_line2
                bsr     set_maus
                movem.l (SP)+,D0-D4
                rts
               ;>ENDPART
********************************************************************************
* Zeile auf Device umlenken                                                    *
********************************************************************************
               ;>PART 'wrt_dev'
wrt_dev:        movea.l A0,A2
                lea     prn_buff(A4),A1
write_dev4:     move.b  (A0)+,D0                  ;Zeile in den Ausgabebuffer
                beq.s   write_dev7
                cmp.b   #32,D0
                blo.s   write_dev5
                cmp.b   #'ú',D0
                bne.s   write_dev6
write_dev5:     moveq   #'.',D0
write_dev6:     move.b  D0,(A1)+
                bra.s   write_dev4
write_dev7:     suba.l  A2,A0
                subq.l  #1,A0
                move.w  A0,prn_pos(A4)            ;Pointer hinter die Zeile (für CR)
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Zeile D0 neu ausgeben                                                        *
********************************************************************************
               ;>PART 'update_line'
update_line:    movem.l D0-A6,-(SP)
                bsr     clr_maus
                lea     screen(A4),A0
                add.w   upper_line(A4),D0
                move.w  D0,D1
                lsl.w   #2,D1                     ;mal 80
                add.w   D1,D0
                lsl.w   #4,D0
                adda.w  D0,A0                     ;Adresse der Bildschirmzeile
                moveq   #80,D1
                bra.s   write_linee
               ;>ENDPART
********************************************************************************
* Text ab A0 ausgeben                                                          *
* D0 - Zeile (-5 bis 19)                                                       *
********************************************************************************
               ;>PART 'write_line'
write_line:     movem.l D0-A6,-(SP)
                tst.b   device(A4)                ;Ausgabe in Datei, auf Drucker?
                bne.s   wrt_dev                   ;dann weg
                bsr     clr_maus
                lea     screen(A4),A2
                add.w   upper_line(A4),D0
                move.w  D0,D1
                lsl.w   #2,D1                     ;mal 80
                add.w   D1,D0
                lsl.w   #4,D0
                adda.w  D0,A2                     ;Adresse der Bildschirmzeile
                lea     80(A2),A3
                move.b  (A3),D1                   ;1.Zeichen der Folgezeile retten
                movea.l A0,A1
write_line0:    move.b  (A1)+,(A2)+               ;L„nge der Zeile ermitteln
                bne.s   write_line0
                move.b  D1,(A3)                   ;1.Zeichen der Folgezeile zurück
                subq.l  #1,A2
write_line00:   cmpa.l  A3,A2
                bhs.s   write_line01
                move.b  #' ',(A2)+                ;Rest der Zeile mit Space auffüllen
                bra.s   write_line00
write_line01:   suba.l  A0,A1
                move.w  A1,D1
                subq.w  #1,D1                     ;L„nge der Zeile

write_linee:    lsl.w   #4,D0                     ;mal 1280
                lea     debugger_scr(A4),A1
                movea.l scr_adr(A1),A2
                adda.w  D0,A2
                moveq   #80,D2
                cmp.w   D1,D2
                bhs.s   write_line1
                moveq   #80,D1
write_line1:    sub.w   D1,D2
                tst.b   scr_moni(A1)              ;Farbe?
                bne     write_line11              ;Ja! =>
                movea.l s_w_font(A4),A1
                bra.s   write_line3
write_line2:    moveq   #0,D0
                move.b  (A0)+,D0
                lea     0(A1,D0.w),A3
                move.b  (A3),(A2)+
                move.b  $0100(A3),79(A2)
                move.b  $0200(A3),159(A2)
                move.b  $0300(A3),239(A2)
                move.b  $0400(A3),319(A2)
                move.b  $0500(A3),399(A2)
                move.b  $0600(A3),479(A2)
                move.b  $0700(A3),559(A2)
                move.b  $0800(A3),639(A2)
                move.b  $0900(A3),719(A2)
                move.b  $0A00(A3),799(A2)
                move.b  $0B00(A3),879(A2)
                move.b  $0C00(A3),959(A2)
                move.b  $0D00(A3),1039(A2)
                move.b  $0E00(A3),1119(A2)
                move.b  $0F00(A3),1199(A2)
write_line3:    dbra    D1,write_line2
                tst.w   D2
                beq.s   write_line10
                moveq   #80,D0
                sub.w   D2,D0
                moveq   #0,D3
                moveq   #15,D1
write_line4:    move.w  D2,D4
                lsr.w   #1,D4
                bhs.s   write_line5
                move.b  D3,(A2)+
write_line5:    lsr.w   #1,D4
                bhs.s   write_line6
                move.w  D3,(A2)+
write_line6:    lsr.w   #1,D4
                bhs.s   write_line9
                bra.s   write_line8
write_line7:    move.l  D3,(A2)+
write_line8:    move.l  D3,(A2)+
write_line9:    dbra    D4,write_line7
                adda.w  D0,A2
                dbra    D1,write_line4
write_line10:   bsr     set_maus
                movem.l (SP)+,D0-A6
                rts

write_line11:   move.w  A2,D4
                moveq   #0,D5
                movea.l farbfont(A4),A1
                bra.s   write_line13
write_line12:   moveq   #0,D0
                move.b  (A0)+,D0
                lea     0(A1,D0.w),A3
                move.b  (A3),(A2)+
                move.b  $0100(A3),159(A2)
                move.b  $0200(A3),319(A2)
                move.b  $0300(A3),479(A2)
                move.b  $0400(A3),639(A2)
                move.b  $0500(A3),799(A2)
                move.b  $0600(A3),959(A2)
                move.b  $0700(A3),1119(A2)
                bchg    D5,D4
                beq.s   write_line13
                addq.l  #2,A2
write_line13:   dbra    D1,write_line12
                tst.w   D2
                beq.s   write_line19
                moveq   #0,D3
                bclr    D5,D4
                beq.s   write_line14
                move.b  D3,(A2)+
                move.b  D3,159(A2)
                move.b  D3,319(A2)
                move.b  D3,479(A2)
                move.b  D3,639(A2)
                move.b  D3,799(A2)
                move.b  D3,959(A2)
                move.b  D3,1119(A2)
                subq.w  #1,D2
write_line14:   bra.s   write_line16
write_line15:   move.w  D3,(A2)+
                move.w  D3,158(A2)
                move.w  D3,318(A2)
                move.w  D3,478(A2)
                move.w  D3,638(A2)
                move.w  D3,798(A2)
                move.w  D3,958(A2)
                move.w  D3,1118(A2)
write_line16:   dbra    D2,write_line15
write_line19:   bsr     set_maus

                IFNE ultradev
                CHECKEXTENSION_NOUD .noUD
                bsr ultradev_mirror_vga
.noUD:                
                ENDC

                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Bildschirm um eine Zeile hochscrollen                                        *
********************************************************************************
               ;>PART 'scroll_up'
scroll_up:      movem.l D0-A3,-(SP)
                bsr     clr_maus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                move.w  upper_offset(A4),D0
                lsl.w   #4,D0
                adda.w  D0,A0
                lea     1280(A0),A1
                move.w  down_lines(A4),D0
                lsl.w   #4,D0
                subq.w  #1,D0
scr_up1:        movem.l (A1)+,D2-D7/A2-A3
                movem.l D2-D7/A2-A3,(A0)
                movem.l (A1)+,D2-D7/A2-A3         ;80 Byte kopieren
                movem.l D2-D7/A2-A3,32(A0)
                movem.l (A1)+,D2-D5
                movem.l D2-D5,64(A0)
                lea     80(A0),A0
                dbra    D0,scr_up1
                moveq   #79,D0
scr_up4:        clr.l   (A0)+                     ;26.Zeile l”schen
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D0,scr_up4
                bsr     set_maus
                lea     screen(A4),A0
                adda.w  upper_offset(A4),A0
                lea     80(A0),A1
                move.w  down_lines(A4),D0
                subq.w  #1,D0
scr_up2:        movem.l (A1)+,D2-D7/A2-A3         ;21 Zeilen scrollen
                movem.l D2-D7/A2-A3,(A0)
                movem.l (A1)+,D2-D7/A2-A3
                movem.l D2-D7/A2-A3,32(A0)
                movem.l (A1)+,D2-D5
                movem.l D2-D5,64(A0)
                lea     80(A0),A0
                dbra    D0,scr_up2
                move.l  #'    ',D1                ;26.Zeile l”schen
                moveq   #4,D0
scr_up3:        move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,scr_up3
                bsr.s   scroll_delay
                movem.l (SP)+,D0-A3
                rts
               ;>ENDPART
********************************************************************************
* Wenn CTRL gedrückt wird, Verz”gerung beim Scrollen                           *
********************************************************************************
               ;>PART 'scroll_delay'
scroll_delay:   btst    #2,kbshift(A4)            ;CTRL gedrückt?
                beq.s   scroll_delay2             ;Ende, wenn nicht
                moveq   #0,D0
                move.w  scroll_d(A4),D0           ;Scrollverz”gerung holen
                lsl.l   #4,D0
scroll_delay1:  subq.l  #1,D0
                bne.s   scroll_delay1             ;und verz”gern
scroll_delay2:  rts
               ;>ENDPART
********************************************************************************
* Bildschirm um eine Zeile runterscrollen                                      *
********************************************************************************
               ;>PART 'scroll_dn'
scroll_dn:      movem.l D0-A3,-(SP)
                bsr     clr_maus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                lea     32000(A0),A0
                movea.l A0,A1
                lea     1280(A0),A0
                move.w  down_lines(A4),D0
                lsl.w   #4,D0
                subq.w  #1,D0
scr_dn1:        movem.l -32(A1),D2-D7/A2-A3
                movem.l D2-D7/A2-A3,-(A0)
                lea     -64(A1),A1
                movem.l (A1),D2-D7/A2-A3
                movem.l D2-D7/A2-A3,-(A0)
                lea     -16(A1),A1
                movem.l (A1),D2-D5
                movem.l D2-D5,-(A0)
                dbra    D0,scr_dn1
                moveq   #79,D0
scr_dn2:        clr.l   -(A0)
                clr.l   -(A0)
                clr.l   -(A0)
                clr.l   -(A0)
                dbra    D0,scr_dn2
                bsr     set_maus
                lea     screen+2080(A4),A0
                lea     screen+2000(A4),A1
                move.w  down_lines(A4),D0
                subq.w  #1,D0
scr_dn4:        movem.l -32(A1),D2-D7/A2-A3
                movem.l D2-D7/A2-A3,-(A0)
                lea     -64(A1),A1
                movem.l (A1),D2-D7/A2-A3
                movem.l D2-D7/A2-A3,-(A0)
                lea     -16(A1),A1
                movem.l (A1),D2-D5
                movem.l D2-D5,-(A0)
                dbra    D0,scr_dn4
                move.l  #'    ',D1
                moveq   #4,D0
scr_dn5:        move.l  D1,-(A0)                  ;oberste Zeile l”schen
                move.l  D1,-(A0)
                move.l  D1,-(A0)
                move.l  D1,-(A0)
                dbra    D0,scr_dn5
                bsr     scroll_delay
                movem.l (SP)+,D0-A3
                rts
               ;>ENDPART
********************************************************************************
* Bildschirm ab D0 um eine Zeile hochscrollen                                  *
********************************************************************************
               ;>PART 'scroll_up2'
scroll_up2:     movem.l D0-A3,-(SP)
                bsr     clr_maus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                lea     32000-1280(A0),A1
                move.w  D0,D2
                add.w   upper_line(A4),D2
                mulu    #1280,D2
                adda.w  D2,A0
                cmpa.l  A1,A0
                beq.s   scr_upf
scr_upa:        move.l  1280(A0),(A0)+
                move.l  1280(A0),(A0)+
                move.l  1280(A0),(A0)+
                move.l  1280(A0),(A0)+
                cmpa.l  A1,A0
                bls.s   scr_upa
scr_upf:        moveq   #79,D1
scr_upb:        clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D1,scr_upb
                lea     screen(A4),A0
                adda.w  upper_offset(A4),A0
                lea     screen+2000(A4),A1
                mulu    #80,D0
                adda.w  D0,A0
                cmpa.l  A1,A0
                beq.s   scr_upe
scr_upc:        move.l  80(A0),(A0)+
                move.l  80(A0),(A0)+
                move.l  80(A0),(A0)+
                move.l  80(A0),(A0)+
                cmpa.l  A1,A0
                bne.s   scr_upc
scr_upe:        move.l  #'    ',D1
                moveq   #4,D0
scr_upd:        move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,scr_upd
                bsr     set_maus
                movem.l (SP)+,D0-A3
                rts
               ;>ENDPART
********************************************************************************
* Bildschirm ab D0 um eine Zeile runterscrollen                                *
********************************************************************************
               ;>PART 'scroll_dn2'
scroll_dn2:     movem.l D0-A3,-(SP)
                bsr     clr_maus
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                move.w  D0,D1
                mulu    #1280,D1
                move.w  upper_offset(A4),D2
                lsl.w   #4,D2
                lea     0(A0,D2.w),A1
                adda.w  D1,A1
                lea     32000-1280(A0),A0
                cmpa.l  A1,A0
                beq.s   scr_dne
scr_dna:        move.l  -(A0),1280(A0)
                move.l  -(A0),1280(A0)
                move.l  -(A0),1280(A0)
                move.l  -(A0),1280(A0)
                cmpa.l  A1,A0
                bgt.s   scr_dna
scr_dne:        moveq   #79,D1
scr_dnb:        clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D1,scr_dnb
                lea     screen(A4),A0
                adda.w  upper_offset(A4),A0
                mulu    #80,D0
                lea     0(A0,D0.w),A1
                lea     screen+2000(A4),A0
                cmpa.l  A1,A0
                bls.s   scr_dnf
scr_dnc:        move.l  -(A0),80(A0)
                move.l  -(A0),80(A0)
                move.l  -(A0),80(A0)
                move.l  -(A0),80(A0)
                cmpa.l  A1,A0
                bne.s   scr_dnc
scr_dnf:        move.l  #'    ',D1
                moveq   #4,D0
scr_dnd:        move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                move.l  D1,(A0)+
                dbra    D0,scr_dnd
                bsr     set_maus
                movem.l (SP)+,D0-A3
                rts
               ;>ENDPART
********************************************************************************
* Hoch- und Runterscrollen mit Dump/...                                        *
********************************************************************************
               ;>PART 'scrollup'
scrollup:       movem.l D0-A6,-(SP)
                cmpi.b  #$50,direct(A4)           ;Cursor down gedrückt?
                bne.s   scruf
                clr.b   direct(A4)
                lea     screen+1920(A4),A1
                move.w  down_lines(A4),D7
                subq.w  #1,D7
scru1:          movea.l A1,A0
                jsr     @get_line(A4)             ;Basisadresse holen (wenn vorhanden)
                move.b  D0,D6                     ;idnt_char merken
                cmp.b   #'.',D6
                beq.s   fnd_up2                   ;Dump.W/L
                cmp.b   #',',D6
                beq.s   fnd_up1                   ;Dump
                cmp.b   #'!',D6
                beq     fnd_up4                   ;Disassemble (symbolisch)
                cmp.b   #')',D6
                beq     fnd_up5                   ;ASCII-Dump
                cmp.b   #'/',D6
                beq     fnd_up6                   ;Disassemble (normal)
                cmp.b   #'(',D6
                beq     fnd_up7                   ;Symboltabelle
                cmp.b   #'&',D6
                beq     fnd_up8                   ;Sourcetext
scru2:          lea     -80(A1),A1
                dbra    D7,scru1                  ;nix los in der Zeile
                bra.s   scrue
scruf:          bsr     scroll_up
scrue:          movem.l (SP)+,D0-A6
                rts
fnd_up1:        adda.w  def_size(A4),A6           ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                move.w  down_lines(A4),zeile(A4)
                moveq   #0,D3
                jsr     cmd_dump7                 ;Hex-Daten ausgeben (+ASCII)
                bsr     scroll_up
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                bra.s   scrue
fnd_up2:        bsr     getb
                moveq   #1,D3                     ;Breite in Bytes -1 (Default für Word)
                cmp.b   #'W',D0
                beq.s   fnd_up3
                cmp.b   #'L',D0
                bne.s   scru2                     ;Das war wohl nix
                moveq   #3,D3                     ;3 Byte+1 = Breite
fnd_up3:        adda.w  def_size(A4),A6           ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                move.w  down_lines(A4),zeile(A4)
                jsr     cmd_dump7                 ;Zeile ausgeben
                bsr     scroll_up
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                bra.s   scrue

fnd_up4:        st      list_flg(A4)              ;symbolische Ausgabe
fnd_up6:        move.l  A6,D1
                addq.l  #1,D1
                andi.b  #$FE,D1                   ;Adresse nun gerade
                movea.l D1,A6
                move.l  A3,-(SP)
                bsr     get_dlen                  ;L„nge des Opcodes in der letzten Zeile
                movea.l (SP)+,A3
                move.w  down_lines(A4),zeile(A4)
                bsr     do_disass                 ;Opcode disassemblieren und ausgeben
                bne     scrue                     ;Illegaler RAM-Bereich,kein Scrollen
                move.l  A6,default_adr(A4)        ;Hier beginnt der n„chste Opcode
                bsr     scroll_up
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                sf      list_flg(A4)
                bra     scrue

fnd_up5:        lea     64(A6),A6                 ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                move.w  down_lines(A4),zeile(A4)
                jsr     asc_out                   ;ASCII-Daten ausgeben
                bsr     scroll_up
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                bra     scrue
fnd_up7:        lea     14(A6),A6
                cmpa.l  sym_end(A4),A6
                bhs     scrue                     ;Ende erreicht => Symboltabelle ignorieren
                move.w  down_lines(A4),zeile(A4)
                clr.w   spalte(A4)
                jsr     sym_out
                bsr     scroll_up
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                bra     scrue

fnd_up8:        moveq   #4,D6                     ;5 Ziffern holen (Zeilennummer)
                moveq   #0,D7
fnd_up9:        bsr     getb                      ;Ziffer holen
                sub.b   #'0',D0
                bmi     scru2                     ;nicht scrollen
                cmp.b   #10,D0
                bhs     scru2                     ;nicht scrollen
                ext.w   D0
                mulu    #10,D7
                add.w   D0,D7
                dbra    D6,fnd_up9
                movea.l ass_vector(A4),A5
                move.l  A5,D0
                beq     scru2                     ;nicht scrollen
                move.w  D7,D0                     ;Zeilennummer
                addq.w  #1,D0
                beq     scrue
                move.w  down_lines(A4),zeile(A4)  ;Sourcetext scrollen
                clr.w   spalte(A4)
                jsr     src_out                   ;Zeile ausgeben
                move    SR,D0
                move.w  down_lines(A4),zeile(A4)
                subq.w  #1,zeile(A4)
                move.w  #10,spalte(A4)
                move    D0,CCR
                bne     scrue                     ;out of Source
                bsr     scroll_up
                bra     scrue
               ;>ENDPART
               ;>PART 'scrolldwn'
scrolldwn:      movem.l D0-A6,-(SP)
                cmpi.b  #$48,direct(A4)           ;Cursor up gedrückt?
                bne.s   scrdf
                clr.b   direct(A4)
                lea     screen(A4),A1
                move.w  upper_offset(A4),D7
                adda.w  D7,A1
                move.w  down_lines(A4),D7
                subq.w  #1,D7
scrd1:          movea.l A1,A0
                jsr     @get_line(A4)             ;Basisadresse holen (wenn vorhanden)
                move.b  D0,D6                     ;idnt_char merken
                cmp.b   #'.',D6
                beq.s   fnd_dwn2                  ;Dump.W/L
                cmp.b   #',',D6
                beq.s   fnd_dwn1                  ;Dump
                cmp.b   #'!',D6
                beq     fnd_dwn4                  ;Disassemble (symbolisch)
                cmp.b   #')',D6
                beq     fnd_dwn0                  ;ASCII-Dump
                cmp.b   #'/',D6
                beq.s   fnd_dwn5                  ;Disassemble (normal)
                cmp.b   #'(',D6
                beq     fnd_dwn6                  ;Symboltabelle
                cmp.b   #'&',D6
                beq     fnd_dwn100                ;Sourcetext
scrd2:          lea     80(A1),A1
                dbra    D7,scrd1                  ;nix los in der Zeile
                bra.s   scrde
scrdf:          bsr     scroll_dn
scrde:          movem.l (SP)+,D0-A6
                rts

fnd_dwn1:       suba.w  def_size(A4),A6           ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                clr.w   zeile(A4)
                bsr     scroll_dn
                moveq   #0,D3
                jsr     cmd_dump7                 ;Hex-Daten ausgeben (+ASCII)
                move.w  #10,spalte(A4)
                bra.s   scrde
fnd_dwn2:       bsr     getb
                moveq   #1,D3                     ;Breite in Bytes -1 (Default für Word)
                cmp.b   #'W',D0
                beq.s   fnddwn3
                cmp.b   #'L',D0
                bne.s   scrd2                     ;Das war wohl nix
                moveq   #3,D3                     ;3 Byte+1 = Breite
fnddwn3:        suba.w  def_size(A4),A6           ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                clr.w   zeile(A4)
                bsr     scroll_dn
                jsr     cmd_dump7                 ;Zeile ausgeben
                move.w  #10,spalte(A4)
                bra.s   scrde
fnd_dwn4:       st      list_flg(A4)              ;Symbolisch abschalten
fnd_dwn5:       move.l  A6,D2
                addq.l  #1,D2
                and.b   #$FE,D2                   ;Adresse nun gerade
                moveq   #30,D5
fnddwn8:        movea.l D2,A6
                suba.w  D5,A6
                tst.l   basep(A4)                 ;Programm geladen?
                beq.s   fnddwn80                  ;weiter, wenn nicht
                movea.l basep(A4),A0              ;Basepageadresse holen
                cmpa.l  A0,A6                     ;Disassembler-Pointer
                blo.s   fnddwn80                  ;< Basepage => Nix zu machen
                movea.l 8(A0),A0                  ;TEXT-Segment-Start
                cmpa.l  A0,A6
                bhs.s   fnddwn80                  ;>= TEXT-Segment-Start => Nix zu machen
                movea.l A0,A6                     ;sonst: Adresse = TEXT-Segment-Start
fnddwn80:       move.l  A6,D0
                bpl.s   fnddwn6
                suba.l  A6,A6
fnddwn6:        movea.l A6,A0
                movem.l D2/D5/A3,-(SP)
                bsr     get_dlen                  ;L„nge des Opcodes in der ersten Zeile
                move    SR,D0
                movem.l (SP)+,D2/D5/A3
                cmpa.l  D2,A6                     ;immer noch zu klein?
                blo.s   fnddwn6                   ;Weiter disassemblieren
                beq.s   fnddwn7                   ;pažt!
fnddwn9:        subq.w  #2,D5                     ;mit'n bižchen weniger probieren
                bhi.s   fnddwn8
                movea.l D2,A0
                subq.l  #2,A0                     ;Besser geht's halt nicht
                bra.s   fnddwn5
fnddwn7:        tst.w   D0
                beq.s   fnddwn9                   ;Fehler beim Disassemblieren
fnddwn5:        movea.l A0,A6
                bsr     check_read                ;Zugriff m”glich?
                bne     scrde                     ;Kein Scrollen, wenn nicht mgl.
                clr.w   zeile(A4)
                move.l  A6,default_adr(A4)        ;Hier beginnt der n„chste Opcode
                bsr     scroll_dn
                bsr     do_disass                 ;Opcode disassemblieren und ausgeben
                move.w  #10,spalte(A4)
                sf      list_flg(A4)              ;Symbolisch wieder an
                bra     scrde
fnd_dwn0:       lea     -64(A6),A6                ;Neue Anfangsadresse
                move.l  A6,default_adr(A4)
                clr.l   zeile(A4)
                bsr     scroll_dn
                jsr     asc_out                   ;ASCII-Daten ausgeben
                move.w  #10,spalte(A4)
                bra     scrde

fnd_dwn6:       lea     -14(A6),A6
                cmpa.l  sym_adr(A4),A6
                blo     scrde                     ;Anfang erreicht => Symboltabelle ignorieren
                clr.l   zeile(A4)
                bsr     scroll_dn
                jsr     sym_out
                move.w  #10,spalte(A4)
                bra     scrde

fnd_dwn100:     moveq   #4,D6                     ;5 Ziffern holen (Zeilennummer)
                moveq   #0,D7
fnd_dwn101:     bsr     getb                      ;Ziffer holen
                sub.b   #'0',D0
                bmi     scrd2                     ;nicht scrollen
                cmp.b   #10,D0
                bhs     scrd2                     ;nicht scrollen
                ext.w   D0
                mulu    #10,D7
                add.w   D0,D7
                dbra    D6,fnd_dwn101
                movea.l ass_vector(A4),A5
                move.l  A5,D0
                beq     scrd2                     ;nicht scrollen
                move.w  D7,D0                     ;Zeilennummer
                subq.w  #1,D0
                blo     scrde                     ;Zeilennummer -1? => raus!
                clr.l   zeile(A4)
                bsr     scroll_dn
                jsr     src_out                   ;Zeile ausgeben
                move.w  #10,spalte(A4)
                bra     scrde
               ;>ENDPART
               ;>PART 'get_line'
get_line:       moveq   #19,D0
get_line1:      cmpi.l  #'    ',(A0)+
                dbne    D0,get_line1
                bne.s   get_line3
get_line2:      moveq   #0,D0                     ;Leerzeile
                rts
get_line3:      subq.l  #4,A0
                bsr     getb                      ;Zeichen aus dem Eingabebuffer holen
                beq.s   get_line8                 ;Leereingabe
                moveq   #$10,D2                   ;Defaultzahlenbasis
                cmp.b   #'0',D0
                blo.s   get_line4                 ;nix

                cmp.b   #'9',D0                   ;Zeichen eine Zahl?
                bls.s   get_line5                 ;ja
get_line4:      jsr     numbas                    ;Zahlenbasis auswerten
                bmi.s   get_line7                 ;nein, keine Zahl!
                move.w  D3,D2                     ;Neue Zahlenbasis setzen
                bsr     getb
get_line5:      jsr     chkval                    ;lfd. zeichen gültig?
                bhs.s   get_line2                 ;nein, nichts gefunden
                moveq   #0,D1                     ;Vorbesetzung von D1
                pea     get_line6(PC)
                movem.l D2-D7/A1-A6,-(SP)
                jmp     w_zahlj                   ;Zahl einlesen
get_line6:      movea.l D1,A6                     ;Adresse merken
get_line7:      cmp.b   #'>',D0
                beq.s   get_line8
                cmp.b   #'',D0
                beq.s   get_line8
                cmp.b   #'¯',D0
                bne.s   get_line9
get_line8:      bsr     getb
get_line9:      tst.b   D0
                rts
               ;>ENDPART
********************************************************************************
* Bildschirm nach Zeilenanfangsadressen=PC durchsuchen                         *
********************************************************************************
               ;>PART 'hunt_pc'
hunt_pc:        movem.l D0-D6/A0-A6,-(SP)
                move.l  merk_pc(A4),D0
                cmp.l   _pc(A4),D0
                beq     hunt_p3
                move.l  _pc(A4),merk_pc(A4)
                moveq   #-1,D7
                move.l  zeile(A4),-(SP)
                lea     screen(A4),A1
                move.w  upper_offset(A4),D6
                adda.w  D6,A1
                clr.w   zeile(A4)                 ;Zeile = 0
                move.w  down_lines(A4),D6         ;20 Zeilen
                subq.w  #1,D6
hunt_p1:        movea.l A1,A0
                cmpi.b  #'$',(A0)+
                bne.s   hunt_p4
                moveq   #0,D1
                moveq   #7,D2                     ;8 Hex-Ziffern holen
hunt_p6:        move.b  (A0)+,D0
                sub.b   #'0',D0
                cmp.b   #9,D0
                bls.s   hunt_p5
                subq.b  #7,D0
                cmp.b   #15,D0
                bls.s   hunt_p5
                sub.b   #32,D0
hunt_p5:        tst.b   D0
                bmi.s   hunt_p4
                cmp.b   #15,D0
                bhi.s   hunt_p4
                lsl.l   #4,D1
                or.b    D0,D1
                dbra    D2,hunt_p6
                cmpi.b  #'>',(A0)
                beq.s   hunt_p7
                cmpi.b  #'',(A0)
                beq.s   hunt_p7
                cmpi.b  #'¯',(A0)
                bne.s   hunt_p4
hunt_p7:        bsr.s   line_char
                cmp.b   #'>',D0
                beq.s   hunt_p2
                move.w  D6,D7
                neg.w   D7
                add.w   down_lines(A4),D7
                subq.w  #1,D7
hunt_p2:        move.w  #9,spalte(A4)
                jsr     @chrout(A4)
                bra.s   hunt_p8
hunt_p4:        ori.w   #$8000,D7
hunt_p8:        addq.w  #1,zeile(A4)
                lea     80(A1),A1
                dbra    D6,hunt_p1                ;nix los in der Zeile
                move.l  (SP)+,zeile(A4)
hunt_p3:        movem.l (SP)+,D0-D6/A0-A6
                rts
               ;>ENDPART
********************************************************************************
* Adresse am Zeilenanfang ausgeben (in D1)                                     *
********************************************************************************
               ;>PART 'anf_adr'
anf_adr:        jsr     hexa2out                  ;Defaultadresse ausgeben
                bsr.s   line_char                 ;Zeichen am Zeilenanfang ermitteln
                jmp     @chrout(A4)               ;und ausgeben
               ;>ENDPART
********************************************************************************
* Zeichen am Zeilenanfang ermitteln                                            *
********************************************************************************
               ;>PART 'line_char'
line_char:      moveq   #'>',D0
                cmp.l   _pc(A4),D1                ;PC in dieser Zeile?
                bne.s   line_char8                ;Nein! =>
                moveq   #'¯',D0                   ;PC markieren
                movem.l D1-D2/A0-A2,-(SP)
                movea.l $08.w,A1
                movea.l SP,A2
                move.l  #line_char7,$08.w
                movea.l D1,A0                     ;Zeiger auf den PC
                move.b  (A0),D2                   ;die obersten 4 Bit des Opcodes holen
                lsr.b   #4,D2
                subq.b  #5,D2                     ;Scc <ea> oder DBcc Dn,<label>
                beq.s   line_char1
                subq.b  #1,D2                     ;Bcc <label>
                bne.s   line_char7                ;kein sinnvoller Opcode =>
                moveq   #$0F,D2
                and.b   (A0),D2                   ;Condition-Maske
                cmp.b   #1,D2
                bhi.s   line_char2                ;Condition testen
                bra.s   line_char9                ;BRA oder BSR => raus
line_char1:     move.w  #$F0C0,D2
                and.w   (A0),D2
                cmp.w   #$50C0,D2
                bne.s   line_char7                ;kein Scc <ea> oder DBcc Dn,<label> =>
                moveq   #$0F,D2
                and.b   (A0),D2                   ;Condition-Maske
line_char2:     lea     anf_adr_tab(PC),A0
line_char3:     tst.b   D2                        ;Position erreicht?
                beq.s   line_char5                ;Ja! =>
line_char4:     tst.b   (A0)+                     ;Eintrag berspringen
                bpl.s   line_char4
                subq.b  #1,D2                     ;und Condition runterz„hlen
                bra.s   line_char3
line_char5:     move.b  (A0)+,D2                  ;die CCR-Maske
                and.w   _sr(A4),D2                ;das CCR-Register dazu
line_char6:     move.b  (A0)+,D1
                bmi.s   line_char7                ;Bedingung ist nicht erfüllt!
                cmp.b   D2,D1                     ;Bedingung erfüllt?
                bne.s   line_char6                ;Nein! =>
line_char9:     moveq   #'',D0                   ;Condition ist erfüllt!
line_char7:     move.l  A1,$08.w
                movea.l A2,SP
                movem.l (SP)+,D1-D2/A0-A2
line_char8:     rts

;               SR-Maske,Ergebnis{,Ergebnis},-1
anf_adr_tab:   DC.B $00,$00,-1                    ;0-T  : 1
               DC.B $01,$02,-1                    ;1-F  : 0
               DC.B $05,$00,-1                    ;2-HI : /C and /Z
               DC.B $05,$01,$04,-1                ;3-LS : C or Z
               DC.B $01,$00,-1                    ;4-CC : /C
               DC.B $01,$01,-1                    ;5-CS : C
               DC.B $04,$00,-1                    ;6-NE : /Z
               DC.B $04,$04,-1                    ;7-EQ : Z
               DC.B $02,$00,-1                    ;8-VC : /V
               DC.B $02,$02,-1                    ;9-VS : V
               DC.B $08,$00,-1                    ;A-PL : /N
               DC.B $08,$08,-1                    ;B-MI : N
               DC.B $0A,$0A,$00,-1                ;C-GE : N and V or /N and /V
               DC.B $0A,$08,$02,-1                ;D-LT : N and /V or /N and V
               DC.B $0E,$0A,$00,-1                ;E-GT : N and V and /Z or /N and /V and /Z
               DC.B $0E,$04,$08,$02,-1            ;F-LE : Z or N and /V or /N and V
               EVEN
               ;>ENDPART
********************************************************************************
* String ab A0, auf Ja oder Nein warten                                        *
********************************************************************************
               ;>PART 'ask_user'
ask_user:       movem.l D0-A6,-(SP)
                move.l  A0,-(SP)
                jsr     @print_line(A4)
                jsr     @c_eol(A4)                ;Zeilenrest l”schen
                move.w  spalte(A4),D7             ;Spalte merken
ask_user1:      bsr     c_bell                    ;bell
                bsr     cursor_on                 ;Cursor anschalten
ask_user2:      jsr     @conin(A4)                ;Tastencode holen
                beq.s   ask_user2                 ;Taste wurde gedrückt
                jsr     @cursor_off(A4)           ;Cursor ausschalten
                jsr     @chrout(A4)               ;Zeichen ausgeben
                move.w  D7,spalte(A4)             ;Cursor wieder zurück
                bclr    #5,D0                     ;in Grožbuchstaben
               IFEQ sprache
                cmp.b   #'J',D0                   ;Ja
               ELSE
                cmp.b   #'Y',D0                   ;Yeah!
               ENDC
                beq.s   ask_user3                 ;Das war's wohl
                cmp.b   #'N',D0
                bne.s   ask_user1                 ;Das war wohl die falsche Taste
                jsr     @crout(A4)
                jmp     (A4)
ask_user3:      jsr     @crout(A4)
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Insert/Overwrite anzeigen                                                    *
********************************************************************************
               ;>PART 'set_ins_flag'
set_ins_flag:   lea     8*14+menue+2(PC),A0        ;Nullword beachten (+2!)
                tst.b   ins_mode(A4)              ;Insert-Mode an?
                bne.s   set_ins_flag1             ;Ja! =>
               IFEQ sprache
                move.l  #'Over',(A0)+
                move.l  #'wrt ',(A0)
                bra.s   set_ins_flag2
set_ins_flag1:  move.l  #'Inse',(A0)+
                move.l  #'rt  ',(A0)
               ELSE
                move.l  #'Over',(A0)+
                move.l  #'wrt ',(A0)
                bra.s   set_ins_flag2
set_ins_flag1:  move.l  #'Inse',(A0)+
                move.l  #'rt  ',(A0)
               ENDC
set_ins_flag2:  bsr.s   draw_menue
                move.w  #-1,entry(A4)             ;Alten Eintrag l”schen
                rts
               ;>ENDPART
********************************************************************************
* Menueeintrag deselektieren                                                    *
********************************************************************************
               ;>PART 'draw_menue'
draw_menue:      movem.l D0-A6,-(SP)
                bsr     clr_maus
                moveq   #0,D0
                moveq   #0,D3
                pea     menue(PC)                  ;Men neu ausgeben
                bsr     print_inv_line
                moveq   #1,D0
                moveq   #-1,D3
                pea     menue2(PC)
                bsr     print_inv_line
                move.w  D3,entry_old(A4)          ;Alten Eintrag l”schen
                move.w  D3,entry(A4)              ;Alten Eintrag l”schen
                bsr     set_maus
                movem.l (SP)+,D0-A6
                rts
               ;>ENDPART
********************************************************************************
* Sprungleiste der Menuefunktionen                                              *
********************************************************************************
               ;>PART 'menue'
;>               DXSET 8,' '
               IFEQ sprache
menue:     DC.B 'Trace   '
               DC.B 'Do PC   '
               DC.B 'Tracrts '
               DC.B 'Ttraps  '
               DC.B 'Skip PC '
               DC.B 'Source  '
               DC.B 'Hexdump '
               DC.B 'Disassm '
               DC.B 'List    '
               DC.B 'Switch  '
               DC.W 0
menue2:        DC.B 'Tr68020 '
               DC.B 'Tnosubs '
               DC.B 'Tracrte '
               DC.B 'Go      '
               DC.B 'xxxxxxxx'
               DC.B 'Marker  '
               DC.B 'Breakp  '
               DC.B 'Info    '
               DC.B 'Direct  '
               DC.B 'Quit    '
               ELSE
menue:          DC.B 'Trace   '
               DC.B 'Do PC   '
               DC.B 'Tracrts '
               DC.B 'Ttraps  '
               DC.B 'Skip PC '
               DC.B 'Source  '
               DC.B 'Hexdump '
               DC.B 'Disassm '
               DC.B 'List    '
               DC.B 'Switch  '
               DC.W 0
menue2:         DC.B 'Tr68020 '
               DC.B 'Tnosubs '
               DC.B 'Tracrte '
               DC.B 'Go      '
               DC.B 'xxxxxxxx'
               DC.B 'Marker  '
               DC.B 'Breakp  '
               DC.B 'Info    '
               DC.B 'Direct  '
               DC.B 'Quit    '
               ENDC
               DC.B 0
               EVEN
               ;>ENDPART
********************************************************************************
* Menueeintrag deselektieren                                                    *
********************************************************************************
               ;>PART 'desel_menue'
desel_menue:     move.w  entry_old(A4),D0          ;Nichts selektiert?
                bmi.s   desel_menue1               ;dann Ende
                lea     iorec_IKBD(A4),A0
                move.w  4(A0),D1
                cmp.w   6(A0),D1
                bne.s   desel_menue1               ;Abbruch, wenn noch eine Taste gedrückt
                move.w  #-1,entry_old(A4)         ;Alten Eintrag l”schen
                moveq   #-1,D7                    ;deselect
                bsr.s   sel_menue
                moveq   #-1,D0
                move.w  D0,entry_old(A4)          ;Alten Eintrag l”schen
                move.w  D0,entry(A4)              ;Aktuellen Eintrag l”schen
desel_menue1:    rts
               ;>ENDPART
********************************************************************************
* Menueeintrag invertieren (Nummer in D0=1-n)                                   *
********************************************************************************
               ;>PART 'sel_menue'
sel_menue:      movem.l D0-D4/A0,-(SP)
                move.w  entry_old(A4),D1          ;Nichts selektiert?
                bmi.s   sel_menue1                 ;dann Ende
                cmp.w   D1,D0
                beq.s   sel_menue5                 ;Immer noch der alte Eintrag?
                move.w  D1,D0
                move.w  #-1,entry_old(A4)         ;Alten Eintrag l”schen
                moveq   #-1,D7
                bsr.s   sel_menue                  ;deselect
sel_menue1:     movem.l (SP),D0-D4/A0
                move.w  D0,entry_old(A4)          ;selektierten Eintrag merken
                move.w  D0,entry(A4)
                subq.w  #1,D0
                lea     menue(PC),A0
                moveq   #0,D1                     ;Zeile 0
                cmp.w   #9,D0                     ;Eintrag>9
                bls.s   sel_menue3                 ;Nein!
                lea     menue2(PC),A0
                moveq   #1,D1                     ;Zeile 1
                sub.w   #10,D0
sel_menue3:     lsl.w   #3,D0                     ;mal 8 (Breite eines Eintrags)
                move.l  zeile(A4),-(SP)           ;Zeile und(!) Spalte retten
                move.w  D1,zeile(A4)
                move.w  D0,spalte(A4)
                adda.w  D0,A0                     ;Zeiger auf den String
                bsr     clr_maus                  ;Die Maus ausschalten
                moveq   #0,D3
                moveq   #-1,D1
                move.w  D7,D2
                tst.w   D1                        ;In Zeile 0
                beq.s   sel_menue6                 ;nicht unterstreichen
                moveq   #-1,D3
sel_menue6:     moveq   #7,D4
sel_menue4:     moveq   #0,D0
                move.b  (A0)+,D0
                bsr     light_char                ;8 Zeichen invertieren
                addq.w  #1,spalte(A4)
                dbra    D4,sel_menue4
                bsr     set_maus                  ;Die Maus darf wieder an
                move.l  (SP)+,zeile(A4)
sel_menue5:     movem.l (SP)+,D0-D4/A0
                rts
               ;>ENDPART
********************************************************************************
* form_do ab A0 ausführen                                                      *
********************************************************************************
               ;>PART 'form_do'
form_do:        movem.l D1-A6,-(SP)
                move.l  zeile(A4),-(SP)
                addq.b  #1,set_lock(A4)           ;Cursorsetzen im VBL verhindern
                st      no_dklick(A4)             ;Kein Doppelklick
                move.w  curflag(A4),-(SP)
                bsr     cursor_off
                suba.l  A5,A5                     ;aktuelle Buttonadr l”schen
                movea.l A0,A1
                bsr     desel_abuttons            ;Alle Exit-Buttons deselektieren
                tst.b   8(A1)                     ;nur ein redraw?
                bmi.s   formddx
                move.b  #1,9(A1)                  ;Hintergrund l”schen
formddx:        bsr     objc_draw                 ;Baum zeichnen
                move.b  #2,9(A1)                  ;bei Redraw nur den Rahmen
                bra.s   form_d0
form_d7:        bsr     c_bell                    ;bell
form_d0:        btst    #1,maustast(A4)           ;Linke Taste gedrückt?
                beq.s   form_d1                   ;Nein!
                clr.b   mausprell(A4)             ;merken, daž gedrückt wird
                bsr     find_button               ;Maus ber einem Button?
form_button:    bne.s   formd8a                   ;Nein!
                btst    #5,9(A5)                  ;Exit-Button?
                beq.s   formd8b                   ;Ja!
                btst    #0,9(A5)                  ;selektiert?
                bne.s   formd8b                   ;ja, alles OK
                bsr     desel_abuttons            ;Exit-Buttons deselektieren
                suba.l  A5,A5                     ;Kein aktueller Button mehr
formd8b:        cmpa.l  A0,A5                     ;immer noch der gleiche Button?
                beq.s   form_d0                   ;dann ignorieren
                btst    #6,9(A0)                  ;Radio-Button?
                bne.s   formd8c                   ;Ja! => Sonderbehandlung
                bchg    #0,9(A0)                  ;Button selektieren/deselektieren
formd88:        movea.l A0,A5                     ;Buttonnummer merken
                movea.l A1,A0                     ;Zeiger auf den Objektbaum
                bsr     objc_draw                 ;Baum neu zeichnen
                bra.s   form_d0
formd8a:        bsr     desel_abuttons            ;Exit-Buttons deselektieren
                suba.l  A0,A0
                move.l  A5,D0                     ;kein aktueller Button da?
                beq.s   form_d0                   ;dann auch nicht neuzeichnen
                bra.s   formd88
formd8c:        moveq   #0,D0
                move.b  8(A0),D0                  ;Die Radio-Button Nummer
                movem.l A0,-(SP)
                movea.l A1,A0
form8d:         tst.w   (A0)                      ;Baum zuende?
                bmi.s   form8e                    ;Ja!
                lea     10(A0),A0                 ;Zeiger auf n„chstes Objekt
                btst    #6,-1(A0)                 ;Radio-Button?
                beq.s   form8d                    ;Nein? => Nicht deselektieren
                cmp.b   -2(A0),D0                 ;ist's der entspr.Radio-Button?
                bne.s   form8d                    ;Nein? => Nicht deselektieren
                bclr    #0,-1(A0)                 ;deselect Button
                bra.s   form8d                    ;Weiter suchen
form8e:         movem.l (SP)+,A0
                bset    #0,9(A0)                  ;Button selektieren
                bra.s   formd88

form_d1:        tas.b   mausprell(A4)             ;Wurde die Taste losgelassen?
                bne.s   form_d2                   ;N” => Ende
                bsr     find_button               ;Button unter der Maus?
                beq.s   formd1a                   ;Ja => evtl.Exit
                bsr     desel_abuttons            ;Exit-Buttons deselektieren
                movea.l A1,A0                     ;Zeiger auf den Objektbaum
                bsr     objc_draw                 ;Baum neu zeichnen
formd1b:        move.l  A5,D0
                beq     form_d7                   ;Es wurde kein Button selektiert
                bra     form_d0                   ;Weiter geht's
formd1a:        btst    #5,9(A5)                  ;Exit-Button?
                beq.s   formd1b                   ;Nein => Weiter geht's
                bra     form_exit                 ;Ende

form_d2:        suba.l  A5,A5                     ;aktuelle Buttonadr l”schen
                bsr     conin
                beq     form_d0                   ;Keine Taste gedrückt
                moveq   #27,D1
                btst    D1,D0                     ;ALT gedrückt?
                beq.s   form_d20                  ;Nein! =>
                cmp.w   #'A',D0
                blo.s   form_d20                  ;kleiner als 'A', dat geht nicht
                cmp.w   #'Z',D0
                bls.s   form_d24                  ;gr”žer als 'Z' geht auch nit
                cmp.w   #'a',D0
                blo.s   form_d20                  ;Kleinbuchstaben gehen auch
                cmp.w   #'z',D0
                bhi.s   form_d20
                sub.w   #32,D0
form_d24:       sub.w   #'A',D0
                moveq   #0,D2                     ;Button Nr l”schen
                movea.l A1,A0
find_d21:       tst.w   (A0)
                bmi.s   find_d22                  ;Nichts gefunden
                lea     10(A0),A0                 ;N„chster Eintrag (Flags unbeeinflužt)
                btst    #2,-1(A0)                 ;Button?
                beq.s   find_d21                  ;Kein Button
                addq.w  #1,D2                     ;Button-Nr erh”hen
                dbra    D0,find_d21
                btst    #4,-1(A0)                 ;disabled?
                bne.s   find_d22                  ;Ja, dann Ende
                btst    #5,-1(A0)                 ;Exit-Button?
                bne     form_d34                  ;dann raus
                lea     -10(A0),A0
                move    #$FF,CCR                  ;Button gefunden
                bra.s   form_d23
find_d22:       moveq   #0,D2                     ;Kein Button selektiert
                move    #0,CCR
form_d23:       bra     form_button

form_d20:       bsr     cursor_off
                cmp.w   #13,D0                    ;Return
                beq.s   form_return               ;Default-Button suchen
                swap    D0
                cmp.b   #$61,D0                   ;UNDO
                beq.s   form_abort
                bra     form_d7                   ;Kein Edit-Objekt da

;Abbruch
form_abort:     jsr     @cursor_off(A4)
                sf      no_dklick(A4)
                jsr     @redraw_all(A4)           ;Bildschirm neu aufbauen
                move.w  (SP)+,curflag(A4)
                btst    #6,curflag(A4)
                beq.s   form_ax12
                bsr     flash_cursor
form_ax12:      sf      no_dklick(A4)             ;Doppelklick wieder erlauben
                subq.b  #1,set_lock(A4)           ;Cursor darf wieder im VBL gesetzt werden
                move.l  (SP)+,zeile(A4)
                movem.l (SP)+,D1-A6
                tst.w   spalte(A4)
                beq.s   formab1                   ;CR, wenn Cursor nicht in Spalte 0
                jsr     @crout(A4)
formab1:        jmp     (A4)                      ;dann in die Hauptschleife zurück

;Ende
form_exit:      moveq   #0,D0
                bsr.s   redraw_all                ;Bildschirm neu aufbauen
                move.w  D2,D0
                move.w  (SP)+,curflag(A4)
                btst    #6,curflag(A4)
                beq.s   formx12
                bsr     flash_cursor
formx12:        sf      no_dklick(A4)             ;Doppelklick wieder erlauben
                subq.b  #1,set_lock(A4)           ;Cursor darf wieder im VBL gesetzt werden
                move.l  (SP)+,zeile(A4)
                movem.l (SP)+,D1-A6
                tst.w   D0                        ;Flags setzen
                rts

; Return = Defaultbutton selektieren + Ende
form_return:    moveq   #0,D2                     ;Button Nr l”schen
                movea.l A1,A0
form_d3:        tst.w   (A0)
                bmi.s   form_d33                  ;Kein Default-Button
                lea     10(A0),A0                 ;Zeiger auf n„chstes Element
                btst    #2,-1(A0)
                beq.s   form_d3                   ;Kein Button
                addq.w  #1,D2                     ;Button-Nr erh”hen
                btst    #1,-1(A0)                 ;Default-Button?
                beq.s   form_d3
                btst    #4,-1(A0)                 ;Disabled?
                bne.s   form_d3                   ;das war wohl nichts
form_d34:       bsr     desel_abuttons            ;deselect all buttons
                bset    #0,-1(A0)
                movea.l A1,A0
                bsr.s   objc_draw                 ;Baum nochmal zeichnen
                bra.s   form_exit                 ;Over and out
form_d33:       tst.w   D2
                bne     form_d7                   ;Kein Default-Button
                bra.s   form_exit                 ;gar kein Button!
               ;>ENDPART
********************************************************************************
* Bildschirm neu aufbauen                                                      *
********************************************************************************
               ;>PART 'redraw_all'
redraw_all:     movem.l D0-A6,-(SP)
                lea     debugger_scr(A4),A0
                tst.b   scr_moni(A0)
                beq.s   redraw_all2               ;S/W hat Pause
                bsr     clr_maus
                movea.l scr_adr(A0),A0            ;Bei Farbe: 2.Plane l”schen
                moveq   #-1,D0
                clr.w   D0                        ;D0=$FFFF0000 (2 Byte kürzer)
                move.w  #1999,D1
redraw_all1:    and.l   D0,(A0)+
                and.l   D0,(A0)+
                and.l   D0,(A0)+
                and.l   D0,(A0)+
                dbra    D1,redraw_all1
                bsr     set_maus
redraw_all2:    move.l  zeile(A4),-(SP)           ;Zeile und(!) Spalte retten
                move.w  upper_line(A4),D0
                neg.w   D0
                move.w  D0,zeile(A4)
                clr.w   spalte(A4)
                bsr     draw_menue
                move.w  #-1,entry(A4)             ;Alten Eintrag l”schen
                sf      testwrd(A4)
                sf      device(A4)
                jsr     rgout
                moveq   #0,D0
redraw_all3:    bsr     update_line               ;Alle Zeilen neu ausgeben
                addq.w  #1,D0
                cmp.w   down_lines(A4),D0
                bne.s   redraw_all3
                move.l  (SP)+,zeile(A4)           ;Zeile und(!) Spalte zurück
                movem.l (SP)+,D0-A6

                rts
               ;>ENDPART
********************************************************************************
* Object draw (ab A0)                                                          *
********************************************************************************
               ;>PART 'objc_draw'
objc_draw:      movem.l D0-A3/A5,-(SP)
                move.l  zeile(A4),-(SP)
                jsr     @cursor_off(A4)
                clr.w   button_nr(A4)
                lea     debugger_scr(A4),A2
                tst.b   scr_moni(A2)
                lea     objc_draw_tab2(PC),A2     ;Sprungtabelle für Farbe
                bne.s   objc_draw1                ;Farbmonitor =>
                lea     objc_draw_tab(PC),A2      ;Sprungtabelle für S/W
objc_draw1:     movem.w 4(A0),D6-D7
                subi.w  #80,D6
                neg.w   D6
                lsr.w   #1,D6                     ;Objekt zentieren
                subi.w  #25,D7
                neg.w   D7
                lsr.w   #1,D7
objc_draw2:     moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                movem.w (A0)+,D0-D4
                tst.w   D0
                bmi.s   objc_draw4
                move.w  D4,D5
                andi.w  #$1F,D5
                add.w   D5,D5
                movea.w 0(A2,D5.w),A3
                cmp.w   #6,D5
                bls.s   objc_draw3
                movea.w (A2),A3
objc_draw3:     adda.l  A2,A3
                add.w   D6,D0
                add.w   D7,D1
                bsr     clr_maus
                jsr     (A3)
                bra.s   objc_draw2
objc_draw4:     bsr     set_maus
                move.l  (SP)+,zeile(A4)
                movem.l (SP)+,D0-A3/A5
                rts

;>               BASE DC.W,objc_draw_tab
objc_draw_tab: DC.W objc_draw_text-objc_draw_tab                ;0 Default
               DC.W objc_draw_bordr-objc_draw_tab               ;1
               DC.W objc_draw_frame-objc_draw_tab               ;2
               DC.W objc_draw_icon-objc_draw_tab                ;3

;>               BASE DC.W,objc_draw_tab2
objc_draw_tab2:DC.W objc_drawfftext-objc_draw_tab2               ;0 Default
               DC.W objc_drawfbordr-objc_draw_tab2               ;1
               DC.W objc_drawfframe-objc_draw_tab2               ;2
               DC.W objc_drawficon-objc_draw_tab2                ;3

objc_draw_icon: lsr.w   #8,D4                     ;Ausgaberoutinen für S/W
                lsl.w   #4,D1                     ;mal 16
                swap    D2
                clr.w   D2
                or.w    D3,D2
                movea.l D2,A3                     ;Adresse des Icons
                lea     debugger_scr(A4),A5
                movea.l scr_adr(A5),A5
                move.w  D1,D2
                lsl.w   #2,D2                     ;mal 80
                add.w   D2,D1
                lsl.w   #4,D1
                add.w   D1,D0
                adda.w  D0,A5                     ;Adresse auf dem Screen
                move.w  D4,D2
                andi.w  #$F0,D2
                lsr.w   #1,D2
                addq.w  #7,D2                     ;Iconh”he
                andi.w  #$0F,D4
objc_draw_icon1:move.w  D4,D1
                movea.l A5,A1
objc_draw_icon2:move.b  (A3)+,(A1)+
                dbra    D1,objc_draw_icon2
                lea     80(A5),A5
                dbra    D2,objc_draw_icon1
                rts

objc_draw_bordr:movem.w D0-D3,-(SP)
                lsl.w   #3,D0
                lsl.w   #4,D1
                lsl.w   #3,D2
                lsl.w   #4,D3
                subq.w  #4,D0
                subq.w  #4,D1
                addq.w  #8,D2
                addq.w  #8,D3
                bsr     clr_box
                movem.w (SP)+,D0-D3
objc_draw_frame:lsl.w   #3,D0
                lsl.w   #4,D1
                lsl.w   #3,D2
                lsl.w   #4,D3
                subq.w  #1,D0
                subq.w  #1,D1
                addq.w  #1,D2
                addq.w  #1,D3
                bsr     draw_box
                subq.w  #1,D0
                subq.w  #1,D1
                addq.w  #2,D2
                addq.w  #2,D3
                bsr     draw_box
                subq.w  #3,D0
                subq.w  #3,D1
                addq.w  #6,D2
                addq.w  #6,D3
                bra     draw_box

objc_draw_text: swap    D2
                clr.w   D2
                or.w    D3,D2
                move.w  D0,spalte(A4)
                move.w  D1,zeile(A4)
                movea.l D2,A3
                movem.l D0-D3,-(SP)
                btst    #2,D4
                beq.s   objc_draw_text1
                cmpi.b  #' ',(A3)
                bne.s   objc_draw_text1
                addq.l  #1,A3
                moveq   #'A',D0
                add.w   button_nr(A4),D0
                or.w    #$FF00,D0                 ;Kleinschrift setzen
                bra.s   objc_draw_text0
objc_draw_text1:moveq   #0,D0
                move.b  (A3)+,D0
                beq.s   objc_draw_text5
objc_draw_text0:moveq   #-1,D1                    ;Light-Maske l”schen
                moveq   #0,D2                     ;Invers-Maske l”schen
                moveq   #0,D3                     ;Underline-Maske l”schen
                btst    #0,D4                     ;selected (invers) ?
                beq.s   objc_draw_text2
                moveq   #-1,D2                    ;Invers darstellen
objc_draw_text2:btst    #4,D4                     ;disabled (light) ?
                beq.s   objc_draw_text3
                moveq   #$55,D1                   ;Light darstellen
objc_draw_text3:btst    #2,D4                     ;kein Button?
                bne.s   objc_draw_text9
                btst    #6,D4                     ;Fett?
                beq.s   objc_draw_text9
                or.w    #$0100,D0                 ;Fett setzen
objc_draw_text9:tst.b   D4                        ;Editierbar?
                bpl.s   objc_draw_text4
                moveq   #-1,D3                    ;Underline an
objc_draw_text4:bsr     light_char                ;Zeichen ausgeben
                addq.w  #1,spalte(A4)             ;n„chste Spalte
                bra.s   objc_draw_text1

objc_draw_text5:movem.l (SP)+,D0-D3
                btst    #2,D4                     ;Text oder Button
                beq.s   objc_draw_text8           ;Text ohne Rahmen
                addq.w  #1,button_nr(A4)
                movea.l D2,A3
                moveq   #-8,D2
objc_draw_text6:addq.l  #8,D2
                tst.b   (A3)+
                bne.s   objc_draw_text6
                lsl.w   #4,D1
                lsl.w   #3,D0
                subq.w  #1,D0
                subq.w  #1,D1
                addq.w  #1,D2
                moveq   #17,D3
                bsr     draw_box
objc_draw_text7:subq.w  #1,D0
                subq.w  #1,D1
                addq.w  #2,D2
                addq.w  #2,D3
                bsr     draw_box
                bclr    #1,D4
                bne.s   objc_draw_text7
objc_draw_text8:rts

objc_drawficon: lsl.w   #4,D1                     ;Ausgaberoutinen für Farbe
                swap    D2
                clr.w   D2
                or.w    D3,D2
                movea.l D2,A3                     ;Adresse des Icons

                move.w  D1,D2
                lsl.w   #2,D2                     ;mal 80
                add.w   D2,D1
                lsl.w   #4,D1
                lea     debugger_scr(A4),A1
                movea.l scr_adr(A1),A1
                adda.w  D1,A1                     ;+ Bildschirmadresse
                move.w  D4,D1
                lsr.w   #8,D4
                move.w  D4,D5
                andi.w  #$F0,D5
                lsr.w   #2,D5
                addq.w  #3,D5                     ;Iconh”he
                andi.w  #$0F,D4
                tst.b   D1
                bpl.s   objc_drawficon4           ;jede 2.Zeile weglassen
objc_drawficon1:move.w  D4,D3                     ;x Byte ausgeben
objc_drawficon2:move.w  D0,D2
                move.w  D0,D1
                andi.w  #-2,D1
                add.w   D1,D1                     ;+ (Spalte and -2) * 2
                andi.w  #1,D2
                add.w   D2,D1                     ;+ (Spalte and 1)
                move.b  (A3)+,0(A1,D1.w)
                addq.w  #1,D0                     ;n„chste Spalte
                dbra    D3,objc_drawficon2
                sub.w   D4,D0                     ;Spaltenz„hler zurück
                subq.w  #1,D0
                move.w  D4,D3
objc_drawficon3:move.w  D0,D2
                move.w  D0,D1
                andi.w  #-2,D1
                add.w   D1,D1                     ;+ (Spalte and -2) * 2
                andi.w  #1,D2
                add.w   D2,D1                     ;+ (Spalte and 1)
                move.b  (A3)+,D2
                or.b    D2,0(A1,D1.w)
                addq.w  #1,D0                     ;n„chste Spalte
                dbra    D3,objc_drawficon3
                sub.w   D4,D0                     ;Spaltenz„hler zurück
                subq.w  #1,D0
                lea     160(A1),A1
                dbra    D5,objc_drawficon1
                rts
objc_drawficon4:move.w  D4,D3                     ;x Byte ausgeben
objc_drawficon5:move.w  D0,D2
                move.w  D0,D1
                andi.w  #-2,D1
                add.w   D1,D1                     ;+ (Spalte and -2) * 2
                andi.w  #1,D2
                add.w   D2,D1                     ;+ (Spalte and 1)
                move.b  (A3)+,0(A1,D1.w)
                addq.w  #1,D0                     ;n„chste Spalte
                dbra    D3,objc_drawficon5
                sub.w   D4,D0                     ;Spaltenz„hler zurück
                subq.w  #1,D0
                adda.w  D4,A3                     ;Zeile berlesen
                addq.l  #1,A3
                lea     160(A1),A1
                dbra    D5,objc_drawficon4
                rts

objc_drawfbordr:movem.w D0-D3,-(SP)
                lsl.w   #3,D0
                lsl.w   #4,D1
                lsl.w   #3,D2
                lsl.w   #4,D3
                subq.w  #4,D0
                subq.w  #8,D1
                addq.w  #8,D2
                addi.w  #14,D3
                bsr     clr_fbox
                movem.w (SP)+,D0-D3
objc_drawfframe:lsl.w   #3,D0
                lsl.w   #4,D1
                lsl.w   #3,D2
                lsl.w   #4,D3
                subq.w  #1,D0
                subq.w  #2,D1
                addq.w  #1,D2
                addq.w  #2,D3
                bsr     drawfbox
                subq.w  #1,D0
                subq.w  #2,D1
                addq.w  #2,D2
                addq.w  #4,D3
                bsr     drawfbox
                subq.w  #3,D0
                subq.w  #6,D1
                addq.w  #6,D2
                addi.w  #12,D3
                bra     drawfbox

objc_drawfftext:swap    D2
                clr.w   D2
                or.w    D3,D2
                move.w  D0,spalte(A4)
                move.w  D1,zeile(A4)
                movea.l D2,A3
                movem.l D0-D2,-(SP)
                btst    #2,D4
                beq.s   objc_drawfftxt1
                cmpi.b  #' ',(A3)
                bne.s   objc_drawfftxt1
                addq.l  #1,A3
                moveq   #'A',D0
                add.w   button_nr(A4),D0
                or.w    #$FF00,D0
                bra.s   objc_drawfftxt0
objc_drawfftxt1:moveq   #0,D0
                move.b  (A3)+,D0
                beq.s   objc_drawfftxt5
objc_drawfftxt0:moveq   #-1,D1                    ;Light-Maske l”schen
                moveq   #0,D2                     ;Invers-Maske l”schen
                moveq   #0,D3                     ;Underline-Maske l”schen
                btst    #0,D4                     ;selected (invers) ?
                beq.s   objc_drawfftxt2
                moveq   #-1,D2                    ;Invers darstellen
objc_drawfftxt2:btst    #4,D4                     ;disabled (light) ?
                beq.s   objc_drawfftxt3
                moveq   #$55,D1                   ;Light darstellen
objc_drawfftxt3:btst    #2,D4                     ;kein Button?
                bne.s   objc_drawfftxt9
                btst    #6,D4                     ;Fett?
                beq.s   objc_drawfftxt9
                or.w    #$0100,D0                 ;Fett markieren
objc_drawfftxt9:tst.b   D4                        ;Editierbar?
                bpl.s   objc_drawfftxt4
                moveq   #-1,D3                    ;Underline an
objc_drawfftxt4:bsr     light_char
                addq.w  #1,spalte(A4)
                bra.s   objc_drawfftxt1
objc_drawfftxt5:movem.l (SP)+,D0-D2

                btst    #2,D4                     ;Text oder Button
                beq.s   objc_drawfftxt8           ;Text ohne Rahmen
                addq.w  #1,button_nr(A4)
                movea.l D2,A3
                moveq   #-8,D2
objc_drawfftxt6:addq.l  #8,D2
                tst.b   (A3)+
                bne.s   objc_drawfftxt6
                lsl.w   #4,D1
                lsl.w   #3,D0
                subq.w  #1,D0
                subq.w  #2,D1
                addq.w  #1,D2
                moveq   #20,D3
                bsr     drawfbox
objc_drawfftxt7:subq.w  #1,D0
                subq.w  #2,D1
                addq.w  #2,D2
                addq.w  #4,D3
                bsr     drawfbox
                bclr    #1,D4
                bne.s   objc_drawfftxt7
objc_drawfftxt8:rts
               ;>ENDPART
********************************************************************************
* Deselect all buttons (D0 = Selected Button)                                  *
********************************************************************************
               ;>PART 'desel_abuttons'
desel_abuttons: movem.l D3/A0,-(SP)
                movea.l A1,A0
                moveq   #0,D3
                moveq   #0,D0
desel_abuttons1:tst.w   (A0)                      ;Baum zuende?
                bmi.s   desel_abuttons2           ;Ja!
                lea     10(A0),A0                 ;Zeiger auf n„chstes Objekt
                btst    #2,-1(A0)                 ;Button?
                beq.s   desel_abuttons1
                addq.w  #1,D3                     ;Button Nr+1
                btst    #5,-1(A0)                 ;Exit-Button?
                beq.s   desel_abuttons1           ;Nein => Button nicht deselecten
                btst    #6,-1(A0)                 ;Radio-Button?
                bne.s   desel_abuttons1           ;Nicht deselektieren
                btst    #0,-1(A0)                 ;Button selektiert?
                beq.s   desel_abuttons1           ;Nein!
                move.w  D3,D0                     ;Button Nr merken
                bclr    #0,-1(A0)                 ;deselect Button
                bra.s   desel_abuttons1           ;Weiter suchen
desel_abuttons2:movem.l (SP)+,D3/A0
                rts
               ;>ENDPART
********************************************************************************
* Button unter der Maus finden (A0 zeigt auf den Button D2, Flags!)            *
********************************************************************************
               ;>PART 'find_button'
find_button:    move.w  mausx(A4),D0
                move.w  mausy(A4),D1
                lsr.w   #3,D0
                lsr.w   #4,D1                     ;In Zeichenkoordinaten umrechnen
                movem.w 4(A1),D6-D7               ;Breite & H”he holen
                subi.w  #80,D6
                neg.w   D6
                lsr.w   #1,D6                     ;Objekt zentieren
                subi.w  #25,D7
                neg.w   D7
                lsr.w   #1,D7
                sub.w   D6,D0
                bmi.s   find_button3
                sub.w   D7,D1                     ;Mauskoordinaten in Offsets umrechnen
                bmi.s   find_button3
                moveq   #0,D2                     ;Button Nr l”schen
                movea.l A1,A0
find_button1:   tst.w   (A0)
                bmi.s   find_button3              ;Nichts gefunden
                lea     10(A0),A0                 ;N„chster Eintrag (Flags unbeeinflužt)
                btst    #2,-1(A0)                 ;Button?
                beq.s   find_button1              ;Kein Button
                addq.w  #1,D2                     ;Button-Nr erh”hen
                btst    #4,-1(A0)                 ;disabled?
                bne.s   find_button1              ;Ja, ignorieren
                move.w  -10(A0),D3                ;X-Koordinate holen
                cmp.w   D3,D0
                blo.s   find_button1              ;X zu klein
                movea.l -6(A0),A2                 ;Textadresse
                moveq   #-1,D4
find_button2:   addq.l  #1,D4                     ;Textl„nge ermitteln
                tst.b   (A2)+
                bne.s   find_button2
                add.w   D4,D3                     ;Breite dazu
                cmp.w   D3,D0
                bhs.s   find_button1              ;X zu grož
                move.w  -8(A0),D3                 ;Y-Koordinate holen
                cmp.w   D3,D1
                blo.s   find_button1              ;Y zu klein
                addq.w  #1,D3                     ;H”he dazu (da Text, stets eine Zeile)
                cmp.w   D3,D1
                bhs.s   find_button1              ;Y zu grož
                lea     -10(A0),A0
                move    #$FF,CCR                  ;Button gefunden
                rts
find_button3:   moveq   #0,D2                     ;Kein Button selektiert
                move    #0,CCR
                rts
               ;>ENDPART
********************************************************************************
* Zeichen D0 an Cursorposition ausgeben (D1=Lightmaske, D2=XOR-wert)           *
********************************************************************************
               ;>PART 'light_char'
light_char:     movem.l D0-A1,-(SP)
                move.w  D1,D6
                move.w  D2,D7
                move.w  D3,D5
                move.w  zeile(A4),D2
                move.w  D2,D1
                lsl.w   #2,D1                     ;mal 80
                add.w   D1,D2
                lsl.w   #4,D2
                move.w  spalte(A4),D3
                move.w  D0,D4
                lsr.w   #8,D4                     ;Negativ.B? => Fett/Klein
                and.w   #$FF,D0
                lea     debugger_scr(A4),A1
                tst.b   scr_moni(A1)
                bne     light2                    ;Farbmonitor
                movea.l s_w_font(A4),A0           ;Fontadresse
                adda.w  D0,A0                     ;plus ASCII-Code (= Zeichenadr)
                lsl.w   #4,D2                     ;Cursorzeile * 1280
                add.w   D3,D2                     ;+ Cursorspalte
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                moveq   #15,D1                    ;Zeilenanzahl
                move.w  #$0100,D2                 ;Offset für den Zeichensatz
                moveq   #80,D3                    ;Offset für den Bildschirm
                tst.b   D4                        ;bes.Attribut
                bmi.s   light10                   ;Klein? dann dorthin
                bne.s   light6                    ;Fett? dann dorthin
light1:         move.b  (A0),D0                   ;Aus dem Font holen
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                tst.w   D1
                bne.s   light4
                or.b    D5,D0                     ;Unterline
light4:         move.b  D0,(A1)                   ;auf den Screen
                adda.w  D2,A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light1
                movem.l (SP)+,D0-A1
                rts
light6:         move.b  (A0),D0                   ;Aus dem Font holen
                move.b  D0,D4
                lsr.b   #1,D4                     ;Zeichen ein Bit nach links
                or.b    D4,D0                     ;und wieder einsetzen => Fett
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                tst.w   D1
                bne.s   light7
                or.b    D5,D0                     ;Unterline
light7:         move.b  D0,(A1)                   ;auf den Screen
                adda.w  D2,A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light6
                movem.l (SP)+,D0-A1
                rts
light10:        movea.l farbfont(A4),A0           ;Fontadresse
                adda.w  D0,A0                     ;plus ASCII-Code (= Zeichenadr)
                moveq   #7,D1                     ;Zeilenanzahl
light11:        move.b  (A0),D0                   ;Aus dem Font holen
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                move.b  D0,(A1)                   ;auf den Screen
                lea     256(A0),A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light11
                moveq   #7,D1                     ;Die restlichen 8 Zeilen
light13:        move.b  D7,D0                     ;invers?
                tst.w   D1
                bne.s   light14
                or.b    D5,D0                     ;Unterline
light14:        move.b  D0,(A1)                   ;auf den Screen
                adda.w  D3,A1
                dbra    D1,light13
                movem.l (SP)+,D0-A1
                rts

light2:         movea.l farbfont(A4),A0
                adda.w  D0,A0                     ;Adresse des Zeichens holen
                lsl.w   #4,D2                     ;Cursorzeile * 1280
                move.w  D3,D1
                andi.w  #-2,D3
                add.w   D3,D3
                add.w   D3,D2                     ;+ (Spalte and -2) * 2
                andi.w  #1,D1
                add.w   D1,D2                     ;+ (Spalte and 1)
                movea.l scr_adr(A1),A1
                adda.w  D2,A1                     ;+ Bildschirmadresse
                moveq   #7,D1                     ;Zeilenanzahl
                move.w  #$0100,D2                 ;Offset für den Zeichensatz
                move.w  #160,D3                   ;Offset für den Bildschirm
                tst.b   D4
                bmi.s   light20                   ;Klein ignorieren
                bne.s   light8                    ;Fett ausgeben
light3:         move.b  (A0),D0                   ;Aus dem Font holen
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                tst.w   D1
                bne.s   light5
                or.b    D5,D0                     ;Unterline
light5:         move.b  D0,(A1)                   ;auf den Screen
                adda.w  D2,A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light3
                movem.l (SP)+,D0-A1
                rts
light8:         move.b  (A0),D0                   ;Aus dem Font holen
                move.b  D0,D4
                lsr.b   #1,D4                     ;Zeichen ein Bit nach links
                or.b    D4,D0                     ;und wieder einsetzen => Fett
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                tst.w   D1
                bne.s   light9
                or.b    D5,D0                     ;Unterline
light9:         move.b  D0,(A1)                   ;auf den Screen
                adda.w  D2,A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light8
                movem.l (SP)+,D0-A1
                rts
light20:        movea.l farbfont(A4),A0           ;Fontadresse
                adda.w  D0,A0                     ;plus ASCII-Code (= Zeichenadr)
                moveq   #3,D1                     ;Zeilenanzahl (nur 4 Pixel hoch!!!)
light21:        move.b  (A0),D0                   ;Aus dem Font holen
                and.b   D6,D0                     ;light
                eor.b   D7,D0                     ;invers
                move.b  D0,(A1)                   ;auf den Screen
                lea     512(A0),A0
                adda.w  D3,A1
                rol.b   #1,D6                     ;Maske rotieren
                dbra    D1,light21
                moveq   #3,D1                     ;Die restlichen 4 Zeilen
light23:        move.b  D7,D0                     ;invers?
                tst.w   D1
                bne.s   light24
                or.b    D5,D0                     ;Unterline
light24:        move.b  D0,(A1)                   ;auf den Screen
                adda.w  D3,A1
                dbra    D1,light23
                movem.l (SP)+,D0-A1
                rts
               ;>ENDPART
********************************************************************************
* Rahmen (S/W) zeichnen (D0-X, D1-Y, D2-Breite, D3-H”he)                       *
********************************************************************************
               ;>PART 'draw_box'
draw_box:       movem.l D0-A2,-(SP)
                move.l  D3,D6
                subq.l  #1,D6                     ;H”he-1 merken
                move.l  D0,D7
                add.w   D0,D2
                add.w   D1,D3                     ;Rechte untere Ecke errechnen
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0            ;Bildschirmadresse
                movea.l A0,A1
                mulu    #80,D1
                mulu    #80,D3
                adda.w  D1,A0                     ;Zeilenadresse der oberen Zeile
                adda.w  D3,A1                     ;Zeilenadresse der unteren Zeile

                move.w  D0,D4
                lsr.w   #3,D0
                adda.w  D0,A0
                adda.w  D0,A1
                addq.w  #8,D7                     ;Linken Rand neu setzen
                and.w   #$03F8,D7
                and.w   #7,D4
                move.b  draw_box_mask1(PC,D4.w),D5
                bne.s   draw_box1
                moveq   #-1,D5
draw_box1:      or.b    D5,(A0)
                or.b    D5,(A1)
                move.b  draw_box_mask2+1(PC,D4.w),D5
                move.w  D6,D0
                movea.l A0,A2
draw_box2:      or.b    D5,(A2)                   ;Linken Rand zeichnen
                lea     80(A2),A2
                dbra    D0,draw_box2
                addq.l  #1,A0
                addq.l  #1,A1
                move.w  D2,D4
                sub.w   D7,D2
                bmi.s   draw_box4
                lsr.w   #3,D2
                subq.w  #1,D2
                bmi.s   draw_box4
                moveq   #-1,D5
draw_box3:      move.b  D5,(A0)+                  ;Obere und untere Linie zeichnen
                move.b  D5,(A1)+

                dbra    D2,draw_box3
draw_box4:      andi.w  #7,D4
                move.b  draw_box_mask1+1(PC,D4.w),D5
                not.b   D5
                or.b    D5,(A0)
                or.b    D5,(A1)
                move.b  draw_box_mask2+1(PC,D4.w),D5
draw_box5:      lea     80(A0),A0
                or.b    D5,(A0)                   ;Rechte Linie zeichnen
                dbra    D6,draw_box5
                movem.l (SP)+,D0-A2
                rts

draw_box_mask1:DC.B %11111111,%1111111,%111111,%11111,%1111,%111
               DC.B %11,%1,%0
draw_box_mask2:DC.B %1,%10000000,%1000000,%100000,%10000,%1000
               DC.B %100,%10,%1,%10000000
               EVEN
               ;>ENDPART
********************************************************************************
* Box (S/W) l”schen (D0-X, D1-Y, D2-Breite, D3-H”he)                           *
********************************************************************************
               ;>PART 'clr_box'
clr_box:        movem.l D0-D4/D7-A1,-(SP)
                subq.w  #1,D2
                add.w   D0,D2
                subq.w  #1,D3
                mulu    #80,D1
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                adda.w  D1,A0
                move.w  D0,D1
                lsr.w   #3,D1
                adda.w  D1,A0
                move.w  D0,D1
                andi.w  #7,D1
                move.b  clr_box_tab(PC,D1.w),D1
                move.w  D3,D7
                movea.l A0,A1
clr_box1:       and.b   D1,(A0)
                lea     80(A0),A0
                dbra    D7,clr_box1
                addq.w  #8,D0
                lsr.w   #3,D0
                move.w  D2,D4
                lsr.w   #3,D4
                sub.w   D0,D4
                subq.w  #1,D4
                bmi.s   clr_box4
clr_box2:       move.w  D3,D7
                addq.l  #1,A1
                movea.l A1,A0
clr_box3:       clr.b   (A0)
                lea     80(A0),A0
                dbra    D7,clr_box3
                dbra    D4,clr_box2
clr_box4:       addq.w  #1,A1
                andi.w  #7,D2
                move.b  clr_box_tab+1(PC,D2.w),D1
                not.w   D1
clr_box5:       and.b   D1,(A1)
                lea     80(A1),A1
                dbra    D3,clr_box5
                movem.l (SP)+,D0-D4/D7-A1
                rts

clr_box_tab:   DC.B %0,%10000000,%11000000,%11100000,%11110000,%11111000
               DC.B %11111100,%11111110,%11111111
               EVEN
               ;>ENDPART
********************************************************************************
* Rahmen (Farbe) zeichnen (D0-X, D1-Y, D2-Breite, D3-H”he)                     *
********************************************************************************
               ;>PART 'drawfbox'
drawfbox:       movem.l D0-A1/A5-A6,-(SP)
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                lsr.w   #1,D1
                mulu    #160,D1                   ;(Y/2) * 160 (Zeilenbreite) =>
                adda.w  D1,A0                     ;Offset für die Zeile
                lsr.w   #1,D3                     ;H”he/2,da intern 400 Y-Aufl”sung
                subq.w  #3,D3                     ;H”he -1 für den DBRA & -2 für 1.&letzte Zeile
                moveq   #$0F,D1
                and.w   D0,D1
                move.w  D1,D4
                neg.w   D4
                add.w   #16,D4
                sub.w   D4,D2                     ;Soviel Pixel sind von der Breite schon weg
                move.w  D2,D4
                and.w   #$03F0,D2
                lsr.w   #4,D2                     ;durch 16 => Wordanzahl
                subq.w  #1,D2                     ;für DBRA
                and.w   #$0F,D4
                lsl.w   #2,D4                     ;Zeiger auf die Endmaske (auch Long-Tabelle)
                lsl.w   #2,D1                     ;* 4, da Long-Tabelle
                and.w   #$03F0,D0
                lsr.w   #2,D0                     ;durch 16 mal 4 => durch 4
                adda.w  D0,A0                     ;Spaltenoffset
                lea     clr_fbox4(PC),A6
                lea     clr_fbox5(PC),A5
                moveq   #-1,D7
                lea     160(A0),A1                ;Zeiger schon mal auf die n„chste Zeile
                move.l  0(A5,D1.w),D0
                or.l    D0,(A0)+
                move.w  D2,D0
                bmi.s   draw_fbox2
draw_fbox1:     move.l  D7,(A0)+                  ;Linie ziehen
                dbra    D0,draw_fbox1
draw_fbox2:     move.l  0(A6,D4.w),D0
                or.l    D0,(A0)                   ;Abschlužmaske
                movea.l A1,A0
draw_fbox3:     lea     160(A0),A1                ;Zeiger schon mal auf die n„chste Zeile
                move.l  draw_fbox_tab2(PC,D1.w),D0
                or.l    D0,(A0)+
                move.w  D2,D0
                bmi.s   draw_fbox5
draw_fbox4:     addq.l  #4,A0
                dbra    D0,draw_fbox4
draw_fbox5:     move.l  draw_fbox_tab1(PC,D4.w),D0
                bne.s   draw_fbox6
                move.l  draw_fbox_tab1-4(PC),D0
                subq.l  #4,A0
draw_fbox6:     or.l    D0,(A0)                   ;Abschlužmaske
                movea.l A1,A0
                dbra    D3,draw_fbox3             ;Ganze H”he durchlaufen
                lea     160(A0),A1                ;Zeiger schon mal auf die n„chste Zeile
                move.l  0(A5,D1.w),D0
                or.l    D0,(A0)+
                move.w  D2,D0
                bmi.s   draw_fbox8
draw_fbox7:     move.l  D7,(A0)+                  ;Linie ziehen
                dbra    D0,draw_fbox7
draw_fbox8:     move.l  0(A6,D4.w),D0
                or.l    D0,(A0)                   ;Abschlužmaske
                movem.l (SP)+,D0-A1/A5-A6
                rts

               DC.L $010001
draw_fbox_tab1:DC.L 0
draw_fbox_tab2:DC.L $80008000,$40004000,$20002000,$10001000,$08000800,$04000400
               DC.L $02000200,$01000100,$800080,$400040,$200020,$100010
               DC.L $080008,$040004,$020002,$010001
               ;>ENDPART
********************************************************************************
* Box (Farbe) l”schen (D0-X, D1-Y, D2-Breite, D3-H”he)                         *
********************************************************************************
               ;>PART 'clr_fbox'
clr_fbox:       movem.l D0-A1,-(SP)
                lea     debugger_scr(A4),A0
                movea.l scr_adr(A0),A0
                and.l   #$0FFF,D0
                and.l   #$0FFF,D1
                and.l   #$0FFF,D2
                and.l   #$0FFF,D3
                mulu    #80,D1                    ;(Y/2) * 160 (Zeilenbreite) =>
                adda.w  D1,A0                     ;Offset für die Zeile
                lsr.w   #1,D3                     ;H”he/2,da intern 400 Y-Aufl”sung
                subq.w  #1,D3                     ;H”he -1 für den DBRA
                moveq   #$0F,D1
                and.w   D0,D1
                move.w  D1,D4
                neg.w   D4
                add.w   #16,D4
                sub.w   D4,D2                     ;Soviel Pixel sind von der Breite schon weg
                move.w  D2,D4
                andi.w  #$03F0,D2
                lsr.w   #4,D2                     ;durch 16 => Wordanzahl
                subq.w  #1,D2                     ;für DBRA
                and.w   #$0F,D4
                lsl.w   #2,D4                     ;Zeiger auf die Endmaske (auch Long-Tabelle)
                lsl.w   #2,D1                     ;* 4, da Long-Tabelle
                andi.w  #$03F0,D0
                lsr.w   #2,D0                     ;durch 16 mal 4 => durch 4
                adda.w  D0,A0                     ;Spaltenoffset
clr_fbox1:      lea     160(A0),A1                ;Zeiger schon mal auf die n„chste Zeile
                move.l  clr_fbox4(PC,D1.w),D0
                and.l   D0,(A0)+
                move.w  D2,D0
                bmi.s   clr_fbox3
clr_fbox2:      clr.l   (A0)+                     ;Zeile l”schen
                dbra    D0,clr_fbox2
clr_fbox3:      move.l  clr_fbox5(PC,D4.w),D0
                and.l   D0,(A0)                   ;Abschlužmaske
                movea.l A1,A0
                dbra    D3,clr_fbox1              ;Ganze H”he durchlaufen
                movem.l (SP)+,D0-A1
                rts

clr_fbox4:     DC.L 0,$80008000,$C000C000,$E000E000,$F000F000,$F800F800
               DC.L $FC00FC00,$FE00FE00,$FF00FF00,$FF80FF80,$FFC0FFC0,$FFE0FFE0
               DC.L $FFF0FFF0,$FFF8FFF8,$FFFCFFFC,$FFFEFFFE
clr_fbox5:     DC.L $FFFFFFFF,$7FFF7FFF,$3FFF3FFF,$1FFF1FFF,$0FFF0FFF,$07FF07FF
               DC.L $03FF03FF,$01FF01FF,$FF00FF,$7F007F,$3F003F,$1F001F
               DC.L $0F000F,$070007,$030003,$010001
               ;>ENDPART

resvalid       EQU $0426
resvector      EQU $042A
_p_cookies_    EQU $05A0
               IF 0
               ;>PART 'hunt_cookie'                 ;Cookie D0.l suchen (N=1, nicht gefunden)
;Cookie mit dem Namen D0.l suchen.
;Parameter:  D0.l : Name des Cookies
;            D0.l : Wert des gefundenen Cookies
;             N=1  : Cookie nicht gefunden (D0.l = L„nge des bisherigen Jars)

hunt_cookie:    movem.l D1-D2/A0,-(SP)
                move.l  D0,D2                     ;gesuchten Namen merken
                move.l  _p_cookies_.w,D0          ;Zeiger auf das Cookie Jar holen
                beq.s   hunt_cookie_ex            ;ist leer => nix gefunden
                movea.l D0,A0
hunt_cookie_l:  move.l  (A0)+,D1                  ;Namen eines Cookies holen
                move.l  (A0)+,D0                  ;und den Wert holen
                cmp.l   D2,D1                     ;Eintrag gefunden?
                beq.s   hunt_cookie_f             ;Ja! =>
                tst.l   D1                        ;Ende der Liste?
                bne.s   hunt_cookie_l             ;Nein! => weiter vergleichen
hunt_cookie_ex: moveq   #-1,D0                    ;N-Flag=1, d.h. nix gefunden
hunt_cookie_f:  movem.l (SP)+,D1-D2/A0
                rts
               ;>ENDPART
               ;>PART 'insert_cookie'               ;Cookie D0.l ins Cookie Jar
;eigenen Cookie in das Cookie jar
;Parameter:  D0.l : Name des Cookies
;            D1.l : Wert des Cookies
;            D2.l : L„nge eines eventuell einzurichtenden Cookie Jars (Langworte)
;            A0.l : Adresse eines eventuell einzurichtenden Cookie Jars
;            D0.w : 0 - alles ok, Cookie wurde eingetragen
;                    1 - wie (1), aber nun resetfest, d.h. resident bleiben
;                    2 - wie (2), aber nicht resetfest eingeklinkt
;                   <0 - Fehler aufgetreten, Cookie nicht eingetragen
insert_cookie:  movem.l D2-D5/A1,-(SP)
                move.l  D2,D5                     ;L„nge einer evtl. Liste merken
                move.l  _p_cookies_.w,D3          ;Zeiger auf das Cookie Jar holen
                beq.s   insert_cookie_s           ;ist leer => Liste einrichten
                movea.l D3,A1
                moveq   #0,D4                     ;Anzahl der Slots
insert_cookie_h:addq.w  #1,D4                     ;Slotanzahl erh”hen
                movem.l (A1)+,D2-D3               ;Namen und Wert eines Cookies holen
                tst.l   D2                        ;leeren Cookie gefunden?
                bne.s   insert_cookie_h           ;Nein => weiter suchen
                cmp.l   D3,D4                     ;alle Slots belegt?
                beq.s   insert_cookie_n           ;Ja! => neue Liste anlegen
                movem.l D0-D3,-8(A1)              ;neuen Cookie & Listenende einfügen
                moveq   #0,D0                     ;alles ok!
                bra.s   insert_cookie_x           ;und raus

insert_cookie_s:moveq   #2,D4
                cmp.l   D4,D2                     ;weniger als 2 Eintr„ge?
                blo.s   insert_cookie_e           ;das ein Fehler! (Liste zu klein!)
                move.l  resvector.w,old_resvector
                move.l  resvalid.w,old_resvalid   ;alten Reset-Vektor merken

                move.l  #cookie_reset,resvector.w
                move.l  #$31415926,resvalid.w     ;und eigenen einsetzen
                move.l  A0,_p_cookies_.w          ;Cookie Jar initialisieren
                moveq   #0,D3                     ;Markierung: Ende der Cookie-List
                exg     D2,D3                     ;Anzahl der Slots nach D3
                movem.l D0-D3,(A0)                ;Namen und Wert des Cookies einsetzen
                moveq   #1,D0                     ;Liste resetfest eingerichtet, alles ok
                bra.s   insert_cookie_x           ;und raus

insert_cookie_e:moveq   #-1,D0                    ;Fehler, Cookie nicht eingetragen
                bra.s   insert_cookie_x           ;und raus

;reset-feste Routine zum Entfernen des Cookie Jars
old_resvalid:  DS.L 1                             ;altes Reset-Valid
               DC.L 'XBRA'                        ;XBRA-Protokoll
               DC.L 'BUG2'                        ;ä-soft-Kennung, Cookie-List
old_resvector: DS.L 1                             ;alter Reset-Vektor
cookie_reset:   clr.l   _p_cookies_.w             ;Cookie Jar entfernen
                move.l  old_resvector(PC),resvector.w ;Reset-Vektor zurück
                move.l  old_resvalid(PC),resvalid.w
                jmp     (A6)                      ;weiter mit dem RESET

insert_cookie_n:cmp.l   D5,D4                     ;reicht der Platz?
                ble.s   insert_cookie_e           ;Nein => Fehler und raus
                movea.l _p_cookies_.w,A1          ;Anfang der Liste erneut holen
                move.l  A0,_p_cookies_.w          ;neuen Cookie Jar eintragen
                subq.w  #2,D4                     ;Ende nicht kopieren (-1 für DBRA)
insert_cookie_m:move.l  (A1)+,(A0)+               ;Eintr„ge der Liste kopieren
                move.l  (A1)+,(A0)+
                dbra    D4,insert_cookie_m
                move.l  D5,D3                     ;Anzahl der Slots
                movem.l D0-D3,(A0)                ;eigenes Element eintragen + Listenende
                moveq   #2,D0                     ;alles ok, resident bleiben
insert_cookie_x:movem.l (SP)+,D2-D5/A1
                rts
               ;>ENDPART
               ENDC

               ;>PART 'STOP-Icon'
stop_icn:      DC.L $7FFE00                       ;Das STOP-Schild
               DC.L $C00300
               DC.L $01BFFD80
               DC.L $037FFEC0
               DC.L $06FFFF60
               DC.L $0DFFFFB0
               DC.L $1BFFFFD8
               DC.L $37FFFFEC
               DC.L $6FFFFFF6
               DC.L $DFFFFFFB
               DC.L $B181860D
               DC.L $A0810205
               DC.L $A4E73265
               DC.L $A7E73265
               DC.L $A3E73265
               DC.L $B1E73205
               DC.L $B8E7320D
               DC.L $BCE7327D
               DC.L $A4E7327D
               DC.L $A0E7027D
               DC.L $B1E7867D
               DC.L $BFFFFFFD
               DC.L $DFFFFFFB
               DC.L $6FFFFFF6
               DC.L $37FFFFEC
               DC.L $1BFFFFD8
               DC.L $0DFFFFB0
               DC.L $06FFFF60
               DC.L $037FFEC0
               DC.L $01BFFD80
               DC.L $C00300
               DC.L $7FFE00
               ;>ENDPART
********************************************************************************
* lange Datenbereiche, welche BSR zu JSR "optimieren" würden                   *
********************************************************************************
               ;>PART 'TOS-Funktionsnamen'
gemdos_befs:   DC.B 0,0,'Pterm0',0,1,0,'Cconin',0,2,1,'Cconout',0
               DC.B 3,0,'Cauxin',0,4,1,'Cauxout',0,5,1,'Cprnout',0
               DC.B 6,1,'Crawio',0,7,0,'Crawcin',0,8,0,'Cnecin',0
               DC.B 9,3,'Cconws',0,10,3,'Cconrs',0,11,0,'Cconis',0
               DC.B 14,1,'Dsetdrv',0,16,0,'Cconos',0,17,0,'Cprnos',0
               DC.B 18,0,'Cauxis',0,19,0,'Cauxos',0,25,0,'Dgetdrv',0
               DC.B 26,3,'Fsetdta',0,32,3,'Super',0,42,0,'Tgetdate',0
               DC.B 43,1,'Tsetdate',0,44,0,'Tgettime',0,45,1,'Tsettime',0
               DC.B 47,0,'Fgetdta',0,48,0,'Sversion',0,49,6,'Ptermres',0
               DC.B 54,7,'Dfree',0,57,3,'Dcreate',0,58,3,'Ddelete',0
               DC.B 59,3,'Dsetpath',0,60,7,'Fcreate',0,61,7,'Fopen',0
               DC.B 62,1,'Fclose',0,63,57,'Fread',0,64,57,'Fwrite',0
               DC.B 65,3,'Fdelete',0,66,22,'Fseek',0,67,23,'Fattrib',0
               DC.B 69,1,'Fdup',0,70,5,'Fforce',0,71,7,'Dgetpath',0
               DC.B 72,2,'Malloc',0,73,3,'Mfree',0,74,45,'Mshrink',0
               DC.B 75,253,0,'Pexec',0,76,1,'Pterm',0,78,7,'Fsfirst',0
               DC.B 79,0,'Fsnext',0,86,61,'Frename',0,87,23,'Fdatime',0
;Ab hier: Netzwerk-Erweiterungen (siehe ST-Magazin 11/89)
               DC.B $60,0,'Nversion',0,$62,57,'Frlock',0,$63,13,'Frunlock',0
               DC.B $64,13,'Flock',0,$65,1,'Funlock',0,$66,1,'Fflush',0
               DC.B $7B,2,'Unlock',0,$7C,2,'Lock',0
               DC.B -1                            ;Ende der Tabelle

bios_befs:     DC.B 0,3,'Getmpb',0,1,1,'Bconstat',0,2,1,'Bconin',0
               DC.B 3,5,'Bconout',0,4,93,1,'Rwabs',0,5,9,'Setexec',0
               DC.B 6,0,'Tickcal',0,7,1,'Getbpb',0,8,1,'Bcostat',0
               DC.B 9,1,'Mediach',0,10,0,'Drvmap',0,11,1,'Kbshift',0
               DC.B -1
               EVEN

xbios_befs:    DC.B 0,61,'Initmous',0,1,2,'Ssbrk',0,2,0,'Physbase',0
               DC.B 3,0,'Logbase',0,4,0,'Getrez',0,5,31,'Setscreen',0
               DC.B 6,3,'Setpalette',0,7,5,'Setcolor',0,8,91,21,'Floprd',0
               DC.B 9,91,21,'Flopwr',0,10,95,149,'Flopfmt',0,11,0,'Getdsb',0
               DC.B 12,13,'Midiws',0,13,13,'Mfpint',0,14,1,'Iorec',0
               DC.B 15,85,5,'Rsconf',0,16,42,'Keytbl',0,17,0,'Random',0
               DC.B 18,91,0,'Protobt',0,19,91,21,'Flopver',0,20,0,'Scrdmp',0
               DC.B 21,5,'Cursconf',0,22,2,'Settime',0,23,0,'Gettime',0
               DC.B 24,0,'Bioskeys',0,25,13,'Ikbdws',0,26,1,'Jdisint',0
               DC.B 27,1,'Jenabint',0,28,5,'Giaccess',0,29,1,'Offgibit',0
               DC.B 30,1,'Ongibit',0,31,213,0,'Xbtimer',0,32,3,'Dosound',0
               DC.B 33,1,'Setprt',0,34,0,'Kbdvbase',0,35,5,'Kbrate',0
               DC.B 36,3,'Prtblk',0,37,0,'Vsync',0,38,3,'Supexec',0
               DC.B 39,0,'Puntaes',0

               DC.B 41,5,'Floprate',0             ;ab TOS 1.4 - Steprate setzen

               DC.B 42,119,0,'DMAread',0,43,119,0,'DMAwrite',0,44,1,'Bconmap',0 ;TT - Funktion

               DC.B 48,1,'Meta_init',0            ;ab hier: neue Funktionen für Meta-DOS
               DC.B 49,5,'open',0                 ;eine Erweiterung für GROžE Datentr„ger
               DC.B 50,1,'close',0                ;d.h. CD-ROM, etc.
               DC.B 51,85,0,'read',0
               DC.B 53,5,'seek',0
               DC.B 54,5,'status',0
               DC.B 59,21,'start_aud',0           ;ab hier: spezielle Funktionen für
               DC.B 60,5,'stop_aud',0             ;das CDAR504 - sprich Ataris CD-ROM
               DC.B 61,21,'set_songtime',0
               DC.B 62,21,'get_toc',0
               DC.B 63,5,'disc_info',0

               DC.B 64,1,'Blitmode',0             ;Ab TOS 1.2 - Blittertest

               DC.B 80,1,'_EsetShift',0           ;TT - Funktionen
               DC.B 81,0,'_EgetShift',0,82,1,'_EsetBank',0
               DC.B 83,5,'_EsetColor',0,84,53,'_EsetPalette',0
               DC.B 85,53,'_EgetPalette',0,86,1,'_EsetGray',0
               DC.B 87,1,'_EsetSmear',0
               DC.B -1
               EVEN

vdi_befs:      DC.B 1,0,'_openwk',0,'_clswk',0,'_clrwk',0,'_updwk',0,'di_esc',0
               DC.B '_pline',0,'_pmarker',0,'_gtext',0,'_fillarea',0
               DC.B '_cellarray',0,-1,0
               DC.B 'st_height',0,'st_rotation',0,'s_color',0
               DC.B 'sl_type',0,'sl_width',0,'sl_color',0,'sm_type',0
               DC.B 'sm_height',0,'sm_color',0,'st_font',0,'st_color',0
               DC.B 'sf_interior',0,'sf_style',0,'sf_color',0,'q_color',0
               DC.B 'q_cellarray',0,'_locator',0,'_valuator',0
               DC.B '_choice',0,'_string',0,'swr_mode',0,'sin_mode',0
               DC.B '_illegal',0,'ql_attributes',0,'qm_attributes',0
               DC.B 'qf_attributes',0,'qt_attributes',0,'st_alignment',0
               DC.B '_opnvwk',0,'_clsvwk',0,'q_extnd',0,'_contourfill',0
               DC.B 'sf_perimeter',0,'_get_pixel',0,'st_effects',0,'st_point',0
               DC.B 'sl_ends',0,'ro_cpyfm',0,'r_trnfm',0,'sc_form',0
               DC.B 'sf_updat',0,'sl_udsty',0,'r_recfl',0,'qin_mode',0
               DC.B 'qt_extent',0,'qt_width',0,'ex_timv',0,'st_load_fonts',0
               DC.B 'st_unload_fonts',0,'rt_cpyfm',0,'_show_c',0,'_hide_c',0
               DC.B 'q_mouse',0,'ex_butv',0,'ex_motv',0,'ex_curv',0
               DC.B 'q_key_s',0,'s_clip',0,'qt_name',0,'qt_fontinfo',0
               EVEN
vdi2bef:       DC.B '_bar',0,'_arc',0,'_pie',0,'_circle',0,'_ellipse',0
               DC.B '_ellarc',0,'_ellpie',0,'_rbox',0,'_rfbox',0,'_justified',0

aes_befs:      DC.B 9,'appl',0
               DC.B 'init',0,'read',0,'write',0,'find',0,'tplay',0,'trecord',0
               DC.B 'bvset',0,'yield',-1
               DC.B 18,'appl',0,'exit',-1
               DC.B 19,'evnt',0
               DC.B 'keybd',0,'button',0,'mouse',0,'mesag',0,'timer',0
               DC.B 'multi',0,'dclick',-1
               DC.B 29,'menu',0
               DC.B 'bar',0,'icheck',0,'ienable',0,'tnormal',0,'text',0
               DC.B 'register',0,'unregister',-1
               DC.B 39,'objc',0
               DC.B 'add',0,'delete',0,'draw',0,'find',0,'offset',0,'order',0
               DC.B 'edit',0,'change',-1
               DC.B 49,'form',0
               DC.B 'do',0,'dial',0,'alert',0,'error',0,'center',0,'keybd',0
               DC.B 'button',-1
               DC.B 69,'graf',0
               DC.B 'rubberbox',0,'dragbox',0,'movebox',0,'growbox',0,'shrinkbox',0
               DC.B 'watchbox',0,'slidebox',0,'handle',0,'mouse',0,'mkstate',-1
               DC.B 79,'scrap',0
               DC.B 'read',0,'write',0,'clear',-1
               DC.B 89,'fsel',0,'input',0,'exinput',-1
               DC.B 99,'wind',0,'create',0,'open',0,'close',0,'delete',0,'get',0
               DC.B 'set',0,'find',0,'update',0,'calc',0,'new',-1
               DC.B 109,'rsrc',0,'load',0,'free',0,'gaddr',0,'saddr',0,'obfix',-1
               DC.B 119,'shel',0,'read',0,'write',0,'get',0,'put',0,'find',0
               DC.B 'envrn',0,'rdef',0,'wdef',-1
               DC.B 129,'xgrf',0,'stepcalc',0,'2box',-1
               DC.B -1
aes_all:       DC.B 10,11,12,13,14,15,16,17,19,20,21,22,23,24,25,26,30,31,32,33
               DC.B 34,35,36,40,41,42,43,44,45,46,47,50,51,52,53,54,55,56,70,71
               DC.B 72,73,74,75,76,77,78,79,80,81,82,90,91,100,101,102,103,104
               DC.B 105,106,107,108,109,110,111,112,113,114,120,121,122,123,124
               DC.B 125,126,127,130,131,0
vdi_all:       DC.B 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
               DC.B 20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39
               DC.B 100,101,102,103,104,105,106,107,108,109
               DC.B 110,111,112,113,114,115,116,117,118,119,120
               DC.B 121,122,123,124,125,126,127,128,129,130,131
               DC.B 0
               EVEN
               ;>ENDPART

               IFEQ sprache
about_txt:     
               DC.B 13,'ä-Softs Bugaboo V'
               DC.B (version>>24)&$0F+'0'
               DC.B '.'
               IF (version>>20)&$0F<>0
               DC.B (version>>20)&$0F+'0'
               ENDC
               DC.B (version>>16)&$0F+'0'
               DC.B '.'
               IF (version>>12)&$0F<>0
               DC.B (version>>12)&$0F+'0'
               ENDC
               DC.B (version>>8)&$0F+'0'
               IF version&$FF
               DC.B version&$FF
               ENDC
               DC.B ' + Falcon refix + extensions',13,13
               IFNE ultradev
               ;     --------------------------------------------------------------------------------
               DC.B '----- Und was ist das jetzt? -----',$0d
               DC.B 'Bugaboo hatte in all seiner Perfektheit doch ein Problem: es lief nicht gut auf',13
               DC.B 'dem Falcon 030. Bis 1993 die 680XX convention stattfand. Zwei Deppen hatten da',13
               DC.B 'die Idee, den Bugaboo (halbwegs) F030-f',$84,'hig zu machen. Gl',$9a,'cklicherweise war von',13
               DC.B 'den Autoren gerade der Sourcecode ver',$94,'ffentlicht worden - anhanddessen sind',13
               DC.B 'dann noch auf der Party F030-fixes (so halbwegs) eingebaut worden.',13
               DC.B 'Leider ging der source dann verloren - bis schliesslich 2020 einer der genannten'
               DC.B 'Deppen das im Umlauf befindliche Binary disassemblierte und die Patches dem',13
               DC.B 'original Source wieder zuf',$94,'gte. Aber da h',$94,'rte es nicht auf; eine Unterst',$9a,'tzung',13
               DC.B 'des neuesten Schreis an Entwicklerhardware wurde zugef',$9a,'gt: ultraDev. Ultra hat',13
               DC.B 'Bugaboo vom ultraDev mit dem Debugtarget aufrufbar gemacht und tIn hat die UD-',13
               DC.B 'Erkennung und einen Modus zugef',$9a,'gt, der die Bugaboo-Oberfl',$84,'che auf dem VGA-',13
               DC.B 'Ausgang des UD ausgibt - echtes Dual-Screen debugging ohne das l',$84,'stige Flackern',13
               DC.B 'beim tracen!',13,13
               DC.B 'Und das ist der Punkt, wo Du ins Spiel kommst - nimm den Source, baue weitere',13
               DC.B 'Erweiterungen oder Bugfixes ein und lasse es uns wissen!'
               ENDC
               DC.B 0
               ELSE
about_txt:     
               DC.B 13,'Bugaboo V'
               DC.B (version>>24)&$0F+'0'
               DC.B '.'
               IF (version>>20)&$0F<>0
               DC.B (version>>20)&$0F+'0'
               ENDC
               DC.B (version>>16)&$0F+'0'
               DC.B '.'
               IF (version>>12)&$0F<>0
               DC.B (version>>12)&$0F+'0'
               ENDC
               DC.B (version>>8)&$0F+'0'
               IF version&$FF
               DC.B version&$FF
               ENDC
               DC.B ' by ä-Soft + Falcon refix + extensions',13,13               
               ;     --------------------------------------------------------------------------------
               IFNE ultradev
               DC.B '----- What is this? -----',$0d
               DC.B "Bugaboo in all it's awesomeness had only one flaw: it did not work very well on",13
               DC.B 'the Falcon 030. Until 680XX convention 1993: two idiots had the idea to patch it'
               DC.B 'to run on Falcon (more or less). Fortunately the author had just released the',13
               DC.B 'source code - so they used that and fixed it for Falcon 030 (more or less).',13
               DC.B 'That version was flawed - but unfortunately the source was lost in the decades',13
               DC.B 'to follow. Until one of those aforementioned idiots disassembled that version',13
               DC.B 'and re-added the patches to the officially released Bugaboo source.',13
               DC.B 'On top of that madness, support for the latest and greatest dev hardware was',13
               DC.B 'added: ultraDev. Since Ultra added support to load Bugaboo and the guest PRG',13
               DC.B 'directly from UD, tIn saw fit to add UD detection and a mirror mode to show',13
               DC.B 'Bugaboos UI on UDs VGA output - true dual-screen debugging without those',13
               DC.B 'flickering switches between Bugaboo and the PRG.',13,13
               DC.B "And now... that's where you come in - use the source, add your own extensions",13
               DC.B "or fixes and let us know!",13
               ENDC
               DC.B 0
               ENDC
               EVEN

********************************************************************************
* Der BSS-Bereich                                                              *
********************************************************************************
varbase:        jmp     ret_jump
               BSS
               RSSET 6                            ;Variablen des Keyboard-/Screen- & Maustreibers
@chrout        EQU chrout-varbase                 ;relative varbase-Offsets
@charout       EQU charout-varbase
@print_line    EQU print_line-varbase
@c_eol         EQU c_eol-varbase
@crout         EQU crout-varbase
@page1         EQU page1-varbase
@page1_force   EQU page1_force-varbase
@page2         EQU page2-varbase
@page2_force   EQU page2_force-varbase
@my_driver     EQU my_driver-varbase
@org_driver    EQU org_driver-varbase
@form_do       EQU form_do-varbase
@ikbd_send     EQU ikbd_send-varbase
@redraw_all    EQU redraw_all-varbase
@space         EQU space-varbase
@init          EQU init-varbase
@set_ins_flag  EQU set_ins_flag-varbase
@c_clrhome     EQU c_clrhome-varbase
@anf_adr       EQU anf_adr-varbase
@get_line      EQU get_line-varbase
@cursor_off    EQU cursor_off-varbase
@cache_up      EQU cache_up-varbase
@desel_menue    EQU desel_menue-varbase
@conin         EQU conin-varbase
@scr_edit      EQU scr_edit-varbase
@_trap3        EQU _trap3-varbase

;Variablen des Keyboard-/Screen- & Maustreibers
curflag:       RS.W 1                             ;<>0: Cursor an
zeile:         RS.W 1                             ;Cursorzeile 0-24
spalte:        RS.W 1                             ;Cursorspalte 0-79
debugger_scr:  RS.B scr_struct                    ;Daten des Debugger-Screens
user_scr:      RS.B scr_struct                    ;Daten des User-Screens
init_scr:      RS.B scr_struct                    ;Daten des Bildschirms beim Debugger-Start
no_overscan:   RS.B scr_struct                    ;nur Nullbytes, d.h. OverScan war aus (RESET-Phase)
               RSEVEN
farbfont:      RS.L 1                             ;Font-Adressen
s_w_font:      RS.L 1

std_keytab:    RS.L 1                             ;Zeiger auf Keyboardtabellen
shift_keytab:  RS.L 1
caps_keytab:   RS.L 1
kbdvbase:      RS.L 9
iorec_IKBD:    RS.L 2
iorec_puffer:  RS.L 64
ikbd_string:   RS.B 20                            ;String für das Keyboard
vbl_count1:    RS.L 1
vbl_count2:    RS.L 1
tmacro_pointer:RS.L 1                             ;Zeigt auf aktives TMacro (0=kein TMacro)
tmacro_repeat: RS.W 1                             ;Anzahl der wiederholungen einer Taste
tmacro_def_key:RS.L 1                             ;<>0 => TMacro-Definition aktiv (MTastencode)
tmacro_def_adr:RS.L 1                             ;akt.Pnt auf TMacro-Definiton
tmacro_def_flag:RS.B 1                            ;<>0 => Wartet auf Taste bei Control-ESC
               RSEVEN
timer_c_bitmap:RS.W 1
kbd_r_init:    RS.B 1
kbd_r_rate:    RS.B 1
stat_paket:    RS.B 7
maus_paket_1:  RS.B 5
maus_paket_2:  RS.B 3
zeit_paket:    RS.B 6
joydat0:       RS.B 2
joydat2:       RS.B 0
kbstate:       RS.B 1
kbindex:       RS.B 1                             ;Variablen des Tastaturtreibers
kbshift:       RS.B 1
kbalt:         RS.B 1
kbd_repeat_on: RS.B 1
kbd_r_key:     RS.B 1
kbd_r_verz:    RS.B 1
kbd_r_cnt:     RS.B 1
merk_shift:    RS.B 1
               RSEVEN
mausx:         RS.W 1                             ;Mausx (0-639)
mausy:         RS.W 1                             ;Mausy (0-399)
maus_time:     RS.L 1                             ;200Hz Z„hlerstand beim letzten Klick
maus_time2:    RS.L 1                             ;200Hz Z„hlerstand beim Drücken einer Maustaste
mausf_time:    RS.L 1                             ;Timer für die Mausbeschleunigung
maus_flag:     RS.W 1                             ;=0  => Doppelklick m”glich (Taste n.gedrückt)
sprite_no:     RS.W 1                             ;Spritenummer (0=Pfeil,1=Diskette)
button_nr:     RS.W 1                             ;akt.Button bei objc_draw
ass_load:      RS.B 1                             ;<>0 => Laden durch den Assembler
maus_merk:     RS.B 1                             ;gemerkter Maustastenstatus
maus_merk2:    RS.B 1
no_dklick:     RS.B 1                             ;<>0 => Keine Doppelklickabfrage
fast_exit:     RS.B 1                             ;<>0 => sofort mit CTRL+HELP raus $25f8
le_allowed:    RS.B 1                             ;<>0 => LE ist erlaubt
resident:      RS.B 1                             ;<>0 => Debugger ist resident
akt_maust:     RS.B 1                             ;Maustasten für den 200Hz-Timer
maustast:      RS.B 1                             ;Bit 0-Rechts,B1-Links,B2-ReDop,B3-LiDop
mausprell:     RS.B 1                             ;zum Entprellen
mausprell2:    RS.B 1
mausoff:       RS.B 1                             ;<>0 => Kein Maussetzen durch den VBL
mausmove:      RS.B 1                             ;<>0 => Maus wurde bewegt
mausflg:       RS.B 1                             ;=0  => Maus nicht da
ssc_flag:      RS.B 1                             ;<>0 => Shift+Shift+Control gedrückt
set_lock:      RS.B 1                             ;<>0 => Cursorsetzen im VBL ist verboten
device:        RS.B 1                             ;Output Standard Device
testwrd:       RS.B 1                             ;<>0 => Ausgabe in Buffer, sonst Screen
gst_sym_flag:  RS.B 1                             ;<>0 => GST Symboltabelle geladen
install_load:  RS.B 1                             ;<>0 => Installation wurde geladen
prozessor:     RS.B 1                             ;-1:68000, 0:68010, 1:68020, 2:68030
fpu_flag:      RS.B 1                             ;Bit 0: SFP004, Bit 1:68881, Bit 2:68882
ste_flag:      RS.B 1                             ;-1:STE-Hardware vorhanden
tt_flag:       RS.B 1                             ;-1:TT vorhanden
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f030_flag:     RS.B 1                             ;-1:F030 vorhanden
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;###############################
extension_flags:RS.B 1                            ;$1=ultradev
 IFNE ultradev
udmirror_enable:RS.B 1                            ;<>0 ==> ultraDev VGA mirror on
 ENDC
;###############################
batch_flag:    RS.B 1                             ;<>0 => Batch-Mode an
ignore_autocrlf:RS.B 1                            ;<>0 => CR/LF nicht automatisch ausgeben
               RSEVEN
entry:         RS.W 1                             ;selektierter Menueeintrag
entry_old:     RS.W 1                             ;letzter selektierter Menueeintrag
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f030_vft:      RS.W 1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
mausbuffer:    RS.L 17                            ;Hintergrundspeicher der Maus

untrace_flag:  RS.W 1                             ;<>0 => Untrace an
untrace_funk:  RS.B 80                            ;Die eingegebene User-Trace-Funktion
untrace_count: RS.L 1                             ;Counter für Untrace
trace_count:   RS.L 1                             ;Counter für Trace
cond_breaks:   RS.B 1280                          ;Platz für 16 Breakpoints

;Allgemeine Variablen
data_buff:     RS.B 80
fname:         RS.B 80                            ;Buffer für den akt.Filenamen
_dumpflg:      RS.B 1                             ;=0 => Screendump auf Disk
dobef_flag:    RS.B 1                             ;<>0 => |Befehl ausgeführt worden
help_allow:    RS.B 1                             ;<>0 => mit HELP zurück zum Assembler
list_flg:      RS.B 1                             ;Symbolisch disassemble in "disa", wenn <>0
direct:        RS.B 1                             ;<>0 => Direktmodus (für's Scrollen)
autodo_flag:   RS.B 1                             ;<>0 => CTRL+M-Befehl ausführen
auto_sym:      RS.B 1                             ;<>0 => Symbole des Assemblers werden genutzt
mausscroll_on: RS.B 1                             ;<>0 => Mausscrolling ist an
mausscroll_flg1:RS.B 1                            ;<>0 => Mausscrolling war an
illegal_flg:   RS.B 1                             ;<>0 => in scr_edit CTRL+CRSR-left für Illegal
find_cont0:    RS.B 1                             ;-1=Hunt,0=Find,1=Ascfind
               RSEVEN
prg_flags:     RS.L 1                             ;Flags des geladenen Programms
find_cont1:    RS.L 1                             ;akt.Adresse für Continue
find_cont2:    RS.L 1                             ;Endadresse für Continue
find_cont3:    RS.W 1                             ;L„nge des Suchstrings
default_adr:   RS.L 1                             ;Defaultadr für diverse Operationen
_fhdle:        RS.W 1                             ;Filehandle für I/O-Operationen
_fhdle2:       RS.W 1                             ;Filehandle für Protokoll auf Disk
dir_ext:       RS.B 14                            ;Platz für den Suchpfad bei Dir
spaced:        RS.B 258                           ;Buffer für z.B. den Disassembler
spaced2:       RS.B 258                           ;ein zweiter allgemeiner Buffer

default_start: RS.B 10                            ;'ä-Soft'
do_resident:   RS.W 1                             ;<>0 => 'RESIDENT' automatisch ausführen
alquantor:     RS.B 1                             ;'*'-Joker
exquantor:     RS.B 1                             ;'?'-Joker
overscan:      RS.W 1                             ;<>0 => OverScan ist an
midi_flag:     RS.W 1                             ;<>0 => keine MIDI-Tastaturabfrage
ring_flag:     RS.W 1                             ;<>0 => kein Ring-Indikatortest
shift_flag:    RS.W 1                             ;<>0 => Shift-Shift-Abbruch implementiert
ins_mode:      RS.W 1                             ;<>0 => Insert-Mode an
cursor_form:   RS.W 1                             ;Die Cursorform
disbase:       RS.W 1                             ;Zahlenbasis des Disassemblers
format_flag:   RS.W 1                             ;<>0 => Disassemble bei Doppelklick, sonst Dump
def_lines:     RS.W 1                             ;Defaultzeilenanzahl (normal=16)
def_size:      RS.W 1                             ;Breite bei Dump (normal=16)
scroll_d:      RS.W 1                             ;Scrollverz”gerung
trace_delay:   RS.W 1                             ;Verz”gerung nach F1, ...
trace_flag:    RS.W 1                             ;0=List, 1=Disassemble bei Trace (F1,F2,...)
smart_switch:  RS.W 1                             ;0=normales Screenumschalten, 1=Umschalten im VBL
small:         RS.W 1                             ;<>0 => Kleinschrift
col0:          RS.W 1                             ;Hintergrundfarbe des Debuggers
col1:          RS.W 1                             ;Vordergrundfarbe  "       "
conterm:       RS.W 1                             ;Bit0=1 => Tastaturklick
no_aes_check:  RS.W 1                             ;<>0 => Kein AES/VDI-Parametertest
all_memory:    RS.W 1                             ;<>0 => kein Speicherzugriffstest
bugaboo_sym:   RS.W 1                             ;<>0 => interne Symboltabelle benutzen
_zeile3:       RS.B 80                            ;3.Zeilenbuffer (für HELP)
convert_tab:   RS.B 256                           ;Zeichenkonvertierungstabelle
               RS.L 1                             ;muž Null sein!
tmacro_tab:    RS.L 1024                          ;TMacro-Tabelle
tmacro_tab_end:RS.L 1                             ;Ende der TMacro-Tabelle
default_end:   RS.W 0

_regsav2:      RS.L 1
_regsav:       RS.L 16                            ;Register bei do_trap_1

trap_abort:    RS.B 1                             ;Trapnummer, welche Abbruch ausl”ste
observe_off:   RS.B 1                             ;<>0 => Observe ausschalten
gemdos_break:  RS.B 126                           ;für Gemdos(0-126)
bios_break:    RS.B 12                            ;für Bios(0-11)
xbios_break:   RS.B 87                            ;für Xbios(0-87)
aes_break:     RS.B 136                           ;für AES (Funktionsnr)
vdi_break:     RS.B 132                           ;für VDI (Funktionsnr)
end_of_breaks: RS.B 0
breaks_flag:   RS.B 1                             ;<>0 => Breakpoints eingesetzt
breakpnt:      RS.W 102                           ;Speicher für die Breakpoints
breakpnt_end:  RS.W 0
input_pnt:     RS.L 1                             ;Zeiger auf den Eingabebuffer (für Makros)

;Die Register des zu debuggenden Programms
regs:          RS.L 15                            ;D0-D7/A0-A6
rega7:         RS.L 1                             ;A7
_pc:           RS.L 1                             ;PC  64 Reichenfolge ist fix !!!
_usp:          RS.L 1                             ;USP 68
_ssp:          RS.L 1                             ;SSP 72
_sr:           RS.W 1                             ;SR  76
_fcreg:        RS.W 1                             ;Funktionscode-Register (Busfehler)
_zykadr:       RS.L 1                             ;Zyklusadresse (Busfehler)
_befreg:       RS.W 1                             ;Befehlsregister (Busfehler)

merk_stk:      RS.L 1                             ;Trace until RTS
merk_a0:       RS.L 1                             ;A0 für Break bei "Lineinput"
merk_pc:       RS.L 1                             ;PC für Markierung am Zeilenanfang
merk_pc_call:  RS.L 1                             ;gemerkter PC für Call

dsk_track:     RS.W 1
dsk_sektor:    RS.W 1
dsk_side:      RS.W 1
dsk_drive:     RS.W 1                             ;für RS, RW, RT
dsk_adr:       RS.L 1
dsk_adr2:      RS.L 1
checksum:      RS.W 1

;Alles nur für den "Load for Execute"-Befehl
load1:         RS.W 1                             ;1.Befehl des Programms (für Breakpoint)
load2:         RS.L 1                             ;Illegal-Vektor
load3:         RS.L 1                             ;Alter Stackpointer
load4:         RS.L 1                             ;Rücksprungadresse nach Term
load5:         RS.L 1                             ;Prg-Interner Stack (Regsave-Base)
load6:         RS.L 1                             ;geretteter TRAP #14
               RS.L 40                            ;Stack bei Load for Execute
lstackend:     RS.L 0

assm_flag:     RS.W 1                             ;<>0 => Eingabe mit dem Line-Assembler
tablen:        RS.W 1                             ;Anzahl der Mnemonics in der Tabelle
op_buffer:     RS.B 64                            ;Puffer Opcode und Zeileninfo

upper_line:    RS.W 1                             ;Bildschirmaufteilung
upper_offset:  RS.W 1                             ;für den Bildschirmtreiber
down_lines:    RS.W 1
rom_base:      RS.L 1                             ;Startadresse des ROMs
jmpdispa:      RS.L 1                             ;Sprungadresse für inp_loop
end_adr:       RS.L 1                             ;Endadresse des Debuggers
merk_svar:     RS.L 1                             ;Zeiger auf die Markertabelle
basep:         RS.L 1                             ;Basepage des eingeladenen Programms
trace_pos:     RS.L 1                             ;Position im Tracebuffer
reg_pos:       RS.L 1                             ;akt.Anzeigeposition im Tracebuffer
merk_anf:      RS.L 1                             ;Anfangs-/Endadresse nach Load
merk_end:      RS.L 1
err_stk:       RS.L 1                             ;gemerkter Stack für Doppelklick
err_flag:      RS.B 1                             ;<>0 => statt Fehler zu mauschf (Ende)
first_call:    RS.B 1                             ;=0 => Intro-Alert ausgeben
merk_it:       RS.L 1                             ;gemerkter 200Hertz-Timer (Schutz!)
sym_adr:       RS.L 1                             ;Zeiger auf die Symboltabelle
sym_size:      RS.L 1                             ;Gr”že der Symboltabelle
sym_end:       RS.L 1                             ;Endadresse der Symboltabelle + 1
prg_base:      RS.L 1                             ;<>0 => Prgbasisadr im RAM (automatisch)
max_linef:     RS.W 1                             ;$9CC als max.Line-F-Opcode
merk_quit_sr:  RS.W 1                             ;SR bei kill_program
linef_base:    RS.L 1                             ;Basisadr der Linef-Sprungtabelle
save_clrkbd:   RS.L 1                             ;Auto-Repeat-Flag-Adresse (stets Inhalt l”schen)
first_free:    RS.L 1                             ;Zeiger hinter den Debugger
end_of_mem:    RS.L 1                             ;Ende des freien Speichers
act_pd:        RS.L 1                             ;Aktueller Prozež-Zeiger
merk_act_pd:   RS.L 1                             ;act_pd beim Debuggerstart
kbshift_adr:   RS.L 1                             ;Adresse der Kbshiftvariable
serial:        RS.L 1                             ;Die Seriennummer aus dem Header (zur Anzeige)
quit_stk:      RS.L 1                             ;Rücksprungadr bei Aufruf der residenten Ver
ass_vector:    RS.L 1                             ;Adr der Assembler-Vektortabelle
_zeile:        RS.B 82                            ;Zeileneingabebuffer
_zeile2:       RS.B 82                            ;2.Zeilenbuffer (für UNDO)
prn_pos:       RS.W 1                             ;Position im Druckbuffer
prn_buff:      RS.B 258                           ;Buffer für Druckerausgabe
simple_vars:   RS.L 10                            ;max.10 "einfache" Anwendervariablen
merk_internal: RS.L 10                            ;Alle mgl Register $2334
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
f030_save_24DC:RS.L $14
f030_save_2532:RS.L $14
f030_save_2588:RS.L $14
f030_save_25DE:RS.L 1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
merk_user:     RS.L 10                            ;Alle mgl Register des zu debuggenden Prgs $2408
cmd_line_adr:  RS.L 1                             ;šbergabe einer Command-Line mit OUTPUT
sym_buffer:    RS.L 1                             ;Zeiger auf die Symboltabelle
sym_anzahl:    RS.W 1                             ;Anzahl der Symbole in der Tabelle
old_stack:     RS.L 1                             ;alter SSP
old_usp:       RS.L 1                             ;alter USP
line_back:     RS.L 1                             ;PC-Offset als Rückgabe an den Assembler
hz200_time:    RS.L 1                             ;gemerkter hz200-Timerstand (wg.der Hardisk!)
caps_tab:      RS.B 128                           ;Keyboard-Tabelle für CAPS/LOCK
dta_buffer:    RS.B 44                            ;der DTA-Buffer für Fsfirst()
default_stk:   RS.L 1                             ;A7 für Fehler
basepage:      RS.L 1                             ;Basepage des Debuggers
save_data:     RS.B $05B0-8                       ;Kopie des Speicherbereichs von $8 bis $5AF
screen:        RS.B 2080                          ;80*26 Zeichen auf einem Bildschirm
               RS.L 64                            ;Rechenstack für convert_formel
formel:        RS.L 0
spez_format:   RS.B 10                            ;Ausgabebreite für spez_buff
spez_buff:     RS.W 2560                          ;10*256 Bytes für die 10 Formelzeilen
scr_buff:      RS.W 8030                          ;10 Bildschirme k”nnen gerettet werden
linebuf:       RS.L 2048                          ;max.2048 Zeilen pro convert_formel (Optimize)
debug_sstack:  RS.L 0                             ;8k Stack für's zu debuggende Programm
cond_bkpt_jsr: RS.W 4096                          ;16*512 Bytes für Breakpoints
user_trace_buf:RS.W 512                           ;1k User-Trace-Routine
allg_buffer:   RS.B 14000                         ;Buffer für DIR und FORMAT
allg_buf_end:  RS.W 0                             ;Ende des Buffers
trace_buff:    RS.W 9984                          ;Buffer für 256 Trace PC+Register
trace_buffend: RS.L 512                           ;Interner Stack
sekbuff:       RS.B 512                           ;Buffer für einen Sektor
drv_table:     RS.L 16                            ;Platz für die Seriennummern von 16 Laufwerken
hires:         RS.B 32000+1280*2+255              ;der Bildschirmspeicher vom Debugger
               RSEVEN
ende:          RS.L 0                             ;Dummy fürs Ende
               ;>RSBSS
               DS.B   __RS
               END
