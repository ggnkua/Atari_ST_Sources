.globl    _scr_copy
.globl    _clear_screen
.globl    _timer

.text

_scr_copy:
move.l    4(sp), a0
move.l    8(sp), a1
move.w    #1999, d0
loop:
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     dbf       d0, loop
rts




_clear_screen:
move.l    4(sp), a0
move.w    #1999, d0
loope:
     clr.l     (a0)+
     clr.l     (a0)+
     clr.l     (a0)+
     clr.l     (a0)+
     dbf       d0, loope
rts




_timer:
move.l    #get_time, -(sp)
move.w    #38, -(sp)
trap      #14
addq.l    #6, sp
rts




get_time:
move.l    $4ba, d0
rts


