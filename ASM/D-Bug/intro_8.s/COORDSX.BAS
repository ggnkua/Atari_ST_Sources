rem sine table maker in 1st basic

n=&hc0000
values=400

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/values

offset=int(143+(sin(t)*142))
count=count+2

pokew n,offset*2
n=n+2
next t

bsave "a:\coordsx.bin",&hc0000,count