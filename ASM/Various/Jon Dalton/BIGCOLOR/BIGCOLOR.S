;                    BIGCOLOR.PRG V1.05
;                    JON DALTON    
;                    DECEMBER 1989

 MOVE.W #4,-(SP)
 TRAP #14                 ; Check MONO monitor attached
 ADDQ.L #2,SP
 CMP.W #2,D0              ; If not, then end program (NODO)
 BEQ HIGH
NODO:        
 MOVE.L #MONO1,-(SP)      ; Address of end message
 MOVE.W #9,-(SP)          ; Print message
 TRAP #1
 ADDQ.L #6,SP
 MOVE.W #0,-(SP)          ; End program and return to GEM desktop
 TRAP #1                      
HIGH:
 CLR.L -(SP)              ; Go into Supervisor mode
 MOVE.W #32,-(SP)
 TRAP #1                      
 ADDQ.L #6,SP
 MOVE.L D0,SUPERVISOR      ; Save the old stack pointer
                                                        
;The next 16 lines check whether the program has already been run by
;checking memory location $3EC for 'magic number' $ABCCBA12.  If
;it has been run, memory location $3F0 should contain start address
;of the program in high memory.  If not, it reserves memory by changing
;$42E (PHYSTOP) and rebooting.
 CMP.L #$abccba12,$3Ec
 BNE DUMPIT
 MOVE.L $42E,D0
 CMP.L $3F0,D0
 BLE ITSOK
 MOVE.L $3F0,$42E
 RESET
DUMPIT:
 MOVE.L $42E,A0
 CMP.L #$abccba12,(A0)
 BEQ ITSOK
RESSET:
 MOVE.L #$abccba12,$3Ec
 SUB.L #$32000,$42E
 MOVE.L $42E,$436
 MOVE.L $42E,$3F0
 RESET

ITSOK:
 MOVE.L #$ABCCBA12,$3EC
 MOVE.L #STARTUP,-(SP)      ; Print STARTUP
 MOVE.W #9,-(SP)               
 TRAP #1
 ADDQ.L #6,SP

;Input the screen refresh rate
INPUTT:
 MOVE.L #INPUT,-(SP)
 MOVE.W #9,-(SP)              ; Print message
 TRAP #1
 ADDQ.L #6,SP
 MOVE.B #1,STORE             
 MOVE.L #STORE,-(SP)
 MOVE.W #10,-(SP)             ; Input the digit  
 TRAP #1                      
 ADDQ.L #6,SP
 TST.B STORE+1
 BNE INPUTOK             ; If return has been pressed, SPEED is set to 14
 MOVE.L #AVERAGE,-(SP)
 MOVE.W #9,-(SP)              ; Print AVERAGE
 TRAP #1
 ADDQ.L #6,SP
 MOVE.W #14,D0
 BRA DEFAULT
INPUTOK:
 MOVE.B STORE+2,D0         
 SUB.W #47,D0
 BLE INPUTT          ; Not a number or letter
 CMP.W #10,D0
 BGT NODO            ; A letter has been entered, so exit the program
 SUB.W #1,D0
 MULU #4,D0          ; Multiply by 4 to get SPEED
 TST D0
 BNE DEFAULT
 MOVE.W #50,D0       ; Zero entered, so set SPEED equal to 50
DEFAULT:
 MOVE.W D0,SPEED

;The next 24 lines check whether the program is already installed in
;high memory, and activates it by setting up VBLANK, XBIOS  MONITOR-
;CHANGED and ETVTERM VECTORS, the addresses of which are at the start of
;the program which is found from $3F0.  It also sets up the new SPEED,
;and sets GEM desktop to colour.
 MOVE.L $3F0.W,D0
 MOVE.L D0,A0        ; Checks the program has been installed before
 MOVE.L (A0),D0
 CMP.L #$ABCCBA12,D0 ; 'Magic Number'
 BNE INSTALL
 MOVE.W SR,-(SP)
 OR.W #$0700,SR       ; Set interupt level to 7
 ADDQ.L #4,A0
 MOVE.L (A0)+,$0B8.W  ; Sets up the new vectors
 MOVE.L (A0)+,$070.W
 MOVE.L (A0)+,$46E.W
 MOVE.L (A0)+,$408.W
 MOVE.L (A0)+,A0
 MOVE.L SPEED,(A0)     ; Set SPEED that has been entered
 ADD.L #28,A0
 MOVE.B #3,(A0)
 MOVE.W (SP)+,SR
 MOVE.W #37,-(SP)
 TRAP #14
 ADDQ.L #2,SP
 MOVE.W #0,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)     ; Set GEM DESKTOP to colour
 TRAP #14
 ADD.L #12,SP
 BRA ENDPROG

;Program has not been installed before. 
INSTALL:
 MOVE.L #CALCULATE,-(SP)
 MOVE.W #9,-(SP)           ; Print message that it is installing.
 TRAP #1
 ADD.L #6,SP

;TABLE CALCULATION.  The next 42 lines calculates a lookup table
;that converts a binary word %aaaaaaaabbbbbbbb into a binary word
;%babababababababa. It does this transformation on all possible
;words, starting at $0000 then $0001 etc up to $FFFE.  $FFFF is added 
;at the end.  It is slow as it has to check every bit of every word.
 MOVE.L #CODE,D0   ; Place the lookup table at this address
 MOVE.L D0,TABLE   ; $20000 bytes long
 CLR.L D4                     
 MOVE.W #0,D4
 MOVE.L D0,A4            
 CLR.L D0                
 CLR.L D2
