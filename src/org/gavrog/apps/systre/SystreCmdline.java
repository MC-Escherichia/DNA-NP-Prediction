/*
Copyright 2010 Olaf Delgado-Friedrichs

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

package org.gavrog.apps.systre;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import org.gavrog.box.collections.Iterators;
import org.gavrog.box.collections.Pair;
import org.gavrog.box.gui.Config;
import org.gavrog.box.simple.DataFormatException;
import org.gavrog.box.simple.Misc;
import org.gavrog.box.simple.Strings;
import org.gavrog.jane.numbers.FloatingPoint;
import org.gavrog.jane.numbers.IArithmetic;
import org.gavrog.jane.numbers.Real;
import org.gavrog.jane.numbers.Whole;
import org.gavrog.joss.geometry.CoordinateChange;
import org.gavrog.joss.geometry.Operator;
import org.gavrog.joss.geometry.Point;
import org.gavrog.joss.geometry.SpaceGroup;
import org.gavrog.joss.geometry.SpaceGroupCatalogue;
import org.gavrog.joss.geometry.SpaceGroupFinder;
import org.gavrog.joss.geometry.Vector;
import org.gavrog.joss.pgraphs.basic.INode;
import org.gavrog.joss.pgraphs.basic.Morphism;
import org.gavrog.joss.pgraphs.basic.PeriodicGraph;
import org.gavrog.joss.pgraphs.embed.Embedder;
import org.gavrog.joss.pgraphs.embed.ProcessedNet;
import org.gavrog.joss.pgraphs.io.Archive;
import org.gavrog.joss.pgraphs.io.Net;
import org.gavrog.joss.pgraphs.io.NetParser;

import buoy.event.EventSource;

/**
 * The basic commandlne version of Gavrog Systre.
 * 
 * @author Olaf Delgado
 */
public class SystreCmdline extends EventSource {
    final static boolean DEBUG = false;
    
    static {
        Locale.setDefault(Locale.US);
    }
    private final static DecimalFormat fmtReal4 = new DecimalFormat("0.0000");

    // --- the last structure processed
    ProcessedNet lastStructure = null;
    
    // --- the output stream
    private PrintStream out = System.out;
    
    // --- the various archives
    private final Archive builtinArchive;
    private final Archive zeoliteArchive;
    private final Map name2archive = new HashMap();
    private final Archive internalArchive = new Archive("1.0");
    
    // --- options
    private boolean computeEmbedding = true;
    private boolean relaxPositions = true;
    private int relaxPasses = 3;
    private int relaxSteps = 10000;
    private boolean useBuiltinArchive = true;
    private boolean outputFullCell = false;
    private boolean outputSystreKey = false;
    private boolean duplicateIsError = false;
    private BufferedWriter outputArchive = null;
    
    // --- the last file that was opened for processing
    private String lastFileNameWithoutExtension;
    
    // --- signals a cancel request from outside
    private boolean cancelled = false;

    // --- text of the last status reported
	private String lastStatus;
    
    /**
     * Constructs an instance.
     */
    public SystreCmdline() {
        builtinArchive = new Archive("1.0");
        zeoliteArchive = new Archive("1.0");

        // --- read the default archives
        final Package pkg = this.getClass().getPackage();
        final String packagePath = pkg.getName().replaceAll("\\.", "/");
        
        final String rcsrPath = packagePath + "/rcsr.arc";
        final InputStream rcsrStream = ClassLoader.getSystemResourceAsStream(rcsrPath);
        builtinArchive.addAll(new InputStreamReader(rcsrStream));
        final String zeoPath = packagePath + "/zeolites.arc";
        final InputStream zeoStream = ClassLoader.getSystemResourceAsStream(zeoPath);
        zeoliteArchive.addAll(new InputStreamReader(zeoStream));
    }
    
    /**
     * Reads an archive file and stores it internally.
     * 
     * @param filename the name of the archive file.
     */
    public void processArchive(final String filename) {
        final String name = filename;
        if (this.name2archive.containsKey(name)) {
            out.println("!!! WARNING (USAGE) - Archive \"" + name + "\" was given twice.");
        } else {
            final Archive arc = new Archive("1.0");
            try {
                arc.addAll(new FileReader(filename));
            } catch (FileNotFoundException ex) {
				out.println("!!! ERROR (FILE) - Could not find file \"" + filename
						+ "\".");
				return;
			} catch (Exception ex) {
				out.println("!!! ERROR (FILE) - " + ex.getMessage()
						+ " - ignoring archive \"" + filename + "\".");
				return;
			}
            this.name2archive.put(name, arc);
            final int n = arc.size();
            out.println("Read " + n + " entr" + (n == 1 ? "y" : "ies")
                        + " from archive \"" + name + "\"");
            out.println();
        }
    }
    
