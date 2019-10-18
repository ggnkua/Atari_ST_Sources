open "I",#1,"\learnbas\words.lst" 
while not eof(1)
a=a+1
input#1,inp$
wend
close #1

dim chk(a)
dim a$(a)
a=0
open "I",#1,"\learnbas\words.lst" 
while not eof(1)
a=a+1
input#1,inp$
a$(a)=inp$
wend
close #1
score=0

start:
had$=""
cls
print


randomize timer

v=int(rnd*a)+1
d=len(a$(v))

	for c=1 to d
		print "_ ";
	next c

print
print
	
	for t = 12 to 1 step -1
	    retry:
		locate 3,1
		
		print
		print "You have";t;"chance(s) to guess the word. "
		locate 5,1
		print "                                          "
		locate 5,1
		input "Choose a letter and press Return: ",h$
		if len(h$)<>1 then goto retry

		had$=had$+" "+ucase$(h$)
		locate 15,1
		print had$

			for c=1 to d
				f=instr(c,a$(v),ucase$(h$))
				if f<>0 
					score=score+10
					locate 16,1
					print "SCORE:";score
					locate 1,(f*2)-1
					print mid$(a$(v),f,1)
					chk(f)=1
				end if
			next c

			ok=0
			for check=1 to d
				if chk(check)=1 then ok=ok+1
			next check
			if ok=d then exit for
		
	next t

locate 10,1

	if ok=d 
		print "WELL DONE"
		print
		print "Press any key..."
		while inkey$=""
		wend
		for check=1 to d
		chk(check)=0
		next
		goto start
	end if

print
print "SORRY. YOU FAILED."
print "THE WORD IS ";a$(v)
print
print "Press any key..."
while inkey$=""
wend
score=0
goto start



