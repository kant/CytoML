context("parse workspaces of various flowJo versions ")
library(data.table)
path <- "~/rglab/workspace/CytoML/wsTestSuite"

sink("/dev/null")

test_that("set T value properly through PnE instead of PnR for flog transform when FCS data is log scale",{
  
  wsFile <- file.path(path, "flog_PnE/Liver.wsp")
  
  ws <- openWorkspace(wsFile)
  gs <- parseWorkspace(ws, name = 2, sampNloc = 'sampleNode')
  
  res <- getPopStats(gs[[1]])
  expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 0.015)
  
  
})


test_that("handle the linear transform with maxRange = 0",{
  
  wsFile <- file.path(path, "faultylinearTransform/FlowJo Test.wsp")
  
  ws <- openWorkspace(wsFile)
  gs <- parseWorkspace(ws, name = 1)
  
  res <- getPopStats(gs[[1]])
  expect_equal(res[, xml.freq], res[, openCyto.freq])
  
  
})

test_that("skip ManuallyIncludedSamples",{
  
  wsFile <- file.path(path, "logicle.wsp")
  
  ws <- openWorkspace(wsFile)
  gs <- parseWorkspace(ws, name = 1, path = system.file("extdata", package = "flowCore"))
  
  res <- getPopStats(gs[[1]])
  expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 0.009)
  
  
})

test_that("skip ManuallyIncludedSamples",{
      
      wsFile <- file.path(path, "ManuallyIncludedSamples.wsp")
      
      ws <- openWorkspace(wsFile)
      expect_true(setequal(subset(getSampleGroups(ws), groupName == "Sample")[["sampleID"]], c(1:5, 21:25)))
      gs <- parseWorkspace(ws, name = 3, path = file.path(path), execute = FALSE)
      
      expect_is(gs, "GatingSet")
      
    })

test_that("search reference node for boolean gate ",{
  thisPath <- file.path(path, "searchRefNode")
  wsFile <- file.path(thisPath, "2583-Y-MAL067-FJ.xml")
  ws <- openWorkspace(wsFile)
  gs <- suppressWarnings(parseWorkspace(ws, name="Samples", subset = "1379326.fcs"))
  res <- getPopStats(gs[[1]])
  expect_equal(nrow(res), 235)
  expect_equal(res[-10, xml.freq], res[-10, openCyto.freq], tol = 0.006)
  expect_equal(res[10, openCyto.count], 164)
  
  #skip leaf bool
  gs <- suppressWarnings(parseWorkspace(ws, name="Samples", subset = "1379326.fcs", leaf.bool = F))
  gh <- gs[[1]]
  leaf.bool <- which(sapply(getNodes(gs), function(node)length(getChildren(gh, node))==0&&flowWorkspace:::.isBoolGate(gh,node)))
  res <- getPopStats(gh)
  expect_true(all(is.na(res[leaf.bool,  openCyto.count])))
  expect_equal(res[-leaf.bool, xml.freq], res[-leaf.bool, openCyto.freq], tol = 0.006)
  })

test_that("vertical ellipsoidGate for vX ",{
  thisPath <- file.path(path, "ellipsoid_vertical")
  wsFile <- file.path(thisPath, "20171103.circle.flow.ctl.wsp")
  ws <- openWorkspace(wsFile)
  gs <- suppressWarnings(parseWorkspace(ws, name=1))
  
  res <- getPopStats(gs[[1]])
  
  expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 0.02)
})

test_that("skip gains from FCS for vX ",{
  thisPath <- file.path(path, "no_gains_vX")
  wsFile <- file.path(thisPath, "10-Apr-2017.wsp")
  ws <- openWorkspace(wsFile)
  gs <- suppressWarnings(parseWorkspace(ws, name=2))
  
  res <- getPopStats(gs[[1]])
  
  expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 1e-3)
})

#somehow the latest Rstudio crashes on this particular test case (but not in R console command)
test_that("gate extension ",{
      thisPath <- file.path(path, "gate_extension")
      wsFile <- file.path(thisPath, "02-15-2013 ICS.xml")
      ws <- openWorkspace(wsFile)
      gs <- suppressWarnings(parseWorkspace(ws, name=3))
      
      res <- getPopStats(gs[[1]])[xml.count != -1, ]
      
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 3e-2)
    })


