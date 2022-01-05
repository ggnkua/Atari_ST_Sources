echo "Packing VISION..."
rm -rf vpack/vision
mkdir -p vpack/vision

cd vpack/vision

echo "Copying sub-folders..."
cp ../../vision.in0 vision.ini
cp -R ../../DSP DSP/
cp -R ../../filtres filtres/
cp -R ../../langues langues/
cp -R ../../scripts scripts/
#cp -R /Y /E X:/documents/MonWeb/vision.doc/ldv ../../ldv/doc/
#cp -R /Y /E X:/documents/MonWeb/vision.doc/english/ldv ../../ldv/doc/english/
cp -R ../../ldv ldv/
rm ldv/ldv.c
mkdir temp
mkdir update

echo "Clean-up..."
find . -name "*.pdb" -type f -print0 | xargs -0 rm -f
find . -name "*.o" -type f -print0 | xargs -0 rm -f
find . -name "*.old" -type f -print0 | xargs -0 rm -f
rm -rf ldv/src/cntcol/perfs

echo "Copying main folder..."
cp ../../vision.prg .
cp ../../visionl.prg .
cp ../../tcw64.dat .
cp ../../tcw128.dat .
cp ../../vision.img .
cp ../../license.txt .
cp ../../png.txt .
cp ../../cacert.pem .

echo "Generating vision.ver..."
cd ../../
str=$(cat defs.h | grep NO_VERSION | cut -d "\"" -f 2)
echo "Version =" $str > vision.ver
../RSHA256/bin/purec/rsha2.prg vpack/vision vision.ver
cp vision.ver vpack/vision