    public void processGraph(final Net graph, String name, final boolean embed) {

    	status("Initializing...");
    	
    	// enable this code to test error handling
//    	if (graph != null) {
//    		throw new RuntimeException("this is not a love song");
//    	}
    	
    	this.cancelled = false;
        setLastStructure(null);
        PeriodicGraph G = graph;
        final int d = G.getDimension();
        final String givenGroup = graph.getGivenGroup();
        
        if (DEBUG) {
            out.println("\t\t@@@ Graph is " + G);
        }
        
        // --- print some information on net as given
        out.println("   Input structure described as " + d + "-periodic.");
        out.println("   Given space group is " + givenGroup + ".");
        out.flush();
        final int n = G.numberOfNodes();
        final int m = G.numberOfEdges();
        out.println("   " + n + " node" + (n > 1 ? "s" : "") + " and " + m
				+ " edge" + (m > 1 ? "s" : "") + " in repeat unit as given.");
        out.flush();

        // --- test if the net is connected
        if (!G.isConnected()) {
        	processDisconnectedGraph(graph, name);
        	return;
        }
        // --- get and check the barycentric placement
    	status("Computing barycentric placement...");
    	
        final Map barycentric = G.barycentricPlacement();
        if (!G.isBarycentric(barycentric)) {
            final String msg = "Incorrect barycentric placement.";
            throw new RuntimeException(msg);
        }
        if (DEBUG) {
            out.println("\t\t@@@ barycentric placement:");
            for (final Iterator nodes = G.nodes(); nodes.hasNext();) {
                final INode v = (INode) nodes.next();
                out.println("\t\t@@@    " + v.id() + " -> " + barycentric.get(v));
            }
        }
        out.println();
        out.flush();
        
        quitIfCancelled();
        
        // --- test if it is Systre-compatible
        if (!G.isLocallyStable()) {
            throw new SystreException(SystreException.STRUCTURE,
            		"Structure has collisions between next-nearest neighbors." +
            		" Systre does not currently support such structures.");
        }
        if (G.isLadder()) {
            final String msg = "Structure is non-crystallographic (a 'ladder')";
            throw new SystreException(SystreException.STRUCTURE, msg);
        }
        if (!G.isStable()) {
            final String msg = "!!! WARNING (STRUCTURE) - "
                + "Structure has collisions. Output embedding may be incorrect.";
            out.println(msg);
            out.println();
        }
        
        quitIfCancelled();

        // --- determine a minimal repeat unit
    	status("Computing ideal repeat unit...");
    	
    	final Morphism M = G.minimalImageMap();
        G = M.getImageGraph();
        final int r = n / G.numberOfNodes();
        if (r > 1) {
            out.println("   Ideal repeat unit smaller than given ("
                    + G.numberOfEdges() + " vs " + m + " edges).");
            if (DEBUG) {
                out.println("\t\t@@@ minimal graph is " + G);
            }
        } else {
            out.println("   Given repeat unit is accurate.");
        }
        
        quitIfCancelled();

        // --- determine the ideal symmetries
    	status("Computing ideal symmetry group...");
    	
        final List ops = G.symmetryOperators();
        if (DEBUG) {
            out.println("\t\t@@@ symmetry operators:");
            for (final Iterator iter = ops.iterator(); iter.hasNext();) {
                out.println("\t\t@@@    " + iter.next());
            }
        }
        out.println("   Point group has " + ops.size() + " elements.");
        out.flush();
        final int k = Iterators.size(G.nodeOrbits());
        out.println("   " + k + " kind" + (k > 1 ? "s" : "") + " of node.");
        out.println();
        out.flush();
        
        quitIfCancelled();
        
        // --- name node orbits according to input names
        status("Mapping node names...");
        
        final Map node2orbit = new HashMap();
        for (final Iterator orbits = G.nodeOrbits(); orbits.hasNext();) {
        	final Set orbit = (Set) orbits.next();
        	for (final Iterator inOrbit = orbit.iterator(); inOrbit.hasNext();) {
        		node2orbit.put(inOrbit.next(), orbit);
        	}
        }
        
        final Map orbit2name = new HashMap();
        final Map orbit2cs = new HashMap();
        final Map name2orbit = new HashMap();
        final Map node2name = new HashMap();
        final Set mergedNames = new LinkedHashSet();
        final Net G0 = (Net) M.getSourceGraph();
        for (final Iterator nodes = G0.nodes(); nodes.hasNext();) {
        	final INode v = (INode) nodes.next();
        	final String nodeName = G0.getNodeName(v);
        	final INode w = (INode) M.get(v);
        	final Set orbit = (Set) node2orbit.get(w);
        	if (orbit2name.containsKey(orbit) && !nodeName.equals(orbit2name.get(orbit))) {
				mergedNames.add(new Pair(nodeName, orbit2name.get(orbit)));
			} else {
        		orbit2name.put(orbit, nodeName);
        		final Integer conn = (Integer) G0.getNodeInfo(v, NetParser.CONNECTIVITY);
        		if (conn != null && conn.intValue() != 0 && conn.intValue() != v.degree()) {
        			String msg = "Node " + v + " has connectivity " + v.degree()
        				+ ", where " + conn + " was expected";
    				throw new SystreException(SystreException.INPUT, msg);
        		}
        		orbit2cs.put(orbit, G0.getNodeInfo(v, NetParser.COORDINATION_SEQUENCE));
        	}
    		node2name.put(w, orbit2name.get(orbit));
        	if (!name2orbit.containsKey(nodeName)) {
				name2orbit.put(nodeName, orbit);
			} else if (name2orbit.get(nodeName) != orbit) {
				final String msg = "Some input symmetries were lost";
				throw new SystreException(SystreException.INTERNAL, msg);
			}
		}
        
        if (mergedNames.size() > 0) {
			out.println("   Equivalences for non-unique nodes:");
			for (final Iterator items = mergedNames.iterator(); items.hasNext();) {
				final Pair item = (Pair) items.next();
				final String old = Strings.parsable((String) item.getFirst(), false);
				final String nu = Strings.parsable((String) item.getSecond(), false);
				out.println("      " + old + " --> " + nu);
			}
			out.println();
		}
        
        quitIfCancelled();
        
        // --- determine the coordination sequences
    	status("Computing coordination sequences...");
    	
        out.println("   Coordination sequences:");
        int cum = 0;
        boolean cs_complete = true;
        for (final Iterator orbits = G.nodeOrbits(); orbits.hasNext();) {
            final Set orbit = (Set) orbits.next();
            final INode v = (INode) orbit.iterator().next();
            out.print("      Node " + Strings.parsable((String) node2name.get(v), false)
					+ ":   ");
            final List givenCS = (List) orbit2cs.get(orbit);
            final Iterator cs = G.coordinationSequence(v);
            cs.next();
            int sum = 1;
            boolean mismatch = false;
            for (int i = 0; i < 10; ++i) {
            	final int x = ((Integer) cs.next()).intValue();
                out.print(" " + x);
                out.flush();
                sum += x;
                if (givenCS != null && i < givenCS.size()) {
                	final int y = ((Whole) givenCS.get(i)).intValue();
                	if (x != y) {
                		mismatch = true;
                	}
                }
                if (sum > 10000) {
                    cs_complete = false;
                    break;
                }
            }
            out.println();
            cum += orbit.size() * sum;
            if (mismatch) {
        		final String msg = "Computed CS does not match input";
				throw new SystreException(SystreException.INPUT, msg);
            }
        }
        out.println();
        if (cs_complete) {
            out.println("   TD10 = "
                    + fmtReal4.format(((double) cum) / G.numberOfNodes()));
            out.println();
        }
        out.flush();
        
        quitIfCancelled();
        
        // --- find the space group name and conventional settings
    	status("Looking up the space group and transforming to a standard setting...");
    	
        final SpaceGroup group = new SpaceGroup(d, ops);
        final SpaceGroupFinder finder = new SpaceGroupFinder(group);
        final String groupName = finder.getGroupName();
        final String extendedGroupName = finder.getExtendedGroupName();
        final CoordinateChange toStd = finder.getToStd();
        out.println("   Ideal space group is " + groupName + ".");
        final String givenName = SpaceGroupCatalogue.normalizedName(givenGroup);
        if (!givenName.equals(groupName)) {
            out.println("   Ideal group differs from given (" + groupName
                    + " vs " + givenName + ").");
        }
        final String ext = finder.getExtension();
        if ("1".equals(ext)) {
        	out.println("     (using first origin choice)");
        } else if ("2".equals(ext)) {
        	out.println("     (using second origin choice)");
        } else if ("H".equals(ext)) {
        	out.println("     (using hexagonal setting)");
        } else if ("R".equals(ext)) {
        	out.println("     (using rhombohedral setting)");
        }
        if (DEBUG) {
            out.println("\t\t@@@ transformed operators:");
            for (final Iterator iter = toStd.applyTo(ops).iterator(); iter.hasNext();) {
                out.println("\t\t@@@    " + iter.next());
            }
        }
        out.println();
        out.flush();
        
        quitIfCancelled();
        
        // --- verify the output of the spacegroup finder
    	status("Verifying the space group setting...");
    	
        final CoordinateChange trans = SpaceGroupCatalogue
				.transform(d, extendedGroupName);
        if (!trans.isOne()) {
            final String msg = "Produced non-conventional space group setting.";
            throw new RuntimeException(msg);
        }
        final Set conventionalOps = new SpaceGroup(d, extendedGroupName)
				.primitiveOperators();
        final Set opsFound = new HashSet();
        opsFound.addAll(ops);
        for (int i = 0; i < d; ++i) {
            opsFound.add(new Operator(Vector.unit(d, i)));
        }
        final Set probes = new SpaceGroup(d, toStd.applyTo(opsFound)).primitiveOperators();
        if (!probes.equals(conventionalOps)) {
            out.println("Problem with space group operators - should be:");
            for (final Iterator iter = conventionalOps.iterator(); iter.hasNext();) {
                out.println(iter.next());
            }
            out.println("but was:");
            for (final Iterator iter = toStd.applyTo(opsFound).iterator(); iter.hasNext();) {
                out.println(iter.next());
            }
            final String msg = "Spacegroup finder messed up operators.";
            throw new RuntimeException(msg);
        }
        
        quitIfCancelled();
        
        // --- determine the Systre key and look it up in the archives
    	status("Computing the unique invariant (a.k.a. Systre key) for this net...");
    	
        final String invariant = G.getSystreKey();
        if (getOutputSystreKey()) {
        	out.println("   Systre key: \"" + invariant + "\"");
        }

        status("Looking for isomorphic nets...");
    	
        int countMatches = 0;
        Archive.Entry found = null;
        if (this.useBuiltinArchive) {
            found = builtinArchive.getByKey(invariant);
            if (found != null) {
                ++countMatches;
                out.println("   Structure was identified with RCSR symbol:");
                writeEntry(out, found);
                out.println();
            }
            found = zeoliteArchive.getByKey(invariant);
            if (found != null) {
                ++countMatches;
                out.println("   Structure was identified as zoelite framework type:");
                writeEntry(out, found);
                out.println();
            }
        }
        for (Iterator iter = this.name2archive.keySet().iterator(); iter.hasNext();) {
            final String arcName = (String) iter.next();
            final Archive arc = (Archive) this.name2archive.get(arcName);
            found = arc.getByKey(invariant);
            if (found != null) {
                ++countMatches;
                out.println("   Structure was found in archive \"" + arcName + "\":");
                writeEntry(out, found);
                out.println();
            }
        }
        found = this.internalArchive.getByKey(invariant);
        if (found != null) {
            if (this.duplicateIsError) {
				final String msg = "Duplicates structure "
						+ Strings.parsable(found.getName(), true);
				throw new SystreException(SystreException.INPUT, msg);
			}
            ++countMatches;
            out.println("   Structure already seen in this run.");
            writeEntry(out, found);
            out.println();
        }
        final String arcName = name == null ? "nameless" : name;
        if (countMatches == 0) {
        	status("Storing the Systre key for this net...");
        	
            out.println("   Structure is new for this run.");
            out.println();
			if (this.internalArchive.get(invariant) != null) {
                final String msg = "!!! WARNING (ARCHIVE) - "
                	+ "Overwriting previous isomorphic net.";
                out.println(msg);
                out.println();
			}
			if (this.internalArchive.get(arcName) != null) {
                final String msg = "!!! WARNING (ARCHIVE) - "
                	+ "Overwriting previous net with the same name";
                out.println(msg);
                out.println();
			}
            final Archive.Entry entry = this.internalArchive.add(G, arcName);
            if (this.outputArchive != null) {
                try {
                    this.outputArchive.write(entry.toString());
                    this.outputArchive.write("\n");
				this.outputArchive.flush();
                } catch (IOException ex) {
					final String msg = "Could not write to archive";
					throw new SystreException(SystreException.FILE, msg);
				}
            }
        }
        out.flush();
        
        quitIfCancelled();
        
        // --- compute an embedding
        if (getComputeEmbedding()) {
        	embedGraph(G, name, node2name, finder);
        } else {
        	setLastStructure(new ProcessedNet(G, name, node2name, finder, null));
        }
    }