WORDLOOP:
 CLR.L D6
 CLR.L D5
 CLR.L D3
 MOVE #7,D5       ; Loop round 8 times for one byte (the low byte)
 MOVE #1,D3       ; D3 is a mask which moves up the byte
 MOVE.L D3,D1     ; D1 contains the position of the mask temporarily
 MOVE.L D4,D0     ; D4 contains the word which is being transformed
BITLOOP:
 AND.L D0,D1      ; D0 contains the word temporarily
 MULU D1,D1       ; Move the bit to its new location, if it was set
 ADD.L D1,D2      ; D2 has the transformed set bits added to it
 ADD D3,D3        ; Shift the mask left one bit 
 MOVE.L D3,D1
 DBF D5,BITLOOP   ; Loop round 8 times
 TST.L D6         ; D6 is set when the high byte has been dealt with
 BNE MOREDO1:
 LSR.L #8,D0      ; Move the high byte to the low byte
 LSL.L #1,D2      ; Offset the bits that have already been calculated
 CLR.L D3
 CLR.L D1
 MOVE #1,D3       ; Reset the mask (D3) to #1 
 MOVE D3,D1
 MOVE.L #1,D6     ; Set D6 to indicate high byte is being dealt with
 MOVE.L #7,D5
 BRA BITLOOP      ; Repeat the process (high byte is now low byte) 
MOREDO1:
 CLR.L D6         ; Clear D6 ready to start a new word 
 MOVE.W D2,(A4)+  ; Save the completed transformed word in the table
 CLR.L D2
 ADDQ #1,D4       ; Add #1 to get the next word to transform
 CMP #$FFFF,D4    ; Check whether all the words have been done
 BEQ FINISH
 BRA WORDLOOP     ; Loop back to calculate the next word
FINISH:
 MOVE.W #$FFFF,(A4)+  ; The last entry in the table

;Set up the extra screen needed for monochrome, and the check screen.
;Place the screens after the table, making sure they lie on a 256-byte
;boundary.
 MOVE.L A4,D0        ; A4 is the address after the table
 ADD.L #$100,D0                  
 AND.L #$FFFFFF00,D0 ; Make sure that last byte is zero (for screen)      
 MOVE.L D0,MONO      ; Set MONO screen (which is actually displayed)
 ADD.L #$8000,D0     ; COLOURCHECK screen to detect changes in COL screen
 MOVE.L D0,COLOURCHECK

;Work out OFFSET for where the program is to be moved to in high memory
 MOVE.L $3F0,D1
 SUB.L #MONITOR,D1
 ADD.L #512,D1
 AND.L #$FFFFFE00,D1
 MOVE.L D1,OFFSET
 ADD.L D1,MONO
 ADD.L D1,TABLE
 ADD.L D1,COLOURCHECK

;Clear the new screens
 MOVE.L COLOURCHECK,A4
 MOVE.L MONO,A5
 CLR.L D1
 CLR.L D0
 MOVE.W #7999,D1
LOADIT:
 MOVE.L D0,(A4)+     ; Loads the table with zero to start
 MOVE.L D0,(A5)+
 DBF D1,LOADIT
 MOVE.L $44E.W,COL   ; Set up COL address (colour screen)

;Move the actual display to MONO address and set up SCRNCHK (to detect if
;the displayed screen address has been changed)
 MOVE.L MONO,D0
 LSR.L #8,D0
 MOVE.L #$FF8200,A5
 MOVEP.W D0,1(A5)
 MOVE.L (A5),SCRNCHK
 CLR.L D0

;Put the VECTOR addresses in the new code (replacing DUMMY) and set
;up the other variables.
 MOVE.L $B8.W,VECTOR1+2     
 MOVE.L $70.W,VECTOR2+2     
 MOVE.L $70.W,VECTOR2A+2
 MOVE.L $408.W,VECTOR3+2
 MOVE.L $70.W,VBLADD
 MOVE.L #0,POSITION         ; Set the position to the top
 MOVE.L #199,COUNTER        ; Set counter to count down from 200 (DBF loop)
 MOVE.B #0,COLOR            ; Set COLOR to #0 (Low Resolution)
 MOVE.L #VBLANK,NEWVBL

;Set up the new MONITOR CHANGED vector and set up GEM DESKTOP to colour
 MOVE.L #MONITOR,$46E 
 MOVE.W #0,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)
 TRAP #14
 ADD.L #12,SP

;Move the program to high memory.  Offset has already been calculated,
;various addresses need to be relocated so they have D6 added to them.
 MOVE.L #MONITOR,A3       ; MONITOR is the start address to relocate
 MOVE.L A3,A4
 ADD.L OFFSET,A4
 MOVE.L OFFSET,D6
 ADD.L D6,REL1+2          ; Add the offset to variables
 ADD.L D6,REL2+2
 ADD.L D6,REL3+2
 ADD.L D6,REL4+2
 ADD.L D6,REL5+2
 ADD.L D6,REL6+2
 ADD.L D6,REL7+2
 ADD.L D6,REL8+2
 ADD.L D6,REL9+2
 ADD.L D6,REL10+2
 ADD.L D6,REL11+2
 ADD.L D6,REL12+2
 ADD.L D6,REL14+2
 ADD.L D6,REL15+2
 ADD.L D6,REL16+2
 ADD.L D6,REL17+6
 ADD.L D6,REL18+6
 ADD.L D6,REL20+2
 ADD.L D6,REL21+2
 ADD.L D6,REL22+2
 ADD.L D6,REL34+2
 ADD.L D6,REL35+2
 ADD.L D6,REL40+2
 ADD.L D6,REL41+2
 ADD.L D6,REL73+2
 ADD.L D6,REL74+2
 ADD.L D6,REL81+2
 ADD.L D6,REL85+4
 ADD.L D6,REL81A+2
 ADD.L D6,REL85A+4
 ADD.L D6,REL88+2
 ADD.L D6,REL160+2
 ADD.L D6,REL120+2
 ADD.L D6,REL121+4
 ADD.L D6,REL122+4
 ADD.L D6,REL140+2
 ADD.L D6,REL190+2
 ADD.L D6,REL191+2
 ADD.L D6,REL192+2 
 ADD.L D6,$46E
 ADD.L D6,NEWVBL
 ADD.L D6,SETMED+2
 ADD.L D6,SETMED+6
 ADD.L D6,SETLOW+2
 ADD.L D6,SETLOW+6
 ADD.L D6,MONITOR+2
 ADD.L D6,YETMORE+2
 ADD.L D6,YETMORE2+2
 ADD.L D6,BACK+2
 MOVE.L #$C800,D3
