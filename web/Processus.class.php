<?php

include_once('Quiz.class.php');
include_once('quiz_common.php');

class Processus {

	private $pid;
	private $command;
	private $quiz;

	public function __construct($_quiz, $_command, $_pid) {
		$this->quiz = $_quiz;
		$this->pid = $_pid;
		$this->command = $_command;
	}

	public function getPid() {
		return $this->pid;
	}

	public function getCommand() {
		return $this->command;
	}

	public function kill() {

	}

	public function getStandardOutputText() {

	}

	public function getErrorOutputText() {

	}

	public static function createBackgroundProcess($quiz, $command) {
		global $quiz_bin_dir; 
		$pid = exec($command." > /tmp/".$quiz->getName().".stdout 2> /tmp/".$quiz->getName().".stderr & PID=\$!; echo \$PID; ".$quiz_bin_dir."wait_process.sh ".$quiz->getName()." \$PID > /tmp/wait.txt &");
		$f = fopen("/tmp/".$quiz->getName().".info", "w");
		fwrite($f, $pid."\n");
		fclose($f);
		return new Processus($quiz, $command, $pid);
	}

	public static function getAllProcesses($quiz) {
		$processes = array();
		$d = dir($quiz->getProcessesDir());
		while (false !== ($entry = $d->read())) {
		  if (($entry[0] != '.') && (strncmp(substr($entry, -5), ".info", 5) == 0)) {
		    $processes[$entry] = new Processus($quiz, "", substr($entry, 0, strlen($entry) - 5));
		  }
		}
		$d->close();
		return $processes;
	}

	public static function startQuizScriptAndViewCreatedProcess($quiz_id, $script) {
	  global $quiz_bin_dir;

	  $q = Quiz::getQuizById($quiz_id);
	  
	  if ($q->hasRunningProcess()) {
	  		echo "<html><head><title>Erreur</title></head><body>Erreur: un processus est déjà actif pour ce quiz.<br><br>";
	  		global $quiz;
	  	     $quiz = $q;
	  		doMainMenu();
	  		echo "</body></html>";
	  		return ;
	  }
	  
	  $p = Processus::createBackgroundProcess($q, $quiz_bin_dir.$script." ".$q->getName());
	  echo "<html><head><title>Redirection vers la visualisation de la sortie du processus</title>";
	  echo "<meta http-equiv=\"REFRESH\" content=\"0; URL=./view_process_progress.php?quiz-id=".$quiz_id."\">";
       echo "</head><body>Redirection</body></html>";
	}

}

?>
