gemdostrap    =        $84
biostrap      =        $b4
xbiostrap     =        $b8


;*******************************************************************************
initial:      move.l 4(sp),a0                    ;restlichen Speicherplatz
              move.l #$100,d7                    ;freigeben
              add.l 12(a0),d7
              add.l 20(a0),d7
              add.l 28(a0),d7
              lea stack,sp
              move.l d7,-(sp)
              move.l a0,-(sp)
              clr.w -(sp)
              move.w #$4a,-(sp)
              trap #1
              lea 12(sp),sp

              lea frage1,a0
              bsr line
              bsr ja_nein
              move d0,screen
              lea frage2,a0
              bsr line
              bsr ja_nein
              move d0,printer
              lea frage3,a0
              bsr line
              bsr ja_nein
              move d0,lf1
              lea frage4,a0
              bsr line
              bsr ja_nein
              move d0,lf2
              lea frage4b,a0
              bsr line
              bsr ja_nein
              move d0,waitflag
              lea fraget1,a0
              bsr line
              bsr ja_nein
              move d0,t1__flag
              lea fraget2,a0
              bsr line
              bsr ja_nein
              move d0,t2__flag
              lea fraget3,a0
              bsr line
              bsr ja_nein
              move d0,t3__flag
              lea frage5,a0
              bsr line
              lea dateiname,a0
              move.b #80,(a0)
              move.l a0,-(sp)
              move #10,-(sp)
              trap #1
              addq.l #2,sp
              move.l (sp)+,a0
              clr.b 2(a0,d0.w)
              lea frage6,a0
              bsr line
              lea command,a0
              move.b #80,(a0)
              move.l a0,-(sp)
              move #10,-(sp)
              trap #1
              addq.l #2,sp
              move.l (sp)+,a0
              clr.b 2(a0,d0.w)
              lea frage7,a0
              bsr line
              lea env,a0
              move.b #80,(a0)
              move.l a0,-(sp)
              move #10,-(sp)
              trap #1
              addq.l #2,sp
              move.l (sp)+,a0
              clr.b 2(a0,d0.w)

              .bss
screen:       ds.w 1
printer:      ds.w 1
lf1:          ds.w 1
lf2:          ds.w 1
waitflag:     ds.w 1
t1__flag:     ds.w 1
t2__flag:     ds.w 1
t3__flag:     ds.w 1

              .data
frage1:       dc.b 13,10,"TRAPPER   Version 1.0    (c)  Manfred Friese"
              dc.b 13,10,"                         2.12.1988",13,10,13,10
              dc.b "Version 1.0 ist Public - Domain",13,10
              dc.b "Voraussetzung: das Programm wird mit Quelltext und Dokumentation",13,10
              dc.b "unverÑndert weitergegeben",13,10,13,10
              dc.b "Fragen, Hinweise auf Fehler oder Anerkennung (in Form von 10 DM Scheinen) an:",13,10
              dc.b "Manfred Friese / Sachsenring 6 / 3200 Hildesheim",13,10,13,10
              dc.b "Ausgabe auf Bildschirm?  ",0
frage2:       dc.b "Ausgabe auf Drucker?     ",0
frage3:       dc.b "Neue Zeile vor Ausgabe?  ",0
frage4:       dc.b "Neue Zeile nach Ausgabe? ",0
frage4b:      dc.b "Warten nach Ausgabe ?    ",0
fraget1:      dc.b "GEMDOS Åberwachen ?      ",0
fraget2:      dc.b "BIOS   Åberwachen ?      ",0
fraget3:      dc.b "XBIOS  Åberwachen ?      ",0
frage5:       dc.b 13,10,"Programmname:",0
frage6:       dc.b 13,10,"Komandozeile:",0
frage7:       dc.b 13,10,"Enviroment:  ",0
              .even

              .text
              move.l #stack-100,stackpointer

              pea init                           ;INIT in Supervisormodus
              move #38,-(sp)                     ;ausfÅhren
              trap #14
              addq.l #6,sp

              pea env+2
              pea command+2
              pea dateiname+2
              clr -(sp)
              move #$4b,-(sp)
              trap #1
              lea 16(sp),sp

              pea exit                           ;EXIT in Supervisormodus
              move #38,-(sp)                     ;ausfÅhren
              trap #14
              addq.l #6,sp

              clr.l -(sp)                        ;und zu GEM
              trap #1


