#!/bin/bash

############################################################
# INSTALLATION                                           
############################################################

if [[ -d "dist" ]]; then

	chmod a+x dist/apple-notes-cli.sh
	cp dist/apple-notes-cli /usr/local/bin/
	apple-notes-cli

else 

	. ./build.sh
	cp dist/apple-notes-cli /usr/local/bin/
	apple-notes-cli

fi


############################################################