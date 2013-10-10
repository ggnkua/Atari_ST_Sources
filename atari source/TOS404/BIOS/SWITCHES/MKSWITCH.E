; Switches files are...
; 
; [eptw] [ao] [ugfksiwabtcnd]
; 
; They have a common header, then ...
; 
; 	TT = t
;	STPAD = p
;	SPARROW = w
;	systype = ram/rom
;	country = [country]

store-procedure make-switches
  set %machine e
  set %systype a
  run do-countries

  set %machine p
  set %systype a
  run do-countries

  set %machine t
  set %systype a
  run do-countries

  set %machine w
  set %systype a
  run do-countries

  set %machine e
  set %systype o
  run do-countries

  set %machine p
  set %systype o
  run do-countries

  set %machine t
  set %systype o
  run do-countries

  set %machine w
  set %systype o
  run do-countries
!endm

store-procedure do-countries
  set %ccode u
  run dofile
  set %ccode g
  run dofile
  set %ccode f
  run dofile
  set %ccode k
  run dofile
  set %ccode s
  run dofile
  set %ccode i
  run dofile
  set %ccode w
  run dofile
  set %ccode a
  run dofile
  set %ccode b
  run dofile
;  set %ccode t
;  run dofile
;  set %ccode c
;  run dofile
;  set %ccode n
;  run dofile
;  set %ccode d
;  run dofile
!endm

; args to this procedure are:
;	%machine	e, p, w, or t
;	%ccode		the one-letter country code
;	%systype	a or o (ram or rom)

store-procedure dofile
	print &cat "* switches file for " &cat &cat %machine %systype %ccode
	beginning-of-file
	set-mark
	end-of-file
	kill-region
	insert-string &cat "* switches file for " &cat &cat %machine %systype %ccode
	newline

	insert-string "rom equ 0~n"
	insert-string "ram equ 1~n"
	insert-string "usa equ 0~n"
	insert-string "uk equ 1~n"
	insert-string "germany equ 2~n"
	insert-string "france equ 3~n"
	insert-string "spain equ 4~n"
	insert-string "sweden equ 5~n"
	insert-string "italy equ 6~n"
	insert-string "swissfra equ 7~n"
	insert-string "swissger equ 8~n"
	insert-string "turkey equ 9~n"
	insert-string "finland equ 10~n"
	insert-string "norway equ 11~n"
	insert-string "denmark equ 12~n"

	!if &seq %machine "t"
		insert-string "TT = 1~n"
	!else
		insert-string "TT = 0~n"
	!endif

	!if &seq %machine "w"
		insert-string "SPARROW = 1~n"
	!else
		insert-string "SPARROW = 0~n"
	!endif

	!if &seq %machine "p"
		insert-string "STPAD = 1~n"
	!else
		insert-string "STPAD = 0~n"
	!endif

	!if &seq %systype "a"
		insert-string "systype = ram~n"
	!else
		insert-string "systype = rom~n"
	!endif

	!if &seq %ccode "u"
		insert-string "country = usa~n"
	!endif
	!if &seq %ccode "g"
		insert-string "country = germany~n"
	!endif
	!if &seq %ccode "f"
		insert-string "country = france~n"
	!endif
	!if &seq %ccode "k"
		insert-string "country = uk~n"
	!endif
	!if &seq %ccode "s"
		insert-string "country = spain~n"
	!endif
	!if &seq %ccode "i"
		insert-string "country = italy~n"
	!endif
	!if &seq %ccode "w"
		insert-string "country = sweden~n"
	!endif
	!if &seq %ccode "a"
		insert-string "country = swissfra~n"
	!endif
	!if &seq %ccode "b"
		insert-string "country = swissger~n"
	!endif
	!if &seq %ccode "t"
		insert-string "country = turkey~n"
	!endif
	!if &seq %ccode "c"
		insert-string "country = finland~n"
	!endif
	!if &seq %ccode "n"
		insert-string "country = norway~n"
	!endif
	!if &seq %ccode "d"
		insert-string "country = denmark~n"
	!endif
	write-file &cat "switches." &cat %machine &cat %systype %ccode
!endm
