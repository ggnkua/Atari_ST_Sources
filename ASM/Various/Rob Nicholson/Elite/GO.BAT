@echo off
call asm %&
bold
writeln Linking
normal
call linkit
call sendit
