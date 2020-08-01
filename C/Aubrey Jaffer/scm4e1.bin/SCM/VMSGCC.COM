$ ! output will be in build.log
$ define/user sys$output build.log
$ ! From: T. Kurt Bond, tkb@mtnet2.wvnet.edu
$ !
$ ! Build scm on VMS systems.
$ !
$ ! p1: Options for cc.
$ ! p2: Options for link.
$ ! p3: Options for macro.
$ !
$ ! The following lines define IMPLINIT as the directory in which this command
$ ! procedure is followed by "Init.scm".  If you want it someplace else, 
$ ! replace the `init = ...' line with `init = "yourfile".
$ !
$ where = f$environment("PROCEDURE")	!full pathname of this procedure
$ where = f$parse(where,,,"DEVICE")+f$parse(where,,,"DIRECTORY") !device:[dir]
$ init = where + "init.scm" 		!device:[dir]init.scm
$ !
$ ! If you don't want floating point, delete the `"FLOATS",' on the lines
$ ! below.
$ gcc 'p1 scm  /define=("RETSIGTYPE=int", -
	"FLOATS","INITS=","IMPLINIT=""''init'""")
$ gcc 'p1 repl /define=("FLOATS")
$ gcc 'p1 eval /define=("FLOATS")
$ gcc 'p1 time /define=("FLOATS")
$ gcc 'p1 scl  /define=("FLOATS")
$ gcc 'p1 subr
$ gcc 'p1 sys  /define=("FLOATS")
$ gcc 'p1 sc2
$ gcc 'p1 unif /define=("FLOATS")
$ macro 'p3 setjump
$ gcc 'p1 pi
$
$   link 'p2 scm.obj,repl.obj,time.obj,eval.obj,scl.obj,subr.obj,sys.obj, -
    sc2.obj,unif.obj,setjump.obj,sys$input/opt
	gnu_cc:[000000]gcclib/lib,-
	sys$share:vaxcrtl/share
$   link 'p2 pi,sys$input/opt
	gnu_cc:[000000]gcclib/lib,-
	sys$share:vaxcrtl/share
