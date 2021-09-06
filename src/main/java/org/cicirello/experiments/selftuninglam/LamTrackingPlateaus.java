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

import org.cicirello.search.operators.bits.BitVectorInitializer;
import org.cicirello.search.operators.bits.DefiniteBitFlipMutation;
import org.cicirello.search.problems.Plateaus;
import org.cicirello.search.representations.BitVector;
import org.cicirello.search.sa.ModifiedLam;
import org.cicirello.search.sa.SimulatedAnnealing;
import org.cicirello.search.sa.SelfTuningLam;
import org.cicirello.search.sa.AcceptanceTracker;
import org.cicirello.search.SolutionCostPair;
import org.cicirello.search.ProgressTracker;

public class LamTrackingPlateaus {
	
	/**
	 * Runs the experiment.
	 * @param args There are optional command line arguments. args[0] is
	 * the length of the simulated annealing runs in maximum number of evaluations
	 * which has a default of 1000 if not specified on the command line. If args[1] is "fixed",
	 * then the bit strings are of a fixed length independent of run length, where that
	 * length is 256 bits.
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = args.length > 0 ? Integer.parseInt(args[0]) : 1000;
		
		final boolean FIXED_BITLENGTH = args.length > 1 && args[1].equalsIgnoreCase("fixed");
		
		final int NUM_SAMPLES = 100;
		
		final int BITS = FIXED_BITLENGTH ? 256 : 
			(RUN_LENGTH >= 1000000 ? 12800 :
			(RUN_LENGTH >= 100000 ? 3200
			: (RUN_LENGTH >= 10000 ? 800 : 200)));
			
		final int BIT_LENGTH = BITS; 
		Plateaus problem = new Plateaus();
		final int MAX_BITS_MUTATE = 1;
		
		AcceptanceTracker modifiedLam = new AcceptanceTracker(new ModifiedLam());
		AcceptanceTracker selfTuningLam = new AcceptanceTracker(new SelfTuningLam());
		
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