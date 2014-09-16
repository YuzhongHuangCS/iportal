#!/bin/bash
coffee --compile *.coffee
coffee --compile wwwfiles/js/*.coffee
jade wwwfiles/*.jade

echo "The files is ready to deploy"