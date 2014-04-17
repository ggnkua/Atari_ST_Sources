;************************************************************************
;* CBHDINST.SRC - Version 2.4                     26.07.89, 16:00-22:30 *
;*                                            und 01.09.89, 01:00-01:07 *
;*                                            und 11.09.89, 19:50-19:58 *
;*                                            und 20.09.89, 19:33-19:34 *
;*                                            und 16.10.89, 14-16 (CB)  *
;*                                                    1/91 (CB)         *
;* Written by Anton Stepper & Claus Brod in GFA-Basic V2                *
;* OMIKRON.Assembler-Version von Markus Fritze, ‰-soft                  *
;*                                                                      *
;* Vorteile gegenÅber der GFA-Version:                                  *
;*  - schneller (naja, nur bei Media-Change deutlich spÅrbar)           *
;*  - ein ECHTER Kaltstart (Speicher wird komplett gelîscht!)           *
;*  - RSC-Datei im Programm integriert (bei ACCs immer gut)             *
;*  - ERHEBLICH kÅrzer (1/3 bei PrglÑnge, 1/8 (!!!) im Speicher)        *
;*    Die alte Version kostete ~131k RAM, dies ist eindeutig zu viel,   *
;*    der neue Treiber belegt (vernÅnftige) 17k RAM.                    *
;* énderungen der 2.1-Version:                                          *
;*  - Suchen des Treibers bei einer schreibgeschÅtzten Partition geht   *
;*    endlich (toi, toi, toi)                                           *
;* énderungen der 2.2-Version:                                          *
;*  - CBHDINST funktioniert nun auch mit GDOS (falsches intin-Array)    *
;*    Der Treiber belegt nur noch 13´k RAM, das sollte reichen...       *
;* énderungen der 2.3-Version:                                          *
;*  - CBHDINST stÅrzt nicht mehr ab, wenn punptr nicht belegt ist, d.h. *
;*    wenn gar keine Platte angeschlossen ist.                          *
;*  - Verhalten bei Einzel-Parken geÑndert (alle Targets anklickbar)    *
;*  - Fehler beim Alles-Parken behoben, Anpassung an CBHD3.5            *
;*  - Fehler in sel_target entfernt                                     *
;* 2.4:                                                                 *
;*  - lÑût sich in GEMINI per Doppelklick aufrufen                      *
;*  - Anpassung an CBHD3.7 (ACC-Bootlaufwerk)                           *
;************************************************************************
                OUTPUT 'CBHDINST.ACC' ;Der Filename des Programms

prg_start:      bra.s   start0

acc_name:       DC.B '  CBHDINST V2.4',0 ;Name des ACCs

start0:         lea     prg_start-$0100(PC),A0 ;Stack wegen ACC nicht nutzbar (Basepage)
                lea     own_stack(PC),SP ;Eigenen Stack einrichten
                tst.l   $24(A0)         ;ACC oder PRG?
                sne     D0
                move.b  D0,app          ;0=ACC, -1=PRG
                beq.s   start1          ;ACC => kein Setblock

                pea     prg_ende-prg_start+$0100.w ;ProgrammlÑnge
                move.l  A0,-(SP)        ;Basepageadr
                move.l  #$4A0000,-(SP)
                trap    #1              ;MShrink()
                lea     12(SP),SP

start1:         move.l  #appl_init,D0
                bsr     aes             ;appl_init()

                btst    #7,app(PC)      ;ACC oder PRG?
                beq.s   start3          ;schau, schau, ein ACC =>

                bsr     aes_init        ;RSC-Datei an die Auflîsung anpassen

                lea     int_in(PC),A1
                clr.w   (A1)            ;Windowhandle: Desktop
                move.w  #WF_NEWDESK,2(A1) ;neues Fenster 0 (Hintergrund)
                clr.l   4(A1)           ;Default als Objektbaum
                move.l  #wind_set,D0
                bsr     aes

                clr.w   (A1)            ;Windowhandle: Desktop
                move.w  #WF_WORKXYWH,2(A1) ;Arbeitsbereich ermitteln
                move.l  #wind_get,D0
                bsr     aes
                movem.w int_out+2(PC),D1-D4 ;X,Y,W,H
                move.w  #FMD_FINISH,(A1) ;Redraw vom Desktop
                movem.w D1-D4,10(A1)    ;Desktopkoordinaten
                move.l  #form_dial,D0
                bsr     aes             ;form_dial(FMD_FINISH,Desktop)
                bra.s   evnt_loop1      ;PRG direkt starten

start3:         move.w  D0,int_in       ;appl_id
                lea     acc_name(PC),A0
                move.l  A0,addr_in
                move.l  #menu_register,D0
                bsr     aes             ;menu_register()
                bsr     aes_init        ;RSC-Datei an die Auflîsung anpassen

;************************************************************************
;* Hier wartet das ACC nun auf seinen Aufruf...                         *
;************************************************************************
evnt_loop:      lea     evnt_buff(PC),A0
                move.l  A0,addr_in
                move.l  #evnt_mesag,D0
                bsr     aes             ;evnt_mesag()
                cmpi.w  #$4711,(A0)     ;Aufruf von GEMINI?
                beq.s   evnt_loop1
                moveq   #40,D0
                cmp.w   (A0),D0
                bne.s   evnt_loop       ;ACC_OPEN? Nein! =>

;************************************************************************
;* Hier geht's erst richtig los: das ACC wurde aufgerufen               *
;************************************************************************
evnt_loop1:     bsr.s   menu            ;und Programm aufrufen

                btst    #7,app(PC)
                beq.s   evnt_loop       ;wenn ACC, in der Warteschleife bleiben

                move.l  #appl_exit,D0
                bsr     aes             ;Programm abmelden

                clr.w   -(SP)
                trap    #1              ;Pterm0() - und beenden

;************************************************************************
;* Hier beginnt die Verwaltung der Dialogbox                            *
;************************************************************************

menu:           move.w  #1,int_in
                move.l  #wind_update,D0
                bsr     aes             ;wind_update(1) - los geht's
                moveq   #ARROW,D0
                bsr     Defmouse        ;Mausform: Pfeil
menu_loop:      bsr     version         ;Treiberversion in RSC einsetzen
                lea     rsc_tree5(PC),A0
                bsr     do_dialog       ;Dialog ausfÅhren, Button nach D0
                cmp.w   #16,D0          ;ABBRUCH?
                beq.s   menu_exit       ;Nein! =>
                subq.w  #3,D0
                bmi.s   menu_loop       ;CHBD.SYS nîtig?
                cmp.w   #3,D0
                bhi.s   menu_loop1      ;Nein! =>
                tst.b   cbhd_path       ;noch kein Pfad definiert?
                bne.s   menu_loop1      ;Doch =>
                move.w  D0,-(SP)        ;Button-Nummer merken
                bsr.s   set_path        ;Pfad erstmal setzen
                move.w  (SP)+,D0        ;und Button-Nummer wieder zurÅckholen
                tst.b   cbhd_path       ;immer noch kein Pfad?
                beq.s   menu_loop       ;=> dann wieder warten
menu_loop1:     add.w   D0,D0
                move.w  menu_tab(PC,D0.w),D0
                jsr     menu_tab(PC,D0.w) ;Funktion ausfÅhren
                bra.s   menu_loop       ;und wieder in die Hauptschleife...


menu_tab:       DC.W wr_prot-menu_tab,boot_dev-menu_tab
                DC.W ordner_problem-menu_tab,drives-menu_tab
                DC.W do_pfad-menu_tab,dum-menu_tab,dum-menu_tab
                DC.W statistik-menu_tab,make_a_reset-menu_tab,dum-menu_tab
                DC.W park-menu_tab,dum-menu_tab
                DC.W media_all-menu_tab,dum-menu_tab,dum-menu_tab

menu_exit:      clr.w   int_in
                move.l  #wind_update,D0
                bsr     aes             ;wind_update(0) - und nix wie raus =>
dum:            rts                     ;Dummy-RTS

;************************************************************************
;* set_path - CBHD.SYS suchen, evtl. anfragen (mit Dialogbox vorneweg)  *
;************************************************************************

set_path:       lea     get_boot_dev(PC),A0
                bsr     Supexec         ;Bootdevice holen
                add.w   #'A',D0
                lea     cbhd_path(PC),A0
                move.b  D0,(A0)+        ;Treiber auf dem Bootlaufwerk suchen
                move.b  #':',(A0)+
                move.b  #'\',(A0)+
                lea     sys_fname(PC),A1
set_path1:      move.b  (A1)+,(A0)+     ;Filenamen kopieren
                bne.s   set_path1
                move.w  #7,-(SP)
                pea     cbhd_path(PC)
                move.w  #$4E,-(SP)
                trap    #1              ;Fsfirst()
                addq.l  #8,SP
                tst.l   D0              ;Treiber gefunden?
                bpl.s   dum             ;dann wieder raus =>
                lea     rsc_tree6(PC),A0
                bsr     do_dialog

;************************************************************************
;* do_pfad - Pfad des CBHD.SYS mit Fileselector setzen                  *
;************************************************************************

do_pfad:        lea     get_boot_dev(PC),A0
                bsr     Supexec         ;Bootdevice holen
                add.w   #'A',D0
                lea     _buf(PC),A0
                move.l  A0,addr_in      ;Pfad fÅr fsel_input()
                move.b  D0,(A0)+
                lea     sys_path(PC),A1
do_pfad1:       move.b  (A1)+,(A0)+     ;Pfad vervollstÑndigen
                bne.s   do_pfad1
                lea     _buf+256(PC),A0
                move.l  A0,addr_in+4    ;Filename fÅr fsel_input()
                lea     sys_fname(PC),A1
do_pfad2:       move.b  (A1)+,(A0)+     ;Filenamen kopieren
                bne.s   do_pfad2
                move.l  #fsel_input,D0
                bsr     aes             ;Fileselector aufrufen
                move.w  int_out+2(PC),D0
                beq.s   do_pfad_exit    ;ABBRUCH angewÑhlt =>
                lea     _buf(PC),A0
                lea     cbhd_path(PC),A1
do_pfad3:       move.b  (A0)+,(A1)+     ;den gewÑhlten Pfad kopieren
                bne.s   do_pfad3
                subq.l  #1,A1
do_pfad4:       tst.b   -1(A1)
                beq.s   do_pfad_exit    ;der Pfad ist illegal (keiner angegeben)!
                cmpi.b  #'\',-(A1)      ;Ende gefunden?
                bne.s   do_pfad4        ;Nein! =>
                addq.l  #1,A1
                lea     _buf+256(PC),A0
do_pfad5:       move.b  (A0)+,(A1)+     ;Filenamen kopieren
                bne.s   do_pfad5
                rts
do_pfad_exit:   clr.b   cbhd_path       ;Pfad ungÅltig machen
                rts
get_boot_dev:   clr.w   D0
                move.b  $0447.w,D0      ;_bootdev holen
                rts

;************************************************************************
;* show - Titelzeile bei wr_prot, drives, boot_dev anpassen             *
;************************************************************************

show:           movem.l D0-D2/A0-A2,-(SP)
                tst.b   mode            ;Treiber geschÅtzt?
                beq.s   show1           ;Nein! =>
                lea     rsc_string53(PC),A1 ;die Blocknummer anzeigen
                lea     20(A1),A0
                moveq   #5,D2
                move.l  block(PC),D1
                bsr     dez_out         ;Blocknummer einsetzen
                bra.s   show2
show1:          lea     cbhd_path(PC),A1 ;den Pfad anzeigen
show2:          move.l  A1,rsc_ted3
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* Laufwerk schreibschÅtzen                                             *
;************************************************************************

wr_prot:        bsr     check_prot      ;Treiber geschÅtzt?
                beq.s   wr_prot0        ;Nein! =>
                bsr     search_block
                bne     wr_prot_exit    ;CBHD.SYS nicht gefunden, etc. =>
                st      mode            ;Treiber auf geschÅtztem Laufwerk
                move.l  _buf+56(PC),D4  ;neue Laufwerksmaske
wr_prot0:       bsr     set_drives_rsc
                lea     rsc_string52(PC),A1
                move.l  #'Schr',(A1)+
                move.l  #'eibs',(A1)+
                move.l  #'chut',(A1)+
                move.b  #'z',(A1)
                bsr.s   show            ;Pfad oder Blocknummer?
                lea     rsc_tree3(PC),A0
                bsr     do_dialog
                cmp.w   #28,D0          ;ABBRUCH?
                beq.s   wr_prot_exit    ;Ja! =>

                moveq   #0,D7           ;keine Laufwerke erlaubt
                moveq   #27,D2
wr_prot5:       add.l   D7,D7           ;Maske nach links schieben
                move.w  D2,D0
                moveq   #$01,D1         ;selectierten Button suchen
                bsr     is_objc
                beq.s   wr_prot6
                or.w    #1,D7           ;Laufwerk anmelden
wr_prot6:       subq.w  #1,D2
                cmp.w   #1,D2           ;schon alle Laufwerke?
                bne.s   wr_prot5        ;Nein! =>
                cmp.l   D7,D4           ;was geÑndert?
                beq.s   wr_prot_exit    ;Nein! =>
                lea     _buf(PC),A0
                tst.b   mode
                beq.s   wr_prot7
                move.l  D7,56(A0)
                move.l  block(PC),D0    ;Blockadresse
                moveq   #10,D1          ;WRITE SECTOR
                moveq   #1,D2
                moveq   #0,D3
                bsr     mach_schon      ;den Sektor schreiben
                bra.s   wr_prot8
wr_prot7:       move.l  D7,(A0)
                moveq   #56,D0          ;geschÅtzte Laufwerke setzen
                moveq   #4,D1
                bsr     put_file
wr_prot8:       move.l  zg(PC),D0       ;Adresse des CBHD.SYS im RAM holen
                beq.s   wr_prot_exit    ;Treiber nicht da =>
                movea.l D0,A1
                lea     ram_alert(PC),A0
                bsr     do_alert        ;Auch im RAM Ñndern?
                subq.b  #1,D0
                bne.s   wr_prot_exit    ;NEIN! =>
                move.l  D7,2(A1)        ;im RAM Ñndern
wr_prot_exit:   bsr.s   check_prot      ;Treiber geschÅtzt?
                beq.s   wr_prot_exit1   ;Nein! =>
                st      mode            ;Treiber geschÅtzt
wr_prot_exit1:  rts

;************************************************************************
;* Befindet sich der Treiber CBHS.SYS auf einer geschÅtzten Partition?  *
;************************************************************************

check_prot:     lea     clr_cache(PC),A0
                bsr     Supexec         ;den ganzen Cache lîschen
                moveq   #56,D0          ;verwaltete Laufwerke holen
                moveq   #4,D1
                bsr     get_file
                bmi.s   wr_prot_exit
                move.l  _buf(PC),D4     ;geschÅtzte Laufwerke
                sf      mode            ;Treiber auf ungeschÅtztem Laufwerk
                move.b  cbhd_path(PC),D0
                sub.b   #'A',D0
                moveq   #1,D1
                lsl.l   D0,D1
                and.l   D4,D1           ;Treiber auf einem geschÅtzten Laufwerk?
                rts