init:         move.l gemdostrap,oldgemdos
              move.l #gdtrapper,gemdostrap
              move.l biostrap,oldbios
              move.l #btrapper,biostrap
              move.l xbiostrap,oldxbios
              move.l #xbtrapper,xbiostrap
              rts

exit:         move.l oldgemdos,gemdostrap
              move.l oldbios,biostrap
              move.l oldxbios,xbiostrap
              rts

;*******************************************************************************
btrapper:     tst t2__flag
              beq .abort
              move.l sp,gemdos_stack              ;Register retten
              move.l stackpointer,sp
              movem.l d0-d7/a0-a6,-(sp)
              lea bios_table,a6
              lea biostxt,a0
              bsr ausgabe
              movem.l (sp)+,d0-d7/a0-a6          ;Register zurÅckholen
              move.l gemdos_stack,sp
.abort:       dc.w %0100111011111001             ;JMP
oldbios:      dc.l 0                             ; zu BIOS

xbtrapper:    tst t3__flag
              beq .abort
              move.l sp,gemdos_stack              ;Register retten
              move.l stackpointer,sp
              movem.l d0-d7/a0-a6,-(sp)
              lea xbios_table,a6
              lea xbiostxt,a0
              bsr ausgabe
              movem.l (sp)+,d0-d7/a0-a6          ;Register zurÅckholen
              move.l gemdos_stack,sp
.abort:       dc.w %0100111011111001             ;JMP
oldxbios:     dc.l 0                             ; zu XBIOS


gdtrapper:    tst t1__flag
              beq .abort
              move.l sp,gemdos_stack              ;Register retten
              move.l stackpointer,sp
              movem.l d0-d7/a0-a6,-(sp)
              lea gemdos_table,a6
              lea gemdostxt,a0
              bsr ausgabe
              movem.l (sp)+,d0-d7/a0-a6          ;Register zurÅckholen
              move.l gemdos_stack,sp
.abort:       dc.w %0100111011111001             ;JMP
oldgemdos:    dc.l 0                             ; zu GEMDOS


ausgabe:      move.l gemdos_stack,a5
              btst #5,(a5)
              bne .not_sv
              move.l usp,a5
              subq #6,a5
.not_sv:      addq #6,a5
              cmp.l #$fc0000,-4(a5)
              bls .user
              rts
.user:        move.l a0,-(sp)
              tst lf1
              beq .nlf
              bsr linefeed
.nlf:         move.l (sp)+,a0
              bsr print
              move (a5)+,d4
              move.l d4,d0
              bsr printhexb
              move.l a6,a4
              tst d4
              beq .out
.one:         tst.b (a4)+
              bne .one
              subq #1,d4
              bne .one
.out:         clr d0
              move.b (a4)+,d0
              beq .ready
              cmp #'1',d0
              bne .not_string

              moveq #' ',d0
              bsr char
              moveq #'"',d0
              bsr char
              move.l (a5)+,a3
.outchar:     clr d0
              move.b (a3)+,d0
              beq .readystr
              bsr char
              bra .outchar
.readystr:    moveq #'"',d0
              bsr char
              bra .out

.not_string:  cmp #'2',d0
              bne .not_word
              move (a5)+,d0
              bsr printhexw
              bra .out

.not_word:    cmp #'3',d0
              bne .not_long
              move.l (a5)+,d0
              bsr printhexl
              bra .out

.not_long:    bsr char
              bra .out

