MODULE MiNTBug2;
(*$C-,N+,R-,L-*)

(*
 * this program shows, that after a Pterm() call even an additional Pterm()
 * call will not override the exit code: the exit code of the first Pterm
 * is returned instead of the latter exit code.
 * if it would run correctly, the exitcode would be 4567. instead, it is 1234.
 *
 * NOTE: link with no additional startup code!
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        ;illegal         ; to call resident debugger (e.g. templemon)
        
        ; go into supervisor mode
        clr.l   -(a7)
        move    #$20,-(a7)
        trap    #1
        
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
        
        ; restore etv_term
        move.l  _term(pc),$408
        
        ; do Pterm(4567)
        move    #4567,-(a7)
        move    #$4c,-(a7)
        trap    #1

test:   ; do nothing
        rts

_term:  dc.l    0               ; to save ($408)

  END
END MiNTBug2.
