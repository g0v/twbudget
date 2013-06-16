# twbudget
### visualizing taiwan central government spending

![twbudget](https://raw.github.com/g0v/twbudget/master/thumbnail.png "twbudget")

## Prerequisites

Mac OS X and [Homebrew](http://mxcl.github.io/homebrew/):

	$ brew install node        # Install nodejs and npm
	$ brew install brew-gem    # Install sass
	$ brew gem sass
	$ brew install mongodb     # Install mongodb
	$ mongod                   # Run mongodb in foreground

## build

* `./scripts/init.sh` to install node packages

### Running the app during development

* `brunch w &`
* `make run`

Then navigate your browser to [http://localhost:8000](http://localhost:8000)
