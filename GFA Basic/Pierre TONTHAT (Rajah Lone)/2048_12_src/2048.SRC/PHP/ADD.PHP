<?
require("../includes/config.php"); 

$DBTable = "highscores_2048";

date_default_timezone_set("Europe/Paris");

$avant = array ("'");
$apres = array (" ");

$score = intval($_POST['score']);

$key = intval($_POST['key']);

$nickname = str_replace($avant, $apres, $_POST['nickname']);
if (strlen($nickname) > 56) { $nickname = substr($nickname, 0, 56); }

$location = str_replace($avant, $apres, $_POST['location']);
if (strlen($location) > 56) { $location = substr($location, 0, 56); }

$version = str_replace($avant, $apres, $_POST['version']);
if (strlen($version) > 56) { $version = substr($version, 0, 56); }

$magic = $_POST['magic'];

if (($magic === "atari2048") && (strlen($nickname) > 0) && ($score > 0))
{
	$link = mysql_connect("$DBHost", "$DBUser", "$DBPass") or die("no database connection");
    mysql_select_db("$DBName");

	$res = mysql_query("SELECT * FROM $DBTable WHERE nickname = '$nickname' AND clef = $key ") or die (mysql_error());

    $nombre = mysql_num_rows($res);

	mysql_free_result($res);

    if ($nombre == 1) 
    {
    	$exe = mysql_query("UPDATE $DBTable SET score = $score, location = '$location', version = '$version' WHERE nickname = '$nickname' AND clef = $key AND score < $score ") or die (mysql_error());
    }
    else if ($nombre == 0)
    {
    	$exe = mysql_query("INSERT INTO $DBTable (score, nickname, location, version, clef) VALUES ($score, '$nickname', '$location', '$version', $key) ") or die (mysql_error());
	}
	
	if ($exe) { echo "OK"; } else { echo "UNCHANGED"; }

	$res = mysql_query("SELECT * FROM $DBTable ORDER BY score DESC ") or die (mysql_error());

    $nombre = mysql_num_rows($res);

	if ($nombre > 100)
	{
		$rank = 1;
		$keep = 0;
		while(($col = mysql_fetch_array($res)) && ($keep == 0))
		{    
			if ($rank == 100) { $keep = $col["score"]; }
			
			$rank +=1;
		}
		if ($keep > 0)
		{
    		$exe = mysql_query("DELETE FROM $DBTable WHERE score < $keep ") or die (mysql_error());
		}
	}

	mysql_free_result($res);
	
	mysql_close($link); 
}
else 
{
	echo "FAILED";
}
echo "\r\n";
?>