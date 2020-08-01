\ REGS.S: examples of the construction of simple words (normally done
\ in assembly code) using direct register access.
\ John Redmond, 30/9/90

\ They use the scratch registers D0, D1, A0 and A1, which are not
\ automatically saved and restored.  INC and DEC cause automatic
\ postincrement and predecrement of pointer registers.
\ There is a full discussion in Part 4 of the FD series.

\ The code generated from such words can be assessed using
\ wd <wordname>  and
\ what <wordname>

\ Their efficiency compares very well with that from assembly source.

: task ;  ( for easy forgetting)

: dup1  a6 @ ;
: dup2  to d0 ( one off)  d0 d0  ( two back) ;

: swap1  to d0 to d1  d0 d1 ;

: drop1  to d0 ;
: drop2  4 addto a6 ;

: nip1  to d0 to d1  d0 ;
: nip2  a6 ! ;

: tuck1  to d0 to d1  d0 d1 d0 ;
: tuck2  a6 @ to d0  to d1  d0 d1 ;

: >r1  a7 dec ! ;  ( careful!)
: r>1  a7 inc @ ;  ( here too!)
: r@1  a7 @ ;

: rot1  to d0 to d1 to a0  ( pop 3 regs)
   d1 d0 a0  ( put them back) ;

: over1  a6 4 + @ ;
: over2  to d0 to d1  d1 d0 d1 ;

: count1  to a0  a0 inc c@ to d0  ( hold length in d0)
   a0 d0  ( usual result) ;

: ?dup1  a6 @ to d0  d0 if d0 ( second copy) then ;

: cmove1  to d1 ( length) to a1 ( dest) to a0 ( source)
   for d1  a0 inc c@  a1 inc c!  next ;


\ use  wd <wordname> to get a hex dump of these words
\ and compare with the corresponding system words (from Assembly),
\ and use what <wordname> to check size and edges.

