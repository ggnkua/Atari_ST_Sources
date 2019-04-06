* 68000 Monitor - An example program for the Metacomco Assembler
*
* Functions provided:
* G [address]    Start at address
* Bn address     Set breakpoint 0-9 at address
* C              Continue after breakpoint
* R              Display registers
* T [address]    Enter trace mode starting at address
*                Trace mode (indicated by t prompt):
*                                 CR   Trace next instruction
*                                 Otherwise, normal command
* L              Load user program
* V              View loaded file info.
* O              Set offset for memory address values
* X              eXit monitor
* M [address]    Open location initially as a byte
*                Memory commands: CR   Next location
*                                 =    Same location
*                                 ^    Previous location
*                                 W    Open as word
*                                 L    Open as long
*                                 S    Open as byte
*                                 n    Update to n
* An [value]     Update address register n
* Dn [value]     Update data register n
* P  [value]     Update program counter
* S  [value]     Update status register
*
   
SPACE   EQU     $20             ASCII space character
CR      EQU     $0D             ASCII carriage return
LF      EQU     $0A             ASCII line feed
BS      EQU     $08             ASCII backspace
DEL     EQU     $7F             ASCII delete
TBIT    EQU       7             Trace bit in saved status register
SBIT    EQU       5             Supervisor bit in it
INTSOFF EQU   $2700             Interrupts off
INTSON  EQU   $2000             Interrupts on
INTVECS EQU       8             Location of fixed vectors
NULLVEC EQU       0             Flag for null vector
BRKTRP  EQU   $4E40             TRAP 0 instruction used for breakpoints
STACK   EQU   $1000             How much stack space monitor will take
DEFSP   EQU  $77FFC             Default USP after end of prog

* so we know how many vectors to move :-
INTSIZE   EQU    46             46 vectors (2 thro 47)

* some GEMDOS function codes

CCONOUT  EQU   $02         code for 'put character to screen'
CCONRS   EQU   $0A         code for 'read string from keyboard'
MSHRINK  EQU   $4A         code for 'shrink memory allocation'
PEXEC    EQU   $4B         code for 'execute process'
SUPER    EQU   $20         code for 'toggle supervisor mode on/off'

* basepage equates - where to find info in basepage

P_HITPA  EQU   $04         pointer to top of programs workspace
P_TBASE  EQU   $08         pointer to program's code section
P_DBASE  EQU   $10         pointer to program's data section
P_BBASE  EQU   $18         pointer to program's BSS section start
P_BLEN   EQU   $1C         length of program's BSS section

        PAGE
*
* RAM workspace used. All RAM workspace is referenced via the
* pointer A6 which is set to point to the start of the RAM area.
*
RDUMPD  EQU     0               Space for 8 data registers
RDUMPA  EQU     RDUMPD+32       Space for 7 address registers
RDUMPSP EQU     RDUMPA+28       Space for USP
RDUMPSR EQU     RDUMPSP+4       Space for user status register
RDUMPPC EQU     RDUMPSR+2       Space for user program counter
BRKP    EQU     RDUMPPC+4       10 breakpoints, 6 bytes each
BFLG    EQU     BRKP+60         Space for breakpoint flag
RAMEND  EQU     BFLG+2          End of RAM area
*
D_A0    EQU     RDUMPA-RDUMPD   Offset of register A0
D_A7    EQU     RDUMPSP-RDUMPD  Offset of register A7
D_SR    EQU     RDUMPSR-RDUMPD  Offset of status register
D_PC    EQU     RDUMPPC-RDUMPD  Offset of user program counter
RDSIZE  EQU     (RAMEND-RDUMPD)/4   Size of save area in long words

        PAGE

*
* Monitor entry point
* Atari ST programs start up with all memory allocated to them
* so first we must give what we don't need back to the O.S.
*
START
        MOVE.L  4(SP),A0        Get pointer to monitor's basepage
        MOVE.L  P_BBASE(A0),A1  Get pointer to start of BSS section
        ADD.L   P_BLEN(A0),A1   Add length of BSS section = end of monitor
        ADD.W   #STACK,A1       Add some space for our stack
        MOVE.L  A1,SP           Now put our stack at the top of that space
        SUB.L   A0,A1           Subtract basepage address to get length
        MOVE.L  A1,-(SP)        Push length of ram we want kept
        MOVE.L  A0,-(SP)        Push base address of that ram (i.e. basepage)
        CLR.W   -(SP)           Push zero word (needed for mshrink call)
        MOVE.W  #MSHRINK,-(SP)  Push gemdos code for 'shrink memory'
        TRAP    #1              Call GEMDOS
        LEA     12(SP),SP       Tidy up the stack (pull 12 bytes)

* Now go into supervisor mode - for convenience if we have to trace
* and so we can change priviledged locations e.g. vectors
                             
        CLR.L   -(SP)           long null - tell O.S. we want same stack
        MOVE.W   #SUPER,-(SP)   push code for toggle supervisor mode
        TRAP     #1             call GEMDOS
        ADDQ.L   #6,SP          correct the stack pointer
        MOVE.L   D0,SAVE_SP     save the system's supervisor stack pointer
   
        MOVE.W  #INTSOFF,SR     Interrupts off, (must be in supervisor mode)

        LEA     INTVECS,A1      point to interrupt vector area
        LEA     I_BERR,A2       point to defined handlers
        LEA     VECSAVE,A3      point to system vector save area
        MOVE.L  A2,D2           Maintain base pointer
        MOVE.W  #INTSIZE-1,D0   Number of slots
ST0     MOVE.L   (A1),(A3)+     copy vector to our save area
        MOVE.L  (A2)+,D1        Extract handler location
        BEQ.S   LEAVIT          if null then don't set this vector
        ADD.L   D2,D1           Add table base
        MOVE.L  D1,(A1)         Install in low RAM
