* Ramdisk routine, made by Martin Liesen
*  Under progress....   not reset proof...
*********************************************

                OUTPUT 'OHM_DISK.PRG'
                OPT P+
hdv_bpb         EQU $00000472
hdv_rw          EQU $00000476
hdv_mediach     EQU $0000047E
drivebits       EQU $000004C4
magic2          EQU 254*4
magic1          EQU 255*4

**************************************************************************
                PART 'header'
header:         bra.s   program_start
                DC.W 512        ; 2   size in kb
                DC.W "D"-"A"    ; 4   drive 0=A 1=B 2=C and so on..
                DC.W 6          ; -1   $484.w    -1.w leave unchanged
                DC.W -1         ; -1   $444.w    -1.w leave unchanged
                ENDPART
program_start:  >PART 'Init'
                lea     stack(PC),A7
                pea     superstart(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,-(A7)


errorlevel:     move.w  #0,-(A7)
returnsize:     pea     0
                move.w  #$0031,-(A7)
                trap    #1

                ENDPART
superstart:
                cmpi.l  #"COKE",magic1.w
                beq     already

                moveq   #0,D0
                move.w  header+4(PC),D0 ;     Drive
                lea     rd_mediach+2(PC),A0
                move.w  D0,(A0)
                lea     rd_bpb+2(PC),A0
                move.w  D0,(A0)
                lea     rd_rw+2(PC),A0
                move.w  D0,(A0)

                move.w  header+2(PC),D0 ;     Size
restore_dta:

                lea     numcl(PC),A0
                move.w  D0,(A0)         ; number of clusters in bpb (1clust=1Kb)
                moveq   #10,D2
                lsl.l   D2,D0           ; *1024 = ramd size in bytes
                add.l   #9216+512,D0    ; leave space for boot sector

                add.l   #disk-header,D0
                lea     returnsize+2(PC),A0
                move.l  D0,(A0)


* + FAT + root dir + BPB + driver


                lea     old_bpb+2(PC),A0 ;        Old Vectors to JMP
                move.l  hdv_bpb.w,(A0)
                lea     old_rw+2(PC),A0
                move.l  hdv_rw.w,(A0)
                lea     old_mediach+2(PC),A0
                move.l  hdv_mediach.w,(A0)

getgoing:       lea     rd_bpb(PC),A0   ;         Start up own rutines
                move.l  A0,hdv_bpb.w
                lea     rd_rw(PC),A0
                move.l  A0,hdv_rw.w
                lea     rd_mediach(PC),A0
                move.l  A0,hdv_mediach.w

                move.w  drivebits.w,D0  ;        Set disk flag
                move.w  header+4(PC),D1
                bset    D1,D0
                move.w  D0,drivebits.w
                move.l  #'COKE',magic1.w
                lea     getgoing(PC),A0
                move.l  A0,magic2.w

                move.l  #$752019F3,$00000520.w
                move.l  #$237698AA,$0000053A.w
                move.l  #$5555AAAA,$0000051A.w

                lea     header(PC),A0
                cmpi.w  #-1,6(A0)
                beq.s   leave484
                move.w  6(A0),$00000484.w
leave484:       cmpi.w  #-1,8(A0)
                beq.s   leave444
                move.w  8(A0),$00000444.w
leave444:

                rts

already:        movea.l magic2.w,A0
                jsr     (A0)
                lea     errorlevel+2(PC),A0
                move.w  #-1,(A0)
                rts


disk:
recsiz:         DC.W 512        ; physical sector size in bytes
clsiz:          DC.W 2          ; cluster size in sectors
clsizb:         DC.W 1024       ; cluster size in bytes
rdlen:          DC.W 7          ; root dir length in sectors
fsiz:           DC.W 5          ; FAT size in sectors
fatrec:         DC.W 6          ; sector # 2nd FAT start
datrec:         DC.W 18         ; sector # data start
numcl:          DC.W $01EC      ; number of clusters (filled in above)
bflags:         DC.W 0

*************************************************
*   Media Change
*************************************************

rd_mediach:     cmpi.w  #-1,4(A7)       ; mediach handler
                bne     old_mediach
                moveq   #0,D0
                rts

*************************************************
*   Get Parameter Block
*************************************************

rd_bpb:         cmpi.w  #-1,4(A7)       ; bpb handler
                bne     old_bpb
                move.l  A0,-(A7)
                lea     disk(PC),A0
                move.l  A0,D0
                movea.l (A7)+,A0
                rts

**************************************************
**  Read  &  Write
**************************************************
rd_rw:          cmpi.w  #-1,14(A7)      ; rw handler
                bne     old_rw
                lea     disk(PC),A0
                adda.l  #512,A0         ; start of ramdisk data area
                movea.l 6(A7),A1        ; buffer address
                moveq   #0,D1
                move.w  12(A7),D1       ; logical record number
                moveq   #9,D0           ; 2^9
                asl.l   D0,D1
                adda.l  D1,A0           ; + ramdisk base = sector address
                move.w  10(A7),D0       ; sector count
                move.l  A1,D2           ; is buffer address odd?
                btst    #0,D2
                bne.s   copy_slow       ; yes, then branch

***************************************
* Copy Fast
***************************************

                btst    #0,5(A7)        ; check mode
                bne.s   nextsector_f    ; branch if write
                exg     A1,A0           ; read, so copy other way round
nextsector_f:   moveq   #7,D1           ; loop 8 times
copyfast512:    REPT 16
                move.l  (A1)+,(A0)+
                ENDR
                dbra    D1,copyfast512
                subq.l  #1,D0           ; decrement count
                bne.s   nextsector_f    ; loop if more sectors to move
                rts

****************************************
* Copy Slow
****************************************

copy_slow:      btst    #0,5(A7)        ; odd address buffer, use slow move
                bne.s   nextsector_s    ; branch if write
                exg     A1,A0           ; read, so copy other way round
nextsector_s:   moveq   #31,D1          ; loop 31 times
copyslow512:    REPT 16
                move.b  (A1)+,(A0)+
                ENDR
                dbra    D1,copyslow512
                subq.l  #1,D0           ; decrement count
                bne.s   nextsector_s    ; loop if more sectors to move
                rts

****************************************
* Orginal Vectors
****************************************

old_bpb:        jmp     0               ; vector to old bpb handler
old_mediach:    jmp     0               ; vector to old mediach handler
old_rw:         jmp     0               ; vector to old rw handle
                BSS
                DS.B 10*1024    ; kepp nulls
stack:
                END
