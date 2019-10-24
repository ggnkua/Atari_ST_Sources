*
* ADD A MACHINECODE ROUTINE TO THE BOOTSECTOR
*

STACK     EQU       4000

GEMDOS    EQU       $01

CCONIN    EQU       $01
CRAWCIN   EQU       $07
CCONWS    EQU       $09
TSETDATE  EQU       $2B
TSETTIME  EQU       $2D
M_SHRINK  EQU       $4A

XBIOS     EQU       $E

FLOPRD    EQU       8
FLOPWR    EQU       9
PROTOBT   EQU       18
GETTIME   EQU       23
SETPRT    EQU       33

* MEMORY MANAGEMENT AND INITIALISATION

          MOVE.L    4(A7),A0            * FETCH BASEPAGE
          MOVE.L    $C(A0),D0           * LENGTH OF TEXT
          MOVE.L    $14(A0),D0          * LENGTH OF DATA
          MOVE.L    $1C(A0),D0          * LENGTH OF BSS
          ADD.L     #$100,D0            * BASEPAGE SIZE
          ADD.L     #STACK,D0           * STACK SIZE
          MOVE.L    A0,A7               * SET THE STACK
          ADD.L     D0,A7
          MOVE.L    D0,-(A7)            * ONLY ALLOCATE AS MUCH SPACE
          MOVE.L    A0,-(A7)            * AS WE ARE USING
          CLR.W     -(A7)
          MOVE.W    #M_SHRINK,-(A7)
          TRAP      #GEMDOS
          LEA       12(A7),A7

* DISPLAY TEXT 

AGAIN     PEA       OPEN_MSG
          MOVE.W    #CCONWS,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #6,A7

* WAIT FOR A KEY

          MOVE.W    #CRAWCIN,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #2,A7

* READ THE BOOTSECTOR

          MOVE.W    #1,-(A7)            * ONE SECTOR TO READ
          CLR.W     -(A7)               * SELECT SIDE 0
          CLR.W     -(A7)               * SELECT TRACK 0
          MOVE.W    #1,-(A7)            * SELECT SECTOR 1
          CLR.W     -(A7)               * SELECT DISKDRIVE A
          CLR.L     -(A7)               * FILLER
          PEA       BUFFER              * START OF THE BUFFER
          MOVE.W    #FLOPRD,-(A7)
          TRAP      #XBIOS
          LEA       20(A7),A7
          TST.L     D0
          BEQ.S     READ_OK

* ERROR WHILE READING
 
          PEA       READ_ERR
          MOVE.W    #CCONWS,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #6,A7
          BRA.S     NEXT

* COPY THE MACHINECODE ROUTINE INTO THE BOOTSECTOR

READ_OK   MOVE.L    #BUFFER,A0
          MOVE.W    #$601C,(A0)         * BRANCH TO THE BEGIN OF THE CODE
          LEA       $1E(A0),A0          * START OF BOOTCODE AREA
          MOVE.L    #EXECUTE,A1         * START OF MACHINECODE
          MOVE.W    #119,D0             * MAXIMUM LENGTH OF THE MACHINECODE
COPY_NEXT MOVE.L    (A1)+,(A0)+
          DBF       D0,COPY_NEXT


* MAKE THE BOOTSECTOR EXECUTABLE

          MOVE.W    #1,-(A7)            * MAKE EXECUTABLE
          MOVE.W    #-1,-(A7)           * LEAVE DISKTYPE ALONE 
          MOVE.L    #-1,-(A7)           * LEAVE SERIALNUMBER ALONE
          PEA       BUFFER              * START OF THE BUFFER
          MOVE.W    #PROTOBT,-(A7)
          TRAP      #XBIOS
          LEA       14(A7),A7

* WRITE THE BOOTSECTOR TO THE DISK

          MOVE.W    #1,-(A7)            * ONE SECTOR TO WRITE
          CLR.W     -(A7)               * SELECT SIDE 0
          CLR.W     -(A7)               * SELECT TRACK 0
          MOVE.W    #1,-(A7)            * SELECT SECTOR 1
          CLR.W     -(A7)               * SELECT DISKDRIVE A
          CLR.L     -(A7)               * FILLER
          PEA       BUFFER              * START OF THE BUFFER
          MOVE.W    #FLOPWR,-(A7)
          TRAP      #XBIOS
          LEA       20(A7),A7 
          TST.L     D0
          BEQ.S     NEXT

