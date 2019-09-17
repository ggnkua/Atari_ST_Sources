*              F I R S T
*     M A C H I N E  L A NG U A G E
*            P R O G R A M
*             16 MAY, 1986
*              "TEST.PRG"
*
MLSTART:
*
*  Store pointer,allocate stack: 

         move.l  a7,a5        to A5 strt adr pointer
         move.l  #ustk,a7     set user stck pointer
*                    point to new stack
*
*  Recover start address:

          move.l  4(a5),a5     A5+04 -> content to A5
*
*
*  Compute total memory:

          move.l  $c(a5),d0    A5+12 ->  .text length
          add.l   $14(a5),d0   A5+20 ->+ .data length
          add.l   $1c(a5),d0   A5+28 ->+ .bss variables
          add.l   #$100,d0             +  256 Base-page
*
*
*  Execu SETBLOCK with parameters, pN:

          move.l  d0,-(sp)     p3 total mem reserved
          move.l  a5,-(sp)     p2 starting address
          move    d0,-(sp)     p1 dummy (must zero)
          move    #$4a,-(sp)   SETBLOCK (SHRINK)
          trap    #1           DOS call
          add.l   #12,sp       stack correction
*
GREETING:
*
*  Locate center screen:

          move.l  #put,-(SP)   text line
          move    #9,-(SP)     PRINT LINE
          Trap    #1           GEMDOS Call
          add.l   #6,SP        Correct Stack
*
*
*  Print HELLO WORLD:

          move.l  #text,-(SP)  text line
          move    #9,-(SP)     PRINT LINE
          Trap    #1           GEMDOS Call
          add.l   #6,SP        Correct Stack
*
*
*  Keep doing it:

          bra     GREETING     Loop do do
*                     ^C=EXIT
*
*
*  Return to sender:

          move.w   #$00,-(sp)  TERMINATE
          trap     #1          now
*  

*-------------------------------------*
*            POS. CALC.               *
* Cursor Position= ESC Y (32+V)(32+H) *
*      MEDIUM RES= V:25 x H:80        *
*           Below= V:08 x H:34        *
*-------------------------------------@

data *constants & strings
even
put:      dc.b       $1B,'Y',40,66,0 *esc,pos
text:     dc.b       " hello world",0
*

bss *variables & uninitiated blocks
           ds.l 256
ustk:      ds.l 1
*

          end *tells assembler to display errors


