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

import matplotlib.pyplot
from matplotlib.ticker import PercentFormatter
import math

def graphDataGramacyLee(n) :
    """Computes n+1 points along the Gramacy and Lee
    function.

    Keyword arguments:
    n - One less than the number of points.
    """
    xVals = getXAxis(0.5, 2.5, n)
    f = [ math.sin(10*math.pi*x)/(2*x) + (x-1)**4 for x in xVals ]
    return xVals, f

def graphDataForrester(n) :
    """Computes n+1 points along the Forrester et al
    function.

    Keyword arguments:
    n - One less than the number of points.
    """
    xVals = getXAxis(0.0, 1.0, n)
    f = [ (6*x-2)**2 * math.sin(12*x-4) for x in xVals ]
    return xVals, f

def graphDataLowFidelityForrester(n) :
    """Computes n+1 points along the lower fidelity version of
    Forrester et al function.

    Keyword arguments:
    n - One less than the number of points.
    """
    xVals, f = graphDataForrester(n)
    g = [ 0.5 * f[i] + 10 * (x - 0.5) + 5 for i, x in enumerate(xVals) ]
    return xVals, g
    
def getXAxis(a, b, n) :
    """Computes n+1 points along the x axis beginning at x=a,
    and ending at x=b.

    Ketword arguments:
    a - The left most value of x.
    b - The right most value of x.
    n - One less than the number of points.
    """
    xVals = [ a ]
    inc = (b-a)/n
    last = a
    for i in range(n-1) :
        last += inc
        xVals.append(last)
    xVals.append(b)
    return xVals

if __name__ == "__main__" :

    n = 100
    
    xVals1, f1 = graphDataForrester(n)
    xVals2, f2 = graphDataLowFidelityForrester(n)
    xVals3, g = graphDataGramacyLee(n)
    
    w = 3.49
    h = w * 0.75
    matplotlib.pyplot.rc('font', size=9)
    matplotlib.pyplot.rc('text', usetex=True)
    fig, ax = matplotlib.pyplot.subplots(figsize=(w,h), constrained_layout=True)
    matplotlib.pyplot.xlabel('x')
    matplotlib.pyplot.ylabel('f(x)')
    line, = ax.plot(xVals1, f1, '-k')
    matplotlib.pyplot.savefig("data/f1-graph.svg")
    matplotlib.pyplot.savefig("data/f1-graph.eps")

    matplotlib.pyplot.rc('font', size=9)
    matplotlib.pyplot.rc('text', usetex=True)
    fig, ax = matplotlib.pyplot.subplots(figsize=(w,h), constrained_layout=True)
    matplotlib.pyplot.xlabel('x')
    matplotlib.pyplot.ylabel('f(x)')
    line, = ax.plot(xVals2, f2, '-k')
    matplotlib.pyplot.savefig("data/f2-graph.svg")
    matplotlib.pyplot.savefig("data/f2-graph.eps")

    matplotlib.pyplot.rc('font', size=9)
    matplotlib.pyplot.rc('text', usetex=True)
    fig, ax = matplotlib.pyplot.subplots(figsize=(w,h), constrained_layout=True)
    matplotlib.pyplot.xlabel('x')
    matplotlib.pyplot.ylabel('g(x)')
    line, = ax.plot(xVals3, g, '-k')
    matplotlib.pyplot.savefig("data/g-graph.svg")
    matplotlib.pyplot.savefig("data/g-graph.eps")

