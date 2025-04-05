**************************************************************
*                                                            *
*         AN ATTEMPT AT A BIOS BINDINGS FILE FOR             *
*                   METACOMCO LANGUAGES                      *
*                                                            *
*             Ted Miller, started 10/21/86                   *
*                                                            *
**************************************************************

**************************************************************
*     MACROS of great importance                             *
**************************************************************

INIT      MACRO
          XDEF      \1
\1        move.l    a2,sava2     ; save address register #2
          ENDM

GOBIOS    MACRO
          move.w    #\1,-(sp)    ;set up stack for call
          trap      #13          ;and call the BIOS
          ENDM

CORRECT   MACRO
          IFGT      \1-8         ;correct stack
          add.l     #\1,sp
          ENDC
          IFLE      \1-8
          addq.l    #\1,sp       ;correct stack
          ENDC
          move.l    sava2,a2     ;restore register a2
          ENDM


*************************************************************
*         BIOS CALL #0: getmpb (get momory parameter block) *
*************************************************************
          INIT      getmpb
          move.l    4(sp),-(sp)   ; get longword pointer
          GOBIOS    0
          CORRECT   6
          rts


*************************************************************
*         BIOS CALL #1: bconstat (get input device status)  *
*************************************************************
          INIT      bconstat
          move.w    6(sp),-(sp)    ; extract word from longword passed and pass
          GOBIOS    1
          CORRECT   4
          rts


*************************************************************
*         BIOS CALL #2: conin (read character from device)  *
*************************************************************
          INIT     conin
          move.w   6(sp),-(sp)     ; extract word from longword passed and pass
          GOBIOS   2
          CORRECT  4
          rts                      ; done.


*************************************************************
*         BIOS CALL #3: bconout (write character to device) *
*************************************************************
          INIT      bconout
          move.w    10(sp),-(sp)    ;get character to output
          move.w    6(sp),-(sp)     ;get device number
          GOBIOS    3
          CORRECT   6
          rts


*************************************************************
*         BIOS CALL #4: rwabs (read/write disk sector)      *
*************************************************************
          INIT      rwabs
          move.w    22(sp),-(sp)       ;determine drive to R/W
          move.w    18(sp),-(sp)       ;get start sector
          move.w    14(sp),-(sp)       ;get # of sectors
          move.l    8(sp),-(sp)        :get buffer address
          move.w    6(sp),-(sp)        ;determine operation
          GOBIOS    4
          CORRECT   14
          rts


*************************************************************
*         BIOS CALL #5: setexec (set exception vector)      *
*************************************************************
          INIT      setexec
          move.l    8(sp),-(sp)         ;get # of vector to change
          move.w    6(sp),-(sp)         ;get address of new routine
          GOBIOS    5
          CORRECT   8
          rts



*************************************************************
*         BIOS CALL #6: tickcal (get milliseconds per tick) *
*************************************************************
          INIT      tickcal
          GOBIOS    6
          CORRECT   2
          rts


*************************************************************
*         BIOS CALL #7: getbpb (get BIOS parameter block)   *
*************************************************************
*  SYNTAX CHANGED FROM STANDARD BIOS.
*  the call is now address := getbpb(drive,block) where block
*  is an array[1..9] of integer.
**********************************
          INIT      getbpb              ;initialize
          move.w    6(sp),-(sp)         ;get device #
          GOBIOS    7                   ;go to the BIOS
          addq.l    #4,sp               ;correct stack
          clr.l     d1                  ;clear register d1
          move.l    d0,a0               ;move block address into a0
          move.l    8(sp),a1            ;get pascal variable buffer address
          addq.l    #2,a1               ;add word offset into longword
loop      move.w    (a0),(a1)           ;move an entry into pascal array
          addq.l    #4,a1               ;add long offset to pascal address
          addq.l    #2,a0               ;add word offset to block address
          addq.l    #1,d1               ;increment counter
          cmp.l     #9,d1               ;check done
          bne       loop                ;not yet
          move.l    sava2,a2            ;restore register a2
          rts



*************************************************************
*         BIOS CALL #8: bcostat (get output device status)  *
*************************************************************
          INIT      bcostat
          move.w    6(sp),-(sp)
          GOBIOS    8
          CORRECT   4
          rts


*************************************************************
*         BIOS CALL #9: mediach (check disk change)         *
*************************************************************
          INIT      mediach
          move.w    6(sp),-(sp)         ;get drive
          GOBIOS    9
          CORRECT   4
          rts


*************************************************************
*         BIOS CALL #10: drvmap (get connected drives)      *
*************************************************************
          INIT      drvmap
          GOBIOS    10
          CORRECT   2
          rts


*************************************************************
*         BIOS CALL #11: kbshift (get/alter keyboard status)*
*************************************************************
          INIT      kbshift
          move.w    6(sp),-(sp)         ;get mode
          GOBIOS    11
          CORRECT   4
          rts

*   space to save register a2, which is corrupted by BIOS
sava2     ds.l      1
          END

