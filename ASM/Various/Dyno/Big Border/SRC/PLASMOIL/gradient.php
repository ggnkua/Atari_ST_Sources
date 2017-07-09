<?php
# +======================================================================+
# | Big Border Demo - Utility script                                     |
# +======================================================================+
# | Copyright (c) 2017 Frederic Poeydomenge <dyno@aldabase.com>          |
# +----------------------------------------------------------------------+
# | This program is free software: you can redistribute it and/or modify |
# | it under the terms of the GNU General Public License as published by |
# | the Free Software Foundation, either version 3 of the License, or    |
# | (at your option) any later version.                                  |
# |                                                                      |
# | This program is distributed in the hope that it will be useful,      |
# | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
# | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
# | GNU General Public License for more details.                         |
# |                                                                      |
# | You should have received a copy of the GNU General Public License    |
# | along with this program. If not, see <http://www.gnu.org/licenses/>. |
# +======================================================================+

$gradient = __DIR__ . '/gradient.png';

$source = imagecreatefrompng($gradient);
list($width, $height, $type, $attr) = getimagesize($gradient);

$palette = array();

for ($y = 0 ; $y < $height ; $y++) {
    $index = imagecolorat($source, 0, $y);
    $rgb   = imagecolorsforindex($source, $index);
    $r = round($rgb['red']   * 7 / 255, 0);
    $g = round($rgb['green'] * 7 / 255, 0);
    $b = round($rgb['blue']  * 7 / 255, 0);
    $palette[$y] = array($r, $g, $b);
}

// Crée le buffer

$image = imagecreatetruecolor(256,256);

$a1 = 24;
$a2 = 18;
$a3 = 12;

$bin = '';
for ($y = 0 ; $y < 256 ; $y++) {
    for ($x = 0 ; $x < 128 ; $x++) {
        
        $idx =
            0
            //+ round(sqrt((abs($x - 64) + 4) * (abs($y - 128) + 4)))
            + round($a1 + $a1 * sin(deg2rad((360/128)*$x*1)), 0)
            + round($a2 + $a2 * sin(deg2rad((360/128)*$x*2)), 0)
            + round($a3 + $a3 * sin(deg2rad((360/128)*$x*3)), 0)
            + round($a1 + $a1 * sin(deg2rad((360/256)*$y*1)), 0)
            + round($a2 + $a2 * sin(deg2rad((360/256)*$y*2)), 0)
            + round($a3 + $a3 * sin(deg2rad((360/256)*$y*3)), 0)
            ;
        
        $rgb = $palette[$idx % 128];
        $color = imagecolorallocate($image, $rgb[0] * 34, $rgb[1] * 34, $rgb[2] * 34);
        imagesetpixel($image, ($x * 2) + 0, $y, $color);
        imagesetpixel($image, ($x * 2) + 1, $y, $color);
        
        $bin .= pack('n', $rgb[0] * 0x100 + $rgb[1] * 0x10 + $rgb[2]);

    }
}

imagepng($image, __DIR__ . '/buffer.png');
file_put_contents(__DIR__ . '/GRADIENT.DAT', $bin);

?>