MODULE MiNTBug3;
(*$C-,N+,R-,L-*)

(*
 * this program shows, that the SP of a new process points into its
 * base page (bp + $E0) where it corrupts the cmd line.
 * if the program run correctly, the exit code is 1, otherwise -1
 *
 * NOTE: link with no additional startup code!
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        ; create a new base page
        CLR.L   -(A7)           ; env
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
        lea     (a0),a2
        lea     low_sp(pc),a1
        move.l  a1,(a2)+        ; p_lowtpa:= low_sp;
        lea     top_sp(pc),a1
        move.l  a1,(a2)+        ; p_hitpa := top_sp;
        lea     proc1(pc),a1
        move.l  a1,(a2)+        ; p_tbase := proc1;
        clr.l   (a2)+           ; p_tlen  := 0L;
        clr.l   (a2)+           ; p_dbase := 0L;
        clr.l   (a2)+           ; p_dlen  := 0L;
        clr.l   (a2)+           ; p_bbase := 0L;
        clr.l   (a2)+           ; p_blen  := 0L;
        
        ; call process (proc1)
        CLR.L   -(A7)           ; env
        MOVE.L  A0,-(A7)        ; com
        CLR.L   -(A7)           ; path
        MOVE.W  #4,-(A7)        ; mode
        MOVE    #$4B,-(A7)
        TRAP    #1
        ADDA.W  #16,A7
        
        ; do Pterm(D0)
        move    D0,-(a7)
        move    #$4c,-(a7)
        trap    #1

        ; here's the sub-process' code:

proc1:  ; ERROR! A7 points into the base page, but it should point into TPA!
        move.l  4(a7),a5        ; load ptr to our base page
        ;illegal                 ;  call resident debugger (e.g. templemon)
        
        ; verify a7 and set appropriate exit code
        lea     low_sp(pc),a0
        cmpa.l  a0,a7
        bls     error
        lea     top_sp(pc),a0
        cmpa.l  a0,a7
        bhi     error
        
        ; OK: do Pterm(1)
        move    #1,-(a7)
        move    #$4c,-(a7)
        trap    #1
        
error:  ; do Pterm(-1)
        move    #-1,-(a7)
        move    #$4c,-(a7)
        trap    #1

        ; stack area (defined as TPA):
low_sp: ds      100     ; 100 bytes
top_sp:

null:   DC.W    0

  END
END MiNTBug3.
