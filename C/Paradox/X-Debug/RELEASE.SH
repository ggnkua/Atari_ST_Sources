# this param to be set to the dest drive
# dest drive requires drivers & utils directories to already exist

if ( $# != 1 ) then
	echo "usage: release drive:"
	exit 1
endif

cp -o drivers\moniterm.scr ${1}drivers
cp -o drivers\reflex.scr ${1}drivers
cp -o drivers\checkram.o ${1}drivers
cp -o drivers\driver.h ${1}drivers
cp -o drivers\moniterm.c ${1}drivers
cp -o drivers\moniterm.mak ${1}drivers
cp -o drivers\testscr.c ${1}drivers
cp -o drivers\testscr.ttp ${1}drivers

cp -o utils\dumpdb.ttp ${1}utils
cp -o utils\resetfpu.prg ${1}utils
cp -o utils\tthead.ttp ${1}utils
cp -o utils\dreloc.ttp ${1}utils
cp -o utils\loadhigh.tos ${1}utils

cp -o release\readme.txt ${1}
cp -o release\startup.xdb ${1}
cp -o release\kludge.h ${1}

cp -o help.xdb ${1}
cp -o sysvar.usm ${1}

cp -f mon.prg ${tmp}
strip ${tmp}mon.prg
mv -f ${tmp}mon.prg ${1}xdb.prg

echo "All done now"


