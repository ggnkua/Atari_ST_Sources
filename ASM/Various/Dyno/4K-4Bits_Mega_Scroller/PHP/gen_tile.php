<?php

/*================================================*/
/* Inspired from the font by THE BLACK CATS, in   */
/* the hidden screen of the Vodka Demo by Equinox */
/* Credits : Conan (Form of the character set)    */
/*           Enculator (Graphics)                 */
/*================================================*/

mt_srand(4);

require_once 'gen_tile_funcs.php';
require_once 'gen_tile_matrix.php';
 
$palette = array(
    0 => array(0x00,0x00,0x00,127),
    1 => array(0xEE,0xEE,0xCC,  0),
    2 => array(0xEE,0xCC,0xAA,  0),
    3 => array(0xCC,0xAA,0x88,  0),
    4 => array(0xAA,0x88,0x66,  0),
    5 => array(0x88,0x66,0x44,  0),
    6 => array(0x66,0x44,0x22,  0),
    7 => array(0x44,0x22,0x00,  0),
    8 => array(0x22,0x00,0x00,  0),
);

$configuration = array(
    array($matrix['bg_medium'],getHorizontal('north'),getHorizontal('east'),getHorizontal('south')),
    array(getHorizontal('west'),getOblique('north'),getOblique('east'),getOblique('south')),
    array(getOblique('west'),getOblique2('north'),getOblique2('east'),getOblique2('south')),
    array(getOblique2('west'),getAngle('north'),getAngle('east'),getAngle('south')),
    array(getAngle('west'),NULL,NULL,NULL),
);

$im = imagecreatetruecolor(64, 80);
imagesavealpha($im, TRUE);
imagefill($im, 0, 0, imagecolorallocatealpha($im, 0, 0, 0, 127));
$map_y = 0;
foreach ($configuration AS $line) {
    $map_x = 0;
    foreach ($line AS $column) {
        for ($y = 0 ; $y < 16 ; $y++) {
            for ($x = 0 ; $x < 16 ; $x++) {
                $col = $column[$y][$x];
                if (is_null($col)) continue;
                if ($col < 0) { $col = 0; }
                if ($col > 8) { $col = 8; }
                $pal = $palette[$col];
                $color = imagecolorallocatealpha($im, $pal[0], $pal[1], $pal[2], $pal[3]);
                imagesetpixel($im, $map_x * 16 + $x, $map_y * 16 + $y, $color);
            }
        }
        $map_x++;
    }
    $map_y++;
}
imagepng($im, __DIR__ . '/text_tile_medium.png');

?>