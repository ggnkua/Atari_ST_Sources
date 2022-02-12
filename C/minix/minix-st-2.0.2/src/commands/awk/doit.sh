./awk '/#define.*ENABLE_NETWORKING.*$/{print $0 " " $3 " " NF; exit}{next}' </u2/src/include/minix/config.h
exit 0
cat liblist | while read obj ; do
    if [ "$obj" = "Kill.o" ] ; then
	echo "Ende bei kill.o"
	exit 0
    fi
    cd /usr/TMP
    ar dv libcX.a $obj
    ar xv /usr/lib/libc68f.a $obj
    ar rv libcX.a $obj
    cd /u2/src/commands/awk
    rm -f awk
    make -f makeack.soz
    ./awk '/#define.*ENABLE_NETWORKING.*$/{print $3; exit}{next}' </u2/src/include/minix/config.h >e2
    e1=`cat e1`
    e2=`cat e2`
    if [ "$e1" = "$e2" ] ; then
      rm -f e2
      echo "$obj" >>objdone
      echo "                      $obj war es nicht"
    fi
done
# EOF
