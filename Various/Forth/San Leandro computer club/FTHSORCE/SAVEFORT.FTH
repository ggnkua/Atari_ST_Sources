\ Saves a copy of the current Forth environment in a Gem file
hex

\ Gem program header
create gem-header
601a w,    \ Magic Number
   0 l,    \ Text size, actual value will be set later
   0 l,    \ Data size, actual value will be set later
   0 l,    \ Bss  size
   0 l,    \ Symbol Table size
   0 l,    \ Reserved
   0 l,    \ Reserved
   0 w,    \ Reserved
\ End of header.

create zeroes 0. l,         \ Null relocation bytes

variable fd

\ While forth is executing, the first (hex) 100 bytes bytes are the
\ base page, which is constructed by the Gem program load function.
\ The image of the base page must not be stored in the file.

: text-base ( -- addr-of-dictionary-start )
  origin th 100 +       \ Skip the base page
;
: text-size ( -- size-of-dictionary )
  here text-base -
;

: save-forth ( str --- )
  dup make  0= abort" Can't make file"
  dup write open fd !             \ make a new file and open for writing
  fd @ 0= 
  if   ." Can't open " ". cr abort
  else
       drop      \ get rid of filename
       text-size user-size +   gem-header 2 + l!  \ Fixup header

       gem-header  th 1c      fd @  fputs  \ Header for program files
       text-base   text-size  fd @  fputs  \ Dictionary image
       up@         user-size  fd @  fputs  \ Initial user area image
       zeroes      4          fd @  fputs  \ (null) relocation info

       fd @ close
  then
;
decimal
