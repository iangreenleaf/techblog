prereqs:
	cabal install -j hakyll

build:
	ghc --make site.hs
	./site rebuild

sync: build
	s3cmd sync --delete-removed _site/* s3://technotes.iangreenleaf.com
	cat ~/.s3cfg | sed 's/\(guess_mime_type.*\)True/\1False/' > .tmpconfig
	s3cmd put --config=.tmpconfig --mime-type=application/rss+xml _site/*.rss s3://technotes.iangreenleaf.com
	rm .tmpconfig
	./upload_redirects s3://technotes.iangreenleaf.com
