; The Mono Emulator. By Mick West.  September 1987.

; Routine to make the ST think it is in mono mode. Needs TOS in ROM
; Makes the system think that there is a mono screen, but actually
; be updating a medium real screen from this under Vblank interrupt
; The XBIOS calls; Physbase,Setscreen and Getrez are revectored.

START:
 MOVE.L #MESSAGE,-(SP)
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


 CLR.L -(SP)
 MOVE.W #32,-(SP)
 TRAP #1                        ; ENTER SUPER MODE
 ADDQ.L #6,SP

 MOVE.W  #$2700,SR              ; Normal ROM reset routine starts here
 RESET
 CMP.L   #$FA52235F,$FA0000.L
 BNE     FC003C
 LEA     FC003C,A6
 JMP     $FA0004.L
FC003C:
 LEA     FC0044,A6
 JMP     $FC05D8
FC0044:
 BNE     FC0050
 MOVE.B  $000424.L,$FF8001.L
FC0050:
 SUB.L   A5,A5
 CMP.L   #$31415926,$0426(A5)
 BNE     FC0074
 MOVE.L  $042A(A5),D0
 TST.B   $042A(A5)
 BNE     FC0074
 BTST    #$0000,D0
 BNE     FC0074
 MOVE.L  D0,A0
 LEA     FC0050,A6
 JMP     (A0)
FC0074:
 LEA     $FF8800.L,A0
 MOVE.B  #$0007,(A0)
 MOVE.B  #$00C0,$0002(A0)
 MOVE.B  #$000E,(A0)
 MOVE.B  #$0007,$0002(A0)
 BTST    #$0000,$FC001D
 BEQ     FC00A6
 LEA     FC009E,A6
 JMP     $FC0CE4
FC009E:
 MOVE.B  #$0002,$FF820A.L
FC00A6:
 MOVE.B  #$0001,$FF8201.L
 MOVE.B  #$0000,$FF8203.L
 SUB.L   A5,A5
; Memory sizing missed out
 MOVE.W  #$093A,A0
 MOVE.L  #$00010000,A1
 MOVEQ   #$00,D0
FC01D0:
 MOVE.W  D0,(A0)+
 CMP.L   A0,A1
 BNE     FC01D0
;
; SCREEN SET UP HERE
;
 MOVE.L  $042E(A5),A0           ; Phystop of RAM
 SUB.L   #$00008000,A0          ; less 32K
 MOVE.L  A0,$044E(A5)           ; is the Physbase of screen
 MOVE.L  A0,MED+SPACE           ; Set MED
 MOVE.B  $044F(A5),$FF8201.L    ; configure hardware addr
 MOVE.B  $0450(A5),$FF8203.L
 MOVE.W  #$0777,$FF8240         ; White background
 MOVE.W  #$0000,$FF8246         ; Black ink for double line
 MOVE.W  #$07FF,D1
FC01F8:
 MOVE.L  D0,(A0)+
 MOVE.L  D0,(A0)+
 MOVE.L  D0,(A0)+
 MOVE.L  D0,(A0)+
 DBF     D1,FC01F8              ; clear the screen
 MOVE.L $044E(A5),A0
 SUB.L #$8000,A0                ; Reserve another 32k
 MOVE.L A0,$044E(A5)            ; For the mono screen
 MOVE.L A0,MONO+SPACE           ; Set MONO
 MOVE.L  $FC0014,A0
 CMP.L   #$87654321,(A0)
 BEQ     FC0214
 LEA     $FC0008,A0
