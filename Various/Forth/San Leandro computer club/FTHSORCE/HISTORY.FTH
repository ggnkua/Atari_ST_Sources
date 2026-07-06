\ History mechanism for the forth line editor

decimal
1024 constant /terminal-buffer
128 constant /line

variable terminal-buffer  terminal-buffer off
variable tbnext
variable tbscan

: inithistory
  /terminal-buffer alloc-mem    terminal-buffer !
  terminal-buffer @ /terminal-buffer erase
  terminal-buffer @   dup  tbnext !  tbscan !
;
: +line  ( addr -- )  \ Move pointer to next line in terminal buffer
  dup @ /line +
  dup terminal-buffer @ /terminal-buffer +
  u>=  if  drop terminal-buffer @
  then
  swap !
;
: -line ( addr -- )  \ Move pointer to previous line in terminal buffer
  dup @ /line -
  dup terminal-buffer @ u<
  if  drop terminal-buffer @ /terminal-buffer +
  then
  swap !
;
: history-expect
  tbnext @ tbscan !   tbscan +line
  (newexpect
  span @
  if
     tbnext +line
     tbnext @ /line erase
     tib  tbnext @  span @  cmove
   then
;
: linelen ( addr -- len ) \ Line is terminated by null character
  dup
  /line 0
  do  dup c@ 0= if leave then ca1+
  loop
  swap - ( length )
;
: cycle ( -- )
  tbscan @ linelen           ( length )
  beginning-of-line  kill-to-end-of-line
  tbscan @ over tib  swap cmove   ( length )
  tbscan @ over type
  /line span ! /line buflen !  dup bufcurrent !  bufcursor !
  tib bufstart !
;
: grab-last-line ( -- )
  tbnext -line
  tbnext @ dup linelen bounds
  do  i c@  lastchar c!  insert-character
  loop
  tbnext +line
;
keys-forth definitions
: ^P   tbscan -line cycle ;
: ^N   tbscan +line cycle ;
: ^[= grab-last-line ;
forth definitions

: (cold-hook
  (cold-hook
  inithistory
  ['] history-expect ['] expect (is
;
' (cold-hook is cold-hook
