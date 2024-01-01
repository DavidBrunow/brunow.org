# iOS Developer Mapping Options Update
date: 2016-06-11T18:31:22-05:00
@Metadata {
  @Available("Brunow", introduced: "2017.01.20")
  @PageColor(purple)
}
Back in November I [tested the maximum zoom levels of three different mapping options](https://brunow.org/2015/11/04/ios-developer-mapping-options/). The three options I tried were the built in Apple Maps using MapKit, Mapbox, and Google Maps. Back in February Mapbox [released a new version of their iOS SDK](https://www.mapbox.com/blog/ios-sdk-3.1.0/) that with one feature being higher zoom levels and today I got around to testing how that impacts my initial results.

Below I've put what each looks like running on an iPad Mini 4 running iOS 9. Obviously, the data for each location on Earth could vary across all three services and my one data point doesn't provide enough information to answer every question about how each of them will work for you. To try to help that, I've put [the source code for my test app on Github](https://github.com/DavidBrunow/iOS-Map-Testing) so you can test locations around you. If you happen to use it, I'd love to hear about your results!

Apple Maps
<img src='/media/2016/06/AppleMaps.JPG' alt='Apple Maps' />

Mapbox
<img src='/media/2016/06/Mapbox.JPG' alt='Mapbox' />

Google Maps
<img src='/media/2016/06/GoogleMaps.JPG' alt='Google Maps' />

As you can see, Google Maps is still the clear leader in quality. What you don't know from that picture that I do is that the building in it is under construction currently and that construction only shows up on the Google map &mdash; so their imagery is not only higher quality but fresher as well.

Mapbox does allow greater zooming than in the last version I tested but for at least this location the imagery is too low quality for the extra zooming to matter.
