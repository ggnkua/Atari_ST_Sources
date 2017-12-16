<?php

// Background texture by Skywalker / Exo7

$palette = __DIR__ . '/palette.png';
$image = imagecreatefrompng($palette);
list($width, $height, $type, $attr) = getimagesize($palette);

if ($width != 8) {
    die('ERROR: palette should be 8 pixels wide' . PHP_EOL);
}

$colors = array(
    '000' => 0,
    '012' => 1,
    '123' => 2,
    '234' => 3,
    '345' => 4,
    '456' => 5,
    '567' => 6,
    '677' => 7,
);

$txt = $bin = '';

for ($j = 0 ; $j < $height ; $j++) {
    $long = 0;
    for ($i = 0 ; $i < $width ; $i++) {
        $rgb = imagecolorsforindex($image, imagecolorat($image, $i, $j));
        $r = round($rgb['red'] * 7 / 255, 0);
        $g = round($rgb['green'] * 7 / 255, 0);
        $b = round($rgb['blue'] * 7 / 255, 0);
        $color = $colors[$r . $g . $b];
        $long = ($long << 4) + $color;
    }
    $txt .= "\t" . 'dc.l $' . dechex($long) . "\r\n";
    $bin .= pack('N',  $long);
}

file_put_contents(__DIR__ . '/../INC/PALETTE.S',   $txt);
file_put_contents(__DIR__ . '/../INC/PALETTE.BIN', $bin);

?>