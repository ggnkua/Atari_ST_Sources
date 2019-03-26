alias ls 'ls -F'

set home a:\work
set prompt      '$ncmd $cwd > $u'

setenv PATH m:,a:\sozobon\bin
setenv INCLUDE m:,a:\sozobon\include
setenv LIB m:,a:\sozobon\lib
setenv TMP a:
setenv CFLAGS '-O'

set gulam_help_file gulam.hlp

set history 25

set baud_rate 019200

unset pr_bof 
set pr_eof '214'
set pr_eop '214n'
set pr_eol 'rn'

echo "Gulam and Sozobon C, ST Format edition."
echo ""
 
if { -d m:\work } == 0
    mkdir m:\work
    if { -d m:\work }
	echo "Copying Sozobon C files onto RAM disk at device M:"
	cd a:\sozobon\bin
		cp cc.ttp m:
#		cp hcc.ttp m:
#		cp jas.ttp m:
#		cp ld.ttp m:
#		cp make.ttp m:
#		cp top.ttp m:
	cd a:\sozobon\include
#		cp osbind.h m:
		cp ctype.h m:
#		cp stdarg.h m:
		cp stddef.h m:
		cp stdio.h m:
#		cp gemfast.h m:
		cp string.h m:
#		cp time.h m:
#		cp macros.h m:
		cp types.h m:
#		cp malloc.h m: 
	cd a:\sozobon\lib
#		cp dlibs.a m:
		cp dstart.o m:
#		cp vdifast.a m:
#		cp aesfast.a m:
    ef
	echo "There is no RAM disk at device M:, but we shall continue anyway."
    endif
ef
	echo "The RAM disk at device M: appears to be set up already,"
	echo "so we will not load the Sozobon files onto the RAM disk."
endif

cd a:\work

rehash
echo ""
date
echo "Ready now"
echo ""
