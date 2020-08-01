$ !
$ !	"Makefile" for VMS versions of UnZip/ZipInfo and UnZipSFX
$ !	[makes default versions--use DESCRIP.MMS to enable VMSCLI]
$ !
$ ! Find out current disk, directory and compiler
$ !
$ my_name = f$env("procedure")
$ here = f$parse(my_name,,,"device") + f$parse(my_name,,,"directory")
$ axp = f$getsyi("HW_MODEL").ge.1024
$ if axp
$ then	cc = "cc/standard=vaxc"
$	opts = ""
$ else	opts = ",[.VMS]VMSSHARE.OPT/OPTIONS"
$	if (f$search("SYS$SYSTEM:VAXC.EXE").eqs."" .and. -
		f$trnlnm("GNU_CC").nes."") .or. (p1.eqs."GCC")
$	then	cc = "gcc"
$		opts = "''opts',GNU_CC:[000000]GCCLIB.OLB/LIB"
$	endif
$ endif
$ old_ver = f$ver(1)	! Turn echo on to see what's going
$ on error then goto error
$ !
$ CC   /NOLIST/OBJECT=UNZIP.OBJ UNZIP.C
$ CC   /NOLIST/OBJECT=CRYPT.OBJ CRYPT.C
$ CC   /NOLIST/OBJECT=ENVARGS.OBJ ENVARGS.C
$ CC   /NOLIST/OBJECT=EXPLODE.OBJ EXPLODE.C
$ CC   /NOLIST/OBJECT=EXTRACT.OBJ EXTRACT.C
$ CC   /NOLIST/OBJECT=FILE_IO.OBJ FILE_IO.C
$ CC   /NOLIST/OBJECT=INFLATE.OBJ INFLATE.C
$ CC   /NOLIST/OBJECT=MATCH.OBJ MATCH.C
$ CC   /NOLIST/OBJECT=UNREDUCE.OBJ UNREDUCE.C
$ CC   /NOLIST/OBJECT=UNSHRINK.OBJ UNSHRINK.C
$ CC   /NOLIST/OBJECT=ZIPINFO.OBJ ZIPINFO.C
$ CC   /INCLUDE=SYS$DISK:[] /OBJ=[.VMS]VMS.OBJ; [.VMS]VMS.C
$ LINK /NOTRACE/EXE=UNZIP.EXE unzip.obj;, crypt.obj;, envargs.obj;, -
	explode.obj;, extract.obj;, file_io.obj;, inflate.obj;, match.obj;, -
	unreduce.obj;, unshrink.obj;, zipinfo.obj;, [.VMS]vms.obj; 'opts'
$ !
$ CC   /DEF=SFX/NOLIST/OBJECT=UNZIP_.OBJ UNZIP.C
$ CC   /DEF=SFX/NOLIST/OBJECT=EXTRACT_.OBJ EXTRACT.C
$ CC   /DEF=SFX/INCLUDE=SYS$DISK:[] /OBJ=[.VMS]VMS_.OBJ; [.VMS]VMS.C
$ LINK /NOTRACE/EXE=UNZIPSFX.EXE unzip_.obj;, crypt.obj;, extract_.obj;, -
	file_io.obj;, inflate.obj;, match.obj;, [.VMS]vms_.obj; 'opts'
$ !
$ ! Next line:  put similar lines (full pathname for unzip.exe) in
$ ! login.com.  Remember to include the leading "$" before disk name.
$ !
$ unzip == "$''here'unzip.exe"		! set up symbol to use unzip
$ zipinfo == "$''here'unzip.exe ""-Z"""	! set up symbol to use zipinfo
$ !
$ RUNOFF/OUT=UNZIP.HLP [.VMS]UNZIP_DEF.RNH
$ !
$error:
$ tmp = f$ver(old_ver)
$ exit
