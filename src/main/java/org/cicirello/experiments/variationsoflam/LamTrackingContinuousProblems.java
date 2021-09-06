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

package org.cicirello.experiments.variationsoflam;

import org.cicirello.search.problems.OptimizationProblem;
import org.cicirello.search.representations.SingleReal;
import org.cicirello.search.operators.Initializer;
import org.cicirello.search.operators.reals.RealValueInitializer;
import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SimulatedAnnealing;
import org.cicirello.search.sa.SelfTuningLam;
import org.cicirello.search.sa.AcceptanceTracker;
import org.cicirello.search.SolutionCostPair;
import org.cicirello.search.ProgressTracker;
import org.cicirello.search.operators.reals.UndoableGaussianMutation;
import org.cicirello.search.problems.CostFunctionScaler;


public class LamTrackingContinuousProblems {
	
	/**
	 * Runs the experiment.
	 * @param args Command line arguments include: args[0] is
	 * the length of the simulated annealing runs in maximum number of evaluations.
	 * args[1] is a scale factor, to scale all cost values by.
	 * args[2] indicates which problem to solve, 0 for GramacyLee2012, 1 for original 
	 * ForresterEtAl2008, 2 for lower fidelity version of ForresterEtAl2008.
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = Integer.parseInt(args[0]);
		
		final int SCALE = Integer.parseInt(args[1]);
		
		double sigma = 0.05;
		
		OptimizationProblem<SingleReal> problem = null;
		OptimizationProblem<SingleReal> scaled = null;
		Initializer<SingleReal> init = null;
		int P = Integer.parseInt(args[2]);
		switch (P) {
			case 0: {
				problem = new GramacyLee2012();
				init = (GramacyLee2012)problem;
				break;
			}
			case 1: {
				problem = new ForresterEtAl2008(false); 
				init = (ForresterEtAl2008)problem;
				break;
			}
			case 2: {
				problem = new ForresterEtAl2008(true); 
				init = (ForresterEtAl2008)problem;
				break;
			}
		}
		if (problem==null) {
			System.err.println("Unknown problem requested. Exiting.");
			System.exit(1);
		}
		scaled = new CostFunctionScaler<SingleReal>(problem, SCALE);
		
		final int NUM_SAMPLES = 100;
		
		AcceptanceTracker modifiedLam = new AcceptanceTracker(new ModifiedLam());
		AcceptanceTracker selfTuningLam = new AcceptanceTracker(new SelfTuningLam());
		
		UndoableGaussianMutation<SingleReal> mutation1 = UndoableGaussianMutation.createGaussianMutation​(sigma);
		UndoableGaussianMutation<SingleReal> mutation2 = UndoableGaussianMutation.createGaussianMutation​(sigma);
		
		SimulatedAnnealing<SingleReal> sa1 = new SimulatedAnnealing<SingleReal>(
			scaled, 
			mutation1,
			init,
			modifiedLam
		);
		
		SimulatedAnnealing<SingleReal> sa2 = new SimulatedAnnealing<SingleReal>(
			scaled, 
			mutation2, 
			init,
			selfTuningLam
		);
		
		System.out.println("End of Run Costs");
		System.out.println("MLam\tSTLam");
		for (int i = 0; i < NUM_SAMPLES; i++) {
			SolutionCostPair<SingleReal> solution1 = sa1.optimize(RUN_LENGTH);
			SolutionCostPair<SingleReal> solution2 = sa2.optimize(RUN_LENGTH);
			
			// Output best of run costs.
			System.out.print(sa1.getProgressTracker().getCostDouble());
			System.out.print("\t");
			System.out.println(sa2.getProgressTracker().getCostDouble());
			System.out.flush();
			
			// Reset the progress trackers for next run to avoid
			// interaction between runs.
			sa1.setProgressTracker(new ProgressTracker<SingleReal>());
			sa2.setProgressTracker(new ProgressTracker<SingleReal>());
		}
		System.out.println("Acceptance Rate");
		System.out.println(modifiedLam.getAcceptanceRate(0) + "\t" + selfTuningLam.getAcceptanceRate(0));
		final int SKIP = RUN_LENGTH / 200;
		for (int i = SKIP - 1; i < RUN_LENGTH; i+=SKIP) {
			System.out.println(modifiedLam.getAcceptanceRate(i) + "\t" + selfTuningLam.getAcceptanceRate(i));
		}

	}
	
	public static class GramacyLee2012 implements OptimizationProblem<SingleReal>, Initializer<SingleReal> {
		
		// many local minima
		
		// eval on [0.5, 2.5]
		
		// https://www.sfu.ca/~ssurjano/grlee12.html
		
		private final RealValueInitializer init;
		
		public GramacyLee2012() { 
			init = new RealValueInitializer​(0.5, 2.5, 0.5, 2.5);
		}
		
		@Override
		public double cost​(SingleReal candidate) {
			return 0.5*Math.sin(10*Math.PI*candidate.get())/candidate.get() + Math.pow(candidate.get()-1,4);
		}
		
		@Override
		public double value​(SingleReal candidate) {
			return cost(candidate);
		} 
		
		@Override
		public SingleReal createCandidateSolution() {
			return init.createCandidateSolution();
		}
		
		@Override
		public GramacyLee2012 split() {
			return new GramacyLee2012();
		}
	}
	
	public static class ForresterEtAl2008 implements OptimizationProblem<SingleReal>, Initializer<SingleReal> {
		
		// 1 global minima, 1 local minima, and 0 gradient inflection point.
		
		// evaluate on [0, 1]
		
		// https://www.sfu.ca/~ssurjano/forretal08.html
		
		private final boolean ORIGINAL;
		private final double A;
		private final double B;
		private final double C;
		private final RealValueInitializer init;
		
		public ForresterEtAl2008(boolean lowerFidelity) {
			ORIGINAL = !lowerFidelity;
			if (ORIGINAL) {
				A = 1;
				B = C = 0;
			} else {
				A = 0.5;
				B = 10;
				C = -5;
			}
			init = new RealValueInitializer​(0.0, 1.0, 0.0, 1.0);
		}
		
		@Override
		public double cost​(SingleReal candidate) {
			if (ORIGINAL) {
				return original(candidate);
			} else {
				return A * original(candidate) + B * (candidate.get() - 0.5) - C;
			}
		}
		
		@Override
		public double value​(SingleReal candidate) {
			return cost(candidate);
		}
		
		@Override
		public SingleReal createCandidateSolution() {
			return init.createCandidateSolution();
		}
		
		@Override
		public ForresterEtAl2008 split() {
			return new ForresterEtAl2008(!ORIGINAL);
		}
		
		private double original(SingleReal candidate) {
			double term = 6 * candidate.get() - 2;
			return term * term * Math.sin(12 * candidate.get() - 4);
		}
	}
	
}