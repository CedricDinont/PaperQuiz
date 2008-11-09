<?php
	require_once('Quiz.class.php');
	require_once('quiz_common.php');

        $quiz = Quiz::getQuizById($_GET['quiz-id']);
        checkParentDirectoryInFilename($_GET['filename']);

function endsWith( $str, $sub ) {
  return (strcmp(substr( $str, strlen( $str ) - strlen( $sub ) ), $sub ) == 0);
}

$file = $quiz->getDir().$_GET['filename'];
$taille = filesize($file);
$array = explode("/", $file);
$simple_filename = $array[count($array)- 1];
//header("Content-Type: application/force-download; name=\"$simple_filename\"");
if (endsWith($file, ".ods")) {
  header("Content-Type: application/x-vnd.oasis.opendocument.spreadsheet; name=\"$simple_filename\"");
} else if (endsWith($file, ".jpg")) {
    header("Content-Type: image/jpeg; name=\"$simple_filename\"");
}
header("Accept-Ranges: bytes");
header("Content-Transfer-Encoding: binary");
header("Content-Length: $taille");
if (isset($_GET['attachment']) && ($_GET['attachment'] == "true")) {
  header("Content-Disposition: attachment; filename=\"$simple_filename\"");
}
header("Expires: 0");
header("Cache-Control: no-cache, must-revalidate");
header("Pragma: no-cache");
readfile("$file");
exit(); 

?>