echo "Packing GEMTAIL..."
rm -rf gtpack/GEMTAIL
mkdir -p gtpack/GEMTAIL
mkdir -p gtpack/GEMTAIL/LANG
mkdir -p gtpack/GEMTAIL/TEMPLATE

cd gtpack/GEMTAIL

echo "Generating GEMTAIL package..."
cp ../../lang/gemtail.rsc lang/

cp ../../gemtail.prg .
cp ../../license.txt .

cd ..
rm ../gemtail.zip
zip -r ../gemtail.zip gemtail

echo "Generating GEMTAIL Source package..."
echo "GEMTAIL sources..."
cd ..
rm -rf gtpack/SRCGTAIL
mkdir -p gtpack/SRCGTAIL
mkdir -p gtpack/SRCGTAIL/TOOLS
mkdir -p gtpack/SRCGTAIL/GEMTAIL
mkdir -p gtpack/SRCGTAIL/GEMTAIL/FORMS
cp -r FORMS/* gtpack/SRCGTAIL/GEMTAIL/FORMS
mkdir -p gtpack/SRCGTAIL/GEMTAIL/lang
cp -r lang/* gtpack/SRCGTAIL/GEMTAIL/lang
mkdir -p gtpack/SRCGTAIL/GEMTAIL/template
cp -r template/* gtpack/SRCGTAIL/GEMTAIL/template
cp * gtpack/SRCGTAIL/GEMTAIL
rm gtpack/SRCGTAIL/GEMTAIL/srcgtail.zip

echo "TOOLS sources..."
mkdir -p gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/XGEM.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/RASTEROS.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/RASTEROP.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/XFILE*.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/COOKIES.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/xmem.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/VA_START.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/GWINDOWS.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/LOGGING.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/XALLOC.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/INI.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/CLIPBRD.* gtpack/SRCGTAIL/TOOLS
cp ../TOOLS/SPATTERN.* gtpack/SRCGTAIL/TOOLS

echo "Zipping..."
cd gtpack
rm ../srcgtail.zip
zip -r ../srcgtail.zip SRCGTAIL

