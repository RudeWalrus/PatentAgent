# PatentAgent [![Build Status](https://secure.travis-ci.org/rudewalrus/patentagent.png)](http://travis-ci.org/rudewalrus/patentagent) [![Dependency Status](https://gemnasium.com/rudewalrus/patentagent.png)](https://gemnasium.com/rudewalrus/patentagent)

## Installation

  gem install patentagent

## Usage

    require 'patentagent'

    # Snarf a patent from the PTO
    PatentAgent.fetch("US6266379")