test_that("curlyQuad gate1 ",{
      thisPath <- file.path(path, "gate_extension")
      wsFile <- file.path(thisPath, "VSVG OGH 14OCT15.wsp")
      ws <- openWorkspace(wsFile)
      gs <- suppressWarnings(parseWorkspace(ws, name=2))
      
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 2e-3)
    })

test_that("curlyQuad gate1 ",{
      thisPath <- file.path(path, "curlyQuad/example1")
      wsFile <- file.path(thisPath, "20151208_TBNK_DS.xml")
      ws <- openWorkspace(wsFile)
      gs <- suppressWarnings(parseWorkspace(ws, name=2))
      
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 7e-3)
    })

test_that("curlyQuad gate ",{
      thisPath <- file.path(path, "curlyQuad/example2")
      wsFile <- file.path(thisPath, "20-Apr-2016.wsp")
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name=1)
      
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 1.6e-2)
    })

test_that("EllipsoidGate defined on log-transformed channels ",{
      thisPath <- file.path(path, "ellipsoid_log")
      wsFile <- file.path(thisPath, "xml_spillover2.xml")
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name=1, execute = T, sampNloc = "sampleNode", subset = "spillover_B2.fcs")
        
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.count], res[, openCyto.count], tol = 4e-3)
})

test_that("No gate extension ",{
      thisPath <- file.path(path, "negCoordinates")
      wsFile <- file.path(thisPath, "08-Mar-2016.wsp")
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 1, subset = 1) #default extend_val = 0 will extend the gate  
      res <- getPopStats(gs[[1]])
      expect_gt(res[11, abs(xml.freq - openCyto.freq)], 0.1)
      
      gs <- parseWorkspace(ws, name = 1, extend_val = -2e3)#relax the threshold to disable extension
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 4e-3)
    })


test_that("Time gate ",{
  thisPath <- file.path(path, "flin")
  wsFile <- file.path(thisPath, "A01.wsp")
  ws <- openWorkspace(wsFile)
  gs <- parseWorkspace(ws, name = 1, subset = 1)
  res <- getPopStats(gs[[1]])
  expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 9e-4)
})
test_that("Time gate2--when computed timestep is very different from $TIMESTEP ",{
      thisPath <- file.path(path, "timegate")
      wsFile <- file.path(thisPath, "MX1 Analysis VISC.xml")
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws,name="Group 1",subset=11)
      res <- getPopStats(gs[[1]])[xml.count!=-1,]
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 8e-3)
    })
test_that("Inverse function of flog ",{
      thisPath <- file.path(path, "inverse")
      wsFile <- file.path(thisPath, "Small.xml")
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name=1, emptyValue=FALSE)
      
      gh <- gs[[1]]
      res <- getPopStats(gs[[1]])
      expect_equal(res[, xml.freq], res[, openCyto.freq], tol = 2e-3)
      
      
      trans <- getTransformations(gh)
      inverse <- getTransformations(gh, inverse = T)
      raw <- c(1, 1e2, 1e3,1e5)
      log <- trans[[1]](raw)
      expect_equal(inverse[[1]](log), raw)
      
    })

test_that("v 10.0.6 - vX 1.8",{
      
      thisPath <- file.path(path, "mssm")
      wsFile <- file.path(thisPath, "CFSP_Analysis14.wsp")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = "Bcell", subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = "Bcell", subset = 1, isNcdf = TRUE)
      
      gh <- gs[[1]]
            
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[-1, xml.count], thisCounts[-1, openCyto.count], tol = 3.7e-3)
      
      #test double delimiter issue
      fcsname <- pData(gs)[["name"]]
      fr <- read.FCS(file.path(thisPath, fcsname))
      tmp <- tempdir()
      suppressWarnings(write.FCS(fr, filename = file.path(tmp, fcsname), delimiter = "/"))
      
      expect_error(gs <- parseWorkspace(ws, name = "Bcell", subset = 1, isNcdf = F, path = tmp)
                  , "Empty keyword name") #flowSet
      expect_error(gs <- parseWorkspace(ws, name = "Bcell", subset = 1, isNcdf = T, path = tmp)
          , "Empty keyword name")#ncdfFlowSet
              
      gs <- parseWorkspace(ws, name = "Bcell", subset = 1, isNcdf = T, path = tmp, emptyValue = F)#ncdf
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)            
      expect_equal(thisCounts[-1, xml.count], thisCounts[-1, openCyto.count], tol = 3.7e-3)
      
      gs <- parseWorkspace(ws, name = "Bcell", subset = 1, isNcdf = F, path = tmp, emptyValue = F)#flowSet
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)            
      expect_equal(thisCounts[-1, xml.count], thisCounts[-1, openCyto.count], tol = 3.7e-3)
    })


