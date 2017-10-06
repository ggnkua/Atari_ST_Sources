warzone.exe : warzone.obj x11.obj
	link warzone.obj,x11.obj,[public.x11]xlib.opt/opt
warzone.obj : warzone.c
	cc warzone.c
x11.obj : x11.c
	cc x11.c
