*	TINYSTART is written by Klaus Pedersen (micro@imada.dk), and
*	distributed, together with "NT_COMP" - the NoiseTracker Compiler
*	for Atari [MEGA] ST, STe and TT computers.
*   Based on Borland's and Atari's (Ken B.) startup code.
	
                IMPORT main

                GLOBL _BasPag
                GLOBL _app
                GLOBL _PgmSize
                GLOBL __text, __data, __bss

                GLOBL exit, errno ; these make TC stdio happy!

TextStart       EQU $08 
TextSize        EQU $0C 
DataStart       EQU $10 
DataSize        EQU $14
BssStart        EQU $18
BssSize         EQU $1C 
CmdLine         EQU $80


* Text segment...
                TEXT

__text:         moveq   #0,D1
                move.l  A0,D0
                bne.b   NotApp
                moveq   #1,D1
                movea.l 4(SP),A0

NotApp:         move.l  A0,_BasPag
                move.w  D1,_app

* Calculate program size...
                movea.l TextSize(A0),A1
                adda.l  DataSize(A0),A1
                adda.l  BssSize(A0),A1
                adda.w  #$100,A1
                move.l  A1,_PgmSize

* Set stack at top of BSS...
                move.l  A0,D0
                add.l   A1,D0
                and.b   #$FC,D0
                movea.l D0,SP

* Make A3 point to Command line...
                lea     CmdLine(A0),A3

* Shrink memory...
                move.l  A1,-(SP)
                move.l  A0,-(SP)
                move.l  #$4A0000,-(SP)
                trap    #1
                lea     12(SP),SP

* Pass command Line...
                moveq   #0,D0
                move.b  (A3)+,D0   ; anything in command-line?
                beq.b   EmptyCommand
                clr.b   0(A3,D0.w) ; terminate command-line
                lea     ArgPointer,A0 ; Argument array (2 long)
                move.l  A3,4(A0)   ; write address of command line
                moveq   #2,D0      ; set argc.

EmptyCommand:

* Execute main program...
*   D0 = argc, if (argc<2) then no parameter(s)...
*   A0 = *argv[2], argv[0] is dummy, argv[1] is a pointer to the command
*        null terminated commandline...
*   In non TURBO_C env. pass these on the stack...

                bsr     main

exit:           move.w  D0,-(SP)
                move.w  #$4C,-(SP)
                trap    #1


* Initialized data segment...
                DATA
__data:

errno:          DC.W 0             ; needed to keep stdio happy!

* Variable segment...
                BSS
__bss:

_BasPag:        DS.L 1
_PgmSize:       DS.L 1
_app:           DS.W 1

ArgPointer:     DS.L 2             ; only 2 args is used (a null and 1.)

                END