LEAVIT  ADDQ.L   #4,A1          Increment A1 to point to next vector
        DBRA    D0,ST0          loop until complete

        MOVE.W  #INTSON,SR      interrupts on again

        LEA     RAMBASE,A6      establish RAM address register
        LEA     RDUMPD(A6),A1   point to data save areas
        MOVE.W  #RDSIZE-1,D0    size of area to clear
CL      CLR.L   (A1)+           clear data area
        DBRA    D0,CL           branch until done
        CLR.L   BP_PTR          flag 'no prog load'
        CLR.L   POFFSET         offset to zero
        MOVE.B  #1,STRBUFF      initialise so buffer is read
        MOVE.L  #DEFSP,RDUMPSP(A6)   set initial USP
        LEA     MESS1,A0        Point to header message
        BSR     WRITES          Write message

* Main command execution loop
ST1     MOVE.B  #'#',D0         Write prompt
        BSR     WRCH
ST2     BSR     RDCH            Get character into D0
        LEA     COMTAB,A0       Point to command search table
        BSR     SEARCH          Execute required function
        BRA.S   ST1             And issue prompt again

*
* Input and output section
*
* Write out the character in D0. All registers preserved.
*
WRCH    MOVEM.L   D0-D4/A0-A4,-(SP)   save regs used by gemdos
        EXT.W   D0              Extend 8 bit character to word size
        MOVE.W   D0,-(SP)       Push it onto the stack
        MOVE.W   #CCONOUT,-(SP) Push code for write character
        TRAP   #1               Call gemdos
        ADDQ.L   #4,SP          Restore the stack pointer as it was
        MOVEM.L   (SP)+,D0-D4/A0-A4   restore those regs
        RTS                     and return
*
* Write out a space to the output
*
BLANK   MOVE.L  D0,-(SP)        Save D0
        MOVEQ   #SPACE,D0       Space code
        BSR.S   WRCH            Write it
        BRA.S   NEWL2           Jump to shared code
*
* Write out a CR, LF to the output
*
NEWLINE MOVE.L  D0,-(SP)        Save D0
        MOVEQ   #CR,D0          Print carriage return
        BSR.S   WRCH
        MOVEQ   #LF,D0          Print line feed
        BSR.S   WRCH
NEWL2   MOVE.L  (SP)+,D0        Restore D0
        RTS
*
* Write out string pointed to by A0 until zero byte found
*
WRITE   MOVEM.L D0/A0,-(SP)     Save registers
WRITE1  MOVE.B  (A0)+,D0        Extract character from string
        BEQ.S   WRITE2          Zero - end of string
        BSR.S   WRCH            Write out character
        BRA.S   WRITE1
WRITE2  MOVEM.L (SP)+,D0/A0     Restore registers
        RTS
*
* As WRITE, but followed by a newline
*
WRITES  BSR.S   WRITE           Print string
        BRA.S   NEWLINE         Print newline and return
*
* Write out 4 byte value in D0 in hexadecimal with leading zeros
*
WRHEX4  SWAP    D0              Swap high and low halves
        BSR.S   WRHEX2          Write high 2 bytes
        SWAP    D0              Swap high and low halves again
*                               .. and drop into WRHEX2 routine
*                               to write bottom half
*
* Write out 2 byte value in D0 in hexadecimal with leading zeros
*
WRHEX2  ROR.W   #8,D0           Shift top byte down to low order
        BSR.S   WRHEX1          Write single byte
        ROL.W   #8,D0           Shift bottom byte back again
*                               .. and drop into WRHEX1 for this byte
*
* Write out byte value contained in low order byte of D0
*
WRHEX1  ROR.B   #4,D0           Shift down top nibble
        BSR.S   WRHEX0          Write it out
        ROL.B   #4,D0           Put back bottom nibble
*                               .. and drop into WRHEX0
* Write out low order 4 bits as hexadecimal character
*
WRHEX0  MOVE.L  D0,-(SP)        Save register
        ANDI.B  #$0F,D0         Mask to bottom 4 bits
        ADDI.B  #'0',D0         Add character zero
        CMPI.B  #'9',D0         Test to see if greater than char 9
        BLS.S   WRHEX01         Just write it
        ADDI.B  #'A'-'9'-1,D0   Convert to character
WRHEX01 BSR.S   WRCH            Write out hex character
        MOVE.L  (SP)+,D0        Restore register
        RTS                     And return
        PAGE
*
* Input routines
*
* Call GEMDOS to read a character from keyboard
*
RDCH    MOVEM.L D1-D4/A0-A4,-(SP)   save some regs used by gemdos
RDCH1   LEA.L   STRBUFF,A0      Point to buffer
        CLR.W   D1
        MOVE.B  (A0),D1         Get current ptr
        CMP.B   1(A0),D1        See if all done
        BGT.S   RDCH2           Yes, get more characters
        MOVE.B  0(A0,D1.W),D0   Get character from buffer
        EXT.L   D0              extend byte to word
        EXT.L   D0              extend word long (for READHEX)
        ADDQ.B  #1,D1           inc ptr
        MOVE.B  D1,(A0)         and store back
        MOVEM.L (SP)+,D1-D4/A0-A4  restore regs
        RTS
* At this point we must get another line
RDCH2   MOVE.B  #80,STRBUFF     Tell gemdos how big string buffer is
        PEA     STRBUFF         Push address of string buffer
        MOVE.W  #CCONRS,-(SP)   push code for 'read string'
        TRAP    #1              call GEMDOS
        ADDQ.L  #6,SP
        LEA.L   STRBUFF,A0
        CLR.W   D0
        MOVE.B  1(A0),D0        Get length count
        ADDQ.B  #2,D0           Now upb in buffer
        MOVE.B  #CR,0(A0,D0.W)  Insert CR at end
        MOVE.B  D0,1(A0)        Insert upb
        MOVE.B  #2,(A0)         Insert current offset
        MOVE.B  #LF,D0          Get a LF to follow the CR
        BSR     WRCH            and reflect that
        BRA.S   RDCH1           Extract character