    /**
     * Processes the components of a disconnected graph.
     * 
	 * @param graph the graph to process.
	 * @param name the name to use for archiving.
	 */
	private void processDisconnectedGraph(final Net graph, final String name) {
		out.println();
		out.println("   Structure is not connected.");
		out.println("   Processing components separately.");
		out.println();
		out.println("   ==========");
		final List components = graph.connectedComponents();
		for (int i = 1; i <= components.size(); ++i) {
			final PeriodicGraph.Component c = (PeriodicGraph.Component) components
					.get(i-1);
			out.println("   Processing component " + i + ":");
			if (c.getDimension() < graph.getDimension()) {
				out.println("      dimension = " + c.getDimension());
			} else {
				out.println("      multiplicity = " + c.getMultiplicity());
			}
			final String cName = name + "_component_" + i;
			processGraph(new Net(c.getGraph(), cName, "P1"), cName, false);
			out.println();
			out.println("   Finished component " + i + ".");
			out.println();
			out.println("   ==========");
		}
	}

	private void writeEntry(final PrintStream out, final Archive.Entry entry) {
        out.println("       Name:\t\t" + entry.getName());
        if (entry.getDescription() != null) {
            out.println("       Description:\t" + entry.getDescription());
        }
        if (entry.getReference() != null) {
            out.println("       Reference:\t" + entry.getReference());
        }
        if (entry.getURL() != null) {
            out.println("       URL:\t\t" + entry.getURL());
        }
    }
    
