package buoy.widget;

import javax.swing.*;
import java.awt.*;

/**
 * A BCheckBoxMenuItem is a menu item for making simple boolean selectons.  Selecting it toggles
 * it on and off.
 * <p>
 * In addition to the event types generated by all Widgets, BCheckBoxMenuItems generate the following event types:
 * <ul>
 * <li>{@link buoy.event.CommandEvent CommandEvent}</li>
 * </ul>
 *
 * @author Peter Eastman
 */

public class BCheckBoxMenuItem extends BMenuItem
{
  /**
   * Create a new BCheckBoxMenuItem with no label, which is initially deselected.
   */
  
  public BCheckBoxMenuItem()
  {
    this(null, null, null, false);
  }

  /**
   * Create a new BCheckBoxMenuItem.
   *
   * @param text     the text to display on the BCheckBoxMenuItem
   * @param state    the initial selection state of the BCheckBoxMenuItem
   */
  
  public BCheckBoxMenuItem(String text, boolean state)
  {
    this(text, null, null, state);
  }

  /**
   * Create a new BCheckBoxMenuItem.
   *
   * @param text      the text to display on the BCheckBoxMenuItem
   * @param image     the image to display next to the menu item
   * @param state     the initial selection state of the BCheckBoxMenuItem
   */
  
  public BCheckBoxMenuItem(String text, Icon image, boolean state)
  {
    this(text, null, image, state);
  }

  /**
   * Create a new BCheckBoxMenuItem.
   *
   * @param text      the text to display on the BCheckBoxMenuItem
   * @param shortcut  a keyboard shortcut which will activate this menu item
   * @param state     the initial selection state of the BCheckBoxMenuItem
   */
  
  public BCheckBoxMenuItem(String text, Shortcut shortcut, boolean state)
  {
    this(text, shortcut, null, state);
  }
  
  /**
   * Create a new BCheckBoxMenuItem.
   *
   * @param text      the text to display on the BCheckBoxMenuItem
   * @param shortcut  a keyboard shortcut which will activate this menu item
   * @param image     the image to display next to the menu item
   * @param state     the initial selection state of the BCheckBoxMenuItem
   */
  
  public BCheckBoxMenuItem(String text, Shortcut shortcut, Icon image, boolean state)
  {
    super(text, shortcut, image);
    setState(state);
  }

  /**
   * Create the JCheckBoxMenuItem which serves as this Widget's Component.  This method is protected so that
   * subclasses can override it.
   */
  
  protected JMenuItem createComponent()
  {
    return new JCheckBoxMenuItem();
  }

  public JMenuItem getComponent()
  {
    return (JMenuItem) component;
  }

  /**
   * Get the selection state of this menu item.
   */
  
  public boolean getState()
  {
    return getComponent().isSelected();
  }
  
  /**
   * Set the selection state of this menu item.
   */
  
  public void setState(boolean selected)
  {
    getComponent().setSelected(selected);
  }
}
