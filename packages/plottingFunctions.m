BeginPackage["plottingFunctions`"]

(* Plotting labels and parameters *)
sizeFontBigger = 21;
sizeFontBig = 17;
sizeFontSmall = 14;
sizeFontSmaller = 12;

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

ageLabel = {"[0,5) y.o.", "[5,10) y.o.", "[10,20) y.o.", 
   "[20,30) y.o.", "[30,40) y.o.", "[40,50) y.o.", "[50,60) y.o.", 
   "[60,70) y.o.", "[70,80) y.o.", "80+ y.o."};
ageLabelShort = {"[0,5)", "[5,10)", "[10,20)", "[20,30)", "[30,40)", 
   "[40,50)", "[50,60)", "[60,70)", "[70,80)", "80+"};


parameterConstXLabelShort = {"\[Epsilon] (%)", "\[Zeta]", 
   "\[Theta] \!\(\*SubsuperscriptBox[\(\[Sum]\), \(k = 1\), \
\(n\)]\)\!\(\*SubscriptBox[\(N\), \(k\)]\)", 
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([0, 20\)\()\)\)]\)",
   "\!\(\*SubscriptBox[\(\[Beta]\), \(\([20, 60\)\()\)\)]\)", 
   "\[Phi]", "1/\[Alpha] (days)", "1/\[Gamma] (days)"};
parameterConstXLabel = {"Probability of transmission\nper contact, \
\[Epsilon]", 
   "Reduction in probability of\ntransmission per contact, \
(1-\[Zeta])", "Initial number\nof infected persons, \[Theta]", 
   "Susceptibility of [0,20) y.o.\nrelative to 60+ y.o., \
\!\(\*SubscriptBox[\(\[Beta]\), \(\([0, 20\)\()\)\)]\)",
   "Susceptibility of [20,60) y.o.\nrelative to 60+ y.o., \
\!\(\*SubscriptBox[\(\[Beta]\), \(\([20, 60\)\()\)\)]\)", 
   "Overdispersion parameter, r", "Latent period (days), 1/\[Alpha]", 
   "Infectious period (days), 1/\[Gamma]"};
parameterTXLabelShort = {"\!\(\*SubscriptBox[\(t\), \(0\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\) (days)"};
parameterTXLabel = {"\!\(\*SubscriptBox[\(t\), \(0\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(1\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(2\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(3\)]\) (days)", 
   "\!\(\*SubscriptBox[\(t\), \(4\)]\) (days)"};
parameterKXLabelShort = {"\!\(\*SubscriptBox[\(K\), \(0\)]\) (1/day)",
    "\!\(\*SubscriptBox[\(K\), \(1\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(2\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(3\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(4\)]\) (1/day)"};
parameterKXLabel = {"\!\(\*SubscriptBox[\(K\), \(0\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(1\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(2\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(3\)]\) (1/day)", 
   "\!\(\*SubscriptBox[\(K\), \(4\)]\) (1/day)"};
parameterUXLabelShort = {"\!\(\*SubscriptBox[\(u\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(4\)]\)"};
parameterUXLabel = {"\!\(\*SubscriptBox[\(u\), \(1\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(2\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(3\)]\)", 
   "\!\(\*SubscriptBox[\(u\), \(4\)]\)"};


(* Public functions (functions the user will call) *)
(* LISTLINEPLOT::usage = "LISTLINEPLOT[data, options] plots the given data."; *)

(* Externally-sourced functions *)


(* Paper-specific plotting functions *)

plotWithLetter[plot_, label_String, side_String : "left"] :=
 Show[plot, Epilog -> Join[{Inset[Graphics[Text[StyleForm[label, FontSize -> sizeFontBigger]]], 
 If[side === "right", Scaled[{0.9, 0.9}], Scaled[{0.1, 0.9}]]]}, If[Length[Cases[plot, OptionsPattern[Epilog]]] > 0, Epilog /. Options[plot, Epilog], {}]]];



plotThickLine[data_, COLORS_, TITLE_, XLABEL_, YLABEL_, LEGLABEL_, options___] :=
  plotListLineDefault[data,
  (* PlotStyle -> ColorData[COLORMAP] /@ (Range[1, Length[data]]/Length[data]), *)
    PlotStyle -> COLORS,
    FrameLabel -> {{YLABEL, None}, {XLABEL, 
      None}},
    PlotLabel -> Style[TITLE, Black, sizeFontBig], 
    FrameTicks -> If[Length[data] == 10,
          {{{1, Rotate["[0,5)", Pi/2]}, {2, Rotate["[5,10)", Pi/2]},
           {3, Rotate["[10,20)", Pi/2]}, {4, Rotate["[20,30)", Pi/2]},
           {5, Rotate["[30,40)", Pi/2]}, {6, Rotate["[40,50)", Pi/2]},
           {7, Rotate["[50,60)", Pi/2]}, {8, Rotate["[60,70)", Pi/2]},
           {9, Rotate["[70,80)", Pi/2]}, {10, Rotate["80+", Pi/2]}}, Automatic}, Automatic],
    PlotLegends -> LEGLABEL,
    options];


