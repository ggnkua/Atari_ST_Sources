rem        WHILE.BAS       While Right Mouse button held, continue.
'
for n=1 to 15
print "Hold right mouse to continue."

for w=1 to 5000        ' delay for mouse to register right click
next w
while mouse(2)<2       ' wait for right click.
wend

next n
