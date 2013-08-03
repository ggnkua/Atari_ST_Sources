********************************************************************************
*                                                                              *
*                              C64-Emulator V3.0                               *
*                             Ω 1987 by Uwe Seimet                             *
*                             Buchenlochstraûe 29                              *
*                             6750 Kaiserslautern                              *
*                                                                              *
*                       Linkreihenfolge: C64.O,VC.O,EMULATOR.O                 *
*                                                                              *
********************************************************************************


GEMDOS  = 1

PROUT   = $05
SETDRV  = $0E
DFREE   = $36
CREATE  = $3C
OPEN    = $3D
CLOSE   = $3E
READ    = $3F
WRITE   = $40
UNLINK  = $41
CHMODE  = $43
MALLOC  = $48
MFREE   = $49
SFIRST  = $4E
SNEXT   = $4F
RENAME  = $56


        globl vc1541
        globl vcopen
        globl vcclose
        globl vcread
        globl vcwrite
        globl vcchkin
        globl vckout
        globl compnt
        globl dta
        globl fsave
        globl fload
        globl file
        globl printer
        globl prfont
        

        text

fload:
        move.b d6,$c3(a6)
        move.b d7,$c4(a6)
        move.b d5,$93(a6)
        clr.b $90(a6)
        bsr iopar
        lea c64+$f0c9,a2                *"SEARCHING"
        bsr print
        lea c64+$f0d4,a2                *"FOR"
        bsr print
        lea file,a2
        bsr print
        cmp.b #"$",file
        beq cat
        clr -(sp)
        pea file
        move #SFIRST,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst d0
        beq ld0
        move #$f704,d0
        bra ret64
ld0:    tst.b $93(a6)
        bne ver
        lea c64+$f106,a2                *"LOADING"
        bsr print
        clr -(sp)
        pea file
        move #OPEN,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        move d0,d2
        bmi loaderr
        pea $ae(a6)
        pea 2
        move d2,-(sp)
        move #READ,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi loaderr
        tst.b $b9(a6)
        bne sadr
        move.b d6,$ae(a6)
        move.b d7,$af(a6)
sadr:   clr.l d0
        move.b $af(a6),d0
        asl #8,d0
        move.b $ae(a6),d0
        pea (a6,d0.l)
        move.l dta+26,-(sp)
        move d2,-(sp)
        move #READ,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi loaderr
        move d2,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        tst d0
        bmi loaderr
        move.b dta+28,d0
        add.b dta+29,d6
        addx.b d0,d7
        subq.b #2,d6
        bcc ld9
        subq.b #1,d7
ld9:    move.b d6,$ae(a6)
        move.b d7,$af(a6)
        bra ok
ver:    lea c64+$f116,a2                *"VERIFYING"
        bsr print
        bra ok

loaderr:
        or.b #$bf,$90(a6)
        or.b #$11,d4
        moveq #$1d,d5
        rts

cat:    lea c64+$f106,a2
        bsr print
        tst.b $b9(a6)
        beq scat
        move.b #$01,$c3(a6)
        move.b #$04,$c4(a6)
scat:   clr.l d0
        move.b $c4(a6),d0
        asl #8,d0
        move.b $c3(a6),d0
        lea (a6,d0.l),a2
        bsr odir
        move.l a2,d0
        sub.l a6,d0
        move.b d0,d6
        lsr #8,d0
        move.b d0,d7
        bra ld9

fsave:
        move.b d6,$ae(a6)
        move.b d7,$af(a6)
        lea (a6,d5),a0
        move.b (a0),$c1(a6)
        move.b 1(a0),$c2(a6)
        bsr iopar
        lea c64+$f10e,a2
        bsr print
        lea file,a2
        bsr print
        clr -(sp)
        pea file
        move #CREATE,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        move d0,d2
        bmi saveerr
        pea $c1(a6)
        pea 2
        move d2,-(sp)
        move #WRITE,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi saveerr
        move.b $c2(a6),d0
        asl #8,d0
        move.b $c1(a6),d0
        move.l d7,d1
        asl #8,d1
        move.b d6,d1
        sub d0,d1
        bcs saveerr
        pea (a6,d0)
        move.l d1,-(sp)
        move d2,-(sp)
        move #WRITE,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi saveerr
        move d2,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        tst d0
        bpl ok