MOVEALL:              
 MOVE.L (A3)+,(A4)+       ; Move the program to high memory
 SUB.L #1,D3
 BNE MOVEALL


;Set up the new vectors
REL1:
 MOVE.L #XBIOS,$B8        
REL2:
 MOVE.L #VBLANK,$70
REL4:
 MOVE.L #ETVTERM,$408  

;Move information to the start of the program that is needed to set it 
;up without having to recalculate it (for use after a 'warm boot').    
 MOVE.L $3F0.W,A0
 MOVE.L #$ABCCBA12,(A0)+
 MOVE.L $0B8,(A0)+
 MOVE.L $070,(A0)+
 MOVE.L $46E,(A0)+
 MOVE.L $408,(A0)+
 MOVE.L #SPEED,(A0)
 ADD.L D6,(A0)

;End the program setting up the colour emulator.
ENDPROG:
 MOVE.L SUPERVISOR,-(SP)      
 MOVE.W #32,-(SP)           ; Go back to User mode
 TRAP #1
 ADDQ.L #6,SP
 CLR.W -(SP)                 
 TRAP #1 

 EVEN
SUPERVISOR: DC.L 0
STORE:      DC.L 0  ; Input put here
DUMMY:      DC.L 0  ; Not used, it marks the places vectors are written

STARTUP:
 DC.B 27,'E','               '
 DC.B 27,'p',' FULL SCREEN COLOUR EMULATOR V1.05 ',13,10
 DC.B 27,'q',13,10,13,10,13,10,13,10
 DC.B 'SCREEN REFRESH RATE',13,10
 DC.B 'Enter a single number from one (1) to ten (0 equals ten) or return'
 DC.B 13,10,'Or enter a letter to skip this program and boot up in COL.'
 DC.B 13,10,'                                            ',13,10,13,10
 DC.B 'JON DALTON, 67 GREENFIELD ROAD, LONDON N15 5ER. U.K.',13,10
 DC.B 'Please send me ideas, problems, money - this is shareware.' 
 DC.B 13,10,13,10,'    Read BIGCOLOR.DOC.  Run only from AUTO folder.'
 DC.B 13,10,13,10,13,10,0
INPUT:
 DC.B 13,10,'Enter a number (1 - 0) or return.          SPEED=',27,'e',0 
AVERAGE:
 DC.B '                                           SPEED=AVERAGE',0
CALCULATE:
 DC.B 27,'f',27,'H',27,'B',27,'B',13,10,'         Please wait 15 seconds.'
 DC.B '                           ',13,10,27,'K',13,10,27,'K'   
 DC.B 13,10,27,'K',13,10,27,'K',13,10,27,'K',13,10,27,'K',13,10,27,'K'
 DC.B 13,10,27,'K','                                          ',13,10,0

MONO1:
 DC.B 27,'E',27,'f',13,10,'                 NOT STARTING BIGCOLOUR.PRG ',0                    

;All of the following code is relocated in high memory.

;This is the new monitor changed vector.  It is called from the Vertical 
;Blank routine when the monitor has been changed.  In this program it is
;called when a new resolution has been set by XBIOS. The old routine in ROM
;is not saved, as it is only a RESET (Warm Boot) Instruction.

MONITOR:
 MOVE.B COLOR,$44A.W  ; Set up new resolution
 MOVE.B $44A.W,$44C.W
 CMP.B #0,$44C.W      ; Set up VBLANK code for appropriate resolution.
 BEQ SETLOW
SETMED:
 MOVE.L #MOVEMED,SWITCH+2
 BRA SETTUP
SETLOW:
 MOVE.L #MOVELOW,SWITCH+2
SETTUP:
 MOVE.B #02,$FF8260   ; Not really needed, but in case a program calls 
;                     ;this vector directly.  Sets hardware to Mono.
 OR.W #$0700,SR  
 MOVEM.L D0-D1/A1,-(SP)
 MOVE.L #7999,D0      ; Clear the screens
REL40:
 MOVE.L COLOURCHECK,A1
 MOVE.L #0,D1
LOOPY:
 MOVE.L D1,(A1)+
 DBF D0,LOOPY
REL41: 
 MOVE.L MONO,A1
 MOVE.L #7999,D0
LOOPY12:
 MOVE.L D1,(A1)+
 DBF D0,LOOPY12
REL17:
 MOVE.L #0,POSITION    ; Set back to top of screen.
REL18:
 MOVE.L #199,COUNTER
REL74:
 MOVE.L VBLADD,D0      ; Check the VBLANK VECTOR address
 CMP.L $070.W,D0
 BNE ENDMON            ; Some programs set up their own VBLANK address
REL73:
 MOVE.L NEWVBL,$070.W  ; If it has not been replaced, set #VBLANK address
ENDMON:
 MOVEM.L (SP)+,D0-D1/A1
 RTS

