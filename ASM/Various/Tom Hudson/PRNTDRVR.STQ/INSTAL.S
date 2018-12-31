
*********************************************
*    DEGAS(TM) Printer Driver Installer     *
*       Assembly language source code       *
*          written by Tom Hudson            *
*      Copyright 1986, ANTIC Publishing     *
*          Freeware, not to be sold         *
*                                           *
*    ---> NOTE: Link with INSTALL.C <---    *
*********************************************

.globl _install         ;Routine to change SCRDMP vector
.globl _scrdump         ;My screen dump printer driver code

.text

_install:
move.l #doit,-(sp)      ;point to the vector changer code
move.w #38,-(sp)        ;we want to do it in supervisor mode!
trap #14                ;execute it!
addq.l #6,sp            ;restore stack pointer
rts                     ;and return to caller

doit:
move.l #_dumpctrl,$502  ;point the system screen dump vector to my routine
rts                     ;and return

_scrdump:
.ds.l 500               ;reserve 2000 bytes for driver code

******************
* End of listing *
******************