*
* Read hexadecimal number from input, terminated by CR.
* Two entry points are provided. READHEX reads the next character from
* the input, while READH assumes that the next character is in D0.
* The result is returned in D1, and D0 is set to the last character read
* If an invalid character is found the Z bit is unset, otherwise
* the Z bit is set.
*
READHEX BSR.S   RDCH            Get character
READH   CMPI.B  #SPACE,D0       Check if space
        BEQ.S   READHEX         Discard leading spaces
        CLR.L   D1              Clear result register
RDH1    CMPI.B  #'0',D0         Check if below character 0
        BLT.S   RDH4            Error exit with Z unset
        CMPI.B  #'9',D0         Check if above character 9
        BGT.S   RDH2            Possibly A .. F
        SUBI.B  #'0',D0         Subtract character 0
        BRA.S   RDH3            And assemble in D1
RDH2    BSR     LOCASE          Convert to lower case
        CMPI.B  #'a',D0         Check if below character a
        BLT.S   RDH4            Error exit with Z clear
        CMPI.B  #'f',D0         Check if above character f
        BGT.S   RDH4            Error exit with Z clear
        SUBI.B  #'a'-10,D0      Convert to correct value
RDH3    ASL.L   #4,D1           Multiply current sum by 16
        ADD.L   D0,D1           Add in this term
        BSR     RDCH            Get next character
        CMPI.B  #CR,D0          See if equal to CR
        BEQ.S   RDH4            Yes.. exit with Z set
        CMPI.B  #SPACE,D0       See if equal to space
        BNE.S   RDH1            No .. go back and handle it
RDH4    RTS                     Exit with Z set if all OK
        PAGE
*
*
*  Branch table handling
*
*
*  This routine is entered with A0 pointing to a branch table
*  of the following form:
*  1 byte     Flag byte
*  1 byte     Character
*  2 byte     Offset of associated routine from base of table
*
*  The character in D0, converted to lower case, is located in
*  the table and the associated routine is jumped to. If the
*  flag byte is non zero then this is the last entry in the
*  table. In this case the character byte is ignored and the
*  routine specified is always jumped to.
*
SEARCH  MOVE.L  D0,-(SP)        Save register D0
        MOVE.L  A0,-(SP)        and register A0
        BSR.S   LOCASE          Convert to lower case
SRCH1   TST.B   (A0)+           Check if end and skip byte
        BNE.S   SRCH2           Non zero - end of table
        CMP.B   (A0)+,D0        Compare character and skip byte
        BEQ.S   SRCH3           Found it!
        ADDQ.L  #2,A0           Skip routine offset
        BRA.S   SRCH1           And try again
SRCH2   ADDQ.L  #1,A0           Skip unused character byte
SRCH3   MOVEA.W (A0),A0         Offset of routine from table base
        ADDA.L  (SP),A0         Add in saved table base
        MOVE.L  4(SP),D0        Restore register D0
        MOVE.L  A0,4(SP)        And replace with routine address
        MOVE.L  (SP)+,A0        Restore register A0
        RTS                     Pick up routine address and jump to it
*
* Subroutine to convert character in D0 to lower case if alphabetic
*
LOCASE  CMPI.B  #'A',D0         Check if alphabetic char
        BLT.S   LOC1            No need to convert unless it is
        CMPI.B  #'Z',D0         Check again
        BGT.S   LOC1            Still no need
        ORI.B   #$20,D0         Convert character to lower case
LOC1    RTS                     And return

*
*
*  Command routines called via command table
*  These routines may corrupt any register except A6
*
*
*  Default routine. Prints message and skips to end of line
*  D0 should contain last character read from line
*
COMERR  LEA     MESS2,A0        Point to message
        BSR     WRITES          Print it
*
* Routine to skip the rest of a line. This is also
* called if just a newline is typed. D0 contains
* the last character read on entry, and CR on exit
*
SKIPNL  CMPI.B  #CR,D0          Check if D0 is CR
        BEQ.S   SKIPNL1         If so then exit
        BSR     RDCH            Otherwise ignore chars
        BRA.S   SKIPNL          Until it is one
SKIPNL1 RTS
*
*  Routine called if number expected but not found.
*  D0 contains last character read.
*
NUMERR  LEA     MESS3,A0        Point to message
        BSR     WRITES          Print it
        BRA.S   SKIPNL          And skip line
*
*  Routine called if error in memory examine/update command
*  D0 contains last character read.
*
MEMERR  LEA     MESS4,A0        Point to message
        BSR     WRITES          Print it
        BRA.S   SKIPNL          And skip line
        PAGE
*
*  Register dump command. Two entry points: DREG if called as command,
*  REGX if called after trace or breakpoint.
*
DREG    BSR     SKIPNL          Skip rest of line if called as command
REGX    MOVEQ   #'P',D0         Register letter into D0
        BSR     WRCH            Write it out
        MOVEQ   #'C',D0         And next letter
        BSR     WRCH            Write that
        BSR     BLANK           And a space
        MOVE.L  RDUMPPC(A6),D0  Obtain user PC
        BSR     WRHEX4          Write it out
        BSR     BLANK           Space
        MOVEQ   #'S',D0         Register letter
        BSR     WRCH            Write out
        MOVEQ   #'R',D0         And the next
        BSR     WRCH            Write that
        BSR     BLANK           And a space
        MOVE.W  RDUMPSR(A6),D0  Obtain user SR
        BSR     WRHEX2          Write out 2 bytes
        BSR     NEWLINE         And a newline
        LEA     RDUMPD(A6),A3   Point to Data registers
        MOVEQ   #'D',D1         Register letter into D1
        BSR.S   REG1            Display register set
        MOVEQ   #'A',D1         Register letter