;This is called when a program terminates to reset the screen to white
;and to reset the screen resolution if res  was set directly in the
;hardware by the program (in case the screen has got fouled up). 
ETVTERM:
 MOVE.W #$777,$FF8240   ; Set colour white for the hardware
REL190: 
 TST.L HARDWARE
 BEQ VECTOR3
 MOVE.L D0,-(SP)
 MOVE.W #37,-(SP)
 TRAP #14
 ADDQ.L #2,SP
 MOVE.L #$FFFF,D0
WAIT:
 DBF D0,WAIT
 CLR.L D0
REL120:
 MOVE.B COLOR,D0        ; Set screen to resolution contained in COLOR
 TST.L D0               ; Alter low/med in COLOR to opposite
 BNE REL122             ; so new XBIOS doesn't ignore it.
REL121:
 MOVE.B #1,COLOR
 BRA REVERSE
REL122: 
 MOVE.B #0,COLOR
REVERSE: 
 MOVE.W D0,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.L #-1,-(SP)
 MOVE.W #5,-(SP)
 TRAP #14
 ADD.L #12,SP
 CLR.L D0
REL192:
 MOVE.L D0,HARDWARE
 MOVE.L (SP)+,D0
VECTOR3:
 JMP DUMMY        ; Jump to real ETVTERM 

;This is called instead of XBIOS.  It amends Physbase, GetRez, SetScreen,
;SetPalette and SetColor. It then (usually) jumps to real XBIOS 
XBIOS:                          
 MOVE.L A0,-(SP)
 MOVE.L USP,A0    ; Get the User Stack Pointer
 BTST #13,4(SP)   ; Check the saved Status Register
 BEQ OK
 MOVE.L SP,A0     ; If called from Supervisor mode
 ADD.L #10,A0
OK:
 MOVE.W (A0),D0   ; D0 holds the XBIOS function number
 CMP.W #2,D0      ; PHYSBASE - asking for base address of screen
 BEQ REL3 
 CMP.W #5,D0      ; SETSCREEN - changes screen addresses and/or resolution
 BEQ SETSCREEN             
 CMP.W #4,D0      ; GETREZ - asking for resolution
 BEQ RES    
 CMP.W #6,D0      ; SETPALETTE - sets up new colour pallette
 BEQ SETPAL
 CMP.W #7,D0      ; SETCOLOR - sets up one colour
 BNE ENDXBIOS
 MOVE.W 2(A0),D0  ; Get logical colour number
 TST.W D0         ; If not colour zero, it does not change display
 BNE ENDXBIOS     ; But set it anyway for paint packages etc
 MOVE.W 4(A0),D0  ; Find out what colour is requested
 AND.L #$0777,D0
 MOVEM.L D1-D2,-(SP)
 MOVE.L #0,D1
 MOVE.L D0,D2
 AND.L #0007,D0
 ADD.B D0,D1     ; Add the three colour components
 MOVE.L D2,D0
 AND.L #$0070,D0
 ASR.L #4,D0
 ADD.B D0,D1
 MOVE.L D2,D0
 AND.L #$0700,D0
 ASR.L #8,D0
 ADD.B D0,D1
 CMP.W #8,D1      ; If they add up to less than eight ie a dark colour
 BGT WHITE1
 AND.W #$F888,$FF8240     ; Set it as black.  Otherwise set white 
 BRA COLORSET 
WHITE1:
 OR.W #$0777,$FF8240
COLORSET:
 MOVEM.L (SP)+,D1-D2
SETCOL:
 MOVE.W #$000,D0  ; Return a (dummy) colour in D0
NOXBIOS:
 MOVE.L (SP)+,A0  ; End, without going to real XBIOS
 RTE
SETPAL:
 MOVE.L 2(A0),A0  ; Get address of new palette table
 MOVE.W (A0)+,D0  ; Get logical colour zero
 AND.L #$0777,D0
 MOVEM.L D1-D2,-(SP)
 MOVE.L #0,D1
 MOVE.L D0,D2
 AND.L #0007,D0
 ADD.B D0,D1     ; Add the three colour components
 MOVE.L D2,D0
 AND.L #$0070,D0
 ASR.L #4,D0
 ADD.B D0,D1
 MOVE.L D2,D0
 AND.L #$0700,D0
 ASR.L #8,D0
 ADD.B D0,D1
 CMP.W #8,D1       ; If it is a light colour change colour to white (777)
 BGT WHITE
 AND.W #$F888,$FF8240   ; If dark colour, change colour in table to black
 BRA SETITUP
WHITE:
 OR.W #$0777,$FF8240
SETITUP:
 MOVE.W (A0)+,$FF8242   ; Set up hardware palette table
 MOVE.L (A0)+,$FF8244
 MOVE.L (A0)+,$FF8248
 MOVE.L (A0)+,$FF824C
 MOVE.L (A0)+,$FF8250
 MOVE.L (A0)+,$FF8254
 MOVE.L (A0)+,$FF8258
 MOVE.L (A0)+,$FF825C
 MOVEM.L (SP)+,D1-D2
 BRA NOXBIOS            ; End without going to XBIOS
SETSCREEN:
 CLR.L D0
 MOVE.W 10(A0),D0  ; Check the resolution requested
 TST.W D0
 BMI YETMORE1      ; If minus one, ignore it
 CMP.B #2,D0
 BNE YETMORE
 MOVE.W #-1,10(A0) ; If it is 2 (Mono), change to minus one (No change)
 BRA YETMORE1
YETMORE:
 CMP.B COLOR,D0
 BNE YETMORE2
 MOVE.W #-1,10(A0) ; If it is the same resolution, change to -1 (No change)
 BRA YETMORE1
