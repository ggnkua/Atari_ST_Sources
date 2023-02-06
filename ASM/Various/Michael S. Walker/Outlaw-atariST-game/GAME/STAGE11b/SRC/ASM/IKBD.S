*  Michael S. Walker <mwalk762@mtroyal.ca>
* 	    _    _
*        | |  | |	OUTLAW. 
*       -| |  | |- 
*   _    | |- | |
* -| |   | |  | |- 	
*  |.|  -| ||/  |
*  | |-  |  ___/ 
* -|.|   | | |
*  |  \_|| |
*   \____  |
*    |   | |- 
*        | |
*       -| |
*        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.

             xdef      _FlushIKBD    
             xdef      _MouseOff
             xdef      _MouseOn

*
*   -------------------------- void FlushIKBD() -------
*   Flush the acia data buffer by reading all ikbd packets.
*   ------------------------------------------------------------------

_FlushIKBD:  bra.s     wait

flush        tst.b     $fffffc02.w         ; check the buffer. 
wait         btst.b    #0,$fffffc00.w      ; loop till empty. 
             bne.s     flush
             rts

*
*   ------------------------- void MouseOff() -------
*   Turn the mouse off. 
*   ------------------------------------------------------------------

_MouseOff: 
             move.b    #$12,$fffffc02.w    ; turn off.
             rts

*
*   -----------------------void MouseON()------------
*   Turn the mouse on. 
*   -----------------------------------------------------------------

_MouseOn: 
             move.b    #$8,$fffffc02.w     ; turn on.
             rts