
#format a:
pushd e:\gulam
arc a f:\gulamsrc.arc 'makefile *.c *.s *.h e:\gulam.hlp'
ls -lF f:\gulamsrc.arc
cp -r f:\gulamsrc.arc e:\gulam\aux e:\dotg a:\
cp e:\g.txi a:\gulamdoc.txi
cp c:\bin\arc.* a:\
cp e:\gu.prg a:\gulam.prg
popd
