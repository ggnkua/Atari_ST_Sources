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

function convertBlock($pixels, $num_bitplane) {
    $bp = array(
        0 => '0000000000000000',
        1 => '0000000000000000',
        2 => '0000000000000000',
        3 => '0000000000000000',
    );
    $x = 0;
    foreach ($pixels AS $pixel) {
        for ($b = $num_bitplane - 1 ; $b >= 0 ; $b--) {
            if ($pixel & pow(2, $b)) {
                $bp[$b][$x] = '1';
            }
        }
        $x++;
    }
    return $bp;
}

$ww = 96;
$hh = 256;

//$p = array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,14,13,12,11,10,9,8,7,6,5,4,3,2); // linear
//$p = array(1,2,3,4,5,6,7,8,9,10,10,11,12,12,13,13,14,14,15,15,15,15,15,15,15,15,15,15,15,14,14,13,13,12,12,11,10,10,9,8,7,6,5,4,3,2); // sin
$p = array(1,2,3,4,5,6,7,8,8,9,10,11,11,12,13,13,14,14,14,15,15,15,15,15,15,15,15,15,15,15,14,14,14,13,13,12,11,11,10,9,8,8,7,6,5,4,3,2,2,1,2,3,4,5,6,7,8,8,9,10,10,11,12,12,13,13,13,14,14,14,14,14,15,14,14,14,14,14,13,13,13,12,12,11,10,10,9,8,8,7,6,5,4,3,2,1); // double sin
//$p = array(1,2,2,3,3,4,4,5,5,6,6,6,7,7,8,8,8,9,9,10,10,10,11,11,11,12,12,12,13,13,13,13,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,14,14,14,14,14,13,13,13,13,12,12,12,11,11,11,10,10,10,9,9,8,8,8,7,7,6,6,6,5,5,4,4,3,3,2,2); // single ball
$plen = count($p);
echo 'PLEN=',$plen,PHP_EOL;

$image = imagecreatetruecolor($ww, $hh);

$black = imagecolorallocate($image, 0, 0, 0);
imagefill($image, 0, 0, $black);

$color = array();
for ($c = 1 ; $c < 16 ; $c++) {
    $color[$c] = imagecolorallocate($image, $c * 16 , $c * 16, $c * 16);
}

$block = '';
for ($y = 0 ; $y < $hh ; $y++) {
    $pos_x =
        0
        + 6 * sin(deg2rad((360/256)*$y*2))
        + 3 * sin(deg2rad((360/256)*$y*4))
        - 120
        ;
    $current = 0;
    for ($x = $pos_x ; $x < 0 ; $x++) {
        $current = ($current + 1) % $plen;
    }
    $pixels = array();
    for ($x = 0 ; $x < $ww ; $x++) {
        $pixels[] = $p[$current];
        if (in_array($x, array(15,31,47,63,79,95))) {
            $bp = convertBlock($pixels, 4);
            for ($b = 0 ; $b < 4 ; $b++) {
                $block .= pack('n', bindec($bp[$b]));
            }
            $pixels = array();
        }
        imagesetpixel($image, $x, $y, $color[$p[$current]]);
        $current = ($current + 1) % $plen;
    }
}

imagepng($image, __DIR__ . '/plasmoil.png');
file_put_contents(__DIR__ . '/PLASMOIL.DAT', $block);

?>