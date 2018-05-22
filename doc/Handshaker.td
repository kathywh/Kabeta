Header (
	company("EMA Design Automation") 
	product("TimingDesigner") 
	rev("9.2") 
	file("f:\\workspace\\kabeta\\doc\\handshaker.td") 
	date("05/22/2018") time("18:51") 
	format("9.0") 
	baseScale(1000.000000) 
	zoomFactor("0.000976191") 
	zoomBegin(0) 
	zoomEnd(254316) 
	nameFrameWidth(200) 
	simHDL(Verilog) 
	simDelayMechanism(Transport) 
	nextID(22) 
	TimingAnalysisMethod(51) 
	SDCVersion(0) 
	
	generalPrintParams( "printer,,,portrait,png,Letter,default,9,5,in,color,scaleable,")
	diagramPrintParams( "0,8,0,245000,true,false,1,1,true,false,false,false,all,diagramEnd")
	spreadsheetPrintParams( "0,2147483647,true,false,1,true,all")
	)
tclPreferences (UseAboveSixtyFiveNm UseAlteraFastTimingModel 
	UseActelMaxTimingModel UseTimingPath UseArrivalTime )
HDLHeader( 
	hdlFile("") 
	checkConstraints(true) 
	comment("") 
	checkTimeout(never) 
	
	command( name("handshaker") cmdType(null) ))
DefaultLabel(
	delay(showNameString,"") 
	constraint(showNameString,"") 
	guarantee(showNameString,"") 
	measure(showMeasure,"") 
	store(showNameString,"") 
	wait(showNameString,"") 
	end(showNameString,"") 
	boundary(showIncrement,"") 
	loop(showNameString,"") 
	waveform(showSkip,"","") 
	specifiedclock(showSkip,"","") 
	derivedclock(showSkip,"","") 
	simwaveform(showSkip,"","") 
	bus(showValue,"","H") 
	)
DiagramStyle (
	waveformFont(winFont("Arial",90) qtFont("Arial",9) ) 
	rulerFont(winFont("Arial",90) qtFont("Arial",9) ) 
	relationshipFont(winFont("Arial",90) qtFont("Arial",9) ) 
	labelFont(winFont("Arial",90) qtFont("Arial",9) ) 
	annotationFont(winFont("Arial",80) qtFont("Arial",8) ) 
	slotHeight("11") 
	edgeHeight("11") 
	edgeGrade("1.96261") 
	inputPenStyle(0) 
	outputPenStyle(0) 
	inoutPenStyle(0) 
	internalPenStyle(0) 
	vRelationshipPenStyle(0) 
	hRelationshipPenStyle(0) 
	inputPenColor(3) 
	outputPenColor(3) 
	inoutPenColor(3) 
	internalPenColor(3) 
	wavePenWidth("0") 
	relationshipPenWidth("0") 
	wavesOnTop 
	relationshipsOnTop 
	annotationsOnTop 
	showSlopedEdges 
	edgeDisplayType(Uncertainty) 
	)
Clock ( objectID(2) name("CLK_SEND") minheight("48") periodScale(1000.000) period(33.333333) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(4) name("REQ") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,66670.000,66670.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(7) name("ACK_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,200000.000,200000.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Bus ( objectID(8) name("DATA") minheight("0") edges(
	(invalid,0.000,0.000,L), 
	(valid,33330.000,33330.000), 
	(valid,233330.000,233330.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Clock ( objectID(3) name("CLK_RECV") minheight("0") periodScale(1000.000) period(20.000000) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(5) name("REQ_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,100000.000,100000.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(19) name("READY") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,100000.000,100000.000), 
	(low,120000.000,120000.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(9) name("FINISH") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,120000.000,120000.000), 
	(low,140000.000,140000.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(6) name("ACK") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,140000.000,140000.000), 
	(blank,245000.000,245000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Grid ( "CLK_SEND" topWave("CLK_SEND") bottomWave("DATA") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )
Grid ( "CLK_RECV" topWave("CLK_RECV") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )

CauseAndEffect(objectID(10) source("DATA",1) target("REQ",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(11) source("REQ",1) target("REQ_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(13) source("FINISH",1) target("ACK",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(14) source("ACK",1) target("ACK_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(18) source("ACK_SYNC",1) target("DATA",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(20) source("REQ_SYNC",1) target("READY",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(21) source("READY",1) target("FINISH",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )
EndCycleEvent ( objectID(1) name("end") time(245.000000) showVert hideOnPrinter label(showDefault,"") fromLatestEnd toEarliestBegin  )
Measure ( name("T1") value("[66.67,,66.67]") 
	instance(objectID(15) source("DATA",1) target("REQ_SYNC",1) MeasureValue("[66.67,,66.67]") label(showNameString,"") fromLatestEnd toEarliestBegin bottom  ))
Measure ( name("T2") value("[113.33,,113.33]") 
	instance(objectID(16) source("FINISH",1) target("DATA",2) MeasureValue("[113.33,,113.33]") label(showNameString,"") fromLatestEnd toEarliestBegin bottom  ))
