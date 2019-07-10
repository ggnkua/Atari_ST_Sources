set v 1
cd d:\secret
while { $v > 0 }
    if { -e ctdltabl.sys } == 0
	configur x
    endif
    citadel +line +ymodem +purge +netdebug +zap
    if { $status == 0 }
	set v 0
	echo 'Normal console termination.'
    ef { $status == 2 }
	set v 0
	echo 'Something must be buggered.'
    ef { $status == 3 }
	set v 0
	echo 'Somebody took it down from remote.'
    ef { $status == 255 }
	set v 0
	echo 'Something is REALLY buggered.'
    ef { $status == 10 }
	echo 'Calling uucp feed: dragos'
	pushd d:\
	rmail
	rnews
	batch dragos
	uupoll dragos
	rmail
	rnews
	expire 3
	popd
    endif
endwhile
