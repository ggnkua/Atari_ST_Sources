: task ;

decimal

9 constant tab
8 constant tabwidth
-1 constant eof
64 constant maxline
13 constant cret
10 constant lfeed

0 constant rd
1 constant wr

variable col
file file1
file file2

: .newline  cret file2 putc  lfeed file2 putc  0 col ! ;
: emit_char ( char--)  file2 putc  1 col +! ;

: ?emit  ( char--)
  dup lfeed  =  if  drop exit  then
  dup cret   =  if  drop .newline exit  then
  emit_char ;
  
: dotab
  begin  bl emit_char  col @ tabwidth mod  0= until ;
  
: detab  { 1 reg char }

   file1 rd namearg fopen
   file2 wr namearg fopen
   cr  0 col !

   begin
     file1 getc  to char
     char eof = not
   while
     char tab =
     if  dotab  else char ?emit  then
   repeat
   
   file1 fclose   file2 fclose ;
