BeginPackage["plottingFunctions`"]

(* *************************************************************** *)
(* PLOTTING PARAMETERS AND LABELS *)

(* Very specific plotting parameters *)
numSamples2PlotIfIndivPlot = 100;

(* Font sizes *)
sizeFontBigger = 21;
sizeFontBig = 17;
sizeFontSmall = 14;
sizeFontSmaller = 12;
sizeFontSmallest = 10;

(* Colors *)
colorRainbow = 
   Table[
      ColorData["Rainbow"][x], 
      {x, 0, 1, 0.075}
   ];
colorViolet = colorRainbow[[1]];
colorBlueViolet = colorRainbow[[2]];
colorNavyBlue = colorRainbow[[3]];
colorBlue = colorRainbow[[4]];
colorLightBlue = colorRainbow[[5]];
colorBlueGreen = colorRainbow[[6]];
colorGreen = colorRainbow[[7]];
colorOliveGreen = colorRainbow[[8]];
colorYellowGreen = colorRainbow[[9]];
colorYellow = colorRainbow[[10]];
colorYellowBright = RGBColor[0.9,0.75,0];
colorYellowOrange = colorRainbow[[11]];
colorOrange = colorRainbow[[12]];
colorRedOrange = colorRainbow[[13]];
colorRed = colorRainbow[[14]];
(* Colors for age groups are manually selected to separate the greens from the yellow-red *)
colorRainbow4AgeGroups = 
   Table[
      ColorData["Rainbow"][x], 
      {x, {0.5, 0.55, 0.6, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1}}
   ]

(* Transition dates labels *)
transitionDatesLabelsShort = {"LD 1", "Relax 1", "Relax 2", "LD 2", 
   "Relax 3"};
transitionDatesLabels = {"First lockdown,\nLD 1",
"Relaxation after first lockdown,\nRelax 1",
"Further relaxation,\nRelax 2",
"Second lockdown,\nLD 2",
"Relaxation due\nto winter\nholidays,\nRelax 3"};

(* X-ticks *)
tickValues = 
   DateRange[
      {2020, 3, 1}, 
      {2021, 1, 1}, 
      {1, "Month"}
   ][[All, {1, 2}]];
ticksVisible = 
   {#, Rotate[
         DateString[
            DateObject[#], 
            {"MonthNameShort", " ", "Year"}], 
            \[Pi]/2]
   } & /@ tickValues;
ticksInvisible =
   {#, Rotate[
         DateString[
            DateObject[#], 
            {"", " ", ""}], 
            \[Pi]/2]
   }& /@ tickValues;

(* Age labels *)
ageLabel = 
   {"[0,5) y.o.", "[5,10) y.o.", "[10,20) y.o.", 
   "[20,30) y.o.", "[30,40) y.o.", "[40,50) y.o.", 
   "[50,60) y.o.", "[60,70) y.o.", "[70,80) y.o.", "80+ y.o."};
ageLabelShort = 
   {"[0,5)", "[5,10)", "[10,20)", "[20,30)", 
   "[30,40)", "[40,50)", "[50,60)", 
   "[60,70)", "[70,80)", "80+"};

(* Parameter histogram labels *)
parameterConstXLabelShort =
   {"\[Epsilon]", "\[Zeta]",
   "\[Theta] \!\(\*SubsuperscriptBox[\(\[Sum]\), \(k = 1\), \ \(n\)]\)\!\(\*SubscriptBox[\(N\), \(k\)]\)",
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([0, 20\)\()\)\)]\)",
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([20, 60\)\()\)\)]\)", 
   "\[Phi]", "1/\[Alpha]", "1/\[Gamma]"};
parameterConstXLabel =
   {"Probability of transmission\nper contact",
   "Reduction in probability of\ntransmission per contact", "Initial number\nof infected persons", 
   "Susceptibility of [0,20) y.o.\nrelative to 60+ y.o.",
   "Susceptibility of [20,60) y.o.\nrelative to 60+ y.o.", 
   "Overdispersion parameter", "Latent period (days)", 
   "Infectious period (days)"};
parameterTXLabelShort =
   {"\!\(\*SubscriptBox[\(t\), \(0\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\) (days)"};
parameterTXLabel =
   {"\!\(\*SubscriptBox[\(t\), \(0\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\)"};
parameterKXLabel =
   {"\!\(\*SubscriptBox[\(K\), \(0\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(4\)]\)"};
parameterUXLabel =
   {"\!\(\*SubscriptBox[\(u\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(4\)]\)"};


