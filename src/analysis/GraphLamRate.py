# Experiments with the Self-Tuning Lam Annealing Schedule.
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

import matplotlib.pyplot
from matplotlib.ticker import PercentFormatter

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
    for i in range(len(data)//numPoints-1, len(data), len(data)//numPoints) :
        sampled.append(data[i])
    return sampled

if __name__ == "__main__" :

    target, xVals = targetAcceptanceRate(1000)
    target = sampleDataAlongTimeAxis(target, 200)
    xVals = sampleDataAlongTimeAxis(xVals, 200)

    w = 3.49
    h = w * 0.75
    matplotlib.pyplot.rc('font', size=9)
    matplotlib.pyplot.rc('text', usetex=True)
    fig, ax = matplotlib.pyplot.subplots(figsize=(w,h), constrained_layout=True)
    ax.xaxis.set_major_formatter(PercentFormatter(xmax=1))
    matplotlib.pyplot.xlabel('percent of run')
    matplotlib.pyplot.ylabel('acceptance rate')
    line, = ax.plot(xVals[0:201:2], target[0:201:2], '-k', label='Lam acceptance rate')
    matplotlib.pyplot.savefig("data/TargetRate.svg")
    matplotlib.pyplot.savefig("data/TargetRate.eps")

