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

import sys

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

def streamlineFile(filename, runLength) :
    """Keeps 201 samples of Acceptance Rate at equally
    spaced time intervals along the run.

    Keyword arguments:
    filename - the name of the file
    runLength - the length of the runs in the filw
    """
    with open(filename, 'r+') as f :
        replacement = []
        line = f.readline()
        while not line.startswith("Acceptance") :
            replacement.append(line)
            line = f.readline()
        replacement.append(line)
        line = f.readline()
        replacement.append(line)
        skip = runLength // 200
        for count in range(2, runLength+1) :
            line = f.readline()
            if count % skip == 0 :
                replacement.append(line)
        f.seek(0)
        f.truncate()
        f.writelines(replacement)


if __name__ == "__main__" :
    datafile = sys.argv[1]
    runLength, scale = parseFilename(datafile)
    
    streamlineFile(datafile, runLength)