YETMORE2:
 MOVE.B D0,COLOR   ; Put new resolution in COLOR
REL88:
 MOVE.L VBLADD,D0  ; Wait if old (ROM) VBLANK has already been set 
 CMP.L $070.W,D0
 BEQ REL88
 CLR.L D0
WAITVB3:
 MOVE.B $FF8260,D0 ; Wait if not mono resolution
 AND.L #03,D0
 CMP.B #02,D0
 BEQ REL85
 AND.W #$F0FF,SR   ; Set interrupt level to three
 OR.W #$0300,SR
 BRA WAITVB3
REL85:
 MOVE.L $070.W,NEWVBL  ; Save the VBLANK VECTOR address
REL81:
 MOVE.L VBLADD,$070.W  ; Replace it with the normal (ROM) VBLANK
 MOVE.L 6(A0),D0       ; Check the new colour screen address (SETSCREEN)
 TST.L D0          
 BMI ENDXBIOS      ; If no change, end this vector and go to real XBIOS
REL21:
 MOVE.L D0,COL     ; New screen address to COL and $44E
 MOVE.L D0,$44E
 MOVE.L #-1,6(A0)  ; Alter to minus one (no change)
 BRA ENDXBIOS
YETMORE1:
 MOVE.L 6(A0),D0   ; Check the new colour screen address
 TST.L D0          
 BMI TESTLLOC      ; If no change, check LLOC
REL20:
 MOVE.L D0,COL     ; New screen address to COL and $44E
 MOVE.L D0,$44E
 MOVE.L #-1,6(A0)  ; Alter to minus one (no change)
TESTLLOC:
 MOVE.L 2(A0),D0
 TST.L D0
 BMI NOXBIOS       ; End XBIOS if no changes are to be made
 BRA ENDXBIOS      ; Go to real XBIOS if LLOC not minus one
REL3:
 MOVE.L COL,D0     ; Address of COL screen for PHYSBASE
 MOVE.L (SP)+,A0          
 RTE               ; Return COL screen address in D0
RES:
 CLR.L D0   
REL34:
 MOVE.B COLOR,D0   ; Resolution for GETREZ
 MOVE.L (SP)+,A0   
 RTE               ; Return resolution in D0
ENDXBIOS:
 MOVE.L (SP)+,A0   
VECTOR1:
 JMP DUMMY         ; Go to real XBIOS 

;This code is called when a program sets colour resolution directly in
;the hardware instead of using XBIOS.  It is called when new VBLANK
;detects the (real) screen is no longer set to mono.  
HOLD:
 MOVEM.L D0-D2/A0,-(SP)
 CLR.L D0
 CLR.L D1
REL160:
 MOVE.B COLOR,D1
 MOVE.L $466.W,D0
HOLDVB5:
 CMP.L $466.W,D0
 BEQ HOLDVB5
 MOVE.B D1,$FF8260
 MOVE.W #1,$452.W
HOLDVB1:
 CMP.B #2,$FF8260
 BNE HOLDVB1
 MOVEM.L (SP)+,D0-D2/A0
 RTE

 
;This code converts the colour screen into a mono screen.  It is called
;every fiftieth of a second and converts a few lines (the number
;determined by SPEED) before going to the real Vertical Blank Routine.
VBLANK:
 MOVEM.L D0-D7/A0-A6,-(SP) 
 MOVE.B $FF8260,D0          ; Check that the hardware is in Mono
 BTST #1,D0
 BNE REL22                  ; If the hardware is set to Mono go to REL22
 MOVE.W #0,$452             ; Cancel VBLANK interrupts 
 TST.B $43F                 ; Check for Disk Read/Write
 BNE VBLEXIT                ; Exit to normal VBLANK if it is 
 AND.L #$03,D0
 MOVE.L #2,D6
REL191:
 MOVE.L D6,HARDWARE
 MOVE.B D6,$FF8260
REL35:                        
 MOVE.B D0,COLOR      ; If hardware has been set to colour, save resolution
REL85A:
 MOVE.L $070.W,NEWVBL ; Save the VBLANK VECTOR address
REL81A:
 MOVE.L VBLADD,$070.W ; Replace it with the normal (ROM) VBLANK
;SKIPIT:
 MOVEM.L (SP)+,D0-D7/A0-A6  
REL140:
 MOVE.L #HOLD,-(SP)   ; Jump to HOLD after VBLANK 
 MOVE.W #$2300,-(SP) 
VECTOR2A:
 JMP DUMMY            ; Go to real VBLANK 
REL22:
 MOVE.L COL,A0              ; Hardware is Mono
REL5:
 MOVE.L MONO,A1
REL6:
 MOVE.L SCRNCHK,D0
 CMP.L $FF8200,D0            ; Check real screen address has not changed     
 BEQ REL8
 CLR.L D1                 
 MOVE.L #$FF8200,A3          ; Get new real screen address
 MOVEP.W 1(A3),D1          
 LSL.L #8,D1               
 MOVE.L D1,A0                ; Real screen address in A0 
REL7:
 MOVE.L A0,COL               ; This becomes the new COL screen address
 MOVE.L A0,$44E.W
 MOVE.L D0,$FF8200           ; Set hardware address as D0 (SCRNCHK) 
REL8:
 MOVE.L COLOURCHECK,A6       ; A6 is the COLOURCHECK screen 
 MOVE.L A1,A2              
 ADD.L #80,A2                ; A2 is the line underneath A1
REL9:
 MOVE.L POSITION,D1          ; Get the screen POSITION to start at.  
 ADD.L D1,A0                 ; Add it to COL, MONO and COLOURCHECK
 ADD.L D1,A2         
 ADD.L D1,A1         
 ADD.L D1,A6
 MOVE.L #160,D2
