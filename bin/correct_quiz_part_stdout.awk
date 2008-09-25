# normal usage: awk -f ../correcteur_quiz_part.awk -v outputmode=ooffice brut.txt

function int2letter(a,   b) {
    if(a==0) 
	return "";
    else {
	b=a-26*int((a)/26);
	if(b==0)
	    b=26;
	a=int((a-b)/26);
	s=sprintf("%s%c",int2letter(a),65-1+b);
    }
    return s;
}

BEGIN {
    FS=";";
    if(students=="")
	# file with students names
	# format: LASTNAME firstname code
	students="../students.txt";
    if(corrige=="")
	# correction file
	# format: question_number;number_of_possible_answers;expected_answers;bonif;malus;coefficient;bonus
	# example: 1;4;R2\R4;1;-.5;1;0
	# comments are possible with the "#" character
	# "bonus" are used for ill-posed questions
	corrige="corrige.txt";
#     if(good=="")
#     # number of points per right answer
#     good=+1;
#     if(bad=="")
#     # number of points per wrong answer, Warning - "bad" should be negative
#     bad=0;
    if(outputmode==openoffice)
	# OpenOffice output or stdout
	outputmode=ooffice
    if(ooffile=="")
	# OpenOffice output file
	ooffile="results.csv"
    if(statfile=="")
	# statistics per question
	statfile="/dev/stdout";
    if(binlength=="")
	# bining length for marks statistics
	binlength=2;
    if(OOFS=="")
	# OpenOffice separator
	# Do not use ";" since this sign is needed in OpenOffice functions (IF and so on)
	OOFS=",";

#   import student names
    while(getline<students>0) {
	split($0,a," ");
	absent[a[3]]=1; # a priori absent...
	if(outputmode=="ooffice")
	    stutab[a[3]]=sprintf("%s%c%s",a[1],OOFS,a[2]);
	else
	    stutab[a[3]]=sprintf("%-20s %-20s",a[1],a[2]);
	# a[3] might be a string like "P45079"
    }
    close(students);

#   import correction
    nr_questions=0;
    nr_fields_corr=7; # there should be 7 fields in file corrige, but keep it as a parameter...
    inputline=0; # trace inputline for warning outputs...
#   format: question_nr;nb_possible_answers;correct_answers(eg.R1\R5);bonif;malus;coef;bonus
    while(getline<corrige>0) {
	inputline++;
	if($1!~"#" && NF==nr_fields_corr) {
	    
	    if($1 in nr_answers) {
		# already seen!!!
		printf "WARNING - in \"%s\" line %d:\n\tquestion %d already defined --> use bonus!!\n",corrige,inputline,$1 > "/dev/stderr";
		bonus[$1]=1;
		corr[$1,0]=1;
	    } else {
		# normal way
		if($1>nr_questions)
		    nr_questions=$1;

		nr_answers[$1]=$2; # number of possible responses for question $1
		if($2>max_nr_answers)
		    max_nr_answers=$2;
		
		nr_correct[$1]=split($3,a,"\\");
		# nr_correct[q] (nr of correct answers at question "q") is used to compute mark
		if(nr_correct[$1]==0) {
		    printf "WARNING - in \"%s\" line %d question %d:\n\t no correct response!!\n",corrige,inputline,$1 > "/dev/stderr";
		    nr_correct[$1]=1; # prevent division by 0
		} else {
		    for(r in a) {
			gsub("R","",a[r]);
			corr[$1,a[r]]=1;
			# by default corr[x,y] is initialized at 0
			if(a[r]>nr_answers[$1]) {
			    printf "WARNING - in \"%s\" line %d question %d:\n\t response R%-2d out of range --> use bonus!!\n",corrige,inputline,$1,a[r] > "/dev/stderr";
			    bonus[$1]=1;
			}
		    }
		}
		good[$1]=$4;
		bad[$1]=$5;
		coeff[$1]=$6;

		if(bonus[$1]==0)
		    bonus[$1]=$7;

		minmark+=bad[$1]*coeff[$1]/nr_correct[$1]*(nr_answers[$1]-nr_correct[$1]);
		maxmark+=coeff[$1];
	    }
	} else if($1!~"#" && NF!=nr_fields_corr && NF>0)
	    # Wrong number of fields!!!
	    printf "WARNING - in \"%s\" line %d:\n\tWrong number of fields (found %d instead of %d) --> question ignored!!\n",corrige,inputline,NF,nr_fields_corr > "/dev/stderr";
    }
    close(corrige);
    printf "%d questions\n",nr_questions > "/dev/stdout";
    printf "Mark between %6.3f and %6.3f\n",minmark,maxmark > "/dev/stdout";

#   check corrige consistency: nr of questions should be equal to max(question_nr)
    for(q=1;q<=nr_questions;q++) {
	if( ! (q in nr_answers) ) {
	    printf "WARNING - in \"%s\":\n\tquestion %d undefined --> use bonus!!\n",corrige,q > "/dev/stderr";
	    nr_answers[q]=0;
	    coeff[q]=1;
	    bonus[q]=1;
	    corr[q,0]=1;
	}
    }

    # OpenOffice output
    if(outputmode=="ooffice") {
	# at this point, we suppose everything above correct
	colstart=4;
	colname1=int2letter(colstart);
	colname2=int2letter(nr_questions+colstart-1);

	printf "student_name%cstudent_first_name%cstudent_id",OOFS,OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c Q%3d",OOFS,q > ooffile;
	printf "%c TOTAL\n",OOFS > ooffile;
	###### NEWLINE

	printf "coefficients" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %f",OOFS,coeff[q] > ooffile;
	printf "%c=SUM($%s$2:$%s$2)\n",OOFS,colname1,colname2 > ooffile;
	###### NEWLINE

	printf "bonification" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %f",OOFS,good[q] > ooffile;
	printf "%c=SUMPRODUCT($%s$2:$%s$2;$%s$3:$%s$3)",OOFS,colname1,colname2,colname1,colname2 > ooffile;
	printf "%cmax_mark\n",OOFS > ooffile;
	###### NEWLINE

	printf "malus" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %f",OOFS,bad[q] > ooffile;
	printf "%c=SUMPRODUCT($%s$2:$%s$2;$%s$4:$%s$4;$%s$7:$%s$7;1/$%s$6:$%s$6)-SUMPRODUCT($%s$2:$%s$2;$%s$4:$%s$4;$%s$6:$%s$6;1/$%s$6:$%s$6)",OOFS,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2,colname1,colname2 > ooffile;
	printf "%cmin_mark\n",OOFS > ooffile;
	###### NEWLINE

	printf "bonus (gift)" > ooffile
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %4d",OOFS,bonus[q] > ooffile;
	printf "%c=SUM($%s$5:$%s$5)\n",OOFS,colname1,colname2 > ooffile;
	###### NEWLINE

	printf "nr_expected_answers" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %4d",OOFS,nr_correct[q] > ooffile;
	printf "%c=SUM(%s6:%s6)\n",OOFS,colname1,colname2 > ooffile;
	###### NEWLINE

	printf "nr_max_answers" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "%c %4d",OOFS,nr_answers[q] > ooffile;
	printf "%c=SUM(%s7:%s7)\n\n",OOFS,colname1,colname2 > ooffile;
	###### NEWLINE - NEWLINE

	line=9; # first student line !
	first_stuline=line;
    } else {
	printf "%-20s %-20s 0000    %6.3f  (min_mark=%6.3f)\n","#------","CORRIGE",maxmark,minmark;
    }
}

