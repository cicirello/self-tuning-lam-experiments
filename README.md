# self-tuning-lam-experiments

Copyright &copy; 2021 Vincent A. Cicirello

This repository contains code to reproduce the experiments, and analysis of 
experimental data, from the following paper:

> Vincent A. Cicirello. 2021. Self-Tuning Lam Annealing: Learning Hyperparameters While Problem Solving. *Applied Sciences*, 11, 21, Article 9828 (November 2021). https://doi.org/10.3390/app11219828 

| __Related Publication__ | [![DOI](doi.svg)](https://doi.org/10.3390/app11219828) |
| :--- | :--- |
| __Source Info__ | [![GitHub](https://img.shields.io/github/license/cicirello/self-tuning-lam-experiments)](LICENSE) |
| __Packages and Releases__ | [![Maven Central](https://img.shields.io/maven-central/v/org.cicirello/self-tuning-lam-experiments.svg?label=Maven%20Central)](https://search.maven.org/artifact/org.cicirello/self-tuning-lam-experiments) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/cicirello/self-tuning-lam-experiments?logo=GitHub)](https://github.com/cicirello/self-tuning-lam-experiments/releases) |

## Requirements to Build and Run the Experiments

To build and run the experiments on your own machine, you will need the following:
* __JDK 11__: I used OpenJDK 11, but you should be fine with Oracle's 
  JDK as well. Technically, there is nothing in the code that strictly 
  requires Java 11, so you should be able to build and run with JDK 8 
  or later. However, the Maven pom.xml provided in the repository assumes 
  Java 11. Also, if you want to recreate the experiments in as similar an 
  environment as used in the reported results, then you should use Java 11.
* __Apache Maven__: In the root of the repository, there is a `pom.xml` 
  for building the Java programs for the experiments. Using this `pom.xml`, 
  Maven will take care of downloading the exact version of 
  the [Chips-n-Salsa](https://chips-n-salsa.cicirello.org/) library that was 
  used in the experiments (release 2.12.1), as well as Chips-n-Salsa's 
  dependencies. 
* __Python 3__: The repository contains Python programs that were used to 
  compute summary statistics, statistical significance tests, and to generate
  graphs for the figures of the paper. If you want to run the Python programs, 
  you will need Python 3. I specifically used Python 3.9.6. You also need scipy 
  and matplotlib installed.
* __Make__: The repository contains a Makefile to simplify running the build, 
  running the experiment's Java programs, and running the Python program to 
  analyze the data. If you are familiar with using the Maven build tool, 
  and running Python programs, then you can just run these directly, although 
  the Makefile may be useful to see the specific commands needed.

## Building the Java Programs (Optiom 1)

The source code of the Java programs, implementing the experiments
is in the [src/main](src/main) directory.  You can build the experiment 
programs in one of the following ways.

__Using Maven__: Execute the following from the root of the
repository.

```shell
mvn clean package
```

__Using Make__: Or, you can execute the following from the root
of the repository.

```shell
make build
```

This produces a jar file containing 10 Java programs for running 
different parts of the experiments. The jar also contains all
dependencies, including the Chips-n-Salsa library and its dependencies.
If you are unfamiliar with the usual structure of the directories of 
a Java project built with Maven, the `.class` files, the `.jar` file, 
etc will be found in a `target` directory that is created by the 
build process.

## Downloading a prebuilt jar (Option 2)

As an alternative to building the jar (see above), you can choose to instead
download a prebuilt jar of the experiments from the Maven Central repository.
The Makefile contains a target that will do this for you, provided that you have
curl installed on your system. To download the jar of the precompiled code of 
the experiments, run the following from the root of the repository:

```shell
make download
```

The jar that it downloads contains the compiled code of the experiments as well
as all dependencies, which would include the version of Chips-n-Salsa originally used
for the paper, as well as its dependencies, all within a single jar file.

## Running the Experiments

You must first either follow the build instructions or download a prebuilt jar (see above
sections). Once the jar of the experiments is either built or downloaded, you can then run 
the experiments with the following executed at the root of the repository:

```shell
make experiments
```

This will run each of the experiment programs in sequence, 
with the results piped to text files in the root of the project. The 
output from my runs are found in the [/data](data) directory. Be aware that
running all of the experiments will take quite a bit of time.

There are also several other targets in the Makefile if you wish to 
run only some of the experiments from the paper. See the Makefile for
details.

## Analyzing the Experimental Data

To run the Python program that I used to generate summary statistics, run 
significance tests, and generate the graphs for the figures frmo the paper,
you need Python 3 installed. The source code of the Python programs is 
found in the [src/analysis](src/analysis) directory.  To run the analysis
execute the following at the root of the repository:

```shell
make analysis
```

This will analyze the data from my runs in the [/data](data) directory.
If you want to analyze the data from your runs instead, then change the variable
`pathToDataFiles = ""` in the `Makefile`. This make command will also take
care of installing any required Python packages if you don't already have them
installed, such as matplotlib and scipy.

## Other Files in the Repository

There are a few other files, potentially of interest, in the repository,
which include:
* `system-stats.txt`: This file contains details of the system I 
  used to run the experiments, such as operating system, processor 
  specs, Java JDK and VM. It is in the [/data](data) directory.
