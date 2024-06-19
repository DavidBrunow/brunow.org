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
