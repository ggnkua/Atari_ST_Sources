; This procedure digests a C structure and produces a debugger script
; file which prints the contents of the structure.
;
;
; Instructions: set dot at the top of the structure definition,
; and mark at the end (at or after the closing brace).
; Then say "region-to-script" to execute this procedure.
;
; The structure is copied to a scratch buffer, and stripped of
; comments and blank lines.  Then you are prompted for the size
; of each element.  GET IT RIGHT.  If you don't know yet, say 'o'ther.
;
; Don't use commas in the structure definition.
;
; Be sure the structure definition starts with "struct [name]"
; and then either a space (as in "[name] {") or a newline (optionally
; preceded by a comment).  The line with the { on it must not also
; have a field on it: "{ int foo;" is not allowed. 
;
; The script produced will generate a list of aliases, the first of
; which is the name of the structure, and takes a pointer as an
; argument.  The rest have the same name with a leading underscore.
;
; The script produced uses t0.
;

store-procedure region-to-script

; get the region in question
  copy-region

; set up scratch buffer
  set %bname $cbufname
  !force delete-buffer +scratch+
  !if &! $status
    print "please make sure buffer +scratch+ is not displayed and try again."
    !return
  !endif
  select-buffer +scratch+
  add-mode magic
  yank

; remove comments and blank lines, and the last line with a } on it
  beginning-of-file
  replace-string "~t" " "
  beginning-of-file
  replace-string "/\*.*\*/" ""
  beginning-of-file
  replace-string "[ ~t]*~n" ~n
  end-of-file
  set-mark
  search-reverse "}"
  beginning-of-line
  kill-region
  unmark-buffer

; get the base name

  beginning-of-file
*sagain
  search-forward "[A-Za-z_][A-Za-z0-9_]*"
  !if &|| &s= $match "extern" &|| &s= $match "struct" &s= $match "typedef"
    !goto sagain
  !endif
  set %sname $match

; set up the DB script buffer and create the initial alias

  set %sbname &cat %sname ".db"
  select-buffer %sbname
  unmark-buffer
  clear-buffer %sbname

  insert-string &cat &cat &cat &cat "alias " %sname " 'defer _" %sname "1;xt0'"
  newline

  set %sname &cat "_" %sname
  set %snumber 1

; for each field, create an alias

*fieldloop:

  select-buffer +scratch+
  !force search-forward "[A-Za-z_][^ *[,;)]*[[,;)]"
  !if &! $status
    !goto done
  !endif
  set %fname &left $match &- &len $match 1

  update-screen
  print &cat &cat %fname ": <w>ord <l>ong <s>tring 0-9a-f or <o>ther: "
  set %size &gtk
  !if &= &asc %size 7
    !return
  !endif

  select-buffer %sbname
  insert-string &cat &cat "alias " %sname %snumber 
  insert-string &cat " 'print " %fname
  
  !if &s= %size w
    insert-string " (wpeek `t0);xt0 (+ `t0 2)"
  !else
    !if &s= %size l
      insert-string " (lpeek `t0);xt0 (+ `t0 4)"
    !else
      !if &s= %size s
	insert-string " -s (lpeek `t0);xt0 (+ `t0 4)"
      !else
	!if &s= %size o
	  insert-string " PRINT_EXP_HERE;xt0 (+ `t0 SIZE_HERE)"
	!else
	  insert-string &cat &cat " PRINT_EXP_HERE;xt0 (+ `t0 " %size ")"
        !endif
      !endif
    !endif
  !endif

  set %snumber &+ %snumber 1
  insert-string &cat &cat &cat ";" %sname %snumber "'"
  next-line
  !goto fieldloop

*done
  unmark-buffer
  select-buffer %sbname
  delete-buffer +scratch+
  end-of-file
  set-mark
  search-reverse ";_"
  kill-region
  insert-string "'"
  next-line
  unmark-buffer
  print "done."
!endm
