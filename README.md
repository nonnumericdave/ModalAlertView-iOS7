ModalAlertView_iOS7
===================

An implementation of modal UIAlertView for iOS 7 using the standard pattern, albeit with a horrendous modification to the run loop.  This modification allows the UIAlertViewDelegate to continue processing delegate messages as expected.

In short, Apple introduced a change to the way certain delegate messages were processed.  In this particular case, UITableViewDelegate's -[tableView:didSelectRowAtIndexPath:] is now processed via an observer we'll call CA.  In prior versions of iOS, it was processed via a timer.  Furthermore, it appears that the same observer X cannot be "fired" recursively, i.e., if we have two run loops on the stack, and the run loop at the bottom of the stack is processing observer CA, the run loop at the top of the stack will skip observer CA.

Unfortunately, observer CA is used to kick -[tableView:didSelectRowAtIndexPath:] as well as the UIAlertViewDelegate's -[alertView:didDismissWithButtonIndex:].  Thus, if we present a modal UIAlertView as a result of a UITableView row selection, for example, the UIAlertView will not send -[alertView:didDismissWithButtonIndex:] to its delegate.  In this case, there are two run loops on the stack -- the bottom run loop, which "fired" observer CA and eventually sent the -[tableView:didSelectRowAtIndexPath:] message, and the top run loop, which is part of our modal UIAlertView pattern.  Because observer CA is in a firing state inside the bottom run loop, it will never "fire" in the top run loop.

This sample is intended to prove a point, so please do not use it in production code.  There is a reason why Apple prevents observers from being reentrant.  That said, this reason contradicts their documentation.  In particular, the ["Threading Programming Guide"](https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html) specifically states the following:

It is possible to run a run loop recursively. In other words, you can call CFRunLoopRun, CFRunLoopRunInMode, or any of the NSRunLoop methods for starting the run loop from within the handler routine of an input source or timer. When doing so, you can use any mode you want to run the nested run loop, including the mode in use by the outer run loop.

Furthermore, the sample they give in Listing 3-2 is a variant of the modal UIAlertView pattern.  The [NSRunLoop documentation](https://developer.apple.com/library/mac/documentation/cocoa/reference/foundation/classes/nsrunloop_class/reference/reference.html) has another example of the same pattern in the documentation of -[run].