test_that("v 10.0.7 - vX 20.0 (ellipsoidGate)",{
      
      thisPath <- file.path(path, "bioaster_ellipsoidGate")
      wsFile <- file.path(thisPath, "Matrice 1.wsp")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = "Matrice", subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = "Matrice", subset = 1, isNcdf = TRUE)
      
      gh <- gs[[1]]
     
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 2e-2)
    })

test_that("v 10.0.7 - vX 20.0 (missing_namespace and flin)",{
      
      thisPath <- file.path(path, "missing_namespace")
      wsFile <- file.path(thisPath, "BM_data.xml")
      
      ws <- openWorkspace(wsFile)
      expect_error(gs <- parseWorkspace(ws, name = 1, subset = 1, execute = FALSE)
                    , "*: unknown tranformation type!transforms:linear")
      
      
      wsFile <- file.path(thisPath, "BM_data_corrected.xml")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 1, subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      gh <- gs[[1]]
      trans <- getTransformations(gh, only = F, channel = "all")
      expect_equal(trans[[2]][["name"]], "flowJo_flog")
    })

# invalid xml with Namespace prefix defintion missing #TODO: try to be robust on this kind of xml error
#test_that("v 10.0.7 - vX 20.0 (McGill/BMDCs) linear transformation",{
#      
#      thisPath <- file.path(path, "McGill/BMDCs")
#      wsFile <- file.path(thisPath, "20140124 BMDCs.1.wsp")
#      
#      ws <- openWorkspace(wsFile)
#      gs <- parseWorkspace(ws, name = 3, subset = 1, execute = FALSE)
#      expect_is(gs, "GatingSet")
#      gs <- parseWorkspace(ws, name = 3, subset = 1, isNcdf = TRUE)
#      
#      gh <- gs[[1]]
#      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
#      thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
#      expect_equal(thisCounts, expectCounts)
#    })

test_that("v 10.0.7 - vX 20.0 (McGill/treg) ellipseidGate (biexponential)",{
      
      thisPath <- file.path(path, "McGill/Treg")
      wsFile <- file.path(thisPath, "20131206_Treg.1.ellipseidGate.wsp")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 3, subset = 4, execute = FALSE)
      expect_is(gs, "GatingSet")
      g <- getGate(gs[[1]], "CD4Ellipse")
      #transformed ellipse Gate
      expect_is(g, "polygonGate")
      expect_equal(range(g@boundaries[, "Comp-APC-A"]), c(143.918, 207.082), tol = 1e-6)
      expect_equal(range(g@boundaries[, "SSC-A"]), c(10168.56, 58439.45), tol = 1e-6)
      
      #skip gate transform
      gs <- parseWorkspace(ws, name = 3, subset = 4, execute = FALSE, transform = FALSE)
      g <- getGate(gs[[1]], "CD4Ellipse")
      expect_is(g, "polygonGate")
      #ellipsoidGate should be in 256 * 256 scale
      expect_equal(range(g@boundaries[, "Comp-APC-A"]), c(143.918, 207.082), tol = 1e-6)
      expect_equal(range(g@boundaries[, "SSC-A"]), c(9.930231, 57.069771), tol = 1e-6)
      
      gs <- parseWorkspace(ws, name = 3, subset = 4)
      
      gh <- gs[[1]]
#      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[,xml.freq], thisCounts[,openCyto.freq], tol = 7e-4)
    })

