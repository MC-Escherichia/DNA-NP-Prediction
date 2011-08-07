/*
   Copyright 2005 Olaf Delgado-Friedrichs

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

package org.gavrog.joss.dsyms.basic;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.NoSuchElementException;

import org.gavrog.box.collections.IteratorAdapter;
import org.gavrog.box.collections.Iterators;


/**
 * Implements a traversal through a collection of connected components of a
 * Delaney symbol. By default, every element (node) is visited exactly once.
 * There is also an option to have every edge visited exactly once.
 * 
 * @author Olaf Delgado
 * @version $Id: Traversal.java,v 1.3 2007/04/18 04:17:48 odf Exp $
 */
public class Traversal extends IteratorAdapter {

    private DelaneySymbol ds;
    private List indices;
    private Iterator seeds;
    private boolean visitAllEdges;

    private LinkedList[] buffer;
    private HashMap elm2num;
    private int nextNum;

    /**
     * Initializes a new partial traversal.
     * @param ds the Delaney symbol to traverse.
     * @param indices follow only edges with these indices.
     * @param seeds the starting points for the traversal.
     * @param allEdges if true, traversal visits all edges.
     */
    public Traversal(DelaneySymbol ds, List indices, Iterator seeds,
            boolean allEdges)
    {
        this.ds = ds;
        this.indices = indices;
        this.seeds = seeds;
        this.visitAllEdges = allEdges;

        this.buffer = new LinkedList[indices.size()];
        for (int i = 0; i < indices.size(); ++i) {
            buffer[i] = new LinkedList();
        }
        this.elm2num = new HashMap();
        this.nextNum = 0;
    }

    /**
     * Initializes a new partial traversal that visits each element (node)
     * exactly once.
     * @param ds the Delaney symbol to traverse.
     * @param indices follow only edges with these indices.
     * @param seeds the starting points for the traversal.
     */
    public Traversal(DelaneySymbol ds, List indices, Iterator seeds) {
        this(ds, indices, seeds, false);
    }
    
    /**
     * Initializes a new partial traversal that visits each element (node)
     * exactly once.
     * @param ds the Delaney symbol to traverse.
     * @param indices follow only edges with these indices.
     * @param seed the single starting point for the traversal.
     */
    public Traversal(DelaneySymbol ds, List indices, Object seed) {
        this(ds, indices, Iterators.singleton(seed), false);
    }
    
    /**
     * Initializes a new partial traversal.
     * @param ds the Delaney symbol to traverse.
     * @param indices follow only edges with these indices.
     * @param seed the single starting point for the traversal.
     * @param allEdges if true, traversal visits all edges.
     */
    public Traversal(DelaneySymbol ds, List indices, Object seed,
            boolean allEdges)
    {
        this(ds, indices, Iterators.singleton(seed), allEdges);
    }

    /**
     * Initializes a new complete traversal.
     * @param ds the Delaney symbol to traverse.
     * @param allEdges if true, traversal visits all edges.
     */
    public Traversal(DelaneySymbol ds, boolean allEdges) {
        this(ds, new IndexList(ds), ds.elements(), allEdges);
    }
    
    /**
     * Initializes a new complete traversal that visits each element (node)
     * exactly once.
     * @param ds the Delaney symbol to traverse.
     */
    public Traversal(DelaneySymbol ds) {
        this(ds, new IndexList(ds), ds.elements(), false);
    }
    
    /**
     * This methods finds the next edge of the traversal.
     */
    protected Object findNext() {
		for (int k = 0; k < indices.size(); ++k) {
			while (buffer[k].size() > 0) {
				int i = ((Integer) indices.get(k)).intValue();
				Object D;
				if (k < 2) {
					D = buffer[k].removeLast();
				} else {
					D = buffer[k].removeFirst();
				}
				if (D != null) {
					if (!elm2num.containsKey(D)) {
						elm2num.put(D, new Integer(nextNum++));

						for (int m = 0; m < indices.size(); ++m) {
							int j = ((Integer) indices.get(m)).intValue();
							if (j != i) {
								buffer[m].addLast(ds.op(j, D));
							}
						}
						return new DSPair(i, D);
					} else if (visitAllEdges) {
						int E = ((Integer) elm2num.get(D)).intValue();
						int Ei = ((Integer) elm2num.get(ds.op(i, D)))
								.intValue();
						if (Ei <= E) {
							return new DSPair(i, D);
						}
					}
				}
			}
		}

		while (seeds.hasNext()) {
			Object D = seeds.next();
			if (D != null && !elm2num.containsKey(D)) {
				elm2num.put(D, new Integer(nextNum++));
				for (int k = 0; k < indices.size(); ++k) {
					int i = ((Integer) indices.get(k)).intValue();
					buffer[k].addLast(ds.op(i, D));
				}
				return new DSPair(-1, D);
			}
		}
		throw new NoSuchElementException("at end");
	}
}
