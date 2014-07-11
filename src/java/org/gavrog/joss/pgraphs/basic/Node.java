package org.gavrog.joss.pgraphs.basic;

import java.util.Set;

import org.gavrog.box.collections.FilteredIterator;
import org.gavrog.box.collections.IteratorAdapter;



/**
 * Implements node objects for this graph.
 */
public class Node implements INode, Comparable<INode> {
    private final long id;
    private UndirectedGraph owner;
    /**
     * Constructs a new node object.
     * 
     * @param id the id of this node.
     */
    public Node(final UndirectedGraph graph, final long id) {
    	this.owner = graph; 
        this.id = id;
    }

    /*
     * (non-Javadoc)
     * 
     * @see javaPGraphs.INode#degree()
     */
    public int degree() {
        return ((Integer) owner.nodeIdToDegree.get(id)).intValue();
    }

    /*
     * (non-Javadoc)
     * 
     * @see javaPGraphs.IGraphElement#owner()
     */
    public IGraph owner() {
        return this.owner;
    }

    /* (non-Javadoc)
     * @see org.gavrog.joss.pgraphs.basic.INode#incidences()
     */
    public IteratorAdapter<IEdge> incidences() {
        final Set<Long> ids = owner.nodeIdToIncidentEdgesIds.get(this.id);
        return new FilteredIterator<IEdge, Long>(ids.iterator()) {
            public IEdge filter(final Long x) {
                if (owner.edgeIdToSourceNodeId.get(x).equals(id())) {
                    return owner.new Edge(x, false);
                } else if (owner.edgeIdToTargetNodeId.get(x).equals(id())) {
                    return owner.new Edge(x, true);
                } else {
                    throw new RuntimeException("inconsistency in graph");
                }
            }
        };
    }

    /*
     * (non-Javadoc)
     * 
     * @see javaPGraphs.IGraphElement#id()
     */
    public long id() {
        return this.id;
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#equals(java.lang.Object)
     */
    public boolean equals(final Object other) {
        if (other instanceof Node) {
            final Node v = (Node) other;
            return this.owner().id().equals(v.owner().id())
                    && this.id == v.id();
        } else {
            return false;
        }
    }
    
    /* (non-Javadoc)
     * @see java.lang.Object#hashCode()
     */
    public int hashCode() {
        return this.owner().id().hashCode() * 37 + (int) id;
    }
    
    /* (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    public String toString() {
        return "Node " + id;
    }

    public int compareTo(final INode arg0) {
        return (int) this.id() - (int) arg0.id();
    }
}
