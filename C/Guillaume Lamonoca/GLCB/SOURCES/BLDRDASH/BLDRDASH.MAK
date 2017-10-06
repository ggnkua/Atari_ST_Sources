
bldrdash.exe : bldrdash.obj levels.obj levels2.obj graphics.obj bitmaps.obj field.obj scores.obj x11.obj
	link bldrdash.obj,levels.obj,levels2.obj,graphics.obj,bitmaps.obj,field.obj,scores.obj,x11.obj,[public.x11]xlib.opt/opt

x11.obj : x11.c
	cc x11.c

bldrdash.obj : bldrdash.c
	cc bldrdash.c

levels.obj : levels.c
	cc levels.c

levels2.obj : levels2.c
	cc levels2.c

graphics.obj : graphics.c
	cc graphics.c

bitmaps.obj : bitmaps.c
	cc bitmaps.c

field.obj : field.c
	cc field.c

scores.obj : scores.c
	cc scores.c
