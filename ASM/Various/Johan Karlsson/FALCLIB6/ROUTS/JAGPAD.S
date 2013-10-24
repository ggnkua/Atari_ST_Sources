
*** JAGPAD code!
* Function performs joypad read.

* Returns :-
* d3.l = c1numpad,c1midbuts,c1firebuts,c1joypad
* d6.l = c2numpad,c2midbuts,c2firebuts,c2joypad

* d3/d6 contain bitwise representation in the form

* 1 4 7 * 3 6 9 # 2 5 8 0 o p c b a r l d u
* where o=option, p=pause, a/b/c=fire, r/l/d/u=directions. and rest are the phone pad.
* d3=port 0, d6= port1.
 
* destroys d0-d7/a0

* This function is a bit tangled, and is not optimised... 



@jpd    clr.l   d0
        clr.l   d1
        clr.l   d2
        clr.l   d3
        clr.l   d4
        clr.l   d5
        clr.l   d6
        clr.l   d7
        move.l  #0,a0
        move.l  #0,c1numpad
        move.l  #0,c2numpad

* read row 1

        move.w  #$ffee,d0
        bsr     read_controller

        move.w  d1,d0
        andi.w  #1,d0
        move.b  d0,d3

        move.w  d1,d0
        andi.w  #2,d0
        lsr.w   #1,d0
        move.b  d0,d4

        move.w  d1,d0
        andi.w  #4,d0
        lsr.w   #2,d0
        move.b  d0,d6

        move.w  d1,d0
        andi.w  #8,d0
        lsr.w   #3,d0
        move.b  d0,d7

        move.w  d2,d0
        andi.w  #$f00,d0
        lsr.w   #8,d0
        move.b  d0,d5

        move.w  d2,d0
        andi.w  #$f000,d0
        lsr.w   #8,d0
        lsr.w   #4,d0
        move.l  d0,a0
 
* read row 2

        move.w  #$ffdd,d0
        bsr     read_controller

        move.w  d1,d0
        andi.w  #2,d0
        or.b    d0,d4

        move.w  d1,d0
        andi.w  #8,d0
        lsr.w   #2,d0
        or.b    d0,d7

        move.w  d2,d0
        andi.w  #$f00,d0
        lsr.w   #8,d0
        move.w  d0,c1numpad

        move.w  d2,d0
        andi.w  #$f000,d0
        lsr.w   #8,d0
        lsr.w   #4,d0
        move.w  d0,c2numpad

* read row 3

        move.w  #$ffbb,d0
        bsr     read_controller

        move.w  d1,d0
        andi.w  #2,d0
        lsl.w   #1,d0
        or.b    d0,d4

        move.w  d1,d0
        andi.w  #8,d0
        lsr.w   #1,d0
        or.b    d0,d7

        move.w  d2,d0
        andi.w  #$f00,d0
        lsr.w   #4,d0
        or.l    d0,c1numpad

        move.w  d2,d0
        andi.w  #$f000,d0
        lsr.w   #8,d0
        or.l    d0,c2numpad

* read row 4

        move.w  #$ff77,d0
        bsr     read_controller

        move.w  d1,d0
        andi.w  #2,d0
        or.b    d0,d3

        move.w  d1,d0
        andi.w  #8,d0
        lsr.w   #2,d0
        or.b    d0,d6
 
        move.w  d2,d0
        andi.w  #$f00,d0
        or.l    d0,c1numpad

        move.w  d2,d0
        andi.w  #$f000,d0
        lsr.w   #4,d0
        or.l    d0,c2numpad

        lsl.l   #7,d3 
        lsl.l   #4,d4
        or.l    d4,d3
        or.l    d5,d3   

        lsl.l   #7,d6  
        lsl.l   #4,d7
        or.l    d7,d6
        move.l  a0,d2
        or.l    d2,d6

        move.l  c1numpad,d2     ; d2 = c1numpad
        lsl.l   #5,d2
        move.l  c2numpad,d5     ; d5 = c2numpad
        lsl.l   #5,d5

        or.l    d2,d3
        or.l    d5,d6

        move.l  d3,d4
        andi.l  #%1111000000000000000000000,d4
        lsr.l   #4,d4
        andi.l  #%11111111111111111,d3
        or.l    d4,d3

        move.l  d6,d4
        andi.l  #%1111000000000000000000000,d4
        lsr.l   #4,d4
        andi.l  #%11111111111111111,d6
        or.l    d4,d6

        rts

read_controller
        move.w  d0,$ff9202
        move.w  $ff9200,d1
        move.w  $ff9202,d2

        andi.w  #$f,d1
        andi.w  #$ff00,d2

        not.w   d1
        not.w   d2

        rts


c1numpad        ds.l    1
c2numpad        ds.l    1       
  

