FILE=2022-04-04-ctf-zip-parser

sd '!\[\]\(images/([^\)]+)\)' \
    "{% include figure.liquid loading=\"eager\" path=\"/assets/img/posts/${FILE}/images/\
\$1\" class=\"img-fluid rounded z-depth-1\" zoomable=true %}" \
    ${FILE}.md