;************************************************************************
;* 1.Block des Treibers suchen und einlesen                             *
;************************************************************************

search_block:   bsr     sel_target      ;Target & GerÑt auswÑhlen
                tst.w   target
                bmi     search_block_ex
                tst.w   geraet
                bmi     search_block_ex
                bsr     root            ;Partitiontabelle anlegen
                lea     p_start(PC),A1  ;Zeiger auf die Partitiontabelle
                lea     rsc_tree2(PC),A0
                moveq   #2,D0           ;max.12 Partitions
search_block1:  tst.l   (A1)+           ;Parition vorhanden?
                bne.s   search_block2
                moveq   #$08,D1         ;disable
                bsr     do_objc
                bra.s   search_block3
search_block2:  moveq   #$01,D1
                bsr     set_flag
search_block3:  addq.w  #1,D0
                cmp.w   #14,D0
                bne.s   search_block1
                bsr     do_dialog       ;Partition abfragen
                move.w  D0,D7
                lea     p_start(PC),A0
                add.w   D7,D7
                add.w   D7,D7
                tst.l   -8(A0,D7.w)     ;Partition vorhanden?
                beq     search_block_ex ;Nein! =>
                move.b  cbhd_path+1(PC),D1
                cmp.b   #':',D1
                bne.s   search_block5
                move.b  cbhd_path(PC),D0
                sub.b   #'A',D0
search_block5:  bsr     bios            ;BPB lesen
                beq     search_block_ex ;Fehler im BPB
                bsr     nam_conv        ;Filenamen in DIR-Format
                lea     p_start(PC),A0
                move.l  -8(A0,D7.w),D0  ;Startsektor der Partition
                moveq   #0,D1
                move.w  len_fat(PC),D1
                add.l   D1,D1
                add.l   D1,D0           ;2*FAT-LÑnge
                addq.l  #1,D0           ;reservierte Sektoren
                move.l  D0,D3           ;Startsektor des Directories
                moveq   #0,D1
                move.w  len_dir(PC),D1
                add.w   D1,D0
                subq.l  #1,D0
                move.l  D0,D4           ;der letzte Sektor im Directory
search_block6:  move.l  D3,-(SP)
                move.l  D3,D0           ;Blockadresse
                moveq   #8,D1           ;READ SECTOR
                moveq   #1,D2
                moveq   #0,D3
                bsr     mach_schon
                move.l  (SP)+,D3
                lea     _buf(PC),A0
                moveq   #15,D5          ;16 Files pro Sektor
search_block8:  lea     name_buffer(PC),A1 ;* Hier war der Fehler, A1 lief weg...
                movem.l (A0),D0-D2      ;12 Byte holen
                clr.b   D2              ;das 12.Byte lîschen
                cmp.l   (A1)+,D0
                bne.s   search_block7
                cmp.l   (A1)+,D1
                bne.s   search_block7
                cmp.l   (A1)+,D2
                beq.s   search_block4
search_block7:  lea     32(A0),A0
                dbra    D5,search_block8
                addq.l  #1,D3           ;INC Block%
                cmp.l   D4,D3
                bls.s   search_block6
                bra.s   search_block_ex ;Nix gefunden => raus =>
search_block4:  moveq   #0,D0
                movep.w 27(A0),D0
                move.b  26(A0),D0       ;Clusternummer holen
                move.w  D0,cl
                subq.l  #2,D0
                mulu    spc(PC),D0      ;mal Sektoren pro Cluster
                add.w   first_sec(PC),D0
                move.l  D0,lgs
                lea     p_start(PC),A0
                add.l   -8(A0,D7.w),D0  ;+ Startsektor der Partition
                move.l  D0,block
                moveq   #8,D1           ;READ SECTOR
                moveq   #1,D2
                moveq   #0,D3
                bsr     mach_schon      ;Block lesen
                moveq   #0,D0
                rts
search_block_ex:moveq   #-1,D0
                rts

;************************************************************************
;* Routine zum AuswÑhlen von Target & GerÑt                             *
;************************************************************************

sel_target:     moveq   #HOURGLASS,D0
                bsr     Defmouse
                lea     tg_table(PC),A3
                move.l  #512,_buf2      ;Blockgrîûe auf 512 Byte setzen
                clr.w   target
sel_target1:    clr.w   geraet
sel_target2:    moveq   #0,D0           ;Block 0
                moveq   #8,D1           ;Read Sector
                moveq   #1,D2           ;Sektoranzahl
                moveq   #0,D3           ;Kontrollbyte
                bsr     mach_schon
                sf      (A3)+
                btst    #1,D0           ;DMA-Fehler?
                bne.s   sel_target3     ;Ja! =>
                tst.l   D1              ;Timeout?
                bne.s   sel_target3     ;Ja! =>
                cmp.l   #512,D2         ;512 Bytes gelesen?
                bne.s   sel_target3     ;Nein! =>
                st      -1(A3)
sel_target3:    addq.w  #1,geraet
                cmpi.w  #2,geraet
                bne.s   sel_target2
                addq.w  #1,target
                cmpi.w  #8,target
                bne.s   sel_target1
                move.w  #ARROW,D0
                bsr     Defmouse

                moveq   #0,D3
                lea     tg_table(PC),A3
                lea     rsc_tree1(PC),A0
sel_target5:    moveq   #4,D0
                add.w   D3,D0
                moveq   #$45,D1
                tst.w   (A3)+
                bne.s   sel_target6
                bsr     del_flag        ;disable
                moveq   #8,D1
                bsr     do_objc
                bra.s   sel_target7
sel_target6:    bsr     set_flag        ;enable
                moveq   #8,D1
                bsr     undo_objc
sel_target7:    addq.w  #1,D3
                cmp.w   #8,D3
                bne.s   sel_target5

                move.w  #-1,target
                lea     rsc_string0(PC),A0
                move.l  #'Targ',(A0)+
                move.w  #'et',(A0)
                lea     rsc_tree1(PC),A0
                bsr     do_dialog
                subq.w  #4,D0
                bmi.s   sel_target_exit
                move.w  D0,target

                lea     tg_table(PC),A3
                add.w   D0,D0           ;Target*2 (da 2 GerÑte pro Target!)
                adda.w  D0,A3
                moveq   #0,D3
                lea     rsc_tree1(PC),A0
sel_target8:    moveq   #4,D0
                add.w   D3,D0
                moveq   #$45,D1
                tst.b   (A3)+
                bne.s   sel_target9
                bsr     del_flag        ;disable
                moveq   #8,D1
                bsr     do_objc
                bra.s   sel_target4
sel_target9:    bsr     set_flag        ;enable
                moveq   #8,D1
                bsr     undo_objc

sel_target4:    addq.w  #1,D3
                cmp.w   #2,D3
                bne.s   sel_target8
sel_target0:    moveq   #4,D0
                add.w   D3,D0
                moveq   #$45,D1
                bsr     del_flag
                moveq   #8,D1
                bsr     do_objc
                addq.w  #1,D3
                cmp.w   #8,D3
                bne.s   sel_target0

                move.w  #-1,geraet
                lea     rsc_string0(PC),A0
                move.l  #'GerÑ',(A0)+
                move.w  #'t ',(A0)
                lea     rsc_tree1(PC),A0
                bsr     do_dialog
                subq.w  #4,D0
                bmi.s   sel_target_exit
                move.w  D0,geraet
sel_target_exit:rts

;************************************************************************
;* get_file(D0:Byte%,D1:B_anz%) - Byte aus dem Treiber lesen            *
;************************************************************************

get_file:       movem.l D0-D4/A0,-(SP)
                move.l  D0,D3           ;Byte (Offset)
                move.l  D1,D4           ;Anzahl
                moveq   #0,D0
                lea     cbhd_path(PC),A0
                bsr     fopen           ;Fopen()
                bmi.s   get_file_err
                moveq   #54,D0          ;Offset
                bsr     fseek0
                bmi.s   get_file_err
                lea     _buf(PC),A0
                moveq   #2,D0
                bsr     fread           ;Version holen
                bmi.s   get_file_err
                move.w  (A0),D0
                cmp.w   #'29',D0
                bhs.s   get_file2       ;>=V2.9 =>
                moveq   #100,D0
                bsr     fseek0          ;100 Bytes Dateianfang Åberspringen
                bmi.s   get_file_err
                moveq   #50,D0
                bsr     fread           ;und 50 Bytes einlesen
                bmi.s   get_file_err
                moveq   #12,D0
get_file1:      cmpi.l  #'XBRA',(A0)+   ;XBRACBHD suchen
                dbeq    D0,get_file1
                bne.s   get_file_err
                cmpi.l  #'CBHD',(A0)    ;Treiber erkannt?
                bne.s   get_file_err    ;Nein! =>
                bra.s   get_file3
get_file2:      moveq   #84,D0          ;Hier ab Treiber 2.9
                bsr     fseek0
                bmi.s   get_file_err
                moveq   #4,D0
                bsr     fread           ;und 4 Bytes einlesen
                bmi.s   get_file_err
                cmpi.l  #'CBHD',(A0)    ;Treiber erkannt?
                bne.s   get_file_err    ;Nein! =>
get_file3:      move.l  D3,D0
                bsr     fseek0          ;Dateipointer auf das Byte
                lea     _buf(PC),A0
                move.l  D4,D0
                bsr     fread           ;Bytes einlesen
                moveq   #0,D1
                bra.s   get_file_exit
get_file_err:   lea     treiber_alert(PC),A0
                bsr     do_alert
                moveq   #-1,D1
get_file_exit:  bsr     fclose          ;Datei, wenn nîtig, wieder schlieûen
                tst.w   D1
                movem.l (SP)+,D0-D4/A0
                rts

;************************************************************************
;* put_file(D0:Byte%,D1:B_anz%) - Byte in den Treiber schreiben         *
;************************************************************************

put_file:       movem.l D0-D4,-(SP)
                move.l  D0,D3
                move.l  D1,D4
                moveq   #2,D0
                lea     cbhd_path(PC),A0
                bsr     fopen           ;Datei îffnen
                move.l  D3,D0
                bsr     fseek0          ;Schreibpointer setzen
                lea     _buf(PC),A0
                move.l  D4,D0
                bsr     fwrite          ;Bytes schreiben
                bsr     fclose          ;und Datei wieder schlieûen
                movem.l (SP)+,D0-D4
boot_dev_exit:
                rts

;************************************************************************
;* Boot-Device setzen                                                   *
;************************************************************************

boot_dev:       lea     rsc_tree3(PC),A0
                moveq   #2,D0
boot_dev1:      moveq   #$11,D1         ;alle selectable + Radio
                bsr     set_flag
                moveq   #$09,D1         ;keines selected, aber selectable
                bsr     undo_objc
                addq.w  #1,D0
                cmp.w   #28,D0
                bne.s   boot_dev1

                moveq   #64,D0          ;Bootlaufwerk holen
                moveq   #2,D1
                bsr     get_file
                bmi.s   boot_dev_exit

                move.w  _buf(PC),D0
                addq.w  #2,D0
                moveq   #$01,D1
                bsr     do_objc         ;Bootdevice selectieren
                bsr     show            ;Pfad oder Blocknummer?

                lea     rsc_string52(PC),A1
                move.l  #' Boo',(A1)+
                move.l  #'tlau',(A1)+
                move.l  #'fwer',(A1)+
                move.b  #'k',(A1)+

                bsr     do_dialog
                cmp.w   #28,D0          ;ABBRUCH?
                beq.s   boot_dev_exit   ;Ja! =>

                moveq   #2,D2
boot_dev2:      move.w  D2,D0
                moveq   #$01,D1         ;selectierten Button suchen
                bsr     is_objc
                bne.s   boot_dev3
                addq.w  #1,D2
                bra.s   boot_dev2
boot_dev3:      subq.w  #2,D2
                move.w  D2,_buf         ;Bootlaufwerk merken
                moveq   #64,D0          ;und setzen
                moveq   #2,D1
                bsr     put_file

;************************************************************************
;* ACC-Boot-Device setzen                                               *
;************************************************************************

accbdev:        lea     rsc_tree3(PC),A0
                moveq   #2,D0
accbdv1:        moveq   #$11,D1         ;alle selectable + Radio
                bsr     set_flag
                moveq   #$09,D1         ;keines selected, aber selectable
                bsr     undo_objc
                addq.w  #1,D0
                cmp.w   #28,D0
                bne.s   accbdv1

                moveq   #72,D0          ;Bootlaufwerk holen
                moveq   #2,D1
                bsr     get_file
                bmi.s   accexit

                move.w  _buf(PC),D0
                addq.w  #2,D0
                moveq   #$01,D1
                bsr     do_objc         ;Bootdevice selectieren
                bsr     show            ;Pfad oder Blocknummer?

                lea     rsc_string52(PC),A1
                move.l  #' ACC',(A1)+
                move.l  #'-Lau',(A1)+
                move.l  #'fwer',(A1)+
                move.b  #'k',(A1)+

                bsr     do_dialog
                cmp.w   #28,D0          ;ABBRUCH?
                beq.s   accexit         ;Ja! =>

                moveq   #2,D2
accbdev2:       move.w  D2,D0
                moveq   #$01,D1         ;selectierten Button suchen
                bsr     is_objc
                bne.s   accbdev3
                addq.w  #1,D2
                bra.s   accbdev2
accbdev3:       subq.w  #2,D2
                move.w  D2,_buf         ;Bootlaufwerk merken
                moveq   #72,D0          ;und setzen
                moveq   #2,D1
                bsr     put_file
accexit:        rts

;************************************************************************
;* Ordner-Problem                                                       *
;************************************************************************

ordner_problem: moveq   #66,D0          ;Ordneranzahl holen
                moveq   #2,D1
                bsr     get_file
                bmi.s   ordner_pro_exit

                lea     rsc_string54(PC),A0
                moveq   #0,D1
                move.w  _buf(PC),D1     ;Ordneranzahl
                moveq   #5,D2
                bsr     dez_out         ;in die RSC
                clr.b   (A0)            ;den Rest lîschen

                bsr     mifl
                lea     rsc_string62a(PC),A0
                move.l  D0,D1
                bmi.s   ordner_pro1
                asr.l   #1,D1           ;ein Ordner belegt 2 EintrÑge
                moveq   #5,D2
                bsr     dez_out
                bra.s   ordner_pro2
ordner_pro1:    move.l  #'??? ',(A0)+
ordner_pro2:    clr.b   (A0)
                lea     rsc_tree4(PC),A0
                bsr     do_dialog
                cmp.w   #3,D0           ;OK?
                bne.s   ordner_pro_exit ;Nein! =>
                lea     rsc_string54(PC),A0
                bsr     dez_in          ;Dezimalzahl holen
                cmp.w   _buf(PC),D0     ;Ordneranzahl gleich?
                beq.s   ordner_pro_exit ;dann raus =>
                move.w  D0,_buf
                moveq   #66,D0          ;neue Ordneranzahl schreiben
                moveq   #2,D1
                bsr     put_file