FC0214:
 MOVE.L  $0004(A0),$0004FA.L
 MOVE.L  $0008(A0),$0004FE.L
 MOVE.L  #$00FC0D60,$046A(A5)
 MOVE.L  #$00FC10D2,$0476(A5)
 MOVE.L  #$00FC0DE6,$0472(A5)
 MOVE.L  #$00FC0F96,$047E(A5)
 MOVE.L  #$00FC137C,$047A(A5)
 MOVE.L  #$00FC1F34,$0506(A5)
 MOVE.L  #$00FC1EA0,$050A(A5)
 MOVE.L  #$00FC1F6E,$050E(A5)
 MOVE.L  #$00FC1F86,$0512(A5)
 MOVE.L  #$00FC0C2C,$0502(A5)

 MOVE.L  $044E(A5),$0436(A5)    ; Memtop = Physbase
 SUB.L   #$400,$0436(A5)        ;          minus 1k

 MOVE.L  $04FA(A5),$0432(A5)
 LEA     $004DB8.L,A7
 MOVE.W  #$0008,$0454(A5)
 ST      $0444(A5)
 MOVE.W  #$0003,$0440(A5)
 MOVE.L  #$0000167A,$04C6(A5)
 MOVE.W  #$FFFF,$04EE(A5)
 MOVE.L  #$00FC0000,$04F2(A5)
 MOVE.L  #$0000093A,$04A2(A5)
 MOVE.L  #$00FC05C0,$046E(A5)
 LEA     $FC0724,A3
 LEA     $FC05C0,A4
 CMP.L   #$FA52235F,$FA0000.L
 BEQ     FC02F6
 LEA     $FC0A1A,A1
 ADD.L   #$02000000,A1
 LEA     $000008.L,A0
 MOVE.W  #$003D,D0
FC02E4:
 MOVE.L  A1,(A0)+
 ADD.L   #$01000000,A1
 DBF     D0,FC02E4
 MOVE.L  A3,$000014.L
FC02F6:
 MOVE.L  #$00FC061E,$0068(A5)
 MOVE.L  A3,$0088(A5)
 MOVE.L  #$00FC074E,$00B4(A5)
 MOVE.L  #$00FC9C48,$0028(A5)
 MOVE.L  A4,$0400(A5)
 MOVE.L  #$00FC0744,$0404(A5)
 MOVE.L  A4,$0408(A5)

 MOVE.L $0436(A5),A0
 ADD.L #SPACE-XBIOS,A0
 MOVE.L A0,POKE1+2              ; SPACE ADDR
 MOVE.L A0,POKE2+2              ; IN BOTH ROUTINES
 MOVE.L #0,MONOPOS+SPACE        ; SET FLY TO TOP OF SCREEN
SCANPOKE:
 MOVE.W #40,MONOLINES+SPACE     ; FORTY LINES/VBLAN DEFAULT
 MOVE.W #0,MONOCOUNT+SPACE      ; NONE DONE YET
 MOVE.L $0436(A5),A2            ; Get Memtop
 MOVE.L #XBIOS,A1               ; NOW MOVE THE
 MOVE.W #XEND-XBIOS-1,D0        ; CODE FOR XBIOS & VBLANK
XMOVE:                          
 MOVE.B (A1)+,(A2)+
 DBF D0,XMOVE
 LEA GEN,A1                     ; Generate the move code
 MOVE.W #39,D0                  ; 40 MOVE's  to the first plane
GENMOVE1:
 MOVE.L (A1),(A2)+
 DBF D0,GENMOVE1
 ADDQ.L #4,A1
 MOVE.W (A1)+,(A2)+             ; Move the SUB #158,A0
 MOVE.L (A1)+,(A2)+
 MOVE.W #39,D0                  ; 40 MOVE's to the other plane
GENMOVE2:
 MOVE.L (A1),(A2)+
 DBF D0,GENMOVE2
 ADDQ.L #4,A1
 MOVE.W (A1),(A2)+              ; Move the RTS

 MOVE.L $0436(A5),A0
 MOVE.L A0,$B8                  ; New XBIOS  Vector  to $B8
 ADD.L #VBLANK-XBIOS,A0
 MOVE.L A0,$70                  ; New VBLANK Vector  to $70
 LEA     $04CE(A5),A0
 MOVE.L  A0,$0456(A5)
 MOVE.W  #$0007,D0
