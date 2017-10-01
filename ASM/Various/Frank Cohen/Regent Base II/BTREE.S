* B-TREE INDEX SYSTEM
* by Frank Cohen
* (c) 1988 Regent Software

* This program is designed to run on an Atari ST or Macintosh SE
* computer.  User input allows integer values to be inserted into
* a m-Way index tree structure.  The program then displays the
* resulting tree and waits for additional user input.

* m-Way index structures use the rules as given below.

* 1. Each node in the tree T contains the following information:
*      n, S(0), (K(1), A(1), S(1)), ... (K(n), A(n), S(n))
* 2. n is the number of key values, 1<=n<m
* 3. m is the degree of each node
* 4. K(i) (1<=i<n) is a key value, where K(i)<K(i+1) for 1<=i<n-1
* 5. S(0) is a pointer to a subtree containing key values
*    less than K(1)
* 6. S(i) 1<=i<=n) is the pointer to a subtree containing key
*    values between K(i) and K(i+1)
* 7. S(n) is a pointer to a subtree containing key values
*    greater than K(n)
* 8. S(i) 0<=i<=n is a pointer to an m-way search tree
* 9. A(i) 1<=i<=n is the address in the file of the record with key K(i)

* The B-Tree structure and searching algorithm is based in part on
* the following references:

* Date, C.J. "Databse: A Primer," Addison-Wesley Publishing Company,
*    Reading, MA, 1983
* Harbron, Thomas R. "File Systems, Structures and Algorithms",
*    Prentice Hall, Englewood Cliffs, NJ, 1988
* Miller, Nancy E. "File Structures Using Pascal," Benjamin/Cummings
*    Publishing Company, Inc. Menlo Park, CA, 1987
* Sedgewick, Robert "Algorithms" Addison-Wesley Publishing Company, Inc.,
*    Reading MA, 1983

*------------------Definitions-------------------

TREESIZE EQU 32000

*-----------------Starting Point-----------------

START JSR INIT_TREE

 JSR FORTESTING

 LEA GREETINGS,A0
 JSR STRING

 JSR DISPLAY_TREE

 LEA ASKFORINPUT,A0
 JSR STRING
 JSR KEYIN
 LEA KEYBUFF+2,A0
 JSR CVAL

* D0        ;Search value
 CLR D1     ;Parent_node
 MOVE #1,D2 ;P
 JSR BTREE_SEARCH

 JSR DISPLAY_STATUS

 JMP _ExitToShell

*----------------Search Algorithm--------------

* Stack Frame Definitions

BTS_VAL EQU -2
BTS_PARENT EQU -4
BTS_P EQU -6
BTS_I EQU -8
BTS_KINDEX EQU -10
BTS_SINDEX EQU -12

SFSIZE1 EQU -14

BTREE_SEARCH LINK A6,#SFSIZE1
 MOVE D0,BTS_VAL(A6)
 MOVE D1,BTS_PARENT(A6)
 MOVE D2,BTS_P(A6)

 TST D2
 BEQ BTS_RZRO

 MOVE #1,BTS_I(A6)

BTS_WHILE CLR.L D0
 MOVE BTS_P(A6),D0
 MULU #NODESIZE,D0
 ADD.L #TREE,D0
 MOVE.L D0,A0

 MOVE BTS_I(A6),D3
 CMP NWAY(A0),D3
 BGT BTS_NOWHILE

 CLR.L D0
 MOVE BTS_P(A6),D0
 MULU #NODESIZE,D0
 ADD.L #TREE,D0
 MOVE.L D0,A0

 MOVE.L A0,A1
 ADD #VALWAY,A1

 MOVE KWAY(A1),D0
 CMP BTS_VAL(A6),D0
 BGE BGS_ELSE

 MOVE BTS_I(A6),D0
 MOVE D0,BTS_KINDEX(A6)
 MOVE D0,BTS_KINDEX(A6)
 SUB #1,BTS_KINDEX(A6)
 MOVE BTS_P(A6),BTS_PARENT(A6)

 SUB #1,D0
 TST D0
 BEQ BTS_SEQ
 MOVE SWAY(A1),BTS_P(A6)
 JMP BTS_SRCH