(* Y-labels for sensitivity scenarios *)
yLabel4Sens =
   {"Total hospitalizations (1/day)", 
   "Youth hospitalizations (1/day)",
   "Total seroprevalence (%)", 
   "Youth seroprevalence (%)",
   "Reproduction number", 
   "Cumulative youth elasticities",
   "Total contacts (1/day)", 
   "Youth contacts (1/day)"};

(* Alphabet LETTERLABELS, just because *)
alphabetLetters = CharacterRange["A", "Z"];



(* *************************************************************** *)
(* PLOTTING FUNCTIONS *)
(* LISTLINEPLOT::usage = "LISTLINEPLOT[TRAJECTORIES, options] plots the given TRAJECTORIES."; *)

plotWithLetter[
   PLOT_,
   LABEL_String:"", SIDE_:"left", FONTSIZE_:sizeFontBigger,
   TEXTCOLOR_:Black, MANUALLEGEND_:{}] :=
   Show[
      PLOT,
      Epilog ->
         {Join[
            {Inset[
               Graphics[Text[StyleForm[LABEL,
                                       FontSize -> FONTSIZE,
                                       FontColor-> TEXTCOLOR]]],
               Which[SIDE === "right", Scaled[{0.9, 0.9}],
                  SIDE === "left", Scaled[{0.1, 0.9}],
                  SIDE === "lefter", Scaled[{0.05, 0.9}],
                  SIDE === "righter", Scaled[{0.95, 0.9}],
                  True, SIDE]
               ]},
            If[Length[Cases[PLOT, OptionsPattern[Epilog]]] > 0,
               Epilog /. Options[PLOT, Epilog],
               {}]],
         MANUALLEGEND}];


plotScenarioTrajectories[
   TRAJECTORIES_,
   YLABEL_:"",
   TITLE_:{"Scenario 1\nSchools remained open",
            "Scenario 2\nSchools remained closed"},
   XTICKS_:{ticksVisible, ticksVisible},
   XYLIMITS_:{{Automatic, Full}, {Automatic, Full}},
   LETTERLABELS_:{"A", "B"},
   LETTERLOC_:"lefter",
   PLOTADDEND_:Graphics[],
   MEDIANTRAJ_:{{},{},{}},
   INDIVTRAJ_:False] :=
   Module[{FIG1, FIG2, XLABEL},
      XLABEL = "";
      FIG1 =
         plotWithLetter[
            {plotLineWithCrI[
               TRAJECTORIES[[1]],
               colorBlue, TITLE[[1]], XLABEL, YLABEL, 1,
               XTICKS[[1]], XYLIMITS[[1]], 0.5, 500, Solid,
               MEDIANTRAJ[[1]], INDIVTRAJ],
            plotLineWithCrI[
               TRAJECTORIES[[2]], 
               colorOrange, "", "", "", 1,
               XTICKS[[1]], XYLIMITS[[1]], 0.5, 500, Solid,
               MEDIANTRAJ[[2]], INDIVTRAJ],
            PLOTADDEND},
            LETTERLABELS[[1]],
            LETTERLOC];
      FIG2 =
         plotWithLetter[{
            plotLineWithCrI[
               TRAJECTORIES[[1]], 
               colorBlue, TITLE[[2]], XLABEL, "", 2, 
               XTICKS[[2]], XYLIMITS[[2]], 0.5, 500, Solid,
               MEDIANTRAJ[[1]], INDIVTRAJ],
            plotLineWithCrI[
               TRAJECTORIES[[3]], 
               colorOrange, "", "", "", 2,
               XTICKS[[1]], XYLIMITS[[1]], 0.5, 500, Solid,
               MEDIANTRAJ[[3]], INDIVTRAJ],
            PLOTADDEND},
            LETTERLABELS[[2]],
            LETTERLOC];

      Grid[{{FIG1, FIG2}}]];


