/*
   Copyright 2012 Olaf Delgado-Friedrichs

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
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;

import org.gavrog.box.collections.NiftyList;
import org.gavrog.box.collections.Pair;
import org.gavrog.box.collections.Partition;
import org.gavrog.box.simple.Stopwatch;
import org.gavrog.joss.algorithms.CheckpointEvent;
import org.gavrog.joss.algorithms.ResumableGenerator;
import org.gavrog.joss.dsyms.basic.DSMorphism;
import org.gavrog.joss.dsyms.basic.DSPair;
import org.gavrog.joss.dsyms.basic.DSymbol;
import org.gavrog.joss.dsyms.basic.DelaneySymbol;
import org.gavrog.joss.dsyms.basic.DynamicDSymbol;
import org.gavrog.joss.dsyms.basic.IndexList;
import org.gavrog.joss.dsyms.basic.Subsymbol;
import org.gavrog.joss.dsyms.basic.Traversal;
import org.gavrog.joss.dsyms.derived.Covers;

import buoy.event.EventProcessor;

/**
 * An iterator that takes a (d-1)-dimensional Delaney symbol encoding a
 * collection of tiles and combines them to a connected d-dimensional in every
 * possible way.
 * 
 * For each isomorphism class of extended symbols, only one representative is
 * produced. The order or naming of elements is not preserved.
 */
public class CombineTiles extends ResumableGenerator<DSymbol> {
    // TODO test local euclidicity where possible

	private class Invariant extends NiftyList<Integer>
	{
		private static final long serialVersionUID = 9019321096153152091L;

		public Invariant(final List<Integer> source)
		{
			super(source);
		}
	}
	
    // --- set to true to enable logging
    final private static boolean LOGGING = false;

    // --- the size of the input symbol
    final int originalSize;

    // --- precomputed or extracted data used by the algorithm
    final private int dim;
    final private List<List<DSymbol>> componentTypes;
    
    // --- persistent data used and generated by elementSignatures()
    final private Map<Invariant, Integer> invarToIndex =
    		new HashMap<Invariant, Integer>();
    final private List<Map<Integer, Integer>> indexToRepMap =
    		new ArrayList<Map<Integer, Integer>>();

    // --- the current state
    private final DynamicDSymbol current;
    private final LinkedList<Move> stack;
    private final int unused[];

    // --- auxiliary information applying to the current state
    private int size;
    private Map<Integer, Pair<Integer, Integer>> signatures;

    // --- point within the search tree at which to resume an old computation
	private int resume[] = new int[] {};
	
	// --- the current progress towards the resume point
	private int resume_level = 0;
	private int resume_stack_level = 0;
	private boolean resume_point_reached = false;
	
	// --- used for timing the generator
	final private Stopwatch timer = Stopwatch.global("CombineTiles.total");
	final private Stopwatch signatureTimer =
		Stopwatch.global("CombineTiles.signatures");

    /**
     * The instances of this class represent individual moves of setting
     * d-neighbor values. These become the entries of the trial stack.
     */
    protected class Move {
        final public int element;
        final public int neighbor;
        final public int newType;
        final public int newForm;
        final public boolean isChoice;
        final public int choiceNr;

        public Move(final int element, final int neighbor, int newType,
                int newForm, final boolean isChoice, int choiceNr) {
            this.element = element;
            this.neighbor = neighbor;
            this.newType = newType;
            this.newForm = newForm;
            this.isChoice = isChoice;
            this.choiceNr = choiceNr;
        }

        @Override
		public String toString() {
			return String.format("Move(%s, %s, %d, %d, %s, %d)", element,
					neighbor, newType, newForm, isChoice, choiceNr);
		}
    }

