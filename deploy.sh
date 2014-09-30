#!/bin/bash
# compile
coffee --compile *.coffee
coffee --compile wwwfiles/js/*.coffee
lessc -x wwwfiles/css/style.less wwwfiles/css/style.css
jade wwwfiles/*.jade

# compress
uglifyjs wwwfiles/js/script.js --compress -o script.js

echo "The files are ready to deploy."