plotMatrix[data_, COLORMAP_, TITLE_, TYPE_ : True, options___] :=
  plotMatrixDefault[data,
  FrameLabel -> Which[TYPE === "contact", {Style["Age of participant (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of contacts (years)", Black, sizeFontBig, Opacity[1]]}, 
                 TYPE === "sensitivity", {Style["Age of infectee (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of infector (years)", Black, sizeFontBig, Opacity[1]]},
                 TYPE === "elasticity", {Style["Age of infectee (years)", Black, sizeFontBig, Opacity[1]],
                 Style["Age of infector (years)", Black, sizeFontBig, Opacity[1]]},
                 True, Automatic], 
  PlotLabel -> Style[Row[{TITLE}], Black, sizeFontBig],
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


plotYLine[number_, xmin_, xmax_, xpos_, ypos_, colorr_] :=
 {Plot[number, {x, xmin, xmax}, 
 PlotStyle -> {colorr, Dashed}],
 Graphics[{Style[
   Text[ToString[Round[number, 0.01]], xpos, ypos], 
   FontSize -> sizeFontSmall,
   FontColor-> colorr]}]};


plotHistogram[vals_, title_, xlab_, ylab_] :=
Show[plotHistogramDefault[vals, title, xlab, ylab],
    Graphics[{Thickness[0.01], Black, 
        InfiniteLine[{{Median[vals], 0}, {Median[vals], 1}}]}], 
     Graphics[{Thickness[0.005], Black, Dashed, 
        InfiniteLine[{{Quantile[vals, 0.025], 0}, {Quantile[vals, 0.025], 1}}]}], 
    Graphics[{Thickness[0.005], Black, Dashed, 
        InfiniteLine[{{Quantile[vals, 0.975], 0}, {Quantile[vals, 0.975], 1}}]}]];


plotLineWithCrI[data_, title_, xlabel_, ylabel_, color_, startdate_, 
  enddate_, ticklabels_, rangevals_ : {Automatic, Automatic}] := 
DateListPlot[{Median[Re[data]],
             Quantile[Re[data], 0.025],
             Quantile[Re[data], 0.975]},
    {"February 25, 2020", Automatic, {0, 0, 1}},
   PlotRange -> {{startdate, enddate}, rangevals},
   PlotRangePadding -> None,
   Ticks -> {tickmarks, Automatic},
   AspectRatio -> 0.5, ImageSize -> 500, 
   Frame -> {{True, False}, {True, False}},
   PlotTheme -> "Web",
   FrameStyle -> Directive[Black, 17], 
   AxesOrigin -> {"February 25, 2020", 0}, 
   FrameLabel -> {Style[xlabel, FontSize -> sizeFontBig], 
      Style[ylabel, FontSize -> sizeFontBig]},
   FrameTicks -> {{Automatic, None}, {ticklabels, None}},
   GridLines -> {Automatic, None},
   GridLinesStyle -> {{GrayLevel[0.95]}, {None}},
   PlotLabel -> Style[Row[{title}], Black, 17],
   Filling -> {3 -> {2}}, 
   PlotStyle -> {{color, Thickness[0.006]}, {Lighter[color], Thin},
                 {Lighter[color], Thin}}, 
   FrameTicksStyle -> {{{Black, 14, Opacity[1]}, None},
                       {{Black, 14, Opacity[1]}, None}}, 
   ImagePadding -> {{50, Automatic}, {Automatic, 
      Automatic}}, 
   Prolog -> {{colorYellow, Table[Line[{{Global`transitionDates[[tIdx]], rangevals[[1]]}, {Global`transitionDates[[tIdx]], rangevals[[2]]}}], {tIdx, 1, Length[Global`transitionDates]}]},
   {Dotted, colorYellow, Line[{{"June 10, 2020", rangevals[[1]]}, {"June 10, 2020", rangevals[[2]]}}]}, 
   {Directive[colorYellow, Opacity[0.1]], Rectangle[{AbsoluteTime["March 24, 2020"], rangevals[[1]]}, {AbsoluteTime["June 10, 2020"], rangevals[[2]]}]},
   {Directive[colorYellow, Opacity[0.1]], Rectangle[{AbsoluteTime["August 22, 2020"], rangevals[[1]]}, {AbsoluteTime["December 18, 2020"], rangevals[[2]]}]},
   {Table[Text[Rotate[Global`transitionDatesLabelsShort[[tIdx]], Pi/2], {Global`transitionDates[[tIdx]], rangevals[[2]]}, {-1.75, 1}, TextStyle -> {FontSize -> sizeFontSmaller, colorYellow}], {tIdx, 1, Length[Global`transitionDates]}]}}]


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

plotHistogramDefault[vals_, title_, xlab_, ylab_] := 
Histogram[vals, {"Raw", 20}, "Probability", AspectRatio -> 0.5, 
   ImageSize -> 250, AxesOrigin -> {0, 0}, 
   PlotRange -> {Automatic, {0, All}}, 
   Frame -> {{True, False}, {True, False}}, 
   FrameStyle -> Directive[Black, sizeFontSmall], 
   ChartStyle -> Directive[colorLightGreen, Opacity[0.5]],
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
  PlotRange -> {{0, Automatic}, {0, Automatic}},
  Frame -> {{True, False}, {True, False}},
  FrameStyle -> Directive[Black, sizeFontBig],
  PlotTheme -> "Web",
  PlotRangePadding -> None,
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


plotMatrixDefault[data_, options___] :=
  MatrixPlot[data, List[Options[plotMatrixDefault], options]];


Options[plotMatrixDefault] = {
  ImageSize -> 300,
  FrameStyle -> Opacity[0], 
  ClippingStyle -> Automatic,
  DataReversed -> {True, False},
  Mesh -> None,
  Frame -> True,
  PlotTheme -> "Web", 
  FrameTicksStyle -> {{{Black, sizeFontSmall, Opacity[1]}, None},
                      {{Black, sizeFontSmall, Opacity[1]}, None}}};


Begin["`Private`"] (* Begin private context *)

medianQuantile[data_] := 
 Table[Around[
   Median[data[[i, All]]], {Abs[
     Median[data[[i, All]]] - Quantile[data[[i, All]], 0.025]], 
    Abs[Quantile[data[[i, All]], 0.975] - 
      Median[data[[i, All]]]]}], {i, 1, Dimensions[data][[1]]}]


End[] (* End private context *)


EndPackage[]