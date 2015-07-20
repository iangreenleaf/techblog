prereqs:
	cabal update
	cabal install -j alex happy
	cabal install -j hakyll pandoc

build:
	ghc --make site.hs
	./site rebuild

publish: build
	s3cmd sync --no-mime-magic --delete-removed _site/* s3://technotes.iangreenleaf.com
	s3cmd put --mime-type=application/rss+xml _site/*.rss s3://technotes.iangreenleaf.com
	s3cmd put --mime-type=application/atom+xml _site/feed.xml s3://technotes.iangreenleaf.com
	./upload_redirects s3://technotes.iangreenleaf.com
