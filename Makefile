run:
	python3 generate_tables.py 5
	python3 generate_commands.py
	rm -Rf $$(pwd)/emulator/lab/shared/p4src
	rm -Rf $$(pwd)/emulator/lab/shared/*.txt
	cp -r p4src $$(pwd)/emulator/lab/shared
	kathara lstart -d $$(pwd)/emulator/lab s1 s2 h1 h5

clean:
	kathara lclean -d $$(pwd)/emulator/lab