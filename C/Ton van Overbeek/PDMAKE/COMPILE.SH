echo compiling check.c
cc -dATARIST check.c
echo compiling input.c
cc -dATARIST input.c
echo compiling macro.c
cc -dATARIST macro.c
echo compiling main.c
cc -dATARIST main.c
echo compiling make.c
cc -dATARIST make.c
echo compiling reader.c
cc -dATARIST reader.c
echo compiling rules.c
cc -dATARIST rules.c
echo compiling ststuff.c
cc -dATARIST ststuff.c
echo assembling gemstart.s
as68 -l -u -s a:\ -f d:\ gemstart.s
