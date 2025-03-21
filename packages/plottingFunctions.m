BeginPackage["plottingFunctions`"]

(* Plotting labels and parameters *)
sizeFontBigger = 21;
sizeFontBig = 17;
sizeFontSmall = 14;
sizeFontSmaller = 12;
sizeFontSmallest = 10;
colorDarkRainbow = 
  Table[ColorData["DarkRainbow"][x], {x, 0, 1, 0.1}];
colorDarkBlue = colorDarkRainbow[[1]];
colorBlue = colorDarkRainbow[[2]];
colorBlueGreen = colorDarkRainbow[[3]];
colorDarkGreen = colorDarkRainbow[[4]];
colorGreen = colorDarkRainbow[[5]];
colorLightGreen = colorDarkRainbow[[6]];
colorYellowGreen = colorDarkRainbow[[7]];
colorYellow = colorDarkRainbow[[8]];
colorOrange = colorDarkRainbow[[9]];
colorRed = colorDarkRainbow[[10]];
colorDarkRed = colorDarkRainbow[[11]];

colorDarkRainbow4AgeGroups = 
 Table[ColorData["DarkRainbow"][
  x], {x, {0.3, 0.35, 0.4, 0.7, 0.75, 0.8, 0.85, 0.9, 0.95, 1}}];

dateTickValues = 
  DateRange[{2020, 3, 1}, {2021, 1, 1}, {1, "Month"}][[All, {1, 2}]];
dateTickVertical = {#, 
     Rotate[DateString[#, {"MonthNameShort", " ", "Year"}], \[Pi]/
       2]} & /@ dateTickValues;
dateTickHorizontal = {#, 
     DateString[#, {"MonthNameShort", " ", "Year"}]} & /@ dateTickValues;

ageLabel = {"[0,5) y.o.", "[5,10) y.o.", "[10,20) y.o.", 
   "[20,30) y.o.", "[30,40) y.o.", "[40,50) y.o.", "[50,60) y.o.", 
   "[60,70) y.o.", "[70,80) y.o.", "80+ y.o."};
ageLabelShort = {"[0,5)", "[5,10)", "[10,20)", "[20,30)", "[30,40)", 
   "[40,50)", "[50,60)", "[60,70)", "[70,80)", "80+"};


parameterConstXLabelShort = {"\[Epsilon]", "\[Zeta]", 
   "\[Theta] \!\(\*SubsuperscriptBox[\(\[Sum]\), \(k = 1\), \
\(n\)]\)\!\(\*SubscriptBox[\(N\), \(k\)]\)", 
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([0, 20\)\()\)\)]\)",
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([20, 60\)\()\)\)]\)", 
   "\[Phi]", "1/\[Alpha]", "1/\[Gamma]"};
parameterConstXLabel = {"Probability of transmission\nper contact", 
   "Reduction in probability of\ntransmission per contact", "Initial number\nof infected persons", 
   "Susceptibility of [0,20) y.o.\nrelative to 60+ y.o.",
   "Susceptibility of [20,60) y.o.\nrelative to 60+ y.o.", 
   "Overdispersion parameter", "Latent period (days)", 
   "Infectious period (days)"};
parameterTXLabelShort = {"\!\(\*SubscriptBox[\(t\), \(0\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\) (days)"};
parameterTXLabel = {"\!\(\*SubscriptBox[\(t\), \(0\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\)"};
parameterKXLabel = {"\!\(\*SubscriptBox[\(K\), \(0\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(K\), \(4\)]\)"};
parameterUXLabel = {"\!\(\*SubscriptBox[\(u\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(4\)]\)"};


diagramLabels = {"First lockdown,\nLD 1",
"Relaxation after first lockdown,\nRelax 1",
"Further relaxation,\nRelax 2",
"Second lockdown,\nLD 2",
"Relaxation due to\nwinter holidays,\nRelax 3"};
diagramLabelsShort = {"LD 1",
"Relax 1",
"Relax 2",
"LD 2",
"Relax 3"};
(* Public functions (functions the user will call) *)
(* LISTLINEPLOT::usage = "LISTLINEPLOT[data, options] plots the given data."; *)

(* Externally-sourced functions *)


(* Paper-specific plotting functions *)

