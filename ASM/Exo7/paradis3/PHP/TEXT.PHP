<?php
# +======================================================================+
# | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
# +----------------------------------------------------------------------+
# | Generate precalculated text structure                                |
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
require_once __DIR__ . '/inc_tile.php';

$repeatText = 26;

$config = array(
    'TEXTDEMO' => array('text' => $textDemo,  'prefix' => 'textDemo',  'cntCombination' => TRUE,),
    'TEXTINTR' => array('text' => $textIntro, 'prefix' => 'textIntro', 'cntCombination' => FALSE),
);

$text = '';
foreach ($config AS $fileName => $param) {
    $text .= $param['text'];
}

/*==============================================================*/
/* Check that all the characters used are available in the font */
/*==============================================================*/

$error = array();
for ($c = 0 ; $c < strlen($text) ; $c++) {
    $char = $text[$c];
    if (! isset($font[$char])) {
        $error[] = $char;
    }
}
if (! empty($error)) {
    die(PHP_EOL . 'ERROR : Characters not found : ' . implode('', array_unique($error)) . PHP_EOL . PHP_EOL);
}

/*==========================*/
/* Generates the $raw array */
/*==========================*/

function genRaw($text) {

    global $font, $numTileY;

    $genCacheWidth = 0;

    $raw = array();
    for ($j = 0 ; $j < $numTileY ; $j++) {
        $raw[$j] = array();
    }
    for ($c = 0 ; $c < strlen($text) ; $c++) {
        $char = $text[$c];
        $tile = $font[$char];
        $fontWidth = count($tile) / 6;
        $genCacheWidth += $fontWidth;
        for ($j = 0 ; $j < $numTileY ; $j++) {
            for ($i = 0 ; $i < $fontWidth ; $i++) {
                $raw[$j][] = $tile[$j * $fontWidth + $i];
            }
        }
    }
    
    return array($raw, $genCacheWidth);

}

list($raw, $genCacheWidth) = genRaw($text);

/*======================================*/
/* Generate the $combination_list array */
/*======================================*/

$combination_list = array();
for ($j = 0 ; $j < $numTileY ; $j++) {
    $max = count($raw[$j]);
    for ($i = 0 ; $i < $max ; $i++) {
        $val1 = $raw[$j][$i];
        $val2 = $raw[$j][($i < $max - 1) ? $i + 1 : 0];
        $idx = $val1 . '-' . $val2;
        $c = array_search($idx, $combination_list);
        if ($c === FALSE) {
            $c = count($combination_list);
            $combination_list[$c] = $idx;
        }
    }
}

echo 'Tiles combinations found : ', count($combination_list), PHP_EOL;

/*=======================================*/
/* Add a pixel to the bitplane structure */
/*=======================================*/

function asm_add(&$asm1, &$asm2, $x, $y, $color) {
    $bin = substr('0000' . decbin($color), -4);
    if ($bin[3] == '1') $asm1[$y][$x +  0] = '1';
    if ($bin[2] == '1') $asm1[$y][$x + 16] = '1';
    if ($bin[1] == '1') $asm2[$y][$x +  0] = '1';
    if ($bin[0] == '1') $asm2[$y][$x + 16] = '1';
}

/*=================================*/
/* Generate PNG picture + ASM data */
/*=================================*/

// PNG picture
$image_width = $widthTile;
$image_height = count($combination_list) * 16 * $heightTile;
$image = imagecreatetruecolor ($image_width, $image_height);

// ASM data
$asm1 = $asm2 = array();
for ($c = 0 ; $c < $image_height ; $c++) {
    $asm1[$c] = '00000000000000000000000000000000';
    $asm2[$c] = '00000000000000000000000000000000';
}

// Go through all possible combinations
$cntCombination = count($combination_list);
foreach ($combination_list AS $combi_id => $combi) {
    list($g, $d) = explode('-', $combi);
    for ($decal = 0 ; $decal < $widthTile ; $decal++) {
        for ($ligne = 0 ; $ligne < $heightTile ; $ligne++) {
            $y = $combi_id * $heightTile +
                 $decal * $cntCombination * $heightTile +
                 $ligne;
            for ($x = 0 ; $x < $widthTile ; $x++) {
                if ($x < $widthTile - $decal) {
                    $xt = $x + $decal;
                    $col = $tiles[$g][$ligne][$xt];
                } else {
                    $xt = $x - $widthTile + $decal;
                    $col = $tiles[$d][$ligne][$xt];
                }
                // PNG picture
                if ($col >= 0) {
                    $rgb = $idxColor[$col];
                    $color = imagecolorallocate($image,  hexdec(substr($rgb, 0, 2)),  hexdec(substr($rgb, 2, 2)), hexdec(substr($rgb, 4, 2)));
                    imagesetpixel($image, $x, $y, $color);
                }
                // ASM data
                if ($col == -1) {
                    asm_add($asm1, $asm2, $x, $y, ($x % 8) + 1); // Background color (1..8)
                } else {
                    asm_add($asm1, $asm2, $x, $y, $col);
                }
            }
        }
    }
}

