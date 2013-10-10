MODULE MiNTBug4;
(*$C-,N+,R-,L-*)

(*
 * this program shows, that after starting two sub-process a memory
 * block of 50248 bytes remains allocated in memory. This block lays
 * behind the allocated memory of the called processes, thus dividing
 * the largest memory block.
 *
 * NOTE: link with no additional startup code!
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        move.l  4(a7),a5        ; load ptr to our base page
        
        ; reduce our own TPA to 80000 bytes
        ; Mshrink (base page, 80000)
        MOVE.L  #80000,-(A7)
        MOVE.L  A5,-(A7)
        CLR.W   -(A7)
        MOVE    #$4A,-(A7)
        TRAP    #1
        ADDA.W  #12,A7

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


        ; here's the sub-process' #1 code:

proc1:  ; fix MiNT bug - load a7 to hi_tpa
        move.l  4(a7),a5
        move.l  4(a5),a7

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
        lea     low_s2(pc),a1
        move.l  a1,(a2)+        ; p_lowtpa:= low_s2;
        lea     top_s2(pc),a1
        move.l  a1,(a2)+        ; p_hitpa := top_s2;
        lea     proc2(pc),a1
        move.l  a1,(a2)+        ; p_tbase := proc2;
        clr.l   (a2)+           ; p_tlen  := 0L;
        clr.l   (a2)+           ; p_dbase := 0L;
        clr.l   (a2)+           ; p_dlen  := 0L;
        clr.l   (a2)+           ; p_bbase := 0L;
        clr.l   (a2)+           ; p_blen  := 0L;
        
        ; call process (proc2)
        CLR.L   -(A7)           ; env
        MOVE.L  A0,-(A7)        ; com
        CLR.L   -(A7)           ; path
        MOVE.W  #4,-(A7)        ; mode
        MOVE    #$4B,-(A7)
        TRAP    #1
        ADDA.W  #16,A7
        
        ; do Pterm(2)
        move    #2,-(a7)
        move    #$4c,-(a7)
        trap    #1


        ; here's the sub-process' #2 code:

proc2:  ; do Pterm(3)
        move    #3,-(a7)
        move    #$4c,-(a7)
        trap    #1

        ; stack area #1 (defined as TPA):
low_sp: ds      200     ; 200 bytes
top_sp:

        ; stack area #2 (defined as TPA):
low_s2: ds      100     ; 100 bytes
top_s2:

null:   DC.W    0

  END
END MiNTBug4.