ordner_pro_exit:rts

;************************************************************************
;* verwaltete Laufwerk Ñndern                                           *
;************************************************************************

drives:         moveq   #60,D0          ;verwaltete Laufwerke holen
                moveq   #4,D1
                bsr     get_file
                bmi.s   ordner_pro_exit
                move.l  _buf(PC),D4     ;Laufwerksmaske
                bsr.s   set_drives_rsc  ;RSC setzen

                lea     rsc_string52(PC),A1
                move.l  #'Lauf',(A1)+
                move.l  #'werk',(A1)+
                move.l  #'e   ',(A1)+
                move.b  #' ',(A1)
                bsr     show            ;Pfad oder Blocknummer?

                bsr     do_dialog
                cmp.w   #28,D0          ;ABBRUCH?
                beq.s   drives_exit     ;Ja! =>

                moveq   #0,D3           ;keine Laufwerke erlaubt
                moveq   #27,D2
drives5:        add.l   D3,D3           ;Maske nach links schieben
                move.w  D2,D0
                moveq   #$01,D1         ;selectierten Button suchen
                bsr     is_objc
                beq.s   drives6
                or.w    #1,D3           ;Laufwerk anmelden
drives6:        subq.w  #1,D2
                cmp.w   #1,D2           ;schon alle Laufwerke?
                bne.s   drives5         ;Nein! =>
                cmp.l   D3,D4           ;was geÑndert?
                beq.s   drives_exit     ;Nein! =>
                move.l  D3,_buf
                moveq   #60,D0          ;verwaltete Laufwerke setzen
                moveq   #4,D1
                bsr     put_file
drives_exit:    rts
get_punptr:     move.l  $0516.w,D0
                rts

;************************************************************************
;* Laufwerke in der RSC enablen, disablen bzw. selecten                 *
;************************************************************************

set_drives_rsc: lea     get_punptr(PC),A0
                bsr     Supexec
                tst.l   D0
                bne.s   set_drives_rsc0
                moveq   #2,D0
                lea     rsc_tree3(PC),A0
                bra.s   set_drives_rsc9

set_drives_rsc0:addq.l  #2,D0
                movea.l D0,A3           ;Zeiger auf die verwalteten Laufwerke
                move.l  D4,D2
                lea     rsc_tree3(PC),A0
                moveq   #2,D0
set_drives_rsc1:moveq   #8,D1
                move.b  (A3)+,D3        ;vom Treiber verwaltet?
                addq.b  #1,D3
                bne.s   set_drives_rsc2 ;Nein! =>
                bsr     do_objc
                bra.s   set_drives_rsc5
set_drives_rsc2:bsr     undo_objc
set_drives_rsc5:moveq   #$10,D1
                bsr     del_flag        ;keine Radio-Buttons
                moveq   #$01,D1
                lsr.l   #1,D2           ;Laufwerk vorhanden?
                bcs.s   set_drives_rsc3 ;Ja! =>
                bsr     undo_objc       ;deselect
                bra.s   set_drives_rsc4
set_drives_rsc3:bsr     do_objc         ;select
set_drives_rsc4:addq.w  #1,D0
                cmp.w   #18,D0          ;schon alle Laufwerke?
                bne.s   set_drives_rsc1 ;Nein! =>

set_drives_rsc9:moveq   #$10,D1
                bsr     del_flag
                moveq   #1,D1
                bsr     del_flag
                moveq   #1,D1
                bsr     undo_objc
                moveq   #8,D1
                bsr     do_objc
                addq.w  #1,D0
                cmp.w   #28,D0
                bne.s   set_drives_rsc9
                rts

;************************************************************************
;* Dialog fÅr Platte(n) parken                                          *
;************************************************************************

park:           clr.b   rsc_string88    ;Den String lîschen
                lea     rsc_tree7(PC),A0
                moveq   #2,D0
                moveq   #1,D1
                bsr     do_objc         ;PARKEN
                moveq   #3,D0
                bsr     undo_objc       ;RE-PARKEN
                bsr     box_draw
                move.l  A0,addr_in
                clr.w   int_in
                move.l  #form_do,D0
                bsr     aes
                and.w   #$7FFF,D0       ;Doppelklick-Bit lîschen
                move.w  D0,D7           ;Exit-Button merken
                cmp.w   #6,D7           ;ABBRUCH?
                beq     park_exit0      ;Ja! =>

                moveq   #1,D2           ;Entparken
                moveq   #2,D0
                moveq   #1,D1
                lea     rsc_tree7(PC),A0
                bsr     is_objc         ;Parken selectiert?
                beq.s   park2           ;nein
                moveq   #0,D2           ;Parken
park2:          cmp.w   #5,D7           ;Single Parken?
                bne.s   park3
                bsr.s   park_exit0      ;Box lîschen
                bra     park_single     ;Parken einzeln

park3:          moveq   #HOURGLASS,D0
                bsr     Defmouse
                clr.w   target
                move.w  D2,-(SP)
park4:          clr.w   geraet
park5:          lea     rsc_string88(PC),A0
                move.b  #'T',(A0)
                move.w  target(PC),D0
                or.b    #'0',D0
                move.b  D0,7(A0)
                move.w  geraet(PC),D0
                or.b    #'0',D0
                move.b  D0,15(A0)
                lea     rsc_tree7(PC),A0
                moveq   #7,D0
                bsr     objc_update
                move.w  (SP),D2
                moveq   #$1B,D1         ;Opcode: START/STOP UNIT
                moveq   #0,D0           ;Blocknr: 0
                moveq   #0,D3           ;Sektoranzahl: 0 (Parkenflag in D2)
                bsr     mach_schon
                addq.w  #1,geraet
                cmpi.w  #2,geraet
                bne.s   park5
                addq.w  #1,target
                cmpi.w  #8,target
                bne.s   park4
                move.w  (SP)+,D2
                moveq   #ARROW,D0
                bsr     Defmouse
park_exit0:     lea     rsc_tree7(PC),A0
                bsr     box_undraw
                moveq   #1,D1
                move.w  D7,D0
                bsr     undo_objc       ;EXIT-Button deselectieren
park_exit:      rts

;************************************************************************
;* eine Platte parken                                                   *
;************************************************************************

park_single:    lea     tg_table(PC),A0
                moveq   #15,D0
park_single1:   st      (A0)+
                dbra    D0,park_single1

park_single2:   move.w  #-1,target
                move.w  #-1,geraet
                moveq   #0,D3
                lea     tg_table(PC),A3
                lea     rsc_tree1(PC),A0
                bsr     sel_target5

                tst.w   geraet
                bmi.s   park_single_exi
                tst.w   target
                bmi.s   park_single_exi

                moveq   #$1B,D1         ;Opcode: START/STOP UNIT
                moveq   #0,D0           ;Blocknr: 0
                moveq   #0,D3           ;Sektoranzahl: 0 (Parkenflag in D2)
                bsr     mach_schon
                bra.s   park_single2
park_single_exi:rts

;************************************************************************
;* Statistik der Platte anzeigen                                        *
;************************************************************************

statistik:      bsr     sel_target      ;Target & GerÑt wÑhlen
                tst.w   target
                bmi     statistik_exit
                tst.w   geraet
                bmi     statistik_exit
                moveq   #$11,D1         ;Opcode: READ USAGE COUNTER
                moveq   #0,D0           ;Blocknr: 0
                moveq   #0,D2           ;Kontrollflag: 0
                moveq   #0,D3           ;Sektoranzahl: 0
                bsr     mach_schon      ;HDC-Command ausfÅhren
                bsr     mifl
                lea     rsc_string102(PC),A0
                move.l  D0,D1
                bmi.s   statistik1
                asr.l   #1,D1           ;ein Ordner belegt 2 EintrÑge
                addq.l  #1,A0
                moveq   #5,D2
                bsr     dez_out
                bra.s   statistik2
statistik1:     move.l  #' ???',(A0)+
statistik2:     clr.b   (A0)
                lea     rsc_string95+1(PC),A0
                moveq   #0,D1
                move.w  _buf2(PC),D1
                lsl.l   #8,D1
                add.b   _buf2+2(PC),D1
                moveq   #7,D2
                bsr     dez_out         ;SektorlesezÑhler ausgeben
                clr.b   (A0)
                lea     rsc_string96+1(PC),A0
                moveq   #0,D1
                move.b  _buf2+3(PC),D1
                swap    D1
                move.w  _buf2+4(PC),D1
                moveq   #7,D2
                bsr     dez_out         ;SuchzÑhler ausgeben
                clr.b   (A0)
                lea     rsc_string97+1(PC),A0
                moveq   #0,D1
                move.b  _buf2+6(PC),D1
                moveq   #7,D2
                bsr     dez_out         ;Nicht korrigierbare Datenfehler ausgeben
                clr.b   (A0)
                lea     rsc_string98+1(PC),A0
                moveq   #0,D1
                move.b  _buf2+7(PC),D1
                moveq   #7,D2
                bsr     dez_out         ;Korrigierbare Datenfehler ausgeben
                clr.b   (A0)
                lea     rsc_string99+1(PC),A0
                moveq   #0,D1
                move.b  _buf2+8(PC),D1
                moveq   #7,D2
                bsr     dez_out         ;Fehler beim Suchen ausgeben
                clr.b   (A0)
                lea     rsc_tree8(PC),A0
                bsr     do_dialog       ;Dialogbox ausfÅhren
statistik_exit: rts

;************************************************************************
;* Anzahl der freien "Ordner" ermitteln                                 *
;************************************************************************

mifl:           lea     get_mifl(PC),A0
                bra     Supexec

get_mifl:       lea     $56FA.w,A1      ;mifl bei TOS 1.0 (06.02.86)
                movea.l $04F2.w,A0
                cmpi.w  #$0100,2(A0)
                beq.s   get_mifl1
                movea.l 32(A0),A1       ;mifl ab dem Blitter-TOS
get_mifl1:      lea     16(A1),A1       ;Next%
                moveq   #0,D0           ;CLR Cnt%
get_mifl2:      move.l  A1,D1           ;WHILE Next%>0?
                ble.s   get_mifl3       ;Nein! => raus =>
                addq.l  #1,D0           ;INC Cnt%
                movea.l (A1),A1         ;Next%=LPEEK(Next%)
                bra.s   get_mifl2       ;WEND
get_mifl3:      cmpi.w  #$0104,2(A0)    ;TOS 1.4 (oder noch "neuer")?
                blo.s   get_mifl4       ;Nein! =>
                moveq   #-1,D0          ;Cnt%=-1
get_mifl4:      rts

;************************************************************************
;* Media-Change auf allen Laufwerken                                    *
;************************************************************************

media_all:      lea     media_alert(PC),A0
                bsr     do_alert        ;Sicherheitsabfrage
                subq.w  #2,D0
                bne.s   media_all_exit  ;Abbruch =>
                moveq   #HOURGLASS,D0
                bsr     Defmouse
                moveq   #31,D3          ;Media-Change auf allen max.32 Drives
media_all1:     move.w  D3,D0
                bsr     do_media_change ;Media-Change durchfÅhren
                dbra    D3,media_all1
                moveq   #ARROW,D0
                bsr     Defmouse
media_all_exit: rts

;************************************************************************
;* RESET durchfÅhren                                                    *
;************************************************************************

make_a_reset:   lea     reset_alert(PC),A0
                bsr     do_alert        ;Sicherheitsabfrage
                subq.w  #2,D0
                bgt.s   make_a_reset_ex ;kein RESET
                lea     reset_warm(PC),A0
                bmi.s   make_a_reset1
                lea     cold_boot(PC),A0
make_a_reset1:  bra     Supexec

reset_warm:     move    #$2700,SR       ;ein Warmstart
                movea.l 4.w,A0
                jmp     (A0)

cold_boot:      move    #$2700,SR       ;ein ECHTER Kaltstart
                lea     cold_boot2(PC),A0
                moveq   #13,D0
                lea     8.w,A1
cold_boot1:     move.l  (A0)+,(A1)+
                dbra    D0,cold_boot1
                jmp     8.w
cold_boot2:     lea     warm_boot(PC),A0
                move.l  A0,8.w
                lea     clr_from_here(PC),A0
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
cold_boot3:     movem.l D0-D7/A1-A6,(A0) ;den Speicher komplett lîschen
                lea     $38(A0),A0
                bra.s   cold_boot3
warm_boot:      movea.l 4.w,A0
                jmp     (A0)
clr_from_here:

make_a_reset_ex:rts

;************************************************************************
;* Rootsektor einlesen                                                  *
;************************************************************************

root:           moveq   #8,D1           ;READ SECTOR
                moveq   #0,D0           ;Block 0
                moveq   #1,D2           ;einen Sektor
                moveq   #0,D3           ;Kontrollbyte
                bsr     mach_schon
                lea     p_start(PC),A0
                lea     _buf+$01C6(PC),A1
                moveq   #3,D0           ;die ersten 4 Partitions testen
root1:          moveq   #0,D2
                move.l  (A1)+,D1
                and.l   #$01FFFFFF,D1
                cmp.l   #'GEM',D1      ;aktive GEM-Partition?
                bne.s   root2           ;Nein! =>
                move.l  (A1),D2
root2:          move.l  D2,(A0)+        ;Startsektor der Partition
                addq.l  #8,A1
                dbra    D0,root1
                lea     _buf+$0152(PC),A1
                cmpi.l  #'CBHD',(A1)+
                seq     D3
                moveq   #7,D0           ;nochmals 8 weitere Partitions testen
root3:          moveq   #0,D2
                move.l  (A1)+,D1
                and.l   #$01FFFFFF,D1
                cmp.l   #'GEM',D1      ;aktive GEM-Partition?
                bne.s   root4           ;Nein! =>
                tst.b   D3              ;erweitert?
                beq.s   root4           ;Nein! =>
                move.l  (A1),D2
root4:          move.l  D2,(A0)+        ;Startsektor der Partition
                addq.l  #8,A1
                dbra    D0,root3
                rts

;************************************************************************
;* BPB-Daten holen                                                      *
;************************************************************************

bios:           move.w  D0,-(SP)
                move.w  #7,-(SP)
                trap    #13             ;Getbpb()
                addq.l  #4,SP
                tst.l   D0
                beq.s   bios1
                movea.l D0,A0
                move.w  2(A0),spc
                move.w  6(A0),len_dir
                move.w  8(A0),len_fat
                move.w  10(A0),fat_anf
                move.w  12(A0),first_sec
                moveq   #-1,D0
bios1:          rts

;************************************************************************
;* den ganzen Cache lîschen                                             *
;************************************************************************

clr_cache:      movea.l $04B2.w,A0      ;Sector-BCB freigeben
                moveq   #-1,D1
