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

import statistics
import scipy.stats
import scipy.spatial.distance
import sys
import math
import matplotlib.pyplot
from matplotlib.ticker import PercentFormatter
from collections import deque

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
    return track, [i/runLength for i in range(1,runLength+1)]

def dataFilenameToFigureFilename(datafile) :
    """Generates the name for the output file containing the
    graph of the data.

    Keyword arguments:
    datafile - The data file including path
    """
    figureFilename = datafile + ".svg" if datafile[-4:] != ".txt" else datafile[:-4] + ".svg"
    return figureFilename

def sampleDataAlongTimeAxis(data, numPoints=100) :
    """The raw data has samples of the acceptance rate at
    each iteration, so for long runs, has a huge number of
    points along the time axis, extremely difficult to plot
    in a clear and easy to interpret manner. This function
    samples at equal intervals along the time axis to deal
    with this.

    Keyword arguments:
    data - the data
    numPoints - the number of points along time axis to sample, equally distant
    """
    sampled = [data[0]]
    for i in range(len(data)//numPoints, len(data), len(data)//numPoints) :
        sampled.append(data[i])
    return sampled

def medianSmoothing(data, k) :
    """Smooths the data with k-median smoothing.

    Keyword arguments:
    data - a list of the data
    k - to indicate size of smoothing window, assumed by code here to be odd
    """
    skip = k // 2
    window = deque(data[:k])
    for i in range(skip, len(data)-skip) :
        data[i] = statistics.median(window)
        window.popleft()
        j = i + skip + 1
        if j < len(data) :
            window.append(data[j])
    for i in range(skip) :
        data[i] = None
        data[-i-1] = None

if __name__ == "__main__" :
    datafile = sys.argv[1]
    numRuns = int(sys.argv[2]) if len(sys.argv) > 2 else 100

    figureFilename = dataFilenameToFigureFilename(datafile)

    runLength, scale = parseFilename(datafile)
    algNames, costs, rates = extractRawData(datafile, runLength, numRuns)

    print("Statistical Analysis of End of Run Costs")
    print("Run Length (in SA iterations):", runLength)
    print("Cost function scale factor:", scale)
    print()
    print("{8:9} {0:9} {1:>8} {2:>8} {3:8} {4:>8} {5:>8} {6:>8} {7:>20}".format(
        "Schedule1",
        "Mean",
        "StDev",
        "Schedule2",
        "Mean",
        "StDev",
        "t-stat",
        "P-value",
        "Measure"
        ))
    outputTemplate = "{8:9} {0:9} {1:8.2f} {2:8.2f} {3:9} {4:8.2f} {5:8.2f} {6:8.2f} {7:20}"        
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
                t.pvalue,
                "CostFunc"))

    print()
    target, xVals = targetAcceptanceRate(runLength)
    target = sampleDataAlongTimeAxis(target, 200)
    xVals = sampleDataAlongTimeAxis(xVals, 200)
    for i in range(len(algNames)) :
        rates[i] = sampleDataAlongTimeAxis(rates[i], 200)

    absDiff = [ [math.fabs(target[j]-x) for j, x in enumerate(rates[i])] for i in range(len(algNames)) ]
    sqDiff = [ list(map(lambda x : x*x, absDiff[i])) for i in range(len(algNames)) ]
    t_MAD = scipy.stats.ttest_ind(
        absDiff[0],
        absDiff[1],
        equal_var = False
        )

    t_MSE = scipy.stats.ttest_ind(
        sqDiff[0],
        sqDiff[1],
        equal_var = False
        )

    maxAbsDiff = [ max(absDiff[i]) for i in range(len(algNames)) ]

    outputTemplate = "{8:9} {0:9} {1:8.6f} {2:8.6f} {3:9} {4:8.6f} {5:8.6f} {6:8.2f} {7:20}"        
    print(outputTemplate.format(
        algNames[0],
        statistics.mean(sqDiff[0]),
        statistics.stdev(sqDiff[0]),
        algNames[1],
        statistics.mean(sqDiff[1]),
        statistics.stdev(sqDiff[1]),
        t_MSE.statistic,
        t_MSE.pvalue,
        "MSE"))

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(absDiff[0]),
        statistics.stdev(absDiff[0]),
        algNames[1],
        statistics.mean(absDiff[1]),
        statistics.stdev(absDiff[1]),
        t_MAD.statistic,
        t_MAD.pvalue,
        "MAD"))

    # PHASE 1: first 15% of run
    t_MAD = scipy.stats.ttest_ind(
        absDiff[0][:31],
        absDiff[1][:31],
        equal_var = False
        )

    t_MSE = scipy.stats.ttest_ind(
        sqDiff[0][:31],
        sqDiff[1][:31],
        equal_var = False
        )

    maxAbsDiff = [ max(absDiff[i][:31]) for i in range(len(algNames)) ]

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(sqDiff[0][:31]),
        statistics.stdev(sqDiff[0][:31]),
        algNames[1],
        statistics.mean(sqDiff[1][:31]),
        statistics.stdev(sqDiff[1][:31]),
        t_MSE.statistic,
        t_MSE.pvalue,
        "MSE.ph1"))

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(absDiff[0][:31]),
        statistics.stdev(absDiff[0][:31]),
        algNames[1],
        statistics.mean(absDiff[1][:31]),
        statistics.stdev(absDiff[1][:31]),
        t_MAD.statistic,
        t_MAD.pvalue,
        "MAD.ph1"))

    # PHASE 2: next 50% of run
    t_MAD = scipy.stats.ttest_ind(
        absDiff[0][31:131],
        absDiff[1][31:131],
        equal_var = False
        )

    t_MSE = scipy.stats.ttest_ind(
        sqDiff[0][31:131],
        sqDiff[1][31:131],
        equal_var = False
        )

    maxAbsDiff = [ max(absDiff[i][31:131]) for i in range(len(algNames)) ]

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(sqDiff[0][31:131]),
        statistics.stdev(sqDiff[0][31:131]),
        algNames[1],
        statistics.mean(sqDiff[1][31:131]),
        statistics.stdev(sqDiff[1][31:131]),
        t_MSE.statistic,
        t_MSE.pvalue,
        "MSE.ph2"))

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(absDiff[0][31:131]),
        statistics.stdev(absDiff[0][31:131]),
        algNames[1],
        statistics.mean(absDiff[1][31:131]),
        statistics.stdev(absDiff[1][31:131]),
        t_MAD.statistic,
        t_MAD.pvalue,
        "MAD.ph2"))

    # PHASE 3: last 35% of run
    t_MAD = scipy.stats.ttest_ind(
        absDiff[0][131:],
        absDiff[1][131:],
        equal_var = False
        )

    t_MSE = scipy.stats.ttest_ind(
        sqDiff[0][131:],
        sqDiff[1][131:],
        equal_var = False
        )

    maxAbsDiff = [ max(absDiff[i][131:]) for i in range(len(algNames)) ]

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(sqDiff[0][131:]),
        statistics.stdev(sqDiff[0][131:]),
        algNames[1],
        statistics.mean(sqDiff[1][131:]),
        statistics.stdev(sqDiff[1][131:]),
        t_MSE.statistic,
        t_MSE.pvalue,
        "MSE.ph3"))

    print(outputTemplate.format(
        algNames[0],
        statistics.mean(absDiff[0][131:]),
        statistics.stdev(absDiff[0][131:]),
        algNames[1],
        statistics.mean(absDiff[1][131:]),
        statistics.stdev(absDiff[1][131:]),
        t_MAD.statistic,
        t_MAD.pvalue,
        "MAD.ph3"))