*
* Drop though to here once and call as subroutine once
* Display 8 registers, register description letter in D1
* A3 points to register dump area
*
REG1    MOVEQ   #0,D2           D2 is register number
REG2    MOVE.B  D1,D0           Extract register letter
        BSR     WRCH            Write register letter
        MOVE.B  D2,D0           Register number
        BSR     WRHEX0          Write nibble of that
        BSR     BLANK           Write out space
        ADDQ.B  #1,D2           Update register number
        MOVE.L  (A3)+,D0        Extract register value
        BSR     WRHEX4          Write it out
        CMP.B   #8,D2           All done yet?
        BEQ.S   REG3            All over
        BSR     BLANK           Print another space
        CMP.B   #4,D2           Register 4 next?
        BNE.S   REG2            No, so print once more
        BSR     NEWLINE         Newline before reg 4
        BRA.S   REG2            And print next line
REG3    BRA     NEWLINE         Final newline and exit
        PAGE
*
*  Register update commands
*
*  Data register
*
SETD    LEA     RDUMPD(A6),A3   Set A3 to data reg store
        BRA.S   SETR            Jump to common code
*
* Address register
*
SETA    LEA     RDUMPA(A6),A3   Set A3 to address reg store
*
* Common code for setting registers
*
SETR    BSR     READHEX
        BNE.S   SETRE           Register number expected
        TST.L   D1              Check bounds
        BLT.S   SETRE           Error
        CMP.L   #7,D1           Upper bound
        BGT.S   SETRE           Error
        MOVE.W  D1,D3           Save in D3
        ASL.W   #2,D3           Multiply by four
SETR1   CMP.B   #CR,D0          See if any value given
        BEQ.S   SETR2           No, so print value
        BSR     READH           Get value, last char in D0
        BNE     NUMERR          Hex number expected
        MOVE.L  D1,0(A3,D3.W)   Insert value in correct slot
        BRA     SKIPNL          Skip rest of line & return
SETR2   MOVE.L  0(A3,D3.W),D0   Extract register value
        BSR     WRHEX4          Print it out
        BRA     NEWLINE         Finish with NL
*
* Program counter
*
SETP    LEA     RDUMPPC(A6),A3  Point to PC store
        CLR.W   D3              Offset zero
        BSR     RDCH            Get next character
        BRA.S   SETR1           Jump to shared code
*
* Status register
*
SETS    BSR     RDCH            Read next character
        CMP.B   #CR,D0          Check if new value given
        BEQ.S   SETS1           No, print current value
        BSR     READH           Get value, last character in D0
        BNE     NUMERR          Error in value
        MOVE.W  D1,RDUMPSR(A6)  Update saved copy of SR
        BRA     SKIPNL          Return
SETS1   MOVE.W  RDUMPSR(A6),D0  Extract current value
        BSR     WRHEX2          Print it out
        BRA     NEWLINE         Print newline & return
*
* Error in register description
*
SETRE   LEA     MESS6,A0        Message
        BSR     WRITES          Print it out
        BRA     SKIPNL          Skip rest of line & return
        PAGE
*
* Request to execute a user program in trace mode
*
TGO     BSET    #TBIT,RDUMPSR(A6)  Set trace bit in saved SR
*
* Request to execute a user program in normal mode
*
GO      BSR     RDCH            Get next character
        CMP.B   #CR,D0          Check for simple case
        BEQ.S   GO1             Start program running
        BSR     READH           Read entry point, D0 last char read
        BNE     NUMERR          Error in number
        MOVE.L  D1,RDUMPPC(A6)  Update saved PC
GO1     CLR.B   BFLG(A6)        Clear CONT flag
* Insert breakpoints. Do not insert a breakpoint at the location
* we are about to execute.
CGO     MOVEA.L RDUMPPC(A6),A4  Extract user program counter
        LEA     BRKP(A6),A1     Point to breakpoint space
        MOVEQ   #9,D0           Counter
        SUBA.L  A2,A2           Zero A2
GO2     MOVE.L  (A1)+,D1        Breakpoint address
        BEQ.S   GO3             Zero address so no breakpoint
        MOVE.W  0(A2,D1.L),(A1) Extract original instruction and save it
        CMPA.L  D1,A4           Compare with current PC
        BEQ.S   GO3             Do not insert this time
        MOVE.W  #BRKTRP,0(A2,D1.L)   Replace with breakpoint trap
GO3     ADDQ.L  #2,A1           Increment A1
        DBRA    D0,GO2          Try next breakpoint
* Set up user registers and enter code
GO4     MOVE.L  RDUMPSP(A6),A0  Extract user stack pointer
        MOVE.L  A0,USP          And set it up
        MOVE.L  RDUMPPC(A6),-(SP)       Stack user PC
        MOVE.W  RDUMPSR(A6),-(SP)       Stack user SR
        MOVEM.L RDUMPD(A6),D0-D7/A0-A6  Set registers to user values
        ST      USERP           Flag we are running user program
        RTE                     Hold tight
        RTS                     If we ever get back
*
* Continue request after breakpoint. Set flag to note fact, then trace one
* instruction without inserting this breakpoint. When trace exception happens
* restore breakpoints and carry on without comment
*
CONT    BSR     SKIPNL                  Skip rest of line
        BSET    #TBIT,RDUMPSR(A6)       Set trace bit
        MOVE.B  #$FF,BFLG(A6)           Flag this case
        BRA.S   CGO                     Enter user program
        PAGE
*
*  Memory examine and alter routine
*
MEM     BSR     READHEX         Read location
        BNE     NUMERR          Error in number
        ADD.L   POFFSET,D1      Add in the offset value
        MOVEA.L D1,A3           Move address into A3
        MOVEQ   #-1,D2          Set up as byte value initially
MEM1    MOVE.L  A3,D0           Move location into D0
        BSR     WRHEX4          And write it out
        BSR     BLANK           Write a space
        CMP.B   #-2,D2          Check size required
        BGT.S   MEMB            > -2 .. byte
        BEQ.S   MEMW            = -2 .. word
        MOVE.L  (A3),D0         Extract long data
        BSR     WRHEX4          Write out information
        BRA.S   MEMQ
