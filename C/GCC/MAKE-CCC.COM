$!
$!	Build the GNU "C" pre-processor on VMS
$!
$ if "''p1'" .eqs. "LINK" then goto Link
$ gcc/debug cccp.c
$ t1:='f$search("CEXP.C")'
$ if "''t1'" .eqs. "" then goto 10$
$ t1:='f$file_attributes("CEXP.Y","RDT")'
$ t1:='f$cvtime(t1)'
$ t2:='f$file_attributes("CEXP.C","RDT")'
$ t2:='f$cvtime(t2)'
$ if t1 .les. t2 then goto 20$
$ 10$:
$ bison cexp.y
$ 20$:
$!
$ rename cexp_tab.c cexp.c
$ gcc/debug cexp.c
$ gcc/debug version.c
$ Link:
$ link/exe=gcc-cpp sys$input:/opt
!
!	Linker options file for linking the GNU "C" pre-processor
!
cccp,cexp,version,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$!
$!	Done
$!
$ exit
