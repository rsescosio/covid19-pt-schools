BeginPackage["preliminaries`"]

importExportScenarioResults[labelPrefix_, dataFunction_, subFolder_] :=
  Table[Module[{filePath, state},
    filePath = 
     FileNameJoin[{"../results"}, 
      StringJoin["/", subFolder, "/", labelPrefix, "_", scenarios[[iScen]],
        ".wxf"]];
    If[FileExistsQ[filePath],
     state = Import[filePath, "WXF"];
     state,
     state = dataFunction[iScen];
     Export[filePath, state, "WXF", "CompressionLevel" -> 5];
     state]],
   {iScen, 1, Length[scenarios]}];

exportFigs[figs_, filename_, forcetrue_ : False] := {
   If[ifShowFigs, Print[figs]];
   If[ifExportFigs || forcetrue, 
    Table[Export[StringJoin["../figures/", filename, exportFormat[[iExpFormat]]],
       figs], {iExpFormat, 1, Length[exportFormat]}]]};

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
     100 (medianMatrix[[idxscen, iDim, All, idxdate]] - 
         medianMatrix[[idxbase, iDim, All, idxdate]])/
       Max[medianMatrix[[idxbase, iDim, All, idxdate]], 0.0001], {iDim, 1, 
      Dimensions[medianMatrix][[2]]}];
   quantMat = 
    Table[100 (quantilesMatrix[[idxscen, iDim, All, idxdate]] - 
         quantilesMatrix[[idxbase, iDim, All, idxdate]])/
       Max[quantilesMatrix[[idxbase, iDim, All, idxdate]], 0.0001], {iDim, 
      1, Dimensions[quantilesMatrix][[2]]}];
   transformToAround[getStats4Hosp[medMat, quantMat, 1], 1]];

getAround[DATAMAT_] :=
   Around[
   Median[DATAMAT], {Median[DATAMAT] - Quantile[DATAMAT, 0.025], 
    Quantile[DATAMAT, 0.975] - Median[DATAMAT]}];
    
relativeChangeAround[DATAMAT_] := 
  Table[getAround[
    100 (DATAMAT[[iDim, 2]] - DATAMAT[[iDim, 1]])/Max[DATAMAT[[iDim, 1]], 0.0001]],
   {iDim, 1, Dimensions[DATAMAT][[1]]}];

EndPackage[]