MEMW    MOVE.W  (A3),D0         Extract word data
        BSR     WRHEX2          And write out
        BRA.S   MEMQ
MEMB    MOVE.B  (A3),D0         Extract byte
        BSR     WRHEX1          And write out
MEMQ    MOVE.B  #'?',D0         Question mark
        BSR     WRCH            Write that out
        BSR     READHEX         Attempt to read new value
        BNE.S   MEM2            If not a number then try other command
        BSR     SKIPNL          Skip rest of line
        PEA     MEM1            Push MEM1 so we will return to it
        CMP.B   #-2,D2          Check size again
        BGT.S   MEMBW           Byte
        BEQ.S   MEMWW           Word
        MOVE.L  D1,(A3)         Update long value
        BRA.S   NMEM            Display next value, return to MEM1
MEMWW   MOVE.W  D1,(A3)         Update word value
        BRA.S   NMEM            Display next value, return to MEM1
MEMBW   MOVE.B  D1,(A3)         Update byte value
        BRA.S   NMEM            And display next and return to MEM1
MEM2    CMPI.B  #'.',D0         Check for end command
        BEQ.S   MEM3            Exit if so
        LEA     MEMTAB,A0       Get memory change response table
        BSR     SEARCH          Call suitable routine
        BRA.S   MEM1            Display again
MEM3    BSR     SKIPNL          Skip rest of line and return
        RTS
*
* Memory change subroutines called via MEMTAB
*
*
* Move to next memory location. Address increment in D2
*
NMEM    SUBA.L  D2,A3           Onto next location
        BRA     SKIPNL          Skip anthing else
*
* Move to previous memory location. The address increment is in D2
*
PMEM    ADDA.L  D2,A3           Back to previous location
        BRA     SKIPNL          Skip anything else
*
* Set to byte size values
*
SETB    MOVEQ   #-1,D2          Update D2
        BRA     SKIPNL          Skip rest
*
* Set to word values. Only possible if A3 is even address
*
SETW    BSR.S   CHKEVEN         Check even, error if not
        MOVEQ   #-2,D2          Update D2
        BRA     SKIPNL          Skip line
*
* Set to long value. Only possible if A3 even address
*
SETL    BSR.S   CHKEVEN         Check if even
        MOVEQ   #-4,D2          Update D2
        BRA     SKIPNL          Skip line
*
* Subroutine to check if A3 contains even address. Corrupts D0
*
CHKEVEN MOVE.L  A3,D0           Place A3 in D0
        BTST    #0,D0           Check bottom bit
        BEQ.S   CHK1            Zero so value is even
        LEA     MESS5,A0        Point to message
        BSR     WRITES          Print it
        LEA     4(SP),SP        Ignore this return address
        BRA     SKIPNL          Error return to MEM
CHK1    RTS
        PAGE
*
* Setting and listing breakpoints
*
BRK     LEA     BRKP(A6),A1     Point to breakpoint table
        BSR     RDCH            Read next character
        CMP.B   #CR,D0          Check for simple B command
        BNE.S   BRK1            No, more complex
* Display current breakpoints
        MOVEQ   #0,D1           Counter
BRK0    TST.L   (A1)            Check if set
        BEQ.S   BRK01           No, not set
        MOVE.B  D1,D0           Breakpoint number into D0
        BSR     WRHEX0          Print breakpoint number
        BSR     BLANK           Print space
        MOVE.L  (A1),D0         Extract breakpoint location
        BSR     WRHEX4          Print address
        BSR     NEWLINE         Print newline
BRK01   ADDQ.L  #6,A1           Increment pointer
        ADDQ.B  #1,D1           Increment offset
        CMP.B   #9,D1           Check if done
        BLE.S   BRK0            Loop until done
        RTS                     Return
* Set or unset particular breakpoint
BRK1    BSR     READH           Read hex number, char in D0
        BNE.S   BRKE            Error in that
        TST.L   D1              Check within bounds
        BLT.S   BRKE            Too small
        CMP.L   #9,D1           Check other bound
        BGT.S   BRKE            Too big
        MULS    #6,D1           Offset in table
        ADDA.L  D1,A1           Point to slot
        CMP.B   #CR,D0          Any position given?
        BNE.S   BRK2
* Clear breakpoint
        CLR.L   (A1)            Clear breakpoint
RET1    RTS                     And return
* Set new breakpoint
BRK2    BSR     READH           Get position of breakpoint
        BNE     NUMERR          Error in that
        ADD.L   POFFSET,D1      Add in the offset
        MOVE.L  D1,(A1)         Place address in slot
        BRA     SKIPNL          Skip rest and return
*
* Error in breakpoint
*
BRKE    LEA     MESS8,A0        Point to message
        BSR     WRITES          Write message
        BRA     SKIPNL          Skip line & return

        PAGE
*
* Offset - set offset to be used with address parameters from user
*
SETOFF  BSR     RDCH            Read a character from kbd
        CMP     #CR,D0          was it carriage return
        BEQ.S   SHOWOFF         Simple case
        BSR     READH           read hex No, starting with character in d0
        BNE     NUMERR          if bad show error message
        MOVE.L  D1,POFFSET      set offset value
        RTS                     exit
SHOWOFF LEA     OFFSTR,A0       String to print
        BSR     WRITE           Print (no newline)
        MOVE.L  POFFSET,D0      get current offset value
        BSR     WRHEX4          and print it
        BRA     NEWLINE         then a new-line
*
* View - show user where the program loaded
*
VIEW    BSR     SKIPNL          wait for <CR>
        TST.L   BP_PTR
        BEQ.S   NOPROG          see if program loaded
VIEW2   LEA     PSSTR,A0        Address of string 'Prog start = '
        BSR     WRITE           Print without newline
        MOVE.L  BP_PTR,A0       get pointer to prog's basepage
        MOVE.L  P_TBASE(A0),D0  get address of text section
        BSR     WRHEX4          print it as a 4 byte hex No.
        LEA     DSSTR,A0        Address of string 'Data start = '
        BSR     WRITE
        MOVE.L  BP_PTR,A0       get address of basepage
        MOVE.L  P_DBASE(A0),D0  get address of data section
        BSR     WRHEX4          print it
        BRA     NEWLINE