REL10:
 MOVE.L TABLE,A5           ; Conversion (lookup) TABLE in A5
REL11:
 MOVE.L COUNTER,D1         ; Count lines done. Counts down from 199 to -1
 CLR.L D4
REL12:
 MOVE.W SPEED,D4           ; Set chosen SPEED. Number of lines to convert
 TST.B $43F                ; If the Disk Drive is Reading/Writing
 BEQ SWITCH             
 MOVE.W #4,D4              ; Set speed as #4, so as not to delay too long
SWITCH:
 JMP DUMMY                 ; Jump to the code for LOW/MED conversion
;Returns to here when lines have been converted and moved
BACK:
 SUB.L COL,A0         ; Find the position on screen that A0 has reached
REL14:
 MOVE.L A0,POSITION   ; Move the new screen position to POSITION
REL15:
 MOVE.L D1,COUNTER    ; Save the number of lines moved so far in COUNTER
 MOVE.L $45E.W,D0     ; Check for a new real screen address  
 TST.L D0
 BEQ VBLEXIT          : Go to real VBLANK if no new screen
REL16:
 MOVE.L D0,COL        ; Put new screen address in COL 
 MOVE.L D0,$44E.W
 CLR.L $45E           ; Cancel new real screen address
VBLEXIT:
 MOVEM.L (SP)+,D0-D7/A0-A6   ; Replace all registers
VECTOR2:
 JMP DUMMY                   ; Jump to real VBLANK routine

MOVELOW:
 CMPM.L (A0)+,(A6)+  ; Compare COL with COLOURCHECK, carry on if no change
 BNE Z0              ; Only update words that have altered  
 CMPM.L (A0)+,(A6)+  ; Repeated 40 times if image has not changed
 BNE Z1              ; Go to Z1 etc if image at that point has changed
 CMPM.L (A0)+,(A6)+
 BNE Z2
 CMPM.L (A0)+,(A6)+
 BNE Z3
 CMPM.L (A0)+,(A6)+
 BNE Z4
 CMPM.L (A0)+,(A6)+
 BNE Z5
 CMPM.L (A0)+,(A6)+
 BNE Z6
 CMPM.L (A0)+,(A6)+
 BNE Z7
 CMPM.L (A0)+,(A6)+
 BNE Z8
 CMPM.L (A0)+,(A6)+
 BNE Z9
 CMPM.L (A0)+,(A6)+
 BNE Y0
 CMPM.L (A0)+,(A6)+
 BNE Y1
 CMPM.L (A0)+,(A6)+
 BNE Y2
 CMPM.L (A0)+,(A6)+
 BNE Y3
 CMPM.L (A0)+,(A6)+
 BNE Y4
 CMPM.L (A0)+,(A6)+
 BNE Y5
 CMPM.L (A0)+,(A6)+
 BNE Y6
 CMPM.L (A0)+,(A6)+
 BNE Y7
 CMPM.L (A0)+,(A6)+
 BNE Y8
 CMPM.L (A0)+,(A6)+
 BNE Y9
 CMPM.L (A0)+,(A6)+
 BNE X0
 CMPM.L (A0)+,(A6)+
 BNE X1
 CMPM.L (A0)+,(A6)+
 BNE X2
 CMPM.L (A0)+,(A6)+
 BNE X3
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+         ; This line has not changed
 BNE W9
NOSKIP:
 ADD.L D2,A1                ; Add 160 to get to next lines
 ADD.L D2,A2 
 DBF D1,NOT                 ; If COUNTER shows 200 lines done, reset screen
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOT:        
 DBF D4,MOVELOW             ; Loop back to check and move another line
 BRA BACK                   ; End moving lines when D4 (SPEED) = -1 
 
; Jump to here if 1st longword of image has changed
Z0:
 MOVE.L -4(A0),-4(A6)  ; Put new longword in COLOURCHECK
 CLR.L D0
 
 MOVEP.W -4(A0),D0  ; Move 1st byte of 1st wd and 1st byte of 2nd wd to D0  
 ADD.L D0,D0        ; Double it to get byte offset in TABLE
 MOVE.W 0(A5,D0.L),(A1) ; Move correct word from table to MONO line 1
 CLR.L D0
 MOVEP.W -3(A0),D0 ; Move 2nd byte of 1st word and 2nd byte of 2nd wd to D0
 ADD.L D0,D0       ; Double it to get offset in TABLE 
 MOVE.W 0(A5,D0.L),2(A1) ; Move word from TABLE to correct word in MONO
;One colour longword has now been transformed to a mono longword 
;for displaying, by mixing the bits of two colour words (that had 
;already been done in TABLE)                                 
 
SKIPMOVE1:
 
 CMPM.L (A0)+,(A6)+  ; Second colour longword check for change
 BEQ SKIPMOVE1B
Z1:
 MOVE.L -4(A0),-4(A6) ; If changed, move as above
 CLR.L D0
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),(A2) ; Move to MONO line two
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),2(A2) ; Move to MONO line two
 
SKIPMOVE1B:
 CMPM.L (A0)+,(A6)+   ; Check 3rd longword, move if changed
 BEQ SKIPMOVE2 
