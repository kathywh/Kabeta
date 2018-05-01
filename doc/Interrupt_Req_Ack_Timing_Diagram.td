Header (
	company("EMA Design Automation") 
	product("TimingDesigner") 
	rev("9.2") 
	file("f:/workspace/kabeta/doc/intinterface.td") 
	date("04/25/2018") time("16:20") 
	format("9.0") 
	baseScale(1000.000000) 
	zoomFactor("0.00328035") 
	zoomBegin(0) 
	zoomEnd(74943.8) 
	nameFrameWidth(200) 
	simHDL(Verilog) 
	simDelayMechanism(Transport) 
	nextID(27) 
	TimingAnalysisMethod(51) 
	SDCVersion(0) 
	
	generalPrintParams( "printer,,,portrait,png,Letter,default,12,8,in,color,scaleable,")
	diagramPrintParams( "0,8,0,220000,true,false,1,1,true,false,false,false,all,diagramEnd")
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
Clock ( objectID(9) name("CLK_INTC") minheight("0") periodScale(1000.000) period(15.000000) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(3) name("IRQ") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,7500.000,7500.000), 
	(low,90000.000,90000.000), 
	(high,105000.000,105000.000), 
	(low,195000.000,195000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Bus ( objectID(6) name("IID") minheight("0") edges(
	(valid,0.000,0.000,L), 
	(valid,7500.000,7500.000), 
	(valid,105000.000,105000.000), 
	(blank,220000.000,220000.000,T)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(15) name("IACK_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,75000.000,75000.000), 
	(low,180000.000,180000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Clock ( objectID(2) name("CLK_CPU") minheight("0") periodScale(1000.000) period(10.000000) dutyCycle(50.000000) 
	hdl( direction(internal) ) square label(showDefault,"","H") )
Waveform ( objectID(4) name("IRQ_SYNC") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,20000.000,20000.000), 
	(low,110000.000,110000.000), 
	(high,120000.000,120000.000), 
	(low,210000.000,210000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(7) name("IRQ_I") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,30000.000,30000.000), 
	(low,40000.000,40000.000), 
	(high,130000.000,130000.000), 
	(low,150000.000,150000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(5) name("PC_IF.S") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,40000.000,40000.000), 
	(low,70000.000,70000.000), 
	(high,100000.000,100000.000), 
	(low,140000.000,140000.000), 
	(high,150000.000,150000.000), 
	(low,200000.000,200000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Waveform ( objectID(8) name("IACK") minheight("0") edges(
	(low,0.000,0.000,L), 
	(high,50000.000,50000.000), 
	(low,160000.000,160000.000), 
	(blank,220000.000,220000.000)) 
	hdl( direction(internal) ) label(showDefault,"","H") )
Grid ( "CLK_CPU" topWave("CLK_CPU") bottomWave("IACK") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )
Grid ( "CLK_INTC" topWave("CLK_INTC") bottomWave("IACK_SYNC") 
	 color(6) 1stWidth(0) 2ndWidth(0) 1stStyle(1) 2ndStyle(0) 
  show1st )

CauseAndEffect(objectID(10) source("IRQ",1) target("IRQ_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(11) source("IRQ_SYNC",1) target("IRQ_I",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(12) source("IRQ_I",1) target("IRQ_I",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(13) source("IRQ_I",2) target("IACK",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(17) source("IACK",1) target("IACK_SYNC",1) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(18) source("IACK_SYNC",1) target("IRQ",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(14) width("0")  )

CauseAndEffect(objectID(19) source("IRQ",2) target("IRQ_SYNC",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(10) width("0")  )

CauseAndEffect(objectID(20) source("IRQ",3) target("IRQ_SYNC",3) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )

CauseAndEffect(objectID(21) source("IRQ_SYNC",3) target("IRQ_I",3) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(22) source("PC_IF.S",4) target("IRQ_I",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(23) source("IRQ_I",4) target("IACK",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(24) source("IACK_SYNC",2) target("IRQ",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(8) width("0")  )

CauseAndEffect(objectID(25) source("IACK",2) target("IACK_SYNC",2) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )

CauseAndEffect(objectID(26) source("IRQ",4) target("IRQ_SYNC",4) label(showDefault,"") fromLatestEnd toEarliestBegin color(7) width("0")  )
EndCycleEvent ( objectID(1) name("end") time(220.000000) showVert hideOnPrinter label(showDefault,"") fromLatestEnd toEarliestBegin  )
