run:
	mkdir -p emulator/lab_5_nodes/shared/commands
	python3 generate_tables.py 5
	python3 generate_commands_5_nodes.py emulator/lab_5_nodes/shared/commands
	rm -Rf $$(pwd)/emulator/lab_5_nodes/shared/p4src
	rm -Rf $$(pwd)/emulator/lab_5_nodes/shared/*.txt
	cp -r p4src $$(pwd)/emulator/lab_5_nodes/shared
	kathara lstart -d $$(pwd)/emulator/lab_5_nodes s1 s2 s3 s4 s5 h1 h5

clean:
	kathara lclean -d $$(pwd)/emulator/lab_5_nodes