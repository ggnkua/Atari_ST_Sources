( UTIL.S:  ForST additional words 18/7/89)

decimal macros cr

32 constant bl

: .(  41 word count type ; immediate
: \  10 upto drop ; immediate

: .r  >r dup >r <# #s r> sign #> r>  over - spaces  type ;
: u.r  >r  <# #s #>  r>  over - spaces  type ;
: type.r  over - spaces  type ;

.( keyboard utilities) cr

: save2  d2 a7 dec ! a2 a7 dec ! ; ( might be bashed!)
: retrieve2  a7 inc @ to a2  a7 inc @ to d2 ;

: key? ( has a key been pressed?)
  save2  11 a7 dec w! gemdos
  d0 a6 dec w!  0 a6 dec w! ( extend flag to long word)
  2 addto a7  retrieve2 ;
  
: wait  key drop ;

: ?key  ( --t/f) key?  dup if drop wait key 27 = then ;

.( words using cfa: >name, >code, >body ) cr

: >name  5 - -1 traverse ;
: >code  @ os> ;
: >body  4+ @ os> ;

.( words using nfa: name>, id., words, macwords) cr

: name>  1 traverse 5 + ;

: id.  { 1 regarg ptr  2 regs padding chars }
  ptr inc c@ 31 and to chars  13 chars - to padding
  for chars  ptr inc c@  127 and emit  next
  padding spaces ;

: words  { 3 regs headptr #words column }
  cr  0 to #words  0 to column  there to headptr
  begin
   headptr dec w@  dup
   negate addto headptr ( ^new head)
   headptr  id.  1 addto #words  1 addto column
   column 6 =  if cr 0 to column then
   0= ?key  or
  until
  cr  #words . ." words displayed" ;

: macwords  { 3 regs headptr #words column }
  cr  0 to #words  0 to column  there to headptr
  begin
   headptr dec w@  dup
   negate addto headptr ( ^new head)
   headptr 1 traverse 3 + c@
   if ( a macro)
     headptr  id.  1 addto #words  1 addto column
     column 6 =  if cr 0 to column then
   then
   0= ?key or
  until
  cr  #words . ." macros displayed" ;

.( extension utilities ) cr

: <> = not ;
: flag  0= not ;

: islower  dup 96 > swap 123 < and ;
: isupper  dup 64 > swap 91 < and ;
: upper  bl - ;
: lower  bl + ;

: blank  bl fill ;
: erase  0 fill ;

: ascii  bl word 1+ c@ ;
: [ascii]  ascii [compile] literal ; immediate
: integer  bl word inumber
  state @  if [compile] literal then ; immediate
  
.( disk utilities) cr	

: namearg  bl word  0 over count + c!  1+ ;

: setdrive  setdrv drop ;
: a: 0 setdrive ;
: b: 1 setdrive ;
: c: 2 setdrive ;
: d: 3 setdrive ;
: e: 4 setdrive ;

: cd  namearg chdir  0< if ." cannot set up path " then ;

: utilities ;

.( utilities with direct file i/o: dump, blksave) cr

: .hex  <# # # #> type space ;
: .addr  cr <# [ascii] : hold # # # # # #  #> type space space ;
: .bytes  0 do count .hex   i 7 =   if space then   loop   drop ;
: .char  dup bl < if drop [ascii] . then emit ;
: .chars  0 do count .char loop   drop ;
: dline  ( --addr,n)  over over .bytes  space space  .chars ;
: dump  namearg  0 open   cls base @ >r hex   0
   begin   dup .addr 16 +  over pad 16 read
   pad over dline   16 = not ?key or  until
   drop close  r> base ! ;

: blksave  namearg 0 fmake  dup >r
   swap write  r> close ;

.( memory utilities: <address> mdump,  <addr> dp,  wd <wordname> ) cr

: mdump  ( --addr)
  cr  even  base @ >r hex
  begin  dup .addr  dup 16 dline  16 +  ?key until
  r> base !  drop ;
  
: .hex <# # # # # #> type space ;

: dp  { 1 regarg pointer 1 reg sofar }
  0 to sofar  base @ >r hex  cr
  begin
   pointer inc w@ .hex
   2 addto sofar
  key 27 = until
  cr  sofar . ." bytes and "  pointer . ." is next address"
  r> base ! ;
: wd  ' dp ;

.( file utilities: dir, ren, del, list, print, copy, ucopy, lcopy ) cr

0 constant rd
1 constant wr
file file1
file file2

: ?emit  dup 0= if drop cr else emit then ;

: ren  { 20 locbuff oldname }
  namearg oldname 20 cmove ( ^old name)
  oldname namearg  ( ^new name) rename
  0= not if ." old file not found" then ;
  
: list  file1 rd namearg fopen   cr
   begin file1 getc   dup 0< ?key or not
   while ?emit repeat   drop
   file1 fclose ;
: copy	file1 rd namearg fopen   file2 wr namearg fopen
   begin file1 getc
   dup 0< not
   while file2 putc repeat   drop
   file1 fclose   file2 fclose ;
: print	file1 rd namearg fopen
   file2 wr " prn:"  over >r  + 0 swap c! r>  fopen
   begin file1 getc
   dup 0< not
   while file2 putc repeat   drop
   file1 fclose   file2 fclose ;
: ucopy  file1 rd namearg fopen   file2 wr namearg fopen
   begin file1 getc
   dup 0< not
   while dup  islower if upper then  file2 putc repeat
   drop   file1 fclose   file2 fclose ;
: lcopy  file1 rd namearg fopen   file2 wr namearg fopen
   begin file1 getc
   dup 0< not
   while dup  isupper if lower then  file2 putc repeat
   drop   file1 fclose   file2 fclose ;

: blkname  getdta 30 +  12 bl fill ;

: getfirst  { 2 regargs &buffer &ambig }

  bl word dup c@
  
  if  0 &ambig ! count  else drop " *.*"  then
  1+ &buffer swap cmove ( initialise buffer)
  
  &buffer 31 ( file attributes) sfirst ;

: .name  { 1 regarg ptr  2 regs char #chars }

   8 to #chars
   begin
     ptr inc c@ to char
     char 0>  char [ascii] . = not and  #chars and
   while
     char emit -1 addto #chars
   repeat
   1 addto #chars  for #chars space next 
   
   3 to #chars
   for #chars
     ptr inc c@  to char
     char bl > if char else bl then emit
   next ;

: funct { 1 reg what }
   5 - c@ to what
   what case
    1  of  " <WPROT>" endof
    2  of  " <HID>" endof
    4  of  " <SYS>" endof
    8  of  " <VOL>" endof
   16  of  " <DIR>" endof
           " <EMPTY>" ( default)
   endcase ;

: .size  dup @
   if @ 8 u.r  else  funct 8 type.r then  2 spaces ;
: .day  31 and # # ;
: .month  5 lsr 15 and # # [ascii] - hold ;
: .year  9 lsr 127 and  80 + # # [ascii] - hold ;
: .date  w@  <#  dup >r .year drop
	  r@  .month drop   r> .day  #>  type ;
: .fname  5 spaces
   getdta dup  30 + .name
   dup 26 +  .size 
   24 + .date ;

: dir  { 3 locals ambig numbase column  20 locbuff name }
   0 to column base @ to numbase  decimal  cr
   blkname
   name addr ambig getfirst 0< not
   if
    begin
     .fname
     column  if cr 0  else 5 spaces 1  then  to column
     blkname snext
    0< until
   then
   numbase base ! ;

: delfile  getdta 30 + delete ;

: del  { 1 local ambig 20 locbuff name }
   blkname  1 to ambig
   name addr ambig getfirst
   ambig if ." delete all files (y/n)?"
            key dup [ascii] y = swap  [ascii] Y = or not
            if abort then
         then
   0< not ( first found)
   if
    begin  delfile  blkname snext  0< until
   then
;

\ clean up the lower-level words:

 from utilities

keep dp    keep wd
keep dump  keep mdump    keep blksave
keep list  keep print
keep copy  keep ucopy    keep lcopy
keep dir   keep ren      keep del

public

load a:\lib\what.s
