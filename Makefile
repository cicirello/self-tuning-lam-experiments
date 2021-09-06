ifeq ($(OS),Windows_NT)
	py = "python"
else
	py = "python3"
endif

JARFILE = "target/self-tuning-lam-experiments-1.0.0-jar-with-dependencies.jar"
pathToDataFiles = "data/"

.PHONY: build
build:
	mvn clean package

# Generates special figures for paper

.PHONY: specialFigures
specialFigures:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/GraphContinuousFunctions.py
	$(py) src/analysis/GraphLamRate.py

# Runs all experiments

.PHONY: experiments
experiments: experimentsContinuous experiments256

.PHONY: analysis
analysis: analysisContinuous analysis256

# Runs all continuous optimization problems

.PHONY: experimentsContinuous
experimentsContinuous: GL F1 F2

.PHONY: analysisContinuous
analysisContinuous: analysisGL analysisF1 analysisF2

# Runs Forrester Lower Fidelity

.PHONY: F2
F2:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1 2 > F2.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1 2 > F2.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1 2 > F2.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1 2 > F2.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 10 2 > F2.1k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 10 2 > F2.10k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 10 2 > F2.100k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 10 2 > F2.1000k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 100 2 > F2.1k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 100 2 > F2.10k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 100 2 > F2.100k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 100 2 > F2.1000k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1000 2 > F2.1k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1000 2 > F2.10k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1000 2 > F2.100k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1000 2 > F2.1000k.1000.txt

.PHONY: analysisF2
analysisF2:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1k.1.txt > F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.10k.1.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.100k.1.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1000k.1.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1k.10.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.10k.10.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.100k.10.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1000k.10.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1k.100.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.10k.100.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.100k.100.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1000k.100.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1k.1000.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.10k.1000.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.100k.1000.txt >> F2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F2.1000k.1000.txt >> F2.summary.data.txt

# Runs Forrester Original

.PHONY: F1
F1:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1 1 > F1.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1 1 > F1.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1 1 > F1.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1 1 > F1.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 10 1 > F1.1k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 10 1 > F1.10k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 10 1 > F1.100k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 10 1 > F1.1000k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 100 1 > F1.1k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 100 1 > F1.10k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 100 1 > F1.100k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 100 1 > F1.1000k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1000 1 > F1.1k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1000 1 > F1.10k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1000 1 > F1.100k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1000 1 > F1.1000k.1000.txt

.PHONY: analysisF1
analysisF1:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1k.1.txt > F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.10k.1.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.100k.1.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1000k.1.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1k.10.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.10k.10.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.100k.10.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1000k.10.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1k.100.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.10k.100.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.100k.100.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1000k.100.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1k.1000.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.10k.1000.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.100k.1000.txt >> F1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}F1.1000k.1000.txt >> F1.summary.data.txt

# Runs gramacylee

.PHONY: GL
GL:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1 0 > gramacylee.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1 0 > gramacylee.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1 0 > gramacylee.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1 0 > gramacylee.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 10 0 > gramacylee.1k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 10 0 > gramacylee.10k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 10 0 > gramacylee.100k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 10 0 > gramacylee.1000k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 100 0 > gramacylee.1k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 100 0 > gramacylee.10k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 100 0 > gramacylee.100k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 100 0 > gramacylee.1000k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000 1000 0 > gramacylee.1k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 10000 1000 0 > gramacylee.10k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 100000 1000 0 > gramacylee.100k.1000.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingContinuousProblems 1000000 1000 0 > gramacylee.1000k.1000.txt

.PHONY: analysisGL
analysisGL:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1k.1.txt > gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.10k.1.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.100k.1.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1000k.1.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1k.10.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.10k.10.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.100k.10.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1000k.10.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1k.100.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.10k.100.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.100k.100.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1000k.100.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1k.1000.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.10k.1000.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.100k.1000.txt >> gramacylee.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsContinuousProblems.py ${pathToDataFiles}gramacylee.1000k.1000.txt >> gramacylee.summary.data.txt
	
# Run all with fixed length, 256-bit, strings regardless of run length.
# Note that HollandRoyalRoad is actually with 240-bit strings.

.PHONY: experiments256
experiments256: onemax256 twomax256 trap256 porcupine256 plateaus256 mix256 royal256 holland240

.PHONY: analysis256
analysis256: analysisOnemax256 analysisTwomax256 analysisTrap256 analysisPorcupine256 analysisPlateaus256 analysisMix256 analysisRoyal256 analysisHolland240

