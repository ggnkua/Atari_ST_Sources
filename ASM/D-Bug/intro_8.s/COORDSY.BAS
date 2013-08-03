rem sine table maker in 1st basic

n=&hc0000
values=500

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/values

offset=int(87+(sin(t)*86))
count=count+4

pokel n,offset*640
n=n+4
next t

bsave "a:\coordsy.bin",&hc0000,count