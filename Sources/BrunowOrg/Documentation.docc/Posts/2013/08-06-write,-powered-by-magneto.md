# Write, Powered by Magneto
date: 2013-08-06T22:24:11-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
In my original [post about Don Melton's Magneto][linkMagnetoPost], I said that one of the disadvantages of using Magneto is that there was no good way to write a post on mobile devices. When I wrote that, I had every intention of building an iOS app to work with Magneto. I am proud to [open source a beta version of that project today][linkGithub], which I am calling Write, Powered by Magneto in my typical pattern of naming things generically.

I am not planning to make any further commits to this project until iOS 7 is out to avoid releasing any code that is under NDA.

And yes, I know it's ugly (especially on iOS 6.) Adding design, and hopefully a bit of delight, are next on my to do list.

Prerequisites
-------------
+ You must have your Magneto blog's folders linked to Dropbox in some way, whether it be by symlinking Dropbox folders to your local directories or by storing all of your directory tree in Dropbox directly. Write uses Dropbox to keep all of the draft, post, images and video in sync and accessible on iOS.

+ You must have a Dropbox Core API key, which you can [get from Dropbox][linkDropboxKey].

+ You must have Xcode so that you can build the app

+ You will need to make your own "Credentials.h" file in your project. It will need to look something like this (or you can look at my commit history, because I accidentally committed it...whoops!):

        #ifndef Write_Credentials_h
        #define Write_Credentials_h

        #define CONSUMER_KEY @"your Dropbox key goes here"
        #define CONSUMER_SECRET @"your Dropbox secret goes here"
        #define USER_NAME_TOKEN @"choose a name for the oauth token to be saved in the keychain"
        #define USER_NAME_TOKEN_SECRET @"choose a name for the oauth token secret to be saved in the keychain"
        #define USER_NAME_USER_NAME @"choose a name for the user name to be saved in the keychain"
        #define SERVICE_NAME @"choose a service name under which to save the keychain information"

        #endif

+ As specified in the Dropbox Core API setup instructions, you will need to change this section of "Write-info.plist" to have your Dropbox key after the "db-":

        <key>CFBundleURLTypes</key>
	    <array>
		    <dict>
			    <key>CFBundleURLSchemes</key>
			    <array>
				    <string>db-0bzv4hxmz3d1144</string>
			    </array>
		    </dict>
	    </array> 

About Write, Powered by Magneto
-------------------------------
While designing Write, I tried my best to keep true to the way that Don designed Magneto. To that end, Write is designed simply, with no underlying database. The app relies only on the file system in Dropbox and two preferences that are stored about your blogs: the location of the blogs in Dropbox and the index of the blog you are currently viewing.

This approach has at least one limitation that I have run into so far &mdash; since all of the information about your drafts and your posts is stored in memory, a large number of either could overwhelm the relatively small amount of memory available on your iOS device. I have done my best to keep that impact to a minimum.

My other major design goal was to enable the user to complete the entire drafting and posting process inside the app. That is another reason I [created the html5video plugin][linkMagnetoRevisited] for my daughter's site - I can easily and directly take the video on the device and upload it to Dropbox. In this version, any cropping of videos or images must be done in the Photos app, but at least everything can be done on the phone.

Limitations
-----------
Since the iOS app is not actually putting the file on your server when you press the "Post" button, some other process must be running to do so. The two options that I know of to do that are to be running Magneto in auto mode on your Mac, or to be running Magneto in auto mode on your server, with the Dropbox files shared to your server.

Currently, I am doing neither of those &mdash; I am manually deploying to my server after posting in the iOS app.

Walkthrough
-----------
When you first open Write, after connecting to your Dropbox account, you will be shown a list of directories that might contain Magneto sites.

<img src='/media/2013/08/Blogchoosingscreen.JPG' alt='Blog choosing screen' />

Upon choosing the site or sites that you want to have available in Write, you are taken to a list of the sites you have selected. You can choose one to see the drafts and posts for that blog.

<img src='/media/2013/08/Availableblogs.JPG' alt='Available blogs' />

Once you have chosen the blog you want to see, you will be shown a list of the file names for your drafts on that blog. Using the segmented controller at the top, you can choose to see the ten most recent posts.

From this screen, you can choose a draft or post to see and edit the contents, or you can click on the "New Draft" button to create a new draft.

<img src='/media/2013/08/Draftsformyblog.JPG' alt='Drafts for my blog' />

The view of the draft is simply the content of the markdown file. As you can see in the screenshot, nothing is wysiwyg. It is the exact same thing you would see if you were editing the file in Sublime Text 2 on your Mac.

<img src='/media/2013/08/EditingaDraft.JPG' alt='Editing a Draft' />

As you can see in this next screenshot, I haven't put anything nice like a keyboard tray with common markdown keys in this version, but probably will in the future. You will also see a "Save" button. That button will upload the file to Dropbox, as will going back to the drafts screen. The file is automatically saved locally every five seconds. I have also included a button to add media, whether an image or a video. As I said before, this button will add the media to your Dropbox and place the proper tag at the cursor location in your file.

<img src='/media/2013/08/EditingaDraftwithKeyboard.JPG' alt='Editing a Draft with Keyboard' />

I think I am handling conflict resolution for the versions of files in a conservative manner. If the copy of the file on the local file system was modified after the copy on Dropbox, then Write updates the copy on Dropbox with the local copy. If the local file was modified before the Dropbox copy then Write creates a new "conflicted" version of the file.

From the draft editing screen, you can choose the "Post" button to move the file from the Drafts folder to the items/current year folder. Choosing that button will change the time stamp in the file to the current time and change the name of the file to the name on the title line, if they differ.

Conclusion
----------
I hope you find Write useful.

If you would like to contact me for bug reporting or any other reason, I am on twitter @davidbrunow or you can email me at helloDavid@brunow.org.

[linkMagnetoPost]: <http://brunow.org/2013/03/27/magneto/>
[linkDropboxKey]:<https://www.dropbox.com/m/login?cont=https%3A//www.dropbox.com/developers/apps>
[linkMagnetoRevisited]:<http://brunow.org/2013/07/14/magneto-revisited/>
[linkGithub]:<https://github.com/DavidBrunow/Write--Powered-by-Magneto>






