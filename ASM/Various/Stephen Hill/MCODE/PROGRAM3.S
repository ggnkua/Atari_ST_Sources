
;   PROGRAM III...Input a capital letter, output lower case letter

;               ( Abacus Assempro-ST listing )

  MOVE.W #1,-(A7)    ; Put function number 1 (CONIN) on the stack
  TRAP #1            ; Use GEMDOS to read next keypress into D0
  ADD.L #2,A7        ; Restore stack pointer to the value before the TRAP
  ADD.W #32,D0       ; Add 32 to the ASCII code in register D0
  MOVE.W D0,-(A7)    ; Put the new ASCII value on the stack
  MOVE.W #2,-(A7)    ; Put function number 2 (CONOUT) on stack
  TRAP #1            ; Use GEMDOS to print it on the screen
  ADD.L #4,A7        ; Restore stack pointer to value before TRAP

;  RTS               ; Use this if called from another program

  MOVE.W #0,-(A7)    ; Put function number 0 on stack
  TRAP #1            ; Return to Desktop
  END

 