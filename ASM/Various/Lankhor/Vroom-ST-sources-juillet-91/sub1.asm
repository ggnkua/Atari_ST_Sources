         TTL - SUBROUTINES 1 - V15 - 27 Aug 91 

         INCLUDE  'EQU.ASM'
*         INCLUDE  'TOS.ASM'

         XDEF     PANSCP,INTER,RD0IMA,RD1IMA,AMIGA,COPSCR,ERASCR
         XDEF     RESKY,FLIPFLOP,SWPSCR,DSPGRD
         XDEF     CMPNXT,ININXT,RDEVT,INFTOP,UPDLAN,PRITOP
         
         XREF     ACTSCR,CURSCR,CRCLAP,DECOMP
         XREF     adsky,rdlog,nolog

         XREF     RD0FIL,RD2FIL
         XREF     TIMVBL
         XREF     SETPALETTE,SETSCREEN

         
* INTER - Interleave Background for Panning
* Input : A0 Points to Top of Source
*         A1 Points to Top of Work Area
*         D1 # of Lines
*         D3 # of Sides

INTER
         MOVE.L   A0,-(A7)
         MOVE.L   A1,-(A7)
         MOVE     D3,D6
         MOVE     D1,D7
         SUBI     #1,D1           # of Lines per Background-1
         MOVEQ    #0,D0           Init Counter
INTER0   MOVE     D7,D2
         SUBI     #1,D2
         SUB      D1,D2           D2 Varies from 0 TO H-1=J
         MULS     #160,D2         J*160
         MOVE     D6,D3           Sides -1 (East, South, West, North, ...)
         SUBI     #1,D3
INTER1   CLR.L    D4
         MOVE     D6,D4
         SUBI     #1,D4
         SUB      D3,D4           Varies from 0 to 3 = K
         MULS     #160,D4         K*160
         MULS     D7,D4           K*160*H
         ADD.L    D2,D4           D4=160*J+160*H*K
         SUB.L    #1,D4
         MOVE     #159,D5         160 Bytes per Line
INTER2   ADD.L    #1,D4
         MOVE.B   0(A0,D4),0(A1,D0)
         ADD      #1,D0           Increment Counter
         DBF      D5,INTER2
         DBF      D3,INTER1
         DBF      D1,INTER0
         MOVE     D7,D0           Sides*40*H-1
         MULS     D6,D0           .
         MULS     #40,D0          .
         SUBI     #1,D0           .
         MOVE.L   (A7)+,A1        Transfer Work Area to Source
         MOVE.L   (A7)+,A0
INTER3   MOVE.L   (A1)+,(A0)+
         DBF      D0,INTER3
         RTS

* PANSCP - Pan Script Routine 
* Input :  A4 Points to SCPEND, ADR, INC
*          A0 Offset to top of Script in Screen

PLN      MACRO
         NOLIST
         MOVE.L   \1*160(A4),D3
         LSL.L    D1,D3
         MOVE.L   (1*ITSCLEN/4)+\1*160(A4),D2
         LSL.L    D1,D2
         SWAP     D2
         MOVE     D2,D3
         MOVE.L   (2*ITSCLEN/4)+\1*160(A4),D4
         LSL.L    D1,D4
         MOVE.L   (3*ITSCLEN/4)+\1*160(A4),D2
         LSL.L    D1,D2
         SWAP     D2
         MOVE     D2,D4
         MOVE.L   D3,0+\1*160(A0)
         MOVE.L   D4,4+\1*160(A0)
         LIST
         ENDM

PHN      MACRO
         NOLIST
         MOVE.L   \1*160(A4),D3
         LSR.L    D1,D3
         SWAP     D3
         MOVE.L   (1*ITSCLEN/4)+\1*160(A4),D2
         LSR.L    D1,D2
         MOVE     D2,D3
         MOVE.L   (2*ITSCLEN/4)+\1*160(A4),D4
         LSR.L    D1,D4
         SWAP     D4
         MOVE.L   (3*ITSCLEN/4)+\1*160(A4),D2
         LSR.L    D1,D2
         MOVE     D2,D4
         MOVE.L   D3,0+\1*160(A0)
         MOVE.L   D4,4+\1*160(A0)
         LIST
         ENDM

PANSCP   MOVEQ    #0,D6          Assume L
         MOVEQ    #0,D5          Wash up D5
         ADDA.L   CURSCR,A0      Point to Top of Script in Proper Screen
PANSCP10 MOVE.L   (A4),A2        Get SCPEND Content
         MOVE.L   4(A4),A1       Get SCPADR Content
         MOVE.W   8(A4),D5       Get SCPINC Content (0 TO 15)
         ADDQ     #1,D5          Shift = 1
         CMPI     #16,D5
         BLT.S    PANSCP11
         ADDQ.L   #2,A2
         ADDQ.L   #2,A1
         SUB      #16,D5
PANSCP11 TST.B    2(A2)          End of Mem
         BPL.S    PANSCP16       If PL, No
         LEA.L    -158(A1),A1    SUBA.L   #158,A1
         LEA.L    -158(A2),A2    SUBA.L   #158,A2