test_that("v 10.0.7 - vX 20.0 (PROVIDE/CyTOF) ellipseidGate (fasinh)",{
      
      thisPath <- file.path(path, "PROVIDE")
      wsFile <- file.path(thisPath, "batch1 local and week 53.wsp")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 1, subset = 3, execute = FALSE, sampNloc = "sampleNode")
      expect_is(gs, "GatingSet")
      
      #won't find the file if $TOT is taken into account(most likely the data provided was wrong)
      expect_warning(expect_error(gs <- parseWorkspace(ws, name = 1, subset = 3, sampNloc = "sampleNode")
                   , "no sample to be added to GatingSet!")
               , "Can't find the FCS")
      
      #relax the rules (shouldn't be doing this, just for the sake of testing)
      gs <- parseWorkspace(ws, name = 1, subset = 3, sampNloc = "sampleNode", additional.keys = NULL)
      
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
      expect_equal(thisCounts[, openCyto.count], thisCounts[, xml.count], tol = 0.04)
      
    })

test_that("v 10.0.7 - vX 20.0 (cytof no compensation)",{
      
      thisPath <- file.path(path, "CyTOF")
      wsFile <- file.path(thisPath, "cytof.wsp")
      
      ws <- openWorkspace(wsFile)
      
      expect_warning(gs <- parseWorkspace(ws, name = 1, path = file.path(path), execute = FALSE), "different gating tree structures")
      
      expect_is(gs, "GatingSet")
#      gh <- gs[[1]]
#      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
#      thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
#      expect_equal(thisCounts, expectCounts)
    })

test_that("v 10.0.7r2 - vX 20.0 (NotNode)",{
      
      thisPath <- file.path(path, "combineNode/NotNode")
      wsFile <- file.path(thisPath, "WSwithNotNodePopulation.wsp")
      
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 1, path = file.path(path), execute = FALSE)
      
      expect_is(gs, "GatingSet")
      gh <- gs[[1]]
      g <- getGate(gh, "CD20+⁻")
      expect_is(g, "booleanFilter")
      expect_equal(g@deparse, "!LIVE/Single Cells/CD45+/CD20+")
      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
      expect_equivalent(thisCounts[,c("xml.count", "node"), with = F], expectCounts[,c("flowJo.count", "node"), with = F])
    })

test_that("v 10.2 - vX 20.0 (AndNode)",{
      
      thisPath <- file.path(path, "combineNode/AndNode")
      wsFile <- file.path(thisPath, "test_gates.wsp")
      
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 1, path = file.path(path), execute = FALSE)
      
      expect_is(gs, "GatingSet")
      
      gh <- gs[[1]]
      g <- getGate(gh, "CD4/CD107+IFNg+IL2+Mip1b+TNF+")
      expect_is(g, "booleanFilter")
      expect_equal(g@deparse, "Lymphocytes/Single Cells/CD3/CD4/CD107&Lymphocytes/Single Cells/CD3/CD4/IFNg&Lymphocytes/Single Cells/CD3/CD4/IL2&Lymphocytes/Single Cells/CD3/CD4/Mip1b&Lymphocytes/Single Cells/CD3/CD4/TNF")
    })

test_that("v 10.0.8r1 - vX 20.0 (OrNode)",{
  
  thisPath <- file.path(path, "combineNode/OrNode")
  wsFile <- file.path(thisPath, "Test_EW.wsp")
  
  ws <- openWorkspace(wsFile)
  
  gs <- parseWorkspace(ws, name = 1, path = file.path(path))
  
  expect_is(gs, "GatingSet")
  gh <- gs[[1]]
  g <- getGate(gh, "CD44+")
  expect_is(g, "booleanFilter")
  expect_equal(g@deparse, "FCS singlets/SSC singlets/Lymphocytes/CD8/F5/Live/Q6: CD44+ , CD62L+|FCS singlets/SSC singlets/Lymphocytes/CD8/F5/Live/Q7: CD44+ , CD62L-")
  
  expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
  thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
  expect_equivalent(thisCounts, expectCounts)
})



test_that("v 10.0.8 - vX 20.0 (slash_issue_vX)",{
      thisPath <- file.path(path, "slash_issue_vX")
      wsFile <- file.path(thisPath, "IFEP004.wsp")
      
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 5, path = file.path(thisPath), execute = T)
      
      expect_is(gs, "GatingSet")
      gh <- gs[[1]]
#      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.count], thisCounts[, openCyto.count], tol = 0.038)
      
      
    })

