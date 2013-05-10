prereqs:
	cabal install -j hakyll

build:
	ghc --make site.hs
	./site rebuild

sync: build
	s3cmd sync --delete-removed _site/* s3://technotes.iangreenleaf.com