PANSCP16 MOVE.L   A2,(A4)        Update SCPEND
         MOVE.L   A1,4(A4)       Update SCPADR
         MOVE.W   D5,8(A4)       Update SCPINC (0 to 15)
         MOVE.L   A1,A4          A4 Points to SCPADR
         MOVE.L   A2,A5          A5 Points to SCPEND
         MOVE     D5,D1          D0 from 0 to 15
         CMPI     #8,D1
         BLT.S    PANSCP17
         MOVE     #1,D6          Say H
         SUB      #16,D1         D1 from 1 to 16
         NEG      D1
PANSCP17 TST      D6
         BEQ      PLNBCK         If EQ, L

PHNBCK   MOVEQ    #19,D7         20 times per Page (160 Bytes/8)
PHNSCP1  PHN      0
         PHN      1
         PHN      2
         PHN      3
         PHN      4
         PHN      5
         PHN      6
         PHN      7
*         PHN      8
*         PHN      9
*         PHN     10
*         PHN     11
         ADDQ.L   #8,A0
         ADDQ.L   #2,A4
         ADDQ.L   #2,A5
         TST.B    2(A5)
         BPL.S    PHNSCP2
         LEA.L    -158(A4),A4    SUBA.L   #158,A4
         LEA.L    -158(A5),A5    SUBA.L   #158,A5
PHNSCP2  DBF      D7,PHNSCP1
         RTS

PLNBCK   MOVEQ    #19,D7         20 times per Page (160 Bytes/8)
PLNSCP1  PLN      0
         PLN      1
         PLN      2
         PLN      3
         PLN      4
         PLN      5
         PLN      6
         PLN      7
*         PLN      8
*         PLN      9
*         PLN     10
*         PLN     11
         ADDQ.L   #8,A0
         ADDQ.L   #2,A4
         ADDQ.L   #2,A5
         TST.B    2(A5)
         BPL.S    PLNSCP2
         LEA.L    -158(A4),A4    SUBA.L   #158,A4
         LEA.L    -158(A5),A5    SUBA.L   #158,A5
PLNSCP2  DBF      D7,PLNSCP1
         RTS

* RDIMA - Open-Read Image-Decompress-Close
* Input: A0 points to File
*        A1 points to Palette Destination Buffer 2+32 (if Palette)
*        A2 points to Image Destination Buffer 
*        D2 Length of Iecompressed Image         
*        A3 Working Area        
RD0IMA:
         MOVEM.L   A1/A2/A3,-(A7)
         MOVE.L   CURSCR,A1
         ADDA.L   #70*160,A1
         JSR      RD0FIL
         BRA      RD2IMA
RD1IMA:
         MOVEM.L   A1/A2/A3,-(A7)
         MOVE.L   CURSCR,A1
         ADDA.L   #70*160,A1
         JSR      RD2FIL
RD2IMA:
         MOVEM.L  (A7)+,A1/A2/A3
         CMPA.L   #0,A1
         BEQ.S    RDIMA2
         MOVEQ    #16,D0         Store Palette (34)
         MOVE.L   CURSCR,A0      Source
         ADDA.L   #70*160,A0     .
RDIMA1   MOVE     (A0)+,(A1)+    .
         DBF      D0,RDIMA1      .        
RDIMA2   MOVE.L   #0,-(A7)       Decompress Image
         MOVE.L   A3,-(A7)       Working Area
         MOVE.L   CURSCR,A0
         ADDA.L   #70*160,A0
         MOVE.L   A0,-(A7)       Source
         CLR.L    -(A7)
         CLR.L    -(A7)
         MOVE.L   A2,-(A7)       Destination
         JSR      DECOMP
         CLR      D0
RDIMAF   RTS                     If MI, Error

* Set Backgrounds  "A la AMIGA"
* Input: D1 Contains Screen Size/4
*        A1 Points to Working Zone
*        A5 Points to Item Screen

AMIGA    MOVE.L   A5,A0
         MOVE.L   A1,-(A7)
         MOVE.L   A1,A2
         ADDA.L   D1,A2
         MOVE.L   A2,A3
         ADDA.L   D1,A3
         MOVE.L   A3,A4
         ADDA.L   D1,A4
         MOVE.L   D1,D0
         LSR      #1,D0
         SUBQ     #1,D0
AMIGA0   MOVE     (A0)+,(A1)+
         MOVE     (A0)+,(A2)+
         MOVE     (A0)+,(A3)+
         MOVE     (A0)+,(A4)+
         DBF      D0,AMIGA0
         MOVE.L   (A7)+,A1
         MOVE.L   A5,A0
         MOVE.L   D1,D0
         LSR      #1,D0
         SUBQ     #1,D0
AMIGA1   MOVE.L   (A1)+,(A0)+
         MOVE.L   (A1)+,(A0)+
         DBF      D0,AMIGA1
         RTS

* COPSCR - Copy "Visible" Screen into "Invisible" Screen 
*
COPSCR   LEA.L    ACTSCR,A1
         MOVE.L   (A1),D0
         MOVE.L   D0,D1         
         EORI.L   #4,D1
         MOVE.L   4(A1,D0),A0   "Invisible"
         MOVE.L   4(A1,D1),A1   "Visible" 
         MOVE     #8000-1,D0
COPSCR1  MOVE.L   (A1)+,(A0)+
         DBF      D0,COPSCR1
         RTS
