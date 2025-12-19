@echo off
rem Batchdatei fÅr Omikron.Mishell
rem verarbeitet .MAK-Dateien
rem
close 1
close 2
local
REM +--------------------------------------------------+
REM I  Hier kînnen Standardoptionen eingefÅgt werden   I
REM +--------------------------------------------------+
REM asmopt : Optionen fÅr Assembler
REM linkopt : Optionen fÅr Linker
REM tcopt=Optionen fÅr Compiler
set tcopt=-I%tdir%include -K
set asmopt=
set linkopt=
set all=
set f=
set libdir=%tdir%lib\
alias cc=set i=$drop( %1 ) :: gosub cc
alias hcc=set i=$drop( %1 ) :: gosub hcc
alias ass=set i=$drop( %1 ) :: gosub asm
goto main
 
REM +--------------------------------------------------+
REM I  Neue Optionen aus Makefile einfÅgen             I
REM +--------------------------------------------------+
:addopt
let i=1
set a=tcopt
while "$par(#i %file%)" ne "" begin
   set i=$par(#i %file%)
   let i=#i+1
   if %i% == -link begin
       set a=linkopt
       goto aopt
   end
   if %i% == -ass begin
       set a=asmopt
       goto opt
   end
   set %a%=%(%%a %i%
:aopt
end
return
REM +--------------------------------------------------+
REM I Rufe den Compiler                                I
REM +--------------------------------------------------+
:cc
 if def all goto cc1
 if older %%i.o %%i.c begin
:cc1
    echo --- Compiling %%i.c ---
    pcc %tcopt% %%i.c
    set doit=1
 end
 write 3 %%file.o
return
REM +--------------------------------------------------+
REM I Rufe den Compiler mit einem .H-File              I
REM +--------------------------------------------------+
:hcc
 
 if older %output% %%i.h begin
:hcc1
    echo --- Compiling %%i.h : $par(2 %file%) ---
    pcc %tcopt% $par(2 %file%)
    set doit=1
 end
 REM LINK wird nicht geÑndert, weil die .C-Datei nochmal extra angegeben wird.
return
 
 
 REM +--------------------------------------------------+
 REM I    Rufe den Assembler                            I
 REM +--------------------------------------------------+
:asm
 if def all goto asm1
 if older %%I.o %I% begin
:asm1
    echo --- Assembling %I% ---
    mas %asmopt% %I%
    set doit=1
 end
 write 3 %%file.o
return
 
REM +--------------------------------------------------+
REM I               Hauptprogramm                      I
REM +--------------------------------------------------+
:main
set i=%1
if not def i goto usage
if "$ext(%i%)" == "" set i=%%i.mak
echo --- MAKE %i% ---
REM +--------------------------------------------------+
REM I   Aufteilung der Kommandozeilen-Optionen auf     I
REM I   Compiler / Assembler / Linker / Make           I
REM +--------------------------------------------------+
shift
if "%1" == "" goto noopt
set a=tcopt
while "%1" ne "" begin
   if %1 == -link begin
       set a=linkopt
       goto opt
   end
   if %1 == -ass begin
       set a=asmopt
       goto opt
   end
   if %1 == -all begin
       set all=1
       goto opt
   end
   set %a%=%(%%a %1
:opt
  shift
end
:noopt
REM +--------------------------------------------------+
REM I Makefile lesen, dabei Obj-Dateinamen und OptionenI
REM I merken. Obj-Dateien werden in die temporÑre DateiI
REM I L.LNK gespeichert.                               I
REM +--------------------------------------------------+
open 1 r %i%
open 2 w %tmp%l.lnk
open 3 w %tmp%l1.lnk
read 1 output ::                rem Output-Datei
set  link=
set doit=
write 3 -o=%output%
while $eof(1) == 0 begin
   read 1 file
   echo %file%
   set file=$drop(%file%)
   if def file begin
     if "$left(1 $drop(%file%))" == "-" begin
        gosub addopt
        goto next
     end
     REM *** e = Erweiterung vom Dateiname. Wenn leer setze "C"
     set e=$ext($par(1 %file%)) :: REM Extension der 1. Datei
     if not def e set e=c
     REM *** Wenn Erweiterung ".c", dann compilieren, wenn ".asm" dann
     REM *** assemblieren.
     if %e% == asm ass %%file.asm
     if %e% == s   ass %%file.s
     if %e% == c   cc  %%file.c
     if %e% == lib begin
                     write 2 %libdir%%%file.lib
                   end
     if %e% == o   write 3 %%file.o
     if %e% == h   hcc %file%
:next
   end
end
close 2
open 2 r %tmp%l.lnk
  while $eof(2) == 0 begin
    read 2 a
    write 3 %a%
  end
  close 2
close 3
close 1
if not exists %output% goto link
if def doit goto link
goto quit
:link
echo --- Linking %output% ---
type l1.link
plink  -C=%tmp%l1.lnk %linkopt%
goto quit
REM +--------------------------------------------------+
REM I     Aufrufmeldung                                I
REM +--------------------------------------------------+
:usage
text
 Einfaches MAKE fÅr Turbo-C: Es muû eine Make-Datei angegeben werden. Diese
 Datei hat folgenden Aufbau:
 1. Zeile = zu erzeugendes Programm
 alle Åbrigen Zeilen = Namen der einzubindenden .C .S .O und .LIB - Dateien
 
 Beispiel:
 hello.mak=
 
   D:\tc\lib\tcstart.o
   hello.c
   TCSTDLIB.LIB
 
 Die Directorys werden direkt in MAKE.BAT eingetragen.
 
 mit SET TDIR wird das Directory fÅr Turbo-C eingestellt. Directoryname
 muû mit \ abgeschlossen werden.
endtext
 
 
:quit
rem  @del l.lnk
close 1
close 2
alias cc=
alias ass=
 