* ERROR WHILE WRITING

          PEA       WRITE_ERR
          MOVE.W    #CCONWS,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #6,A7

* "RUN PROGRAM AGAIN ?" MESSAGE

NEXT      PEA       AGAIN_MSG
          MOVE.W    #CCONWS,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #6,A7

* GET A KEY

          MOVE.W    #CCONIN,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #2,A7

          AND.B     #%01011111,D0
          CMP.B     #"Y",D0

          BEQ       AGAIN

* END OF PROGRAM

          CLR.W     -(A7)
          TRAP      #GEMDOS

* HERE FOLLOWS THE MACHINECODE ROUTINE THAT MUST BE INCORPORATED INTO
* THE BOOTSECTOR. REMEMBER THE FOLLOWING POINTS:
* - THE LENGTH MAY NOT EXCEED 480 BYTES
* - THE MACHINECODE MUST BE POSITION INDEPENDED
* - THE MACHINECODE MUST BE FINISHED WITH AN RTS INSTRUCTION
* - DON'T USE GEM OR VDI ROUTINES
* - THE MACHINECODE IS EXECUTED IN SUPERVISORMODE, DON'T CHANGE THE MODE 

EXECUTE:

* SET THE PRINTER CONFIGURATION

          MOVE.W    #%101110,-(A7)
          MOVE.W    #SETPRT,-(A7)
          TRAP      #XBIOS
          ADDQ.L    #4,A7

* COPY THE KEYBOARD PROCESSOR TIME AND DATE TO GEM

          MOVE.W    #GETTIME,-(A7)  
          TRAP      #XBIOS          
          ADDQ.L    #2,A7
          MOVE.W    D0,-(A7)
          SWAP      D0
          MOVE.W    D0,-(A7)
          MOVE.W    #TSETDATE,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #4,A7
          MOVE.W    #TSETTIME,-(A7)
          TRAP      #GEMDOS
          ADDQ.L    #4,A7
          
* FIDDLE THE HZ

          MOVE.B    $FFFF820A,D7
          EOR.B     #%10,D7
          DC.W      $4DFA              * MY ASSEMBLER GOT PROBLEMS
          DC.W      $0004              * WITH LEA 4(PC),A6
          BRA.S     TIME_DUM
          MOVE.B    D7,$FFFF820A
          RTS
               
TIME_DUM  LEA       $FFFFFA21,A0
          LEA       $FFFFFA1B,A1
          MOVE.B    #$10,(A1)
          MOVEQ.L   #1,D4
          MOVE.B    #0,(A1)
          MOVE.B    #$F0,(A0)
          MOVE.B    #$8,$FFFFFA1B
WAIT_1    MOVE.B    (A0),D0
          CMP.B     D4,D0
          BNE.S     WAIT_1
WAIT_2    MOVE.B    (A0),D4
          MOVE.W    #$267,D3
WAIT_3    CMP.B     (A0),D4
          BNE.S     WAIT_2
          DBF       D3,WAIT_3    
          MOVE.B    #$10,(A1)
          JMP       (A6)
   
* INITIALISED DATA

          DATA          
          
OPEN_MSG  DC.B      27,'E'
          DC.B      "**********************************",13,10
          DC.B      "*                                *",13,10
          DC.B      "*       BOOTSECTOR MODIFIER      *",13,10
          DC.B      "*                                *",13,10
          DC.B      "*       (C) Guus Surtel 1987     *",13,10
          DC.B      "*                                *",13,10
          DC.B      "**********************************",13,10
          DC.B      13,10,13,10
          DC.B      "Insert the disk to be modified and press return..."
          DC.B      0

READ_ERR  DC.B      13,10
          DC.B      "Error while reading !"
          DC.B      0

WRITE_ERR DC.B      13,10
          DC.B      "Error while writing !"
          DC.B      0

AGAIN_MSG DC.B      13,10
          DC.B      "Would you like to run this program again ? (y/n) "
          DC.B      0
 
* UNITIALISED DATA

          BSS

BUFFER    DS.W      256

* END OF THE PROGRAM

          END