BTS_SEQ MOVE S0WAY(A0),BTS_P(A6)

BTS_SRCH MOVE BTS_VAL(A6),D0
 MOVE BTS_PARENT(A6),D1
 MOVE BTS_P(A6),D1
 JSR BTREE_SEARCH
 JMP BTS

BTS_ELSE



BTS_NOWHILE

KINDEX<-N
SINDEX<-N
PARENT_NODE <- P
P <- P.S(N)
SEARCH (SUBTREE POINT TO BY S(N))


BTS_DONE MOVE BTS_VAL(A6),D0
 MOVE BTS_PARENT(A6),D1
 MOVE BTS_P(A6),D1
 UNLK A6
 RTS

BTS_RZRO CLR.L D0
 UNLK A6
 RTS

*-------------Testing Code------------

FORTESTING LEA TREE,A0

 MOVE #2,NWAY(A0)
 MOVE #2,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #30,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #3,SWAY(A1)
 ADD #KASize,A1
 MOVE #70,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #4,SWAY(A1)
 ADD #NODESIZE,A0

 MOVE #2,NWAY(A0)
 MOVE #0,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #10,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #KASize,A1
 MOVE #20,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #NODESIZE,A0

 MOVE #2,NWAY(A0)
 MOVE #0,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #40,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #KASize,A1
 MOVE #50,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #5,SWAY(A1)
 ADD #NODESIZE,A0

 MOVE #2,NWAY(A0)
 MOVE #0,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #80,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #KASize,A1
 MOVE #90,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #6,SWAY(A1)
 ADD #NODESIZE,A0

 MOVE #1,NWAY(A0)
 MOVE #0,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #60,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #KASize,A1
 MOVE #0,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #NODESIZE,A0

 MOVE #1,NWAY(A0)
 MOVE #0,S0WAY(A0)
 MOVE.L A0,A1
 ADD #VALWAY,A1
 MOVE #100,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)
 ADD #KASize,A1
 MOVE #0,KWAY(A1)
 MOVE #0,AWAY(A1)
 MOVE #0,SWAY(A1)

 MOVE #6,ORDER
 RTS

*-----------------Subroutines-----------------

INIT_TREE MOVE #TREESIZE-1,D0
 LEA TREE,A0
INIT_TREE_LP CLR.B (A0)+
 DBF D0,INIT_TREE_LP
 CLR ORDER
 RTS

*-----------------Display Tree-----------------

DISPLAY_TREE LEA SHOWTREE,A0
 JSR STRING

 MOVE ORDER,D0
 LEA SHOWTREE2+15,A3
 JSR CONV2DEC
 LEA SHOWTREE2,A0
 JSR STRING

 LEA SHOWTREE3,A0
 JSR STRING

 CLR COUNT
 LEA TREE,A4

DT_LOOP
 MOVE COUNT,D0
 ADD #1,D0
 LEA SHOWNODE,A3
 JSR CONV2DEC

 MOVE NWAY(A4),D0
 LEA SHOWNODE+6,A3
 JSR CONV2DEC

 MOVE S0WAY(A4),D0
 LEA SHOWNODE+11,A3
 JSR CONV2DEC

 MOVE.L A4,A2
 ADD #VALWAY,A2
 MOVE KWAY(A2),D0
 LEA SHOWNODE+17,A3
 JSR CONV2DEC

 MOVE AWAY(A2),D0
 LEA SHOWNODE+22,A3
 JSR CONV2DEC

 MOVE SWAY(A2),D0
 LEA SHOWNODE+27,A3
 JSR CONV2DEC

 ADD #KASize,A2

 MOVE KWAY(A2),D0
 LEA SHOWNODE+34,A3
 JSR CONV2DEC

 MOVE AWAY(A2),D0
 LEA SHOWNODE+39,A3
 JSR CONV2DEC

 MOVE SWAY(A2),D0
 LEA SHOWNODE+44,A3
 JSR CONV2DEC

 LEA SHOWNODE,A0
 JSR STRING

 ADD #NODESIZE,A4
 ADD #1,COUNT
 MOVE COUNT,D0
 CMP ORDER,D0
 BNE DT_LOOP
 RTS