#-------------------------------------------------------------------------------------------------------------
$1!~"Code" {
    absent[$1]=0;
    # globstudmark[$1] = global student "s" mark, set to 0 by default
    # questudmark[s,q] = student "s" mark at question "q", set to 0 by default
    # stugood[s] and stubad[s] stand for number of right and wrong ticks of student "s"

    for(q=2;q<=nr_questions+1;q++) {

	if($q=="") {
	    # class_responses[q,r] = nr of answers "r" at question "q" ("r=0" for no answer)
	    class_responses[q-1,0]++;
	    # studresp[s,q,r] = 1 iff student "s" has answered "r" at question "q"
	    studresp[$1,q-1,0]=1;

	} else {
	    # update student ($1) answers table for question q-1
	    split($q,tab,"\\");
	    for(r in tab) {
		gsub("R","",tab[r]);
		class_responses[q-1,tab[r]]++;
		studresp[$1,q-1,tab[r]]=1;
	    }

	    # compute mark
	    for(r=1;r<=nr_answers[q-1];r++) {
		if(corr[q-1,r]==1 && studresp[$1,q-1,r]==1) {
		    # match!
		    questudmark[$1,q-1]+=good[q-1]/nr_correct[q-1];
		    globstudmark[$1]+=coeff[q-1]*good[q-1]/nr_correct[q-1];
		    questugood[$1,q-1]++;
		    stugood[$1]++;
		} else if(corr[q-1,r]==0 && studresp[$1,q-1,r]==1) {
		    # mismatch!
		    questudmark[$1,q-1]+=bad[q-1]/nr_correct[q-1];
		    globstudmark[$1]+=coeff[q-1]*bad[q-1]/nr_correct[q-1];
		    questubad[$1,q-1]++;
		    stubad[$1]++;
		}
	    }
	}
    }

    # OpenOffice output
    if(outputmode=="ooffice") {
	printf "%s%c%s",stutab[$1],OOFS,$1 > ooffile;   # remind that stutab[s] has two fields
	for(q=1;q<=nr_questions;q++) {
	    currentcol=int2letter(colstart+q-1);
	    printf "%c=IF(%s$5=0;(%s$3*%d+%s$4*%d)/%s$6;%s$3)",OOFS,currentcol,currentcol,questugood[$1,q],currentcol,questubad[$1,q],currentcol,currentcol > ooffile;
	}
	printf "%c=IF($%s%d=\"ABS\";\"ABS\";20*SUMPRODUCT($%s$2:$%s$2;$%s%d:$%s%d)/$%s$2)\n",OOFS,colname1,line,colname1,colname2,colname1,line,colname2,line,int2letter(colstart+nr_questions) > ooffile;
	line++;
	###### NEWLINE

    } else {
	printf "%s %-7s  %6.3f \t (correct_ticks: %3d   wrong_ticks: %3d )\n",stutab[$1],$1,globstudmark[$1],stugood[$1],stubad[$1];
    }
}

