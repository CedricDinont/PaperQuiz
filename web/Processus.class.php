<?php

include_once('Quiz.class.php');

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
		return new Processus($quiz, $command, $pid);
	}

	public static function getAllProcesses($quiz) {
		$processes = array();
		$d = dir($quiz->getProcessesDir());
		while (false !== ($entry = $d->read())) {
		  if ($entry[0] != '.') {
		    $processes[$entry] = new Processus($quiz, "", $entry);
		  }
		}
		$d->close();
		return $processes;
	}

}

?>
