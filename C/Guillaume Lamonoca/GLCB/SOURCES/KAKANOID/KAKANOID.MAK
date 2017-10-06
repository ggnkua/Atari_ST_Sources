
kakanoid.exe : kakanoid.obj level.obj sprites.obj x11.obj
	link kakanoid.obj,level.obj,sprites.obj,x11.obj,[public.x11]xlib.opt/opt

x11.obj : x11.c
	cc x11.c

kakanoid.obj : kakanoid.c
	cc kakanoid.c

level.obj : level.c
	cc level.c

sprites.obj : sprites.c
	cc sprites.c