.ready:       tst waitflag
              beq .nowait
              move #2,-(sp)
              move #2,-(sp)
              pea .trapret
              move sr,-(sp)
              move.l oldbios,a0
              jmp(a0)
.trapret:     addq.l #4,sp
.nowait:      tst lf2
              bne linefeed
              rts

              .data
gemdostxt:    dc.b "GEMDOS ",0
biostxt:      dc.b "BIOS   ",0
xbiostxt:     dc.b "XBIOS  ",0
              even
gemdos_stack: dc.l 0
              .text

;*******************************************************************************

line:         move.l a0,-(sp)
              move #9,-(sp)
              trap #1
              addq.l #6,sp
              rts

ja_nein:      move #7,-(sp)
              trap #1
              addq.l #2,sp
              cmp #'j',d0
              beq .ja
              cmp #'J',d0
              beq .ja
              cmp #'n',d0
              beq .nein
              cmp #'N',d0
              bne ja_nein
.nein:        lea neintxt,a0
              bsr line
              clr d0
              rts
.ja:          lea jatxt,a0
              bsr line
              moveq #1,d0
              rts

              .data
neintxt:      dc.b "Nein",13,10,0
jatxt:        dc.b "Ja",13,10,0
              even
              .text

char:         tst screen
              beq .noscr
              move d0,-(sp)
              move #2,-(sp)
              move #3,-(sp)
              pea .trapret
              move sr,-(sp)
              move.l oldbios,a0
              jmp(a0)
.trapret:     addq.l #6,sp
.noscr:       tst printer
              beq .noprt
              move d0,-(sp)
              clr -(sp)
              move #3,-(sp)
              pea .trapret2
              move sr,-(sp)
              move.l oldbios,a0
              jmp(a0)
.trapret2:    addq.l #6,sp
.noprt:       rts

printhexb:    move.l d0,d7
              moveq.l #2,d6
              bra printhex

printhexw:    move.l d0,d7
              moveq.l #4,d6
              bra printhex

printhexl:    move.l d0,d7
              moveq.l #8,d6
              bra printhex

printhex:     move #' ',d0
              bsr char
              move.l d6,d0
              asl #2,d0
              neg d0
              add #32,d0
              rol.l d0,d7
              subq #1,d6
.printhexl:   rol.l #4,d7
              move.l d7,d0
              and #%1111,d0
              add #'0',d0
              cmp #'9',d0
              ble .ok
              add #'A'-'9'-1,d0
.ok:          bsr char
              dbra d6,.printhexl
              move #' ',d0
              bra char

linefeed:     lea linefeedtxt,a0

print:        clr d0
              move.b (a0)+,d0
              beq .ready
              move.l a0,-(sp)
              bsr char
              move.l (sp)+,a0
              bra print
.ready:       rts

              .data
linefeedtxt:  dc.b 13,10,0,0

;*******************************************************************************
              .data
gemdos_table:

DC.B "TERM",0                        ;00
DC.B "CONIN",0                       ;01
DC.B "CONOUT   CHAR2",0              ;02
DC.B "AUXIN",0                       ;03
DC.B "AUXOUT   CHAR2",0              ;04
DC.B "PRTOUT   CHAR2",0              ;05
DC.B "RAWCONIO MODE/CHAR2",0         ;06
DC.B "DCONINWE",0                    ;07
DC.B "CONINWE",0                     ;08
DC.B "PRINT    STRING1",0            ;09
DC.B "READLINE ADR3",0               ;0A
DC.B "CONSTAT",0                     ;0B
DC.B "UNUSED",0                      ;0C
DC.B "UNUSED",0                      ;0D
DC.B "SETDRV   DRIVE2",0             ;0E
DC.B "UNSED",0                       ;0F
DC.B "COUTSTAT",0                    ;10
DC.B "PRTSTAT",0                     ;11
DC.B "AUXINSTAT",0                   ;12
DC.B "AUXOUTSTAT",0                  ;13
DC.B "UNUSED",0                      ;14
DC.B "UNUSED",0                      ;15
DC.B "UNUSED",0                      ;16
DC.B "UNUSED",0                      ;17
DC.B "UNUSED",0                      ;18
DC.B "CURRDISK",0                    ;19
DC.B "SETDTA   ADR3",0               ;1A
DC.B "UNUSED",0                      ;1B
DC.B "UNUSED",0                      ;1C
DC.B "UNUSED",0                      ;1D
DC.B "UNUSED",0                      ;1E
DC.B "UNUSED",0                      ;1F
DC.B "SUPER    ADR3",0               ;20
DC.B "UNUSED",0                      ;21
DC.B "UNUSED",0                      ;22
DC.B "UNUSED",0                      ;23
DC.B "UNUSED",0                      ;24
DC.B "UNUSED",0                      ;25
DC.B "UNUSED",0                      ;26
DC.B "UNUSED",0                      ;27
DC.B "UNUSED",0                      ;28
DC.B "UNUSED",0                      ;29
DC.B "GETDATE",0                     ;2A
DC.B "SETDATE  DATE2",0              ;2B
DC.B "GETTIME",0                     ;2C
DC.B "SETTIME  TIME2",0              ;2D
DC.B "UNUSED",0                      ;2E
DC.B "GETDTA",0                      ;2F
DC.B "VERSION",0                     ;30
DC.B "KEEP     BYTES3 CODE2",0       ;31
DC.B "UNUSED",0                      ;32
DC.B "UNUSED",0                      ;33
DC.B "UNUSED",0                      ;34
DC.B "UNUSED",0                      ;35
DC.B "DSKFREE  ADR3 DRIVE2",0       ;36
DC.B "UNUSED",0                      ;37
DC.B "UNUSED",0                      ;38
DC.B "MKDIR    PATH1",0              ;39
DC.B "RMDIR    PATH1",0              ;3A
DC.B "CHDIR    PATH1",0              ;3B
DC.B "CREATE   FILE1 STATUS2",0      ;3C
DC.B "OPEN     FILE1 STATUS2",0      ;3D
DC.B "CLOSE    HANDLE2",0            ;3E
DC.B "READ     HANDLE2 BYTES3 PUFFER3",0    ;3F
DC.B "WRITE    HANDEL2 BYTES3 PUFFER3",0    ;40
DC.B "UNLINK   FILE1",0                     ;41
DC.B "LSEEK    DIFF3 HANDLE2 MODE2",0       ;42
DC.B "CHMODE   FILE1 ATTR2 STATUS2",0       ;43
DC.B "UNUSED",0                      ;44
DC.B "DUP",0                         ;45
DC.B "FORCE",0                       ;46
DC.B "GETDIR   ADR3 DRIVE2",0        ;47
DC.B "MALLOC   BYTES3",0             ;48
DC.B "MFREE    ADR3",0               ;49
DC.B "SETBLOCK FILLER2 FROM3 BYTES3",0      ;4A
DC.B "EXEC     MODE2 FILE1 COMM1 ENV1",0    ;4B
DC.B "TERM     CODE2",0              ;4C
DC.B "UNUSED",0                      ;4D
DC.B "SFIRST   FILE1 ATTR2",0        ;4E
DC.B "SNEXT",0                       ;4F
DC.B "UNUSED",0                      ;50
DC.B "UNUSED",0                      ;51
DC.B "UNUSED",0                      ;52
DC.B "UNUSED",0                      ;53
DC.B "UNUSED",0                      ;54
DC.B "UNUSED",0                      ;55
DC.B "RENAME   FILLER2 OLD1 NEW1",0         ;56
DC.B "GSDTOF   ADR3 HANDLE2 MODE2",0        ;57

;*******************************************************************************

bios_table:

