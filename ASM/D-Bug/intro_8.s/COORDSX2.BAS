rem sine table maker in 1st basic

n=&hc0000
values=700

count=0

for t=0 to (3.1415927*2) step (3.1415927*2)/values

offset=int(143+(sin(t)*142))
count=count+4

pokew n,offset*2
pokew n+2,((offset*2) mod 3)*2
n=n+4
next t

bsave "a:\coordsx2.bin",&hc0000,count