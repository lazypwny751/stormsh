# stormsh
Simple configure tool (like ninja build, cmake and meson) for shell scripts written in bash 5.17 and gawk language.

## INSTALLATION
```bash
git clone "https://github.com/lazypwny751/stormsh.git" && cd stormsh
sudo make install
```
## USAGE
```
There is 4 arguments for stormsh:
	not-run, nr:
		after the creatation of temp files do not run the result script.

file, f:
		change the default value of stormsh's configuration file, the default file name is Stormfile.

help, h:
		it shows this helper text screen.

	version, v:
		it shows current version 1.0.0 (major.minor.patch) of stormsh.

also there is no needed another option, just type 'stormsh' in the configuration file directory. 
```

## REQUIREMENTS
- [awk](https://git.savannah.gnu.org/git/gawk.git)
- [coreutils](https://github.com/coreutils/coreutils)

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[GPL3](https://choosealicense.com/licenses/gpl-3.0/)
