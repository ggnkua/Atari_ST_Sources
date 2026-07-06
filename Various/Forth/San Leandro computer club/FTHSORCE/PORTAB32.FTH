\ for 32 bit stacks
forth definitions

\ Alias makes a new word which behaves exactly like an existing
\ word.  This works whether the new word is encountered during
\ compilation or interpretation, and does the right thing even
\  if the old word is immediate.

: alias  ( -- )     ( input stream:  new-name old-word )
  create
    hide
      bl word find    ( cfa -1 | cfa 1  |  str false )
      dup if
         , , immediate
      else
         drop  ." can't find "  count type
      then
    reveal
  does>  2@   ( cfa -1 | cfa 1 )
  do-defined
;

: 32-bit ; immediate
: 16-bit 1 abort" Not a 16 bit forth" ; immediate
: 32\ ; immediate
alias 16\ \
alias l+! +!
alias lnover over
alias nlover over
alias lswap swap
alias l= =
alias l< <
alias l>= >=
alias lbetween between
alias lwithin within
alias lliteral literal
alias land and 
: w->l ; immediate

alias lvariable variable
alias lconstant constant

alias \c \
alias aligned even
