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

package org.gavrog.box.collections;

import java.io.BufferedWriter;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.Set;

import org.gavrog.box.collections.Iterators;
import org.gavrog.box.collections.Pair;

import junit.framework.Assert;
import junit.framework.TestCase;

/**
 * Unit test for class Iterators.
 * 
 * @author Olaf Delgado
 * @version $Id: TestIterators.java,v 1.3 2007/04/29 21:34:03 odf Exp $
 */
public class TestIterators extends TestCase {
    private Object x;
    private Object letters[];
    private Iterator singleton;
    private Iterator range;
    private Iterator emptyRange;
    private Iterator product;
    private Iterator perms;
    
    /*
     * @see TestCase#setUp()
     */
    protected void setUp() throws Exception {
        super.setUp();
        x = new Integer(27);
        letters = new Object[] { "a", "b", "c", "d" };
        singleton = Iterators.singleton(x);
        range = Iterators.range(3, 7);
        emptyRange = Iterators.range(3, 3);
        product = Iterators.cantorProduct(Iterators.range(1, 3), Iterators
                .range(4, 7));
        perms = Iterators.permutations(letters);
    }

    /*
     * @see TestCase#tearDown()
     */
    protected void tearDown() throws Exception {
        super.tearDown();
        x = null;
        letters = null;
        singleton = null;
        range = null;
        emptyRange = null;
        product = null;
        perms = null;
    }

    public void testSingleton() {
        Assert.assertTrue(singleton.hasNext());
        Assert.assertSame(singleton.next(), x);
        Assert.assertFalse(singleton.hasNext());
        try {
            singleton.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
    }

    public void testRange() {
        Assert.assertTrue(range.hasNext());
        Assert.assertEquals(range.next(), new Integer(3));
        Assert.assertTrue(range.hasNext());
        Assert.assertEquals(range.next(), new Integer(4));
        Assert.assertTrue(range.hasNext());
        Assert.assertEquals(range.next(), new Integer(5));
        Assert.assertTrue(range.hasNext());
        Assert.assertEquals(range.next(), new Integer(6));
        Assert.assertFalse(range.hasNext());
        try {
            range.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
    }

    public void testEmptyRange() {
        Assert.assertFalse(emptyRange.hasNext());
        try {
            emptyRange.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
    }
    
    private Pair intPair(final int a, final int b) {
        return new Pair(new Integer(a), new Integer(b));
    }
    
    public void testProduct() {
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(1, 4), product.next());
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(1, 5), product.next());
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(2, 4), product.next());
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(1, 6), product.next());
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(2, 5), product.next());
        Assert.assertTrue(product.hasNext());
        Assert.assertEquals(intPair(2, 6), product.next());
        Assert.assertFalse(product.hasNext());
        try {
            product.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
    }
    
    public void testPermutations() {
        final Set seen = new HashSet();
        Assert.assertTrue(perms.hasNext());
        final List first = (List) perms.next();
        Assert.assertEquals(Arrays.asList(letters), first);
        seen.add(first);
        Assert.assertTrue(seen.contains(first));
        for (int i = 1; i < 24; ++i) {
            final List a= (List) perms.next();
            Assert.assertFalse(seen.contains(a));
            seen.add(a);
            Assert.assertTrue(seen.contains(a));
        }
        Assert.assertFalse(perms.hasNext());
        try {
            perms.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
    }
    
    public void testCombinations() {
        final Iterator combinations = Iterators.combinations(letters, 3);
        final Set seen = new HashSet();
        while (combinations.hasNext()) {
            final List a= (List) combinations.next();
            Assert.assertFalse(seen.contains(a));
            seen.add(a);
            Assert.assertTrue(seen.contains(a));
        }
        assertEquals(24, seen.size());
        Assert.assertFalse(combinations.hasNext());
        try {
            combinations.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
        assertFalse(seen.contains(Arrays.asList(new Object[] { "a", "a", "c" })));
        assertFalse(seen.contains(Arrays.asList(new Object[] { "a", "d", "d" })));
        assertTrue(seen.contains(Arrays.asList(new Object[] { "a", "d", "c" })));
        assertTrue(seen.contains(Arrays.asList(new Object[] { "a", "c", "d" })));
    }
    
    public void testSelections() {
        final Iterator selections = Iterators.selections(letters, 3);
        final Set seen = new HashSet();
        while (selections.hasNext()) {
            final List a= (List) selections.next();
            Assert.assertFalse(seen.contains(a));
            seen.add(a);
            Assert.assertTrue(seen.contains(a));
        }
        assertEquals(20, seen.size());
        Assert.assertFalse(selections.hasNext());
        try {
            selections.next();
            fail("Should raise a NoSuchElementException");
        } catch (NoSuchElementException success) {
        }
        assertTrue(seen.contains(Arrays.asList(new Object[] { "a", "a", "c" })));
        assertTrue(seen.contains(Arrays.asList(new Object[] { "a", "d", "d" })));
        assertFalse(seen.contains(Arrays.asList(new Object[] { "a", "d", "c" })));
    }
    
    public void testEqual() {
        Assert.assertTrue(Iterators.equal(range, Iterators.range(3, 7)));
        Assert.assertFalse(Iterators.equal(range, Iterators.range(4, 8)));
        Assert.assertFalse(Iterators.equal(range, Iterators.range(3, 8)));
    }
    
    public void testContains() {
    	assertTrue(Iterators.contains(range, new Integer(3)));
    	assertTrue(Iterators.contains(range, new Integer(6)));
    	assertFalse(Iterators.contains(range, new Integer(7)));
    	assertFalse(Iterators.contains(range, "a"));
    }
    
    public void testWrite() {
        final StringWriter out = new StringWriter(100);
        int count;
        try {
            count = Iterators.write(new BufferedWriter(out), range, ", ");
        } catch (IOException ex) {
            throw new RuntimeException(ex);
        }
        assertEquals(4, count);
        assertEquals("3, 4, 5, 6, ", out.toString());
    }
}