    private void embedGraph(final PeriodicGraph G, final String name,
			final Map node2name, final SpaceGroupFinder finder) {

    	for (int pass = 0; pass <= 1; ++pass) {
        	status("Computing an embedding...");
        	
            // --- relax the structure from the barycentric embedding
            Embedder embedder = new Embedder(G);
            try {
                embedder.setRelaxPositions(false);
                embedder.go(500);
                embedder.setRelaxPositions(relaxPositions && pass == 0);
                embedder.setPasses(this.relaxPasses);
                embedder.go(relaxSteps);
            } catch (Exception ex) {
                out.println("==================================================");
                final String msg = "!!! WARNING (INTERNAL) - Could not relax - ";
                out.println(msg + ex.getMessage());
                out.println(Misc.stackTrace(ex));
                out.println("==================================================");
                embedder.reset();
            }
            embedder.normalize();
            
            quitIfCancelled();
            
            // --- do some checking
        	status("Verifying the embedding...");
        	
            final IArithmetic det = embedder.getGramMatrix().determinant();
            if (det.isLessThan(new FloatingPoint(0.001))) {
                out.println("==================================================");
                final String msg = "!!! WARNING (INTERNAL) - "
						+ "Unit cell degenerated in relaxation.";
                out.println(msg);
                out.println("==================================================");
                embedder.reset();
                embedder.normalize();
            }
            if (!embedder.positionsRelaxed()) {
                final Map pos = embedder.getPositions();
                final Map bari = G.barycentricPlacement();
                int problems = 0;
                for (final Iterator nodes = G.nodes(); nodes.hasNext();) {
                    final INode v = (INode) nodes.next();
                    final Point p = (Point) pos.get(v);
                    final Point q = (Point) bari.get(v);
                    final Vector diff = (Vector) p.minus(q);
                    final double err = ((Real) Vector.dot(diff, diff)).sqrt()
                            .doubleValue();
                    if (err > 1e-12) {
                        out.println("\t\t@@@ " + v + " is at " + p + ", but should be "
                                    + q);
                        ++problems;
                    }
                }
                if (problems > 0) {
                    final String msg = "Embedder misplaced " + problems + " points";
                    throw new SystreException(SystreException.INTERNAL, msg);
                }
            }
            
            quitIfCancelled();
            
            // --- write a Systre readable net description to a string buffer
        	status("Preparing the output...");
        	
            final StringWriter cgdStringWriter = new StringWriter();
            final PrintWriter cgd = new PrintWriter(cgdStringWriter);
            final ProcessedNet net = new ProcessedNet(G, name, node2name, finder,
					embedder);
            setLastStructure(net);
            net.writeEmbedding(cgd, true, getOutputFullCell());

            final String cgdString = cgdStringWriter.toString();
			boolean success = false;
            try {
                if (G.isStable()) {
                    status("Consistency test: reading output back in...");
                    final PeriodicGraph test = NetParser.stringToNet(cgdString);

                    quitIfCancelled();

                    status("Consistency test: comparing with original net...");
                    if (!test.minimalImage().equals(G)) {
                        final String msg = "Output does not match original graph.";
                        throw new RuntimeException(msg);
                    }
                }
                out.println();
                success = true;
                
                quitIfCancelled();
                
            } catch (Exception ex) {
                if (DEBUG) {
                    out.println("\t\t@@@ Failing output:");
                    out.println(cgdString);
                }
                if (pass == 0) {
                    if (relaxPositions) {
                        out.println("   Falling back to barycentric positions.");
                    }
                } else {
                    out.println("Could not verify output:");
                    out.println(cgdString);
                    throw new RuntimeException(ex);
                }
            }
            
            quitIfCancelled();
            
            // --- now write the actual output
            if (success) {
            	status("Writing output...");
                net.writeEmbedding(new PrintWriter(out), false, getOutputFullCell());
                net.setVerified(true);
                status("Done!");
                break;
            }
        }
    }
    
