rem SelCase.bas  -- test SELECT CASE

Sub Main
   Print "SelCase.bas -- test SELECT CASE statement"
   Input "Enter a number"; d

   Select Case d

      Case 3 to 5
         Print "The number is between 3 and 5."

      Case 6
         Print "The number you entered is 6."

      Case 7 to 9
         Print "The number is between 7 and 9."

      Case If > 10
         Print "The number is greater than 10"

      Case If < 0
         Print "The number is less than 0"

      Case Else
         Print "The number is 1, 2 or 10."

   End Select

End Sub


