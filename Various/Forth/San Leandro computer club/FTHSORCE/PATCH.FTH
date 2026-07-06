\  Patch utility.  Allows you to make patches to already-defined words.
\   Use:
\     patch new-word old-word word-to-patch
\         In the definition of "word-to-patch", replaces the first
\         occurence of "old-word" with "new-word".
\
\     n-new  n-old  npatch  word-to-patch 
\         In the definition of "word-to-patch", replaces the first
\         compiled instance of the number "n-old" with the number
\         "n-new".
\
\     n-new  n-old  start-addr  end-addr  (patch   
\         replaces the first occurrence of "n-old" between start-addr
\         and end-addr with "n-new"
\
\     n  start-addr end-addr   search
\         searches for an occurrence of "n" between start-addr and
\         end-addr.  Leaves the address where found and a success flag.
: csearch ( c start end --- loc true | false )
  swap ( n end start )
  begin ( n end curr )
   2dup = 
   if drop drop drop false exit then ( if curr=end exit with false )
   dup c@ 3 pick  ( n end curr curr@ n )
   <>
  while
     ca1+ 
  repeat
  swap drop swap drop true  ( loc true )
;
: wsearch ( w start end --- loc true | false )
  rot n->w -rot  ( strip off any high bits )
  swap ( n end start )
  begin ( n end curr )
   2dup = 
   if drop drop drop 0 exit then ( if curr=end exit with false )
   dup w@ 3 pick  ( n end curr curr@ n )
   <>
  while
     wa1+ 
  repeat
  swap drop swap drop true ( loc true )
;
: tsearch ( addr start end --- loc true | false )
  swap ( n end start )
  begin ( n end curr )
   2dup <=
   if drop drop drop 0 exit then ( if curr=end exit with false )
   dup token@ 3 pick  ( n end curr curr@ n )
   <>
  while
     wa1+ 
  repeat
  swap drop swap drop true ( loc true )
;
: search ( n start end --- loc true | false )
  swap ( n end start )
  begin ( n end curr )
   2dup = 
   if drop drop drop false exit then ( if curr=end exit with false )
   dup @ 3 pick  ( n end curr curr@ n )
   <>
  while
     wa1+ 
  repeat
  swap drop swap drop true ( loc true )
;
: word-bounds ( cfa -- pfa end )
  >body
  ['] unnest over  here  ( pfa end-token pfa here )
  tsearch                     ( pfa [ loc ] f )
  0= if  here then
;
: (patch ( new old cfa --- )
  word-bounds
  search
  if  !  else ." Couldn't find it" drop then
;
: (wpatch ( new old cfa --- )
  word-bounds
  wsearch
  if  w!  else ." Couldn't find it" drop then
;
: npatch ( new old --name ) 
 ( substitute new for first occurrence of old in word "name" )
 '          ( new old cfa )
 (patch
;
: wpatch ( new old --name ) 
 ( substitute new for first occurrence of old in word "name" )
 '          ( new old cfa )
 (wpatch
;
: patch ( --newword-oldword-wordtopatch )
\t32  ' ' npatch
\t16  ' ' wpatch
;
