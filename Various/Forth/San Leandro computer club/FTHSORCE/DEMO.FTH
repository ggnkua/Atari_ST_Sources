\ these are some demo programs to show you how to use this forth with emacs
\ to write forth programs.

17 14 trap: _random { -- l.rnd-number }  ( bios random number routine )
37 14 trap: vsync { -- }  ( wait till next vertical retrace then return )

: rnd  ( limit -- rndnum )  ( return rnd number up to limit )
 _random swap  mod
;

get-rez
constant cury
constant curx

create buf-1  256 allot
create buf-2  256 allot

variable source-buff
variable dest-buff

variable keep-going keep-going on
variable #verts  3 #verts !

: set-buf  ( addr -- )  ( randomize a buffer )
 dup #verts @ 0
  do   curx rnd  over w! 2+  cury rnd  over w! 2+   loop
 over w@ over w! 2+ swap 2+ w@  swap w!
;

: move-buf  ( -- )  ( convert one buffer to another )
 dest-buff @  source-buff @  keep-going off  #verts @ 2+ 0
 do
	 dup w@  2 pick w@  2dup  <>
 	 if   over >
		if   1+
		else 1-
		then over w!  keep-going on
  	else 2drop
  	then 2+  swap  2+  swap
 loop  2drop
;

: draw-source ( -- )  ( draw the source polygon )
 source-buff @  #verts @ 1+ 2dup  poly-line   poly-line
;

: poly-demo
 2 _wrt_mod w!  buf-1 source-buff !  buf-2 dest-buff !
 buf-2 set-buf  buf-1 set-buf
 begin
	begin
		draw-source  move-buf  key? 
		if   exit   then  keep-going @ 0=
	until  dest-buff @ set-buf 
 again
;
