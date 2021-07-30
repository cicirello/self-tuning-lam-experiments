/*
 * Experiments with variations of Lam annealing.
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

import org.cicirello.search.operators.bits.BitVectorInitializer;
import org.cicirello.search.operators.bits.DefiniteBitFlipMutation;
import org.cicirello.search.problems.OneMax;
import org.cicirello.search.representations.BitVector;
import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SimulatedAnnealing;
import org.cicirello.search.sa.SelfTuningModifiedLam;
import org.cicirello.search.sa.AcceptanceTracker;
import org.cicirello.search.problems.IntegerCostFunctionScaler;
import org.cicirello.search.SolutionCostPair;
import org.cicirello.search.ProgressTracker;

public class LamTrackingOneMax {
	
	/**
	 * Runs the experiment.
	 * @param args There are two optional command line arguments. args[0] is
	 * the length of the simulated annealing runs in maximum number of evaluations
	 * which has a default of 1000 if not specified on the command line. args[1]
	 * is a scale factor, which scales the cost function values by whatever 
	 * value is specified here, which must be a positive integer.
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = args.length > 0 ? Integer.parseInt(args[0]) : 1000;
		final int SCALE = args.length > 1 ? Integer.parseInt(args[1]) : 1;
		
		final int NUM_SAMPLES = 100;
		
		//final int BITS = RUN_LENGTH >= 1000000 ? 12800 :
		//	(RUN_LENGTH >= 100000 ? 6400
		//	: (RUN_LENGTH >= 10000 ? 960 : 192));
		
		final int BITS = RUN_LENGTH >= 1000000 ? 8192 :
			(RUN_LENGTH >= 100000 ? 2048
			: (RUN_LENGTH >= 10000 ? 512 : 128));
		
		final int BIT_LENGTH = BITS; 
		IntegerCostFunctionScaler<BitVector> problem = new IntegerCostFunctionScaler<BitVector>(new OneMax(), SCALE);
		final int MAX_BITS_MUTATE = 1;
		
		AcceptanceTracker modifiedLam = new AcceptanceTracker(new ModifiedLam());
		AcceptanceTracker selfTuningLam = new AcceptanceTracker(new SelfTuningModifiedLam());
		
		SimulatedAnnealing<BitVector> sa1 = new SimulatedAnnealing<BitVector>(
			problem, 
			new DefiniteBitFlipMutation(MAX_BITS_MUTATE),
			new BitVectorInitializer(BIT_LENGTH),
			modifiedLam
		);
		
		SimulatedAnnealing<BitVector> sa2 = new SimulatedAnnealing<BitVector>(
			problem, 
			new DefiniteBitFlipMutation(MAX_BITS_MUTATE), 
			new BitVectorInitializer(BIT_LENGTH),
			selfTuningLam
		);
		
		System.out.println("End of Run Costs");
		System.out.println("MLam\tSTLam");
		for (int i = 0; i < NUM_SAMPLES; i++) {
			SolutionCostPair<BitVector> solution1 = sa1.optimize(RUN_LENGTH);
			SolutionCostPair<BitVector> solution2 = sa2.optimize(RUN_LENGTH);
			
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
			
			// Reset the progress trackers for next run to avoid
			// interaction between runs.
			sa1.setProgressTracker(new ProgressTracker<BitVector>());
			sa2.setProgressTracker(new ProgressTracker<BitVector>());
		}
		System.out.println("Acceptance Rate");
		System.out.println(modifiedLam.getAcceptanceRate(0) + "\t" + selfTuningLam.getAcceptanceRate(0));
		final int SKIP = RUN_LENGTH / 200;
		for (int i = SKIP - 1; i < RUN_LENGTH; i+=SKIP) {
			System.out.println(modifiedLam.getAcceptanceRate(i) + "\t" + selfTuningLam.getAcceptanceRate(i));
		}
		
	}
	
}