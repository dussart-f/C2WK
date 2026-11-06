#!/bin/bash

postqueue -p
postsuper -s
postsuper -p
postsuper -d ALL
postqueue -p