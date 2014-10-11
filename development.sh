#!/bin/bash
coffee --watch --compile *.coffee&
coffee --watch --compile wwwfiles/js/*.coffee&
jade -w -P wwwfiles/*.jade&

echo "The development environment has ready!"
