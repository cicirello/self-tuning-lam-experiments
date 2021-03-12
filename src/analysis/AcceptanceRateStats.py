# Experiments with variations of Lam annealing.
# Copyright (C) 2021  Vincent A. Cicirello
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#

import sklearn.metrics
import statistics
import scipy.stats
import sys
import math

def parseFilename(filename) :
    """Parses the filename to get the run length and
    cost scale factor.

    Keyword arguments:
    filename - The name of the file.
    """
    i = filename.find(".")
    j = filename.find(".", i+1)
    k = filename.find(".", j+1)
    runString = filename[i+1:j]
    if runString == "1k" :
        runLength = 1000
    elif runString == "10k" :
        runLength = 10000
    elif runString == "100k" :
        runLength = 100000
    elif runString == "1000k" :
        runLength = 1000000
    else :
        runLength = None
    scale = int(filename[j+1:k])
    return runLength, scale

def extractRawData(filename, runLength, numRuns=100):
    """Parses the datafile and extracts the raw data
    as Python list objects.

    Keyword arguments:
    filename - The name of the file.
    runLength - The length of the runs represented in the file.
    numRuns - The number of runs in the data file.
    """
    with open(filename, 'r') as f :
        f.readline()
        algNames = f.readline().split()
        costs = [ [] for i in range(len(algNames)) ]
        for i in range(numRuns) :
            samples = f.readline().split()
            for j in range(len(algNames)) :
                costs[j].append(int(samples[j]))
        f.readline()
        rates = [ [] for i in range(len(algNames)) ]
        for i in range(runLength) :
            r = f.readline().split()
            for j in range(len(algNames)) :
                rates[j].append(float(r[j]))

    return algNames, costs, rates

def targetAcceptanceRate(runLength) :
    """Computes the Lam annealing schedule target acceptance rate
    throughout a run of a specified length.

    Keyword arguments:
    runLength - The run length
    """
    phase1 = 0.15 * runLength
    phase2 = 0.65 * runLength
    termPhase1 = 0.56
    multPhase1 = 560 ** (-1.0/phase1)
    multPhase3 = 440 ** (-1.0/(runLength-phase2))
    targetRate = 1.0
    track = []
    for i in range(runLength) :
        j = i + 1
        if j <= phase1 :
            termPhase1 *= multPhase1
            targetRate = 0.44 + termPhase1
        elif j > phase2 :
            targetRate *= multPhase3
        else :
            targetRate = 0.44
        track.append(targetRate)
    return track

if __name__ == "__main__" :
    datafile = sys.argv[1]
    numRuns = int(sys.argv[2]) if len(sys.argv) > 2 else 100

    runLength, scale = parseFilename(datafile)
    algNames, costs, rates = extractRawData(datafile, runLength, numRuns)

    print("Statistical Analysis of End of Run Costs")
    print("Run Length (in SA iterations):", runLength)
    print("Cost function scale factor:", scale)
    print()
    print("{0:9} {1:>8} {2:>8} {3:8} {4:>8} {5:>8} {6:>8} {7:>8}".format(
        "Schedule1",
        "Mean",
        "StDev",
        "Schedule2",
        "Mean",
        "StDev",
        "t-stat",
        "P-value"
        ))
    outputTemplate = "{0:9} {1:8.2f} {2:8.2f} {3:9} {4:8.2f} {5:8.2f} {6:8.2f} {7:8.5f}"        
    for i in range(len(algNames)-1) :
        for j in range(i+1, len(algNames)) :
            t = scipy.stats.ttest_ind(
                costs[i],
                costs[j],
                equal_var = False)

            print(outputTemplate.format(
                algNames[i],
                statistics.mean(costs[i]),
                statistics.stdev(costs[i]),
                algNames[j],
                statistics.mean(costs[j]),
                statistics.stdev(costs[j]),
                t.statistic,
                t.pvalue))

    print()
    target = targetAcceptanceRate(runLength)
    print("{0:9} {1:>5}".format( ##{2:>5} {3:>8}".format(
        "Schedule",
        ##"r",
        "r^2"##,
        ##"P-value"
        ))
    for i in range(len(algNames)) :
        ##corr = scipy.stats.pearsonr(target, rates[i])
        ##corr = scipy.stats.spearmanr(target, rates[i])
        r2 = sklearn.metrics.r2_score(rates[i], target)
        print("{0:9} {1:5.3f}".format( ##{2:5.3f} {3:8.5f}".format(
            algNames[i],
            r2
            ##corr[0],
            ##corr[0]*corr[0],
            ##corr[1]
            ))

    print()
    print()
            
    
    