    /**
     * Creates a new instance.
     * 
     * @param ds the symbol to extend.
     */
    public <T> CombineTiles(final DelaneySymbol<T> ds) {
    	timer.start();
    	
        this.dim = ds.dim() + 1;

        // --- basic checks on the input symbol
        if (ds.equals(null)) {
            throw new IllegalArgumentException("null argument");
        }
        try {
            ds.size();
        } catch (UnsupportedOperationException ex) {
            throw new UnsupportedOperationException("symbol must be finite");
        }
        if (!ds.isComplete()) {
            throw new UnsupportedOperationException("symbol must be complete");
        }
        
        // --- now check the connected components of the input symbol
        final IndexList idcs = new IndexList(ds);
        for (final T D: ds.orbitReps(idcs)) {
            final DelaneySymbol<T> sub = new Subsymbol<T>(ds, idcs, D);
            if (this.dim == 3 && !sub.isSpherical2D()) {
                throw new IllegalArgumentException(
                        "components must be spherical");
            }
        }

        // --- remember the input symbol
        this.originalSize = ds.size();

        // --- collect component types with multiplicities and the different
        //     forms they can appear in within a generated symbol
        final DSymbol canonical = new DSymbol(ds.canonical());
        final Map<DelaneySymbol<Integer>, Integer> multiplicities =
        	componentMultiplicities(canonical);
        final List<DelaneySymbol<Integer>> types =
        	new ArrayList<DelaneySymbol<Integer>>(multiplicities.keySet());
        Collections.sort(types);
        final List<List<DSymbol>> forms = new ArrayList<List<DSymbol>>();
        final List<Integer> free = new ArrayList<Integer>();
        for (int i = 0; i < types.size(); ++i) {
            final DelaneySymbol<Integer> type = types.get(i);
            forms.add(Collections.unmodifiableList(subCanonicalForms(type)));
            free.add(multiplicities.get(type));
            if (LOGGING) {
                System.out.println("# " + free.get(i) + " copies and "
                        + forms.get(i).size() + " forms for " + type
                        + " with invariant " + type.invariant() + "\n");
            }
        }
        this.componentTypes = Collections.unmodifiableList(forms);

        // --- initialize the state
        this.size = 0;
        this.signatures = new HashMap<Integer, Pair<Integer, Integer>>();
        this.stack = new LinkedList<Move>();
        this.unused = new int[free.size()];
        for (int i = 0; i < free.size(); ++i) {
        	this.unused[i] = free.get(i);
        }
        this.current = new DynamicDSymbol(this.dim);

        // --- add the component with the smallest invariant
        final DSymbol start = this.componentTypes.get(0).get(0);
        this.current.append((DSymbol) start.canonical()); //MUST make canonical!
        this.unused[0] -= 1;
        this.size = this.current.size();
        this.signatures = elementSignatures(this.current, this.dim - 2);

        // --- push a dummy move on the stack as a fallback
        stack.addLast(new Move(1, 0, 0, 0, true, 0));
        
        timer.stop();
    }

    /**
     * Repeatedly finds the next legal choice in the enumeration tree and
     * executes it, together with all its implications, until all 3-neighbors
     * are defined and in canonical form, in which case the resulting symbol is
     * returned.
     * 
     * Does appropriate backtracking in order to find the respective next
     * choice. Also backtracks if the partial symbol resulting from the latest
     * choice is not in canonical form.
     * 
     * To simplify the code, the algorithm makes use of "dummy moves", which are
     * put on the stack as fallback entries but do not have any effect on the
     * symbol. A dummy move is of the form
     * <code>Move(D, 0, -1, -1, true)</code> and effectively indicates that
     * the next neighbor to be set is for element D.
     * 
     * @return the next symbol, if any.
     */
	protected DSymbol findNext() throws NoSuchElementException {
		timer.start();
		
        if (LOGGING) {
            System.out.println("#findNext(): stack size = " + this.stack.size());
            System.out.println(("#  current symbol:\n" + this.current
					.tabularDisplay()).replaceAll("\\n", "\n#  "));
        }
        while (true) {
        	if (!resume_point_reached && resume_level >= resume.length) {
        		resume_point_reached = true;
        		if (resume.length > 0) {
        			postCheckpoint("resume point reached");
        		}
            	if (LOGGING) {
            		if (resume_level > resume.length) {
            			System.out.format("#  past resume point at <%s>\n",
            					getCheckpoint());
            		} else {
            			System.out.format("#  resume point reached at <%s>\n",
            					getCheckpoint());
            		}
            	}
        	}
            final Move choice = undoLastChoice();
            if (LOGGING) {
            	if (choice != null && (Integer) choice.neighbor > 0) {
            		System.out.println("#  last choice was " + choice);
                    System.out.println(("#  current symbol:\n" + this.current
    						.tabularDisplay()).replaceAll("\\n", "\n#  "));
            	}
            }
            if (choice == null) {
            	timer.stop();
                throw new NoSuchElementException();
            }
            if (!resume_point_reached && stack.size() < resume_stack_level) {
            	resume_point_reached = true;
        		if (resume.length > 0) {
        			postCheckpoint("resume point reached");
        		}
            	if (LOGGING) {
					System.out.format("#  past resume point at <%s>\n",
							getCheckpoint());
				}
            }
            final Move move = nextMove(choice);
            if (move == null) {
                if (LOGGING) {
                    System.out.println("#  no potential move");
                }
                continue;
            }
            if (LOGGING) {
                System.out.println("#  found potential move " + move);
            }
            boolean incr_level = false;
            if (!resume_point_reached && stack.size() == resume_stack_level) {
            	if (resume_level < resume.length) {
            		if (move.choiceNr == resume[resume_level]) {
            			incr_level = true;
            		}
            	}
            }
            final boolean success = performMove(move);
            postCheckpoint(null);
            if (incr_level) {
            	resume_stack_level = stack.size();
            	resume_level += 1;
            	if (LOGGING) {
            		System.out.format("#  resume level is %d at stack level %d\n",
            				resume_level, resume_stack_level);
            	}
            }
            if (success) {
                if (LOGGING) {
					System.out.println(("#  new symbol after move:\n" +
							this.current.tabularDisplay()).
							replaceAll("\\n","\n#  "));
				}
                if (isCanonical()) {
                	final int D = nextFreeElement(choice.element);
                	if (D == 0) {
                		if (LOGGING) {
                			System.out.println("#  no more moves found");
                		}
                		if (this.size == this.originalSize) {
                			final DSymbol ds = new DSymbol(this.current);
                			if (this.dim != 3
                					|| Utils.mayBecomeLocallyEuclidean3D(ds)) {
                				timer.stop();
                				return new DSymbol(this.current);
                			}
                		}
                	} else if (resume_point_reached ||
                    		stack.size() == resume_stack_level) {
                    	this.stack.addLast(new Move(D, 0, -1, -1, true, 0));
                    } else if (LOGGING) {
                    	System.out.println("#  higher branches are skipped");
                    }
                } else if (LOGGING) {
                	System.out.println("#  result of move is not canonical");
                }
            } else if (LOGGING) {
            	System.out.println("#  move was rejected");
            }
        }
    }

