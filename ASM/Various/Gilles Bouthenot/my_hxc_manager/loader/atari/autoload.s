;                OPT O+,OW+                                  ;all optimisations warns
;
; Many Thanks to Jean Louis-Guerin (DrCoolZic) for documentation of the WD1772 at:
; http://info-coach.fr/atari/documents/mydoc/WD1772-JLG-V11.pdf
;
;O2: d16(an) -> (an) when d16=0


;NOTRACKINFO     equ     1                               ;don't update alTrackCurrent
;NOSEEK          equ     1                               ;don't seek first
;FORCE2SIDES     equ     1
;FORCESECTORS    equ     9                               ;0/9/10/11 use 0 to not force
;USEMOVEP        equ     0                               ;recommended to leave to 0, as the 68060 doesn't know movep
;SHOWCOLORS      equ     0
;DONTSAVEREGS    equ     1                               ;don't save/restore all registers when calling fdcAutoloader. Saves 8 bytes
;DONTINITA0      equ     1                               ;set to 1 if A0=alStruct before calling fdcAutoloader. Saves 4 bytes
;DONTTOUCHVBL    equ     1                               ;does not install the motoroff vbl. fdcVBL should still be called to handle motoroff. Saves 28 bytes
;DONTINCLUDEVBL  equ     1                               ;saves an extra 98 bytes. Motoroff code must be implemented
;ASYNCADDR2      equ     0                               ;maintain a second, offseted address (used for asynchronous loading like real time depacking). Costs 8 bytes + 4 in alStruct

;alStruct:       ds.b    alLength
;                EVEN


        
                rsset   0
alAddress:      rs.l    1                               ;address to read to (auto incremented)
        IF    ASYNCADDR2
alAddress2:     rs.l    1                               ;second address = address + xxxxx
        ENDIF
alSectorCount:  rs.l    1                               ;the number of sector to read (auto decremented)
alSector:       rs.b    1                               ;the sector to read (1-9) (auto incremented)
alSide:         rs.b    1                               ;the side to read (0 or 1) (auto changed)
alMotoron:      rs.b    1                               ;indicate that the motor is ON.
        IF    NOSEEK=0
alSeekTrack:    rs.b    1                               ;track to seek to first
        ENDIF
        IF    NOTRACKINFO=0
alTrackCurrent: rs.b    1                               ;the track whe _think_ we are (auto incremented)
        ENDIF
        IF    FORCESECTORS=0
alDiskSectors:  rs.b    1                               ;number of sectors by track (9)
        ENDIF
        IF    FORCE2SIDES=0
alDiskSides:    rs.b    1                               ;number of side of the disk (1,2)
        ENDIF
alLength:       rs.l    0


fdcAutoloader:
        IF    DONTSAVEREGS=0
                movem.l d0-d3/a0-a2,-(a7)
        ENDIF
        IF    DONTINITA0=0
                lea     alStruct(pc),a0
        ENDIF
                
                moveq   #$40,d3
                add.b   d3,d3                               ;d3=00000080. Saves 2 bytes instead 3x move.w #$80,(An)

                st      $43e+1.w                            ;floppy lock
                st      alMotoron(a0)                       ;flag motoron

        IF    NOSEEK=0
                move.b  alSeekTrack(a0),d0                  ;d0=desired track
                cmp.b   alTrackCurrent(a0),d0               ;same ?
                beq.s   .goodtrack
                
                ILLEGAL
        ENDIF
                
