; Patch fÅr Boot von ATAPI-Laufwerken
; Installiert XBIOS-Anpassung von DMAREAD() und DMAWRITE()

               org $7fe60000

atapi:         lea.l      $fff00000,a1

               move.b     $f(sp),d0    ; device
               lea.l      $aa2,a0      ; buffer
               andi.b     #7,d0
               lsl.b      #4,d0
               ori.b      #$a0,d0      ; for compatibility to old IDE-Drives
               move.b     d0,$19(a1)   ; set drive

               bsr        atbusy
               tst.w      d0
               bmi        aterror

               move.b     #1,9(a1)
               move.b     #1,$d(a1)
               move.b     #0,$11(a1)
               move.b     #0,$15(a1)
               move.b     #0,$39(a1)
               move.b     #$ec,$1d(a1)  ; identify device
               bsr        atbusy        ; ready for new command ?
               tst.w      d0
               bmi        aterror
       
               cmpi.b     #1,9(a1)      ; signature-test
               bne        idefound      ; no atapi
               cmpi.b     #1,$d(a1)
               bne        idefound      ; no atapi

               cmpi.b     #$14,$11(a1)
               bne        idefound      ; no atapi
               cmpi.b     #$eb,$15(a1)
               bne        idefound      ; no atapi

               bsr        atfehler
               tst.b      d0
               bne        mediaerr
               moveq.l    #4,d2         ; trialcounter
               btst       #3,$1d(a1)
               beq.s      nextatread
               bsr        readout
nextatread:   
               move.w     d2,-(sp)
               move.w     $10(sp),-(sp)      ; devno
               move.l     $e(sp),-(sp)       ; buffer
               move.w     $10(sp),-(sp)      ; count
               move.l     $e(sp),-(sp)       ; startsector
               tst.b      $aa0
               bne.s      atgotowr      ; to write_atapi
               bsr        atapiread
               bra.s      atgoend
atgotowr:      bsr        atapiwrite
atgoend:       adda.w     #$c,sp
               move.w     (sp)+,d2
               tst.b      d0
               bmi.s      aterror
               beq        atokex
               cmpi.b     #6,d0
               bne        aterrex
               bsr        atbusy
               tst.w      d0
               bmi.s      aterror
               bsr        req_sense
               bsr        atbusy
               tst.w      d0
               bmi.s      aterror
               bsr        inquiry
               bsr        atbusy
               tst.w      d0
               bmi.s      aterror
               dbra       d2,nextatread
aterrex:       bra        mediaerr

atwait:        moveq.l    #4,d0
               add.l      $4ba,d0
atwloop:       cmp.l      $4ba,d0
               bhi.s      atwloop
               rts        

atbusy:        bsr        atwait
               move.b     $fffffa01,d0
               move.b     $39(a1),d0
               move.l     #$7d0,d0
               add.l      $4ba,d0
atbusyloop:    move.b     $1d(a1),d1
               btst       #7,d1
               beq.s      atreadyex
               cmp.l      $4ba,d0
               bhi.s      atbusyloop
aterror:       moveq.l    #-1,d0
               rts        
atreadyex:     moveq.l    #0,d0
               rts        
               
readywait:     move.l  #$7d0,d0
      	       add.l   $4ba,d0
rdyloop:       move.b  $1d(a1),d1
      	       and.b   #$88,d1
      	       tst.b   d1
      	       beq.s   exrdy
      	       cmp.l   $4ba,d0
      	       bhi.s   rdyloop
exrdy:         rts
               
atfehler:      bsr        atwait
               move.b     $1d(a1),d0
               btst       #0,d0
               beq.s      atreadyex
               move.b     5(a1),d0
               lsr.b      #4,d0
atfehex:       rts        

atapiwrite:    lea.l      $fff00000,a1
               move.w     $e(sp),d0     ;devno
               andi.b     #7,d0
               lsl.b      #4,d0
               ori.b      #$a0,d0      ; for compatibility to old IDE-Drives
               move.b     d0,$19(a1)
               move.b     #0,$39(a1)
               bsr        atcmd_strt
               tst.w      d0
               bmi.s      aterror
               move.l     $a(sp),a0     ; buffer
               move.w     #$2a,(a1)     ; atapi-write
               move.l     4(sp),d1      ; logical sector
               swap.w     d1
               rol.w      #8,d1
               move.w     d1,(a1)       ; adress msb
               swap.w     d1
               rol.w      #8,d1
               move.w     d1,(a1)       ; adress lsb
               move.w     8(sp),d1      ; count
               move.w     d1,d0
               andi.w     #$ff00,d0
               move.w     d0,(a1)       ; count msb
               andi.w     #$ff,d1
               move.w     d1,(a1)       ; count lsb
               move.w     #0,(a1)
               move.w     8(sp),d2
               subq.w     #1,d2
               bsr        atwait
