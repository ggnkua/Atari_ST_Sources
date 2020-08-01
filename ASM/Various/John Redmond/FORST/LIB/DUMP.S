( dump.s: a simple hex file dump application )

macros
decimal

: .hex  <# # # #> type space ;
: .addr  cr <# [ascii] : hold # # # # # #  #> type space space ;

: .bytes  { 2 regargs ptr #bytes  1 reg sofar }
   0 to sofar
   for #bytes
     ptr inc c@ .hex  1 addto sofar
     sofar 8 =   if space then
   next ;

: .char  dup 32 < if drop [ascii] . then emit ;
: .chars  { 2 regargs ptr #chars }
   for #chars  ptr inc c@ .char  next ;

: dumpline  { 2 regargs ptr #chars }
   ptr #chars .bytes  space space
   ptr #chars  .chars ;

: dump  { 3 regs fhandle lineaddress #read
          18 locbuff lpad }

   16 base !   0 to lineaddress
   
   openfile to fhandle

   begin
     fhandle lpad 16 read  to #read
     lineaddress .addr  16 addto lineaddress
     lpad #read dumpline  ?key
     #read 16 = not  (  key 27 = or)
   until

   fhandle close
;

: main

   ." ForST dump utility" cr cr  dump
;
