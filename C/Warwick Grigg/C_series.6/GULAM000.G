alias ls 'ls -F'

set home a:\work
set prompt      '$ncmd $cwd > $u'

setenv PATH a:\sozobon\bin
setenv INCLUDE a:\sozobon\include
setenv LIB a:\sozobon\lib
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
cd a:\work

rehash
echo ""
date
echo "Ready now"
echo ""
