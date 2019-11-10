#!/usr/bin/env bash

rm ./*.gem
gem build click_house.gemspec
gem push click_house-*