saveerr:move #$f70d,d0                  *"NOT OUTPUT FILE"
        bra ret64

iopar:
        move #$f713,d0                  *"ILLEGAL DEVICE NUMBER"
        move.b $ba(a6),d3
        cmp.b #1,d3
        bgt io0
        move.b drv(pc),d3
io0:    cmp.b #8,d3
        blt iret64
        cmp.b #17,d3
        bgt iret64
        move #$f710,d0                  *"MISSING FILENAME"
        tst.b $b7(a6)
        beq iret64
io4:    move.b d3,drv
        subq.b #8,d3
        move d3,-(sp)
        move #SETDRV,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        move.b $b7(a6),d3
        clr.l d0
        lea $bb(a6),a1
        move.b 1(a1),d0
        asl #8,d0
        move.b (a1),d0
        lea (a6,d0.l),a1
        lea file,a0
        clr.b (a0,d3)
        subq.b #1,d3
io1:    move.b (a1,d3),(a0,d3)
        dbf d3,io1
        clr d3
        rts
iret64: addq.l #4,sp
        bra ret64
        
vc1541:
        clr.b track                     *Spur und Sektor
        clr.b sector
        lea file,a0
        move.l compnt(pc),d0
        sub.l a0,d0
        tst.b d0                        *LÑnge der Kommandozeile
        beq ok                          *kein Kommando-
        cmp.b #$0d,(a0)
        beq ok                          *kein Kommando-
        move.b (a0),d1
        moveq #$0b,d0                   *Anzahl der Befehle
        lea com(pc),a1
flp0:   cmp.b (a1,d0),d1
        beq flp
        dbf d0,flp0
        bra err2
flp:    asl #2,d0
        lea adr(pc),a1
        move.l (a1,d0),a1
        moveq #$3a,d0                   *":"
        bsr find
        jsr (a1)
        rts

*File îffnen, logische Filenummer in D0
vcopen:
        clr.b teof
        move.b d0,tmp                   *logische Filenummer
        move.b $ba(a6),d3               *GerÑteadresse
        bsr io4                         *Filename nach A0
        moveq #$2c,d0                   *","
        bsr find                        *suchen
        bne readf                       *nicht gefunden-File lesen
        clr.b (a0,d0)                   *Ende des Filenamens markieren
        cmp.b #"S",1(a0,d0)             *SEQ?
        beq seq                         *ja-
        cmp.b #"P",1(a0,d0)             *PRG?
        bne err4                        *nein-
seq:    cmp.b #",",2(a0,d0)             *Komma?
        bne err4                        *nein-
        cmp.b #"R",3(a0,d0)             *File lesen?
        beq readf                       *ja-
        cmp.b #"W",3(a0,d0)             *File schreiben
        bne err4                        *nein-
        st rwflg                        *Flag fÅr Schreiben
        clr -(sp)
        pea file
        move #CREATE,-(sp)
        bra readf1
readf:  clr.b rwflg
        moveq #-1,d0                    *Dummy-Handle
        cmp.b #"$",file                 *Directory?
        beq odi                         *ja-
        clr -(sp)
        pea file
        move #OPEN,-(sp)
readf1: trap #GEMDOS
        addq.l #8,sp
        tst d0
        bmi err4
odi:    clr d1
        move.b $98(a6),d1               *Position des Fileeintrags
        subq.b #1,d1                    *Position in Liste
        lea filenr,a0
        move.b tmp,(a0,d1)              *logische Filenummer
        lea eofs,a0
        clr.b (a0,d1)                   *EOF-Flag lîschen
        lea rwflgs,a0
        move.b rwflg,(a0,d1)            *Flag fÅr Lesen/Schreiben
        add d1,d1
        lea fhandle,a0
        move d0,(a0,d1)                 *Handle merken
        lea fillen,a0
        clr (a0,d1)                     *keine gÅltigen Bytes
        add d1,d1
        move d1,d0
        lea bufpnt,a0
        mulu #$0400,d0                  *Bufferadresse berechnen
        add.l #filbuf,d0
        move.l d0,(a0,d1)               *Adresse fÅr Schreiben/Lesen
        rts

