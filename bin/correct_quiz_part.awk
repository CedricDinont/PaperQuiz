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
# awk -f ../correcteur.awk -v bad=-0.5 brut.txt
    FS=";";
    if(students=="")
	students="../students.txt";
    if(corrige=="")
	corrige="corrige.txt";
    if(good=="")
	good=+1;
    if(bad=="")
	bad=0;  # Warning - bad should be negative
    if(outputmode==openoffice)
	outputmode=ooffice
    if(ooffile=="")
	ooffile="results.csv"
    if(statfile=="")
	statfile="/dev/stdout";

#   import student names
    while(getline<students>0) {
	split($0,a," ");
	absent[a[3]]=1; # a priori absent...
	if(outputmode=="ooffice")
	    stutab[a[3]]=sprintf("%s;%s",a[1],a[2]);
	else
	    stutab[a[3]]=sprintf("%-20s %-20s",a[1],a[2]);
    }
    close(students);

#   import correction
    nr_questions=0;
    nr_fields_corr=5;
    inputline=0;
#   format is:
#   question_nr;nb_possible_responses;correct_answers(eg.R1\R5);coef;bonus
    while(getline<corrige>0) {
	inputline++;
	if($1!~"#" && NF==nr_fields_corr) {

	    if($1 in nr_responses) {
		printf "Warning - in \"%s\" line %d:\n\tquestion %d already defined --> use bonus!!\n",corrige,inputline,$1 > "/dev/stderr";
		bonus[$1]=1;
		corr[$1,0]=1;
	    } else {
		nr_responses[$1]=$2; # number of possible responses for question $1
		if($2>max_nr_responses)
		    max_nr_responses=$2;
		
		nr_correct[$1]=split($3,a,"\\");
		if(nr_correct[$1]==0) {
		    printf "Warning - in \"%s\" line %d question %d:\n\t no correct response!!\n",corrige,inputline,$1 > "/dev/stderr";
		    nr_correct[$1]=1; # prevent division by 0
		} else {
		    for(r in a) {
			gsub("R","",a[r]);
			corr[$1,a[r]]=1;
			if(a[r]>nr_responses[$1]) {
			    printf "Warning - in \"%s\" line %d question %d:\n\t response R%-2d out of range --> use bonus!!\n",corrige,inputline,$1,a[r] > "/dev/stderr";
			    bonus[$1]=1;
			}
		    }
		}
		coeff[$1]=$4;
		if(bonus[$1]==0)
		    bonus[$1]=$5;
		if($1>nr_questions)
		    nr_questions=$1;
		
		minmark+=bad/nr_correct[$1]*(nr_responses[$1]-nr_correct[$1]);
	    }
	} else if($1!~"#" && NF!=nr_fields_corr && NF>0)
	    printf "Warning - in \"%s\" line %d:\n\tWrong number of fields (found %d instead of %d) --> question ignored!!\n",corrige,inputline,NF,nr_fields_corr > "/dev/stderr";
    }
    close(corrige);
    maxmark=nr_questions;
#   printf "%d questions\n",nr_questions > "/dev/stderr";
#   printf "Mark between %6.2f and %6.2f\n",minmark,maxmark > "/dev/stderr";

#   check corrige consistency
    for(q=1;q<=nr_questions;q++) {
	if( ! (q in nr_responses) ) {
	    printf "Warning - in \"%s\":\n\tquestion %d undefined --> use bonus!!\n",corrige,q > "/dev/stderr";
	    nr_responses[q]=0;
	    coeff[q]=1;
	    bonus[q]=1;
	    corr[q,0]=1;
	}
    }

    if(outputmode=="ooffice") {
#	at this point, we suppose everything above correct
	printf "student_name;student_first_name;student_id" > ooffile;
	colstart=4;
	for(q=1;q<=nr_questions;q++)
	    printf "; Q%3d",q > ooffile;
	printf "; TOTAL\ncoefficients" > ooffile;

	for(q=2;q<=colstart-1;q++)
	    printf ";" > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "; %f",coeff[q] > ooffile;
	printf ";=SUM(%s2:%s2)\nbonus",int2letter(colstart),int2letter(nr_questions+colstart-1) > ooffile;

	for(q=2;q<=colstart-1;q++)
	    printf ";" > ooffile;
	for(q=1;q<=nr_questions;q++)
	    printf "; %4d",bonus[q] > ooffile;
	printf "\n" > ooffile;
	line=4; # first student line !
    } else {
	printf "%-20s %-20s 0000    %6.2f  (min_mark=%6.2f)\n","#------","CORRIGE",maxmark,minmark;
    }

}