	private void postCheckpoint(final String message) {
		dispatchEvent(
		        new CheckpointEvent(this, !resume_point_reached, message));
	}

    /**
     * Retreives the current checkpoint value as a string.
     * 
     * @return the current checkpoint.
     */
    public String getCheckpoint() {
    	final StringBuffer buf = new StringBuffer(20);
    	for (Move move: stack) {
    		if (move.isChoice) {
    			if (buf.length() > 0) {
    				buf.append('-');
    			}
    			buf.append(move.choiceNr);
    		}
    	}
    	return buf.toString();
    }
    
    /**
     * Sets the point in the search tree at which the algorithm should resume.
     * 
     * @param resume specifies the checkpoint to resume execution at.
     */
    public void setResumePoint(final String spec) {
    	if (spec == null || spec.length() == 0) {
    		return;
    	}
    	final String fields[] = spec.trim().split("-");
    	resume = new int[fields.length];
    	for (int i = 0; i < fields.length; ++i) {
    		resume[i] = Integer.valueOf(fields[i]);
    	}
    }

    /**
     * Undoes the last choice and all its implications by popping moves from the
     * stack until one is found which is a choice. The corresponding neighbor
     * assignment are cleared and the last choice is returned. If there was no
     * choice left on the stack, a <code>null</code> result is returned.
     * 
     * @return the last choice or null.
     */
    private Move undoLastChoice() {
        final IndexList idcs = new IndexList(this.current);
        Move last;
        do {
            if (stack.size() == 0) {
                return null;
            }
            last = this.stack.removeLast();

            if (LOGGING) {
            	if (last.neighbor > 0) {
            		System.out.println("#  undoing " + last);
            	}
            }
            if (this.current.hasElement(last.neighbor)) {
                this.current.undefineOp(this.dim, last.element);
            }
            if (last.newType >= 0 && last.neighbor > 0) {
                for (final int D: this.current.orbit(idcs, last.neighbor)) {
                    this.current.removeElement(D);
                }
                this.current.renumber();
                this.unused[last.newType] += 1;
                this.size = this.current.size();
                this.signatures = elementSignatures(this.current, this.dim - 2);
            }
        } while (!last.isChoice);

        return last;
    }

