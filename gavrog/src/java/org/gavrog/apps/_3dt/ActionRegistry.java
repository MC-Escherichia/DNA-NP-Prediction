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


package org.gavrog.apps._3dt;

import java.util.HashMap;
import java.util.Map;

import javax.swing.AbstractAction;
import javax.swing.Action;
import javax.swing.KeyStroke;

/**
 * @author Olaf Delgado
 * @version $Id:$
 */
public class ActionRegistry {
	private static ActionRegistry _instance = null;
	
	private Map<String, AbstractAction> actions =
		new HashMap<String, AbstractAction>();
	
	private ActionRegistry() {}
	
	public static ActionRegistry instance() {
		if (_instance == null) {
			_instance = new ActionRegistry();
		}
		return _instance;
	}
	
	public AbstractAction get(final String name) {
		return actions.get(name);
	}
	
	public void put(final AbstractAction action,
			final String desc, final KeyStroke key) {
		action.putValue(AbstractAction.SHORT_DESCRIPTION, desc);
		action.putValue(AbstractAction.ACCELERATOR_KEY, key);
		actions.put(String.valueOf(action.getValue(Action.NAME)), action);
	}
}
