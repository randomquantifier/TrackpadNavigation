# Trackpad Navigation for Lönn

Adds laptop-trackpad-friendly map navigation to Lönn.

## Controls

- Two-finger scroll: pan the map horizontally and vertically.
- Control/Command + two-finger scroll: smoothly zoom around the pointer.

You can still use right-click drag, but you will eventually stop using it anyways.

Use **View -> Trackpad Navigation** to turn the feature on or off. The choice is saved between Lönn sessions. When disabled, Lönn's original wheel-to-zoom behavior is restored.

LÖVE 11 cannot always distinguish a physical mouse wheel from a trackpad. While this setting is enabled, an unmodified mouse wheel pans instead of zooming; hold Control or Command to zoom.

## Optional tuning

The constants near the top of `Loenn/libraries/trackpad_navigation.lua` control pan speed, zoom sensitivity, and scale limits.

## macOS keyboard compatibility

The plugin also fixes Command shortcuts in Lönn text fields. 

Command+A/C/X/V and Command+arrow/backspace work alongside their Control equivalents.   
The default material-search shortcut is changed from Control+F to Command+F on macOS. 
