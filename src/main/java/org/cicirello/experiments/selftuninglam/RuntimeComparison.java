/*
 * Experiments with the Self-Tuning Lam Annealing Schedule.
 * Copyright (C) 2021  Vincent A. Cicirello
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

package org.cicirello.experiments.selftuninglam;

import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;

import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SelfTuningLam;

/**
 * <p>Driver program for experiment comparing the runtime of 
 * the Modified Lam annealing schedule to the Self-Tuning Lam
 * annealing schedule, where the comparisons are done 
 * independently from simulated annealing. That is, in the 
 * experiment, the annealing schedule object is initialized for a 
 * run length, and then the acceptance decision and annealing 
 * schedule update is called repeatedly the number of
 * times corresponding to the run length for which it was 
 * initialized.</p>
 *
 * <p>The output is formatted in columns as follows:<br>
 * L  cpu1  cpu2<br>
 * where L is the run length, 
 * cpu1 is the cpu time for the Modified Lam schedule,
 * and cpu2 is the cpu time for the Self-Tuning Lam schedule.
 * The cpu times are in nanoseconds.</p>
 *
 * @author <a href=https://www.cicirello.org/ target=_top>Vincent A. Cicirello</a>, 
 * <a href=https://www.cicirello.org/ target=_top>https://www.cicirello.org/</a>
 */
public class RuntimeComparison {
	
	/**
	 * Initializes the Modified Lam schedule, and then repeatedly
	 * calls the method that determines move acceptance and updates the schedule.
	 *
	 * @param runLength The length of one run.
	 *
	 * @return The double returned is the average number of moves accepted during a run. 
	 * The only actual purpose is to produce a result to avoid the JVM from optimizing
	 * away the work we are timing.
	 */
	public static double runModifiedLam(int runLength) {
		ModifiedLam lam = new ModifiedLam();
		long count = 0;
		lam.init(runLength);
		double currentCost = 1000;
		for (int i = 0; i < runLength; i++) {
			double neighborCost = currentCost;
			if (i % 2 == 0) neighborCost = neighborCost + i % 1000;
			else neighborCost = neighborCost - i % 1000;
			if (lam.accept(neighborCost, currentCost)) count = count + 1;
		}
		return 1.0 * count;
	}
	
	/**
	 * Initializes the Self-Tuning Lam schedule, and then repeatedly
	 * calls the method that determines move acceptance and updates the schedule.
	 *
	 * @param runLength The length of one run.
	 *
	 * @return The double returned is the average number of moves accepted during a run. 
	 * The only actual purpose is to produce a result to avoid the JVM from optimizing
	 * away the work we are timing.
	 */
	public static double runSelfTuningLam(int runLength) {
		SelfTuningLam lam = new SelfTuningLam();
		long count = 0;
		lam.init(runLength);
		double currentCost = 1000;
		for (int i = 0; i < runLength; i++) {
			double neighborCost = currentCost;
			if (i % 2 == 0) neighborCost = neighborCost + i % 1000;
			else neighborCost = neighborCost - i % 1000;
			if (lam.accept(neighborCost, currentCost)) count = count + 1;
		}
		return 1.0 * count;
	}
	
	/**
	 * Runs the experiment.
	 * @param args There are no command line arguments.
	 */
    public static void main(String[] args) {
		final int WARMUP_NUM_SAMPLES = 100;
		final int WARMUP_RUN_LENGTH = 128000;
		final int NUM_SAMPLES = 100;
		final int MIN_RUNLENGTH = 1000;
		final int MAX_RUNLENGTH = 1024000;
		
		// Warm up JVM prior to timing alternatives
		double totalDiff = 0;
		{
			for (int i = 0; i < WARMUP_NUM_SAMPLES; i++) {
				double x = runModifiedLam(WARMUP_RUN_LENGTH);
				double y = runSelfTuningLam(WARMUP_RUN_LENGTH);
				// Do something with return values to avoid JVM from optimizing away the calls.
				totalDiff += (x-y);		
			}
		}
		// End warm up
		
		ThreadMXBean bean = ManagementFactory.getThreadMXBean();
		
		System.out.printf("%7s\t%12s\t%12s\n",
			"L",
			"cpu1",
			"cpu2"
		);
		
		for (int L = MIN_RUNLENGTH; L <= MAX_RUNLENGTH; L *= 2) {
			for (int i = 0; i < NUM_SAMPLES; i++) {
				long start = bean.getCurrentThreadCpuTime();
				double x = 0;
				for (int j = 0; j < NUM_SAMPLES; j++) {
					x += runModifiedLam(L);
				}
				long mid = bean.getCurrentThreadCpuTime();
				double y = 0;
				for (int j = 0; j < NUM_SAMPLES; j++) {
					y += runSelfTuningLam(L);
				}
				long end = bean.getCurrentThreadCpuTime();
				// Do something with return values to avoid JVM from optimizing away the calls.
				totalDiff += (x-y);
				
				System.out.printf("%7d\t%12.2f\t%12.2f\n",
					L,
					(mid-start)/((double)NUM_SAMPLES),
					(end-mid)/((double)NUM_SAMPLES)
				);
			}
		}
		System.out.println("Experiment finished: " + totalDiff);
	}
}