plotWithLetter[plot_, label_String, side_ : "left", fontsize_:sizeFontBigger, colortext_:Black, legendmanual_:{}] :=
 Show[plot, Epilog -> {Join[{Inset[Graphics[Text[StyleForm[label, FontSize -> fontsize, FontColor-> colortext]]], 
 Which[side === "right", Scaled[{0.9, 0.9}], side === "left", Scaled[{0.1, 0.9}], True, side]]}, If[Length[Cases[plot, OptionsPattern[Epilog]]] > 0, Epilog /. Options[plot, Epilog], {}]], legendmanual}];


plotScenarioTrajectories[scentrajectories_, xlabel_: "Dates", ylabel_:"", title_:{"",""}, tickvals_:{Global`ticksss, Global`ticksss}, rangevals_:{{Automatic, Full}, {Automatic, Full}}, addend_:Graphics[], letters_:{"A", "B"}, letterdirection_:"left"] :=
   Module[{fig1, fig2}, 
   fig1 = plotWithLetter[{
      plotLineWithCrI[
         scentrajectories[[1]], 
         colorBlue, title[[1]], xlabel, ylabel, 1, 
         tickvals[[1]], rangevals[[1]]],
      plotLineWithCrI[
         scentrajectories[[2]], 
         colorOrange],
      addend}, letters[[1]], letterdirection];
   fig2 = plotWithLetter[{
      plotLineWithCrI[
         scentrajectories[[1]], 
         colorBlue, title[[2]], xlabel, "", 2, 
         tickvals[[2]], rangevals[[2]]],
      plotLineWithCrI[
         scentrajectories[[3]], 
         colorOrange],
      addend}, letters[[2]], letterdirection];
   Grid[{{fig1, fig2}}]];

