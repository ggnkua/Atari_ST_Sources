********************************
* NEWROOT                      *
*                              *
* Boot-Selektor im Root-Sektor *
* fuer TOS/UNIX                *
*                              *
* April 1992 by Uwe Seimet     *
* (c) 1992 MAXON Computer      *
********************************


GEMDOS   = 1

BIOS     = 13
RWABS    = 4
KBSHIFT  = 11

XBIOS    = 14
DMAREAD  = 42

flock    = $43e
_hz_200  = $4ba
_drvbits = $4c2
_sysbase = $4f2

daccess  = $ffff8604
dmodus   = $ffff8606
dmahi    = $ffff8609
gpip     = $fffffa01


         text

         move #10,-(sp)             ;von SCSI
                                    ;Device 0
         clr -(sp)                  ;Rootsektor
                                    ;lesen
         move #1,-(sp)
         pea buffer
         move #10,-(sp)             ;physikalisch
                                    ;mit Retry
         move #RWABS,-(sp)
         trap #BIOS
         lea 14(sp),sp
         tst.l d0
         bne.s error

         lea buffer,a0              ;Start des
                                    ;Rootprogramms
         lea rootprg,a1
         move #rootend-rootprg-1,d0
copy:    move.b (a1)+,(a0)+         ;Rootprogram
                                    ;kopieren
         dbra d0,copy

         clr d1
         lea buffer,a0
         move #254,d0
check:   add (a0)+,d1               ;PrÅfsumme
                                    ;bilden
         dbra d0,check
         move #$1234,d0
         sub d1,d0
         move d0,(a0)               ;PrÅfsummen-
                                    ;ausgleich

         move #10,-(sp)             ;auf SCSI
                                    ;Device 0
         clr -(sp)                  ;Rootsektor
                                    ;schreiben
         move #1,-(sp)
         pea buffer
         move #11,-(sp)             ;physikalisch
                                    ;mit Retry
         move #RWABS,-(sp)
         trap #BIOS
         lea 14(sp),sp

error:   clr -(sp)
         trap #GEMDOS


*Es folgt das eigentliche Rootprogramm
rootprg:
         bra.s start
         bra read                   ;Sprung auf
                                    ;Leseroutine
start:   bclr #2,_drvbits+3         ;Laufwerk C
                                    ;abmelden
         movem.l d3/d5,-(sp)
         move #-1,-(sp)
         move #KBSHIFT,-(sp)
         trap #BIOS
         addq.l #4,sp
         btst #3,d0
         bne.s exit
         btst #0,d0                 ;Shift-Taste
                                    ;rechts?
         beq.s noshift              ;nein-
         tst.b d5
         beq.s noshift              ;keine
                                    ;PrÑferenz-
         eor.b #$c0,d5              ;Maske
                                    ;wechseln
noshift: moveq #3,d0
         moveq #$f8,d1
         lea rootprg+$1c6(pc),a0
         cmp.l #"DMAr",d3           ;DMAREAD
                                    ;vorhanden?
         beq.s dma                  ;ja-
         moveq #-1,d4               ;Flag fÅr
                                    ;DMAREAD
         moveq #$80,d2              ;TOS booten
         bra.s test1
dma:     move.b d5,d2
         beq.s test2                ;keine
                                    ;PrÑferenz-

*voreingestelltes System booten
test1:   btst #0,(a0)               ;Partition
         beq.s noval1               ;ungÅltig-
         and.b d1,(a0)
         cmp.b (a0),d2
         beq.s boot
noval1:  lea 12(a0),a0
         dbra d0,test1
         bra.s exit

*von erstem ausfÅhrbaren Bootsektor booten
test2:   btst #0,(a0)
         beq.s noval2
         and.b d1,(a0)
         bne.s boot
noval2:  lea 12(a0),a0
         dbra d0,test2

*RÅckkehr ins TOS
exit:    addq.l #8,sp
tostest: move.l _sysbase,a0
         move.l $18(a0),d0
         swap d0
         cmp.l #$19870422,d0        ;altes TOS?
         bcc.s ret                  ;nein-
         move #$e0,d7
ret:     rts                        ;zurÅck ins
                                    ;System
boot:    move.l 4(a0),d6
         moveq #1,d5
         lea rootprg+512(pc),a4
         bsr.s read                 ;Bootsektor
                                    ;lesen
         tst d0
         bne exit
         move.l a4,a0
         move.w #$ff,d1
         moveq #0,d0
chk:     add (a0)+,d0
         dbra d1,chk
         cmp #$1234,d0              ;Bootsektor
                                    ;ausfÅhrbar?
         bne exit                   ;nein-
         lea read(pc),a3
         lea tostest(pc),a5
         movem.l (sp)+,d3/d5
         cmp.b #$e9,(a4)            ;Sektor DOS-
                                    ;kompatibel?
         bne.s jmp                  ;nein-
         jmp 30(a4)                 ;Bootprogramm
jmp:     jmp (a4)                   ;ausfÅhren-
read:    tst d4                     ;DMAREAD
                                    ;verfÅgbar?
         bmi.s acsi                 ;nein-

*Sektor per DMAREAD lesen
         move d4,-(sp)
         pea (a4)
         move d5,-(sp)
         move.l d6,-(sp)
         move #DMAREAD,-(sp)
         trap #XBIOS
         lea 14(sp),sp
         rts

*Sektor von ACSI-Bus lesen
acsi:
         tas flock                  ;Busfreigabe
         bne acsi                   ;abwarten
         move.l _hz_200,d0
         addq.l #2,d0
wait:    cmp.l _hz_200,d0
         bcc wait
         lea dmahi,a6
         movem.l d6/a4,-(sp)
         move.b 7(sp),4(a6)
         move.b 6(sp),2(a6)
         move.b 5(sp),(a6)
         lea com(pc),a6
         move.b 1(sp),1(a6)
         move.b 2(sp),5(a6)
         move.b 3(sp),9(a6)
         move.b d5,13(a6)
         addq.l #8,sp
         lea dmodus,a6
         lea daccess,a5
         move #$198,(a6)
         move #$98,(a6)
         move d5,(a5)               ;SektorzÑhler
         move #$88,(a6)
         moveq #0,d0
         move.b d7,d0               ;GerÑtenummer
         or.b #$08,d0               ;READ SECTOR
         swap d0
         move.w #$8a,d0
         bsr.s hshake
         lea com(pc),a0
         moveq #3,d2
send:    move.l (a0)+,d0
         bsr.s hshake
         dbra d2,send
         moveq #$0a,d0
         move.l d0,(a5)             ;öbertragung
                                    ;starten
         move.l #$190,d1
         bsr.s wt
         move #$8a,(a6)
         move (a5),d0
         and #$ff,d0
         beq *+2
err:     moveq #-1,d0
         move #$80,(a6)
         clr.b flock
ret0:    rts
com:     dc.l $8a,$8a,$8a,$1008a    ;Kommandos
                                    ;fÅr READ
hshake:  move.l d0,(a5)
         moveq #$0a,d1
wt:      add.l _hz_200,d1
wait0:   btst #5,gpip
         beq ret0
         cmp.l _hz_200,d1
         bcc wait0
         addq.l #4,sp
         bra err
rootend:


         bss

buffer:  ds.b 512
