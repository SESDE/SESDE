using Wnck;
using Gtk;

public static int runmode = 0; // 0 -> Desktop, 1 -> Tablet

namespace SESDE {

static Panel.MainWindow win;
static Preference.PreferenceWin prwin;

static Wnck.Screen wscr;

static Gtk.CssProvider cssp;


public void main (string[] args) {
	Gtk.init (ref args);
	
	try {
		cssp = new Gtk.CssProvider ();
		cssp.load_from_path ("./style.css");
		Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), cssp, Gtk.STYLE_PROVIDER_PRIORITY_USER);
	} catch (GLib.Error e) {
		stderr.printf("Can not load style.css");
	}	

	foreach(string arg in args) {
		stdout.printf("Argument : %s\n",arg);
		if(arg == "tablet") {
			stdout.printf("Entering Tablet Mode.\n");
			runmode = 1;
		}
	}

	wscr = Wnck.Screen.get_default ();
	prwin = new Preference.PreferenceWin ();
	
	if (runmode == 1) {
		win = new Panel.MainWindow (runmode);//, taskl);
	} else {
		win = new Panel.MainWindow (runmode);//, taskl);
	}
	
	win.show_all ();
	
	Gtk.main ();
}

}
