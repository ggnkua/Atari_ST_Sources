;*****************************************************************************
;  This routine demonstrates how to construct a module which will boot
;  from an external byte-wide EPROM and execute in on-chip Program RAM.
;
;  The main routine simply toggles the least significant bit of Port-C
;  and this activity can be monitored externally with an oscilloscope
;  to confirm that the boot occurred correctly.
;
;  assemble this routine with the following command line:
;     asm56000 -a -b -l boot
;
;  build the S-Record file for use by the PROM-Burner via the SREC utility:
;     SREC boot
;
;  The vectors will be placed into the EPROM at address $C000 and the 
;  main routine will start at $C0F0 in the EPROM. 
;*****************************************************************************
m_pcc       equ    $FFE1           ;Port-C control register address (in X:)
m_pcddr     equ    $FFE3           ;Port-C data direction register
m_pcd       equ    $FFE5           ;Port-C data register
main        equ    $50             ;main routine starting address
RUNTIME     equ    0               ;bootstrap into P:0
LOADTIME    equ    $C000           ;load into EPROM at P:$C000

     page   132,66,3,3             ;format the page for 132 columns, 66 lines

                                   
     org    P:RUNTIME,P:LOADTIME
     jsr    <GO_1                  ;RESET Vector...start program
     nop                           ;...vectors have 2 words...

     DUP    62                     ;define unused vectors with
     nop                           ;..."safe" default routine
     nop
     ENDM


     org    P:main,P:LOADTIME+(3*main)
GO_1
                                   ;**** simple routine to toggle I/O pin ****
     movep  #$0001,x:m_pcddr       ;only lsb of Port-C will be an output
     movep  #$0000,x:m_pcc         ;all Port-C pins will be G.P. I/O
_loop
     bchg   #0,x:m_pcd             ;toggle the lsb of Port-C
     jmp    <_loop

CodeSize   set *

;
;    test to see if the code size exceeds the available on-chip resources
;           (512 words in on-chip P:RAM)
;
     IF     CodeSize>$1FF
     msg    "  WARNING WARNING WARNING WARNING WARNING"
     msg    "*** program size EXCEEDS onboard P:RAM ***"
     msg    "  WARNING WARNING WARNING WARNING WARNING"
     ENDIF

     END


