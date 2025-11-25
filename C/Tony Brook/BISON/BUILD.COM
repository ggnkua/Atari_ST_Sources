$!
$! This command procedure compiles and links BISON for VMS.
$! BISON has been tested with VAXC version 2.3 and VMS version 4.5
$! and on VMS 4.5 with GCC 1.12.
$!
$! Bj|rn Larsen			blarsen@ifi.uio.no
$! With some contributions by Gabor Karsai, 
$!  KARSAIG1%VUENGVAX.BITNET@jade.berkeley.edu
$! All merged and cleaned by RMS.
$!
$! Adapted for both VAX-11 "C" and VMS/GCC compilation by
$! David L. Kashtan		kashtan.iu.ai.sri.com
$!
$! Uncomment the appropriate compilation command (CC=VAX-11 "C", GCC=VMS/GCC)
$ cc_command:="CC"
$! cc_command:="GCC"
$!
$! Note: Change the directories immediately below to whereever 
$! you have placed bison.simple & hairy
$!
$ if "''cc_command'" .nes. "CC" then goto Try_GCC
$ cc_options:="/NOLIST/define=(""index=strchr"",""rindex=strrchr"",""XPFILE=""""DISK_USE:[BISON]bison.simple"""""",""XPFILE1=""""DISK_USE:[BISON]bison.hairy"""""")"
$ extra_linker_files:="VMSHLP,"
$ goto Compile
$!
$! VMS/GCC compilation:
$!
$ Try_GCC:
$ if "''cc_command'" .nes. "GCC" then goto Fail
$ cc_options:="/DEBUG"
$ extra_linker_files:="GNU_CC:[000000]GCCLIB/LIB,"
$ goto Compile
$!
$! Unknown compiler type
$!
$ Fail:
$ write sys$output "Unknown compiler type: ''cc_command'"
$ exit
$!
$!	Do the compilation (compiler type is all set up)
$!
$ Compile:
$ if "''p1'" .eqs. "LINK" then goto Link
$ 'cc_command' 'cc_options' files.c
$ 'cc_command' 'cc_options' LR0.C
$ 'cc_command' 'cc_options' ALLOCATE.C
$ 'cc_command' 'cc_options' CLOSURE.C
$ 'cc_command' 'cc_options' CONFLICTS.C
$ 'cc_command' 'cc_options' DERIVES.C
$ 'cc_command' 'cc_options' VMSGETARGS.C
$ 'cc_command' 'cc_options' GRAM.C
$ 'cc_command' 'cc_options' LALR.C
$ 'cc_command' 'cc_options' LEX.C
$ 'cc_command' 'cc_options' MAIN.C
$ 'cc_command' 'cc_options' NULLABLE.C
$ 'cc_command' 'cc_options' OUTPUT.C
$ 'cc_command' 'cc_options' PRINT.C
$ 'cc_command' 'cc_options' READER.C
$ 'cc_command' 'cc_options' SYMTAB.C
$ 'cc_command' 'cc_options' WARSHALL.C
$ if "''cc_command'" .eqs. "CC" then macro vmshlp.mar
$ Link:
$ link/exec=bison main,LR0,allocate,closure,conflicts,derives,files,-
vmsgetargs,gram,lalr,lex,nullable,output,print,reader,symtab,warshall,-
'extra_linker_files'sys$library:vaxcrtl/lib
