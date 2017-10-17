;==================================================
; Y2K-Fix fr XBIOS Settime/Gettime
; Freeware V. 0.9, von Ingo Linkweiler
; visit me at: www.icc-computer.de/starcall
; behebt TOS-Y2K-Fehler im Zeitraum von 2000-2015
; danach kleine Anpassung n”tig.
;
; getestet auf TOS 2.6, sollte aber mit jedem TOS laufen
;==================================================

            GLOBAL main,vt,vt_pas,vt_out

            >PART 'Definitions'
;:   Offsets in die base-page

            TEXT

;LineA -Emulator
la_curx     EQU -$1C
la_cury     EQU -$1A
la_maxx     EQU -$2C
la_maxy     EQU -$2A

prglen      EQU $0C
datalen     EQU $14
bsslen      EQU $1C
cmdlin      EQU $80

;:   Systemvariablen

hdv_bpb     EQU $0472              ;Bios Parameterblock
hdv_rw      EQU $0476
hdv_media   EQU $047E
phystop     EQU $042E
_memtop     EQU $0436

drvbits     EQU $04C2

xbios       EQU 14
tos         EQU 1

keepterm    EQU $31
supexec     EQU 38

;================================
            ENDPART
            >PART 'Hauptprogramm'
;========== fr Compilierung als Programm ===========

main::      movea.l 4(sp),a0       ;Adresse base page
            lea stackend(pc),sp    ;Mein STACK anlegen

            move.l #$0100,d0       ;L„nge Basepage
            add.l prglen(a0),d0    ;L„nge Text
            add.l datalen(a0),d0   ;L„nge Data
            add.l bsslen(a0),d0    ;L„nge BSS

            move.l d0,baslen
            move.l a0,-(sp)
            move.l d0,-(sp)        ;Ergebnis auf SP
            move.l a0,-(sp)        ;BASEPAGE auf SP
            clr.w -(sp)            ;immer 0
            move.w #$4A,-(sp)      ;Mshrink
            trap #1                ;GEMdos
            lea 12(sp),sp          ;STack korrektur
            movea.l (sp)+,a0

            pea info(pc)
            move.w #9,-(sp)        ;Message ausgeben
            trap #1
            addq.l #6,sp

            pea init_bi(pc)        ;BIOS installieren
            move.w #supexec,-(sp)
            trap #xbios
            addq.l #6,sp

            tst.w merk
            bne.s pterm0

ptermres:   clr.w -(sp)            ;ENDE!
            move.l baslen(pc),-(sp)
            move.w #49,-(sp)
            trap #tos
            rts

pterm0:
            pea info2(pc)
            move.w #9,-(sp)        ;Message ausgeben
            trap #1
            addq.l #6,sp


            clr.w -(sp)            ; Bye..
            trap #tos
            ENDPART

            >PART 'De-Installation'
;===========================================================
; Alles installierten Routienen wieder raus.
;===========================================================

remove:     move.l xbrabios(pc),$B8
deinsx:     rts

            ENDPART
            >PART 'Installation'
;=====================================
; Bios-umleitung installieren
;=====================================
init_bi:    lea xbret(pc),a3
            addq.l #2,a3
            movea.l #$B8,a4        ;Xbios Vektor sichern
            move.l (a4),(a3)
            move.l (a4),xbrabios

            movea.l $B8,a4
            cmpi.l #'ILVT',-8(a4)
            beq.s init_err

            move.l #nxbio,$B8      ;Xbios auf eigene Routiene
            clr.w merk
            rts

init_err:   move.w #1,merk
            rts
            ENDPART
            PART 'Neuer BIOS-Vector'

            DC.B 'XBRAILVT'
xbrabios:   DC.L 0

nxbio:      cmpi.w #1,xb_disable   ;Xbios z.Z. inaktiv, original benutzen?
            beq.s xbret

            move.l a1,rett         ;Unsere Umleitung:
            movea.l sp,a1
            move.w (a1)+,ddo
            addq.l #4,a1

            tst.w $059E            ;Bin ich ein 68000er?
            beq.s n68000           ;Ja!
            addq.w #2,a1           ;680X0-er Stackkorrektur.
n68000:     andi.w #$2000,ddo      ;btst #$d,ddo ;Supervisor an?
            bne.s noc
            move usp,a1            ;Superstack benutzen!

noc:        cmpi.w #23,(a1)        ;neues Gettime
            beq.s ngettime
            cmpi.w #22,(a1)
            beq.s nsettime
nbcx:       movea.l rett(pc),a1

xbret:      jmp $0F0000            ;Dummy, JMP SYSTEM

;------- Das neue gettime:

ngettime:   move.w #1,xb_disable   ;eigenes Xbios deaktivieren
            movem.l d1-a6,-(sp)

            move.w #23,-(sp)
            trap #14               ;System-Gettime aufrufen
            addq.l #2,sp

;Jahreszahl auf 4 Bit ab 1980 reduzieren
            and.l #%11111111111111111111111111111,d0
;                jjjjjjjmmmmtttttsssssmmmmmmsssss

            move.l #20,d1          ;2000 = 1980+20
            ror.l #7,d1

;Nun 20 Jahre dazurechnen
            add.l #%101000000000000000000000000000,d0
            movem.l (sp)+,d1-a6

            clr.w xb_disable       ;Eigenes Xbios aktivieren
            rte

;------- Das neue settime:

nsettime:   move.w #1,xb_disable   ;eigenes Xbios deaktivieren

            movem.l d1-a6,-(sp)
;von der Jahreszahl 20 Jahre abziehen
            move.l 2(a1),d0
            move.l d0,datum
            sub.l #%101000000000000000000000000000,d0

            move.l d0,-(sp)
            move.w #22,-(sp)
            trap #14               ;System-Settime
            addq.l #6,sp
;jetzt nochmal settime aufrufen mit der "richtigen" Zeit.
;Xbios ignoriert die "richtige" Zeit, reicht sie aber ans Gemdos weiter.
;So stimmen dann beide Uhren.

            move.l datum,d0

            move.l d0,-(sp)
            move.w #22,-(sp)
            trap #14               ;System-Settime
            addq.l #6,sp
;jetzt nochmal settime aufrufen mit der "richtigen" Zeit.

            movem.l (sp)+,d1-a6

            clr.w xb_disable       ;Eigenes Xbios wieder aktivieren
            rte

;-----------------------------------------------------

            ENDPART

;           DATA
            PART 'Data-Segment'
info:       DC.B 13,10,10
            DC.B 'Xbios Y2K-Fix resident installed.',13,10
            DC.B '--==>> InLi-Software <<==--      ',13,10
            DC.B 'Visit me: www.icc-computer.de/starcall',13,10
            DC.B 'I.Linkweiler, Marktstr.48, 45711 Datteln',13,10,10,0
            EVEN

info2:      DC.B 13,10,'Error, installed 2x ?',13,10,0

            ENDPART
            PART 'Variablen'
;            BSS
datum:      DS.L 1
xb_disable: DS.W 1
merk:       DS.L 1
rett:       DS.L 1
crs_stat:   DS.W 1
ddo:        DS.L 1
baslen:     DS.L 1
handle:     DS.W 1
ttp_flag:   DS.W 1

;---- Font Attribute, Zust„nde...
xsp_puf:    DS.L 1

            DS.L 100               ;Platz fr Stack
stackend:   DS.L 4
            DS.W 64
line_a_mem: DS.W 1

            ENDPART
            END
