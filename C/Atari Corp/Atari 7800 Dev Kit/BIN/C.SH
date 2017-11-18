set i=$cwd
cp $1.c m:\$1.c
cd m:\
cc $1.c
link1 $1
rm $1.c
mv $1.o $i\$1.o
mv $1.prg $i\$1.prg
cd $i

