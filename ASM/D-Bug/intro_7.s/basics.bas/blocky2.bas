rem sine table maker in 1st basic

n=&hc0000
values=30
range=20

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/values

offset=int(range+(sin(t)*(range-1)))
count=count+4

pokel n,offset*160+((110-range)*160)
n=n+4
next t

bsave "a:\block_y7.bin",&hc0000,count