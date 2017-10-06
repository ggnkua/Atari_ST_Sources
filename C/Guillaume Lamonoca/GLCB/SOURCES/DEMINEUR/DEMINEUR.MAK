
demineur.exe : demineur.obj graphics.obj main.obj x11.obj
	link demineur.obj,graphics.obj,main.obj,x11.obj,[public.x11]xlib.opt/opt

x11.obj : x11.c
	cc x11.c

demineur.obj : demineur.c
	cc demineur.c

graphics.obj : graphics.c
	cc graphics.c

main.obj : main.c
	cc main.c
