\ Output Formatting                                   27Sep83map
decimal
: >type   (s adr len -- )
   tuck pad swap cmove   pad swap type  ;
variable lmargin    0 lmargin !
variable rmargin   79 rmargin !
: ?line  (s n -- ) #out @ +    rmargin @ >
  if  cr  lmargin @ spaces  then
;
: ?cr    (s -- )   0 ?line  ;
: ??cr   (s -- )   #out @ if cr then ;
: to-column (s column -- )
   #out @  -  1 max spaces
;

variable tabstops  8 tabstops !
: ?to-column ( string-length starting-column -- )
  tuck + rmargin @ >
  if   drop cr  lmargin @ spaces
  else #out @ - spaces
  then
;
: .tab ( string-length -- )
  rmargin @ tabstops @ +  lmargin @
  do
      i  #out @   >=  if  i leave  then
      tabstops @
  +loop   ( string-length target-column )
  ?to-column
;
