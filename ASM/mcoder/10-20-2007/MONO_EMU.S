; The Auto Mono Emulator. V5.00 By Mick West.  November 20th 1988.

; Routine to make the ST think it is in mono mode. Needs TOS in ROM
; Makes the system think that there is a mono screen, but actually
; be updating a medium real screen from this under Vblank interrupt
; The XBIOS calls; Physbase,Setscreen and Getrez are revectored.
; Put in an Auto Folder
; Works with any TOS in the entire world - hopefully


 MOVE.L 4(A7),A0
 MOVE.L #$8400,D6               ; 32K for the screen
 ADD.L $C(A0),D6                ; plus the usual space
 ADD.L $14(A0),D6
 ADD.L $1C(A0),D6
 MOVE.L D6,-(SP)                ; save length of program for later

 MOVE.W #4,-(SP)
 TRAP #14                       ; Get screen Resolution
 ADDQ.L #2,SP
 CMP.W #2,D0                    ; If not high then carry on
 BNE NOTHIGH        
 MOVE.L (SP)+,D6                ; else tidy up the stack
 MOVE.W #0,-(SP)                ; return ok to,GEM
 TRAP #1                        ; Then exit back to desktop
NOTHIGH:
 CLR.L -(SP)
 MOVE.W #32,-(SP)
 TRAP #1                        ; Enter supervisor mode
 ADDQ.L #6,SP
 MOVE.L D0,SAVESTACK            ; Save the supervisor stack

 MOVE.L #MESSAGE,-(SP)          ; Address of start of message
 MOVE.W #9,-(SP)                ; Print startup message
 TRAP #1
 ADDQ.L #6,SP
INLOOP:
 MOVE.L #INPUT,-(SP)
 MOVE.W #9,-(SP)                ; Print input message
 TRAP #1
 ADDQ.L #6,SP
 MOVE.B #3,MESSAGE              ; Input length = 3
 MOVE.L #MESSAGE,-(SP)
 MOVE.W #10,-(SP)
 TRAP #1                        ; Input number
 ADDQ.L #6,SP
 MOVE.W #40,D0                  ; Default = 40
 TST.B MESSAGE+1
 BEQ DEFAULT                    ; If len=0
 CMP.B #1,MESSAGE+1             ; len of 1 not allowed
 BEQ INLOOP
 CLR.W D0
 MOVE.B MESSAGE+2,D0            ; first digit
 SUB.W #48,D0
 BLE INLOOP                     ; Too low
 CMP.W #9,D0
 BGT INLOOP                     ; Too High (>100)
 MULU #10,D0
 CLR.W D1
 MOVE.B MESSAGE+3,D1            ; second digit
 SUB.W #48,D1
 BLT INLOOP                     ; Too low
 CMP.W #9,D1
 BGT INLOOP                     ; Too high
 ADD.W D1,D0
 CMP.W #80,D0
 BGT INLOOP                     ; Check less than 80
DEFAULT:
 MOVE.W D0,SCANPOKE+2
 SUB.L A5,A5
 MOVE.L  $044E(A5),MED          ; Set MED
 MOVE.L $B8,XBIOSPOKE+2         ; Get the old XBIOS address and
 MOVE.L $70,VBLANKPOKE+2        ; VBLANK and insert into new versions
 MOVE.L #0,MONOPOS              ; Set offset to top of screen
SCANPOKE:
 MOVE.W #40,MONOLINES           ; Fourty lines per Vblank is default
 MOVE.W #0,MONOCOUNT            ; Counter is set to zero
 LEA XEND,A2                    ; A2 = pos of generated code
 LEA GEN,A1                     ; A1 = pos of instructions to copy
 MOVE.W #39,D0                  ; Generate the code
GENMOVE1:
 MOVE.L (A1),(A2)+              ; Copys 40 of - MOVE.W (A0)+,(A1)+
 DBF D0,GENMOVE1                ; and           MOVE.W (A2)+,(A1)+
 ADDQ.L #4,A1
 MOVE.W (A1),(A2)+              ; Move the RTS
 MOVE.L A2,D0                   ; A2 = start of free memory
 ADD.L #512,D0                  ; Force it to a 512 byte boundry
 AND.L #$FFFFFE00,D0
 MOVE.L D0,$044E(A5)            ; And that is the monochrome screen
 MOVE.L D0,MONO                 ; Set MONO
 MOVE.W #$0002,-(SP)            ; Hardware and Software to Mono
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)
 TRAP #14                       ; Set high resolution
 ADD.L #12,SP
 MOVE.L	$70,A0			; Save the old VBLANK
 MOVE.L	#SIMPLE_VBLANK,$70	; And set up mine
 MOVE.W	#1,RASTER_FLAG		; Set raster flag to 'not occured yet'
