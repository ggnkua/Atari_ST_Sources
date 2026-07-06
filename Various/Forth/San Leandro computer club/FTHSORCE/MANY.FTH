\ iterated interpretation                             27sep83map
\ times is used on a command line to repeat the line several times
\ E.g.   here . cr  10 times
\
\ Many is similar to times, but it repeats until a key is typed
\
\ Loops using times or many are much slower than compiled loops,
\ because the command line is re-interpreted every time through
\
\ This can only be used from the keyboard
\
\ This is terribly kludgey.  If we had a compile buffer we could do this right

variable #times   ( # times already performed )   1 #times !
: times   ( n -- )
   1 #times +!  #times @
   < if  1 #times !
   else  in-file @ file !  bfbase @ bfcurrent !
   then
;
: many   (s -- )
   key? 0= if   in-file @ file !  bfbase @ bfcurrent !   then   ;
