<?php
	$nr_files = 50;														// nr of files
	$basename = "9/out";													// relpath + filename base

	$width = 64;
	$height = 40;


	for($i=0; $i<$nr_files; $i++){
		$fileName = $basename . str_pad($i,5,0,STR_PAD_LEFT) . ".gif";		// determine name
		$image = imagecreatefromgif($fileName);
//		$uniques = array();

		for($y=0;$y<$height;$y++){
			echo "\tdc.b\t";
			for($x=0;$x<$width;$x++){
				if($x!=0){
					echo ",";
				}
				$col = imagecolorat($image, $y , $x);
				if($col==""){
					echo "0";
				}
				else{
					echo $col;
				}
			}
			echo "\n";
		}
		echo "\n\n";
	}

	print_r($uniques);


?>
