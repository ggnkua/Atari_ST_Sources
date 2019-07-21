<?php

$source = __DIR__ . '/font.png';
$destin = __DIR__ . '/FONT.DAT';

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

$font = imagecreatefrompng($source);

$sizes = array();

$bin = '';
for ($y = 0 ; $y < 7 ; $y++) {
    for ($x = 0 ; $x < 10 ; $x++) {

        // Compute size
        $size = -1;
        for ($j = 0 ; $j < 6 ; $j++) {
            for ($i = 0 ; $i < 6 ; $i++) {
                $index = imagecolorat($font, ($x * 6) + $i, ($y * 6) + $j);
                if (($index > 0) and ($i > $size)) {
                    $size = $i;
                }
            }
        }
        $size++;
        if ($x + $y == 0) {
            $size = 2;
        }
        if ($size <= 0) {
            continue;
        }
        $sizes[chr($y * 10 + $x + 32)] = $size + 1;

        // Compute font
        for ($j = 0 ; $j < 6 ; $j++) {
            $pixels = array();
            for ($i = 0 ; $i < 6 ; $i++) {
                $index = imagecolorat($font, ($x * 6) + $i, ($y * 6) + $j);
                $pixels[] = $index;
            }
            $bps = convertBlock($pixels, 1);
            $byte = substr($bps[0], 0, 8);
            $bin .= pack('C', bindec($byte));
            //echo '  ', $byte, PHP_EOL;
        }
        $bin .= pack('C', $size + 1);

    }
}

if (strlen($bin) % 2 == 1) {
    $bin .= chr(0);
}

echo 'Done.', PHP_EOL;

file_put_contents(__DIR__ . '/sizes.php', json_encode($sizes));
echo '  Sizes.php written.', PHP_EOL;

file_put_contents($destin, $bin);
echo '  Font written : ', filesize($destin), ' bytes.', PHP_EOL;

?>