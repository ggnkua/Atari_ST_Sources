*/*   ABC p35/36  eg 3.2                 */
* H069V102
        XREF    M$,G$,LIB$
        MODULE  ABCP35 GST QC Compiler 15:58 Sunday    30/11/86 
        OPT ABS
*/*  Finally got this to work - the problem was that in the line 
*                    FILE *fptr,*fopen();
*     *fopen() was being re-initialised by this declaration
*     and was not  then being linked  in to the program properly.
*
*     By leaving out *fopen() ,this cured the problem.
*     tested and working 23/11/86                                      */
*
*         #include stdio.h
*/*--------------------------------------------------------------------+
*|                                                                     |
*|    STDIO.H - Standard I/O Definitions Header File for Atari ST      |
*|                                                                     |
*+--------------------------------------------------------------------*/
*
        XREF    STDIN
        XREF    STDOUT
        XREF    STDERR
*
**         #define gap fprintf(fptr,"\n\n\n\n\n");
*
*         #define allstars fprintf(fptr,"*****\n");
*         #define endstars fprintf(fptr,"*   *\n");
*         #define midstars fprintf(fptr,"  *  \n");
*         FILE *fptr;
        SECTION S.GLOB

        XDEF    FPTR
FPTR:
        DC.L    0
* 
*     main()
        SECTION S.CCODE
C.1:

        XDEF    MAIN
MAIN:
*
*           {   
        LINK    A6,#-C.3
*               fptr = fopen("results.text","w");
C.3     EQU     0
        PEA     C.2+0(PC)
        PEA     C.2+13(PC)
        MOVEQ   #2,D2
        JSR     FOPEN-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  A0,FPTR-G$(A5)
*               if ( fptr == NULL)
        TST.L   FPTR-G$(A5)
        BNE     C.4
*                    {   printf("error on opening file \n"); }
        PEA     C.2+15(PC)
        MOVEQ   #1,D2
        JSR     PRINTF-M$(A4)
        ADDQ.L  #4,SP
*               else
        BRA     C.5
C.4:
*                    {
*                         bigH(); gap;
        MOVEQ   #0,D2
        JSR     BIGH-M$(A4)
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.2+39(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*                         bigI(); gap;
        MOVEQ   #0,D2
        JSR     BIGI-M$(A4)
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.2+45(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*                         fclose(fptr);
        MOVE.L  FPTR-G$(A5),-(SP)
        MOVEQ   #1,D2
        JSR     FCLOSE-M$(A4)
        ADDQ.L  #4,SP
*                    }                    
C.5:
*
*           }
        UNLK    A6
        RTS
C.2:    DC.B    114,101,115,117,108,116,115,46,116,101
        DC.B    120,116,0,119,0,101,114,114,111,114
        DC.B    32,111,110,32,111,112,101,110,105,110
        DC.B    103,32,102,105,108,101,32,10,0,10
        DC.B    10,10,10,10,0,10,10,10,10,10
        DC.B    0
*
*     bigH()
        DS.W    0

        XDEF    BIGH
BIGH:
*          {   
        LINK    A6,#-C.7
*               endstars;endstars;endstars;
C.7     EQU     0
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+0(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+7(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+14(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*               allstars;
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+21(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*               endstars;endstars;endstars;
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+28(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+35(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.6+42(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*          }
        UNLK    A6
        RTS
C.6:    DC.B    42,32,32,32,42,10,0,42,32,32
        DC.B    32,42,10,0,42,32,32,32,42,10
        DC.B    0,42,42,42,42,42,10,0,42,32
        DC.B    32,32,42,10,0,42,32,32,32,42
        DC.B    10,0,42,32,32,32,42,10,0
*     bigI()
        DS.W    0

        XDEF    BIGI
BIGI:
*          {    
        LINK    A6,#-C.9
*               allstars;
C.9     EQU     0
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+0(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*               midstars; midstars;midstars;
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+7(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+14(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+21(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*               midstars; midstars;
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+28(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+35(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*               allstars;
        MOVE.L  FPTR-G$(A5),-(SP)
        PEA     C.8+42(PC)
        MOVEQ   #2,D2
        JSR     FPRINTF-M$(A4)
        ADDQ.L  #8,SP
*          }          
        UNLK    A6
        RTS
C.8:    DC.B    42,42,42,42,42,10,0,32,32,42
        DC.B    32,32,10,0,32,32,42,32,32,10
        DC.B    0,32,32,42,32,32,10,0,32,32
        DC.B    42,32,32,10,0,32,32,42,32,32
        DC.B    10,0,42,42,42,42,42,10,0
*
*
*
*
        XREF    FCLOSE
        XREF    PRINTF
        XREF    FOPEN
        XREF    FPRINTF
        END