test_that("v 10.2 - vX 20.0 (EllipsoidGate)",{
      thisPath <- file.path(path, "EllipsoidGate_10.2")
      wsFile <- file.path(thisPath, "mA J21 for HT.wsp")
      
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 2, path = file.path(thisPath), execute = T)
      
      expect_is(gs, "GatingSet")
      gh <- gs[[1]]
#      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.count], thisCounts[, openCyto.count], tol = 0.03)
      
      
    })

test_that("v 7.6.1- win 1.6 (use default biexp trans when channel-specific trans not found within its respective trans group )",{
      
      thisPath <- file.path(path, "GYO")
      wsFile <- file.path(thisPath, "whole blood GYO-0109 050214.wsp")
      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 2, subset = 1, path = thisPath,  execute = FALSE)
      expect_is(gs, "GatingSet")
      
      expect_warning(gs <- parseWorkspace(ws, name = 2, path = thisPath), "Can't find the FCS")
      gh <- gs[[1]]
      
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 5e-3)
    })

test_that("v 7.6.5 - win 1.61 (PBMC)",{
      
      thisPath <- file.path(path, "PBMC/Blomberg")
      wsFile <- file.path(thisPath, "Exp2_Tcell.wsp")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 1, subset = 1, sampNloc = "sampleNode", execute = FALSE)
      expect_is(gs, "GatingSet")
      gs <- parseWorkspace(ws, name = 1, subset = 1, sampNloc = "sampleNode")
      gh <- gs[[1]]
            
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 9e-3)
            
    })

test_that("v 7.6.5 - win 1.61 (sampNloc = 'sampleNode')",{
      
      thisPath <- file.path(path, "Cytotrol/Miami")
      wsFile <- file.path(thisPath, "flowJo/Cytotrol_061112_Tcell.wsp")

      ws <- openWorkspace(wsFile)
      
      gs <- parseWorkspace(ws, name = 1, subset = 1, path = file.path(thisPath,"Tcell"), sampNloc = "sampleNode", execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 1, subset = 1, path = file.path(thisPath,"Tcell"), sampNloc = "sampleNode", isNcdf = TRUE)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 2e-4)
      
    })

#this test case failed on the libxml parsing
# test_that("v 9.0.1 - mac 2.0 (HVTN RV144 -- options = 1)",{
#       
#       thisPath <- file.path(path, "HVTN/RV144")
#       wsFile <- file.path(thisPath, "Batch 1264 RV144.xml")
# 
#       dd <- capture_output(ws <- openWorkspace(wsFile, options = 1))
#       #not sure how to suppress the long stacks of C messages (XML package)      
#       gs <- parseWorkspace(ws, name = 4, subset = 1, execute = FALSE)
#       expect_is(gs, "GatingSet")
#       
#       gs <- parseWorkspace(ws, name = 4, subset = 1, isNcdf = TRUE)
#       gh <- gs[[1]]
#       expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
#       thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
#       expect_equal(thisCounts, expectCounts, tolerance = 1e-5, check.attributes = FALSE)
#       
#     })
# 
test_that("v 9.0.1 - mac 2.0 (HVTN 080-0880)",{
      
      thisPath <- file.path(path, "HVTN/080")
      wsFile <- file.path(thisPath, "080 batch 0880.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 4, subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 4, subset = 1, isNcdf = TRUE)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 2e-3)
      
    })


test_that("v 9.2 - mac 2.0 (ITN029)",{
      
      thisPath <- file.path(path, "ITN029ST")
      wsFile <- file.path(thisPath, "QA_template.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 2, subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 2, subset = 1, isNcdf = TRUE)
      gh <- gs[[1]]
      # expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      # thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
      # expect_equal(thisCounts, expectCounts, check.attributes = FALSE)
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 7e-3)
      
    })
test_that("v 9.4.2 - mac 2.0",{
      
      thisPath <- file.path(path, "PBMC/HIPC_trial")
      wsFile <- file.path(thisPath, "data/HIPC_trial.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 2, subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 2, subset = 1, isNcdf = TRUE)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 5e-3)
      
    })

#1. boolean specification contains double spaces and non-spaces, which leads to the fix that uses boolean operator as delimiter instead of space)
#2. boolean gate refers to the node (AM) that appears both at sibling and children level, which leads to further checking in getRefNodes routines
#3. boolean gate has quotedString which leads to more generic xpath searching for gatePath and trailing space removal.
test_that("v 9.4.4 - mac 2.0 ",{
      
      thisPath <- file.path(path, "JJ")
      wsFile <- file.path(thisPath, "JJ_FlowJo_.xml")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = "Test", subset = 1, execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = "Test", subset = 1)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 2e-2)
      
    })