plotLineWithCrI[
   TRAJECTORIES_, 
   COLOR_:colorBlue, TITLE_:"", XLABEL_:"", YLABEL_:"", SCENARIOPERIOD_:1,
   XTICKS_:ticksVisible, XYLIMITS_:{0, 1000}, ASPECTRATIO_:0.5,
   IMAGESIZE_:500, LINESTYLE_:Solid, MEDIANTRAJ_:{}, 
   INDIVTRAJ_:False, SCENTOSHOW_:"default"] := 
   Module[{MEDIAN2PLOT, TRAJ2PLOT, MAINPLOT, INDIVTRAJPLOT},
      MEDIAN2PLOT = 
         If[Length[MEDIANTRAJ] == 0,
            Median[Re[TRAJECTORIES]],
            Median[Re[MEDIANTRAJ]]];
      TRAJ2PLOT =
         If[INDIVTRAJ,
            MEDIAN2PLOT,
            {MEDIAN2PLOT,
               Quantile[Re[TRAJECTORIES], 0.025],
               Quantile[Re[TRAJECTORIES], 0.975]}];
               
      MAINPLOT = DateListPlot[
         TRAJ2PLOT,
         {"February 25, 2020", Automatic, {0, 0, 1}},
         PlotRange ->
            {Which[SCENARIOPERIOD==1,
               {Global`tStart1, Global`tEnd1},
               SCENARIOPERIOD==2,
               {Global`tStart2, Global`tEnd2},
               SCENARIOPERIOD==3,
               {Global`tStart1, Global`tEnd2},
               True,
               Automatic],
            XYLIMITS},
         PlotRangePadding -> None,
         Ticks -> {tickmarks, Automatic},
         AspectRatio -> ASPECTRATIO,
         ImageSize -> IMAGESIZE,
         Frame -> {{True, False}, {True, False}},
         PlotTheme -> "Web",
         FrameStyle -> Directive[Black, sizeFontBig],
         AxesOrigin -> {"February 25, 2020", 0},
         FrameLabel ->
            {Style[XLABEL, FontSize -> sizeFontBig],
            Style[YLABEL, FontSize -> sizeFontBig]},
         FrameTicks ->
            {{Automatic, None},
            {XTICKS, None}},
         GridLines -> {Automatic, None},
         GridLinesStyle ->
            {{GrayLevel[0.95]},
            {None}},
         PlotLabel -> Style[Row[{TITLE}], colorOrange, sizeFontBig],
         Filling -> {3 -> {2}},
         PlotStyle ->
            {{LINESTYLE, COLOR,
               If[SCENARIOPERIOD==3,
                  Thickness[0.004],
                  Thickness[0.006]]},
            {Lighter[COLOR], Thin},
            {Lighter[COLOR], Thin}},
         FrameTicksStyle ->
            {{{Black, 14, Opacity[1]}, None},
            {{Black, 14, Opacity[1]}, None}},
         ImagePadding ->
            {{If[YLABEL === "", 35, 50], 5},
            {If[XTICKS === ticksVisible, 70, 10],
            If[TITLE === "", 1, Automatic]}}, 
         Prolog ->
            yellowLinesAndRegion[XYLIMITS, SCENTOSHOW]
         ];

      INDIVTRAJPLOT = 
         If[INDIVTRAJ,
            DateListPlot[
               TRAJECTORIES[[1;;numSamples2PlotIfIndivPlot, All]],
               {"February 25, 2020", Automatic, {0, 0, 1}},
               PlotStyle ->
                  {{LINESTYLE, Lighter[COLOR], Thickness[0.0005]}},
               PlotRange ->
                  {If[SCENARIOPERIOD == 1,
                     {Global`tStart1, Global`tEnd1},
                     {Global`tStart2, Global`tEnd2}],
                  XYLIMITS}],
            Graphics[]];
      
      If[INDIVTRAJ,
         Show[MAINPLOT, INDIVTRAJPLOT],
         MAINPLOT]
   ];

