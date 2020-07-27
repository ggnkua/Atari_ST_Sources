




# count the number of arguments ----------------------------------------------
# example:		argc a b c

echo  '$0 ' $0
echo  '$1 ' $1
echo  '$2 ' $2
echo  '$3 ' $3
echo '-----'

set i 0
foreach xx { $- }
	set i $i + 1
endfor
echo '	--- ===' $i ' arguments === ---'

echo '-----'
echo  '$0 ' $0
echo  '$1 ' $1
echo  '$2 ' $2
echo  '$3 ' $3
echo '-----'