/*===============*/
/* Save BIN file */
/*===============*/

$fp = fopen(__DIR__ . '/../INC/FONT.BIN', 'w');
$c = 0;
foreach ($combination_list AS $combi_id => $combi) {
    for ($decal = 0 ; $decal < 16 ; $decal++) {
        for ($ligne = 0 ; $ligne < $heightTile ; $ligne++) {
            fwrite($fp, pack('N', bindec($asm1[$c]))); // 32 bit, big endian byte order
            fwrite($fp, pack('N', bindec($asm2[$c]))); // 32 bit, big endian byte order
            $c++;
        }
    }
}
fclose($fp);
echo 'File <FONT.BIN> saved (', ($c * 8), ' bytes).', PHP_EOL;

/*===============*/
/* Save PNG file */
/*===============*/

imagepng($image, __DIR__ . '/../INC/FONT.PNG');
imagedestroy($image);
echo 'File <FONT.PNG> saved.', PHP_EOL;

/*===============================*/
/* Generate all the scroll texts */
/*===============================*/

foreach ($config AS $fileName => $param) {

    /*====================*/
    /* Generate structure */
    /*====================*/

    list($raw, $genCacheWidth) = genRaw($param['text']);

    $combination = array();
    for ($j = 0 ; $j < $numTileY ; $j++) {
        $max = count($raw[$j]);
        for ($i = 0 ; $i < $max ; $i++) {
            $val1 = $raw[$j][$i];
            $val2 = $raw[$j][($i < $max - 1) ? $i + 1 : 0];
            $idx = $val1 . '-' . $val2;
            $combination[$j][$i] = array_search($idx, $combination_list);
        }
    }

    /*========================*/
    /* Write TXT_INC.BIN file */
    /*========================*/

    $genCacheSize = $genCacheWidth * $numTileY;

    $size = 0;
    $fp = fopen(__DIR__ . '/../INC/' . $fileName . '.BIN', 'w');
    for ($j = 0 ; $j < $numTileY ; $j++) {
        foreach ($combination[$j] AS $val) {
            fwrite($fp, chr($val));
            $size++;
        }
        for ($i = 0 ; $i < $repeatText ; $i++) {
            $val = $combination[$j][$i % $genCacheWidth];
            fwrite($fp, chr($val));
            $size++;
        }
    }
    fclose($fp);
    echo 'File <' . $fileName . '.BIN> saved (2*' . $size . ' = ' . ($size * 2) . ' bytes).', PHP_EOL;

    /*======================*/
    /* Write TXT_INC.S file */
    /*======================*/

    $rawCacheWidth = $genCacheWidth;
    $genCacheWidth += $repeatText;
    $genCacheSize = $genCacheWidth * $numTileY;

    $struct = '';
    if ($param['cntCombination']) {
        $struct .= 'cntCombination:' . "\t\t" . 'dc.w ' . $cntCombination. "\r\n\r\n";
    }
    $struct .=
        //$param['prefix'] . 'WidthRaw:' . "\t" . 'dc.w ' . $rawCacheWidth . "\r\n" .
        //$param['prefix'] . 'WidthRawX2:' . "\t" . 'dc.l ' . ($rawCacheWidth * 2) . "\r\n" .
        //$param['prefix'] . 'WidthRawX4:' . "\t" . 'dc.l ' . ($rawCacheWidth * 4) . "\r\n" .
        //$param['prefix'] . 'WidthRawX8:' . "\t" . 'dc.l ' . ($rawCacheWidth * 8) . "\r\n" .
        $param['prefix'] . 'WidthRawX16:' . "\t" . 'dc.l ' . ($rawCacheWidth * 16) . "\r\n" .
        "\r\n" .
        //$param['prefix'] . 'Width:' . "\t\t" . 'dc.w ' . $genCacheWidth . "\t" . '; ' . $rawCacheWidth . ' + ' . $repeatText . ' repeated chars' . "\r\n" .
        $param['prefix'] . 'WidthX2:' . "\t" . 'dc.l ' . ($genCacheWidth * 2) . "\r\n" .
        $param['prefix'] . 'WidthX4:' . "\t" . 'dc.l ' . ($genCacheWidth * 4) . "\r\n" .
        //$param['prefix'] . 'WidthX8:' . "\t" . 'dc.l ' . ($genCacheWidth * 8) . "\r\n" .
        //$param['prefix'] . 'WidthX16:' . "\t" . 'dc.l ' . ($genCacheWidth * 16) . "\r\n" .
        "\r\n" .
        $param['prefix'] . 'Size:' . "\t\t" . 'dc.w ' . $genCacheSize . "\t" . '; ' . $genCacheWidth . '*' . $numTileY . "\r\n";
    file_put_contents(__DIR__ . '/../INC/' . $fileName . '.S', $struct);
    echo 'File <' . $fileName . '.S> saved.', PHP_EOL;

}

?>