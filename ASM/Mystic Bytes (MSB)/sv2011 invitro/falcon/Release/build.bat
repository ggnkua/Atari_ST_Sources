:: convert msb logo
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\msb7.png 00_01.pic 00_01.pal

:: convert engine
"../../data\ExrConverter\Build\Windows\ExrConverter.exe" ../assets\spiralka\uv.exr 02_03.raw 2180 30
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\fotki/IMG_4206_crop_small.png 02_01.pic 02_01.pal
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_1.png 02_02.pic

:: convert wall
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\murek_2_128c.png 01_01.pic 01_01.pal
"../../data\ExrConverter\Build\Windows\ExrConverter.exe" ../assets\murek_1\uv.exr0012.exr 01_02.raw 1640 40
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_2_01.png 01_03.pic
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_2_02.png 01_04.pic
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_2_03.png 01_05.pic

:: convert crane scroll
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\crane+msb+credits.png 03_01.pic  03_01.pal

:: machine 1
"../../data\ExrConverter\Build\Windows\ExrConverter.exe" ../assets\machine_1\uv.exr0012.exr 04_03.raw 2048 32
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_4_01.png 04_02.pic
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\machine1.png 04_01.pic 04_01.pal

:: machine 2
"../../data\ExrConverter\Build\Windows\ExrConverter.exe" ../assets\machine_2\uv.exr0012.exr 05_03.raw 2048 32
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\text_5_01.png 05_02.pic
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\machine2.png 05_01.pic 05_01.pal

:: sv2011 logo
"../../data\PngConverter\Build\Windows\PngConverter.exe" ../assets\sv2011_logo.png 06_01.pic 06_01.pal