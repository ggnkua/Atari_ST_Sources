
rem -----------------------------------------------------
rem elseif.bas -- Test MultiLine IF-ELSEIF-THEN statement
rem -----------------------------------------------------

Print "ELSEIF.BAS -- Test MultiLine IF-THEN-ELSE Constructions"

Print
Print "The program should detect if the number you enter is 4 or 5 or 6."
Input "Please enter a number, 1-9"; x

If x = 4 then
   Print "The number is 4."

Elseif x = 5 then
   Print "The number is 5."

Elseif x = 6 then
   Print "The number is 6."

Else
   Print "The number is neither 4 nor 5 nor 6."

End If

Print "This concludes our test."