plotDiagram[
   HOSPDATA_,
   XTICKS_, ASPECTRATIO_:0.5, IMAGESIZE_:500] :=
   DateListPlot[
      Total[Transpose[HOSPDATA]],
      "February 26, 2020",
      PlotMarkers ->
         {Graphics[{Black, Style[Circle[], Thickness[0.25]]}], 5}, 
      PlotTheme -> "Web",
      Joined -> False,
      GridLines -> {Automatic, None},
      GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
      DateTicksFormat -> {"MonthShort", "/", "YearShort"}, 
      FrameTicks ->
         {{Automatic, None},
         {XTICKS, None}},
      AspectRatio -> ASPECTRATIO 0.5,
      ImageSize -> 1.625 IMAGESIZE,
      PlotRangeClipping -> False,
      PlotRange ->
         {{"February 25, 2020", "January 16, 2021"},
         {0, 550}},
      Frame -> {{True, False}, {True, False}},
      FrameStyle -> Directive[Black, sizeFontBig],
      FrameLabel ->
         {{"Hospitalizations (1/day)", None},
         {None, None}}, 
      FrameTicksStyle ->
         {{{Black, 14, Opacity[1]}, None},
         {{Black, 14, Opacity[1]}, None}},
      ImagePadding -> {{All, All}, {All, 50}},
      Prolog ->
         {
         {Thick, Black,
            Line[{{"July 15, 2020", 0}, {"July 15, 2020", 550}}]},
         {colorYellowBright,
            Table[
               Line[{{Global`transitionDates[[tIdx]], 0},
                  {Global`transitionDates[[tIdx]], 550}}],
               {tIdx, 1, Length[Global`transitionDates]}]},
         {Dashed, colorYellowBright,
            Table[
               Line[{{Global`transitionDatesQuantiles025[[tIdx]], 0},
               {Global`transitionDatesQuantiles025[[tIdx]], 550}}],
               {tIdx, 1, Length[Global`transitionDatesQuantiles025]}]},
         {Dashed, colorYellowBright,
            Table[
               Line[{{Global`transitionDatesQuantiles975[[tIdx]], 0},
               {Global`transitionDatesQuantiles975[[tIdx]], 480}}], 
               {tIdx, 1, Length[Global`transitionDatesQuantiles975]}]},
         {Dotted, colorYellowBright,
            Line[{{"June 10, 2020", 0},
            {"June 10, 2020", 550}}]},
         {Directive[colorYellowBright, Opacity[0.075]],
            Rectangle[
               {AbsoluteTime["March 24, 2020"], 0},
               {AbsoluteTime["June 10, 2020"], 550}]},
         {Directive[colorYellowBright, Opacity[0.075]],
            Rectangle[
               {AbsoluteTime["August 22, 2020"], 0},
               {AbsoluteTime["January 15, 2021"], 550}]},
         {Table[
            Text[transitionDatesLabels[[tIdx]],
               {Global`transitionDates[[tIdx]], 550},
               {-1.075, 1},
                  TextAlignment-> Left,
                  TextStyle ->
                     {FontSize -> sizeFontSmallest,
                     colorYellowBright}],
            {tIdx, 1, Length[Global`transitionDates]}]},
         {Text["School\nholidays",
            {AbsoluteTime["June 10, 2020"], 450},
            {-1.075, 1},
               TextAlignment-> Left,
               TextStyle ->
                  {FontSize -> sizeFontSmallest,
                  colorYellowBright}]}
         },
      Epilog ->
         {
         annotatedArrow[
            {"February 26, 2020", 560},
            {"July 15, 2020", 560},
            "Scenario 1\nSchools remained open"],
         annotatedArrow[
            {"July 15, 2020", 560},
            {"January 15, 2021", 560},
            "Scenario 2\nSchools remained closed"]
         }
  ];

plotThickLine[
   TRAJECTORIES_,
   COLORS_, TITLE_, XLABEL_, YLABEL_, LEGLABEL_, TYPE_,
   MEANVALS_:{}, RANGEVALS_:Automatic, OPTIONS___] :=
   ListLinePlot[
      TRAJECTORIES,
      PlotStyle -> COLORS,
      FrameLabel ->
         {{YLABEL, None},
         {XLABEL, None}},
      PlotRange -> RANGEVALS,
      PlotLabel -> Style[TITLE, Black, sizeFontBig],
      AspectRatio -> 0.75,
      ImageSize -> 300,
      Frame -> {{True, False}, {True, False}},
      FrameStyle -> Directive[Black, sizeFontBig],
      PlotTheme -> "Web",
      PlotRangePadding -> None,
      FrameTicksStyle ->
         {{{Black, sizeFontSmall, Opacity[1]}, None},
         {{Black, sizeFontSmall, Opacity[1]}, None}},
      FrameTicks ->
         If[TYPE == "contacts",
            {{{1, Rotate["[0,5)", Pi/2]},
               {2, Rotate["[5,10)", Pi/2]},
               {3, Rotate["[10,20)", Pi/2]},
               {4, Rotate["[20,30)", Pi/2]},
               {5, Rotate["[30,40)", Pi/2]},
               {6, Rotate["[40,50)", Pi/2]},
               {7, Rotate["[50,60)", Pi/2]},
               {8, Rotate["[60,70)", Pi/2]},
               {9, Rotate["[70,80)", Pi/2]},
               {10, Rotate["80+", Pi/2]}},
               Automatic},
            Automatic],
      PlotLegends ->
         Placed[
            LineLegend[LEGLABEL,
               "Spacings" -> {.5, .1},
               LabelStyle -> sizeFontSmaller],
            {Right, Top}],
      Prolog ->
         If[Length[MEANVALS] > 0,
            {{Thick,
               Table[
                  {COLORS[[i]], Dashed,
                     InfiniteLine[{0, MEANVALS[[i]]},
                                 {MEANVALS[[i]], 0}]},
                  {i, 1, Length[MEANVALS]}]}},
                  {}],
    OPTIONS];

plotMatrix[
   TRAJECTORIES_,
   COLORMAP_, TITLE_, 
   TYPE_:True, SHOWCBAR_:True, OPTIONS___] :=
   MatrixPlot[
      TRAJECTORIES,
      FrameLabel ->
         Which[
            TYPE === "contact",
            {Style["Age of participant (years)",
               Black, sizeFontBig, Opacity[1]],
            Style["Age of contacts (years)",
               Black, sizeFontBig, Opacity[1]]}, 
            TYPE === "sensitivity",
            {Style["Age of infectee (years)",
               Black, sizeFontBig, Opacity[1]],
            Style["Age of infector (years)",
               Black, sizeFontBig, Opacity[1]]},
            True,
            Automatic],
      PlotLabel -> Style[Row[{TITLE}], Black, sizeFontBig],
      AspectRatio -> 1,
      ImageSize -> 300,
      FrameStyle -> Opacity[0], 
      ClippingStyle -> Automatic,
      DataReversed -> {True, False},
      Mesh -> None,
      Frame -> True,
      PlotTheme -> "Web",
      FrameTicksStyle ->
         {{{Black, sizeFontSmall, Opacity[1]}, None},
         {{Black, sizeFontSmall, Opacity[1]}, None}},
      ColorFunction ->
         (Blend[
            {White, ColorData[COLORMAP][#]}, 0.7]
            &),
      PlotLegends ->
         Placed[
            BarLegend[Automatic,
               LegendMarkerSize -> 250, 
               LegendLabel -> Style[
                  Which[TYPE === "contact",
                      "Contacts\n(1/day)",
                      TYPE === "sensitivity",
                      "Sensitivity",
                      True,
                      Automatic],
                  Black, sizeFontBig], 
               LabelStyle -> Directive[
                  Black, sizeFontSmall, Opacity[1]]],
            {After, Top}],
      FrameTicks ->
         If[Dimensions[TRAJECTORIES][[1]] == 10,
            {{{1, "[0,5)", 0}, {2, "[5,10)", 0},
                  {3, "[10,20)", 0}, {4, "[20,30)", 0},
                  {5, "[30,40)", 0}, {6, "[40,50)", 0},
                  {7, "[50,60)", 0}, {8, "[60,70)", 0},
                  {9, "[70,80)", 0}, {10, "80+", 0}},
               {{1, Rotate["[0,5)", Pi/2], 0},
                  {2, Rotate["[5,10)", Pi/2], 0},
                  {3, Rotate["[10,20)", Pi/2], 0},
                  {4, Rotate["[20,30)", Pi/2], 0},
                  {5, Rotate["[30,40)", Pi/2], 0},
                  {6, Rotate["[40,50)", Pi/2], 0},
                  {7, Rotate["[50,60)", Pi/2], 0},
                  {8, Rotate["[60,70)", Pi/2], 0},
                  {9, Rotate["[70,80)", Pi/2], 0},
                  {10, Rotate["80+", Pi/2], 0}}},
            Automatic],
      ImagePadding ->
         If[TYPE === "contact"
               && Dimensions[TRAJECTORIES][[1]] == 85,
            {{70, 0},
            {Automatic, 0}},
            Automatic],
      OPTIONS];

plotHistogram[
   DATA_,
   TITLE_:"", XLABEL_:"", YLABEL_:"",
   COLOR_:Black] :=
   Histogram[
         DATA,
         {"Raw", 20},
         "Probability",
         AspectRatio -> 0.5, 
         ImageSize -> 250,
         AxesOrigin -> {0, 0},
         PlotRange -> {Automatic, {0, All}}, 
         Frame -> {{True, False}, {True, False}}, 
         FrameStyle -> Directive[Black, sizeFontSmall],
         ChartStyle -> Directive[COLOR, Opacity[0.5]],
         ChartBaseStyle -> EdgeForm[{Thick, White}],
         PlotTheme -> "Web",
         FrameLabel -> {{YLABEL, None},{XLABEL, None}},
         PlotLabel -> Style[TITLE,
            FontSize -> sizeFontBig,
            FontColor -> Black],
         FrameTicks -> {{Automatic, None}, {Automatic, None}}, 
         FrameTicksStyle ->
         {{{Black, sizeFontSmall, Opacity[1]}, None},
         {{Black, sizeFontSmall, Opacity[1]}, None}},
         ImagePadding -> Automatic,
         Prolog ->
            {{Thickness[0.01], Black,
               InfiniteLine[{{Median[DATA], 0},
                           {Median[DATA], 1}}]}, 
            {Thickness[0.005], Black, Dashed,
               InfiniteLine[{{Quantile[DATA, 0.025], 0},
                           {Quantile[DATA, 0.025], 1}}]},
            {Thickness[0.005], Black, Dashed,
               InfiniteLine[{{Quantile[DATA, 0.975], 0},
                           {Quantile[DATA, 0.975], 1}}]}}
   ];


plotBoxWhisker[
   TRAJECTORIES_,
   COLORS_, LABELS_:"", XLABEL_:None, YLABEL_:None] :=
   BoxWhiskerChart[
      TRAJECTORIES,
      {{"Whiskers", Thick}, {"Fences", Thick}},
      PlotTheme -> "Web",
      ChartLabels -> Placed[LABELS, Axis, Rotate[#, 0] &],
      BarSpacing -> 2,
      ChartStyle -> COLORS, 
      AspectRatio -> 0.5,
      ImageSize -> 500,
      Frame -> {{True, False}, {True, False}}, 
      FrameStyle -> Directive[Black, sizeFontSmall],
      FrameLabel ->
         If[XLABEL === None && YLABEL === None,
         {None, None},
         {Style[XLABEL, FontSize -> sizeFontBig], 
            Style[YLABEL, FontSize -> sizeFontBig]}],
      FrameTicks -> {{Automatic, None}, {label, None}},
      ChartElementFunction ->
         (ChartElementData["BoxWhisker"][##] /.
            GrayLevel[Except[1]] -> {} &)];


(* *************************************************************** *)
(* PRIVATE FUNCTIONS *)
Begin["`Private`"]

annotatedArrow[p_, q_, label_] :=
   {colorOrange,
      Arrowheads[
         {{-.015, 0},
         {0, 0.5, Graphics[Text[label,
                           {Global`transitionDates[[1]], 550},
                           {0, -1},
                              TextStyle -> {
                                 FontSize -> sizeFontSmall, colorOrange}]]},
         {.015, 1}}],
      Arrow[{p, q}]}