vcread:
        move.b $b9(a6),d0
        and.b #$0f,d0
        cmp.b #$0f,d0                   *Kommandokanal?
        beq readc                       *ja-
        tst tlen
        bne fil1
        st d5                           *Byte an Dateiende
        tst.b teof                      *Dateiende?
        bne eof                         *ja-
        bsr vcr1                        *nÑchsten Block lesen
fil1:   move.l tpnt(pc),a0
        move.b (a0)+,d5
        move.l a0,tpnt
        subq #1,tlen
        bne eof
        tst.b teof
        beq eof
ceof:   or.b #$40,$90(a6)               *EOF
eof:    and.b #$ee,d4
        rts
vcr1:   tst thand                       *Directory-File?
        bmi getdir                      *ja-
        move.l bufadr(pc),-(sp)         *Bufferadresse
        pea $1000
        move thand,-(sp)
        move #READ,-(sp)
        trap #GEMDOS
        add.l #12,sp
        move d0,tlen
        bmi err4
        cmp #$1000,d0
        beq noeof
gdir:   st teof
noeof:  move.l bufadr(pc),tpnt
        rts
getdir: move.l bufadr(pc),a2
        bsr opdir
        sub.l bufadr(pc),a2
        move a2,tlen
        bsr ok
        bra gdir
readc:  move.l compnt(pc),a0
        move.b (a0)+,d5
        move.l a0,compnt
        tst.b (a0)
        bne eof
        bsr ok
        bra ceof

vcwrite:
        move.b $b9(a6),d0
        and.b #$0f,d0
        cmp.b #$0f,d0                   *Kommandokanal?
        beq wcom                        *ja-
        move.l tpnt(pc),a0
        move.b d5,(a0)+
        move.l a0,tpnt
        addq #1,tlen
        cmp #$1000,tlen
        bne nowr
        move.l bufadr(pc),-(sp)         *Bufferadresse
        pea $1000
        move thand,-(sp)
        move #WRITE,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi err4
        clr tlen
        move.l bufadr(pc),tpnt
        bra nowr
wcom:   move.l compnt(pc),a0
        move.b d5,(a0)+
        move.l a0,compnt
nowr:   and.b #$ee,d4
        rts

*File schlieûen, logische Filenummer in D0
vcclose:
        bsr getfil                      *Nummer in Tabelle holen
        lea rwflgs,a0
        tst.b (a0,d1)                   *Lesen?
        beq cls1                        *ja-
        move d1,d0
        lea bufpnt,a0
        mulu #$1000,d0                  *Bufferadresse berechnen
        add.l #filbuf,d0
        move.l d0,-(sp)                 *Adresse fÅr Schreiben/Lesen
        add d1,d1
        lea fillen,a0
        clr.l d0
        move (a0,d1),d0
        move.l d0,-(sp)                 *BlocklÑnge
        lea fhandle,a0
        move (a0,d1),-(sp)              *File-Handle
        move #WRITE,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi err4
        bra cls2
cls1:   add d1,d1
cls2:   lea fhandle,a0
        tst (a0,d1)                     *Directory-File?
        bmi clcom                       *ja-
        move (a0,d1),-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
clcom:  rts

*Ein-/Ausgabe auf IEC-Bus, logische Filenummer in D0
vcchkin:
vckout:
        tst onr
        beq fchk
        move onr,d1
        subq #1,d1
        lea eofs,a0
        move.b teof,(a0,d1)             *EOF-Flag
        add d1,d1
        lea fillen,a0
        move tlen,(a0,d1)               *BlocklÑnge
        add d1,d1
        lea bufpnt,a0
        move.l tpnt(pc),(a0,d1)         *Bufferpointer
