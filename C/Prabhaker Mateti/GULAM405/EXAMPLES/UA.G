# -------------------------------------------
# Copy a file to ram disk, 
# UUdecode it
# deARC it
# -------------------------------------------
# Works only for files with a certain naming conventions:
# Example:
# Suppose a bunch of files have been collected into	JUNK.ARC .
# UUE has been used to create	JUNK.UUE .
# Somehow this last file is now on disk A:\  and you want to
# to recover the original bunch files, of files on drive D:.
# Type	ua JUNK. 

set fu $1.uue
set fa $1.arc

# copy the file to  D:
echo	cp	a:\$fu	d:\
	cp	a:\$fu	d:\
	
# UUDECODE it
echo	uud	d:\$fu	
	uud	d:\$fu
unset fu	

echo	arc v	d:\$fa 
	arc v	d:\$fa 
unset fa

exit
