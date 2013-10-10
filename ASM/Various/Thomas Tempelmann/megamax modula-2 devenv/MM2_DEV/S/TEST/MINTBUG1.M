MODULE MiNTBug1;
(*$C-,N+,R-,L-*)

(*
 * this program shows, that after a Pterm() call the next Supexec() call
 * terminates the program anyway.
 * if it would run correctly, the exitcode would be 4567. instead, it is 1234.
 *
 * NOTE: link with no additional startup code!
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        ;illegal         ; to call resident debugger (e.g. templemon)
        
        ; save usp
        lea     _usp(pc),a0
        move.l  a7,(a0)
        
        ; go into supervisor mode
        clr.l   -(a7)
        move    #$20,-(a7)
        trap    #1
        
        ; save ssp
        lea     _ssp(pc),a0
        move.l  d0,(a0)
        
        ; install 'catch' in etv_term
        lea     _term(pc),a0
        move.l  $408,(a0)
        lea     catch(pc),a0
        move.l  a0,$408
        
        ; do Pterm(1234)
        move    #1234,-(a7)
        move    #$4c,-(a7)
        trap    #1              ; execution will continue at 'catch'...
        
catch:  ;illegal         ; to call resident debugger (e.g. templemon)
        
        ; reload usp/ssp
        move.l  _ssp(pc),a7
        move.l  _usp(pc),a0
        move.l  a0,usp
        
        ; restore etv_term
        move.l  _term(pc),$408
        
        ; go from supervisor mode back to user mode
        andi    #$dfff,sr
        
        ; now call Supexec(test), you'll see that it'll not return here
        pea     test(pc)
        move    #38,-(a7)
        trap    #14
        addq.l  #6,a7
        
        ; ERROR! this code gets never executed:
        
        ; do Pterm(4567)
        move    #4567,-(a7)
        move    #$4c,-(a7)
        trap    #1

test:   ; do nothing
        rts

_usp:   dc.l    0               ; to save usp
_ssp:   dc.l    0               ; to save ssp
_term:  dc.l    0               ; to save ($408)

  END
END MiNTBug1.
