; This procedure digests a C structure and produces an assembly source
; file with equates for the elements' offsets.
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
; The script produced will generate a list of aliases, the first of
; which is the name of the structure, and takes a pointer as an
; argument.  The rest have the same name with a leading underscore.
;

store-procedure region-to-equ

; copy the region in question
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

; set up the .s file buffer and create the initial equate

  set %sbname &cat %sname ".s"
  select-buffer %sbname
  unmark-buffer
  clear-buffer %sbname

  insert-string &cat "* equates for C structure " %sname
  newline

  set %pfield "NONE"
  set %psize 0

; for each field, create an EQU

*fieldloop:

  select-buffer +scratch+
  !force search-forward "[A-Za-z_][^ *[,;)]*[[,;)]"
  !if &! $status
    !goto done
  !endif
  set %fname &left $match &- &len $match 1
  
  update-screen
  print &cat &cat %fname ": <w>ord <l>ong 0-9a-f or <o>ther: "
  set %size &gtk
  !if &= &asc %size 7
    !return
  !endif

  select-buffer %sbname
  insert-string %fname
  handle-tab
  insert-string "equ~t"
  !if &s= %pfield "NONE"
    insert-string 0
  !else
    insert-string &cat &cat %pfield "+$" %psize
  !endif

  !if &s= %size w
    set %psize 2
  !else
    !if &s= %size l
      set %psize 4
    !else
      !if &s= %size o
	set %psize &cat %fname "_SIZE_HERE"
      !else
	; hex-digit case: add the input character to the last symbol
	set %psize %size
      !endif
    !endif
  !endif

  set %pfield %fname

  next-line
  !goto fieldloop

*done
  select-buffer %sbname
  !force delete-buffer +scratch+
  insert-string &cat %sname "_size"
  handle-tab
  insert-string &cat &cat &cat "equ~t" %pfield "+$" %psize
  next-line
  print "done."
!endm
