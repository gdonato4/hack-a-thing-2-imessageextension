# ImessageCollaborativeDrawing
# By Andrew Ogren and Alex Beals

### What We Attempted to Build
We attempted to build a collaborative drawing imessage app. Essentially, you could make a drawing, send it to a friend, and then they could click 
on that image and edit the drawing. Ideally, the drawing feature would incorporate the option for using different colors as well as an eraser feature.

### Who Did What
Andrew wrote the base code to get the drawing functionality, added the multiple colors, and image uploading. We attempted to follow this tutorial https://www.raywenderlich.com/18840/how-to-make-a-simple-drawing-app-with-uikit, but
the code was buggy and adjustments had to be made. Alex added buttons to launch the drawing screen and to send the message, as well as the eraser.

### What We Learned
The big takeaway from this is that auto-layout and constraints are very hard to use in the imessage environment. There is a compact view and
an expanded view, and it's easy to have constraints get messed up so that certain elements such as buttons don't show up on the screen. We both furthered
our knowledge of swift, the messages framework, and UIKit.

### What Didn't Work
Constraints were a big pain, and there are definitely still some bugs revolved around constraints and objects not being in the positions that they
should be. The collaborative part of the app also did not work as planned, and we were not able to get it to be fully functional. Essentially, we thought we would be able to access the image on the receiving end and load it into the imessage extension when it was clicked on. However, Apple does not allow you to do this. The only way to do it is to push the image to a server and then send the url as a payload to the receiver so that they can request the image from the server.
