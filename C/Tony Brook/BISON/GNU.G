#
# set up commands for gcc and gas
#
alias cpp f:\gnu\exec\gcc-cpp
setenv cpp f:\gnu\exec\gcc-cpp.ttp
alias cc1 f:\gnu\exec\gcc-cc1
setenv cc1 f:\gnu\exec\gcc-cc1.ttp
alias gas f:\gnu\exec\gcc-as
setenv gas f:\gnu\exec\gcc-as.ttp
alias as f:\gnu\exec\gcc-as
setenv as f:\gnu\exec\gcc-as.ttp
alias link f:\gnu\exec\link
setenv link f:\gnu\exec\link.ttp
alias ar f:\gnu\exec\gcc-ar
setenv ar f:\gnu\exec\gcc-ar.ttp
alias ld f:\gnu\exec\gcc-ld
setenv ld f:\gnu\exec\gcc-ld.ttp
alias gcc f:\gnu\exec\gcc
setenv gcc f:\gnu\exec\gcc.ttp
#
alias cc f:\gnu\exec\gcc
setenv cc f:\gnu\exec\gcc.ttp
alias xcc f:\gnu\exec\gcc -Bf:\gnu\exec\x
setenv xcc f:\gnu\exec\gcc.ttp -Bf:\gnu\exec\x
#
alias make f:\gnu\util\xmake
setenv make f:\gnu\util\xmake.ttp
#
# bison...
#
alias bison f:\gnu\bison\bison
setenv bison f:\gnu\bison\bison.ttp
setenv BISON_SIMPLE f:\gnu\bison\bison.sim
setenv BISON_HAIRY f:\gnu\bison\bison.hai
#
#setenv GNULIB d:\gnu\lib
setenv GNULIB f:\gnu\lib
setenv GCCEXEC f:\gnu\exec\gcc-