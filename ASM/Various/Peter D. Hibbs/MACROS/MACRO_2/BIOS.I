* Atari BIOS - Trap #13
* =====================
* Trap #13 is Exception Vector 45 (address 180 or $B4)
* Can be called from User Mode
* Recursive up to three levels of nest
* Do not attempt printer or disk I/O in interupt vectors $100-$102
* Function number put on stack will be zero on return!
* USE REGISTERS D0-D2/A0-A2
* Any return value is in d0

* Atari BIOS
* ==========
* To call BIOS from inside an interrupt:-
*	sub.l	#46,$4a2
*	BIOS Calls...
*	add.l	#46,$4a2
*	rte
* This may only be done inside one interrupt or interrupt routine must
* not be interrupted.

getmpb	equ	0	;done
bconstat	equ	1	;done
bconin	equ	2	;done
bconout	equ	3	;done
rwabs	equ	4	;done
setexc	equ	5	;done
tickcal	equ	6	;done
getbpb	equ	7	;done
bcostat	equ	8	;done
mediach	equ	9	;done
drvmap	equ	10	;done
kbshift	equ	11	;done
