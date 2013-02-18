V8HorizontalPickerView
======================
by Shawn Veader (@veader) of [V8 Logic](http://v8logic.com) / [V8 Labs, LLC](http://v8labs.com)

Original design concept by [Buck Sharp](http://bucksharp.tumblr.com/), the designer on [f/stats](http://fstatsapp.com).


How to use V8HorizontalPickerView
---------------------------------
Add the `V8HorizontalPickerView` header and implementation files (.h and .m)
along with the protocol header file to your app source and include them in
your project.

Implement the necessary delegate and data source protocol methods.
Instantiate and add the picker view to your view and wire up the delegate
and data source. That's it!

Delegate Protocol
----------------
    - (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker;

Data Source Protocol
-------------------
    - (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index;
    - (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index;
    - (UIView *)  horizontalPickerView:(V8HorizontalPickerView *)picker  viewForElementAtIndex:(NSInteger)index;
    - (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index;

The protocol requires the width method to be implemented and for either the
title or view *ForElementAtIndex: method to be implemented. (ie: you don't
need both)

Using Views for Elements
------------------------
If you are going to implement the

    -horizontalPickerView:viewForElementAtIndex:

data source method, make sure your view conforms to the
`V8HorizontalPickerElementState` protocol.

License
-------
See LICENSE file.
TL;DR: I am publishing this under the zlib/libpng license.

Thanks
------
Thanks for taking the time to check out the project. Let me know via the
GitHub issues feature if you find any bugs or have feature requests. Please
drop me a note and let me know if you use this in a project that hits the
AppStore.

Apps Using this Control
-----------------------
[f/stats](http://fstatsapp.com) - Flickr stats for iPhone

[Spentory](http://spentory-landingpage.herokuapp.com/) - Expense Transactions inventory for iPhone


- Submit yours to be included in this list.
