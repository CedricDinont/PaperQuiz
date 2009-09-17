<?php

include_once('Quiz.class.php');
include_once('quiz_common.php');

class Processus {

	private $pid;
	private $command;
	private $quiz;
	private $time;

	public function __construct($_quiz, $_command, $_pid, $_time) {
		$this->quiz = $_quiz;
		$this->pid = $_pid;
		$this->command = $_command;
		$this->time = $_time;
	}

	public function getPid() {
		return $this->pid;
	}

	public function getCommand() {
		return $this->command;
	}

	public function getTime() {
		return $this->time;
	}

	public static function compareByTime($a, $b) {
		if ($a->getTime() == $b->getTime()) {
			return 0;
		} else if ($a->getTime() < $b->getTime()) {
			return 1;
		} else {
			return -1;
		}
	}

	public function kill() {

	}

	public function getStandardOutputText() {

	}

	public function getErrorOutputText() {

	}

	public static function createBackgroundProcess($quiz, $command) {
		global $quiz_bin_dir;
		$time = time();
		touch("/tmp/".$quiz->getName().".stdout");
		touch("/tmp/".$quiz->getName().".stderr");
		$pid = exec($command." > /tmp/".$quiz->getName().".stdout 2> /tmp/".$quiz->getName().".stderr & PID=\$!; echo \$PID; ".$quiz_bin_dir."wait_process.sh ".$quiz->getName()." \$PID > /tmp/wait.txt &");
		$f = fopen("/tmp/".$quiz->getName().".info", "w");
		fwrite($f, $pid."\n");
		fwrite($f, $command."\n");
		fwrite($f, $time."\n");
		fclose($f);
		return new Processus($quiz, $command, $pid, $time);
	}

	public static function getAllProcesses($quiz) {
		$processes = array();
		$d = dir($quiz->getProcessesDir());
		while (false !== ($entry = $d->read())) {
		  if (($entry[0] != '.') && (strncmp(substr($entry, -5), ".info", 5) == 0)) {
		    $file_content = file($quiz->getProcessesDir() . $entry);
		    if (isset($file_content[1])) {
		      $command = trim($file_content[1]);
		    } else {
		      $command = "Commande inconnue";
		    }
                    if (isset($file_content[2])) {
                      $time = trim($file_content[2]);
                    } else {
                      $time = 0;
                    }		
		    $processes[$entry] = new Processus($quiz, $command, trim($file_content[0]), $time);
		  }
		}
		$d->close();
		usort($processes, array("Processus", "compareByTime"));
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
//	  sleep(1); // Pour éviter d'avoir une erreur indiquant que les fichiers de log ne sont pas encore créés. TODO: A remplacer par quelque chose de mieux.
	  echo "<html><head><title>Redirection vers la visualisation de la sortie du processus</title>";
	  echo "<meta http-equiv=\"REFRESH\" content=\"0; URL=./view_process_progress.php?quiz-id=".$quiz_id."\">";
          echo "</head><body>Redirection</body></html>";
	}

}

?>