##    print("{0:9} {1:>10} {2:>10} {3:>10} {4:>10} {5:>10} {6:>10} {7:>10} {8:>10} {9:>10} {10:>10} {11:>10} {12:>10}".format( 
##        "Schedule",
##        "maxDiff",
##        "sumDiff",
##        "Euclidean",
##        "maxPh1",
##        "sumPh1",
##        "EuclPh1",
##        "maxPh2",
##        "sumPh2",
##        "EuclPh2",
##        "maxPh3",
##        "sumPh3",
##        "EuclPh3"
##        ))
##    for i in range(len(algNames)) :
##        euc = scipy.spatial.distance.euclidean(target, rates[i])
##        maxPointDist = scipy.spatial.distance.chebyshev(target, rates[i])
##        sumAbsDiff = scipy.spatial.distance.cityblock(target, rates[i])
##        
##        euc1 = scipy.spatial.distance.euclidean(target[:17], rates[i][:17])
##        maxPointDist1 = scipy.spatial.distance.chebyshev(target[:17], rates[i][:17])
##        sumAbsDiff1 = scipy.spatial.distance.cityblock(target[:17], rates[i][:17])
##
##        euc2 = scipy.spatial.distance.euclidean(target[17:67], rates[i][17:67])
##        maxPointDist2 = scipy.spatial.distance.chebyshev(target[17:67], rates[i][17:67])
##        sumAbsDiff2 = scipy.spatial.distance.cityblock(target[17:67], rates[i][17:67])
##
##        euc3 = scipy.spatial.distance.euclidean(target[67:], rates[i][67:])
##        maxPointDist3 = scipy.spatial.distance.chebyshev(target[67:], rates[i][67:])
##        sumAbsDiff3 = scipy.spatial.distance.cityblock(target[67:], rates[i][67:])
##        
##        print("{0:9} {1:10.3f} {2:10.3f} {3:10.3f} {4:10.3f} {5:10.3f} {6:10.3f} {7:10.3f} {8:10.3f} {9:10.3f} {10:10.3f} {11:10.3f} {12:10.3f}".format(
##            algNames[i],
##            maxPointDist,
##            sumAbsDiff,
##            euc,
##            maxPointDist1,
##            sumAbsDiff1,
##            euc1,
##            maxPointDist2,
##            sumAbsDiff2,
##            euc2,
##            maxPointDist3,
##            sumAbsDiff3,
##            euc3
##            ))

    fig, ax = matplotlib.pyplot.subplots()
    ax.xaxis.set_major_formatter(PercentFormatter(xmax=1))
    line, = ax.plot(xVals, target, '-k', label='The target acceptance rate')
    matplotlib.pyplot.xlabel('percent of run')
    matplotlib.pyplot.ylabel('acceptance rate')
    styles = [ ':b', '--r' ]
    for i in range(len(algNames)) :
        if algNames[i] == "MLam" :
            algLabel = "Modified Lam"
        elif algNames[i] == "STLam" :
            algLabel = "Self-Tuning Lam"
        else :
            algLabel = "Unknown"
        line, = ax.plot(xVals, rates[i], styles[i], label="{0} observed acceptance rate".format(algLabel))
    ax.legend()
    matplotlib.pyplot.savefig(figureFilename)

## Previously tried smoothing the data, but this
## is not really necessary if we sample the acceptance rates
## a fixed (100) number of times along time axis, rather than
## at every simulated anneal;ing iteration.
##
##    fig, ax = matplotlib.pyplot.subplots()
##    line, = ax.plot(xVals, target, label='The target acceptance rate')
##    k = 5
##    skip = k // 2
##    xValSmooth = xVals[skip:-skip]
##    for i in range(len(algNames)) :
##        if algNames[i] == "MLam" :
##            algLabel = "Modified Lam"
##        elif algNames[i] == "STLam" :
##            algLabel = "Self-Tuning Lam"
##        else :
##            algLabel = "Unknown"
##        medianSmoothing(rates[i], k)
##        line, = ax.plot(xValSmooth, rates[i][skip:-skip], label="{0} observed acceptance rate".format(algLabel))
##    smoothFilename = figureFilename[:-3] + "smooth.svg"
##    ax.legend()
##    matplotlib.pyplot.savefig(smoothFilename)

    print()
    print()
            
    
    
