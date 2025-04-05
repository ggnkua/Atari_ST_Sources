; The Auto Mono Emulator. V3.00 By Mick West.  April 1988.

; Routine to make the ST think it is in mono mode. Needs TOS in ROM
; Makes the system think that there is a mono screen, but actually
; be updating a medium real screen from this under Vblank interrupt
; The XBIOS calls; Physbase,Setscreen and Getrez are revectored.
; Put in an Auto Folder
; Calculates which ROM is in use from the date bytes ($FC0018.L)
; and installs the correct ROM call required from a table.

          movea.l   4(sp),a0
          move.l    #$8400,d6           ; 32K for the screen
          add.l     $c(a0),d6           ; plus the usual space
          add.l     $14(a0),d6
          add.l     $1c(a0),d6
          move.l    d6,-(sp)            ; save length of program for later

          move.w    #4,-(sp)
          trap      #14                 ; Get screen Resolution
          addq.l    #2,sp
          cmpi.w    #2,d0               ; If not high then carry on
          bne       NOTHIGH
          move.l    (sp)+,d6            ; else tidy up the stack
          move.w    #0,-(sp)            ; return ok to,GEM
          trap      #1                  ; Then exit back to desktop
NOTHIGH:  
          clr.l     -(sp)
          move.w    #32,-(sp)
          trap      #1                  ; Enter supervisor mode
          addq.l    #6,sp
          move.l    d0,SAVESTACK        ; Save the supervisor stack

          move.l    #MESSAGE,-(sp)      ; Address of start of message
          move.w    #9,-(sp)            ; Print startup message
          trap      #1
          addq.l    #6,sp

          move.l    $fc0018,d0          ; Get the date bytes from ROM
          lea.l     ROMTABLE,a0         ; Get start of rom table
FINDROM:  
          cmpi.l    #0,(a0)             ; Check if finished table
          beq       WRONGROM            ; Jump if no more ROMs
          cmp.l     (a0),d0             ; Check date bytes
          beq       RIGHTROM            ; Jump if they match
          adda.l    #8,a0               ; Go to next entry in the table
          bra       FINDROM             ; and try that
WRONGROM: 
          move.l    #WRONG,-(sp)        ; Address of start of message
          move.w    #9,-(sp)
          trap      #1                  ; Print message about crashing now.
          addq.l    #6,sp
          move.w    #1,-(sp)
          trap      #1                  ; Wait for keypress
          addq.l    #4,sp
          lea.l     ROMTABLE,a0         ; Default to the old british
RIGHTROM: 
          move.l    4(a0),ROMPOKE+2     ; Insert the ROM routine address

INLOOP:   
          move.l    #INPUT,-(sp)
          move.w    #9,-(sp)            ; Print input message
          trap      #1
          addq.l    #6,sp
          move.b    #3,MESSAGE          ; Input length = 3
          move.l    #MESSAGE,-(sp)
          move.w    #10,-(sp)
          trap      #1                  ; Input number
          addq.l    #6,sp
          move.w    #40,d0              ; Default = 40
          tst.b     MESSAGE+1
          beq       DEFAULT             ; If len=0
          cmpi.b    #1,MESSAGE+1        ; len of 1 not allowed
          beq       INLOOP
          clr.w     d0
          move.b    MESSAGE+2,d0        ; first digit
          subi.w    #48,d0
          ble       INLOOP              ; Too low
          cmpi.w    #9,d0
          bgt       INLOOP              ; Too High (>100)
          mulu.w    #10,d0
          clr.w     d1
          move.b    MESSAGE+3,d1        ; second digit
          subi.w    #48,d1
          blt       INLOOP              ; Too low
          cmpi.w    #9,d1
          bgt       INLOOP              ; Too high
          add.w     d1,d0
          cmpi.w    #80,d0
          bgt       INLOOP              ; Check less than 80
DEFAULT:  
          move.w    d0,SCANPOKE+2
          suba.l    a5,a5
          move.l    $0000044e(a5),MED   ; Set MED
          move.l    $b8,XBIOSPOKE+2     ; Get the old XBIOS address and
          move.l    $70,VBLANKPOKE+2    ; VBLANK and insert into new versions
          move.l    #0,MONOPOS          ; Set offset to top of screen
SCANPOKE: 
          move.w    #40,MONOLINES       ; Fourty lines per Vblank is default
          move.w    #0,MONOCOUNT        ; Counter is set to zero
          lea.l     XEND,a2             ; A2 = pos of generated code
          lea.l     GEN,a1              ; A1 = pos of instructions to copy
          move.w    #39,d0              ; Generate the code
