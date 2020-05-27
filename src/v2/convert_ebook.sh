#!/bin/bash

function filenames {
  {
    for f in guide/*.md; do
      order="$(head $f | grep order: | cut -d' ' -f2)"
      title="$(head $f | grep title: | cut -d' ' -f2-)"
      echo -e "$order\t$f\t$title"
    done
  } | sort -n | cut -f2
}

mkdir -p guide_out
for fn in $(filenames); do
  fn_out=$(echo $fn | sed -e 's/^guide/guide_out/')
  {
    # prepend header/title with anchor (using filename):
    title="$(head $fn | grep title: | cut -d' ' -f2-)"
    echo ""
    echo "# <a name="#$fn"></a>$title"
    echo ""

    # remove raw and fix links:
    <$fn awk '
      BEGIN {raw=0} {
      if ($0 == "{% raw %}") raw = 1;
      else if ($0 == "{% endraw %}") raw = 0;
      else if (!raw) print;
      }
    ' \
    | sed -e 's@href="./"@href="#index.md"@g' \
    | sed -e 's/^{% codeblock lang:js %}/```js/' \
    | sed -e 's/^{% codeblock lang:html %}/```html/' \
    | sed -e 's/^{% endcodeblock %}/```/' \
    | sed -e 's@/images/@../images/@g'
    echo ""
    echo ""
    echo ""
  } > $fn_out
done

# Pandoc will just merge anyway, so may as well merge ourselves.
{
  # Header info:
  echo "---"
  echo "title: Vue 2.x guide (docs)"
  echo "author: Vue documentation authors"
  echo "---"
  echo ""
  cat $(filenames | sed -e 's/guide/guide_out/g')
} > guide_out/MERGED.md
pandoc -o vue-guide.epub guide_out/MERGED.md
pandoc -o vue-guide.mobi guide_out/MERGED.md