*
* ERASCR - Erase "Invisible" Screen
*
ERASCR   MOVE.L   CURSCR,A0     Erase "Invisible" Screen
         MOVE     #8000-1,D0    #-1 of Double Words
ERASCR0  CLR.L    (A0)+
         DBF      D0,ERASCR0
         RTS

* RESKY - Refresh Sky
* Entry : No Input
*         adsky Points to line under Sky 

RESKY    MOVE.L   adsky,A5            
         CMPA.L   #32000,A5      Below Screen?
         BLE.S    RESKY0         If LT, No
         MOVE.L   #32000,A5        
RESKY0   MOVE.L   A5,D7
         SUBI.L   #TSKYEQU,D7    TSKYEQU is just Below Banner
         BGT.S    RESKY1         **** Oct 89
         RTS
RESKY1   DIVU     #160,D7
         SUBQ     #1,D7          **** Oct 89 
         ADDA.L   CURSCR,A5      Point to Bottom Address
         MOVEQ    #$0,D1         Sky Color (0001)
         MOVE.L   #$FFFFFFFF,D0  .
         MOVE.L   D0,D2
         MOVE.L   D1,D3
         MOVE.L   D0,D4
         MOVE.L   D1,D5
         MOVE.L   D0,D6
         MOVE.L   D1,A0
         MOVE.L   D0,A1
         MOVE.L   D1,A2
         MOVE.L   D0,A3
         MOVE.L   D1,A4
RESKY2   MOVEM.L  D0-D6/A0-A4,-(A5)
         MOVEM.L  D0-D6/A0-A4,-(A5)
         MOVEM.L  D0-D6/A0-A4,-(A5)
         MOVEM.L  D0-D3,-(A5)
         DBF      D7,RESKY2
         RTS

*
* FLIPFLOP - Flip-Flop "Invisible"/Visible"
*
FLIPFLOP MOVE     #-1,-(A7)      Set New Screen Address
         MOVE.L   CURSCR,-(A7)   Update Screen Indicator
         MOVE.L   CURSCR,-(A7)   .
         JSR      SETSCREEN      .
         ADD      #10,A7         .CD29/07/91
*         LEA.L    CURSCR,A0      Set New Screen Address
*         MOVE.B   1(A0),$FFFF8201 .
*         MOVE.B   2(A0),$FFFF8203 .
         MOVE.L   TIMVBL,D0        Wait for VBL $466 CD29/07/91
FLIP0    CMP.L    TIMVBL,D0        test frclock $466 CD29/07/91
         BEQ.S    FLIP0  
         BSR      SWPSCR
         RTS

* SWPSCR - Swap Screens

SWPSCR   LEA.L    ACTSCR,A5      Update Screen Indicator
         MOVE.L   (A5),D5        .
         EORI.L   #4,D5          .
         MOVE.L   D5,(A5)        .
         MOVE.L   4(A5,D5),CURSCR Set New "Invisible" Screen
         RTS

*
* DSPGRD - Display Racing Score Grid in "Invisible" Screen
*

DSPGRD   MOVE.L   CURSCR,A0     Point after 20 Lines
         ADDA.L   #20*160,A0
         BSR      DSPLIN        1 White Line
         MOVEQ    #17-1,D2      17 Column Lines (Total=38)
DSPGRD2  BSR      DSPCOL
         DBF      D2,DSPGRD2
         BSR      DSPLIN        1 White Line (Total=39)
         MOVEQ    #16-1,D1      16*8 Lines= 128 (Total=167)
DSPGRD5  MOVEQ    #7-1,D2
DSPGRD6  BSR      DSPCOL       
         DBF      D2,DSPGRD6
         BSR      DSPLIN
         DBF      D1,DSPGRD5                  
         ADDA.L   #4*160,A0     Skip 4 lines (Total=171)
         BSR      DSPLUN        1 White Line (Total=172) 
         MOVEQ    #13-1,D2      13 Column Lines (Total=185)
DSPGRD11 BSR      DSPCUL
         DBF      D2,DSPGRD11
         BSR      DSPLUN        1 White Line (Total=186)
         MOVEQ    #13-1,D2      13 Column Lines (Total=199)
DSPGRD14 BSR      DSPCUL
         DBF      D2,DSPGRD14
         BSR      DSPLUN        1 White Line (Total=200) 
         RTS

DSPLIN   MOVE     #(40*1)-1,D0  1 White Line 
DSPLIN0  MOVE.L   #$FFFFFFFF,(A0)+
         DBF      D0,DSPLIN0
         RTS

DSPLUN   MOVE     #(40*1)-1,D0  1 White Line 
DSPLUN0  MOVE.L   #$FFFF0000,(A0)+
         DBF      D0,DSPLUN0
         RTS


DSPCOL   MOVEQ    #8-1,D0       1 White Column Line
DSPCOL0  MOVE.L   #$80008000,(A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         DBF      D0,DSPCOL0
         MOVE.L   #$00010001,-4(A0)               
         RTS

DSPCUL   MOVEQ    #8-1,D0       1 White Column Line
DSPCUL0  MOVE.L   #$80000000,(A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         CLR.L    (A0)+
         DBF      D0,DSPCUL0
         MOVE.L   #$00010000,-4(A0)               
         RTS