    /**
	 * Analyzes all nets specified in a file and prints the results.
	 * 
	 * @param filePath
	 *            the name of the input file.
	 */
    public void processDataFile(final String filePath) {
        // --- set up a parser for reading input from the given file
        Iterator inputs = null;
        int count = 0;
        try {
            inputs = Net.iterator(filePath);
        } catch (FileNotFoundException ex) {
            out.println("!!! ERROR (FILE) - Could not find file \"" + filePath + "\".");
            return;
        } catch (Net.IllegalFileNameException ex) {
            out.println("!!! ERROR (FILE) - " + ex.getMessage());
        }
        this.lastFileNameWithoutExtension = new File(filePath).getName().replaceFirst(
                "\\..*$", "");
        out.println("Data file \"" + filePath + "\".");
        
        // --- loop through the structures specified in the input file
        while (inputs.hasNext()) {
            Net G = null;
            Exception problem = null;
            
            // --- read the next net
            status("Reading...");
            try {
                G = (Net) inputs.next();
            } catch (Exception ex) {
                problem = ex;
            }
            ++count;
            
            // --- some blank lines as separators
            out.println();
            if (count > 1) {
                out.println();
                out.println();
            }
            
            // --- process the graph
            String name = null;
            try {
                name = G.getName();
            } catch (Exception ex) {
                if (problem == null) {
                    problem = ex;
                }
            }
            if (problem == null && !G.isOk()) {
            	problem = (Exception) G.getErrors().next();
            }
            final String archiveName;
            final String displayName;
            if (name == null) {
                archiveName = lastFileNameWithoutExtension + "-#" + count;
                displayName = "";
            } else {
                archiveName = name;
                displayName = Strings.parsable(name, true);
            }
            
            out.println("Structure #" + count + " - " + displayName + ".");
            out.println();
            if (problem != null) {
            	if (problem instanceof DataFormatException) {
                    out.println("==================================================");
            		out.println("!!! ERROR (INPUT) - " + problem.getMessage());
            		reportErrorLocation(count, displayName);
                    out.println("==================================================");
            	} else {
            		reportError(problem, count, displayName);
            	}
            } else {
                try {
                    processGraph(G, archiveName, true);
                } catch (SystreException ex) {
                    out.println("==================================================");
                    out.println("!!! ERROR (" + ex.getType() + ") - " + ex.getMessage()
							+ ".");
            		reportErrorLocation(count, displayName);
                    out.println("==================================================");
                } catch (Exception ex) {
                	reportError(ex, count, displayName);
                }
            }
            out.println();
			out.println("Finished structure #" + count + " - " + displayName + ".");
        }

        out.println();
        out.println("Finished data file \"" + filePath + "\".");
    }
    
