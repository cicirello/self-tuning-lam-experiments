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

import statistics
import sys
import scipy.stats

class TimeDataPoint :
    """Summarizes the data associated with one run length."""
    
    __slots__ = ['cpu1', 'cpu2']

    def __init__(self, t1, t2) :
        """Initializes a TimeDataPoint object with the first data point.
        Keyword arguments:
        t1 - CPU time in nanoseconds for algorithm 1.
        t2 - CPU time in nanoseconds for algorithm 2.
        """
        self.cpu1 = [ t1 / 1000000000 ]
        self.cpu2 = [ t2 / 1000000000 ]

    def addDataPoint(self, t1, t2) :
        """Adds another data point.
        Keyword arguments:
        t1 - CPU time in nanoseconds for algorithm 1.
        t2 - CPU time in nanoseconds for algorithm 2.
        """
        self.cpu1.append(t1 / 1000000000)
        self.cpu2.append(t2 / 1000000000)

if __name__ == "__main__" :
    datafile = sys.argv[1]
    
    lengthMap = {}
    with open(datafile, 'r') as f :
        f.readline()
        for line in f :
            if line.startswith("Experiment") :
                break
            values = line.split()
            key = int(values[0])
            cpu1 = int(values[1])
            cpu2 = int(values[2])
            if key in lengthMap :
                lengthMap[key].addDataPoint(cpu1, cpu2)
            else :
                lengthMap[key] = TimeDataPoint(cpu1, cpu2)
    print("Statistical Analysis:", datafile)
    print("{0:7s}\t{1}\t{2}\t{3}\t{4}\t{5}\t{6}\t{7}".format(
        "Length",
        "muT1",
        "muT2",
        "devT1",
        "devT2",
        "N",
        "t-cpu",
        "P-cpu"))
    outputTemplate = "{0:7d}\t{1:.5f}\t{2:.5f}\t{3:.5f}\t{4:.5f}\t{5:3d}\t{6:.2f}\t{7:.2g}"
    for key in sorted(lengthMap.keys()) : 
        muCpu1 = statistics.mean(lengthMap[key].cpu1)
        muCpu2 = statistics.mean(lengthMap[key].cpu2)
        if muCpu1 >= 1E-10 and muCpu2 >= 1E-10 :
            stdevCpu1 = statistics.stdev(lengthMap[key].cpu1)
            stdevCpu2 = statistics.stdev(lengthMap[key].cpu2)
            n = len(lengthMap[key].cpu1)
            cpuTTest = scipy.stats.ttest_ind_from_stats(
                mean1=muCpu1,
                std1=stdevCpu1,
                nobs1=n,
                mean2=muCpu2,
                std2=stdevCpu2,
                nobs2=n,
                equal_var=False)
            print(outputTemplate.format(
                key,
                muCpu1,
                muCpu2,
                stdevCpu1,
                stdevCpu2,
                n,
                cpuTTest.statistic,
                cpuTTest.pvalue))

