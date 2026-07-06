: xload ( -- ) ( Input stream: filename )
  bl word      ( str )
  dup ." Loading " count type cr
  "load
;
xload portab32.fth
xload util.fth
xload th.fth
xload strings.fth
xload savefort.fth
xload dump.fth
xload order.fth
xload assem68k.fth
xload assem32.fth
xload cutil.fth
xload case.fth
xload catchexc.fth
xload stack.fth
xload ccalls.fth
xload syscalls.fth
xload format.fth
xload command.fth
xload stringfi.fth
xload words.fth
xload patch.fth
xload needs.fth
xload stringar.fth
xload decompm.fth
xload decomp.fth
xload disassem.fth
xload terminals.fth
xload more.fth
xload emacsed.fth
xload history.fth
xload cmdcpl.fth
xload callfind.fth
xload exec.fth
xload ftitle.fth

.( Saving as FORTH.TOS ... ) "" forth.tos save-forth
