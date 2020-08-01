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
$ cc /define=(FLOATS,"IMPLINIT=""''init'""","INITS=init_sc2();") 'p1 scm
$ cc /define=(FLOATS) 'p1 repl,time,eval,scl,subr,sys,sc2,unif
$ macro 'p3 setjump
$ cc 'p1 pi
$   link 'p2 scm,repl,time,eval,scl,subr,sys,sc2,unif,setjump,sys$input/opt
	sys$share:vaxcrtl/share
$   link 'p2 pi,sys$input/opt
	sys$share:vaxcrtl/share