#-------------------------------------------------------------------------------------------------------------
END {
    # OpenOffice output
    if(outputmode=="ooffice") {

	# output ABSENTS
	for(s in stutab)
	    if(absent[s]==1) {
		printf "%s%c%s",stutab[s],OOFS,s > ooffile;   # stutab[s] has two fields!!
		for(q=1;q<=nr_questions;q++)
		    printf "%c\"ABS\"",OOFS,questudmark[$1,q] > ooffile;
		printf "%c=IF(%s%d=\"ABS\";\"ABS\";20*SUM(%s%d:%s%d)/%s$2)\n",OOFS,colname1,line,int2letter(colstart+nr_questions+nr_void_col+1),line,int2letter(colstart+2*nr_questions+nr_void_col),line,int2letter(colstart+nr_questions) > ooffile;
		line++;
	    }
	last_stuline=line-1;
	###### NEWLINE

	printf "\n" > ooffile;
	line++;
	###### NEWLINE

	# average over class for each question and global marks
	printf "avg" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
 	for(q=1;q<=nr_questions+1;q++) { # +1 for "TOTAL" statistics
	    colname=int2letter(colstart-1+q);
 	    printf "%c=AVERAGE(%s%d:%s%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
	}
	printf "\n" > ooffile;
	line++;
	###### NEWLINE

	# standart deviation over class for each question and global marks
	printf "rms" > ooffile;
	for(q=2;q<=colstart-1;q++)
	    printf "%c",OOFS > ooffile;
 	for(q=1;q<=nr_questions+1;q++) { # +1 for "TOTAL" statistics
	    colname=int2letter(colstart-1+q);
 	    printf "%c=STDEV(%s%d:%s%d)",OOFS,colname,first_stuline,colname,last_stuline > ooffile;
	}
	printf "\n\n" > ooffile;
	line+=2;
	###### NEWLINE - NEWLINE

	# compute nr of present students and repartition of marks
	printf "presents%c=%s%d\n",OOFS,int2letter(2+1000-int(1000-20/binlength)),line+4 > ooffile;
	# 1000-int(1000-x) rounds "x" towards +infty (well... towards +1000)
	line++;
	###### NEWLINE
	
	printf "absents%c=COUNTIF($%s$%d:$%s$%d;\"ABS\")\n\n",OOFS,colname1,first_stuline,colname1,last_stuline > ooffile;
	line+=2;
	###### NEWLINE - NEWLINE

	# repartition...
	printf "marks" > ooffile;
	for(n=binlength;n<20;n+=binlength)
	    printf "%c]%d;%d]",OOFS,n-binlength,n > ooffile;
	printf "%c>%d\n",OOFS,n-binlength > ooffile;
	line++;
	###### NEWLINE

	printf "repartition" > ooffile;
	printf "%c=B%d",OOFS,line+1 > ooffile;
	for(n=binlength;n<20-binlength;n+=binlength)
	    printf "%c=%s%d-%s%d",OOFS,int2letter(2+n/binlength),line+1,int2letter(1+n/binlength),line+1 > ooffile;
	printf "%c=COUNTIF($%s$%d:$%s$%d;\">%d\")",OOFS,int2letter(colstart+nr_questions),first_stuline,int2letter(colstart+nr_questions),last_stuline,n > ooffile;
	printf "%c=SUM(B%d:%s%d)\n",OOFS,line,int2letter(1+1000-int(1000-20/binlength)),line > ooffile;
	# 1000-int(1000-x) rounds "x" towards +infty (well... towards +1000)
	line++;
	###### NEWLINE

	printf "cumulative" > ooffile;
	for(n=binlength;n<20;n+=binlength)
	    printf "%c=COUNTIF($%s$%d:$%s$%d;\"<=%d\")",OOFS,int2letter(colstart+nr_questions),first_stuline,int2letter(colstart+nr_questions),last_stuline,n > ooffile;
	printf "%c=%s%d+%s%d\n",OOFS,int2letter(1000-int(1000-20/binlength)),line,int2letter(1+1000-int(1000-20/binlength)),line-1 > ooffile;
	line++;
	###### NEWLINE

	printf "$A$%d:$%s$%d\n",line-3,int2letter(1+1000-int(1000-20/binlength)),line-2 > "chartcorners.txt"

    } else {
	# output ABSENTS
	for(s in stutab)
	    if(absent[s]==1)
		printf "%s %5d      ABS\n",stutab[s],s;
    }

#   stats
    printf "#Ans:   coeff  VOID     " > statfile;
    for(r=1;r<=max_nr_answers;r++)
	printf "R%-4d  ",r > statfile;
    printf "(sutdents|correction)\n" > statfile;

    for(q=1;q<=nr_questions;q++) {
	printf "#Q%-2d    %5.2f ",q,coeff[q] > statfile;
	if(bonus[q]==1) {
	    for(r=0;r<=nr_answers[q];r++)
		printf "%3d%2s  ",class_responses[q,r],"|X" > statfile;
	    for(r=nr_answers[q]+1;r<=max_nr_answers;r++)
		printf "%5s  ","_" > statfile;
	} else {
	    for(r=0;r<=nr_answers[q];r++)
		printf "%3d|%1d  ",class_responses[q,r],corr[q,r] > statfile;
	    for(r=nr_answers[q]+1;r<=max_nr_answers;r++)
		printf "%5s  ","_" > statfile;
	}
	printf "\n" > statfile;
    }

}
