rem     STOP.BAS   CONTROL/C; or Input -0; (or Right Mouse?) then RETURN.
'
Print "Press CONTROL/C, or -0, (or Right Mouse key?) to STOP, then Return."
do
if mouse(2)=2 then          ' right click
stop                        ' not working !!!
end if
print "Enter the first number you want to add..."
input x
if x=-0 then                 ' a non-sence figure, to exit.
stop
end if
Print "Enter the second number..."
input y
print "Total = ";x+y
loop


