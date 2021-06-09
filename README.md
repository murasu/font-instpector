# TwoWindowsApp

Issue description:

The sample app that I have included has two windows. When I update any of the two text fields in the fist window, I like the text in the second window to be updated. 

Passing myObject to the second window as suggested fixes the problem.  
See included video ScreenRecording-01-NonDocument-2021-04-23.mov


However, this seems to produce undesirable results in a Document based app.
See included video ScreenRecording-02-DocumentBased-2021-04-23.mov

1. When I update the fist window, the second one does not get updated. Although I have seen instances when it does.

2. When I open a new document, fire up the second window in the new document and then edit the new document, even the second window in the first document is getting updated.  This is undesirable.

What I want is this:

1. When I open a new document (weather new or existing) and fire a second window, the update on the document should  be reflected in that second window.

2. When I open another document and fire a second window from this second document, changes to the second document should only be seen in the second window fired by the second document.

In summary: I want changes made in the document to be only seen by the second window fired from that document.

Please let me know if this makes sense and how I can achieve this.


# font-instpector
