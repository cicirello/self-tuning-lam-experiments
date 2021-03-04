/*
 * Chips-n-Salsa: A library of parallel self-adaptive local search algorithms.
 * Copyright (C) 2002-2021  Vincent A. Cicirello
 *
 * This file is part of Chips-n-Salsa (https://chips-n-salsa.cicirello.org/).
 * 
 * Chips-n-Salsa is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Chips-n-Salsa is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
 
package org.cicirello.search.sa;

import java.util.concurrent.ThreadLocalRandom;

/**
 * <p>UPDATE THIS BEFORE MAKING IT PUBLIC</p>
 * 
 * <p>This class implements an optimized variant of the Modified Lam annealing schedule. 
 * The Modified Lam annealing schedule dynamically
 * adjusts simulated annealing's temperature parameter up and down to either decrease
 * or increase the neighbor acceptance rate as necessary to attempt to match 
 * a theoretically determined ideal.  The Modified Lam annealing schedule is
 * a practical realization of Lam and Delosme's (1988) schedule, 
 * refined first by Swartz (1993) and
 * then further by Boyan (1998).</p> 
 *
 * <p>This optimized version of the Modified Lam is described in the following
 * article:<br>
 * Vincent A. Cicirello. 2020. 
 * <a href=https://www.cicirello.org/publications/eai.16-12-2020.167653.pdf>Optimizing 
 * the Modified Lam Annealing Schedule</a>.
 * <i>Industrial Networks and Intelligent Systems</i>, 7(25): 1-11, Article e1 (December 2020).
 * doi:<a href=https://doi.org/10.4108/eai.16-12-2020.167653>10.4108/eai.16-12-2020.167653</a>.
 * </p>
 *
 * <p>This optimized Java implementation is significantly faster than the 
 * implementation that would result from a direct implementation as described
 * originally by Boyan (1998). Specifically, in the original Boyan's Modified Lam,
 * the update of the target rate of acceptance involves an
 * exponentiation. This update occurs once for each iteration of simulated annealing.
 * However, in the Optimized Modified Lam of Cicirello (2020), the target rate is 
 * instead computed incrementally from the prior
 * rate. If the simulated annealing run is n evaluations in length, then the
 * direct implementation of Boyan's Modified Lam schedule performs
 * n/2 exponentiations in total across all updates of the target rate; 
 * while the Optimized Modified Lam instead perform only 2 exponentiations and n/2
 * multiplications total across all updates of the target rate. The schedule of target
 * acceptance rates is otherwise the same.</p>
 *
 * <p>For details of the original Modified Lam schedule, such as 
 * its origins and rationale, see the following references:</p>
 * <ul>
 * <li>Lam, J., and Delosme, J. 1988. Performance of a new annealing schedule. 
 * In Proc. 25th ACM/IEEE DAC, 306–311.</li>
 * <li>Swartz, W. P. 1993. Automatic Layout of Analog and Digital Mixed 
 * Macro/Standard Cell Integrated Circuits. Ph.D. Dissertation, Yale University.</li>
 * <li>Boyan, J. A. 1998. Learning Evaluation Functions for Global Optimization. 
 * Ph.D. Dissertation, Carnegie Mellon University, Pittsburgh, PA.</li>
 * </ul>
 *
 * <p>The Chips-n-Salsa library also includes an implementation of the original
 * Modified Lam schedule that is the result of a direct
 * implementation of Boyan's description of the annealing schedule,
 * see the {@link ModifiedLamOriginal} class for that version.</p>
 *
 * <p>The {@link #accept} methods of this class use the classic, and most common,
 * Boltzmann distribution for determining whether to accept a neighbor.</p>
 *
 *
 * @author <a href=https://www.cicirello.org/ target=_top>Vincent A. Cicirello</a>, 
 * <a href=https://www.cicirello.org/ target=_top>https://www.cicirello.org/</a>
 * @version 1.22.2021
 */
public final class SelfTuningModifiedLam implements AnnealingSchedule {
	
	private double t;
	private double acceptRate;
	private double targetRate;
	private double phase0;
	private double phase1;
	private double phase2;
	private int iterationCount;
	
	private double termPhase1;
	private double multPhase1;
	private double multPhase3;
	
	private double deltaSum;
	private int sameCostCount;
	private int betterCostCount;
	
	private int lastMaxEvals;
	
	private static final double LAM_RATE_POINT_ONE_PERCENT_OF_RUN = 0.9768670788789564;
	private static final double LAM_RATE_ONE_PERCENT_OF_RUN = 0.8072615745900611;
	
	/**
	 * Default constructor.  The Self-Tuning Modified Lam annealing schedule,
	 * unlike other annealing schedules, has no control parameters
	 * other than the run length (the maxEvals parameter of the
	 * {@link #init} method), so no parameters need be passed to
	 * the constructor.
	 */
	public SelfTuningModifiedLam() {
		lastMaxEvals = -1;
	}
	
