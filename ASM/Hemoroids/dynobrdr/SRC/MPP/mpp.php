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

if (empty($argv[1])) {
    die('[ERROR] Usage : php mpp.php IMAGENAME' . PHP_EOL);
}

$name = $argv[1];

$source256 = imagecreatefrompng('/tmp/' . $name . '256.png');
$source16  = imagecreatefrompng('/tmp/' . $name .  '16.png');

$destination = imagecreatetruecolor(96, 54);

$bin_palette = '';
$bin_image   = '';

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

for ($y = 0 ; $y < 54 ; $y++) {

    $colorz = array();
    for ($x = 0 ; $x < 96 ; $x++) {
        $index16  = imagecolorat($source16, $x, $y);
        $rgb16    = imagecolorsforindex($source16, $index16);
        $index256 = imagecolorat($source256, $x, $y);
        $rgb256   = imagecolorsforindex($source256, $index256);
        $colorz[$index16 + 1][] = $rgb256;
    }

    $palette = array();
    // Compute palette 0
    $palette[0] = array(0, 0, 0);
    $bin_palette .= pack('n', 0);
    // Compute palettes 1..15
    for ($c = 1 ; $c < 16 ; $c++) {
        // Compute average color
        $pixelCount = 0;
        $red = 0;
        $green = 0;
        $blue = 0;
        if (isset($colorz[$c])) {
            foreach ($colorz[$c] AS $col) {
                $pixelCount++;
                $red   += round($col['red']  * 7 / 255, 0);
                $green += round($col['green']* 7 / 255, 0);
                $blue  += round($col['blue'] * 7 / 255, 0);
            }
        }
        // Convert to Atari value
        if ($pixelCount > 0) {
            $r = round($red  /$pixelCount, 0);
            $g = round($green/$pixelCount, 0);
            $b = round($blue /$pixelCount, 0);
        } else {
            $r = 0;
            $g = 0;
            $b = 0;
        }
        // Compute palette
        $palette[$c] = array($r, $g, $b);
        $bin_palette .= pack('n', $r * 0x100 + $g * 0x10 + $b);
    }

    // Draw destination image
    for ($x = 0 ; $x < 96 ; $x++) {
        $index16 = imagecolorat($source16, $x, $y);
        list($r, $g, $b) = $palette[$index16 + 1];
        $color = imagecolorallocate($destination, $r * 34, $g * 34, $b * 34);
        imagesetpixel($destination, $x, $y, $color);
    }

    /* Parse Image */
    for ($x = 0 ; $x < 96 ; $x += 16) {
        $rgb = array();
        for ($k = 0 ; $k < 16 ; $k++) {
            $rgb[$k] = imagecolorat($source16, $x + $k, $y) + 1;
        }
        $bp = convertBlock($rgb, 4);
        for ($b = 0 ; $b < 4 ; $b++) {
            $bin_image .= pack('n', bindec($bp[$b]));
        }
    }

}

imagepng($destination, '/tmp/' . $name . 'SPC.png');

file_put_contents(__DIR__ . '/pics/' . $name . '.pal', $bin_palette);
file_put_contents(__DIR__ . '/pics/' . $name . '.img', $bin_image);

?>