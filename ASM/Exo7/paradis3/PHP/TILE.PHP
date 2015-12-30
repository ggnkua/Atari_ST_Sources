<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate tile structure                                              |
# +======================================================================+
# | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
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

require_once __DIR__ . '/include.php';

$tilemap = file_get_contents(__DIR__ . '/map.tmx');

$xml = simplexml_load_string($tilemap);

$width  = $xml->layer['width'];
$height = $xml->layer['height'];
echo 'Map size : ', $width, 'x', $height, PHP_EOL;

// Create an array [width x height]

$tiles = array();
$array = array();
$c = 0;
for ($j = 0 ; $j < $height ; $j++) {
    for ($i = 0 ; $i < $width ; $i++) {
        $gid = (int) $xml->layer->data->tile[$c++]['gid'];
        $tiles[$gid] = array();
        $array[$j][$i] = $gid;
    }
}

// Split for every character

$font = array();
for ($y = 0 ; $y < ($height / $numTileY) ; $y++) {
    for ($x = 0 ; $x < ($width / $numTileX) ; $x++) {
        $zero = 0;
        $tmp = array();
        for ($j = 0 ; $j < $numTileY ; $j++) {
            for ($i = 0 ; $i < $numTileX ; $i++) {
                $val = $array[$y * $numTileY + $j][$x * $numTileX + $i];
                $zero += $val;
                $tmp[$j][$i] = $val;
            }
        }
        $ascii = $y * ($width / $numTileX) + $x + 32;
        if (($ascii == 32) or ($zero > 0)) {
            $font[chr($ascii)] = $tmp;
        }
    }
}

// Write inc_tile.php file

$struct = '<?php' . PHP_EOL;

$gpl = file(__DIR__ . '/../Makefile');
foreach ($gpl as $line) {
    if (substr($line, 0, 2) == '# ') $struct .= $line;
    else break;
}
$struct .= PHP_EOL;

// Tiles

echo count($tiles), ' different tiles used in map', PHP_EOL;

$image = imagecreatefrompng(__DIR__ . '/' . $mapTile);
$struct .= '$tiles = array(' . PHP_EOL;
foreach ($tiles AS $key => $tile) {
    $struct .= '    ' . $key . ' => array(' . PHP_EOL;
    if ($key == 0) {    
        $src_x = 5;
        $src_y = 5; // an empty space at the bottom right
    } else {
        $src_y = floor(($key - 1) / $tileMapWidth);
        $src_x = $key - 1 - $src_y * $tileMapWidth;
    }
    if ($src_x < 0 or $src_x > $tileMapWidth - 1 or $src_y < 0 or $src_y > $tileMapHeight - 1) {
        die('ERROR Key = '. $key. ' / SRC_X = ' . $src_x . ' / SRC_Y = ' . $src_y);
    }
    for ($j = 0 ; $j < $heightTile ; $j++) {
        $struct .= '        array(';
        for ($i = 0 ; $i < $widthTile ; $i++) {
            $rgb = imagecolorsforindex($image, imagecolorat($image, $src_x * $widthTile + $i, $src_y * $heightTile + $j));
            $r = substr('00' . dechex($rgb['red']), -2);
            $g = substr('00' . dechex($rgb['green']), -2);
            $b = substr('00' . dechex($rgb['blue']), -2);
            $idx = array_search(strtoupper($r . $g . $b), $idxColor);
            if ($idx === FALSE) {
                die (
                    'Color not defined : ' . strtoupper($r . $g . $b) .
                    ' for tile (' . ($src_x + 1) . ',' . ($src_y + 1) . ')' .
                    ' at pos (' . ($i + 1) . ',' . ($j + 1) . ')' .
                    PHP_EOL
                );
            }
            $struct .= substr('  ' . $idx, -2) . ',';
        }
        $struct .= '),' . PHP_EOL;
    }
    $struct .= '    ),' . PHP_EOL;
}
$struct .= ');' . PHP_EOL;

// Font

echo count($font), ' characters found in map : ', implode('', array_keys($font)), PHP_EOL;

$struct .= '$font = array(' . PHP_EOL;
foreach ($font AS $key => $char) {
    $quote = ($key === '"') ? '\'' : '"';
    $struct .= '    ' . $quote . $key . $quote . ' => array(';
    $sep = '';
    // Compute font width
    if ($key === ' ') {
        $fontWidth = 2;
    } else {
        $arrWidth = array();
        for ($i = 0 ; $i < $numTileX ; $i++) {
            $arrWidth[$i] = 0;
        }
        for ($j = 0 ; $j < $numTileY ; $j++) {
            for ($i = 0 ; $i < $numTileX ; $i++) {
                if ($char[$j][$i] > 0) {
                    $arrWidth[$i] = 1;
                }
            }
        }
        $fontWidth = 0;
        for ($i = 0 ; $i < $numTileX ; $i++) {
            if ($arrWidth[$i] == 1) {
                $fontWidth = $i + 1;
            }
        }
    }
    // Write font data
    for ($j = 0 ; $j < $numTileY ; $j++) {
        for ($i = 0 ; $i < $fontWidth ; $i++) {
            $struct .= $sep . substr('   ' . $char[$j][$i], -2);
            $sep = ',';
        }
    }
    $struct .= '),' . PHP_EOL;
}
$struct .= ');' . PHP_EOL;

// End of file

$struct .= '?>';
file_put_contents(__DIR__ . '/inc_tile.php', $struct);
echo 'File <INC_TILE.PHP> saved.', PHP_EOL;

?>