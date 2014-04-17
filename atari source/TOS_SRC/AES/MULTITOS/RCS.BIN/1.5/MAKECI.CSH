#
# script to check in a new version
# NOTE: this script works only under MultiTOS
#
set lastvers=`cat lastvers`
echo "Last RCS version number was:" $lastvers
echo -n "Enter version number: "
set vers=$<
echo -n "Enter version message: "
set descr=$<
set files=`cat ci.lis`
ci "-l$vers" -f "-m$descr" $files
#
# binary files must be copied verbatim
#
echo "Copying binary files..."
mkdir rcs.bin\$vers
set files=`cat cp.lis`
foreach i ($files)
	cmp $i rcs.bin\$lastvers\$i
	if ($status) then
		cp $i rcs.bin\$vers\$i
	else
		echo $i is unchanged since version $lastvers
	endif
end
#
# all done
#
echo $vers >lastvers
unset i lastvers vers descr files
