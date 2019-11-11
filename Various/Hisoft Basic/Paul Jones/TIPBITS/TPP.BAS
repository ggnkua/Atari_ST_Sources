REM TPP - The Power Protector
REM Date : 1/10/1996
REM Date : 5/10/1996 - All En/de-cryption rutines installed
REM                    GEM included

REM $option !gy
REM $option k10
REM $include toolbox.bas

DEFINT a-z
wx=PEEKW(SYSTAB+58)
wy=PEEKW(SYSTAB+60)
ww=PEEKW(SYSTAB+62)
wh=PEEKW(SYSTAB+64)

WINDOW OPEN 1," TPP - The Power Protector V0.06 ",wx,wy,ww,wh,win_all
WINDOW NAME 1," TPP - The Power Protector V0.06 "," TPP "

REM 1=Title bar
REM 2=Close box
REM 4=Full box
REM 8=Move box
REM 16=Info line
REM 32=Size box
REM 64=Up arrow
REM 128=Down arrow
REM 256=Vertical slider
REM 512=Left Arrow
REM 1024=Right arrow
REM 2048=Horizontal slider

WINDOW OUTPUT 1

WINDOW CONTRL 1,3,1000
WINDOW CONTRL 1,2,1000

WINDOW ON

 
PRINT
PRINT "          TPP¿ V0.06"
PRINT "             The Power Protector"
PRINT "                By Paul Jones"
PRINT
PRINT "Type 'COMMANDS' for list of commands"
PRINT

SUB info
END SUB

SUB comlist
PRINT
PRINT "Command list:-"
PRINT
PRINT "Type in a file name for en/de-cryption"
PRINT "Type in 'EXIT' to quit"
PRINT "Type in 'INFO' for info"
PRINT
END SUB

SUB decrypt
STATIC a$,b$,a$,dummy$,dummy2$,pa,l&,f2$,p$,g$,b,c,p,d,ch,ch$,r,b2,ch2
SHARED a$,b$,a$,dummy$,dummy2$,pa,l&,f2$,p$,g$,b,c,p,d,ch,ch$,r,b2,ch2

ch=0
PRINT
PRINT "Decryption code - Version 0.2 - 5/10/1996"
PRINT "½copyright Paul Jones to TPP¿"
PRINT
a$=UCASE$(a$)
PRINT "Are you sure you want to decrypt the file '"+a$+"'?"
PRINT "Answer: Y/N: ";
WINDOW NAME 1," TPP - The Power Protector V0.06 "," Input: "

DO
b$=INKEY$
LOOP UNTIL UCASE$(b$)="N" OR UCASE$(b$)="Y"
PRINT b$
IF UCASE$(b$)="N" THEN PRINT "Aborted..." : PRINT : EXIT SUB