* CMPNXT - Compute Next Same type event Pos (0,8,..) 
* in Event Curve/Relief/Lane Event Entry

CMPNXT   MOVE.L   #CRCEVT,A0
         MOVEQ    #-8,D0     
CMPNXT0  ADDQ.L   #8,D0
         MOVE.L   D0,D1
         CMPI     #-1,0(A0,D0)
         BEQ      CMPNXTF
         MOVE.B   1(A0,D0),D2
         ANDI.B   #$3,D2
         CMP.B    #$2,D2        Vertical Event?
         BEQ.S    CMPNXT0       If EQ, Yes
CMPNXT1  ADDQ.L   #8,D1
         CMPI     #-1,0(A0,D1)
         BNE.S    CMPNXT2
         MOVE.L   #0,D1
CMPNXT2  MOVE.B   1(A0,D1),D3
         ANDI.B   #$3,D3
         CMP.B    D2,D3         Same Type?
         BNE.S    CMPNXT1       If NE, No         
         MOVE     D1,6(A0,D0)   Store Next Event #
         BRA      CMPNXT0       
CMPNXTF  RTS

* ININXT - Init Next Events in OCCUR Table (Updated New Tables 16 Nov)
* Input :  A1 Points to OCCUR Entry
*          A0 Not Destroyed

ININXT   MOVE.L   #CRCEVT,A4
         MOVEQ.L  #-8,D4
         CLR      D3
ININXT0  ADDQ.L   #8,D4
         CMPI     #-1,0(A4,D4)   End of Circuit?
         BNE.S    ININXTD        If PL, No
         BTST     #1,D3          Relief Treated?
         BNE.S    ININXTB        If NE, Already Treated
         MOVE     #-1,44(A1)     No Relief Flag
         MOVE.B   #0,50(A1)      Say Current is Flat
ININXTB  BTST     #2,D3          Lane Treated?
         BNE      ININXTF        If NE, Already Treated     
         MOVE     #-1,52(A1)     No Lanes Flag
         MOVE.B   #2,58(A1)      2 Lanes is Current
         BRA      ININXTF
ININXTD  CMP      #7,D3          
         BEQ      ININXTF
         MOVE.B   1(A4,D4),D2
         ANDI.B   #$3,D2
         CMP.B    #$2,D2         Vertical?
         BEQ.S    ININXT0        If EQ, Yes
         CMP.B    #$0,D2         Curve?
         BNE.S    ININXT1        If NE, No
         BTST     #0,D3          HERE Curve
         BNE.S    ININXT0        If NE, Already treated
         BSET     #0,D3
         MOVE     D4,20(A1)      Update Next Curve Number
         MOVE.L   2(A4,D4),D5    Compute Distance to Next "Curve"
         SUB.L    2(A1),D5       .
         MOVE.L   D5,22(A1)      .
         MOVE.B   #0,26(A1)      Say Current is Straight
         MOVE     #0,30(A1)      
         MOVEM.L  D0-D4,-(A7)
         MOVEQ    #0,D0
         BSR      UPDCRV6        Init Next Anticipated Curve
         MOVEM.L  (A7)+,D0-D4
         BRA      ININXT0
ININXT1  CMP.B    #$1,D2         Relief?
         BNE.S    ININXT2        If NE, No
         BTST     #1,D3          HERE Relief
         BNE      ININXT0        If NE, Already Treated
         BSET     #1,D3
         MOVE     D4,44(A1)      Update Next Relief Number
         MOVE.L   2(A4,D4),D5    Compute Distance to Next Relief
         SUB.L    2(A1),D5       .
         MOVE.L   D5,46(A1)      .
         MOVE.B   #0,50(A1)      Say Current Type is Flat 
         BRA      ININXT0
ININXT2  CMP.B    #3,D2          Lane?
         BNE      ININXT0        If NE, No
         BTST     #2,D3          HERE Lane
         BNE      ININXT0        If NE, Already Treated
         BSET     #2,D3
         MOVE     D4,52(A1)      Update Next Lane type Event #      
         MOVE.L   2(A4,D4),D5    Compute Delta Distance to Next
         SUB.L    2(A1),D5       .
         MOVE.L   D5,54(A1)
         MOVE.B   #2,58(A1)      Say Current Type is 2 Lanes
         BRA      ININXT0
ININXTF  RTS

* RDEVT - Read Physical Events from Logical in Circuit
*        adhaut initialized with CRCOBJ

RDEVT    MOVE.L   #CRCEVT,A0
         MOVEQ    #-8,D0     
RDEVT0   ADDQ.L   #8,D0
         CMPI     #-1,0(A0,D0)
         BEQ.S    RDEVTF
         MOVE.B   1(A0,D0),D2
         ANDI.B   #$3,D2
         CMP.B    #$2,D2        Vertical Event?
         BNE.S    RDEVT0        If NE, NO
         MOVEQ    #0,D1
         MOVE.B   0(A0,D0),D1   Get Logical Event #
         MOVE     D1,nolog
         MOVEM.L  D0/A0,-(A7)
         JSR      rdlog
         MOVEM.L  (A7)+,D0/A0
         BRA.S    RDEVT0
