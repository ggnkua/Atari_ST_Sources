REM The Spirals program discussed in the
REM Tutorial chapter of the HiSoft BASIC 2
REM manual.
REM modifications by A.LOVATT

REM $include a:\basic\turtle.bas

REM The actual spiral routine.
sub spirals (L,A)
  fwd L
  right A
  if L<150 THEN spirals L+1,A
end sub

main:

REM Set this up for a particular screen size.
curx=300 : cury=90 : dir=0

MOUSE -1
DO
curx=300 : cury=90 : dir=0
RANDOMIZE TIMER
a=RND(1)*15
b=(RND(1)*90)+90
spirals a,b
LOCATE 1,1:? a:LOCATE 2,1:? b
DO
a$=INKEY$
LOOP UNTIL a$<>""
CLS
LOOP UNTIL a$="s"
MOUSE 0