.goodtrack:
        IF SHOWCOLORS
                move.w  #$700,$ffff8240.w
        ENDIF
                moveq   #0,d0
                or.w    #$700,sr                            ; no interrupts
                move.b  #$0e,$ffff8800.w
                move.b  $ffff8800.w,d0                      ; read PSG register 14
                and.b   #$f8,d0
                move.b  alSide(a0),d2                       ; side
                not.b   d2
                and.b   #1,d2                               ; not side
                add.b   d2,d0
                addq.b  #4,d0                               ; not driveB
                move.b  d0,$ffff8802.w

                ;install our fdc Interrupt
                lea     fdcIrq80(pc),a1
                move.l  a1,$11c.w
                moveq   #7,d1
                bset    d1,$fffffa09.w                      ;enable FDC MFP interrupt
                bset    d1,$fffffa15.w                      ;enable FDC MFP interrupt

                lea     $ffff8606.w,a1                      ;a1=$FF8606
                lea     $ffff8604.w,a2                      ;a2=$FF8604

                move.w  #$180,(a1)                          ;DMA reset to load mode
                move.w  d3,(a1)

                ;put DMA address
        IF    (USEMOVEP=1)
                        move.w  alAddress+2(a0),d1
                movep.w d1,$ffff860b.w                      ;load address mid&low
                move.b  alAddress+1(a0),$ffff8609.w         ;load address high
        ELSE
                        addq.l #4,a0
                move.b -(a0),$ffff860d.w         ;load address low
                move.b -(a0),$ffff860b.w         ;load address mid
                move.b -(a0),$ffff8609.w         ;load address high
                subq.l #1,a0
        ENDIF

                ;DMA 1 sector to load
                move.w  #$90,(a1)                           ;DMA sector count
                move.w  #1,(a2)                             ;one sector
                
                ;d0=000000xx
                move.b  alSector(a0),d0
                
                move.w  #$84,(a1)                           ;FDC sector register
                move.w  d0,(a2)                             ;start sector

                move.w  d3,(a1)                             ;FDC Command register
                move.w  d3,(a2)                             ;Read single sector

                move.w  #$2300,sr                           ;enable interrupts
                ;at the end of the operation the FDC IRQ will be raised, and FdcIrq80 will be called

        IF    DONTSAVEREGS=0
                        movem.l (a7)+,d0-d3/a0-a2
        ENDIF
        IF SHOWCOLORS
                        move.w  #$777,$ffff8240.w
        ENDIF
                rts











fdcIrq80:
        IF SHOWCOLORS
                move.w  #$700,$ffff8240.w
        ENDIF
                movem.l  a0-a2/d0,-(a7)
                lea     alStruct(pc),a0
                
                moveq   #64,d0
                asl     #3,d0                               ;d0=512
                add.l   d0,(a0)+                            ;alAddress,     a0=s+4 we juste read 512 bytes
        IF ASYNCADDR2
                        add.l   d0,(a0)+                            ;alAddress2,    a0=s+8 we juste read 512 bytes
        ENDIF

                subq.l  #1,(a0)+                            ;alSectorCount, a0=s+8/12 remaining sectors
                beq     .readcomplete
                
                addq.b  #1,(a0)                             ;alSector              sector++
        IF    FORCESECTORS=0
                        move.b  (a0),d0                             ;alSector
                cmp.b   alDiskSectors-8(a0),d0              ;                      sector <= diskSectors ?
        ELSE
                        cmp.b   #FORCESECTORS,(a0)                  ;alSector              sector <= diskSectors ?
        ENDIF
                bls.s   .nextSector                         ; then continue reading
            
                ; end of track reached
                move.b  #1,(a0)+                            ;alSector,      a0=s+9/13 reset to sector 1

                addq.b  #1,(a0)                             ;alSide                side++
        IF    FORCE2SIDES=0
                        move.b  (a0),d0                             ;alSide
                cmp.b   alDiskSides-10(a0),d0               ; side < diskSides ?
        ELSE
                        cmp.b   #2,(a0)                             ;alSide
        ENDIF
                blt.s   .switchSide                         ; then switch side
                                                            ; else step in, then reset to first side
                clr.b   (a0)                                ;alSide                reset to first side
                move.w  #$80,$ffff8606.w                    ; FDC Command register
                move.w  #$53,$ffff8604.w                    ; Step in, updateTrack, notVerify, 3ms
                
                lea     .fdcIrq53(pc),a0                    ; change IRQ to the StepIn one. This also calls .switchSide
                move.l  a0,$11c.w
                bra     .return

.switchSide:    ;a0=s+9/13
                ;reset PSG register 14. Also called after StepIn.
                move.w  sr,-(a7)
                or.w    #$700,sr                            ; no interrupts
                move.b  #$0e,$ffff8800.w
        IF FORCE2SIDES=0
                        move.w  d2,-(a7)
                move.b  $ffff8800.w,d0                      ; read PSG register 14
                and.b   #$f8,d0
                move.b  (a0),d2                             ;alSide
                not.b   d2
                and.b   #1,d2                               ; not side
                add.b   d2,d0
                addq.b  #4,d0                               ; not driveB
                move.b  d0,$ffff8802.w
                move.w  (a7)+,d2
        ELSE
                        move.b  $ffff8800.w,d0                      ; read PSG register 14
                bchg    #0,d0
                move.b  d0,$ffff8802.w
        ENDIF
                move.w  (a7)+,sr

