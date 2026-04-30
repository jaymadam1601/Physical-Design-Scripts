BEGIN {startpoint="something";endpoint="something";flag=0;count=0;print "Startpoint(1) Endpoint(2) Startpoint_Clock(3) Endpoint_Clock(4) Status(5) PathGroup(6) CheckType(7) AnalysisView(7) Period(8) Captuer_Latency(9) Setup/Hold/Recovery/Removal(10) Uncertainty(11) Required_Time(12) Arrival_Time(13) LogicDepth(14) Slack(15)"}
/^Path [0-9]+:/ {
	startpoint="NA"; endpoint="NA"; startpoint_clock="NA";endpoint_clock="NA"
	stat="NA"; pathgroup="NA"; checktype="NA"; analsview="NA"
	capturelatency="NA"; setuporhold="NA"; period="NA"; uncertainty="NA"; reqtime="NA"; arrtime="NA"; slacktime="NA"
	stat=$3;checktype=$4
}
/^Beginpoint:/ {startpoint=$2; gsub("[']","",$NF); startpoint_clock=$NF}
/^Endpoint:/ {endpoint=$2; gsub("[']","",$NF); endpoint_clock=$NF}
/^Path Groups:/ {gsub("[{}]","",$3); pathgroup=$3}
/^Analysis View:/ {analsview=$3}
/^Other End Arrival Time/ {capturelatency=$5}
/^..Setup/ || /^..Hold/ || /^..Recovery/ || /^..Removal/ {setuporhold=$3}
/^..Phase Shift/ {period=$4}
/^..Uncertainty/ {uncertainty=$3}
/^..Required Time/ {reqtime=$4}
/^..Arrival Time/ {for (i = 1; i< NF; i++) {if ($i == "Time") {arrtime=$(i+1)} }}
/^..Slack Time/ {for (i = 1; i< NF; i++) {if ($i == "Time") {slacktime=$(i+1)} }}

$1==startpoint {
    flag=1 
    count=0
    next
}
flag && $1!=endpoint {
	if ($2 ~ /\(net\)/) {
		count=count
	}
	else {
		count++
	}
}
$1==endpoint {
	count=count/2
	print startpoint,endpoint,startpoint_clock,endpoint_clock,stat,pathgroup,checktype,analsview,period,capturelatency,setuporhold,uncertainty,reqtime,arrtime,count,slacktime
	flag=0
}