clr_cache1:     move.l  A0,D0
                beq.s   clr_cache2
                tst.w   10(A0)          ;Daten noch nicht geschrieben? (b_dirty)
                bne.s   clr_cache5      ;dann nicht freigeben! =>
                move.w  D1,4(A0)        ;Cache-Eintrage freigeben (b_bufdrv)
clr_cache5:     movea.l (A0),A0         ;n_link
                bra.s   clr_cache1
clr_cache2:     movea.l $04B6.w,A0      ;Dir & FAT-BCB freigeben
clr_cache3:     move.l  A0,D0
                beq.s   clr_cache4
                tst.w   10(A0)          ;Daten noch nicht geschrieben? (b_dirty)
                bne.s   clr_cache6      ;dann nicht freigeben! =>
                move.w  D1,4(A0)        ;Cache-Eintrage freigeben (b_bufdrv)
clr_cache6:     movea.l (A0),A0         ;n_link
                bra.s   clr_cache3
clr_cache4:     rts

;************************************************************************
;* mach_schon() - Plattentreiber aufrufen                               *
;* D0 - Blocknummer                                                     *
;* D1 - Opcode                                                          *
;* D2 - Sektoranzahl                                                    *
;* D3 - Kontrollbyte                                                    *
;* D0 - Status                                                         *
;* D1 - Timeoutflag                                                    *
;* D2 - Åbertragene Bytes                                              *
;************************************************************************

mach_schon:     lea     comblock(PC),A0
                move.l  D0,(A0)         ;Blocknr setzen
                andi.w  #$1F,(A0)
                move.b  D1,(A0)         ;Opcode setzen
                move.w  target(PC),D0
                lsl.w   #5,D0
                or.b    D0,(A0)         ;Target einsetzen
                move.w  geraet(PC),D0
                lsl.w   #5,D0
                or.b    D0,1(A0)        ;GerÑt einsetzen
                move.b  D2,4(A0)        ;Sektoranzahl
                move.b  D3,5(A0)        ;Kontrollbyte
                bsr     Hdread          ;HDC ansprechen
                move.l  status(PC),D0   ;Status
                move.l  timeflag(PC),D1 ;Timeoutflag
                move.l  dmaend(PC),D2
                sub.l   buffer(PC),D2   ;Anzahl der Åbertragenen Bytes
                rts

;************************************************************************
;* nam_conv - Namen in DIR-Format wandeln                               *
;************************************************************************

nam_conv:       lea     cbhd_path(PC),A1
nam_conv1:      tst.b   (A1)+           ;Ende des Pfades suchen
                bne.s   nam_conv1
                subq.l  #1,A1
nam_conv3:      tst.b   -1(A1)          ;Anfang wieder erreicht?
                beq.s   nam_conv2       ;Ja! =>
                cmpi.b  #'\',-(A1)      ;Pfadende gefunden
                bne.s   nam_conv3       ;Nein! =>
                addq.l  #1,A1
nam_conv2:      lea     name_buffer(PC),A0
                move.l  #'    ',D0
                move.l  D0,(A0)
                move.l  D0,4(A0)        ;Filenamen lîschen
                move.l  D0,8(A0)
                clr.b   11(A0)
                moveq   #0,D1
nam_conv5:      move.b  (A1)+,D0
                beq.s   nam_conv4       ;Ende des Namens
                cmp.b   #'.',D0         ;Extension erreicht?
                bne.s   nam_conv6       ;Nein! =>
                moveq   #8,D1           ;Zeiger auf die Extension
                bra.s   nam_conv5       ;den '.' ignorieren
nam_conv6:      move.b  D0,0(A0,D1.w)   ;Zeichen umkopieren
                addq.w  #1,D1
                bra.s   nam_conv5
nam_conv4:      rts

;************************************************************************
;* Hier beginnen nun allgemeine Library-Funktionen                      *
;************************************************************************
;************************************************************************
;* GEMDOS-Funktionen: fopen,fclose,fread,fwrite,fseek, sowie err_inf    *
;************************************************************************

;************************************************************************
;* Fopen(Fname=A0,Mode=D0)                                              *
;************************************************************************
fopen:          movem.l D0-D2/A0-A2,-(SP)
                move.w  D0,-(SP)
                move.l  A0,-(SP)
                move.w  #$3D,-(SP)
                trap    #1              ;Fopen()
                addq.l  #8,SP
                lea     fopen_err(PC),A0
                bsr     err_inf
                move.w  D0,fhandle      ;Datei-Handle merken
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* Fclose() - offene Datei schlieûen                                    *
;************************************************************************
fclose:         movem.l D0-D2/A0-A2,-(SP)
                move.w  fhandle(PC),D0
                bmi.s   fclose1         ;Datei ist nicht offen =>
                move.w  D0,-(SP)
                move.w  #$3E,-(SP)
                trap    #1              ;Fclose()
                addq.l  #4,SP
                lea     fclose_err(PC),A0
                bsr     err_inf
fclose1:        move.w  #-1,fhandle
                tst.w   D0
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* Fread(Buffer=A0, Bytes=D0) - Daten aus einer Datei lesen             *
;************************************************************************
fread:          movem.l D0-D2/A0-A2,-(SP)
                move.w  fhandle(PC),D1
                bmi.s   fread1          ;Datei ist nicht offen =>
                move.l  A0,-(SP)
                move.l  D0,-(SP)
                move.w  D1,-(SP)
                move.w  #$3F,-(SP)
                trap    #1              ;Fread()
                lea     12(SP),SP
                lea     fread_err(PC),A0
                bsr.s   err_inf
fread1:         tst.w   D0
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* Fwrite(Buffer=A0, Bytes=D0) - Daten in eine Datei schreiben          *
;************************************************************************
fwrite:         movem.l D0-D2/A0-A2,-(SP)
                move.w  fhandle(PC),D1
                bmi.s   fwrite1         ;Datei ist nicht offen =>
                move.l  A0,-(SP)
                move.l  D0,-(SP)
                move.w  D1,-(SP)
                move.w  #$40,-(SP)
                trap    #1              ;Fwrite()
                lea     12(SP),SP
                lea     fwrite_err(PC),A0
                bsr.s   err_inf
fwrite1:        tst.w   D0
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* Fseek(Offset=D0,Modus=D1) - Dateipointer neu setzen                  *
;************************************************************************
fseek0:         moveq   #0,D1           ;Modus=0
                movem.l D0-D2/A0-A2,-(SP)
                move.w  fhandle(PC),D2
                bmi.s   fseek1          ;Datei ist nicht offen =>
                move.w  D1,-(SP)
                move.w  D2,-(SP)
                move.l  D0,-(SP)
                move.w  #$42,-(SP)
                trap    #1              ;Fseek()
                lea     10(SP),SP
                lea     fseek_err(PC),A0
                bsr.s   err_inf
fseek1:         tst.w   D0
                movem.l (SP)+,D0-D2/A0-A2
                rts

;************************************************************************
;* err_inf(Text=A0,Fehler=D0) - GEMDOS-Funktion auf Fehler testen       *
;************************************************************************
err_inf:        movem.l D1-D2/A0-A2,-(SP)
                tst.l   D0              ;ein Fehler?
                bpl.s   err_inf1        ;Nein! =>
                movea.l A0,A1
                lea     gemdos_no(PC),A0
                move.w  D0,D1
                neg.w   D1
                moveq   #1,D2           ;2 Stellen
                bsr.s   dez_out         ;Fehlernummer ausgeben
                lea     gemdos_err(PC),A0
err_inf3:       tst.b   (A1)            ;Fehlertext einsetzen
                beq.s   err_inf2
                move.b  (A1)+,(A0)+
                bra.s   err_inf3
err_inf2:       lea     gemdos_alert(PC),A0
                bsr.s   do_alert
                moveq   #-1,D0          ;Fehlernummer lîschen
err_inf1:       movem.l (SP)+,D1-D2/A0-A2
                rts

;************************************************************************
;* do_alert() - form_alert ab A0 ausfÅhren                              *
;************************************************************************

do_alert:       move.l  A0,addr_in
                move.w  #1,int_in       ;Default-Button: 1
                move.l  #form_alert,D0
                bra     aes

;************************************************************************
;* positive Dezimal-Zahl ab A0 nach D0 holen                            *
;************************************************************************

dez_in:         move.l  D1,-(SP)
                moveq   #0,D0           ;Dezimalzahl lîschen
dez_in1:        moveq   #0,D1
                move.b  (A0)+,D1
                beq.s   dez_in_exit     ;Ende der Eingabe =>
                sub.w   #'0',D1
                bmi.s   dez_in_exit     ;keine Dez-Zahl
                cmp.w   #10,D1
                bhs.s   dez_in_exit     ;keine Dez-Zahl
                mulu    #10,D0
                add.w   D1,D0
                bra.s   dez_in1
dez_in_exit:    move.l  (SP)+,D1
                rts

;************************************************************************
;* positive Dezimal-Zahl in D1 ohne FÅhrungsnullen ausgeben             *
;* max.Anzahl der Stellen minus 1 in D2                                 *
;************************************************************************

