#! /bin/sh

while test x$1 != x; do
	case $1 in
	-a)
		shift
		aut=`head -2 $1 | sed -ne 's/^Copyright (C) [-0-9]*  \(.*\)$/\1/p'`
		sum=`head -1 $1 | sed -ne 's/^[^-]*-- \(.*\)$/\1/p'`
		echo "* aut=$aut sum=$sum"
		shift
		;;
	-d) shift; dir=$1; echo "* dir=$dir"; shift ;;
	-t) shift; pkg=$1; echo "* pkg=$pkg"; shift ;;
	-m) shift; manifest=$1; echo "* manifest=$manifest"; shift ;;
	-v)
		shift; versfile=$1; shift;
		oldarg=$*; set - `sh verextr.sh $versfile /dev/null`
		shift; vers=$1; shift; fruit=$1; shift; gen=$1; shift
		shift; vend=$1; shift; shift; date=$*
		echo "* vers=$vers fruit=$fruit gen=$gen"
		echo "* vend=$vend date=$date"

		set - $oldarg
		;;
	-s) shift; spec=$1; echo "* spec=$spec"; shift ;;
	check|chk|ck)
		shift
		if test ! -r $spec; then
			echo "* Error: $spec not found or unreadable"
			exit 1
		fi
		oldvers=`head -25 $spec | sed -ne 's/^Version: \([^ ]*\)$/\1/p'`
		if test x$vers != x -a x$vers != x$oldvers; then
			echo "* Spec version number mismatch, needs rebuild."
			exit 1
		fi
		echo "* Spec version check passed."
		;;
	fixspec|spec|sp)
		shift
		if test ! -r $spec; then
			echo "* Error: $spec not found or unreadable"
			exit 1
		fi
		mv -f $spec $spec.OLD
		oldrel=`head -25 $spec.OLD | sed -ne 's/^Release: \([^ ]*\)$/\1/p'`
		oldvers=`head -25 $spec.OLD | sed -ne 's/^Version: \([^ ]*\)$/\1/p'`
		if test x$vers != x; then
			newvers=$vers
			if test x$oldvers != x$vers; then rel=1; else rel=$oldrel; fi
		else
			newvers=$oldvers
		fi
		if test "x$sum" != x; then
			desc=$sum
		else
			desc=`head -25 $spec.OLD | sed -ne 's/^Summary: \(.*\)$/\1/p'`
		fi
		if test "x$vend" = x; then vend=$ORGANIZATION; fi
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
	makerpms|rpms|mr)
		shift
		if test x$vers != x; then base=$pkg-$vers; else base=$pkg; fi

		if test ! -r $base.tar.gz; then
			echo "* Rebuild requires the tar package in $base.tar.gz"
			exit 1
		fi

		echo "* Rebuilding a binary RPM from $base.tar.gz"
		rpm -tb --clean $base.tar.gz
		echo "* done"
		;;
	makedist|dist|md)
		shift
		if test x$vers != x; then base=$pkg-$vers; else base=$pkg; fi
		echo "$base/$base.tar.gz" > /tmp/manifest.$$
		if test x$manifest != x; then
			echo "* Calculating exclusion list."
			touch /tmp/manifest.$$
			for mask in `sed -ne 's/^\* SKIP=//p' $manifest`; do
				echo "* - $mask"
				echo "$base/$mask" >> /tmp/manifest.$$
			done
		fi
		oldpwd=$PWD
		if test x$dir != x; then
			echo "* Packing $base in $dir at $date"
			cd $dir
		else
			echo "* Packing $base at $date"
		fi
		oldbase=`basename $PWD`
		cd ..
		mv $oldbase $base
		tar czvf $base/$base.tar.gz -X /tmp/manifest.$$ $base
		mv $base $oldbase
		cd $oldpwd
		rm /tmp/manifest.$$
		echo "* Done."
		;;
	esac
done

# vim:ts=4

