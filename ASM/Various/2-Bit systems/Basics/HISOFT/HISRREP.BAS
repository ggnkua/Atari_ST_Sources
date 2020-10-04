' ****************************************
' * REPLAY effects Demo for HISOFT Basic *
' *  by A.Racine  (C) 2-BIT systems LTD  *
' ****************************************

Dim A%(2000),B%(5000)	: ' Reserve memory for code & sample
Code&=Varptr(A%(0))		: ' Get code address
Sample&=Varptr(B%(0))	: ' Get sample address

' ***************************
' * Load code & Demo sample *
' ***************************

Print "Loading Code..."
Bload "BASCODE.EXE",Code&
Start&=Code&+28
Print "Loading Sample."
Bload "REPLAY.SPL",Sample&

' ***************
' * Set up Loop *
' ***************

Print "Playing Sample Segments.."
For Loop%=1 To 19

  ' ********************
  ' * Read Sample data *
  ' ********************

  Read Offset&,Length&,Speed&

  ' ******************************
  ' * Poke Sample data into code *
  ' ******************************

  Pokel Start&+2,Sample&+Offset&
  Pokel Start&+6,Length&
  Pokel Start&+10,Speed&

  ' *********************************
  ' * Now REPLAY the sample section *
  ' *********************************

  Call Loc Start&
Next Loop%
Print "Finished."
End

' ***********************************
' * The REPLAY Sample Segment table *
' ***********************************

Data 0,6960,0, 0,6960,1, 0,6960,2, 0,6960,3, 0,6960,4
Data 0,1320,4, 0,1320,4, 0,1320,4, 0,1320,4, 0,6960,4
Data 0,6960,4, 3600,1332,4, 3600,1332,4, 3600,3360,4
Data 0,1328,0, 0,1328,1, 0,1328,2, 0,1328,3, 0,6960,4
