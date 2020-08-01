# NMAKE Makefile for Windows NT
#   D. Feinleib 7/92 t-davefe@microsoft.com
#   H. Gessau 9/93 <henryg@kullmar.kullmar.se>
#
# Last revised:  10 Jul 94
#
# Tested with NT SDK, VC++ 1.0 for NT, and DEC C/C++ beta.
#
# For DEC C/C++, comment out the "cdebug = -Ogityb2" line (or 
# define debug?).  [Jack Stansbury]

# Nmake macros for building Windows NT applications
# To build with debug info use 'nmake debug=1'
!IFNDEF debug
NODEBUG=1
!ENDIF
!include <ntwin32.mak>

# object files
OBJS1 = unzip.obj crypt.obj envargs.obj explode.obj extract.obj file_io.obj
OBJS2 = inflate.obj match.obj unreduce.obj unshrink.obj zipinfo.obj nt.obj
OBJS  = $(OBJS1) $(OBJS2)
OBJX1 = unzipsfx.obj crypt.obj extract_.obj file_io.obj inflate.obj match.obj
OBJX2 = nt_.obj
OBJX  = $(OBJX1) $(OBJX2)
OBJF  = funzip.obj crypt_.obj inflate_.obj

# cvars = $(cvars) -nologo -DMSDOS -DNO_ASM -J
cvars = $(cvars) -nologo -DNO_ASM -J

# Some optimization (if not debugging)
!IFDEF NODEBUG
cdebug = -Ogityb2
!ENDIF

# How to compile sources
.c.obj:
	$(cc) $(cdebug) $(cflags) $(cvars) $<

# How to link
.obj.exe:
	$(link) $(ldebug) $(conflags) $(conlibs) $** -out:$@


# Default target is all the executables
unzips : unzip.exe funzip.exe unzipsfx.exe


unzip.exe:	$(OBJS)
unzipsfx.exe:	$(OBJX)
funzip.exe:	$(OBJF)

crypt.obj:	crypt.c unzip.h zip.h crypt.h
envargs.obj:	envargs.c unzip.h
explode.obj:	explode.c unzip.h
extract.obj:	extract.c unzip.h crypt.h
file_io.obj:	file_io.c unzip.h crypt.h tables.h
funzip.obj:	funzip.c unzip.h crypt.h tables.h
inflate.obj:	inflate.c inflate.h unzip.h
match.obj:	match.c unzip.h
unreduce.obj:	unreduce.c unzip.h
unshrink.obj:	unshrink.c unzip.h
unzip.obj:	unzip.c unzip.h crypt.h version.h
zipinfo.obj:	zipinfo.c unzip.h

nt.obj: 	nt\nt.c unzip.h
	$(cc) $(cdebug) $(cflags) $(cvars) -I. nt\nt.c
	
nt_.obj: 	nt\nt.c unzip.h					# unzipsfx only
	copy nt\nt.c nt_.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DSFX nt_.c
	del nt_.c
	
crypt_.obj:	crypt.c unzip.h zip.h crypt.h			# funzip only
	copy crypt.c crypt_.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DFUNZIP crypt_.c
	del crypt_.c

extract_.obj:	extract.c unzip.h crypt.h			# unzipsfx only
	copy extract.c extract_.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DSFX extract_.c
	del extract_.c

inflate_.obj:	inflate.c inflate.h unzip.h crypt.h		# funzip only
	copy inflate.c inflate_.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DFUNZIP inflate_.c
	del inflate_.c

unzipsfx.obj:	unzip.c unzip.h	crypt.h version.h		# unzipsfx only
	copy unzip.c unzipsfx.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DSFX unzipsfx.c
	del unzipsfx.c
  
zipinfo_.obj:	zipinfo.c unzip.h				# unzipsfx only
	copy zipinfo.c zipinfo_.c
	$(cc) $(cdebug) $(cflags) $(cvars) -DSFX zipinfo_.c
	del zipinfo_.c
  
clean:
	del /q $(OBJS) unzip.exe $(OBJF) funzip.exe $(OBJX) unzipsfx.exe
