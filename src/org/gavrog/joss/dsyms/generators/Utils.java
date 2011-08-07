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

package org.gavrog.joss.dsyms.generators;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;

import org.gavrog.joss.dsyms.basic.DSymbol;
import org.gavrog.joss.dsyms.basic.DelaneySymbol;
import org.gavrog.joss.dsyms.basic.IndexList;
import org.gavrog.joss.dsyms.basic.Subsymbol;


/**
 * A collection of utility methods to be used by the generator classes in this package.
 * 
 * @author Olaf Delgado
 * @version $Id: Utils.java,v 1.2 2007/04/26 20:21:58 odf Exp $
 */
public class Utils {
    /**
     * Checks if a 2-dimensional symbol may still be made spherical by defining
     * its undefined v-values. It is assumed but not verified that the symbol
     * defines all its op-values.
     * 
     * @param ds the input symbol.
     * @return true if the symbol may still be made spherical.
     */
    public static boolean mayBecomeSpherical2D(DelaneySymbol ds) {
        if (ds.dim() != 2) {
            throw new IllegalArgumentException("symbol must be 2-dimensional");
        }
        ds = new DSymbol(ds.orientedCover());
        ds.setVDefaultToOne(true);
        if (!ds.curvature2D().isPositive()) {
            return false;
        }
        
        final List<Integer> degrees = new ArrayList<Integer>();
        int undefined = 0;
        for (int i = 0; i < 2; ++i) {
            for (int j = i+1; j <= 2; ++j) {
                final List idcs = new IndexList(i, j);
                for (final Iterator reps = ds.orbitReps(idcs); reps.hasNext();) {
                    final Object D = reps.next();
                    if (ds.definesV(i, j, D)) {
                        final int v = ds.v(i, j, D);
                        if (v > 1) {
                            degrees.add(v);
                        }
                    } else {
                        ++undefined;
                    }
                }
            }
        }
        
        final int n = degrees.size();
        if (n == 2){
            final int a = Collections.max(degrees);
            final int b = Collections.min(degrees);
            if (a != b) {
                if ((a > 5 && b > 2) || b > 3 || undefined == 0) {
                    return false;
                }
            }
        } else if (n == 1 && undefined == 0) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Checks if a 3-dimensional symbol may still be made locally euclidean by
     * defining its undefined v-values. It is assumed but not verified that the
     * symbol defines all its op-values.
     * 
     * @param ds the input symbol.
     * @return true if the symbol may still be made locally euclidean.
     */
    public static boolean mayBecomeLocallyEuclidean3D(DelaneySymbol ds) {
        if (ds.dim() != 3) {
            throw new IllegalArgumentException("symbol must be 3-dimensional");
        }
        ds = new DSymbol(ds);
        for (int k = 0; k <= ds.dim(); ++k) {
            final List idcs = new IndexList(ds);
            idcs.remove(k);
            for (final Iterator reps = ds.orbitReps(idcs); reps.hasNext();) {
                final DelaneySymbol sub = new Subsymbol(ds, idcs, reps.next());
                if (!mayBecomeSpherical2D(sub)) {
                    return false;
                }
            }
        }
        return true;
    }
}