plotStackedLinesWhole[data_, divider_, scen2plot_:1, SHOWLEGENDS_:True, ylabel_:"", title_:"", xlabel_:"Dates", ticklabels_:Global`ticksss,cmapstr_:colorDarkRainbow4AgeGroups, asprat_:0.5, imsize_:500, linestyle_:Solid, rangevals_:{0,107.5}] := 
   Show[StackedDateListPlot[data,
    {"February 25, 2020", Automatic, {0, 0, 1}},
   PlotRange -> {If[scen2plot==1, {Global`tStart1, Global`tEnd1}, {Global`tStart2, Global`tEnd2}], rangevals},
   PlotRangePadding -> None,
   PlotLegends -> If[SHOWLEGENDS, ageLabelShort, None],
   Ticks -> {tickmarks, Automatic},
   AspectRatio -> asprat, ImageSize -> imsize, 
   Frame -> {{True, False}, {True, False}},
   PlotTheme -> "Web",
   FrameStyle -> Directive[Black, 17], 
   AxesOrigin -> {"February 25, 2020", 0},
   FrameLabel -> {Style[xlabel, FontSize -> sizeFontBig], 
      Style[ylabel, FontSize -> sizeFontBig]},
   FrameTicks -> {{Automatic, None}, {ticklabels, None}},
   GridLines -> {Automatic, None},
   GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
   PlotLabel -> Style[Row[{title}], Black, 17, Bold],
   PlotStyle -> Table[{cmapstr[[kkk]], Thickness[0.001]}, {kkk, 1, Dimensions[data][[1]]}], 
   FrameTicksStyle -> {{{Black, 14, Opacity[1]}, None},
                       {{Black, 14, Opacity[1]}, None}}, 
   ImagePadding -> {{50, Automatic}, {Automatic, 
      Automatic}}, 
   Prolog -> {{colorYellow, Table[Line[{{Global`transitionDates[[tIdx]], 0}, {Global`transitionDates[[tIdx]], 107.5}}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Dotted, colorYellow, Line[{{"June 10, 2020", 0}, {"June 10, 2020", 107.5}}]}, 
   {Directive[colorYellow, Opacity[0.25]], Rectangle[{AbsoluteTime["March 24, 2020"], 100}, {AbsoluteTime["June 10, 2020"], 107.5}]},
   {Directive[colorYellow, Opacity[0.25]], Rectangle[{AbsoluteTime["August 22, 2020"], 100}, {AbsoluteTime["December 18, 2020"], 107.5}]},
   {Table[Text[Global`transitionDatesLabelsShort[[tIdx]], {Global`transitionDates[[tIdx]], 107.5}, {-1.25, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Text["Sch. Holi.", {AbsoluteTime["June 10, 2020"], 107.5}, {-1.25, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}]}}],
   DateListPlot[divider, {"February 25, 2020", Automatic, {0, 0, 1}},
   PlotStyle->{colorDarkGreen, Thick}]]

plotStackedLinesMoving[data_, scen2plot_:1, SHOWLEGENDS_:True, rangevals_:{0,1}, ylabel_:"", title_:"", xlabel_:"Dates", ticklabels_:Global`ticksss, cmapstr_:colorDarkRainbow4AgeGroups, asprat_:0.5, imsize_:500] := 
   StackedDateListPlot[data,
    {"February 25, 2020", Automatic, {0, 0, 1}},
   PlotRange -> {If[scen2plot==1, {Global`tStart1, Global`tEnd1}, {Global`tStart2, Global`tEnd2}], rangevals},
   PlotRangePadding -> None,
   (* PlotLegends -> Placed[If[SHOWLEGENDS, ageLabelShort, None], {Left, Top}, LabelStyle -> sizeFontSmallest], *)
   PlotLegends -> If[SHOWLEGENDS, Placed[SwatchLegend[colorDarkRainbow4AgeGroups, ageLabelShort, LabelStyle -> sizeFontSmallest], {Left, Top}], None],
   Ticks -> {tickmarks, Automatic},
   AspectRatio -> asprat, ImageSize -> imsize, 
   Frame -> {{True, False}, {True, False}},
   PlotTheme -> "Web",
   FrameStyle -> Directive[Black, 17], 
   AxesOrigin -> {"February 25, 2020", 0},
   FrameLabel -> {Style[xlabel, FontSize -> sizeFontBig], 
      Style[ylabel, FontSize -> sizeFontBig]},
   FrameTicks -> {{Automatic, None}, {ticklabels, None}},
   GridLines -> {Automatic, None},
   GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
   PlotLabel -> Style[Row[{title}], Black, 17, Bold],
   PlotStyle -> Table[{cmapstr[[kkk]], Thickness[0.002]}, {kkk, 1, Dimensions[data][[1]]}], 
   FrameTicksStyle -> {{{Black, 14, Opacity[1]}, None},
                       {{Black, 14, Opacity[1]}, None}}, 
   ImagePadding -> {{50, Automatic}, {Automatic, 
      Automatic}}, 
   Prolog -> {{colorYellow, Table[Line[{{Global`transitionDates[[tIdx]], rangevals[[1]]}, {Global`transitionDates[[tIdx]], rangevals[[2]]}}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Dotted, colorYellow, Line[{{"June 10, 2020", rangevals[[1]]}, {"June 10, 2020", rangevals[[2]]}}]}, 
   {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["March 24, 2020"], rangevals[[1]]}, {AbsoluteTime["June 10, 2020"], rangevals[[2]]}]},
   {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["August 22, 2020"], rangevals[[1]]}, {AbsoluteTime["December 18, 2020"], rangevals[[2]]}]},
   {Table[Text[Rotate[Global`transitionDatesLabelsShort[[tIdx]], Pi/2], {Global`transitionDates[[tIdx]], rangevals[[2]]}, {-1.75, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Text[Rotate["Sch. Holi.", Pi/2], {AbsoluteTime["June 10, 2020"], rangevals[[2]]}, {-1.75, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}]},
   {Dashed, Black, InfiniteLine[{AbsoluteTime["February 26, 2020"], 
    0}, {AbsoluteTime["January 15, 2020"], 0}]}}]


plotPDF[data_, minval_, maxval_, colorval_, xlabel_, ylabel_, title_,ifLog_:False, rangevals_:Automatic] :=
   Module[{plotter, x, skd},
   skd = SmoothKernelDistribution[data];
   plotter = If[ifLog, LogLinearPlot, Plot];
   plotter[PDF[skd, x],
   {x, minval, maxval}, 
   Filling -> Axis, 
   PlotStyle -> {colorval},
   PlotRange -> rangevals,
   Frame -> {{True, False}, {True, False}}, 
   FrameStyle -> Directive[Black, sizeFontSmall],
   TicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, 
      None}, {{Black, sizeFontSmall, Opacity[1]}, None}},
   FrameLabel -> {Style[xlabel, FontSize -> sizeFontBig], 
      Style[ylabel, FontSize -> sizeFontBig]},
   GridLines -> {Automatic, None},
   TicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                  {{Black, sizeFontSmall, Opacity[1]}, None}}
   ]]

