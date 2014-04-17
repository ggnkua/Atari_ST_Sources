Motorola Fast Floating Point (FFP) for the 68000


Assemble and run DEMO and CALC.



          CALC operations

Q   quit
X=  assign to the X variable
Y=  assign to the Y variable
R=  assign to the rounding variable
+   add
-   subtract, negate
*   multiply
**  power
/   divide
?   compare
$   specify floating point number in hexadecimal
(      parenthesis
SQRT(  square root
SIN(   sine
COS(   cosine
TAN(   tangent
EXP(   exponent
LOG(   logorithm
ATAN(  arctangent
SINH(  hyperbolic sine
COSH(  hyperbolic cosine
TANH(  hyperbolic tangent
TST(   test
NEG(   negate
ABS(   absolute value
INT(   integer

The calculator will flag overflow, divide by zero, and negative
square root errors.



          FFP format:

The FFP format is undocumented, but the CALC program will display
in hexadecimal any number you type in.  Here are some examples:

                       mantissa     exponent
                       --------     --------
   -1   = $800000C1 = %10000000 ... 11000001
   -0.5 = $800000C0 = %10000000 ... 11000000
    0   = $00000000
    0.5 = $80000040 = %10000000 ... 01000000
    1   = $80000041 = %10000000 ... 01000001
    1.5 = $C0000041 = %11000000 ... 01000001
    2   = $80000042 = %10000000 ... 01000010
    2.5 = $A0000042 = %10100000 ... 01000010
    3   = $C0000042 = %11000000 ... 01000010
 1000   = $FA00004A = %11111010 ... 01001010



          Where this code came from:

I found two different version of the FFP on the Motorola Freeware
BBS: 68343FFP.ARC (121KB) and FFP.ARC (135KB).  After comparing
the two, I chose to start with FFP.ARC.

I used three different assemblers to check the code: EASy68K
(freeware), Teesside (freeware), and Intermetrics (commercial).

The original code had I/O for an unknown system.  I created
simple character input, character output, and halt routines for
the Motorola Educational Computer Board (MECB) and the EASy68K
emulator (compatible with the Teesside emulator) and modified the
FFPDEMO and FFPCALC routines to use them.  I tweaked the MECB I/O
routines to be EASy68K compatible so the output looks identical.

The original code was 68010 compatible instead of 68000.  I made
it 68000 code again, mostly by changing the 68010 MOVE CCR,dest
instructions to 68000 MOVE SR,dest instructions.  The EASy68K and
Teesside assemblers would assemble some 68010 instructions
without warning but the Intermetrics assembler flagged them.

The original code was meant to be separately assembled and
linked.  The EASY68K and Teesside assemblers do not have linkers.
I wrote DEMO.X68 and CALC.X68 which INCLUDEd the other files.
I commented all the linker directives: IDNT, XDEF, XREF, SECTION,
and END.  I did not delete them since they helped document the
code.  This change showed some duplicated labels which I made
unique.  I also commented the TTL and PAGE directives because I
mostly look at listing files and rarely actually print them out.

The Teesside assembler does not accept SWAP.W, MOVEQ.L, EXG.L,
and SEQ.B mnemonics.  I changed them to SWAP, MOVEQ, EXG, and
SEQ.  It does not convert MOVE, ADD, and SUB instructions to
their MOVEQ, ADDQ, and SUBQ equivalents.  This meant the code was
longer and many short branches were out of range.  I changed most
(all?) of them to the Quick versions.

The Teesside listing file has the code formatted into columns.
I used this to make new pretty source files.  Only those files
needed to create the DEMO and CALC programs are included.
I removed FFPMUL2, FFPFPBCD, and all the IEF* files.

I made a few other changes to make the code compatible with all
three assemblers.  DEMO.X68 and CALC.X68 are for EASy68K and
Teesside.  DEMO.ASM and CALC.ASM are for the Intermetrics
assembler and MECB.  I have included the S-record files for the
MECB as MECBDEMO.HEX and MECBCALC.HEX.



Below are the original information files that came with 68343FFP.



*** ARESTRRG.HT:

         RESTRICTED RIGHTS LEGEND
Use, duplication, or disclosure by the
Government is subject to restrictions
as set forth in paragraph (b)(3)(B) of
the Rights in Technical Data and Computer
Software clause in DAR 7-104.9(a).



*** COPYRIG.HT

(C) Motorola, Inc.  1980,1981,1982
 
Copyright Motorola, Inc.  1980,1981,1982



*** NEWSFILE.SA

*****************************************************************************
*                                                                           *
*                   68343 FAST FLOATING-POINT FIRMWARE                      *
*                                                                           *
*                       RELEASE 1.2 JULY 29, 1983                           *
*                                                                           *
*                     SOFTWARE DISTRIBUTION DISKETTE                        *
*                                                                           *
*                                                                           *
*           (THIS FILE RESIDES AS "NEWSFILE.SA" ON THE DISKETTE)            *
*                                                                           *
*****************************************************************************
 
TECHNICAL ASPECTS OF THE PRODUCT:
 
The 68343 Software Distribution diskette contains the entire collection
of files which make up the Fast Floating-Point library.  The diskette is init-
ialized with the Volume ID of "FFP" and under User Number 343.
Upon receiving this diskette a backup should be done.
 
For each module in the library there is a source ASCII file (.SA).  Assembly
listings of the files may be obtained via normal use of the assembler.  Each
module assembles without the need for auxiliary files.  The floating-point
library itself resides on the file "FFPLIB.RO".  The VERSAdos
"LIBARY" utility can be used to list or otherwise manipulate the library
members.
 
There also exist two complete  programs which function as desk
calculators and use the 68343 library.  One is for the fast format
functions and is executed by entering "FFPCALC".  The other is for the
IEEE equivalent functions and starts by entering "IEFCALC".
The source (.SA) for both programs are on the
diskette and can be printed or assembled as desired.  Both routines have
complete documentation for their execution as beginning comments in their
respective files.  A demonstration program for the fast format
can be had by entering "FFPDEMO".  The source and assembly output listings
for that are present on the diskette as FFPDEMO.SA and FFPDEMO.LS.
The chain files FFPCALC.CF, IEFCALC.CF, and FFPDEMO.CF may be used to
re-assemble and link the three demonstration packages.  They are linked to
execute on an M68010 system with an MMU in the system.  To use on an M68000
based system it is necessary to re-assemble with the processor code
option changed from '68010' to '68000'.  In addition, the program line
'MOVE.W CCR,CCRSAVE' must be changed to read 'MOVE.W SR,CCRSAVE' before
doing the assembly and link.  The programs are linked on 2046 byte
boundaries.  This may be changed by using a different value for the
'PAGESIZE' link directive.  The programs may also be linked at physical
addresses by changing the starting address from $0 to a physical value
suitable for your system.
 
 
 
SYSTEM ENHANCEMENTS:
 
The following routines were modified to make them 68010 compatible:
 
   "IEFSIN.SA"
   "IEFADD.SA"
   "IEFCMP.SA"
   "IEFFRONT.SA"
   "IEFBACK.SA"
   "IEFFPA.SA"
   "IEFCALC.SA"
   "FFPFPA.SA"
   "FFPCALC.SA"
   "FFPIEEE.SA"
   "FFPFPBCD.SA"
 
References to the Status Register (SR), now requiring privileged
instructions on the 68010, have been removed.
 
 
LATEST DOCUMENTATION FOR THE PRODUCT:
 
Documentation is internal to the source files.
 
 
DESCRIPTION OF BUGS FIXED FOR THE CURRENT RELEASE:
 
In the Fast Floating Point Square Root routine, a check
was added to look for a mantissa of all 1's  ($FFFFFF).
The code previously assumed such a case could never happen
when in reality it can.  FFPSQRT.SA and FFPLIB.RO were
both modified to reflect this fix.
 
 
DESCRIPTION OF KNOWN BUGS IN THE RELEASE:
 
None
 
 
DISCLAIMER:
 
Motorola reserves the right to make changes to any products herein
to improve functioning or design.  Although the information in this
document has been carefully reviewed and is believed to be reliable,
Motorola does not assume any liability out of the application or use
of any product described within; neither does it convey any license
under its patent rights nor the rights of others.


