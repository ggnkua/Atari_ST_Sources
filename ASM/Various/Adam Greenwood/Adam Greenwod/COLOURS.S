* System variables for interrupts

VBLNO   EQU     $454            No of Vblank routines
VBLQU   EQU     $456            Vblank queue
HBLANK  EQU     $120            Hblank vector
KEYHND  EQU     $118            Key handler vector

* Display registers

SSHMOD  EQU     $FF8240         Shift mode
COLOR0  EQU     $FF8240         Palette colour 0

* MFP 68901 Addresses

IEA     EQU     $FFFA07         Interrupt Enable A
IEB     EQU     $FFFA09         Interrupt Enable B
ISRA    EQU     $FFFA0F         In Service A
IMA     EQU     $FFFA13         Interrupt Mask A
TBCR    EQU     $FFFA1B         Timer B Control
TBDR    EQU     $FFFA21         Timer B Data

* Start of program

START   JSR     INIT            Set everything up
WAITKEY CLR.W   D0
        MOVE.W  #7,-(A7)        Raw input call
        TRAP    #1
        ADDQ    #2,A7
        CMP.B   #$20,D0         Wait for Space to be pressed
        BNE.S   WAITKEY
        BRA     FIN             Controlled exit via FIN routine

* Subroutine to make any necessary calls to the OS

INIT    MOVE.W  #4,-(A7)        Get screen resolution
        TRAP    #14
        ADDQ    #2,A7
        TST.W   D0              
        BNE     THEEND           If not 0 set to 0

        CLR.L   -(A7)           Set supervisor mode
        MOVE.W  #32,-(A7)
        TRAP    #1
        ADDQ    #6,A7
        MOVE.L  #STK,A6         Save value of old stack
        MOVE.L  D0,(A6)
        
        MOVE.W  #-1,-(A7)       Turn cursor off
        MOVE.W  #0,-(A7)
        MOVE.W  #21,-(A7)
        TRAP    #14
        ADDQ    #6,A7

        MOVE.W  #3,-(A7)
        TRAP    #14             Get screen base address
        ADDQ    #2,A7           and save in SCRAD 
        MOVE.L  D0,SCRAD

        MOVE.L  #OLDPAL,A6        Save old palette
        JSR     SAVEPAL

        MOVE.L  #RED,A6         Load new initial palette
        JSR     RESTPAL

        MOVE.L  SCRAD,A0        
        ADD.L   #16,A0          Copy colours onto screen
        MOVE.L  #LINES,A1       from predefined block
        MOVE.L  A1,A2
        MOVE.L  #191,D0
SETSC   MOVE.L  #31,D1        
SETLN   MOVE.L  (A1)+,(A0)+
        DBRA    D1,SETLN
        ADD.W   #32,A0
        MOVE.L  A2,A1
        DBRA    D0,SETSC

        MOVE.L  #KEYHND,A0      Get old key handler
        MOVE.L  (A0),A1
        MOVE.L  A1,OLDKEY       Save it
        MOVE.L  #NEWOKY,A2
        ADDQ    #2,A2           Give address to new routine
        MOVE.L  A1,(A2)
        MOVE.L  #NEWKEY,(A0)    Replace old with new one

        MOVEQ   #0,D0   
        MOVE.W  VBLNO,D0        Get old number of Vblank routines
        MOVE.W  D0,D1
        MOVE.W  D0,OLDVBN       Save old number
        MOVE.L  VBLQU,A0        Get old Vblank Queue address
        MOVE.L  A0,OLDVBQ       Save old address
        MOVE.L  #NEWQU,A1       
        SUBQ    #1,D0
