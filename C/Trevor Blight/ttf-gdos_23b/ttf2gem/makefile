#####################################################
#
#  makefile for ttf2gem.prg using freetype libraries
#
#####################################################

#CC = gcc -mshort
CC = cc

.DEFAULT:
	echo default $@
	#@cp a:$@ d:\

.c.o:
	@$(CC) -c -O $*.c

OBJS  = ttapi.o ttcache.o ttcalc.o ttcmap.o ttdebug.o \
        ttfile.o ttgload.o ttinterp.o ttload.o \
        ttmemory.o ttobjs.o ttraster.o

HDRS  = freetype.h ftnameid.h ttcmap.h   ttengine.h ttinterp.h ttmutex.h  \
	tttables.h ft_conf.h  ttcache.h  ttconfig.h ttfile.h   ttload.h   \
	ttobjs.h   tttags.h fterrid.h  ttcalc.h   ttdebug.h  ttgload.h  \
	ttmemory.h ttraster.h tttypes.h 

ttf2gem.prg : ttf2gem.o $(OBJS)
	$(CC) -o $@ -s ttf2gem.o $(OBJS) -liio16 -lgem16

debug : debug.o $(OBJS)
	ld -o ttf2gem.prg $$GNULIB\crt0.o debug.o $(OBJS) -liio16 -lgnu16 -lgem16
	sym-ld -o ttf2gem.sym $$GNULIB\crt0.o debug.o $(OBJS) -liio16 -lgnu16 -lgem16

debug.o : ttf2gem.c freetype.h fterrid.h ftnameid.h
	$(CC) -g -c -o $@ ttf2gem.c

#$(OBJS) :  $(HDRS)

ttf2gem.o : ttf2gem.c freetype.h fterrid.h ftnameid.h ttf2gem.h
	$(CC) -O -c -o $@ ttf2gem.c

delerr :
	#echo removing stuff
	rm compile.err

#
#ttapi.o : ttapi.c freetype.h fterrid.h ftnameid.h ttengine.h tttypes.h \
#  ttconfig.h ft_conf.h ttmutex.h ttcalc.h ttmemory.h ttcache.h ttfile.h \
#  ttdebug.h ttobjs.h tttables.h ttcmap.h ttload.h ttgload.h ttraster.h
#
#ttcache.o : ttcache.c ttengine.h tttypes.h ttconfig.h ft_conf.h freetype.h \
#  fterrid.h ftnameid.h ttmutex.h ttmemory.h ttcache.h ttobjs.h tttables.h \
#  ttcmap.h ttdebug.h 
#
#ttcalc.o : ttcalc.c ttcalc.h ttconfig.h ft_conf.h freetype.h fterrid.h \
#  ftnameid.h ttdebug.h tttables.h tttypes.h 
#
#ttcmap.o : ttcmap.c ttobjs.h ttconfig.h ft_conf.h ttengine.h tttypes.h \
#  freetype.h fterrid.h ftnameid.h ttmutex.h ttcache.h tttables.h ttcmap.h \
#  ttdebug.h ttfile.h ttmemory.h ttload.h 
#
#ttdebug.o : ttdebug.c ttdebug.h ttconfig.h ft_conf.h tttables.h tttypes.h \
#  freetype.h fterrid.h ftnameid.h ttobjs.h ttengine.h ttmutex.h ttcache.h \
#  ttcmap.h 
#
#ttf2bdf.o : ttf2bdf.c freetype.h fterrid.h ftnameid.h remap.h 
#
#ttfile.o : ttfile.c ttconfig.h ft_conf.h freetype.h fterrid.h ftnameid.h \
#  tttypes.h ttdebug.h ttengine.h ttmutex.h ttmemory.h ttfile.h 
#
#ttgload.o : ttgload.c tttypes.h ttconfig.h ft_conf.h freetype.h fterrid.h \
#  ftnameid.h ttdebug.h ttcalc.h ttfile.h ttengine.h ttmutex.h tttables.h \
#  ttobjs.h ttcache.h ttcmap.h ttgload.h ttmemory.h tttags.h ttload.h 
#
#ttinterp.o : ttinterp.c freetype.h fterrid.h ftnameid.h tttypes.h \
#  ttconfig.h ft_conf.h ttdebug.h ttcalc.h ttmemory.h ttinterp.h ttobjs.h \
#  ttengine.h ttmutex.h ttcache.h tttables.h ttcmap.h 
#
#ttload.o : ttload.c tttypes.h ttconfig.h ft_conf.h freetype.h fterrid.h \
#  ftnameid.h ttdebug.h ttcalc.h ttfile.h ttengine.h ttmutex.h tttables.h \
#  ttobjs.h ttcache.h ttcmap.h ttmemory.h tttags.h ttload.h 
#
#ttmemory.o : ttmemory.c ttdebug.h ttconfig.h ft_conf.h ttmemory.h tttypes.h \
#  freetype.h fterrid.h ftnameid.h ttengine.h ttmutex.h 
#
#ttobjs.o : ttobjs.c ttobjs.h ttconfig.h ft_conf.h ttengine.h tttypes.h \
#  freetype.h fterrid.h ftnameid.h ttmutex.h ttcache.h tttables.h ttcmap.h \
#  ttfile.h ttdebug.h ttcalc.h ttmemory.h ttload.h ttinterp.h 
#
#ttraster.o : ttraster.c ttraster.h ttconfig.h ft_conf.h freetype.h \
#  fterrid.h ftnameid.h ttengine.h tttypes.h ttmutex.h ttdebug.h ttmemory.h 

##################### end of makefile ######################