wcntloop:      bsr        atfehler
               tst.b      d0
               bne.s      atwrexit
               bsr        atbusy
               tst.w      d0
               bmi        aterror
               move.w     #$ff,d0
atwdata:       move.w     (a0)+,d1
               rol.w      #8,d1
               move.w     d1,(a1)
               dbra       d0,atwdata
               dbra       d2,wcntloop
               bsr        readywait
               moveq.l    #0,d0
atwrexit:      rts        

atapiread:     lea.l      $fff00000,a1
               move.w     $e(sp),d0     ; devno
               andi.b     #7,d0
               lsl.b      #4,d0
               ori.b      #$a0,d0       ; for compatibility to old IDE-Drives
               move.b     d0,$19(a1)
               move.b     #0,$39(a1)
               bsr        atcmd_strt
               tst.w      d0
               bmi        aterror
               move.l     $a(sp),a0     ; buffer
               move.w     #$28,(a1)     ; atapi-read
               move.l     4(sp),d1      ; logical sector
               swap.w     d1
               rol.w      #8,d1
               move.w     d1,(a1)       ; adress msb
               swap.w     d1
               rol.w      #8,d1
               move.w     d1,(a1)       ; adress lsb
               move.w     8(sp),d1      ; count
               move.w     d1,d0
               andi.w     #$ff00,d0
               move.w     d0,(a1)       ; count msb
               andi.w     #$ff,d1
               move.w     d1,(a1)       ; count lsb
               move.w     #0,(a1)
               move.w     8(sp),d2
               subq.w     #1,d2
               bsr        atwait
rcntloop:      bsr        atfehler
               tst.b      d0
               bne.s      atrdexit
               bsr        atbusy
               tst.w      d0
               bmi        aterror
               move.w     #$ff,d0
atrdata:       move.w     (a1),d1
               rol.w      #8,d1
               move.w     d1,(a0)+
               dbra       d0,atrdata
               dbra       d2,rcntloop
               bsr        readywait
               moveq.l    #0,d0
atrdexit:      rts        

readout:       move.l     a0,-(sp)
               moveq.l    #$7f,d0
rdodata:       move.l     (a1),(a0)+
               dbra       d0,rdodata
               movea.l    (sp)+,a0
               rts        

req_sense:     bsr        atcmd_strt
               tst.w      d0
               bmi        aterror
               move.w     #$3,(a1)
               move.w     #0,(a1)
               move.w     #$12,-(sp)
               bsr        atcmd_main
               addq.w     #2,sp
               rts        

inquiry:       bsr        atcmd_strt
               tst.w      d0
               bmi        aterror
               move.w     #$12,(a1)
               move.w     #0,(a1)
               move.w     #36,-(sp)
               bsr        atcmd_main
               addq.w     #2,sp
               rts        

atcmd_strt:    move.b     #0,5(a1)
               move.b     #0,9(a1)
               move.b     #0,$11(a1)
               move.b     #2,$15(a1)    ; sector-nummer
               move.b     #$a0,$1d(a1)  ; packed-command
               bsr        atbusy
               tst.w      d0
               bmi        aterror
               rts        

atcmd_main:    move.w     4(sp),(a1)
               move.w     #0,(a1)
               move.w     #0,(a1)
               move.w     #0,(a1)
               bsr        atfehler
               tst.b      d0
               bne.s      atcmdex
               bsr        atbusy
               tst.w      d0
               bmi        aterror
               move.w     4(sp),d0
               lsr.w      #1,d0
               subq.w     #1,d0
atgetdat:      move.w     (a1),d1
               dbra       d0,atgetdat
               moveq.l    #0,d0
atcmdex:       rts        

idefound:      bsr        devready  ; device ready ?
               tst.b      d0
               beq.s      timeout
               bsr        atfehler
               tst.b      d0
               bne.s      mediaerr
               move.b     $1d(a1),d0
               btst       #3,d0
               beq.s      idefound2
               bsr        readout
idefound2:     moveq.l    #0,d0
               bra.s      init_dev_par
atokex:        moveq.l    #0,d0
               jmp        $7fe01990  ; jump to flush cache,errortest
init_dev_par:  jmp        $7fe01932  ; jump to wait,init device param
mediaerr:      jmp        $7fe019a8  ; jump to errorcode "read/write fault"
timeout:       jmp        $7fe019b6  ; jump to errorcode "unknown device"
devready:      jsr        $7fe01ece  ; test device ready without sel.dev
               rts