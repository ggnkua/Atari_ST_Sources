
rem ----------------------------------------------------
rem CallSub.BAS
rem ----------------------------------------------------

Print "CallSub.BAS -- Test BASIC Call and Sub Statements"
Print "The next printed line should be from the Subroutine."
Print
testvar = 17

Call TestSub 5, "Hello", testvar

Print
Print "This is back at the main program. "
Print "The value of variable <testvar> is now "; testvar

Print "Did it work?"
End

rem ----------------------------------------------------
rem Subroutine TestSub
rem ----------------------------------------------------

Sub TestSub( xarg, yarg$, tvar )
   Print "This is written from the Subroutine."
   Print "The value of variable <xarg> is"; xarg
   Print "The value of variable <yarg$> is "; yarg$
   Print "The value of variable <tvar> is "; tvar
   tvar = 99
   Print "The value of variable <tvar> is reset to "; tvar
End Sub

