jewel.exe : jewel.obj x11.obj
	link jewel.obj,x11.obj,[public.x11]xlib.opt/opt
jewel.obj : jewel.c
	cc jewel.c
x11.obj : x11.c
	cc x11.c
