proj:
	@swift package generate-xcodeproj
build:
	@swift build
release:
	@swift build -c release
	
releaseXcodeLatest:
	@swift build -c release -Xswiftc -DXCODE_LATEST
	
run:
	@swift run
toolVersion:
	@swift package tools-version

rb:
	@swift build && swift run

deploy:
	cp .build/release/iswift /usr/local/share/jupyter/kernels/swift/iswift

rd: 
	@swift build -c release
	@cp .build/release/iswift /usr/local/share/jupyter/kernels/swift/iswift

jupyterInstall:
	jupyter-kernelspec install kernel.json

jupyter:
	jupyter notebook --NotebookApp.token=