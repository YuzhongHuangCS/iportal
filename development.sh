#!/bin/bash
coffee --watch --compile *.coffee&
coffee --watch --compile wwwfiles/js/*.coffee&
jade -w -P wwwfiles/*.jade&
lessc -x bootstrap.less
nodejs app.js&

echo "The development environment is ready"