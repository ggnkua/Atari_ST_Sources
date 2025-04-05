cc -c -DDECL ltb.c
cc -c -DDECL look.c
link68 ltb.68k=gems,ltb.o,look.o,gemlib,libf
relmod ltb
ltb proffsym.new lextab
cc -c -DDECL proff.c
cc -c -DDECL proff01.c
cc -c -DDECL proff02.c
cc -c -DDECL lookup.c
cc -c -DDECL pinit.c
cc -c -DDECL putwrd.c
cc -c -DDECL pxlex.c
cc -c -DDECL pxxparse.c
cc -c -DDECL dostuff2.c
cc -c -DDECL eval.c
cc -c -DDECL map.c
cc -c -DDECL stack.c
link68 [u,com[lnk]]
relmod proff
rm proff.68k
