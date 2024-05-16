rem sine table maker in 1st basic

n=&hc0000

count=0

for t=0 to (3.1415927*2) step .032

offset=int(152+(sin(t)*151))
count=count+2

pokew n,1+offset
n=n+2
next t

bsave "a:\trk_x.bin",&hc0000,count