DISPLAY_STATUS MOVE D1,D4

 LEA SHOWST2+11,A3  ;D0 = Return value
 JSR CONV2DEC

 LEA SHOWST3+15,A3  ;D1 = Parent_node
 MOVE D4,D0
 JSR CONV2DEC

 LEA SHOWST4+10,A3  ;D2 = P
 MOVE D2,D0
 JSR CONV2DEC

 LEA SHOWSTAT,A0
 JMP STRING

*--------------Node Definitions----------------
* The following defines the node for the Atari ST version.
* The Mac version using MPW looks like this:

* MWAY EQU 3

* WAYVALS RECORD 0
* K       DS     1
* A       DS.L   1
* S       DS     1
*         ENDR

* NODE    RECORD 0
* N       DS     1
* S0      DS     1
* REC1    DS     WAYVALS
* REC2    DS     WAYVALS
*         ENDR

MWAY EQU 2  ;m-1 Degree of each node

WAYK DS 1   ;Define K(i), A(i), S(i) records for each node
WAYA DS 1
WAYS DS 1
ENDWAY DS 1

KASize EQU ENDWAY-WAYK  ;Used to establish NodeSize

WAYN DS 1
WAYS0 DS 1
WAYVALS DS.B MWAY*KASize
ENDNODE DS 1

NODESIZE EQU ENDNODE-WAYN ;Size in bytes of each node

NWAY EQU WAYN-WAYN      ;Offset values
S0WAY EQU WAYS0-WAYN
VALWAY EQU WAYVALS-WAYN
KWAY EQU WAYK-WAYK
AWAY EQU WAYA-WAYK
SWAY EQU WAYS-WAYK

*--------Input/Output Specific Procedures---------

************************************
* CONVERT THE VALUE IN D0 TO ASCII *
* A3 POINTS TO ASCII BUFFER        *
************************************

CONV2DEC AND.L #$FFFF,D0
 DIVU #1000,D0
 MOVE.L D0,D1
 AND.L #15,D0
 ADD.B #'0',D0
 MOVE.B D0,(A3)

 SWAP D1
 AND.L #$FFFF,D1
 DIVU #100,D1
 MOVE.L D1,D0
 AND.L #15,D1
 ADD.B #'0',D1
 MOVE.B D1,1(A3)

 SWAP D0
 AND.L #$FFFF,D0
 DIVU #10,D0
 MOVE.L D0,D1
 AND.L #15,D0
 ADD.B #'0',D0
 MOVE.B D0,2(A3)

 SWAP D1
 AND.L #$FFFF,D1
 AND.L #15,D1
 ADD.B #'0',D1
 MOVE.B D1,3(A3)

BLANKLDS MOVE.L A3,-(A7)
 MOVE #2,D1  ;Clear leading zeros
BLANK1 CMP.B #'0',(A3)
 BNE BLANK2
 MOVE.B #' ',(A3)
 ADD #1,A3
 DBF D1,BLANK1
BLANK2 MOVE.L (A7)+,A3
 RTS

***************************
* Convert ASCII to Binary *
* A0 points to string     *
* Returns D0 = value      *
***************************