fchk:   bsr getfil                      *Parameter holen
        move d1,onr
        addq #1,onr                     *als gÅltig markieren
        move d1,d0
        lea eofs,a0
        move.b (a0,d1),teof             *EOF-Flag
        add d1,d1
        lea fillen,a0
        move (a0,d1),tlen               *BlocklÑnge
        lea fhandle,a0
        move (a0,d1),thand              *File-Handle
        add d1,d1
        lea bufpnt,a0
        move.l (a0,d1),tpnt             *Bufferpointer
        mulu #$1000,d0                  *Bufferadresse berechnen
        lea filbuf,a0
        add.l d0,a0
        move.l a0,bufadr                *Adresse fÅr Schreiben/Lesen
        rts

getfil:
        lea filenr,a0
gf:     cmp.b (a0)+,d0
        bne gf
        sub.l #filenr+1,a0
        move a0,d1
        rts

opdir:
        move #$0401,(a2)+       *Programmstart bei $0400
odir:   st (a2)+                *Dummy fÅr Zeilennummer
        st (a2)+
        move.b $ba(a6),(a2)     *Drivenummer
        subq.b #8,(a2)+
        clr.b (a2)+
        move.b #$12,(a2)+       *RVS ON
        move.b #$22,(a2)+
        lea dta,a1
        move #$08,-(sp)         *Diskname suchen
        pea joker(pc)           *"*.*"
        move #SFIRST,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst d0
        bne vol1
vol0:   tst.b 30(a1,d0)
        beq vol2
        move.b 30(a1,d0),(a2)+  *Diskname Åbertragen
        addq.b #1,d0
        bra vol0
vol1:   clr d0        
vol2:   cmp.b #16,d0
        beq vol3
        move.b #" ",(a2)+
        addq.b #1,d0
        bra vol2
vol3:   lea format(pc),a0       *"ST 2A"
vol4:   move.b (a0)+,(a2)+
        bne vol4
        move #$01,-(sp)
        pea joker(pc)           *"*.*"
        move #SFIRST,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst d0
        bne dir0                *nicht gefunden-
dir9:   bsr dir                 *Directoryeintrag erzeugen
        move #SNEXT,-(sp)
        trap #GEMDOS
        addq.l #2,sp
        tst d0
        beq dir9                *nÑchste Datei-
dir0:   clr -(sp)
        lea buffer,a1
        move.l a1,-(sp)
        move #DFREE,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        move.l (a1),d0
        mulu 14(a1),d0          *Disk-Speicherplatz berechnen
        mulu 10(a1),d0
        divu #256,d0
        st (a2)+                *Dummy-Zeilennummer
        st (a2)+
        move.b d0,(a2)+         *Platz auf Disk
        lsr #8,d0
        move.b d0,(a2)+
        lea free(pc),a0         *"BLOCKS FREE."
dira:   move.b (a0)+,(a2)+
        bne dira
        clr.b (a2)+             *Programmende
        clr.b (a2)+
        rts

dir:
        st (a2)+                *Dummy-Zeilennummer
        st (a2)+
        move.l 26(a1),d0        *DateilÑnge
        add.l #258,d0           *Blockzahl berechnen
        divu #254,d0
        move.b d0,(a2)+
        ror #8,d0
        move.b d0,(a2)+
        ror #8,d0
        cmp #10,d0
        bge dir3
        move.b #" ",(a2)+
dir3:   cmp #100,d0
        bge dir4
        move.b #" ",(a2)+
dir4:   move.b #" ",(a2)+
        move.b #$22,(a2)+       *Beginn des Filenamens
        clr d0
dir1:   move.b 30(a1,d0),d1
        beq dir6                *Ende des Filenamens-
        cmp.b #".",d1
        beq dir6
        move.b d1,(a2)+
        addq.b #1,d0
        bra dir1
dir6:   move.b #$22,(a2)+       *Ende des Filenamens
        move.b d0,d3
dir2:   cmp.b #17,d0
        beq dir5
        move.b #" ",(a2)+       *Mit Spaces fÅllen
        addq.b #1,d0
        bra dir2
dir5:   tst.b 30(a1,d3)         *Extension?
        beq dir7                *nein-
        tst.b 31(a1,d3)
        bne di0                 *Extension untersuchen
dir7:   move.b #" ",(a2)+
        move.b #" ",(a2)+
        move.b #" ",(a2)+
        bra di3                 *Keine Extension
