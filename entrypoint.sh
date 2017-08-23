#!/bin/bash

osbs-box-update-hosts

exec atomic-reactor --verbose inside-build --input osv3
