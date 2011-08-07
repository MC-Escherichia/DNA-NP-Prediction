/*
   Copyright 2008 Olaf Delgado-Friedrichs

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/


package org.gavrog.joss.dsyms.filters;

import java.util.Iterator;
import java.util.List;

import org.gavrog.joss.dsyms.basic.DSymbol;
import org.gavrog.joss.dsyms.basic.IndexList;
import org.gavrog.joss.dsyms.generators.InputIterator;

/**
 * @author Olaf Delgado
 * @version $Id: FilterFaceDegrees.java,v 1.1 2008/03/15 05:59:02 odf Exp $
 */
public class FilterFaceDegrees {
    public static void main(String[] args) {
        final String filename = args[0];
        final int min = Integer.parseInt(args[1]);
        final int max = Integer.parseInt(args[2]);
        final List idcs = new IndexList(0, 1, 3);
        int inCount = 0;
        int outCount = 0;

        for (InputIterator iter = new InputIterator(filename); iter.hasNext();) {
			final DSymbol ds = (DSymbol) iter.next();
			boolean good = true;
			++inCount;
			for (Iterator reps = ds.orbitReps(idcs); reps.hasNext();) {
				final Object D = reps.next();
				final int m = ds.m(0, 1, D);
				if (m < min || m > max) {
					good = false;
				}
			}
			if (good) {
				++outCount;
				System.out.println(ds);
				System.out.flush();
			}
		}
        System.out.println("# " + inCount + " symbols read.");
        System.out.println("# " + outCount + " symbols written.");
	}
}
