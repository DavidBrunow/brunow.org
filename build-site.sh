#! /bin/sh

swift package --allow-writing-to-directory docs generate-documentation --target Brunow --disable-indexing --output-path docs --transform-for-static-hosting --hosting-base-path brunow.org

./docc2html docs htmldocs -f

items=()

# html is in docs/documentation/brunow

for file in `find docs/data/documentation/brunow/*.json`
do
  filename=$(basename $file .json)
  # echo "$filename"
  html_file="htmldocs/documentation/brunow/$filename.html"
  # echo "$file"
  json=`cat "$file" | jq`
  # echo "$json"
  id=`printf "%s" "$json" | jq -r .identifier.url`
  title=`printf "%s" "$json" | jq -r .metadata.title`
  url="$id"
  # `awk '{printf "%s\\n", $0}' ${html_file}`
  # `sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g' "${html_file}"`
  # `sed 's/$/\\n/' "${html_file}" | tr -d '\n'`
  # `sed -i '' $'s/\r//' "${html_file}"`
  # content_html=`cat "${html_file}" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' | sed $'s/\x0D//' | sed 's/$/,/g' | sed 's/["]/\\\"/g'`
  
  content_html=`cat "${html_file}" | sed 's#\\\\#\\\\\\\\#g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g' | sed 's/["]/\\\"/g'` # | sed 's/\	//g'`
  # content_html=`sed 's/$/\\\\/g' <<<"$content_html"`
  # content_text=`echo "$json" | jq -r .primaryContentSections[].content[].inlineContent[].text`
  summary=`printf "%s" "$json" | jq -r .abstract[]?.text | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ /g'`
  date_published=`printf "%s" "$json" | jq -r .metadata.platforms[0].introducedAt | tr . -`
  if [[ "$date_published" != "null" ]]
  then
    items+=("{\"id\":\"${id}\", \"title\": \"${title}\", \"url\": \"${url}\", \"content_html\": \"${content_html}\", \"summary\": \"${summary}\", \"date_published\": \"${date_published}T23:59:59-06:00\"}")
  fi
done
PREVIOUS_IFS=IFS
IFS=,
feed_json="{\"version\": \"https://jsonfeed.org/version/1.1\", \"user_comment\": \"Meow meow meow\", \"title\": \"Brunow\", \"home_page_url\": \"https://brunow.org/\", \"feed_url\": \"https://brunow.org/feed.json\", \"items\": [${items[*]}]}"
IFS=PREVIOUS_IFS
printf "%s" "$feed_json" > docs/documentation/brunow/feed.json

rm -rf htmldocs