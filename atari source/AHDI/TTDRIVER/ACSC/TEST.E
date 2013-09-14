1 store-macro
  1 redraw-display
!endm

bind-to-key execute-macro-1 M-!

2 store-macro
*loop
  !force search-forward equ
  !if &not $status
    !goto end
  !endif
  3 delete-previous-character
  insert-string =
  !goto loop
*end
!endm
