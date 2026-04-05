@echo off

rem Batch pour compiler le source de Nyancat sous CygWin
rem MaJ 14/03/2026


rem .../dev/nyancat/
rem .../dev/fonction/
rem .../dev/Build/xxxxx/
rem .../dev/EXEcutable/EXE_xxxx/
rem .../dev/nyancat.bat                 compilation de Nyancat
rem .../dev/nyancat_build.bat           construction archives Nyancat




rem ---- Configuration de la compilation ------------------------------------

rem set PCdev=win7_32bit
set PCdev=win10_64bit

set GCC_exe=m68k-atari-mint-gcc
rem set GCC_exe=m68k-atari-mintelf-gcc

rem set LIB_exe=MINTlib
set LIB_exe=LIBCmini


set NomProjet=NyanCat
set ProjetSRC=nyancat.c
set dossier_source=nyancat
set dossier_executable=../EXEcutable/EXE_nyancat/
set option_compilation=-O2 -fomit-frame-pointer -Wall -W -Wunused -Wshadow -Wpointer-arith -Wcast-qual -Wcast-align -Wstrict-prototypes -Wsign-conversion

rem -- executable prefix (4 char max) --
set PRG_prefix=NYAN
rem -- suffixe 4 char : _68k / _68D / _206 / _V4E / _V4D / _030 / _040 / _060 --


rem -------------------------------------------------------------------------


if %PCdev%==win10_64bit GOTO conf_win10_64bit

:conf_win7_32bit

set LIBCMINI=/cygdrive/h/cygwin/opt/cross-mint/m68k-atari-mint/libcmini/lib
set INCLUDE=/cygdrive/h/cygwin/opt/cross-mint/m68k-atari-mint/libcmini/include

set dossier_hatari=/cygdrive/H/Hatari_Disk/Daroou_HD_C/Daroou/nyancat/NYANCAT.DEV/
set dossier_aranym=/cygdrive/H/MyAES_Aranym_demo/diskC/applis/Daroou/Nyancat/nyancat.dev/

set dossier_projet_rsc=/cygdrive/H/MyAES_Aranym_demo/diskC/applis/Daroou/rsc_prj/nyancat/

goto end_conf



:conf_win10_64bit

if %GCC_exe%==m68k-atari-mintelf-gcc goto conf_win10_64bit_elf

set LIBCMINI=/cygdrive/e/cygwin64/opt/cross-mint/m68k-atari-mint/libcmini/lib
set INCLUDE=/cygdrive/e/cygwin64/opt/cross-mint/m68k-atari-mint/libcmini/include
goto conf_win10_64bit_elf_end


:conf_win10_64bit_elf

set LIBCMINI=/cygdrive/e/cygwin64/opt/cross-mintelf/m68k-atari-mintelf/libcmini/lib
set INCLUDE=/cygdrive/e/cygwin64/opt/cross-mintelf/m68k-atari-mintelf/libcmini/include

:conf_win10_64bit_elf_end

set dossier_hatari=/cygdrive/e/Hatari_Disk/Daroou_HD_C/Daroou/nyancat/NYANCAT.DEV/
set dossier_aranym=/cygdrive/e/MyAES_Aranym_demo/diskC/applis/Daroou/Nyancat/nyancat.dev/

set dossier_projet_rsc=/cygdrive/e/MyAES_Aranym_demo/diskC/applis/Daroou/rsc_prj/nyancat/


:end_conf

set bibliotheque=-lgem -lldg
set bibliotheque_mini=-lgem -lldg -lcmini -lgcc


rem ---- Fin configuration de la compilation --------------------------------




cd %dossier_source%


@echo on

@echo * Copie des fichiers RSC (aranym vers dossier dev)
@echo * on copie les RSC avant compilation,
@echo * ils sont gérés sous Aranym/interface/RSCbuilder
cp -R   %dossier_projet_rsc%RSC/.   RSC/

@echo * on supprime les versions précédentes des executables...
rm -v %dossier_executable%*.PRG


@echo off


@echo *
@echo ************ Compilation de %NomProjet%... ************
@echo * with %GCC_exe%
@echo * Lib %LIB_exe%
@echo *
@echo *


if %LIB_exe%==LIBCmini GOTO build_with_libcmini

:build_with_mintlib

REM *********************  MINTLIB BUILD ***

@echo Standard Mint LIB version
%GCC_exe% %ProjetSRC%  %option_compilation% -m68000 -DCPU_68K -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_MNT68K.PRG %bibliotheque%
%GCC_exe% %ProjetSRC%  %option_compilation% -m68020-60 -DCPU_68K -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_MNT206.PRG %bibliotheque%
rem %GCC_exe% %ProjetSRC%  %option_compilation% -m68000 -DCPU_68K -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_68K.PRG %bibliotheque%
REM m68k-atari-mint-objdump -dt %dossier_executable%%PRG_prefix%_68K.PRG > %dossier_executable%%PRG_prefix%_68K.S

rem %GCC_exe% %ProjetSRC%  %option_compilation% -m68000 -DCPU_68K -DBUILDMINTLIB -DLOG_FILE -o%dossier_executable%%PRG_prefix%_68D.PRG %bibliotheque%

