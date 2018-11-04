<?php
	$clears = 0;
	for($i=0;$i<360;$i++){
		$frameNumber = str_pad(($i%360), 3, '0', STR_PAD_LEFT);
		$fileName= "results_". $frameNumber . ".json";
		$curFile = json_decode(file_get_contents($fileName),true);	
		$clears+=$curFile['clearRemaining'];
	}
	echo	$clears/360;

?>