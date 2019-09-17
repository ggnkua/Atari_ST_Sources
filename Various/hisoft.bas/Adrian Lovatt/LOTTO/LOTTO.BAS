DEFINT a-z

REM $include toolbox.bas
REM $include menu.bas
REM $include dialog.bas

REM $option y,k50
REM $include a:\lotto\lotto.bh

DIM SHARED num$(6)

SUB choose
STATIC i,d,d$
LOCAL temp(50)
RANDOMIZE TIMER
FOR i=1 TO 6
  DO
  d=(RND*48)+1
  LOOP UNTIL temp(d)=0
  temp(d)=1
  d$=FORMATI$(d,"##")
  num$(i)=d$
NEXT i
sort
END SUB

SUB sort
LOCAL x,y
FOR x=1 TO 6
FOR y=x TO 6
IF VAL(num$(x))>VAL(num$(y)) THEN SWAP num$(x),num$(y)
NEXT y
NEXT x
END SUB

SUB store
sette_ptext first,num$(1)
sette_ptext second,num$(2)
sette_ptext third,num$(3)
sette_ptext fourth,num$(4)
sette_ptext fifth,num$(5)
sette_ptext sixth,num$(6)
END SUB

SUB processusermenus (VAL wind,VAL item,VAL title)
STATIC dum,mem&
SELECT CASE item
  CASE mnabout
    selecttree about
    mem&=FRE(" ")
    sette_ptext memory%,"memory"+STR$(mem&)
    dum=handledialog(0)
  CASE mnpick
    selecttree pick
    DO
    choose
    store
    dum=handledialog(0)
    LOOP UNTIL dum=pickexit
END SELECT
END SUB


startprogram "a:\lotto\lotto.rsc",menu,mnquit

hgtloop

stopprogram