Z2:
 MOVE.L -4(A0),-4(A6)
 CLR.L D0
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),4(A1) ; MONO line 1
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),6(A1)
 
 
SKIPMOVE2:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE2B
Z3:
 MOVE.L -4(A0),-4(A6)
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),4(A2)
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),6(A2)
 
 
SKIPMOVE2B:
 CMPM.L (A0)+,(A6)+  ; Check if rest of line has moved
 BNE Z4
 CMPM.L (A0)+,(A6)+
 BNE Z5
 CMPM.L (A0)+,(A6)+
 BNE Z6
 CMPM.L (A0)+,(A6)+
 BNE Z7
 CMPM.L (A0)+,(A6)+
 BNE Z8
 CMPM.L (A0)+,(A6)+
 BNE Z9
 CMPM.L (A0)+,(A6)+
 BNE Y0
 CMPM.L (A0)+,(A6)+
 BNE Y1
 CMPM.L (A0)+,(A6)+
 BNE Y2
 CMPM.L (A0)+,(A6)+
 BNE Y3
 CMPM.L (A0)+,(A6)+
 BNE Y4
 CMPM.L (A0)+,(A6)+
 BNE Y5
 CMPM.L (A0)+,(A6)+
 BNE Y6
 CMPM.L (A0)+,(A6)+
 BNE Y7
 CMPM.L (A0)+,(A6)+
 BNE Y8
 CMPM.L (A0)+,(A6)+
 BNE Y9
 CMPM.L (A0)+,(A6)+
 BNE X0
 CMPM.L (A0)+,(A6)+
 BNE X1
 CMPM.L (A0)+,(A6)+
 BNE X2
 CMPM.L (A0)+,(A6)+
 BNE X3
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTA
 MOVE.W #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTA:
 DBF D4,MOVELOW
 BRA BACK
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE3 
Z4:
 MOVE.L -4(A0),-4(A6)
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),8(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),10(A1)
 
 
SKIPMOVE3:
  
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE3B
Z5:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),8(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),10(A2)
 
 
SKIPMOVE3B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE4 
Z6:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),12(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),14(A1)
 
 
SKIPMOVE4:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE4B
Z7:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),12(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),14(A2)
 
 
SKIPMOVE4B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE5 
Z8:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),16(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),18(A1)
 
 
SKIPMOVE5:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE5B
Z9:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),16(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),18(A2)
 
 
SKIPMOVE5B:
 



 CMPM.L (A0)+,(A6)+
 BNE Y0
 CMPM.L (A0)+,(A6)+
 BNE Y1
 CMPM.L (A0)+,(A6)+
 BNE Y2
 CMPM.L (A0)+,(A6)+
 BNE Y3
 CMPM.L (A0)+,(A6)+
 BNE Y4
 CMPM.L (A0)+,(A6)+
 BNE Y5
 CMPM.L (A0)+,(A6)+
 BNE Y6
 CMPM.L (A0)+,(A6)+
 BNE Y7
 CMPM.L (A0)+,(A6)+
 BNE Y8
 CMPM.L (A0)+,(A6)+
 BNE Y9
 CMPM.L (A0)+,(A6)+
 BNE X0
 CMPM.L (A0)+,(A6)+
 BNE X1
 CMPM.L (A0)+,(A6)+
 BNE X2
 CMPM.L (A0)+,(A6)+
 BNE X3
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTB
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTB:
 DBF D4,MOVELOW               
 BRA BACK                   
Y0:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),20(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),22(A1)
 
 

 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE6B
Y1:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),20(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),22(A2)
 
 
SKIPMOVE6B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE7 
Y2:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),24(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),26(A1)
 
 
SKIPMOVE7:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE7B
Y3:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),24(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),26(A2)
 
 
SKIPMOVE7B:
 CMPM.L (A0)+,(A6)+
 BNE Y4
 CMPM.L (A0)+,(A6)+
 BNE Y5
 CMPM.L (A0)+,(A6)+
 BNE Y6
 CMPM.L (A0)+,(A6)+
 BNE Y7
 CMPM.L (A0)+,(A6)+
 BNE Y8
 CMPM.L (A0)+,(A6)+
 BNE Y9
 CMPM.L (A0)+,(A6)+
 BNE X0
 CMPM.L (A0)+,(A6)+
 BNE X1
 CMPM.L (A0)+,(A6)+
 BNE X2
 CMPM.L (A0)+,(A6)+
 BNE X3
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTD
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTD:
 DBF D4,MOVELOW
 BRA BACK
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE8 
Y4:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),28(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),30(A1)
 
 
SKIPMOVE8:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE8B
Y5:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),28(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),30(A2)
 
 
SKIPMOVE8B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE9 
Y6:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),32(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),34(A1)
 
 
SKIPMOVE9:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE9B
Y7:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),32(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),34(A2)
 
 
SKIPMOVE9B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE10 
Y8:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),36(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),38(A1)
 
 
SKIPMOVE10:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE10B
Y9:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),36(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),38(A2)
 
 
SKIPMOVE10B:
 
 CMPM.L (A0)+,(A6)+ 
 BNE X0
 CMPM.L (A0)+,(A6)+
 BNE X1
 CMPM.L (A0)+,(A6)+
 BNE X2
 CMPM.L (A0)+,(A6)+
 BNE X3
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTE
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTE:
 DBF D4,MOVELOW
 BRA BACK
