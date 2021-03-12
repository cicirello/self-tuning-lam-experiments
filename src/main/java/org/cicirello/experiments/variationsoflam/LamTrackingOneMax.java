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

public class LamTrackingOneMax {
	
	/**
	 * Runs the experiment.
	 * @param args There are no command line arguments.
	 */
	public static void main(String[] args) {
		final int RUN_LENGTH = args.length > 0 ? Integer.parseInt(args[0]) : 1000;
		final int SCALE = args.length > 1 ? Integer.parseInt(args[1]) : 1;
		
		final int NUM_SAMPLES = 100;
		
		final int BITS = RUN_LENGTH >= 1000000 ? 13760 :
			(RUN_LENGTH >= 100000 ? 6432
			: (RUN_LENGTH >= 10000 ? 928 : 192));
		final int BITS3 = RUN_LENGTH <= 1000 ? BITS + 128 : (RUN_LENGTH >= 100000 ? BITS + 64 : BITS + 32);
		final int BIT_LENGTH = SCALE > 2 ? BITS3 : BITS; 
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
			System.out.println(solution1.getCost() + "\t" + solution2.getCost());
		}
		System.out.println("Acceptance Rate");
		for (int i = 0; i < RUN_LENGTH; i++) {
			System.out.println(modifiedLam.getAcceptanceRate(i) + "\t" + selfTuningLam.getAcceptanceRate(i));
		}
		
		/*
		// Remove this later
		double lam002 = 0.44 + 0.56 * Math.pow(560, -2.0/150);
		double lam011 = 0.44 + 0.56 * Math.pow(560, -11.0/150);
		System.out.println("lam002:" + lam002);
		System.out.println("lam011:" + lam011);
		*/
		//System.out.println("001 case: " + 1.0/Math.log(0.001/(1.001-0.9546897506857566)));
		//System.out.println("01 case: " + 1.0/Math.log(0.001/(1.001-0.7920904441690215)));
		//double lam02 = 0.44 + 0.56 * Math.pow(560, -2.0/15);
		//System.out.println("lam02: " + lam02);
		//System.out.println("02 case: " + 1.0/Math.log(0.001/(1.001-0.6808590431613767)));
		//System.out.println("beta 10k case: " + 0.260731492877931 / 0.3141120890121576);
		//System.out.println("beta 1k case: " + 0.17334743675123146 / 0.18987910472222955);
	}
	
}