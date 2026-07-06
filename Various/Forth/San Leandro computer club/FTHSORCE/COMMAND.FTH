\ File manipulation command set for Forth on the Atari 520
\ Missing: copy
decimal
create string2  256 allot
: (rename ( old-name-string new-name-string -- )
  swap 0 f_rename abort" rename failed"
;
: rename ( -- )  ( Input stream: old-name new-name )
  bl word ( old-name-str ) string2 "copy string2
  bl word ( old-name-str new-name-str )
  (rename
;
: .dir ( -- )
  0 cstrbuf d_getpath
  cstrbuf fstr
  count type
;
: .filename
  pad td 30 + fstr count type
;
variable dir-attributes  0 dir-attributes !
: first-file ( str -- another? )
  pad f_setdta
  dir-attributes @ swap f_sfirst
  0=
;
: another-file? ( -- another? )
  f_snext 0=
;
: (files ( match-str -- )
  td 14 tabstops !
  first-file  ( another? )
  begin
  while
      td 14 .tab .filename
      another-file?
  repeat
;
: files ( -- )
  ["] *.*" (files
;
: (cd ( path -- )
  d_setpath abort" Can't change directory"
;
: cd ( -- ) ( Input stream: directory )
  bl word (cd
;
: (md ( path -- )
  d_create abort" Can't make directory"
;
: md ( -- ) ( Input stream: directory )
  bl word (md
;
: (rd ( path -- )
  d_delete abort" Can't remove directory"
;
: rd ( -- ) ( Input stream: directory )
  bl word (rd
;
: (del ( path -- )
  f_delete abort" Can't remove file"
;
: del ( -- ) ( Input stream: directory )
  bl word (del
;

alias dir files
alias pwd .dir
alias mv  rename
alias ls  dir
alias chdir cd
alias mkdir md
alias rmdir rd
alias rm    del
alias era   del

: zapaes ( -- )
  1 th 482 w!    \ Set cmdload variable to 1 so COMMAND.PRG will be loaded
  puntaes        \ Throw away Gem AES and reboot
;
