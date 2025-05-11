$!
$!	Build the GNU "C" compiler on VMS
$!
$ if "''p1'" .eqs. "LINK" then goto Link
$ gcc/debug/cc1_options="-mpcc-alignment" rtl.c
$ gcc/debug/cc1_options="-mpcc-alignment" obstack.c
$!	Generate insn-flags.h
$ gcc/debug/cc1_options="-mpcc-alignment" genflags.c
$ link/nomap genflags,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genflags:=$sys$disk:[]genflags
$ assign/user insn-flags.h sys$output:
$ genflags md
$!	Generate insn-codes.h
$ gcc/debug/cc1_options="-mpcc-alignment" gencodes.c
$ link/nomap gencodes,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ gencodes:=$sys$disk:[]gencodes
$ assign/user insn-codes.h sys$output:
$ gencodes md
$!	Generate insn-config.h
$ gcc/debug/cc1_options="-mpcc-alignment" genconfig.c
$ link/nomap genconfig,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genconfig:=$sys$disk:[]genconfig
$ assign/user insn-config.h sys$output:
$ genconfig md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" toplev.c
$!
$ t1:='f$search("PARSE_TAB.C")'
$ if "''t1'" .eqs. "" then goto 10$
$ t1:='f$file_attributes("PARSE.Y","RDT")'
$ t1:='f$cvtime(t1)'
$ t2:='f$file_attributes("PARSE_TAB.C","RDT")'
$ t2:='f$cvtime(t2)'
$ if t1 .les. t2 then goto 20$
$ 10$:
$ bison /verbose parse.y
$ 20$:
$!
$ gcc/debug/cc1_options="-mpcc-alignment" parse_tab.c
$ gcc/debug/cc1_options="-mpcc-alignment" tree.c
$ gcc/debug/cc1_options="-mpcc-alignment" print-tree.c
$ gcc/debug/cc1_options="-mpcc-alignment" decl.c
$ gcc/debug/cc1_options="-mpcc-alignment" typecheck.c
$ gcc/debug/cc1_options="-mpcc-alignment" stor-layout.c
$ gcc/debug/cc1_options="-mpcc-alignment" fold-const.c
$ gcc/debug/cc1_options="-mpcc-alignment" varasm.c
$ gcc/debug/cc1_options="-mpcc-alignment" expr.c
$ gcc/debug/cc1_options="-mpcc-alignment" stmt.c
$ gcc/debug/cc1_options="-mpcc-alignment" expmed.c
$ gcc/debug/cc1_options="-mpcc-alignment" explow.c
$ gcc/debug/cc1_options="-mpcc-alignment" optabs.c
$ gcc/debug/cc1_options="-mpcc-alignment" symout.c
$ gcc/debug/cc1_options="-mpcc-alignment" dbxout.c
$ gcc/debug/cc1_options="-mpcc-alignment" emit-rtl.c
$!	Generate insn-emit.c
$ gcc/debug/cc1_options="-mpcc-alignment" genemit.c
$ link/nomap genemit,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genemit:=$sys$disk:[]genemit
$ assign/user insn-emit.c sys$output:
$ genemit md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" insn-emit.c
$ gcc/debug/cc1_options="-mpcc-alignment" jump.c
$ gcc/debug/cc1_options="-mpcc-alignment" cse.c
$ gcc/debug/cc1_options="-mpcc-alignment" loop.c
$ gcc/debug/cc1_options="-mpcc-alignment" flow.c
$ gcc/debug/cc1_options="-mpcc-alignment" stupid.c
$ gcc/debug/cc1_options="-mpcc-alignment" combine.c
$ gcc/debug/cc1_options="-mpcc-alignment" regclass.c
$ gcc/debug/cc1_options="-mpcc-alignment" local-alloc.c
$ gcc/debug/cc1_options="-mpcc-alignment" global-alloc.c
$ gcc/debug/cc1_options="-mpcc-alignment" reload.c
$ gcc/debug/cc1_options="-mpcc-alignment" reload1.c
$!	Generate insn-peep.c
$ gcc/debug/cc1_options="-mpcc-alignment" genpeep.c
$ link/nomap genpeep,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genpeep:=$sys$disk:[]genpeep
$ assign/user insn-peep.c sys$output:
$ genpeep md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" insn-peep.c
$ gcc/debug/cc1_options="-mpcc-alignment" final.c
$ gcc/debug/cc1_options="-mpcc-alignment" recog.c
$!	Generate insn-recog.c
$ gcc/debug/cc1_options="-mpcc-alignment" genrecog.c
$ link/nomap genrecog,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genrecog:=$sys$disk:[]genrecog
$ assign/user insn-recog.c sys$output:
$ genrecog md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" insn-recog.c
$!	Generate insn-extract.c
$ gcc/debug/cc1_options="-mpcc-alignment" genextract.c
$ link/nomap genextract,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genextract:=$sys$disk:[]genextract
$ assign/user insn-extract.c sys$output:
$ genextract md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" insn-extract.c
$!	Generate insn-output.c
$ gcc/debug/cc1_options="-mpcc-alignment" genoutput.c
$ link/nomap genoutput,rtl,obstack,gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$ genoutput:=$sys$disk:[]genoutput
$ assign/user insn-output.c sys$output:
$ genoutput md
$!
$ gcc/debug/cc1_options="-mpcc-alignment" insn-output.c
$ gcc/debug/cc1_options="-mpcc-alignment" integrate.c
$!
$!	Link it
$!
$ Link:
$ link/nomap/exe=gcc-cc1 sys$input:/opt
!
!	"CC1" Linker options file
!
toplev,parse_tab,tree,print-tree,decl,typecheck,stor-layout,fold-const,-
varasm,rtl,expr,stmt,expmed,explow,optabs,symout,dbxout,emit-rtl,insn-emit,-
jump,cse,loop,flow,stupid,combine,regclass,local-alloc,global-alloc,reload,-
reload1,insn-peep,final,recog,insn-recog,insn-extract,insn-output,obstack,-
integrate,-
gnu_cc:[000000]gcclib/lib,sys$share:vaxcrtl/lib
$!
$!	Done
$!