di0:    move.b 31(a1,d3),(a2)+
        tst.b 32(a1,d3)
        bne di1
        move.b #" ",(a2)+
        move.b #" ",(a2)+
        bra di3
di1:    move.b 32(a1,d3),(a2)+
        tst.b 33(a1,d3)
        bne di2
        move.b #" ",(a2)+
        bra di3
di2:    move.b 33(a1,d3),(a2)+
di3:    btst #0,21(a1)
        beq dirb                *ungeschÅtztes File-
        move.b #"<",(a2)+       *geschÅtztes File kennzeichnen
dirb:   clr.b (a2)+             *Zeilenende
        rts

ok:     lea msg0(pc),a0
        and.b #$ee,d4
        bra err
err1:   lea msg1(pc),a0
        bra err
err2:   lea msg2(pc),a0
        bra err
err3:   lea msg3(pc),a0
        bra err
err4:   lea msg4(pc),a0
        bra err
err5:   lea msg5(pc),a0
err:    lea file,a1
        move.l a1,compnt
cerr:   move.b (a0)+,(a1)+
        bne cerr
        move.b #",",-1(a1)
        move.b track,d0
        bsr asc
        move.b #",",(a1)+
        move.b sector,d0
asc:    move.b #"0"-1,d1
asc0:   addq.b #1,d1
        sub.b #10,d0
        bcc asc0
        add.b #10,d0
        move.b d1,(a1)+
        add.b #"0",d0
        move.b d0,(a1)+
        clr.b (a1)
        rts

validate:
        bra ok

init:
        bra ok

memory:
        bra ok

block:
        bra ok

user:
        cmp.b #"9",1(a0)
        beq err3                *"VC 1541 EMULATOR"
        bra ok

record:
        bra ok

lbl:
        bra ok

copy:
        bne err2                *kein Doppelpunkt-
        lea 1(a0,d0),a2
        move.l a2,a0
        moveq #$3d,d0           *"="
        bsr find                *suchen
        bne err2
        tst.b 1(a0,d0)
        beq err2                *kein Filename-
        move.b d0,d3
        clr.b (a0,d0)           *Ende des Filenamens markieren
        clr -(sp)
        move.l a2,-(sp)         *neuer Filename
        move #SFIRST,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst d0
        beq err5                *"FILE EXISTS"
        move.l dta+26,-(sp)
        move #MALLOC,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        tst.l d0
        bmi ok
        move.l d0,d2
        clr -(sp)
        pea 1(a2,d3)
        move #OPEN,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst.l d0
        bmi cok
        move d0,d3
        move.l d2,-(sp)
        move.l dta+26,-(sp)
        move d3,-(sp)
        move #READ,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi cok
        move d3,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        tst d0
        bmi cok
        clr -(sp)
        move.l a2,-(sp)
        move #CREATE,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst.l d0
        bmi cok
        move d0,d3
        move.l d2,-(sp)
        move.l dta+26,-(sp)
        move d3,-(sp)
        move #WRITE,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst.l d0
        bmi cok
        move d3,-(sp)
        move #CLOSE,-(sp)
        trap #GEMDOS
        addq.l #4,sp
cok:    move.l d2,-(sp)
        move #MFREE,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        clr.l d2
        bra ok

rename:
        bne err2                *kein Doppelpunkt-
        lea 1(a0,d0),a2
        move.l a2,a0
        moveq #$3d,d0           *"="
        bsr find                *suchen
        bne err2
        move.b d0,d3
        clr.b (a0,d0)           *Ende des Filenamens markieren
        clr -(sp)
        move.l a2,-(sp)         *neuer Filename
        move #SFIRST,-(sp)
        trap #GEMDOS
        addq.l #8,sp
        tst d0
        beq err5                *"FILE EXISTS"
        move.l a2,-(sp)
        pea 1(a2,d3)
        clr -(sp)
        move #RENAME,-(sp)
        trap #GEMDOS
        add.l #12,sp
        tst d0
        beq ok
        bra err4                *"FILE NOT FOUND"

scratch:
        bne err2                *kein Doppelpunkt-
