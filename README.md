# twbudget
### visualizing taiwan central government spending

![twbudget](https://raw.github.com/g0v/twbudget/master/thumbnail.png "twbudget")

## Prerequisites


### Windows 7(32-bit):

1.Install the correct Windows SDK from [here](http://go.microsoft.com/?linkid=7729279) for the Node modules requiring rebuild for installation such as bcrypt.	

2.Install Visual Studio 2008 Redistributables from [here](http://www.microsoft.com/downloads/details.aspx?familyid=9B2DA534-3E03-4391-8A4D-074B9F2BC1BF) for OpenSLL, which is for bcrypt.	

3.Install OpenSSL from [here](http://slproweb.com/download/Win32OpenSSL-1_0_1e.exe) for bcrypt.	

4.Same as below except "brew" is not available on Windows so please install below modules separately.
	
### Mac OS X and [Homebrew](http://mxcl.github.io/homebrew/):

	$ brew install node        # Install nodejs and npm
	$ brew install brew-gem    # Install sass
	$ gem install sass
	$ brew install mongodb     # Install mongodb
	$ mongod                   # Run mongodb in foreground

## build

* `npm i` to install node packages

### Running the app during development

* `brunch w &`
* `make run`

Then navigate your browser to [http://localhost:8000](http://localhost:8000)

## License

MIT http://g0v.mit-license.org/