    /**
     * Finds the next legal move with the same element to connect.
     * 
     * @param choice describes the previous move.
     * @return the next move or null.
     */
    private Move nextMove(final Move choice) {
        final int D = choice.element;
        final Pair<Integer, Integer> sigD = this.signatures.get(D);

        // --- look for a neighbor in the curently connected portion
        for (int E = choice.neighbor + 1; E <= size; ++E) {
            if (!this.current.definesOp(this.dim, E)
                    && sigD.equals(this.signatures.get(E))) {
                return new Move(choice.element, E, -1, -1, true,
						choice.choiceNr + 1);
            }
        }

        // --- look for a new component to connect
        int type = Math.max(0, choice.newType);
        int form = Math.max(0, choice.newForm + 1);
        while (type < this.componentTypes.size()) {
            if (this.unused[type] > 0) {
                final List<DSymbol> forms = this.componentTypes.get(type);
                while (form < forms.size()) {
                    final DSymbol candidate = (DSymbol) forms.get(form);
                    final Map<Integer, Pair<Integer, Integer>> sigs =
                    		elementSignatures(candidate, this.dim - 2);
                    if (sigD.equals(sigs.get(1))) {
                        return new Move(choice.element, this.size + 1, type,
								form, true, choice.choiceNr + 1);
                    }
                    ++form;
                }
            }
            ++type;
            form = 0;
        }

        // --- nothing found
        return null;
    }

    /**
     * Performs a move with all its implications. This includes setting the
     * neighbor relation described by the move, pushing the move on the stack
     * and as well performing all the deduced moves as dictated by the
     * orthogonality of the 3-neighbor operation with the 0- and 1-operations.
     * 
     * @param initial the move to try.
     * @return true if the move did not lead to a contradiction.
     */
    private boolean performMove(final Move initial) {
        // --- a little shortcut
        final DynamicDSymbol ds = this.current;

        // --- we maintain a queue of deductions, starting with the initial move
        final LinkedList<Move> queue = new LinkedList<Move>();
        queue.addLast(initial);

        while (queue.size() > 0) {
            // --- get some info on the next move in the queue
            Move move = queue.removeFirst();
            final int type = move.newType;
            final int form = move.newForm;
            final int D = move.element;
            final int E = move.neighbor;
            final int d = this.dim;

            // --- see if the move would contradict the current state
            if (ds.definesOp(d, D) || ds.definesOp(d, E)) {
                if (ds.definesOp(d, D) && ds.op(d, D).equals(E)) {
                    continue;
                } else {
                    if (LOGGING) {
                        System.out.println("#    found contradiction at " + D
                                + "<-->" + E);
                    }
                    if (move == initial) {
                        // --- the initial move was impossible
                        throw new IllegalArgumentException(
                                "#    internal error: received illegal move.");
                    }
                    return false;
                }
            }

            // --- perform the move
            if (type >= 0) {
                // --- connect a new component
                final DSymbol component =
                		this.componentTypes.get(type).get(form);
                this.current.append(component);
                this.unused[type] -= 1;
                this.size = this.current.size();
                this.signatures = elementSignatures(this.current, this.dim - 2);
            }
            ds.redefineOp(d, D, E);

            // --- record the move we have performed
            this.stack.addLast(move);

            // --- check for any problems with that move
            if (!this.signatures.get(D).equals(this.signatures.get(E))) {
                if (LOGGING) {
                    System.out.println(
                    		"#    bad connection " + D + "<-->" + E + ".");
                }
                return false;
            }

            // --- add default deductions
            for (int i = 0; i <= d - 2; ++i) {
                final int Di = ds.op(i, D);
                final int Ei = ds.op(i, E);
                if (LOGGING) {
                    System.out.println(
                    		"#    found deduction " + Di + "<-->" + Ei);
                }
                queue.addLast(new Move(Di, Ei, -1, -1, false, 0));
            }

            // --- handle application specific deductions and contradictions
			final List<Move> extraDeductions = getExtraDeductions(ds, move);
			if (extraDeductions == null) {
				return false;
			} else {
				for (final Move ded : extraDeductions) {
					if (LOGGING) {
						System.out.println("#    extra deduction " + ded);
					}
					queue.addLast(ded);
				}
			}
        }

        // --- everything went smoothly
        return true;
    }

    /**
     * Tests if the current symbol is in canonical form with respect to this
     * generator class. That means it is the form of the symbol that should be
     * reported.
     * 
     * @return true if the symbol is canonical.
     */
    private boolean isCanonical() {
        final DSymbol flat = new DSymbol(this.current);
        return flat.getMapToCanonical().get(1).equals(1);
    }

