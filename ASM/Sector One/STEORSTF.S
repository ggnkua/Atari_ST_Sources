*    STE or STFM ? Dats ye question...    *
* Code: Jedi/Sector One/The Heavy Killers *

        clr.l -(sp)
        move #$20,-(sp)
        trap #1                Supervisor mode
        move.l d0,2(sp)        Save user stack
        
        move #37,-(sp)         
        trap #14               Wait the beginning of the next VBL
        addq.l #2,sp
        
        lea $ffff8209.w,a0     Lower byte of the video counter
        moveq #74,d0           Randomized value
        move.b d0,(a0)         Write it
        cmp.b (a0),d0          Equality test
        bne.s stfm             Failed ? => it's a STFM
        st ste_flag            Otherwise, it's a STE

stfm    trap #1                User mode
        addq.l #6,sp
        
...insert the rest of your sourcecode here...

ste_flag dc.b 0


ste_flag if filled with the byte $FF if the computer is a STE, and null
if it isn't the case...
