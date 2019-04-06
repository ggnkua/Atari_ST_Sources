*
* This MCC assembler program appears on the distribution disk.
* It uses the resource file generated in the worked example
* explaining the resource file editor.
*
         INCLUDE  'gemlib.i'

EXAMPLE1 EQU      0
TEXTNAME EQU      1

*
* Macro to push a 16 bit quantity onto the stack
*
PUSHW    MACRO
         move.w   \1,d0
         ext.l    d0
         move.l   d0,-(a7)
         ENDM

         TEXT

         XREF     appl_init,rsrc_load,rsrc_gaddr,appl_exit
         XREF     form_alert,form_center,form_dial,objc_draw,form_do

*
* Shrink memory to make room for resource file
*
         move.l   4(a7),a0
         move.l   12(a0),d0
         add.l    20(a0),d0
         add.l    28(a0),d0
         add.l    #$2000,d0
         lea      0(a0,d0),a7

         move.l   d0,-(a7)
         move.l   a0,-(a7)
         clr.w   -(a7)
         move.w   #$4A,-(a7)
         trap     #1
         lea      12(a7),a7
*
* Initialise the AES
*
         jsr      appl_init
*
* Load the resource file form disk
*
         pea      rscname
         jsr      rsrc_load
         addq     #4,a7

         tst.l    d0
         bne.s    cont
*
* If not found then give alert and exit
*
         pea      errmes
         move.l   #1,-(a7)
         jsr      form_alert
         addq     #8,a7
*
* Exit with non-zero error code
*
         move.w   #1,-(a7)
         move.w   #$4C,-(a7)
         trap     #1

cont
*
* Get the address of the dialogue box
*
         pea      tree
         move.l   #EXAMPLE1,-(a7)
         clr.l    -(a7)
         jsr      rsrc_gaddr
         lea      12(a7),a7
*
* Make the TEDINFO record point to our string
*
         lea      input,a1
         clr.b    (a1)

         move.l   tree,a0
         move.w   #TEXTNAME,d0
         mulu.w   #SIZE_OBJECT,d0
         lea      0(a0,d0),a0
         move.l   OB_SPEC(a0),a0
         move.l   a1,TE_PTEXT(a0)
*
* Handle dialogue box
*
         move.l   tree,a3
         bsr.s    dialog
*
* Terminate the AES
*
         jsr      appl_exit
*
* Exit with zero error code
*
         clr.w    -(a7)
         move.w   #$4C,-(a7)
         trap     #1
*
* Routine to handle a dialogue box
*
dialog
*
* Calculate the coordinates for a centred box
*
         pea      ch
         pea      cw
         pea      cy
         pea      cx
         move.l   a3,-(a7)
         jsr      form_center
         lea      20(a7),a7
*
* Reserve some screen memory for box
*
         PUSHW    ch
         PUSHW    cw
         PUSHW    cy
         PUSHW    cx
         clr.l    -(a7)
         clr.l    -(a7)
         clr.l    -(a7)
         clr.l    -(a7)
         move.l   #FMD_START,-(a7)
         jsr      form_dial
         lea      36(a7),a7
*
* Draw the dialogue box
*
         PUSHW    ch
         PUSHW    cw
         PUSHW    cy
         PUSHW    cx
         move.l   #MAX_DEPTH,-(a7)
         move.l   #ROOT,-(a7)
         move.l   a3,-(a7)
         jsr      objc_draw
         lea      28(a7),a7
*
* Pass control to the AES telling it that the
* first field to be edited is TEXTNAME. (In
* fact this is the only editable field). The
* AES does not return until the EXIT button
* is selected
*
         move.l   #TEXTNAME,-(a7)
         move.l   a3,-(a7)
         jsr      form_do
         addq     #8,a7
*
* Tell the AES to redraw the screen behind the box
*
         PUSHW    ch
         PUSHW    cw
         PUSHW    cy
         PUSHW    cx
         clr.l    -(a7)
         clr.l    -(a7)
         clr.l    -(a7)
         clr.l    -(a7)
         move.l   #FMD_FINISH,-(a7)
         jsr      form_dial
         lea      36(a7),a7
         
         rts

         DATA

tree     DS.L     1
cx       DS.W     1
cy       DS.W     1
cw       DS.W     1
ch       DS.W     1
rscname  DC.B     'EXAMPLE.RSC',0
errmes   DC.B     '[0][Cannot find example.rsc file|Terminating...][OK]',0
input    DS.B     14

         END
