using Gtk;

namespace ALaunch {

public class MainWindow : Gtk.Window {

	private Gdk.Pixbuf file_pixbuf;

	private GLib.AppInfoMonitor monitor = GLib.AppInfoMonitor.get ();

	private Gtk.ListStore store = new Gtk.ListStore (4, typeof (string), typeof (string), typeof (Gdk.Pixbuf), typeof(GLib.AppInfo));

	private Gdk.Pixbuf find_icon (string name, IconTheme theme) {
		try {

			Gdk.Pixbuf icon_px;
			icon_px = theme.load_icon (name, 64, Gtk.IconLookupFlags.FORCE_SVG);
			icon_px = icon_px.scale_simple (64, 64, Gdk.InterpType.BILINEAR);
			return icon_px;
		} catch (Error e) {
			return file_pixbuf.scale_simple (64, 64, Gdk.InterpType.BILINEAR);
		}
	}

	private void fill_store () {
		IconTheme theme = Gtk.IconTheme.get_default ();
		store.clear ();
		
		GLib.List<GLib.AppInfo> infolist = GLib.AppInfo.get_all ();
		infolist.foreach ((appinfo) => {
			if (appinfo.should_show ()) {
				TreeIter iter;
				string name;
				string icon;
				string disc;
				Gdk.Pixbuf icon_px;
				
				name = appinfo.get_display_name ();
				disc = "";//appinfo.get_des ();
				icon = appinfo.get_icon ().to_string ();
				icon_px = find_icon(icon, theme);
				
				store.append (out iter);
				store.set (iter, 0, disc, 1, name, 2, icon_px, 3, appinfo);
			}
		});
	}

	private void appchanged () {
		this.fill_store ();
	}

	private void icon_activate (TreePath path) {
		try {
			TreeIter iter;
			store.get_iter (out iter, path);
			GLib.Value info_v;
			store.get_value (iter, 3, out info_v);
			GLib.AppInfo info = (GLib.AppInfo) info_v;
			info.launch (null, null);
		} catch (Error e) {
			stderr.printf ("Could not load icon: %s\n", e.message);
		}
		//this.vanish ();
		SESDE.win.button_launcher.active = false;
	}
	
	public void vanish () {
		this.hide ();
	}
	
	public void appear () {
		this.show_all ();
	}
	
	public MainWindow() {
		this.title = "ALaunch";
		
		this.set_decorated (false);
		this.set_skip_pager_hint (true);
		this.set_skip_taskbar_hint (true);
		this.set_keep_above (true);
		this.stick ();
		
		Gdk.Screen screen = Gdk.Screen.get_default ();
		this.set_default_size (screen.get_width (), screen.get_height ());

		store.set_sort_column_id (1, SortType.ASCENDING);
		this.fill_store ();

		monitor.changed.connect (this.appchanged);

		IconView iconview = new IconView ();
		iconview.set_model (store);
		iconview.set_activate_on_single_click (true);
		iconview.set_selection_mode (SelectionMode.SINGLE);
		iconview.set_text_column (1);
		iconview.set_pixbuf_column (2);
		iconview.item_activated.connect (icon_activate);
		
		ScrolledWindow sw = new ScrolledWindow (null, null);
		sw.set_policy(PolicyType.AUTOMATIC, PolicyType.AUTOMATIC);
		sw.add (iconview);
		
		Box box = new Box (Orientation.VERTICAL, 5);
		box.pack_end (sw, true, true, 0);
		this.add (box);
	}

}

}
