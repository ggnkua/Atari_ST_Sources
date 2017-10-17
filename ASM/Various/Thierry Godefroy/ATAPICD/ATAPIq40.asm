********************************************************************************
*     ATAPI extensions thing v0.20 for Q40/Q60 (c) 2001 Thierry Godefroy.      *
*    This software is free and open source (under the "artistic" license).     *
********************************************************************************

          data      0
          section   ATAPI

          include   drv1_src_asm_ATAPI_inc

* Thing version Id:

VERSION   equ       '0.20'

* Room needed by the thing definition header. Note that this header is followed
* by the thing variables area (44 bytes + thing name length in chars (rounded
* up to the next even number).

THGDEFHDL equ       $32

* The following offsets are relative to the pseudo device driver linkage block.
* They are used inside the SCHEDINT routine (in which they are relative to A3).

ATP_PKTQL equ       0                             ATAPI packet queue link.
ATP_REGBS equ       4                             IDE ctrl register base addr.
ATP_MCONF equ       8                             Master drive configuration.
ATP_MCAPA equ       10                            Master drive capabilities.
ATP_SCONF equ       12                            Slave drive configuration.
ATP_SCAPA equ       14                            Slave drive capabilities.

* Device driver linkage block offsets (QDOS/SMS fixed: don't change !).

IOD_SHLK  equ       $10                           Scheduler loop linkage.
IOD_SHAD  equ       $14                           Scheduler loop routine addr.

* Variables offsets into the ATAPI thing linkage block.
*
* Notes about drive flags:
* ------------------------
* MSB of the ATP_CONFn word : bit 7 denotes a removable media, bits 6 and 5
*                             give the CMD DRQ type (00=micro-processor (3ms),
*                             01=interrupt (10ms), 10=accelerated (50°s)), and
*                             bits 1 and 0 the packet size (00=12 bytes, 01=16
*                             bytes).
* LSB of the ATP_CONFn word : bit 7 and 6 give the protocol type (10=ATAPI),
*                             bits 4 to 0 give the device type (5=CD-ROM).
*
* MSB of the ATP_CAPAn word : this vendor specific byte is overwritten by the
*                             ident ATAPI device routine: it is set to $FF if no
*                             ATAPI drive is present or to $00 if an ATAPI drive
*                             is present, ready and identified.
* LSB of the ATP_CAPAn word : bit 5 is interesting as it denotes OVERLAPped
*                             command support when set.

ATP_PKQL1 equ       THGDEFHDL+ATP_PKTQL           ATAPI packet queue link #1.
ATP_REGB1 equ       ATP_PKQL1+ATP_REGBS           IDE ctrl 1 register base addr.
ATP_CONF0 equ       ATP_PKQL1+ATP_MCONF           Drive 0 configuration flags.
ATP_CAPA0 equ       ATP_PKQL1+ATP_MCAPA           Drive 0 capabilities flags.
ATP_CONF1 equ       ATP_PKQL1+ATP_SCONF           Drive 1 configuration flags.
ATP_CAPA1 equ       ATP_PKQL1+ATP_SCAPA           Drive 1 capabilities flags.
ATP_SCDL1 equ       ATP_PKQL1+IOD_SHLK            Link to next sched loop rout.
ATP_SCHD1 equ       ATP_PKQL1+IOD_SHAD            Scheduler loop #1 pointer.

ATP_PKQL2 equ       ATP_SCHD1+4+ATP_PKTQL         ATAPI packet queue link #2.
ATP_REGB2 equ       ATP_PKQL2+ATP_REGBS           IDE ctrl 2 register base addr.
ATP_CONF2 equ       ATP_PKQL2+ATP_MCONF           Drive 2 configuration flags.
ATP_CAPA2 equ       ATP_PKQL2+ATP_MCAPA           Drive 2 capabilities flags.
ATP_CONF3 equ       ATP_PKQL2+ATP_SCONF           Drive 3 configuration flags.
ATP_CAPA3 equ       ATP_PKQL2+ATP_SCAPA           Drive 3 capabilities flags.
ATP_SCDL2 equ       ATP_PKQL2+IOD_SHLK            Link to next sched loop rout.
ATP_SCHD2 equ       ATP_PKQL2+IOD_SHAD            Scheduler loop #2 pointer.

ATP_PKQL3 equ       ATP_SCHD2+4+ATP_PKTQL         ATAPI packet queue link #3.
ATP_REGB3 equ       ATP_PKQL3+ATP_REGBS           IDE ctrl 3 register base addr.
ATP_CONF4 equ       ATP_PKQL3+ATP_MCONF           Drive 4 configuration flags.
ATP_CAPA4 equ       ATP_PKQL3+ATP_MCAPA           Drive 4 capabilities flags.
ATP_CONF5 equ       ATP_PKQL3+ATP_SCONF           Drive 5 configuration flags.
ATP_CAPA5 equ       ATP_PKQL3+ATP_SCAPA           Drive 5 capabilities flags.
ATP_SCDL3 equ       ATP_PKQL3+IOD_SHLK            Link to next sched loop rout.
ATP_SCHD3 equ       ATP_PKQL3+IOD_SHAD            Scheduler loop #3 pointer.

ATP_PKQL4 equ       ATP_SCHD3+4+ATP_PKTQL         ATAPI packet queue link #4.
ATP_REGB4 equ       ATP_PKQL4+ATP_REGBS           IDE ctrl 4 register base addr.
ATP_CONF6 equ       ATP_PKQL4+ATP_MCONF           Drive 6 configuration flags.
ATP_CAPA6 equ       ATP_PKQL4+ATP_MCAPA           Drive 6 capabilities flags.
ATP_CONF7 equ       ATP_PKQL4+ATP_SCONF           Drive 7 configuration flags.
ATP_CAPA7 equ       ATP_PKQL4+ATP_SCAPA           Drive 7 capabilities flags.
ATP_SCDL4 equ       ATP_PKQL4+IOD_SHLK            Link to next sched loop rout.
ATP_SCHD4 equ       ATP_PKQL4+IOD_SHAD            Scheduler loop #4 pointer.

* Total length for the thing linkage block (i.e. THGDEFHDL + variables area
* length + vectors area size).

THGDEF    equ       ATP_VECTS+6*16

* Hardware keys:

* Offsets (relative to the IDE controller base) for the various IDE registers.

IDE_DATA  equ       0<<2+0                        Data address register (word).
IDE_ERROR equ       1<<2+1                        Error register (read).
IDE_FEATR equ       1<<2+1                        Feature register (write).
IDE_NSECT equ       2<<2+1                        Sector count register.
IDE_SECTR equ       3<<2+1                        "sector" register.
IDE_LCYL  equ       4<<2+1                        "lcyl" register.
IDE_HCYL  equ       5<<2+1                        "hcyl" register.
IDE_CURRT equ       6<<2+1                        "current" register.
IDE_STATS equ       7<<2+1                        Status register (read).
IDE_CMD   equ       7<<2+1                        Command register (write).
IDE_ASTAT equ       $206<<2+1                     Alternate status register (r).
IDE_CTRL  equ       $206<<2+1                     Control register (write).

* ATAPI Interrupt Reason Register (IDE_NSECT) bits:

IDE..COD  equ       0                             Command (1) or data (0).
IDE..IO   equ       1                             IO direction (1=to host).
ISE..REL  equ       2                             ATA bus release flag.

IDE.COD   equ       %00000001                     Command awaited.
IDE.IO    equ       %00000010                     Data to host awaiting.
IDE.REL   equ       %00000100                     ATA bus released.

* IDE STATUS bits:

IDE..ERR  equ       0                             Error in previous command.
IDE..IDX  equ       1                             Set to 1 at each disk revol.
IDE..ECC  equ       2                             Succes. read, error corrected.
IDE..DRQ  equ       3                             Data transfer request.
IDE..SEEK equ       4                             Seek complete.
IDE..WERR equ       5                             Write fault.
IDE..RDY  equ       6                             Drive is ready.
IDE..BUSY equ       7                             IDE controller busy.

IDE.ERR   equ       %00000001                     Error in previous command.
IDE.IDX   equ       %00000010                     Set to 1 at each disk revol.
IDE.ECC   equ       %00000100                     Succes. read, error corrected.
IDE.DRQ   equ       %00001000                     Data transfer request.
IDE.SEEK  equ       %00010000                     Seek complete.
IDE.WERR  equ       %00100000                     Write fault.
IDE.RDY   equ       %01000000                     Drive is ready.
IDE.BUSY  equ       %10000000                     IDE controller busy.

* IDE ERROR bits:

IDE..SNS  equ       %11110000                     Mask for sense bits.
IDE..MCR  equ       3                             Media change request.
IDE..ABRT equ       2                             Aborted command.
IDE..EOM  equ       1                             End of media detected.
IDE..ILI  equ       0                             Illegal length indication.

* Sense keys (as available in IDE error byte shifted right into lower nibble):

SNS.RECOV equ       1                             Recovered data with err/corr.
SNS.NOTRD equ       2                             Logical drive not ready
SNS.UNREC equ       3                             Unrecoverable error.
SNS.BADCD equ       5                             Bad command/parameters.
SNS.RESET equ       6                             RESET in progress.

* IDE CTRL bits:

IDE.NIEN  equ       %00000010                     Disable interrupts.
IDE.SRST  equ       %00000100                     Perform software reset.

IDE.CTLM  equ       %00001000                     Mandatory bits (to be ORed).

IDE..NIEN equ       1                             Set to disable interrupts.
IDE..SRST equ       2                             Set to perform software reset.

********************************************************************************
* Initialization routine:

          MOVEQ     #1,D7                         Set the first init flag.
          BRA.S     INIT                          Initialize ATAPI thing now.
ATAPILINK MOVEQ     #0,D7                         Reset the "first init" flag.
INIT      MOVEQ     #0,D0                         | Get system info.
          TRAP      #1                            |
          MOVEQ     #-19,D0                       "Not implemented" error code.
          CMPI.L    #'SMSQ',(A0)                  Are we running under SMSQ(/E)?
          BNE.S     INIT_END                      If not then return with error.
          MOVE.B    $A7(A0),D2                    Get the machine type.
          ANDI.B    #$1F,D2                       Get rid of display type flags.
          CMPI.B    #$11,D2                       Is this a Q40/Q60 ?
          BNE.S     INIT_END                      If no then return with error.
          MOVEQ     #-2,D0                        "Invalid job Id" error code.
          TST.L     D1                            Is job 0 the calling job ?
          BNE.S     INIT_END                      If no, then return with error.
          BSR.S     INIT_THG                      Initialize the thing.
          TST.L     D0                            Was there an error ?
          BNE.S     INIT_END                      If yes, return to SBASIC now.
          TST.B     D7                            Is the "first init" flag set ?
          BEQ.S     INIT1                         If no then jump over...
          LEA       PROC_FN,A1                    PROC/FN table address.
          MOVEA.W   $110,A2                       | Link in the new PROCs/FNs.
          JSR       (A2)                          |
          BNE.S     INIT_END                      If error, return.
INIT1     LEA       COPYRIGHT,A1                  Get copyright message address.
          SUBA.L    A0,A0                         SBASIC #0 channel Id.
          MOVEA.W   $D0,A2                        | Print the copyright.
          JSR       (A2)                          |
INIT_END  RTS                                     Return to SBASIC.

********************************************************************************
* ATAPI thing initialization:

INIT_THG  BSR       SEARCH                        Search for the THING vector.
          BNE.S     INIT_END                      If error, return now.
          LEA       ATPNAME,A0                    Pointer on thing name.
          MOVEQ     #$27,D0                       | Remove possible previously
          JSR       (A4)                          |  loaded old ATAPI thing.
          CMPI.L    #-9,D0                        Is the old thing still in use?
          BEQ.S     INIT_END                      If yes, then return now...
          MOVEQ     #0,D2                         | Reserves some space for the
          MOVE.L    #THGDEF,D1                    |  thing linkage block in the
          MOVEQ     #$18,D0                       |  common heap (owner is the
          TRAP      #1                            |  un-removable job 0).
          TST.L     D0                            Error ?
          BNE.S     INIT_END                      If yes, return immediately.
          MOVEA.L   A0,A3                         Save linkage block address.
          ADDQ.L    #8,A0                         Jump over system links.
          CLR.L     (A0)+                         Use default TH_FRFRE routine.
          CLR.L     (A0)+                         Use default TH_FRZAP routine.
          LEA       ATAPI_THG,A1                  ATAPI thing address.
          MOVE.L    A1,(A0)+                      Store thing address.
          CLR.L     (A0)+                         Use default TH_USE routine.
          CLR.L     (A0)+                         Use default TH_FREE routine.
          CLR.L     (A0)+                         Use default TH_FFREE routine.
          LEA       ATPTHGRMV,A1                  ATAPI thing TH_REMOV addr.
          MOVE.L    A1,(A0)+                      Use my routine for TH_REMOV.
          CLR.W     (A0)+                         This thing is shareable.
          MOVE.L    #VERSION,(A0)+                Thing version ID.
          MOVE.W    #5,(A0)+                      Length of thing name.
          MOVE.L    #'ATAP',(A0)+                 | Name of thing.
          MOVE.W    #'I ',(A0)+                   |
          LEA       ATP_VECTS(A3),A0              Point on vectors table start.
          MOVE.W    #$4EF9,D0                     Opcode for JMP.
          LEA       IDENTDEV,A1                   | Setup the JMP fo the 'IDEN'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       RESETDEV,A1                   | Setup the JMP fo the 'RSET'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       TRANSIENT,A1                  | Setup the JMP fo the 'ATPK'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       RESERVPKT,A1                  | Setup the JMP fo the 'ANPK'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       PKTZERO,A1                    | Setup the JMP fo the 'ZPKT'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       QUEUE,A1                      | Setup the JMP fo the 'QPKT'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       UNQUEUE,A1                    | Setup the JMP fo the 'UQPK'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       RUNQUEUE,A1                   | Setup the JMP fo the 'RUNQ'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       DECODESNS,A1                  | Setup the JMP fo the 'DSNS'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       WAITCOMP,A1                   | Setup the JMP fo the 'WPCC'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       SETFEATUR,A1                  | Setup the JMP fo the 'FEAT'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       SLEEPDRV,A1                   | Setup the JMP fo the 'SLEP'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          LEA       STBYDRV,A1                    | Setup the JMP fo the 'STBY'
          MOVE.W    D0,(A0)+                      |  extension thing routine.
          MOVE.L    A1,(A0)+                      |
          MOVE.L    #$70ED4E75,D0                 Opcodes for MOVEQ #-19,D0 RTS.
          MOVE.L    D0,(A0)+                      | Not implemented extension.
          ADDQ.L    #2,A0                         |
          MOVE.L    D0,(A0)+                      | Not implemented extension.
          ADDQ.L    #2,A0                         |
          MOVE.L    D0,(A0)+                      | Not implemented extension.
          MOVEA.L   A3,A1                         A1=thing linkage block addr.
          MOVEQ     #$26,D0                       | Link in my thing.
          JSR       (A4)                          |
          TST.L     D0                            Is there any error ?
          BEQ.S     INIT_SCHD                     If no jump over...
INITTHG1  MOVE.L    D0,D4                         Save error code.
          MOVEA.L   A3,A0                         Thing linkage block address.
          MOVEQ     #$19,D0                       | Release common heap area
          TRAP      #1                            |  (thing linkage block).
          MOVE.L    D4,D0                         Restore error code.
          RTS                                     Return.

*******************************************************************************
* Scheduler loop routines initialisation. There is one such routine for each
* IDE controller (4 controllers are supported). In fact the SAME routine is
* shared by all controllers but it is linked 4 times with a different pseudo-
* device driver linkage block address each time; this address is held in A3
* when the routine is called and A3 therefore points on different sets of
* variables (one for each IDE controller) for the four linked scheduler loops
* routines.

INIT_SCHD MOVE.B    #1,$FF000010                  Disable external interrupts.
          LEA       ATP_PKQL1(A3),A4              Pseudo dev driver linkage add.
          MOVEQ     #3,D1                         Number of routines - 1.
INITSCHD1 CLR.L     ATP_PKTQL(A4)                 Clear the ATAPI packet queue.
          ST        ATP_MCAPA(A4)                 | Mark master and slave drives
          ST        ATP_SCAPA(A4)                 |  as not yet identified.
          LEA       IOD_SHLK(A4),A0               Sched. int. link address.
          LEA       SCHEDINT,A2                   Scheduler interrupt address.
          MOVE.L    A2,4(A0)                      Store it.
          MOVEQ     #$1E,D0                       | Link in the scheduler
          TRAP      #1                            |  interrupt routine.
          ADDA.W    #ATP_PKQL2-ATP_PKQL1,A4       Point on next pseudo linkage.
          DBRA      D1,INITSCHD1                  Link next sched loop routine.
INITSCHD2 RTS                                     Return.

********************************************************************************
* ATAPI_UNLINK (PROC), syntax:  ATAPI_UNLINK
*
* This procedure unlinks the ATAPI thing. Note that the SBASIC extensions are
* _not_ removed by this code.

ATAPIUNLK BSR       SEARCH                        Get the THING vector.
          BNE.S     INITSCHD2                     If error then return.
          LEA       ATPNAME,A0                    Name of the thing to remove.
          MOVEQ     #$27,D0                       | Remove the ATAPI thing.
          JMP       (A4)                          |

********************************************************************************
* This code (TH_REMOVE) is called when the ATAPI thing is removed.

ATPTHGRMV MOVEA.L   A1,A4                         Save thing linkage block addr.

* Unlink the scheduler loop routines removing all remaining transient packets
* from memory.

          LEA       ATP_PKQL1(A4),A2              Pseudo dev driver linkage add.
          MOVEQ     #3,D1                         Number of routines - 1.
ATPTHGRM1 LEA       IOD_SHLK(A2),A0               Sched. int. link address.
          MOVEQ     #$1F,D0                       | Link in the scheduler
          TRAP      #1                            |  interrupt routine.
          MOVEA.L   A2,A0                         Copy address of packet queue.
ATPTHGRM3 MOVE.L    (A0),D0                       Is there any packet left ?
          BEQ.S     ATPTHGRM2                     If no more packet, jump over.
          MOVEA.L   D0,A0                         Address of the packet.
          BSET      #PKT..AERR,PKT_FLAGS(A0)      Report an ATA error (aborted).
          BTST      #PKT..TRNS,PKT_FLAGS(A0)      Was it a transient packet ?
          BEQ.S     ATPTHGRM3                     If no, process next packet.
          MOVEM.L   D1/A0/A2,-(SP)                Save context.
          SUBQ.L    #4,A0                         Actual memory block start.
          MOVEA.W   $C2,A3                        | Release common heap space.
          JSR       (A3)                          |
          MOVEM.L   (SP)+,D1/A0/A2                Restore context.
          BRA.S     ATPTHGRM3                     Process next packet.
ATPTHGRM2 ADDA.W    #ATP_PKQL2-ATP_PKQL1,A2       Point on next pseudo linkage.
          DBRA      D1,ATPTHGRM1                  Link next sched loop routine.

* And finally we must return the thing linkage block to the common heap:

          MOVEA.L   A4,A0                         Thing linkage block address.
          MOVEQ     #$19,D0                       | De-allocate this block from
          TRAP      #1                            |  the common heap.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

********************************************************************************
* 'RUNQ': RUN Queue routine (forces a run through the scheduler loop routine for
*         a given drive).
*
* Input parameters  : D1.B = drive number.
*                     A2.L = thing linkage block address.
*                     A6.L = pointer on system variables base.
* Output parameters : D0.L = error code (always 0, never fails).
* Modified registers: D0.
*
* NOTE: this routine MUST be called in supervisor mode only.

RUNQUEUE  MOVEM.L   D1-D7/A0-A5,-(SP)             Save context.
          ANDI.W    #PKT..DRIV,D1                 Drive number is >0 and <8.
          LSR.W     #1,D1                         IDE controller number.
          MULU      #ATP_PKQL2-ATP_PKQL1,D1       Offset for IDE ctrl block.
          LEA       ATP_PKQL1(A2,D1.W),A3         Pseudo-linkage block address.
          BSR.S     SCHEDINT                      Run the queue.
          MOVEM.L   (SP)+,D1-D7/A0-A5             Restore context.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

********************************************************************************
* ATAPI thing scheduler loop routine. This is the main ATAPI packet protocol
* routine.

* First check for waiting ATAPI packet into our queue, if nothing is found
* return

SCHEDINT  MOVE.L    ATP_PKTQL(A3),D0              Get the first packet address.
          BNE.S     SCHEDINT1                     If packet waiting, jump over.
          RTS                                     Return.

* A packet is waiting, so extract the drive (master or slave) from the packet
* header, get the corresponding configuration flags for the drive and set the
* packet length accordingly.

SCHEDINT1 MOVE.W    SR,D7                         Save 680x0 status register.
          ORI.W     #$0300,SR                     Level 2 interrupts forbiden !
          MOVEA.L   D0,A0                         Address of packet to process.
          MOVEA.L   ATP_REGBS(A3),A2              IDE controller reg base addr.
          LEA       ATP_MCONF(A3),A1              Master config word address.
          MOVEQ     #$E0,D4                       IDE_CURRT (master select).
          BTST      #PKT..SLAV,PKT_DRIVE(A0)      Is the slave bit set ?
          BEQ.S     SCHEDINT2                     If no, then jump over...
          ADDQ.L    #ATP_SCONF-ATP_MCONF,A1       Slave config word address.
          MOVEQ     #$F0,D4                       IDE_CURRT (slave select).
SCHEDINT2 SWAP      D4                            Save select drive byte in MSW.
          TST.B     ATP_MCAPA-ATP_MCONF(A1)       Is the drive identified ?
          BNE       ATAERROR                      If not, then abort packet !
          MOVE.W    #12,D4                        Default packet length.
          BTST      #0,(A1)                       Is the packet 16 bytes long ?
          BEQ.S     SNDPACKET                     If no, jump over...
          ADDQ.W    #4,D4                         The packet is 16 bytes long.

* This is the routine for sending the ATAPI packet command:
*
* Check first if the controller is not busy nor performing data transfer:

SNDPACKET BSR       READASTAT                     Read and save IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          BEQ.S     SENDPKT2                      Yes, continue...
SENDPKT1  MOVE.W    D7,SR                         Allow level 2 interrupts.
          RTS                                     Abort (wait next poll).

* We now can perform the device selection protocol:

SENDPKT2  SWAP      D4                            Get drive number in LS word.
          MOVE.B    D4,IDE_CURRT(A2)              Select the proper drive.
          SWAP      D4                            Packet length back in LSW.
          MOVE.W    #1000,D1                      Timeout.
SENDPKT3  BSR       DELAY                         Wait for 400ns.
          BSR       READASTAT                     Read and save IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,SENDPKT3                   If no, wait some more...
          TST.W     D1                            Timed out ?
          BMI       ATAERROR                      If yes, then abort.

* The proper device is selected, ensure that it will not use interrupts:

SENDPKT7  MOVE.B    #IDE.NIEN+IDE.CTLM,IDE_CTRL(A2)

* Setup IDE registers and write the ATA "PACKET" command:

          CLR.B     IDE_FEATR(A2)                 Features: no overlap, no DMA.
          MOVE.B    #$FE,IDE_LCYL(A2)             | Max supported transfer
          MOVE.B    #$FF,IDE_HCYL(A2)             |  length.
          MOVE.B    #$A0,IDE_CMD(A2)              Packet command opcode.

* Wait for BSY=0 and DRQ=1... and check for possible error !

SENDPKT4  BSR       DELAY                         Wait for 400 ns.
          BSR       READASTAT                     Read and save IDE status.
          BTST      #IDE..BUSY,D0                 Controller still busy ?
          BNE.S     SENDPKT4                      Yes, so wait again...
          BTST      #IDE..DRQ,D0                  Controller ready for data ?
          BNE.S     SENDPKT5                      Yes, so go on...
          BTST      #IDE..ERR,D0                  Was there an error ?
          BNE       ATAERROR                      If yes, then abort !
          BRA.S     SENDPKT4                      Wait (should never occur !).

* Send the actual ATAPI packet:

SENDPKT5  MOVE.W    D4,D0                         Packet length in bytes.
          LSR.W     #1,D0                         Packet length in words.
          SUBQ.W    #1,D0                         Counter (number of words-1).
          LEA       PKT_DATA(A0),A1               Pointer to first packet word.
SENDPKT6  MOVE.W    (A1)+,D1                      Get a word.
          ROL.W     #8,D1                         Swap bytes.
          MOVE.W    D1,IDE_DATA(A2)               Send the word to IDE I/F.
          DBRA      D0,SENDPKT6                   Process next word if any.
          BSET      #PKT..SENT,PKT_FLAGS(A0)      Set the sent flag.

* The following routine is responsible for exchanging data after the ATAPI
* command was sent to the drive:

* Recover our data buffer address and size, as well as amount of data already
* transfered (will be used later when overlapped commands will be implemented
* and/or when the SMSQ/E ATA disk device driver will allow for non-atomic IDE
* transfers).

EXCHDATA  MOVE.L    PKT_BUFF(A0),D0               Is there a buffer reserved ?
          BNE.S     EXGDATA1                      Yes, so jump over...
          CLR.L     PKT_BUFLN(A0)                 Clear this, just in case...
EXGDATA1  MOVEA.L   D0,A1                         Buffer address.
          MOVE.L    PKT_DDONE(A0),D2              Number of bytes transfered.
          MOVE.L    PKT_BUFLN(A0),D3              Buffer length.
          MOVE.L    PKT_SKIP(A0),D4               Nb of leading bytes to skip.

* Wait for BSY=0 and DRQ=1... and check for error as well !

EXGDATA2  BSR       DELAY                         Wait for 400 ns.
          BSR       READASTAT                     Read and save status.
          BTST      #IDE..BUSY,D0                 Controller still busy ?
          BNE.S     EXGDATA2                      Yes, so wait again...
          BTST      #IDE..ERR,D0                  Was there an error ?
          BNE       ATAABORT                      Yes, so abort now...
          BTST      #IDE..DRQ,D0                  Is data exchange pending ?
          BNE.S     EXGDATA3                      If yes, exchange data...
          BSET      #PKT..DXCH,PKT_FLAGS(A0)      All data exchanged.
          BRA       ATAPIOK                       Packet command completed...

* We now must find how many bytes the drive is ready to transfer:

EXGDATA3  MOVEQ     #0,D1                         Clear MS word.
          MOVE.B    IDE_HCYL(A2),D1               Get the MSB of bytes to xfr.
          LSL.W     #8,D1                         Make it MSB in D1.
          MOVE.B    IDE_LCYL(A2),D1               Get the LSB of bytes to xfr.
          TST.L     D1                            Is actually any data waiting ?
          BEQ       ATAPIOK                       No, so exchange is over...

* Prepare buffer pointer, check for the transfer direction and branch to proper
* routine:

          LEA       0(A1,D2.L),A4                 Pointer on buffer.
          BTST      #IDE..IO,IDE_NSECT(A2)        Send data ?
          BEQ.S     SENDDATA                      Yes, jump to routine then...

* Get data from the drive:

GETDATA   MOVE.W    IDE_DATA(A2),D0               Get one word.
          SUBQ.L    #2,D1                         Two less bytes to get.
          TST.L     D4                            Should we skip leading bytes ?
          BGT.S     GETDATA2                      Yes, so skip MSB...
          CMP.L     D2,D3                         Room available in buffer ?
          BLE.S     GETDATA1                      No more room, don't store !
          MOVE.B    D0,(A4)+                      Store the MSB into the buffer.
          ADDQ.L    #1,D2                         Increment stored byte count.
          CMP.L     D2,D3                         Room available in buffer ?
          BLE.S     GETDATA1                      No, so don't store...
GETDATA3  LSR.W     #8,D0                         Get LSB.
          MOVE.B    D0,(A4)+                      Store LSB.
          ADDQ.L    #1,D2                         Increment stored byte count.
GETDATA1  TST.L     D1                            Is any data awaiting ?
          BGT.S     GETDATA                       Yes, so get next word...
          MOVE.L    D2,PKT_DDONE(A0)              Save total nb of bytes got.
          MOVE.L    D4,PKT_SKIP(A0)               Save nb of bytes left to skip.
          BRA.S     EXGDATA2                      Go get next data chunk...
GETDATA2  SUBQ.L    #1,D4                         One byte skipped, still skip ?
          BEQ.S     GETDATA3                      No, so store LSB...
          SUBQ.L    #1,D4                         Yes, one more skipped then...
          BRA.S     GETDATA1                      Check for awaiting data.

* Send data to the drive:

SENDDATA  MOVEQ     #0,D0                         Data if buffer overflowed.
          CMP.L     D2,D3                         Is there still data in buff ?
          BLE.S     SENDDATA1                     No, so jump over...
          ADDQ.L    #2,D2                         Increment relative pointer.
          MOVE.W    (A4)+,D0                      Get one word.
          ROL.W     #8,D0                         Swap bytes.
SENDDATA1 MOVE.W    D0,IDE_DATA(A2)               Send the word to IDE I/F.
          SUBQ.L    #2,D1                         Decrement counter.
          BGT.S     SENDDATA                      If more to send, loop...
          MOVE.L    D2,PKT_DDONE(A0)              Save total nb of bytes sent.
          BRA       EXGDATA2                      Go send next data chunk...

* In case something goes wrong we must abort the ATAPI command, report an error
* and remove the packet from the queue...

* This is the first case: an error occured while the ATA protocol took place
* (may be a timeout, an undefined drive, or anything unrelated to the ATAPI
* command itself).

ATAERROR  BSET      #PKT..AERR,PKT_FLAGS(A0)      Set the ATA error bit.
          BRA.S     ATAPIOK                       Do post-processing & unlink.

* When an error occured after the ATAPI packet was sent, we must perform a
* request sense command so we can get more details about what gone wrong...

ATAABORT  CMPI.B    #3,PKT_DATA(A0)               Was it a REQUEST SENSE cmd ?
          BEQ.S     ATAPIOK                       Yes, so don't redo it.
ATABORT1  MOVE.W    PKT_STATS(A0),PKT_SAVE1(A0)   Save current status/error.
          MOVE.L    #$03000000,PKT_DATA(A0)       Perform a request sense cmd.
          MOVE.L    #$12000000,PKT_DATA+4(A0)     18 bytes max please !
          CLR.L     PKT_DATA+8(A0)                | Clear remaining packet
          CLR.L     PKT_DATA+12(A0)               |  data.
          BCLR      #PKT..SENT,PKT_FLAGS(A0)      Clear sent flag.
          BCLR      #PKT..COMP,PKT_FLAGS(A0)      Clear command completed flag.
          LEA       PKT_DATA(A0),A4               Addr for returned sense data.
          MOVE.L    A4,PKT_BUFF(A0)               Store it into the header.
          MOVEQ     #18,D0                        Buffer length.
          MOVE.L    D0,PKT_BUFLN(A0)              Store it into the header.
          MOVE.W    D7,SR                         Allow level 2 interrupts.
          RTS                                     Return.

* Save possible error code, set the "packet command completed" flag, call the
* eventual post-processing routine, and remove the packet from the queue:

ATAPIOK   MOVE.W    D7,SR                         Allow level 2 interrupts.
          TST.W     PKT_SAVE1(A0)                 Test save area for status/err.
          BEQ.S     ATAPIOK1                      If nothing saved, jump over...
          MOVE.W    PKT_SAVE1(A0),PKT_STATS(A0)   Restore saved status/error.
          BRA.S     ATAPIOK2                      And jump over...
ATAPIOK1  MOVE.B    IDE_ERROR(A2),PKT_ERROR(A0)   Save error byte in pkt header.
ATAPIOK2  MOVE.L    PKT_POSTP(A0),D0              Is there any post-processing ?
          BEQ.S     ATAPIOK3                      No, so jump over...
          MOVEA.L   D0,A4                         | Call the post-processing
          JSR       (A4)                          |  routine.
ATAPIOK3  BSET      #PKT..COMP,PKT_FLAGS(A0)      Set "command completed" flag.
          MOVE.L    (A0),ATP_PKTQL(A3)            Unlink this packet from queue.
          BTST      #PKT..TRNS,PKT_FLAGS(A0)      Is it a transient packet ?
          BNE.S     ATARMEM                       If yes, then free memory.
          RTS                                     Return.

* This routine frees the memory allocated for the transient packet (this is only
* suitable for auto-cleaning transient packets for which a result/error report
* is not needed: these packets should have been allocated by the ATAPI thing
* only !).

ATARMEM   SUBQ.L    #4,A0                         Point to the block base addr.
          MOVE.L    A6,-(SP)                      Save context.
          MOVEA.W   $C2,A4                        | Release space.
          JSR       (A4)                          |
          MOVEA.L   (SP)+,A6                      Restore context.
          RTS                                     Return.

* Sub-routine for reading the IDE status and saving it into the packet header.
* Note that ATA protocol sometimes recommends reading (and ignoring) the
* alternate status bytes BEFORE the main status byte (so that the later one
* has the time to settle), in these cases READASTAT is called instead of
* READSTATS...

READASTAT MOVE.B    IDE_ASTAT(A2),D0              Read alt. status and ignore.
READSTATS MOVE.B    IDE_STATS(A2),D0              Read IDE status.
          MOVE.B    D0,PKT_STATS(A0)              Store it into the pkt header.
          RTS                                     Return.

* The controller should change status bits within 400 ns after a command is
* received or completed. This delay routine is there to let it do so...
*
* ===> TO DO: we will need to calibrate the loop so that it adapts itself to
*             the processor speed (to be done when the device driver is initia-
*             lized, and proper loop count to be stored into the device driver
*             linkage block...).

DELAY     MOVE.W    #100,D0                       | Delay loop.
DELAY1    DBRA      D0,DELAY1                     |
          RTS                                     Return.

********************************************************************************
* Other low level ATA/ATAPI routines:

* 'IDEN': IDENtify device routine (performed before issuing the first ATAPI
* command on a given drive, so to ensure it is actually an ATAPI drive).
*
* Input parameters  : D1.B = drive number.
*                     A2.L = thing linkage block address.
* Output parameters : D0.L = error code.
*                     D1.L = MSW: general configuration, LSW: capabilities.
* Modified registers: D0, D1.
*
* NOTE: this routine MUST be called in user mode only !

IDENTDEV  MOVEM.L   D2-D4/A1/A3,-(SP)             Save context.
          ANDI.W    #PKT..DRIV,D1                 Drive number is >0 and <8.
          LEA       ATP_PKQL1(A2),A3              Ptr to 1st IDE controller blk.
          MOVEQ     #$F0,D2                       Slave select for IDE_CURRT.
          MOVEQ     #ATP_SCONF,D3                 Offset for slave IDE config.
          BCLR      #0,D1                         Make the drive number even.
          BNE.S     IDENTDEV1                     If it was odd, jump over...
          MOVEQ     #$E0,D2                       Master select for IDE_CURRT.
          MOVEQ     #ATP_MCONF,D3                 Offset for master IDE config.
IDENTDEV1 MOVE.W    D1,D0                         Copy drive number.
          MULU      #(ATP_PKQL2-ATP_PKQL1)>>1,D0  Offset to IDE controllers blk.
          ADDA.W    D0,A3                         Ptr on proper IDE ctrl block.
          LSL.W     #1,D1                         Make drive number an index.
          LEA       IDE_CTRLB,A1                  Base of IDE ctrl addr table.
          MOVEA.L   0(A1,D1.W),A1                 IDE controller registers addr.
          MOVE.L    A1,ATP_REGBS(A3)              Store it into IDE ctrl block.
          MOVEQ     #50,D1                        Setup timeout counter.
          TRAP      #0                            Go supervisor !
IDENTDEV2 ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
          BSR       DELAY                         Wait for 400ns.
          TRAP      #0                            Go supervisor !
          ORI.W     #$0300,SR                     Level 2 interrrupts forbidden.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,IDENTDEV2                  No, wait some more...
          TST.W     D1                            Timed out ?
          BPL.S     IDENTDEV3                     No, so jump and continue...
IDENTDEV5 ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
          ST        2(A3,D3.L)                    Mark drive as unidentified.
          MOVEM.L   (SP)+,D2-D4/A1/A3             Restore context.
          MOVEQ     #-16,D0                       "bad medium" error code.
          RTS                                     Return.
IDENTDV12 MOVE.B    D4,IDE_CURRT(A1)              Re-select old drive/head.
          BRA.S     IDENTDEV5                     Restore context and return.
IDENTDEV3 MOVE.B    IDE_CURRT(A1),D4              Save current drive/head.
          MOVE.B    D2,IDE_CURRT(A1)              Select the proper drive.
          MOVEQ     #100,D1                       Setup timeout counter.
IDENTDEV4 BSR       DELAY                         Wait for 400ns.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,IDENTDEV4                  If no, wait some more...
          TST.W     D1                            Timed out ?
          BMI.S     IDENTDV12                     If yes, abort !
          MOVE.B    IDE_CURRT(A1),D0              Get selected drive number.
          EOR.B     D2,D0                         | Do we agree on the drive
          BTST      #4,D0                         |  actually selected ?
          BNE.S     IDENTDV12                     No, so return with error...
          MOVE.B    #$EC,IDE_CMD(A1)              ATA identify drive command.
          MOVE.W    #32000,D1                     Setup timeout counter.
IDENTDEV9 BSR       DELAY                         Wait for 400ns.
          BTST      #IDE..BUSY,IDE_STATS(A1)      Is the controller ready ?
          DBEQ      D1,IDENTDEV9                  If no, wait some more...
          TST.W     D1                            Timed out ?
          BMI.S     IDENTDV12                     If yes, abort !
          MOVE.B    IDE_HCYL(A1),D0               Get signature MS byte.
          LSL.W     #8,D0                         Make room for LSB.
          MOVE.B    IDE_LCYL(A1),D0               Get signature LS byte.
          CMPI.W    #$EB14,D0                     ATAPI signature ?
          BEQ.S     IDENTDV10                     If yes, jump over...
          MOVE.W    #255,D2                       256 words to fetch.
IDENTDV11 MOVE.W    IDE_DATA(A1),D0               Fetch one word.
          MOVE.B    IDE_STATS(A1),D0              Fake (used as a small delay).
          DBRA      D2,IDENTDV11                  Fetch next words.
          BSR       DELAY                         Wait a bit.
          MOVE.B    IDE_STATS(A1),D0              Clear any pending interrupt.
          BRA.S     IDENTDV12                     Return with error.
IDENTDV10 MOVE.B    #IDE.NIEN,IDE_CTRL(A1)        Disable interrupts from drive.
          CLR.B     IDE_FEATR(A1)                 Features: no overlap, no DMA.
          MOVE.B    #$FE,IDE_LCYL(A1)             | Max supported transfer
          MOVE.B    #$FF,IDE_HCYL(A1)             |  length.
          MOVE.B    #$A1,IDE_CMD(A1)              Identify ATAPI device opcode.
          MOVE.W    #32000,D1                     Maximum number of wait loops.
IDENTDEV6 BSR       DELAY                         Wait for 400 ns.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Mask BUSY and DRQ bits.
          SUBQ.B    #IDE.DRQ,D0                   Is DRQ=1 and BUSY=0 ?
          DBEQ      D1,IDENTDEV6                  If no, wait some more...
          TST.W     D1                            Timeout waiting for DRQ ?
          BMI       IDENTDV12                     If yes, then abort !
          MOVE.W    IDE_DATA(A1),D1               Get general configuration.
          ROL.W     #8,D1                         Swap bytes.
          SWAP      D1                            Save it in MS word.
          MOVEQ     #48,D2                        Ignore next 48 words.
IDENTDEV7 MOVE.W    IDE_DATA(A1),D1               Get next word.
          DBRA      D2,IDENTDEV7                  And wait for the 50th.
          ROL.W     #8,D1                         Reorder the capability word.
          MOVE.W    #206,D2                       |
IDENTDEV8 MOVE.W    IDE_DATA(A1),D0               | Ignore remaining words...
          DBRA      D2,IDENTDEV8                  |
          MOVE.L    D1,0(A3,D3.L)                 Save CONF and CAPA words.
          SF        2(A3,D3.L)                    Mark drive as identified.
          ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
          MOVEM.L   (SP)+,D2-D4/A1/A3             Restore context.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

* 'RSET': Drive ATAPI software reset routine:
*
* Input parameters  : D1.B = drive number.
*                     A2.L = thing linkage block address.
* Output parameters : D0.L = error code.
* Modified registers: D0.
*
* NOTE: this routine MUST be called in user mode only !

RESETDEV  MOVEM.L   D1-D3/A1/A3,-(SP)             Save context.
          LEA       ATP_PKQL1(A2),A3              Ptr to 1st IDE controller blk.
          MOVEQ     #$F0,D2                       Slave select for IDE_CURRT.
          MOVEQ     #ATP_SCONF,D3                 Offset for slave IDE config.
          ANDI.W    #PKT..DRIV,D1                 Drive number is >0 and <8.
          BCLR      #0,D1                         Make the drive number even.
          BNE.S     RESETDEV1                     If it was odd, jump over...
          MOVEQ     #$E0,D2                       Master select for IDE_CURRT.
          MOVEQ     #ATP_MCONF,D3                 Offset for master IDE config.
RESETDEV1 MULU      #(ATP_PKQL2-ATP_PKQL1)>>1,D1  Offset to IDE controllers blk.
          ADDA.W    D1,A3                         Ptr on proper IDE ctrl block.
          LEA       MSGUNINIT,A1                  "Uninitialized drive" msg add.
          MOVE.L    A1,D0                         | Make it an error code.
          BSET      #31,D0                        |
          TST.B     2(A3,D3.L)                    Was the drive identified ?
          BNE.S     RESETDEV2                     If no, then return with error.
          MOVEA.L   ATP_REGBS(A3),A1              IDE controller registers addr.
          MOVEQ     #50,D1                        Setup timeout counter.
          TRAP      #0                            Go supervisor !
RESETDEV3 ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
          BSR       DELAY                         Wait for 400ns.
          TRAP      #0                            Go supervisor !
          ORI.W     #$0300,SR                     Level 2 interrrupts forbidden.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,RESETDEV3                  If no, wait some more...
          TST.W     D1                            Timed out ?
          BPL.S     RESETDEV4                     No, so jump and continue...
RESETDEV7 LEA       MSGATAERR,A1                  "ATA error" message address.
          MOVE.L    A1,D0                         | Make it an error code.
          BSET      #31,D0                        |
RESETDEV8 ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
RESETDEV2 MOVEM.L   (SP)+,D1-D3/A1/A3             Restore context.
          TST.L     D0                            Set CCR according to error.
          RTS                                     Return.
RESETDEV4 MOVE.B    D2,IDE_CURRT(A1)              Select the proper drive.
          MOVEQ     #100,D1                       Setup timeout counter.
RESETDEV5 BSR       DELAY                         Wait for 400ns.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,RESETDEV5                  No, wait some more...
          MOVE.B    #$08,IDE_CMD(A1)              ATAPI soft reset command.
          MOVE.W    #32760,D1                     Maximum number of wait loops.
RESETDEV6 BSR       DELAY                         Wait for 400 ns.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,RESETDEV6                  If no, wait some more...
          TST.W     D1                            Timed out ?
          BMI.S     RESETDEV7                     If yes, then return with err.
          MOVEQ     #0,D0                         No error.
          BRA.S     RESETDEV8                     Restore context and return.

* 'FEAT': set/clear drive FEATures:
*
* Input parameters  : D1.B = drive number.
*                     D3.W = bit 0-6: feature number, bit 7: 1=set, 0=clear.
*                            If bit 0-7=$03 then bit 8-15=transfer mode.
*                     A2.L = thing linkage block address.
* Output parameters : D0.L = error code.
* Modified registers: D0.
*
* NOTE: this routine MUST be called in user mode only !

SETFEATUR MOVEM.L   D1-D4/A1/A3,-(SP)             Save context.
          MOVE.W    D3,D4                         Copy IDE_FEATR byte.
          SWAP      D4                            Save it in MSW.
          MOVE.B    #$EF,D4                       ATA set feature command.
          BRA.S     ATACMD                        Perform ATA command.

* 'SLEP': order the drive to enter SLEeP mode:
*
* Input parameters  : D1.B = drive number.
*                     A2.L = thing linkage block address.
* Output parameters : D0.L = error code.
* Modified registers: D0.
*
* NOTE: this routine MUST be called in user mode only !

SLEEPDRV  MOVEM.L   D1-D4/A1/A3,-(SP)             Save context.
          MOVE.L    #$E6,D4                       ATA sleep command.
          BRA.S     ATACMD                        Perform ATA command.

* 'STBY': order the drive to enter STandBY mode:
*
* Input parameters  : D1.B = drive number.
*                     A2.L = thing linkage block address.
* Output parameters : D0.L = error code.
* Modified registers: D0.
*
* NOTE: this routine MUST be called in user mode only !

STBYDRV   MOVEM.L   D1-D4/A1/A3,-(SP)             Save context.
          MOVE.L    #$E0,D4                       ATA stanby command.

ATACMD    LEA       ATP_PKQL1(A2),A3              Ptr to 1st IDE controller blk.
          MOVEQ     #$F0,D2                       Slave select for IDE_CURRT.
          MOVEQ     #ATP_SCONF,D3                 Offset for slave IDE config.
          ANDI.W    #PKT..DRIV,D1                 Drive number is >0 and <8.
          BCLR      #0,D1                         Make the drive number even.
          BNE.S     ATACMD1                       If it was odd, jump over...
          MOVEQ     #$E0,D2                       Master select for IDE_CURRT.
          MOVEQ     #ATP_MCONF,D3                 Offset for master IDE config.
ATACMD1   MULU      #(ATP_PKQL2-ATP_PKQL1)>>1,D1  Offset to IDE controllers blk.
          ADDA.W    D1,A3                         Ptr on proper IDE ctrl block.
          LEA       MSGUNINIT,A1                  "Uninitialized drive" msg add.
          MOVE.L    A1,D0                         | Make it an error code.
          BSET      #31,D0                        |
          TST.B     2(A3,D3.L)                    Was the drive identified ?
          BNE.S     ATACMD2                       If no, then return with error.
          MOVEA.L   ATP_REGBS(A3),A1              IDE controller registers addr.
          MOVEQ     #50,D1                        Setup timeout counter.
          TRAP      #0                            Go supervisor !
ATACMD3   ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
          BSR       DELAY                         Wait for 400ns.
          TRAP      #0                            Go supervisor !
          ORI.W     #$0300,SR                     Level 2 interrrupts forbidden.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,ATACMD3                    If no, wait some more...
          TST.W     D1                            Timed out ?
          BPL.S     ATACMD4                       No, so jump and continue...
ATACMD7   LEA       MSGATAERR,A1                  "ATA error" message address.
          MOVE.L    A1,D0                         | Make it an error code.
          BSET      #31,D0                        |
ATACMD8   ANDI.W    #$D8FF,SR                     User mode, interrupts allowed.
ATACMD2   MOVEM.L   (SP)+,D1-D4/A1/A3             Restore context.
          TST.L     D0                            Set CCR according to error.
          RTS                                     Return.
ATACMD4   MOVE.B    D2,IDE_CURRT(A1)              Select the proper drive.
          MOVEQ     #100,D1                       Setup timeout counter.
ATACMD5   BSR       DELAY                         Wait for 400ns.
          MOVE.B    IDE_STATS(A1),D0              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D0          Is the controller ready ?
          DBEQ      D1,ATACMD5                    If no, wait some more...
          TST.W     D1                            Timed out ?
          BMI.S     ATACMD4                       If yes, return with error.
          SWAP      D4                            Possible feature in LSW.
          TST.W     D4                            Any feature there ?
          BEQ.S     ATACMD9                       If no, then jump over...
          MOVE.B    D4,IDE_FEATR(A1)              Feature to set or clear.
          CMPI.B    #3,D4                         Is this "set transfer mode" ?
          BNE.S     ATACMD9                       If no, then jump over...
          LSR.W     #8,D4                         Put transfer mode in LSB.
          MOVE.B    D4,IDE_NSECT(A1)              Send transfer mode code.
ATACMD9   SWAP      D4                            Get back ATA opcode in LSW.
          MOVE.B    D4,IDE_CMD(A1)                Send the ATA command.
          MOVE.W    #32760,D1                     Maximum number of wait loops.
ATACMD6   BSR       DELAY                         Wait for 400 ns.
          MOVE.B    IDE_STATS(A1),D2              Read IDE status.
          ANDI.B    #IDE.BUSY+IDE.DRQ,D2          Is the controller ready ?
          DBEQ      D1,ATACMD6                    If no, wait some more...
          CMPI.B    #$E6,D4                       Sleep command ?
          BEQ.S     ATACMD10                      If yes, ignore timeout/error.
          TST.W     D1                            Timed out ?
          BMI.S     ATACMD7                       If yes, then return with err.
          MOVEQ     #-1,D0                        "not complete" error code.
          BTST      #IDE..ERR,D2                  Was there an error ?
          BNE.S     ATACMD8                       If yes, return with error.
ATACMD10  MOVEQ     #0,D0                         No error.
          BRA.S     ATACMD8                       Restore context and return.

********************************************************************************
* Utility extensions:

* 'ATPK': Allocate Transient PacKet routine:
*
* Input parameters  :  A6.L = system variables address.
* Output parameters :  A0.L = transient packet address.
* Modified registers:  D0, A0.
*
* NOTE: this routine MUST be called in supervisor mode only.

TRANSIENT MOVEM.L   D1-D3/A1-A3/A6,-(SP)          Save context.
          MOVEQ     #PKT_LENGT+4,D1               Size for a transient packet.
          MOVEA.W   $C0,A3                        | Allocate space in common
          JSR       (A3)                          |  heap.
          MOVEM.L   (SP)+,D1-D3/A1-A3/A6          Restore context.
          BNE.S     TRANSNT1                      If error, return.
          ADDQ.L    #4,A0                         Room for link.
          BSET      #PKT..TRNS,PKT_FLAGS(A0)      Set the transient flag.
          MOVEQ     #0,D0                         No error.
TRANSNT1  RTS                                     Return.

* 'ANPK': Allocate "Normal" PacKet routine:
*
* Input parameters  :  none.
* Output parameters :  D0.L = error code.
*                      A0.L = base address of packet header.
* Modified registers:  D0.
*
* NOTE: This routine MUST be called in user mode only.

RESERVPKT MOVEM.L   D1-D3/A1-A3,-(SP)             Save context (1)
          MOVEQ     #PKT_LENGT,D1                 Length of packet header+data.
          MOVEQ     #-1,D2                        Owner = current (calling) job.
          MOVEQ     #$18,D0                       | Reserve space on the common
          TRAP      #1                            |  heap.
          TST.L     D0                            Error ?
          BNE.S     RESRVPKT1                     If yes, return now.
          MOVEA.L   A0,A1                         Copy of reserved space addr.
          MOVEQ     #PKT_LENGT>>1-1,D1            Number of words to clear - 1.
RESRVPKT2 CLR.W     (A1)+                         Clear 1 word.
          DBRA      D1,RESRVPKT2                  Clear the whole area.
RESRVPKT1 MOVEM.L   (SP)+,D1-D3/A1-A3             Restore context (1)
          TST.L     D0                            Set CCR depending on error.
          RTS                                     Return.

* 'WPCC': Wait for Packet Command Completion routine.
*
* Input parameters  :  A0.L = packet header base address.
* Output parameters :  D0.L = error code.
* Modified registers:  D0.
*
* NOTE: this routine may be called both in user or supervisor mode. In user
*       mode, it suspends the calling job until the ATAPI packet command is
*       completed, while, in supervisor mode, it returns immediately (with a
*       "not complete" error code if the ATAPI command is not completed).

WAITCOMP  MOVE.W    SR,D0                         Get 680x0 status register.
          BTST      #13,D0                        Supervisor mode in force ?
          BNE.S     WAITCOMP3                     If yes, jump to proper code.
          MOVEM.L   D1-D3/A0/A1/A4,-(SP)          Save context.
          MOVEA.L   A0,A4                         Save packet base address.
          SUBA.L    A1,A1                         No flag to clear on release.
WAITCOMP1 MOVEQ     #1,D3                         |
          MOVEQ     #-1,D1                        | Suspend the current job
          MOVEQ     #8,D0                         |  for 1/50s (at least).
          TRAP      #1                            |
          BTST      #PKT..COMP,PKT_FLAGS(A4)      Is the packet processing over?
          BEQ.S     WAITCOMP1                     If no, wait...
          LEA       MSGATAERR,A0                  "ATA error" message address.
          MOVE.L    A0,D0                         | Make it an error code.
          BSET      #31,D0                        |
          BTST      #PKT..AERR,PKT_FLAGS(A4)      Was there an ATA error ?
          BNE.S     WAITCOMP2                     If yes, return now.
          MOVEQ     #0,D0                         No error.
          BTST      #IDE..ERR,PKT_STATS(A4)       Was there an ATAPI error ?
          BEQ.S     WAITCOMP2                     If no, deallocate & return.
          LEA       PKT_DATA(A4),A0               Pointer on sense data.
          BSR       DECODESNS                     Decode sense data.
WAITCOMP2 MOVEM.L   (SP)+,D1-D3/A0/A1/A4          Restore context.
          TST.L     D0                            Set CCR according to err code.
          RTS                                     Return.
WAITCOMP3 MOVEM.L   A0/A4,-(SP)                   Save context.
          MOVEA.L   A0,A4                         Save packet base address.
          MOVEQ     #-1,D0                        "not complete" error code.
          BTST      #PKT..COMP,PKT_FLAGS(A4)      Is the packet processing over?
          BEQ.S     WAITCOMP4                     If no, return with error.
          LEA       MSGATAERR,A0                  "ATA error" message address.
          MOVE.L    A0,D0                         | Make it an error code.
          BSET      #31,D0                        |
          BTST      #PKT..AERR,PKT_FLAGS(A4)      Was there an ATA error ?
          BNE.S     WAITCOMP4                     If yes, return now.
          MOVEQ     #0,D0                         No error.
          BTST      #IDE..ERR,PKT_STATS(A4)       Was there an ATAPI error ?
          BEQ.S     WAITCOMP4                     If no, deallocate & return.
          LEA       PKT_DATA(A4),A0               Pointer on sense data.
          BSR       DECODESNS                     Decode sense data.
WAITCOMP4 MOVEM.L   (SP)+,A0/A4                   Restore context.
          TST.L     D0                            Set CCR according to err code.
          RTS                                     Return.

* 'QPKT': Queue PacKeT routine:
*
* Input parameters  :  D1.B = IDE drive number (0 to 7).
*                      A0.L = packet header address.
*                      A2.L = thing linkage block address.
* Output parameters :  none.
* Modified registers:  D0.
*
* NOTE: this routine may be called from both user or supervisor mode.

QUEUE     MOVEM.L   D1/A1,-(SP)                   Save context.
          MOVE.W    SR,D0                         Save status register.
          TRAP      #0                            Go supervisor.
          ORI.W     #$0300,SR                     Prevent level 2 interrupts.
          ANDI.W    #PKT..DRIV,D1                 Drive number is >0 and <8.
          MOVE.B    D1,PKT_DRIVE(A0)              Store drive number in pkt hdr.
          LSR.W     #1,D1                         Ignore LS bit of drive number.
          MULU      #ATP_PKQL2-ATP_PKQL1,D1       Make D1 and index on IDE blk.
          LEA       ATP_PKQL1(A2,D1.W),A1         Packet queue link address.
QUEUE1    MOVE.L    (A1),D1                       Get next packet address.
          BEQ.S     QUEUE2                        No more packet !
          MOVEA.L   D1,A1                         Next packet link address.
          BRA.S     QUEUE1                        Continue to search last pkt.
QUEUE2    MOVE.L    A0,(A1)                       Link in our new packet.
          MOVE.W    D0,SR                         Restore run level.
          MOVEM.L   (SP)+,D1/A1                   Restore context.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

* 'UQPK': UnQueue PacKet routine:
*
* Input parameters  :  D1.B = 1 for forced dequeueing.
*                      A0.L = packet header address.
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code (0=OK, -7=not found, -9=in use).
* Modified registers:  D0, D1, D2, A1.
*
* NOTE: this routine may be called from both user or supervisor mode.

UNQUEUE   MOVE.W    SR,D2                         Save status register.
          TRAP      #0                            Go supervisor if not already.
          ORI.W     #$0300,SR                     Prevent level 2 interrupts.
          CMPI.B    #1,D1                         Forced de-queing ?
          BEQ.S     UNQUEUE3                      If yes, jump over...
          MOVEQ     #-9,D0                        "in use" error code.
          MOVE.B    PKT_FLAGS(A0),D1              Get the packet flags.
          BTST      #PKT..SENT,D1                 Was the packet command sent ?
          BEQ.S     UNQUEUE3                      If no, remove packet.
          BTST      #PKT..COMP,D1                 Was the command completed ?
          BNE.S     UNQUEUE3                      If yes, remove packet
UNQUEUE4  MOVE.W    D2,SR                         Restore interrupts+runlevel.
          TST.L     D0                            Set CCR following error code.
          RTS                                     Return.
UNQUEUE3  MOVEQ     #-7,D0                        "not found" error code.
          MOVEQ     #0,D1                         Clear MS bytes.
          MOVE.B    PKT_DRIVE(A0),D1              Get the related drive number.
          LSR.W     #1,D1                         Ignore LS bit.
          MULU      #ATP_PKQL2-ATP_PKQL1,D1       Offset to IDE ctrl block.
          LEA       ATP_PKQL1(A2,D1.W),A1         Packet queue link address.
UNQUEUE1  MOVE.L    (A1),D1                       Get next packet address.
          BEQ.S     UNQUEUE4                      No more packet !
          CMP.L     A0,D1                         Is this our packet ?
          BEQ.S     UNQUEUE2                      Yes, so unlink it...
          MOVEA.L   D1,A1                         Next packet link address.
          BRA.S     UNQUEUE1                      Continue to search our packet.
UNQUEUE2  MOVE.L    (A0),(A1)                     Unlink our packet.
          BTST      #PKT..TRNS,PKT_FLAGS(A0)      Was it a transient packet ?
          BEQ.S     UNQUEUE5                      No, so jump over...
          MOVEM.L   D2/D3/A0/A2/A3/A6,-(SP)       Save context.
          SUBQ.L    #4,A0                         Actual start of packet block.
          MOVEA.L   A0,A1                         Save packet base address.
          MOVEQ     #0,D0                         | Get system variables base
          TRAP      #1                            |  address.
          MOVEA.L   A0,A6                         Set A6 as system vars pointer.
          MOVEA.L   A1,A0                         Restore packet base address.
          MOVEA.W   $C2,A3                        | Release common heap space.
          JSR       (A3)                          |
          MOVEM.L   (SP)+,D2/D3/A0/A2/A3/A6       Restore context.
UNQUEUE5  MOVE.W    D2,SR                         Restore interrupts+runlevel.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

* 'DSNS': Decode SeNSe data routine:
*
* Input parameters  :  A0.L = pointer on REQUEST SENSE returned data
*                      A2.L = thing linkage block address.
* Output parameters :  D0.L = error code (bit 31 set and ptr on error message).
* Modified registers:  D0.

DECODESNS MOVEM.L   D1/D2/A1/A2,-(SP)             Save context.
          LEA       MSGUNKN,A1                    Ptr on unknown error message.
          MOVE.L    A1,D0                         Store it as default message.
          MOVE.W    12(A0),D1                     Get ASC (MSB) and ASCQ (LSB).
          MOVE.B    12(A0),D2                     Get ASC.
          CMPI.B    #$40,D2                       ASC = $40 ?
          BNE.S     DECODSNS4                     No, so jump over...
          ANDI.W    #$FF00,D1                     Mask ASCQ (component number).
DECODSNS4 LEA       SENSE_TBL,A1                  Sense table pointer.
          MOVEA.L   A1,A2                         Copy pointer.
DECODSNS1 MOVE.W    (A2)+,D2                      Get ASC/ASCQ couple from tbl.
          CMPI.W    #-1,D2                        End of table reached ?
          BEQ.S     DECODSNS3                     If yes, return unknow error...
          CMP.W     D2,D1                         Compare with our values.
          BEQ.S     DECODSNS2                     If equal we found it !
          BMI.S     DECODSNS3                     If we gone too far, abort...
          ADDQ.L    #2,A2                         Point on next table entry.
          BRA.S     DECODSNS1                     Continue to scan the table.
DECODSNS2 MOVE.W    (A2),D2                       Relative pointer on message.
          LEA       0(A1,D2.W),A2                 Absolute pointer on message.
          MOVE.L    A2,D0                         Store the message pointer.
DECODSNS3 BSET      #31,D0                        Make D0 an error code.
          MOVEM.L   (SP)+,D1/D2/A1/A2             Restore context.
          RTS                                     Return.

* 'ZPKT': Zero PacKeT bloc routine:
*
* Input parameters  :  A0.L = pointer on packet.
*                      A2.L = thing linkage block address.
* Output parameters :  none.
* Modified registers:  none.

PKTZERO   MOVEM.L   D0/A0,-(SP)                   Save context.
          MOVEQ     #PKT_LENGT>>1-1,D0            DBRA counter.
PKTZERO1  CLR.W     (A0)+                         Clear one word.
          DBRA      D0,PKTZERO1                   CLear whole packet block.
          MOVEM.L   (SP)+,D0/A0                   Restore context.
          RTS                                     Return.

********************************************************************************
* SBASIC PROCedures and FuNctions:

* Sub-routine to use the "ATAPI" thing:

USE_ATAPI MOVEM.L   D1/D3/A0,-(SP)                Save context.
          BSR       SEARCH                        Get the THING vector.
          BNE.S     USEATAPI1                     If error then return.
          LEA       ATPNAME,A0                    Name of the thing to use.
          MOVEQ     #-1,D1                        User = calling job.
          MOVEQ     #-1,D3                        Infinite timeout.
          MOVEQ     #$28,D0                       | Use the CDROM thing.
          JSR       (A4)                          |
USEATAPI1 MOVEM.L   (SP)+,D1/D3/A0                Restore context.
          TST.L     D0                            Set CCR according to error.
          RTS                                     Return.
          
* Common end routine used to call the ATAPI extension thing:
*
* Input parameters  :  D1.L = parameter.
*                      D2.L = extension Id.
*                      D3.L = parameter.
* Output parameters :  D0.L = error code.

CALL_EXT  BSR.S     USE_ATAPI                     Use the "CDROM" thing.
          BNE.S     CALL_EXT1                     If error then return.
          JSR       $18(A1)                       Call the extension thing.

FRE_ATAPI MOVEM.L   D0/D1/A0/A1,-(SP)             Save context.
          LEA       ATPNAME,A0                    Name of the thing to free.
          MOVEQ     #-1,D1                        User = calling job.
          MOVEQ     #$29,D0                       | Free the CCDROM thing.
          JSR       (A4)                          |
          MOVEM.L   (SP)+,D0/D1/A0/A1             Restore context.
CALL_EXT1 RTS

* ATAPI_IDENT (FN), syntax: DriveFlags=ATAPI_IDENT(Drive_number)

ATAPIDENT MOVEQ     #1,D4                         One parameter awaited.
          BSR       GETWORD                       Get a word integer.
          MOVE.W    0(A6,A1.L),D1                 Get the drive number.
          ADDQ.L    #2,$58(A6)                    Update arithmetic stack ptr.
          MOVE.L    #'IDEN',D2                    Extension name.
          BSR.S     CALL_EXT                      Call the extension.
          MOVEQ     #0,D4                         Default return value.
          TST.L     D0                            Error ?
          BNE.S     ATAPIDEN1                     If yes, return now.
          MOVE.L    D1,D4                         Long integer to return.
ATAPIDEN1 BRA       LITOFP                        Turn long int into a float.

* ATAPI_RESET (PROC), syntax: ATAPI_RESET Drive_number

ATAPIRSET MOVE.L    #'RSET',D2                    Extension name.
          BRA.S     ATAPIPRC1                     1st common PROCedure code.

* ATAPI_SLEEP (PROC), syntax: ATAPI_SLEEP Drive_number

ATAPISLEP MOVE.L    #'SLEP',D2                    Extension name.
          BRA.S     ATAPIPRC1                     1st common PROCedure code.

* ATAPI_STANDBY (PROC), syntax: ATAPI_STANDBY Drive_number

ATAPISTBY MOVE.L    #'STBY',D2                    Extension name.

ATAPIPRC1 MOVEQ     #1,D4                         One parameter awaited.
          BSR       GETWORD                       Get a word integer.
          MOVE.W    0(A6,A1.L),D1                 Get the drive number.
          ADDQ.L    #2,A1                         | Update arithmetic stack
          MOVE.L    A1,$58(A6)                    |  pointer.
          BRA.S     CALL_EXT                      Call the extension.

* ATAPI_FEATURE (PROC), syntax: ATAPY_FEATURE Drive_number,Feature

ATAPIFEAT MOVEQ     #2,D4                         Two parameters awaited.
          BSR       GETWORD                       Get word integers.
          MOVE.W    0(A6,A1.L),D1                 Get the drive number.
          MOVE.W    2(A6,A1.L),D3                 Get the feature to set/clear.
          MOVE.L    #'FEAT',D2                    Extension name.
          BRA       CALL_EXT                      Call the extension.

* ATAPI_ALLOCPKT (FN), syntax: Packet_address=ATAPI_ALLOCPKT

ATAPIAPKT CMPA.L    A3,A5                         Is there any parameters ?
          BNE.S     BADPAR                        If yes, return with error.
          MOVE.L    #'ANPK',D2                    Extension name.
          BSR       CALL_EXT                      Call the extension thing.
          MOVE.L    A0,D4                         Address to return.
          TST.L     D0                            Error ?
          BNE       CALL_EXT1                     If yes, return now.
          BRA       LITOFP                        Return the packet address.

* ATAPI_FREEPKT (PROC), syntax: ATAPI_FREEPKT Packet_address

ATAPIFPKT MOVEQ     #1,D4                         One parameter awaited.
          BSR.S     GETLONG                       Get a long integer.
          MOVE.L    0(A6,A1.L),A0                 ATAPI packet address.
          MOVEQ     #$19,D0                       | Free the memory from the
          TRAP      #1                            |  packet.
          MOVEQ     #0,D0                         No error.
          RTS                                     Return.

* ATAPI_QUEUE (PROC), syntax: ATAPI_QUEUE Packet_address

ATAPIQUEU MOVEQ     #2,D4                         Two parameters awaited.
          BSR.S     GETLONG                       Get a long integer.
          MOVE.L    0(A6,A1.L),D1                 Drive number.
          MOVE.L    4(A6,A1.L),A0                 ATAPI packet address.
          MOVE.L    #'QPKT',D2                    Extension name.
          BRA       CALL_EXT                      Call the extension thing.

* ATAPI_UNQUEUE (PROC), syntax: ATAPI_UNQUEUE Packet_address

ATAPIUNQU MOVEQ     #0,D1                         No forced de-queuing.
          MOVE.L    #'UQPK',D2                    Extension name.
          BRA.S     ATAPIPRC2                     2nd common PROCedure code.

* ATAPI_ZEROPKT (PROC), syntax: ATAPI_ZEROPKT Packet_address

ATAPIZERO MOVE.L    #'ZPKT',D2                    Extension name.

ATAPIPRC2 MOVEQ     #1,D4                         One parameter awaited.
          BSR.S     GETLONG                       Get a long integer.
          MOVE.L    0(A6,A1.L),A0                 ATAPI packet address.
          BRA       CALL_EXT                      Call the extension thing.

* ATAPI_SENSE (FN), syntax: Error=ATAPI_SENSE(Sense_data_address)

ATAPISENS MOVE.L    #'DSNS',D2                    Extension name.
          BRA.S     ATAPIFN1                      Call common FuNction code.

* ATAPI_WAIT (FN), syntax: Error=ATAPI_WAIT(Packet_address)

ATAPIWAIT MOVE.L    #'WPCC',D2                    Extension name.

ATAPIFN1  MOVEQ     #1,D4                         One parameter awaited.
          BSR.S     GETLONG                       Get a long integer.
          MOVE.L    0(A6,A1.L),A0                 ATAPI packet address.
          ADDQ.L    #4,$58(A6)                    Update arithmetic stack ptr.
          BSR       CALL_EXT                      Call the extension thing.
          MOVE.L    D0,D4                         Error code to return.
          BRA.S     LITOFP                        Return error as long integer.

********************************************************************************
* General usage routines:

EXIT      ADDQ.L    #4,SP                         Pop the return address.
          RTS                                     Return to caller of caller...

BADPAR    MOVEQ     #-15,D0                       "bad parameter" error code.
          RTS                                     Return.

* Parameter fetching routines:
*
* Put the number of awaited parameters in D4.W (or 0 if number unknown) and call
* the appropriate routine. In case of error, these routine will return to the
* caller of the caller which is supposed to be SBASIC; if these routine are to
* be called from a SUBROUTINE of a PROC/FN, then call them as follow:
*
*         PEA       EXIT
*         BSR.S     GET....
*         ADDQ.L    #4,SP
*
* No test is needed after a call to these routines (the parameters are OK and in
* good number), unless D4 was set to 0 (in which case a check for the number of
* fetched parameters is needed).

GETWORD   MOVEA.W   $112,A2
          BRA.S     GETPAR
GETSTRG   MOVEA.W   $116,A2
          BRA.S     GETPAR
GETLONG   MOVEA.W   $118,A2
GETPAR    MOVEM.L   D1/D2/D4/D6/A0,-(SP)
          JSR       (A2)
          MOVEM.L   (SP)+,D1/D2/D4/D6/A0
          BNE.S     EXIT
          TST.W     D4
          BEQ.S     GETPAR1
          MOVEQ     #-15,D0
          CMP.W     D3,D4
          BNE.S     EXIT
          MOVEQ     #0,D0
GETPAR1   RTS

* The following routine converts a long integer held into D4 into a floating
* point number which is put onto the arithmetic stack.

LITOFP    MOVEQ     #6,D1
          BSR.S     MSRESV1
          MOVE.L    D4,D1
          CLR.W     0(A6,A1.L)
          TST.L     D1
          BEQ.S     LITOFP2
          MOVE.W    #$820,D2
LITOFP1   SUBQ.W    #1,D2
          ASL.L     #1,D1
          BVC.S     LITOFP1
          ROXR.L    #1,D1
          MOVE.W    D2,0(A6,A1.L)
LITOFP2   MOVE.L    D1,2(A6,A1.L)
LITOFP3   MOVEQ     #2,D4
          MOVEQ     #0,D0
          RTS

* Arithmetic stack space reservation routine.

MSRESV1   MOVEA.L   $58(A6),A1
          BRA.S     MSRESV2
MSRESV    MOVE.L    A1,$58(A6)
MSRESV2   ADDQ.L    #1,D1
          BCLR      #0,D1
          MOVEM.L   D1-D3/A2,-(SP)
          MOVEA.W   $11A,A2
          JSR       (A2)
          MOVEM.L   (SP)+,D1-D3/A2
          MOVEA.L   $58(A6),A1
          SUBA.L    D1,A1
          MOVE.L    A1,$58(A6)
          RTS

* Routine searching for the "THING" vector:
*
* Call parameters   : none.
* ~~~~~~~~~~~~~~~
* Return parameters : A0.L = "THING" thing address (if D0=0)
* ~~~~~~~~~~~~~~~~~   A4.L = "TH_ENTRY" routine address
*                     D0.L = error code (0: no error, -19: not implemented),
*
* Modified registers: D0, A0, A4.
* ~~~~~~~~~~~~~~~~~~

SEARCH    MOVEM.L   D1/D2,-(SP)                   Save the context.
          MOVEQ     #0,D0                         | Get system info (we need
          TRAP      #1                            |  the system variable addr.).
          MOVEQ     #-19,D0                       "Not implemented" error code.
          LEA       $B8(A0),A0                    Things linked list pointer.
          MOVE.L    A0,D1                         Is it zero ?
          BEQ.S     SEARCH3                       If yes, return (no things).
SEARCH1   MOVE.L    (A0),D1                       D1=Thing linkage block addr.
          BEQ.S     SEARCH2                       If last thing then end.
          MOVEA.L   D1,A0                         | Else search for the next
          BRA.S     SEARCH1                       |  thing.
SEARCH2   MOVEA.L   16(A0),A0                     Pointer on the thing header.
          CMPI.L    #'THG%',(A0)                  Is it actually a thing ?
          BNE.S     SEARCH3                       If no then return with error.
          CMPI.L    #-1,4(A0)                     Is it the "THING" thing ?
          BNE.S     SEARCH3                       If no then return with error.
          MOVEA.L   8(A0),A4                      Get the TH_ENTRY vector.
          MOVEQ     #0,D0                         No error.
SEARCH3   MOVEM.L   (SP)+,D1/D2                   Restore the context.
          TST.L     D0                            Set the CCR.
          RTS                                     Return.

********************************************************************************
* Data:

* IDE controllers register address bases:

ISABASE   equ       $FF400000                     Base addr for ISA I/O.

IDE_CTRLB dc.l      ISABASE+$1F0<<2               First IDE controller reg base.
          dc.l      ISABASE+$170<<2               ...
          dc.l      ISABASE+$1E8<<2               ...
          dc.l      ISABASE+$168<<2               Fourth IDE controller...

* Sense error messages:

SENSE_TBL dc.w      $0000,MSG0000-SENSE_TBL
          dc.w      $0011,MSG0011-SENSE_TBL
          dc.w      $0012,MSG0012-SENSE_TBL
          dc.w      $0013,MSG0013-SENSE_TBL
          dc.w      $0014,MSG0014-SENSE_TBL
          dc.w      $0015,MSG0015-SENSE_TBL
          dc.w      $0100,MSG0100-SENSE_TBL
          dc.w      $0200,MSG0200-SENSE_TBL
          dc.w      $0400,MSG0400-SENSE_TBL
          dc.w      $0401,MSG0401-SENSE_TBL
          dc.w      $0402,MSG0402-SENSE_TBL
          dc.w      $0403,MSG0403-SENSE_TBL
          dc.w      $0501,MSG0501-SENSE_TBL
          dc.w      $0600,MSG0600-SENSE_TBL
          dc.w      $0900,MSG0900-SENSE_TBL
          dc.w      $0901,MSG0901-SENSE_TBL
          dc.w      $0902,MSG0902-SENSE_TBL
          dc.w      $0903,MSG0903-SENSE_TBL
          dc.w      $1100,MSG1100-SENSE_TBL
          dc.w      $1106,MSG1106-SENSE_TBL
          dc.w      $1500,MSG1500-SENSE_TBL
          dc.w      $1501,MSG0100-SENSE_TBL
          dc.w      $1502,MSG1502-SENSE_TBL
          dc.w      $1700,MSG1700-SENSE_TBL
          dc.w      $1701,MSG1701-SENSE_TBL
          dc.w      $1702,MSG1702-SENSE_TBL
          dc.w      $1703,MSG1703-SENSE_TBL
          dc.w      $1704,MSG1704-SENSE_TBL
          dc.w      $1705,MSG1705-SENSE_TBL
          dc.w      $1800,MSG1800-SENSE_TBL
          dc.w      $1801,MSG1801-SENSE_TBL
          dc.w      $1802,MSG1802-SENSE_TBL
          dc.w      $1803,MSG1803-SENSE_TBL
          dc.w      $1804,MSG1804-SENSE_TBL
          dc.w      $1A00,MSG1A00-SENSE_TBL
          dc.w      $2000,MSG2000-SENSE_TBL
          dc.w      $2100,MSG2100-SENSE_TBL
          dc.w      $2400,MSG2400-SENSE_TBL
          dc.w      $2600,MSG2600-SENSE_TBL
          dc.w      $2601,MSG2601-SENSE_TBL
          dc.w      $2602,MSG2602-SENSE_TBL
          dc.w      $2800,MSG2800-SENSE_TBL
          dc.w      $2900,MSG2900-SENSE_TBL
          dc.w      $2A00,MSG2A00-SENSE_TBL
          dc.w      $2A01,MSG2A01-SENSE_TBL
          dc.w      $3000,MSG3000-SENSE_TBL
          dc.w      $3001,MSG3001-SENSE_TBL
          dc.w      $3002,MSG3002-SENSE_TBL
          dc.w      $3900,MSG3900-SENSE_TBL
          dc.w      $3A00,MSG3A00-SENSE_TBL
          dc.w      $4000,MSG40NN-SENSE_TBL       Special error code ($40NN)...
          dc.w      $4400,MSG4400-SENSE_TBL
          dc.w      $4E00,MSG4E00-SENSE_TBL
          dc.w      $5300,MSG0501-SENSE_TBL
          dc.w      $5302,MSG5302-SENSE_TBL
          dc.w      $5700,MSG5700-SENSE_TBL
          dc.w      $5A00,MSG5A00-SENSE_TBL
          dc.w      $5A01,MSG5A01-SENSE_TBL
          dc.w      $6300,MSG6300-SENSE_TBL
          dc.w      $6400,MSG6400-SENSE_TBL
          dc.w      $B900,MSGB900-SENSE_TBL
          dc.w      $BF00,MSGBF00-SENSE_TBL
          dc.w      -1,-1

MSG0000   dc.w      32
          dc.b      'No additional sense information',10
MSG0011   dc.w      27
          dc.b      'Play operation in progress',10,0
MSG0012   dc.w      22
          dc.b      'Play operation paused',10
MSG0013   dc.w      38
          dc.b      'Play operation successfully completed',10
MSG0014   dc.w      36
          dc.b      'Play operation stopped due to error',10
MSG0015   dc.w      34
          dc.b      'No current audio status to return',10
MSG0100   dc.w      40
          dc.b      'Mechanical positioning or changer error',10
MSG0200   dc.w      17
          dc.b      'No seek complete',10,0
MSG0400   dc.w      47
          dc.b      'Logical drive not ready - cause not reportable',10,0
MSG0401   dc.w      56
          dc.b      'Logical drive not ready - in progress of becoming ready',10
MSG0402   dc.w      56
          dc.b      'Logical drive not ready - initializing command required',10
MSG0403   dc.w      55
          dc.b      'Logical drive not ready - manual intervention required',10,0
MSG0501   dc.w      27
          dc.b      'Media load or eject failed',10,0
MSG0600   dc.w      28
          dc.b      'No reference position found',10
MSG0900   dc.w      22
          dc.b      'Track following error',10  
MSG0901   dc.w      23
          dc.b      'Tracking servo failure',10,0
MSG0902   dc.w      20
          dc.b      'Focus servo failure',10
MSG0903   dc.w      22
          dc.b      'Spindle servo failure',10
MSG1100   dc.w      22
          dc.b      'Unrecovered read error',10
MSG1106   dc.w      22
          dc.b      'CIRC unrecovered error',10
MSG1500   dc.w      25
          dc.b      'Random positioning error',10,0
MSG1502   dc.w      45
          dc.b      'Positioning error detected by read of medium',10,0
MSG1700   dc.w      48
          dc.b      'Recovered data with no error correction applied',10
MSG1701   dc.w      28
          dc.b      'Recovered data with retries',10
MSG1702   dc.w      41
          dc.b      'Recovered data with positive head offset',10,0
MSG1703   dc.w      41
          dc.b      'Recovered data with negative head offset',10,0
MSG1704   dc.w      48
          dc.b      'Recovered data with retries and/or CIRC applied',10
MSG1705   dc.w      40
          dc.b      'Recovered data using previous sector Id',10
MSG1800   dc.w      45
          dc.b      'Recovered data with error correction applied',10,0
MSG1801   dc.w      55
          dc.b      'Recovered data with error correction & retries applied',10,0
MSG1802   dc.w      47
          dc.b      'Recovered data - the data was auto-reallocated',10,0
MSG1803   dc.w      25
          dc.b      'Recovered data with CIRC',10,0
MSG1804   dc.w      25
          dc.b      'Recovered data with L-EC',10,0
MSG1A00   dc.w      28
          dc.b      'Parameter list length error',10
MSG2000   dc.w      31
          dc.b      'Invalid command operation code',10,0
MSG2100   dc.w      35
          dc.b      'Logical block address out of range',10,0
MSG2400   dc.w      32
          dc.b      'Invalid field in command packet',10
MSG2600   dc.w      32
          dc.b      'Invalid field in parameter list',10
MSG2601   dc.w      24
          dc.b      'Parameter not supported',10
MSG2602   dc.w      24
          dc.b      'Parameter value invalid',10
MSG2800   dc.w      55
          dc.b      'Not ready to ready transition, medium may have changed',10,0
MSG2900   dc.w      44
          dc.b      'Power on, reset or bus device reset occured',10
MSG2A00   dc.w      19
          dc.b      'Parameters changed',10,0
MSG2A01   dc.w      24
          dc.b      'Mode parameters changed',10
MSG3000   dc.w      30
          dc.b      'Incompatible medium installed',10
MSG3001   dc.w      36
          dc.b      'Cannot read medium - unknown format',10
MSG3002   dc.w      41
          dc.b      'Cannot read medium - incompatible format',10,0
MSG3900   dc.w      32
          dc.b      'Saving parameters not supported',10
MSG3A00   dc.w      19
          dc.b      'Medium not present',10,0
MSG3F00   dc.w      53
          dc.b      'ATAPI CD-ROM drive operating conditions have changed',10,0
MSG3F01   dc.w      27
          dc.b      'Microcode has been changed',10,0
MSG40NN   dc.w      32
          dc.b      'Diagnostic failure on component',10
MSG4400   dc.w      36
          dc.b      'Internal ATAPI CD-ROM drive failure',10
MSG4E00   dc.w      30
          dc.b      'Overlapped commands attempted',10
MSG5302   dc.w      25
          dc.b      'Medium removal prevented',10,0
MSG5700   dc.w      26
          dc.b      'Unable to recover table of contents',10
MSG5A00   dc.w      53
          dc.b      'Operator request or state change input (unspecified)',10,0
MSG5A01   dc.w      32
          dc.b      'Operator medium removal request',10
MSG6300   dc.w      43
          dc.b      'End of user area encountered on this track',10,0
MSG6400   dc.w      28
          dc.b      'Illegal mode for this track',10
MSGB900   dc.w      23
          dc.b      'Play operation aborted',10,0
MSGBF00   dc.w      28
          dc.b      'Loss of streaming',10

MSGUNKN   dc.w      20
          dc.b      'Unknown ATAPI error',10
MSGATAERR dc.w      39
          dc.b      'ATA protocol error (drive not ready ?)',10,0
MSGUNINIT dc.w      20
          dc.b      'Uninitialized drive',10

* PROCedures and FuNctions definition table:

PROC_FN   dc.w      18
          dc.w      ATAPILINK-*
          dc.b      10,'ATAPI_LINK',0
          dc.w      ATAPIUNLK-*
          dc.b      12,'ATAPI_UNLINK',0
          dc.w      ATAPIRSET-*
          dc.b      11,'ATAPI_RESET'
          dc.w      ATAPIQUEU-*
          dc.b      11,'ATAPI_QUEUE'
          dc.w      ATAPIUNQU-*
          dc.b      13,'ATAPI_UNQUEUE'
          dc.w      ATAPIZERO-*
          dc.b      13,'ATAPI_ZEROPKT'
          dc.w      ATAPIFPKT-*
          dc.b      13,'ATAPI_FREEPKT'
          dc.w      ATAPIFEAT-*
          dc.b      13,'ATAPI_FEATURE'
          dc.w      ATAPISLEP-*
          dc.b      11,'ATAPI_SLEEP'
          dc.w      ATAPISTBY-*
          dc.b      13,'ATAPI_STANDBY'
          dc.w      0
          dc.w      7
          dc.w      ATAPIDENT-*
          dc.b      11,'ATAPI_IDENT'
          dc.w      ATAPIWAIT-*
          dc.b      10,'ATAPI_WAIT',0
          dc.w      ATAPISENS-*
          dc.b      11,'ATAPI_SENSE'
          dc.w      ATAPIAPKT-*
          dc.b      14,'ATAPI_ALLOCPKT',0
          dc.w      0

* Copyright message:

COPYRIGHT dc.w      COPYREND-*-1
          dc.b      'ATAPI extensions thing v'
          dc.l      VERSION
          dc.b      ' for Q40/Q60'
          dc.b      ' (c) 2001 Thierry GODEFROY.'
COPYREND  dc.b      10
          dc.w      0

* Thing name:

ATPNAME   dc.w      5
          dc.b      'ATAPI',0

* Thing header:

ATAPI_THG
ATP_THG1  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG2-ATP_THG1             Pointer to next extension.
          dc.b      'IDEN'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       IDENTDEV                      Jump to actual extension code.
ATP_THG2  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG3-ATP_THG2             Pointer to next extension.
          dc.b      'RSET'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       RESETDEV                      Jump to actual extension code.
ATP_THG3  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG4-ATP_THG3             Pointer to next extension.
          dc.b      'ATPK'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       TRANSIENT                     Jump to actual extension code.
ATP_THG4  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG5-ATP_THG4             Pointer to next extension.
          dc.b      'ANPK'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       RESERVPKT                     Jump to actual extension code.
ATP_THG5  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG6-ATP_THG5             Pointer to next extension.
          dc.b      'ZPKT'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       PKTZERO                       Jump to actual extension code.
ATP_THG6  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG7-ATP_THG6             Pointer to next extension.
          dc.b      'QPKT'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       QUEUE                         Jump to actual extension code.
ATP_THG7  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG8-ATP_THG7             Pointer to next extension.
          dc.b      'UQPK'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       UNQUEUE                       Jump to actual extension code.
ATP_THG8  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG9-ATP_THG8             Pointer to next extension.
          dc.b      'RUNQ'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       RUNQUEUE                      Jump to actual extension code.
ATP_THG9  dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG10-ATP_THG9            Pointer to next extension.
          dc.b      'DSNS'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       DECODESNS                     Jump to actual extension code.
ATP_THG10 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG11-ATP_THG10           Pointer to next extension.
          dc.b      'WPCC'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       WAITCOMP                      Jump to actual extension code.
ATP_THG11 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG12-ATP_THG11           Pointer to next extension.
          dc.b      'FEAT'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       SETFEATUR                     Jump to actual extension code.
ATP_THG12 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      ATP_THG13-ATP_THG12           Pointer to next extension.
          dc.b      'SLEP'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       SLEEPDRV                      Jump to actual extension code.
ATP_THG13 dc.b      'THG%'                        Thing header marker.
          dc.l      $01000003                     Extension thing with list.
          dc.l      0                             Pointer to next extension.
          dc.b      'STBY'                        Id for this extension.
          dc.l      0                             No parameter definition list.
          dc.l      0                             No parameter description list.
          BRA       STBYDRV                       Jump to actual extension code.

          end
