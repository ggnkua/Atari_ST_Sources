rem sine table maker in 1st basic

n=&hc0000

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/200

offset=int(138+(sin(t)*137))
count=count+4

pokel n,offset*160
n=n+4
next t

bsave "a:\logo_y.bin",&hc0000,count