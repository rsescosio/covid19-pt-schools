BeginPackage["preliminaries`"]

importExportScenarioResults[labelPrefix_, dataFunction_, subFolder_] :=
  Table[Module[{filePath, state},
    filePath = 
     FileNameJoin[{"../results"}, 
      StringJoin["/", subFolder, "/", labelPrefix, "_", scenarios[[i]],
        ".wxf"]];
    If[FileExistsQ[filePath],
     state = Import[filePath, "WXF"];
     state,
     state = dataFunction[i];
     Export[filePath, state, "WXF", "CompressionLevel" -> 5];
     state]],
   {i, 1, Length[scenarios]}];

exportFigs[figs_, filename_, forcetrue_ : False] := {
   If[ifShowFigs, Print[figs]];
   If[ifExportFigs || forcetrue, 
    Table[Export[StringJoin["../figures/", filename, exportFormat[[i]]],
       figs], {i, 1, Length[exportFormat]}]]};

getStats4Hosp[medianMatrix_, quantilesMatrix_, 
   index2GetMeasures_ : 2] :=
  Module[{med1, med2, low2, high2},
   med1 = Map[Median, medianMatrix, {index2GetMeasures}];
   med2 = Map[Median, quantilesMatrix, {index2GetMeasures}];
   low2 = 
    Map[Quantile[#, 0.025] &, quantilesMatrix, {index2GetMeasures}];
   high2 = 
    Map[Quantile[#, 0.975] &, quantilesMatrix, {index2GetMeasures}];
   {med1, med2, low2, high2}];

transformToAround[matrix_, dim_ : 3] := 
 MapThread[
  Around[#1, {#2 - #3, #4 - #2}] &, {matrix[[1]], matrix[[2]], 
   matrix[[3]], matrix[[4]]}, dim]

getRelChange4Hosp[medianMatrix_, quantilesMatrix_, scenario_ : 1] :=
  Module[{medMat, quantMat, idxbase, idxscen, idxdate},
   Which[scenario == 1,
    idxbase = 1; idxscen = 2; idxdate = 1;,
    scenario == 2,
    idxbase = 1; idxscen = 3; idxdate = 2;];
   medMat = 
    Table[
     100 (medianMatrix[[idxscen, i, All, idxdate]] - 
         medianMatrix[[idxbase, i, All, idxdate]])/
       Max[medianMatrix[[idxbase, i, All, idxdate]], 0.0001], {i, 1, 
      Dimensions[medianMatrix][[2]]}];
   quantMat = 
    Table[100 (quantilesMatrix[[idxscen, i, All, idxdate]] - 
         quantilesMatrix[[idxbase, i, All, idxdate]])/
       Max[quantilesMatrix[[idxbase, i, All, idxdate]], 0.0001], {i, 
      1, Dimensions[quantilesMatrix][[2]]}];
   transformToAround[getStats4Hosp[medMat, quantMat, 1], 1]];

getAround[DATA_] :=
   Around[
   Median[DATA], {Median[DATA] - Quantile[DATA, 0.025], 
    Quantile[DATA, 0.975] - Median[DATA]}];
    
relativeChangeAround[DATA_] := 
  Table[getAround[
    100 (DATA[[i, 2]] - DATA[[i, 1]])/Max[DATA[[i, 1]], 0.0001]],
   {i, 1, Dimensions[DATA][[1]]}];

EndPackage[]