RDEVTF   RTS

* INFTOP - Influence of Curve/Lane in OCCUR Table Entry
* Input :  A1 Points to OCCUR                   Not Destroyed
*          D0 Pointer in OCCUR (0, 64, ...)     Not Destroyed
*          D1.W Contains X                      Updated
*          D2.L Contains Y for UPDCRV/UPDLAN    Corrupted
*          D3.L Contains Curspd                 Updated

INFTOP   BSR      UPDCRV         Update Curve Info
         BSR      UPDLAN         Update Lane Info (After, D2.L is Free)

         CLR      PRITOP
         MOVE     #-170,D6       Assume 2 Lanes 
         BTST.B   #1,58(A1,D0)   Get Current Lane Type
         BNE.S    INFLAN0        If NE, 2 Lanes 
         BTST.B   #2,58(A1,D0)     
         BNE.S    INFLAN         If NE, 3 Lanes
         MOVE     #50,D6         1 Lane 
         BRA.S    INFLAN0    
INFLAN   MOVE     #-420,D6       3 Lanes MOD1JL
INFLAN0  CMP      D6,D1          In Wrong Lane?
         BPL      INFLAN1        If PL, No
         MOVE.L   D3,D5          Compute Prioritary Shift
         LSR      #6,D5          .
         MOVE.L   D3,D4          .
         LSR.L    #4,D4          .
         SUB.L    D5,D4          =Spd/16-Spd/64
         MOVE     D4,PRITOP      Save 
INFLAN1  BSR      INFTOPB       
         MOVE     PRITOP(PC),D4
         BEQ.S    INFLAN2
         MOVE     D4,D1         DX
         BRA.S    INFLAN3
INFLAN2  SUB      8(A1,D0),D1   DX
INFLAN3  MOVE     D1,PRITOP+2
         RTS
          
PRITOP   DC.W     0             Priority
         DC.W     0             DXTOP
       
* HERE ANTICIPATION TREATMENT 
         
INFTOPB  MOVE     38(A1,D0),D4   Already Reached Braking Distance (a)
         EXT.L    D4
         BGT.S    INFTOP2        If GT a>0
         MOVE     36(A1,D0),D5   Compute Braking Distance
         EXT.L    D5
         MOVE.L   D5,D4
         ADD.L    D3,D5          =32*(Curspd+Maxspd)
         LSL.L    #5,D5          .
         CMP.L    32(A1,D0),D5   Compare to Distance
         BLT      INFTOP10       If LT, Too Far : No Anticipation Yet 
         
         MOVE.L   D5,40(A1,D0)   Store Braking Distance
         NEG.L    D4             Compute Speed Reduction a
         ADD.L    D3,D4          Curspd-Maxspd/64
         ASR.L    #6,D4          .
         BPL.S    INFTOP1        .
         MOVEQ    #0,D4          .
INFTOP1  MOVE     D4,38(A1,D0)   Store Speed Reduction a
 
INFTOP2  CMP      36(A1,D0),D3   
         BLE.S    INFTOP10       If LE Slower : No Constraint Yet
         SUB.L    D4,D3          Reduce Speed
         CMP.L    #3000,32(A1,D0)
         BLT.S    INFTOP7    
         
         MOVE.L   40(A1,D0),D5   Shift Outside : Brkdst   
         MOVE.L   32(A1,D0),D4
         LSR.L    #1,D4          In order to Avoid 0 Divide
         TST      D4             .
         BEQ.S    INFTOP2A       .
         DIVU     D4,D5          Compute Outside Shift = Brkdst/(Crvdst/2)
         CMPI     #10,D5         Too Big?
         BLT.S    INFTOP3        If LT, No
INFTOP2A MOVE     #10,D5         .
INFTOP3  TST.B    27(A1,D0)      Next Anticipated Curve Type
         BGT.S    INFTOP4        If GT, Next Curve Right
         CMPI     #70,D1         Already Shifted?
         BLT.S    INFTOP5        If LT, No
         RTS
INFTOP4  CMP      D6,D1          Right : Already Shifted JLL : AJOUT DECAL
         BLE.S    INFTOP6        If LE, Yes
         NEG      D5
INFTOP5  ADD      D5,D1          Shift Outside
         RTS
INFTOP6  MOVE.W   D6,D4          
         SUB.W    D1,D4
         MOVE.W   18(A1,D0.W),D5
         LSR.W    #5,D5
         CMP.W    D5,D4
         BLT.S    INTOP6F
         ADD.W    D5,D1
INTOP6F  RTS

INFTOP7  TST.B    27(A1,D0)      Shift Inside Again 
         BGT.S    INFTOP8        If GT, Next Curve Right
         CMP      D6,D1          Left : Already Shifted?
         BLE.S    INFTOP6        If LE, Yes
         SUBQ     #4,D1          Shift Inside by 4
         RTS
INFTOP8  CMPI     #70,D1         Right : Already Shifted 
         BPL.S    INFTOP9        If PL, Yes
         ADDQ     #4,D1          Shift Inside by 4
INFTOP9  RTS          

* CURRENT CONSTRAINTS (IF NO NEXT ANTICIPATION)