    /**
     * Reports an error that occurred during the reading or processing of a graph.
     * 
     * @param ex the exception thrown.
     * @param count the running number of the graph in the current file.
     * @param name the name of the graph.
     */
    private void reportError(final Throwable ex, final int count, final String name) {
        out.println("==================================================");
        out.println("!!! ERROR (INTERNAL) - Unexpected " + ex.getClass().getName() + ": "
				+ ex.getMessage());
        reportErrorLocation(count, name);
        out.println("!!!    Stack trace:");
        out.print(Misc.stackTrace(ex, "!!!       "));
        out.println("==================================================");
    }
    
    private void reportErrorLocation(final int count, final String name) {
        out.println("!!!    In structure #" + count + " - " + name + ".");
        out.println("!!!    Last status: " + this.lastStatus);
    }
    
    /**
     * Writes all the entries read from data files onto a stream.
     * 
     * @param writer represents the output stream.
     * @throws IOException if writing to the stream did not work.
     */
    public int writeInternalArchive(final Writer writer) throws IOException {
    	return writeArchive(writer, this.internalArchive);
    }
    
    /**
     * Writes all the entries from Systre's builtin archive onto a stream.
     * 
     * @param writer represents the output stream.
     * @throws IOException if writing to the stream did not work.
     */
    public int writeBuiltinArchive(final Writer writer) throws IOException {
    	return writeArchive(writer, this.builtinArchive);
    }
    
