rem     STOP.BAS   CONTROL/C; Input -0
'
Print "Press CONTROL/C, or -0 to STOP, then Return."
do
print "Enter the first number you want to add..."
input x
if x=-0 then                ' a nonsence number
stop
end if
Print "Enter the second number..."
input y
print "Total = ";x+y
loop


