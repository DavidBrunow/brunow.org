# DocC JSON Feed

Stacking a pile of hacks to provide a fundamental part of a blog to my DocC site
– a machine-parsable feed with updates as I post new things.

@Metadata {
  @Available("Brunow", introduced: "2024.06.19")
  @PageColor(purple)
  @PageImage(
    purpose: card,
    source: "jsonFeed",
    alt: "Screenshot of the JSON from the JSON feed that I talk about in this post."
  )
}

As I've talked about in a [previous post](<doc:06-29-blog-as-documentation>), I
decided to start using DocC for my personal blog just about a year ago. In that
post I mentioned three things that I did not like about using DocC this way:

> Quote: 
> * The site that DocC generates is very opinionated about looking like Apple's
> documentation. This makes perfect sense for its intended purpose, but I'm not
> sure how I feel about it for this purpose I'm misusing it for.
> * The site that DocC generates has a base path of "documentation/MODULE_NAME"
> but I'd rather the site were at the root with no extra path. But really, do
> people care what URL they are linked to for a blog post? I don't.
> * I don't believe that DocC generates an RSS feed which is my favorite way of
> consuming a blog.

After using it for a year, I think I like the style of my blog that looks like
documentation. And like a year ago, I don't really care about the URL structure
of my blog. I could not remember the URL for my blog, so I created a redirect
from brunow.org to the blog so that's all I needed to remember – the rest is
fine by me.

But the third bullet has been bothering me, so I decided to do
something about it – I've strung together a handful of tools to create a JSON
feed every time I rebuild my site. I'll talk through how I did that.

## Hacking Together a JSON Feed

Building a DocC site from the command line requires running a command similar to
this:

```sh
swift package --allow-writing-to-directory docs \
  generate-documentation --target Brunow --disable-indexing \
  --output-path docs --transform-for-static-hosting \
  --hosting-base-path brunow.org
```

That's quite a bit to type, so from the beginning I've used a super simple
script called `build-site.sh` to run this command:

```sh
#! /bin/sh

swift package --allow-writing-to-directory docs \
  generate-documentation --target Brunow --disable-indexing \
  --output-path docs --transform-for-static-hosting \
  --hosting-base-path brunow.org
```

This script is the perfect place to add logic to build my feed.

JSON feeds have [a detailed specification](https://www.jsonfeed.org/version/1.1/),
which, in my opinion, makes this problem more fun to solve. I find something
satisfying about having a well-defined problem space and implementing it to the
specification. The icing on top of that satisfaction is the fact that I have a
specific purpose, so I don't need to build a general purpose thing (which is
much more difficult). I get to focus on my use case and making it work well.

In the JSON feed specification I see two different types of data: static and
dynamic. The static data will be the same every time my feed is generated, and
that data can be hardcoded. It could look like this, easy peasy:

```sh
items=()

PREVIOUS_IFS=IFS
IFS=,
feed_json="{\"version\": \"https://jsonfeed.org/version/1.1\", \"title\": \"Brunow\", \"home_page_url\": \"https://brunow.org/\", \"feed_url\": \"https://davidbrunow.github.io/brunow.org/documentation/brunow/feed.json\", \"items\": [${items[*]}]}"
IFS=PREVIOUS_IFS

printf "%s" "$feed_json" > docs/documentation/brunow/feed.json
```

I find handwriting JSON simple and straightforward, so that's what I've done.
The static data is the version, title, home page URL, and feed URL. In
anticipation of adding the dynamic data, I've created an array of items and I've
added them to the static JSON – I'll fill out that dynamic data in the items
array in a bit. The `IFS` part will be used later – it will join the items in
the items array with a comma. On the last line we print the JSON to a file.
Before we add the dynamic data, let's look at what our JSON will look like so
far, formatted in a nicer way:

```json
{
    "version": "https://jsonfeed.org/version/1.1",
    "title": "Brunow",
    "home_page_url": "https://brunow.org/",
    "feed_url": "https://davidbrunow.github.io/brunow.org/documentation/brunow/feed.json",
    "items": []
}
```

OK, looks good, let's move on to the dynamic content. We need to fill in that
items array with posts. Looking at the JSON feed spec, we need data for these
fields:

* `content_html`
* `date_published`
* `id`
* `summary`
* `title`
* `url`