dez_out:        movem.l D0-D5/A1,-(SP)
                lea     dez_tab(PC),A1  ;Zeiger auf die Tabelle (s.u.)
                move.w  D2,D0           ;Anzahl der Stellen-1 (fÅr DBRA -1)
                add.w   D0,D0
                add.w   D0,D0           ;mal 4 (schneller als LSL.W #2,D5 !)
                lea     4(A1,D0.w),A1   ;Tabellenzeiger auf die Stellenzahl
                moveq   #0,D4           ;fÅhrende Nullen ignorieren
dez_out1:       move.l  -(A1),D3        ;Wert aus der Tabelle holen
                moveq   #-'0',D0        ;wird zu -'1',-'2',-'3', ...
dez_out2:       sub.l   D3,D1           ;Tabellenwert bis zum Unterlauf abziehen
                dbcs    D0,dez_out2     ;Unterlauf? Nein! =>
                neg.w   D0              ;z.B. -'1' => '1'
                cmp.b   #'0',D0         ;eine Null?
                beq.s   dez_out4        ;Ja! =>
                moveq   #-1,D4          ;ab nun werden Nullen ausgegeben
dez_out3:       move.b  D0,(A0)+        ;das Zeichen in D0 ausgeben
dez_out5:       add.l   D3,D1           ;den Unterlauf (s.o.) zurÅcknehmen
                dbra    D2,dez_out1     ;schon alle Stellen ausgeben? Nein! =>
                movem.l (SP)+,D0-D5/A1
                rts
dez_out4:       tst.b   D4              ;Nullen ausgeben?
                bne.s   dez_out3        ;Ja! =>
                tst.w   D2              ;letzte Ziffer?
                bne.s   dez_out5        ;Nein! => dann ignorieren
                moveq   #'0',D0         ;wenn der gesamte Wert 0 ist, zumindest
                bra.s   dez_out3        ;eine 0 ausgeben!

dez_tab:        DC.L 1,10,100,1000,10000,100000
                DC.L 1000000,10000000,100000000,1000000000

;************************************************************************
;* do_dialog(tree) - Dialogbox ab A0 ausfÅhren (Button nach D0)         *
;************************************************************************

do_dialog:      bsr     box_draw
                move.l  A0,addr_in
                clr.w   int_in
                move.l  #form_do,D0
                bsr     aes
                and.w   #$7FFF,D0       ;Doppelklick-Bit lîschen
                bsr     box_undraw
                moveq   #1,D1
                bra.s   undo_objc       ;EXIT-Button deselectieren

;************************************************************************
;* do_objc(tree,index,bit) - Objektstatus setzen                        *
;* tree  - Adresse des Baumes in A0                                     *
;* index - Objektindex in D0                                            *
;* bit   - Bitmaske in D1                                               *
;************************************************************************

do_objc:        movem.l D0-D1,-(SP)
                mulu    #24,D0
                or.w    10(A0,D0.w),D1  ;in die Bitmaske einsetzen
                move.w  D1,10(A0,D0.w)  ;neuen Status setzen
                movem.l (SP)+,D0-D1
                rts

;************************************************************************
;* undo_objc(tree,index,bit) - Objektstatus lîschen                     *
;* tree  - Adresse des Baumes in A0                                     *
;* index - Objektindex in D0                                            *
;* bit   - Bitmaske in D1                                               *
;************************************************************************

undo_objc:      movem.l D0-D1,-(SP)
                mulu    #24,D0
                not.w   D1
                and.w   10(A0,D0.w),D1  ;in die Bitmaske einsetzen
                move.w  D1,10(A0,D0.w)  ;neuen Status setzen
                movem.l (SP)+,D0-D1
                rts

;************************************************************************
;* is_objc(tree,index,bit) - Objektstatus testen                        *
;* tree  - Adresse des Baumes in A0                                     *
;* index - Objektindex in D0                                            *
;* bit   - Bitmaske in D1                                               *
;************************************************************************

is_objc:        move.l  D1,-(SP)
                mulu    #24,D0
                and.w   10(A0,D0.w),D1  ;in die Bitmaske einsetzen
                move.w  D1,D0
                movem.l (SP)+,D1        ;Flags nicht Ñndern!
                rts

;************************************************************************
;* set_flag(tree,index,bit) - Objektflags setzen                        *
;* tree  - Adresse des Baumes in A0                                     *
;* index - Objektindex in D0                                            *
;* bit   - Bitmaske in D1                                               *
;************************************************************************

set_flag:       movem.l D0-D1,-(SP)
                mulu    #24,D0
                or.w    8(A0,D0.w),D1   ;in die Bitmaske einsetzen
                move.w  D1,8(A0,D0.w)   ;Flags neu setzen
                movem.l (SP)+,D0-D1
                rts

;************************************************************************
;* del_flag(tree,index,bit) - Objektflags lîschen                       *
;* tree  - Adresse des Baumes in A0                                     *
;* index - Objektindex in D0                                            *
;* bit   - Bitmaske in D1                                               *
;************************************************************************

del_flag:       movem.l D0-D1,-(SP)
                mulu    #24,D0
                not.w   D1
                and.w   8(A0,D0.w),D1   ;in die Bitmaske einsetzen
                move.w  D1,8(A0,D0.w)   ;Flags neu setzen
                movem.l (SP)+,D0-D1
                rts

;************************************************************************
;* box_draw(tree,X,Y,W,H) - RSC-Baum ab A0 zeichnen                     *
;* X,Y -> D1  W,H -> D2                                                 *
;************************************************************************

box_draw:       movem.l D0-D4/A0-A1,-(SP)
                move.l  A0,addr_in
                move.l  #form_center,D0
                bsr     aes             ;form_center()
                movem.l int_out+2(PC),D3-D4 ;cX,cY,cW,cH
                bsr     Hidem
                lea     int_in(PC),A1
                move.w  #FMD_START,(A1)
                movem.l D1-D2,2(A1)     ;X,Y,W,H
                movem.l D3-D4,10(A1)    ;cX,cY,cW,cH
                move.l  #form_dial,D0
                bsr     aes             ;form_dial()
                move.l  A0,addr_in
                clr.w   (A1)+
                move.w  #8,(A1)+
                movem.l D3-D4,(A1)      ;cX,cY,cW,cH
                move.l  #objc_draw,D0
                bsr     aes
                bsr     Showm
                movem.l (SP)+,D0-D4/A0-A1
                rts

;************************************************************************
;* box_undraw(tree,X,Y,W,H) - RSC-Baum ab A0 lîschen                    *
;* X,Y -> D1  W,H -> D2                                                 *
;************************************************************************

box_undraw:     movem.l D0-D4/A0-A1,-(SP)
                move.l  A0,addr_in
                move.l  #form_center,D0
                bsr     aes             ;form_center()
                movem.l int_out+2(PC),D3-D4 ;cX,cY,cW,cH
                lea     int_in(PC),A1
                move.w  #FMD_FINISH,(A1)
                movem.l D1-D2,2(A1)     ;X,Y,W,H
                movem.l D3-D4,10(A1)    ;cX,cY,cW,cH
                move.l  #form_dial,D0
                bsr     aes             ;form_dial()
                movem.l (SP)+,D0-D4/A0-A1
                rts

;************************************************************************
;* objc_update(tree,index) - Objekt D0 neu zeichnen                     *
;************************************************************************

objc_update:    movem.l D0-D5/A0-A2,-(SP)
                move.w  D0,D1
                move.l  A0,addr_in
                move.w  D1,int_in
                move.l  #objc_offset,D0
                bsr     aes
                movem.w int_out+2(PC),D2-D3 ;X,Y
                move.w  D1,D0
                mulu    #24,D0
                movem.w 20(A0,D0.w),D4-D5 ;W,H
                move.l  A0,addr_in
                lea     int_in(PC),A0
                move.w  D1,(A0)+        ;Index
                move.w  #8,(A0)+        ;Depth
                movem.w D2-D5,(A0)      ;X,Y,W,H
                move.l  #objc_draw,D0
                bsr     aes
                movem.l (SP)+,D0-D5/A0-A2
                rts

;************************************************************************
;* Hidem/Showm/Defmouse - Maus aus- bzw. anschalten oder umdefinieren   *
;************************************************************************

Hidem:          move.w  #M_OFF,D0       ;Maus ausschalten
                bra.s   Defmouse
Showm:          move.w  #M_ON,D0        ;Maus anschalten
Defmouse:       move.w  D0,int_in
                move.l  #graf_mouse,D0
                bra     aes             ;Maus umdefinieren

;************************************************************************
;* Den Treiber suchen, und Versionsnummer in RSC umkopieren             *
;************************************************************************

version:        lea     init_vers_text(PC),A0
                bra     Supexec


init_vers_text: lea     acc_name(PC),A0
                lea     rsc_string77(PC),A1
init_vers_text1:move.b  (A0)+,(A1)+     ;Namen des ACCs kopieren
                bne.s   init_vers_text1
                subq.l  #1,A1
                move.l  $0516.w,D0      ;punptr holen
                beq.s   init_vers_text4 ;Nicht da! => nicht installiert =>
                movea.l D0,A2
init_vers_text2:lea     -12(A2),A2
                cmpi.l  #'XBRA',(A2)+   ;XBRA?
                bne.s   init_vers_text4 ;Nein! => nicht installiert =>
                cmpi.l  #'CBHD',(A2)+   ;der Treiber?
                beq.s   init_vers_text3 ;Ja! =>
                movea.l (A2),A2         ;sonst: weiter in der XBRA-Liste
                bra.s   init_vers_text2 ;und suchen =>
init_vers_text3:movea.l -12(A2),A2      ;Zeiger auf den CBHD-Treiber
                lea     54-28(A2),A2
                move.l  A2,zg           ;Zeiger auf die RAM-Daten merken
                tst.b   mode
                bne.s   init_vers_text6
                lea     cbhd_text1(PC),A0
                move.b  (A2)+,cbhd_text_vers-cbhd_text1(A0)
                move.b  (A2),cbhd_text_vers-cbhd_text1+2(A0)
                bra.s   init_vers_text5
init_vers_text6:lea     cbhd_text3(PC),A0
                move.b  (A2)+,cbhd_text_vers2-cbhd_text3(A0)
                move.b  (A2),cbhd_text_vers2-cbhd_text3+2(A0)
                bra.s   init_vers_text5
init_vers_text4:lea     cbhd_text2(PC),A0 ;not installed!
init_vers_text5:move.b  (A0)+,(A1)+     ;Namen des Treibers kopieren
                bne.s   init_vers_text5
                rts

;************************************************************************
;* AES-Init, RSC-Daten an die Auflîsung anpassen                        *
;************************************************************************

aes_init:       move.l  #graf_handle,D0
                bsr     aes             ;Handle der Bildschirm-Workstation ermitteln
                move.w  D0,gr_handle

                lea     rsc_tree1(PC),A0
                moveq   #0,D1
aes_init1:      move.w  D1,int_in       ;den RSC-Baum an die Auflîsung anpassen
                move.l  A0,addr_in
                move.l  #rsrc_obfix,D0
                bsr     aes             ;rsrc_obfix()
                addq.w  #1,D1
                cmp.w   #rsh_nobs,D1    ;schon alle Objekte?
                bne.s   aes_init1       ;Nein! =>
                rts

;************************************************************************
;* Routine ab A0 im Supervisormode ausfÅhren                            *
;************************************************************************

Supexec:        move.l  A0,-(SP)
                move.w  #$26,-(SP)
                trap    #14             ;Supexec()
                addq.l  #6,SP
                rts

;************************************************************************
;* Einige Routinen, die als DATAs schon im Basic drin waren             *
;************************************************************************
;BHDI - Interface-Programm fÅr die SH205
*****************************************
* BHDI.S                                *
* Interface-Programm fÅr die SH205      *
* aus "SCHEIBENKLEISTER"                *
* Basisroutinen fÅr CD-Behandlung       *
* V1.1, 12.2.89                         *
* Written & (C) by Claus Brod           *
*                  Am Felsenkeller 2    *
*                  8772 Marktheidenfeld *
*                  09391/3206           *
*                                       *
* V0.1: READ und STDCOMMAND             *
*       implementiert (unvollstÑndig)   *
* V0.2: DMA-Modus-Bit 7 entrÑtselt      *
* V0.3: neue Routinen sd2to5, sd1to5,   *
*       sd1to6; Statusdaten immer nach  *
*       buf2                            *
* V0.4: mdselect, mdsense eingebaut     *
* V0.5: Neue Routinen fÅr Request Sense,*
*       Mode Sense, Translate, Read/    *
*       Reset Usage Counter, Read Data  *
*       Buffer, Write Data Buffer, Set  *
*       Error Threshold, Receive/Send   *
*       Diagnostic                      *
*       read/write verallgemeinert      *
* V0.6: send diagnostic und format      *
*       entwanzt                        *
* V0.7: AufrÑumungsarbeiten in Source   *
*       und Kommentaren                 *
* V0.8: Vorbereitungen fÅr CD-Pro-      *
*       grammierung                     *
* V0.9: Alle CDAR504-Kommandos in erster*
*       Fassung implementiert           *
*       READ-Kommandos noch provisorisch*
*       sd1to5, sd2to5, sd1to6 umge-    *
*       Ñndert in sd1tox, sd2tox,       *
*       sd2toend; d3.w jetzt global     *
*       sd2tox verbessert               *
* V1.0: CDAR-Kommandos Åberarbeitet     *
* V1.1: Flexible Sektorgrîûen im HD-Teil*
*****************************************

dlow            EQU $FFFF860D   ; DMA-AdreûzÑhler, Lowbyte
dmid            EQU $FFFF860B   ; DMA-AdreûzÑhler, Midbyte
dhigh           EQU $FFFF8609   ; DMA-AdreûzÑhler, Highbyte
gpip            EQU $FFFFFA01   ; GPIP-Register des MFP
daccess         EQU $FFFF8604   ; DMA-Access-Register
dmodus          EQU $FFFF8606   ; DMA-Modus-Register
vbl             EQU $043E       ; Floppy-VBL-Sperre
hz_200          EQU $04BA       ; 200-Hz-ZÑhler

Hdread:         bra.s   main            ; zum Programmanfang

buffer:         DC.L _buf       ; Zeiger auf DMA-Puffer
buf2:           DC.L _buf2      ; Zeiger auf Reservepuffer
                DC.L 0          ; Modus
; (0=SH205/SH204,
;  1=CDAR504,
;  alle anderen Werte reserviert)
comblock:       DC.W 0,0,0      ; Puffer fÅr Kommandoblock

status:         DC.L 0          ; Status (bei CD-ROM auch Puffer fÅr
; die letzten 4 Kommandobytes)
timeflag:       DC.L 0          ; Timeout-Flag
dmaend:         DC.L 0          ; Ende der DMA-öbertragung

                DC.L 0,0,0,0,0,0,0,0 ; 8 Erweiterungsworte
; fÅr die Zukunft

save_ssp:       DC.L 0          ; Ein Platz fÅr Tiere

***************************
* main: Hauptprogramm
* Aktiviert Supervisormodus, analysiert
* Modus-Langwort und verteilt danach;
* terminiert nach Umschalten in Usermodus
****************************
main:           movem.l D0-A6,-(SP)     ; Register retten

                clr.l   D0              ; Userstack wird Supervisorstack
                bsr     super           ; in den Supervisormodus
                lea     save_ssp(PC),A2 ; Stackpointer retten
                move.l  D0,(A2)
                lea     timeflag(PC),A2 ; Timeout-Flag lîschen
                clr.l   (A2)

                st      vbl.w           ; Floppy-VBL sperren

                clr.w   D4              ; Ende-Flag lîschen
                clr.w   D3              ; 6-Byte-Kommandos

* d4.w = 0: nach Kommando nicht auf IRQ warten
* d4.w = 1: nach Kommando auf IRQ warten
* d3.w = 0: 6-Byte-Kommandos
* d3.w = 1: 10-Byte-Kommandos

                lea     comblock(PC),A0 ; Adresse von comblock
                clr.l   D0              ; d0.l lîschen

***************** Hier beginnt der spezifische Teil fÅr die Platten-
***************** programmierung

                move.b  (A0),D0         ; Kommando holen
                and.w   #31,D0          ; untere 5 Bit isolieren

                cmp.b   #3,D0           ; Request Sense?
                beq     reqsense        ; ja
                cmp.b   #$0F,D0         ; Translate
                beq     translate       ; ja
                cmp.b   #4,D0           ; Format Drive?
                beq     fmtdrive        ; ja
                cmp.b   #8,D0           ; READ-Kommando?
                beq     read            ; ja
                cmp.b   #$0A,D0         ; WRITE-Kommando?
                beq     write           ; ja
                cmp.b   #$15,D0         ; MODE-SELECT-Kommando?
                beq     modeselect      ; ja
                cmp.b   #$1A,D0         ; MODE-SENSE?
                beq     modesense       ; ja
                cmp.b   #$11,D0         ; READ/RESET USAGE COUNTER?
                beq     rdusage         ; ja
                cmp.b   #$10,D0         ; SET ERROR THRESHOLD?
                beq     threshold       ; ja
                cmp.b   #$13,D0         ; WRITE DATA BUFFER?
                beq     wrbuf
                cmp.b   #$14,D0         ; READ DATA BUFFER?
                beq     rdbuf
                cmp.b   #$1C,D0         ; RECEIVE DIAGNOSTIC?
                beq     getdiag
                cmp.b   #$1D,D0         ; SEND DIAGNOSTIC?
                beq     senddiag        ; ja

*                               * alles andere ist Standard-Kommando

*************************
* stdcommand: Schickt Standard-Kommandoblock
* IN: a0.l Zeiger auf comblock
*************************
                move.w  #$8A,D1         ; DMA-Modus
                bsr     sd1toend        ; Kommandoblock schicken

                move.w  #$8A,dmodus.w   ; ACSI-Bus selektieren
                bsr     getstatus       ; Status holen

************************
* exitus: Interface beendet die Arbeit
************************
exitus:         clr.w   vbl.w           ; Floppy-VBL freigeben

                move.l  save_ssp(PC),D0 ; Stackpointer zurÅckholen
                bsr     super           ; in den Usermodus
                movem.l (SP)+,D0-A6     ; Register zurÅckholen

                rts                     ; raus hier

**************************
* reqsense
**************************
reqsense:       move.w  #3,D6           ; ZÑhler fÅr 4 DurchlÑufe
                move.w  #1,D5           ; Blockanzahl

**************************
* rqentry: Einsprung fÅr Reqsense-Ñhnliche
* Kommandos
* IN: d6.w ZÑhler, d5.w Blockanzahl
**************************
rqentry:        bsr     rdtoggle        ; DMA-Status/Puffer lîschen
                move.w  D5,daccess.w    ; Blockanzahl in SektorzÑhler

                move.l  buf2(PC),D0     ; Startadresse des Statuspuffers
                bsr     setdma          ; in DMA-ZÑhlerregister

rqlp:           move.w  #$8A,D1         ; Moduswort $8A
                clr.w   D0              ; d0 lîschen
                bsr     sd1tox          ; die ersten fÅnf Kommandobytes
                bmi     rwerr           ; Timeout?

                move.l  #$0A,daccess.w  ; letztes Kommandobyte, DMA starten
                bsr     waitforcom      ; öbertragung abwarten
                bmi     rwerr           ; Timeout?

                move.w  #$8A,dmodus.w   ; Bus selektieren
                nop
                move.w  daccess.w,D0    ; CS low, ACK bleibt High, R/W auf R
                btst    #1,D0           ; Fehler?
                bne.s   rwerr2          ; jawohl

                move.w  #130,D2         ; 100 reicht auch
as_time_goes_by:dbra    D2,as_time_goes_by ; Zeitschleife

                dbra    D6,rqlp         ; next one

                move.w  #$8A,dmodus.w   ; Bus selektieren

rwerr2:         bsr     getst2          ; Status holen
                bra.s   exitus          ; raus aus dem Schlamassel

**************************
* translate
**************************
translate:      move.w  #1,D6           ; Kommando zweimal schicken
                move.w  #1,D5           ; Blockanzahl 1
                bra.s   rqentry         ; Reqsense-Ñhnliches Kommando

**************************
* read/reset usage counter
**************************
rdusage:        move.w  #1,D6           ; Kommando zweimal schicken
                move.w  #1,D5           ; Blockanzahl 1
                bra.s   rqentry         ; Reqsense-Ñhliches Kommando

*****************
* modesense: Liest Modus von Platte
*****************
modesense:      move.w  #1,D6           ; Kommando zweimal schicken
                move.w  #1,D5           ; Blockanzahl 1
                bra.s   rqentry         ; Reqsense-Ñhnliches Kommando

******************
* receive diagnostic
******************
getdiag:        move.w  #1,D6           ; Kommando zweimal schicken
                move.w  #2,D5           ; Blockanzahl 2
                bra.s   rqentry         ; Reqsense-Ñhnliches Kommando

******************
* fmtdrive: Formatiert die ganze Platte
******************
fmtdrive:       move.w  #$018A,D1       ; DMA-Modus
                bsr     sd1tox          ; Kommandobytes 1 bis 5 schicken
                bmi     rwerr           ; Timeout?

                move.b  5(A0),D0        ; letztes Kommandobyte
                swap    D0              ; WorthÑlften vertauschen
                move.w  #$018A,D0       ; Moduswort
                move.l  D0,daccess.w    ; und weg damit

wtfmt:          btst    #5,gpip.w       ; Auf Ende warten
                bne.s   wtfmt
                bra     rwerr           ; und Sense

*****************
* set error threshold
*****************
threshold:      move.l  buf2(PC),D0     ; DMA-Startadresse
                move.w  #1,D5           ; Blockanzahl 1
                bra.s   wrentry         ; Write-Ñhnliches Kommando

****************
* write data buffer
****************
wrbuf:          move.l  buf2(PC),D0     ; DMA-Startadresse
                move.w  #2,D5           ; Blockanzahl 2
                bra.s   wrentry         ; Write-Ñhnliches Kommando

*****************
* modeselect: Plattenparameter setzen
*****************
modeselect:     move.l  buf2(PC),D0     ; Reservepufferadresse holen
                move.w  #1,D5           ; Blockanzahl 1
                bra.s   wrentry         ; Write-Ñhnliches Kommando

*****************
* write: Schreibt Sektoren auf Platte
*****************
write:          clr.w   D0
                move.b  4(A0),D0        ; Sektoranzahl holen
                bsr     calcblk         ; Anzahl der DMA-Blîcke berechnen
                move.l  buffer(PC),D0   ; DMA-Startadresse

******************
* wrentry: Einsprungpunkt fÅr
* Write-Ñhnliche Kommandos
* IN: d0.l DMA-Start, d5 Sektoranzahl
*     d4.w Flag fÅr Timeoutbehandlung (<>0=bis IRQ warten)
******************
wrentry:        bsr     setdma          ; DMA-Start setzen

                move.w  #$88,dmodus.w   ; HDC-Zugriff
                clr.l   D0              ; d0 lîschen
                move.b  comblock(PC),D0 ; Kommando und Target holen
                swap    D0              ; WorthÑlften vertauschen
                move.w  #$8A,D0         ; Modus einkopieren
                move.l  D0,daccess.w    ; und alles auf den Bus
                bsr     zeiteisen       ; auf BestÑtigung warten
                bmi     rwerr           ; Fehler?

                move.w  #$018A,D1       ; DMA-Modus
                bsr     sd2tox          ; Bytes 2 bis x schicken
                bmi     rwerr           ; Fehler?

                bsr     wrtoggle        ; DMA-Status/Puffer lîschen

                move.w  D5,daccess.w    ; Sektoranzahl an DMA-Chip
                nop
                move.w  #$018A,dmodus.w ; HDC selektieren
                nop
                move.l  #$010A,daccess.w ; öbertragung starten
                tst.w   D4              ; mit Timeout beim letzten Byte?
                bne.s   wrlp            ; nein, dann weiter
                bsr     waitforcom      ; auf Kommandoende warten
                bra.s   wrst

wrlp:           btst    #5,gpip.w       ; bis ultimo auf IRQ warten
                bne.s   wrlp

wrst:           move.w  #$018A,dmodus.w ; HDC selektieren
                nop
                bra.s   rwerr           ; mit Statussequenz fortfahren

*****************
* send diagnostic
*****************
senddiag:       move.w  #1,D5           ; Blockanzahl 1
                move.l  buf2(PC),D0     ; DMA-Start
                movea.l D0,A1
                cmpi.b  #$60,(A1)       ; REINITIALIZE?
                bne.s   wrentry         ; nein, weiter
                st      D4              ; jawohl, auf IRQ am Ende warten
                bra.s   wrentry

****************
* read data buffer
****************
rdbuf:          move.w  #2,D5           ; 2 Blîcke
                move.l  buf2(PC),D6     ; DMA-Start
                bra.s   rdentry         ; Read-Ñhnliches Kommando

*****************
* read: Liest Sektoren von Festplatte
*****************
read:           moveq   #0,D0           ; d0.l lîschen
                move.b  4(A0),D0        ; Sektoranzahl
                bsr     calcblk         ; Anzahl der DMA-Blîcke ausrechnen
                move.l  buffer(PC),D6   ; DMA-Startadresse

******************
* rdentry: Einsprungpunkt fÅr
* Read-Ñhnliche Kommandos
* IN: d6.l DMA-Start, d5 Sektoranzahl
*******************
rdentry:        move.w  #$88,dmodus.w   ; Busanforderung
                clr.l   D0              ; d0 lîschen
                move.b  comblock(PC),D0 ; Kommando und Target holen
                swap    D0              ; WorthÑlften vertauschen
                move.w  #$8A,D0         ; Modus einkopieren
                move.l  D0,daccess.w    ; und alles auf den Bus
                bsr     zeiteisen       ; auf BestÑtigung warten
                bmi.s   rwerr           ; Timeout?

                move.l  D6,D0           ; Pufferadresse
                bsr     setdma          ; als DMA-Startadresse
                move.w  #$8A,D1         ; DMA-Modus
                bsr.s   sd2tox          ; Kommandobytes 2 bis x Åbergeben
                bmi.s   rwerr           ; Fehler?

                bsr     rdtoggle

                move.w  D5,daccess.w    ; Sektoranzahl an DMA-SektorzÑhler
                nop
                move.w  #$8A,dmodus.w   ; HDC wieder selektieren
                nop
                move.l  #$0A,daccess.w  ; öbertragung starten
                bsr.s   waitforcom      ; auf Kommandoende warten

                move.w  #$8A,dmodus.w   ; HDC selektieren
                nop

rwerr:          bsr     getstatus       ; Status holen
                bra     exitus          ; und raus

**********************
* sdbyte: Byte in d0 an HDC schicken
* IN:  d0.l wie folgt:
*      -------------------------
*      | X.b | X.b | 0.b | CB.b|
*      -------------------------
*      CB=Commandbyte
*      d1.w DMA-Modus ($8A/$18A)
***********************
sdbyte:         swap    D0              ; WorthÑlften vertauschen
                move.w  D1,D0           ; DMA-Modus einschieben
                move.l  D0,daccess.w    ; Byte auf Bus und Modus an DMA-Chip
                bra.s   zeiteisen       ; und warten

**********************
* sd2tox: Schickt die Kommandobytes 2 bis x
* auf den ACSI-Bus (per sdbyte)
* IN: a0.l Zeiger auf comblock
*     d1.w DMA-Modus
*     d3.w = 0: 6-Byte-Kommando (x=5)
*          = 1: 10-Byte-Kommando (x=9)
* OUT: N-Flag gesetzt, wenn Timeout
**********************
sd2tox:         movem.l D0/D2,-(SP)     ; d0 und d2 retten
                clr.l   D0              ; d0.l lîschen
                clr.w   D2              ; d2.w initialisieren
                lea     ende(PC),A1
                move.w  #4,(A1)
                tst.w   D3              ; 10-Byte-Kommando?
                beq.s   sdloop
                move.w  #8,(A1)

sdloop:         addq.w  #1,D2           ; d2++
                move.b  0(A0,D2.w),D0   ; Kommandobyte holen
                bsr.s   sdbyte          ; und auf Bus legen
                bmi.s   sd2err          ; Timeout?

                cmp.w   (A1),D2         ; schon 4 bzw. 8 Bytes Åbertragen?
                bne.s   sdloop          ; nein, weitermachen

sd2err:         movem.l (SP)+,D0/D2     ; d0 und d2 zurÅckholen
                rts                     ; und raus

ende:           DC.W 0          ; Anzahl zu Åbertragender Bytes+1
**********************
* sd1tox: Schickt Kommandobytes 1 bis x auf ACSI-Bus
* (per sdbyte)
* IN: a0.l Zeiger auf comblock
*     d1.w DMA-Modus
*     d3 = 0: 6-Byte-Kommando
*     d3 = 1: 10-Byte-Kommando
* OUT: N-Flag gesetzt, wenn Timeout
***********************
sd1tox:         clr.w   D0              ; d0.w lîschen
                move.w  #$88,dmodus.w   ; ACSI-Bus wachrÅtteln
                move.b  (A0),D0         ; erstes Kommandobyte holen
                bsr.s   sdbyte          ; und auf ASI-Bus legen
                bmi.s   sd1err          ; Timeout?
                bsr.s   sd2tox          ; Kommandobytes 2 bis 5 schicken
sd1err:         rts

***********************
* sd1toend: Schickt Kommandobytes 1 bis 6 bzw. 10 auf ACSI-Bus
* (per sdbyte)
* IN: a0.l Zeiger auf comblock
*     d1.w DMA-Modus
*     d3 = 0: 6-Byte-Kommando
*     d3 = 1: 10-Byte-Kommando
* OUT: N-Flag fÅr Timeout
***********************
sd1toend:       bsr.s   sd1tox          ; Kommandobytes 1 bis x schicken
                bmi.s   sderr           ; Timeout?
                move.b  5(A0),D0        ; letztes Kommandobyte holen
                tst.w   D3              ; 10-Byte-Kommando?
                beq.s   sdlast          ; nein, weiter
                move.b  9(A0),D0        ; letztes Kommandobyte holen
sdlast:         swap    D0              ; WorthÑlften vertauschen
                move.w  D1,D0           ; DMA-Modus
                move.l  D0,daccess.w    ; auf Bus damit
                bsr.s   waitforcom      ; auf Kommandoende warten
sderr:          rts

**********************
* waitforcom: Wartet nach Kommandoblock auf Kommandoende
* USES: d0,d1,a2
**********************
waitforcom:     movem.l D0-D1/A2,-(SP)
                clr.l   D0              ; Default-Fehler
                move.l  #800,D1         ; langes Timeout
                bra.s   gettimer        ; und warten

*********************
* zeiteisen: Wartet auf IRQ des HDC
* USES: d0,d1,a2
*********************
zeiteisen:      movem.l D0-D1/A2,-(SP)

                clr.l   D0              ; Fehler-Default
                moveq   #20,D1          ; 20 Ticks warten
gettimer:       add.l   hz_200.w,D1     ; d1 plus 200Hz-ZÑhler
zeita:          btst    #5,gpip.w       ; auf HDC-IRQ testen
                beq.s   fix_und_fertig  ; ist angekommen, fertig
                cmp.l   hz_200.w,D1     ; Timer-Zielwert erreicht?
                bhi.s   zeita           ; nein, weiter

                lea     timeflag(PC),A2
                moveq   #-1,D0          ; Fehler Åbermitteln
                move.l  D0,(A2)         ; Timeout-Flag setzen
fix_und_fertig: tst.l   D0              ; N-Flag aktualisieren
                movem.l (SP)+,D0-D1/A2
                rts                     ; und raus

********************
* setdma: DMA-Startadresse setzen
* IN: D0.L Pufferadresse
********************
setdma:         move.b  D0,dlow.w       ; Lowbyte
                asr.l   #8,D0
                move.b  D0,dmid.w       ; Midbyte
                asr.l   #8,D0
                move.b  D0,dhigh.w      ; Highbyte
                rts

********************
* getdma: DMA-Adresse lesen und in dmaend
* ablegen
********************
getdma:         clr.w   D0
                move.b  dhigh.w,D0      ; Highbyte lesen
                asl.l   #8,D0           ; mal 256
                move.b  dmid.w,D0       ; Midbyte
                asl.l   #8,D0           ; mal 256
                move.b  dlow.w,D0       ; Lowbyte
                lea     dmaend(PC),A0   ; Adresse von dmaend
                move.l  D0,(A0)         ; DMA-Adresse ablegen
                rts                     ; und raus

*********************
* rdtoggle: DMA-Puffer und DMA-Status lîschen
* SektorzÑhler selektieren, Datenrichtung auf lesen
*********************
rdtoggle:       move.w  #$98,dmodus.w
                nop
tglentry:       move.w  #$0198,dmodus.w
                nop
                move.w  #$98,dmodus.w
                rts

********************
* wrtoggle, wie oben, nur fÅr Datenrichtung Schreiben
********************
wrtoggle:       bsr.s   tglentry
                move.w  #$0198,dmodus.w
                rts

**************************
* getstatus: Liest Statusbyte
* deselektiert HDC
* ACSI-Bus muû bereits selektiert sein ($8a oder $18a nach dmodus)
* OUT: Status in status
* USES: d0,a2
**************************
getstatus:      move.w  daccess.w,D0    ; Status holen

getst2:         swap    D0              ; WorthÑlften tauschen
                move.w  dmodus.w,D0     ; DMA-Status holen
                lea     status(PC),A2
                and.l   #$FF0007,D0     ; ausmaskieren
                move.l  D0,(A2)         ; in status ablegen

                move.w  #$80,dmodus.w   ; FDC selektieren
                bra.s   getdma          ; DMA-Adresse holen

********************
* super: Zwischen Super- und Usermode umschalten
* IN: D0 neuer Stack
* OUT: D0 alter Stack
* USES: D0, D1, A0, A1 (GEMDOS)
********************
super:          move.l  D0,-(SP)        ; neue Stackadresse
                move.w  #$20,-(SP)      ; SUPER
                trap    #1              ; GEMDOS
                addq.l  #6,SP           ; Stack sÑubern
                rts                     ; raus

**********************
* calcblk: Errechnet die Anzahl der
* zu Åbertragenden DMA-Blocks (512 Bytes)
* IN:  d0.w Blockanzahl (aus Kommando)
*      buf2(pc) -> logische Blockgrîûe in Bytes (Langwort)
* OUT: d5.w Anzahl der DMA-Blocks
* USES: d6.l
**********************
calcblk:        movea.l buf2(PC),A1     ; -> Reservepuffer
                move.l  (A1),D5         ; Blockgrîûe holen
                mulu    D0,D5           ; mal Blockanzahl

                divu    #512,D5         ; in DMA-Blocks umrechnen
                move.l  D5,D6           ; Ergebnis nach d6
                swap    D6              ; WorthÑlften tauschen
                tst.w   D6              ; Division mit Rest?
                beq.s   calc1           ; nein
                addq.w  #1,D5           ; ein Block mehr
calc1:          rts

;Media-Change auf Laufwerk D0
;*******************************************************************************
;* alle Ordner auf dem Laufwerk D0 freigeben                                   *
;*******************************************************************************
do_media_change:add.b   #'A',D0
                lea     dummy_fname(PC),A0
                move.b  D0,(A0)         ;das Laufwerk einsetzen

                lea     do_medi_vektor1(PC),A0
                bsr     do_super        ;Vektoren rein

                pea     dta_buffer(PC)
                move.w  #$1A,-(SP)
                trap    #1              ;fÅr Fsfirst()
                addq.l  #6,SP

                clr.w   -(SP)
                pea     dummy_fname(PC)
                move.w  #$4E,-(SP)
                trap    #1              ;Fsfirst() - ein Zugriff auf das Laufwerk
                addq.l  #8,SP

                lea     do_medi_vektor2(PC),A0
                bra     do_super        ;und die Vektoren wieder raus

do_medi_vektor1:lea     hdv_bpb(PC),A0
                move.l  $0472.w,(A0)+
                move.l  $047E.w,(A0)+   ;alte Vektoren retten
                move.l  $0476.w,(A0)
                lea     own_hdv_bpb(PC),A0 ;und neue Vektoren rein
                move.l  A0,$0472.w
                lea     own_hdv_mediach(PC),A0
                move.l  A0,$047E.w
                lea     own_hdv_rw(PC),A0
                move.l  A0,$0476.w
                rts

do_medi_vektor2:move.l  hdv_bpb(PC),$0472.w ;alte Vektoren wieder einsetzen
                move.l  hdv_mediach(PC),$047E.w
                move.l  hdv_rw(PC),$0476.w
                rts

own_hdv_bpb:    moveq   #0,D0           ;Fehler!
                rts
own_hdv_mediach:moveq   #2,D0           ;DatentrÑger wurde gewechselt
                rts
own_hdv_rw:     moveq   #-14,D0         ;Media-Change
                rts

dummy_fname:    DC.B 'X:\*.*',0 ;Pfad fÅr Fsfirst()
                EVEN
dta_buffer:     DS.B 44         ;der DTA-Buffer fÅr Fsfirst()
hdv_bpb:        DS.L 1
hdv_mediach:    DS.L 1          ;Platz fÅr die Originalvektoren
hdv_rw:         DS.L 1

do_super:       move.l  A0,-(SP)
                move.w  #$26,-(SP)
                trap    #14             ;Routine ab A0 um Supervisormode
                addq.l  #6,SP           ;aufrufen
                rts

;************************************************************************
;* Meine Standard-AES/VDI-Aufrufe                                       *
;************************************************************************

;************************************************************************
;* Mein eigener kleiner AES-Aufruf                                      *
;* D0=Die ersten 4 EintrÑge im contrl-Array (Bytebreite!)               *
;*    Bit 24-31 = Der Opcode bzw. die Funktionsnummer                   *
;*    Bit 16-23 = Anzahl der EintrÑge in int_in                         *
;*    Bit 8-15  = Anzahl der EintrÑge in int_out                        *
;*    Bit 0-7   = Anzahl der EintrÑge in addr_in                        *
;* Die Anzahl der EintrÑge in addr_out ist stets 0.                     *
;* Ausnahme:Bei rsrc_gaddr() dort sollte dort eine 1 stehen (Atari hÑlt *
;*          sich allersdings selbst nicht dran)                         *
;************************************************************************
aes:            movem.l D1-A6,-(SP)     ;besser retten, man kann nie wissen
                lea     control(PC),A0
                clr.l   (A0)
                clr.l   4(A0)           ;contrl-Array lîschen
                movep.l D0,1(A0)        ;und die neuen Daten eintragen
                lea     aes_pb(PC),A0
                move.l  A0,D1
                move.w  #$C8,D0
                trap    #2              ;AES aufrufen
                moveq   #0,D0
                move.w  int_out(PC),D0
                movem.l (SP)+,D1-A6
                rts

;************************************************************************
;* Nun folgt noch der DATA-Bereich                                      *
;************************************************************************
                DATA
aes_pb:         DC.L control    ;Der AES-Parameterblock
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out

cbhd_text1:     DC.B '  CBHD.SYS  V'
cbhd_text_vers: DC.B '0.0',0
cbhd_text3:     DC.B '   Treiber V'
cbhd_text_vers2:DC.B '0.0',0
cbhd_text2:     DC.B '  CBHD.SYS not installed ',0
sys_path:       DC.B ':\*.SYS',0
sys_fname:      DC.B 'CBHD.SYS',0
ram_alert:      DC.B '[1][    Auch im RAM    |    abÑndern?][Ja|Nein]',0
media_alert:    DC.B '[1][    ACHTUNG!    |    énderungen an offenen|'
                DC.B '    Dateien gehen|    evtl. verloren!][Abbruch|Weiter]',0
reset_alert:    DC.B '[1][    System-RESET?    ][Warm|Kalt|Nieee]',0
gemdos_alert:   DC.B '[2][    CBHDINST:    |    Fehler -'
gemdos_no:      DC.B '00! |    (F'
gemdos_err:     DC.B 'xxxxx)][Aha]',0
fopen_err:      DC.B 'open) ',0
fclose_err:     DC.B 'close)',0
fread_err:      DC.B 'read) ',0
fwrite_err:     DC.B 'write)',0
fseek_err:      DC.B 'seek) ',0
treiber_alert:  DC.B '[3][    Das ist kein    |    Treiber!][Aha]',0
                EVEN

;RSC-Daten
rsh_nobs        EQU 118

rsc_tree1:      DC.W -1,1,1,20,0,16
                DC.L $021100
                DC.W $00,$00,$2F,$0B
                DC.W 0,2,11,20,0,0
                DC.L $FF1111
                DC.W $00,$00,$2F,$0B
                DC.W 3,-1,-1,22,0,32
                DC.L rsc_ted0
                DC.W $07,$01,$1E,$01
                DC.W 4,-1,-1,26,7,0
                DC.L rsc_string2
                DC.W $0E,$09,$12,$01
                DC.W 5,-1,-1,26,85,0
                DC.L rsc_string3
                DC.W $03,$04,$08,$01
                DC.W 6,-1,-1,26,69,0
                DC.L rsc_string4
                DC.W $0D,$04,$08,$01
                DC.W 7,-1,-1,26,85,0
                DC.L rsc_string5
                DC.W $17,$04,$08,$01
                DC.W 8,-1,-1,26,85,0
                DC.L rsc_string6
                DC.W $21,$04,$08,$01
                DC.W 9,-1,-1,26,85,0
                DC.L rsc_string7
                DC.W $03,$06,$08,$01
                DC.W 10,-1,-1,26,85,0
                DC.L rsc_string8
                DC.W $0D,$06,$08,$01
                DC.W 11,-1,-1,26,85,0
                DC.L rsc_string9
                DC.W $17,$06,$08,$01
                DC.W 1,-1,-1,26,117,0
                DC.L rsc_string10
                DC.W $21,$06,$08,$01

rsc_tree2:      DC.W -1,1,1,20,0,16
                DC.L $021100
                DC.W $00,$00,$33,$09
                DC.W 0,2,14,20,0,0
                DC.L $FF1111
                DC.W $00,$00,$33,$09
                DC.W 3,-1,-1,26,21,0
                DC.L rsc_string3
                DC.W $06,$04,$05,$01
                DC.W 4,-1,-1,26,21,0
                DC.L rsc_string4
                DC.W $0D,$04,$05,$01
                DC.W 5,-1,-1,26,21,0
                DC.L rsc_string5
                DC.W $14,$04,$05,$01
                DC.W 6,-1,-1,26,21,0
                DC.L rsc_string6
                DC.W $1B,$04,$05,$01
                DC.W 7,-1,-1,26,21,0
                DC.L rsc_string7
                DC.W $22,$04,$05,$01
                DC.W 8,-1,-1,26,21,0
                DC.L rsc_string8
                DC.W $29,$04,$05,$01
                DC.W 9,-1,-1,26,21,0
                DC.L rsc_string9
                DC.W $06,$06,$05,$01
                DC.W 10,-1,-1,26,21,0
                DC.L rsc_string10
                DC.W $0D,$06,$05,$01
                DC.W 11,-1,-1,26,21,0
                DC.L rsc_string19
                DC.W $14,$06,$05,$01
                DC.W 12,-1,-1,26,21,0
                DC.L rsc_string20
                DC.W $1B,$06,$05,$01
                DC.W 13,-1,-1,26,21,0
                DC.L rsc_string21
                DC.W $22,$06,$05,$01
                DC.W 14,-1,-1,26,21,0
                DC.L rsc_string22
                DC.W $29,$06,$05,$01
                DC.W 1,-1,-1,22,32,0
                DC.L rsc_ted1
                DC.W $0A,$01,$20,$01

rsc_tree3:      DC.W -1,1,1,20,0,16
                DC.L $021100
                DC.W $00,$00,$2B,$10
                DC.W 0,2,31,20,0,0
                DC.L $FF1131
                DC.W $00,$00,$2B,$10
                DC.W 3,-1,-1,26,1,0
                DC.L rsc_string24
                DC.W $02,$05,$03,$02
                DC.W 4,-1,-1,26,1,0
                DC.L rsc_string25
                DC.W $05,$05,$03,$02
                DC.W 5,-1,-1,26,1,0
                DC.L rsc_string26
                DC.W $08,$05,$03,$02
                DC.W 6,-1,-1,26,1,0
                DC.L rsc_string27
                DC.W $0B,$05,$03,$02
                DC.W 7,-1,-1,26,1,0
                DC.L rsc_string28
                DC.W $0E,$05,$03,$02
                DC.W 8,-1,-1,26,1,0
                DC.L rsc_string29
                DC.W $11,$05,$03,$02
                DC.W 9,-1,-1,26,1,0
                DC.L rsc_string30
                DC.W $14,$05,$03,$02
                DC.W 10,-1,-1,26,1,0
                DC.L rsc_string31
                DC.W $17,$05,$03,$02
                DC.W 11,-1,-1,26,1,0
                DC.L rsc_string32
                DC.W $1A,$05,$03,$02
                DC.W 12,-1,-1,26,1,0
                DC.L rsc_string33
                DC.W $1D,$05,$03,$02
                DC.W 13,-1,-1,26,1,0
                DC.L rsc_string34
                DC.W $20,$05,$03,$02
                DC.W 14,-1,-1,26,1,0
                DC.L rsc_string35
                DC.W $23,$05,$03,$02
                DC.W 15,-1,-1,26,1,0
                DC.L rsc_string36
                DC.W $26,$05,$03,$02
                DC.W 16,-1,-1,26,1,0
                DC.L rsc_string37
                DC.W $02,$08,$03,$02
                DC.W 17,-1,-1,26,1,0
                DC.L rsc_string38
                DC.W $05,$08,$03,$02
                DC.W 18,-1,-1,26,1,0
                DC.L rsc_string39
                DC.W $08,$08,$03,$02
                DC.W 19,-1,-1,26,1,0
                DC.L rsc_string40
                DC.W $0B,$08,$03,$02
                DC.W 20,-1,-1,26,1,0
                DC.L rsc_string41
                DC.W $0E,$08,$03,$02
                DC.W 21,-1,-1,26,1,0
                DC.L rsc_string42
                DC.W $11,$08,$03,$02
                DC.W 22,-1,-1,26,1,0
                DC.L rsc_string43
                DC.W $14,$08,$03,$02
                DC.W 23,-1,-1,26,1,0
                DC.L rsc_string44
                DC.W $17,$08,$03,$02
                DC.W 24,-1,-1,26,1,0
                DC.L rsc_string45
                DC.W $1A,$08,$03,$02
                DC.W 25,-1,-1,26,1,0
                DC.L rsc_string46
                DC.W $1D,$08,$03,$02
                DC.W 26,-1,-1,26,1,0
                DC.L rsc_string47
                DC.W $20,$08,$03,$02
                DC.W 27,-1,-1,26,1,0
                DC.L rsc_string48
                DC.W $23,$08,$03,$02
                DC.W 28,-1,-1,26,1,0
                DC.L rsc_string49
                DC.W $26,$08,$03,$02
                DC.W 29,-1,-1,26,5,0
                DC.L rsc_string2
                DC.W $19,$0C,$10,$02
                DC.W 30,-1,-1,26,7,0
                DC.L rsc_string51
                DC.W $02,$0C,$10,$02
                DC.W 31,-1,-1,22,0,0
                DC.L rsc_ted2
                DC.W $04,$01,$24,$01
                DC.W 1,-1,-1,22,32,0
                DC.L rsc_ted3
                DC.W $04,$02,$24,$01

rsc_tree4:      DC.W -1,1,1,20,0,16
                DC.L $021100
                DC.W $00,$00,$22,$0D
                DC.W 0,2,9,20,0,0
                DC.L $FF1111
                DC.W $00,$00,$22,$0D
                DC.W 3,-1,-1,30,8,0
                DC.L rsc_ted4
                DC.W $07,$06,$13,$02
                DC.W 4,-1,-1,26,7,0
                DC.L rsc_string82
                DC.W $03,$0A,$08,$01
                DC.W 5,-1,-1,26,5,0
                DC.L rsc_string2
                DC.W $15,$0A,$08,$01
                DC.W 8,6,7,20,0,0
                DC.L $FF1100
                DC.W $02,$01,$1D,$02
                DC.W 7,-1,-1,28,0,0
                DC.L rsc_string59
                DC.W $05,$00,$12,$01
                DC.W 5,-1,-1,28,0,0
                DC.L rsc_string60
                DC.W $01,$01,$1A,$01
                DC.W 9,-1,-1,28,0,0
                DC.L rsc_string59
                DC.W $07,$01,$12,$01
                DC.W 1,-1,-1,22,32,0
                DC.L rsc_ted5
                DC.W $02,$03,$1D,$01

rsc_tree5:      DC.W -1,1,18,20,0,16
                DC.L $FD1121
                DC.W $00,$00,$0329,$0816
                DC.W 2,-1,-1,22,0,0
                DC.L rsc_ted6
                DC.W $04,$01,$21,$02
                DC.W 9,3,8,20,0,0
                DC.L $FF1132
                DC.W $04,$06,$0F,$0C
                DC.W 4,-1,-1,26,5,0
                DC.L rsc_string64
                DC.W $00,$02,$0F,$02
                DC.W 5,-1,-1,26,5,0
                DC.L rsc_string65
                DC.W $00,$04,$0F,$02
                DC.W 6,-1,-1,26,5,0
                DC.L rsc_string66
                DC.W $00,$06,$0F,$02
                DC.W 7,-1,-1,26,5,0
                DC.L rsc_string67
                DC.W $00,$08,$0F,$02
                DC.W 8,-1,-1,26,5,0
                DC.L rsc_string68
                DC.W $00,$0A,$0F,$02
                DC.W 2,-1,-1,21,0,0
                DC.L rsc_ted7
                DC.W $04,$0600,$07,$01
                DC.W 13,10,12,20,0,0
                DC.L $FF1131
                DC.W $16,$06,$0F,$0C
                DC.W 11,-1,-1,26,5,0
                DC.L rsc_string70
                DC.W $00,$06,$0F,$02
                DC.W 12,-1,-1,26,5,0
                DC.L rsc_string71
                DC.W $00,$0A,$0F,$02
                DC.W 9,-1,-1,21,0,0
                DC.L rsc_ted8
                DC.W $04,$0500,$06,$01
                DC.W 14,-1,-1,26,5,0
                DC.L rsc_string73
                DC.W $16,$08,$0F,$02
                DC.W 15,-1,-1,26,4,0
                DC.L rsc_string1
                DC.W $16,$0A,$0F,$02
                DC.W 16,-1,-1,26,5,0
                DC.L rsc_string74
                DC.W $16,$0E,$0F,$02
                DC.W 17,-1,-1,26,7,0
                DC.L rsc_string2
                DC.W $0104,$0813,$21,$02
                DC.W 18,-1,-1,22,0,0
                DC.L rsc_ted9
                DC.W $04,$04,$21,$01
                DC.W 0,-1,-1,22,32,0
                DC.L rsc_ted10
                DC.W $04,$03,$21,$01

rsc_tree6:      DC.W -1,1,6,20,0,16
                DC.L $021111
                DC.W $00,$00,$1E,$0B
                DC.W 6,2,5,20,0,0
                DC.L $FF1100
                DC.W $02,$01,$1A,$04
                DC.W 3,-1,-1,28,0,0
                DC.L rsc_string78
                DC.W $02,$00,$16,$01
                DC.W 4,-1,-1,28,0,0
                DC.L rsc_string79
                DC.W $03,$01,$14,$01
                DC.W 5,-1,-1,28,0,0
                DC.L rsc_string80
                DC.W $03,$02,$14,$01
                DC.W 1,-1,-1,28,0,0
                DC.L rsc_string81
                DC.W $07,$03,$0B,$01
                DC.W 0,-1,-1,26,39,0
                DC.L rsc_string82
                DC.W $09,$07,$0D,$02

rsc_tree7:      DC.W -1,1,7,20,0,16
                DC.L $021100
                DC.W $00,$00,$19,$13
                DC.W 4,2,3,20,0,0
                DC.L $FF1111
                DC.W $02,$01,$15,$05
                DC.W 3,-1,-1,26,17,0
                DC.L rsc_string73
                DC.W $03,$01,$0F,$01
                DC.W 1,-1,-1,26,17,0
                DC.L rsc_string84
                DC.W $03,$03,$0F,$01
                DC.W 5,-1,-1,26,7,0
                DC.L rsc_string85
                DC.W $02,$0C,$15,$02
                DC.W 6,-1,-1,26,5,0
                DC.L rsc_string86
                DC.W $02,$09,$15,$02
                DC.W 7,-1,-1,26,5,0
                DC.L rsc_string2
                DC.W $05,$10,$10,$02
                DC.W 0,-1,-1,22,32,0
                DC.L rsc_ted11
                DC.W $02,$07,$15,$01

rsc_tree8:      DC.W -1,1,14,20,0,16
                DC.L $021111
                DC.W $00,$00,$2A,$0F
                DC.W 2,-1,-1,22,0,0
                DC.L rsc_ted12
                DC.W $08,$01,$18,$02
                DC.W 3,-1,-1,22,0,0
                DC.L rsc_ted13
                DC.W $02,$04,$1B,$01
                DC.W 4,-1,-1,22,0,0
                DC.L rsc_ted14
                DC.W $02,$05,$1B,$01
                DC.W 5,-1,-1,22,0,0
                DC.L rsc_ted15
                DC.W $02,$06,$1B,$01
                DC.W 6,-1,-1,22,0,0
                DC.L rsc_ted16
                DC.W $02,$07,$1B,$01
                DC.W 7,-1,-1,22,0,0
                DC.L rsc_ted17
                DC.W $02,$08,$1B,$01
                DC.W 8,-1,-1,22,0,0
                DC.L rsc_ted18
                DC.W $1D,$04,$0B,$01
                DC.W 9,-1,-1,22,0,0
                DC.L rsc_ted19
                DC.W $1D,$05,$0B,$01
                DC.W 10,-1,-1,22,0,0
                DC.L rsc_ted20
                DC.W $1D,$06,$0B,$01
                DC.W 11,-1,-1,22,0,0
                DC.L rsc_ted21
                DC.W $1D,$07,$0B,$01
                DC.W 12,-1,-1,22,0,0
                DC.L rsc_ted22
                DC.W $1D,$08,$0B,$01
                DC.W 13,-1,-1,26,71,0
                DC.L rsc_string100
                DC.W $09,$0C,$18,$01
                DC.W 14,-1,-1,22,0,0
                DC.L rsc_ted23
                DC.W $02,$09,$1B,$01
                DC.W 0,-1,-1,22,32,0
                DC.L rsc_ted24
                DC.W $1D,$09,$0B,$01

rsc_string52:   DC.B 'Schreibschutz einstellen',0
                EVEN
rsc_string0:    DC.B 'Target auswÑhlen',0
rsc_string1:    DC.B 0
rsc_string2:    DC.B 'ABBRUCH',0
rsc_string3:    DC.B '0',0
rsc_string4:    DC.B '1',0
rsc_string5:    DC.B '2',0
rsc_string6:    DC.B '3',0
rsc_string7:    DC.B '4',0
rsc_string8:    DC.B '5',0
rsc_string9:    DC.B '6',0
rsc_string10:   DC.B '7',0
rsc_string19:   DC.B '8',0
rsc_string20:   DC.B '9',0
rsc_string21:   DC.B '10',0
rsc_string22:   DC.B '11',0
rsc_string23:   DC.B 'Partition auswÑhlen',0
rsc_string24:   DC.B 'A',0
rsc_string25:   DC.B 'B',0
rsc_string26:   DC.B 'C',0
rsc_string27:   DC.B 'D',0
rsc_string28:   DC.B 'E',0
rsc_string29:   DC.B 'F',0
rsc_string30:   DC.B 'G',0
rsc_string31:   DC.B 'H',0
rsc_string32:   DC.B 'I',0
rsc_string33:   DC.B 'J',0
rsc_string34:   DC.B 'K',0
rsc_string35:   DC.B 'L',0
rsc_string36:   DC.B 'M',0
rsc_string37:   DC.B 'N',0
rsc_string38:   DC.B 'O',0
rsc_string39:   DC.B 'P',0
rsc_string40:   DC.B 'Q',0
rsc_string41:   DC.B 'R',0
rsc_string42:   DC.B 'S',0
rsc_string43:   DC.B 'T',0
rsc_string44:   DC.B 'U',0
rsc_string45:   DC.B 'V',0
rsc_string46:   DC.B 'W',0
rsc_string47:   DC.B 'X',0
rsc_string48:   DC.B 'Y',0
rsc_string49:   DC.B 'Z',0
rsc_string51:   DC.B 'FIX & FERTIG',0
rsc_string53:   DC.B ' Treiber in Block :         ',0
rsc_string54:   DC.B '      ',0
rsc_string56:   DC.B '999999',0
rsc_string55:   DC.B 'Anzahl:______',0
rsc_string59:   DC.B 'FÅr wieviel Ordner',0
rsc_string60:   DC.B 'soll Platz gemacht werden ?',0
                EVEN
rsc_string62:   DC.B 'momentaner Rest :   '
rsc_string62a:  DC.B '     ',0
rsc_string63:   DC.B 'CBHDINST - TREIBER NACH MASS',0
rsc_string64:   DC.B 'SCHREIBSCHUTZ',0
rsc_string65:   DC.B 'BOOTLAUFWERK',0
rsc_string66:   DC.B 'ORDNER',0
rsc_string67:   DC.B 'LAUFWERKE',0
rsc_string68:   DC.B 'TREIBER SUCHEN',0
rsc_string69:   DC.B 'Treiber',0
rsc_string70:   DC.B 'STATISTIK',0
rsc_string71:   DC.B 'RESET',0
rsc_string72:   DC.B 'Platte',0
rsc_string73:   DC.B 'PARKEN',0
rsc_string74:   DC.B 'MEDIA',0
rsc_string76:   DC.B 'by Stepper Anton,Claus Brod,Markus Fritze',0
rsc_string77:   DC.B '                                       ',0
rsc_string78:   DC.B 'Bitte in der folgenden',0
rsc_string79:   DC.B 'Dateiauswahlbox  den',0
rsc_string80:   DC.B 'Pfad fÅr den Treiber',0
rsc_string81:   DC.B 'festlegen :',0
rsc_string82:   DC.B 'OK',0
rsc_string84:   DC.B 'RE-PARKEN',0
rsc_string85:   DC.B 'ALLE GERéTE',0
rsc_string86:   DC.B 'EINZELN',0
rsc_string88:   DC.B 'Target ? GerÑt ?',0
rsc_string89:   DC.B 'FEHLERSTATISTIK',0
rsc_string90:   DC.B 'SektorlesezÑhler',0
rsc_string91:   DC.B 'SuchzÑhler',0
rsc_string92:   DC.B 'Nicht korrigierbare Fehler',0
rsc_string93:   DC.B 'Korrigierbare Fehler',0
rsc_string94:   DC.B 'Fehler beim Suchen',0
rsc_string95:   DC.B '              ',0
rsc_string96:   DC.B '              ',0
rsc_string97:   DC.B '              ',0
rsc_string98:   DC.B '              ',0
rsc_string99:   DC.B '              ',0
                EVEN
rsc_string102:  DC.B '              ',0
rsc_string100:  DC.B 'Interessant',0
rsc_string101:  DC.B 'Platz fÅr Ordner',0
                EVEN
rsc_ted0:       DC.L rsc_string0,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$11,$01
rsc_ted1:       DC.L rsc_string23,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$14,$01
rsc_ted2:       DC.L rsc_string52,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$19,$01
rsc_ted3:       DC.L rsc_string53,rsc_string1,rsc_string1
                DC.W $05,$06,$02,$1180,$00,$FFFF,$1D,$01
rsc_ted4:       DC.L rsc_string54,rsc_string55,rsc_string56
                DC.W $03,$06,$02,$1180,$00,$FFFF,$07,$0E
rsc_ted5:       DC.L rsc_string62,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$1A,$01
rsc_ted6:       DC.L rsc_string63,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1101,$00,$FFFF,$1D,$01
rsc_ted7:       DC.L rsc_string69,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$08,$01
rsc_ted8:       DC.L rsc_string72,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1180,$00,$FFFF,$07,$01
rsc_ted9:       DC.L rsc_string76,rsc_string1,rsc_string1
                DC.W $05,$06,$02,$1180,$00,$FFFF,$29,$01
rsc_ted10:      DC.L rsc_string77,rsc_string1,rsc_string1
                DC.W $05,$06,$02,$1180,$00,$FFFF,$28,$01
rsc_ted11:      DC.L rsc_string88,rsc_string1,rsc_string1
                DC.W $05,$06,$02,$0180,$00,$FFFF,$17,$01
rsc_ted12:      DC.L rsc_string89,rsc_string1,rsc_string1
                DC.W $03,$06,$02,$1181,$00,$FFFF,$10,$01
rsc_ted13:      DC.L rsc_string90,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$11,$01
rsc_ted14:      DC.L rsc_string91,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0B,$01
rsc_ted15:      DC.L rsc_string92,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$1B,$01
rsc_ted16:      DC.L rsc_string93,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$15,$01
rsc_ted17:      DC.L rsc_string94,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$13,$01
rsc_ted18:      DC.L rsc_string95,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01
rsc_ted19:      DC.L rsc_string96,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01
rsc_ted20:      DC.L rsc_string97,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01
rsc_ted21:      DC.L rsc_string98,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01
rsc_ted22:      DC.L rsc_string99,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01
rsc_ted23:      DC.L rsc_string101,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$11,$01
rsc_ted24:      DC.L rsc_string102,rsc_string1,rsc_string1
                DC.W $03,$06,$00,$1180,$00,$FFFF,$0F,$01

fhandle:        DC.W -1         ;Handle des geîffneten CBHD.SYS-Treibers
;************************************************************************
;* und noch ein wenig BSS-Bereich                                       *
;************************************************************************
                BSS
control:        DS.W 5          ;Die AES-Variablen
global:         DS.W 15
int_in:         DS.W 16
int_out:        DS.W 7
addr_in:        DS.L 3
addr_out:       DS.L 1

app:            DS.W 1          ;Flag, ob Acc (0) oder Prg (-1)
gr_handle:      DS.W 1          ;Die Handle der Bildschirm-Workstation (graf_handle)

evnt_buff:      DS.W 8          ;Buffer fÅr evnt_mesag()
mode:           DS.B 1          ;=1, wenn Treiber auf einem geschÅtzten Laufwerk
                DS.B 1          ;Nullbyte vor dem Pfad ist nîtig!
cbhd_path:      DS.B 96         ;Pfad fÅr CBHD.SYS
target:         DS.W 1          ;akt.Target
geraet:         DS.W 1          ;akt.GerÑt
tg_table:       DS.B 2*8        ;aktive GerÑte
p_start:        DS.L 12         ;Anfangssektoren der akt.Partitions
                DS.W 1          ;Nullbyte muû vorhanden sein
name_buffer:    DS.B 12         ;Buffer fÅr den Namen im DIR-FORMAT
spc:            DS.W 1          ;Sektoren pro Cluster
len_dir:        DS.W 1          ;LÑnge des Directories
len_fat:        DS.W 1          ;LÑnge der FAT
fat_anf:        DS.W 1          ;Anfang der FAT
first_sec:      DS.W 1          ;1.Sektor
cl:             DS.W 1          ;Clusternummer des Treibers
lgs:            DS.L 1          ;logische Sektornummer des Treibers
block:          DS.L 1          ;phys.Sektornummer des Treibers
zg:             DS.L 1          ;Zeiger auf den CBHD.SYS im RAM
_buf:           DS.B 512        ;512 Byte allgemeiner Buffer
_buf2:          DS.B 512        ;zweiter 512 Byte Buffer (kann Åberlaufen!!!)
                DS.L 512
own_stack:      DS.W 0          ;der eigene Stack
prg_ende:
;AES-Daten
;EQU's mit Konstanten sind auch als VorwÑrtsreferenzen mîglich, da diese Symbole
;ihren Wert bereits bei der Eingabe erhalten:
appl_init       EQU $0A000100
appl_exit       EQU $13000100
evnt_mesag      EQU $17000101
menu_register   EQU $23010101
objc_draw       EQU $2A060101
objc_offset     EQU $2C010301
form_do         EQU $32010101
form_dial       EQU $33090100
form_alert      EQU $34010101
form_center     EQU $36000501
graf_handle     EQU $4D000500
graf_mouse      EQU $4E010101
fsel_input      EQU $5A000202
fsel_exinput    EQU $5B000203   ;ab TOS 1.4
wind_get        EQU $68020500
wind_set        EQU $69060100
wind_update     EQU $6B010100
rsrc_obfix      EQU $72010101

; form_dial()
FMD_START       EQU 0           ;Bildschirmhintergrund reservieren
FMD_FINISH      EQU 3           ;Bildschirmbereich wieder freigeben

WF_WORKXYWH     EQU 4
WF_NEWDESK      EQU 14
; graf_mouse()
ARROW           EQU 0
HOURGLASS       EQU 2
M_OFF           EQU 256
M_ON            EQU 257

                END