GENMOVE1: 
          move.l    (a1),(a2)+          ; Copys 40 of - MOVE.W (A0)+,(A1)+
          dbf       d0,GENMOVE1         ; and           MOVE.W (A2)+,(A1)+
          addq.l    #4,a1
          move.w    (a1),(a2)+          ; Move the RTS
          move.l    a2,d0               ; A2 = start of free memory
          addi.l    #512,d0             ; Force it to a 512 byte boundry
          andi.l    #$fffffe00,d0
          move.l    d0,$0000044e(a5)    ; And that is the monochrome screen
          move.l    d0,MONO             ; Set MONO
          move.w    #$0001,-(sp)        ; Hardware to medium
          move.l    #-1,-(sp)
          move.l    #-1,-(sp)
          move.w    #5,-(sp)
          trap      #14                 ; Set medium resolution for hardware
          adda.l    #12,sp
          move.b    #$02,$0000044c      ;.L        ; set high resolution for software
          move.w    #0,$452             ; Turn off VBLANK
ROMPOKE:  
          jsr       $0                  ; The only ROM call, set up rez info
          move.w    #1,$452             ; Turn on VBLANK
          move.l    #XBIOS,$b8          ; Set up the new XBIOS vector
          move.l    #VBLANK,$70         ; And the new VBLANK vector
          move.l    SAVESTACK,-(sp)     ; Restore the Supervisor stack
          move.w    #32,-(sp)           ; And go back to User mode
          trap      #1
          addq.l    #6,sp
          move.l    (sp)+,d0            ; Tidy stack
          clr.w     -(sp)               ; Exit ok for GEM
          move.l    d0,-(sp)            ; Length of program + data space
          move.w    #$31,-(sp)          ; terminate and stay resident (TSR)
          trap      #1                  ; Finished this AUTO program

; This is the new XBIOS routine
XBIOS:    
          movem.l   a1/a2,-(sp)         ; Save A1 and A2
          movea.l   sp,a2               ; A2 = the stack
          adda.l    #8,a2               ; offset over A1 and A2
          btst      #5,(a2)             ; Test if called from user mode
          bne       NOTUSER             ; Skip if it is
          move.l    usp,a2              ; Otherwise get A2 = User stack
          suba.l    #6,a2               ; Offset it as if it were the SSP
NOTUSER:  
          move.w    $6(a2),d0           ; Get XBIOS instruction code
          cmpi.w    #2,d0               ; If it is _PHYSBASE
          beq       PHYSBASE            ; then jump to new PHYSBASE routine
          cmpi.w    #4,d0               ; If it is _GETREZ
          beq       GETREZ              ; then jump to new GETREZ routine
          cmpi.w    #5,d0               ; If it is NOT _SETSCREEN
          bne       NORM_XBIOS          ; Then continue with the normal XBIOS
          move.w    #-1,16(a2)          ; Else alter rez.W to -1 (No change)
          move.l    12(a2),d0           ; Get the ploc.L parameter
          cmpi.l    #-1,d0              ; If it is -1
          beq       NORM_XBIOS          ; then continue with normal XBIOS
          move.l    d0,MONO             ; Otherwise, new value goes to MONO
          move.l    #-1,12(a2)          ; Set ploc.L to -1 (no change)
          bra       NORM_XBIOS          ; then norm BIOS deals with lloc.L
PHYSBASE: 
          move.l    MONO,d0             ; Get address of mono screen
          movem.l   (sp)+,a1/a2         ; Tidy stack
          rte                           ; Return mono screen location
GETREZ:   
          move.w    #2,d0               ; Pretend we are in mono resolution
          movem.l   (sp)+,a1/a2         ; Tidy the stack
          rte                           ; Return code for mono resolution
NORM_XBIOS:         
          movem.l   (sp)+,a1/a2         ; Tidy the stack up
XBIOSPOKE:          
          jmp       $0                  ;.L                       ; And jump into the normal XBIOS

; This is the new VBLANK routine
VBLANK:   
          movem.l   d0-d7/a0-a6,-(sp)   ; Save all registers
          move.w    #$333,$ff8242       ; Set up colours, grey for thin lines
          move.w    #$333,$ff8244       ; (1 vert mono pixel = 1 grey med pix)
          btst      #0,$ff8240          ; Check inverted
          beq       INVERT              ; Jump if so
          move.w    #$777,$ff8240       ; White background (normal)
          move.w    #$0000,$ff8246      ; Black ink
          bra       NOINVERT
INVERT:   
          move.w    #$0000,$ff8240      ; Black background (inverted)
          move.w    #$777,$ff8246       ; White ink
