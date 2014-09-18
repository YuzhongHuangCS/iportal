#!/bin/bash
coffee --compile *.coffee
coffee --compile wwwfiles/js/*.coffee
lessc -x wwwfiles/css/style.less wwwfiles/css/style.css
jade wwwfiles/*.jade

echo "The files are ready to deploy."