X0:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),40(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),42(A1)
 
 
SKIPMOVE11:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE11B
X1:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),40(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),42(A2)
 
 
SKIPMOVE11B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE12 
X2:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),44(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),46(A1)
 
 
SKIPMOVE12:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE12B
X3:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),44(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),46(A2)
 
 
SKIPMOVE12B:
 CMPM.L (A0)+,(A6)+
 BNE X4
 CMPM.L (A0)+,(A6)+
 BNE X5
 CMPM.L (A0)+,(A6)+
 BNE X6
 CMPM.L (A0)+,(A6)+
 BNE X7
 CMPM.L (A0)+,(A6)+
 BNE X8
 CMPM.L (A0)+,(A6)+
 BNE X9
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTF
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTF:
 DBF D4,MOVELOW
 BRA BACK
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE13 
X4:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),48(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),50(A1)
 
 
SKIPMOVE13:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE13B
X5:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),48(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),50(A2)
 
 
SKIPMOVE13B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE14 
X6:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),52(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),54(A1)
 
 
SKIPMOVE14:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE14B
X7:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),52(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),54(A2)
 
 
SKIPMOVE14B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE15 
X8:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),56(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),58(A1)
 
 
SKIPMOVE15:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE15B
X9:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),56(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),58(A2)
 
 
SKIPMOVE15B:
 
 CMPM.L (A0)+,(A6)+
 BNE W0
 CMPM.L (A0)+,(A6)+
 BNE W1
 CMPM.L (A0)+,(A6)+
 BNE W2
 CMPM.L (A0)+,(A6)+
 BNE W3
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTG
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTG:
 DBF D4,MOVELOW
 BRA BACK
W0:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),60(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),62(A1)
 
 
SKIPMOVE16:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE16B
W1:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),60(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),62(A2)
 
 
SKIPMOVE16B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE17 
W2:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),64(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),66(A1)
 
 
SKIPMOVE17:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE17B
W3:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),64(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),66(A2)
 
 
SKIPMOVE17B:
 CMPM.L (A0)+,(A6)+
 BNE W4
 CMPM.L (A0)+,(A6)+
 BNE W5
 CMPM.L (A0)+,(A6)+
 BNE W6
 CMPM.L (A0)+,(A6)+
 BNE W7
 CMPM.L (A0)+,(A6)+
 BNE W8
 CMPM.L (A0)+,(A6)+
 BNE W9
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTH
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTH:
 DBF D4,MOVELOW
 BRA BACK
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE18 
W4:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),68(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),70(A1)
 
 
SKIPMOVE18:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE18B
W5:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),68(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),70(A2)
 
 
SKIPMOVE18B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE19 
W6:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),72(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),74(A1)
 
 
SKIPMOVE19:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE19B
W7:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),72(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),74(A2)
 
 
SKIPMOVE19B:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ SKIPMOVE20 
W8:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),76(A1)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),78(A1)
 
 
SKIPMOVE20:
 
 CMPM.L (A0)+,(A6)+ 
 BEQ NOSKIP
W9:
 MOVE.L -4(A0),-4(A6)
  
 CLR.L D0
 
 MOVEP.W -4(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),76(A2)
  
 CLR.L D0
 MOVEP.W -3(A0),D0
 ADD.L D0,D0
 MOVE.W 0(A5,D0.L),78(A2)
 
 
SKIPMOVE20B:
                              
 ADD.L D2,A1
 ADD.L D2,A2
 DBF D1,NOTJ
 MOVE.L #32000,D3
 SUB.W D3,A0                ; COL reset back to top of screen
 SUB.W D3,A1                ; MONO line one reset back to top of screen
 SUB.W D3,A2                ; MONO line two reset back to top of screen 
 SUB.W D3,A6                ; and the COLOURCHECK table
 MOVE.L #199,D1             ; Set COUNTER to count down from #199
NOTJ:
 DBF D4,MOVELOW
 BRA BACK

MOVEMED:
 MOVE.L D4,D3       ; Increase the number of lines moved as MEDIUM
 LSR.L #1,D3        ; updating is faster than for LOW , so move more lines
 ADD.L D3,D4
 MOVEQ.L #80,D2       ; A0,A1,A2 need to be moved down a line each cycle
MEDIUM:
 MOVE.W (A0)+,(A1)+   ; Move alternate colour words to alternate
 MOVE.W (A0)+,(A2)+   ; mono lines. Repeat 40 times
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+
 MOVE.W (A0)+,(A2)+
 MOVE.W (A0)+,(A1)+     ; One colour line has now been moved to
 MOVE.W (A0)+,(A2)+     ; two mono lines
 ADD.L D2,A1            ; Skip a line (add #80)
 ADD.L D2,A2            ; Skip a line (add #80)
 DBF D1,NOTQ            ; If 200 lines have been done, go back to top
 MOVE.L #32000,D3
 SUB.W D3,A0            ; COL reset back to top of screen
 SUB.W D3,A1            ; MONO line one reset back to top of screen  
 SUB.W D3,A2            ; MONO line two reset back to top of screen  
 MOVE.L #199,D1         ; Set COUNTER to count down from #199
NOTQ:
 DBF D4,MEDIUM          ; Loop back move another line 
 BRA BACK               ; Finish moving lines when D4 is -1 (DBF loop)   

 EVEN
COL:        DC.L 0  ; Address of Colour (fake) screen
MONO:       DC.L 0  ; Address of Mono (real) screen
SPEED:      DC.L 0  ; Number of colour lines to move per cycle 
POSITION:   DC.L 0  ; Position that has been reached in screens
COUNTER:    DC.L 0  ; Counter to check when all lines have been moved 
TABLE:      DC.L 0  ; Conversion (lookup) table address
COLOURCHECK: DC.L 0 ; Extra screen to compare with COL to spot changes
SCRNCHK:     DC.L 0 ; Address of MONO screen as stored by hardware
OFFSET:      DC.L 0 ; Number of bytes added to program to relocate it
COLOR:       DC.L 0 ; Resolution
VBLADD:      DC.L 0 ; Old VBLANK address
NEWVBL:      DC.L 0 ; New VBLANK address
HARDWARE:    DC.L 0 ; Indicates a program has set res directly in hardware
CODE:        DC.L 0 ; Position that calculated table and screens are placed