test_that("v 9.5.2 - mac 2.0",{
      
      thisPath <- file.path(path, "Cytotrol/NHLBI")
      wsFile <- file.path(thisPath, "flowJo/NHLBI.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 2, subset = 1, path = file.path(thisPath,"Bcell"), execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 2, subset = 1, path = file.path(thisPath,"Bcell"), isNcdf = TRUE)
      gh <- gs[[1]]
      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 5e-3)
      
      #create a temp folder and symlink to original files to test the feature of searching sample by keyword $FIL
      # in the use case where the fcs has been modified
      fcs <- list.files(pattern = "fcs", file.path(thisPath, "Bcell"), full = T)[[1]]
      tmp <- tempfile()
      dir.create(tmp)
      newFCS <- file.path(tmp, "test.fcs")
      file.symlink(fcs, newFCS)
      
      gs <- parseWorkspace(ws, name = 2, subset = 1, path = tmp)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 5e-3)
      unlink(tmp,recursive = T)
    })

test_that("v 9.6.3 - mac 2.0 (ignore highValue for FSC/SSC)",{
      
      thisPath <- file.path(path, "roch")
      wsFile <- file.path(thisPath, "PROP_20120118_TPHE.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 1, subset = "Specimen_001_Tube_024.fcs", execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 1, subset = "Specimen_001_Tube_024.fcs", isNcdf = TRUE)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 7e-3)
      
    })

test_that("v 9.7.4 - mac 3.0",{
      thisPath <- file.path(path, "v9.7.4")
      wsFile <- file.path(thisPath, "T1 CHI-002v974.xml")

      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = "CHI-002 PBMC control", subset = "CHI-002 PBMC control_101211.fcs", execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = "CHI-002 PBMC control", subset = "CHI-002 PBMC control_101211.fcs", isNcdf = TRUE)
      gh <- gs[[1]]
      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh, path = "full")[, list(xml.count,openCyto.count, node)]
      expectCounts[flowJo.count ==0, flowJo.count := -1]#fix the legacy counts
      expect_equal(thisCounts, expectCounts, check.attributes = FALSE, tol = 3.3e-3)
    })

test_that("v 9.7.5 - mac 3.0 (no compensation and using calibrationIndex)",{
      thisPath <- file.path(path, "Ragon")
      wsFile <- file.path(thisPath, "neut v non neut v9.xml")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 5, subset = "477889_env_cct_norm_concatenated.txt", execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 5, subset = "477889_env_cct_norm_concatenated.txt", isNcdf = TRUE)
      gh <- gs[[1]]
      expectCounts <- fread(file.path(thisPath, "expectCounts.csv"))      
      thisCounts <- getPopStats(gh)[, list(xml.count,openCyto.count, node)]
      expectCounts[flowJo.count ==0, flowJo.count := -1] #fix the legacy counts
      expect_equal(thisCounts, expectCounts, check.attributes = FALSE, tol = 2e-4)
    })

test_that("v 9.7.5 - mac 3.0 (boolGate that refers to the non-sibling nodes)",{
      thisPath <- file.path(path, "094")
      wsFile <- file.path(thisPath, "1851-M-094.xml")
      
      ws <- openWorkspace(wsFile)
      gs <- parseWorkspace(ws, name = 2, subset = "434713.fcs", execute = FALSE)
      expect_is(gs, "GatingSet")
      
      gs <- parseWorkspace(ws, name = 2, subset = "434713.fcs", isNcdf = TRUE)
      gh <- gs[[1]]
      thisCounts <- getPopStats(gh)
      expect_equal(thisCounts[, xml.freq], thisCounts[, openCyto.freq], tol = 2e-3)
    })



sink()
