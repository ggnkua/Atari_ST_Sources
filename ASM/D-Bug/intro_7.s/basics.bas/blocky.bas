rem sine table maker in 1st basic

n=&hc0000
values=100

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/values

offset=int(110+(sin(t)*109))
count=count+4

pokel n,offset*160
n=n+4
next t

bsave "a:\block_y.bin",&hc0000,count