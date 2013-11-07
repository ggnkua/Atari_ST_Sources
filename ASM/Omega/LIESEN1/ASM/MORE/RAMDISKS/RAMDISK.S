                OUTPUT 'OHM_DISK.PRG'
membot          EQU $00000432
memtop          EQU $00000436
phystop         EQU $0000042E
hdv_bpb         EQU $00000472
hdv_rw          EQU $00000476
hdv_mediach     EQU $0000047E
drivebits       EQU $000004C4

**************************************************************************
                >PART 'INIT'
pogram_start:   movea.l A7,A5           ; save old stack ptr
                lea     stack(PC),A7    ; new stack
                movea.l 4(A5),A5        ; get address of base page
                move.l  12(A5),D0       ;  compute length of program
                add.l   20(A5),D0
                add.l   28(A5),D0
                add.l   #$00000100,D0

                move.l  D0,-(A7)        ; Reserve Memory
                move.l  A5,-(A7)
                move.w  D0,-(A7)
                move.w  #$004A,-(A7)
                trap    #1
                adda.l  #12,A7

                pea     superstart(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,-(A7)
                clr.w   -(A7)
                trap    #1
                ENDPART

superstart:
                lea     memtop.w,A4
                lea     phystop.w,A5

                lea     $0000010C.w,A0
                cmpi.w  #'CO',(A0)
                beq.s   restart
                move.w  #'CO',(A0)

                moveq   #3,D0           ; Drive D
                move.w  D0,device_no    ; save device number
                move.w  D0,rd_mediach+2 ; modify this code
                move.w  D0,rd_bpb+2     ; with the device number
                move.w  D0,rd_rw+2

                move.w  #512,D0         ; 349 KB
restore_dta:    move.l  D0,save_size    ; save the size number



                move.l  save_size(PC),D0
                move.w  D0,numcl        ; put number of clusters in bpb
                moveq   #10,D2
                lsl.l   D2,D0           ; d0 = ramd size in bytes
                add.l   #9216+512,D0    ; leave space for boot sector

* + FAT + root dir + BPB + driver

                move.l  D0,D1           ; leave at least 128K for user
                add.l   membot.w,D1
                add.l   #$00020000,D1
                cmp.l   (A4),D1
                bge.s   exit

                sub.l   D0,(A4)         ; okay, so reserve memory
                sub.l   D0,(A5)
                move.l  hdv_bpb.w,old_bpb+2 ; save hdv_bpb vector
                move.l  hdv_rw.w,old_rw+2 ; save hdv_rw vector
                move.l  hdv_mediach.w,old_mediach+2 ; save hdv_mediach

                lea     driver(PC),A0   ; copy drivers to reserved memory
                movea.l (A5),A1
                moveq   #127,D7         ; move 512 bytes
L4:             move.l  (A0)+,(A1)+
                dbra    D7,L4

                movea.l $00000004.w,A0  ; force a reset
                jmp     (A0)

restart:        move.l  (A5),D1
                add.l   #rd_bpb-driver,D1
                move.l  D1,hdv_bpb      ; set hdv_bpb vector

                move.l  (A5),D1
                add.l   #rd_rw-driver,D1
                move.l  D1,hdv_rw       ; set hdv_rw vector

                move.l  (A5),D1
                add.l   #rd_mediach-driver,D1
                move.l  D1,hdv_mediach  ; set hdv_mediach vector

                movea.l (A5),A0         ; mark ramdisk as present
                adda.l  #device_no-driver,A0
                move.w  (A0),D1
                move.w  drivebits.w,D0
                bset    D1,D0
                move.w  D0,drivebits

exit:
                rts


* Following bytes moved into high memory
* ramdisk bios parameter block
                EVEN
driver:
recsiz:         DC.W 512        ; physical sector size in bytes
clsiz:          DC.W 2          ; cluster size in sectors
clsizb:         DC.W 1024       ; cluster size in bytes
rdlen:          DC.W 7          ; root dir length in sectors
fsiz:           DC.W 5          ; FAT size in sectors
fatrec:         DC.W 6          ; sector # 2nd FAT start
datrec:         DC.W 18         ; sector # data start
numcl:          DC.W $01EC      ; number of clusters (filled in above)
bflags:         DC.W 0

rd_mediach:     cmpi.w  #-1,4(A7)       ; mediach handler
                bne     old_mediach
                moveq   #0,D0
                rts

rd_bpb:         cmpi.w  #-1,4(A7)       ; bpb handler
                bne     old_bpb
                move.l  phystop.w,D0
                rts

rd_rw:          cmpi.w  #-1,14(A7)      ; rw handler
                bne.s   old_rw
                movea.l phystop.w,A0
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
                bne.s   L8              ; yes, then branch

****** Copy Fast

                btst    #0,5(A7)        ; check mode
                bne.s   L6              ; branch if write
                exg     A1,A0           ; read, so copy other way round
L6:             moveq   #15,D1          ; loop 16 times
L7:             move.l  (A1)+,(A0)+     ; move 32 bytes quickly
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                move.l  (A1)+,(A0)+
                dbra    D1,L7
                subq.l  #1,D0           ; decrement count
                bne.s   L6              ; loop if more sectors to move
                rts

**** Copy Slow

L8:             btst    #0,5(A7)        ; odd address buffer, use slow move
                bne.s   L9              ; branch if write
                exg     A1,A0           ; read, so copy other way round
L9:             moveq   #63,D1          ; loop 64 times
L10:            move.b  (A1)+,(A0)+     ; move 8 bytes
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                move.b  (A1)+,(A0)+
                dbra    D1,L10
                subq.l  #1,D0           ; decrement count
                bne.s   L9              ; loop if more sectors to move
                rts

old_bpb:        jmp     0               ; vector to old bpb handler
old_mediach:    jmp     0               ; vector to old mediach handler
old_rw:         jmp     0               ; vector to old rw handle

                EVEN
device_no:      DC.W -1
save_size:      DS.L 1
                DS.W 200        * stack
stack:          DS.L 1
                END
**************************************************************************
                END
