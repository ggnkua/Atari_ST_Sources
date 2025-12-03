;RAIL_MAN Version 2.13 Macros
;============================
;
;Assembler: GFA, Version 1.5
;
;Letzte énderung: 26.10.1990
;
;(C) 1990 by Martin Birn, Knoblochstraûe 51, 7100 Heilbronn
;==========================================================

                .TEXT 

;
;Offsets in den Datenstrukturen
;

m_len           equ 6         ;LÑnge der DatensÑtze im MAG-Segment
m_art           equ 0         ;Offsets
m_adr1          equ 2
m_adr2          equ 3
m_sp            equ 4

e_flag1         equ 0         ;Offsets im Einstallungssegment
e_datflag       equ 2
e_baflag        equ 3
e_magd          equ 4
e_rm_freq       equ 5
e_rm_flag       equ 6
e_rm_comm       equ 7
e_nhkont        equ 8
e_flag3         equ 10
e_wx0           equ 12        ;ab Version 2.00
e_wy0           equ 14
e_ww0           equ 16
e_wh0           equ 18
e_wx1           equ 20
e_wy1           equ 22
e_ww1           equ 24
e_wh1           equ 26
e_whs1          equ 28
e_wvs1          equ 30
e_wx2           equ 32
e_wy2           equ 34
e_ww2           equ 36
e_wh2           equ 38
e_whs2          equ 40
e_wvs2          equ 42
e_wx3           equ 44
e_wy3           equ 46
e_ww3           equ 48
e_wh3           equ 50
e_whs3          equ 52
e_wvs3          equ 54
e_wx4           equ 56
e_wy4           equ 58
e_ww4           equ 60
e_wh4           equ 62
e_whs4          equ 64
e_wvs4          equ 66
e_wx5           equ 68
e_wy5           equ 70
e_ww5           equ 72
e_wh5           equ 74
e_whs5          equ 76
e_wvs5          equ 78
e_pflag         equ 80        ;ab Version 2.10
e_pname         equ 82
e_ppath         equ 94

l_len           equ 66        ;LÑnge der DatensÑtze im Loksegment
l_sfflag        equ 0         ;Offsets
l_delay         equ 1
l_sf1           equ 2
l_sf2           equ 4
l_sf3           equ 6
l_sf4           equ 8
l_bez           equ 10
l_bs1           equ 18
l_bs2           equ 26
l_bs3           equ 34
l_bs4           equ 42
l_laddr         equ 50
l_faddr         equ 51
l_stab          equ 52

b_len           equ 4         ;LÑnge der DatensÑtze im Blocksegment
b_sp            equ 0         ;Offsets
b_ekg_adr       equ 2
b_flag          equ 3

f_len           equ 80        ;LÑnge der DatensÑtze im Fahrstraûen-Segment
f_name          equ 0         ;Offsets
f_gbits         equ 16
f_sbits         equ 48

seg_lok         equ 1         ;Nummern der Segmente
seg_mag         equ 2
seg_block       equ 3
seg_fenster     equ 4
seg_einst       equ 5
seg_fs          equ 6

maxmag          equ 256       ;maximale Anzahl Magnetartikel
maxlok          equ 80        ;maximale Anzahl Loks
maxblock        equ 496       ;maximale Anzahl Blockstrecken
maxfahrs        equ 255       ;maximale Anzahl Fahrstraûen

l_lok           equ l_len*maxlok        ;LÑnge Loksegment
l_mag           equ m_len*maxmag*2      ;LÑnge Magnetartikelsegment
l_block         equ b_len*maxblock      ;LÑnge Blocksegment
l_fens          equ 26600     ;LÑnge Gleisplansegment
l_einst         equ 500       ;LÑnge Einstallungssegment
l_fahrs         equ f_len*maxfahrs      ;LÑnge Fahrstraûensegment

;
;Fehlernummern
;

e_eaddr         equ -1001
e_espeed        equ -1002
e_emode         equ -1003
e_edata         equ -1004
e_endef         equ -1005

e_faddr         equ -1006
e_fmode         equ -1007
e_fdata         equ -1008
e_fndef         equ -1009

e_saddr         equ -1010
e_smode         equ -1011
e_sdir          equ -1012
e_sndef         equ -1013

e_gaddr         equ -1014
e_gmode         equ -1015
e_gndef         equ -1016
e_sgcros        equ -1017

e_nofile        equ -1018
e_rserr         equ -1019
e_handle        equ -1020
e_fnimpl        equ -1021
e_accden        equ -1022
e_unknown       equ -1023