COPYQU  MOVE.L  (A0)+,(A1)+     Copy old queue into our new one
        DBRA    D0,COPYQU
        MOVE.L  #NEWQU,VBLQU    Set our queue as new one
        MOVE.L  #VBL_RTN,(A1)+  Add new routine to queue
        ADDQ    #1,D1           
        MOVE.W  D1,$454         Add one to number of routines
        
        MOVE.L  #OLDMK,A0
        MOVE.B  IEB,(A0)+       Save old Interrupt register values
        MOVE.B  IEA,(A0)+
        MOVE.B  IMA,(A0)+

        MOVE.L  #OLDHBV,A0      Save old Hblank vector
        MOVE.L  HBLANK,(A0)

        AND.B   #$DF,IEB        Disable 200Hz Interrupt
        AND.B   #$FE,IEA        Disable Hblank Interrupt

        MOVE.L  #HBL_RTN,A0     Replace old Hblank vector with
        MOVE.L  A0,HBLANK               the address of our routine

        OR.B    #1,IEA          Re-enable Hblank interrupt
        OR.B    #1,IMA

        MOVE.B  #0,GRNCNT       Set counter for green to 0

        RTS

* New key handling routine to stop mouse disrupting display

NEWKEY  MOVE.W  #$2500,SR
NEWOKY  JMP     $0              Jump to old routine

* Vblank routine which is added to queue and called every Vblank

VBL_RTN MOVE.B  #0,TBCR         Stop timer

        MOVE.L  #COLOR0,A6      
        MOVE.L  #GRN,A5
        MOVEQ   #0,D0
        MOVE.B  GRNCNT,D0
        MOVE.W  D0,D1
        DIVU    #4,D0
        MULU    #2,D0           Get next palette in list of 
        ADD.W   D0,A5           green paletes
        MOVE.W  (A5),D7

        MOVE.L  #15,D2
SETGRN  MOVE.W  (A6),D6
        MOVE.B  #0,D6           Set blue to 0 as we replace
        OR.B    D7,D6           old green value with new one,
        MOVE.W  D6,(A6)+        thus setting blue palette for 
        DBRA    D2,SETGRN       first 12 lines

        BTST.B  #0,GDIR         Check for direction
        BNE     GDWN    
        ADDQ    #1,D1           If up add 1 to counter
        CMP.B   #60,D1          and check for end of list
        BNE.S   NEWGRN
        MOVE.B  #1,GDIR         If end change direction
        BRA     NEWGRN
GDWN    SUBQ    #1,D1           If down decrement counter
        CMP.B   #0,D1           and check for start of list
        BNE.S   NEWGRN
        MOVE.B  #0,GDIR         If start change direction
NEWGRN  MOVE.B  D1,GRNCNT       Save new value of counter

        MOVE.B  #1,BLUCNT       Set blue counter to second palette

        MOVE.B  #12,TBDR        Set number of Scan lines per Hblank
        MOVE.B  #8,TBCR         Restart timer
        RTS
        
* HBlank routine called every 12 lines

HBL_RTN MOVEM.L A6/D0-D1,-(A7)  Save the registers used by routine
        MOVEQ   #0,D0
        MOVE.B  BLUCNT,D0       Get count for next blue palette
        MOVE.L  D0,D1
        MULU    #2,D0
        MOVE.L  #BLU,A6
        ADD.W   D0,A6           Set address of correct palette
        ADDQ    #1,D1
        MOVE.B  D1,BLUCNT       Increment and save counter
        MOVE.W  (A6),D1
        MOVE.L  #COLOR0,A6
        MOVE.W  #15,D0
SETBLU  AND.W   #$FFF0,(A6)     Set new blue level for all colours
        OR.W    D1,(A6)+
        DBRA    D0,SETBLU
       
        BCLR    #0,ISRA         Re-enbale lower level interupts
        MOVEM.L (A7)+,A6/D0-D1  Restore registers
        RTE

* Routine to make a controlled exit, restoring anything we have 
* changed and retruning to desktop

