#! /bin/sh

while test x$1 != x; do
	case $1 in
	-a)
		shift
		aut=`head -2 $1 | sed -n -e 's/^Copyright (C) [-0-9]*  \(.*\)$/\1/p'`
		sum=`head -1 $1 | sed -n -e 's/^[^-]*-- \(.*\)$/\1/p'`
		echo "* aut=$aut sum=$sum"
		shift
		;;
	-d)
		shift
		dir=$1
		echo "* dir=$dir"
		shift
		;;
	-t)
		shift
		pkg=$1
		echo "* pkg=$pkg"
		shift
		;;
	-v)
		shift
		versfile=$1
		shift
		oldarg=$*
		
		set - `sh verextr.sh $versfile /dev/null`
		shift
		vers=$1
		shift
		fruit=$1
		shift
		gen=$1
		shift
		shift
		vend=$1
		shift
		shift
		date=$*
		echo "* vers=$vers fruit=$fruit gen=$gen"
		echo "* vend=$vend date=$date"

		set - $oldarg
		;;
	-s)
		shift
		spec=$1
		echo "* spec=$spec"
		shift
		;;
	fixspec)
		shift
		if test ! -r $spec
		then
			echo "* Error: $spec not found or unreadable"
			exit 1
		fi
		mv -f $spec $spec.OLD
		oldrel=`head -25 $spec.OLD | sed -n -e 's/^Release: \([^ ]*\)$/\1/p'`
		oldvers=`head -25 $spec.OLD | sed -n -e 's/^Version: \([^ ]*\)$/\1/p'`
		if test x$vers != x
		then newvers=$vers
			if test x$oldvers != x$vers
			then rel=1
			else rel=$oldrel
			fi
		else newvers=$oldvers
		fi
		if test "x$sum" != x
		then desc=$sum
		else desc=`head -25 $spec.OLD | sed -n -e 's/^Summary: \(.*\)$/\1/p'`
		fi
		if test "x$vend" = x
		then vend=$ORGANIZATION
		fi
		echo "* patching $spec"
		echo "* + Summary: $desc"
		echo "* + Name: $pkg  Version: $newvers (old: $oldvers set: $vers)"
		echo "* + Vendor: $vend  Release: $rel (old: $oldrel)"
		echo "* + Author: $aut"
		sed -e '1,25s/^Summary: .*$/Summary: '"$desc"'/' \
		    -e '1,25s/^Version: [^ ]*$/Version: '"$newvers"'/' \
		    -e '1,25s/^Vendor: [a-zA-Z ]*$/Vendor: '"$vend"'/' \
		    -e '1,25s/^Name: [^ ]*$/Name: '"$pkg"'/' \
		    -e '1,25s/^Release: [^ ]*$/Release: '"$rel"'/' \
		    $spec.OLD > $spec
		echo "* done"
		;;
	makerpms)
		shift
		if test x$vers != x
		then
			base=$pkg-$vers
		else
			base=$pkg
		fi
		if test -r /tmp/$base.tar.gz
		then
			echo "* Rebuilding a binary RPM from /tmp/$base.tar.gz"
			rpm -tb --clean /tmp/$base.tar.gz
			echo "* done"
		else
			echo "* Rebuild requires the tar package in /tmp/$base.tar.gz"
			exit 1
		fi
		;;
	makedist)
		shift
		if test x$vers != x
		then
			base=$pkg-$vers
		else
			base=$pkg
		fi
		oldpwd=$PWD
		if test x$dir != x
		then
			echo "* Packing $base in $dir at $date"
			cd $dir
		else
			echo "* Packing $base at $date"
		fi
		oldbase=`basename $PWD`
		cd ..
		mv $oldbase $base
		tar czvf /tmp/$base.tar.gz $base
		mv $base $oldbase
		cd $oldpwd
		echo "* Inspect /tmp for the result"
		;;
	esac
done