yellowLinesAndRegion[XYLIMITS_, SCENTOSHOW_:"default"] :=
   {{colorYellowBright,
      Table[
         Line[{{Global`transitionDates[[tIdx]],
               XYLIMITS[[1]]},
            {Global`transitionDates[[tIdx]],
               XYLIMITS[[2]]}}],
      {tIdx, 1, Length[Global`transitionDates]}]},
   {Dotted, colorYellowBright,
      Line[{{"June 10, 2020", XYLIMITS[[1]]},
            {"June 10, 2020", XYLIMITS[[2]]}}]},
   {Directive[colorYellowBright, 
               Which[SCENTOSHOW == "1zeta", Opacity[0.0375],
                     True, Opacity[0.075]]],
      Rectangle[
         {AbsoluteTime["March 24, 2020"], XYLIMITS[[1]]},
         {AbsoluteTime["June 10, 2020"], XYLIMITS[[2]]}]},
   Which[SCENTOSHOW == "1to2",
         {},
         True,
         {Directive[colorYellowBright,
                     Which[SCENTOSHOW == "2chris", Opacity[0.150],
                           True, Opacity[0.075]]],
         Rectangle[
            {AbsoluteTime["August 22, 2020"], XYLIMITS[[1]]},
            {Which[SCENTOSHOW == "2alt",
                     AbsoluteTime["December 18, 2020"],
               True, AbsoluteTime["January 15, 2021"]],
               XYLIMITS[[2]]}]}],
   {Table[
      Text[Rotate[transitionDatesLabelsShort[[tIdx]], Pi/2],
         {Global`transitionDates[[tIdx]], XYLIMITS[[2]]},
         {-1.75, 1},
            TextStyle ->
               {FontSize -> sizeFontSmaller, colorYellowBright}],
      {tIdx, 1, Length[Global`transitionDates]}]},
   {Text[Rotate["School holiday", Pi/2],
      {AbsoluteTime["June 10, 2020"], XYLIMITS[[2]]},
      {-1.75, 1},
         TextStyle ->
            {FontSize -> sizeFontSmaller,
            colorYellowBright}]}};

End[]


EndPackage[]