;
;Macrodefinitionen
;

                .MACRO A_START
                RAIL_MAN      0,4
                .ENDM 

                .MACRO A_END handle
                move.w        \handle,-(sp)
                RAIL_MAN      1,6
                .ENDM 

                .MACRO A_STATE handle,mode
                move.w        \mode,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      2,8
                .ENDM 

                .MACRO A_WAIT handle
                move.w        \handle,-(sp)
                RAIL_MAN      3,6
                .ENDM 

                .MACRO A_RESET handle
                move.w        \handle,-(sp)
                RAIL_MAN      5,6
                .ENDM 

                .MACRO A_UPDATE handle
                move.w        \handle,-(sp)
                RAIL_MAN      6,6
                .ENDM 

                .MACRO E_SPEED handle,index,mode,speed
                move.w        \speed,-(sp)
                move.w        \mode,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      7,12
                .ENDM 

                .MACRO E_DIRECTION handle,index
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      8,8
                .ENDM 

                .MACRO E_MODE handle,index,mode
                move.w        \mode,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      9,10
                .ENDM 

                .MACRO E_FUNCTION handle,index,number,mode
                move.w        \mode,-(sp)
                move.w        \number,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      10,12
                .ENDM 


                .MACRO S_SETGROUP handle,index,mode
                move.w        \mode,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      11,10
                .ENDM 

                .MACRO S_DELGROUP handle,index
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      12,8
                .ENDM 

                .MACRO S_SWITCH handle,index,mode,direction
                move.w        \direction,-(sp)
                move.w        \mode,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      13,12
                .ENDM 

                .MACRO S_BSWITCH handle,index
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      21,8
                .ENDM 

                .MACRO R_START handle
                move.w        \handle,-(sp)
                RAIL_MAN      14,6
                .ENDM 

                .MACRO R_STOP handle
                move.w        \handle,-(sp)
                RAIL_MAN      15,6
                .ENDM 

                .MACRO Q_VERSION handle
                move.w        \handle,-(sp)
                RAIL_MAN      16,6
                .ENDM 

                .MACRO Q_ARRAY handle,addr
                move.l        \addr,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      17,10
                .ENDM 

                .MACRO Q_FILE handle
                move.w        \handle,-(sp)
                RAIL_MAN      18,6
                .ENDM 

                .MACRO X_SEARCH handle
                move.w        \handle,-(sp)
                RAIL_MAN      19,6
                .ENDM 

                .MACRO X_UPDATED handle
                move.w        \handle,-(sp)
                RAIL_MAN      20,6
                .ENDM 

                .MACRO X_DONE handle,index
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      22,8
                .ENDM 

;
;Die folgenden Funktionen sind erst ab RAIL_MAN-Version 2.20 verfÅgbar. Sie
;kînnen aber bereits jetzt in Quelltexte eingebaut werden, liefern dann aller-
;dings noch den Fehler e_fnimpl
;

                .MACRO E_PAUSE handle,index,number          ;ab Version 2.20
                move.w        \number,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      23,10
                .ENDM 

                .MACRO S_FSWITCH handle,index,mode          ;ab Version 2.20
                move.w        \mode,-(sp)
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      24,10
                .ENDM 

                .MACRO S_ISWITCH handle,index     ;ab Version 2.20
                move.w        \index,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      25,8
                .ENDM 

                .MACRO A_IDENT handle,m,a_n,a_s,a_v,a_d,a_a,a_vec     ;ab Version 2.20
                move.l        \a_vec,-(sp)
                move.l        \a_a,-(sp)          ;Autorkennung (alles Strings)
                move.l        \a_d,-(sp)          ;Erstellungsdatum
                move.l        \a_v,-(sp)          ;Versionsnummer
                move.l        \a_s,-(sp)          ;Anzeige
                move.l        \a_n,-(sp)          ;Name
                move.w        \m,-(sp)
                move.w        \handle,-(sp)
                RAIL_MAN      4,28
                .ENDM 

;Allgemeines zum Aufruf einer RAIL_MAN-Funktion
;==============================================
;
;Das Unterprogramm rail_test muû natÅrlich dem Programm ent-
;sprechend realisiert sein. Es sollte den RÅckgabewert in d0
;auswerten, aber nicht verÑndern. Alle Register sollten ge-
;sichert werden. Ggf. kînnen die Redraw-Messages mit 'andi.l
;#$ffff,d0' gelîscht werden.
;
;rail_test muû sofort vor dem ersten RAIL_MAN-Aufruf
;rail_eflg testen. Falls dieses Flag <>0 ist, so ist das
;Unterprogramm abzubrechen, da es sonst zu einer endlosen Re-
;kursion kommt (zumindest fast - doch irgendwann steht der
;Stack mitten im Programm und es kommt zum Absturz!).
;
;ACHTUNG!!
;In der Redraw-Routine sollte VOR DEM ERSTEN AUFRUF einer
;RAIL_MAN-Funktion (i.A. X_SEARCH) deshalb das Wort rail_eflg
;auf <>0 gesetzt werden. Nach Beendigung ist rail_eflg wieder
;auf 0 zu setzen. Dieses Verhalten kann auch beim Programm-
;start ausgenutzt werden, wenn das Programm noch nicht so weit
;initialisiert ist, daû es schon Redraw-Messages brauchen
;kînnte.
;
;Daraus ergibt sich folgende Vorgehensweise:
;
;               rail_test:    tst.w     rail_eflg
;                             bne       .ende
;                             move.w    #1,rail_eflg
;                             ;
;                             ;hier kommt Ihre Routine
;                             ;
;                             clr.w     rail_eflg
;               .ende:        rts
;
;Zur Ausgabe von Fehlermeldungen Åber das GEM-AES sollen
;mit q_array die Adressen vorgefertigter Alert-Strings er-
;mittelt werden.

                .MACRO RAIL_MAN function,len
                move.w        #\1,-(sp)
                move.w        #253,-(sp)          ;Funktionsnummer
                trap          #1        ;Trap ausfÅhren
                .IF \?2       ;Parameter 2 Åbergeben ?
                .IF \2<=8     ;ja
                addq.l        #\2,sp    ;Stackkorrektur bis 8
                .ELSE 
                lea.l         \2(sp),sp ;Stackkorrektur ab 10
                .ENDIF 
                .ELSE         ;nein
                addq.l        #2,sp
                .ENDIF 
                jsr           rail_test
                .ENDM 


                .BSS 

rail_eflg:      .DS.w 1


