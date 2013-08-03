path c:\tools;c:\mince;c:\
cp \BIOSSRC\ @cfls .c
cp \BIOSSRC\ @sfls .s
copy @hfls
copy @ofls
ren bios.h fs.h