    /**
     * Finds the next symbol element with an undefined d-neighbor, starting from
     * the given element.
     * 
     * @param element to start the search at.
     * @return the next unconnected element.
     */
    private int nextFreeElement(final int element) {
    	int D = element;
        do {
            if (++D > this.size) {
                return 0;
            }
        } while (this.current.definesOp(this.dim, D));

        return D;
    }

    /**
     * Computes signatures for the elements of symbol.
     * 
     * @param ds the symbol to compute signatures for.
     * @param dim
     * @return a map assigning signatures to the symbol's elements.
     */
    public Map<Integer, Pair<Integer, Integer>> elementSignatures(
    		final DelaneySymbol<Integer> ds,
			final int dim)
	{
    	signatureTimer.start();
        final Map<Integer, Pair<Integer, Integer>> signatures =
        		new HashMap<Integer, Pair<Integer, Integer>>();
        final List<Integer> idcs = new ArrayList<Integer>();
        for (int i = 0; i <= dim; ++i) {
            idcs.add(i);
        }

        for (final int D: ds.orbitReps(idcs)) {
            final DelaneySymbol<Integer> face =
            		new Subsymbol<Integer>(ds, idcs, D);
            final Invariant invariant = new Invariant(face.invariant());
            if (!this.invarToIndex.containsKey(invariant)) {
                final int i = this.indexToRepMap.size();
                this.invarToIndex.put(invariant, i);
                final DSymbol canon = (DSymbol) face.canonical();
                this.indexToRepMap.add(mapToFirstRepresentatives(canon));
            }
            final Integer i = this.invarToIndex.get(invariant);
            final Map<Integer, Integer> toRep = this.indexToRepMap.get(i);
            final Map<Integer, Integer> toCanon = face.getMapToCanonical();
            for (final int E: face.elements()) {
                final int rep = toRep.get(toCanon.get(E));
                signatures.put(E, new Pair<Integer, Integer>(i, rep));
            }
        }
        signatureTimer.stop();

        return signatures;
    }

    /**
     * Collects the isomorphism types of connected components of a symbol and
     * counts how many times each type occurs. The result is a map with
     * {@link DSymbol} instances as its keys and the associated multiplicities
     * as values.
     * 
     * @param ds the input symbol.
     * @return a map assigning to each component type the number of occurences.
     */
    public static Map<DelaneySymbol<Integer>, Integer> componentMultiplicities(
			final DelaneySymbol<Integer> ds) {
        final Map<DelaneySymbol<Integer>, Integer> type2number =
        	new HashMap<DelaneySymbol<Integer>, Integer>();
        final IndexList idcs = new IndexList(ds);
        for (final int D: ds.orbitReps(idcs)) {
            final DelaneySymbol<Integer> sub =
            		new Subsymbol<Integer>(ds, idcs, D).canonical();
            if (type2number.containsKey(sub)) {
                type2number.put(sub, type2number .get(sub) + 1);
            } else {
                type2number.put(sub, 1);
            }
        }
        return type2number;
    }

    /**
     * Takes a connected symbol and computes the first representative of each
     * equivalence class of its elements with respect to its automorphism group.
     * 
     * @param ds the symbol to use.
     * @return the list of first representatives.
     */
    public static List<Integer> firstRepresentatives(
    		final DelaneySymbol<Integer> ds)
    {
        final Map<Integer, Integer> map = mapToFirstRepresentatives(ds);
        final List<Integer> res = new ArrayList<Integer>();
        for (final int D: ds.elements()) {
            if (D == map.get(D)) {
                res.add(D);
            }
        }
        return res;
    }

    /**
     * Takes a connected symbol and returns a map that to each element assigns
     * the first representative of its equivalence class with respect to the
     * symbol's automorphism group.
     * 
     * @param ds the symbol to use.
     * @return the map from elements to first representatives.
     */
    public static Map<Integer, Integer> mapToFirstRepresentatives(
			final DelaneySymbol<Integer> ds)
	{
        if (!ds.isConnected()) {
            throw new UnsupportedOperationException("symbol must be connected");
        }

        final Map<Integer, Integer> res = new HashMap<Integer, Integer>();
        final Iterator<Integer> elms = ds.elements();
        if (elms.hasNext()) {
            final int first = elms.next();
            final Partition<Integer> classes = new Partition<Integer>();
            while (elms.hasNext()) {
                final int D = elms.next();
                if (classes.areEquivalent(first, D)) {
                    continue;
                }
                final DSMorphism<Integer, Integer> morphism;
                try {
                    morphism =
                    		new DSMorphism<Integer, Integer>(ds, ds, first, D);
                } catch (IllegalArgumentException ex) {
                    continue;
                }
                for (final int E: ds.elements()) {
                    classes.unite(E, morphism.get(E));
                }
            }

            for (final int D: ds.elements()) {
                final int E = classes.find(D);
                if (!res.containsKey(E)) {
                    res.put(D, D);
                    res.put(E, D);
                } else {
                    res.put(D, res.get(E));
                }
            }
        }
        return res;
    }