OPEN a$ FOR INPUT AS #1
l&=LOF(1)
FOR pa=1 TO 3
dummy$=dummy$+INPUT$ (1,#1)
ch=ch+1
NEXT pa
IF dummy$<>"TPP" THEN PRINT "Not TPP file..." : CLOSE #1 : EXIT SUB
dummy$=INPUT$ (1,#1)
ch=ch+1
ch$=dummy$
ch2=ch
IF ch$=CHR$(1) THEN

pa=1

DO
dummy$=INPUT$(1,#1)
ch=ch+1
IF dummy$<>CHR$(0) THEN dummy2$=dummy2$+dummy$
LOOP UNTIL dummy$=CHR$(0)

f2$=dummy2$
dummy2$=""
dummy$=""

PRINT "Multi-encryption selected..."
PRINT
PRINT "File input: "+a$
PRINT "File output: "+f2$
LINE INPUT "Password?: ",p$
PRINT
PRINT "Pre-encrypting... ";

IF FEXISTS(a$)=0 THEN PRINT "error, could not find file." : PRINT : EXIT SUB

PRINT "done."

WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 000% completed "

PRINT "Decrypting..."

OPEN f2$ FOR OUTPUT AS #2

FOR pa=1 TO l&-ch
g$=INPUT$ (1,#1)
b=ASC(g$)
FOR c=1 TO LEN(p$)
b=b XOR ASC(MID$(p$,c,1))
NEXT c

PRINT #2,CHR$(b);

p=(pa/l&)*100
p=CINT(p)
IF p=5 AND d=0 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 005% completed " : d=1
IF p=10 AND d=1 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 010% completed " : d=2
IF p=15 AND d=2 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 015% completed " : d=3
IF p=20 AND d=3 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 020% completed " : d=4
IF p=25 AND d=4 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 025% completed " : d=5
IF p=30 AND d=5 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 030% completed " : d=6
IF p=35 AND d=6 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 035% completed " : d=7
IF p=40 AND d=7 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 040% completed " : d=8
IF p=45 AND d=8 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 045% completed " : d=9
IF p=50 AND d=9 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 050% completed " : d=10
IF p=55 AND d=10 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 055% completed " : d=11
IF p=60 AND d=11 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 060% completed " : d=12
IF p=65 AND d=12 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 065% completed " : d=13
IF p=70 AND d=13 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 070% completed " : d=14
IF p=75 AND d=14 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 075% completed " : d=15
IF p=80 AND d=15 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 080% completed " : d=16
IF p=85 AND d=16 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 085% completed " : d=17
IF p=90 AND d=17 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 090% completed " : d=18
IF p=95 AND d=18 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 095% completed " : d=19
IF p=100 AND d=19 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 100% completed " : d=20
NEXT pa

d=0
CLOSE #1
CLOSE #2
PRINT
PRINT "File conversion finished."
WINDOW NAME 1," TPP - The Power Protector V0.06 "," TPP "
END IF

IF ch$=CHR$(2) THEN
ch=ch2
pa=1

DO
dummy$=INPUT$(1,#1)
ch=ch+1
IF dummy$<>CHR$(0) THEN dummy2$=dummy2$+dummy$
LOOP UNTIL dummy$=CHR$(0)

f2$=dummy2$
dummy2$=""
dummy$=""

PRINT "Part-decryption selected..."
PRINT
PRINT "File input: "+a$
PRINT "File output: "+f2$
WINDOW NAME 1," TPP - The Power Protector V0.06 "," Input: "
LINE INPUT "Password?: ",p$
PRINT
PRINT "Pre-encrypting... ";

IF FEXISTS(a$)=0 THEN PRINT "error, could not find file." : PRINT : EXIT SUB

PRINT "done."

PRINT "Decrypting..."
r=0

OPEN f2$ FOR OUTPUT AS #2

FOR pa=1 TO l&-ch
g$=INPUT$ (1,#1)
b=ASC(g$)

r=r+1 : IF r>LEN(p$) THEN r=1

b2=b XOR ASC(MID$(p$,r,1))

PRINT #2,CHR$(b2);

p=(pa/l&)*100
p=CINT(p)
IF p=5 AND d=0 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 005% completed " : d=1
IF p=10 AND d=1 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 010% completed " : d=2
IF p=15 AND d=2 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 015% completed " : d=3
IF p=20 AND d=3 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 020% completed " : d=4
IF p=25 AND d=4 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 025% completed " : d=5
IF p=30 AND d=5 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 030% completed " : d=6
IF p=35 AND d=6 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 035% completed " : d=7
IF p=40 AND d=7 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 040% completed " : d=8
IF p=45 AND d=8 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 045% completed " : d=9
IF p=50 AND d=9 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 050% completed " : d=10
IF p=55 AND d=10 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 055% completed " : d=11
IF p=60 AND d=11 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 060% completed " : d=12
IF p=65 AND d=12 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 065% completed " : d=13
IF p=70 AND d=13 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 070% completed " : d=14
IF p=75 AND d=14 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 075% completed " : d=15
IF p=80 AND d=15 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 080% completed " : d=16
IF p=85 AND d=16 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 085% completed " : d=17
IF p=90 AND d=17 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 090% completed " : d=18
IF p=95 AND d=18 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 095% completed " : d=19
IF p=100 AND d=19 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Decrypting - 100% completed " : d=20
NEXT pa

d=0
CLOSE #1
CLOSE #2
PRINT
PRINT "File conversion finished."
PRINT
WINDOW NAME 1," TPP - The Power Protector V0.06 "," TPP "
END IF

END SUB

SUB encrypt
STATIC a$,b$
SHARED a$,b$

PRINT
PRINT "Encryption code - Version 0.2 - 5/10/1996"
PRINT "½copyright Paul Jones to TPP¿"
PRINT
a$=UCASE$(a$)
PRINT "Are you sure you want to encrypt the file '"+a$+"'?"
PRINT "Answer: Y/N: ";
WINDOW NAME 1," TPP - The Power Protector V0.06 "," Input: "

DO
b$=INKEY$
LOOP UNTIL UCASE$(b$)="N" OR UCASE$(b$)="Y"
PRINT b$
IF UCASE$(b$)="N" THEN PRINT "Aborted..." : PRINT : EXIT SUB

PRINT
PRINT "Please select type of encryption:"
PRINT "1 - Multi-encrypt."
PRINT "2 - Part-encrypt."
PRINT "3 - Help"
PRINT
PRINT "Please select: ";

DO
b$=INKEY$

IF b$="3" THEN
PRINT
PRINT
PRINT "Type 1 - Multi-encrypt. Each character of the file is encrypted"
PRINT "         with the password. Excelent protection, but suffers"
PRINT "         in the speed department. Best type. Default."
PRINT
PRINT "Type 2 - Part-encrypt. Character by character is encrypted."
PRINT "         Faster the Multi-encrypt, protection not as good as"
PRINT "         Multi-encrypt. Worst type."
PRINT
PRINT "Please select type of encryption:"
PRINT "1 - Multi-encrypt."
PRINT "2 - Part-encrypt."
PRINT "3 - Help"
PRINT 
PRINT "Please select:";
END IF

LOOP UNTIL b$="1" OR b$="2"
PRINT b$
PRINT

IF b$="1" THEN CALL multien
IF b$="2" THEN CALL parten
END SUB

SUB parten
STATIC a$,l&,dummy$,p$,f2$,pa&,p,b,g$,p$,c,d,r,b2
SHARED a$,l&,dummy$,p$,f2$,pa&,p,b,g$,p$,c,d,r,b2

PRINT "Part-encryption selected..."
PRINT
PRINT "File input: "+a$
PRINT "File output: ";
f2$=MID$(a$,1,LEN(a$)-3)+"TPP"
PRINT f2$
WINDOW NAME 1," TPP - The Power Protector V0.06 "," Input: "
LINE INPUT "Password?: ",p$
PRINT "Password: '"+p$+"'"
PRINT
PRINT "Pre-encrypting... ";

IF FEXISTS(a$)=0 THEN PRINT "error, could not find file." : PRINT : EXIT SUB

IF FEXISTS(a$) THEN
OPEN a$ FOR INPUT AS #1
l&=LOF(1)
CLOSE #1
PRINT "done."

PRINT "Encrypting..."

OPEN a$ FOR INPUT AS #1
OPEN f2$ FOR OUTPUT AS #2

REM Send options to file.
REM Type 2 - Part

PRINT #2,"T";
PRINT #2,"P";
PRINT #2,"P";
PRINT #2,CHR$(2); 

REM Output name, with a null terminator

FOR pa&=1 TO LEN(a$)
PRINT #2,MID$(a$,pa&,1);
NEXT pa&
PRINT #2,CHR$(0);

FOR pa&=1 TO l&
g$=INPUT$ (1,#1)
b=ASC(g$)

r=r+1 : IF r>LEN(p$) THEN r=1

b2=b XOR ASC(MID$(p$,r,1))

PRINT #2,CHR$(b2);

p=(pa&/l&)*100
p=CINT(p)
IF p=5 AND d=0 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 005% completed " : d=1
IF p=10 AND d=1 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 010% completed " : d=2
IF p=15 AND d=2 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 015% completed " : d=3
IF p=20 AND d=3 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 020% completed " : d=4
IF p=25 AND d=4 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 025% completed " : d=5
IF p=30 AND d=5 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 030% completed " : d=6
IF p=35 AND d=6 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 035% completed " : d=7
IF p=40 AND d=7 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 040% completed " : d=8
IF p=45 AND d=8 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 045% completed " : d=9
IF p=50 AND d=9 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 050% completed " : d=10
IF p=55 AND d=10 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 055% completed " : d=11
IF p=60 AND d=11 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 060% completed " : d=12
IF p=65 AND d=12 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 065% completed " : d=13
IF p=70 AND d=13 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 070% completed " : d=14
IF p=75 AND d=14 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 075% completed " : d=15
IF p=80 AND d=15 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 080% completed " : d=16
IF p=85 AND d=16 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 085% completed " : d=17
IF p=90 AND d=17 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 090% completed " : d=18
IF p=95 AND d=18 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 095% completed " : d=19
IF p=100 AND d=19 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 100% completed " : d=20
NEXT pa&

d=0
CLOSE #1
CLOSE #2
PRINT
PRINT "File conversion finished."
PRINT
WINDOW NAME 1," TPP - The Power Protector V0.06 "," TPP "
END IF
END SUB

SUB multien
STATIC a$,l&,dummy$,p$,f2$,pa&,p,b,g$,p$,c,d
SHARED a$,l&,dummy$,p$,f2$,pa&,p,b,g$,p$,c,d

PRINT "Multi-encryption selected..."
PRINT
PRINT "File input: "+a$
PRINT "File output: ";
f2$=MID$(a$,1,LEN(a$)-3)+"TPP"
PRINT f2$
WINDOW NAME 1," TPP - The Power Protector V0.06 "," Input: "
LINE INPUT "Password?: ",p$
PRINT
PRINT "Pre-encrypting... ";

IF FEXISTS(a$)=0 THEN PRINT "error, could not find file." : PRINT : EXIT SUB

IF FEXISTS(a$) THEN
OPEN a$ FOR INPUT AS #1
l&=LOF(1)
CLOSE #1
PRINT "done."

PRINT "Encrypting..."

OPEN a$ FOR INPUT AS #1
OPEN f2$ FOR OUTPUT AS #2

REM Send options to file.
REM Type 1 - Multi

PRINT #2,"T";
PRINT #2,"P";
PRINT #2,"P";
PRINT #2,CHR$(1); 

FOR pa&=1 TO LEN(a$)
PRINT #2,MID$(a$,pa&,1);
NEXT pa&
PRINT #2,CHR$(0);

FOR pa&=1 TO l&
g$=INPUT$ (1,#1)
b=ASC(g$)
FOR c=1 TO LEN(p$)
b=b XOR ASC(MID$(p$,c,1))
NEXT c

PRINT #2,CHR$(b);

p=(pa&/l&)*100
p=CINT(p)
IF p=5 AND d=0 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 005% completed " : d=1
IF p=10 AND d=1 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 010% completed " : d=2
IF p=15 AND d=2 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 015% completed " : d=3
IF p=20 AND d=3 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 020% completed " : d=4
IF p=25 AND d=4 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 025% completed " : d=5
IF p=30 AND d=5 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 030% completed " : d=6
IF p=35 AND d=6 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 035% completed " : d=7
IF p=40 AND d=7 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 040% completed " : d=8
IF p=45 AND d=8 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 045% completed " : d=9
IF p=50 AND d=9 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 050% completed " : d=10
IF p=55 AND d=10 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 055% completed " : d=11
IF p=60 AND d=11 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 060% completed " : d=12
IF p=65 AND d=12 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 065% completed " : d=13
IF p=70 AND d=13 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 070% completed " : d=14
IF p=75 AND d=14 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 075% completed " : d=15
IF p=80 AND d=15 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 080% completed " : d=16
IF p=85 AND d=16 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 085% completed " : d=17
IF p=90 AND d=17 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 090% completed " : d=18
IF p=95 AND d=18 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 095% completed " : d=19
IF p=100 AND d=19 THEN WINDOW NAME 1," TPP - The Power Protector V0.06 "," Encrypting - 100% completed " : d=20
NEXT pa&

d=0
CLOSE #1
CLOSE #2
PRINT
PRINT "File conversion finished."
WINDOW NAME 1," TPP - The Power Protector V0.06 "," TPP "
END IF
END SUB

SUB endecrypt
STATIC a$
SHARED a$
IF RIGHT$(a$,3)="TPP" THEN CALL decrypt ELSE CALL encrypt
END SUB

DO
LINE INPUT "Option: ",a$
a$=UCASE$(a$)
IF a$="COMMANDS" THEN CALL comlist
IF a$="EXIT" THEN EXIT DO
IF a$="INFO" THEN CALL info
IF FEXISTS(a$) THEN CALL endecrypt
LOOP UNTIL a$="EXIT"
STOP -1