INFTOP10 MOVE.B   26(A1,D0),D2   Get Current Curve Value
         BEQ      INFTOP20       If EQ, Straight
         MOVE     30(A1,D0),D5   Curve : Get Re-Acceleration Distance
         EXT.L    D5             .
         CMP.L    22(A1,D0),D5   Compare with Distance to Next
         BPL.S    INFTOP16       If PL, Within Re-Accelerating Part of Curve

         MOVE     28(A1,D0),D5   HERE Within Decelerating Part of Curve
         CMP      D5,D3          Compare Speed to Maxspd
         BLT      INFTOP20       If LT Slower : No Speed Limit from Curve
         SUBQ.L   #2,D3          Reduce Speed 
         CMP      D5,D3          Compare Speed to Maxspd   
         BPL.S    INFTOP1A       If PL, Still Bigger
         MOVE     D5,D3          Smaller : Limit to Maxspd
         EXT.L    D3             .
INFTOP1A EXT      D2             Curve Type?
         BGT.S    INFTOP14       If GT, Curve Right 
         CMP      D6,D1          Already Shifted *
         BPL.S    INFTOP13       No              *
         SUB.W    D1,D6
         MOVE.W   18(A1,D0.W),D5
         LSR.W    #5,D5
         CMP.W    D5,D6
         BLT.S    INTO13F
         ADD.W    D5,D1
INTO13F  RTS
INFTOP13 ADDI     #9,D2          Curve Left
         MOVE.L   D3,D5
         MULU     D2,D5          Compute Shift = Curspd*C/128??
         LSR      #7,D5                          *         
         SUB      D5,D1          Shift X         *
         RTS              
INFTOP14 CMPI     #80,D1         Already Shifted
         BLT.S    INFTOP15       No 
         MOVE.W   18(A1,D0.W),D5
         LSR.W    #5,D5
         MOVE.W   D1,D6
         SUB.W    #80,D6    
         CMP.W    D5,D6
         BLT.S    INTO14F
         SUB.W    D5,D1          If Yes, Limit X MOD1JL
INTO14F  RTS
INFTOP15 ADDI     #-9,D2
         NEG      D2
         MOVE.L   D3,D5
         MULU     D2,D5          Curve Right
         LSR      #7,D5         
         ADD      D5,D1          Shift
         RTS

INFTOP16 TST.B    D2             HERE Within Re-Acceleration Part of Curve
         BGT.S    INFTOP18       If GT, Next Curve Right
         CMPI     #70,D1         Already Shifted?
         BPL      INFTOP19       If PL, Yes
         ADDQ     #4,D1          Shift Outside By 4    
         BRA      INFTOP1B
INFTOP18 CMPI     #-170,D1       Right : Already Shifted 
         BLE      INFTOP19       If LE, Yes
         SUBQ     #4,D1          Shift Outside By 4
         BRA      INFTOP1B      
INFTOP19 BCLR.B   #5,27(A1,D0)
INFTOP1B CMP.L    12(A1,D0),D3   Compare Speed to Max Allowed
         BPL.S    INFTOP1C       
         ADDQ.L   #2,D3          Re-Accelerate slowly  
INFTOP1C RTS

* HERE CURRENT HAS NO CONSTRAINT (Straight or no Constraining Curve)
* Tend to come Back to Nominal Speed and Nominal Shift Position

INFTOP20 CMPI     #-170,D6       2 Lanes?
         BEQ.S    INFTOP30       If EQ, 2 Lanes
         CMPI     #50,D6         1 Lane?
         BEQ      INFTOP40 
INFTOP25 CMP      #0,D1          3 Lanes - Car on Left Lane
         BPL.S    INFTOP30       If PL, No   MOD1JL
         BTST     #2,59(A1,D0.W) Modulo 4 Position
         BNE.S    SINF25         
         MOVE.W   #-170,D6
         BRA.S    COM25
SINF25:  SUB      D5,D1          Update Current X (D5>0)
         CMP      D6,D1          .
         BPL.S    INFTOP40 
         MOVE     D6,D1
         BRA.S    INFTOP40
INFTOP30 MOVE     6(A1,D0),D6    2 Lanes, Get Initial X
COM25:   SUB      D1,D6          Compare to Current X (I-C)
         BEQ.S    INFTOP40
         BPL.S    INFTOP33
         NEG      D6
         CMP      D5,D6
         BPL.S    INFTOP32
         MOVE     D6,D5
INFTOP32 SUB      D5,D1
         BRA.S    INFTOP40
INFTOP33 CMP      D5,D6
         BPL.S    INFTOP34
         MOVE     D6,D5
INFTOP34 ADD      D5,D1
INFTOP40 MOVE.L   12(A1,D0),D5   Get MaxSPD     MOD1JL 
         CMP.L    D3,D5          Compare Speed to Max Allowed
         BEQ.S    INFTOP45       If EQ, OK
         BPL.S    INFTOP43       If PL, Increment
         SUBQ.L   #5,D3          Decrement Speed
         BRA.S    INFTOP45       or
INFTOP43 NEG.L    D5             
         ADD.L    #526,D5        (526=351*1.5)
         BLT.S    SUINF
         LSR.L    #6,D5          .
         MOVE.W   #511,D6        MOD1JL
         SUB.W    D3,D6
         BLT.S    SUINF
         LSR.W    #6,D6
         ADD.W    D6,D5          MOD1JL
         LSR.W    #2,D6
         SUB.W    D6,D5
         BNE.S    INFTOP44
