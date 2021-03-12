ifeq ($(OS),Windows_NT)
	py = "python"
else
	py = "python3"
endif

JARFILE = "target/variations-on-lam-annealing-1.0.0-jar-with-dependencies.jar"

.PHONY: build
build:
	mvn clean package
	
.PHONY: experiments
experiments: onemax.1k.1.txt onemax.10k.1.txt onemax.100k.1.txt onemax.1k.2.txt onemax.10k.2.txt onemax.100k.2.txt onemax.1k.3.txt onemax.10k.3.txt onemax.100k.3.txt onemax.1000k.1.txt
	
.PHONY: analysis
analysis:
	$(py) -m pip install --user scipy
	$(py) src/analysis/AcceptanceRateStats.py onemax.1k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.10k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.100k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.1000k.1.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.1k.2.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.10k.2.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.100k.2.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.1k.3.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.10k.3.txt
	$(py) src/analysis/AcceptanceRateStats.py onemax.100k.3.txt

onemax.1k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax > onemax.1k.1.txt

onemax.10k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 > onemax.10k.1.txt

onemax.100k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 > onemax.100k.1.txt
	
onemax.1000k.1.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 > onemax.1000k.1.txt

onemax.1k.2.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 2 > onemax.1k.2.txt

onemax.10k.2.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 2 > onemax.10k.2.txt

onemax.100k.2.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 2 > onemax.100k.2.txt

onemax.1000k.2.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000000 2 > onemax.1000k.2.txt
	
onemax.1k.3.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 1000 3 > onemax.1k.3.txt

onemax.10k.3.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 10000 3 > onemax.10k.3.txt

onemax.100k.3.txt:
	java -cp ${JARFILE} org.cicirello.experiments.variationsoflam.LamTrackingOneMax 100000 3 > onemax.100k.3.txt

	
.PHONY: clean
clean:
	mvn clean