WAIT_RASTER
 TST.W	RASTER_FLAG		; If still not occured
 BNE	WAIT_RASTER		; then loop until a vbl does occur
 MOVE.B	#1,$FF8260		; Back to medium hardware after VBL 
 MOVE.L	A0,$70
 MOVE.L #XBIOS,$B8              ; Set up the new XBIOS vector
 MOVE.L #VBLANK,$70             ; And the new VBLANK vector
 MOVE.L SAVESTACK,-(SP)         ; Restore the Supervisor stack
 MOVE.W #32,-(SP)               ; And go back to User mode
 TRAP #1
 ADDQ.L #6,SP
 MOVE.L (SP)+,D0                ; Tidy stack
 CLR.W -(SP)                    ; Exit ok for GEM
 MOVE.L D0,-(SP)                ; Length of program + data space
 MOVE.W #$31,-(SP)              ; terminate and stay resident (TSR)
 TRAP #1                        ; Finished this AUTO program

; This is the new XBIOS routine
XBIOS:                          
 MOVEM.L A1/A2,-(SP)            ; Save A1 and A2
 MOVE.L SP,A2                   ; A2 = the stack
 ADD.L #8,A2                    ; offset over A1 and A2
 BTST #5,(A2)                   ; Test if called from user mode
 BNE NOTUSER                    ; Skip if it is
 MOVE.L USP,A2                  ; Otherwise get A2 = User stack
 SUB.L #6,A2                    ; Offset it as if it were the SSP
NOTUSER:
 MOVE.W $6(A2),D0               ; Get XBIOS instruction code
 CMP.W #2,D0                    ; If it is _PHYSBASE 
 BEQ PHYSBASE                   ; then jump to new PHYSBASE routine
 CMP.W #4,D0                    ; If it is _GETREZ 
 BEQ GETREZ                     ; then jump to new GETREZ routine
 CMP.W #5,D0                    ; If it is NOT _SETSCREEN
 BNE NORM_XBIOS                 ; Then continue with the normal XBIOS
 MOVE.W #-1,16(A2)              ; Else alter rez.W to -1 (No change)
 MOVE.L 12(A2),D0               ; Get the ploc.L parameter
 CMP.L #-1,D0                   ; If it is -1 
 BEQ NORM_XBIOS                 ; then continue with normal XBIOS
 MOVE.L D0,MONO                 ; Otherwise, new value goes to MONO
 MOVE.L #-1,12(A2)              ; Set ploc.L to -1 (no change)
 BRA NORM_XBIOS                 ; then norm BIOS deals with lloc.L
PHYSBASE:
 MOVE.L MONO,D0                 ; Get address of mono screen
 MOVEM.L (SP)+,A1/A2            ; Tidy stack
 RTE                            ; Return mono screen location
GETREZ:
 MOVE.W #2,D0                   ; Pretend we are in mono resolution
 MOVEM.L (SP)+,A1/A2            ; Tidy the stack
 RTE                            ; Return code for mono resolution
NORM_XBIOS:
 MOVEM.L (SP)+,A1/A2            ; Tidy the stack up
XBIOSPOKE:
 JMP $0.L                       ; And jump into the normal XBIOS

; This is the new VBLANK routine
VBLANK: 
 MOVEM.L D0-D7/A0-A6,-(SP)      ; Save all registers
 MOVE.W #$333,$FF8242           ; Set up colours, grey for thin lines
 MOVE.W #$333,$FF8244           ; (1 vert mono pixel = 1 grey med pix)
 BTST #0,$FF8240                ; Check inverted
 BEQ INVERT                     ; Jump if so
 MOVE.W #$777,$FF8240           ; White background (normal)
 MOVE.W #$000,$FF8246           ; Black ink
 BRA NOINVERT
INVERT:
 MOVE.W #$000,$FF8240           ; Black background (inverted)
 MOVE.W #$777,$FF8246           ; White ink
