prereqs:
	cabal install -j hakyll

build:
	ghc --make site.hs
	./site rebuild

.PHONY: prereqs build
