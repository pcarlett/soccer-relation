-- processo di visualizzazione del campo 
with Double_Buffer;		use Double_Buffer;
with Gdk.Color;		 	use Gdk.Color;
with Gdk.Drawable;		use Gdk.Drawable;
with Gtk.Style;			use Gtk.Style;
with Gdk.GC;			use Gdk.GC;
with Gtk.Button;		use Gtk.Button;
with Gtk.Hbutton_Box;	use Gtk.Hbutton_Box;
with Gtk.Box;			use Gtk.Box;
with Gtk.Handlers;		use Gtk.Handlers;
pragma Elaborate_All (Gtk.Handlers);
with Gtk.Label;			use Gtk.Label;
with Pango.Font;		use Pango.Font;
with Gtk.Main;			use Gtk.Main;
with Ada.Text_IO;		use Ada.Text_IO;

package body Display_Package is
	
	Layer0_Gc : Gdk.GC.Gdk_GC;
	Layer1_Gc : Gdk.GC.Gdk_GC;
	Layer2_Gc : Gdk.GC.Gdk_GC;
	Layer3_Gc : Gdk.GC.Gdk_GC;
	Layer4_Gc : Gdk.GC.Gdk_GC;

	Field : Field_Access;
	Ball : Ball_Access;
	Time : TimeCount_Access;
	Timer : Timer_Access;

	package Void_Cb is new Gtk.Handlers.Callback (Gtk.Window.Gtk_Window_Record);
	package Button_Cb is new Gtk.Handlers.Callback (Gtk.Button.Gtk_Button_Record);
	package Draw_Timeout is new Gtk.Main.Timeout (Gtk.Drawing_Area.Gtk_Drawing_Area);
	package Timer_Timeout is new Gtk.Main.Timeout (Gtk_Label);
	package Score_Timeout is new Gtk.Main.Timeout (Gtk_Label);
	

	------------------
	-- Draw_Content --
	------------------
	procedure Draw_Content (Pixmap : Gdk.Gdk_Drawable) is
		Width, Height : Gint;
		BP, PP : Position;
	begin
		-- Erase the old
		
		Gdk.Drawable.Get_Size(Pixmap, Width, Height);
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer0_Gc, True, 0, 0, Width, Height);
		
		-- Draw the new main rectangle
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 10, 10, 630, 408);
		Gdk.Drawable.Draw_Line(Pixmap, Layer1_Gc, 325, 10, 325, 418);
		
		-- Draw the 2 goals
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 5, 184, 5, 60);
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 640, 184, 5, 60);

		-- Draw the 2 areas
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 10, 102, 110, 224);
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 530, 102, 110, 224);
		
		-- Draw the 2 little areas
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 10, 153, 54, 112);
		Gdk.Drawable.Draw_Rectangle(Pixmap, Layer1_Gc, False, 586, 153, 54, 112);

		-- Draw the center
		Gdk.Drawable.Draw_Arc(Pixmap, Layer1_Gc, False, 260, 149, 130, 130, 0 * 64, 360 * 64);

		-- disegna la palla
		BP := Field.GetBallPosition;
		Gdk.Drawable.Draw_Arc(Pixmap, Layer4_Gc, True, Gint(BP.Col*2), Gint(BP.Row*2), 10, 10, 0 * 64, 360 * 64);

		-- disegna i vari giocatori in campo
		for i in 1..22 loop
			if (i < 12) then
				PP := Field.GetPlayerPosition(i);
				Gdk.Drawable.Draw_Arc(Pixmap, Layer2_Gc, True, Gint(PP.Col*2), Gint(PP.Row*2), 20, 20, 0 * 64, 360 * 64);
				if (i = Ball.GetOwner) then
					Gdk.Drawable.Draw_Arc(Pixmap, Layer4_Gc, False, Gint(PP.Col*2-3), Gint(PP.Row*2-3), 26, 26, 0 * 64, 360 * 64);
				end if;
			else
				PP := Field.GetPlayerPosition(i);
				Gdk.Drawable.Draw_Arc(Pixmap, Layer3_Gc, True, Gint(PP.Col*2), Gint(PP.Row*2), 20, 20, 0 * 64, 360 * 64);
				if (i = Ball.GetOwner) then
					Gdk.Drawable.Draw_Arc(Pixmap, Layer4_Gc, False, Gint(PP.Col*2-3), Gint(PP.Row*2-3), 26, 26, 0 * 64, 360 * 64);
				end if;

			end if;
		end loop;
			
	end Draw_Content;
   
	-----------------
	-- Draw_Buffer --
	-----------------
	function Draw_Buffer (Area : Gtk.Drawing_Area.Gtk_Drawing_Area) return Boolean is
		Buffer : Double_Buffer.Gtk_Double_Buffer :=	Double_Buffer.Gtk_Double_Buffer (Area);
	begin
		-- Buffer.Set_Triple_Buffer(True);
		Draw_Content (Double_Buffer.Get_Pixmap (Buffer));
		Double_Buffer.Draw (Buffer);
		return True;
	end Draw_Buffer;
	
	------------------
	-- Update Score --
	------------------
	function UpdateScore (Label : in Gtk_Label) return Boolean is
	begin
		Set_Text (Label, "Score:   Red " & Integer'Image(Field.GetScore(1)) & " - " & Integer'Image(Field.GetScore(2)) & " Blue");
		return True;
	end UpdateScore;
   
	------------------
	-- Update Timer --
	------------------
	function UpdateTimer (Label : in Gtk_Label) return Boolean is
		T : Integer;
	begin
		T := Time.GetTime;
		Set_Text (Label, "Time:   " & Integer'Image(T/5) & ":00");
		return True;
	end UpdateTimer;

	-------------
	-- Quitter --
	-------------
	procedure Starter (Button : access Gtk.Button.Gtk_Button_Record'Class) is
		pragma Warnings (Off, Button);
	begin
		Timer.Start;
	end Starter;
	
	-------------
	-- Quitter --
	-------------
	procedure Quitter (Button : access Gtk.Button.Gtk_Button_Record'Class) is
		pragma Warnings (Off, Button);
	begin
		Gtk.Main.Gtk_Exit (0);
	end Quitter;
	
	----------
	-- Quit --
	----------
	procedure Quit (Win : access Gtk.Window.Gtk_Window_Record'Class) is
		pragma Warnings (Off, Win);
	begin
		Gtk.Main.Gtk_Exit (0);
	end Quit;
	
	-------------------------
	-- Init Field and Ball --
	-------------------------
	procedure References(F : in Field_Access; B : in Ball_Access; T : in TimeCount_Access; Tm : in Timer_Access) is
	begin
		-- inizializza le variablili globali Field e Ball
		Field := F;
		Ball := B;
		Time := T;
		Timer := Tm;
	end References;
		
	----------
	-- Init --
	----------
	procedure Init is
		Win    	: Gtk.Window.Gtk_Window;
		Buffer 	: Double_Buffer.Gtk_Double_Buffer;
		Hbox   	: Gtk.Hbutton_Box.Gtk_HButton_Box;
		Vbox   	: Gtk.Box.Gtk_Box;
		Timer  	: Gtk.Label.Gtk_Label;
		Score  	: Gtk.Label.Gtk_Label;
		Style  	: Gtk.Style.Gtk_Style;
		Button 	: Gtk.Button.Gtk_Button;
		Id     	: Gtk.Main.Timeout_Handler_Id;
		Id2		: Gtk.Main.Timeout_Handler_Id; -- timer
		Id3		: Gtk.Main.Timeout_Handler_Id;
		
		RedColor : Gdk_Color;
		WhiteColor : Gdk_Color;
		BlueColor : Gdk_Color;
		GreenColor : Gdk_Color;
		BlackColor : Gdk_Color;
	    Success : Boolean;
	
	begin		
		-- Inizializza i colori principali
	    Set_Rgb (WhiteColor, 65000, 65000, 65000);
	    Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
	                 Color   => WhiteColor,
	                 Writeable  => False,
	                 Best_Match => True,
	                 Success    => Success);
	    Set_Rgb (RedColor, 65000, 0, 0);
	    Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
	                 Color   => RedColor,
	                 Writeable  => False,
	                 Best_Match => True,
	                 Success    => Success);
	    Set_Rgb (BlueColor, 0, 0, 65000);
	    Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
	                 Color   => BlueColor,
	                 Writeable  => False,
	                 Best_Match => True,
	                 Success    => Success);
	    Set_Rgb (GreenColor, 0, 65000, 0);
	    Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
	                 Color => GreenColor,
	                 Writeable  => False,
	                 Best_Match => True,
	                 Success    => Success);
	    Set_Rgb (BlackColor, 0, 0, 0);
	    Alloc_Color (Colormap   => Gtk.Widget.Get_Default_Colormap,
	                 Color => BlackColor,
	                 Writeable  => False,
	                 Best_Match => True,
	                 Success    => Success);

		-- Double buffer demo
		Gtk.Window.Gtk_New (Win, Gtk.Enums.Window_Toplevel);
		Gtk.Window.Set_Title (Win, "Ada Soccer Game");
		Void_Cb.Connect (Win, "destroy", Void_Cb.To_Marshaller (Quit'Access));

		-- A vertical box with three rows
		Gtk.Box.Gtk_New_Vbox (Vbox, Homogeneous => False, Spacing => 5);

		-- Row 1: a label with style: Timer
		Gtk.Label.Gtk_New (Timer, "Time:   00:00");
		Style := Gtk.Style.Copy (Gtk.Window.Get_Style (Win));
		Gtk.Style.Set_Font_Description (Style, Pango.Font.From_String ("Arial Bold 14"));
		Gtk.Label.Set_Style (Timer, Style);
		
		-- Row 1.1: a label with style: Score
		Gtk.Label.Gtk_New (Score, "Score:   Red " & Integer'Image(Field.GetScore(1)) & " - " & Integer'Image(Field.GetScore(2)) & " Blue");
		Style := Gtk.Style.Copy (Gtk.Window.Get_Style (Win));
		Gtk.Style.Set_Font_Description (Style, Pango.Font.From_String ("Arial Bold 14"));
		Gtk.Label.Set_Style (Score, Style);
		
		-- Row 2: a double buffered drawing area
		Double_Buffer.Gtk_New (Buffer);
		Double_Buffer.Set_USize (Buffer, 650, 428);
		Double_Buffer.Set_Back_Store (Buffer, True);

		-- Row 3: A horizontal row of buttons
		Gtk.HButton_Box.Gtk_New (Hbox);
		Gtk.HButton_Box.Set_Border_Width (Hbox, 10);
		Gtk.HButton_Box.Set_Spacing (Hbox, 10);
		Gtk.HButton_Box.Set_Layout (Hbox, Gtk.Enums.Buttonbox_Spread);
		-- start game
		Gtk.Button.Gtk_New (Button, "Start");
		Gtk.HButton_Box.Pack_Start (HBox, Button);
		Button_Cb.Object_Connect (Button, "clicked", Button_Cb.To_Marshaller (Starter'Access), Button);
		-- quit game
		Gtk.Button.Gtk_New (Button, "Quit");
		Gtk.HButton_Box.Pack_Start (HBox, Button);
		Button_Cb.Object_Connect (Button, "clicked", Button_Cb.To_Marshaller (Quitter'Access), Button);

		-- Pack them in
		Gtk.Box.Pack_Start (Vbox, Buffer);
		Gtk.Box.Pack_Start (Vbox, Timer, Expand => False);
		Gtk.Box.Pack_Start (Vbox, Score, Expand => False);
		Gtk.Box.Pack_Start (Vbox, HBox, Expand => False);
		Gtk.Window.Add (Win, Vbox);
		Gtk.Window.Show_All (Win);

		-- The window needs to be created before creating the GCs
		Gdk.GC.Gdk_New (Layer0_Gc, Double_Buffer.Get_Window (Buffer));
		Gdk.GC.Set_Foreground (Layer0_Gc, GreenColor);
		Gdk.GC.Gdk_New (Layer1_Gc, Double_Buffer.Get_Window (Buffer));
		Gdk.GC.Set_Foreground (Layer1_Gc, WhiteColor);
		Gdk.GC.Gdk_New (Layer2_Gc, Double_Buffer.Get_Window (Buffer));
		Gdk.GC.Set_Foreground (Layer2_Gc, RedColor);
		Gdk.GC.Gdk_New (Layer3_Gc, Double_Buffer.Get_Window (Buffer));
		Gdk.GC.Set_Foreground (Layer3_Gc, BlueColor);
		Gdk.GC.Gdk_New (Layer4_Gc, Double_Buffer.Get_Window (Buffer));
		Gdk.GC.Set_Foreground (Layer4_Gc, BlackColor);
		
		-- Draw a frame every 40 ms (25 frames/sec)
		Id := Draw_Timeout.Add (30, Draw_Buffer'Access, Gtk.Drawing_Area.Gtk_Drawing_Area (Buffer));
		Id2 := Timer_Timeout.Add (100, UpdateTimer'Access, Gtk_Label (Timer));
		Id3 := Score_Timeout.Add (100, UpdateScore'Access, Gtk_Label (Score));

	end Init;
	
end Display_Package;