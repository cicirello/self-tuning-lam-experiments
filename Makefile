ifeq ($(OS),Windows_NT)
	py = "python"
else
	py = "python3"
endif

JARFILE = "target/variations-on-lam-annealing-1.0.0-jar-with-dependencies.jar"
pathToDataFiles = "data/"

.PHONY: build
build:
	mvn clean package

.PHONY: porcupine
porcupine:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine > porcupine.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 10000 > porcupine.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 100000 > porcupine.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPorcupine 1000000 > porcupine.1000k.1.txt

.PHONY: analysisPorcupine
analysisPorcupine:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine.1k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine.10k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine.100k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}porcupine.1000k.1.txt
	
.PHONY: plateaus
plateaus:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus > plateaus.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 10000 > plateaus.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 100000 > plateaus.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingPlateaus 1000000 > plateaus.1000k.1.txt

.PHONY: analysisPlateaus
analysisPlateaus:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus.1k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus.10k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus.100k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}plateaus.1000k.1.txt

.PHONY: trap
trap:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap > trap.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 10000 > trap.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 100000 > trap.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTrap 1000000 > trap.1000k.1.txt

.PHONY: analysisTrap
analysisTrap:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap.1k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap.10k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap.100k.1.txt
	$(py) src/analysis/AcceptanceRateStatsFloatingPoint.py ${pathToDataFiles}trap.1000k.1.txt

.PHONY: twomax
twomax:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax > twomax.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 10000 > twomax.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 100000 > twomax.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingTwoMax 1000000 > twomax.1000k.1.txt

.PHONY: analysisTwomax
analysisTwomax:
	$(py) -m pip install --user pycairo
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax.1k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax.10k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax.100k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}twomax.1000k.1.txt

.PHONY: onemax
onemax: onemax.1k.1.txt onemax.10k.1.txt onemax.100k.1.txt onemax.1000k.1.txt onemax.1k.10.txt onemax.10k.10.txt onemax.100k.10.txt onemax.1000k.10.txt 
	
.PHONY: analysisOnemax
analysisOnemax:
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.1k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.10k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.100k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.1000k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.1k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.10k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.100k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}onemax.1000k.10.txt
	
onemax.1k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax > onemax.1k.1.txt

onemax.10k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 > onemax.10k.1.txt

onemax.100k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 > onemax.100k.1.txt
	
onemax.1000k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 > onemax.1000k.1.txt

onemax.1k.10.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 10 > onemax.1k.10.txt

onemax.10k.10.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 10 > onemax.10k.10.txt

onemax.100k.10.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 10 > onemax.100k.10.txt

onemax.1000k.10.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 10 > onemax.1000k.10.txt
	

	
.PHONY: clean
clean:
	mvn clean