DC.B "GETMPB   ADR3",0        ;0
DC.B "BCONSTAT DEV2",0        ;1
DC.B "CONIN    DEV2",0        ;2
DC.B "BCONOUT  DEV2 CHAR2",0  ;3
DC.B "RWABS    RWFLAG2 BUFFER3 ANZ2 RECORD2 DEV2",0 ;4
DC.B "SETEXEC  NR2 VECTOR3",0 ;5
DC.B "TICKAL",0               ;6
DC.B "GETBPB   DEV2",0          ;7
DC.B "BCOSTAT  DEV2",0        ;8
DC.B "MEDIACH  DEV2",0        ;9
DC.B "DRVMAP",0               ;10
DC.B "KBSHIFT  MODE2",0       ;11

;*******************************************************************************

xbios_table:

DC.B "INITMOUS TYP2 PARAM3 VECTOR3",0   ;0
DC.B "SSBRK    ANZ2",0                  ;1
DC.B "PHYSBASE",0                       ;2
DC.B "LOGBASE",0                        ;3
DC.B "GETREZ",0                         ;4
DC.B "SETSCRN  LOGADR3 PHYSADR3 RES2",0 ;5
DC.B "SETPALET ADR3",0                  ;6
DC.B "SETCOLOR NR2 COLOR2",0            ;7
DC.B "FLOPRD   BUFFER3 FILLER3 DEV2 SECTOR2 TRACK2 SIDE2 COUNT2",0        ;8
DC.B "FLOPWR   BUFFER3 FILLER3 DEV2 SECTOR2 TRACK2 SIDE2 COUNT2",0        ;9
DC.B "FLOPFMT  BUFFER3 FILLER3 DEV2 SPT2 TRACK2 SIDE2 INTER2 MAGIC3 VIRG2",0 ;10
DC.B "UNUSED",0                         ;11
DC.B "MIDIWS   COUNT2 ADR3",0           ;12
DC.B "MFPINT   NR2 ADR3",0              ;13
DC.B "IOREC    DEV2",0                  ;14
DC.B "RSCONF   BAUD2 CTRL2 UCR2 RSR2 TSR2 SCR2",0      ;15
DC.B "KEYTBL   UNSHIFT3 SHIFT3 CAPSLOCK3",0            ;16
DC.B "RANDOM",0                         ;17
DC.B "PROTOBT  BUFFER3 SERIAL3 DISKTYP2 EXEC2",0       ;18
DC.B "FLOPVER  BUFFER3 FILLER3 DEV2 SECTOR2 TRACK2 SIDE2 COUNT2",0        ;19
DC.B "SCRDMP",0                         ;20
DC.B "CURSCONF FKT2 RATE2",0            ;21
DC.B "SETTIME  TIME3",0                 ;22
DC.B "GETTIME",0                        ;23
DC.B "BIOSKEYS",0                       ;24
DC.B "IKBDWS   ANZ2 ADR3",0             ;25
DC.B "JDISINT  NR2",0                   ;26
DC.B "JENABINT NR2",0                   ;27
DC.B "GIACCESS DATA2 REG2",0            ;28
DC.B "OFFGIBIT MASKE2",0                ;29
DC.B "ONGIBIT  MASKE2",0                ;30
DC.B "XBTIMER  TIMER2 CONTROL2 DATA2 ADR3",0           ;31
DC.B "DOSOUND  ADR3",0                  ;32
DC.B "SETPRT   CONFIG2",0               ;33
DC.B "KBDVBASE",0                       ;34
DC.B "KBRATE   VERZ2 WDH2",0            ;35
DC.B "PRTBLK   PARAM3",0                ;36
DC.B "WVBL",0                           ;37
DC.B "SUPEXEC  ADR3",0                  ;38
DC.B "PUNTAES",0                        ;39


;*******************************************************************************
              .bss
              .even
dateiname:    ds.b 82
command:      ds.b 82
env:          ds.b 82
stackpointer:
              ds.l 500
stack:
