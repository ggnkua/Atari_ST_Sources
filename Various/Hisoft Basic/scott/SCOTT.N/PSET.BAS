rem    PSET.BAS   plots a pixel at x,y(,color)
'    this programs plots a red sine wave.
'
pi=3.14159
for i=0 to 4*pi step 0.05
pset(i*50,100+100*sin(i)),2
next i