FIN     MOVE.L  #OLDPAL,A6      
        JSR     RESTPAL         Restore original palette

        MOVE.L  OLDKEY,A0       Restore old key handler
        MOVE.L  A0,KEYHND

        MOVE.L  OLDHBV,A0       Restore old Hblank handler
        MOVE.L  A0,HBLANK

        MOVE.L  #OLDMK,A0       Restore MFP registers
        MOVE.B  (A0)+,IEB
        MOVE.B  (A0)+,IEA
        MOVE.B  (A0),IMA

        MOVE.L  OLDVBQ,A0       Restore Vblank queue
        MOVE.L  A0,VBLQU

        MOVE.W  OLDVBN,D0       and coorect number of vectors
        MOVE.W  D0,VBLNO

        LEA     STK,A6          restore value of original stack
        MOVE.L  (A6),-(A7)
        MOVE.W  #32,-(A7)
        TRAP    #1              and return to user mode
        ADDQ    #6,A7

        MOVE.W  #0,-(A7)        Return to desktop
        TRAP    #1

* Subroutine to save palette to address in A6
* A5,D0 Corrupted

SAVEPAL MOVE.L  #COLOR0,A5
        MOVEQ   #7,D0
SAVE    MOVE.L  (A5)+,(A6)+
        DBRA    D0,SAVE
        RTS

* Subroutine to Restore Palette at address in A6
* A5,D0 Corrupted

RESTPAL MOVE.L  #COLOR0,A5
        MOVEQ   #7,D0
REST    MOVE.L  (A6)+,(A5)+
        DBRA    D0,REST
        RTS

* Storage for:

STK     DS.L    1               Initial value of stack          
OLDKEY  DS.L    1               Initial key handler vector
OLDVBN  DS.W    1               Initial number of Vblank routines
OLDVBQ  DS.L    1               Initial Vblank queue address
OLDHBV  DS.L    1               Initial Hblank vector
OLDMK   DS.B    3               Initial state of MFP
OLDPAL  DS.L    8               Initial palette
NEWQU   DS.L    20              New Vblank queue
SCRAD   DS.L    1               Address of screen in memory
GDIR    DS.B    1               Direction of green shift
GRNCNT  DS.B    1               Green shift counter
BLUCNT  DS.B    1               Blue shift counter
 
* Initial palette with red set

RED     DC.W    $000,$800,$100,$900,$200,$A00,$300,$B00
        DC.W    $400,$C00,$500,$D00,$600,$E00,$700,$F00

* Blue settings for colours

BLU     DC.W    $000,$008,$001,$009,$002,$00A,$003,$00B
        DC.W    $004,$00C,$005,$00D,$006,$00E,$007,$00F
  
* Green settings for colours

GRN     DC.W    $000,$080,$010,$090,$020,$0A0,$030,$0B0
        DC.W    $040,$0C0,$050,$0D0,$060,$0E0,$070,$0F0

* Block to copy onto screen to get 16 colours

LINES   DC.W $0000,$0000,$0000,$0000
        DC.W $FFFF,$0000,$0000,$0000
        DC.W $0000,$FFFF,$0000,$0000
        DC.W $FFFF,$FFFF,$0000,$0000
        DC.W $0000,$0000,$FFFF,$0000
        DC.W $FFFF,$0000,$FFFF,$0000  
        DC.W $0000,$FFFF,$FFFF,$0000
        DC.W $FFFF,$FFFF,$FFFF,$0000 
        DC.W $0000,$0000,$0000,$FFFF
        DC.W $FFFF,$0000,$0000,$FFFF
        DC.W $0000,$FFFF,$0000,$FFFF
        DC.W $FFFF,$FFFF,$0000,$FFFF
        DC.W $0000,$0000,$FFFF,$FFFF
        DC.W $FFFF,$0000,$FFFF,$FFFF
        DC.W $0000,$FFFF,$FFFF,$FFFF
        DC.W $FFFF,$FFFF,$FFFF,$FFFF

* The end

THEEND  END