.nextSector:    ;continue reading to the next sector
                ;a0=s+8/12 ou a0=s+9/13 (instantly reseted)
                
                lea     alStruct(pc),a0                     ;a0=s+0
                moveq   #0,d0
                move.b  alSector(a0),d0                     ;alSector

                addq.l  #4,a0                               ;a0=s+4
                move.b  -(a0),$ffff860d.w                   ;load address low,  a0=s+3
                move.b  -(a0),$ffff860b.w                   ;load address mid,  a0=s+2
                move.b  -(a0),$ffff8609.w                   ;load address high, a0=s+1 (no more used)
                
                lea     $ffff8606.w,a1                      ;a1=$FF8606
                lea     $ffff8604.w,a2                      ;a2=$FF8604

                ;DMA 1 sector to load
                move.w  #$90,(a1)                           ;DMA sector count
                move.w  #1,(a2)                             ;one sector
                
                move.w  #$84,(a1)                           ;FDC sector register
                move.w  d0,(a2)                             ;sector to read

                move.w  #$80,(a1)                           ;FDC Command register
                move.w  #$80,(a2)                           ;Read single sector

                bra.s   .return
                

.readcomplete:  ;a0=s+8/12
        IF ASYNCADDR2
                        move.l  -12(a0),-8(a0)                      ;alAddress2 = alAddress
        ENDIF
                moveq   #7,d0
                bclr    d0,$fffffa09.w                      ;disable FDC MFP interrupt
                bclr    d0,$fffffa15.w                      ;disable FDC MFP interrupt

            lea     $ffff8604.w,a0
            move.w  #$86,2(a0)                              ;FDC data register
            move.w  #255,(a0)                               ;write : tracknumber : 255
            move.w  #$80,2(a0)                              ;FDC Command register
            move.w  #$13,(a0)                               ;send command Seek, no verify

                sf      $43e+1.w                            ;floppy unlock
                
                lea     .rte(pc),a0                         ;remove fdcInterrupt for safety
                move.l  a0,$11c.w
                
        IF DONTTOUCHVBL=0
                        lea     fdcOldVBL(pc),a0
                move.l  $70.w,(a0)                          ;modify JMP
                lea     fdcVBL(pc),a0
                move.l  a0,$70.w
        ENDIF

.return:        bclr    #7,$fffffa11.w                      ; clear interrupt pending
                movem.l  (a7)+,a0-a2/d0
        IF SHOWCOLORS
                        move.w  #$777,$ffff8240.w
        ENDIF
.rte:           rte
        

.fdcIrq53:
        IF SHOWCOLORS
                        move.w  #$700,$ffff8240.w
        ENDIF
                movem.l  a0-a2/d0,-(a7)
                lea     fdcIrq80(pc),a0                     ; reset IRQ vector to the old one
                move.l  a0,$11c.w
                lea     alStruct(pc),a0
        IF NOTRACKINFO=0
                        addq.b  #1,alTrackCurrent(a0)
        ENDIF
                bra     .switchSide                         ; continue







        if ((DONTTOUCHVBL=0)|(DONTINCLUDEVBL=0))
        ; VBL INTERRUPT
fdcVBL:         tst.w   $43e.w                      ; floppy locked ?
                bne.s   .fdcLocked
                move.l  a0,-(a7)
                move.w  d0,-(a7)
                lea     alStruct+alMotoron(pc),a0
                tst.b   (a0)                        ; motor already off ?
                beq.s   .fdcBusy                    ; yes: exit
                move.w  #$80,$ffff8606.w
                move.w  $ffff8604.w,d0              ; read FDC status
                btst    #7,d0                       ; FDC busy ?
                bne.s   .fdcBusy                    ; yes: returns

                move.w  sr,-(a7)                    ; no:deselect drives
                or.w    #$700,sr                    ; no interrupts
                move.b  #$0e,$ffff8800.w
                move.b  $ffff8800.w,d0              ; read PSG register 14
                or.b    #6,d0                       ; deselect drivea & driveb
                move.b  d0,$ffff8802.w
                sf      (a0)                        ; unset motoron
                move.w  (a7)+,sr
                
        IF DONTTOUCHVBL=0
                        move.l  fdcOldVBL(pc),d0
                move.l  d0,$70.w                    ; restore the old VBL interrupt
        ENDIF
            
.fdcBusy:       move.w  (a7)+,d0
                move.l  (a7)+,a0
.fdcLocked:
        IF DONTTOUCHVBL=0
                        jmp     $0.l
fdcOldVBL       equ *-4
        ELSE
                        rte
        ENDIF
        ENDIF