NOPROG  LEA     MESS13,A0
        BRA     WRITES
*
* LOAD USER PROGRAM into memory and set PC & stack
*
LOAD    BSR     RDCH            Get char
        CMPI.B  #CR,D0          If CR then error
        BEQ     LERR       
        CMPI.B  #SPACE,D0       Skip spaces
        BEQ.S   LOAD
        LEA.L   FNAME,A0        Point to filename buffer
1$      MOVE.B  D0,(A0)+        Insert char
        BSR     RDCH
        CMPI.B  #CR,D0          Return?
        BNE.S   1$
        CLR.B   (A0)+           Set null at end
        TST.L   BP_PTR          See if already done
        BEQ.S   5$              Nothing loaded
        LEA.L   MESS11,A0       Message
        BRA     WRITES          Print and return
5$      PEA     $0              Null environment
        PEA     CMDSTR          push address of command string
        PEA     FNAME           push address of filename string
        MOVE.W  #3,-(SP)        push flag for 'just load'
        MOVE.W  #PEXEC,-(SP)    push code for 'execute process'
        TRAP    #1              basepage address returned in d0
        LEA     16(SP),SP       tidy stack
        TST.L   D0              error?
        BMI.S   BADLOAD         if so then print message
        MOVE.L  D0,BP_PTR       make a copy of basepage pointer
        MOVE.L  D0,A0           need it in address register
        MOVE.L  P_HITPA(A0),A1  get top of prog's workspace
        MOVE.L  D0,-(A1)        push basepage address there
        MOVE.L  #EXITLBL,-(A1)  push a suitable return address
        MOVE.L  A1,RDUMPSP(A6)  give user new stack like TOS would do
        MOVE.L  P_TBASE(A0),D0  get pointer to prog's code start
        MOVE.L  D0,RDUMPPC(A6)  and update user's PC
        BRA     VIEW2           Dump registers.

BADLOAD LEA     MESS12,A0
PRINTM  BSR     WRITES          print error message
EXITLBL RTS                     and that's all.

LERR    LEA.L   MESS10,A0
        BRA.S   PRINTM
*
* EXIT MONITOR - returns to GEM desktop (or wherever we came from)
*
EXIT    BSR     SKIPNL          skip rest of line, no parameters
        LEA     MESS9,A0        make sure really want to exit
        BSR     WRITE           write message
        BSR     RDCH            read keyboard
        BSR     LOCASE          make sure it's lower case
        CMP.B   #'y',D0         did they type a 'Y' ?
        BNE     SKIPNL          No, return and skip rest
     
* O.K. so you really want to exit:-

        MOVE.W  #INTSOFF,SR     turn interrupts off before...

        LEA     INTVECS,A1      point to 68000 vector area
        LEA     VECSAVE,A2      point to our vector save area
        MOVE.W  #INTSIZE-1,D0   -1 'cos dbf finishes at -1 count
RS0     MOVE.L  (A2)+,(A1)+     copy from saved to vectors
        DBF     D0,RS0          loop until done all vectors
     
        MOVE.W  #INTSON,SR      put interrupts on again

        MOVE.L  SAVE_SP,-(SP)   push address of system's old stack
        MOVE.W  #SUPER,-(SP)    and push code for supervisor toggle
        TRAP    #1              call GEMDOS
        ADDQ.L  #6,SP           tidy up the stack
     
* o.k. now we're back in user mode and the system has it's old stack back

        CLR.W   -(SP)           push code for process terminate
        TRAP    #1              call GEMDOS to exit (shouldn't return)
        PAGE
*
*
* Interrupt and trap handling. In most cases a message is written
* and further commands are requested. For each type of error an
* immediate BSR is made to code which can handle it. The saved PC
* on the stack can then be used to identify which one it was.
*
* Exceptions
*
B_EXCPT BSR.S   EXCP1           Bus error
A_EXCPT BSR.S   EXCP1           Address error
I_EXCPT BSR.S   EXCP2           Illegal instruction
D_EXCPT BSR.S   EXCP2           Divide by zero
C_EXCPT BSR.S   EXCP2           CHK
O_EXCPT BSR.S   EXCP2           TRAPV
P_EXCPT BSR.S   EXCP2           Privilege
T_EXCPT BSR.S   EXCP2           Trace
X_EXCPT BSR.S   EXCP2           L1010
Y_EXCPT BSR.S   EXCP2           L1111
S_EXCPT BSR.S   EXCP2           Spurious interrupt
*
* Interrupts
*
INT     BSR.S   EXCP2           Unexpected interrupt
INT7    BSR.S   EXCP2           Console abort
*
* Traps
*
TRP     BSR.S   EXCP2           Unexpected TRAP
TRP0    BSR.S   EXCP2           Breakpoint
TRP15   BSR.S   EXCP2           End of user program
*
*
* Handle address or bus errors. In this case there is extra information
* on the stack which we can use to correct the value of the program counter.
*
EXCP1   MOVEM.L D0/A0,-(SP)     Save some registers
        MOVE.L  22(SP),A0       Program counter
        MOVE.W  18(SP),D0       Instruction register
        CMP.W   -(A0),D0        Decrement PC and compare
        BEQ.S   EXCP10          Equal so ok
        CMP.W   -(A0),D0        Decrement again
        BEQ.S   EXCP10          Ok
        CMP.W   -(A0),D0        Decrement again
        BEQ.S   EXCP10          Ok
        CMP.W   -(A0),D0        Decrement again
        BEQ.S   EXCP10          Ok
        SUBQ.L  #2,A0           No so must be this one
