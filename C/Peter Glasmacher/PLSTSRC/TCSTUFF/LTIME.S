*-----------------------------------------------------------------------*
*-----------------------------------------------------------------------*
*  change a Dos Date/Time into a time struct:
*  static struct TT   {
*     int  sec, min, hour, day, month, year;
*   };
* 
* d0 = time, d1 = date, a0 = *tstruct
* used by Unixtime()
*-----------------------------------------------------------------------*
*-----------------------------------------------------------------------*
        .globl ltime
ltime:
        move.b  d0,d2
        and     #$1f,d2
        move    d2,(a0)
        lsr     #5,d0
        move.b  d0,d2
        and     #$3f,d2  
        move    d2,2(a0)
        lsr     #6,d0
        move.b  d0,d2
        and     #$1f,d2
        move    d2,4(a0)
; now the date
        move.b  d1,d2
        and     #$1f,d2
        move    d2,6(a0)
        lsr     #5,d1
        move.b  d1,d2
        and     #$f,d2
        move    d2,8(a0)
        lsr     #4,d1
        and     #$7f,d1
        move    d1,10(a0)
        rts
        .end





