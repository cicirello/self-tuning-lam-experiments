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

import org.cicirello.search.problems.OptimizationProblem;
import org.cicirello.search.operators.permutations.ThreeOptMutation;
import org.cicirello.search.operators.permutations.PermutationInitializer;
import org.cicirello.permutations.Permutation;
import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SimulatedAnnealing;
import org.cicirello.search.sa.SelfTuningLam;
import org.cicirello.search.sa.AcceptanceTracker;
import org.cicirello.search.SolutionCostPair;
import org.cicirello.search.ProgressTracker;
import java.util.SplittableRandom;

/**
 * <p>Driver program for experiment comparing how well the new
 * Self-Tuning Lam annealing schedule follows the target idealized
 * acceptance rate vs how well the Modified Lam annealing schedule
 * follows the target idealized acceptance rate. This driver
 * program does this specifically for the Traveling Salesperson problem. 
 * In addition to acceptance rate data, it
 * also outputs the optimization objective function values for
 * all of the runs.</p>
 *
 * @author <a href=https://www.cicirello.org/ target=_top>Vincent A. Cicirello</a>, 
 * <a href=https://www.cicirello.org/ target=_top>https://www.cicirello.org/</a>
 */
public class LamTrackingTSP {
	
	/**
	 * Runs the experiment.
	 * @param args There are command line arguments. args[0] is
	 * the length of the simulated annealing runs in maximum number of evaluations. 
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = Integer.parseInt(args[0]);
		final int WIDTH = Integer.parseInt(args[1]);
		final int NUM_SAMPLES = 100;
		final int NUM_CITIES = 1000;
		
		AcceptanceTracker modifiedLam = new AcceptanceTracker(new ModifiedLam());
		AcceptanceTracker selfTuningLam = new AcceptanceTracker(new SelfTuningLam());
		
		System.out.println("End of Run Costs");
		System.out.println("MLam\tSTLam");
		for (int i = 0; i < NUM_SAMPLES; i++) {
			// Use different instance per sample, with i as seed.
			TSP problem = new TSP(NUM_CITIES, WIDTH, i);
			
			SimulatedAnnealing<Permutation> sa1 = new SimulatedAnnealing<Permutation>(
				problem, 
				new ThreeOptMutation(),
				new PermutationInitializer(NUM_CITIES),
				modifiedLam
			);
			
			SimulatedAnnealing<Permutation> sa2 = new SimulatedAnnealing<Permutation>(
				problem, 
				new ThreeOptMutation(),
				new PermutationInitializer(NUM_CITIES),
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
	
	/**
	 * Cost function for the TSP.
	 * @author <a href=https://www.cicirello.org/ target=_top>Vincent A. Cicirello</a>, 
	 * <a href=https://www.cicirello.org/ target=_top>https://www.cicirello.org/</a>
	 */
	public static class TSP implements OptimizationProblem<Permutation> {
		
		private final double[] x;
		private final double[] y;
		
		/** 
		 * Constructs an instance of the TSP.
		 * @param n Number of cities
		 * @param width Cities are uniformly dispersed within a width x width square.
		 * @param seed Seed for the random number generator to enable replication.
		 */
		public TSP(int n, double width, int seed) {
			SplittableRandom gen = new SplittableRandom(seed);
			x = new double[n];
			y = new double[n];
			for (int i = 0; i < n; i++) {
				x[i] = width*gen.nextDouble();
				y[i] = width*gen.nextDouble();
			}
		}
		
		@Override
		public double cost(Permutation candidate) {
			if (candidate.length() != x.length) {
				throw new IllegalArgumentException("Permutation must be same length as number of cities.");
			}
			double total = edgeCost(candidate.get(0), candidate.get(candidate.length()-1));
			for (int i = 1; i < candidate.length(); i++) {
				total = total + edgeCost(candidate.get(i), candidate.get(i-1));
			}
			return total;
		}
		
		@Override
		public double value(Permutation candidate) {
			return cost(candidate);
		}
		
		private double edgeCost(int i, int j) {
			double deltaX = x[i] - x[j];
			double deltaY = y[i] - y[j];
			return Math.sqrt(deltaX*deltaX + deltaY*deltaY);
		}
	}
}