<?php
	$lines = file("wave268.txt");

	for($i=0;$i<1;$i++){
		$frameNumber = str_pad($i, 3, '0', STR_PAD_LEFT);
		$fileName= "results_". $frameNumber . ".json";
		$curFile = json_decode(file_get_contents($fileName),true);
		$sol = $curFile['sol'];
		$offset = $i * 269;
		foreach($sol as $spriteIndex){
			$tmp = $offset + $spriteIndex;

			echo $lines[$tmp];
		}
	}
?>