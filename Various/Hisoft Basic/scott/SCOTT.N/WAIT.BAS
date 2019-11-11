rem        WAIT.BAS       with Right Mouse to continue
'
for n=1 to 5
print "pause"

for w=1 to 5000        ' delay for mouse to register right click
next w
while mouse(2)<2       ' wait for right click.
wend

next n