NOINVERT: 
          clr.l     d0
          move.b    $ff8201,d0          ; Video base high
          lsl.l     #8,d0               ; times 256
          move.b    $ff8203,d0          ; Plus video base low
          lsl.l     #8,d0               ; All times 256
          movea.l   d0,a3               ; Is the address of the Real screen
          movea.l   MONO,a0             ; A0 = virtual mono screen
          movea.l   MED,a1              ; A1 = real medium screen
          cmpa.l    a1,a3               ; Check if the real screen has moved
          beq       MEDOK               ; Skip this if not
          movea.l   a3,a0               ; Get the new real screen address
          move.l    a0,MONO             ; Set MONO From this
          move.l    a1,d0               ; And put the real screen back
          lsr.l     #8,d0               ; to its origional position
          move.b    d0,$ff8203
          lsr.l     #8,d0
          move.b    d0,$ff8201
MEDOK:    
          movea.l   a0,a2               ; A2 = mono start
          adda.l    #80,a2              ; plus 80, on to next line
          move.l    MONOPOS,d2          ; Get position in the screen RAM
          adda.l    d2,a0               ; Offset position in mono screen
          adda.l    d2,a2               ; And the other mono position
          adda.l    d2,a1               ; Offset pos in real medium screen
          move.w    #10,d1              ; default 10 lines / Vblank
          tst.b     $43e                ; Test flock system variable
          bne       COPYMOVE            ; Set speed to 10 if using disk drive
          tst.b     $9be                ; Test if motor on ? (not sure)
          bne       COPYMOVE            ; Jump if using disk
          move.w    MONOLINES,d1        ; Otherwise get preset speed
COPYMOVE: 
          bsr       XEND                ; combine and move two mono lines
          adda.l    #80,a0              ; both need moving down another line
          adda.l    #80,a2              ; in the mono screen
          addi.l    #160,MONOPOS        ; move down one medium/two mono lines
          addi.w    #1,MONOCOUNT        ; count medium lines dome
          cmpi.w    #200,MONOCOUNT      ; Done 200 medium/ 400 mono ?
          bne       NOT200              ; if not then skip
          move.l    #0,MONOPOS          ; otherwise reset ram offset
          suba.l    #32000,a0           ; MONO position back to top of screen
          suba.l    #32000,a1           ; and the same for MEDIUM
          suba.l    #32000,a2           ; and the other MONO position
          move.w    #0,MONOCOUNT        ; reset the counter
NOT200:   
          dbf       d1,COPYMOVE         ; loop round MONOLINES times
VBLEXIT:  
          movem.l   (sp)+,d0-d7/a0-a6   ; Restore all registers
VBLANKPOKE:         
          jmp       $0                  ;.L                       ; Jump to normal VBLANK routine
; The following bits of code are not called but are used to calculate
; a large chunk of code to combine two mono lines into one medium one.
GEN:      
          move.w    (a0)+,(a1)+         ; Move one Mono line to one Medium
          move.w    (a2)+,(a1)+         ; line on both colour planes times 40

          rts       

          .EVEN 
SAVESTACK:          .DC.l 0
MONO:     .DC.l 0   ; Base address of mono screen
MED:      .DC.l 0   ; Base address of medium screen
MONOPOS:  .DC.l 0   ; Offset in both screens in bytes
MONOLINES:          .DC.l 0             ; Pairs of mono lines to do per VBLANK
MONOCOUNT:          .DC.l 0             ; Count of pairs done so far

XEND:     nop                           ; Position of calculated code

MESSAGE:  
          .DC.b 27,'E','The Mono Emulator - Mick West 1988',13,10
          .DC.b 'V3.00. Should be in AUTO Folder',13,10,13,10
          .DC.b 'This is Shareware',13,10
          .DC.b 'Send Money and Problems to:',13,10
          .DC.b '27 Lynton Drive,',13,10
          .DC.b 'Shipley,',13,10
          .DC.b 'BD18 3DJ',13,10
          .DC.b 'ENGLAND',13,10,13,10
          .DC.b 'Feel free to give away copies of this',13,10
          .DC.b 'But please copy the whole folder',13,10,13,10,0
INPUT:    
          .DC.b 13,10
          .DC.b 'Enter speed (10 to 80, return = 40) ',0
WRONG:    
          .DC.b 'Sorry I do not recognise this Version of',13,10
          .DC.b 'TOS, I will carry on and probably crash.',13,10
          .DC.b 'Please read MONOEMU.DOC. Press a Key',13,10,0

          .EVEN 

; This is a table of ROM creation dates ($FC0018) and the corresponding
; ROM routine to set up the resolution information. If you can add to
; this then please let me know the two numbers.
; The ROM routine is called as part of XBIOS _SETSCREEN routine,
; it is the last routine called. See MONOEMU.DOC for more info.

ROMTABLE: 
          .DC.l $11201985,$00fca76a     ; Old British (1.08)
          .DC.l $04221987,$00fca914     ; New British (1.09)

; Insert any more here with comments, leave the following terminator

          .DC.l $02061986,$00fca7c4     ; German      (1.04)
