<?php
	$_steps = 128;
	$_amp = 5;
	$result = array();
	$adjust = 5;

	for($i=0; $i<$_steps; $i++){
		$roundedval = round(sin($i/$_steps*2*Pi())*$_amp+$adjust);
		$result[] = $roundedval;
	}

	foreach($result as $id=>$val){
	    echo "\tdc.w\t" . $val . "\n";
	}

?>
