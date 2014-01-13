package buoy.widget;

import buoy.internal.*;
import buoy.xml.*;
import buoy.xml.delegate.*;
import java.awt.*;
import java.util.*;
import javax.swing.JPanel;

/**
 * RowContainer is a WidgetContainer which arranges its child Widgets in a row, from left to right.
 * <p>
 * In addition to the event types generated by all Widgets, RowContainers generate the following event types:
 * <ul>
 * <li>{@link buoy.event.RepaintEvent RepaintEvent}</li>
 * </ul>
 *
 * @author Peter Eastman
 */

public class RowContainer extends WidgetContainer
{
  private ArrayList<Widget> child;
  private ArrayList<LayoutInfo> childLayout;
  private LayoutInfo defaultLayout;
  
  static
  {
    WidgetEncoder.setPersistenceDelegate(RowContainer.class, new IndexedContainerDelegate(new String [] {"getChild", "getChildLayout"}));
  }

  /**
   * Create a new RowContainer.
   */
  
  public RowContainer()
  {
    component = new WidgetContainerPanel(this);
    child = new ArrayList<Widget>();
    childLayout = new ArrayList<LayoutInfo>();
    defaultLayout = new LayoutInfo(LayoutInfo.CENTER, LayoutInfo.NONE, new Insets(2, 2, 2, 2), null);
  }

  public JPanel getComponent()
  {
    return (JPanel) component;
  }

  /**
   * Get the number of children in this container.
   */
  
  public int getChildCount()
  {
    return child.size();
  }
  
  /**
   * Get the i'th child of this container.
   */
  
  public Widget getChild(int i)
  {
    return child.get(i);
  }

  /**
   * Get a Collection containing all child Widgets of this container.
   */
  
  public Collection<Widget> getChildren()
  {
    return new ArrayList<Widget>(child);
  }
  
  /**
   * Layout the child Widgets.  This may be invoked whenever something has changed (the size of this
   * WidgetContainer, the preferred size of one of its children, etc.) that causes the layout to no
   * longer be correct.  If a child is itself a WidgetContainer, its layoutChildren() method will be
   * called in turn.
   */
  
  public void layoutChildren()
  {
    Dimension size = getComponent().getSize();
    Rectangle cell = new Rectangle(0, 0, 0, size.height);
    for (int i = 0; i < child.size(); i++)
      {
        Widget w = child.get(i);
        LayoutInfo layout = childLayout.get(i);
        if (layout == null)
          layout = defaultLayout;
        Dimension prefSize = layout.getPreferredSize(w);
        cell.width = prefSize.width;
        w.getComponent().setBounds(layout.getWidgetLayout(w, cell));
        if (w instanceof WidgetContainer)
          ((WidgetContainer) w).layoutChildren();
        cell.x += prefSize.width;
      }
  }
  
  /**
   * Add a Widget to this container, using the default LayoutInfo to position it.
   *
   * @param widget     the Widget to add
   */
  
  public void add(Widget widget)
  {
    add(widget, null);
  }

  /**
   * Add a Widget to this container.
   *
   * @param widget     the Widget to add
   * @param layout     the LayoutInfo to use for this Widget.  If null, the default LayoutInfo will be used.
   */
  
  public void add(Widget widget, LayoutInfo layout)
  {
    add(widget, widget.getParent() == this ? getChildCount()-1 : getChildCount(), layout);
  }
  
  /**
   * Add a Widget to this container.
   *
   * @param widget     the Widget to add
   * @param index      the index at which to add the Widget
   * @param layout     the LayoutInfo to use for this Widget.  If null, the default LayoutInfo will be used.
   */

  public void add(Widget widget, int index, LayoutInfo layout)
  {
    if (widget.getParent() != null)
      widget.getParent().remove(widget);
    child.add(index, widget);
    childLayout.add(index, layout);
    getComponent().add(widget.getComponent(), index);
    setAsParent(widget);
    invalidateSize();
  }

  /**
   * Get the LayoutInfo for a particular Widget.
   *
   * @param index     the index of the Widget for which to get the LayoutInfo
   * @return the LayoutInfo being used for that Widget.  This may return null, which indicates that the
   *         default LayoutInfo is being used.
   */
  