Fortunately, DocC generates an entire folder of JSON files which describe
the posts, and we can use values from that JSON to create our items. We'll use
[`jq`](https://jqlang.github.io/jq/) to parse the JSON:

```sh
for file in docs/data/documentation/brunow/*.json
do
  json=`cat "$file" | jq`
  id=`printf "%s" "$json" | jq -r .identifier.url`
  title=`printf "%s" "$json" | jq -r .metadata.title`
  url=`printf "%s" "$id" | sed 's#doc://Brunow/documentation/Brunow/#https://davidbrunow.github.io/brunow.org/documentation/brunow/#g'`
  summary=`printf "%s" "$json" | jq -r .abstract[]?.text | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g'`
  date_published=`printf "%s" "$json" | jq -r .metadata.platforms[0].introducedAt | tr . -`

  content_html="where can we get this!?!"

  if [[ "$date_published" != "null" ]]
  then
    items+=("{\"id\":\"${id}\", \"title\": \"${title}\", \"url\": \"${url}\", \"content_html\": \"${content_html}\", \"summary\": \"${summary}\", \"date_published\": \"${date_published}T23:59:59-06:00\"}")
  fi
done
```

We loop over each JSON file in the directory, extract the JSON into a variable
with `jq`, then parse different values from the JSON variable using `jq`, `sed`,
and `tr`. Here is what one of those items would look like at this point:

```json
{
  ...
  items: [
    {
        "id": "doc://Brunow/documentation/Brunow/01-01-celebrations",
        "title": "Celebrations",
        "url": "https://davidbrunow.github.io/brunow.org/documentation/brunow/01-01-celebrations",
        "content_html": "where can we get this!?!",
        "summary": "",
        "date_published": "2016-01-01T23:59:59-06:00"
    },
    ...
  ]
}
```

Most of the fields have obvious counterparts in the documentation
JSON, but we have to get creative to figure out the `date_published` and
`content_html` fields.

For the `date_published` field, past me set myself up for success by using a
date format for the version the documentation applies to, as you can see in the
following screenshot. Therefore, I simply need to grab that version and reformat
it for the date format that JSON feeds expect. Then I'm good to go.

![Screenshot of the top of one of my recent blog posts, showing that the "version" is "Brunow 2024.05.27+", where 2024.05.27 represents the date that I published the post.](dateBasedVersioning)

The `content_html` field is not as straightforward. Despite the fact that DocC
builds documentation that can be hosted on a web server, it does not build HTML.
Instead, it creates a single page application (SPA) that uses JavaScript to
parse the documentation's JSON for rendering. Fortunately, Helge Heß has an open
source project, [`docc2html`](https://github.com/DoccZz/docc2html?tab=readme-ov-file),
which takes the output of the DocC generation and parses it into HTML in a very
similar directory structure. We can use that tool like so:

```sh
./docc2html docs htmldocs -f -t ../docc2html/Templates
```

`docs` is the output folder from DocC, and `htmldocs` is where I want
`docc2html` to output the HTML. I use `-t` to point to the `docc2html/Templates`
folder because I overrode the header in the templates and I want to use that
instead of the default. After running this, we have a folder full of HTML
files, each of which pairs up with a JSON file in our DocC output. And they are
both named the same, aside from their extensions being different. That makes it
easy to add this code to our shell script to set the `content_html`:

```diff
...
for file in docs/data/documentation/brunow/*.json
do
  ...
  date_published=`printf "%s" "$json" | jq -r .metadata.platforms[0].introducedAt | tr . -`

+  filename=$(basename $file .json)
+  html_file="htmldocs/documentation/brunow/$filename.html"
+  content_html=`cat "${html_file}" | sed 's#\\\\#\\\\\\\\#g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\n/g' | sed 's/["]/\\\"/g'`

  if [[ "$date_published" != "null" ]]
  ...
done
...
```

We get the filename without the extension from the JSON filename, then use that
filename to set a variable with the contents of the HTML file, plus some
escaping to ensure the HTML doesn't break our JSON.

And that's it! I now have a [JSON feed that folks can subscribe to](https://davidbrunow.github.io/brunow.org/documentation/brunow/feed.json) to get my
latest posts. This solution is not elegant, and it is definitely not performant.
But despite being all kinds of hacky, it solves a real problem – even if it has
limitations, like not working with some feed services. Here's what my script
looks like after putting everything together ([GitHub link](https://github.com/DavidBrunow/brunow.org/blob/main/build-site.sh)):

```sh
#! /bin/sh

swift package --allow-writing-to-directory docs \
  generate-documentation --target Brunow --disable-indexing \
  --output-path docs --transform-for-static-hosting \
  --hosting-base-path brunow.org

./docc2html docs htmldocs -f -t ../docc2html/Templates

items=()

for file in docs/data/documentation/brunow/*.json
do
  json=`cat "$file" | jq`
  id=`printf "%s" "$json" | jq -r .identifier.url`
  title=`printf "%s" "$json" | jq -r .metadata.title`
  url=`printf "%s" "$id" | sed 's#doc://Brunow/documentation/Brunow/#https://davidbrunow.github.io/brunow.org/documentation/brunow/#g'`
  summary=`printf "%s" "$json" | jq -r .abstract[]?.text | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g'`
  date_published=`printf "%s" "$json" | jq -r .metadata.platforms[0].introducedAt | tr . -`

  filename=$(basename $file .json)
  html_file="htmldocs/documentation/brunow/$filename.html"
  content_html=`cat "${html_file}" | sed 's#\\\\#\\\\\\\\#g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\\n/g' | sed 's/["]/\\\"/g'`

  if [[ "$date_published" != "null" ]]
  then
    items+=("{\"id\":\"${id}\", \"title\": \"${title}\", \"url\": \"${url}\", \"content_html\": \"${content_html}\", \"summary\": \"${summary}\", \"date_published\": \"${date_published}T23:59:59-06:00\"}")
  fi
done

PREVIOUS_IFS=IFS
IFS=,
feed_json="{\"version\": \"https://jsonfeed.org/version/1.1\", \"title\": \"Brunow\", \"home_page_url\": \"https://brunow.org/\", \"feed_url\": \"https://davidbrunow.github.io/brunow.org/documentation/brunow/feed.json\", \"items\": [${items[*]}]}"
IFS=PREVIOUS_IFS

printf "%s" "$feed_json" > docs/documentation/brunow/feed.json

rm -rf htmldocs
```
