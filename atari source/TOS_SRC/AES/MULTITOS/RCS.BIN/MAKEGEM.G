#
# gulam script file for building the AES
# execute with "makegem"
# 
set foo $PATH
setenv PATH \bin
rehash
make -f makeprg
setenv PATH "$foo"
rehash
unset foo