EXCP10  MOVE.L  A0,22(SP)       Restore corrected PC
        MOVEM.L (SP)+,D0/A0     Restore saved registers
        MOVE.L  (SP),8(SP)      Overwrite saved info with return address
        ADDQ.L  #8,SP           Modify SP and drop through ...
*
*  Simpler type of exception. SP points to return address created
*  by BSR, the status register of the program which was running and
*  the program counter of the instruction which caused the exception.
*
EXCP2   TST.B   USERP           See if user program running
        BEQ.S   EXCP3           If zero then not user prog running
        CLR.B   USERP           Not user prog now
        MOVE.L  A0,-(SP)        Save A0 temporarily
        LEA     RAMBASE,A0      Point to RAM area
        LEA     RDUMPD(A0),A0   Get a pointer to register save area
        MOVEM.L D0-D7/A0-A6,(A0) Save all the user's registers
        MOVE.L  (SP)+,D_A0(A0)  Fix saved value of A0
        MOVE.L  (SP)+,A1        Extract return address caused by BSR
        MOVE.W  (SP)+,D_SR(A0)  Update user's SR
        BCLR    #TBIT,D_SR(A0)  Ensure trace bit turned off
        MOVE.L  (SP)+,D_PC(A0)  Update user's PC
        MOVE.L  USP,A2          Extract USP
        MOVE.L  A2,D_A7(A0)     And place that in A7 slot
*
* We must now remove any breakpoints and restore the original code
*
        LEA     RAMBASE,A6      Re-establish RAM pointer
        LEA     BRKP(A6),A3     Point to breakpoint save space
        MOVEQ   #9,D0           Counter
BRKL    MOVE.L  (A3)+,A4        Location of breakpoint
        MOVE.W  (A3)+,D1        Original code
        CMPA.L  #0,A4           Was breakpoint set?
        BEQ.S   BRKL1           No..
        MOVE.W  D1,(A4)         Replace original code
BRKL1   DBRA    D0,BRKL         Loop as required
        BRA.S   EXCP4           Now write message
*
* In this case an error (hopefully Bus error during M command) occurred
* while running the monitor. Do not alter user's registers, but
* give the message as usual.
*
EXCP3   MOVE.L  (SP)+,A1        Extract return address stacked by BSR
*
* We now have saved all the user's registers, and A1 contains the
* address of the next instruction after the one we jumped to via
* the interrupt vector locations.
*
EXCP4   SUBQ.L  #2,A1           Pointer to code we actually entered
*
* Check for the special case of a breakpoint or trace.
*
*       MOVE.L  I_RESET,SP      Reset system stack

        MOVE.W  #INTSON,SR      Interrupts on again
        LEA     T_EXCPT,A0      Trace exception
        CMPA.L  A0,A1           Was it one?
        BEQ.S   EXCP5           Yes, handle it
        LEA     TRP0,A0         Breakpoint trap?
        CMPA.L  A0,A1           Was it this?
        BEQ.S   EXCP6           Handle it
*
* Write message and enter command loop again
*
        BSR.S   WRABO           Write suitable message
        BRA     ST1             And handle any more commands
*
* TRACE exception. Could possibly be trace after passing a breakpoint,
* in which case we simply continue in the normal way, thus replacing
* any breakpoints.
*
EXCP5   TST.B   BFLG(A6)        Test to see if C was last command
        BNE     GO1             Continue execution if flag was not clear
*
* Normal trace. First display the registers.
* Issue different prompt, and if return is typed
* do another T command. Otherwise handle normal command.
*
        BSR.S   WRABO           Write trace message
        BSR     REGX            Print registers
        LEA     COMTAB,A0       Point to command table
        PEA     ST1             Push return address of command loop
        MOVE.B  #'t',D0         New prompt character
        BSR     WRCH            Write it out
        BSR     RDCH            Get next character
        CMP.B   #CR,D0          Return?
        BNE     SEARCH          No, do standard search for command
        BSET    #TBIT,RDUMPSR(A6)   Set the trace bit in saved SR
        BRA     GO1             And continue execution
*
* Breakpoint entry. Back up the program counter by two
*
EXCP6   SUBQ.L  #2,RDUMPPC(A6)  Back up user PC
        BSR.S   WRABO           Write breakpoint message
        BSR     REGX            Display registers
        BRA     ST1             And ask for another command
*
*  Subroutine to write abort message associated with address in A1
*
WRABO   LEA     B_EXCPT,A0      Base of table
        SUBA.L  A0,A1           Now a word offset from zero
        LEA     ABOTAB,A2       Pointer to abort table base
        MOVE.L  A1,D0           Offset into D0
        MOVE.W  0(A2,D0.L),A0   Offset of string from table base
        ADDA.L  A2,A0           Add table base giving pointer to string
        BRA     WRITES          Write it out and return

        PAGE

*
* Messages
*
MESS1   DC.B    'Atari monitor V1.4',0
MESS2   DC.B    'Unknown command',0
MESS3   DC.B    'Hexadecimal number expected',0
MESS4   DC.B    'Invalid memory command',0
MESS5   DC.B    'Current address not even',0
MESS6   DC.B    'Invalid register number',0
MESS8   DC.B    'Invalid breakpoint number',0
MESS9   DC.B    'Exit Monitor - are you sure ?',0
MESS10  DC.B    'Filename expected',0
MESS11  DC.B    'Program already loaded',0
MESS12  DC.B    'Load failed',0
MESS13  DC.B    'No program loaded',0
*
* Abort table messages
*
AB1     DC.B    'Bus error',0
AB2     DC.B    'Address error',0
AB3     DC.B    'Illegal instruction',0
AB4     DC.B    'Divide by zero',0
AB5     DC.B    'CHK exception',0
AB6     DC.B    'TRAPV exception',0
AB7     DC.B    'Privilege violation',0
AB8     DC.B    'Trace...',0
AB9     DC.B    'L1010 emulation',0
AB10    DC.B    'L1111 emulation',0
AB11    DC.B    'Spurious interrupt',0
AB12    DC.B    'Unexpected interrupt',0
AB13    DC.B    'Console abort',0
AB14    DC.B    'Unexpected TRAP',0
AB15    DC.B    'Breakpoint',0
AB16    DC.B    'End of user program',0
*
* Abort message table
*
ABOTAB  DC.W   (AB1-ABOTAB)
        DC.W   (AB2-ABOTAB)
        DC.W   (AB3-ABOTAB)
        DC.W   (AB4-ABOTAB)
        DC.W   (AB5-ABOTAB)
        DC.W   (AB6-ABOTAB)
        DC.W   (AB7-ABOTAB)
        DC.W   (AB8-ABOTAB)
        DC.W   (AB9-ABOTAB)
        DC.W   (AB10-ABOTAB)
        DC.W   (AB11-ABOTAB)
        DC.W   (AB12-ABOTAB)
        DC.W   (AB13-ABOTAB)
        DC.W   (AB14-ABOTAB)
        DC.W   (AB15-ABOTAB)
        DC.W   (AB16-ABOTAB)
        PAGE
