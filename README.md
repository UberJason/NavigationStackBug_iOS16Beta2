# NavigationStackBug_iOS16Beta2

## Overview:
* Two types of data objects: Plans and Entries. A Plan may contain multiple Entries.
* Three levels of screens: All Plans View, Plan Details View, Entry Details View. Each one is a drill-down detail view of the previous.

## Problem: 
If initializing the navigation stack on Plan 1 Details view, and then drill into Entry 1 Details view, I expect the navigation stack to be All Plans view > Plan Details view > Entry Details view. 

Instead, the navigation stack is All Plans view > Entry Details 1 view > Entry Details 1 view.

In other words, Entry Details 1 view is duplicated in the stack, while Plan Details 1 view is gone.

Once you pop all the way back to root (All Plans view), then navigation starts to behave as expected again.


![Recording of the 
bug](https://github.com/UberJason/NavigationStackBug_iOS16Beta2/blob/main/BugRecording.gif)