SUINF:   MOVEQ    #1,D5
INFTOP44 ADD.L    D5,D3          Increment Speed
         CMP.L    12(A1,D0.W),D3    MOD1JL
         BLE.S    INFTOP45
         MOVE.L   12(A1,D0.W),D3
INFTOP45 RTS

* OCCUR Car Occurence Buffer for 16 Car Events
*
* Fisrt Entry  = F1
* Second Entry = F2 if Comm
*
* 0  B   Evt # (-1 F1, 0 = F2, 1,2) 
* 1  B   8 Bits
* 2  L   Y in cm  
* 6  W   Initial X in Pixels on Line 0 + Bits (LE/CE/RI)
* 8  W   Actual  X in Pixels on line 0
* 10 W   Lap #  
* 12 L   MaxSpd (a la SP1D)
* 16 L   Curspd (SP1D for F1)

*        Curve
* 20 W   Next Curve Event # 
* 22 L   Next Curve Distance
* 26 B   Current Curve Type (0,-1 to -8, 1 to 8) 
* 27 B   Anticipated Curve Type (0,-1 to -8, 1 to 8) 
* 28 W   Current Curve Max Speed
* 30 W   Re Acceleration Distance in Current Curve
* 32 L   Next Anticipated Curve Distance
* 36 W   Next Anticipated Maxspd
* 38 W   Speed Reduction in Anticipation (a or 0)
* 40 L   Braking Distance for Anticipation
*        Relief
* 44 W   Next Relief Event # 
* 46 L   Next Relief Distance
* 50 B   Current Relief Type (0,-m,m)
* 51 B   Dummy
*        Lane
* 52 W   Next Lanes Event # 
* 54 L   Next Lanes Distance
* 58 B   Current Lanes Type
* 59 B   Dummy
* 
* 60 L   Reserved for Overpassing

* UPDCRV - Update Curve Info in OCCUR
* Input :  A1 Points to OCCUR                   Not Destroyed
*          D0 Pointer in OCCUR (0, 64, ...)     Not Destroyed
*          D2.L Contains Y                      Not Modified
*          D3.L Contains Curspd                 Not Modified
*
UPDCRV   MOVE.L   #CRCEVT,A4
         SUB.L    D3,32(A1,D0)   Update Distance to Next Anticipated
         SUB.L    D3,22(A1,D0)   Update Distance to Next CURVE
         BGT      UPDCRVF        If GT, Still in Current
         MOVE     20(A1,D0),D4   New "Curve", Get Number
         MOVE     D4,-(A7)
         MOVE     6(A4,D4),D4
         MOVE     D4,20(A1,D0)   Update Next Curve Number
         MOVE.L   2(A4,D4),D5    Compute Distance to Next "Curve"
         SUB.L    D2,D5          .
         BPL.S    UPDCRV1
         ADD.L    CRCLAP,D5      End of Circuit Condition
UPDCRV1  MOVE.L   D5,22(A1,D0)   .
         MOVE     (A7)+,D4       Restore D4                  

         MOVE.B   1(A4,D4),D6    Get Mask
         ANDI.B   #$C,D6 
         BNE.S    UPDCRV1A       If NE, Curve
         MOVE.B   D6,26(A1,D0)   Say Straight
         RTS
UPDCRV1A MOVE.B   0(A4,D4),D5    Get Curve Value (0 to 7)
         ADDQ.B   #1,D5          Make it +-1 to +-8 (1 = Serre, 8 = Large)
         LSR.B    #3,D6          Compute Curve Value
         BEQ.S    UPDCRV2        If EQ, Right
         NEG.B    D5
         MOVE.B   D5,26(A1,D0)   Store Left Curve Value (-1 to -8)
         NEG.B    D5
         BRA.S    UPDCRV3
UPDCRV2  MOVE.B   D5,26(A1,D0)   Store Right Curve Value (+1 to +8)
UPDCRV3  EXT      D5             Compute SPDMIN 
         SUBQ     #1,D5          .
         LSL      #1,D5          .

         BTST.B   #6,1(A4,D4)    Speed Constraint?
         BNE.S    UPDCRV4        If NE, Yes
         MOVE     #526,D6        Say MaxSpd is 351          
         BRA.S    UPDCRV5
UPDCRV4  LEA.L    SPDMAX(PC),A5      Compute SPDMAX
         MOVE.L   12(A1,D0),D6   And Delta from Maxspd
         LSR      #4,D6          .MOD1JL
         SUB      0(A5,D5),D6    .
         NEG      D6             .
UPDCRV5  MOVE     D6,28(A1,D0)   .

         BTST.B   #5,1(A4,D4)    Re-Acceleration Constraint?
         BNE.S    UPDCRV4A       IF NE, Yes
         MOVEQ    #0,D6
         BRA.S    UPDCRV5A
UPDCRV4A LEA.L    DSTACC(PC),A5      Set Re-acceleration distance
         MOVE     0(A5,D5),30(A1,D0) .
