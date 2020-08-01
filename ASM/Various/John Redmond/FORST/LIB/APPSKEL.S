( appskel.s: skeleton for compilation of stand-alone application code )

decimal macros

( critical allocation of work space: )

1024 constant return_stack
1024 constant data_stack
return_stack data_stack +  constant work_space

variable patch ( holds address of branch to top-level application code )

vector >type	
vector >number	
vector >.	
vector >(")

: even  dup 1 and + ;
: ", 34 word dup c@ 2+  even dup >r
   here swap cmove  r> allot ;
: ."  delay >(")  ",  delay >type ;  immediate

: another  ( replicate code from ForST system)

  { 6 regs  cfa dest
    headstart headlength
    codesize codestart
    1 local  codeoffset }

  head  to cfa
  cfa 4 - w@ 1023 and  to codesize
  
  codesize if
  
    codesize 1 + 2*  to codesize  ( full code size in bytes)
    cfa 5 - -1 traverse  to headstart
    cfa 4 + @  a5 +  to codestart
    cfa 8 + w@ 2+  to headlength

    cp @ to codeoffset  
    codestart here codesize cmove  codesize cp +!
    
    headstart there headlength cmove
    headlength hp +!
    
    there 10 - to dest ( point to new cfa)
    codeoffset dest inc ! ( cfa) codeoffset dest ! ( pfa)

  else

    ." not suitable for duplication"

  then
;

: called  0 there 14 - ! ; ( make sure last word cannot be expanded )

( macros for application code)

: appsave
  origin @  here over -  blksave ;

: textsize  here origin @ -  origin @ 2+ ! ;

( application header )

hex
here origin !

	( tos header: branch plus 6 long words and a word flag)
	
601a w,  ( branch)
0 ,	( size of text)
0 ,	( size of data)
work_space ,	( default size of bss)
0 ,	( size of symbol table)
0 , 0 ,	( reserved)
ffff w, ( flag)

: start  a7 4 + @ to a2	( ^ code header)
a2 100 + to a6		( temp data stack ptr)
a6 to a5		( index pointer)
a2 0c + @ to d2		( text size)
a2 14 + @ addto d2	( data size)
a2 1c + @ addto d2	( bss size)
100 addto d2		( base page size)
a2 d2 + to a7		( stack at top of ^code+size)
d2 a7 dec !		( size)
a2 a7 dec !		( ^code)
0 a7 dec w!		( ??)
4a a7 dec w!		( shrink memory function)
gemdos			( do it)
0c addto a7		( correct stack)
a7 return_stack - to a6	( final data stack ptr) 

[ 6100 w,  here patch !  0 w,	( bsr to application) ] ;

-2 allot ( drop RTS)	

( code will normally drop through to appabort)

: appabort
  0 a7 dec w!  4c a7 dec w!  gemdos ( pterm) ;

\ load a:\forth\apputils.s 

\ load conio.s
\   head type is >type	
\   head (") is >(")

\ load intout.s
\   head . is >.

\ load appfilin.s

\ load dump1.s


textsize  ( poke application code size into header)
' main patch @ -  patch @ w!  ( patch the branch to MAIN)