s2:     lea 1(a0,d0),a2
        tst.b (a2)
        beq err1                *kein Filename-
        move.l a2,a0
        moveq #$2c,d0           *Komma
        bsr find                *suchen
        clr.b (a0,d0)
s4:     move.l a2,-(sp)
        move #UNLINK,-(sp)
        trap #GEMDOS
        addq.l #6,sp
        tst d0
        bmi s3
        addq.b #1,track         *zÑhlt gelîschte Files
        bra s4                  *nÑchstes File
s3:     move.l a2,a0
        clr d0
        bsr find
        bra s2                  *nÑchstes File-

new:
        bra ok

toggle:
        bne err2                *kein Doppelpunkt-
t2:     lea 1(a0,d0),a2
        tst.b (a2)
        beq ok                  *kein Filename-
        move.l a2,a0
        moveq #$2c,d0           *Komma
        bsr find                *suchen
        clr.b (a0,d0)
t4:     clr.l -(sp)
        move.l a2,-(sp)
        move #CHMODE,-(sp)
        trap #GEMDOS
        add.l #10,sp
        tst d0
        bmi t3
        bchg #0,d0
        move d0,-(sp)
        move #$01,-(sp)
        move.l a2,-(sp)
        move #CHMODE,-(sp)
        trap #GEMDOS
        add.l #10,sp
t3:     move.l a2,a0
        clr d0
        bsr find
        bra t2                  *nÑchstes File-

*Zeichen in D0 suchen, Pointer auf String in A0, Position in D0
find:
        move.b d0,d1
        clr d0
find1:  move.b (a0,d0),d2
        beq nfound
        cmp.b d2,d1
        beq found
        addq #1,d0
        bra find1
nfound: and #$fb,ccr
found:  rts

*Druckeremulation
printer:
        move.b $b9(a6),d3
        bmi sa0
        and.b #$0f,d3
        asl.b #2,d3
        move.l saadr(pc,d3),a0
        jmp (a0)

saadr:  dc.l sa0,sa1,sa2,sa3,sa4,sa5,sa6,sa7,sa8,sa9,sa10

out:    cmp.b #$0a,d5
        beq prrt
        move d5,d0
        bsr prout
        cmp.b #$0d,d5
        bne prrt
        moveq #$0a,d0
        bsr prout
        clr.b revflg
        clr.b qflg
        clr chrpnt
prrt:   rts

spc:
        moveq #$20,d0
        bra prout
cr:
        clr chrpnt
        clr.b revflg
        clr.b qflg
        moveq #$0d,d0
        bra prout

sa0:    clr.b caseflg
sa1:
        cmp.b #$0d,d5
        beq crout
        cmp.b #$22,d5
        bne quote
        not.b qflg
        bra qout
quote:  tst.b qflg
        bne qout
        cmp.b #$12,d5
        bne rev
        st revflg
        rts
rev:    cmp.b #$92,d5
        bne norev
        clr.b revflg
        rts
norev:  cmp.b #$11,d5
        bne nolo
        st caseflg
        rts
nolo:   cmp.b #$91,d5
        bne noup
        clr.b caseflg
        rts
noup:   cmp.b #$01,d5
        bne enh
        st expflg
        rts
enh:    cmp.b #$81,d5
        bne noenh
        clr.b expflg
        rts
noenh:  cmp.b #$1d,d5
        beq spc
        cmp.b #$8d,d5
        beq cr
        cmp.b #$20,d5
        bcs out
qout:   cmp.b #$fe,d5
        beq defchr
        move.l d5,d0
        tst.b d0
        bmi grprnt
        cmp.b #$20,d0
        blt qcode
        cmp.b #$60,d0
        blt code1
        and.b #$df,d0
        bra normal
code1:  and.b #$3f,d0
        bra normal
grprnt: and.b #$7f,d0
        cmp.b #$20,d0
        blt qcode1
        cmp.b #$7f,d0
        bne nopi
        moveq #$5e,d0
        bra normal
qcode1: or.b #$40,d0
qcode:  or.b #$80,d0
        bra normal
nopi:   or.b #$40,d0
normal: asl #3,d0
        tst.b caseflg
        beq nosml
        add.l #2048,d0