CVAL CLR.L D0
 CLR.L D1

 MOVE.L A0,A1
 MOVE.B (A1)+,D0
 CMP.B #'0',D0
 BLT CVALERR
 CMP.B #'9',D0
 BGT CVALERR

 MOVE.B (A1)+,D0
 CMP.B #'0',D0
 BLT CVAL4
 CMP.B #'9',D0
 BGT CVAL4

 MOVE.B (A1)+,D0
 CMP.B #'0',D0
 BLT CVAL3
 CMP.B #'9',D0
 BGT CVAL3

 MOVE.B (A1)+,D0
 CMP.B #'0',D0
 BLT CVAL2
 CMP.B #'9',D0
 BGT CVAL2

CVAL1 MOVE.B (A0)+,D0
 SUB.B #'0',D0
 MULU #1000,D0
 ADD D0,D1

CVAL2 CLR.L D0
 MOVE.B (A0)+,D0
 SUB.B #'0',D0
 MULU #100,D0
 ADD D0,D1

CVAL3 CLR.L D0
 MOVE.B (A0)+,D0
 SUB.B #'0',D0
 MULU #10,D0
 ADD D0,D1

CVAL4 CLR.L D0
 MOVE.B (A0)+,D0
 SUB.B #'0',D0
 ADD D0,D1
 AND.L #$FFFF,D1
 MOVE.L D1,D0
 RTS

CVALERR CLR.L D1
 RTS

*------------Atari ST Specific Procedures---------------

_ExitToShell CLR -(A7)
 TRAP #1

STRING MOVE.L A0,-(A7)
 MOVE #9,-(A7)
 TRAP #1
 ADD #6,A7
 RTS

KEYIN MOVE #100,D0
 LEA KEYBUFF,A0
KEYIN2 MOVE.B #' ',(A0)+
 DBF D0,KEYIN2

 MOVE.B #100,KEYBUFF
 MOVE.L #KEYBUFF,-(A7)
 MOVE #10,-(A7)
 TRAP #1
 ADD #6,A7

 CLR.L D0
 MOVE.B KEYBUFF+1,D0
 ADD.L #KEYBUFF+2,D0
 MOVE.L D0,A0
 CLR.B (A0)
 RTS

*-------------Text Messages---------------

GREETINGS DC.B 27,'E',27,'p'
 DC.B '                           B-TREE INDEX SYSTEM                                ',27,'q',13,10
 DC.B '                              by Frank Cohen',13,10
 DC.B '                         (c) 1988 Regent Software',13,10,13,10
 DC.B 'This program is designed to run on an Atari ST or Macintosh SE',13,10
 DC.B 'computer.  User input allows integer values to be inserted into',13,10
 DC.B 'a m-Way index tree structure.  The program then displays the',13,10
 DC.B 'resulting tree and waits for additional user input.',13,10,13,10,0

ASKFORINPUT DC.B 27,'p','Enter integer value (0-1000)>',27,'q',0

SHOWTREE DC.B 13,10,13,10,13,10,27,'p','m-Way Tree Structure'
 DC.B 27,'q',13,10,13,10,0
 EVEN
SHOWTREE2 DC.B 'Order of tree: 0000',13,10,13,10,0
 EVEN
SHOWTREE3 DC.B 'Node   n   s(0)  K(1) A(1) S(1)   K(2) A(2) S(2)',13,10,0
 EVEN
SHOWNODE  DC.B '0000  0000 0000  0000 0000 0000   0000 0000 0000',13,10,0
 EVEN

SHOWSTAT DC.B 'Status of Search',13,10
SHOWST2  DC.B '  Return:      ',13,10
SHOWST3  DC.B '  Parent Node:     ',13,10
SHOWST4  DC.B '  P_Root:       ',13,10,0

SHOWCRLF DS.B 13,10,0
 EVEN

 EVEN
 BSS

*---------------Variables------------------

ORDER DS 1          ;Order of m-Way search tree
TREE DS.B TREESIZE
 EVEN

*--------User Interface Variables----------

KEYBUFF DS.B 32000
COUNT DS 1

 END