$1!~"Code" {
    mark[$1]=0;
    absent[$1]=0;

#   response[q,r] = nr responses "r" at question "q"
#   "r=0" for no response
#   printf "%5d %s\n",$1,stutab[$1];
    for(q=2;q<=nr_questions+1;q++) {

	if($q=="") {
	    responses[q-1,0]++;
	    studresp[$1,q-1,0]=1;

	} else {
#	    update student ($1) tab of responses for question q-1
	    split($q,a,"\\");
	    for(r in a) {
		gsub("R","",a[r]);
		responses[q-1,a[r]]++;
		studresp[$1,q-1,a[r]]=1;
	    }

#           compute mark
#	    printf "\t-->S%-5d Q%-2d ",$1,q-1;
	    for(r=1;r<=nr_responses[q-1];r++) {
		if(corr[q-1,r]==1 && studresp[$1,q-1,r]==1) {
#		    match!
		    studmark[$1,q-1]+=good;
		    stugood[$1]++;
		} else if(corr[q-1,r]==0 && studresp[$1,q-1,r]==1) {
#		    mismatch!
		    studmark[$1]+=bad;
		    stubad[$1]++;
#		    printf "Student:%4d Q%-2d mismatched at R%-2d\n",$1,q-1,r;
		}
#		printf "%5d ",studresp[$1,q-1,r];
	    }
#	    printf "\n";
	}
    }

#   output
    if(outputmode=="ooffice") {
	printf "%s;%d",stutab[$1],$1 > ooffile;   # stutab[$1] has two fields!!
	for(q=1;q<=nr_questions;q++)
	    printf ";%.2f",studmark[$1,q] > ooffile;
	printf ";=SUM(%s%d:%s%d)\n",int2letter(colstart),line,int2letter(nr_questions+colstart-1),line > ooffile;
	line++;
    } else {
	printf "%s %5d     %5.2f \t (= %5.2f  %-5.2f)\n",stutab[$1],$1,mark[$1],stugood[$1]*good,stubad[$1]*bad;
    }
}

END {
#   output ABS
    if(outputmode=="ooffice") {
	for(s in stutab)
	    if(absent[s]==1) {
		printf "%s;%d",stutab[s],s > ooffile;   # stutab[s] has two fields!!
		for(q=1;q<=nr_questions;q++)
		    printf ";ABS",studmark[$1,q] > ooffile;
		printf "\n" > ooffile;
	    }
    } else {
	for(s in stutab)
	    if(absent[s]==1)
		printf "%s %5d      ABS\n",stutab[s],s;
    }

#   stats
    printf "#Response:VOID    " > statfile;
    for(r=1;r<=max_nr_responses;r++)
	printf "R%-4d  ",r > statfile;
    printf "\n" > statfile;

    for(q=1;q<=nr_questions;q++) {
	printf "#Q%-2d    ",q > statfile;
	if(bonus[q]==1)
	    for(r=0;r<=max_nr_responses;r++)
		printf "%5s  ","X.X" > statfile;
	else {
	    for(r=0;r<=nr_responses[q];r++)
		printf "%5.1f  ",responses[q,r]+corr[q,r]/10 > statfile;
	    for(r=nr_responses[q]+1;r<=max_nr_responses;r++)
		printf "%5s  ","_" > statfile;
	}
	printf "\n" > statfile;
    }

}
