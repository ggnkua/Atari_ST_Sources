*       APSTART.S       4/30/85                 MIKE SCHMAL
*
*       APPLICATION STARTUP PROGRAM
*
* This version only contains what is necessary for a application to run
* All other garbage has been removed as not to waste memory.
*
* Sample application startup code. This must be the first object file in
*  the link statement so that the base page address can be accessed.
*  When a program is executed, GEMDOS gives all available memory to it.
*  If this program needs to do any memory management, then one must first
*  free unused memory by a setblock call. All "segment" lengths in the base
*  page are totaled and 0x100 is added for the base page length for the setblock
*  call.
*

        .text
        .globl  _main
        .globl  _ctrl_cnts
        .globl  _Base_Page

*
*  Must be first object file in link statement
*
        move.l  a7,a5           * save a7 so we can get the base page address
        move.l  #ustk,a7        * set local stack
        move.l  4(a5),a5        * basepage address
        move.l  a5,_Base_Page
        move.l  $c(a5),d0
        add.l   $14(a5),d0
        add.l   $1c(a5),d0
        add.l   #$100,d0        * skip los pageos baseos
        move.l  d0,-(sp)
        move.l  a5,-(sp)
        move    d0,-(sp)        * junk word
        move    #$4a,-(sp)
        trap    #1
        add.l   #12,sp
*
        jsr     _main           * go to program
        move.l  #0,-(a7)        * back to gemdos
        trap    #1

        .bss
        .even
        .ds.l   256
ustk:   .ds.l   1

*
        .data
        .even
_ctrl_cnts:                             *       Application Manager
        .dc.b   0, 1, 0                 * func 010              
        .dc.b   2, 1, 1                 * func 011              
        .dc.b   2, 1, 1                 * func 012              
        .dc.b   0, 1, 1                 * func 013              
        .dc.b   2, 1, 1                 * func 014              
        .dc.b   1, 1, 1                 * func 015              
        .dc.b   0, 0, 0                 * func 016              
        .dc.b   0, 0, 0                 * func 017              
        .dc.b   0, 0, 0                 * func 008              
        .dc.b   0, 1, 0                 * func 019              

*                                                       Shell Manager
        .dc.b   0, 1, 2                 * func 120
        .dc.b   3, 1, 2                 * func 121
        .dc.b   1, 1, 1                 * func 122
        .dc.b   1, 1, 1                 * func 123
        .dc.b   0, 1, 1                 * func 124
        .dc.b   0, 1, 2                 * func 125
        .end