NOINVERT:
 CLR.L D0                 
 MOVE.B $FF8201,D0              ; Video base high
 LSL.L #8,D0                    ; times 256
 MOVE.B $FF8203,D0              ; Plus video base low
 LSL.L #8,D0                    ; All times 256
 MOVE.L D0,A3                   ; Is the address of the Real screen
 MOVE.L MONO,A0                 ; A0 = virtual mono screen
 MOVE.L MED,A1                  ; A1 = real medium screen
 CMP.L A1,A3                    ; Check if the real screen has moved
 BEQ MEDOK                      ; Skip this if not
 MOVE.L A3,A0                   ; Get the new real screen address
 MOVE.L A0,MONO                 ; Set MONO From this
 MOVE.L A1,D0                   ; And put the real screen back 
 LSR.L #8,D0                    ; to its origional position
 MOVE.B D0,$FF8203         
 LSR.L #8,D0
 MOVE.B D0,$FF8201
MEDOK:
 MOVE.L A0,A2                   ; A2 = mono start
 ADD.L #80,A2                   ; plus 80, on to next line
 MOVE.L MONOPOS,D2              ; Get position in the screen RAM
 ADD.L D2,A0                    ; Offset position in mono screen
 ADD.L D2,A2                    ; And the other mono position
 ADD.L D2,A1                    ; Offset pos in real medium screen
 MOVE.W #20,D1                  ; default 20 lines / Vblank
 TST.B $43E                     ; Test flock system variable
 BNE COPYMOVE                   ; Set speed to 20 if using disk drive
 MOVE.W MONOLINES,D1            ; Otherwise get preset speed
COPYMOVE:
 BSR XEND                       ; combine and move two mono lines
 ADD.L #80,A0                   ; both need moving down another line
 ADD.L #80,A2                   ; in the mono screen
 ADD.L #160,MONOPOS             ; move down one medium/two mono lines
 ADD.W #1,MONOCOUNT             ; count medium lines dome
 CMP.W #200,MONOCOUNT           ; Done 200 medium/ 400 mono ?
 BNE NOT200                     ; if not then skip
 MOVE.L #0,MONOPOS              ; otherwise reset ram offset
 SUB.L #32000,A0                ; MONO position back to top of screen
 SUB.L #32000,A1                ; and the same for MEDIUM
 SUB.L #32000,A2                ; and the other MONO position
 MOVE.W #0,MONOCOUNT            ; reset the counter
NOT200:
 DBF D1,COPYMOVE                ; loop round MONOLINES times
VBLEXIT:
 MOVEM.L (SP)+,D0-D7/A0-A6      ; Restore all registers
VBLANKPOKE:
 JMP $0.L                       ; Jump to normal VBLANK routine

; This is a simple Vblank routine that just clears a flag 
SIMPLE_VBLANK
 CLR.W RASTER_FLAG		; Indicate a Vertical blank has occured
 RTE

; The following bits of code are not called but are used to calculate
; a large chunk of code to combine two mono lines into one medium one.
GEN:                            
 MOVE.W (A0)+,(A1)+              ; Move one Mono line to one Medium
 MOVE.W (A2)+,(A1)+              ; line on both colour planes times 40

 RTS
 
 EVEN
SAVESTACK: DC.L 0
MONO:      DC.L 0               ; Base address of mono screen
MED:       DC.L 0               ; Base address of medium screen
MONOPOS:   DC.L 0               ; Offset in both screens in bytes
MONOLINES: DC.L 0               ; Pairs of mono lines to do per VBLANK 
MONOCOUNT: DC.L 0               ; Count of pairs done so far
RASTER_FLAG:  DC.W	0	; Flag cleared every raster (tempory)

XEND: nop                       ; Position of calculated code 

MESSAGE:
 DC.B 27,'E','The Mono Emulator - Mick West 1988',13,10
 DC.B 'V5.00. Should be in AUTO Folder',13,10
 DC.B 'Will run with any TOS',13,10,13,10
 DC.B 'This is Shareware',13,10
 DC.B 'Send Money and Problems to:',13,10
 DC.B 'Mick West',13,10
 DC.B '27 Lynton Drive,',13,10
 DC.B 'Shipley,',13,10
 DC.B 'BD18 3DJ',13,10
 DC.B 'ENGLAND',13,10,13,10
 DC.B 'Feel free to give away copies of this',13,10
 DC.B 'But please copy the whole folder',13,10,13,10,0
INPUT:
 DC.B 13,10
 DC.B 'Enter speed (10 to 80, Return = 40) ',0