UPDCRV5A MOVE     D6,30(A1,D0)   .
     
         BTST.B   #7,1(A4,D4)    Current Was Anticipated?
         BEQ.S    UPDCRVF        If EQ, No
         MOVE     20(A1,D0),D4   Re-Point to Next
UPDCRV6  BTST.B   #7,1(A4,D4)    Next is Anticipated?
         BNE.S    UPDCRV7        If EQ, Yes
         MOVE     6(A4,D4),D4
         BRA.S    UPDCRV6        
UPDCRV7  MOVE.L   2(A4,D4),D5    Compute Distance to New Anticipated Curve
         SUB.L    D2,D5          .
         BPL.S    UPDCRV8
         ADD.L    CRCLAP,D5      End of Circuit Condition
UPDCRV8  MOVE.L   D5,32(A1,D0)   Store Distance to New Anticipated
         MOVE.B   1(A4,D4),D6    Get Mask
         MOVE.B   0(A4,D4),D5    Get Curve Value (0 to 7)
         ANDI.B   #$C,D6 
         ADDQ.B   #1,D5          Make it +-1 to +-8 (1 = Serre, 8 = Large)
         LSR.B    #3,D6          Compute Curve Value
         BEQ.S    UPDCRV9        If EQ, Right
         NEG.B    D5
         MOVE.B   D5,27(A1,D0)   Store Left Curve Value (-1 to -8)
         NEG.B    D5
         BRA.S    UPDCRV10
UPDCRV9  MOVE.B   D5,27(A1,D0)   Store Right Curve Value (+1 to +8)
UPDCRV10 EXT      D5             Compute SPDMAX 
         SUBQ     #1,D5          .
         LSL      #1,D5          .
         LEA.L    SPDMAX,A5      
         MOVE     0(A5,D5),36(A1,D0) .
         MOVE     #0,38(A1,D0)   Say Not Reached Braking Distance (a=0)
         MOVE.L   #0,40(A1,D0)   Clear Braking Distance 
UPDCRVF  RTS

SPDMAX   DC.W     150   Mimimum Speed in Curve (60=1.5*40)MOD1JL
         DC.W     200
         DC.W     250
         DC.W     300
         DC.W     350
         DC.W     400
         DC.W     450
         DC.W     526

DSTACC   DC.W    1000   Re-Acceleration Distance  
         DC.W    2000
         DC.W    4000 
         DC.W    8000
         DC.W   16000
         DC.W   32000
         DC.W   32765
         DC.W   32765
         
* UPDLAN - Update Lane Info in OCCUR (*** Does not Treat Pitstop Yet ***)
* Input :  A1 Points to OCCUR                   Not Destroyed
*          D0 Pointer in OCCUR (0, 64, ...)     Not Destroyed
*          D2.L Contains Y                      Not Modified
*          D3.L Contains Curspd                 Not Modified
         
UPDLAN   MOVE     52(A1,D0),D4   Next Lane Event #
         BLT.S    UPDLANF        If LT, No Lane Event at all
         MOVE.L   #CRCEVT,A4
         SUB.L    D3,54(A1,D0)   Update Distance to LANE
         BGT.S    UPDLANF
         MOVE     52(A1,D0),D4   New Lane Type, Get Number
         MOVE     D4,-(A7)       
         MOVE     6(A4,D4),D4    
         MOVE     D4,52(A1,D0)   Update Next Lane Type
         MOVE.L   2(A4,D4),D5    Compute Delta Distance
         SUB.L    D2,D5          .
         BPL.S    UPDLAN1
         ADD.L    CRCLAP,D5      End of Circuit Condition
UPDLAN1  MOVE.L   D5,54(A1,D0)   Next Lane Type Distance
         MOVE     (A7)+,D4       Restore D4
         MOVEQ    #0,D5
         MOVE.B   1(A4,D4),D5    Get New Lane Mask
         LSR      #2,D5
         LEA.L    UPDLAT,A4
         ADDA.L   D5,A4
         MOVE.B   (A4),D4
         BGT.S    UPDLAN4        If GT, normal
         BNE.S    UPDLAN2        If NE, Pitstop >Info
         DC.W     $4AFC          Illegal 
UPDLAN2  BTST.B   #0,D4
         BEQ.S    UPDLAN3        If EQ, End of Pitstop (-2)
         BSET.B   #7,D4          Start of Pitstop (-1)
         BRA.S    UPDLAN4
UPDLAN3  BCLR.B   #7,D4          End of Pitstop
UPDLAN4  MOVE.B   D4,58(A1,D0)   Store New Lane Type        
UPDLANF  RTS

UPDLAT   DC.B      0             0 = Illegal            
         DC.B      0             1 = Illegal
         DC.B      1             2 = 1 Lane
         DC.B      4             3 = 3 Lanes
         DC.B      2             4 = 2 Lanes
         DC.B      0             5 = Illegal
         DC.B      2             6 = 2 Lanes after 1 Lane
         DC.B      2             7 = 2 Lanes after 3 Lanes
         DC.B      0             8 = Illegal
         DC.B      0             9 = Illegal
         DC.B      0             A = Illegal
         DC.B     -1             B = + Pitstop
         DC.B      0             C = Illegal
         DC.B      0             D = Illegal
         DC.B      0             E = Illegal
         DC.B     -2             F = -Pitstop  

         END

