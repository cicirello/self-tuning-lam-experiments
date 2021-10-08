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

import org.cicirello.search.problems.scheduling.WeightedStaticSchedulingWithSetups;
import org.cicirello.search.problems.scheduling.WeightedTardiness;
import org.cicirello.search.operators.permutations.InsertionMutation;
import org.cicirello.search.operators.permutations.PermutationInitializer;
import org.cicirello.permutations.Permutation;
import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SimulatedAnnealing;
import org.cicirello.search.sa.SelfTuningLam;
import org.cicirello.search.sa.AcceptanceTracker;
import org.cicirello.search.SolutionCostPair;
import org.cicirello.search.ProgressTracker;

/**
 * <p>Driver program for experiment comparing how well the new
 * Self-Tuning Lam annealing schedule follows the target idealized
 * acceptance rate vs how well the Modified Lam annealing schedule
 * follows the target idealized acceptance rate. This driver
 * program does this specifically for the Common Due Date problem. 
 * In addition to acceptance rate data, it
 * also outputs the optimization objective function values for
 * all of the runs.</p>
 *
 * @author <a href=https://www.cicirello.org/ target=_top>Vincent A. Cicirello</a>, 
 * <a href=https://www.cicirello.org/ target=_top>https://www.cicirello.org/</a>
 */
public class LamTrackingSchedulingWithSetups {
	
	/**
	 * Runs the experiment.
	 * @param args There are command line arguments. args[0] is
	 * the length of the simulated annealing runs in maximum number of evaluations. 
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = Integer.parseInt(args[0]);
		final double TAU = 0.5;
		final double R = 0.5;
		final double ETA = 0.5;
		final int NUM_SAMPLES = 100;
		final int NUM_JOBS = 1000;
		
		AcceptanceTracker modifiedLam = new AcceptanceTracker(new ModifiedLam());
		AcceptanceTracker selfTuningLam = new AcceptanceTracker(new SelfTuningLam());
		
		System.out.println("End of Run Costs");
		System.out.println("MLam\tSTLam");
		for (int i = 0; i < NUM_SAMPLES; i++) {
			// Use different instance per sample, with i as seed.
			WeightedStaticSchedulingWithSetups scheduling = new WeightedStaticSchedulingWithSetups(NUM_JOBS, TAU, R, ETA, i);
			WeightedTardiness problem = new WeightedTardiness(scheduling);
			
			SimulatedAnnealing<Permutation> sa1 = new SimulatedAnnealing<Permutation>(
				problem, 
				new InsertionMutation(),
				new PermutationInitializer(NUM_JOBS),
				modifiedLam
			);
			
			SimulatedAnnealing<Permutation> sa2 = new SimulatedAnnealing<Permutation>(
				problem, 
				new InsertionMutation(),
				new PermutationInitializer(NUM_JOBS),
				selfTuningLam
			);
			
			SolutionCostPair<Permutation> solution1 = sa1.optimize(RUN_LENGTH);
			SolutionCostPair<Permutation> solution2 = sa2.optimize(RUN_LENGTH);
			
			// Output best of run costs.
			if (sa1.getProgressTracker().containsIntCost()) {
				System.out.print(sa1.getProgressTracker().getCost());
			} else {
				System.out.print(sa1.getProgressTracker().getCostDouble());
			}
			System.out.print("\t");
			if (sa2.getProgressTracker().containsIntCost()) {
				System.out.println(sa2.getProgressTracker().getCost());
			} else {
				System.out.println(sa2.getProgressTracker().getCostDouble());
			}
			System.out.flush();
		}
		System.out.println("Acceptance Rate");
		System.out.println(modifiedLam.getAcceptanceRate(0) + "\t" + selfTuningLam.getAcceptanceRate(0));
		final int SKIP = RUN_LENGTH / 200;
		for (int i = SKIP - 1; i < RUN_LENGTH; i+=SKIP) {
			System.out.println(modifiedLam.getAcceptanceRate(i) + "\t" + selfTuningLam.getAcceptanceRate(i));
		}
	}
}