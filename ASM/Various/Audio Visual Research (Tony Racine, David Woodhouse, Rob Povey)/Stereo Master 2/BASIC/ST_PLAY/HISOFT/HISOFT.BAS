' ***************************************
' * Simple SAMPLE Demo for HISOFT Basic *
' *  by A.Racine (C) 2-BIT systems LTD  *
' ***************************************

	Library "SAMPLER"

Dim A%(13000)			' Reserve space for sample
Sample&=Varptr(A%(0))	' Get the sample start address

' ***************************
' * Load code & Demo sample *
' ***************************

Print "Loading Sample."
Bload "SAMPLE.SAM",Sample&
Start& = Sample& + 12	' Add offset for sample header
Length& = 25000			' Sample length in BYTES

' ***************
' * Set up Loop *
' ***************

Print "Playing Sample at different speeds ...."

For Loop% = 0 To 4

  ' *******************************
  ' * Now PLAY the sample section *
  ' *******************************

  print "Speed = ";Loop%
  frequency Loop%
  play Start&,Length&,0

  ' *********************************
  ' * And wait for sample to finish *
  ' *********************************

  wait
Next Loop%
print

  ' *************************
  ' * Play sample backwards *
  ' *************************

print "Now play the sample backwards 5 times ...."

back Start&,Length&,1		' LOOP mode on

for Loop% = 1 to 5
  print Loop%;" ";
  wait						' Wait for end of sample
next Loop%

halt						' Stop the looping sample
Print
Print "Finished."
Stop
