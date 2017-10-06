
sokoban.exe : sokoban.obj levels.obj levels2.obj sprites.obj x11.obj
	link sokoban.obj,levels.obj,levels2.obj,sprites.obj,x11.obj,[public.x11]xlib.opt/opt

x11.obj : x11.c
	cc x11.c

sokoban.obj : sokoban.c
	cc sokoban.c

levels.obj : levels.c
	cc levels.c

levels2.obj : levels2.c
	cc levels2.c

sprites.obj : sprites.c
	cc sprites.c