FC033E:
 CLR.L   (A0)+
 DBF     D0,FC033E
 JSR     $FC21B4
 MOVEQ   #$02,D0
 JSR     $FC0596
FC0360:
 LEA     FC0376,A6
 JMP     $FC0CE4                ; Wait for fly
FC0376:
 MOVE.B  #$0001,$FF8260.L       ; Hardware to medium
 MOVE.B  #$0002,$00044C.L       ; software to mono
FC0386:
 JSR     $FCA76A.L
FC03A0:
 JMP $FC03A8                    ; Jump back into ROM


XBIOS:                          
 MOVEM.L A1/A2,-(SP)
POKE1:
 MOVE.L #0,A1
 MOVE.L SP,A2                   ; A2=STACK
 ADD.L #8,A2                    ; SKIP A1/A2
 BTST #5,(A2)                   ; IF CALLED FROM USER MODE
 BNE NOTUSER                    ; THEN
 MOVE.L USP,A2                  ; GET THE USER STACK
 SUB.L #6,A2                    ; OFFSET AS SUPER STACK
NOTUSER:
 MOVE.W $6(A2),D0               ; GET CODE
 CMP.W #2,D0                    ; CHECK FOR PHYSBASE CODE
 BEQ PHYSBASE                   ; JUMP TO NEW PHYSBASE ROUTINE
 CMP.W #4,D0                    ; CHECK FOR GETREZ CODE
 BEQ GETREZ                     ; JUMP TO NEW GETREZ ROUTINE
 CMP.W #5,D0                    ; CHECK FOR SETSCREEN CODE
 BNE NORM_XBIOS                 ; NOTHING NEEDS CHANGING SO NORMAL XBIOS
 MOVE.W #-1,16(A2)              ; NO CHANGE TO RESOLUTION
 MOVE.L 12(A2),D0               ; GET NEW PHYS
 CMP.L #-1,D0                   ; IF NEGATIVE
 BEQ NORM_XBIOS                 ; THEN NO CHANGE
 MOVE.L D0,MONO(A1)             ; NEW BASE FOR MONO
 MOVE.L #-1,12(A2)              ; SET TO NO CHANGE
 BRA NORM_XBIOS                 ; AND CONTINUE WITH NORMAL XBIOS
PHYSBASE:
 MOVE.L MONO(A1),D0             ; GET MONO ADDR
 MOVEM.L (SP)+,A1/A2
 RTE                            ; AND RETURN IT AS 'REAL' SCREEN
GETREZ:
 MOVE.W #2,D0                   ; RETURN MONO RESOLUTION
 MOVEM.L (SP)+,A1/A2
 RTE
NORM_XBIOS:
 MOVEM.L (SP)+,A1/A2
 JMP $FC0748                    ; JUMP INTO THE NORMAL XBIOS ROUTINE

VBLANK: 
 MOVEM.L D0-D7/A0-A6,-(SP)
 MOVE.W #$333,$FF8242           ; Grey for the single width lines
 MOVE.W #$333,$FF8244           ; For 01 and 10
 BTST #0,$FF8240                ; Check inverted
 BEQ INVERT                     ; Jump if so
 MOVE.W #$777,$FF8240           ; White background
 MOVE.W #$000,$FF8246           ; Black ink
 BRA POKE2
INVERT:
 MOVE.W #$000,$FF8240           ; Black background
 MOVE.W #$777,$FF8246           ; White ink
POKE2:
 MOVE.L #0,A5                   ; A5 To base of variable space
 CLR.L D0
 MOVE.B $FF8201,D0              ; Video base high
 LSL.L #8,D0
 MOVE.B $FF8203,D0              ; Video base low
 LSL.L #8,D0
 MOVE.L D0,A3
 MOVE.L MONO(A5),A0
 MOVE.L MED(A5),A1
 CMP.L A1,A3                    ; Is MED still the real screen
 BEQ MEDOK                      ; Yes so jump
 MOVE.L A3,A0
 MOVE.L A0,MONO(A5)             ; Set MONO From new Physbase
 MOVE.L A1,D0
 LSR.L #8,D0
 MOVE.B D0,$FF8203              ; Set Physbase back to MED
 LSR.L #8,D0
 MOVE.B D0,$FF8201