# Targets for experiments with fixed length, 256-bit, bit vectors regardless of run length.
# Note that HollandRoyalRoad is actually with 240-bit strings.

.PHONY: holland240
holland240:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingHolland 1000 > holland240.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingHolland 10000 > holland240.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingHolland 100000 > holland240.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingHolland 1000000 > holland240.1000k.1.txt

.PHONY: analysisHolland240
analysisHolland240:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}holland240.1k.1.txt > holland240.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}holland240.10k.1.txt >> holland240.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}holland240.100k.1.txt >> holland240.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}holland240.1000k.1.txt >> holland240.summary.data.txt

.PHONY: royal256
royal256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 1000 false > R1.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 10000 false > R1.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 100000 false > R1.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 1000000 false > R1.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 1000 true > R2.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 10000 true > R2.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 100000 true > R2.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingRoyalRoads 1000000 true > R2.1000k.1.txt

.PHONY: analysisRoyal256
analysisRoyal256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R1.1k.1.txt > R1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R1.10k.1.txt >> R1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R1.100k.1.txt >> R1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R1.1000k.1.txt >> R1.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R2.1k.1.txt > R2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R2.10k.1.txt >> R2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R2.100k.1.txt >> R2.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}R2.1000k.1.txt >> R2.summary.data.txt
	
.PHONY: mix256
mix256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingMix 1000 fixed > mix256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingMix 10000 fixed > mix256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingMix 100000 fixed > mix256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingMix 1000000 fixed > mix256.1000k.1.txt

.PHONY: analysisMix256
analysisMix256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}mix256.1k.1.txt > mix256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}mix256.10k.1.txt >> mix256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}mix256.100k.1.txt >> mix256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}mix256.1000k.1.txt >> mix256.summary.data.txt

.PHONY: porcupine256
porcupine256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 1000 fixed > porcupine256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 10000 fixed > porcupine256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 100000 fixed > porcupine256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 1000000 fixed > porcupine256.1000k.1.txt

.PHONY: analysisPorcupine256
analysisPorcupine256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine256.1k.1.txt > porcupine256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine256.10k.1.txt >> porcupine256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine256.100k.1.txt >> porcupine256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine256.1000k.1.txt >> porcupine256.summary.data.txt
	
.PHONY: plateaus256
plateaus256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 1000 fixed > plateaus256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 10000 fixed > plateaus256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 100000 fixed > plateaus256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 1000000 fixed > plateaus256.1000k.1.txt

.PHONY: analysisPlateaus256
analysisPlateaus256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus256.1k.1.txt > plateaus256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus256.10k.1.txt >> plateaus256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus256.100k.1.txt >> plateaus256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus256.1000k.1.txt >> plateaus256.summary.data.txt

.PHONY: trap256
trap256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 1000 fixed > trap256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 10000 fixed > trap256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 100000 fixed > trap256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 1000000 fixed > trap256.1000k.1.txt

.PHONY: analysisTrap256
analysisTrap256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap256.1k.1.txt > trap256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap256.10k.1.txt >> trap256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap256.100k.1.txt >> trap256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap256.1000k.1.txt >> trap256.summary.data.txt

.PHONY: twomax256
twomax256:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 1000 fixed > twomax256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 10000 fixed > twomax256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 100000 fixed > twomax256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 1000000 fixed > twomax256.1000k.1.txt

.PHONY: analysisTwomax256
analysisTwomax256:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax256.1k.1.txt > twomax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax256.10k.1.txt >> twomax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax256.100k.1.txt >> twomax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax256.1000k.1.txt >> twomax256.summary.data.txt

.PHONY: onemax256
onemax256: 
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 1 fixed > onemax256.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 1 fixed > onemax256.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 1 fixed > onemax256.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 1 fixed > onemax256.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 10 fixed > onemax256.1k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 10 fixed > onemax256.10k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 10 fixed > onemax256.100k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 10 fixed > onemax256.1000k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 100 fixed > onemax256.1k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 100 fixed > onemax256.10k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 100 fixed > onemax256.100k.100.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 100 fixed > onemax256.1000k.100.txt
		
.PHONY: analysisOnemax256
analysisOnemax256:
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1k.1.txt > onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.10k.1.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.100k.1.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1000k.1.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1k.10.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.10k.10.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.100k.10.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1000k.10.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1k.100.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.10k.100.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.100k.100.txt >> onemax256.summary.data.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax256.1000k.100.txt >> onemax256.summary.data.txt


	
.PHONY: clean
clean:
	mvn clean