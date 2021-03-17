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
	
.PHONY: experiments
experiments: onemax.1k.1.txt onemax.10k.1.txt onemax.100k.1.txt onemax.1000k.1.txt onemax.1k.10.txt onemax.10k.10.txt onemax.100k.10.txt onemax.1000k.10.txt 
	
.PHONY: prelim
prelim:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA > prelim.1k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 10000 > prelim.10k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 100000 > prelim.100k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 1000000 > prelim.1000k.1.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 1000 10 > prelim.1k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 10000 10 > prelim.10k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 100000 10 > prelim.100k.10.txt
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMaxEMA 1000000 10 > prelim.1000k.10.txt

.PHONY: analysis
analysis:
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

.PHONY: prelimAnalysis
prelimAnalysis:
	$(py) -m pip install --user scipy
	$(py) -m pip install --user matplotlib
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.1k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.10k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.100k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.1000k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.1k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.10k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.100k.10.txt
	$(py) src/analysis/AcceptanceRateStats.py ${pathToDataFiles}prelim.1000k.10.txt


	
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