REM m68k-atari-mint-gcc %ProjetSRC%  %option_compilation% -m68030 -DCPU_030 -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_030.PRG %bibliotheque%
REM m68k-atari-mint-gcc %ProjetSRC%  %option_compilation% -m68040 -DCPU_040 -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_040.PRG %bibliotheque%
REM m68k-atari-mint-gcc %ProjetSRC%  %option_compilation% -m68060 -DCPU_060 -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_060.PRG %bibliotheque%

REM m68k-atari-mint-gcc %ProjetSRC%  %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDMINTLIB -o%dossier_executable%%PRG_prefix%_V4E.PRG %bibliotheque%
REM m68k-atari-mint-gcc %ProjetSRC%  %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDMINTLIB -DLOG_FILE -o%dossier_executable%%PRG_prefix%_V4D.PRG %bibliotheque%

goto build_end



:build_with_libcmini

REM *********************  LIBCMINI  BUILD ***
@echo ---  LIBCmini Build version  ---
@echo compilation de %PRG_prefix%_68K.PRG
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68000 -DCPU_68K -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_68K.PRG -s -L%LIBCMINI% %bibliotheque_mini%
%GCC_exe% -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68000 -DCPU_68K -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_68K.PRG -s -L%LIBCMINI% %bibliotheque_mini%

rem avec symbol sans strip
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68000 -DCPU_68K -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_68S.PRG -g -L%LIBCMINI% %bibliotheque_mini%

rem @echo compilation de %PRG_prefix%_68K.S
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -S -m68000 -DCPU_68K -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_68K.S -s -L%LIBCMINI% %bibliotheque_mini%

rem @echo compilation de %PRG_prefix%_68K.dump
rem @echo (export dans le dossier source et EXE_xxxx)
rem m68k-atari-mint-gcc boing.c -fdump-tree-all -O3 -Wall -W -Wunused -Wcast-qual -s -m68000 -DCPU_68K -o ../EXEcutable/EXE_boing/boing68k.dump -lgem -lldg


@echo compilation de %PRG_prefix%_68D.PRG
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68000 -DCPU_68K -DBUILDLIBCMINI -DLOG_FILE -o%dossier_executable%%PRG_prefix%_68D.PRG -s -L%LIBCMINI% %bibliotheque_mini%
%GCC_exe% -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68000 -DCPU_68K -DBUILDLIBCMINI -DLOG_FILE -o%dossier_executable%%PRG_prefix%_68D.PRG -s -L%LIBCMINI% %bibliotheque_mini%

@echo compilation de %PRG_prefix%_206.PRG
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68020-60 -DCPU_020_060 -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_206.PRG -s -L%LIBCMINI%/m68020-60 %bibliotheque_mini%
%GCC_exe% -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -m68020-60 -DCPU_020_060 -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_206.PRG -s -L%LIBCMINI%/m68020-60 %bibliotheque_mini%

@echo compilation de %PRG_prefix%_V4E.PRG
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_V4E.PRG -s -L%LIBCMINI%/m5475 %bibliotheque_mini%
%GCC_exe% -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDLIBCMINI -o%dossier_executable%%PRG_prefix%_V4E.PRG -s -L%LIBCMINI%/m5475 %bibliotheque_mini%

@echo compilation de %PRG_prefix%_V4D.PRG
rem m68k-atari-mint-gcc -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDLIBCMINI -DLOG_FILE -o%dossier_executable%%PRG_prefix%_V4D.PRG -s -L%LIBCMINI%/m5475 %bibliotheque_mini%
%GCC_exe% -nostdlib -I%INCLUDE% %LIBCMINI%/crt0.o %ProjetSRC% %option_compilation% -mcfv4e -DCPU_CFV4E -DBUILDLIBCMINI -DLOG_FILE -o%dossier_executable%%PRG_prefix%_V4D.PRG -s -L%LIBCMINI%/m5475 %bibliotheque_mini%



:build_end

@echo *
@echo * Copie des fichiers PRG et RSC vers Hatari...
cp -R  RSC/.  %dossier_hatari%RSC/

cp     %dossier_executable%%PRG_prefix%_68K.PRG    %dossier_hatari%
rem cp     %dossier_executable%%PRG_prefix%_MNT.PRG    %dossier_hatari%
cp     %dossier_executable%%PRG_prefix%_68D.PRG    %dossier_hatari%
rem cp     %dossier_executable%%PRG_prefix%_68S.PRG    %dossier_hatari%



@echo *
@echo * Copie des fichiers PRG et RSC vers Aranym...
cp -R  RSC/.  %dossier_aranym%RSC/

rem cp     %dossier_executable%%PRG_prefix%_68K.PRG     %dossier_aranym%
cp     %dossier_executable%%PRG_prefix%_206.PRG     %dossier_aranym%
cp     %dossier_executable%%PRG_prefix%_68D.PRG     %dossier_aranym%

@echo *
@echo * Terminé.




rem ------------------ export code asm ----------------
rem m68k-atari-mint-gcc xxx.c -S -O0 -fomit-frame-pointer -Wall -W -Wunused -Wshadow -Wpointer-arith -Wcast-qual -Wcast-align -Wstrict-prototypes -Wsign-conversion -s -m68000 -DCPU_68K -lgem -lldg

rem ------------------ export code ??? ----------------
rem m68k-atari-mint-gcc xxx.c -fdump-tree-all -O3 -Wall -W -Wunused -Wcast-qual -s -m68000 -DCPU_68K -o ../EXEcutable/EXE_boing/boing68k.prg -lgem -lldg
