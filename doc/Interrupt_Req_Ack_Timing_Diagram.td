Header (
	company("EMA Design Automation") 
	product("TimingDesigner") 
	rev("9.2") 
	file("f:\\workspace\\kabeta\\doc\\interrupt_req_ack_timing_diagram.td") 
	date("05/23/2018") time("17:38") 
	format("9.0") 
	baseScale(1000.000000) 
	zoomFactor("0.00165249") 
	zoomBegin(14527) 
	zoomEnd(162292) 
	nameFrameWidth(231) 
	simHDL(Verilog) 
	simDelayMechanism(Transport) 
	nextID(35) 
	TimingAnalysisMethod(51) 
	SDCVersion(0) 
	
	generalPrintParams( "printer,,,portrait,png,Letter,default,9,5,in,color,scaleable,")
	diagramPrintParams( "0,9,0,220000,true,false,1,1,true,false,false,false,all,diagramEnd")
	spreadsheetPrintParams( "0,2147483647,true,false,1,true,all")
	)
tclPreferences (UseAboveSixtyFiveNm UseAlteraFastTimingModel 
	UseActelMaxTimingModel UseTimingPath UseArrivalTime )
HDLHeader( 
	hdlFile("") 
	checkConstraints(true) 
	comment("") 
	checkTimeout(never) 
	
	command( name("intinterface") cmdType(null) ))
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
Clock ( objectID(9) name("CLK_IO") minheight("0") periodScale(1000.000) period(15.000000) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(3) name("EIC_IRQ") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,30000.000,30000.000), 
	(low,90000.000,90000.000), 
	(high,105000.000,105000.000), 
	(low,180000.000,180000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Bus ( objectID(6) name("EIC_IID") minheight("0") edges(
	(invalid,0.000,0.000,L), 
	(valid,15000.000,15000.000), 
	(valid,90000.000,90000.000), 
	(blank,220000.000,220000.000,T)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(15) name("IACK_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,75000.000,75000.000), 
	(low,165000.000,165000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Clock ( objectID(2) name("CLK_CPU") minheight("0") periodScale(1000.000) period(6.000000) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(4) name("IRQ_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,42000.000,42000.000), 
	(low,102000.000,102000.000), 
	(high,114000.000,114000.000), 
	(low,192000.000,192000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(7) name("KIU_IRQ") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,48000.000,48000.000), 
	(low,54000.000,54000.000), 
	(high,120000.000,120000.000), 
	(low,144000.000,144000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Bus ( objectID(28) name("KIU_IID") minheight("0") edges(
	(invalid,0.000,0.000,L), 
	(valid,48000.000,48000.000), 
	(valid,120000.000,120000.000), 
	(blank,220000.000,220000.000,T)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(5) name("PC_IF.S") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,54000.000,54000.000), 
	(low,72000.000,72000.000), 
	(high,90000.000,90000.000), 
	(low,138000.000,138000.000), 
	(high,144000.000,144000.000), 
	(low,200000.000,200000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(8) name("KIU_IACK") minheight("30") edges(
	(low,0.000,0.000,L), 
	(high,54000.000,54000.000), 
	(low,144000.000,144000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Grid ( "CLK_CPU" topWave("CLK_CPU") bottomWave("KIU_IACK") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )
Grid ( "CLK_IO" topWave("CLK_IO") bottomWave("IACK_SYNC") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )

CauseAndEffect(objectID(10) source("EIC_IRQ",1) target("IRQ_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(11) source("IRQ_SYNC",1) target("KIU_IRQ",1) label(showDefault,"") fromLatestEnd toEarliestBegin slot(1) color(14) width("0")  )

CauseAndEffect(objectID(12) source("KIU_IRQ",1) target("KIU_IRQ",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(17) source("KIU_IACK",1) target("IACK_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(18) source("IACK_SYNC",1) target("EIC_IRQ",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(19) source("EIC_IRQ",2) target("IRQ_SYNC",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(20) source("EIC_IRQ",3) target("IRQ_SYNC",3) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )

CauseAndEffect(objectID(21) source("IRQ_SYNC",3) target("KIU_IRQ",3) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(24) source("IACK_SYNC",2) target("EIC_IRQ",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(25) source("KIU_IACK",2) target("IACK_SYNC",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )

CauseAndEffect(objectID(26) source("EIC_IRQ",4) target("IRQ_SYNC",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )

CauseAndEffect(objectID(29) source("IRQ_SYNC",1) target("KIU_IID",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(30) source("KIU_IRQ",1) target("KIU_IACK",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(32) source("PC_IF.S",4) target("KIU_IRQ",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(33) source("PC_IF.S",4) target("KIU_IACK",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(34) source("IRQ_SYNC",3) target("KIU_IID",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )
EndCycleEvent ( objectID(1) name("end") time(220.000000) showVert hideOnPrinter label(showDefault,"") fromLatestEnd toEarliestBegin  )