    private int writeArchive(final Writer writer, final Archive archive)
			throws IOException {
		int count = 0;
        for (Iterator iter = archive.keySet().iterator(); iter.hasNext();) {
            final String key = (String) iter.next();
            final Archive.Entry entry = archive.getByKey(key);
            writer.write(entry.toString());
            ++count;
        }
        return count;
    }
    
    /**
     * This method takes command line arguments one by one and passes them to
     * {@link #processDataFile} or {@link #processArchive}.
     * 
     * @param args the command line arguments.
     */
    public void run(final String args[]) {
        final List files = new LinkedList();
        final List archives = new LinkedList();
        boolean archivesAsInput = false;
        String outputArchiveFileName = null;
        
        for (int i = 0; i < args.length; ++i) {
            final String s = args[i];
            if (s.equals("-b")
                    || s.equalsIgnoreCase("--barycentric")
                    || s.equalsIgnoreCase("-barycentric")) {
                setRelaxPositions(false);
            } else if (s.equals("-d")) {
            	setDuplicateIsError(true);
            } else if (s.equals("-a")) {
                if (i == args.length - 1) {
                    out.println("!!! WARNING (USAGE) - Argument missing for \""
                            + s + "\".");
                } else {
                    outputArchiveFileName = args[++i];
                }
            } else if (s.equalsIgnoreCase("--skipEmbedding")
                    || s.equalsIgnoreCase("-skipEmbedding")) {
                setComputeEmbedding(false);
            } else if (s.equalsIgnoreCase("--noBuiltin")
                    || s.equalsIgnoreCase("-noBuiltin")) {
                setUseBuiltinArchive(false);
            } else if (s.equalsIgnoreCase("--firstOrigin")
                    || s.equalsIgnoreCase("-firstOrigin")) {
                SpaceGroupCatalogue.setPreferSecondOrigin(false);
            } else if (s.equalsIgnoreCase("--rhombohedral")
                    || s.equalsIgnoreCase("-rhombohedral")) {
                SpaceGroupCatalogue.setPreferHexagonal(false);
            } else if (s.equals("-e")
                    || s.equalsIgnoreCase("--equalEdges")
                    || s.equalsIgnoreCase("-equalEdges")) {
                if (i == args.length - 1) {
                    out.println("!!! WARNING (USAGE) - Argument missing for \""
                            + s + "\".");
                } else {
                    this.relaxPasses = Integer.parseInt(args[++i]);
                }
            } else if (s.equals("-s")
                    ||s.equalsIgnoreCase("--steps")
                    || s.equalsIgnoreCase("-steps")) {
                if (i == args.length - 1) {
                    out.println("!!! WARNING (USAGE) - Argument missing for \""
                            + s + "\".");
                } else {
                    this.relaxSteps = Integer.parseInt(args[++i]);
                }
            } else if (s.equalsIgnoreCase("--arcAsInput")
                    || s.equalsIgnoreCase("-arcAsInput")) {
                archivesAsInput = true;
            } else if (s.equalsIgnoreCase("--fullUnitCell")
            		|| s.equalsIgnoreCase("-fullUnitCell")) {
            	setOutputFullCell(true);
            } else if (s.equalsIgnoreCase("--systreKey")
            		|| s.equalsIgnoreCase("-systreKey")) {
            	setOutputSystreKey(true);
            } else if (s.equalsIgnoreCase("--writeConfig")
            		|| s.equalsIgnoreCase("-writeConfig")) {
                if (i == args.length - 1) {
                    out.println("!!! WARNING (USAGE) - Argument missing for \""
                            + s + "\".");
                } else {
                    saveOptions(args[++i]);
                }
            } else if (s.equals("-c")) {
                if (i == args.length - 1) {
                    out.println("!!! WARNING (USAGE) - Argument missing for \""
                            + s + "\".");
                } else {
                    loadOptions(args[++i]);
                }
            } else if (s.equals("-x")) {
                archivesAsInput = !archivesAsInput;
            } else {
                if (args[i].endsWith(".arc") && !archivesAsInput) {
                    archives.add(args[i]);
                } else {
                    files.add(args[i]);
                }
            }
        }
        
        if (files.size() == 0) {
            out.println("!!! WARNING (USAGE) - No file names given.");
        }
        
        int count = 0;
        
        
        if (outputArchiveFileName != null) {
            try {
                this.outputArchive = new BufferedWriter(new FileWriter(outputArchiveFileName));
            } catch (IOException ex) {
                out.println("!!! ERROR (FILE) - Could not open output archive:" + ex);
            }
        }
        
        for (final Iterator iter = archives.iterator(); iter.hasNext();) {
            final String filename = (String) iter.next();
            this.processArchive(filename);
        }
        
        for (final Iterator iter = files.iterator(); iter.hasNext();) {
            final String filename = (String) iter.next();
            ++count;
            if (count > 1) {
                out.println();
                out.println();
                out.println();
            }
            this.processDataFile(filename);
        }
        
        if (this.outputArchive != null) {
            try {
        	this.outputArchive.flush();
        	this.outputArchive.close();
            } catch (IOException ex) {
                out.println("!!! ERROR (FILE) - Output archive not completely written.");
            }
        }
    }
    
