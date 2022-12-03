# test script
# this works for old gulam, not with new gulam

echo $$HOME is $HOME

set i 10 
set i 21+22 
set i 30 + 5

if { $i >  0 } 
   set i $i - 1
   echo $$i is $i 
endif

if { $i <  0 }
   echo error press CR
ef
   echo correct,  $$i is $i 
endif

if { $i == 34 }
   echo "correct"
ef
   echo 'xxxxxxxxxxx error'
endif
echo 'now press CR'
echo $<

if { -e t.c }
   echo found t.c
   ls -l t.c
   touch t.c
ef
   pwd
   echo there is no t.c here
   touch t.c
endif


# need space after '!', otherwise it means history
if  { ! -e t.c }
   echo 'xxxxxxxxx error: no t.c'
ef    # this is 'else' or 'else if'
   echo 't.c exists, should now have uptodate timestamp'   
   ls -l t.c
endif

echo "current time is"
date

echo 'removing t.c'
delete t.c
ls -l t.c
touch -c t.c
if  { -e t.c }
   echo 'xxxxxxxxx error: t.c should not exist'
ef    # 
   echo 'correct: there is no t.c'   
endif

if { -e $GNULIB\iio16.olb };   echo found;  ls -l $GNULIB\iio16.olb; ef; echo dne; endif

set i 10
set XX $HOME
#setenv XX $HOME

echo $$XX is $XX
while $i && { ! -e $XX\tmp }
   #echo '$XX' is $XX
   #set i $i - 1
   set XX $XX\..
endwhile

echo '$i' is $i, '$XX' is $XX
if { -e $XX\tmp }
   echo "found tmp dir"
   setenv TMP $XX\tmp
   echo '$TMP' is $TMP
#   ls -l $TMP
endif

# watch out!   ... expands into subdirs, so needs single quotes
echo 'testing foreach ...'

foreach i { 10 12 14 }
   echo $i
endfor
