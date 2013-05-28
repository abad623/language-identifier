Vicom-language-identifier-lite_kernel
=====================================

Kernel for language detection lite version.

## Prerequisites

  * Perl: Text/ExtractWords.pm, please refer to https://github.com/gitpan/Text-ExtractWords and read the readme there so see how to install there.

## Installation


Add this line to your application's Gemfile:

    gem 'Vicom-language-identifier-lite_kernel', :git=>"git@github.com:opener-project/Vicom-language-identifier-lite_kernel.git"

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem specific_install Vicom-language-identifier-lite_kernel -l https://github.com/opener-project/Vicom-language-identifier-lite_kernel.git

## Usage

Once installed as a gem you can access the gem from anywhere:

This aplication reads a text from standard input in order to identify language.

Usage: Vicomtech-language-identifier-lite_kernel [OPTION]

1. -d,	(optional) extends language detection,

	without this flag application detects:
	english (en), french (fr), spanish (es), italian (it),
	german (de) and dutch (nl).
	with this flag application detects:
	english (en), french (fr), spanish (es), portugese (pt),
	italian (it), german (de), dutch (nl), swedish (sv),
	norwegian (no) and danish (da).

2. --help,	outputs aplication help.

Example: cat english_text.txt | Vicomtech-language-identifier-lite_kernel -d

Will output:

en


## Contributing

1. Pull it
2. Create your feature branch (`git checkout -b features/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin features/my-new-feature`)
5. If you're confident, merge your changes into master.