	@Override
	public void init(int maxEvals) {
		if (maxEvals >= 10000) {
			targetRate = acceptRate = LAM_RATE_POINT_ONE_PERCENT_OF_RUN;
		} else {
			targetRate = acceptRate = LAM_RATE_ONE_PERCENT_OF_RUN;
		}
		termPhase1 = acceptRate - 0.44;
		sameCostCount = 0;
		betterCostCount = 0;
		deltaSum = 0.0;
		// very very short runs won't have a phase 0, so default to initial t=0.5
		t = 0.5;
		iterationCount = 0;
		if (lastMaxEvals != maxEvals) {
			// These don't change during the run, and only depend
			// on maxEvals.  So initialize only if run length
			// has changed.
			phase0 = maxEvals * (maxEvals >= 10000 ? 0.001 : 0.01);
			phase1 = 0.15 * maxEvals;
			phase2 = 0.65 * maxEvals;
			multPhase1 = Math.pow(560, -1.0/phase1);
			multPhase3 = Math.pow(440, -1.0/(maxEvals-phase2));
			lastMaxEvals = maxEvals;
		}
	}
	
	@Override
	public boolean accept(double neighborCost, double currentCost) {
		iterationCount++;
		if (iterationCount <= phase0) {
			doPhaseZeroUpdate(neighborCost, currentCost);
			return true;
		} else {
			boolean doAccept = neighborCost <= currentCost ||
				ThreadLocalRandom.current().nextDouble() < Math.exp((currentCost-neighborCost)/t);
			updateSchedule(doAccept);
			return doAccept;
		}
	}
	
	@Override
	public SelfTuningModifiedLam split() {
		return new SelfTuningModifiedLam();
	}
	
	private void doPhaseZeroUpdate(double neighborCost, double currentCost) {
		double costDelta = currentCost - neighborCost;
		if (costDelta > 0.0) {
			betterCostCount++;
			deltaSum += costDelta;
		} else if (costDelta < 0.0) {
			deltaSum -= costDelta;
		} else {
			sameCostCount++;
		}
		if (iterationCount + 1 > phase0) {
			int acceptedCount = sameCostCount + betterCostCount;
			double initialAcceptanceRate = (acceptedCount != iterationCount)
				? ((double)acceptedCount) / iterationCount
				: acceptedCount / (1.0 + iterationCount);
			// if all of the tuning samples had same cost (e.g., starting on
			// a plateau), we assume an average cost delta equal to 1,
			// which for an integer-cost objective function is the smallest
			// possible non-zero cost difference.
			double costAverage = iterationCount == sameCostCount 
				? 1 : deltaSum / (iterationCount - sameCostCount);
			if (initialAcceptanceRate < acceptRate) {
				t = -costAverage / 
					Math.log((acceptRate - initialAcceptanceRate) / 
					(1.0 - initialAcceptanceRate));
			} else {
				// If the tuning samples have an approximated aceptance rate
				// greater than or equal to the initial Lam rate, we assume that
				// it is 0.001 less than the initial Lam rate when computing an initial
				// temperature.
				t = costAverage * (lastMaxEvals >= 10000 ? 0.3141120890121576 : 0.18987910472222955);
				// Logically equivalent to:
				// t = -costAverage / Math.log(0.001 / (1.001 - acceptRate));
			}
		}
	}
	
	private void updateSchedule(boolean doAccept) {
		if (doAccept) acceptRate = 0.998 * acceptRate + 0.002;	
		else acceptRate = 0.998 * acceptRate;
		
		if (iterationCount <= phase1) {
			// Original Modified Lam schedule indicates that targetRate should 
			// be set in phase 1 (first 15% of run) 
			// to: 0.44 + 0.56 * Math.pow(560, -1.0*iterationCount/phase1);
			// That involves a pow for each phase 1 iteration.  We instead compute it
			// incrementally with 1 call to pow in the init, and 1 multiplication per
			// phase 1 update.
			termPhase1 *= multPhase1;
			targetRate = 0.44 + termPhase1;
		} else if (iterationCount > phase2) {
			// Original Modified Lam schedule indicates that targetRate should 
			// be set in phase 3 (last 35% of run) 
			// to: 0.44 * Math.pow(440, -(1.0*iterationCount/maxEvals - 0.65)/0.35);
			// That involves a pow for each phase 3 iteration.  We instead compute it
			// incrementally with 1 call to pow in the init, and 1 multiplication per
			// phase 3 update.
			// Also note that at the end of phase 2, targetRate will equal 0.44, where phase 3 begins.
			targetRate *= multPhase3;
		} else {
			// Phase 2 (50% of run beginning after phase 1): constant targetRate at 0.44.
			targetRate = 0.44;
		}
		
		if (acceptRate > targetRate) t *= 0.999;
		else t *= 1.001001001001001; // 1.001001001001001 == 1.0 / 0.999 
	}
	
	/*
	 * package-private for unit testing
	 */
	double getTargetRate() {
		return targetRate;
	}
	
	/*
	 * package-private for unit testing
	 */
	double getAcceptRate() {
		return acceptRate;
	}
	
	/*
	 * package-private for unit testing
	 */
	double getTemperature() {
		return t;
	}
}