    /**
     * Returns the list of distinct subcanonical forms for a given connected
     * symbol. A subcanonical form is obtained by assigning numbers to the
     * elements in the order they are visited by a standard traversal starting
     * from an arbitrary element.
     * 
     * @param ds the input symbol.
     * @return the list of subcanonical forms.
     */
    public static List<DSymbol> subCanonicalForms(
    		final DelaneySymbol<Integer> ds)
    {
        if (!ds.isConnected()) {
            throw new UnsupportedOperationException("symbol must be connected");
        }
        if (!ds.hasStandardIndexSet()) {
            throw new UnsupportedOperationException(
                    "symbol must have indices 0..dim");
        }

        final List<DSymbol> res = new LinkedList<DSymbol>();

        final int size = ds.size();
        final int dim = ds.dim();
        final IndexList idcs = new IndexList(ds);

        final List<Integer> reps = firstRepresentatives(ds);
        for (final int seed: reps) {
            final Traversal<Integer> trav =
                    new Traversal<Integer>(ds, idcs, seed, true);

            // --- elements will be numbered in the order they appear
            final HashMap<Object, Integer> old2new =
            	new HashMap<Object, Integer>();

            // --- follow the traversal and assign the new numbers
            int nextE = 1;
            while (trav.hasNext()) {
                // --- retrieve the next edge
                final DSPair<Integer> e = trav.next();
                final int D = e.getElement();

                // --- determine a running number E for the target element D
                final Integer tmp = old2new.get(D);
                if (tmp == null) {
                    // --- element D is encountered for the first time
                    old2new.put(D, nextE);
                    ++nextE;
                }
            }

            // --- construct the new symbol
            int op[][] = new int[dim + 1][size + 1];
            int v[][] = new int[dim][size + 1];

            for (final int E: ds.elements()) {
                final int D = old2new.get(E);
                for (int i = 0; i <= dim; ++i) {
                    op[i][D] = old2new.get(ds.op(i, E));
                    if (i < dim) {
                        v[i][D] = ds.v(i, i + 1, E);
                    }
                }
            }

            // --- add it to the list
            res.add(new DSymbol(op, v));
        }

        // --- finis
        return res;
    }

    /**
     * Hook for derived classes to specify additional deductions of a move.
     * 
     * @param ds the current symbol.
     * @param move the last move performed.
     * @return the list of deductions (may be empty) or null in case of a
     *         contradiction.
     */
    protected List<Move> getExtraDeductions(
            final DelaneySymbol<Integer> ds,
			final Move move)
	{
		return new ArrayList<Move>();
	}

    public static void main(final String[] args) {
        DSymbol ds;
        boolean verbose = false;
        boolean useCover = false;
        int i;
        String resume = null;
        
		i = 0;
		while (i < args.length && args[i].startsWith("-")) {
			if (args[i].equals("-v")) {
				verbose = !verbose;
			} else if (args[i].equals("-c")) {
				useCover = !useCover;
			} else if (args[i].equals("-r")) {
				resume = args[++i];
			}
			++i;
		}
		if (i < args.length) {
			 ds = new DSymbol(args[i]);
		} else {
			throw new RuntimeException("no input symbol given");
		}
		if (useCover) {
			ds = Covers.finiteUniversalCover(ds);
		}
		
        final Stopwatch timer = new Stopwatch();
        final CombineTiles iter = new CombineTiles(ds);
        iter.addEventLink(CheckpointEvent.class, new EventProcessor() {
            @Override
            public void handleEvent(final Object event) {
                final CheckpointEvent ev = (CheckpointEvent) event;
				timer.reset();
				System.out.format("#@@@ %sCheckpoint %s\n", ev.isOld() ? "Old "
						: "", ev.getSource().getCheckpoint());
			}
		});
        iter.setResumePoint(resume);

        int count = 0;
        try {
        	for (final DSymbol out: iter) {
                System.out.println(out);
                ++count;
            }
        } catch (Exception ex) {
            ex.printStackTrace(System.err);
        }
        System.out.println("# produced " + count + " symbols");
    }
}
