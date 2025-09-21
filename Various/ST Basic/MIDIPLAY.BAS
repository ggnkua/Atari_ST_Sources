10    clear
30    gosub 1200
50    defint a-z :Z=500:  dim midarray(z)
100   fullw 2 : clearw 2
110   ?:?:?"                 Current File: ";Filename$:?:?
120   ?"1.       Record New Sequence"
130   ?"2.       Playback Sequence Once"
140   ?"3.       Playback Sequence 'x' Times"
155   ?"4.       Save Current Song"
156   ?"5.       Load A Song"
157   ?"6.       Stop"
160   ?:?:input "Enter Number Desired";INK
165   if ink > 7 goto 100
170   on ink gosub 1000,2000,2000,3000,4000,500
180   goto 100
500   end
1000  ?"Move Pitch Wheel to Finish"
1005  m=0:f=0: gosub 1200
1010  if m=0 and inp(-3)=0 then goto 1010
1020  if inp(-3)=0 then f=f+1:goto 1020
1040  a=inp(3)+256
1050  if a=224 then gosub 1200 : return
1070  if f>0 then midarray(m)=f+1000: m=m+1
1075  if m=z-1 then ? "Out of Memory": for del=1 to 100 : next: return
1080  midarray(m)=a
1120  f=0 :m=m+1
1160  goto 1020
1200  if inp(-3)=0 then return
1210  junk = inp(3) : goto 1200
2000  lc=1
2010  IF ink=3 then input "Repeat How Many Times";lc
2020  Input"Tempo <1 to 100>";tempo
2040  for c= 1 to lc
2060  b=0
2080  if midarray(b) < 1000 then 2100
2090  for loop=0 to int(midarray(b)-1000)/10 * tempo : next: b=b+1
2100  out 3,midarray(b)
2120  if b<m then b=b+1 : goto 2080
2140  next
2160  return
3000  rem 'save array onto disk file
3020  input "   Name of File (8 chars. or less, no extension) ";filename$
3030  filename$ = left$(filename$,8) + ".DAT"
3040  open "O",#1,filename$
3050  print# 1,m
3060  for loop = 0 to m
3070  print# 1,midarray(loop)
3080  next
3090  close
3100  return
4000  rem *** loads .dat file to midarray ***
4020  input "Name of File (No Extensions!!)";filename$
4025  filename$ = filename$ + ".DAT"
4030  open "I",#1,filename$
4040  input# 1,m
4050  for loop = 0 to m
4060  input#1,midarray(loop)
4070  next
4080  close
4090  return
