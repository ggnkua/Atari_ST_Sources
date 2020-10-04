' ***************************************
' * Simple REPLAY Demo for HISOFT Basic *
' *  by A.Racine (C) 2-BIT systems LTD  *
' ***************************************

Dim A%(2000),B%(5000)	: ' Reserve space for code and sample
Code&=Varptr(A%(0))		: ' Get the code address
Sample&=Varptr(B%(0))	: ' Get the sample address

' ***************************
' * Load code & Demo sample *
' ***************************

Print "Loading Code..."
Bload "BASCODE.EXE",Code&
Start&=Code&+28
Print "Loading Sample."
Bload "REPLAY.SPL",Sample&

' *************************
' * Sample data :-        *
' *   length = 6960 bytes *
' *   speed  = 4 (20 KHZ) *
' *************************

Length&=6960
Speed&=4

' ******************************
' * Poke Sample data into code *
' ******************************

Pokel Start&+2,Sample&
Pokel Start&+6,Length&
Pokel Start&+10,Speed&

' *************************
' * Now REPLAY the sample *
' *************************

Print "Playing Sample..."
Call Loc Start&
Print "Finished."
End