    public static void main(final String args[]) {
        new SystreCmdline().run(args);
    }

    private void status(final String text) {
    	this.lastStatus = text;
    	dispatchEvent(text);
    }
    
	public synchronized void cancel() {
		this.cancelled = true;
		status("Cancel request received!");
	}
	
	private void quitIfCancelled() {
		if (this.cancelled) {
			this.cancelled = false;
			throw new SystreException(SystreException.CANCELLED,
						"Execution stopped for this structure");
		}
	}
	
    private void saveOptions(final String configFileName) {
    	// --- pick up all property values for this instance
    	final Properties ourProps;
		try {
			ourProps = Config.getProperties(this);
		} catch (Exception ex) {
			ex.printStackTrace();
			return;
		}
		
		// --- write them to the configuration file
    	try {
			ourProps.store(new FileOutputStream(configFileName), "Systre options");
		} catch (final FileNotFoundException ex) {
			System.err.println("Could not find configuration file " + configFileName);
		} catch (final IOException ex) {
			System.err.println("Exception occurred while writing configuration file");
		}
    }

    private void loadOptions(final String configFileName) {
    	// --- read the configuration file
    	final Properties ourProps = new Properties();
    	try {
			ourProps.load(new FileInputStream(configFileName));
		} catch (FileNotFoundException ex) {
			System.err.println("Could not find configuration file " + configFileName);
			return;
		} catch (IOException ex) {
			System.err.println("Exception occurred while reading configuration file");
			return;
		}
		
		// --- override by system properties if defined
		for (final Iterator keys = ourProps.keySet().iterator(); keys.hasNext();) {
			final String key = (String) keys.next();
			final String val = System.getProperty(key);
			if (val != null) {
				ourProps.setProperty(key, val);
			}
		}
    	
		// --- set the properties for this instance
    	try {
    		Config.pushProperties(ourProps, this);
		} catch (Exception ex) {
			ex.printStackTrace();
		}
    }
    
	// --- user-definable properties
    public ProcessedNet getLastStructure() {
        return this.lastStructure;
    }

    protected void setLastStructure(ProcessedNet lastStructure) {
        this.lastStructure = lastStructure;
    }

    public boolean getUseBuiltinArchive() {
		return useBuiltinArchive;
	}

	public void setUseBuiltinArchive(boolean useBuiltinArchive) {
		this.useBuiltinArchive = useBuiltinArchive;
	}

	public boolean getComputeEmbedding() {
		return this.computeEmbedding;
	}

	public void setComputeEmbedding(boolean computeEmbedding) {
		this.computeEmbedding = computeEmbedding;
	}

	public boolean getRelaxPositions() {
		return relaxPositions;
	}

	public void setRelaxPositions(boolean relax) {
		this.relaxPositions = relax;
	}

	public int getRelaxPasses() {
		return this.relaxPasses;
	}

	public void setRelaxPasses(int relaxPasses) {
		this.relaxPasses = relaxPasses;
	}

	public int getRelaxSteps() {
		return this.relaxSteps;
	}

	public void setRelaxSteps(int relaxSteps) {
		this.relaxSteps = relaxSteps;
	}

	public boolean getDuplicateIsError() {
		return duplicateIsError;
	}

	public void setDuplicateIsError(boolean duplicateIsError) {
		this.duplicateIsError = duplicateIsError;
	}
	
    protected PrintStream getOutStream() {
        return this.out;
    }
    
    protected void setOutStream(final PrintStream out) {
        this.out = out;
    }
    
    public boolean getOutputFullCell() {
        return this.outputFullCell;
    }
    
    public void setOutputFullCell(boolean fullCellOutput) {
        this.outputFullCell = fullCellOutput;
    }
    
	public boolean getOutputSystreKey() {
		return this.outputSystreKey;
	}

	public void setOutputSystreKey(boolean outputSystreKey) {
		this.outputSystreKey = outputSystreKey;
	}
}