nosml:  lea prfont,a1
        add.l d0,a1
        bra nodef
defchr: lea char,a1
nodef:  moveq #7,d2
        move.l pbufpnt(pc),a0
setout: move.b (a1)+,d3
        tst.b revflg
        beq norev2
        not.b d3
norev2: move.b d3,(a0)+
        tst.b expflg
        beq noexp2
        move.b d3,(a0)+
noexp2: dbf d2,setout
        move.l a0,pbufpnt
        rts

crout:
        cmp.l #prbuf,pbufpnt
        beq out
        lea grprt(pc),a1
grout:  move.b (a1)+,d0
        bmi grend
        bsr prouta
        bra grout
grend:  move.l pbufpnt(pc),a1
        sub.l #prbuf,a1
        move a1,d0
        bsr prouta
        move a1,d0
        lsr #8,d0
        bsr prout
        move a1,d2
        subq #1,d2
        lea prbuf,a1
        move.l a1,pbufpnt
eplop:  move.b (a1)+,d0
        bsr prouta
        dbf d2,eplop
        bra out

sa3:
        moveq #$43,d2
        bra sa6_1

sa5:
        cmp #$08,chrpnt
        beq sa4
        move chrpnt,d0
        lea char,a0
        move.b d5,(a0,d0)
        addq #1,chrpnt
sa4:    rts

sa6:
        moveq #$41,d2
sa6_1:  bsr esc
        move d5,d0
        bra prout

sa7:
        st caseflg
sa2:    rts

sa8:
        clr.b caseflg
sa9:    rts

sa10:
        moveq #$40,d2

esc:
        moveq #$1b,d0
        bsr prout
        move d2,d0
prouta: and #$ff,d0        
prout:  move d0,-(sp)
        move #PROUT,-(sp)
        trap #GEMDOS
        addq.l #4,sp
        rts


com:    dc.b "VIDMUP&CRSNT"

adr:    dc.l validate,init,memory
        dc.l block,user,record,lbl
        dc.l copy,rename,scratch,new
        dc.l toggle

drv:    dc.b 8                          *letzter Drive

joker:  dc.b "*.*",0

format: dc.b $22," ST 2A",0

free:   dc.b "BLOCKS FREE.",0

compnt: dc.l file+3                     *Default fÅr Floppy-Reset

msg0:   dc.b "00, OK",0
msg1:   dc.b "01, FILES SCRATCHED",0
msg2:   dc.b "30,SYNTAX ERROR",0
msg3:   dc.b "73,VC 1541 EMULATOR",0
msg4:   dc.b "63,FILE NOT FOUND",0
msg5:   dc.b "62,FILE EXISTS",0

pbufpnt:dc.l prbuf

grprt:  dc.b $1b,$2a,$04,$ff

bufadr: ds.l 1                  *aktuelle Bufferadresse

tpnt:   ds.l 1                  *aktueller Bufferpointer


        bss

track:  ds.b 1

sector: ds.b 1

filbuf: ds.b $1000*10           *File-Buffer

bufpnt: ds.l 10                 *Bufferpointer

fhandle:ds 10                   *File-Handles

fillen: ds 10                   *BlocklÑngen

filenr: ds.b 10                 *logische Filenummern

eofs:   ds.b 10                 *EOF-Flags

rwflgs: ds.b 10                 *Flags fÅr Lesen/Schreiben

tlen:   ds 1                    *aktuelle BlocklÑnge

thand:  ds 1                    *aktuelles File-Handle

teof:   ds.b 1                  *aktuelles EOF-Flag

rwflg:  ds.b 1                  *Flag fÅr Lesen/Schreiben

onr:    ds 1                    *aktuelle Nummer in Liste

dta:    ds.b 44

buffer: ds.l 4                  *fÅr Berechnung der freien Blîcke

file:   ds.b 81                 *fÅr ParameterÅbergabe

tmp:    ds.b 1

chrpnt: ds 1

prfont: ds.b 4096

prbuf:  ds.b 8*160

char:   ds.b 8

revflg: ds.b 1

caseflg:ds.b 1

expflg: ds.b 1

qflg:   ds.b 1
