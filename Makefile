prereqs:
	cabal install -j hakyll

build:
	ghc --make site.hs
	./site rebuild

sync:
	s3cmd sync --delete-removed _site/* s3://technotes.iangreenleaf.com

.PHONY: prereqs build
