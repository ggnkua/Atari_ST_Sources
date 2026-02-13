1     ' Peter Wollschlaeger's Quick & Dirty
2     ' A         B     C
3     ' Assembler Basic Converter (und zurÅck)
4     '
10    clearw 2:fullw 2
20    input"Name des Programms (*.PRG)";p$
30    p$=p$+".PRG"
40    print "Grîûe von ";p$;:input" in Bytes";b
45    b=int(b/16+0.5)*16
50    input"Name des Basic-Files (*.BAS)";b$
60    b$=b$+".BAS"
70    dim c%(b/2-1)
80    bload p$,varptr(c%(0))
90    open "O",1,b$
100   z=0:cs#=0
110   for i=1 to b/16
120   print #1,str$(i*10);" DATA ";
130   for j=1 to 8
140   print #1,right$("0000"+hex$(c%(z)),4);
150   if j<8 then print #1,",";
160   cs#=cs#+c%(z) :z=z+1
170   next j
180   print #1
190   next i
200   close #1
210   print "Die Checksum ist ";cs#
