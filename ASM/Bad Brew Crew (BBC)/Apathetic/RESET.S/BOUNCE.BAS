rem sine table maker in 1st basic

n=&hc0000

count=0

for t=(3.1415927) to 0 step -.03

offset=76-(int(sin(t)*75))
count=count+4

print offset
pokel n,offset+1
n=n+4
next t

bsave "a:\bounce_y.bin",&hc0000,count