blockout.exe : blockout.obj x11.obj
	link blockout.obj,x11.obj,[public.x11]xlib.opt/opt
blockout.obj : blockout.c
	cc blockout.c
x11.obj : x11.c
	cc x11.c
