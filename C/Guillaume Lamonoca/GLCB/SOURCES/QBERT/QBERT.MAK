
qbert.exe : qbert.obj game.obj bitmaps2.obj bitmaps.obj graphics.obj main.obj scores.obj x11.obj
	link qbert.obj,game.obj,bitmaps2.obj,bitmaps.obj,graphics.obj,main.obj,scores.obj,x11.obj,[public.x11]xlib.opt/opt

x11.obj : x11.c
	cc x11.c

qbert.obj : qbert.c
	cc qbert.c

game.obj : game.c
	cc game.c

bitmaps2.obj : bitmaps2.c
	cc bitmaps2.c

bitmaps.obj : bitmaps.c
	cc bitmaps.c

graphics.obj : graphics.c
	cc graphics.c

main.obj : main.c
	cc main.c

scores.obj : scores.c
	cc scores.c