*
* Tables for search routine
*
* Command table
COMTAB  DC.W    CR              Just a return
        DC.W    (SKIPNL-COMTAB)
        DC.W    'm'             Memory change
        DC.W    (MEM-COMTAB)
        DC.W    'r'             Register dump
        DC.W    (DREG-COMTAB)
        DC.W    'd'             Alter data register
        DC.W    (SETD-COMTAB)
        DC.W    'a'             Alter address register
        DC.W    (SETA-COMTAB)
        DC.W    'p'             Alter PC
        DC.W    (SETP-COMTAB)
        DC.W    's'             Alter SR
        DC.W    (SETS-COMTAB)
        DC.W    'g'             Enter user program
        DC.W    (GO-COMTAB)
        DC.W    't'             Trace user program
        DC.W    (TGO-COMTAB)
        DC.W    'b'             Breakpoint
        DC.W    (BRK-COMTAB)
        DC.W    'c'             Continue after breakpoint
        DC.W    (CONT-COMTAB)
        DC.W    'v'             View program spec.
        DC.W    (VIEW-COMTAB)
        DC.W    'o'             Set address offset
        DC.W    (SETOFF-COMTAB)
        DC.W    'l'             Load user program
        DC.W    (LOAD-COMTAB)
        DC.W    'x'             Exit monitor
        DC.W    (EXIT-COMTAB)
        DC.W    $FF00           Marker flag for end
        DC.W    (COMERR-COMTAB)

* Memory change table

MEMTAB  DC.W    CR              Move to next location
        DC.W    (NMEM-MEMTAB)
        DC.W    '^'             Up arrow
        DC.W    (PMEM-MEMTAB)   Previous memory location
        DC.W    '='             Equals
        DC.W    (SKIPNL-MEMTAB) Stay at same location
        DC.W    's'             Set to byte size
        DC.W    (SETB-MEMTAB)
        DC.W    'w'             Set to word size
        DC.W    (SETW-MEMTAB)
        DC.W    'l'             Set to long size
        DC.W    (SETL-MEMTAB)
        DC.W    $FF00           Marker flag for end
        DC.W    (MEMERR-MEMTAB) Memory change error
*
* strings for use with PEXEC function
*
CMDSTR   DC.W   0               Null command line string
PSSTR    DC.B   'Prog start = ',0
DSSTR    DC.B   '    Data start = ',0
OFFSTR   DC.B   'Offset = ',0
*
* Data area
*
USERP   DC.W    0               Zero if running monitor
*
* Vector table, used to set-up the exception vectors
* for those exceptions which the monitor is to intercept.
* Those set to NULLVEC will not be altered
*
TS
I_BERR  DC.L    B_EXCPT-TS      Bus error
        DC.L    A_EXCPT-TS      Address error
        DC.L    I_EXCPT-TS      Illegal instruction
        DC.L    D_EXCPT-TS      Divide by zero
        DC.L    C_EXCPT-TS      CHK exception
        DC.L    O_EXCPT-TS      TRAPV exception
        DC.L    P_EXCPT-TS      Privilege exception
I_TRACE DC.L    T_EXCPT-TS      Trace exception
        DC.L    NULLVEC         L1010 emulation (Atari ST graphics)
        DC.L    NULLVEC         L1111 emulation (used by GEM AES)
        DCB.L   12,NULLVEC      Unassigned as yet so keep them all null
        DC.L    S_EXCPT-TS      Spurious interrupt
*
* Autovectored interrupts
*
* mustn't touch the interrupt vectors used by the OS.
*
        DC.L    NULLVEC         Interrupt level 1
        DC.L    NULLVEC         Interrupt level 2
        DC.L    NULLVEC         Interrupt level 3
        DC.L    NULLVEC         Interrupt level 4
        DC.L    NULLVEC         Interrupt level 5
I_INT6  DC.L    NULLVEC         Interrupt level 6
I_INT7  DC.L    NULLVEC         Interrupt level 7
*
* Trap vectors, mustn't change the ones used for OS calls
*
        DC.L    TRP0-TS         Breakpoint TRAP
        DC.L    NULLVEC         TRAP #1 is a GEMDOS call
        DC.L    TRP-TS          Unexpected TRAP
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    TRP-TS
        DC.L    NULLVEC         TRAP #13 is a BIOS call
        DC.L    NULLVEC         TRAP #14 is an XBIOS call
I_BRK   DC.L    TRP15-TS        User requests

        BSS
FNAME   DS.B    30         30 character buffer for filename
STRBUFF DS.B    82         80 character string buffer for CCONRS
SAVE_SP DS.L    1          space for systems super-stack-pointer
BP_PTR  DS.L    1          space for user prog's basepage pointer
POFFSET DS.L    1          memory address offset value
VECSAVE DS.L    INTSIZE    reserve space to save system's vectors
RAMBASE DS.B    RAMEND     reserve for RAM workspace

        END
