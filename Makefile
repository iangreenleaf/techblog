prereqs:
	cabal install -j hakyll

build:
	ghc --make site.hs
	./site rebuild

acceptable-s3cmd-version:
	s3cmd --version | grep '\s[0-9]\.[1-9]'

sync: acceptable-s3cmd-version build
	s3cmd sync --guess-mime-type --delete-removed _site/* s3://technotes.iangreenleaf.com
	s3cmd put --mime-type=application/rss+xml _site/*.rss s3://technotes.iangreenleaf.com