MEDOK:
 MOVE.L MONOPOS(A5),D2
 ADD.L D2,A0
 ADD.L D2,A1
 MOVE.W #10,D1
 TST.B $43E
 BNE COPYMOVE                   ; Set speed to 10 if using disk drive
 TST.B $9BE
 BNE COPYMOVE                     
 MOVE.W MONOLINES(A5),D1        ; Otherwise get preset speed
COPYMOVE:
 BSR XEND                       ; COMBINE & MOVE TWO MONO LINES
 SUBQ.L #2,A1                   ; BACK TO NORMAL PLANE
 ADD.L #160,MONOPOS(A5)         ; DOWN ONE MED, TWO MONO LINES
 ADD.W #1,MONOCOUNT(A5)         ; ONE MORE LINE
 CMP.W #200,MONOCOUNT(A5)       ; DONE 200 ?
 BNE NOT200
 MOVE.L #0,MONOPOS(A5)          ; BACK TO TOP OF SCREEN
 SUB.L #32000,A0                ; FOR MONO
 SUB.L #32000,A1                ; AND MED
 MOVE.W #0,MONOCOUNT(A5)        ; RESET THE COUNTER
NOT200:
 DBF D1,COPYMOVE                ; LOOP ROUND MONOLINES TIMES
 MOVEM.L (SP)+,D0-D7/A0-A6
 ADDQ.L #1,$466                 ; FIRST BIT OF NORMAL VBLANK
 SUBQ.W #1,$452                 ; TEST IF ENABLED
 BMI NOVBL                      ; SKIP IF NOT
 MOVEM.L D0-D7/A0-A6,-(A7)
 ADDQ.L #1,$462
 SUB.L A5,A5
 JMP $FC069E                    ; SKIP MONITOR DETECTION
NOVBL:
 ADDQ.W #1,$452
 RTE                            ; NO VBLANK SO RETURN

GEN:                            
 MOVE.W (A0)+,(A1)              ; FORTY MOVES TO MOVE ONE LINE
 ADDQ.L #4,A1

 SUB.L #158,A1                  ; A1 BACK TO THE START OF THE LINE
                                
 MOVE.W (A0)+,(A1)              ; THEN FORTY MOVES TO NEXT PLANE
 ADDQ.L #4,A1
 RTS

SPACE: DS.L 6
XEND:

MESSAGE:
 DC.B 27,'E','The Mono Emulator - Mick West 1987',13,10
 DC.B        'This program is Shareware, If you',13,10
 DC.B        'find it useful then send a donation to',13,10,13,10
 DC.B        'Mick West',13,10
 DC.B        '27 Lynton Drive',13,10
 DC.B        'Shipley',13,10
 DC.B        'West Yorkshire',13,10
 DC.B        'BD18 3DJ',13,10
 DC.B        'ENGLAND',13,10,13,10
 DC.B        'Your Donation will be used to ',13,10
 DC.B        'Develope more Shareware',13,10
 DC.B        'This program can be freely copied.',13,10
 DC.B 13,10,0
INPUT:
 DC.B 13,10
 DC.B        'Enter speed (10 to 80, return = 40) '
 
 EVEN
MONO:      EQU 0                ; ADDR OF MONO SCREEN
MED:       EQU 4                ; ADDR OF REAL MEDIUM SCREEN
MONOPOS:   EQU 8                ; POSITION IN MONO SCREEN
MONOLINES: EQU 12               ; NO OF LINES/VBLANK
MONOCOUNT: EQU 14               ; LINE NO IN MONO


