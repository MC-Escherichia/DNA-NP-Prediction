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

package org.gavrog.joss.pgraphs.basic;

/**
 * Interface for the representation of nodes in a graph.
 * 
 * @author Olaf Delgado
 * @version $Id: INode.java,v 1.1.1.1 2005/07/15 21:58:38 odf Exp $
 */
public interface INode extends IGraphElement {
    /**
     * Retrieves the the number of incident edges for this node.
     * 
     * @return the number of incident edges.
     */
    public int degree();
}
