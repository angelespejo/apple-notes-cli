#!/bin/bash

############################################################
# TEST                                        
############################################################

chmod a+x src/main.sh
cd src && echo "$(. ./main.sh $@ )" && cd ..


############################################################