  public LayoutInfo getChildLayout(int index)
  {
    return childLayout.get(index);
  }

  /**
   * Set the LayoutInfo for a particular Widget.
   *
   * @param index      the index of the Widget for which to set the LayoutInfo
   * @param layout     the new LayoutInfo.  If null, the default LayoutInfo will be used
   */
  
  public void setChildLayout(int index, LayoutInfo layout)
  {
    childLayout.set(index, layout);
    invalidateSize();
  }
  
  /**
   * Get the LayoutInfo for a particular Widget.
   *
   * @param widget     the Widget for which to get the LayoutInfo
   * @return the LayoutInfo being used for that Widget.  This may return null, which indicates that the
   *         default LayoutInfo is being used.  It will also return null if the specified Widget is not
   *         a child of this container.
   */
  
  public LayoutInfo getChildLayout(Widget widget)
  {
    int index = child.indexOf(widget);
    if (index == -1)
      return null;
    return childLayout.get(index);
  }
  
  /**
   * Set the LayoutInfo for a particular Widget.
   *
   * @param widget     the Widget for which to set the LayoutInfo
   * @param layout     the new LayoutInfo.  If null, the default LayoutInfo will be used
   */
  
  public void setChildLayout(Widget widget, LayoutInfo layout)
  {
    int index = child.indexOf(widget);
    if (index == -1)
      return;
    childLayout.set(index, layout);
    invalidateSize();
  }

  /**
   * Get the default LayoutInfo.
   */
  
  public LayoutInfo getDefaultLayout()
  {
    return defaultLayout;
  }
  
  /**
   * Set the default LayoutInfo.
   */
  
  public void setDefaultLayout(LayoutInfo layout)
  {
    defaultLayout = layout;
    invalidateSize();
  }
    
  /**
   * Remove a child Widget from this container.
   *
   * @param widget     the Widget to remove
   */
  
  public void remove(Widget widget)
  {
    int index = child.indexOf(widget);
    if (index > -1)
      remove(index);
  }
  
  /**
   * Remove a child Widget from this container.
   *
   * @param index     the index of the Widget to remove
   */
  
  public void remove(int index)
  {
    Widget w = child.get(index);
    getComponent().remove(w.getComponent());
    child.remove(index);
    childLayout.remove(index);
    removeAsParent(w);
    invalidateSize();
  }
  
  /**
   * Remove all child Widgets from this container.
   */
  
  public void removeAll()
  {
    getComponent().removeAll();
    for (Widget w : child)
      removeAsParent(w);
    child.clear();
    childLayout.clear();
    invalidateSize();
  }

  /**
   * Get the index of a particular Widget.
   *
   * @param widget      the Widget to locate
   * @return the position of the Widget within this container, or -1 if the Widget is not a child
   * of this container
   */
  
  public int getChildIndex(Widget widget)
  {
    return child.indexOf(widget);
  }
  
  /**
   * Get the smallest size at which this Widget can reasonably be drawn.  When a WidgetContainer lays out
   * its contents, it will attempt never to make this Widget smaller than its minimum size.
   */
  
  public Dimension getMinimumSize()
  {
    Dimension minSize = new Dimension(0, 0);
    for (int i = 0; i < child.size(); i++)
    {
      Dimension dim = child.get(i).getMinimumSize();
      minSize.width += dim.width;
      if (minSize.height < dim.height)
        minSize.height = dim.height;
    }
    return minSize;
  }

  /**
   * Get the preferred size at which this Widget will look best.  When a WidgetContainer lays out
   * its contents, it will attempt to make this Widget as close as possible to its preferred size.
   */
  
  public Dimension getPreferredSize()
  {
    Dimension prefSize = new Dimension(0, 0);
    for (int i = 0; i < child.size(); i++)
    {
      Widget w = child.get(i);
      LayoutInfo layout = childLayout.get(i);
      if (layout == null)
        layout = defaultLayout;
      Dimension dim = layout.getPreferredSize(w);
      prefSize.width += dim.width;
      if (prefSize.height < dim.height)
        prefSize.height = dim.height;
    }
    return prefSize;
  }
}