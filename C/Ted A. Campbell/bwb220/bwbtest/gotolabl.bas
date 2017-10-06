Print "Hello"


goto test_label
Print "This should NOT print"


test_label:
gosub test_sub
Print "Goodbye"
End


test_sub:
   Print "This is the subroutine."
   gosub test_subsub
   Return


test_subsub:
   Print "This is the sub-subroutine."
   Return
