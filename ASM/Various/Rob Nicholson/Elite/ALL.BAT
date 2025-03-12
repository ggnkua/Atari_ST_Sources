@echo off
bold
writeln Assembling all files
writeln
normal
buildall quelo f: e: elite
writeln
blink
bold
writeln (Hmm, tricky, I'll have to think about it)
normal
writeln
delete *.ltx
delete f:*.ltx
if not exist notes.m68 call load notes.m68
call asmall
writeln
writeln Don't forget to look at the ERRORS file!