plotSmoothHist[data_, ifLog_:False, options___] :=
   SmoothHistogram[data, Automatic, "PDF", 
   ScalingFunctions -> {If[ifLog, "Log", Identity], {#*(Max[data] - Min[data])/
 Length[HistogramList[data, 20, "Probability"][[1]] - 1] &, #/(Max[data] - Min[data])/
 Length[HistogramList[data, 20, "Probability"][[1]] - 1] &}}, options];

plotDiagram[data_, tickss_, asprat_:0.5, imsize_:500] :=
  DateListPlot[Total[Transpose[data]], 
   "February 26, 2020",
   PlotMarkers ->{Graphics[{Black, Style[Circle[], Thickness[0.25]]}], 5}, 
   PlotTheme -> "Web",
   Joined -> False,
   GridLines -> {Automatic, None},
   GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
   DateTicksFormat -> {"MonthShort", "/", "YearShort"}, 
   FrameTicks -> {{Automatic, None}, {tickss, None}},
   AspectRatio -> asprat 0.5, ImageSize -> 1.625 imsize,
   PlotRangeClipping -> False,
   PlotRange -> {{"February 25, 2020", "January 16, 2021"}, {0, 550}},
   Frame -> {{True, False}, {True, False}}, PlotTheme -> "Web",
   FrameStyle -> Directive[Black, 17], 
   FrameLabel -> {{"Hospitalizations (1/day)", None}, {"Dates", None}}, 
   (* PlotLabel -> 
    Style[Row[{"Scenario 1                                            \
                        Scenario 2        "}], Black, 17],  *)
   FrameTicksStyle -> {{{Black, 14, Opacity[1]}, 
      None}, {{Black, 14, Opacity[1]}, None}}, 
   Prolog -> {
      {Thick, Black, Line[{{"July 15, 2020", 0}, {"July 15, 2020", 550}}]},
      {colorYellow, Table[Line[{{Global`transitionDates[[tIdx]], 0}, {Global`transitionDates[[tIdx]], 550}}], {tIdx, 1, Length[Global`transitionDates]}]},
      {Dashed, colorYellow, Table[Line[{{Global`transitionDatesQuantiles025[[tIdx]], 0}, {Global`transitionDatesQuantiles025[[tIdx]], 550}}], {tIdx, 1, Length[Global`transitionDatesQuantiles025]}]},
      {Dashed, colorYellow, Table[Line[{{Global`transitionDatesQuantiles975[[tIdx]], 0}, {Global`transitionDatesQuantiles975[[tIdx]], 480}}], {tIdx, 1, Length[Global`transitionDatesQuantiles975]}]},
      {Dotted, colorYellow, Line[{{"June 10, 2020", 0}, {"June 10, 2020", 550}}]},
      {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["March 24, 2020"], 0}, {AbsoluteTime["June 10, 2020"], 550}]},
      {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["August 22, 2020"], 0}, {AbsoluteTime["December 18, 2020"], 550}]},
      {Table[Text[diagramLabels[[tIdx]], {Global`transitionDates[[tIdx]], 550}, {-1.075, 1}, TextAlignment-> Left, TextStyle -> {FontSize -> sizeFontSmallest, colorYellow}], {tIdx, 1, Length[Global`transitionDates]}]},
      {Text["School\nholidays", {AbsoluteTime["June 10, 2020"],450}, {-1.075, 1}, TextAlignment-> Left, TextStyle -> {FontSize -> sizeFontSmallest, colorYellow}]}
      },
      Epilog -> {AnnotatedArrow[{"February 26, 2020", 560}, {"July 15, 2020", 560}, "Scenario 1"],
      AnnotatedArrow[{"July 15, 2020", 560}, {"January 15, 2021", 560}, "Scenario 2"]},
      ImagePadding -> {{All, All}, {All, 50}}
   (* ImagePadding -> {{50, 2.5}, {65, 10}} *)
  ]

plotThickLine[data_, COLORS_, TITLE_, XLABEL_, YLABEL_, LEGLABEL_, TYPE_, MEANVALS_:{}, RANGEVALS_:Automatic, options___] :=
  plotListLineDefault[data,
  (* PlotStyle -> ColorData[COLORMAP] /@ (Range[1, Length[data]]/Length[data]), *)
    PlotStyle -> COLORS,
    FrameLabel -> {{YLABEL, None}, {XLABEL, 
      None}},
    PlotRange -> RANGEVALS,
    PlotLabel -> Style[TITLE, Black, sizeFontBig], 
    FrameTicks -> If[TYPE == "contacts",
          {{{1, Rotate["[0,5)", Pi/2]}, {2, Rotate["[5,10)", Pi/2]},
           {3, Rotate["[10,20)", Pi/2]}, {4, Rotate["[20,30)", Pi/2]},
           {5, Rotate["[30,40)", Pi/2]}, {6, Rotate["[40,50)", Pi/2]},
           {7, Rotate["[50,60)", Pi/2]}, {8, Rotate["[60,70)", Pi/2]},
           {9, Rotate["[70,80)", Pi/2]}, {10, Rotate["80+", Pi/2]}}, Automatic}, Automatic],
    PlotLegends -> Placed[LineLegend[LEGLABEL,
  "Spacings" -> {.5, .1}, LabelStyle -> sizeFontSmaller], {Right, Top}],
    Prolog -> If[Length[MEANVALS] > 0, 
                  {{Thick, Table[{COLORS[[i]], Dashed, InfiniteLine[{0, MEANVALS[[i]]}, {MEANVALS[[i]], 0}]},
                  {i, 1, Length[MEANVALS]}]}},
                  {}],
    options];


plotYLine[number_, xpos_, ypos_, colorr_] :=
 {InfiniteLine[{0, number}, {1, number}, 
 PlotStyle -> {colorr, Dashed}],
 Graphics[{Style[
   Text[ToString[Round[number, 0.01]], xpos, ypos], 
   FontSize -> sizeFontSmall,
   FontColor-> colorr]}]};

plotMatrix[data_, COLORMAP_, TITLE_, TYPE_ : True, SHOWCBAR_:True, options___] :=
  plotMatrixDefault[data,
  FrameLabel -> Which[TYPE === "contact", {Style["Age of participant (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of contacts (years)", Black, sizeFontBig, Opacity[1]]}, 
                 TYPE === "sensitivity", {Style["Age of infectee (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of infector (years)", Black, sizeFontBig, Opacity[1]]},
                 TYPE === "elasticity", {Style["Age of infectee (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of infector (years)", Black, sizeFontBig, Opacity[1]]},
                 True, Automatic], 
  PlotLabel -> Style[Row[{TITLE}], Black, sizeFontBig, Bold],
  ColorFunction -> COLORMAP, 
  PlotLegends -> 
    Placed[BarLegend[Automatic, LegendMarkerSize -> 250, 
      LegendLabel -> Style["Contacts\n(1/day)", Black, sizeFontBig], 
      LabelStyle -> Directive[Black, sizeFontSmall, Opacity[1]]], {After, Top}],
  FrameTicks -> If[Dimensions[data][[1]] == 10,
          {{{1, "[0,5)", 0}, {2, "[5,10)", 0},
          {3, "[10,20)", 0}, {4, "[20,30)", 0},
          {5, "[30,40)", 0}, {6, "[40,50)", 0},
          {7, "[50,60)", 0}, {8, "[60,70)", 0},
          {9, "[70,80)", 0}, {10, "80+", 0}},
          {{1, Rotate["[0,5)", Pi/2], 0}, {2, Rotate["[5,10)", Pi/2], 0},
          {3, Rotate["[10,20)", Pi/2], 0}, {4, Rotate["[20,30)", Pi/2], 0},
          {5, Rotate["[30,40)", Pi/2], 0}, {6, Rotate["[40,50)", Pi/2], 0},
          {7, Rotate["[50,60)", Pi/2], 0}, {8, Rotate["[60,70)", Pi/2], 0},
          {9, Rotate["[70,80)", Pi/2], 0}, {10, Rotate["80+", Pi/2], 0}}},
          Automatic],
  options];

plotMatrix2[data_, quantlow_, quanthigh_, TITLE_String:"", SHOWFRAMES_:False, COLORMAP_:"ThermometerColors",  options___] :=
  Module[{index1,index2, transposedData, transposedLow, transposedUp},

  transposedData = Reverse[data, 1];
  transposedLow = Reverse[quantlow, 1];
  transposedUp = Reverse[quanthigh, 1];
  plotMatrix2Default[data, 
  FrameLabel -> If[SHOWFRAMES == True, {Style["Age of participant (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of contacts (years)", Black, sizeFontBig, Opacity[1]]},
                 {"", ""}],
  PlotLabel -> Style[Row[{TITLE}], Black, sizeFontBig, Bold],
  ColorFunction -> (ColorData["ThermometerColors"][Rescale[#, {0, 13}, {0.5, 1.25}]] &),
  ColorFunctionScaling -> False,
  PlotLegends -> None,
  FrameTicks -> {{{1, Rotate["[0,20)", Pi/2], 0}, {2, Rotate["20+", Pi/2], 0},
          {3, Rotate["[0,20)", Pi/2], 0}},
          {{1, "[0,20)", 0}, {2, "20+", 0}}},
   Epilog -> Table[
    Text[
     Style[
      ToString[Round[transposedData[[index2, index1]], 0.01]]
      <>
      "\n[" <> ToString[Round[transposedLow[[index2, index1]], 0.01]]
      <> "-" <>
      ToString[Round[transposedUp[[index2, index1]], 0.01]] <> "]", 
      FontSize -> sizeFontSmaller,
      If[data[[3 - index2, index1]] < 2.5, Black, White] (* Conditional color *)
     ],
     {index1 - 0.5, 2.5 - index2}
    ], 
    {index1, 2}, {index2, 2}
   ],
  options]];


plotHistogram[vals_, title_, xlab_, ylab_, colorChosen_, addLine_:True] :=
   Show[plotHistogramDefault[vals, title, xlab, ylab, colorChosen],
   Sequence @@ If[addLine, {plotSmoothHist[vals, False, PlotStyle -> {Thick, colorChosen}]}, {}],
   Graphics[{Thickness[0.01], Black, 
        InfiniteLine[{{Median[vals], 0}, {Median[vals], 1}}]}], 
     Graphics[{Thickness[0.005], Black, Dashed, 
        InfiniteLine[{{Quantile[vals, 0.025], 0}, {Quantile[vals, 0.025], 1}}]}], 
    Graphics[{Thickness[0.005], Black, Dashed, 
        InfiniteLine[{{Quantile[vals, 0.975], 0}, {Quantile[vals, 0.975], 1}}]}]];


plotLineWithCrI[data_, color_:colorBlue, title_:"", xlabel_:"Dates", ylabel_:"", scen2plot_:1, 
  ticklabels_:Global`ticksss, rangevals_ : {0, Full}, asprat_:0.5, imsize_:500, linestyle_:Solid] := 
   DateListPlot[{Median[Re[data]],
             Quantile[Re[data], 0.025],
             Quantile[Re[data], 0.975]},
    {"February 25, 2020", Automatic, {0, 0, 1}},
   PlotRange -> {If[scen2plot==1, {Global`tStart1, Global`tEnd1}, {Global`tStart2, Global`tEnd2}], rangevals},
   PlotRangePadding -> None,
   Ticks -> {tickmarks, Automatic},
   AspectRatio -> asprat, ImageSize -> imsize, 
   Frame -> {{True, False}, {True, False}},
   PlotTheme -> "Web",
   FrameStyle -> Directive[Black, 17], 
   AxesOrigin -> {"February 25, 2020", 0},
   FrameLabel -> {Style[xlabel, FontSize -> sizeFontBig], 
      Style[ylabel, FontSize -> sizeFontBig]},
   FrameTicks -> {{Automatic, None}, {ticklabels, None}},
   GridLines -> {Automatic, None},
   GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
   PlotLabel -> Style[Row[{title}], Black, 17, Bold],
   Filling -> {3 -> {2}}, 
   PlotStyle -> {{linestyle, color, Thickness[0.006]}, {Lighter[color], Thin},
                 {Lighter[color], Thin}}, 
   FrameTicksStyle -> {{{Black, 14, Opacity[1]}, None},
                       {{Black, 14, Opacity[1]}, None}}, 
   ImagePadding -> {{50, Automatic}, {Automatic, 
      Automatic}}, 
   Prolog -> {{colorYellow, Table[Line[{{Global`transitionDates[[tIdx]], rangevals[[1]]}, {Global`transitionDates[[tIdx]], rangevals[[2]]}}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Dotted, colorYellow, Line[{{"June 10, 2020", rangevals[[1]]}, {"June 10, 2020", rangevals[[2]]}}]}, 
   {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["March 24, 2020"], rangevals[[1]]}, {AbsoluteTime["June 10, 2020"], rangevals[[2]]}]},
   {Directive[colorYellow, Opacity[0.075]], Rectangle[{AbsoluteTime["August 22, 2020"], rangevals[[1]]}, {AbsoluteTime["December 18, 2020"], rangevals[[2]]}]},
   {Table[Text[Rotate[Global`transitionDatesLabelsShort[[tIdx]], Pi/2], {Global`transitionDates[[tIdx]], rangevals[[2]]}, {-1.75, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Text[Rotate["Sch. Holi.", Pi/2], {AbsoluteTime["June 10, 2020"], rangevals[[2]]}, {-1.75, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}]}}]


plotScatterWithError[data_, label_, xlab_, ylab_, title_, 
  ifInset_ : False, insetIndex_ : False] := Module[{maxOfAll},
  maxOfAll = 
   Max[medianQuantile[data]][[2, 2]] + 
    Max[medianQuantile[data]][[1]] + 
    Max[medianQuantile[data]][[2, 2]]/2;
  ListPlot[medianQuantile[data], 
   PlotMarkers -> {Automatic, 13},
   AspectRatio -> 1, ImageSize -> 300, 
   IntervalMarkers -> "Fences", 
   IntervalMarkersStyle -> {Black, Thick},
   PlotStyle -> Lighter[colorDarkBlue],
   PlotStyle -> "Web",
   LabelStyle -> Directive[ FontSize -> sizeFontSmall],
   Frame -> {{True, False}, {True, False}}, 
   FrameStyle -> Directive[Black, sizeFontSmall],
   
   TicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, 
      None}, {{Black, sizeFontSmall, Opacity[1]}, None}},
   PlotRangePadding -> {{Automatic, Scaled[0.05]}, Automatic},
   PlotRange -> {{0, Length[data]}, {0, maxOfAll}},
   PlotMarkers -> {Automatic, Scaled[0.02]},
   FrameLabel -> If[xlab === None && ylab === None,
   {None, None},
    {Style[xlab, FontSize -> sizeFontBig], 
      Style[ylab, FontSize -> sizeFontBig]}],
   PlotLabel -> If[title === None, None, Style[Row[{title}], Black, 17]],
   FrameTicks -> {Transpose[{Range[Length[label]], 
       Rotate[#, Pi/2] & /@ label}], Automatic},
   Prolog -> If[ifInset,
     {Inset[
       plotScatterWithError[data[[insetIndex, All]], label, None, None, None, 
        False, {}], Scaled[{0.1, 0.8}], Scaled[{0, 1}], 
       Scaled[0.6], Background -> Lighter[Gray, 0.95]]}, {}]]]

plotBoxWhisker[data_, label_, ifInset_ : False, insetIndex_ : False] :=
  BoxWhiskerChart[data, "Outliers", 
   ChartLabels -> Placed[label, Axis, Rotate[#, 90 Degree] &],
   ChartStyle -> 4, 
   Epilog -> 
    If[ifInset, 
     Inset[plotBoxWhisker[data[[insetIndex, All]], label], 
      Scaled[{0.1, 0.95}], Scaled[{0, 1}], Automatic], {}]];

(* Redefining default functions *)

plotHistogramDefault[vals_, title_, xlab_, ylab_, colorChosen_] := 
Histogram[vals, {"Raw", 20}, "Probability", AspectRatio -> 0.5, 
   ImageSize -> 250, AxesOrigin -> {0, 0}, 
   PlotRange -> {Automatic, {0, All}}, 
   Frame -> {{True, False}, {True, False}}, 
   FrameStyle -> Directive[Black, sizeFontSmall], 
   ChartStyle -> Directive[colorChosen, Opacity[0.5]],
   ChartBaseStyle -> EdgeForm[{Thick, White}],
   PlotTheme -> "Web",
   FrameLabel -> {{ylab, None},{xlab, None}},
   PlotLabel -> Style[title, FontSize -> sizeFontBig, FontColor -> Black],
   FrameTicks -> {{Automatic, None}, {Automatic, None}}, 
   FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None}, {{Black, sizeFontSmall, Opacity[1]}, None}},
   ImagePadding -> Automatic];


plotListDefault[data_, options___] :=
  ListPlot[data,
  List[Options[plotListDefault],
  options]];


Options[plotListDefault] = {
  AspectRatio -> 0.75,
  ImageSize -> 300,
  PlotRange -> {{0, Automatic}, {0, Automatic}},
  Frame -> {{True, False}, {True, False}},
  FrameStyle -> Directive[Black, sizeFontBig],
  PlotTheme -> "Web",
  PlotRangePadding -> None,
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


plotListLineDefault[data_, options___] :=
  ListLinePlot[data,
  List[Options[plotListLineDefault],
  options]];


Options[plotListLineDefault] = {
  AspectRatio -> 0.75,
  ImageSize -> 300,
  (* PlotRange -> {{0, Automatic}, {0, Automatic}}, *)
  Frame -> {{True, False}, {True, False}},
  FrameStyle -> Directive[Black, sizeFontBig],
  PlotTheme -> "Web",
  PlotRangePadding -> None,
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


plotMatrix2Default[data_, options___] :=
  MatrixPlot[data, List[Options[plotMatrix2Default], options]];

Options[plotMatrix2Default] = {
  AspectRatio -> 1,
  ImageSize -> 200,
  FrameStyle -> Opacity[0], 
  ClippingStyle -> Automatic,
  DataReversed -> {True, False},
  Mesh -> None,
  Frame -> True,
  PlotTheme -> "Web", 
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


plotMatrixDefault[data_, options___] :=
  MatrixPlot[data, List[Options[plotMatrixDefault], options]];

Options[plotMatrixDefault] = {
  AspectRatio -> 1,
  ImageSize -> 300,
  FrameStyle -> Opacity[0], 
  ClippingStyle -> Automatic,
  DataReversed -> {True, False},
  Mesh -> None,
  Frame -> True,
  PlotTheme -> "Web", 
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


medianQuantile[data_] := 
 Table[Around[
   Median[data[[i, All]]], {Abs[
     Median[data[[i, All]]] - Quantile[data[[i, All]], 0.025]], 
    Abs[Quantile[data[[i, All]], 0.975] - 
      Median[data[[i, All]]]]}], {i, 1, Dimensions[data][[1]]}]

Begin["`Private`"] (* Begin private context *)


AnnotatedArrow[p_, q_, 
  label_] := {colorOrange, Arrowheads[{{-.015, 0}, {0, 0.5, 
     Graphics[Text[label, {Global`transitionDates[[1]], 550}, {0, -1}, TextStyle -> {FontSize -> sizeFontSmall, colorOrange}]]}, {.015, 1}}],
   Arrow[{p, q}]}
ArrowYear[p_, q_, 
  label_] := {Black, Arrowheads[{{-.015, 0}, {0, If[label === "2020", 0.5, 1], 
     Graphics[Text[label, {0, 0}, {1, 1.25}, TextStyle -> {FontSize -> sizeFontSmall, Black}]]}, If[label === "2020", {.015, 1}, {.0, 1}]}],
   Arrow[{p, q}]}
arrowSchoolsOpen[p_, q_, 
  label_] := {colorDarkGreen, Arrowheads[{{-.015, 0}, {0, 0.5, 
     Graphics[Text[label, {0, 0}, {0, -1.5}, TextStyle -> {FontSize -> sizeFontSmallest, colorDarkGreen}]]}, {.015, 1}}],
   Arrow[{p, q}]}
arrowSchoolsClosed[p_, q_, 
  label_] := {colorDarkRed, Arrowheads[{{-.015, 0}, {0, 0.5, 
     Graphics[Text[label, {0, 0}, {0, -1.5}, TextStyle -> {FontSize -> sizeFontSmallest, colorDarkRed}]]}, {.015, 1}}],
   Arrow[{p, q}]}

End[] (* End private context *)


EndPackage[]