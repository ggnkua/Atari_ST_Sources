MODULE MiNTFix;
(*$C-,N+,R-,L-*)

(*
 * Dieses Programm behebt einen kleinen Fehler bei MiNT,
 * einem Multitask-Betriebsssystemkernel fÅr TOS-Anwendungen.
 *
 * Benîtigt wird das Programm, wenn die MM2-Shells unter MiNT
 * eingesetzt werden sollen und im Editor (z.B. GEP_ED o. GME)
 * der Compiler per Loadtime-Link aufgerufen werden soll.
 * Ohne dieses Programm wÅrde danach der verfÅgbare Gesamtspeicher
 * um ca. 50000 Byte verringert sein, der grîûte verfÅgbare Block
 * wird sogar viel geringer sein, so daû evtl. weitere Compiler-
 * oder Linker-Aufrufe wegen zu knappem Speicher fehlschlagen.
 *
 * Dieses Programm umgeht dieses öbel, wenn es vor Start der Shell
 * aufgerufen wird. Dann sorgt es dafÅr, daû diese leider unvermeidlichen
 * 50000 Byte im untersten Speicherbereich belegt werden, so daû
 * in der Shell keine weiteren SpeicherzerstÅckelungen auftreten
 * dÅrften.
 *
 * Das Programm ist zu Åbersetzen und dann ohne irgendwelche Treiber
 * zu linken (auch ohne M2Init!). Dann muû es nach der Installation
 * von MiNT, jedoch vor dem Start der MM2-Shell, gestartet werden,
 * am Besten, indem es mit der "exec"-Anweisung in MINT.CNF gestartet
 * wird.
 *
 * Getestet wurde das Ganze mit MiNT Version 0.92. Andere Versionen
 * zeigen diesen Effekt evtl. nicht, schaden kann dieses Programm
 * aber keinesfalls.
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        ; reduce our own TPA to size of code
        move.l  4(a7),a5        ; load ptr to our base page
        lea     256(a5),a7
        MOVE.L  12(a5),a0
        adda.w  #256,a0
        move.l  a0,-(A7)
        MOVE.L  A5,-(A7)
        CLR.W   -(A7)
        MOVE    #$4A,-(A7)      ; Mshrink ()
        TRAP    #1
        ADDA.W  #12,A7

        pea     proc1(pc)
        bsr     call
        bra     proc3

proc1:  ; create a new base page
        pea     proc2(pc)
        bsr     call

proc2:  ; create a new base page
        pea     proc3(pc)
        bsr     call

proc3:  clr     -(a7)
        trap    #1

call:   CLR.L   -(A7)           ; env
        PEA     null(PC)        ; com
        CLR.L   -(A7)           ; path
        MOVE.W  #5,-(A7)        ; mode
        MOVE    #$4B,-(A7)
        TRAP    #1
        ADDA.W  #16,A7

        ; reduce TPA to size of base page only:
        ; Mshrink (base page, 256)
        MOVE.L  #256,-(A7)
        MOVE.L  D0,-(A7)
        CLR.W   -(A7)
        MOVE    #$4A,-(A7)
        TRAP    #1
        MOVE.L  4(A7),A0        ; A0: base page addr
        ADDA.W  #12,A7

        ; do base page settings
        move.l  4(a7),8(a0)
        
        ; call process ()
        CLR.L   -(A7)           ; env
        MOVE.L  A0,-(A7)        ; com
        CLR.L   -(A7)           ; path
        MOVE.W  #4,-(A7)        ; mode
        MOVE    #$4B,-(A7)
        TRAP    #1
        ADDA.W  #16,A7
        
        RTS

null:   DC.W    0

  END
END MiNTFix.
