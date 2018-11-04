#!/bin/bash
cp out.tos sprite.tos
upx sprite.tos
upx -d sprite.tos
dd if=/dev/zero of=test.st bs=1 count=10240
cat sprite.tos >> test.st
FILESIZE=$(stat -f%z "test.st")
echo $FILESIZE
X=819200
FILESIZ=$(echo $X - $FILESIZE | bc)
echo $FILESIZ
dd if=/dev/zero of=tmp.bin bs=1 count=$FILESIZ
cat tmp.bin >> test.st
